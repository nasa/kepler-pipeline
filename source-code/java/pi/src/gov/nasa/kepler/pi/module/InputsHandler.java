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

import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class defines execution dependencies for sub-tasks.
 * 
 * Each element in the sequence contains one or more sub-tasks. Sub-tasks that 
 * are members of the same element will run in parallel.
 * 
 * For example, consider the sequence [0][1,5][6]
 * Sub-task 0 will run first, then sub-tasks 1, 2, 3, 4, and 5 will run in parallel,
 * then sub-task 6 will run. Each element of the sequence starts executing only after
 * the previous element is complete.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class InputsHandler implements Serializable {
    private static final Log log = LogFactory.getLog(InputsHandler.class);
    private static final long serialVersionUID = -7951474508998966736L;
    private static final String PERSISTED_FILE_NAME = ".subtask-metadata.ser";
    
    private transient PipelineTask task = null;
    private transient File taskDir = null;
    
    private List<InputsGroup> inputsGroups = new ArrayList<InputsGroup>();

    private int currentGroupIndex = 0;
    
    enum Mode {
        UNSPECIFIED,
        SINGLE,
        GROUP
    }
    
    private Mode mode = Mode.UNSPECIFIED;

    // only used when mode == Mode.SINGLE
    private List<Pair<Integer,Integer>> pairs = new ArrayList<Pair<Integer,Integer>>();

    // only used when mode == Mode.SINGLE
    private int currentSubTaskIndex = 0;
    
    public InputsHandler(){
    }
    
    InputsHandler(PipelineTask task, File taskDir) {
        this.task = task;
        this.taskDir = taskDir;
    }

    /** 
     * Serialize a single Persistable to the current sub-task directory
     * and increment the sub-task index.
     * 
     * @param inputs
     */
    public void addSubTaskInputs(Persistable inputs){
        if(mode == Mode.GROUP){
            throw new IllegalStateException("Can't add sub-task inputs to the sequence when groups are used. " +
            		"Add the inputs to the group instead, or don't create groups.");
        }
        mode = Mode.SINGLE;
        
        File subTaskDir = subTaskDirectory(taskDir, currentSubTaskIndex);
        
        log.info("Serializing inputs to sub-task dir: " + subTaskDir);
        
        MatlabSerializerImpl serializer = new MatlabSerializerImpl();
        serializer.serializeInputs(task, inputs, subTaskDir);
        currentSubTaskIndex ++;
    }
    
    /**
     * Return the current sub-task directory
     * @return
     */
    public File subTaskDirectory(){
        if(mode == Mode.GROUP){
            throw new IllegalStateException("Can't call this method when groups are used. " +
                    "Use the corresponding methods in InputsGroup instead, or don't create groups.");
        }
        
        return InputsHandler.subTaskDirectory(taskDir, currentSubTaskIndex);
    }

    /**
     * Add a range of sub-tasks. These sub-tasks will be run in parallel.
     * 
     * @param startSubTaskIndex
     * @param endSubTaskIndex
     */
    public void add(int startSubTaskIndex, int endSubTaskIndex){
        if(mode == Mode.GROUP){
            throw new IllegalStateException("Can't call this method when groups are used. " +
                    "Use the corresponding methods in InputsGroup instead, or don't create groups.");
        }
        mode = Mode.SINGLE;
        
        if(pairs.isEmpty() && startSubTaskIndex != 0){
            throw new PipelineException("First sub-task index of first InputsGroup must be 0 (zero), was: " 
                + startSubTaskIndex);
        }
        pairs.add(Pair.of(startSubTaskIndex, endSubTaskIndex));
    }
    
    /**
     * Add a single sub-task. This sub-task will be run serially.
     * 
     * @param subTaskIndex
     */
    public void add(int subTaskIndex){
        if(mode == Mode.GROUP){
            throw new IllegalStateException("Can't call this method when groups are used. " +
                    "Use the corresponding methods in InputsGroup instead, or don't create groups.");
        }
        mode = Mode.SINGLE;
        
        if(pairs.isEmpty() && subTaskIndex != 0){
            throw new PipelineException("First sub-task index of first InputsGroup must be 0 (zero), was: " 
                + subTaskIndex);
        }
        pairs.add(Pair.of(subTaskIndex, subTaskIndex));
    }

    public List<Pair<Integer, Integer>> getPairs() {
        if(mode == Mode.GROUP){
            throw new IllegalStateException("Can't call this method when groups are used. " +
                    "Use the corresponding methods in InputsGroup instead, or don't create groups.");
        }
        
        return pairs;
    }

    public boolean contains(int subTaskNumber){
        if(mode == Mode.GROUP){
            throw new IllegalStateException("Can't call this method when groups are used. " +
                    "Use the corresponding methods in InputsGroup instead, or don't create groups.");
        }
        
        
        for (Pair<Integer,Integer> element : pairs) {
            if(subTaskNumber >= element.left && subTaskNumber <= element.right){
                return true;
            }
        }
        return false;
    }

    public int numSubTasks(){
        int numSubTaskInSeq = 0;
        
        if(mode == Mode.GROUP){
            for (InputsGroup group : inputsGroups) {
                numSubTaskInSeq += group.numSubTasks();
            }
        }else{
            for (Pair<Integer,Integer> element : pairs) {
                numSubTaskInSeq += ((element.right - element.left) + 1);
            }
        }
        
        log.info("numSubTaskInSeq: " + numSubTaskInSeq);
        return numSubTaskInSeq;
    }

    public int numInputs(){
        int numInputs = 0;
        
        if(mode == Mode.GROUP){
            for (InputsGroup group : inputsGroups) {
                numInputs += group.numInputs();
            }
        }else{
            numInputs = currentSubTaskIndex;
        }
        
        log.info("numSubTaskInSeq: " + numInputs);
        return numInputs;
    }

    public InputsGroup createGroup(){
        if(mode == Mode.SINGLE){
            throw new IllegalStateException("Can't create groups after adding sub-task inputs to the sequence. " +
                    "When using groups, sub-task inputs must be added to the group instead of the sequence.");
        }
        
        mode = Mode.GROUP;
        
        InputsGroup group = new InputsGroup(task, currentGroupIndex, taskDir);
        inputsGroups.add(group);
        currentGroupIndex ++;
        return group;
    }
    
    public InputsGroup getGroup(int index){
        return inputsGroups.get(index);
    }

    public int numGroups(){
        return inputsGroups.size();
    }
    
    public List<InputsGroup> getGroups(){
        return inputsGroups;
    }
    
    public Mode getMode() {
        return mode;
    }

    public boolean hasGroups(){
        return(mode == Mode.GROUP);
    }
    
    public boolean isEmpty(){
        if(mode == Mode.GROUP){
            if (inputsGroups.isEmpty()) {
                return true;
            } else {
                // Check each InputsGroup.
                boolean foundInputs = false;
                for (InputsGroup inputsGroup : inputsGroups) {
                    if (!inputsGroup.isEmpty()) {
                        foundInputs = true;
                    }
                }
                return !foundInputs;
            }
        }else{
            return pairs.isEmpty();
        }
    }
    
    /**
     * Automatically set pairs to run all sub-tasks in parallel
     * is not already specified.
     * 
     * @return
     */
    void validate(){
        if(inputsGroups.isEmpty() && pairs.isEmpty()){
            // run all sub-tasks in parallel
            add(0, currentSubTaskIndex - 1);
        }
        
        int numSubTasks = numSubTasks();
        int numInputs = numInputs();
        
        if(numInputs != numSubTasks){
            String message = String.format("Number of sub-tasks(%d) does not match number of inputs (%d)", 
                numSubTasks, numInputs);
            log.error(message);
            throw new PipelineException(message);
        }
    }
    
    @Override
    public String toString(){
        StringBuffer b = new StringBuffer();
        
        if(mode == Mode.GROUP){
            int groupNumber = 0;
            
            for (InputsGroup group : inputsGroups) {
                b.append("GROUPS:{" + groupNumber + ": " + group.toString() + "} ");
                groupNumber++;
            }
        }else{
            for (Pair<Integer,Integer> element : pairs) {
                b.append("SINGLE:[" + element.left + "," + element.right + "]");
            }
        }

        return b.toString();
    }
    
    public void persist(File dir){
        try {
            File dest = new File(dir, PERSISTED_FILE_NAME);
            FileOutputStream fos = new FileOutputStream(dest);
            ObjectOutputStream oos = new ObjectOutputStream(fos);

            log.info("Persisting inputs metadata to: " + dest);
            
            oos.writeObject(this);
            oos.flush();
            oos.close();
        } catch (Exception e) {
            throw new IllegalArgumentException("Unable to persist to: " + dir + ", caught: " + e, e);
        }
    }

    public static InputsHandler restore(File taskDir){
        try {
            File src = new File(taskDir, PERSISTED_FILE_NAME);
            FileInputStream fis = new FileInputStream(src);
            ObjectInputStream ois = new ObjectInputStream(fis);

            log.info("Restoring outputs metadata from: " + src);
            
            InputsHandler s = (InputsHandler) ois.readObject();
            ois.close();

            s.taskDir = taskDir;
            
            // KSOC-4141: Set InputsGroup fields that are used by the remote code.
            int groupIndex = 0;
            for (InputsGroup group : s.getGroups()) {
                group.setTaskWorkingDir(taskDir);
                group.setGroupIndex(groupIndex);
                groupIndex++;
            }
            
            return s;
        } catch (Exception e) {
            throw new IllegalArgumentException("Unable to read persisted object from: " + taskDir + ", caught: " + e, e);
        }
    }

    /**
     * Return a collection of all sub-task directories for this InputsHandler
     * 
     * @return
     */
    public List<File> allSubTaskDirectories(){
        List<File> subTaskDirs = new LinkedList<File>();
        
        if(mode == Mode.GROUP){
            int numGroups = numGroups();
            for (int groupIndex = 0; groupIndex < numGroups; groupIndex++) {
                int numSubTasks = getGroup(groupIndex).numSubTasks();
                for (int subTaskIndex = 0; subTaskIndex < numSubTasks; subTaskIndex++) {
                    subTaskDirs.add(subTaskDirectory(taskDir, groupIndex, subTaskIndex));
                }
            }
        }else{
            int numSubTasks = numSubTasks();
            for (int subTaskIndex = 0; subTaskIndex < numSubTasks; subTaskIndex++) {
                subTaskDirs.add(subTaskDirectory(taskDir, subTaskIndex));
            }
        }
        return subTaskDirs;
    }
    
    /**
     * Return a collection of all group directories for this InputsHandler
     * 
     * @return
     */
    public List<File> allGroupDirectories(){
        List<File> groupDirs = new LinkedList<File>();
        
        if(mode == Mode.GROUP){
            int numGroups = numGroups();
            for (int groupIndex = 0; groupIndex < numGroups; groupIndex++) {
                File groupDir = new File(taskDir, "g-" + groupIndex);
                groupDirs.add(groupDir);
            }
        }
        return groupDirs;
    }

    /**
     * For PI use only. {@link PipelineModule} classes should use subTaskDirectory(), above.
     * 
     * Create the sub-task working directory (if necessary) and return the path
     * 
     * @param subTaskIndex
     * @return
     */
    public static File subTaskDirectory(File taskWorkingDir, int subTaskIndex){
        return InputsHandler.subTaskDirectory(taskWorkingDir, -1, subTaskIndex);
    }
    
    /**
     * For PI use only. {@link PipelineModule} classes should use subTaskDirectory(), above.
     * 
     * Create the sub-task working directory (if necessary) and return the path
     * 
     * @param subTaskIndex
     * @return
     */
    public static File subTaskDirectory(File taskWorkingDir, int groupIndex, int subTaskIndex){
        try {
            File subTaskDir = null;
            
            if(groupIndex >= 0){
                // using groups
                File groupDir = new File(taskWorkingDir, "g-" + groupIndex);
                subTaskDir = new File(groupDir, "st-" + subTaskIndex);
            }else{
                // not using groups
                subTaskDir = new File(taskWorkingDir, "st-" + subTaskIndex);
            }
    
            // ensure that the directory exists
            if(!subTaskDir.exists()){
                FileUtils.forceMkdir(subTaskDir);
            }
            
            return subTaskDir;
        } catch (IOException e) {
            throw new PipelineException("Failed to create sub-task dir: " + e, e);
        }
    }

    PipelineTask getTask() {
        return task;
    }

    File getTaskDir() {
        return taskDir;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#hashCode()
     */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((inputsGroups == null) ? 0 : inputsGroups.hashCode());
        return result;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#equals(java.lang.Object)
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        InputsHandler other = (InputsHandler) obj;
        if (inputsGroups == null) {
            if (other.inputsGroups != null)
                return false;
        } else if (!inputsGroups.equals(other.inputsGroups))
            return false;
        return true;
    }
}
