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

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.fail;
import gov.nasa.kepler.hibernate.dv.DvPlanetModelFit.PlanetModelFitType;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link DvPlanetModelFit} class.
 * 
 * @author Bill Wohler
 */
public class DvPlanetModelFitTest {

    private static final Log log = LogFactory.getLog(DvPlanetModelFitTest.class);

    static final long ID = 8;
    private static final int KEPLER_ID = 8;
    private static final int PLANET_NUMBER = 88;
    private static final PlanetModelFitType TYPE = PlanetModelFitType.ALL;
    private static final float MODEL_CHI_SQUARE = 8.5F;
    private static final float MODEL_DEGREES_OF_FREEDOM = 8.6F;
    private static final float MODEL_FIT_SNR = 87F;
    private static final String TRANSIT_MODEL_NAME = "transitModelName";
    private static final String LIMB_DARKENING_MODEL_NAME = "limbDarkeningModelName";
    private static final DvModelParameter ORBITAL_PERIOD = createDvModelParameter(8.3F);
    private static final DvModelParameter ORBITAL_INCLINATION = createDvModelParameter(8.4F);
    private static final List<DvModelParameter> MODEL_PARAMETERS = Arrays.asList(
        ORBITAL_PERIOD, ORBITAL_INCLINATION);
    private static final List<Float> MODEL_PARAMETER_COVARIANCE = Arrays.asList(
        (float) ORBITAL_PERIOD.getValue(), 0F, 0F,
        (float) ORBITAL_INCLINATION.getValue());
    static final long PIPELINE_TASK_ID = 44;
    static final PipelineTask PIPELINE_TASK = createPipelineTask(PIPELINE_TASK_ID);

    private DvPlanetModelFit planetModelFit;

    private static PipelineTask createPipelineTask(long pipelineTaskId) {
        PipelineTask pipelineTask = new PipelineTask();
        pipelineTask.setId(pipelineTaskId);

        return pipelineTask;
    }

    private static DvModelParameter createDvModelParameter(float seed) {
        return new DvModelParameter(Float.toString(seed), seed + .01F,
            seed + 0.02F, true);
    }

    @Before
    public void createExpectedPlanetModelFit() {
        planetModelFit = createPlanetModelFit(KEPLER_ID, PLANET_NUMBER, TYPE,
            MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM, MODEL_FIT_SNR,
            TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME, MODEL_PARAMETERS,
            MODEL_PARAMETER_COVARIANCE, PIPELINE_TASK);
    }

    static DvPlanetModelFit createPlanetModelFit(float seed) {
        return createPlanetModelFit(KEPLER_ID + (int) seed, PLANET_NUMBER
            + (int) seed, TYPE, MODEL_CHI_SQUARE + seed,
            MODEL_DEGREES_OF_FREEDOM + seed, MODEL_FIT_SNR + seed,
            TRANSIT_MODEL_NAME + seed, LIMB_DARKENING_MODEL_NAME + seed,
            modelParameterAdd(MODEL_PARAMETERS, seed),
            add(MODEL_PARAMETER_COVARIANCE, seed),
            createPipelineTask(PIPELINE_TASK_ID + (int) seed));
    }

    private static List<DvModelParameter> modelParameterAdd(
        List<DvModelParameter> modelParameters, float seed) {

        List<DvModelParameter> newModelParameters = new ArrayList<DvModelParameter>();
        for (DvModelParameter modelParameter : modelParameters) {
            newModelParameters.add(new DvModelParameter(
                modelParameter.getName() + seed, modelParameter.getValue()
                    + seed, modelParameter.getUncertainty() + seed,
                modelParameter.isFitted()));
        }

        return newModelParameters;
    }

    private static List<Float> add(List<Float> list, float seed) {
        List<Float> newList = new ArrayList<Float>(list.size());
        for (Float element : list) {
            newList.add(element + seed);
        }

        return newList;
    }

    private static DvPlanetModelFit createPlanetModelFit(int keplerId,
        int planetNumber, PlanetModelFitType type, float modelChiSquare,
        float modelDegreesOfFreedom, float modelFitSnr,
        String transitModelName, String limbDarkeningModelName,
        List<DvModelParameter> modelParameters,
        List<Float> modelParameterCovariance, PipelineTask pipelineTask) {

        return createPlanetModelFit(ID, keplerId, planetNumber, type,
            modelChiSquare, modelDegreesOfFreedom, modelFitSnr,
            transitModelName, limbDarkeningModelName, modelParameters,
            modelParameterCovariance, pipelineTask);
    }

    private static DvPlanetModelFit createPlanetModelFit(long id, int keplerId,
        int planetNumber, PlanetModelFitType type, float modelChiSquare,
        float modelDegreesOfFreedom, float modelFitSnr,
        String transitModelName, String limbDarkeningModelName,
        List<DvModelParameter> modelParameters,
        List<Float> modelParameterCovariance, PipelineTask pipelineTask) {

        return new DvPlanetModelFit.Builder(keplerId, planetNumber,
            pipelineTask).id(id)
            .type(type)
            .modelChiSquare(modelChiSquare)
            .modelDegreesOfFreedom(modelDegreesOfFreedom)
            .modelFitSnr(modelFitSnr)
            .transitModelName(transitModelName)
            .limbDarkeningModelName(limbDarkeningModelName)
            .modelParameters(modelParameters)
            .modelParameterCovariance(modelParameterCovariance)
            .build();
    }

    @Test
    public void testConstructor() {
        // Create simply to get code coverage.
        new DvPlanetModelFit();

        testPlanetModelFit(planetModelFit);
    }

    static void testPlanetModelFit(DvPlanetModelFit planetModelFit) {
        assertEquals(ID, planetModelFit.getId());
        assertEquals(KEPLER_ID, planetModelFit.getKeplerId());
        assertEquals(MODEL_CHI_SQUARE, planetModelFit.getModelChiSquare(), 0);
        assertEquals(MODEL_DEGREES_OF_FREEDOM,
            planetModelFit.getModelDegreesOfFreedom(), 0);
        assertEquals(MODEL_FIT_SNR, planetModelFit.getModelFitSnr(), 0);
        assertEquals(PLANET_NUMBER, planetModelFit.getPlanetNumber());
        assertEquals(TYPE, planetModelFit.getType());
        assertEquals(TRANSIT_MODEL_NAME, planetModelFit.getTransitModelName());
        assertEquals(LIMB_DARKENING_MODEL_NAME,
            planetModelFit.getLimbDarkeningModelName());
        assertEquals(MODEL_PARAMETERS, planetModelFit.getModelParameters());
        ReflectionEquals reflectionEquals = new ReflectionEquals();
        try {
            reflectionEquals.assertEquals(MODEL_PARAMETER_COVARIANCE,
                planetModelFit.getModelParameterCovariance());
        } catch (IllegalAccessException e) {
            log.error(e);
            fail(e.getMessage());
        }
        assertEquals(PIPELINE_TASK, planetModelFit.getPipelineTask());
    }

    @Test
    public void testEquals() {
        // Include all don't-care fields here.
        DvPlanetModelFit pmf = createPlanetModelFit(ID + 1, KEPLER_ID,
            PLANET_NUMBER, TYPE, MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM,
            MODEL_FIT_SNR, TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME,
            MODEL_PARAMETERS, MODEL_PARAMETER_COVARIANCE, PIPELINE_TASK);
        assertEquals(planetModelFit, pmf);

        pmf = createPlanetModelFit(KEPLER_ID + 1, PLANET_NUMBER, TYPE,
            MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM, MODEL_FIT_SNR,
            TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME, MODEL_PARAMETERS,
            MODEL_PARAMETER_COVARIANCE, PIPELINE_TASK);
        assertFalse("equals", planetModelFit.equals(pmf));

        pmf = createPlanetModelFit(KEPLER_ID, PLANET_NUMBER + 1, TYPE,
            MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM, MODEL_FIT_SNR,
            TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME, MODEL_PARAMETERS,
            MODEL_PARAMETER_COVARIANCE, PIPELINE_TASK);
        assertFalse("equals", planetModelFit.equals(pmf));

        pmf = createPlanetModelFit(KEPLER_ID, PLANET_NUMBER,
            PlanetModelFitType.ODD, MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM,
            MODEL_FIT_SNR, TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME,
            MODEL_PARAMETERS, MODEL_PARAMETER_COVARIANCE, PIPELINE_TASK);
        assertFalse("equals", planetModelFit.equals(pmf));

        pmf = createPlanetModelFit(KEPLER_ID, PLANET_NUMBER, TYPE,
            MODEL_CHI_SQUARE + 1, MODEL_DEGREES_OF_FREEDOM, MODEL_FIT_SNR,
            TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME, MODEL_PARAMETERS,
            MODEL_PARAMETER_COVARIANCE, PIPELINE_TASK);
        assertFalse("equals", planetModelFit.equals(pmf));

        pmf = createPlanetModelFit(KEPLER_ID, PLANET_NUMBER, TYPE,
            MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM + 1, MODEL_FIT_SNR,
            TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME, MODEL_PARAMETERS,
            MODEL_PARAMETER_COVARIANCE, PIPELINE_TASK);
        assertFalse("equals", planetModelFit.equals(pmf));

        pmf = createPlanetModelFit(KEPLER_ID, PLANET_NUMBER, TYPE,
            MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM, MODEL_FIT_SNR + 1,
            TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME, MODEL_PARAMETERS,
            MODEL_PARAMETER_COVARIANCE, PIPELINE_TASK);
        assertFalse("equals", planetModelFit.equals(pmf));

        pmf = createPlanetModelFit(KEPLER_ID, PLANET_NUMBER, TYPE,
            MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM, MODEL_FIT_SNR,
            TRANSIT_MODEL_NAME + "foo", LIMB_DARKENING_MODEL_NAME,
            MODEL_PARAMETERS, MODEL_PARAMETER_COVARIANCE, PIPELINE_TASK);
        assertFalse("equals", planetModelFit.equals(pmf));

        pmf = createPlanetModelFit(KEPLER_ID, PLANET_NUMBER, TYPE,
            MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM, MODEL_FIT_SNR,
            TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME + "foo",
            MODEL_PARAMETERS, MODEL_PARAMETER_COVARIANCE, PIPELINE_TASK);
        assertFalse("equals", planetModelFit.equals(pmf));

        pmf = createPlanetModelFit(KEPLER_ID, PLANET_NUMBER, TYPE,
            MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM, MODEL_FIT_SNR,
            TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME,
            modelParameterAdd(MODEL_PARAMETERS, 1), MODEL_PARAMETER_COVARIANCE,
            PIPELINE_TASK);
        assertFalse("equals", planetModelFit.equals(pmf));

        pmf = createPlanetModelFit(KEPLER_ID, PLANET_NUMBER, TYPE,
            MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM, MODEL_FIT_SNR,
            TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME, MODEL_PARAMETERS,
            add(MODEL_PARAMETER_COVARIANCE, 1), PIPELINE_TASK);
        assertFalse("equals", planetModelFit.equals(pmf));

        pmf = createPlanetModelFit(KEPLER_ID, PLANET_NUMBER, TYPE,
            MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM, MODEL_FIT_SNR,
            TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME, MODEL_PARAMETERS,
            MODEL_PARAMETER_COVARIANCE,
            createPipelineTask(PIPELINE_TASK_ID + 1));
        assertFalse("equals", planetModelFit.equals(pmf));
    }

    @Test
    public void testHashCode() {
        // Include all don't-care fields here.
        DvPlanetModelFit pmf = createPlanetModelFit(ID + 1, KEPLER_ID,
            PLANET_NUMBER, TYPE, MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM,
            MODEL_FIT_SNR, TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME,
            MODEL_PARAMETERS, MODEL_PARAMETER_COVARIANCE, PIPELINE_TASK);
        assertEquals(planetModelFit.hashCode(), pmf.hashCode());

        pmf = createPlanetModelFit(KEPLER_ID + 1, PLANET_NUMBER, TYPE,
            MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM, MODEL_FIT_SNR,
            TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME, MODEL_PARAMETERS,
            MODEL_PARAMETER_COVARIANCE, PIPELINE_TASK);
        assertFalse("hashCode", planetModelFit.hashCode() == pmf.hashCode());

        pmf = createPlanetModelFit(KEPLER_ID, PLANET_NUMBER + 1, TYPE,
            MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM, MODEL_FIT_SNR,
            TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME, MODEL_PARAMETERS,
            MODEL_PARAMETER_COVARIANCE, PIPELINE_TASK);
        assertFalse("hashCode", planetModelFit.hashCode() == pmf.hashCode());

        pmf = createPlanetModelFit(KEPLER_ID, PLANET_NUMBER,
            PlanetModelFitType.ODD, MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM,
            MODEL_FIT_SNR, TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME,
            MODEL_PARAMETERS, MODEL_PARAMETER_COVARIANCE, PIPELINE_TASK);
        assertFalse("hashCode", planetModelFit.hashCode() == pmf.hashCode());

        pmf = createPlanetModelFit(KEPLER_ID, PLANET_NUMBER, TYPE,
            MODEL_CHI_SQUARE + 1, MODEL_DEGREES_OF_FREEDOM, MODEL_FIT_SNR,
            TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME, MODEL_PARAMETERS,
            MODEL_PARAMETER_COVARIANCE, PIPELINE_TASK);
        assertFalse("hashCode", planetModelFit.hashCode() == pmf.hashCode());

        pmf = createPlanetModelFit(KEPLER_ID, PLANET_NUMBER, TYPE,
            MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM + 1, MODEL_FIT_SNR,
            TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME, MODEL_PARAMETERS,
            MODEL_PARAMETER_COVARIANCE, PIPELINE_TASK);
        assertFalse("hashCode", planetModelFit.hashCode() == pmf.hashCode());

        pmf = createPlanetModelFit(KEPLER_ID, PLANET_NUMBER, TYPE,
            MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM, MODEL_FIT_SNR + 1,
            TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME, MODEL_PARAMETERS,
            MODEL_PARAMETER_COVARIANCE, PIPELINE_TASK);
        assertFalse("hashCode", planetModelFit.hashCode() == pmf.hashCode());

        pmf = createPlanetModelFit(KEPLER_ID, PLANET_NUMBER, TYPE,
            MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM, MODEL_FIT_SNR,
            TRANSIT_MODEL_NAME + "foo", LIMB_DARKENING_MODEL_NAME,
            MODEL_PARAMETERS, MODEL_PARAMETER_COVARIANCE, PIPELINE_TASK);
        assertFalse("hashCode", planetModelFit.hashCode() == pmf.hashCode());

        pmf = createPlanetModelFit(KEPLER_ID, PLANET_NUMBER, TYPE,
            MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM, MODEL_FIT_SNR,
            TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME + "foo",
            MODEL_PARAMETERS, MODEL_PARAMETER_COVARIANCE, PIPELINE_TASK);
        assertFalse("hashCode", planetModelFit.hashCode() == pmf.hashCode());

        pmf = createPlanetModelFit(KEPLER_ID, PLANET_NUMBER, TYPE,
            MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM, MODEL_FIT_SNR,
            TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME,
            modelParameterAdd(MODEL_PARAMETERS, 1), MODEL_PARAMETER_COVARIANCE,
            PIPELINE_TASK);
        assertFalse("hashCode", planetModelFit.hashCode() == pmf.hashCode());

        pmf = createPlanetModelFit(KEPLER_ID, PLANET_NUMBER, TYPE,
            MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM, MODEL_FIT_SNR,
            TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME, MODEL_PARAMETERS,
            add(MODEL_PARAMETER_COVARIANCE, 1), PIPELINE_TASK);
        assertFalse("hashCode", planetModelFit.hashCode() == pmf.hashCode());

        pmf = createPlanetModelFit(KEPLER_ID, PLANET_NUMBER, TYPE,
            MODEL_CHI_SQUARE, MODEL_DEGREES_OF_FREEDOM, MODEL_FIT_SNR,
            TRANSIT_MODEL_NAME, LIMB_DARKENING_MODEL_NAME, MODEL_PARAMETERS,
            MODEL_PARAMETER_COVARIANCE,
            createPipelineTask(PIPELINE_TASK_ID + 1));
        assertFalse("hashCode", planetModelFit.hashCode() == pmf.hashCode());
    }

    @Test
    public void testToString() {
        // Check log and ensure that output isn't brutally long.
        log.info(planetModelFit.toString());
    }
}
