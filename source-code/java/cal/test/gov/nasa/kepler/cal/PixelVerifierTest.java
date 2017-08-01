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

package gov.nasa.kepler.cal;

import static org.junit.Assert.*;

import java.util.Collections;
import java.util.Set;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.mc.gar.RequantTable;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.Sets;

/**
 * @author Sean McCauliff
 *
 */
@RunWith(JMock.class)
public class PixelVerifierTest {

    private final int startCadence = 2;
    private final int endCadence = 4;
    
    private Mockery mockery;
    
    @Before
    public void setup() {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
    }
    
    @Test
    public void pixelVerifierTest() {
        runPixelVerifierTest(new int[] { 2, -1, 1}, 0);
    }
    
    @Test
    public void failPixelVerifier() {
        runPixelVerifierTest(new int[] { 2, -1, 42}, 1);
    }
    
    private void runPixelVerifierTest(int[] uncalPixelValues, int missCount) {
        TimestampSeries cadenceTimes = 
            MockUtils.mockCadenceTimes(null, null, CadenceType.LONG, startCadence, endCadence);
        
        final int[] requantEntries = new int[] { 0, 1, 2};
        
        final RequantTable requantTable = mockery.mock(RequantTable.class);
        mockery.checking(new Expectations() {{
            atLeast(1).of(requantTable).getRequantEntries();
            will(returnValue(requantEntries));
        }});
        
        
        IntTimeSeries uncalTimeSeries = 
            new IntTimeSeries(new FsId("/b0gus/0"), uncalPixelValues,
                startCadence, endCadence, new boolean[] { false, true, false}, 333);
        PixelVerifier pixelVerifier = 
            new PixelVerifier(Collections.singletonList(requantTable), cadenceTimes);
        Set<TimeSeries> allUncalSeries = Sets.newHashSet();
        allUncalSeries.add(uncalTimeSeries);
        assertEquals(missCount, pixelVerifier.verify(allUncalSeries));
    }
    
    
}
