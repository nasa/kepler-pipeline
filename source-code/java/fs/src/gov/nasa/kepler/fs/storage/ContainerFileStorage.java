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

package gov.nasa.kepler.fs.storage;

import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.nc.NonContiguousReadWrite;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.Collections;

/**
 * @author Sean McCauliff
 * 
 */
class ContainerFileStorage implements RandomAccessStorage {
    private final FsId id;
    private final StorageAllocatorInterface allocator;
    private final LaneAddressSpace dataSpace;
    private final LaneAddressSpace metaSpace;

    ContainerFileStorage(FsId id,
        LaneAddressSpace dataSpace, 
        LaneAddressSpace metaSpace, StorageAllocatorInterface allocator) {

        this.allocator = allocator;
        this.id = id;
        this.dataSpace = dataSpace;
        this.metaSpace = metaSpace;
    }

    /**
     * @throws InterruptedException 
     * @see gov.nasa.kepler.fs.storage.RandomAccessStorage#cleanUp()
     */
    @Override
    public void cleanUp() throws IOException, InterruptedException {
        allocator.removeId(id);
    }

    /**
     * @see gov.nasa.kepler.fs.storage.RandomAccessStorage#dataRw()
     */
    @Override
    public NonContiguousReadWrite dataRw() throws IOException {

        RandomAccessFile dataRaf = new RandomAccessFile(dataSpace.file(), "rw");
        boolean trackLength = allocator.doesStorageTrackLength();
        NonContiguousReadWrite dataRw = 
            new NonContiguousReadWrite(dataRaf, dataSpace, trackLength, isDataLengthNew());
                                      
        return dataRw;
    }

    /**
     * @throws IOException
     * @throws InterruptedException 
     * @see gov.nasa.kepler.fs.storage.RandomAccessStorage#isNew()
     */
    @Override
    public boolean isNew() throws IOException, InterruptedException {
        return allocator.isNew(id);
    }

    /**
     * @see gov.nasa.kepler.fs.storage.RandomAccessStorage#metaDataRw()
     */
    @Override
    public NonContiguousReadWrite metaDataRw() throws IOException {
        RandomAccessFile metaRaf = new RandomAccessFile(metaSpace.file(), "rw");
        boolean trackLength = allocator.doesStorageTrackLength();
        NonContiguousReadWrite metaDataRw = new NonContiguousReadWrite(
            metaRaf, metaSpace, trackLength, isMetaLengthNew());
        return metaDataRw;
    }

    public FsId fsId() {
        return id;
    }

    @Override
    public void markOld() throws IOException, InterruptedException {
        allocator.markIdsPersistent(Collections.singletonList(id));
    }

    /**
     * @param realDelete removes this file from the index else just sets the new flag.
     * @throws InterruptedException 
     */
    @Override
    public void delete(boolean realDelete) throws IOException, InterruptedException {
        if (realDelete) {
            allocator.removeId(id);
        } else {
            allocator.setNewState(id, true);
        }
    }
    
    protected boolean isDataLengthNew() {
        return false;
    }
    
    protected boolean isMetaLengthNew() {
        return false;
    }

	@Override
	public void initAlreadyDone() {
	}
}
