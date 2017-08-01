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

package gov.nasa.kepler.systest.sbt;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Test;


/**
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class PingResultsTest {

    private PingResults init(boolean dbStatus, boolean fsStatus, boolean requireDatabase, boolean requireFilestore){
        PingResults results = new PingResults();
        
        results.setRequireDatabase(requireDatabase);
        results.setDbAvailable(dbStatus);
        results.setDbError("Can't connect");
        results.setDbUrl("jdbc:hsqldb:hsql://host:port/db");
        
        results.setRequireFilestore(requireFilestore);
        results.setFsAvailable(fsStatus);
        results.setFsError("Can't connect");
        results.setFsUrl("fstp://host:port");
        return results;
    }
    
    @Test
    public void testBothRequiredBothOk(){
        System.out.println("testBothRequiredBothOk");
        PingResults results = init(true, true, true, true);
        assertTrue(results.validate());
    }

    @Test
    public void testBothRequiredOneOk(){
        System.out.println("testBothRequiredOneOk");
        PingResults results = init(true, false, true, true);
        assertFalse(results.validate());
    }

    @Test
    public void testBothRequiredNoneOk(){
        System.out.println("testBothRequiredNoneOk");
        PingResults results = init(false, false, true, true);
        assertFalse(results.validate());
    }
    
    @Test
    public void testOneRequiredBothOk(){
        System.out.println("testOneRequiredBothOk");
        PingResults results = init(true, true, true, false);
        assertTrue(results.validate());
    }

    @Test
    public void testOneRequiredOneOk(){
        System.out.println("testOneRequiredOneOk");
        PingResults results = init(true, false, true, false);
        assertTrue(results.validate());
    }

    @Test
    public void testOneRequiredNoneOk(){
        System.out.println("testOneRequiredNoneOk");
        PingResults results = init(false, false, true, false);
        assertFalse(results.validate());
    }
    
    @Test
    public void testNoneRequiredBothOk(){
        System.out.println("testNoneRequiredBothOk");
        PingResults results = init(true, true, false, false);
        assertTrue(results.validate());
    }

    @Test
    public void testNoneRequiredOneOk(){
        System.out.println("testNoneRequiredOneOk");
        PingResults results = init(true, false, false, false);
        assertTrue(results.validate());
    }

    @Test
    public void testNoneRequiredNoneOk(){
        System.out.println("testNoneRequiredNoneOk");
        PingResults results = init(false, false, false, false);
        assertTrue(results.validate());
    }    
}
