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

package gov.nasa.kepler.mc.uow;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.hibernate.dv.DvCrud;
import gov.nasa.kepler.mc.CompletedDvPipelineInstanceSelectionParameters;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(JMock.class)
public class DvResultUowTaskGeneratorTest {

    private static final int CHUNK_SIZE = 256;
    private Mockery mockery;

    @Before
    public void setup() throws Exception {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
    }

    @Test
    public void testDvResultUowTaskGenerator() throws Exception {
        final long PIPELINE_INST_ID = 42L;
        final List<Integer> keplerIds = new ArrayList<Integer>();
        for (int i = 0; i < CHUNK_SIZE * 2; i++) {
            keplerIds.add(i);
        }
        CompletedDvPipelineInstanceSelectionParameters params = new CompletedDvPipelineInstanceSelectionParameters();
        params.setChunkSize(CHUNK_SIZE);
        params.setPipelineInstanceId(PIPELINE_INST_ID);
        final DvCrud dvCrud = mockery.mock(DvCrud.class);
        mockery.checking(new Expectations() {
            {
                one(dvCrud).retrievePlanetResultsKeplerIdsByPipelineInstanceId(
                    PIPELINE_INST_ID);
                will(returnValue(keplerIds));
            }
        });

        DvResultUowTaskGenerator generator = new DvResultUowTaskGenerator() {
            @Override
            protected DvCrud dvCrud() {
                return dvCrud;
            }
        };

        Map<Class<? extends Parameters>, Parameters> parameters = new HashMap<Class<? extends Parameters>, Parameters>();
        parameters.put(CompletedDvPipelineInstanceSelectionParameters.class,
            params);

        @SuppressWarnings("unchecked")
        List<DvResultUowTask> tasks = (List<DvResultUowTask>) generator.generateTasks(parameters);

        assertTasks(tasks, false);

    }

    private static void assertTasks(List<DvResultUowTask> tasks, boolean latest) {
        assertEquals(2, tasks.size());
        assertEquals(0, tasks.get(0)
            .getStartKeplerId());
        assertEquals(CHUNK_SIZE - 1, tasks.get(0)
            .getEndKeplerId());

        assertEquals(CHUNK_SIZE, tasks.get(1)
            .getStartKeplerId());
        assertEquals(CHUNK_SIZE * 2 - 1, tasks.get(1)
            .getEndKeplerId());
    }
}
