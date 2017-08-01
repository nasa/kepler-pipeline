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

package gov.nasa.kepler.ar.exporter.cal;

import static org.junit.Assert.*;
import gov.nasa.kepler.ar.exporter.cal.TargetAndApertureIdMap.TargetAndApertureId;

import nom.tam.fits.Fits;

import org.junit.Ignore;
import org.junit.Test;

/**
 * 
 * @author Sean McCauliff
 *
 */
public class TargetAndApertureIdMapTest {

    @Test
    public void testMap() throws Exception {
        short module = (short) 2;
        short output = (short) 3;
        TargetAndApertureIdMap map = new TargetAndApertureIdMap();
        map.addIds(module,true, output, new short[] { (short) 44}, new short[] {(short) 42}, new int[] { 1}, new short[]{(short) 7});
        TargetAndApertureId lookup = map.find(module, true, output, (short) 44, (short) 42);
        assertEquals((short)7,  lookup.apertureId);
        assertEquals(1, lookup.targetId);
        
        lookup = map.find(module, true, output, (short) 42, (short)44);
        assertEquals(null, lookup);
        
        
        lookup = map.find(module, false, output, (short) 44, (short) 42);
        assertEquals(null, lookup);
    }
    
    @Ignore
    public void loadPmrfTest() throws Exception {
        Fits pmrfFits = new Fits("/path/to/kplr2008308132901-170-170_lcm.fits");
        TargetAndApertureIdMap map = new TargetAndApertureIdMap();
        map.addVisiblePmrf(pmrfFits, "blah");
        
        TargetAndApertureId lookup =
            map.find((short)2, false, (short) 1, (short) 904, (short) 441);
        assertTrue(lookup != null);
    }
}
