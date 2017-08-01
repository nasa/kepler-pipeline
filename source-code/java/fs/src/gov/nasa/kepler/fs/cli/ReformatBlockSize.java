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

package gov.nasa.kepler.fs.cli;

import gov.nasa.kepler.common.file.SparseFileUtil;
import gov.nasa.kepler.fs.server.nc.NonContiguousInputStream;
import gov.nasa.kepler.fs.server.raf.RandomAccessFileProxy;
import gov.nasa.kepler.io.DataInputStream;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.List;

import org.apache.commons.io.input.CloseShieldInputStream;

import static gov.nasa.spiffy.common.lang.MathUtils.log2;

/**
 * Changes the block size of the TransactionalRandomAccessFile and the 
 * TransactionalMjdTimeSeriesFile
 * 
 * @author Sean McCauliff
 *
 */
public class ReformatBlockSize {
    
    private final static int OLD_BLOCK_SIZE = 1024 * 8;
    private final static int OLD_BLOCK_SIZE_BIT_SHIFT = log2(OLD_BLOCK_SIZE) - 1;
    private final static long OLD_HIGH_BITS_MASK = -1L << OLD_BLOCK_SIZE_BIT_SHIFT;
    private final static int NEW_BLOCK_SIZE = OLD_BLOCK_SIZE * 4;
    private final static int N_IDS_PER_FILE = 128;
    private final static int N_IDS_PER_FILE_BIT_SHIFT = log2(N_IDS_PER_FILE) - 1;
    private final static int OLD_LANE_NO_MASK = 1 << N_IDS_PER_FILE_BIT_SHIFT; 
    private final static int NEW_SUPERBLOCK_SIZE = NEW_BLOCK_SIZE * N_IDS_PER_FILE;
    
    private final static AddressSpaceTranslator xlator = 
        new AddressSpaceTranslator();
    
    
    void reformat(File srcFile, File destFile) throws IOException {
        SparseFileUtil sparseFileUtil = new SparseFileUtil();
        RandomAccessFile srcRaf = null;
       
        RandomAccessFile destRaf = null;
        
        try {
            srcRaf =  new RandomAccessFile(srcFile, "r");
            destRaf = new RandomAccessFile(destFile, "rw");
            long srcFileLength = srcFile.length();
            byte[] buf = new byte[OLD_BLOCK_SIZE];
            List<SimpleInterval> srcExtents = sparseFileUtil.extents(srcFile);
            for (SimpleInterval srcExtent : srcExtents) {
                writeSrcExtent(srcRaf, destRaf, srcFileLength, buf, srcExtent);
            }
        } finally {
            FileUtil.close(srcRaf);
            FileUtil.close(destRaf);
        }
    }

    private void writeSrcExtent(RandomAccessFile srcRaf,
            RandomAccessFile destRaf, long srcFileLength, byte[] buf,
            SimpleInterval srcExtent) throws IOException {
        //This makes sure we start at the beginning of a block boundary.
        long srcExtentStartAddress = srcExtent.start() & OLD_HIGH_BITS_MASK;
        
        srcRaf.seek(srcExtentStartAddress);
        DataInputStream src = createInputStream(srcRaf);
        for (long srcBlockAddr = srcExtentStartAddress;
             srcBlockAddr < srcExtent.end();
             srcBlockAddr += OLD_BLOCK_SIZE) {
            
            int expectedRead = (int) Math.min(srcFileLength - srcBlockAddr , OLD_BLOCK_SIZE);
            src.readFully(buf,0, expectedRead);
            
            long destAddress = xlator.srcToDest(srcBlockAddr);
            destRaf.seek(destAddress);
            destRaf.write(buf, 0, expectedRead);
        }
    }
    
    private DataInputStream createInputStream(RandomAccessFile raf) {
        RandomAccessFileProxy proxy = new RandomAccessFileProxy(raf);
        NonContiguousInputStream rafAsStream = new NonContiguousInputStream(proxy);
        CloseShieldInputStream closeShield = new CloseShieldInputStream(rafAsStream);
        BufferedInputStream bin = new BufferedInputStream(closeShield, NEW_BLOCK_SIZE);
        DataInputStream din = new DataInputStream(bin);
        return din;
    }
    
    
    public static void main(String[] argv) throws Exception {
        File srcFile = new File(argv[0]);
        File destFile = new File(argv[1]);
        
        ReformatBlockSize reformatBlockSize = new ReformatBlockSize();
        reformatBlockSize.reformat(srcFile, destFile);
    }
    
    /**
     * This class is MT-safe.
     *
     */
    static final class AddressSpaceTranslator {
        /**
         * 
         * @param srcBlockAddr this is the source file address aligned to the
         * beginning of a src block.
         * @return the destination address in the new addressing scheme.
         */
        public long srcToDest(long srcBlockAddr) {
            long srcLaneNo = srcBlockAddr >> OLD_BLOCK_SIZE_BIT_SHIFT;
            srcLaneNo = srcLaneNo % N_IDS_PER_FILE;
            //This is the virtual block address as seen by the source lane.
            long srcLaneBlockNo = (srcBlockAddr >> OLD_BLOCK_SIZE_BIT_SHIFT) >> N_IDS_PER_FILE_BIT_SHIFT;
            long destAddress = srcLaneNo * NEW_BLOCK_SIZE +
                    (srcLaneBlockNo % 4) * OLD_BLOCK_SIZE +
                    (srcLaneBlockNo / 4) * NEW_SUPERBLOCK_SIZE;
            return destAddress;
        }
    }
}
