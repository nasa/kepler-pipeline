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

package gov.nasa.kepler.fs.perf;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.CountDownLatch;
import java.util.regex.Pattern;

import org.junit.Test;

import static org.junit.Assert.*;

/**
 * @author Sean MscCauliff
 *
 */
public class StackTraceDumperTest {

    @Test
    public void testStackTraceDumper() throws Exception {
        final CountDownLatch done = new CountDownLatch(1);
        final CountDownLatch start = new CountDownLatch(2);
        Runnable dumpedRunnable = new Runnable() {
            
            @Override
            public void run() {
                try {
                    start.countDown();
                    done.await();
                } catch (InterruptedException e) {
                    //Ignore
                }
            }
        };
        
        
        Runnable filteredRunnable = new Runnable() {
            
            @Override
            public void run() {
                filteredMethod(done, start);
            }
        };
        
        String dumpedThreadName = "count down waiter";
        Thread dumpedThread = new Thread(dumpedRunnable, dumpedThreadName);
        dumpedThread.start();
        
        String filteredThreadName = "filtered thread name";
        Thread filteredThread = new Thread(filteredRunnable, filteredThreadName);
        filteredThread.start();
        
        start.await();
        
        Pattern ignoreFilteredMethod = Pattern.compile(getClass().getName() + ".filteredMethod");
        StringWriter dump = new StringWriter();
        List<Pattern> emptyClassFilter = Collections.emptyList();
        StackTraceDumper dumper = new StackTraceDumper();
        dumper.dumpStack(dump, Collections.singletonList(ignoreFilteredMethod), 
            emptyClassFilter);
        
        done.countDown();
        
        String dumpStr = dump.toString();
        System.out.println(dumpStr);
        
        testOutput(dumpStr, dumpedThreadName, filteredThreadName);
        
    }
    
    
    
    private void testOutput(String dumpStr, String dumpedThreadName,
        String filteredThreadName) throws IOException {

        Set<String> threadsSeen = new HashSet<String>();
        StringReader reader = new StringReader(dumpStr);
        BufferedReader breader = new BufferedReader(reader);
        for (String line = breader.readLine(); line != null; line = breader.readLine()) {
            String[] parts = line.split("\\|");
            assertEquals(5, parts.length);
            Long.parseLong(parts[0]);
            threadsSeen.add(parts[1]);
            assertTrue(parts[2].length() > 0);
            assertTrue(parts[2].length() > 0);
        }
       
        assertTrue(threadsSeen.contains(dumpedThreadName));
        assertFalse(threadsSeen.contains(filteredThreadName));
    }



    private void filteredMethod(CountDownLatch done, CountDownLatch start) {
        start.countDown();
        try {
            done.await();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
