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

package gov.nasa.kepler.pi.module;

import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributeOperations;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes.ProcessingState;
import gov.nasa.kepler.pi.module.io.MatlabBinFileUtils;
import gov.nasa.kepler.pi.module.remote.RemoteExecutionParameters;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.io.File;
import java.util.List;

/**
 * Implementation of {@link MatlabSerializer} for .bin files
 * 
 * @author tklaus
 *
 */
public class MatlabSerializerImpl implements MatlabSerializer {

    public MatlabSerializerImpl() {
    }

    @Override
    public void serializeInputs(PipelineTask pipelineTask, List<? extends Persistable> inputsList, File taskWorkingDir) throws Exception {
        
        String moduleExeName = pipelineTask.moduleExeName();
        RemoteExecutionParameters remoteParams = pipelineTask.getParameters(RemoteExecutionParameters.class, false);
        boolean useSubTaskDirs = (remoteParams != null && remoteParams.isEnabled());

        PipelineTaskAttributeOperations attrOps = new PipelineTaskAttributeOperations();
        attrOps.updateProcessingState(pipelineTask.getId(), pipelineTask.getPipelineInstance().getId(), ProcessingState.SENDING);

        if(useSubTaskDirs){
            int numJobs = inputsList.size();

            for (int binNumber = 0; binNumber < numJobs; binNumber++) {
                // assumes a single group
                File subTaskDir = InputsHandler.subTaskDirectory(taskWorkingDir, 0, binNumber);

                serializeInputs(pipelineTask, inputsList.get(binNumber), subTaskDir);
            }
        }else{
            // single task dir
            
            // Make sure there are no leftover error files before launching the process.
            MatlabBinFileUtils.clearStaleErrorState(taskWorkingDir, moduleExeName, 0);
            
            serializeInputs(pipelineTask, inputsList.get(0), taskWorkingDir);
        }
    }

    @Override
    public void serializeInputs(PipelineTask pipelineTask, Persistable inputs, File taskWorkingDir) {
        serializeInputsWithSeqNum(pipelineTask, inputs, taskWorkingDir, 0);
    }

    @Override
    public void serializeInputsWithSeqNum(PipelineTask pipelineTask, Persistable inputs, File taskWorkingDir, int sequenceNum) {
        
        String moduleExeName = pipelineTask.moduleExeName();
        IntervalMetricKey key = IntervalMetric.start();
        try {
            MatlabBinFileUtils.serializeInputsFile(inputs, taskWorkingDir, moduleExeName, sequenceNum);
        } finally {
            IntervalMetric.stop(MatlabPipelineModule.JAVA_SERIALIZATION_METRIC, key);
        }
    }
}
