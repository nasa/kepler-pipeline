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
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.hibernate.pi.PipelineTask;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Before;
import org.junit.Test;

/**
 * Test the {@link DvLimbDarkeningModel} class.
 * 
 * @author Forrest Girouard
 */
public class DvLimbDarkeningModelTest {

    private static final Log log = LogFactory.getLog(DvLimbDarkeningModelTest.class);

    private static final int START_CADENCE = 9999;
    private static final int END_CADENCE = 99999;
    private static final int KEPLER_ID = 9;
    private static final int TARGET_TABLE_ID = 99;
    private static final int QUARTER = 9;
    private static final int CCD_MODULE = 9;
    private static final int CCD_OUTPUT = 3;
    private static final String LIMB_DARKENING_MODEL_NAME = "kepler_nonlinear_limb_darkening_model";
    private static final float COEFFICIENT1 = 0.42F;
    private static final float COEFFICIENT2 = 0.042F;
    private static final float COEFFICIENT3 = 0.0042F;
    private static final float COEFFICIENT4 = 0.00042F;
    private static final long PIPELINE_TASK_ID = 999L;
    private static final FluxType FLUX_TYPE = FluxType.SAP;
    private static final PipelineTask PIPELINE_TASK = createPipelineTask(PIPELINE_TASK_ID);

    private DvLimbDarkeningModel limbDarkeningModel;

    private static PipelineTask createPipelineTask(long pipelineTaskId) {
        PipelineTask pipelineTask = new PipelineTask();
        pipelineTask.setId(pipelineTaskId);

        return pipelineTask;
    }

    @Before
    public void createExpectedLimbDarkeningModel() {
        limbDarkeningModel = createLimbDarkeningModel(TARGET_TABLE_ID,
            FLUX_TYPE, KEPLER_ID, PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT,
            START_CADENCE, END_CADENCE, QUARTER, LIMB_DARKENING_MODEL_NAME,
            COEFFICIENT1, COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
    }

    private static DvLimbDarkeningModel createLimbDarkeningModel(
        int targetTableId, FluxType fluxType, int keplerId,
        PipelineTask pipelineTask, int ccdModule, int ccdOutput,
        int startCadence, int endCadence, int quarter, String modelName,
        float coefficient1, float coefficient2, float coefficient3,
        float coefficient4) {

        return new DvLimbDarkeningModel.Builder(targetTableId, fluxType,
            keplerId, pipelineTask).ccdModule(ccdModule)
            .ccdOutput(ccdOutput)
            .startCadence(startCadence)
            .endCadence(endCadence)
            .quarter(quarter)
            .modelName(modelName)
            .coefficient1(coefficient1)
            .coefficient2(coefficient2)
            .coefficient3(coefficient3)
            .coefficient4(coefficient4)
            .build();
    }

    @Test
    public void testConstructor() {
        // Create simply to get code coverage.
        new DvLimbDarkeningModel();

        testLimbDarkeningModel(limbDarkeningModel);
    }

    private void testLimbDarkeningModel(DvLimbDarkeningModel limbDarkeningModel) {

        assertEquals(KEPLER_ID, limbDarkeningModel.getKeplerId());
        assertEquals(TARGET_TABLE_ID, limbDarkeningModel.getTargetTableId());
        assertEquals(FLUX_TYPE, limbDarkeningModel.getFluxType());
        assertEquals(CCD_MODULE, limbDarkeningModel.getCcdModule());
        assertEquals(CCD_OUTPUT, limbDarkeningModel.getCcdOutput());
        assertEquals(START_CADENCE, limbDarkeningModel.getStartCadence());
        assertEquals(END_CADENCE, limbDarkeningModel.getEndCadence());
        assertEquals(QUARTER, limbDarkeningModel.getQuarter());
        assertEquals(LIMB_DARKENING_MODEL_NAME,
            limbDarkeningModel.getModelName());
        assertEquals(COEFFICIENT1, limbDarkeningModel.getCoefficient1(), 1e-10);
        assertEquals(COEFFICIENT2, limbDarkeningModel.getCoefficient2(), 1e-10);
        assertEquals(COEFFICIENT3, limbDarkeningModel.getCoefficient3(), 1e-10);
        assertEquals(COEFFICIENT4, limbDarkeningModel.getCoefficient4(), 1e-10);
        assertEquals(PIPELINE_TASK, limbDarkeningModel.getPipelineTask());
    }

    @Test
    public void testEquals() {
        DvLimbDarkeningModel model = createLimbDarkeningModel(TARGET_TABLE_ID,
            FLUX_TYPE, KEPLER_ID, PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT,
            START_CADENCE, END_CADENCE, QUARTER, LIMB_DARKENING_MODEL_NAME,
            COEFFICIENT1, COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertEquals(limbDarkeningModel, model);

        model = createLimbDarkeningModel(TARGET_TABLE_ID + 1, FLUX_TYPE,
            KEPLER_ID, PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT, START_CADENCE,
            END_CADENCE, QUARTER, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1,
            COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertFalse("equals", limbDarkeningModel.equals(model));

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FluxType.OAP,
            KEPLER_ID, PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT, START_CADENCE,
            END_CADENCE, QUARTER, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1,
            COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertFalse("equals", limbDarkeningModel.equals(model));

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE,
            KEPLER_ID + 1, PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT,
            START_CADENCE, END_CADENCE, QUARTER, LIMB_DARKENING_MODEL_NAME,
            COEFFICIENT1, COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertFalse("equals", limbDarkeningModel.equals(model));

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            createPipelineTask(PIPELINE_TASK_ID + 1), CCD_MODULE, CCD_OUTPUT,
            START_CADENCE, END_CADENCE, QUARTER, LIMB_DARKENING_MODEL_NAME,
            COEFFICIENT1, COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertFalse("equals", limbDarkeningModel.equals(model));

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            PIPELINE_TASK, CCD_MODULE + 1, CCD_OUTPUT, START_CADENCE,
            END_CADENCE, QUARTER, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1,
            COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertFalse("equals", limbDarkeningModel.equals(model));

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT + 1, START_CADENCE,
            END_CADENCE, QUARTER, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1,
            COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertFalse("equals", limbDarkeningModel.equals(model));

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT, START_CADENCE + 1,
            END_CADENCE, QUARTER, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1,
            COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertFalse("equals", limbDarkeningModel.equals(model));

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT, START_CADENCE,
            END_CADENCE + 1, QUARTER, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1,
            COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertFalse("equals", limbDarkeningModel.equals(model));

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE,
            QUARTER + 1, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1, COEFFICIENT2,
            COEFFICIENT3, COEFFICIENT4);
        assertFalse("equals", limbDarkeningModel.equals(model));

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE,
            QUARTER, "special_" + LIMB_DARKENING_MODEL_NAME, COEFFICIENT1,
            COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertFalse("equals", limbDarkeningModel.equals(model));

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE,
            QUARTER, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1 + 1.0F,
            COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertFalse("equals", limbDarkeningModel.equals(model));

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE,
            QUARTER, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1,
            COEFFICIENT2 + 1.0F, COEFFICIENT3, COEFFICIENT4);
        assertFalse("equals", limbDarkeningModel.equals(model));

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE,
            QUARTER, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1, COEFFICIENT2,
            COEFFICIENT3 + 1.0F, COEFFICIENT4);
        assertFalse("equals", limbDarkeningModel.equals(model));

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE,
            QUARTER, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1, COEFFICIENT2,
            COEFFICIENT3, COEFFICIENT4 + 1.0F);
        assertFalse("equals", limbDarkeningModel.equals(model));
    }

    @Test
    public void testHashCode() {
        DvLimbDarkeningModel model = createLimbDarkeningModel(TARGET_TABLE_ID,
            FLUX_TYPE, KEPLER_ID, PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT,
            START_CADENCE, END_CADENCE, QUARTER, LIMB_DARKENING_MODEL_NAME,
            COEFFICIENT1, COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertEquals(limbDarkeningModel.hashCode(), model.hashCode());

        model = createLimbDarkeningModel(TARGET_TABLE_ID + 1, FLUX_TYPE,
            KEPLER_ID, PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT, START_CADENCE,
            END_CADENCE, QUARTER, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1,
            COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertFalse("hashCode",
            limbDarkeningModel.hashCode() == model.hashCode());

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FluxType.OAP,
            KEPLER_ID, PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT, START_CADENCE,
            END_CADENCE, QUARTER, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1,
            COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertFalse("hashCode",
            limbDarkeningModel.hashCode() == model.hashCode());

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE,
            KEPLER_ID + 1, PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT,
            START_CADENCE, END_CADENCE, QUARTER, LIMB_DARKENING_MODEL_NAME,
            COEFFICIENT1, COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertFalse("hashCode",
            limbDarkeningModel.hashCode() == model.hashCode());

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            createPipelineTask(PIPELINE_TASK_ID + 1), CCD_MODULE, CCD_OUTPUT,
            START_CADENCE, END_CADENCE, QUARTER, LIMB_DARKENING_MODEL_NAME,
            COEFFICIENT1, COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertFalse("hashCode",
            limbDarkeningModel.hashCode() == model.hashCode());

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            PIPELINE_TASK, CCD_MODULE + 1, CCD_OUTPUT, START_CADENCE,
            END_CADENCE, QUARTER, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1,
            COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertFalse("hashCode",
            limbDarkeningModel.hashCode() == model.hashCode());

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT + 1, START_CADENCE,
            END_CADENCE, QUARTER, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1,
            COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertFalse("hashCode",
            limbDarkeningModel.hashCode() == model.hashCode());

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT, START_CADENCE + 1,
            END_CADENCE, QUARTER, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1,
            COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertFalse("hashCode",
            limbDarkeningModel.hashCode() == model.hashCode());

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT, START_CADENCE,
            END_CADENCE + 1, QUARTER, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1,
            COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertFalse("hashCode",
            limbDarkeningModel.hashCode() == model.hashCode());

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE,
            QUARTER + 1, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1, COEFFICIENT2,
            COEFFICIENT3, COEFFICIENT4);
        assertFalse("hashCode",
            limbDarkeningModel.hashCode() == model.hashCode());

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE,
            QUARTER, "special_" + LIMB_DARKENING_MODEL_NAME, COEFFICIENT1,
            COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertFalse("hashCode",
            limbDarkeningModel.hashCode() == model.hashCode());

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE,
            QUARTER, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1 + 1.0F,
            COEFFICIENT2, COEFFICIENT3, COEFFICIENT4);
        assertFalse("hashCode",
            limbDarkeningModel.hashCode() == model.hashCode());

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE,
            QUARTER, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1,
            COEFFICIENT2 + 1.0F, COEFFICIENT3, COEFFICIENT4);
        assertFalse("hashCode",
            limbDarkeningModel.hashCode() == model.hashCode());

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE,
            QUARTER, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1, COEFFICIENT2,
            COEFFICIENT3 + 1.0F, COEFFICIENT4);
        assertFalse("hashCode",
            limbDarkeningModel.hashCode() == model.hashCode());

        model = createLimbDarkeningModel(TARGET_TABLE_ID, FLUX_TYPE, KEPLER_ID,
            PIPELINE_TASK, CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE,
            QUARTER, LIMB_DARKENING_MODEL_NAME, COEFFICIENT1, COEFFICIENT2,
            COEFFICIENT3, COEFFICIENT4 + 1.0F);
        assertFalse("hashCode",
            limbDarkeningModel.hashCode() == model.hashCode());
    }

    @Test
    public void testToString() {
        // Check log and ensure that output isn't brutally long.
        log.info(limbDarkeningModel.toString());
    }
}
