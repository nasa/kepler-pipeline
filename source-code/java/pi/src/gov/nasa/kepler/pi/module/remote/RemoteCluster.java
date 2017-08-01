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

package gov.nasa.kepler.pi.module.remote;

import gov.nasa.kepler.hibernate.pi.PipelineTask;

import java.io.File;

/**
 * This class provides an interface to a remote cluster 
 * for running MATLAB processes.
 * 
 * This functionality includes transferring input files to the
 * cluster, submitting processing jobs, monitoring those jobs,
 * and transferring the results back to the worker when processing
 * is complete.
 * 
 * This class is stateless
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public interface RemoteCluster {
    
    /**
     * Submit the specified {@link PipelineTask} to the remote cluster.
     * 
     * This method returns as soon as the task files and state file have been
     * successfully transfered to the remote cluster or an error occurs.
     * 
     * @param pipelineTask
     * @param taskWorkingDir
     * @param numSubTasks
     * @return
     * @throws Exception
     */
    public File submitTask(PipelineTask pipelineTask, File taskWorkingDir, int numSubTasks) throws Exception;

    public StateFile generateStateFile(PipelineTask pipelineTask, int numSubTasks);
    
    public void submitToPbs(StateFile initialState, PipelineTask pipelineTask) throws Exception;
    
    /**
     * Add the specified task to this worker's {@link RemoteMonitor}. 
     * 
     * This method returns immediately.
     * 
     * @param pipelineTask
     */
    public void addToMonitor(PipelineTask pipelineTask);

    /**
     * Block until the specified task completes on the remote cluster.
     * 
     * Used only when running {@link AsyncPipelineModule}s in local mode.
     * 
     * @param pipelineTask
     * @return
     */
    public StateFile waitForCompletion(PipelineTask pipelineTask);

    /**
     * Retrieves the completed task files from the remote cluster.
     * 
     * Returns as soon as the copy is complete or failed.
     * 
     * @param pipelineTask
     * @param taskWorkingDir
     * @param sequenceNum
     * @throws Exception
     */
    public void retrieveTaskOutputs(PipelineTask pipelineTask, File taskWorkingDir, int sequenceNum) throws Exception;
    
}
