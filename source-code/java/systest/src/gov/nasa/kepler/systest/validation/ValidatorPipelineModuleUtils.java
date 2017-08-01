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

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.common.pi.TpsType;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.tps.TpsModuleParameters;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Validation pipeline utilities.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class ValidatorPipelineModuleUtils {

    private static final Log log = LogFactory.getLog(ValidatorPipelineModuleUtils.class);

    public static long getMostRecentInstanceId(CadenceType cadenceType,
        long preferredValue, String moduleName, TpsType tpsType) {

        if (preferredValue > -1) {
            log.info(String.format("Returning preferred instance ID %d for %s",
                preferredValue, moduleName));
            return preferredValue;
        }

        PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud();
        PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();
        long mostRecentInstanceId = -1;

        for (PipelineInstance pipelineInstance : pipelineInstanceCrud.retrieveAll()) {
            if (pipelineInstance.hasPipelineParameters(CadenceTypePipelineParameters.class)) {
                CadenceTypePipelineParameters cadenceTypeParameters = (CadenceTypePipelineParameters) pipelineInstance.getPipelineParameters(CadenceTypePipelineParameters.class);
                log.debug(String.format(
                    "Current CadenceTypePipelineParameters.cadenceType=%s",
                    cadenceTypeParameters.getCadenceType()));
                if (cadenceTypeParameters.getCadenceType() == null
                    || cadenceTypeParameters.getCadenceType()
                        .length() == 0
                    || CadenceType.valueOf(cadenceTypeParameters.getCadenceType()) != cadenceType) {
                    continue;
                }
            }

            long pipelineInstanceId = pipelineInstance.getId();

            for (PipelineTask pipelineTask : pipelineTaskCrud.retrieveAll(pipelineInstance)) {
                if (pipelineTask.getPipelineDefinitionNode()
                    .getModuleName()
                    .getName()
                    .equals(moduleName)) {
                    if (tpsType != null) {
                        TpsModuleParameters tpsModuleParameters = (TpsModuleParameters) pipelineInstance.getPipelineParameters(TpsModuleParameters.class);
                        if ((tpsType == TpsType.TPS_LITE && !tpsModuleParameters.isTpsLiteEnabled())
                            || (tpsType == TpsType.TPS_FULL && tpsModuleParameters.isTpsLiteEnabled())) {
                            continue;
                        }
                    }
                    if (pipelineInstanceId > mostRecentInstanceId) {
                        mostRecentInstanceId = pipelineInstanceId;
                    }
                }
            }
        }

        log.info(String.format("Returning instance ID %d for %s",
            mostRecentInstanceId, moduleName));

        return mostRecentInstanceId;
    }
}
