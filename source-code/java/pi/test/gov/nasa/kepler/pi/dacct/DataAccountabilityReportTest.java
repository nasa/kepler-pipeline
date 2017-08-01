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


import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrail;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.spiffy.common.collect.ArrayUtils;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import org.junit.Test;


/**
 * @author Sean McCauliff
 *
 */
public class DataAccountabilityReportTest {

    private final StubPipelineTaskCrud pipelineTaskCrud =
        new StubPipelineTaskCrud();
    private final ReflectionEquals reflectionEquals = 
        new ReflectionEquals();
    private final SimpleTaskRenderer taskRenderer = 
        new SimpleTaskRenderer();
    

    @Test
    public void emptyReport() throws Exception {
        StubDataAccountabilityTrailCrud acctCrud =
            new StubDataAccountabilityTrailCrud(new HashMap<Long, Set<Long>>());
        DataAccountabilityReport report = 
            new DataAccountabilityReport(new HashSet<Long>(), acctCrud, pipelineTaskCrud, taskRenderer);
        
        String reportStr = report.produceReport();
        assertEquals("", reportStr);
        
    }
    
    /**
     * The initial set of task ids do not depend on anything.
     * @throws Exception
     */
    @Test
    public void noProducers() throws Exception {
        Set<Long> init = new HashSet<Long>();
        init.add(0L);
        init.add(1L);
        
        StubDataAccountabilityTrailCrud acctCrud =
            new StubDataAccountabilityTrailCrud(new HashMap<Long, Set<Long>>());
        DataAccountabilityReport report  =
            new DataAccountabilityReport(init, acctCrud, pipelineTaskCrud, taskRenderer);
        reflectionEquals.assertEquals(new HashMap<Long, Set<Long>>(), report.calculateClosure());
        reflectionEquals.assertEquals(init, report.findRoots(new HashSet<Long>(), 
                                                             new HashMap<Long, Set<Long>>(),
                                                             new HashMap<Long, Set<Long>>()));
        
        String expectedReport = "Data Receipt\nStub taskId = 1\n";
        assertEquals(expectedReport, report.produceReport());
        
    }
    
    /**
     *  consumer 1 - > producer0
     *  consumer 2 -> producer 3
     * @throws Exception
     */
    @Test
    public void mutuallyExclusiveProducers() throws Exception {
        Set<Long> init = new HashSet<Long>();
        //init.add(0L);
        init.add(1L);
        init.add(2L);
        
        Map<Long, Set<Long>> consumerProducer = new HashMap<Long, Set<Long>>();
        consumerProducer.put(1L, Collections.singleton(0L));
        consumerProducer.put(2L, Collections.singleton(3L));
        
        Map<Long, Set<Long>> expectedProducerConsumer =  new HashMap<Long, Set<Long>>();
        expectedProducerConsumer.put(0L, Collections.singleton(1L));
        expectedProducerConsumer.put(3L, Collections.singleton(2L));
        
        Set<Long> expectedRoots = new HashSet<Long>();
        expectedRoots.add(0L);
        expectedRoots.add(3L);
        
        StubDataAccountabilityTrailCrud acctCrud = 
            new StubDataAccountabilityTrailCrud(consumerProducer);
        
        DataAccountabilityReport report = 
            new DataAccountabilityReport(init, acctCrud, pipelineTaskCrud, taskRenderer);
        
        reflectionEquals.assertEquals(consumerProducer, report.calculateClosure());
        Map<Long, Set<Long>> producerConsumer = report.invertMap(consumerProducer);
        reflectionEquals.assertEquals(expectedProducerConsumer, producerConsumer);
        Set<Long> roots =
            report.findRoots(producerConsumer.keySet(), consumerProducer, producerConsumer);
        reflectionEquals.assertEquals(expectedRoots, roots);
        
        String expectedReport = "Data Receipt\n    Stub taskId = 1\nStub taskId = 3\n    Stub taskId = 2\n";
        assertEquals(expectedReport, report.produceReport());
    }
    

    /**
     *                    6
     *                   /  \
     *                 5     4
     *               /  \      / \
     *             3   2    1   0
     *             
     * @throws Exception
     */
    @Test
    public void pyramid() throws Exception {
        Set<Long> init = new HashSet<Long>();
        init.addAll(Arrays.asList(new Long[] { 3L, 2L, 1L , 0L} ));
        
        Map<Long, Set<Long>> consumerProducer = new HashMap<Long, Set<Long>>();
        consumerProducer.put(3L, Collections.singleton(5L));
        consumerProducer.put(2L, Collections.singleton(5L));
        consumerProducer.put(1L, Collections.singleton(4L));
        consumerProducer.put(0L, Collections.singleton(4L));
        consumerProducer.put(5L, Collections.singleton(6L));
        consumerProducer.put(4L, Collections.singleton(6L));
        
        StubDataAccountabilityTrailCrud acctCrud = 
            new StubDataAccountabilityTrailCrud(consumerProducer);
        
        DataAccountabilityReport report = 
            new DataAccountabilityReport(init, acctCrud, pipelineTaskCrud, taskRenderer);
        String expectedReport = "Stub taskId = 6\n    Stub taskId = 4\n" +
                "        Data Receipt\n        Stub taskId = 1\n" +
                "    Stub taskId = 5\n        Stub taskId = 2\n        Stub taskId = 3\n";
        
        assertEquals(expectedReport, report.produceReport());
        
    }
    
    /**
     *        3   2   1   0
     *         \   /     \   /
     *          5         4
     *            \      /
     *               6
     */
    @Test
    public void invertedPyramid() throws Exception {
        Set<Long> init = Collections.singleton(6L);
        
        Map<Long, Set<Long>> consumerProducer = new HashMap<Long, Set<Long>>();
        consumerProducer.put(6L, ArrayUtils.toSet(new Long[] { 5L, 4L}));
        consumerProducer.put(5L, ArrayUtils.toSet(new Long[] { 3L, 2L }));
        consumerProducer.put(4L, ArrayUtils.toSet(new Long[] { 1L, 0L}));
        
        StubDataAccountabilityTrailCrud acctCrud = 
            new StubDataAccountabilityTrailCrud(consumerProducer);
        
        DataAccountabilityReport report =
            new DataAccountabilityReport(init, acctCrud, pipelineTaskCrud, taskRenderer);
        
        String expectedReport = 
               "Data Receipt\n    Stub taskId = 4\n        Stub taskId = 6\n" +
               "Stub taskId = 1\n    Stub taskId = 4\n        Stub taskId = 6\n" +
               "Stub taskId = 2\n    Stub taskId = 5\n        Stub taskId = 6\n" +
               "Stub taskId = 3\n    Stub taskId = 5\n        Stub taskId = 6\n";
        
        assertEquals(expectedReport, report.produceReport());
        
    }
    
    /**
     * Circular
     *            1
     *           ^ \
     *           /    v      X->Y ( X produces Y)
     *          4    2
     *          ^   /
     *           \   v
     *             3
     */
    @Test
    public void circular() throws Exception {
        Set<Long> init =  Collections.singleton(1L);
        Map<Long, Set<Long>> consumerProducer = new HashMap<Long, Set<Long>>();
        consumerProducer.put(2L, Collections.singleton(1L));
        consumerProducer.put(3L, Collections.singleton(2L));
        consumerProducer.put(4L, Collections.singleton(3L));
        consumerProducer.put(1L, Collections.singleton(4L));
        
        Map<Long, Set<Long>> producerConsumer = new HashMap<Long, Set<Long>>();
        producerConsumer.put(1L, Collections.singleton(2L));
        producerConsumer.put(2L, Collections.singleton(3L));
        producerConsumer.put(3L, Collections.singleton(4L));
        producerConsumer.put(4L, Collections.singleton(1L));
        
        StubDataAccountabilityTrailCrud acctCrud =
            new StubDataAccountabilityTrailCrud(consumerProducer);
        
        DataAccountabilityReport report =
            new DataAccountabilityReport(init, acctCrud, pipelineTaskCrud, taskRenderer);
        
        reflectionEquals.assertEquals(consumerProducer, report.calculateClosure());
        reflectionEquals.assertEquals(producerConsumer, report.invertMap(consumerProducer));
        reflectionEquals.assertEquals(init, report.findRoots(init, consumerProducer, producerConsumer));
        
        String expectedReport =
            "Stub taskId = 1\n    Stub taskId = 2\n        Stub taskId = 3\n" +
            "            Stub taskId = 4\n                Stub taskId = 1\n";
        String actualReport = report.produceReport();
        assertEquals(actualReport+expectedReport, expectedReport, actualReport);
    }
    
    /**
     * Cycle
     * 
     *       1      
     *         \
     *           2
     *           | \ 4
     *           | / 
     *           3
     */
    @Test
    public void cycle() throws Exception {
        Set<Long> init = Collections.singleton(3L);
        
        Map<Long, Set<Long>> consumerProducer = new HashMap<Long, Set<Long>>();
        consumerProducer.put(3L, ArrayUtils.toSet(new Long[] {2L, 4L}));
        consumerProducer.put(4L, Collections.singleton(2L));
        consumerProducer.put(2L, Collections.singleton(1L));
        
        StubDataAccountabilityTrailCrud acctCrud =
            new StubDataAccountabilityTrailCrud(consumerProducer);
        
        DataAccountabilityReport report =
            new DataAccountabilityReport(init, acctCrud, pipelineTaskCrud, taskRenderer);
        
        String expectedReport =
            "Stub taskId = 1\n    Stub taskId = 2\n        Stub taskId = 3\n" +
            "        Stub taskId = 4\n            Stub taskId = 3\n";
        String actualReport = report.produceReport();
        
        assertEquals(actualReport + expectedReport, expectedReport, actualReport);
    }
    
    /**
     * 
     * @author Sean McCauliff
     *
     */
    
    private static class StubDataAccountabilityTrailCrud extends DataAccountabilityTrailCrud {
        private final Map<Long, Set<Long>> consumerProducer;
        
        public StubDataAccountabilityTrailCrud(Map<Long, Set<Long>>  consumerProducer) {
            super(null);
            this.consumerProducer = consumerProducer;
        }
        
        @Override
        public DataAccountabilityTrail retrieve(long pipelineTaskId) {
            if (!consumerProducer.containsKey(pipelineTaskId)) {
                return null;
            }
            DataAccountabilityTrail trail = 
                new DataAccountabilityTrail(pipelineTaskId, consumerProducer.get(pipelineTaskId));
            return trail;
        }
    }
    
    private static class StubPipelineTaskCrud extends PipelineTaskCrud {
        public StubPipelineTaskCrud() {
            super(null);
        }
        
        @Override
        public PipelineTask retrieve(final long pipelineTaskId) {
            if (pipelineTaskId == 0) {
                throw new IllegalArgumentException("Pipeline task 0 does not exist.");
            }
            PipelineTask task = new PipelineTask();
            task.setId(pipelineTaskId);
                        
            UnitOfWorkTask uowt = new TestUnitOfWorkTask(pipelineTaskId);
            
            BeanWrapper<UnitOfWorkTask> bwUow;
            try {
                bwUow = new BeanWrapper<UnitOfWorkTask>(uowt);
            } catch (PipelineException e) {
                throw new IllegalStateException("Can't instantiate UowTask.", e);
            }
            task.setUowTask(bwUow);
            
            return task;
            
        }
    }
    
    public static class TestUnitOfWorkTask extends UnitOfWorkTask{
        
        private long pipelineTaskId;
        
        public TestUnitOfWorkTask() {
        }

        public TestUnitOfWorkTask(long pipelineTaskId) {
            this.pipelineTaskId = pipelineTaskId;
        }

        public long getPipelineTaskId() {
            return pipelineTaskId;
        }

        public void setPipelineTaskId(long pipelineTaskId) {
            this.pipelineTaskId = pipelineTaskId;
        }

        @Override
        public String briefState() {
            return "Stub taskId = " + pipelineTaskId;
        }

    }
}
