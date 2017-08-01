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

import gov.nasa.kepler.fs.server.raf.RandomAccessFileProxy;
import gov.nasa.kepler.fs.server.raf.RandomAccessIo;
import gov.nasa.kepler.fs.server.xfiles.DebugReentrantReadWriteLock;

import java.io.Closeable;
import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;

/**
 * A persistable BitSet similar to java.util.BitSet.  This class is MT-safe.
 * 
 * Unlike other container like classes this does not track the size of the bits
 * in use by a user of this class.  This is done to optimize disk access times.
 * 
 * @author Sean McCauliff
 *
 */
public final class PersistentBitSet implements Closeable {
    /**
     * The minimum amount to expand the vector by each time space 
     * is exhausted.
     */
    private final static int EXPANSION = 1024*4;
    
    private byte[] bitVector;
    private final RandomAccessIo storage;
    private final DebugReentrantReadWriteLock rwLock = new DebugReentrantReadWriteLock();
    
    public PersistentBitSet(File f) throws IOException {
        bitVector = new byte[(int)f.length()];
        this.storage = new RandomAccessFileProxy(new RandomAccessFile(f, "rw"));
        storage.readFully(bitVector);
    }
    
    public PersistentBitSet(RandomAccessIo storage) throws IOException {
        this.storage = storage;
        bitVector = new byte[(int) storage.length()];
        storage.readFully(bitVector);
    }
    
    private int arrayAddress(int bitAddress) {
        return bitAddress >> 3;
    }
    
    private int bitMask(int biti) {
        return  (1 << (biti & 0x00000007));
    }
    
    public int capacityInBytes() {
        return bitVector.length;
    }
    
    /**
     * 
     * @param biti  The index of the bit to get.
     * @return This assume that unallocated bits are false.
     */
    public boolean get(int biti) {
        rwLock.readLock().lock();
        try {
            int arrayAddress = arrayAddress(biti);
            if (arrayAddress >= bitVector.length) {
                return false;
            }
            return ((bitVector[arrayAddress] & 0xff) & bitMask(biti) ) != 0;
        } finally {
            rwLock.readLock().unlock();
        }
    }

    /**
     * Truncates the size to the nearest byte.
     * @param newBitSize
     * @throws IOException
     */
    public void truncate(int newBitSize) throws IOException {
        rwLock.writeLock().lock();
        try {
            int newArraySize = arrayAddress(newBitSize - 1) + 1;
            if (bitVector.length < newArraySize) {
                throw new IllegalArgumentException("Can't grow with truncate().");
            }
            
            if (bitVector.length != newArraySize) {
                byte[] tmp = bitVector;
                bitVector = new byte[newArraySize];
                System.arraycopy(tmp, 0, bitVector, 0, newArraySize);
                storage.setLength(newArraySize);
            }
            
            if (newBitSize > 0) {
                //Clear all the remaining bits at the end of the last byte
                int stopIndex = ( (newBitSize - 1) | 0x07) + 1;
                for (int biti=newBitSize; biti < stopIndex; biti++) {
                    bitVector[arrayAddress(biti)]  &= ~bitMask(biti);
                }
                storage.seek(bitVector.length - 1);
                storage.writeByte(bitVector[bitVector.length - 1]);
            }
        } finally {
            rwLock.writeLock().unlock();
        }
    }
    
    /**
     * Truncates the end of the bitset if it is set to false.
     */
    public void truncateEndIfEmpty() throws IOException {
        rwLock.writeLock().lock();
        try {
            int lastNonEmpty = bitVector.length-1;
            for (; lastNonEmpty >= 0; lastNonEmpty--) {
                if (bitVector[lastNonEmpty] != 0) break;
            }
            
            if (lastNonEmpty == bitVector.length - 1) return;
        
            int newSize = lastNonEmpty + 1;
            byte[] tmp = new byte[newSize];
            System.arraycopy(bitVector, 0, tmp, 0, newSize);
            bitVector = tmp;
            storage.setLength(newSize);
        } finally {
            rwLock.writeLock().unlock();
        }
    }
    
    /**
     * Updates all the specified indices and then writes the update to
     * disk. Unlike set() all these indices must exist.
     * 
     * @param bitIndex 
     * @param newState
     * @throws IOException
     */
    public void update(Collection<Integer> bitIndex, boolean newState) throws IOException {
        rwLock.writeLock().lock();
        try {
            for (int biti : bitIndex) {
                int ai = arrayAddress(biti);
                int newByte = bitVector[ai] & 0xff;
                if (newState) {
                    newByte |= bitMask(biti);
                } else {
                    newByte &= ~bitMask(biti);
                }
                bitVector[ai] = (byte) newByte;
            }
            storage.seek(0);
            storage.write(bitVector);
        } finally {
            rwLock.writeLock().unlock();
        }
    }
    
    /**
     * Collect all the indices in the specified state.
     * @param currentState
     * @return
     */
    public List<Integer> allIndex(boolean currentState) {
        rwLock.readLock().lock();
        try {
            List<Integer> rv = new ArrayList<Integer>();
            int maxBit = bitVector.length << 3;
            for (int biti=0; biti < maxBit; biti++) {
                int ai = arrayAddress(biti);
                if (((bitVector[ai] & bitMask(biti)) != 0) ^ !currentState) {
                    rv.add(biti);
                }
            }
            
            return rv;
        } finally {
            rwLock.readLock().unlock();
        }
    }
    
    /**
     * Makes sure that sufficient capacity exists.  If this extends the size of the
     * array then it will be zero filled. This is useful way to add new elements
     * that have been set to the default value.
     *@param newBitSize The number of bits (at least) that the bit set must
     *hold.
     * @throws IOException 
     */
    public void ensureSpace(int newBitSize) throws IOException {
        rwLock.writeLock().lock();
        try {
            if (arrayAddress(newBitSize -1 ) < bitVector.length) {
                return;
            }
            
            int ai = arrayAddress(newBitSize - 1);
            int sizeDiff = Math.max(EXPANSION, ai - bitVector.length + 1);
            byte[] tmp = bitVector;
            bitVector = new byte[tmp.length + sizeDiff];
            System.arraycopy(tmp,0,bitVector,0,tmp.length);
            //Expand file and clear bits in the file.
            storage.seek(tmp.length);
            storage.write(new byte[sizeDiff]);
        } finally {
            rwLock.writeLock().unlock();
        }
    }
    

    /**
     * Writes this update into storage.
     * @param biti The index of the bit to set.
     * @param newState
     */
    public void set(int biti, boolean newState) throws IOException {
        rwLock.writeLock().lock();
        try {
            int ai = arrayAddress(biti);
            ensureSpace(biti + 1);
            
            storage.seek(ai);
            int newByte = bitVector[ai] & 0xff;
            if (newState) {
                newByte |= bitMask(biti);
            } else {
                newByte &= ~bitMask(biti);
            }
            bitVector[ai] = (byte) newByte;
            storage.write(newByte);
        } finally {
            rwLock.writeLock().unlock();
        }
    }
    
    /**
     * Saves the current state of the bit vector.
     *
     */
    public void close() throws IOException {
        rwLock.writeLock().lock();
        try {
            storage.close();
        } finally {
            rwLock.writeLock().unlock();
        }
    }
    
    /**
     * Locate an empty spot in the bitset.
     * @param startFrom
     * @return if not found then this returns an address over the end of the
     * current bitset.
     */
    public int findNextFalse(int startFrom) {
        rwLock.readLock().lock();
        try {
            for (int i=startFrom>>3; i < bitVector.length; i++) {
                if (bitVector[i] == (byte)-1) {
                    continue;
                }
                
                int biti=0;
                for (; biti < 8; biti++) {
                    if ( ((bitVector[i] & 0xFF) & bitMask(biti)) ==0){
                        break;
                    }
                }
                
                int index = ( i << 3)  + biti;
                if (index < startFrom) {
                    continue;
                }
                return index;
            }
        
            return bitVector.length << 3;
        } finally {
            rwLock.readLock().unlock();
        }
    }
    
    /**
     * This may not see a consistent view of the bit vector.
     */
    @Override
    public boolean equals(Object o) {
        if (!(o instanceof PersistentBitSet)) {
            return false;
        }
        
        PersistentBitSet other = (PersistentBitSet) o;
        return Arrays.equals(this.bitVector, other.bitVector);
    }
    
    /**
     * This may not see a consistent view of the bit vector.
     */
    @Override
    public int hashCode() {
        return Arrays.hashCode(bitVector);
    }
    
}
