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

package gov.nasa.spiffy.common.io;

import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;

import org.apache.commons.io.filefilter.IOFileFilter;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author Sean McCauliff
 * 
 */
public class FileCopyVisitor implements FileVisitor {

    private static Log log = LogFactory.getLog(FileCopyVisitor.class);

    private final File destDir;
    private final File srcDir;
    private final IOFileFilter fileFilter;
    private final CopyOp copyOp;
    private final boolean includeAll;

    private int copyCount = 0;
    private boolean pruneState = false;

    public FileCopyVisitor(File srcDir, File destDir, CopyOp copyOp) {
        this(srcDir, destDir, copyOp, null);
    }

    /**
     * 
     * @param srcDir
     * @param destDir
     * @param copyOp What kind of copy operation should be used when copying
     * regular files.
     * @param fileFilter Only copy files matching these filters.
     */
    public FileCopyVisitor(File srcDir, File destDir, CopyOp copyOp,
        IOFileFilter fileFilter) {
        this(srcDir, destDir, copyOp, fileFilter, true);
    }

    /**
     * 
     * @param srcDir
     * @param destDir
     * @param copyOp What kind of copy operation should be used when copying
     * regular files.
     * @param fileFilter Only copy files matching these filters.
     * @param includeAll If {@code true} and fileFilter is not null, all src
     * directories (but not necessarily their contents) will be copied, in other
     * words, empty directories not matching the fileFilter will be created.
     */
    public FileCopyVisitor(File srcDir, File destDir, CopyOp copyOp,
        IOFileFilter fileFilter, boolean includeAll) {
        this.destDir = destDir;
        this.srcDir = srcDir;
        this.copyOp = copyOp;
        this.fileFilter = fileFilter;
        this.includeAll = includeAll;
    }

    public int filesCopies() {
        return copyCount;
    }

    /**
     * Makes a new directory under dest.
     */
    @Override
    public void enterDirectory(File newdir) throws IOException,
        PipelineException {

        if (fileFilter != null) {
            if (!fileFilter.accept(newdir)) {
                pruneState = true;
                return;
            }
        }

        File destDir = destDir(newdir);
        if (destDir.exists()) {
            log.debug("Destination directory \"" + destDir
                + "\" already exists.");
            return;
        }

        if (fileFilter == null || includeAll) {
            log.debug("Creating destination directory \"" + destDir + "\".");
            if (!destDir.mkdir()) {
                throw new IOException(
                    "Failed to create destination directory \"" + newdir
                        + "\".");
            }
            copyCount++;
        }
    }

    /**
     * This does nothing.
     */
    @Override
    public void exitDirectory(File exitdir) {
        // Nothing
    }

    /**
     * This will return true if a directory matches the file name filter.
     */
    @Override
    public boolean prune() {
        boolean rv = pruneState;
        pruneState = false;
        return rv;
    }

    /**
     */
    @Override
    public void visitFile(File dir, File f) throws IOException,
        PipelineException {

        if (f.equals(srcDir)) {
            return;
        }

        if (fileFilter != null) {
            if (!fileFilter.accept(f)) {
                return;
            }
        }

        File destDir = destDir(dir);
        File destFile = new File(destDir, f.getName());

        switch (copyOp) {
            case COPY:
                log.debug("Copying file \"" + f + "\" -> \"" + destFile + "\".");
                org.apache.commons.io.FileUtils.copyFile(f, destFile);
                break;
            case HARD_SHALLOW:
                log.debug("Making hard link \"" + f + "\" -> \"" + destFile
                    + "\".");
                gov.nasa.spiffy.common.io.FileUtil.hardlink(f, destFile);
                break;
            case SYMBOLIC_SHALLOW:
                log.debug("Making symbolic link \"" + f + "\" -> \"" + destFile
                    + "\".");
                gov.nasa.spiffy.common.io.FileUtil.symlink(f, destFile);
                break;
            default:
                throw new IllegalStateException("Unhandled case statement.");
        }

        copyCount++;
    }

    protected File destDir(File dir) {
        int srcDirLen = srcDir.getAbsolutePath()
            .length();
        String suffixDirName = dir.getAbsolutePath()
            .substring(srcDirLen);
        File currentDestDir = new File(destDir, suffixDirName);
        return currentDestDir;
    }

    protected IOFileFilter getFileFilter() {
        return fileFilter;
    }

    protected void setPruneState(boolean pruneState) {
        this.pruneState = pruneState;
    }

    protected void incrementCopyCount() {
        copyCount++;
    }

}
