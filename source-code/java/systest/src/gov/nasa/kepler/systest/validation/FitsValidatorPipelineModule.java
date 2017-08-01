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

package gov.nasa.kepler.systest.validation;

import static gov.nasa.kepler.systest.validation.ValidatorPipelineModuleUtils.getMostRecentInstanceId;
import gov.nasa.kepler.cal.CalPipelineModule;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.common.pi.PlannedPhotometerConfigParameters;
import gov.nasa.kepler.etem2.DataGenDirManager;
import gov.nasa.kepler.etem2.DataGenParameters;
import gov.nasa.kepler.etem2.PackerParameters;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.kepler.pa.PaPipelineModule;
import gov.nasa.kepler.pdc.PdcPipelineModule;
import gov.nasa.kepler.systest.validation.FitsValidationOptions.Command;
import gov.nasa.kepler.systest.validation.flux.FitsFluxValidator;
import gov.nasa.kepler.systest.validation.pixels.FitsArpPixelValidator;
import gov.nasa.kepler.systest.validation.pixels.FitsBackgroundPixelValidator;
import gov.nasa.kepler.systest.validation.pixels.FitsCollateralPixelValidator;
import gov.nasa.kepler.systest.validation.pixels.FitsPixelValidator;
import gov.nasa.kepler.systest.validation.pixels.FitsTargetPixelValidator;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.List;

public class FitsValidatorPipelineModule extends PipelineModule {

    public static final String MODULE_NAME = "fits-validator";

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return ModOutCadenceUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        ArrayList<Class<? extends Parameters>> parameters = new ArrayList<Class<? extends Parameters>>();

        parameters.add(CadenceRangeParameters.class);
        parameters.add(CadenceTypePipelineParameters.class);
        parameters.add(DataGenParameters.class);
        parameters.add(FitsValidationParameters.class);
        parameters.add(PackerParameters.class);
        parameters.add(PlannedPhotometerConfigParameters.class);

        return parameters;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) throws PipelineException {

        FitsValidationOptions options = retrieveOptions(pipelineTask);

        try {
            options.setCommand(Command.VALIDATE_FLUX);
            new FitsFluxValidator(options).validate();

            options.setCommand(Command.VALIDATE_PIXELS_IN);
            new FitsPixelValidator(options).validate();

            options.setCommand(Command.VALIDATE_PIXELS_OUT);
            new FitsPixelValidator(options).validate();

            options.setCommand(Command.VALIDATE_TARGET_PIXELS);
            new FitsTargetPixelValidator(options).validate();

            if (options.getCadenceType() == CadenceType.LONG) {
                options.setCommand(Command.VALIDATE_BACKGROUND_PIXELS);
                new FitsBackgroundPixelValidator(options).validate();

                options.setCommand(Command.VALIDATE_ARP_PIXELS);
                new FitsArpPixelValidator(options).validate();
            }

            options.setCommand(Command.VALIDATE_COLLATERAL_PIXELS);
            new FitsCollateralPixelValidator(options).validate();
        } catch (Exception e) {
            throw new IllegalStateException("A validation error occurred.", e);
        }
    }

    private FitsValidationOptions retrieveOptions(PipelineTask pipelineTask) {

        FitsValidationOptions options = new FitsValidationOptions();

        ModOutCadenceUowTask task = pipelineTask.uowTaskInstance();
        FitsValidationParameters parameters = pipelineTask.getParameters(FitsValidationParameters.class);
        CadenceTypePipelineParameters cadenceTypeParameters = pipelineTask.getParameters(CadenceTypePipelineParameters.class);
        PlannedPhotometerConfigParameters photometerConfigParameters = pipelineTask.getParameters(PlannedPhotometerConfigParameters.class);

        CadenceType cadenceType = CadenceType.valueOf(cadenceTypeParameters.getCadenceType());
        DataGenDirManager dataGenDirManager = new DataGenDirManager(
            pipelineTask.getParameters(DataGenParameters.class),
            pipelineTask.getParameters(PackerParameters.class),
            cadenceTypeParameters);

        options.setArId(getMostRecentInstanceId(cadenceType,
            parameters.getArId(), "targetPixelExporter", null));
        options.setArpPixelsDirectory(dataGenDirManager.getTargetPixelExportDir());
        options.setBackgroundPixelsDirectory(dataGenDirManager.getTargetPixelExportDir());
        options.setCadenceRange(task.getStartCadence(), task.getEndCadence());
        options.setCadenceType(cadenceType);
        options.setCalId(getMostRecentInstanceId(cadenceType,
            parameters.getCalId(), CalPipelineModule.MODULE_NAME, null));
        options.setCcdModule(task.getCcdModule());
        options.setCcdOutput(task.getCcdOutput());
        options.setChunkSize(parameters.getChunkSize());
        options.setCollateralPixelsDirectory(dataGenDirManager.getTargetPixelExportDir());
        options.setFluxDirectory(dataGenDirManager.getTargetPixelExportDir());
        options.setMaxErrorsDisplayed(parameters.getMaxErrorsDisplayed());
        options.setPaId(getMostRecentInstanceId(cadenceType,
            parameters.getPaId(), PaPipelineModule.MODULE_NAME, null));
        options.setPdcId(getMostRecentInstanceId(cadenceType,
            parameters.getPdcId(), PdcPipelineModule.MODULE_NAME, null));
        options.setPixelsInputDirectory(dataGenDirManager.getCadenceFitsDir());
        options.setPixelsOutputDirectory(dataGenDirManager.getCalExportDir(
            cadenceType, task.getStartCadence(), task.getEndCadence()));
        options.setPmrfDirectory(dataGenDirManager.getPmrfDir(photometerConfigParameters));
        options.setSkipCount(parameters.getSkipCount());
        options.setTargetPixelsDirectory(dataGenDirManager.getTargetPixelExportDir());
        options.setTargetSkipCount(parameters.getTargetSkipCount());
        options.setTasksRootDirectory(parameters.getTasksRootDirectory());
        options.setTimeLimit(parameters.getTimeLimit());

        return options;
    }
}
