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

import gov.nasa.kepler.nm.DataProductMessageDocument;
import gov.nasa.kepler.nm.DataProductMessageXB;
import gov.nasa.kepler.nm.FileListXB;
import gov.nasa.kepler.nm.FileXB;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlException;
import org.apache.xmlbeans.XmlOptions;

/**
 * Splits a notification message.
 * 
 * @author Miles Cote
 * 
 */
public class NmSplitter {

    private static final Log log = LogFactory.getLog(NmSplitter.class);

    public List<File> split(File nmFile, int maxFilesPerNm)
        throws XmlException, IOException {
        DataProductMessageDocument doc = DataProductMessageDocument.Factory.parse(nmFile);
        DataProductMessageXB message = doc.getDataProductMessage();

        @SuppressWarnings("deprecation")
        FileXB[] fileList = message.getFileList()
            .getFileArray();

        List<File> splitNmFiles = new ArrayList<File>();

        List<List<FileXB>> fileXbLists = createFileXbLists(fileList);

        int splitNmCount = 0;
        List<FileXB> fileXbBuffer = new ArrayList<FileXB>();
        for (List<FileXB> fileXbs : fileXbLists) {
            if (fileXbBuffer.size() + fileXbs.size() > maxFilesPerNm) {
                File splitNmFile = generateSplitNmFile(nmFile, splitNmCount,
                    fileXbBuffer);
                splitNmFiles.add(splitNmFile);

                log.info("Created splitNmFile: " + splitNmFile);

                fileXbBuffer = new ArrayList<FileXB>();
                splitNmCount++;
            }

            fileXbBuffer.addAll(fileXbs);
        }

        if (!fileXbBuffer.isEmpty()) {
            File splitNmFile = generateSplitNmFile(nmFile, splitNmCount,
                fileXbBuffer);
            splitNmFiles.add(splitNmFile);
            log.info("Created splitNmFile: " + splitNmFile);
        }

        return splitNmFiles;
    }

    private List<List<FileXB>> createFileXbLists(FileXB[] fileList) {
        log.info("Creating fileXbLists.");

        String prefix = null;
        List<FileXB> fileXbs = null;
        List<List<FileXB>> fileXbLists = new ArrayList<List<FileXB>>();
        for (FileXB fileXB : fileList) {
            String filename = fileXB.getFilename();
            String[] filenameParts = filename.split(NotificationMessageHandler.FILENAME_SEPARATOR);
            String nextPrefix = filenameParts[0];

            if (prefix == null || !prefix.equals(nextPrefix)) {
                prefix = nextPrefix;
                fileXbs = new ArrayList<FileXB>();
                fileXbLists.add(fileXbs);
            }

            fileXbs.add(fileXB);
        }

        return fileXbLists;
    }

    private File generateSplitNmFile(File origNmFile, int splitNmCount,
        List<FileXB> fileXbBuffer) throws IOException, XmlException {
        log.info("Generating splitNmFile " + splitNmCount);

        String[] nmFileNameParts = origNmFile.getName()
            .split(NotificationMessageHandler.FILENAME_SEPARATOR);
        if (nmFileNameParts.length != 2) {
            throw new IllegalArgumentException(
                "nmFileName must be of the format <prefix>_<suffix>.\n  nmFile: "
                    + origNmFile);
        }
        String nmPrefix = nmFileNameParts[0];
        String nmSuffix = nmFileNameParts[1];

        String splitNmFileName = getSplitNmFileName(nmPrefix, nmSuffix,
            splitNmCount);

        DataProductMessageDocument origDoc = DataProductMessageDocument.Factory.parse(origNmFile);
        DataProductMessageXB origMessage = origDoc.getDataProductMessage();

        DataProductMessageDocument newDoc = DataProductMessageDocument.Factory.newInstance();
        DataProductMessageXB newMessage = newDoc.addNewDataProductMessage();
        newMessage.setMessageType(origMessage.getMessageType());
        newMessage.setIdentifier(splitNmFileName);

        FileListXB newFileList = newMessage.addNewFileList();
        newFileList.setFileArray(fileXbBuffer.toArray(new FileXB[0]));

        XmlOptions xmlOptions = new XmlOptions().setSavePrettyPrint()
            .setSavePrettyPrintIndent(2);
        List<XmlError> errors = new ArrayList<XmlError>();
        xmlOptions.setErrorListener(errors);
        if (!newDoc.validate(xmlOptions)) {
            throw new PipelineException("XML validation errors: " + errors);
        }

        File newNmFile = new File(origNmFile.getParent(), splitNmFileName);
        newDoc.save(newNmFile, xmlOptions);

        return newNmFile;
    }

    private String getSplitNmFileName(String prefix, String suffix,
        int splitNmCount) {
        return prefix + "s" + splitNmCount
            + NotificationMessageHandler.FILENAME_SEPARATOR + suffix;
    }

}
