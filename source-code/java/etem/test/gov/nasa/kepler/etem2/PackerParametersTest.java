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

package gov.nasa.kepler.etem2;

import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.util.ArrayList;
import java.util.List;

import org.junit.Test;


public class PackerParametersTest {

    @Test
    public void testEmptyCadenceGapOffsets() throws Exception{
        PackerParameters p = new PackerParameters();
        p.setCadenceGapOffsets(new String[0]);
        
        List<Integer> actualGaps = p.cadenceGapOffsets();
        List<Integer> expectedGaps = new ArrayList<Integer>();
        
        ReflectionEquals c = new ReflectionEquals();
        
        c.assertEquals("gaps", expectedGaps, actualGaps);
    }

    @Test
    public void testSingleCadenceGapOffsets() throws Exception{
        PackerParameters p = new PackerParameters();
        p.setCadenceGapOffsets(new String[]{"0","5","42"});
        
        List<Integer> actualGaps = p.cadenceGapOffsets();
        List<Integer> expectedGaps = new ArrayList<Integer>(){
            {
                add(0);
                add(5);
                add(42);
            }
        };
        
        ReflectionEquals c = new ReflectionEquals();
        
        c.assertEquals("gaps", expectedGaps, actualGaps);
    }

    @Test
    public void testRangeCadenceGapOffsets() throws Exception{
        PackerParameters p = new PackerParameters();
        p.setCadenceGapOffsets(new String[]{"0","5-10","42-52"});
        
        List<Integer> actualGaps = p.cadenceGapOffsets();
        List<Integer> expectedGaps = new ArrayList<Integer>(){
            {
                add(0);
                add(5);
                add(6);
                add(7);
                add(8);
                add(9);
                add(10);
                add(42);
                add(43);
                add(44);
                add(45);
                add(46);
                add(47);
                add(48);
                add(49);
                add(50);
                add(51);
                add(52);
            }
        };
        
        ReflectionEquals c = new ReflectionEquals();
        
        c.assertEquals("gaps", expectedGaps, actualGaps);
    }
}
