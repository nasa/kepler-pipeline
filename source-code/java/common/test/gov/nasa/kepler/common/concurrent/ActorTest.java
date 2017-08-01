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

package gov.nasa.kepler.common.concurrent;

import static org.junit.Assert.*;
import gov.nasa.spiffy.common.concurrent.Actor;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.*;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class ActorTest {

	private final ExecutorService xService = Executors.newCachedThreadPool();
	private final String endMessage = "end";

	private final File testFileDir = new File(Filenames.BUILD_TEST, "ActorTest");
	private final File testFile = new File(testFileDir, "test-input");
	private int expectedTokenCount;
	
	@Before
	public void setup() throws Exception {
		expectedTokenCount = 0;
		FileUtil.mkdirs(testFileDir);
		BufferedWriter bwriter = new BufferedWriter(new FileWriter(testFile));
		for (int i=0; i < 20; i++) {
			for (int j=0; j < i; j++) {
				bwriter.write(Integer.toString(j));
				bwriter.write('|');
				expectedTokenCount++;
			}
			bwriter.write(Integer.toString(i));
			bwriter.write('\n');
			expectedTokenCount++;
		}
		bwriter.close();
	}
	
	@After
	public void tearDown() throws Exception {
		FileUtil.cleanDir(testFileDir);
	}
	
    @Test
    public void actorProducerConsumerTest() throws Exception {
		
    	final CountDownLatch done = new CountDownLatch(1);
    	final AtomicInteger atomicTokenCount = new AtomicInteger();

		final Actor<String> consumer = new Actor<String>() {
			private int tokenCount = 0;
			
			@Override
			protected void act(String message) {
				tokenCount += message.split("\\|").length;
			}
			
			@Override
			protected boolean isDoneProducing(String message) {
				if (endMessage == message) {
					atomicTokenCount.set(tokenCount);
					done.countDown();
					System.out.println(tokenCount);
					return true;
				} else {
					return false;
				}
			}
			
			@Override
			protected void handleException(Exception e) {
				done.countDown();
				super.handleException(e);
			}
		};
		
		xService.submit(consumer);
		
		final BufferedReader breader = new BufferedReader(new FileReader(testFile));
		final Actor<Object> producer = new Actor<Object>() {
			@Override
			protected void act(Object message) throws Exception {
				for (String line = breader.readLine();
						line != null;
						line = breader.readLine()) {
					consumer.blockingSend(line);
				}
				consumer.blockingSend(endMessage);
			}
			@Override
			protected void passOnError() {
				try {
					consumer.blockingSend(endMessage);
				} catch (InterruptedException ie) {
					//log me.
				}
			}
		};
		
		xService.submit(producer);
		
		producer.blockingSend("go");
		done.await(45, TimeUnit.SECONDS);
		assertEquals(0L, done.getCount());
		
		assertEquals(expectedTokenCount, atomicTokenCount.get());
		
		breader.close();
	}
}
