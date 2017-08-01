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

package gov.nasa.kepler.pi.module.io;

import gov.nasa.kepler.pi.module.AlgorithmStateFile;
import gov.nasa.kepler.pi.module.io.matlab.MatlabErrorReturn;
import gov.nasa.spiffy.common.persistable.BinaryPersistableFilter;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.PersistableUtils;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class MatlabBinFileUtils {
    private static final Log log = LogFactory.getLog(MatlabBinFileUtils.class);

    private MatlabBinFileUtils() {
    }

    /**
     * Serialize and write the inputs file to the specified file
     * 
     * @param inputs
     * @param dataDir
     * @param seqNum
     * @throws PipelineException
     */
    public static void serializeInputsFile(Persistable inputs, File dataDir, String moduleName, int seqNum) {
    	serializeInputsFile(inputs, dataDir, moduleName, seqNum, null);
    }

    /**
     * Serialize and write the inputs file to the specified file
     * using the specified filter
     * 
     * @param inputs
     * @param dataDir
     * @param moduleName
     * @param seqNum
     * @param filter
     */
    public static void serializeInputsFile(
    		Persistable inputs, File dataDir, String moduleName, int seqNum, BinaryPersistableFilter filter) {
    	
        File inputFile = new File(dataDir + "/" + moduleName + "-inputs-" + seqNum + ".bin");
        
        PersistableUtils.writeBinFile(inputs, inputFile, filter);
    }

    /**
     * De-serialize the specified outputs file and populate the outputs object
     * 
     * @param outputs
     * @param dataDir
     * @param moduleName
     * @param seqNum
     * @return null if no MATLAB error file was generated, and the error file contents otherwise
     */
    public static MatlabErrorReturn deserializeOutputsFile(Persistable outputs, File dataDir, 
        String moduleName, int seqNum) {
        
        return deserializeOutputsFile(outputs, dataDir, moduleName, seqNum, false);
    }
    
    /**
     * De-serialize the specified outputs file and populate the outputs object
     * 
     * @param outputs
     * @param dataDir
     * @param moduleName
     * @param seqNum
     * @param deleteBin if true, delete the .bin file after reading to save disk space
     * @return null if no MATLAB error file was generated, and the error file contents otherwise
     */
    public static MatlabErrorReturn deserializeOutputsFile(Persistable outputs, File dataDir, 
        String moduleName, int seqNum, boolean deleteBin) {
        File currentErrorFile = errorFile(dataDir, moduleName, seqNum);
        MatlabErrorReturn errorReturn = null;
        
        log.info("Deserializing from: " + dataDir + ", mod=" + moduleName + ",seqNum=" + seqNum);
        
        if(currentErrorFile.exists()){
            try{
                /*
                 * The presence of the errorFile indicates that the MATLAB *_Main.m function caught an
                 * exception and did not create the outputs bin file.  In this case, the error bin
                 * file contains the MATLAB error information.  This only happens if the error is caught
                 * by the Main function and the MATLAB process exits normally.  If the process exits
                 * abnormally, it is caught above, in executeExternal()
                 */
                
                log.warn("Found an error file in the MATLAB task dir: " + currentErrorFile);

                errorReturn = dumpErrorFile(currentErrorFile);
                
            }finally{
                deleteErrorFile(currentErrorFile);
            }
        }else{
            AlgorithmStateFile state = new AlgorithmStateFile(dataDir);
            if(state.currentState() == AlgorithmStateFile.TaskState.COMPLETE){
                File outputFile = new File(dataDir + "/" + moduleName + "-outputs-" + seqNum + ".bin");
                PersistableUtils.readBinFile(outputs, outputFile);
                if(deleteBin){
                    // remove the .bin file to save disk space
                    if(!FileUtils.deleteQuietly(outputFile)){
                        log.warn("failed to delete .bin file: " + outputFile);
                    }
                }
            }else{
                String msg = "Could not read outputs, AlgorithmStateFile.currentState() = " + state.currentState();
                log.warn(msg);
                errorReturn = new MatlabErrorReturn();
                errorReturn.setMessage(msg);
            }
        }
        return errorReturn;
    }
    
    public static MatlabErrorReturn dumpErrorFile(File errorFile){
        MatlabErrorReturn errorReturn = new MatlabErrorReturn();
        String errorMessage;
        
        try {
            PersistableUtils.readBinFile(errorReturn, errorFile);
            
            errorReturn.logStackTrace();

            errorMessage = "MATLAB code generated an error file, message = " + errorReturn.getMessage();
        } catch (Throwable t) {
            errorMessage = "MATLAB code generated an error file, but it was unreadable (" + t.getMessage() + ")";
            errorReturn.setMessage(errorMessage);
        } 
        log.warn(errorMessage);
        
        return errorReturn;
    }
    
    /**
     * Make sure there are no leftover error files before launching the process.
     * If a MATLAB process generates an error, but the error is not picked up 
     * by the Java process (because it crashed, etc.), then the stale error file may
     * still exist when the task is re-run later.  When that re-run task finishes,
     * the Java process will see the stale error file and think that the new process
     * failed, when in fact it was the old (previous) process.  We mitigate that by
     * deleting any existing error files before launching the process.
     * 
     * @param dataDir
     * @param filenamePrefix
     * @param seqNum
     */
    public static void clearStaleErrorState(File dataDir, String filenamePrefix, int seqNum){
        File currentErrorFile = errorFile(dataDir, filenamePrefix, seqNum);

        if(currentErrorFile.exists()){
            deleteErrorFile(currentErrorFile);
        }
    }
    
    public static File errorFile(File dataDir, String filenamePrefix, int seqNum){
        File errorFile = new File(dataDir + "/" + filenamePrefix + "-error-" + seqNum + ".bin");
        return errorFile;
    }
    
    public static File errorFile(File dataDir, String filenamePrefix){
        return errorFile(dataDir, filenamePrefix, 0);
    }
    
    private static void deleteErrorFile(File errorFileToDelete){
        boolean deleted = errorFileToDelete.delete();
        if(!deleted){
            log.error("Failed to delete errorFile=" + errorFileToDelete);
        }
    }
}
