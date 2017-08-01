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

package gov.nasa.kepler.systest.ops;

import gov.nasa.kepler.common.UsageException;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetCrud;
import gov.nasa.kepler.hibernate.pi.ParameterSetName;
import gov.nasa.kepler.hibernate.pi.PipelineDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionNode;
import gov.nasa.kepler.mc.PouModuleParameters;
import gov.nasa.kepler.mc.TargetListParameters;
import gov.nasa.kepler.pi.parameters.ParameterLibraryXml;
import gov.nasa.kepler.pi.parameters.ParameterSetDescriptor;
import gov.nasa.kepler.pi.parameters.ParameterSetDescriptor.State;
import gov.nasa.kepler.tps.TpsModuleParameters;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.TreeSet;

import org.apache.log4j.Logger;

/**
 * Validator for the monthly and quarterly science pipeline triggers.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class SciencePipelineTriggerValidator {

    private static final Logger log = Logger.getLogger(SciencePipelineTriggerValidator.class);

    private TriggerValidatorOptions options;

    public SciencePipelineTriggerValidator(TriggerValidatorOptions options) {

        this.options = options;
        validateOptions();
    }

    private void validateOptions() {

        if (options.getTriggerName() == null || options.getTriggerName()
            .length() == 0) {
            throw new UsageException("Missing trigger name");
        }
        if (options.getXmlFiles() == null) {
            throw new UsageException("XML files not set");
        }
    }

    public void validateTrigger() throws Exception {
        boolean equals = true;

        TriggerDefinitionCrud triggerDefinitionCrud = new TriggerDefinitionCrud();
        TriggerDefinition triggerDefinition = triggerDefinitionCrud.retrieve(options.getTriggerName());

        if (triggerDefinition == null) {
            throw new IllegalArgumentException(String.format(
                "The given triggerName %s was not found in the database",
                options.getTriggerName()));
        }

        Map<String, ParameterSetDescriptor> parameterSetDescriptorsByName = new HashMap<String, ParameterSetDescriptor>();
        ParameterLibraryXml parameterLibraryXml = new ParameterLibraryXml();
        for (String xmlFile : options.getXmlFiles()) {
            List<ParameterSetDescriptor> parameterSetDescriptors = parameterLibraryXml.readFromFile(xmlFile);
            for (ParameterSetDescriptor parameterSetDescriptor : parameterSetDescriptors) {
                String name = parameterSetDescriptor.getName();
                parameterSetDescriptorsByName.put(name, parameterSetDescriptor);
            }
        }

        Map<ClassWrapper<Parameters>, ParameterSetName> pipelineParameterSetNames = triggerDefinition.getPipelineParameterSetNames();
        PipelineDefinitionCrud pipelineDefinitionCrud = new PipelineDefinitionCrud();
        PipelineDefinition latestPipelineDefinition = pipelineDefinitionCrud.retrieveLatestVersionForName(triggerDefinition.getPipelineDefinitionName());
        latestPipelineDefinition.buildPaths();

        Set<ParameterSetName> parameterSetNames = new HashSet<ParameterSetName>();
        parameterSetNames.addAll(pipelineParameterSetNames.values());
        addParameterSetNames(triggerDefinition,
            latestPipelineDefinition.getRootNodes(), parameterSetNames);

        List<String> messages = new ArrayList<String>();
        ParameterSetCrud parameterSetCrud = new ParameterSetCrud();
        Set<String> names = convertParameterSetNames(parameterSetNames);
        for (String name : names) {

            ParameterSet currentParamSet = parameterSetCrud.retrieveLatestVersionForName(name);
            BeanWrapper<Parameters> currentParamsBean = currentParamSet.getParameters();

            if (currentParamsBean.getClazz() == CadenceRangeParameters.class) {
                messages.add(displayCadenceRangeParameters(name,
                    currentParamsBean));
            }
            if (currentParamsBean.getClazz() == ModuleOutputListsParameters.class) {
                messages.add(displayModuleOutputListsParameters(name,
                    currentParamsBean));
            }
            if (currentParamsBean.getClazz() == PouModuleParameters.class) {
                messages.add(displayPouModuleParameters(name, currentParamsBean));
            }
            if (currentParamsBean.getClazz() == TargetListParameters.class) {
                messages.add(displayTargetListParameters(name,
                    currentParamsBean));
            }
            if (currentParamsBean.getClazz() == TpsModuleParameters.class) {
                messages.add(displayTpsModuleParameters(name, currentParamsBean));
            }

            ParameterSetDescriptor parameterSetDescriptor = null;
            String k2Name = null;
            if (options.isK2Enabled() && !name.trim().endsWith(" (K2)")) {
                k2Name = name.trim() + " (K2)";
                parameterSetDescriptor = parameterSetDescriptorsByName.get(k2Name);
                if (parameterSetDescriptor == null) {
                    k2Name = null;
                    parameterSetDescriptor = parameterSetDescriptorsByName.get(name);
                } else {
                    log.warn(String.format(
                        "Parameter library contains a K2 specific parameter set '%s'",
                        k2Name));
                }
            } else {
                parameterSetDescriptor = parameterSetDescriptorsByName.get(name);
            }
            if (parameterSetDescriptor == null) {
                log.warn(String.format(
                    "Parameter library does not contain expected parameter set '%s'",
                    name));
                continue;
            }

            if (parameterSetDescriptor.getState() == State.CLASS_MISSING) {
                log.warn(String.format(
                    "Parameter library contains parameter set '%s' that refers to an unknown class",
                    name));
                continue;
            }

            BeanWrapper<Parameters> importedParamsBean = parameterSetDescriptor.getImportedParamsBean();
            if (importedParamsBean == null) {
                // TODO Fix root cause and remove this check
                log.error(String.format(
                    "Unexpected null imported params bean for parameter set '%s'",
                    name));
                continue;
            }
            // importedParamsBean = new BeanWrapper<Parameters>(
            // importedParamsBean.getInstance());

            log.debug(String.format("Comparing parameters in set '%s' (%s)",
                k2Name != null ? k2Name : name, parameterSetDescriptor.getClassName()));
            if (!diffParameters(name, currentParamsBean, importedParamsBean)) {
                equals = false;
            }

        }

        for (String message : messages) {
            log.info(message);
        }

        if (!equals) {
            throw new IllegalStateException(
                String.format(
                    "Trigger parameters for '%s' differ from parameter set libraries %s",
                    options.getTriggerName(),
                    displayXmlFiles(options.getXmlFiles())));
        }
    }

    private void addParameterSetNames(TriggerDefinition triggerDefinition,
        List<PipelineDefinitionNode> nodes,
        Set<ParameterSetName> parameterSetNames) {

        for (PipelineDefinitionNode node : nodes) {
            TriggerDefinitionNode triggerNode = triggerDefinition.findNodeForPath(node.getPath());
            if (triggerNode != null) {
                Map<ClassWrapper<Parameters>, ParameterSetName> moduleParameterSetNames = triggerNode.getModuleParameterSetNames();
                parameterSetNames.addAll(moduleParameterSetNames.values());
            }

            addParameterSetNames(triggerDefinition, node.getNextNodes(),
                parameterSetNames);
        }
    }

    private Set<String> convertParameterSetNames(
        Set<ParameterSetName> parameterSetNames) {

        Set<String> names = new TreeSet<String>();
        for (ParameterSetName parameterSetName : parameterSetNames) {
            names.add(parameterSetName.getName());
        }

        return names;
    }

    private boolean diffParameters(String name,
        BeanWrapper<Parameters> currentParamsBean,
        BeanWrapper<Parameters> importedParamsBean) {

        Map<String, String> currentProperties = currentParamsBean.getProps();
        Map<String, String> importedProperties = importedParamsBean.getProps();

        boolean equals = true;
        if (currentProperties == null) {
            if (importedProperties != null) {
                equals = false;
            }
            return equals;
        }
        if (importedProperties == null) {
            return false;
        }

        for (Entry<String, String> parameter : currentProperties.entrySet()) {
            String importedValue = importedProperties.get(parameter.getKey());
            
            boolean floatEquals = false;
            if (importedValue != null) {
                try {
                    floatEquals = Float.valueOf(parameter.getValue()).equals(Float.valueOf(importedValue));
                } catch (NumberFormatException e) {
                    // The parameter was not a float.
                }
            }
            
            if (!floatEquals && !parameter.getValue().equals(importedValue)) {
                log.warn(String.format(
                    "Parameter %s in parameter set '%s' differs from parameter set library: currentValue=%s, libraryValue=%s",
                    parameter.getKey(), name, parameter.getValue(),
                    importedValue));
                equals = false;
            }
        }

        return equals;
    }

    private String displayCadenceRangeParameters(String name,
        BeanWrapper<Parameters> currentParamsBean) {

        CadenceRangeParameters cadenceRangeParameters = (CadenceRangeParameters) currentParamsBean.getInstance();
        StringBuilder output = new StringBuilder();
        output.append(String.format(
            "Parameter set '%s': startCadence=%d, endCadence=%d, "
                + "numberOfBins=%d, minimumBinSize=%d"
                + ", binByTargetTable=%s, excludeCadences=[", name,
            cadenceRangeParameters.getStartCadence(),
            cadenceRangeParameters.getEndCadence(),
            cadenceRangeParameters.getNumberOfBins(),
            cadenceRangeParameters.getMinimumBinSize(),
            cadenceRangeParameters.isBinByTargetTable()));
        boolean added = false;
        for (String cadences : cadenceRangeParameters.getExcludeCadences()) {
            if (added) {
                output.append(", ");
            }
            output.append(cadences);
            added = true;
        }
        output.append("]");

        return output.toString();
    }

    private String displayModuleOutputListsParameters(String name,
        BeanWrapper<Parameters> currentParamsBean) {

        ModuleOutputListsParameters moduleOutputListsParameters = (ModuleOutputListsParameters) currentParamsBean.getInstance();
        StringBuilder output = new StringBuilder();
        output.append(String.format("Parameter set '%s': ", name));
        output.append("channelIncludeArray=[");
        boolean added = false;
        for (int channel : moduleOutputListsParameters.getChannelIncludeArray()) {
            if (added) {
                output.append(", ");
            }
            output.append(channel);
            added = true;
        }
        output.append("], ");
        output.append("channelExcludeArray=[");
        added = false;
        for (int channel : moduleOutputListsParameters.getChannelExcludeArray()) {
            if (added) {
                output.append(", ");
            }
            output.append(channel);
            added = true;
        }
        output.append("], ");
        output.append("cadenceOfDeathArray=[");
        added = false;
        for (int cadence : moduleOutputListsParameters.getCadenceOfDeathArray()) {
            if (added) {
                output.append(", ");
            }
            output.append(cadence);
            added = true;
        }
        output.append("], ");
        output.append("deadChannelArray=[");
        added = false;
        for (int channel : moduleOutputListsParameters.getDeadChannelArray()) {
            if (added) {
                output.append(", ");
            }
            output.append(channel);
            added = true;
        }
        output.append("], ");
        output.append("channelsPerTask=");
        output.append(moduleOutputListsParameters.getChannelsPerTask());

        return output.toString();
    }

    private String displayPouModuleParameters(String name,
        BeanWrapper<Parameters> currentParamsBean) {

        PouModuleParameters pouModuleParameters = (PouModuleParameters) currentParamsBean.getInstance();

        return String.format("Parameter set '%s': pouEnabled=%s", name,
            pouModuleParameters.isPouEnabled());
    }

    private String displayTargetListParameters(String name,
        BeanWrapper<Parameters> currentParamsBean) {

        TargetListParameters targetListParameters = (TargetListParameters) currentParamsBean.getInstance();
        Set<String> lists = new TreeSet<String>();
        for (String targetList : targetListParameters.getTargetListNames()) {
            lists.add(targetList);
        }

        StringBuilder targetLists = new StringBuilder();
        for (String targetListName : lists) {
            if (targetLists.length() > 0) {
                targetLists.append(", ");
            }
            targetLists.append(targetListName);
        }

        return String.format("Parameter set '%s': %s", name,
            targetLists.toString());
    }

    private String displayTpsModuleParameters(String name,
        BeanWrapper<Parameters> currentParamsBean) {

        TpsModuleParameters tpsModuleParameters = (TpsModuleParameters) currentParamsBean.getInstance();

        return String.format("Parameter set '%s': tpsLiteEnabled=%s", name,
            tpsModuleParameters.isTpsLiteEnabled());
    }

    private String displayXmlFiles(String[] xmlFiles) {

        StringBuffer buffer = new StringBuffer();
        for (String xmlFile : xmlFiles) {
            if (buffer.length() > 0) {
                buffer.append(", ");
            }
            buffer.append(xmlFile);
        }

        return buffer.toString();
    }
}
