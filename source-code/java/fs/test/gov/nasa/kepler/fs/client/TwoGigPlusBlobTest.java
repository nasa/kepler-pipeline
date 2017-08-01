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

package gov.nasa.kepler.fs.client;
import gov.nasa.kepler.io.DataInputStream;
import gov.nasa.kepler.io.DataOutputStream;


import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreTestInterface;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.StreamedBlobResult;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;

import junit.framework.AssertionFailedError;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class TwoGigPlusBlobTest {

	private final File testRoot = 
		new File(Filenames.BUILD_TEST, "/TwoGigPlusBlobTest");
	private FileStoreClient fsClient;
	
	
	@Before
	public void setUp() throws Exception {
		if (!testRoot.mkdirs()) {
			throw new IllegalStateException("Can't make test directory.");
		}
		fsClient = FileStoreClientFactory.getInstance();
	}

	@After
	public void tearDown() throws Exception {
		FileUtil.removeAll(testRoot);
		((FileStoreTestInterface)fsClient).cleanFileStore();
		
	}
	
	@Test
	public void twoGigBlobTest() throws Exception {
		File twoGigBlob = new File(testRoot, "2G.blob");
		DataOutputStream dout = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(twoGigBlob), 1024*1024));
		long size = ((long)Integer.MAX_VALUE) + 8;
		for (long i=0; i < size; i++) {
			dout.writeByte((byte)i);
		} 
		dout.close();
		
		FsId id = new FsId("/b/BigOne");
		
		fsClient.beginLocalFsTransaction();
		fsClient.writeBlob(id, 1L, twoGigBlob);
		fsClient.commitLocalFsTransaction();
		
		System.out.println("Done writing.");
		
		StreamedBlobResult result = fsClient.readBlobAsStream(id);
		assertEquals(1L, result.originator());
		assertEquals(size, result.size());
		
		
		DataInputStream din  = new DataInputStream(new BufferedInputStream(result.stream(), 1024*1024));
		for (long i=0; i < size; i++) {
			byte readByte = din.readByte();
			if (readByte != (byte) i) {  //not using assertEquals() here because of auto boxing overhead.
				throw new AssertionFailedError("Bytes not equals.");
			}
		}
		din.close();
	}

}
