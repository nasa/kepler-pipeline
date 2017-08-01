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

package gov.nasa.kepler.gar.xml;

import gov.nasa.kepler.gar.xmlbean.HuffmanEntryXB;
import gov.nasa.kepler.gar.xmlbean.HuffmanTableDocument;
import gov.nasa.kepler.gar.xmlbean.HuffmanTableXB;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.HuffmanEntry;
import gov.nasa.kepler.hibernate.gar.HuffmanTable;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

/**
 * This class imports a specified huffman table file as a {@link HuffmanTable}.
 * 
 * @author Miles Cote
 */
public class HuffmanImporter {

    static final long HISTOGRAM_FILL_VALUE = -1L;

    public HuffmanTable importFile(File xmlFile) {
        return importFile(xmlFile, true);
    }

    @SuppressWarnings("deprecation")
    public HuffmanTable importFile(File xmlFile, boolean validate) {
        try {
            HuffmanTableDocument doc = HuffmanTableDocument.Factory.parse(xmlFile);

            if (validate) {
                XmlOptions xmlOptions = new XmlOptions();
                List<XmlError> errors = new ArrayList<XmlError>();
                xmlOptions.setErrorListener(errors);
                if (!doc.validate(xmlOptions)) {
                    throw new PipelineException("XML validation error.  "
                        + errors);
                }
            }

            HuffmanTableXB huffmanTableXB = doc.getHuffmanTable();

            HuffmanTable huffmanTable = new HuffmanTable();
            // NOTE: DO NOT set the externalId or the plannedStartTime because
            // this class needs to simulate the behavior of the real pipeline
            // module, which does not set these things.
            // huffmanTable.setExternalId(huffmanTableXB.getTableId());
            // huffmanTable.setPlannedStartTime(huffmanTableXB.getPlannedStartTime()
            // .getTime());
            huffmanTable.setFileName(xmlFile.getName());

            for (HuffmanEntryXB huffmanEntryXB : huffmanTableXB.getEntryArray()) {
                huffmanTable.getEntries()
                    .add(
                        new HuffmanEntry(huffmanEntryXB.getBitstring(),
                            HISTOGRAM_FILL_VALUE));
            }

            return huffmanTable;
        } catch (Exception e) {
            throw new PipelineException("Unable to import file.  file = "
                + xmlFile.getAbsolutePath(), e);
        }
    }

    public static void main(String[] args) {
        if (args.length != 1) {
            throw new PipelineException(HuffmanImporter.class.getName()
                + " must receive one input arg: absoluteFileName");
        }

        DatabaseService databaseService = DatabaseServiceFactory.getInstance();

        try {
            databaseService.beginTransaction();

            File file = new File(args[0]);

            HuffmanImporter huffmanImporter = new HuffmanImporter();
            HuffmanTable huffmanTable = huffmanImporter.importFile(file);

            CompressionCrud compressionCrud = new CompressionCrud();
            compressionCrud.createHuffmanTable(huffmanTable);

            databaseService.commitTransaction();

        } catch (Throwable e) {
            System.err.println("config-maker failed: " + e.getMessage());
            e.printStackTrace();
            System.exit(-1);
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }
}
