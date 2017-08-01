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

package gov.nasa.kepler.hibernate.pdc;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.intervals.CadenceData;
import gov.nasa.kepler.common.intervals.CadenceDataCalculator;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;

import java.util.Arrays;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * 
 * @author Forrest Girouard
 */
public class PdcCrudTest {

    private static final int CCD_MODULE = 2;
    private static final int CCD_OUTPUT = 1;
    private static final int KEPLER_ID = 8;
    private static final FluxType FLUX_TYPE = FluxType.SAP;
    private static final CadenceType CADENCE_TYPE = CadenceType.LONG;
    private static final int START_CADENCE = 3000;
    private static final int END_CADENCE = 4000;
    private static final long PIPELINE_TASK_ID = 5;
    private static final String FILE_EXTENSION = ".test";
    private static final String PDC_METHOD = "regularMap";
    private static final int NUM_DISCONTINUITIES_DETECTED = 3;
    private static final int NUM_DISCONTINUITIES_REMOVED = 2;
    private static final boolean HARMONICS_FITTED = true;
    private static final boolean HARMONICS_RESTORED = false;
    private static final float TARGET_VARIABILITY = 4.0F;
    private static final String PRIOR_FIT_TYPE = "prior";
    private static final float PRIOR_WEIGHT = 5.0F;
    private static final float PRIOR_GOODNESS = 6.0F;
    private static final PdcBand PDC_BAND = createPdcBand();
    private static final List<PdcBand> BANDS = Arrays.asList(PDC_BAND);

    private CbvBlobMetadata cbvBlobMetadata = new CbvBlobMetadata(
        PIPELINE_TASK_ID, CCD_MODULE, CCD_OUTPUT, CADENCE_TYPE, START_CADENCE,
        END_CADENCE, FILE_EXTENSION);
    private List<CbvBlobMetadata> cbvBlobMetadataList = ImmutableList.of(cbvBlobMetadata);

    private PdcBlobMetadata pdcBlobMetadata = new PdcBlobMetadata(
        PIPELINE_TASK_ID, CCD_MODULE, CCD_OUTPUT, CADENCE_TYPE, START_CADENCE,
        END_CADENCE, FILE_EXTENSION);
    private List<PdcBlobMetadata> pdcBlobMetadataList = ImmutableList.of(pdcBlobMetadata);

    private PdcProcessingCharacteristics pdcProcessingCharacteristics = new PdcProcessingCharacteristics.Builder(
        PIPELINE_TASK_ID, FLUX_TYPE, CADENCE_TYPE, KEPLER_ID).startCadence(
        START_CADENCE)
        .endCadence(END_CADENCE)
        .pdcMethod(PDC_METHOD)
        .numDiscontinuitiesDetected(NUM_DISCONTINUITIES_DETECTED)
        .numDiscontinuitiesRemoved(NUM_DISCONTINUITIES_REMOVED)
        .harmonicsFitted(HARMONICS_FITTED)
        .harmonicsRestored(HARMONICS_RESTORED)
        .targetVariability(TARGET_VARIABILITY)
        .bands(BANDS)
        .build();
    private PdcProcessingCharacteristics pdcProcessingCharacteristics1 = new PdcProcessingCharacteristics.Builder(
        PIPELINE_TASK_ID, FLUX_TYPE, CADENCE_TYPE, KEPLER_ID + 1).startCadence(
        START_CADENCE)
        .endCadence(END_CADENCE)
        .pdcMethod(PDC_METHOD)
        .numDiscontinuitiesDetected(NUM_DISCONTINUITIES_DETECTED)
        .numDiscontinuitiesRemoved(NUM_DISCONTINUITIES_REMOVED)
        .harmonicsFitted(HARMONICS_FITTED)
        .harmonicsRestored(HARMONICS_RESTORED)
        .targetVariability(TARGET_VARIABILITY)
        .bands(BANDS)
        .build();
    private List<PdcProcessingCharacteristics> pdcProcessingCharacteristicsList = ImmutableList.of(pdcProcessingCharacteristics);
    private List<PdcProcessingCharacteristics> multiPdcProcessingCharacteristicsList = ImmutableList.of(
        pdcProcessingCharacteristics, pdcProcessingCharacteristics1);

    private static PdcBand createPdcBand() {
        return new PdcBand(PRIOR_FIT_TYPE, PRIOR_WEIGHT, PRIOR_GOODNESS);
    }

    public PdcCrudTest() {
    }

    private DatabaseService databaseService = DatabaseServiceFactory.getInstance();

    private PdcCrud pdcCrud = new PdcCrud();

    @Before
    public void setUp() throws Exception {
        TestUtils.setUpDatabase(databaseService);
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    @Test
    public void testCreateRetrievePdcBlobMetadata() {

        databaseService.beginTransaction();
        pdcCrud.createPdcBlobMetadata(pdcBlobMetadata);
        databaseService.commitTransaction();
        databaseService.closeCurrentSession();

        List<PdcBlobMetadata> actualPdcBlobMetadataList = pdcCrud.retrievePdcBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, CADENCE_TYPE, START_CADENCE, END_CADENCE);

        assertEquals(pdcBlobMetadataList, actualPdcBlobMetadataList);
    }

    @Test
    public void testCreateRetrieveCbvBlobMetadata() {

        databaseService.beginTransaction();
        pdcCrud.createCbvBlobMetadata(cbvBlobMetadata);
        databaseService.commitTransaction();
        databaseService.closeCurrentSession();

        List<CbvBlobMetadata> actualCbvBlobMetadataList = pdcCrud.retrieveCbvBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, CADENCE_TYPE, START_CADENCE, END_CADENCE);

        assertEquals(cbvBlobMetadataList, actualCbvBlobMetadataList);
    }

    @Test
    public void testCreateRetrievePdcProcessingCharacteristics() {

        databaseService.beginTransaction();
        pdcCrud.createPdcProcessingCharacteristics(pdcProcessingCharacteristics);
        databaseService.commitTransaction();
        databaseService.closeCurrentSession();

        List<PdcProcessingCharacteristics> actualPdcProcessingCharacteristicsList = pdcCrud.retrievePdcProcessingCharacteristics(
            FLUX_TYPE, CADENCE_TYPE, KEPLER_ID, START_CADENCE, END_CADENCE);

        assertEquals(pdcProcessingCharacteristicsList,
            actualPdcProcessingCharacteristicsList);
    }

    @Test
    public void testCreateRetrievePdcProcessingCharacteristicsList() {

        databaseService.beginTransaction();
        pdcCrud.createPdcProcessingCharacteristics(pdcProcessingCharacteristicsList);
        databaseService.commitTransaction();
        databaseService.closeCurrentSession();

        List<PdcProcessingCharacteristics> actualPdcProcessingCharacteristicsList = pdcCrud.retrievePdcProcessingCharacteristics(
            FLUX_TYPE, CADENCE_TYPE, KEPLER_ID, START_CADENCE, END_CADENCE);

        assertEquals(pdcProcessingCharacteristicsList,
            actualPdcProcessingCharacteristicsList);
    }

    @Test
    public void testMultiCreateRetrievePdcProcessingCharacteristics() {

        databaseService.beginTransaction();
        pdcCrud.createPdcProcessingCharacteristics(multiPdcProcessingCharacteristicsList);
        databaseService.commitTransaction();
        databaseService.closeCurrentSession();

        List<PdcProcessingCharacteristics> actualPdcProcessingCharacteristicsList = pdcCrud.retrievePdcProcessingCharacteristics(
            FLUX_TYPE, CADENCE_TYPE, KEPLER_ID, START_CADENCE, END_CADENCE);

        assertEquals(pdcProcessingCharacteristicsList,
            actualPdcProcessingCharacteristicsList);

        actualPdcProcessingCharacteristicsList = pdcCrud.retrievePdcProcessingCharacteristics(
            FLUX_TYPE, CADENCE_TYPE,
            ImmutableList.of(KEPLER_ID, KEPLER_ID + 1), START_CADENCE,
            END_CADENCE);

        assertEquals(multiPdcProcessingCharacteristicsList,
            actualPdcProcessingCharacteristicsList);
    }

    @Test
    public void testOverlapCreateRetrievePdcProcessingCharacteristics() {

        int halfLength = (END_CADENCE - START_CADENCE + 1) / 2;
        PdcProcessingCharacteristics overlappingPdcProcessingCharacteristics = new PdcProcessingCharacteristics.Builder(
            PIPELINE_TASK_ID, FLUX_TYPE, CADENCE_TYPE, KEPLER_ID + 1).startCadence(
            START_CADENCE + halfLength)
            .endCadence(END_CADENCE + halfLength)
            .pdcMethod(PDC_METHOD)
            .numDiscontinuitiesDetected(NUM_DISCONTINUITIES_DETECTED)
            .numDiscontinuitiesRemoved(NUM_DISCONTINUITIES_REMOVED)
            .harmonicsFitted(HARMONICS_FITTED)
            .harmonicsRestored(HARMONICS_RESTORED)
            .targetVariability(TARGET_VARIABILITY)
            .bands(BANDS)
            .build();
        databaseService.beginTransaction();
        pdcCrud.createPdcProcessingCharacteristics(multiPdcProcessingCharacteristicsList);
        pdcCrud.createPdcProcessingCharacteristics(overlappingPdcProcessingCharacteristics);
        databaseService.commitTransaction();
        databaseService.closeCurrentSession();

        List<PdcProcessingCharacteristics> actualPdcProcessingCharacteristicsList = pdcCrud.retrievePdcProcessingCharacteristics(
            FLUX_TYPE, CADENCE_TYPE, KEPLER_ID, START_CADENCE, END_CADENCE);

        assertEquals(pdcProcessingCharacteristicsList,
            actualPdcProcessingCharacteristicsList);

        actualPdcProcessingCharacteristicsList = pdcCrud.retrievePdcProcessingCharacteristics(
            FLUX_TYPE, CADENCE_TYPE,
            ImmutableList.of(KEPLER_ID, KEPLER_ID + 1), START_CADENCE,
            END_CADENCE);

        assertEquals("size", 3, actualPdcProcessingCharacteristicsList.size());

        actualPdcProcessingCharacteristicsList = pdcCrud.retrievePdcProcessingCharacteristics(
            FLUX_TYPE, CADENCE_TYPE, KEPLER_ID + 1, START_CADENCE, END_CADENCE);

        assertEquals("size", 2, actualPdcProcessingCharacteristicsList.size());
        assertEquals("equals", actualPdcProcessingCharacteristicsList.get(0),
            pdcProcessingCharacteristics1);
        assertEquals("equals", actualPdcProcessingCharacteristicsList.get(1),
            overlappingPdcProcessingCharacteristics);
    }

    @Test
    public void testCadenceDataCalculatorForPdcProcessingCharacteristics() {

        int halfLength = (END_CADENCE - START_CADENCE + 1) / 2;
        PdcProcessingCharacteristics overlappingPdcProcessingCharacteristics = new PdcProcessingCharacteristics.Builder(
            PIPELINE_TASK_ID, FLUX_TYPE, CADENCE_TYPE, KEPLER_ID + 1).startCadence(
            START_CADENCE + halfLength)
            .endCadence(END_CADENCE + halfLength)
            .pdcMethod(PDC_METHOD)
            .numDiscontinuitiesDetected(NUM_DISCONTINUITIES_DETECTED)
            .numDiscontinuitiesRemoved(NUM_DISCONTINUITIES_REMOVED)
            .harmonicsFitted(HARMONICS_FITTED)
            .harmonicsRestored(HARMONICS_RESTORED)
            .targetVariability(TARGET_VARIABILITY)
            .bands(BANDS)
            .build();
        databaseService.beginTransaction();
        pdcCrud.createPdcProcessingCharacteristics(multiPdcProcessingCharacteristicsList);
        pdcCrud.createPdcProcessingCharacteristics(overlappingPdcProcessingCharacteristics);
        databaseService.commitTransaction();
        databaseService.closeCurrentSession();

        List<PdcProcessingCharacteristics> actualPdcProcessingCharacteristicsList = pdcCrud.retrievePdcProcessingCharacteristics(
            FLUX_TYPE, CADENCE_TYPE, KEPLER_ID + 1, START_CADENCE, END_CADENCE);

        assertEquals("size", 2, actualPdcProcessingCharacteristicsList.size());
        assertEquals("equals", actualPdcProcessingCharacteristicsList.get(0),
            pdcProcessingCharacteristics1);
        assertEquals("equals", actualPdcProcessingCharacteristicsList.get(1),
            overlappingPdcProcessingCharacteristics);

        CadenceDataCalculator<PdcProcessingCharacteristics> cadenceDataCalculator = new CadenceDataCalculator<PdcProcessingCharacteristics>(
            actualPdcProcessingCharacteristicsList);
        CadenceData[] cadenceDataArray = cadenceDataCalculator.cadenceDataForInterval(
            START_CADENCE, END_CADENCE);
        for (int cadence = START_CADENCE; cadence < END_CADENCE - START_CADENCE
            + 1; cadence++) {
            if (cadence < START_CADENCE + halfLength) {
                assertEquals(pdcProcessingCharacteristics1,
                    cadenceDataArray[cadence - START_CADENCE]);
            } else {
                assertEquals(overlappingPdcProcessingCharacteristics,
                    cadenceDataArray[cadence - START_CADENCE]);
            }
        }
    }
}
