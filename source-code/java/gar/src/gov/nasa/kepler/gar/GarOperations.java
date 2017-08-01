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

package gov.nasa.kepler.gar;

import gov.nasa.kepler.common.DateUtils;
import gov.nasa.kepler.common.file.Md5Sum;
import gov.nasa.kepler.gar.xml.HuffmanExporter;
import gov.nasa.kepler.gar.xml.RequantExporter;
import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.gar.HuffmanTable;
import gov.nasa.kepler.hibernate.gar.RequantTable;
import gov.nasa.kepler.nm.DataProductMessageDocument;
import gov.nasa.kepler.nm.DataProductMessageXB;
import gov.nasa.kepler.nm.FileListXB;
import gov.nasa.kepler.nm.FileXB;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlObject;
import org.apache.xmlbeans.XmlOptions;

public class GarOperations {

    private static final int MAX_ERRORS = 25;
    private static Log log = LogFactory.getLog(GarOperations.class);

    public List<File> export(HuffmanTable huffmanTable,
        RequantTable requantTable, String path) throws IOException,
        PipelineException {
        return export(huffmanTable, requantTable, path, true);
    }

    public List<File> export(HuffmanTable huffmanTable,
        RequantTable requantTable, String path, boolean validate)
        throws IOException {

        // Validation.
        if (huffmanTable.getExternalId() != requantTable.getExternalId()) {
            throw new PipelineException("Huffman encoding and "
                + "requantization tables must have the same table ID");
        }
        validatePath(path);
        validateForExport(huffmanTable);
        validateForExport(requantTable);

        // Export.
        List<File> files = new ArrayList<File>(2);
        Date timeGenerated = new Date();
        HuffmanExporter huffmanExporter = new HuffmanExporter();
        files.add(huffmanExporter.export(huffmanTable, path, timeGenerated,
            validate));

        RequantExporter requantExporter = new RequantExporter();
        files.add(requantExporter.export(requantTable, path, timeGenerated,
            validate));

        // Create notification message.
        DataProductMessageDocument doc = DataProductMessageDocument.Factory.newInstance();
        DataProductMessageXB dataProductMessage = doc.addNewDataProductMessage();

        dataProductMessage.setMessageType("TANM");
        String tanmFilename = String.format("kplr%s_%s.xml",
            DateUtils.formatLikeDmc(timeGenerated), "tanm");
        dataProductMessage.setIdentifier(tanmFilename);

        FileListXB fileList = dataProductMessage.addNewFileList();

        for (File file : files) {
            FileXB dataProductFile = fileList.addNewFile();
            dataProductFile.setFilename(file.getName());
            dataProductFile.setSize(file.length());
            dataProductFile.setChecksum(Md5Sum.computeMd5(file));
        }

        files.add(writeDocument(doc, path, tanmFilename, validate));

        return files;
    }

    private void validatePath(String path) {
        File file = new File(path);
        if (!file.isDirectory()) {
            throw new IllegalArgumentException("The path " + path
                + " is not a directory");
        }
        if (!file.canWrite()) {
            throw new IllegalArgumentException(
                "You do not have permission to add files to " + path);
        }
    }

    private void validateForExport(ExportTable exportTable) {
        exportTable.validate();
    }

    /**
     * Writes the given XML document to a file.
     * 
     * @param doc the XML document.
     * @param path the directory.
     * @param filename the file name.
     * @param validate if {@code true}, XML validation is performed.
     * @return the actual file written.
     * @throws IOException if there was an error opening or writing the file.
     */
    public static File writeDocument(XmlObject doc, String path,
        String filename, boolean validate) throws IOException {

        XmlOptions xmlOptions = new XmlOptions().setSavePrettyPrint()
            .setSavePrettyPrintIndent(2);
        @SuppressWarnings("serial")
        List<XmlError> errors = new ArrayList<XmlError>() {
            @Override
            public boolean add(XmlError e) {
                if (size() >= MAX_ERRORS) {
                    throw new IllegalStateException("Too many errors");
                }
                return super.add(e);
            }
        };
        xmlOptions.setErrorListener(errors);

        if (validate) {
            log.info("Validating XML document");
            boolean valid = false;
            try {
                valid = doc.validate(xmlOptions);
            } finally {
                if (!valid) {
                    throw new PipelineException("XML validation error:  "
                        + errors);
                }
            }
        }

        File file = new File(path, filename);
        log.info("Writing " + file.getAbsolutePath());
        doc.save(file, xmlOptions);

        return file;
    }
}
