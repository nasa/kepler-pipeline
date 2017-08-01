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

package gov.nasa.kepler.fs.server.xfiles;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.Collection;
import java.util.Set;

import org.apache.commons.io.output.ByteArrayOutputStream;

import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.FakeXid;
import gov.nasa.kepler.fs.server.journal.ConcurrentJournalWriter;
import gov.nasa.kepler.fs.server.journal.JournalWriter;
import gov.nasa.kepler.fs.server.scheduler.FsIdLocation;
import gov.nasa.kepler.fs.server.scheduler.FsIdOrder;
import gov.nasa.kepler.fs.storage.LaneAddressSpace;
import gov.nasa.kepler.fs.storage.MjdContainerFileStorage;
import gov.nasa.kepler.fs.storage.RandomAccessAllocator;
import gov.nasa.kepler.fs.storage.RandomAccessStorage;
import gov.nasa.kepler.fs.storage.StorageAllocatorInterface;
import gov.nasa.kepler.io.DataOutputStream;
import gov.nasa.spiffy.common.collect.Pair;

/**
 * @author smccauli
 *
 */
public class MjdTimeSeriesInspector {

	// RandomAccessFsIdInfo [dataFileId=924, dataLane=47, metaFileId=925, metaLane=47, isNew()=false]
	public static void main(String[] argv) throws Exception {
		FsId id = new FsId("/pdc/Sap/Outliers/long/7886329");
		File dataDir = new File("/path/to/long/hd-42");
		File metaDir = new File("/path/to/long/hd-43");
		LaneAddressSpace dataSpace =
		    new LaneAddressSpace(47, RandomAccessAllocator.HEADER_SIZE, 64,  dataDir, 924);
		LaneAddressSpace metaSpace = new LaneAddressSpace(47, RandomAccessAllocator.HEADER_SIZE, 64, metaDir, 925);
		
		FakeXid fakeXid = new FakeXid(23423423, 4);
		JournalWriter journalWriter = new ConcurrentJournalWriter(new File("/tmp/journal"), fakeXid);
		StorageAllocatorInterface allocator = new StorageAllocatorInterface() {
			
			@Override
			public void setNewState(FsId id, boolean b) throws IOException,
					InterruptedException {

				throw new UnsupportedOperationException();
			}
			
			@Override
			public void removeId(FsId id) throws IOException, InterruptedException {

				throw new UnsupportedOperationException();
			}
			
			@Override
			public void removeAllNewIds() throws IOException, InterruptedException {

				throw new UnsupportedOperationException();
			}
			
			@Override
			public void removeAllNewIds(Collection<FsId> ids) throws IOException,
					InterruptedException {

				throw new UnsupportedOperationException();
			}
			
			@Override
			public void markIdsPersistent(Collection<FsId> ids) throws IOException,
					InterruptedException {

				//ignored
			}
			
			@Override
			public FsIdLocation locationFor(FsIdOrder id) throws IOException,
					FileStoreException, InterruptedException {

				throw new UnsupportedOperationException();
			}
			
			@Override
			public boolean isNew(FsId id) throws IOException, InterruptedException {
				return false;
			}
			
			@Override
			public boolean isAllocated(FsId id) throws IOException,
					InterruptedException {
				return true;
			}
			
			@Override
			public boolean hasSeries(FsId id) throws IOException, InterruptedException {
				return true;
			}
			
			@Override
			public void gcFiles() throws IOException, InterruptedException {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public Set<FsId> findNewIds() {

				throw new UnsupportedOperationException();
			}
			
			@Override
			public Set<FsId> findIds() {

				throw new UnsupportedOperationException();
			}
			
			@Override
			public boolean doesStorageTrackLength() {
				return true;
			}
			
			@Override
			public void commitPendingModifications() throws IOException,
					InterruptedException {

				throw new UnsupportedOperationException();
			}
			
			@Override
			public void close() throws IOException {

				throw new UnsupportedOperationException();
			}
		};
		RandomAccessStorage storage =
				new MjdContainerFileStorage(id, dataSpace, metaSpace, false, allocator);
		TransactionalMjdTimeSeriesFile xfile = 
				TransactionalMjdTimeSeriesFile.loadFile(storage);
		
		xfile.beginTransaction(fakeXid, journalWriter, 2);
		FloatMjdTimeSeries xSeries = xfile.read(0, Double.MAX_VALUE, fakeXid);

//		double newStart = 55931.59293884;
//		double newEnd = 56014.532944;
//		int newStartIndex = Arrays.binarySearch(xSeries.mjd(), newStart);
//		if (newStartIndex < 0) {
//			newStartIndex = -newStartIndex - 1; 
//		}
//		int newEndIndex = Arrays.binarySearch(xSeries.mjd(), newEnd);
//		if (newEndIndex < 0) {
//			newEndIndex = -newEndIndex - 1;
//		}
//		double[] subsetMjd = Arrays.copyOfRange(xSeries.mjd(), newStartIndex, newEndIndex + 1);
//		float[] subsetValues = Arrays.copyOfRange(xSeries.values(), newStartIndex, newEndIndex + 1);
//		long[] subsetOriginators = Arrays.copyOfRange(xSeries.originators(), newStartIndex, newEndIndex + 1);
//		int newLength = subsetMjd.length;
//		FloatMjdTimeSeries suffixSeries = 
//				new FloatMjdTimeSeries(xSeries.id(), subsetMjd[0], subsetMjd[newLength - 1],
//						subsetMjd, subsetValues, subsetOriginators, true);
//
//		xfile.write(suffixSeries, true, fakeXid);
//		
//		xfile.acquireTransactionLock(fakeXid);
//		xfile.prepareTransaction(fakeXid);
//		journalWriter.close();
//		TransactionalMjdTimeSeriesTest.commitTransaction(fakeXid, journalWriter.file(), xfile, storage);

		
	}
}
