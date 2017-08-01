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

import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.pi.module.AlgorithmResults;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.kepler.pi.module.TaskDirectoryIterator;
import gov.nasa.kepler.pi.module.io.MatlabBinFileUtils;
import gov.nasa.kepler.pi.module.io.matlab.MatlabErrorReturn;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.Iterator;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Iterates over a collection of AlgorithmResults which contain
 * Persistable objects created by de-serializing .bin files and
 * other metadata.
 * 
 * To conserve memory, this class implements 'just in time' deserialization
 * such that only one de-serialized Persistable object is in memory at 
 * any given time. The de-serilization is performed in the context of the
 * next() method.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class MultipleAlgorithmResultsIterator implements Iterator<AlgorithmResults> {
    private static final Log log = LogFactory.getLog(MultipleAlgorithmResultsIterator.class);

    public static String ALLOW_PARTIAL_TASKS_PROP = "pi.worker.allowPartialTasks";
    
    private String moduleName;
    private File taskDir;
	private Class<?> persistableClass;

	private TaskDirectoryIterator directoryIterator = null;
	
	private boolean allowPartialTasks;
        
    public MultipleAlgorithmResultsIterator(String moduleName, File taskDir, Class<?> persistableClass) {
        this.moduleName = moduleName;
        this.taskDir = taskDir;
		this.persistableClass = persistableClass;
		
        Configuration config = ConfigurationServiceFactory.getInstance();
        allowPartialTasks = config.getBoolean(ALLOW_PARTIAL_TASKS_PROP, true);
        
        validateResults();
        
        directoryIterator = new TaskDirectoryIterator(taskDir);
	}

	@Override
    public boolean hasNext() {
        return directoryIterator.hasNext();
    }

    @Override
    public AlgorithmResults next() {
        Persistable outputsInstance = null;
        MatlabErrorReturn errorFile = null;
        Pair<File, File> dirs = directoryIterator.next();
        File groupDir = dirs.left;
        File resultsDir = dirs.right;
        
        IntervalMetricKey key = IntervalMetric.start();
        try{
        	outputsInstance = (Persistable) persistableClass.newInstance();
        	errorFile = MatlabBinFileUtils.deserializeOutputsFile(outputsInstance, resultsDir, 
                moduleName, 0);
            
        	if(errorFile != null){
                if(!allowPartialTasks){
                    log.error("At least one sub-task failed ("+ resultsDir +") and "
                        + ALLOW_PARTIAL_TASKS_PROP + "== false, aborting this task");
                    throw new ModuleFatalProcessingException(errorFile.getMessage());
                }else{
                    log.warn("MATLAB error file indicates error in sub-task: " + resultsDir);
                }
        	}
        } catch (Exception e) {
        	throw new ModuleFatalProcessingException("Failed to instantiate Persistable(" 
        			+ persistableClass.getName() + "), caught e=" + e, e);
		}finally{
            IntervalMetric.stop(MatlabPipelineModule.JAVA_SERIALIZATION_METRIC, key);
        }
    	return new AlgorithmResults(outputsInstance, taskDir, groupDir, resultsDir, errorFile);
    }

    @Override
    public void remove() {
    	throw new IllegalStateException("remove not supported");
    }
    
    private void validateResults(){
        TaskDirectoryIterator it = new TaskDirectoryIterator(taskDir);
        int count = 0;
        int failedCount = 0;
        
        while (it.hasNext()) {
            count++;
            Pair<File, File> task = (Pair<File, File>) it.next();
            File resultsDir = task.right;
            if(MatlabBinFileUtils.errorFile(resultsDir, moduleName).exists()){
                failedCount++;
            }
        }
        
        if(failedCount == count && count != 0){
            log.error("All sub-tasks failed");
            throw new PipelineException(failedCount + " out of " + count + " sub-tasks failed, aborting processing");
        }
    }
}
