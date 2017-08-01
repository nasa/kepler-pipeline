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


import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Map;
import java.util.Set;
import java.util.zip.GZIPInputStream;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class MemdroneLogTest {
    private static final Log log = LogFactory.getLog(MemdroneLogTest.class);
        
    private static final String MEMDRONE_LOG_PATH = "testdata/memdrone/memdrone-r190i1n5.txt.gz"; 
    private static final String[] expectedPids = {"62960","62954","54531","89594","62956","62963","72050","83687","62959","96229","20017","47885","50848"};
    private static final int[] expectedSampleCounts = {109003,21253,17881,1,42567,25968,15783,209673,85938,10369,1,1,13542};

    @Before
    public void setUp() throws Exception {
    }
    
    @Test
    public void testParse() throws Exception{
        File memdroneFile = new File(MEMDRONE_LOG_PATH);
        InputStream input = new GZIPInputStream(new FileInputStream(memdroneFile));
        MemdroneLog mLog = new MemdroneLog(input);
        Map<String, DescriptiveStatistics> contents = mLog.getLogContents();
        
        Set<String> processIds = contents.keySet();
        assertEquals("numKeys", expectedPids.length, processIds.size());
        
        for (String pid : processIds) {
            log.info("pid: " + pid + ", N=" + contents.get(pid).getN());
        }
                
        for (int i = 0; i < expectedPids.length; i++) {
            String expectedPid = expectedPids[i];
            int expectedSampleCount = expectedSampleCounts[i];
            DescriptiveStatistics stats = contents.get(expectedPid);
            
            assertTrue("contains " + expectedPid, processIds.contains(expectedPid));
            assertEquals("expectedSampleCount[" + expectedPid + "]", expectedSampleCount, stats.getN());
        }
    }
}
