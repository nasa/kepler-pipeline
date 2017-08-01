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
import gov.nasa.spiffy.common.os.OperatingSystemType;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import org.apache.commons.io.FileUtils;

/**
 * This is used to describe the extents in a file in the file system.
 * Currently, this only works for Linux.
 * 
 * @author Sean McCauliff
 *
 */
public class SparseFileUtil {

    private static volatile boolean initialized = false;
    
    private static final Comparator<SimpleInterval> comp = new Comparator<SimpleInterval>() {
        @Override
        public int compare(SimpleInterval o1, SimpleInterval o2) {
            if (o1.start() < o2.start()) {
                return -1;
            } else if (o1.start() > o2.start()) {
                return 1;
            } else {
                return 0;
            }
        }
    };
    
    public SparseFileUtil() {
        OperatingSystemType osType = OperatingSystemType.getInstance();
        if (osType != OperatingSystemType.LINUX) {
            throw new IllegalStateException("Not supported on \"" + osType + "\"");
        }
        if (!initialized) {
            synchronized (SparseFileUtil.class) {
                if (!initialized) {
                    System.loadLibrary("extentmap-linux");
                    initExtentMapLib();
                    initialized = true;
                }
            }
        }
    }
    
    public List<SimpleInterval> extents(File file) throws IOException {
        if (!file.exists()) {
            throw new FileNotFoundException(file.getAbsolutePath());
        }
        if (file.isDirectory()) {
            //Actually we might be able to do this, but I don't care to.
            throw new FileNotFoundException("Can't read extents on directory \""
                + file + "\".");
        }
        if (!file.canRead()) {
            throw new IOException("Can't read file\"" + file + "\".");
        }
        
        SimpleInterval[] extents = null;
        try {
            extents = extentsForFile(file.getAbsolutePath());
        } catch (IllegalArgumentException iae) {
            throw new IllegalArgumentException("For file \"" + file + "\".", iae);
        }
        if (extents.length == 0) {
            return Collections.emptyList();
        }
        
        //I don't actually know what order these come in so I'm sorting them.
        Arrays.sort(extents, comp);
        List<SimpleInterval> mergedExtents = new ArrayList<SimpleInterval>();
        SimpleInterval current = extents[0];
        //Sometimes the extents are not merged: extents which touch
        //each other logically are not merged into the same extent. This might
        //be because they are physically fragmented or just some ioctl artifact.
        for (int i=1; i < extents.length; i++) {
            SimpleInterval sortedExtent = extents[i];
            if (current.end() < sortedExtent.start()) {
                mergedExtents.add(current);
                current = sortedExtent;
            } else {
                current = new SimpleInterval(Math.min(sortedExtent.start(), current.start()),
                    Math.max(current.end(), sortedExtent.end()));
            }
        }
        mergedExtents.add(current);
        return mergedExtents;
    }
    
    /**
     * 
     * @param src A file.
     * @param dest A destination file.
     * @throws IOException
     */
    public void copySparseFile(File src, File dest) throws IOException {
        if (!src.exists()) {
            throw new FileNotFoundException(src.getAbsolutePath());
        }
        if (src.isDirectory()) {
            throw new IllegalArgumentException("Src must be a file.");
        }
        List<SimpleInterval> extents = extents(src);
        if (extents.size() == 1 && extents.get(0).start() == 0) {
            FileUtils.copyFile(src, dest);
            return;
        } 
        
        byte[] buf = new byte[1024*1024];
        RandomAccessFile srcRaf = new RandomAccessFile(src, "r");
        try {
            RandomAccessFile destRaf = new RandomAccessFile(dest, "rw");
            try {
                for (SimpleInterval extent : extents) {
                    long extentSize = extent.end() - extent.start() + 1;
                    srcRaf.seek(extent.start());
                    destRaf.seek(extent.start());
                    while (extentSize > 0) {
                        int readLen = (int) Math.min(buf.length, extentSize);
                        int nread = srcRaf.read(buf,0, readLen);
                        if (nread == -1) {
                            break; //file ends before extent ends.
                        }
                        extentSize -= nread;
                        destRaf.write(buf, 0, nread);
                    }
                }
                destRaf.setLength(srcRaf.length());
            } finally {
                FileUtil.close(destRaf);
            }
        } finally {
            FileUtil.close(srcRaf);
        }
    }
    
    private native SimpleInterval[] extentsForFile(String fname) throws IOException;
    
    /**
     * Call this from the class initializer.
     * @throws IOException
     */
    private static native void initExtentMapLib();
}
