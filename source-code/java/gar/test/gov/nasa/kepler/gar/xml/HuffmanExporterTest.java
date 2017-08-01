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

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.gar.xmlbean.HuffmanEntryXB;
import gov.nasa.kepler.gar.xmlbean.HuffmanTableDocument;
import gov.nasa.kepler.gar.xmlbean.HuffmanTableXB;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.gar.HuffmanEntry;
import gov.nasa.kepler.hibernate.gar.HuffmanTable;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xmlbeans.XmlException;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class HuffmanExporterTest {

    private static final Log log = LogFactory.getLog(HuffmanExporterTest.class);

    private static final long MILLIS_PER_MONTH = 30 * 24 * 60 * 60 * 1000L;

    @Before
    public void setUp() throws Exception {
        DefaultProperties.setPropsForUnitTest();
        TestUtils.setUpDatabase(DatabaseServiceFactory.getInstance());
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(DatabaseServiceFactory.getInstance());
    }

    @Test
    public void export() throws IOException, XmlException {
        List<HuffmanEntry> huffmanEntries = createHuffmanEntries();
        HuffmanTable huffmanTable = createHuffmanTable(huffmanEntries);

        File file = new HuffmanExporter().export(huffmanTable,
            Filenames.BUILD_TMP);

        validateHuffman(file, huffmanTable, huffmanEntries);
    }

    private List<HuffmanEntry> createHuffmanEntries() {
        List<HuffmanEntry> huffmanEntries = new ArrayList<HuffmanEntry>();
        int n = (int) Math.pow(2.0, 17.0) - 1;
        for (int i = 0; i < n; i++) {
            huffmanEntries.add(new HuffmanEntry("01010", i));
        }

        return huffmanEntries;
    }

    private HuffmanTable createHuffmanTable(List<HuffmanEntry> huffmanEntries) {
        HuffmanTable huffmanTable = new HuffmanTable();
        huffmanTable.setExternalId(1);
        huffmanTable.setPlannedStartTime(new Date());
        huffmanTable.setPlannedEndTime(new Date(
            huffmanTable.getPlannedStartTime()
                .getTime() + 3 * MILLIS_PER_MONTH));
        huffmanTable.setEntries(huffmanEntries);

        return huffmanTable;
    }

    private void validateHuffman(File file, HuffmanTable huffmanTable,
        List<HuffmanEntry> huffmanEntries) throws XmlException, IOException {

        log.info("Validating " + file.getAbsolutePath());

        HuffmanTableDocument doc = HuffmanTableDocument.Factory.parse(file);

        HuffmanTableXB huffmanTableXB = doc.getHuffmanTable();
        assertEquals(huffmanTable.getExternalId(), huffmanTableXB.getTableId());
        assertEquals(huffmanTable.getPlannedStartTime(),
            huffmanTableXB.getPlannedStartTime()
                .getTime());

        log.info("Validating " + huffmanEntries.size() + " Huffman entries");
        int i = 0;
        for (HuffmanEntryXB huffmanEntryXB : huffmanTableXB.getEntryArray()) {
            if (i % 100 == 0) {
                log.debug("Validated " + i + " entries");
            }
            HuffmanEntry huffmanEntry = huffmanEntries.get(i++);
            assertEquals(huffmanEntry.getBitstring(),
                huffmanEntryXB.getBitstring());
            assertEquals(huffmanEntry.getValue(), huffmanEntryXB.getValue());
        }
    }
}
