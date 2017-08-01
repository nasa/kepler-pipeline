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

package gov.nasa.kepler.ar.exporter;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.ar.exporter.FrontEndPipelineMetadata;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.hibernate.cal.CalCrud;
import gov.nasa.kepler.hibernate.cal.UncertaintyTransformationMetadata;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.util.List;

import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.Lists;

/**
 * @author Miles Cote
 * 
 */
public class FrontEndPipelineMetadataTest extends JMockTest {

    private static final CadenceType CADENCE_TYPE = CadenceType.LONG;
    private static final int START_CADENCE = 1;
    private static final int END_CADENCE = 2;
    private static final long PIPELINE_TASK_ID = 4;

    private UncertaintyTransformationMetadata metadata = mock(UncertaintyTransformationMetadata.class);
    private List<UncertaintyTransformationMetadata> metadataList = Lists.newArrayList(metadata);

    private PipelineTask pipelineTask = mock(PipelineTask.class);
    private PipelineInstance pipelineInstance = mock(PipelineInstance.class);

    private CalCrud calCrud = mock(CalCrud.class);
    private PipelineTaskCrud pipelineTaskCrud = mock(PipelineTaskCrud.class);

    private FrontEndPipelineMetadata frontEndPipelineMetadata = new FrontEndPipelineMetadata(
        calCrud, pipelineTaskCrud);

    @Before
    public void setUp() {
        allowing(calCrud).retrieveUncertaintyTransformationMetadata(
            START_CADENCE, END_CADENCE, CADENCE_TYPE);
        will(returnValue(metadataList));

        allowing(metadata).getPipelineTaskId();
        will(returnValue(PIPELINE_TASK_ID));

        allowing(pipelineTaskCrud).retrieve(PIPELINE_TASK_ID);
        will(returnValue(pipelineTask));

        allowing(pipelineTask).getPipelineInstance();
        will(returnValue(pipelineInstance));
    }

    @Test
    public void testGetPipelineInstanceIdWithMetadata() {
        testGetPipelineInstanceIdInternal();
    }

    @Test(expected = IllegalArgumentException.class)
    public void testGetPipelineInstanceIdWithNoMetadata() {
        metadataList.clear();

        testGetPipelineInstanceIdInternal();
    }

    private void testGetPipelineInstanceIdInternal() {
        PipelineInstance actualPipelineInstance = frontEndPipelineMetadata.getPipelineInstance(
            CADENCE_TYPE, START_CADENCE, END_CADENCE);

        assertEquals(pipelineInstance, actualPipelineInstance);
    }

}
