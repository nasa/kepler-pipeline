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

import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.nc.NonContiguousReadWrite;
import gov.nasa.kepler.fs.storage.LaneAddressSpace;
import gov.nasa.kepler.fs.storage.RandomAccessStorage;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;

/**
 * Useful for testing classes that need an implementation of RandomAccessStorage.
 * @author Sean McCauliff
 *
 */
public final class DefaultStorage implements RandomAccessStorage {

    private final File dataFile;
    private final LaneAddressSpace metaSpace;
    private final LaneAddressSpace dataSpace;
    private boolean isNew;
    private boolean isMetaLengthNew;
    private boolean isDataLengthNew;
    private final FsId id;
    private final boolean storeLength;

    DefaultStorage(File targetFile, FsId id) {
        this(targetFile, id, false, true);
    }
    
    public DefaultStorage(File targetFile, FsId id, boolean storeLength, boolean isNew) {
        this.dataFile = targetFile;
        this.isNew = isNew;
        this.id = id;
        this.storeLength = storeLength;
        this.isMetaLengthNew = (storeLength) ? isNew : false;
        this.isDataLengthNew = isMetaLengthNew;
        
        metaSpace = new AnyFileLaneAddressSpace(0, 13, 2, targetFile);
        dataSpace = new AnyFileLaneAddressSpace(1, 13, 2, targetFile);
    }

    void setNew(boolean newness) {
        this.isNew = newness;
    }

    public void cleanUp() {
        dataFile.delete();
    }

    public NonContiguousReadWrite dataRw() throws IOException {
        RandomAccessFile raf = new RandomAccessFile(dataFile, "rw");
        NonContiguousReadWrite data = 
            new NonContiguousReadWrite(raf, dataSpace, storeLength, isDataLengthNew);
        isDataLengthNew = false;
        return data;
    }

    public boolean isNew() {
        return isNew;
    }

    public NonContiguousReadWrite metaDataRw() throws IOException {
        RandomAccessFile raf = new RandomAccessFile(dataFile, "rw");
        NonContiguousReadWrite meta = 
            new NonContiguousReadWrite(raf, metaSpace, storeLength, isMetaLengthNew);
        isMetaLengthNew = false;
        return meta;
    }

    public FsId fsId() {
        return id;
    }

    @Override
    public void markOld() throws IOException {
        isNew = false;
    }

    @Override
    public void delete(boolean realDelete) throws IOException {
        if (realDelete) {
            dataFile.delete();
        } else {
            isNew = true;
        }
    }
    
    private static class AnyFileLaneAddressSpace extends LaneAddressSpace {
        private final File testFile;
        
        AnyFileLaneAddressSpace(int laneNo, int headerSize, int nLanes, File testFile) {
            super(laneNo, headerSize, nLanes, null, -1);
            this.testFile = testFile;
        }
        
        @Override
        public File file() {
            return testFile;
        }
    }

    @Override
    public void initAlreadyDone() {
        isMetaLengthNew = false;
        isDataLengthNew = false;
    }
}
