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

package gov.nasa.kepler.fs.server.scheduler;

import static org.junit.Assert.*;
import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FsId;

import java.io.IOException;
import java.util.*;

import org.apache.commons.math3.random.RandomGenerator;
import org.jmock.Expectations;
import org.jmock.Mockery;
import org.junit.Test;

public class SchedulerTest {
    
    private Mockery mockery = new Mockery();
    
    @Test
    public void scheduleNothing() throws Exception {
        Scheduler scheduler = new Scheduler(new ReturnFactory(new ArrayList<FsIdLocation>()));
        List<List<FsIdOrder>> chunkList  = scheduler.accessOrder(new ArrayList<FsIdOrder>(), 0);
        assertEquals(0, chunkList.size());
    }
    
    @Test
    public void allInOneChunk() throws Exception {
        Random rand = new Random();
        final RandomGenerator schedulerOffsetGenerator = mockery.mock(RandomGenerator.class);
        mockery.checking(new Expectations() {{
            atLeast(1).of(schedulerOffsetGenerator).nextInt(1);
            will(returnValue(0));
        }});
        
        List<FsIdLocation> locations = new ArrayList<FsIdLocation>();
        List<FsIdOrder> ids = new ArrayList<FsIdOrder>();
        Map<FsId, Integer> trueOrder = new HashMap<FsId, Integer>();
        int order = 1;
        for (int fileOffset=0; fileOffset < 64; fileOffset++) {
            FsId id = new FsId("/blah/" + rand.nextInt());
            locations.add(new FsIdLocation(0, fileOffset,  id, order));
            ids.add(new DefaultFsIdOrder(id, order++));
            trueOrder.put(id, fileOffset);
        }
        Collections.shuffle(ids);
        
        Scheduler scheduler = new Scheduler(new ReturnFactory(locations), schedulerOffsetGenerator);
        List<List<FsIdOrder>> chunks = scheduler.accessOrder(ids, 1 /* order */ );
        assertEquals(1, chunks.size());
        List<FsIdOrder> firstChunk = chunks.get(0);
        assertEquals(64, firstChunk.size());
        int previous = -1;
        for (FsIdOrder idOrder : firstChunk) {
            assertTrue(previous < trueOrder.get(idOrder.id()));
            previous = trueOrder.get(idOrder.id());
        }
    }
    
    private static final class ReturnFactory implements FsIdLocationFactory {

        private final List<FsIdLocation> rv;
        
        public ReturnFactory(List<FsIdLocation> rv) {
            this.rv = rv;
        }

        @Override
        public List<FsIdLocation> locationFor(List<FsIdOrder> ids)
            throws FileStoreException, IOException {

            return rv;
        }
        
    }
}
