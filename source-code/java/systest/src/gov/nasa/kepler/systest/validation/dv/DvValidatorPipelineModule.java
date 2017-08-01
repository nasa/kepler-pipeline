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

package gov.nasa.kepler.systest.validation.dv;

import static gov.nasa.kepler.systest.validation.ValidatorPipelineModuleUtils.getMostRecentInstanceId;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.dv.DvPipelineModule;
import gov.nasa.kepler.etem2.DataGenDirManager;
import gov.nasa.kepler.etem2.DataGenParameters;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.systest.validation.FitsValidationOptions;
import gov.nasa.kepler.systest.validation.FitsValidationOptions.Command;
import gov.nasa.kepler.systest.validation.FitsValidationParameters;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.List;

/**
 * Pipeline module for validation of DV exports.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class DvValidatorPipelineModule extends PipelineModule {

    public static final String MODULE_NAME = "dv-validator";

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return SingleUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        ArrayList<Class<? extends Parameters>> parameters = new ArrayList<Class<? extends Parameters>>();

        parameters.add(FitsValidationParameters.class);
        parameters.add(DataGenParameters.class);

        return parameters;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) throws PipelineException {

        FitsValidationOptions options = retrieveOptions(pipelineTask);

        options.setCommand(Command.VALIDATE_DV);
        try {
            /**
             * KSOC-4856 Comment by Sean McCauliff on 11 Aug 2015:
             * When we decided to create a new DV time series FITS file we
             * decided not to update the validator. This exporter will only be
             * run once in production and once for V&V (check). Automating the
             * validation of this file was then viewed as not worth the effort.
             * 
             * I would just disable this validator. 
             */
            // new DvValidator(options).validate();
        } catch (Exception e) {
            throw new IllegalStateException("A validation error occurred.", e);
        }
    }

    private FitsValidationOptions retrieveOptions(PipelineTask pipelineTask) {

        FitsValidationOptions options = new FitsValidationOptions();

        FitsValidationParameters parameters = pipelineTask.getParameters(FitsValidationParameters.class);
        DataGenParameters dataGenParams = pipelineTask.getParameters(DataGenParameters.class);

        DataGenDirManager dataGenDirManager = new DataGenDirManager(
            dataGenParams);

        options.setDvFitsDirectory(dataGenDirManager.getDvTimeSeriesExportDir());
        options.setDvId(getMostRecentInstanceId(CadenceType.LONG,
            parameters.getDvId(), DvPipelineModule.MODULE_NAME, null));
        options.setDvXmlDirectory(dataGenDirManager.getDvExportDir());
        options.setMaxErrorsDisplayed(parameters.getMaxErrorsDisplayed());
        options.setTasksRootDirectory(parameters.getTasksRootDirectory());

        return options;
    }
}
