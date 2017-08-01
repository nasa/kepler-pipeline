/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * This file is available under the terms of the NASA Open Source Agreement
 * (NOSA). You should have received a copy of this agreement with the
 * Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
 * 
 * No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
 * WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
 * INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
 * WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
 * INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
 * FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
 * TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
 * CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
 * OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
 * OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
 * FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
 * REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
 * AND DISTRIBUTES IT "AS IS."
 * 
 * Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
 * AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
 * SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
 * THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
 * EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
 * PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
 * SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
 * STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
 * PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
 * REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
 * TERMINATION OF THIS AGREEMENT.
 */

package gov.nasa.kepler.hibernate.dv;

import static gov.nasa.kepler.hibernate.dv.DvTestUtils.createCentroidOffsets;
import static gov.nasa.kepler.hibernate.dv.DvTestUtils.createImageCentroid;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.dv.DvCrud.DvPlanetSummary;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import org.hibernate.HibernateException;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Unit tests of the DV data model.
 * 
 * @author Bill Wohler
 */
public class DvCrudTest {

    private static final int PIXEL_STATISTICS = 16;
    private static final int MODEL_PARAMETERS_COUNT = 2;
    private static final int PIXEL_CORRELATION_RESULTS_COUNT = 2;
    private static final int DIFFERENCE_IMAGE_RESULTS_COUNT = 2;
    private static final int DIFFERENCE_IMAGE_PIXEL_DATA_COUNT = 16;
    private static final int SINGLE_TRANSIT_FITS_COUNT = 2;
    private static final int START_CADENCE = 4242;
    private static final int END_CADENCE = 424242;
    private static final int KEPLER_ID = 42;
    private static final int PLANET_NUMBER = 1;
    private static final int TARGET_TABLE_ID = 42;
    private static final FluxType FLUX_TYPE = FluxType.SAP;
    private static final int CCD_MODULE = 4;
    private static final int CCD_OUTPUT = 2;
    private static final int QUARTER = 2;
    private static final int CCD_ROW = 422;
    private static final int CCD_COLUMN = 244;
    private static final String LIMB_DARKENING_MODEL_NAME = "kepler_nonlinear_limb_darkening_model";
    private static final float COEFFICIENT1 = 0.42F;
    private static final float COEFFICIENT2 = 0.042F;
    private static final float COEFFICIENT3 = 0.0042F;
    private static final float COEFFICIENT4 = 0.00042F;
    private static final int PLANET_CANDIDATE_COUNT = 2;
    private static final String QUARTERS_OBSERVED = "O";
    private static final String PROVENANCE = "provenance";
    private static final DvQuantityWithProvenance EFFECTIVE_TEMP = createQuantityWithProvenance(
        1.0F, PROVENANCE);
    private static final DvQuantityWithProvenance LOG10_METALLICITY = createQuantityWithProvenance(
        2.0F, PROVENANCE);
    private static final DvQuantityWithProvenance LOG10_SURFACE_GRAVITY = createQuantityWithProvenance(
        3.0F, PROVENANCE);
    private static final DvQuantityWithProvenance RADIUS = createQuantityWithProvenance(
        4.0F, PROVENANCE);
    private static final long PIPELINE_INSTANCE_ID = 4;
    private static final String MODEL_DESCRIPTION = "Test model description.";
    private static final String TRANSIT_NAME_MODEL_DESCRIPTION = "Test name model description.";
    private static final String TRANSIT_PARAMETER_MODEL_DESCRIPTION = "Test parameter model description.";
    private static final int DETREND_FILTER_LENGTH = 420;

    private static final String MAT_FILE_EXTENSION = ".mat";
    private static final int TEST_PULSE_DURATION_LC = 10;

    private List<UkirtImageBlobMetadata> ukirtImageBlobMetadataList1;
    private List<UkirtImageBlobMetadata> ukirtImageBlobMetadataList2;

    private UkirtImageBlobMetadata ukirtImageBlobMetadata1;
    private UkirtImageBlobMetadata ukirtImageBlobMetadata2;

    private DatabaseService databaseService;
    private DvCrud dvCrud;
    private ReflectionEquals reflectionEquals;
    private List<DvPlanetResults> planetResultsList;
    private ArrayList<DvLimbDarkeningModel> limbDarkeningModelList;
    private ArrayList<DvTargetResults> targetResultsList;
    private ArrayList<DvExternalTceModelDescription> modelDescriptionsList;
    private ArrayList<DvTransitModelDescriptions> transitModelDescriptionsList;
    private long maxPipelineInstanceId;
    private PipelineTask pipelineTask;
    private PipelineInstance pipelineInstance;

    @Before
    public void setUp() throws Exception {
        maxPipelineInstanceId = -1L;

        // For code coverage only.
        new DvCrud();

        // System.setProperty("hibernate.show_sql", "true");
        databaseService = DatabaseServiceFactory.getInstance();
        dvCrud = new DvCrud(databaseService);

        TestUtils.setUpDatabase(databaseService);

        reflectionEquals = new ReflectionEquals();
        reflectionEquals.excludeField(".*\\.uowTask");
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    @Test
    public void testDelete() {
        // Also asserts that retrieveAllPlanetResults always returns a non-null
        // list.
        assertEquals(0, dvCrud.retrieveAllPlanetResults()
            .size());
        assertEquals(0, dvCrud.retrieveAllLimbDarkeningModels()
            .size());
        assertEquals(0, dvCrud.retrieveAllTargetResults()
            .size());

        populateObjects();

        assertEquals(3, dvCrud.retrieveAllPlanetResults()
            .size());
        assertEquals(3, dvCrud.retrieveAllLimbDarkeningModels()
            .size());
        assertEquals(3, dvCrud.retrieveAllTargetResults()
            .size());

        databaseService.beginTransaction();
        dvCrud.deletePlanetResultsCollection(dvCrud.retrieveAllPlanetResults());
        dvCrud.deleteLimbDarkeningModelCollection(dvCrud.retrieveAllLimbDarkeningModels());
        dvCrud.deleteTargetResultsCollection(dvCrud.retrieveAllTargetResults());
        databaseService.commitTransaction();

        assertEquals(0, dvCrud.retrieveAllPlanetResults()
            .size());
        assertEquals(0, dvCrud.retrieveAllLimbDarkeningModels()
            .size());
        assertEquals(0, dvCrud.retrieveAllTargetResults()
            .size());
    }

    @Test
    public void testRetrieveAllPlanetResults() throws IllegalAccessException {
        populateObjects();

        List<DvPlanetResults> planetResults = dvCrud.retrieveAllPlanetResults();
        assertEquals(3, planetResults.size());
        reflectionEquals.assertEquals(planetResultsList.get(2),
            planetResults.get(0));
        reflectionEquals.assertEquals(planetResultsList.get(0),
            planetResults.get(1));
        reflectionEquals.assertEquals(planetResultsList.get(1),
            planetResults.get(2));
    }

    @Test
    public void testRetrieveAllLimbDarkeningModels()
        throws IllegalAccessException {
        populateObjects();

        List<DvLimbDarkeningModel> limbDarkeningModels = dvCrud.retrieveAllLimbDarkeningModels();
        assertEquals(3, limbDarkeningModels.size());
        reflectionEquals.assertEquals(limbDarkeningModelList.get(2),
            limbDarkeningModels.get(0));
        reflectionEquals.assertEquals(limbDarkeningModelList.get(0),
            limbDarkeningModels.get(1));
        reflectionEquals.assertEquals(limbDarkeningModelList.get(1),
            limbDarkeningModels.get(2));
    }

    @Test
    public void testRetrieveAllTargetResults() throws IllegalAccessException {
        populateObjects();

        List<DvTargetResults> targetResults = dvCrud.retrieveAllTargetResults();
        assertEquals(3, targetResults.size());
        reflectionEquals.assertEquals(targetResultsList.get(2),
            targetResults.get(0));
        reflectionEquals.assertEquals(targetResultsList.get(0),
            targetResults.get(1));
        reflectionEquals.assertEquals(targetResultsList.get(1),
            targetResults.get(2));
    }

    @Test
    public void testRetrieveAllPlanetResultsForKeplerId()
        throws IllegalAccessException {

        populateObjects();

        List<DvPlanetResults> planetResults = dvCrud.retrieveAllPlanetResults(KEPLER_ID);
        assertEquals(1, planetResults.size());
        reflectionEquals.assertEquals(planetResultsList.get(0),
            planetResults.get(0));
    }

    @Test
    public void testRetrieveAllLimbDarkeningModelsForKeplerId()
        throws IllegalAccessException {

        populateObjects();

        List<DvLimbDarkeningModel> limbDarkeningModels = dvCrud.retrieveAllLimbDarkeningModels(KEPLER_ID);
        assertEquals(1, limbDarkeningModels.size());
        reflectionEquals.assertEquals(limbDarkeningModelList.get(0),
            limbDarkeningModels.get(0));
    }

    @Test
    public void testRetrieveAllTargetResultsForKeplerId()
        throws IllegalAccessException {

        populateObjects();

        List<DvTargetResults> targetResults = dvCrud.retrieveAllTargetResults(KEPLER_ID);
        assertEquals(1, targetResults.size());
        reflectionEquals.assertEquals(targetResultsList.get(0),
            targetResults.get(0));
    }

    @Test
    public void testRetrieveLatestCompletedPlanetResults() throws Exception {
        populateObjects();

        populateMoreObjects();

        List<DvPlanetResults> planetResults = dvCrud.retrieveLatestCompletedOrErredPlanetResultsBeforePipelineInstance(maxPipelineInstanceId);
        assertEquals(3, planetResults.size());

        Set<Integer> keplerIdsSeen = new HashSet<Integer>();
        for (DvPlanetResults p : planetResults) {
            PipelineInstance pipelineInstance = p.getPipelineTask()
                .getPipelineInstance();
            assertEquals(PipelineInstance.State.COMPLETED,
                pipelineInstance.getState());
            assertTrue(pipelineInstance.getId() <= maxPipelineInstanceId);
            assertFalse(keplerIdsSeen.contains(p.getKeplerId()));
            keplerIdsSeen.add(p.getKeplerId());
        }
        assertEquals(3, keplerIdsSeen.size());
    }

    @Test
    public void testRetrieveLatestCompletedLimbDarkeningModels()
        throws Exception {
        populateObjects();

        populateMoreObjects();

        List<DvLimbDarkeningModel> limbDarkeningModels = dvCrud.retrieveLatestCompletedOrErredLimbDarkeningModelsBeforePipelineInstance(maxPipelineInstanceId);
        assertEquals(3, limbDarkeningModels.size());

        Set<Integer> keplerIdsSeen = new HashSet<Integer>();
        for (DvLimbDarkeningModel model : limbDarkeningModels) {
            PipelineInstance pipelineInstance = model.getPipelineTask()
                .getPipelineInstance();
            assertEquals(PipelineInstance.State.COMPLETED,
                pipelineInstance.getState());
            assertTrue(pipelineInstance.getId() <= maxPipelineInstanceId);
            assertFalse(keplerIdsSeen.contains(model.getKeplerId()));
            keplerIdsSeen.add(model.getKeplerId());
        }
        assertEquals(3, keplerIdsSeen.size());
    }

    @Test
    public void testRetrieveLatestCompletedTargetResults() throws Exception {
        populateObjects();

        populateMoreObjects();

        List<DvTargetResults> targetResults = dvCrud.retrieveLatestCompletedOrErredTargetResultsBeforePipelineInstance(maxPipelineInstanceId);
        assertEquals(3, targetResults.size());

        Set<Integer> keplerIdsSeen = new HashSet<Integer>();
        for (DvTargetResults results : targetResults) {
            PipelineInstance pipelineInstance = results.getPipelineTask()
                .getPipelineInstance();
            assertEquals(PipelineInstance.State.COMPLETED,
                pipelineInstance.getState());
            assertTrue(pipelineInstance.getId() <= maxPipelineInstanceId);
            assertFalse(keplerIdsSeen.contains(results.getKeplerId()));
            keplerIdsSeen.add(results.getKeplerId());
        }
        assertEquals(3, keplerIdsSeen.size());
    }

    @Test
    public void testRetrieveLatestPlanetResults() throws Exception {
        populateObjects();

        populateMoreObjects();

        LinkedList<Integer> keplerIds = new LinkedList<Integer>();
        keplerIds.add(KEPLER_ID - 10);
        keplerIds.add(KEPLER_ID);
        keplerIds.add(KEPLER_ID + 10);

        List<DvPlanetResults> planetResults = dvCrud.retrieveLatestPlanetResults(keplerIds);
        assertEquals(3, planetResults.size());

        Set<Integer> keplerIdsSeen = new HashSet<Integer>();
        for (DvPlanetResults p : planetResults) {
            PipelineInstance pipelineInstance = p.getPipelineTask()
                .getPipelineInstance();
            assertEquals(PipelineInstance.State.COMPLETED,
                pipelineInstance.getState());
            assertFalse(keplerIdsSeen.contains(p.getKeplerId()));
            keplerIdsSeen.add(p.getKeplerId());
        }
        assertEquals(3, keplerIdsSeen.size());
    }

    @Test
    public void testRetrieveLatestLimbDarkeningModels() throws Exception {
        populateObjects();

        populateMoreObjects();

        LinkedList<Integer> keplerIds = new LinkedList<Integer>();
        keplerIds.add(KEPLER_ID - 10);
        keplerIds.add(KEPLER_ID);
        keplerIds.add(KEPLER_ID + 10);

        List<DvLimbDarkeningModel> limbDarkeningModels = dvCrud.retrieveLatestLimbDarkeningModels(keplerIds);
        assertEquals(3, limbDarkeningModels.size());

        Set<Integer> keplerIdsSeen = new HashSet<Integer>();
        for (DvLimbDarkeningModel model : limbDarkeningModels) {
            PipelineInstance pipelineInstance = model.getPipelineTask()
                .getPipelineInstance();
            assertEquals(PipelineInstance.State.COMPLETED,
                pipelineInstance.getState());
            assertFalse(keplerIdsSeen.contains(model.getKeplerId()));
            keplerIdsSeen.add(model.getKeplerId());
        }
        assertEquals(3, keplerIdsSeen.size());
    }

    @Test
    public void testRetrieveLatestTargetResults() throws Exception {
        populateObjects();

        populateMoreObjects();

        LinkedList<Integer> keplerIds = new LinkedList<Integer>();
        keplerIds.add(KEPLER_ID - 10);
        keplerIds.add(KEPLER_ID);
        keplerIds.add(KEPLER_ID + 10);

        List<DvTargetResults> targetResults = dvCrud.retrieveLatestTargetResults(keplerIds);
        assertEquals(3, targetResults.size());

        Set<Integer> keplerIdsSeen = new HashSet<Integer>();
        for (DvTargetResults results : targetResults) {
            PipelineInstance pipelineInstance = results.getPipelineTask()
                .getPipelineInstance();
            assertEquals(PipelineInstance.State.COMPLETED,
                pipelineInstance.getState());
            assertFalse(keplerIdsSeen.contains(results.getKeplerId()));
            keplerIdsSeen.add(results.getKeplerId());
        }
        assertEquals(3, keplerIdsSeen.size());
    }

    @Test
    public void testRetrievePlanetResultsForPipelineInstance() throws Exception {
        populateObjects();
        PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud();
        List<PipelineInstance> pipelineInstances = pipelineInstanceCrud.retrieveAll();
        List<DvPlanetResults> planets = dvCrud.retrievePlanetResultsByPipelineInstanceId(pipelineInstances.get(
            0)
            .getId());
        assertEquals(1, planets.size());
        assertEquals(SINGLE_TRANSIT_FITS_COUNT, planets.get(0)
            .getSingleTransitFits()
            .size());
        assertEquals(MODEL_PARAMETERS_COUNT, planets.get(0)
            .getSingleTransitFits()
            .get(0)
            .getModelParameters()
            .size());
        assertEquals(MODEL_PARAMETERS_COUNT * MODEL_PARAMETERS_COUNT,
            planets.get(0)
                .getSingleTransitFits()
                .get(0)
                .getModelParameterCovariance()
                .size());
        assertEquals(SINGLE_TRANSIT_FITS_COUNT, planets.get(0)
            .getReducedParameterFits()
            .size());
        assertEquals(MODEL_PARAMETERS_COUNT, planets.get(0)
            .getReducedParameterFits()
            .get(0)
            .getModelParameters()
            .size());
        assertEquals(MODEL_PARAMETERS_COUNT * MODEL_PARAMETERS_COUNT,
            planets.get(0)
                .getReducedParameterFits()
                .get(0)
                .getModelParameterCovariance()
                .size());
        assertEquals(PIXEL_CORRELATION_RESULTS_COUNT, planets.get(0)
            .getPixelCorrelationResults()
            .size());
        assertEquals(PIXEL_STATISTICS, planets.get(0)
            .getPixelCorrelationResults()
            .get(0)
            .getPixelCorrelationStatistics()
            .size());
        assertEquals(DIFFERENCE_IMAGE_RESULTS_COUNT, planets.get(0)
            .getDifferenceImageResults()
            .size());
        assertEquals(DIFFERENCE_IMAGE_PIXEL_DATA_COUNT, planets.get(0)
            .getDifferenceImageResults()
            .get(0)
            .getDifferenceImagePixelData()
            .size());
        assertEquals(DETREND_FILTER_LENGTH, planets.get(0)
            .getDetrendFilterLength());
    }

    @Test
    public void testRetrieveLimbDarkeningModelsForPipelineInstance()
        throws Exception {
        populateObjects();
        PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud();
        List<PipelineInstance> pipelineInstances = pipelineInstanceCrud.retrieveAll();
        List<DvLimbDarkeningModel> models = dvCrud.retrieveLimbDarkeningModelsByPipelineInstanceId(pipelineInstances.get(
            0)
            .getId());
        assertEquals(1, models.size());
        assertEquals(LIMB_DARKENING_MODEL_NAME, models.get(0)
            .getModelName());
        assertEquals(COEFFICIENT1, models.get(0)
            .getCoefficient1(), 1e-10);
        assertEquals(COEFFICIENT2, models.get(0)
            .getCoefficient2(), 1e-10);
        assertEquals(COEFFICIENT3, models.get(0)
            .getCoefficient3(), 1e-10);
        assertEquals(COEFFICIENT4, models.get(0)
            .getCoefficient4(), 1e-10);
    }

    @Test
    public void testRetrieveTargetResultsForPipelineInstance() throws Exception {
        populateObjects();
        PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud();
        List<PipelineInstance> pipelineInstances = pipelineInstanceCrud.retrieveAll();
        List<DvTargetResults> results = dvCrud.retrieveTargetResultsByPipelineInstanceId(pipelineInstances.get(
            0)
            .getId());
        assertEquals(1, results.size());
        assertEquals(PLANET_CANDIDATE_COUNT, results.get(0)
            .getPlanetCandidateCount());
        assertEquals(QUARTERS_OBSERVED, results.get(0)
            .getQuartersObserved());
        assertEquals(EFFECTIVE_TEMP, results.get(0)
            .getEffectiveTemp());
        assertEquals(LOG10_METALLICITY, results.get(0)
            .getLog10Metallicity());
        assertEquals(LOG10_SURFACE_GRAVITY, results.get(0)
            .getLog10SurfaceGravity());
        assertEquals(RADIUS, results.get(0)
            .getRadius());
    }

    @Test
    public void testRetrievePlanetResultsKeplerIdsForPipelineInstance()
        throws Exception {
        populateObjects();
        PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud();
        List<PipelineInstance> pipelineInstances = pipelineInstanceCrud.retrieveAll();
        List<Integer> keplerIds = dvCrud.retrievePlanetResultsKeplerIdsByPipelineInstanceId(pipelineInstances.get(
            0)
            .getId());
        assertEquals(1, keplerIds.size());
        assertEquals(KEPLER_ID, keplerIds.get(0)
            .intValue());
    }

    @Test
    public void testRetrieveLimbDarkeningModelsKeplerIdsForPipelineInstance()
        throws Exception {
        populateObjects();
        PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud();
        List<PipelineInstance> pipelineInstances = pipelineInstanceCrud.retrieveAll();
        List<Integer> keplerIds = dvCrud.retrieveLimbDarkeningModelsKeplerIdsByPipelineInstanceId(pipelineInstances.get(
            0)
            .getId());
        assertEquals(1, keplerIds.size());
        assertEquals(KEPLER_ID, keplerIds.get(0)
            .intValue());
    }

    @Test
    public void testRetrieveTargetResultsKeplerIdsForPipelineInstance()
        throws Exception {
        populateObjects();
        PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud();
        List<PipelineInstance> pipelineInstances = pipelineInstanceCrud.retrieveAll();
        List<Integer> keplerIds = dvCrud.retrieveTargetResultsKeplerIdsByPipelineInstanceId(pipelineInstances.get(
            0)
            .getId());
        assertEquals(1, keplerIds.size());
        assertEquals(KEPLER_ID, keplerIds.get(0)
            .intValue());
    }

    @Test
    public void testRetrievePlanetResultsKeplerIdsForLatest() throws Exception {
        populateObjects();
        populateMoreObjects();

        List<Integer> keplerIds = dvCrud.retrievePlanetResultsKeplerIdsBeforePipelineInstance(maxPipelineInstanceId);

        assertEquals(3, keplerIds.size());
        assertEquals(KEPLER_ID - 10, keplerIds.get(0)
            .intValue());
        assertEquals(KEPLER_ID, keplerIds.get(1)
            .intValue());
        assertEquals(KEPLER_ID + 10, keplerIds.get(2)
            .intValue());
    }

    @Test
    public void testRetrieveLimbDarkeningModelsKeplerIdsForLatest()
        throws Exception {
        populateObjects();
        populateMoreObjects();

        List<Integer> keplerIds = dvCrud.retrieveLimbDarkeningModelsKeplerIdsBeforePipelineInstance(maxPipelineInstanceId);

        assertEquals(3, keplerIds.size());
        assertEquals(KEPLER_ID - 10, keplerIds.get(0)
            .intValue());
        assertEquals(KEPLER_ID, keplerIds.get(1)
            .intValue());
        assertEquals(KEPLER_ID + 10, keplerIds.get(2)
            .intValue());
    }

    @Test
    public void testRetrieveTargetResultsKeplerIdsForLatest() throws Exception {
        populateObjects();
        populateMoreObjects();

        List<Integer> keplerIds = dvCrud.retrieveTargetResultsKeplerIdsBeforePipelineInstance(maxPipelineInstanceId);

        assertEquals(3, keplerIds.size());
        assertEquals(KEPLER_ID - 10, keplerIds.get(0)
            .intValue());
        assertEquals(KEPLER_ID, keplerIds.get(1)
            .intValue());
        assertEquals(KEPLER_ID + 10, keplerIds.get(2)
            .intValue());
    }

    @Test
    public void testRetrieveSummaryForPipelineInstance() throws Exception {
        populateObjects();

        PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud();
        List<PipelineInstance> pipelineInstances = pipelineInstanceCrud.retrieveAll();
        List<DvPlanetSummary> systems = dvCrud.retrievePlanetSummaryByPipelineInstanceId(
            pipelineInstances.get(0)
                .getId(), KEPLER_ID + 10, Integer.MAX_VALUE);
        assertEquals(0, systems.size());

        systems = dvCrud.retrievePlanetSummaryByPipelineInstanceId(
            pipelineInstances.get(0)
                .getId(), KEPLER_ID - 10, KEPLER_ID + 10);
        assertEquals(1, systems.size());
    }

    @Test
    public void testRetrieveSummaryForLatest() throws Exception {
        populateObjects();
        populateMoreObjects();

        List<DvPlanetSummary> systems = dvCrud.retrievePlanetSummaryBeforePipelineInstance(
            maxPipelineInstanceId, Integer.MIN_VALUE, Integer.MAX_VALUE);
        assertEquals(3, systems.size());
        assertEquals(KEPLER_ID - 10, systems.get(0).keplerId);
        assertEquals(1, systems.get(0).planetNumbers.length);

        assertEquals(KEPLER_ID, systems.get(1).keplerId);
        assertEquals(KEPLER_ID + 10, systems.get(2).keplerId);
    }

    @Test
    public void testRetrieveExternalTceModelDescriptions() {
        populateObjects();
        populateMoreObjects();

        List<DvExternalTceModelDescription> externalTceModelDescriptions = dvCrud.retrieveExternalTceModelDescription(PIPELINE_INSTANCE_ID);
        assertEquals(3, externalTceModelDescriptions.size());
    }

    @Test
    public void testRetrieveTransitModelDescriptions() {
        populateObjects();
        populateMoreObjects();

        List<DvTransitModelDescriptions> transitModelDescriptions = dvCrud.retrieveTransitModelDescriptions(PIPELINE_INSTANCE_ID);
        assertEquals(3, transitModelDescriptions.size());
    }

    @Test(expected = IllegalStateException.class)
    public void testRetrieveExternalTceModelDescriptionsConflict() {
        populateObjects();
        populateMoreObjects();

        try {
            databaseService.beginTransaction();
            dvCrud.create(createExternalTceModelDescription(MODEL_DESCRIPTION
                + " extra stuff"));
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }

        dvCrud.retrieveExternalTceModelDescription(PIPELINE_INSTANCE_ID);
    }

    @Test(expected = IllegalStateException.class)
    public void testRetrieveTransitModelDescriptionsConflict() {
        populateObjects();
        populateMoreObjects();

        try {
            databaseService.beginTransaction();
            dvCrud.create(createTransitModelDescriptions(
                TRANSIT_NAME_MODEL_DESCRIPTION + " extra stuff",
                TRANSIT_PARAMETER_MODEL_DESCRIPTION + " extra stuff"));
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }

        dvCrud.retrieveTransitModelDescriptions(PIPELINE_INSTANCE_ID);
    }

    @Test
    public void createUkirtImageBlobMetadata() {
        populateUkirtImageBlobMetadata();

        try {
            databaseService.beginTransaction();
            dvCrud.createUkirtImageBlobMetadata(ukirtImageBlobMetadata1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test(expected = HibernateException.class)
    public void storeUkirtImageBlobMetadataWithEmptyDatabase() throws Exception {

        try {
            databaseService.beginTransaction();
            databaseService.getDdlInitializer()
                .cleanDB();
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        createUkirtImageBlobMetadata();
    }

    @Test(expected = NullPointerException.class)
    public void createNullUkirtImageBlobMetadata() {

        try {
            databaseService.beginTransaction();
            dvCrud.createUkirtImageBlobMetadata((UkirtImageBlobMetadata) null);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void retrieveEmptyUkirtImageBlobMetadata() {
        // empty database
        List<UkirtImageBlobMetadata> ukirtImageBlobMetadata = dvCrud.retrieveUkirtImageBlobMetadata(KEPLER_ID);
        assertTrue(ukirtImageBlobMetadata.isEmpty());
    }

    @Test
    public void retrieveEmpty2UkirtImageBlobMetadata() {
        // add motionBlobMetadata to database
        createUkirtImageBlobMetadata(KEPLER_ID + 1);

        List<UkirtImageBlobMetadata> ukirtImageBlobMetadata = dvCrud.retrieveUkirtImageBlobMetadata(KEPLER_ID);
        assertTrue(ukirtImageBlobMetadata.isEmpty());
    }

    @Test
    public void retrieveUkirtImageBlobMetadata() {
        // add ukirtImageBlobMetadataList1 to database
        createUkirtImageBlobMetadataList();

        // get ukirtImageBlobMetadataList1 from database
        List<UkirtImageBlobMetadata> ukirtImageBlobMetadataList = dvCrud.retrieveUkirtImageBlobMetadata(KEPLER_ID);
        assertFalse(ukirtImageBlobMetadataList.isEmpty());
        assertEquals(ukirtImageBlobMetadataList1, ukirtImageBlobMetadataList);

        // get non-existent metadata from database
        ukirtImageBlobMetadataList = dvCrud.retrieveUkirtImageBlobMetadata(KEPLER_ID + 10);
        assertTrue(ukirtImageBlobMetadataList.isEmpty());
    }

    @Test
    public void createUkirtImageBlobMetadataList() {
        populateUkirtImageBlobMetadata();

        try {
            databaseService.beginTransaction();
            dvCrud.createUkirtImageBlobMetadata(ukirtImageBlobMetadataList1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test(expected = IllegalArgumentException.class)
    public void createEmptyUkirtImageBlobMetadataList() {
        populateUkirtImageBlobMetadata();

        try {
            databaseService.beginTransaction();
            dvCrud.createUkirtImageBlobMetadata(new ArrayList<UkirtImageBlobMetadata>());
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    private void populateObjects() {
        try {
            databaseService.beginTransaction();

            planetResultsList = new ArrayList<DvPlanetResults>(3);
            limbDarkeningModelList = new ArrayList<DvLimbDarkeningModel>();
            targetResultsList = new ArrayList<DvTargetResults>();

            planetResultsList.add(createPlanetResults(KEPLER_ID));
            limbDarkeningModelList.add(createLimbDarkeningModel(KEPLER_ID));
            targetResultsList.add(createTargetResults(KEPLER_ID));
            planetResultsList.add(createPlanetResults(KEPLER_ID + 10));
            limbDarkeningModelList.add(createLimbDarkeningModel(KEPLER_ID + 10));
            targetResultsList.add(createTargetResults(KEPLER_ID + 10));
            planetResultsList.add(createPlanetResults(KEPLER_ID - 10));
            limbDarkeningModelList.add(createLimbDarkeningModel(KEPLER_ID - 10));
            targetResultsList.add(createTargetResults(KEPLER_ID - 10));

            pipelineInstance = createPipelineInstance(true);
            modelDescriptionsList = new ArrayList<DvExternalTceModelDescription>();

            modelDescriptionsList.add(createExternalTceModelDescription(MODEL_DESCRIPTION));
            modelDescriptionsList.add(createExternalTceModelDescription(MODEL_DESCRIPTION));
            modelDescriptionsList.add(createExternalTceModelDescription(MODEL_DESCRIPTION));
            modelDescriptionsList.add(createExternalTceModelDescription(
                createPipelineInstance(true), MODEL_DESCRIPTION));

            transitModelDescriptionsList = new ArrayList<DvTransitModelDescriptions>();

            transitModelDescriptionsList.add(createTransitModelDescriptions(
                TRANSIT_NAME_MODEL_DESCRIPTION,
                TRANSIT_PARAMETER_MODEL_DESCRIPTION));
            transitModelDescriptionsList.add(createTransitModelDescriptions(
                TRANSIT_NAME_MODEL_DESCRIPTION,
                TRANSIT_PARAMETER_MODEL_DESCRIPTION));
            transitModelDescriptionsList.add(createTransitModelDescriptions(
                TRANSIT_NAME_MODEL_DESCRIPTION,
                TRANSIT_PARAMETER_MODEL_DESCRIPTION));
            transitModelDescriptionsList.add(createTransitModelDescriptions(
                createPipelineInstance(true), TRANSIT_NAME_MODEL_DESCRIPTION,
                TRANSIT_PARAMETER_MODEL_DESCRIPTION));

            dvCrud.createPlanetResultsCollection(planetResultsList);
            dvCrud.createLimbDarkeningModelsCollection(limbDarkeningModelList);
            dvCrud.createTargetResultsCollection(targetResultsList);
            dvCrud.createExternalTceModelDescriptionCollection(modelDescriptionsList);
            dvCrud.createTransitModelDescriptionsCollection(transitModelDescriptionsList);

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        maxPipelineInstanceId = planetResultsList.get(
            planetResultsList.size() - 1)
            .getPipelineTask()
            .getPipelineInstance()
            .getId();
    }

    private void populateMoreObjects() {
        try {
            databaseService.beginTransaction();
            dvCrud.create(createPlanetResults(KEPLER_ID));
            dvCrud.create(createLimbDarkeningModel(KEPLER_ID));
            dvCrud.create(createTargetResults(KEPLER_ID));
            dvCrud.create(createPlanetResults(KEPLER_ID, false));
            dvCrud.create(createLimbDarkeningModel(KEPLER_ID));
            dvCrud.create(createTargetResults(KEPLER_ID));
            dvCrud.create(createExternalTceModelDescription(
                createPipelineInstance(true), MODEL_DESCRIPTION));
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        // So maxPipelineInstanceId should no longer be max.
    }

    private DvPlanetResults createPlanetResults(int keplerId) {
        return createPlanetResults(keplerId, true);
    }

    private DvPlanetResults createPlanetResults(int keplerId, boolean completed) {
        pipelineTask = createPipelineTask(completed);
        return new DvPlanetResults.Builder(START_CADENCE, END_CADENCE,
            keplerId, PLANET_NUMBER, pipelineTask).singleTransitFits(
            createSingleTransitFits(SINGLE_TRANSIT_FITS_COUNT))
            .reducedParameterFits(
                createSingleTransitFits(SINGLE_TRANSIT_FITS_COUNT))
            .pixelCorrelationResults(
                createPixelCorrelationResultsList(
                    PIXEL_CORRELATION_RESULTS_COUNT, TARGET_TABLE_ID,
                    CCD_MODULE, CCD_OUTPUT, QUARTER, START_CADENCE, END_CADENCE))
            .differenceImageResults(createDifferenceImageResultsList())
            .imageArtifactResults(createImageArtifactResults())
            .detrendFilterLength(DETREND_FILTER_LENGTH)
            .build();
    }

    private DvImageArtifactResults createImageArtifactResults() {

        return new DvImageArtifactResults(
            createRollingBandContaminationHistogram());
    }

    private DvRollingBandContaminationHistogram createRollingBandContaminationHistogram() {

        return new DvRollingBandContaminationHistogram(TEST_PULSE_DURATION_LC,
            new ArrayList<Float>(),
            new ArrayList<Integer>(), new ArrayList<Float>());
    }

    private PipelineInstance createPipelineInstance(
        boolean pipelineInstanceCompleted) {

        PipelineInstance pipelineInstance = new PipelineInstance();
        if (pipelineInstanceCompleted) {
            pipelineInstance.setState(PipelineInstance.State.COMPLETED);
        }

        new PipelineInstanceCrud(databaseService).create(pipelineInstance);

        return pipelineInstance;
    }

    private PipelineTask createPipelineTask(boolean pipelineInstanceCompleted) {

        PipelineTask pipelineTask = new PipelineTask();
        PipelineInstance pipelineInstance = createPipelineInstance(pipelineInstanceCompleted);
        pipelineTask.setPipelineInstance(pipelineInstance);
        if (pipelineInstanceCompleted) {
            pipelineTask.setState(PipelineTask.State.COMPLETED);
        } else {
            pipelineTask.setState(PipelineTask.State.PARTIAL);
        }

        new PipelineTaskCrud(databaseService).create(pipelineTask);

        return pipelineTask;
    }

    private List<DvPlanetModelFit> createSingleTransitFits(int count) {
        List<DvPlanetModelFit> singleTransitFits = new ArrayList<DvPlanetModelFit>();
        for (int i = 0; i < count; i++) {
            singleTransitFits.add(new DvPlanetModelFit.Builder(KEPLER_ID,
                PLANET_NUMBER + i, pipelineTask).modelParameters(
                createModelParameters(MODEL_PARAMETERS_COUNT))
                .modelParameterCovariance(
                    createModelParameterCovariance(MODEL_PARAMETERS_COUNT
                        * MODEL_PARAMETERS_COUNT))
                .build());
        }
        return singleTransitFits;
    }

    private List<DvModelParameter> createModelParameters(int count) {
        List<DvModelParameter> modelParameters = new ArrayList<DvModelParameter>();
        for (int i = 0; i < count; i++) {
            modelParameters.add(new DvModelParameter("ModelParameter-" + i, i,
                (i + 1) / 10, false));
        }
        return modelParameters;
    }

    private List<Float> createModelParameterCovariance(int count) {
        List<Float> covariance = new ArrayList<Float>();
        for (int i = 0; i < count; i++) {
            covariance.add((float) i);
        }
        return covariance;
    }

    private List<DvPixelCorrelationResults> createPixelCorrelationResultsList(
        int count, int targetTableId, int ccdModule, int ccdOutput,
        int quarter, int startCadence, int endCadence) {

        List<DvPixelCorrelationResults> pixelCorrelationResults = new ArrayList<DvPixelCorrelationResults>();
        for (int i = 0; i < count; i++) {
            pixelCorrelationResults.add(new DvPixelCorrelationResults.Builder(
                targetTableId).ccdModule(ccdModule)
                .ccdOutput(ccdOutput)
                .quarter(quarter)
                .startCadence(startCadence)
                .endCadence(endCadence)
                .controlCentroidOffsets(createCentroidOffsets(0))
                .controlImageCentroid(createImageCentroid(6))
                .correlationImageCentroid(createImageCentroid(10))
                .kicCentroidOffsets(createCentroidOffsets(14))
                .kicReferenceCentroid(createImageCentroid(20))
                .pixelCorrelationStatistics(
                    createPixelCorrelationStatistics(PIXEL_STATISTICS))
                .build());
        }
        return pixelCorrelationResults;
    }

    private List<DvPixelStatistic> createPixelCorrelationStatistics(int count) {
        List<DvPixelStatistic> pixelStatistics = new ArrayList<DvPixelStatistic>();
        for (int i = 0; i < count; i++) {
            pixelStatistics.add(new DvPixelStatistic(CCD_ROW + i, CCD_COLUMN
                + i, i, i / 10));
        }
        return pixelStatistics;
    }

    private List<DvDifferenceImageResults> createDifferenceImageResultsList() {
        List<DvDifferenceImageResults> differenceImageResultsList = new ArrayList<DvDifferenceImageResults>();

        for (int i = 0; i < DIFFERENCE_IMAGE_RESULTS_COUNT; i++) {
            differenceImageResultsList.add(DvDifferenceImageResultsTest.createDifferenceImageResults(DvDifferenceImageResultsTest.createDifferenceImagePixelData(
                DIFFERENCE_IMAGE_PIXEL_DATA_COUNT, i)));
        }
        return differenceImageResultsList;
    }

    private DvLimbDarkeningModel createLimbDarkeningModel(int keplerId) {

        return new DvLimbDarkeningModel.Builder(TARGET_TABLE_ID, FLUX_TYPE,
            keplerId, pipelineTask).ccdModule(CCD_MODULE)
            .ccdOutput(CCD_OUTPUT)
            .startCadence(START_CADENCE)
            .endCadence(END_CADENCE)
            .quarter(QUARTER)
            .modelName(LIMB_DARKENING_MODEL_NAME)
            .coefficient1(COEFFICIENT1)
            .coefficient2(COEFFICIENT2)
            .coefficient3(COEFFICIENT3)
            .coefficient4(COEFFICIENT4)
            .build();
    }

    private DvTargetResults createTargetResults(int keplerId) {
        return new DvTargetResults.Builder(FLUX_TYPE, START_CADENCE,
            END_CADENCE, keplerId, pipelineTask).planetCandidateCount(
            PLANET_CANDIDATE_COUNT)
            .quartersObserved(QUARTERS_OBSERVED)
            .effectiveTemp(EFFECTIVE_TEMP)
            .log10Metallicity(LOG10_METALLICITY)
            .log10SurfaceGravity(LOG10_SURFACE_GRAVITY)
            .radius(RADIUS)
            .build();
    }

    private DvExternalTceModelDescription createExternalTceModelDescription(
        String modelDescription) {

        return createExternalTceModelDescription(pipelineInstance,
            modelDescription);
    }

    private DvTransitModelDescriptions createTransitModelDescriptions(
        String nameModelDescription, String parameterModelDescription) {

        return createTransitModelDescriptions(pipelineInstance,
            nameModelDescription, parameterModelDescription);
    }

    private DvExternalTceModelDescription createExternalTceModelDescription(
        PipelineInstance pipelineInstance, String modelDescription) {

        PipelineTask pipelineTask = createPipelineTask(true);
        pipelineTask.setPipelineInstance(pipelineInstance);

        return new DvExternalTceModelDescription(pipelineTask, modelDescription);
    }

    private DvTransitModelDescriptions createTransitModelDescriptions(
        PipelineInstance pipelineInstance, String nameModelDescription,
        String parameterModelDescription) {

        PipelineTask pipelineTask = createPipelineTask(true);
        pipelineTask.setPipelineInstance(pipelineInstance);

        return new DvTransitModelDescriptions(pipelineTask,
            nameModelDescription, parameterModelDescription);
    }

    private static DvQuantityWithProvenance createQuantityWithProvenance(
        float seed, String provenance) {

        return new DvQuantityWithProvenance(seed, seed / 1000, provenance);
    }

    private void populateUkirtImageBlobMetadata() {
        UkirtImageBlobMetadata uib = null;

        ukirtImageBlobMetadataList1 = new LinkedList<UkirtImageBlobMetadata>();
        ukirtImageBlobMetadata1 = createUkirtImageBlobMetadata(KEPLER_ID);
        ukirtImageBlobMetadataList1.add(ukirtImageBlobMetadata1);
        try {
            Thread.sleep(100);
        } catch (InterruptedException ie) {
        }
        ukirtImageBlobMetadata2 = createUkirtImageBlobMetadata(KEPLER_ID);
        ukirtImageBlobMetadataList1.add(ukirtImageBlobMetadata2);

        ukirtImageBlobMetadataList2 = new LinkedList<UkirtImageBlobMetadata>();
        uib = createUkirtImageBlobMetadata(KEPLER_ID + 1);
        ukirtImageBlobMetadataList2.add(uib);
        uib = createUkirtImageBlobMetadata(KEPLER_ID + 1);
        ukirtImageBlobMetadataList2.add(uib);
    }

    private UkirtImageBlobMetadata createUkirtImageBlobMetadata(int keplerId) {
        return new UkirtImageBlobMetadata(System.currentTimeMillis(), keplerId,
            MAT_FILE_EXTENSION);
    }
}
