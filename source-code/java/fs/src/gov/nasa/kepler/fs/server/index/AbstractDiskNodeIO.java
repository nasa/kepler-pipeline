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

package gov.nasa.kepler.fs.server.index;
import gov.nasa.kepler.io.DataInputStream;
import gov.nasa.kepler.io.DataOutputStream;

import gov.nasa.kepler.fs.server.nc.NonContiguousInputStream;
import gov.nasa.kepler.fs.server.nc.NonContiguousOutputStream;
import gov.nasa.kepler.fs.server.raf.RandomAccessIo;
import gov.nasa.kepler.fs.server.xfiles.DebugReentrantReadWriteLock;
import gov.nasa.spiffy.common.collect.Cache;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.util.*;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author Sean McCauliff
 *
 */
public abstract class AbstractDiskNodeIO<K,V, T extends TreeNode<K,V>> 
    implements NodeIO<K, V, T> {

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(AbstractDiskNodeIO.class);
    
    /**
     * Addresses that have been allocated, but do not yet have nodes. 
     */
    private final Set<Long> allocatedAddresses = new HashSet<Long>();
    /**
     * Outstanding IO operations for the current Btree transaction.
     */
    protected final SortedMap<Long, IOOp> ioOps = new TreeMap<Long, IOOp>();
    
    /**
     * Start looking for new unallocated addresses from this address.
     */
    private long searchFromHere = -1;
    
    private final KeyValueIO<K, V> kvio;
    
    protected final int nodeSize;
    
    private final Cache<CacheNodeKey, T> nodeCache;
    
    private final TreeNodeFactory<K, V, T> nodeFactory;

    protected final DebugReentrantReadWriteLock rwLock = 
        new DebugReentrantReadWriteLock();
    
    protected AbstractDiskNodeIO(KeyValueIO<K, V> kvio, int nodeSize,
        Cache<CacheNodeKey, T> nodeCache,
        TreeNodeFactory<K,V,T> nodeFactory) {

        this.kvio = kvio;
        this.nodeSize = nodeSize;
        this.nodeCache = nodeCache;
        this.nodeFactory = nodeFactory;
        searchFromHere = nodeSize * 2L;
    }

    protected abstract RandomAccessIo storage();
    
    protected abstract PersistentBitSet allocatedBitSet();
    
    protected abstract Object treeId();
    
    protected abstract void incrementCacheHit();
    
    protected abstract void incrementCacheMiss();
    
    
    /**
     * @exception NoSuchElementException if there is an attempt to access
     * a node that does not exist.
     */
    public T readNode(long nodesFileAddress) throws IOException {
        T node = readNode(nodesFileAddress, false);
        if (node != null) {
            return node;
        }
        return readNode(nodesFileAddress, true);
    }
    
    /**
     * @param writeOK  When this is true it will try to acquire the writeLock()
     * and modify internal data structures.  Try calling this method with this
     * flag set to false first and then call with true.
     * @return This will only return null if writeOK is false.
     * @exception NoSuchElementException if there is an attempt to access
     * a node that does not exist and writeOK is true.
     */
    private T readNode(long nodesFileAddress, final boolean writeOK) 
        throws IOException {
        
        if (writeOK) {
            rwLock.writeLock().lock();
        } else {
            rwLock.readLock().lock();
        }
        
        try {
            if (allocatedAddresses.contains(nodesFileAddress)) {
                throw new NoSuchElementException("Can't read allocated, but " +
                        "unwritten node with address " + nodesFileAddress + ".");
            }
            
            
            IOOp ioop = ioOps.get(nodesFileAddress);
            if (ioop == null) {
                if (!isNodeAllocated(nodesFileAddress)) {
                    throw new NoSuchElementException("Node with address " +
                        nodesFileAddress + " is not allocated.");
                }
               
                CacheNodeKey nodeKey = new CacheNodeKey(treeId(), nodesFileAddress);
                T rv = nodeCache.get(nodeKey);
                if (rv != null) {
                    incrementCacheHit();
                    return rv;
                }
                if (writeOK) {
                    incrementCacheMiss();
                    
                    storage().seek(nodesFileAddress);
                    BufferedInputStream bin =
                        new BufferedInputStream(new NonContiguousInputStream(storage(), true), nodeSize);
                    DataInputStream din = new DataInputStream(bin);
        
                    rv = nodeFactory.read(nodesFileAddress, din, this);
                    nodeCache.put(nodeKey, rv);
                    return rv;
                } 
                return null;
            } else if (ioop.type() == IOOpType.WRITE) {
                return ((WriteOp) ioop).node;
            } else if (ioop.type() == IOOpType.DELETE) {
                throw new NoSuchElementException("Attempt to read deleted node" +
                        " with address " + nodesFileAddress + ".");
            } else {
                throw new IllegalStateException("Unknown IOOp type.");
            }
        } finally {
            if (writeOK) {
                rwLock.writeLock().unlock();
            } else {
                rwLock.readLock().unlock();
            }
        }
    }

    /**
     */
    @Override
    public void deleteNode(T deleteMe) throws IOException {
        rwLock.writeLock().lock();
        try {
            if (allocatedAddresses.contains(deleteMe.address())) {
                allocatedAddresses.remove(deleteMe.address());
                return;
            }
            
            IOOp ioop = ioOps.get(deleteMe.address());
            if (ioop == null || ioop.type() == IOOpType.WRITE) {
                ioOps.put(deleteMe.address(), new DeleteOp(deleteMe.address()));
            } else if (ioop.type() == IOOpType.DELETE ) {
                //strange, but ok
            } else {
                throw new IllegalStateException("Unknown op type.");
            }
        } finally {
            rwLock.writeLock().unlock();
        }
    }

    public KeyValueIO<K,V> keyValueIO() {
        return kvio;
    }
   
    /**
     * This is useful for debugging.
     * @return A string describing the outstanding file operations.
     */
    public String describeOps() {
        StringBuilder bldr = new StringBuilder();
        rwLock.readLock().lock();
        try {
            for (Map.Entry<Long, IOOp> entry : this.ioOps.entrySet()) {
                bldr.append(entry.getKey()).append(" -- ").append(entry.getValue()).append("\n");
            }
        } finally {
            rwLock.readLock().unlock();
        }
        return bldr.toString();
    }
    
    @Override
    public void writeNode(T node) throws IOException {
        rwLock.writeLock().lock();
        try {
            IOOp ioop = ioOps.get(node.address());
            if (ioop == null) {
                boolean allocated = false;
                if (allocatedAddresses.contains(node.address())) {
                    allocatedAddresses.remove(node.address());
                    allocated = true;
                }
                ioOps.put(node.address(), new WriteOp(node, allocated));
                incrementCacheMiss();
            } else if (ioop.type() == IOOpType.DELETE) {
                throw new IllegalStateException("Attempt to write to deleted node " +
                        "with address " + node.address() + ".");
            } else if (ioop.type() == IOOpType.WRITE) {
                //update cached copy
                WriteOp previousOp = (WriteOp) ioop;
                ioOps.put(node.address(), new WriteOp(node, previousOp.allocate));
                incrementCacheHit();
            } else {
                throw new IllegalStateException("Unknown IOOp type.");
            }
        } finally {
            rwLock.writeLock().unlock();
        }
    }
    
    private boolean isNodeAllocated(long nodesFileAddress) throws IOException {
        int nodeAddress = fileAddressToNodeAddress(nodesFileAddress);
        if (!allocatedBitSet().get(nodeAddress)) {
            return false;
        }
        return true;
    }
    
    /**
     * 
     * @param nodesFileAddress  0 being the first node, 1 the second and
     * so on.
     * @return
     */
    private int fileAddressToNodeAddress(long nodesFileAddress) {
        return (int) ((nodesFileAddress - nodeSize) / nodeSize);
    }
    
    private long nodeAddressToFileAddress(int nodeAddress) {
        return (long) (nodeAddress+1) * (long) nodeSize;
    }
    
    /**
     * The addresses returned by this will always be increasing until
     * commit() is called.  This avoids having to track where new holes
     * may have opened up if an allocated node is ever deleted.
     */
    public long allocateAddress() throws IOException {
        rwLock.writeLock().lock();
        try {
            long rv = -1;
            long fileLength = storage().length();
            if (searchFromHere >= fileLength) {
                //Already allocated blocks at the end of the file.
                rv = searchFromHere;
                searchFromHere += nodeSize;
            } else {
                    
                int nodeIndex = fileAddressToNodeAddress(searchFromHere);
                int nextAddress = allocatedBitSet().findNextFalse(nodeIndex);
                //Found empty spot.
                rv = nodeAddressToFileAddress(nextAddress);
                searchFromHere  = rv + nodeSize;
            }
            
            //Sanity checks.
            if (allocatedAddresses.contains(rv) || ioOps.containsKey(rv)) {
                throw new IllegalStateException("Attempt to allocate address " + rv
                    +"that has already been allocated ");
            }
            
            allocatedAddresses.add(rv);
            return rv;
        } finally {
            rwLock.writeLock().unlock();
        }

    }

    /**
     * the root node's address is the first valid address, that is nodeSize.
     */
    public long rootNodeAddress() throws IOException {
        long addr = rootNodeAddress(false);
        if (addr != -1L) {
            return addr;
        }
        return rootNodeAddress(true);
    }
    
    protected long currentRootNodeAddress() {
        return nodeSize;
    }
    
    private long rootNodeAddress(boolean writeOK) throws IOException {
        if (writeOK) {
            rwLock.writeLock().lock();
        } else {
            rwLock.readLock().lock();
        }
        
        try {
            Long currentRootNodeAddress = Long.valueOf(currentRootNodeAddress());
            if (isNodeAllocated(currentRootNodeAddress)) {
                return currentRootNodeAddress;
            }
            
            if (allocatedAddresses.contains(currentRootNodeAddress)) {
                return currentRootNodeAddress;
            }
            
            if (ioOps.containsKey(currentRootNodeAddress)) {
                return currentRootNodeAddress;
            }
            
            if (writeOK) {
                allocatedAddresses.add(currentRootNodeAddress);
                return currentRootNodeAddress;
            }
            return -1L;
        } finally {
            if (writeOK) {
                rwLock.writeLock().unlock();
            } else {
                rwLock.readLock().unlock();
            }
        }
    }
    
   protected void clearDirtyState() {
       searchFromHere = nodeSize * 2L;
       ioOps.clear();
       allocatedAddresses.clear();
   }
   
   protected void executeOpFromJournal(DataInput din) throws IOException {
       do {
           int opType = din.readInt();
           if (opType == IOOpType.JOURNAL_END.ordinal()) {
               break;
           } else if (IOOpType.WRITE.ordinal() == opType) {
               WriteOp writeOp = readWriteOpFromJournal(din);
               writeOp.doOp();
           } else if (IOOpType.DELETE.ordinal() == opType) {
               DeleteOp deleteOp = readDeleteFromJournal(din);
               deleteOp.doOp();
           } else if (IOOpType.ROOT_NODE_ADDRESS_CHANGE.ordinal() == opType) {
               RootNodeAddressChangedOp rootOp = readRootChangeFromJournal(din);
               rootOp.doOp();
           } else {
               throw new IllegalStateException("Unknown opType " + opType + ".");
           }
       } while (true);
   }
   
   private WriteOp readWriteOpFromJournal(DataInput din) throws IOException {
       boolean allocate = din.readBoolean();
       long nodeAddress = din.readLong();

       T node = nodeFactory.read(nodeAddress, din, this);
       return new WriteOp(node, allocate);
   }
   
    private DeleteOp readDeleteFromJournal(DataInput din) throws IOException {
        long deleteAddress = din.readLong();
        return new DeleteOp(deleteAddress);
    }
       
    protected RootNodeAddressChangedOp readRootChangeFromJournal(DataInput din) throws IOException {
        long rootNodeAddressAddress = din.readLong();
        long oldAddress = din.readLong();
        long newAddress = din.readLong();
        return new RootNodeAddressChangedOp(rootNodeAddressAddress, oldAddress, newAddress);
    }
    
    protected SortedMap<Long, IOOp> ioOps() {
       return Collections.unmodifiableSortedMap(ioOps);
    }
    
    
    
    public enum IOOpType {
        DELETE, WRITE, JOURNAL_END, ROOT_NODE_ADDRESS_CHANGE;
    }

    protected abstract class IOOp {
        abstract IOOpType type();
        
        /** Makes changes to the btree file. */
        public abstract void doOp() throws IOException;
        
        /**  Writes the changes it would have made into the journal file. */
        public abstract void writeToJournal(DataOutput journalWriter) throws IOException;
    }
    
    protected class RootNodeAddressChangedOp extends IOOp {
        final long rootNodeAddressAddress;
        final long oldAddress; //this is just here for debugging
        final long newAddress;

        RootNodeAddressChangedOp(long rootNodeAddressAddress, 
            long oldAddress, long newAddress) {
            this.rootNodeAddressAddress = rootNodeAddressAddress;
            this.oldAddress = oldAddress;
            this.newAddress = newAddress;
        }
        
        @Override
        IOOpType type() {
            return IOOpType.ROOT_NODE_ADDRESS_CHANGE;
        }

        @Override
        public void doOp() throws IOException {
            RandomAccessIo raf = storage();
            raf.seek(rootNodeAddressAddress);
            raf.writeLong(newAddress);
        }

        @Override
        public void writeToJournal(DataOutput journalWriter) throws IOException {
            journalWriter.writeInt(type().ordinal());
            journalWriter.writeLong(rootNodeAddressAddress);
            journalWriter.writeLong(oldAddress);
            journalWriter.writeLong(newAddress);
        }

    }
    
    protected class WriteOp extends IOOp {
        final T node;
        final boolean allocate;
        
        WriteOp(T node, boolean allocate) {
            this.node = node;
            this.allocate = allocate;
            
        }
        
        @Override
        IOOpType type() { return IOOpType.WRITE; }
        
        @Override
        public void doOp() throws IOException {
            storage().seek(node.address());
            DataOutputStream dout = 
                new DataOutputStream(new BufferedOutputStream(new NonContiguousOutputStream(storage(), true), nodeSize));
            node.write(dout, kvio);
            dout.flush();
            dout.close();
            CacheNodeKey nodeKey = new CacheNodeKey(treeId(), node.address());
            nodeCache.put(nodeKey, node);
            if (allocate) {
                allocatedBitSet().set(fileAddressToNodeAddress(node.address()), true);
            }
        }
        
        @Override
        public void writeToJournal(DataOutput journalWriter) throws IOException {
            journalWriter.writeInt(type().ordinal());
            journalWriter.writeBoolean(allocate);
            journalWriter.writeLong(node.address());
            node.write(journalWriter, kvio);
        }
        
        @Override
        public String toString() {
            return "Write " + node.address() + " nKeys " + node.nKeys();// + " nchildren " + node.childAddresses.size();
        }
    }

    protected class DeleteOp extends IOOp {
        final long deleteAddress;
       
        DeleteOp(long deleteAddress) {
            this.deleteAddress = deleteAddress;
        }
        
        @Override
        IOOpType type() { return IOOpType.DELETE; }
        
        @Override
        public void doOp() throws IOException {
            allocatedBitSet().set(fileAddressToNodeAddress(deleteAddress), false);
            allocatedBitSet().truncateEndIfEmpty();
            CacheNodeKey nodeKey = new CacheNodeKey(treeId(), deleteAddress);
            nodeCache.remove(nodeKey);
            //This may actually increase the file size to align with node capacity boundary
            long expectedFileSize = nodeAddressToFileAddress(allocatedBitSet().capacityInBytes()*8);
            if (expectedFileSize != storage().length()) {
                storage().setLength(expectedFileSize);
            }
        }
        
        @Override
        public void writeToJournal(DataOutput journalWriter) throws IOException {
            journalWriter.writeInt(type().ordinal());
            journalWriter.writeLong(deleteAddress);
        }
        
        @Override
        public String toString() {
            return "Delete " + deleteAddress;
        }
    }
    
    
    public static final class CacheNodeKey {
        private final Object btreeId;
        private final long nodeAddress;

        CacheNodeKey(Object btreeId, long nodeAddress) {
            if (btreeId == null) {
                throw new NullPointerException("btreeId must not be null.");
            }
            this.btreeId = btreeId;
            this.nodeAddress = nodeAddress;
        }

        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime * result
                + ((btreeId == null) ? 0 : btreeId.hashCode());
            result = prime * result
                + (int) (nodeAddress ^ (nodeAddress >>> 32));
            return result;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj)
                return true;
            if (obj == null)
                return false;
            if (getClass() != obj.getClass())
                return false;
            final CacheNodeKey other = (CacheNodeKey) obj;
            if (btreeId == null) {
                if (other.btreeId != null)
                    return false;
            } else if (!btreeId.equals(other.btreeId))
                return false;
            if (nodeAddress != other.nodeAddress)
                return false;
            return true;
        }

    }
}
