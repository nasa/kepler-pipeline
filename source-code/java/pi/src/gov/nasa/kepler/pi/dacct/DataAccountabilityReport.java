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

package gov.nasa.kepler.pi.dacct;

import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrail;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;

/**
 * Given a set of task ids indicating where data originated from generate the
 * the multi-graph transitive closure of all parent task ids.  Subclass this
 *  class in order to generate different report formats.
 * 
 * @author Sean McCauliff
 *
 */
public class DataAccountabilityReport { 

        
    private static final int DATA_RECEIPT_ID = 0;
    
    private final Set<Long> initialTaskIds;
    private final DataAccountabilityTrailCrud acctCrud;
    private final PipelineTaskCrud taskCrud;
    private final PipelineTaskRenderer taskRenderer;
    
    public DataAccountabilityReport(Set<Long> initialTaskIds, 
                                                         DataAccountabilityTrailCrud acctCrud,
                                                         PipelineTaskCrud taskCrud,
                                                         PipelineTaskRenderer taskRenderer) {
        this.initialTaskIds = initialTaskIds;
        this.acctCrud = acctCrud;
        this.taskCrud = taskCrud;
        this.taskRenderer = taskRenderer;
    }

    public String produceReport() throws IOException {
        Map<Long, Set<Long>> consumerProducer = calculateClosure();
        Map<Long, Set<Long>> producerConsumer = invertMap(consumerProducer);
        Set<Long> roots = findRoots(producerConsumer.keySet(), consumerProducer, producerConsumer);
        
        return formatReport(producerConsumer, roots);
    }

    /**
     * Calculates the transitive closure of the relation  produced(c,p).
     * 
     * @param initialTaskIds
     * @param acctCrud
     * @return A map from consumer ->  producer task id.  If nothing then this returns
     * an empty map.
     */
    Map<Long, Set<Long>> calculateClosure() {

        Map<Long, Set<Long>> consumerProducer =
            new HashMap<Long, Set<Long>>(); 
        
        //As we expand new producers we needs to explore them as well.
        SortedSet<Long> queue = new TreeSet<Long>();
        queue.addAll(initialTaskIds);
        
        //We don't want to explore the same path again.
        Set<Long> visited = new HashSet<Long>();
        
        //This does not use a "for" or an iterator since we add more tasks
        //into the queue as we iterate through the queue.
        while (!queue.isEmpty())  {
            long taskId = queue.first();
            queue.remove(taskId);
            visited.add(taskId);
            
            DataAccountabilityTrail acctTrail = acctCrud.retrieve(taskId);
            if (acctTrail == null) continue;
            Set<Long> parentTasks = acctTrail.getProducerTaskIds();
            
            consumerProducer.put(taskId, parentTasks);
            
            for (long parentTask : parentTasks) {
                if (parentTask == DATA_RECEIPT_ID) continue;
                if (visited.contains(parentTask)) continue;
                
                queue.add(parentTask);
            }
        }
        
        return consumerProducer;

    }
    
    /**
     * @param consumerProducer consumer->producer
     * @return producer->consumer
     */
    Map<Long, Set<Long>> invertMap(Map<Long, Set<Long>> consumerProducer) {
        Map<Long, Set<Long>> producerConsumer = 
            new HashMap<Long, Set<Long>>();
        
        for (Map.Entry<Long, Set<Long>> entry : consumerProducer.entrySet()) {
            for (long producer : entry.getValue()) {
                if (!producerConsumer.containsKey(producer)) {
                    producerConsumer.put(producer, new HashSet<Long>());
                }
                
                producerConsumer.get(producer).add(entry.getKey());
                
            }
        }
        
        return producerConsumer;
    }
    
    /**
     * Finds the ids which are not pointed at by anything.  Find all the
     * producers which are not themselves consumers.
     * @return
     */
    Set<Long> findRoots(Set<Long> producers,
                                      Map<Long, Set<Long>> consumerProducer, 
                                      Map<Long, Set<Long>> producerConsumer) {
        Set<Long> roots = new HashSet<Long>();
        
        ///Handle the case where the initial set of producers may not consume
        //anything.
        Set<Long> producersWithInit = new HashSet<Long>(producers);
        producersWithInit.addAll(initialTaskIds);
        
        //Handle the case where the initial task ids are also producers and they
        //are not in a list because they are in a loop.

        for (Long initialTask : initialTaskIds) {
            if (producerConsumer.containsKey(initialTask)) {
                roots.add(initialTask);
            }
        }
        
        for (Long producer : producersWithInit) {
            Set<Long> parents = consumerProducer.get(producer);
            if (parents == null)  {
                roots.add(producer);
            } else if (parents.size() == 0)  {
                roots.add(producer);
            }
        }

        return roots;
    }
    
    /**
     * 
     * @param producerConsumer producer->consumer
     * @param roots The top level consumers.
     * @return report
     * @throws IOException 
     * @throws PipelineException 
     */

    protected String formatReport(Map<Long, Set<Long>> producerConsumer, Set<Long> roots) throws IOException {
        
        List<Long> sortedRoots = new ArrayList<Long>(roots);
        Collections.sort(sortedRoots);
        
        StringBuilder bldr = new StringBuilder();
        
        
        for (long root : sortedRoots) {
            Set<Long> visited = new HashSet<Long>();
            printTask(bldr, root, producerConsumer, 0, visited);
        }
        
        return bldr.toString();
    }

    protected void printTask(Appendable bldr, long taskId, 
                                                Map<Long, Set<Long>> producerConsumer,
                                                int level, Set<Long> visited) 
        throws IOException {
    
        renderLine(bldr, taskId, level);
        
        Set<Long> consumers = producerConsumer.get(taskId);
        
        if (consumers == null) return;
        
        List<Long> sortedConsumers = new ArrayList<Long>(consumers);
        Collections.sort(sortedConsumers);
        
        visited.add(taskId);
        
        for (long consumer : sortedConsumers) {
            if (visited.contains(consumer)) {
                renderLine(bldr, consumer, level + 1);
            } else {
                printTask(bldr, consumer, producerConsumer, level + 1, visited);
            }
        }
    }
    
    protected void renderLine(Appendable bldr, long taskId, int level) throws IOException {
        for (int i=0; i < level; i++) {
            bldr.append("    ");
        }
        if (taskId == DATA_RECEIPT_ID) {
            bldr.append(taskRenderer.renderDefaultTask()).append('\n');
        } else {
            PipelineTask task = taskCrud.retrieve(taskId);
            bldr.append(taskRenderer.renderTask(task));
            bldr.append("\n");
        }
    }
    
}
