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
import java.util.Map.Entry;
import java.util.Set;
import java.util.TreeMap;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

/**
 * Reads in a notification message and writes out a new notification message
 * where the files are sorted in alphabetical order. Since the filenames contain
 * a timestamp in the standard format defined in the DMC-SOC ICD, this also
 * results in a list that is time-ordered. The DMC is supposed to always send
 * these sorted, but if they don't (as was the case for the CDPP reprocessing,
 * see KAR-501), this gives the SOC operators another option.
 * 
 * @author tklaus
 * 
 */
public class NmSort {
    private static final Log log = LogFactory.getLog(NmSort.class);

    private String nmPath;
    private File nmFile;

    public NmSort(String sdnmFilename) {
        this.nmPath = sdnmFilename;
    }

    public void report() throws Exception {
        nmFile = new File(nmPath);

        if (nmFile.exists() && nmFile.isFile()) {
            DataProductMessageDocument doc = DataProductMessageDocument.Factory.parse(nmFile);
            DataProductMessageXB message = doc.getDataProductMessage();
            FileXB[] fileList = message.getFileList()
                .getFileArray();
            TreeMap<String, FileXB> orderedFileMap = new TreeMap<String, FileXB>();

            for (FileXB file : fileList) {
                orderedFileMap.put(file.getFilename(), file);
            }

            // generate new NM
            generateNewNm(message, orderedFileMap);

        } else {
            throw new Exception(
                "Specified NM does not exist or is not a regular file: "
                    + nmFile);
        }
    }

    private void generateNewNm(DataProductMessageXB originalMessage,
        TreeMap<String, FileXB> orderedFileMap) throws Exception {
        DataProductMessageDocument newDoc = DataProductMessageDocument.Factory.newInstance();
        DataProductMessageXB newMessage = newDoc.addNewDataProductMessage();

        newMessage.setMessageType(originalMessage.getMessageType());
        newMessage.setIdentifier(originalMessage.getIdentifier());

        FileListXB newFileList = newMessage.addNewFileList();

        int i = 0;
        Set<Entry<String, FileXB>> orderedEntries = orderedFileMap.entrySet();
        for (Entry<String, FileXB> entry : orderedEntries) {
            FileXB originalFile = entry.getValue();
            FileXB newFile = newFileList.addNewFile();

            newFile.setFilename(originalFile.getFilename());
            newFile.setChecksum(originalFile.getChecksum());
            newFile.setSize(originalFile.getSize());

            if (++i % 100 == 0) {
                log.info("Processed " + i + " files");
            }
        }

        XmlOptions xmlOptions = new XmlOptions().setSavePrettyPrint()
            .setSavePrettyPrintIndent(2);
        List<XmlError> errors = new ArrayList<XmlError>();
        xmlOptions.setErrorListener(errors);
        if (!newDoc.validate(xmlOptions)) {
            throw new PipelineException("XML validation error.  " + errors);
        }

        String originalNmName = nmFile.getName();
        String newNmName = originalNmName.substring(0,
            originalNmName.lastIndexOf("."))
            + "_sorted.xml";
        File directory = nmFile.getParentFile();
        File file = new File(directory, newNmName);
        newDoc.save(file, xmlOptions);

        log.info("Wrote " + file);
    }

    /**
     * @param args
     * @throws IOException
     * @throws Exception
     */
    public static void main(String[] args) throws Exception {
        NmSort sorter;

        if (args.length != 1) {
            throw new Exception("USAGE: nmsort NM_PATH");
        }

        sorter = new NmSort(args[0]);
        sorter.report();
    }
}
