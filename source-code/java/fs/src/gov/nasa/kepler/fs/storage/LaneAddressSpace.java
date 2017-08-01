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

import gov.nasa.kepler.fs.server.nc.ReservedAddressSpace;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;

import java.io.File;

import static gov.nasa.kepler.fs.FileStoreConstants.*;

/**
 * This is a file that contains other files.  It is not transactional.
 * 
 * Header
 * |||||||
 *          +++++--------!!!!!!!!!******+++++--------!!!!!!!!******  ...etc
 *          Lane0  Lane1 Lane2  Lane3 Lane0  Lane1 Lane2 Lane3 ...etc
 *          ~~~~~~~~~~~~~~~~~~
 *          Super block
 *          
 *  Since LANE_BLOCK_SIZE and the number of lanes must be powers of 2
 *  the address into the file can be broken down into:
 *  ########################^^^^^^^^^^^^
 *  # - super block address
 *  ^ - offset into super block
 *  
 *          
 * File format:
 *  version 1 byte.
 *  nlanes 1 byte
 *  lane 1..n
 *    1 byte allocated / not allocated
 *    98 byte FsId.
 *  remainder of bytes are split between lanes 0..n-1
 *  
 *
 * This class represents the address space on disk for a particular lane in the
 * container file.  This class is MT-safe.
 * 
 * @author Sean McCauliff
 *

 *
 */
public class LaneAddressSpace implements ReservedAddressSpace {
	
    /** This must be a power of 2 */
    static final int LANE_BLOCK_SIZE;
    
    static {
        LANE_BLOCK_SIZE = 
            ConfigurationServiceFactory.getInstance().getInt(
                FS_SERVER_STORAGE_BLOCK_SIZE,
                FS_SERVER_STORAGE_BLOCK_SIZE_DEFAULT);
    }
    
    private final long superBlockSize;
    
    /** Doing a bit-wise and vs an address will yield the offset into that
     * super block.
     */
    private final long superBlockSizeMask;
    
    /** The first physical address holding data for this lane. */
    private final long firstBlock;
    
    private final File fileDir;
    
    private final int laneNo;
    private final int fileId;
    
    public LaneAddressSpace(int laneNo, int headerSize, int nLanes, 
        File directory, int fileId) {
        this.superBlockSize = nLanes * LANE_BLOCK_SIZE;
        this.superBlockSizeMask = superBlockSize - 1;
        this.firstBlock = headerSize + laneNo * LANE_BLOCK_SIZE;
        this.fileDir = directory;
        this.laneNo = laneNo;
        this.fileId = fileId;
    }
    
    @Override
    public boolean isUsed(long addr) {
        //The first place that this lane can write into.
        if ( addr  < firstBlock) {
            return true;
        }
      
        addr -= firstBlock;
        
        long offsetIntoSuperBlock = addr & superBlockSizeMask;
        return offsetIntoSuperBlock >= LANE_BLOCK_SIZE;
    }

    @Override
    public long nextUnusedAddress(long addr) {
        if ( addr < firstBlock) {
            return firstBlock;
        }
      
        addr -= firstBlock;
        
        long offsetIntoSuperBlock = addr & superBlockSizeMask;
        long startOfAddrSuperBlock = addr & (~superBlockSizeMask);
        if (offsetIntoSuperBlock < LANE_BLOCK_SIZE) {
            //return the end of the lane addr is pointed into
            return startOfAddrSuperBlock + (LANE_BLOCK_SIZE - 1) + firstBlock;
        }
        
        //return the start of the next block
        return startOfAddrSuperBlock + superBlockSize + firstBlock;
      
    }

    @Override
    public long xlateAddress(long virtualAddress) {
        long blockNo = virtualAddress / LANE_BLOCK_SIZE;
        long offsetIntoBlock = virtualAddress & (LANE_BLOCK_SIZE - 1);
        return blockNo * superBlockSize + offsetIntoBlock + firstBlock;
    }
    
    @Override
    public long lastVirtualAddress() {
        long lastPhysicalAddress = file().length() - this.firstBlock;
        if (lastPhysicalAddress <= 0) {
            return 0;
        }
        long superBlockNo = lastPhysicalAddress / superBlockSize;
        long offsetIntoSuperBlock = lastPhysicalAddress & superBlockSizeMask;
        
        if (offsetIntoSuperBlock < LANE_BLOCK_SIZE) {
            //Return the address in the super block
            return superBlockNo * LANE_BLOCK_SIZE + offsetIntoSuperBlock;
        } else {
            return (superBlockNo+1) * LANE_BLOCK_SIZE;
        }
    }
    
    /**
     * The lane number used by a particular FsId.
     * @return
     */
    int laneNo() {
        return laneNo;
    }
    
    public File file() {
        return new File(this.fileDir, DirectoryHash.toFileName(Integer.toString(fileId)));
    }
    
}

