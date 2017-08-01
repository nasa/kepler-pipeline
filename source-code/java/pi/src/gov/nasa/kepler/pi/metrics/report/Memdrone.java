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

package gov.nasa.kepler.pi.metrics.report;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;

import gov.nasa.kepler.hibernate.dbservice.MatlabJavaInitialization;

public class Memdrone {
    private static final Log log = LogFactory.getLog(Memdrone.class);

    static final String MEMDRONE_STATS_CACHE_FILENAME = ".memdrone-stats-cache.ser";
    static final String PID_MAP_CACHE_FILENAME = ".pid-map-cache.ser";
    
    private File taskDir;
    
    public Memdrone(File taskDir) {
        this.taskDir = taskDir;
    }
    
    public Map<String,DescriptiveStatistics> statsByPid() throws Exception{
        Map<String,DescriptiveStatistics> taskStats = null;
        boolean cacheFileLoaded = false;
        
        try {
            File cacheFile = new File(taskDir, MEMDRONE_STATS_CACHE_FILENAME);

            if(cacheFile.exists()){
    			log.info("Using stats cache file");
    			FileInputStream fis = new FileInputStream(cacheFile);
    			BufferedInputStream bis = new BufferedInputStream(fis);
    			ObjectInputStream ois = new ObjectInputStream(bis);
    			@SuppressWarnings("unchecked")
    			Map<String, DescriptiveStatistics> obj = (Map<String, DescriptiveStatistics>) ois.readObject();
    			taskStats = obj;
    			ois.close();
    			cacheFileLoaded = true;
            }
		} catch (Throwable e) {
			log.warn("Failed to read stats cache file, re-creating. Exception was " + e);
		}

        if(!cacheFileLoaded){
            log.info("Creating stats cache file");
            taskStats = createStatsCache();
        }
        
        return taskStats;
    }

    public Map<String,String> subTasksByPid() throws Exception{
        Map<String,String> pidToSubTask = null;
        boolean cacheFileLoaded = false;
                
        try {
            File cacheFile = new File(taskDir, PID_MAP_CACHE_FILENAME);
            if(cacheFile.exists()){
                log.info("Using pid cache file");
                FileInputStream fis = new FileInputStream(cacheFile);
                BufferedInputStream bis = new BufferedInputStream(fis);
                ObjectInputStream ois = new ObjectInputStream(bis);
                @SuppressWarnings("unchecked")
    			Map<String, String> obj = (Map<String, String>) ois.readObject();
                pidToSubTask = obj;
                ois.close();
                cacheFileLoaded = true;
            }
		} catch (Throwable e) {
			log.warn("Failed to read pid cache file, re-creating. Exception was " + e);
        }

        if(!cacheFileLoaded){
            log.info("Creating pid cache file");
            pidToSubTask = createPidMapCache();
        }
        
        return pidToSubTask;
    }

    public Map<String,DescriptiveStatistics> createStatsCache() throws Exception{
        File cacheFile = new File(taskDir, MEMDRONE_STATS_CACHE_FILENAME);
        Map<String,DescriptiveStatistics> taskStats = new HashMap<String,DescriptiveStatistics>();
        
        File[] memdroneLogs = taskDir.listFiles(new FileFilter(){
            @Override
            public boolean accept(File f) {
                return (f.getName().startsWith("memdrone-") && f.isFile());
            }
        });

        log.info("Number of memdrone-* files found: " + memdroneLogs.length);
        
        for (File memdroneLog : memdroneLogs) {
            log.info("Processing: " + memdroneLog);
            
            String filename = memdroneLog.getName();
            String host = filename.substring(filename.indexOf("-")+1, filename.indexOf("."));
            MemdroneLog mLog = new MemdroneLog(memdroneLog);
            Map<String, DescriptiveStatistics> contents = mLog.getLogContents();
            
            Set<String> pids = contents.keySet();
            
            for (String pid : pids) {
                taskStats.put(host + ":" + pid, contents.get(pid));
            }
        }

        try {
            FileOutputStream fos = new FileOutputStream(cacheFile);
            BufferedOutputStream bos = new BufferedOutputStream(fos);
            ObjectOutputStream oos = new ObjectOutputStream(bos);
            oos.writeObject(taskStats);
            oos.flush();
            bos.close();
        } catch (Exception e) {
            log.warn("failed to create cache file, caught e = " + e);
        }
        
        return taskStats;
    }
    
    public Map<String,String> createPidMapCache() throws Exception{
        File cacheFile = new File(taskDir, PID_MAP_CACHE_FILENAME);
        Map<String,String> pidToSubTask = new HashMap<String,String>();

        log.info("cacheFile: " + cacheFile);

        log.info("processing taskDir: " + taskDir);
        
        File[] subTaskDirs = taskDir.listFiles(new FileFilter(){
            @Override
            public boolean accept(File f) {
                return (f.getName().contains("st-") && f.isDirectory());
            }
        });
        
        for (File subTaskDir : subTaskDirs) {
            String taskDirName = taskDir.getName();
            taskDirName = taskDirName.substring(taskDirName.lastIndexOf("-")+1);
            String subTaskId = taskDirName + "/" + subTaskDir.getName(); 
            log.debug("processing subTaskId: " + subTaskId);
            File pidsFile = new File(subTaskDir, MatlabJavaInitialization.MATLAB_PIDS_FILENAME);
            if(pidsFile.exists()){
                List<String> pids = FileUtils.readLines(pidsFile);
                
                for (String pid : pids) {
                    log.debug("put(" + pid + ", " + subTaskId + ")");
                    pidToSubTask.put(pid, subTaskId);
                }
            }
        }

        try {
            FileOutputStream fos = new FileOutputStream(cacheFile);
            BufferedOutputStream bos = new BufferedOutputStream(fos);
            ObjectOutputStream oos = new ObjectOutputStream(bos);
            oos.writeObject(pidToSubTask);
            oos.flush();
            bos.close();
        } catch (Exception e) {
            log.warn("failed to create cache file, caught e = " + e);
        }
        
        return pidToSubTask;
    }
}
