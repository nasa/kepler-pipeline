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

import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.FileFilter;
import java.io.IOException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public abstract class TimestampFile {
    private static final Log log = LogFactory.getLog(TimestampFile.class);

    public enum Event{
      ARRIVE_PFE,
      QUEUED_PBS,
      PBS_JOB_START,
      PBS_JOB_FINISH,
      SUB_TASK_START,
      SUB_TASK_FINISH
    }
    
    public static boolean create(File directory, Event name, long timestamp){
        if(delete(directory, name)){
            String filename = String.format("%s.%d", name.toString(), timestamp);
            File f = new File(directory, filename);
            try {
                return f.createNewFile();
            } catch (IOException e) {
                log.warn(String.format("failed to create timestamp file, dir=%s, file=%s, caught e = %s", 
                    directory, filename, e), e );
                return false;
            }
        }else{
            return false;
        }
    }

    public static boolean delete(File directory, Event name){
        // delete any existing files with this prefix
        String prefix = name.toString();

        File[] files = directory.listFiles();
        for (File file : files) {
            if(file.getName().startsWith(prefix)){
                boolean deleted = file.delete();
                if(!deleted){
                    log.warn(String.format("failed to delete existing timestamp file, dir=%s, file=%s", 
                        directory, file));
                    return false;
                }
            }
        }
        return true;
    }
    
    public static boolean create(File directory, Event name){
        return create(directory, name, System.currentTimeMillis());
    }
    
    public static long timestamp(File directory, final Event name){
        File[] files = directory.listFiles(new FileFilter(){
            @Override
            public boolean accept(File f) {
                return (f.getName().startsWith(name.toString()) && f.isFile());
            }
        });
        
        if(files.length == 0){
            throw new PipelineException("Found zero files that match event:" + name);
        }

        if(files.length > 1){
            throw new PipelineException("Found more than one files that match event:" + name);
        }

        String filename = files[0].getName();
        String[] elements = filename.split("\\.");
        
        if(elements.length != 2){
            throw new PipelineException("Unable to parse timestamp file: " + filename + ", numElements = " 
                + elements.length);
        }
        
        String timeString = elements[1];
        long timeMillis = -1;
        try{
            timeMillis = Long.parseLong(timeString);
        }catch(NumberFormatException e){
            throw new PipelineException("Unable to parse timestamp file: " + filename + ", timeString = "
                + timeString);
        }
        
        return timeMillis;
    }

    /**
     * Returns the elapsed time between the specified events.
     * Assumes that the specified directory contains timestamp files for the specified events.
     * 
     * @param directory
     * @param startEvent
     * @param finishEvent
     * @return
     */
    public static long elapsedTimeMillis(File directory, final Event startEvent, final Event finishEvent){
        long startTime = timestamp(directory, startEvent);
        long finishTime = timestamp(directory, finishEvent);
        
        if(startTime == -1 || finishTime == -1){
            // at least one of the events was missing or unparsable
            log.warn(String.format("Missing or invalid timestamp files, startTime=%s, finishTime=%s", 
                startTime, finishTime));
            return 0;
        }else{
            return finishTime - startTime;
        }
    }
}
