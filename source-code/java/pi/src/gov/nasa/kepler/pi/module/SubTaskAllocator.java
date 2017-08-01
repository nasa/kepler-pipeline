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

import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Allocates sub-tasks to clients that execute them in the order
 * specified by an {@link InputsHandler} instance.
 * 
 * This class is typically accessed over a socket using
 * {@link SubTaskServer} and {@link SubTaskClient}
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class SubTaskAllocator {
    private static final Log log = LogFactory.getLog(SubTaskAllocator.class);

    private static final int NO_GROUPS = -1;
    
    private class AllocationGroup{
        int currentSubTaskPairIndexToProcess = 0;
        LinkedList<Integer> currentPoolWaiting = new LinkedList<Integer>();
        LinkedList<Integer> currentPoolProcessing = new LinkedList<Integer>();
        List<Pair<Integer,Integer>> pairs = new ArrayList<Pair<Integer,Integer>>();
        
        @Override
        public String toString() {
            return "ag:[currentSubTaskPairIndexToProcess=" + currentSubTaskPairIndexToProcess
                + ", currentPoolWaiting=" + currentPoolWaiting + ", currentPoolProcessing=" + currentPoolProcessing
                + ", pairs=" + pairs + "]";
        }
    }
    
    private int currentRoundRobinGroupIndex = 0;
    private int numGroups = 0;
    
    private Map<Integer,AllocationGroup> subTasks = new HashMap<Integer,AllocationGroup>();
    
    public SubTaskAllocator(InputsHandler inputsHandler) {
        if(inputsHandler.numGroups() > 0){
            numGroups = inputsHandler.numGroups();
            for (int groupIndex = 0; groupIndex < numGroups; groupIndex++) {
                InputsGroup inputsGroup = inputsHandler.getGroup(groupIndex);
                AllocationGroup ag = new AllocationGroup();
                ag.pairs = inputsGroup.getPairs();
                if(ag.pairs.size() > 0){
                    populateWaitingPool(ag, 0);
                }

                subTasks.put(groupIndex, ag);
            }
            currentRoundRobinGroupIndex = 0;
        }else{ // no groups defined
            AllocationGroup ag = new AllocationGroup();
            ag.pairs = inputsHandler.getPairs();
            if(ag.pairs.size() > 0){
                populateWaitingPool(ag, 0);
            }
            subTasks.put(NO_GROUPS, ag);
            currentRoundRobinGroupIndex = NO_GROUPS; 
        }
    }

    public boolean markSubTaskComplete(int groupIndex, int subTaskIndex){
        
        dump();
        
        AllocationGroup ag = subTasks.get(groupIndex);
        if(ag == null){
            log.warn("No sub-tasks found for groupIndex: " + groupIndex);
        }
        
        boolean found = false;
        for (int i = 0; i < ag.currentPoolProcessing.size(); i++) {
            if(ag.currentPoolProcessing.get(i) == subTaskIndex){
                found = true;
                ag.currentPoolProcessing.remove(i);
                log.debug("removing subTaskIndex: " + subTaskIndex);
            }
        }
        
        if(!found){
            log.warn("failed to remove subTaskIndex: " + subTaskIndex);
            return false;
        }else{
            return true;
        }
    }
    
    /**
     * Return the next sub-task available for processing
     * 
     * @return
     */
    public SubTaskAllocation nextSubTask() {
        
        dump();
        
        boolean noMore = true;
        SubTaskAllocation next = null;
        
        if(currentRoundRobinGroupIndex == NO_GROUPS){
            return nextSubTaskForGroup(NO_GROUPS);
        }else{
            int startingGroupIndex = currentRoundRobinGroupIndex;
            
            do{
                next = nextSubTaskForGroup(currentRoundRobinGroupIndex);
                
                currentRoundRobinGroupIndex += 1;
                if(currentRoundRobinGroupIndex >= numGroups){
                    currentRoundRobinGroupIndex = 0;
                }
                
                if(next.getStatus() == SubTaskServer.ResponseType.NO_MORE){
                    continue;
                }

                if(next.getStatus() == SubTaskServer.ResponseType.TRY_AGAIN){
                    noMore = false;
                    continue;
                }
                
                return next;
            }while(currentRoundRobinGroupIndex != startingGroupIndex);
            
            // if we got here, no sub-tasks are available
            if(noMore){
                return new SubTaskAllocation(SubTaskServer.ResponseType.NO_MORE, -1, -1);
            }else{
                return new SubTaskAllocation(SubTaskServer.ResponseType.TRY_AGAIN, -1, -1);
            }
        }
    }

    private SubTaskAllocation nextSubTaskForGroup(int groupIndex) {
        AllocationGroup ag = subTasks.get(groupIndex);
        if(ag == null){
            return new SubTaskAllocation(SubTaskServer.ResponseType.NO_MORE, -1, -1);
        }
        
        if(ag.currentSubTaskPairIndexToProcess >= ag.pairs.size()){
            // all sub-tasks in the sequence are done
            return new SubTaskAllocation(SubTaskServer.ResponseType.NO_MORE, -1, -1);
        }
        
        if(ag.currentPoolWaiting.isEmpty()){
            if(ag.currentPoolProcessing.isEmpty()){
                // no more in this pool, try the next pool
                ag.currentSubTaskPairIndexToProcess++;
                
                if(ag.currentSubTaskPairIndexToProcess < ag.pairs.size()){
                    populateWaitingPool(ag, ag.currentSubTaskPairIndexToProcess);
                }else{
                    // all sub-tasks in the sequence are done
                    return new SubTaskAllocation(SubTaskServer.ResponseType.NO_MORE, -1, -1);
                }
            }else{ // currentPoolProcessing not empty
                if(ag.currentSubTaskPairIndexToProcess == (ag.pairs.size()-1)){
                    // this is the last list and all other sub-tasks are already running
                    return new SubTaskAllocation(SubTaskServer.ResponseType.NO_MORE, -1, -1);
                }else{
                    // blocked until the currentPoolProcessing empties
                    return new SubTaskAllocation(SubTaskServer.ResponseType.TRY_AGAIN, -1, -1);
                }
            }
        }
        
        int subTaskIndex = ag.currentPoolWaiting.remove();
        ag.currentPoolProcessing.add(subTaskIndex);
        return new SubTaskAllocation(SubTaskServer.ResponseType.OK, groupIndex, subTaskIndex);
    }
    
    private void populateWaitingPool(AllocationGroup ag, int pairIndex){
        Pair<Integer, Integer> l = ag.pairs.get(pairIndex);
        for (int i = l.left; i <= l.right; i++) {
            ag.currentPoolWaiting.add(i);
        }
    }
    
    private void dump(){
        if(log.isDebugEnabled()){
            Set<Integer> groupIndices = subTasks.keySet();
            
            log.info("Group indices: " + groupIndices);
            
            for (int groupIndex : groupIndices) {
                AllocationGroup ag = subTasks.get(groupIndex);
                log.debug("G: " + groupIndex + ", " + ag);
            }
        }
    }
    
    public boolean isEmpty(){
        return subTasks.isEmpty();
    }
}
