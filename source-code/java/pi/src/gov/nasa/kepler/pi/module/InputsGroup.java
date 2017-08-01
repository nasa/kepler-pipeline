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
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * An inputs group runs in parallel with other inputs groups.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class InputsGroup implements Serializable{
    private static final Log log = LogFactory.getLog(InputsGroup.class);
    private static final long serialVersionUID = 2532167771586644148L;

    // Used only when marshaling inputs
    private transient PipelineTask task;
    private transient int groupIndex = -1;
    private transient File taskWorkingDir;
    private transient int currentSubTaskIndex = 0;
    
    private List<Pair<Integer,Integer>> pairs = new ArrayList<Pair<Integer,Integer>>();

    /**
     * Use InputsHandler.createGroup() to create instances
     */
    InputsGroup(PipelineTask task, int groupIndex, File taskWorkingDir) {
        this.task = task;
        this.groupIndex = groupIndex;
        this.taskWorkingDir = taskWorkingDir;
    }
    
    /** 
     * Serialize a single Persistable to the next sub-task directory.
     * 
     * @param inputs
     */
    public void addSubTaskInputs(Persistable inputs){
        File subTaskDir = subTaskDirectory();
        
        log.info("Serializing inputs to sub-task dir: " + subTaskDir);
        
        MatlabSerializerImpl serializer = new MatlabSerializerImpl();
        serializer.serializeInputs(task, inputs, subTaskDir);
        currentSubTaskIndex++;
    }
       
    /**
     * Return the current sub-task directory
     * @return
     */
    public File subTaskDirectory(){
        return InputsHandler.subTaskDirectory(taskWorkingDir, groupIndex, currentSubTaskIndex);
    }

    /**
     * Return the current group directory
     * @return
     */
    public File groupDirectory(){
        File groupDir = new File(taskWorkingDir, "g-" + groupIndex);
        return groupDir;
    }

    /**
     * 
     * 
     * @param subTaskIndex
     * @return
     */
    File subTaskDirectoryName(int subTaskIndex){
        return InputsHandler.subTaskDirectory(taskWorkingDir, groupIndex, subTaskIndex);
    }

    /**
     * Add a range of sub-tasks. These sub-tasks will be run in parallel.
     * 
     * @param startSubTaskIndex
     * @param endSubTaskIndex
     */
    public void add(int startSubTaskIndex, int endSubTaskIndex){
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
        if(pairs.isEmpty() && subTaskIndex != 0){
            throw new PipelineException("First sub-task index of group must be 0 (zero), was: " 
                + subTaskIndex);
        }
        pairs.add(Pair.of(subTaskIndex, subTaskIndex));
    }

    public List<Pair<Integer, Integer>> getPairs() {
        return pairs;
    }

    public boolean contains(int subTaskNumber){
        
        for (Pair<Integer,Integer> element : pairs) {
            if(subTaskNumber >= element.left && subTaskNumber <= element.right){
                return true;
            }
        }
        return false;
    }
    
    public boolean isEmpty() {
        return numSubTasks() == 0;
    }

    public int numSubTasks(){
        int numSubTaskInSeq = 0;
        
        for (Pair<Integer,Integer> element : pairs) {
            numSubTaskInSeq += ((element.right - element.left) + 1);
        }
        
        log.debug("numSubTaskInSeq: " + numSubTaskInSeq);
        
        return numSubTaskInSeq;
    }
    
    public int numInputs(){
        return currentSubTaskIndex;
    }
    
    @Override
    public String toString(){
        StringBuilder b = new StringBuilder();
        
        for (Pair<Integer,Integer> element : pairs) {
            b.append("[" + element.left + "," + element.right + "]");
        }
        return b.toString();
    }

    /* (non-Javadoc)
     * @see java.lang.Object#hashCode()
     */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + currentSubTaskIndex;
        result = prime * result + groupIndex;
        result = prime * result + ((pairs == null) ? 0 : pairs.hashCode());
        result = prime * result + ((task == null) ? 0 : task.hashCode());
        result = prime * result + ((taskWorkingDir == null) ? 0 : taskWorkingDir.hashCode());
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
        InputsGroup other = (InputsGroup) obj;
        if (currentSubTaskIndex != other.currentSubTaskIndex)
            return false;
        if (groupIndex != other.groupIndex)
            return false;
        if (pairs == null) {
            if (other.pairs != null)
                return false;
        } else if (!pairs.equals(other.pairs))
            return false;
        if (task == null) {
            if (other.task != null)
                return false;
        } else if (!task.equals(other.task))
            return false;
        if (taskWorkingDir == null) {
            if (other.taskWorkingDir != null)
                return false;
        } else if (!taskWorkingDir.equals(other.taskWorkingDir))
            return false;
        return true;
    }
    
    int getGroupIndex() {
        return groupIndex;
    }

    void setGroupIndex(int groupIndex) {
        this.groupIndex = groupIndex;
    }

    File getTaskWorkingDir() {
        return taskWorkingDir;
    }

    void setTaskWorkingDir(File taskWorkingDir) {
        this.taskWorkingDir = taskWorkingDir;
    }
}
