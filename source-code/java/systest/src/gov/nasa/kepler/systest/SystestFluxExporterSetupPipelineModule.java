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

package gov.nasa.kepler.systest;

import gov.nasa.kepler.common.pi.PlannedPhotometerConfigParameters;
import gov.nasa.kepler.etem2.DataGenDirManager;
import gov.nasa.kepler.etem2.DataGenParameters;
import gov.nasa.kepler.etem2.PackerParameters;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.TargetTableParameters;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.ops.seed.CommonPipelineSeedData;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class SystestFluxExporterSetupPipelineModule extends PipelineModule {

    public static final String MODULE_NAME = "fluxExporterSetup";

    private static final Log log = LogFactory.getLog(SystestFluxExporterSetupPipelineModule.class);

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
        List<Class<? extends Parameters>> requiredParams = new ArrayList<Class<? extends Parameters>>();
        requiredParams.add(DataGenParameters.class);
        requiredParams.add(PackerParameters.class);
        requiredParams.add(PlannedPhotometerConfigParameters.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        try {
            DataGenParameters dataGenParams = pipelineTask.getParameters(DataGenParameters.class);
            PackerParameters packerParams = pipelineTask.getParameters(PackerParameters.class);
            DataGenDirManager dataGenDirManager = new DataGenDirManager(
                dataGenParams, packerParams);

            PlannedPhotometerConfigParameters photometerConfigParams = pipelineTask.getParameters(PlannedPhotometerConfigParameters.class);

            File exportDir = new File(dataGenDirManager.getFluxExportDir());

            // Clean the exportDir.
            log.info("Cleaning export dir: " + exportDir);
            FileUtil.cleanDir(exportDir);

            // Retrieve targetTables.
            TargetCrud targetCrud = new TargetCrud();
            TargetTable lcTargetTable = targetCrud.retrieveUplinkedTargetTable(
                photometerConfigParams.getLctExternalId(),
                TargetType.LONG_CADENCE);
            TargetTable scTargetTable = targetCrud.retrieveUplinkedTargetTable(
                photometerConfigParams.getSctExternalId(),
                TargetType.SHORT_CADENCE);

            // Set params for the exportPipeline.
            ParameterSetCrud parameterSetCrud = new ParameterSetCrud();
            PipelineOperations pipelineOperations = new PipelineOperations();

            ParameterSet lcTargetTablePs = parameterSetCrud.retrieveLatestVersionForName(CommonPipelineSeedData.LC_TARGET_TABLE);
            TargetTableParameters lcTargetTableParams = lcTargetTablePs.parametersInstance();
            lcTargetTableParams.setTargetTableDbId(lcTargetTable.getId());
            pipelineOperations.updateParameterSet(lcTargetTablePs,
                lcTargetTableParams, false);

            ParameterSet scTargetTablePs = parameterSetCrud.retrieveLatestVersionForName(CommonPipelineSeedData.SC_M1_TARGET_TABLE);
            TargetTableParameters scTargetTableParams = scTargetTablePs.parametersInstance();
            scTargetTableParams.setTargetTableDbId(scTargetTable.getId());
            pipelineOperations.updateParameterSet(scTargetTablePs,
                scTargetTableParams, false);

        } catch (Exception e) {
            AlertServiceFactory.getInstance()
                .generateAlert(MODULE_NAME, pipelineTask.getId(),
                    Severity.WARNING, "Unable to process task.\n" + e);
        }
    }

}
