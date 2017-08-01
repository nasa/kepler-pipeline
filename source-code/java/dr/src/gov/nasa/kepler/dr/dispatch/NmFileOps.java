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

package gov.nasa.kepler.dr.dispatch;

import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.nm.DataProductMessageDocument;
import gov.nasa.kepler.nm.DataProductMessageXB;
import gov.nasa.kepler.nm.FileXB;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

/**
 * Performs a specified action on the files listed in the specified notification
 * message to the destination directory, then performs that action on the
 * notification message itself.
 * 
 * Common nicknames include:
 * 
 * drcopy : NmFileOps -drcopy foonm.xml # copies files to
 * dr.filewatcher.incoming.dir nmcopy : NmFileOps -nmcopy # copies files from
 * src to dest nmmove : NmFileOps -nmmove # moves files from src to dest
 * 
 * @author tklaus
 * 
 */
public class NmFileOps {
    private static final Log log = LogFactory.getLog(NmFileOps.class);

    public NmFileOps() {
    }

    public void fileOp(File notificationMsgFile, File destDirFile, boolean move)
        throws Exception {
        File sourceDir = notificationMsgFile.getParentFile();
        String op = move ? "moving" : "copying";

        log.info("parsing notification message = "
            + notificationMsgFile.getName() + " in dir = " + sourceDir);

        DataProductMessageDocument doc = DataProductMessageDocument.Factory.parse(notificationMsgFile);

        // Validate nm xml.
        XmlOptions xmlOptions = new XmlOptions();
        List<XmlError> errors = new ArrayList<XmlError>();
        xmlOptions.setErrorListener(errors);
        if (!doc.validate(xmlOptions)) {
            throw new DispatchException("XML validation error.  " + errors);
        }

        DataProductMessageXB message = doc.getDataProductMessage();
        FileXB[] fileList = message.getFileList()
            .getFileArray();

        log.info(op + " files to: " + destDirFile);

        for (FileXB file : fileList) {
            File srcFile = new File(sourceDir, file.getFilename());
            File destFile = new File(destDirFile, file.getFilename());

            log.info(op + " file [" + srcFile + "] to [" + destFile + "]");

            if (move) {
                moveFile(srcFile, destFile);
            } else {
                FileUtils.copyFile(srcFile, destFile);
            }
        }

        log.info(op + " notification message to: " + destDirFile);
        File destFile = new File(destDirFile, notificationMsgFile.getName());
        if (move) {
            moveFile(notificationMsgFile, destFile);
        } else {
            FileUtils.copyFile(notificationMsgFile, destFile);
        }

        log.info("Done");
    }

    private void nmMove(String nmPath, String destDirPath) throws Exception {
        log.info("nmMove: " + nmPath + ", destDir: " + destDirPath);
        fileOp(checkFile(nmPath), checkDirectory(destDirPath), true);
    }

    private void nmCopy(String nmPath, String destDirPath) throws Exception {
        log.info("nmCopy: " + nmPath + ", destDir: " + destDirPath);
        fileOp(checkFile(nmPath), checkDirectory(destDirPath), false);
    }

    private void nmSplit(String nmPath, int maxFilesPerNm) throws Exception {
        log.info("nmSplit: " + nmPath + ", maxFilesPerNm: " + maxFilesPerNm);

        File nmFile = new File(nmPath);

        NmSplitter nmSplitter = new NmSplitter();
        nmSplitter.split(nmFile, maxFilesPerNm);
    }

    public void drCopy(String nmPath) throws Exception {
        Configuration config = ConfigurationServiceFactory.getInstance();

        String incomingDirStr = config.getString(FileWatcher.INCOMING_DIR_PROP);
        if (incomingDirStr == null) {
            String error = "DR incoming dir prop () is null!";
            log.fatal(error);
            throw new IllegalArgumentException(error);
        }

        File nmFile = checkFile(nmPath);
        File incomingDirFile = checkDirectory(incomingDirStr);
        log.info("drCopy: " + nmPath + ", incomingDir: " + incomingDirFile);

        fileOp(nmFile, incomingDirFile, false);
    }

    private File checkDirectory(String path) throws IOException {
        File file = new File(path);
        if (!file.exists()) {
            throw new IOException(path + ": does not exist");
        }
        if (!file.isDirectory()) {
            throw new IOException(path + ": is not a directory");
        }
        return file;
    }

    private File checkFile(String path) throws IOException {
        File file = new File(path);
        if (!file.exists()) {
            throw new IOException(path + ": does not exist");
        }
        if (!file.isFile()) {
            throw new IOException(path + ": is not a directory");
        }
        return file;
    }

    private void moveFile(File srcFile, File destFile) throws IOException {
        boolean rename = srcFile.renameTo(destFile);
        if (!rename) {
            FileUtils.copyFile(srcFile, destFile);
            if (!srcFile.delete()) {
                deleteQuietly(destFile);
                throw new IOException("Failed to delete original file '"
                    + srcFile + "' after copy to '" + destFile + "'");
            }
        }
    }

    private boolean deleteQuietly(File file) {
        if (file == null) {
            return false;
        }
        try {
            if (file.isDirectory()) {
                FileUtils.cleanDirectory(file);
            }
        } catch (Exception e) {
        }

        try {
            return file.delete();
        } catch (Exception e) {
            return false;
        }
    }

    private static void usage() {
        System.err.println("USAGE: nmfileops -drcopy|-nmcopy|-nmmove notificationMessagePath [destination path]");
        System.err.println("USAGE: nmfileops -nmsplit notificationMessagePath maxFilesPerNm");
        System.exit(-1);
    }

    public static void main(String[] args) throws Exception {
        NmFileOps nmFileOps = new NmFileOps();
        String cmd = null;
        String nmPath = null;
        String destDirPath = null;

        if (args.length < 2) {
            usage();
        } else {
            cmd = args[0];
            nmPath = args[1];

            if (cmd.equals("-drcopy")) {
                nmFileOps.drCopy(nmPath);
            } else {
                if (args.length == 3) {
                    destDirPath = args[2];

                    if (cmd.equals("-nmcopy")) {
                        nmFileOps.nmCopy(nmPath, destDirPath);
                    } else if (cmd.equals("-nmmove")) {
                        nmFileOps.nmMove(nmPath, destDirPath);
                    } else if (cmd.equals("-nmsplit")) {
                        int maxFilesPerNm = Integer.parseInt(args[2]);
                        nmFileOps.nmSplit(nmPath, maxFilesPerNm);
                    } else {
                        usage();
                    }
                } else {
                    usage();
                }
            }
        }
    }
}
