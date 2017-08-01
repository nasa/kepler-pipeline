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

import java.util.ArrayList;
import java.util.List;

import org.junit.Test;

public class KicGroupBinnerTest {

    @Test
    public void testSingle() {

        List<TestKicGroupBinnable> groupBins = new ArrayList<TestKicGroupBinnable>();
        groupBins.add(new TestKicGroupBinnable(1, 1000));
        groupBins = KicGroupBinner.subDivide(groupBins, 100, 0);

        assertEquals("incorrect number of bins", 10, groupBins.size());
        
        for (int i = 0; i < 10; i++) {
            assertEquals("incorrect size in bin#" + 1, 100, groupBins.get(i)
                .size());
        }
    }

    @Test
    public void testMultiple() {

        List<TestKicGroupBinnable> groupBins = new ArrayList<TestKicGroupBinnable>();
        groupBins.add(new TestKicGroupBinnable(1, 1000));
        groupBins.add(new TestKicGroupBinnable(1, 1000));
        groupBins = KicGroupBinner.subDivide(groupBins, 100, 0);

        assertEquals("incorrect number of bins", 20, groupBins.size());
        
        for (int i = 0; i < 10; i++) {
            assertEquals("incorrect size in bin#" + 1, 100, groupBins.get(i)
                .size());
        }
    }

    @Test
    public void testMaxGroups() {

        List<TestKicGroupBinnable> groupBins = new ArrayList<TestKicGroupBinnable>();
        groupBins.add(new TestKicGroupBinnable(1, 1000));
        groupBins = KicGroupBinner.subDivide(groupBins, 100, 5);

        assertEquals("incorrect number of bins", 5, groupBins.size());
        
        for (int i = 0; i < 5; i++) {
            assertEquals("incorrect size in bin#" + 1, 100, groupBins.get(i)
                .size());
        }
    }

    private class TestKicGroupBinnable implements KicGroupBinnable {
        private int startId;
        private int endId;

        public TestKicGroupBinnable(int startId, int endId) {
            this.startId = startId;
            this.endId = endId;
        }

        public KicGroupBinnable makeCopy() {
            return new TestKicGroupBinnable(startId, endId);
        }

        public int size() {
            return endId - startId + 1;
        }

        /**
         * @return the endId
         */
        public int getEndId() {
            return endId;
        }

        /**
         * @param endId the endId to set
         */
        public void setEndId(int endId) {
            this.endId = endId;
        }

        /**
         * @return the startId
         */
        public int getStartId() {
            return startId;
        }

        /**
         * @param startId the startId to set
         */
        public void setStartId(int startId) {
            this.startId = startId;
        }

    }
}
