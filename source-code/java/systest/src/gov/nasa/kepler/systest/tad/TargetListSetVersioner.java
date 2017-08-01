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

import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.TransactionWrapper;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetCrud;
import gov.nasa.kepler.hibernate.pi.ParameterSetName;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionNode;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.Map;

public class TargetListSetVersioner {

    /** matches _vN only at the end of the line */
    public static final String EXISTING_VERSION_REGEXP = ".*_v\\d+$";

    private static final String FIRST_VERSION_TO_ASSIGN = "2";
    private static final String VERSION_STRING = "_v";

    public void version(String targetListSetName, String triggerName) {
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        TargetListSet tls = targetSelectionCrud.retrieveTargetListSet(targetListSetName);

        if (tls == null) {
            throw new IllegalArgumentException(
                "The target list set must exist in the database.\n  targetListSetName: "
                    + targetListSetName);
        }

        String newTlsName = getNewTlsName(targetListSetName);

        // Make a copy of the target list set using the unique name.
        TargetListSet newTargetListSet = new TargetListSet(newTlsName, tls);
        newTargetListSet.setState(State.LOCKED);
        newTargetListSet.clearTadFields();

        targetSelectionCrud.create(newTargetListSet);

        updateTadParameters(triggerName, targetListSetName,
            newTargetListSet.getName());
    }

    String getNewTlsName(String tlsName) {
        String newTlsName = "";
        if (tlsName.matches(EXISTING_VERSION_REGEXP)) {
            String[] strings = tlsName.split(VERSION_STRING);
            String prevVersionNumberString = strings[strings.length - 1];

            int prevVersionNumber;
            try {
                prevVersionNumber = Integer.parseInt(prevVersionNumberString);
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException(
                    "The tls name to version must be of the format *_vINTEGER (e.g. q1_v2).\n  tlsName: "
                        + tlsName);
            }

            for (int i = 0; i < strings.length; i++) {
                if (i != strings.length - 1) {
                    if (i != 0) {
                        newTlsName += VERSION_STRING;
                    }
                    newTlsName += strings[i];
                }
            }

            int newVersionNumber = prevVersionNumber + 1;
            newTlsName = newTlsName + VERSION_STRING + newVersionNumber;
        } else {
            newTlsName = tlsName + VERSION_STRING + FIRST_VERSION_TO_ASSIGN;
        }

        return newTlsName;
    }

    private void updateTadParameters(String triggerName, String oldTlsName,
        String newTlsName) {
        TriggerDefinitionCrud triggerDefinitionCrud = new TriggerDefinitionCrud();
        TriggerDefinition triggerDef = triggerDefinitionCrud.retrieve(triggerName);

        if (triggerDef == null) {
            throw new IllegalArgumentException(
                "The input triggerName must exist in the database.\n  triggerName: "
                    + triggerName);
        }

        Map<ClassWrapper<Parameters>, ParameterSetName> pipelineParameterSetNames = triggerDef.getPipelineParameterSetNames();
        updateTadParameters(pipelineParameterSetNames, oldTlsName, newTlsName);

        for (TriggerDefinitionNode node : triggerDef.getNodes()) {
            Map<ClassWrapper<Parameters>, ParameterSetName> moduleParameterSetNames = node.getModuleParameterSetNames();
            updateTadParameters(moduleParameterSetNames, oldTlsName, newTlsName);
        }
    }

    private void updateTadParameters(
        Map<ClassWrapper<Parameters>, ParameterSetName> parameterSetNames,
        String oldTlsName, String newTlsName) {
        ParameterSetCrud parameterSetCrud = new ParameterSetCrud();
        ParameterSetName parameterSetName = parameterSetNames.get(new ClassWrapper<Parameters>(
            TadParameters.class));
        if (parameterSetName != null) {
            ParameterSet paramSet = parameterSetCrud.retrieveLatestVersionForName(parameterSetName);
            TadParameters tadParameters = paramSet.parametersInstance();

            if (oldTlsName.equals(tadParameters.getTargetListSetName())) {
                tadParameters.setTargetListSetName(newTlsName);
            }

            if (oldTlsName.equals(tadParameters.getAssociatedLcTargetListSetName())) {
                tadParameters.setAssociatedLcTargetListSetName(newTlsName);
            }

            PipelineOperations pipelineOperations = new PipelineOperations();
            pipelineOperations.updateParameterSet(parameterSetName,
                tadParameters, false);
        }
    }

    public static void main(String[] args) {
        if (args.length != 2) {
            System.err.println("USAGE: version-tls TLS_NAME TRIGGER_NAME");
            System.err.println("EXAMPLE: version-tls q1_lc_untrimmed TAD\\ Quarterly:\\ Trimmed");
            System.exit(-1);
        }

        final String tlsName = args[0];
        final String triggerName = args[1];

        TransactionWrapper.run(new Runnable() {
            @Override
            public void run() {
                TargetListSetVersioner versioner = new TargetListSetVersioner();
                versioner.version(tlsName, triggerName);
            }
        });
    }

}
