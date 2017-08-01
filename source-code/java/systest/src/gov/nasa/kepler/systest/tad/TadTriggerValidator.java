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

package gov.nasa.kepler.systest.tad;

import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetCrud;
import gov.nasa.kepler.hibernate.pi.ParameterSetName;
import gov.nasa.kepler.hibernate.pi.PipelineDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionNode;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.TargetListSetValidator;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.tad.peer.AmtModuleParameters;
import gov.nasa.kepler.tad.peer.ama.AmaPipelineModule;
import gov.nasa.kepler.tad.peer.amt.AmtPipelineModule;
import gov.nasa.kepler.tad.peer.bpa.BpaPipelineModule;
import gov.nasa.kepler.tad.peer.bpasetup.BpaSetupPipelineModule;
import gov.nasa.kepler.tad.peer.coa.CoaPipelineModule;
import gov.nasa.kepler.tad.peer.merge.MergePipelineModule;
import gov.nasa.kepler.tad.peer.rpts.RptsPipelineModule;
import gov.nasa.kepler.tad.peer.rptscleanup.RptsCleanupPipelineModule;
import gov.nasa.kepler.tad.peer.tadval.TadValPipelineModule;
import gov.nasa.kepler.tad.xml.TadXmlImportPipelineModule;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * This class validates a tad trigger according to the spec in KSOC-312.
 * 
 * @author Miles Cote
 * 
 */
public class TadTriggerValidator {

    private final TargetListSetValidator targetListSetValidator;
    private List<TargetListSet> targetListSets;
    private TargetListSet expectedAssocLcTls;

    public TadTriggerValidator(TargetListSetValidator targetListSetValidator) {
        this.targetListSetValidator = targetListSetValidator;
    }

    public void validate(String triggerName) {
        TriggerDefinitionCrud triggerDefinitionCrud = new TriggerDefinitionCrud();
        TriggerDefinition triggerDef = triggerDefinitionCrud.retrieve(triggerName);

        if (triggerDef == null) {
            throw new IllegalArgumentException(
                "The input triggerName must exist in the database.\n  triggerName: "
                    + triggerName);
        }

        targetListSets = new ArrayList<TargetListSet>();
        expectedAssocLcTls = null;

        Map<ClassWrapper<Parameters>, ParameterSetName> pipelineParameterSetNames = triggerDef.getPipelineParameterSetNames();
        addTargetListSet(pipelineParameterSetNames, null);
        validateAmtParams(pipelineParameterSetNames, null);

        PipelineDefinitionCrud pipelineDefinitionCrud = new PipelineDefinitionCrud();
        PipelineDefinition latestPipelineDefinition = pipelineDefinitionCrud.retrieveLatestVersionForName(triggerDef.getPipelineDefinitionName());
        latestPipelineDefinition.buildPaths();
        addTargetListSetsForTriggerDefNodes(triggerDef,
            latestPipelineDefinition.getRootNodes());

        targetListSetValidator.validate(targetListSets);

        System.out.println(triggerName + " has been validated.");
    }

    private void addTargetListSet(
        Map<ClassWrapper<Parameters>, ParameterSetName> parameterSetNames,
        Class<?> pipelineModuleClass) {
        ParameterSetCrud parameterSetCrud = new ParameterSetCrud();
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        ParameterSetName parameterSetName = parameterSetNames.get(new ClassWrapper<Parameters>(
            TadParameters.class));
        if (parameterSetName != null) {
            ParameterSet paramSet = parameterSetCrud.retrieveLatestVersionForName(parameterSetName);
            TadParameters tadParameters = paramSet.parametersInstance();
            TargetListSet targetListSet = targetSelectionCrud.retrieveTargetListSet(tadParameters.getTargetListSetName());

            if (targetListSet == null) {
                throw new IllegalArgumentException(
                    "The target list set must exist in the database.\n  parameterSetName: "
                        + parameterSetName + "\n  targetListSetName: "
                        + tadParameters.getTargetListSetName());
            }

            validate(targetListSet.getType(), pipelineModuleClass);

            if (expectedAssocLcTls == null) {
                if (targetListSet.getType()
                    .equals(TargetType.LONG_CADENCE)) {
                    expectedAssocLcTls = targetListSet;
                } else {
                    expectedAssocLcTls = targetSelectionCrud.retrieveTargetListSet(tadParameters.getAssociatedLcTargetListSetName());
                }
            }

            if (!targetListSet.getType()
                .equals(TargetType.LONG_CADENCE)) {
                TargetListSet assocLcTls = targetSelectionCrud.retrieveTargetListSet(tadParameters.getAssociatedLcTargetListSetName());
                if (assocLcTls == null) {
                    throw new IllegalArgumentException(
                        "A Target list set that is not long cadence must have a valid assocLcTls.\n  assocLcTlsName: "
                            + tadParameters.getAssociatedLcTargetListSetName());
                }

                if (!expectedAssocLcTls.equals(assocLcTls)) {
                    throw new IllegalArgumentException(
                        "assocLcTls must be consistent across all tad parameters.\n  expected assocLcTls: "
                            + expectedAssocLcTls
                            + "\n  actual assocLcTls:"
                            + assocLcTls);
                }
            }

            if (!targetListSets.contains(targetListSet)) {
                targetListSets.add(targetListSet);
            }
        }
    }

    private void validateAmtParams(
        Map<ClassWrapper<Parameters>, ParameterSetName> parameterSetNames,
        Class<?> pipelineModuleClass) {
        ParameterSetCrud parameterSetCrud = new ParameterSetCrud();
        ParameterSetName parameterSetName = parameterSetNames.get(new ClassWrapper<Parameters>(
            AmtModuleParameters.class));
        if (parameterSetName != null) {
            ParameterSet paramSet = parameterSetCrud.retrieveLatestVersionForName(parameterSetName);
            AmtModuleParameters amtModuleParameters = paramSet.parametersInstance();
            String maskTableImportSourceFileName = amtModuleParameters.getMaskTableImportSourceFileName();

            if (maskTableImportSourceFileName != null
                && !maskTableImportSourceFileName.isEmpty()) {
                String filename = maskTableImportSourceFileName;
                FsId fsId = DrFsIdFactory.getFile(DispatcherType.MASK_TABLE,
                    filename);
                FileStoreClient fsClient = FileStoreClientFactory.getInstance();

                if (!fsClient.blobExists(fsId)) {
                    throw new IllegalArgumentException(
                        "amtParams.maskTableImportSourceFileName must exist in the filestore.\n  maskTableImportSourceFileName: "
                            + maskTableImportSourceFileName
                            + "\n  fsId: "
                            + fsId);
                }
            }
        }
    }

    private void validate(TargetType type, Class<?> pipelineModuleClass) {
        if (pipelineModuleClass.equals(MergePipelineModule.class)) {
            // Any type is valid.
        } else if (pipelineModuleClass.equals(CoaPipelineModule.class)) {
            if (type != TargetType.LONG_CADENCE
                && type != TargetType.SHORT_CADENCE) {
                throw new IllegalArgumentException(pipelineModuleClass
                    + " must run on a " + TargetType.LONG_CADENCE + " or "
                    + TargetType.SHORT_CADENCE
                    + " targetListSet.\n  targetType: " + type);
            }
        } else if (pipelineModuleClass.equals(AmtPipelineModule.class)) {
            if (type != TargetType.LONG_CADENCE) {
                throw new ModuleFatalProcessingException(pipelineModuleClass
                    + " must run on a " + TargetType.LONG_CADENCE
                    + " targetListSet.\n  targetType: " + type);
            }
        } else if (pipelineModuleClass.equals(AmaPipelineModule.class)) {
            if (type != TargetType.LONG_CADENCE
                && type != TargetType.SHORT_CADENCE) {
                throw new ModuleFatalProcessingException(pipelineModuleClass
                    + " must run on a " + TargetType.LONG_CADENCE + " or "
                    + TargetType.SHORT_CADENCE
                    + " targetListSet.\n  targetType: " + type);
            }
        } else if (pipelineModuleClass.equals(BpaSetupPipelineModule.class)) {
            if (type != TargetType.LONG_CADENCE) {
                throw new ModuleFatalProcessingException(pipelineModuleClass
                    + " must run on a " + TargetType.LONG_CADENCE
                    + " targetListSet.\n  targetType: " + type);
            }
        } else if (pipelineModuleClass.equals(BpaPipelineModule.class)) {
            if (type != TargetType.LONG_CADENCE) {
                throw new ModuleFatalProcessingException(pipelineModuleClass
                    + " must run on a " + TargetType.LONG_CADENCE
                    + " targetListSet.\n  targetType: " + type);
            }
        } else if (pipelineModuleClass.equals(RptsPipelineModule.class)) {
            if (type != TargetType.REFERENCE_PIXEL) {
                throw new IllegalArgumentException(pipelineModuleClass
                    + " must run on a " + TargetType.REFERENCE_PIXEL
                    + " targetListSet.\n  targetType: " + type);
            }
        } else if (pipelineModuleClass.equals(RptsCleanupPipelineModule.class)) {
            if (type != TargetType.REFERENCE_PIXEL) {
                throw new ModuleFatalProcessingException(pipelineModuleClass
                    + " must run on a " + TargetType.REFERENCE_PIXEL
                    + " targetListSet.\n  targetType: " + type);
            }
        } else if (pipelineModuleClass.equals(TadValPipelineModule.class)) {
            // Any type is valid.
        } else if (pipelineModuleClass.equals(TadXmlImportPipelineModule.class)) {
            // Any type is valid.
        }
    }

    private void addTargetListSetsForTriggerDefNodes(TriggerDefinition trigger,
        List<PipelineDefinitionNode> nodes) {

        PipelineModuleDefinitionCrud moduleDefinitionCrud = new PipelineModuleDefinitionCrud();
        for (PipelineDefinitionNode node : nodes) {
            PipelineModuleDefinition modDef = moduleDefinitionCrud.retrieveLatestVersionForName(node.getModuleName());
            Class<?> pipelineModuleClass = modDef.getImplementingClass()
                .getClazz();

            TriggerDefinitionNode triggerNode = trigger.findNodeForPath(node.getPath());
            if (triggerNode != null) {
                Map<ClassWrapper<Parameters>, ParameterSetName> moduleParameterSetNames = triggerNode.getModuleParameterSetNames();
                addTargetListSet(moduleParameterSetNames, pipelineModuleClass);
                validateAmtParams(moduleParameterSetNames, pipelineModuleClass);
            }

            addTargetListSetsForTriggerDefNodes(trigger, node.getNextNodes());
        }
    }

    public static void main(String[] args) {
        if (args.length != 1) {
            System.err.println("USAGE: validate-tad-trigger TRIGGER_NAME");
            System.err.println("EXAMPLE: validate-tad-trigger TAD\\ Quarterly:\\ Trimmed");
            System.exit(-1);
        }

        String triggerName = args[0];

        TadTriggerValidator validator = new TadTriggerValidator(
            new TargetListSetValidator(new RollTimeOperations()));
        validator.validate(triggerName);

        System.exit(0);
    }

}
