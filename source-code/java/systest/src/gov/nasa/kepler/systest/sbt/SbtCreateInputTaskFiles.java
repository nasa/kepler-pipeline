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

package gov.nasa.kepler.systest.sbt;

import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.KeplerSocVersion;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.PipelineDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionCrud;
import gov.nasa.kepler.mc.PlanetaryCandidatesFilterParameters;
import gov.nasa.kepler.mc.TargetListParameters;
import gov.nasa.kepler.pi.module.AsyncPipelineModule;
import gov.nasa.kepler.pi.module.InputsHandler;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.util.List;
import java.util.Map;

import com.google.common.primitives.Ints;

/**
 * Creates input task files.
 * 
 * @author Miles Cote
 * 
 */
public class SbtCreateInputTaskFiles {

    private static final String SBT_NAME = "SbtCreateInputTaskFiles";

    /**
     * @param uowArray an array of keplerIds (tps, dv) or channels (mod/outs for
     * cal, pa, pdc)
     */
    public static void createInputTaskFiles(String triggerName,
        String moduleName, String taskFileDirName, int[] uowArray,
        int startCadence, int endCadence) throws Exception {
        checkArguments(triggerName, taskFileDirName, uowArray, startCadence,
            endCadence);

        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        try {
            databaseService.beginTransaction();

            TriggerDefinitionCrud triggerDefinitionCrud = new TriggerDefinitionCrud();
            TriggerDefinition triggerDefinition = triggerDefinitionCrud.retrieve(triggerName);

            setParameters(triggerDefinition, moduleName, uowArray,
                startCadence, endCadence);
            databaseService.flush();

            PipelineInstance pipelineInstance = fireTrigger(triggerDefinition,
                moduleName);
            databaseService.flush();

            generateInputs(taskFileDirName, pipelineInstance);
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    private static void checkArguments(String triggerName,
        String outputDirName, int[] uowArray, int startCadence, int endCadence) {
        checkNotNull(triggerName);

        checkNotNull(outputDirName);

        checkNotNull(uowArray);
        for (int uow : uowArray) {
            if (uow <= 0) {
                throw new IllegalArgumentException(
                    "uow cannot be less than or equal to 0." + "\n  uow: "
                        + uow);
            }
        }

        if (startCadence < 0) {
            throw new IllegalArgumentException(
                "startCadence cannot be less than 0." + "\n  startCadence: "
                    + startCadence);
        }

        if (endCadence < startCadence) {
            throw new IllegalArgumentException(
                "endCadence cannot be less than startCadence."
                    + "\n  startCadence: " + startCadence + "\n  endCadence: "
                    + endCadence);
        }
    }

    private static void setParameters(TriggerDefinition triggerDefinition,
        String moduleName, int[] uowArray, int startCadence, int endCadence) {
        PipelineOperations pipelineOperations = new PipelineOperations();
        Map<ClassWrapper<Parameters>, ParameterSet> parameterSets = pipelineOperations.retrieveParameterSets(
            triggerDefinition, moduleName);

        setCadenceRangeParameters(startCadence, endCadence, pipelineOperations,
            parameterSets);

        if (isModOutArray(uowArray)) {
            setModuleOutputListsParameters(uowArray, pipelineOperations,
                parameterSets);
        } else {
            TargetList targetList = createTargetList(uowArray);

            setPlanetaryCandidatesFilterParameters(targetList,
                pipelineOperations, parameterSets);
            setTargetListParameters(targetList, pipelineOperations,
                parameterSets);
        }
    }

    private static boolean isModOutArray(int[] uowArray) {
        return uowArray[0] <= FcConstants.MODULE_OUTPUTS;
    }

    private static void setPlanetaryCandidatesFilterParameters(
        TargetList targetList, PipelineOperations pipelineOperations,
        Map<ClassWrapper<Parameters>, ParameterSet> parameterSets) {
        ParameterSet parameterSet = parameterSets.get(new ClassWrapper<Parameters>(
            PlanetaryCandidatesFilterParameters.class));
        PlanetaryCandidatesFilterParameters parameters = parameterSet.parametersInstance();
        parameters.setIncludedTargetLists(new String[] { targetList.getName() });
        parameters.setExcludedTargetLists(new String[0]);
        pipelineOperations.updateParameterSet(parameterSet, parameters, false);
        parameterSet.setParameters(new BeanWrapper<Parameters>(parameters));
    }

    private static void setTargetListParameters(TargetList targetList,
        PipelineOperations pipelineOperations,
        Map<ClassWrapper<Parameters>, ParameterSet> parameterSets) {
        ParameterSet parameterSet = parameterSets.get(new ClassWrapper<Parameters>(
            TargetListParameters.class));
        TargetListParameters parameters = parameterSet.parametersInstance();
        parameters.setTargetListNames(new String[] { targetList.getName() });
        pipelineOperations.updateParameterSet(parameterSet, parameters, false);
        parameterSet.setParameters(new BeanWrapper<Parameters>(parameters));
    }

    private static TargetList createTargetList(int[] uowArray) {
        KicCrud kicCrud = new KicCrud();
        Map<Integer, Integer> skyGroupIdsForKeplerIds = kicCrud.retrieveSkyGroupIdsForKeplerIds(Ints.asList(uowArray));

        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();

        TargetList targetList = new TargetList(SBT_NAME);
        targetList.setCategory(SBT_NAME);
        targetSelectionCrud.create(targetList);

        List<PlannedTarget> plannedTargets = newArrayList();
        for (int keplerId : uowArray) {
            PlannedTarget plannedTarget = new PlannedTarget(keplerId,
                skyGroupIdsForKeplerIds.get(keplerId));
            plannedTarget.setTargetList(targetList);
            plannedTargets.add(plannedTarget);
        }
        targetSelectionCrud.create(plannedTargets);

        return targetList;
    }

    private static void setModuleOutputListsParameters(int[] uowArray,
        PipelineOperations pipelineOperations,
        Map<ClassWrapper<Parameters>, ParameterSet> parameterSets) {
        ParameterSet parameterSet = parameterSets.get(new ClassWrapper<Parameters>(
            ModuleOutputListsParameters.class));
        ModuleOutputListsParameters parameters = parameterSet.parametersInstance();
        parameters.setChannelIncludeArray(uowArray);
        parameters.setChannelExcludeArray(new int[0]);
        pipelineOperations.updateParameterSet(parameterSet, parameters, false);
        parameterSet.setParameters(new BeanWrapper<Parameters>(parameters));
    }

    private static void setCadenceRangeParameters(int startCadence,
        int endCadence, PipelineOperations pipelineOperations,
        Map<ClassWrapper<Parameters>, ParameterSet> parameterSets) {
        ParameterSet parameterSet = parameterSets.get(new ClassWrapper<Parameters>(
            CadenceRangeParameters.class));
        CadenceRangeParameters parameters = parameterSet.parametersInstance();
        parameters.setStartCadence(startCadence);
        parameters.setEndCadence(endCadence);
        pipelineOperations.updateParameterSet(parameterSet, parameters, false);
        parameterSet.setParameters(new BeanWrapper<Parameters>(parameters));
    }

    private static PipelineInstance fireTrigger(
        TriggerDefinition triggerDefinition, String moduleName) {
        PipelineDefinitionCrud pipelineDefinitionCrud = new PipelineDefinitionCrud();
        PipelineDefinition pipelineDefinition = pipelineDefinitionCrud.retrieveLatestVersionForName(triggerDefinition.getPipelineDefinitionName());

        PipelineDefinitionNode pipelineDefinitionNode = findPipelineDefinitionNodeWithName(
            pipelineDefinition.getRootNodes(), moduleName);

        PipelineOperations pipelineOperations = new PipelineOperations();
        PipelineInstance pipelineInstance = pipelineOperations.fireTrigger(
            triggerDefinition, SBT_NAME, pipelineDefinitionNode,
            pipelineDefinitionNode);
        return pipelineInstance;
    }

    private static PipelineDefinitionNode findPipelineDefinitionNodeWithName(
        List<PipelineDefinitionNode> pipelineDefinitionNodes, String moduleName) {
        if (pipelineDefinitionNodes.isEmpty()) {
            return null;
        }

        for (PipelineDefinitionNode pipelineDefinitionNode : pipelineDefinitionNodes) {
            if (pipelineDefinitionNode.getModuleName()
                .getName()
                .equals(moduleName)) {
                return pipelineDefinitionNode;
            }

            PipelineDefinitionNode pipelineDefinitionNodeWithName = findPipelineDefinitionNodeWithName(
                pipelineDefinitionNode.getNextNodes(), moduleName);
            if (pipelineDefinitionNodeWithName != null) {
                return pipelineDefinitionNodeWithName;
            }
        }

        return null;
    }

    private static void generateInputs(String taskFileDirName,
        PipelineInstance pipelineInstance) throws Exception {
        PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();
        List<PipelineTask> pipelineTasks = pipelineTaskCrud.retrieveAll(pipelineInstance);

        for (PipelineTask pipelineTask : pipelineTasks) {
            pipelineTask.setSoftwareRevision(KeplerSocVersion.getUrl() + "@"
                + KeplerSocVersion.getRevision());
            DatabaseServiceFactory.getInstance()
                .flush();

            PipelineModule pipelineModule = pipelineTask.getPipelineInstanceNode()
                .getPipelineModuleDefinition()
                .getImplementingClass()
                .newInstance();

            if (pipelineModule instanceof MatlabPipelineModule) {
                MatlabPipelineModule matlabPipelineModule = (MatlabPipelineModule) pipelineModule;
                matlabPipelineModule.setPipelineTask(pipelineTask);
                matlabPipelineModule.initialize(pipelineTask);
            } else {
                throw new IllegalArgumentException(
                    "pipelineModule must be an instance of MatlabPipelineModule."
                        + "\n  pipelineModule.class.simpleName: "
                        + pipelineModule.getClass()
                            .getSimpleName());
            }

            if (pipelineModule instanceof AsyncPipelineModule) {
                AsyncPipelineModule asyncPipelineModule = (AsyncPipelineModule) pipelineModule;

                File workingDir = new File(taskFileDirName,
                    pipelineTask.getUowTask()
                        .getInstance()
                        .briefState());
                FileUtil.cleanDir(workingDir);

                InputsHandler inputsHandler = new InputsHandler();
                asyncPipelineModule.generateInputs(inputsHandler, pipelineTask, workingDir);
            } else {
                throw new IllegalArgumentException(
                    "pipelineModule must be an instance of AsyncPipelineModule."
                        + "\n  pipelineModule.class.simpleName: "
                        + pipelineModule.getClass()
                            .getSimpleName());
            }
        }
    }

    public static void main(String[] args) throws Exception {
        // System.setProperty(
        // ConfigurationServiceFactory.CONFIG_SERVICE_PROPERTIES_PATH_PROP,
        // "/path/to/test.properties");
        // createInputTaskFiles("Planet Search", "dv",
        // "/path/to/dv_inputs", new int[] { 11853905, 8191672 },
        // 29873, 30667);
        // createInputTaskFiles("Planet Search", "tps",
        // "/path/to/tps_inputs", new int[] { 11853905, 8191672 },
        // 29873, 30667);
        // createInputTaskFiles("Quarterly LC Mega", "pdc",
        // "/path/to/pdc_inputs", new int[] { 19, 20 }, 29873,
        // 30667);
        // createInputTaskFiles("Quarterly LC Mega", "cal",
        // "/path/to/cal_inputs", new int[] { 19, 20 }, 29873,
        // 30667);

        // System.setProperty(
        // ConfigurationServiceFactory.CONFIG_SERVICE_PROPERTIES_PATH_PROP,
        // "/path/to/dw4.properties");
        // createInputTaskFiles("PLANETSEARCH_LC", "dv",
        // "/path/to/tps_inputs", new int[] { 4557572 }, 20579,
        // 20580);
        // createInputTaskFiles("PLANETSEARCH_LC", "tps",
        // "/path/to/tps_inputs", new int[] { 4557572 }, 20579,
        // 20580);
        // createInputTaskFiles("PHOTOMETRY_LC", "pdc",
        // "/path/to/pdc_inputs", new int[] { 19 }, 20579, 20580);
        // createInputTaskFiles("PHOTOMETRY_LC", "cal",
        // "/path/to/cal_inputs", new int[] { 19 }, 20579, 20580);

        System.exit(0);
    }

}
