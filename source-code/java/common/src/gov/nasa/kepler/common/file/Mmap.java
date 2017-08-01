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

package gov.nasa.kepler.common.file;

import java.io.Closeable;
import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

/**
 * This is a re-implementation of memory mapped files for Java.  The goals of
 * this implementation are greater robustness compared with JDK memory maps,
 * ability to unmap a file, multithreaded access to the mapped region,
 * automatic expansion of the mmap region and mmaps greater than 2GiB of address
 * space.
 * 
 * @author Sean McCauliff
 *
 */
public class Mmap implements Closeable {

    private static final long INITIAL_FILE_SIZE = 1024*1024L;
    private static final long INCREMENT_SIZE = 1024L*1024*512;
    private static final class NativeInfo {
        private final long mmapAddress;
        private final long fileMappingPtr;
        private final long mappedRegionPtr;
        public NativeInfo(long mmapAddress, long fileMappingPtr,
            long mappedRegionPtr) {
            super();
            this.mmapAddress = mmapAddress;
            this.fileMappingPtr = fileMappingPtr;
            this.mappedRegionPtr = mappedRegionPtr;
        }
        
    }
    
    private NativeInfo mmapNativeInfo;
    /**
     * This protects the mapping itself, not the actual data that is mapped.
     */
    private ReadWriteLock rwLock = new ReentrantReadWriteLock();
    private File mappedFile;
    
    private static void initializeFileWithSize(File f, long size) throws IOException {
        if (f.exists() && f.length() >= size) {
            return;
        }
        if (size <= 0) {
            throw new IllegalArgumentException("Can't create mmap of zero of negative size.");
        }
        RandomAccessFile raf = new RandomAccessFile(f, "rw");
        try {
            raf.seek(size - 1);
            raf.write(0);
        } finally {
            raf.close();
        }
    }
    
    public Mmap(File mappedFile) throws IOException {
        this.mappedFile = mappedFile;
        if (!mappedFile.exists()) {
            initializeFileWithSize(mappedFile, INITIAL_FILE_SIZE);
        }
    }
    /**
     * Create the file mapping or create a new mapping discarding the old 
     * mapping.
     * 
     * @throws InterruptedException
     */
    public void mmap(long newSize) throws InterruptedException, IOException {
        rwLock.writeLock().lockInterruptibly();
        try {
            if (mmapNativeInfo != null) {
                close();
            }
            initializeFileWithSize(mappedFile, newSize);
            mmapNativeInfo = nativeMap(mappedFile.getAbsolutePath(), newSize);
        }  finally {
            rwLock.writeLock().unlock();
        }
    }
    
    private native NativeInfo nativeMap(String absoluteMap, long mapSize);
    
    /**
     * Maps the entire file.
     * @throws InterruptedException
     * @throws IOException
     */
    public void mmap() throws InterruptedException, IOException  {
       mmap(mappedFile.length());
    }
    
    /**
     * This immediately unmaps the file.  Subsequent operations on this mmap 
     * will fail.
     * @throws IOException
     */
    @Override
    public void close() throws IOException {
        //TODO: implement me
    }

}
