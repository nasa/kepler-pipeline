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

package gov.nasa.kepler.hibernate.mc;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.Cadence;

import java.util.ArrayList;
import java.util.List;

import org.junit.Test;

import com.google.common.collect.ImmutableList;


/**
 * @author Miles Cote
 * 
 */
public class ObservingLogModelTest {
    private List<ObservingLog> observingLogs = ImmutableList.of(
    new ObservingLog(Cadence.CADENCE_SHORT, 100, 200, 55000.5, 55030.5, 1, 1, 1, 42),
    new ObservingLog(Cadence.CADENCE_SHORT, 210, 300, 55031.5, 55060.5, 1, 2, 1, 43),
    new ObservingLog(Cadence.CADENCE_SHORT, 310, 400, 55061.5, 55090.5, 1, 3, 1, 44),
    new ObservingLog(Cadence.CADENCE_SHORT, 410, 500, 55091.5, 55120.5, 2, 1, 2, 45),
    new ObservingLog(Cadence.CADENCE_SHORT, 510, 600, 55121.5, 55150.5, 2, 2, 2, 46),
    new ObservingLog(Cadence.CADENCE_SHORT, 610, 700, 55151.5, 55180.5, 2, 3, 2, 47)
    );

    private int revision = 1;
    private ObservingLogModel observingLogModel = new ObservingLogModel(revision, observingLogs);
    
    @Test
    public void testStoreAndRetrieveByCadenceRange() throws Exception {
        List<ObservingLog> expectedList = new ArrayList<ObservingLog>();
        expectedList.add(observingLogs.get(0));
        expectedList.add(observingLogs.get(1));

        List<ObservingLog> actualList = observingLogModel.observingLogsFor(Cadence.CADENCE_SHORT, 200, 300);

        assertEquals(expectedList, actualList);
    }

    @Test
    public void testStoreAndRetrieveByBadCadenceType() throws Exception {
        List<ObservingLog> actualList = observingLogModel.observingLogsFor(Cadence.CADENCE_LONG, 200, 300);

        assertEquals("actualList.size()", 0, actualList.size());
    }

    @Test
    public void testStoreAndRetrieveByBadCadenceRange() throws Exception {
        List<ObservingLog> actualList = observingLogModel.observingLogsFor(Cadence.CADENCE_SHORT, 800, 900);

        assertEquals("actualList.size()", 0, actualList.size());
    }

    @Test
    public void testRetrieveWithCadenceRangeBeforeObsLog() throws Exception {
        List<ObservingLog> expectedList = new ArrayList<ObservingLog>();

        List<ObservingLog> actualList = observingLogModel.observingLogsFor(Cadence.CADENCE_SHORT, 90, 95);

        assertEquals(expectedList, actualList);
    }

    @Test
    public void testRetrieveWithEndCadenceAtObsLogStartCadence() throws Exception {
        List<ObservingLog> expectedList = new ArrayList<ObservingLog>();
        expectedList.add(observingLogs.get(0));
        
        List<ObservingLog> actualList = observingLogModel.observingLogsFor(Cadence.CADENCE_SHORT, 95, 100);

        assertEquals(expectedList, actualList);
    }

    @Test
    public void testRetrieveWithCadenceRangeWrappingObsLogStartCadence() throws Exception {
        List<ObservingLog> expectedList = new ArrayList<ObservingLog>();
        expectedList.add(observingLogs.get(0));
        
        List<ObservingLog> actualList = observingLogModel.observingLogsFor(Cadence.CADENCE_SHORT, 98, 103);

        assertEquals(expectedList, actualList);
    }

    @Test
    public void testRetrieveWithStartCadenceAtObsLogStartCadence() throws Exception {
        List<ObservingLog> expectedList = new ArrayList<ObservingLog>();
        expectedList.add(observingLogs.get(0));
        
        List<ObservingLog> actualList = observingLogModel.observingLogsFor(Cadence.CADENCE_SHORT, 100, 105);

        assertEquals(expectedList, actualList);
    }

    @Test
    public void testRetrieveWithCadenceRangeWithinObsLogCadenceRange() throws Exception {
        List<ObservingLog> expectedList = new ArrayList<ObservingLog>();
        expectedList.add(observingLogs.get(0));
        
        List<ObservingLog> actualList = observingLogModel.observingLogsFor(Cadence.CADENCE_SHORT, 105, 110);

        assertEquals(expectedList, actualList);
    }

    @Test
    public void testRetrieveWithEndCadenceAtObsLogEndCadence() throws Exception {
        List<ObservingLog> expectedList = new ArrayList<ObservingLog>();
        expectedList.add(observingLogs.get(0));
        
        List<ObservingLog> actualList = observingLogModel.observingLogsFor(Cadence.CADENCE_SHORT, 195, 200);

        assertEquals(expectedList, actualList);
    }

    @Test
    public void testRetrieveWithCadenceRangeWrappingObsLogEndCadence() throws Exception {
        List<ObservingLog> expectedList = new ArrayList<ObservingLog>();
        expectedList.add(observingLogs.get(0));
        
        List<ObservingLog> actualList = observingLogModel.observingLogsFor(Cadence.CADENCE_SHORT, 198, 203);

        assertEquals(expectedList, actualList);
    }

    @Test
    public void testRetrieveWithStartCadenceAtObsLogEndCadence() throws Exception {
        List<ObservingLog> expectedList = new ArrayList<ObservingLog>();
        expectedList.add(observingLogs.get(0));
        
        List<ObservingLog> actualList = observingLogModel.observingLogsFor(Cadence.CADENCE_SHORT, 200, 205);

        assertEquals(expectedList, actualList);
    }

    @Test
    public void testRetrieveWithCadenceRangeAfterObsLog() throws Exception {
        List<ObservingLog> expectedList = new ArrayList<ObservingLog>();

        List<ObservingLog> actualList = observingLogModel.observingLogsFor(Cadence.CADENCE_SHORT, 203, 208);

        assertEquals(expectedList, actualList);
    }
}
