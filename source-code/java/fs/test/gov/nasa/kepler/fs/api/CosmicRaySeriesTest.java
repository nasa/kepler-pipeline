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

package gov.nasa.kepler.fs.api;


import static org.junit.Assert.assertEquals;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class CosmicRaySeriesTest {

    @Before
    public void setUp() throws Exception {
    }

    @After
    public void tearDown() throws Exception {
    }

    @Test
    public void pipeDelimitedCosmicRaySeriesTest() throws Exception {
        FsId id = new FsId("/blah/blah/blah234234/234234/23");
        double[] mjd = new double[] {34.0, 35.0, 37.0};
        float[] values = new float[] {0.5f, 1.0f, 0.01f};
        long[] originators = new long[] {2L, 2L, 1L};
        FloatMjdTimeSeries crs = new FloatMjdTimeSeries(id, 0.0, 50.0, mjd, values, originators, true); 
        String pipeString = crs.toPipeString();
        FloatMjdTimeSeries unPiped = FloatMjdTimeSeries.fromPipeString(pipeString);
        assertEquals(crs, unPiped);
    }
    
    @Test
    public void emptyPipeDelimitedCosmicRaySeries() throws Exception {
        FsId id = new FsId("/a/b");
        FloatMjdTimeSeries emptySeries = 
            new FloatMjdTimeSeries(id, 1.0, 2.0, FloatMjdTimeSeries.EMPTY_MJD, 
                                                FloatMjdTimeSeries.EMPTY_VALUES, 
                                                FloatMjdTimeSeries.EMPTY_ORIGIN, true);
        String pipeString = emptySeries.toPipeString();
        FloatMjdTimeSeries unPiped = FloatMjdTimeSeries.fromPipeString(pipeString);
        assertEquals(emptySeries, unPiped);
        
    }
    
    @Test(expected=java.lang.IllegalArgumentException.class)
    public void constructorMjdExceptionTest() {
        double[] mjd = {0.0, 2.0, 1.9, 2.2};
        float[] values = { 1.0f, 2.0f, 3.0f, 4.0f};
        long[] originators = {4L, 5L, 6L, 7L};
        FsId id = new FsId("/blah/b");
        
        @SuppressWarnings("unused")
        FloatMjdTimeSeries mts = 
            new FloatMjdTimeSeries(id, mjd[0], mjd[mjd.length - 1], mjd, values,
                originators, true);
        
    }
}
