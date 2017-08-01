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

package gov.nasa.kepler.pi.metrics.report;


import static org.junit.Assert.*;
import gov.nasa.kepler.pi.metrics.report.TopNList;

import org.junit.Test;

/**
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class TopNListTest {

    private final static int MAX_LIST_LENGTH = 5;
    
    @Test
    public void testShortUnorderedList(){
        TopNList actualList = generateList(MAX_LIST_LENGTH, 3,2,1);
        String actual = actualList.toString();
        String expected = "[3, 2, 1]";
        
        assertEquals("list", expected, actual);
    }
    
    @Test
    public void testShortOrderedList(){
        TopNList actualList = generateList(MAX_LIST_LENGTH, 1,2,3);
        String actual = actualList.toString();
        String expected = "[3, 2, 1]";
        
        assertEquals("list", expected, actual);
    }
    
    @Test
    public void testLongUnorderedList(){
        TopNList actualList = generateList(MAX_LIST_LENGTH, 7,3,4,1,9,2,5,8,6);
        String actual = actualList.toString();
        String expected = "[9, 8, 7, 6, 5]";
        
        assertEquals("list", expected, actual);
    }
    
    @Test
    public void testLongOrderedList(){
        TopNList actualList = generateList(MAX_LIST_LENGTH, 1,2,3,4,5,6,7,8,9,10);
        String actual = actualList.toString();
        String expected = "[10, 9, 8, 7, 6]";
        
        assertEquals("list", expected, actual);
    }
    
    private TopNList generateList(int listMaxLength, int... values){
        TopNList l = new TopNList(listMaxLength);
        for (int i : values) {
            l.add(i, "i=" + i);
        }
        return l;
    }
}
