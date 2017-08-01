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


import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.index.KeyValueIO;
import gov.nasa.kepler.fs.server.scheduler.FsIdLocation;
import gov.nasa.kepler.fs.server.scheduler.FsIdOrder;
import gov.nasa.kepler.fs.storage.LaneAllocator.Allocation;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.File;
import java.io.IOException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * This is used to track the associations between the time series files and
 * their FsIds.
 * 
 * This class is MT-safe.  Do not use "synchronized" to coordinate access with
 * instances of this class.
 * 
 * 
 * @author Sean McCauliff
 *
 */
public class RandomAccessAllocator  extends AbstractStorageAllocator {
    
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(RandomAccessAllocator.class);
    /** container file header size. */
    public static final int HEADER_SIZE = 0;
    private final LaneAllocator dataLaneAllocator;
    private final LaneAllocator  metaLaneAllocator;
    
    public RandomAccessAllocator(DirectoryHash dirHash)
        throws IOException, IllegalArgumentException {
        
        super(dirHash);
        
        dataLaneAllocator = new LaneAllocator(super.sequence, IDS_PER_CONTAINER);
        metaLaneAllocator = new LaneAllocator(super.sequence, IDS_PER_CONTAINER);
    }
    
  
    
    public RandomAccessStorage randomAccessStorage(FsId id)
        throws IOException, InterruptedException {
        
        return randomAccessStorage(id, true);
    }
    
    
    /**
     * Fetches existing storage or allocates new storage for the specified
     * time series.
     * 
     * @param id
     * @param create
     * @return null if it exists and create is false, else returns a storage
     * object which can be used to read and write data.  The backing files
     * for the storage object are lazly created.
     * @throws IOException
     * @throws InterruptedException 
     */
    public RandomAccessStorage randomAccessStorage(FsId id, boolean create) 
        throws IOException, InterruptedException{
        
        
        //If this exists then return the storage
        //else if !create return null
        //else 
        //  allocate lanes
        //  insert into btree index
        //  return storage
        
        RandomAccessFsIdInfo info = null;
        info = (RandomAccessFsIdInfo) super.fsIdToFileName.find(id);
        if (info == null && !create) {
            return null;
        } 

        if (info == null) {
            //create must be true at this point
            Allocation dataAllocation = dataLaneAllocator.allocateLane();
            Allocation metaAllocation = metaLaneAllocator.allocateLane();
            info = new RandomAccessFsIdInfo(dataAllocation.fileNumber, dataAllocation.laneNo,
                metaAllocation.fileNumber, metaAllocation.laneNo, true /* is new */);
            info = (RandomAccessFsIdInfo) fsIdToFileName.insertIfAbsent(id, info);
            btreeChange();
        }
        
        File dataDir = dirHash.directoryForId(Integer.toString(info.dataFileId));
        File metaDir = dirHash.directoryForId(Integer.toString(info.metaFileId));
        
        LaneAddressSpace dataSpace = 
            new LaneAddressSpace(info.dataLane, HEADER_SIZE, IDS_PER_CONTAINER, 
                dataDir, info.dataFileId);
        LaneAddressSpace metaSpace = 
            new LaneAddressSpace(info.metaLane, HEADER_SIZE, IDS_PER_CONTAINER,
                metaDir, info.metaFileId);
        
        RandomAccessStorage storage = createStorage(id, dataSpace, metaSpace, info.isNew());
        return storage;

    }



    protected RandomAccessStorage createStorage(FsId id, LaneAddressSpace dataSpace, LaneAddressSpace metaSpace, boolean isNew) {
        RandomAccessStorage storage = 
            new ContainerFileStorage(id, dataSpace,  metaSpace, this);
        return storage;
    }

    @Override
    protected KeyValueIO<FsId, FsIdInfo> getKeyValueIo() {
        return new RandomAccessKeyValueIo();
    }

    public static final class RandomAccessKeyValueIo extends IndexEncoder {

        @Override
        public FsIdInfo readValue(DataInput din) throws IOException {
            int dataId = din.readInt();
            byte dataLane = din.readByte();
            int metaId = din.readInt();
            byte metaLane = din.readByte();
            boolean isNew = din.readBoolean();
            return new RandomAccessFsIdInfo(dataId, dataLane, metaId, metaLane, isNew);
        }

        @Override
        public int valueSize() {
            return 4 + 1 + 4 + 1 + 1;
        }

        @Override
        public void writeValue(DataOutput dout, FsIdInfo value)
            throws IOException {
            
            RandomAccessFsIdInfo info = (RandomAccessFsIdInfo) value;
            dout.writeInt(info.dataFileId);
            dout.writeByte(info.dataLane);
            dout.writeInt(info.metaFileId);
            dout.writeByte(info.metaLane);
            dout.writeBoolean(info.isNew());
        }
        
    }
   

    /**
     * @throws InterruptedException 
     */
    @Override
    public boolean isAllocated(FsId id) throws IOException, InterruptedException {
        return randomAccessStorage(id, false) != null;
    }

    /**
     * Used by tests to get the actual file the data is stored in.
     * @param id
     * @throws IOException 
     * @throws InterruptedException 
     */
    public File[] testGetActualFiles(FsId id) throws IOException, InterruptedException {
        RandomAccessFsIdInfo info = (RandomAccessFsIdInfo) fsIdToFileName.find(id);
        File dataFile = dirHash.idToFile(Integer.toString(info.dataFileId));
        File metaFile = dirHash.idToFile(Integer.toString(info.metaFileId));
        return new File[] { dataFile, metaFile};
    }


    /**
     * 
     * @return true if the returned storage objects will support getLength() and setLength().
     */
    @Override
    public boolean doesStorageTrackLength() {
        return false;
    }

    @Override
    public FsIdLocation locationFor(FsIdOrder idOrder)
    throws FileStoreException, IOException, InterruptedException {

        RandomAccessFsIdInfo info = (RandomAccessFsIdInfo) 
                                    fsIdToFileName.find(idOrder.id());
        if (info == null) {
            return new FsIdLocation(idOrder.id(), idOrder.originalOrder());
        }
        FsIdLocation loc = 
            new FsIdLocation(info.dataFileId, info.dataLane, 
                idOrder.id(), idOrder.originalOrder());
        return loc;
    }
    
    public static final class RandomAccessFsIdInfo extends FsIdInfo {
        public final int dataFileId;
        public final byte dataLane;
        public final int metaFileId;
        public final byte metaLane;
        
        private RandomAccessFsIdInfo(int dataFileId, byte dataLane, int metaFileId, byte metaLane, boolean newState) {
            super(newState);
            this.dataFileId = dataFileId;
            this.dataLane = dataLane;
            this.metaFileId = metaFileId;
            this.metaLane = metaLane;
        }
        
        @Override
        public int[] fileIds() {
            return new int[] { dataFileId, metaFileId };
        }

        @Override
        public FsIdInfo setNew(boolean newState) {
            return new RandomAccessFsIdInfo(dataFileId, dataLane, metaFileId, metaLane, newState);
        }

        @Override
        public int hashCode() {
            final int prime = 31;
            int result = super.hashCode();
            result = prime * result + dataFileId;
            result = prime * result + dataLane;
            result = prime * result + metaFileId;
            result = prime * result + metaLane;
            return result;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj)
                return true;
            if (!super.equals(obj))
                return false;
            if (!(obj instanceof RandomAccessFsIdInfo))
                return false;
            RandomAccessFsIdInfo other = (RandomAccessFsIdInfo) obj;
            if (dataFileId != other.dataFileId)
                return false;
            if (dataLane != other.dataLane)
                return false;
            if (metaFileId != other.metaFileId)
                return false;
            if (metaLane != other.metaLane)
                return false;
            return true;
        }

        @Override
        public String toString() {
            StringBuilder builder = new StringBuilder();
            builder.append("RandomAccessFsIdInfo [dataFileId=")
                .append(dataFileId)
                .append(", dataLane=")
                .append(dataLane)
                .append(", metaFileId=")
                .append(metaFileId)
                .append(", metaLane=")
                .append(metaLane)
                .append(", isNew()=")
                .append(isNew())
                .append("]");
            return builder.toString();
        }
        
        

    }

}
