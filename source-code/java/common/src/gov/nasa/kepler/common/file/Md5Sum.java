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

import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.lang.StringUtils;

import java.io.*;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.List;

/**
 * Calculates the MD5 for the given file. 
 * 
 * @author Sean McCauliff
 *
 */ 
public class Md5Sum {

    private static final int BUF_SIZE = 1024*1024;
    
    /**
     * Reads in the entire file and computes the MD5 on that file.
     * @param f The file to read in.
     * @param sparse When true only read the data extents on sparse files, this
     * only works on Linux.
     * @return The MD5 in hexadecimal format the same as md5sums.
     */
    public static String computeMd5(File productFile, boolean sparse) throws IOException {
        MessageDigest md = null;
        try {
            md = MessageDigest.getInstance("MD5");
        } catch (NoSuchAlgorithmException e) {
            throw new IOException(e.toString());
        }

        byte[] buf = new byte[BUF_SIZE];
        if (!sparse) {
            FileInputStream fin = null;
            try {
                fin =  new FileInputStream(productFile);
                
                for (int nread = fin.read(buf);
                     nread > 0;
                     nread = fin.read(buf)) {
                    md.update(buf, 0, nread);
                }
               
            } finally  {
               FileUtil.close(fin);
            }
        } else {
            SparseFileUtil extentMap = new SparseFileUtil();
            List<SimpleInterval> extents = extentMap.extents(productFile);
            RandomAccessFile raf = new RandomAccessFile(productFile, "r");
            try {
                long start = Long.MAX_VALUE;
                long end = Long.MIN_VALUE;
                int extenti=0;
                while (start <= end || extenti < extents.size()) {
                    if (start > end) {
                        SimpleInterval nextExtent = extents.get(extenti++);
                        start = nextExtent.start();
                        end = nextExtent.end();
                        raf.seek(start);
                    }
                    int len = (int) Math.min((end-start)+1, buf.length);
                    int nread = raf.read(buf, 0, len);
                    if (nread == -1) {
                        //reached end of file, but space allocated was longer.
                        break;
                    }
                    start += nread;
                    md.update(buf, 0, nread);
                }
            } finally {
                FileUtil.close(raf);
            }
        }
        
        byte[] md5 = md.digest();
        return StringUtils.toHexString(md5, 0, md5.length);

    }
    
    public static String computeMd5(File productFile) throws IOException {
        return computeMd5(productFile, false);
    }

}
