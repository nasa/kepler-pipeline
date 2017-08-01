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

import gov.nasa.kepler.gar.GarOperations;
import gov.nasa.kepler.gar.xmlbean.HuffmanEntryXB;
import gov.nasa.kepler.gar.xmlbean.HuffmanTableDocument;
import gov.nasa.kepler.gar.xmlbean.HuffmanTableXB;
import gov.nasa.kepler.hibernate.gar.HuffmanEntry;
import gov.nasa.kepler.hibernate.gar.HuffmanTable;

import java.io.File;
import java.io.IOException;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.TimeZone;

/**
 * This class exports a specified {@link HuffmanTable} to a specified directory.
 * 
 * @author Miles Cote
 */
public class HuffmanExporter {

    /**
     * Exports the given Huffman table using the current time in the filename.
     * Use {@link #export(HuffmanTable, String, Date, boolean)} when exporting
     * multiple files to ensure that the date in the filename is consistent.
     */
    public File export(HuffmanTable huffmanTable, String path)
        throws IOException {
        return export(huffmanTable, path, true);
    }

    /**
     * Exports the given Huffman table using the current time in the filename.
     * Use {@link #export(HuffmanTable, String, Date, boolean)} when exporting
     * multiple files to ensure that the date in the filename is consistent.
     */
    public File export(HuffmanTable huffmanTable, String path, boolean validate)
        throws IOException {
        return export(huffmanTable, path, new Date(), validate);
    }

    public File export(HuffmanTable huffmanTable, String path,
        Date timeGenerated, boolean validate) throws IOException {

        HuffmanTableDocument doc = HuffmanTableDocument.Factory.newInstance();
        HuffmanTableXB tableXB = doc.addNewHuffmanTable();
        tableXB.setTableId(huffmanTable.getExternalId());
        tableXB.setPlannedStartTime(getPlannedStartTime(huffmanTable));

        addHuffmanEntries(tableXB, huffmanTable);

        return GarOperations.writeDocument(doc, path,
            huffmanTable.generateFileName(timeGenerated), validate);
    }

    private void addHuffmanEntries(HuffmanTableXB tableXB,
        HuffmanTable huffmanTable) {

        List<HuffmanEntry> entries = huffmanTable.getEntries();
        tableXB.setTotalEntryCount(entries.size());
        for (HuffmanEntry entry : entries) {
            HuffmanEntryXB entryXB = tableXB.addNewEntry();
            entryXB.setBitstring(entry.getBitstring());
            entryXB.setValue(entry.getValue());
        }
    }

    private Calendar getPlannedStartTime(HuffmanTable huffmanTable) {
        Calendar plannedStartTime = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
        plannedStartTime.setTime(huffmanTable.getPlannedStartTime());

        return plannedStartTime;
    }
}
