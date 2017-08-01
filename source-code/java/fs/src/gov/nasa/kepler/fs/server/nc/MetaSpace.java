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

package gov.nasa.kepler.fs.server.nc;

/**
 * Represents the space reserved for use by metadata.  Every 1MiBytes it
 * reserves 4KiBytes of space for growth.  The header used by the
 * TransactionalRandomAccessFile is rolled into the first block used.
 * 
 * <pre>
 *  |----------- meta + normal data ----------------------------------|
 *   |||||
 *   header(opt) 
 *   ||||||||||||||||
 *   meta data block
 *                   |||||||||||||||||||||||||||||||||||||||||||||||||
 *                   Normal data
 *  </pre>
 *                 
 *  This object is stateless and MT safe.
 *  
 * @author Sean McCauliff
 *
 */
public class MetaSpace implements ReservedAddressSpace {
    private final long headerSize;
    private final boolean metaReserved;
    
    /** How much space is allocated at a time for metadata. */
    static final long BLOCK_SIZE = 1024*4;
    
    /** How much unallocated space between allocated blocks. */
    static final long BLOCK_SPACING = 1024*1024;
    
    static final long USED_PLUS_UNUSED = BLOCK_SIZE + BLOCK_SPACING;
    
    /**
     * 
     * @param headerSize The number of bytes initially used by 
     * TransactionalRandomAccessFile
     * @param metaReserved When true this reserves space for metaData as opposed
     * to actual data.
     */
    public MetaSpace(long headerSize, boolean metaReserved) {
        this.headerSize = headerSize;
        this.metaReserved = metaReserved;
        if (headerSize >= BLOCK_SIZE) {
            throw new IllegalArgumentException("Header too large.  "+
                    "Adjust BLOCK_SIZE or make header smaller.");
        }
    }
    
    /** 
     * @see gov.nasa.kepler.fs.server.nc.ReservedAddressSpace#isUsed(long)
     */
    public boolean isUsed(final long addr) {
        
        long unusedSpaceOffset = addr % USED_PLUS_UNUSED;
        if (unusedSpaceOffset < BLOCK_SIZE) {
            if (!metaReserved && addr < headerSize) {
                return true;
            }
            return metaReserved;
        } else {
            return !metaReserved;
        }
    }

    /**
     * @see gov.nasa.kepler.fs.server.nc.ReservedAddressSpace#nextUnusedAddress(long)
     */
    public long nextUnusedAddress(final long start) {
     
        long unusedSpaceOffset = start % USED_PLUS_UNUSED;  
        
        if (!metaReserved && start < headerSize) {
            return headerSize;
        }
        
        //Note that if we make the assumption that USED_PLUS_UNUSED was a power of
        //two then we could use faster operations that '/', '%', and '*'
        if (!metaReserved) {
            //Calculate the next place to put metadata
            if (unusedSpaceOffset < BLOCK_SIZE) {
                return (start / USED_PLUS_UNUSED) * USED_PLUS_UNUSED + BLOCK_SIZE -1;
            } else {
                return (start / USED_PLUS_UNUSED + 1) * USED_PLUS_UNUSED; 
            }
        } else {
            //Calculate the next place to put normal data
            if (unusedSpaceOffset < BLOCK_SIZE) {
                return (start / USED_PLUS_UNUSED) * USED_PLUS_UNUSED + BLOCK_SIZE;
            } else {
                return (start / USED_PLUS_UNUSED+1) * USED_PLUS_UNUSED - 1;
            }
        }
        
    }
    
    /**
     * @see gov.nasa.kepler.fs.server.nc.ReservedAddressSpace#xlateAddress(long)
     */
    public long xlateAddress(final long start) {
        if (metaReserved) {
            long skipSpaceBlocks = start / BLOCK_SPACING;
            return BLOCK_SPACING * skipSpaceBlocks + BLOCK_SIZE * (skipSpaceBlocks + 1) + (start %  BLOCK_SPACING);
        } else {
            long skipBlocks = (start + headerSize) / BLOCK_SIZE;
            return USED_PLUS_UNUSED * skipBlocks + ((start + headerSize) % BLOCK_SIZE);
        }
    }

    public long lastVirtualAddress() {
        //TODO:  fix me.
        return Long.MAX_VALUE;
    }


}
