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

package gov.nasa.kepler.mc.pi;

import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.pi.ModelRegistry;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.mc.fs.PpaFsIdFactory;
import gov.nasa.kepler.mc.fs.PpaFsIdFactory.TimeSeriesType;
import gov.nasa.kepler.mc.pi.OriginatorsModelRegistryChecker;
import gov.nasa.kepler.services.alert.AlertService;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.util.List;
import java.util.Map;
import java.util.Set;

import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;

/**
 * @author Miles Cote
 * 
 */
public class OriginatorsModelRegistryCheckerTest extends JMockTest {

    private PipelineInstance pipelineInstance1 = mock(PipelineInstance.class,
        "pipelineInstance1");
    private PipelineInstance pipelineInstance2 = mock(PipelineInstance.class,
        "pipelineInstance2");
    private AlertService alertService = mock(AlertService.class);

    @Test
    public void testCheckWithModelRegistryIdsAllTheSame() {
        System.setProperty(OriginatorsModelRegistryChecker.ENABLED_PROP_NAME,
            "true");
        
        long modelRegistryId1 = 5;
        long modelRegistryId2 = 5;

        testCheckInternal(modelRegistryId1, modelRegistryId2);
    }

    @Test
    public void testCheckWithModelRegistryIdsNotTheSame() {
        System.setProperty(OriginatorsModelRegistryChecker.ENABLED_PROP_NAME,
            "true");
        
        long modelRegistryId1 = 5;
        long modelRegistryId2 = 6;

        oneOf(alertService).generateAlert(
            OriginatorsModelRegistryChecker.class.getSimpleName(),
            "timeSeries cannot have different modelRegistries."
                + "\n  ***************"
                + "\n  fsId: /ppa/AchievedCompressionEfficiency"
                + "\n  pipelineTaskIds: [3, 4]" + "\n  modelRegistryId: 5"
                + "\n  ***************"
                + "\n  fsId: /ppa/AchievedCompressionEfficiency"
                + "\n  pipelineTaskIds: [3, 4]" + "\n  modelRegistryId: 6");

        testCheckInternal(modelRegistryId1, modelRegistryId2);
    }

    @Test
    public void testCheckWithNullModelRegistry() {
        System.setProperty(OriginatorsModelRegistryChecker.ENABLED_PROP_NAME,
            "true");
        
        long modelRegistryId1 = 5;
        long modelRegistryId2 = 5;

        allowing(pipelineInstance1).getModelRegistry();
        will(returnValue(null));

        allowing(pipelineInstance2).getModelRegistry();
        will(returnValue(null));

        testCheckInternal(modelRegistryId1, modelRegistryId2);
    }

    @Test
    public void testCheckWithModelRegistryIdsNotTheSameWithCheckerDisabled() {
        System.setProperty(OriginatorsModelRegistryChecker.ENABLED_PROP_NAME,
            "false");

        OriginatorsModelRegistryChecker checker = new OriginatorsModelRegistryChecker(
            null, null);
        checker.check(null);
    }

    private void testCheckInternal(long modelRegistryId1, long modelRegistryId2) {
        long start = 1;
        long end = 2;
        long originator1 = 3;
        long originator2 = 4;

        List<TaggedInterval> originatorsTaggedIntervals = ImmutableList.of(
            new TaggedInterval(start, end, originator1), new TaggedInterval(
                start, end, originator2));

        Set<Long> originatorsSet = ImmutableSet.of(originator1, originator2);

        long[] originatorsArray = { originator1, originator2 };

        PipelineTask pipelineTask1 = mock(PipelineTask.class, "pipelineTask1");
        PipelineTask pipelineTask2 = mock(PipelineTask.class, "pipelineTask2");

        ModelRegistry modelRegistry1 = mock(ModelRegistry.class,
            "modelRegistry1");
        ModelRegistry modelRegistry2 = mock(ModelRegistry.class,
            "modelRegistry2");

        List<PipelineTask> pipelineTasks = ImmutableList.of(pipelineTask1,
            pipelineTask2);

        FsId fsId = PpaFsIdFactory.getTimeSeriesFsId(TimeSeriesType.ACHIEVED_COMPRESSION_EFFICIENCY);
        TimeSeries timeSeries = mock(TimeSeries.class);
        FloatMjdTimeSeries floatMjdTimeSeries = mock(FloatMjdTimeSeries.class);

        Map<FsId, TimeSeries> fsIdToTimeSeries = ImmutableMap.of(fsId,
            timeSeries);

        Map<FsId, FloatMjdTimeSeries> fsIdToFloatMjdTimeSeries = ImmutableMap.of(
            fsId, floatMjdTimeSeries);

        Pair<Map<FsId, TimeSeries>, Map<FsId, FloatMjdTimeSeries>> fsIdToTimeSeriesMapPair = Pair.of(
            fsIdToTimeSeries, fsIdToFloatMjdTimeSeries);

        PipelineTaskCrud pipelineTaskCrud = mock(PipelineTaskCrud.class);

        allowing(timeSeries).originators();
        will(returnValue(originatorsTaggedIntervals));

        allowing(floatMjdTimeSeries).originators();
        will(returnValue(originatorsArray));

        allowing(pipelineTaskCrud).retrieveAll(originatorsSet);
        will(returnValue(pipelineTasks));

        allowing(pipelineTask1).getPipelineInstance();
        will(returnValue(pipelineInstance1));

        allowing(pipelineTask2).getPipelineInstance();
        will(returnValue(pipelineInstance2));

        allowing(pipelineInstance1).getModelRegistry();
        will(returnValue(modelRegistry1));

        allowing(pipelineInstance2).getModelRegistry();
        will(returnValue(modelRegistry2));

        allowing(modelRegistry1).getId();
        will(returnValue(modelRegistryId1));

        allowing(modelRegistry2).getId();
        will(returnValue(modelRegistryId2));

        allowing(pipelineTask1).getId();
        will(returnValue(originator1));

        allowing(pipelineTask2).getId();
        will(returnValue(originator2));

        OriginatorsModelRegistryChecker checker = new OriginatorsModelRegistryChecker(
            pipelineTaskCrud, alertService);
        checker.check(fsIdToTimeSeriesMapPair);
    }

}
