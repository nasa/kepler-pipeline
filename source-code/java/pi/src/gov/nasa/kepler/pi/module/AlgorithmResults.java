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

import java.io.File;

import gov.nasa.kepler.pi.module.io.matlab.MatlabErrorReturn;
import gov.nasa.spiffy.common.persistable.Persistable;

/**
 * Container class that contains the outputs for the algorithm
 * as well as metadata related to the run (working dir, error
 * info, etc.)
 * 
 * @author tklaus
 *
 */
public final class AlgorithmResults {

	private final Persistable outputs;

	/**
	 * Top-level task directory
	 */
	private File taskDir;
	
	/** For tasks with sub-tasks, this is the group directory,
	 * otherwise it is the task directory. This is the parent directory
	 * of the subtask directories, for example, cal-matlab-1-2/g-0
	 */
	private File groupDir;
	
    /** Working directory for the MATLAB process. Contains algorithm
     * inputs/outputs. For tasks that do not use sub-tasks, this is
     * the same as taskWorkingDir, otherwise it is the sub-task dir */
    private final File resultsDir;
	
	/** Contains the MATLAB error message and stack information
	 * if the algorithm failed, and null otherwise. */
	private MatlabErrorReturn matlabErrorReturn = null;
	
    public AlgorithmResults(Persistable outputs, File taskDir, File groupDir, File resultsDir,
        MatlabErrorReturn matlabErrorReturn) {
        this.outputs = outputs;
        this.taskDir = taskDir;
        this.groupDir = groupDir;
        this.resultsDir = resultsDir;
        this.matlabErrorReturn = matlabErrorReturn;
    }

	public Persistable getOutputs() {
		return outputs;
	}
	
    public MatlabErrorReturn getMatlabErrorReturn() {
        return matlabErrorReturn;
    }

    public boolean successful(){
        return(matlabErrorReturn == null);
    }

    public File getGroupDir() {
        return groupDir;
    }

    public File getResultsDir() {
        return resultsDir;
    }

    public File getTaskDir() {
        return taskDir;
    }
}
