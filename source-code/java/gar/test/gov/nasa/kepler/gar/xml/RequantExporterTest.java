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
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.gar.xmlbean.MeanBlackEntriesXB;
import gov.nasa.kepler.gar.xmlbean.MeanBlackEntryXB;
import gov.nasa.kepler.gar.xmlbean.RequantEntriesXB;
import gov.nasa.kepler.gar.xmlbean.RequantEntryXB;
import gov.nasa.kepler.gar.xmlbean.RequantTableDocument;
import gov.nasa.kepler.gar.xmlbean.RequantTableXB;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.gar.MeanBlackEntry;
import gov.nasa.kepler.hibernate.gar.RequantEntry;
import gov.nasa.kepler.hibernate.gar.RequantTable;
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

public class RequantExporterTest {

    private static final Log log = LogFactory.getLog(RequantExporterTest.class);

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
        List<RequantEntry> requantEntries = createRequantEntries();
        List<MeanBlackEntry> meanBlackEntries = createMeanBlackEntries();
        RequantTable requantTable = createRequantTable(requantEntries,
            meanBlackEntries);

        File file = new RequantExporter().export(requantTable,
            Filenames.BUILD_TMP);

        // The following depends that the first file name returned is the
        // requant one and that the second one is the mean black one.
        validate(file, requantTable, requantEntries, meanBlackEntries);
    }

    private List<RequantEntry> createRequantEntries() {
        List<RequantEntry> requantEntries = new ArrayList<RequantEntry>(
            FcConstants.REQUANT_TABLE_LENGTH);
        for (int i = 0; i < FcConstants.REQUANT_TABLE_LENGTH; i++) {
            requantEntries.add(new RequantEntry(i));
        }

        return requantEntries;
    }

    private List<MeanBlackEntry> createMeanBlackEntries() {
        List<MeanBlackEntry> meanBlackEntries = new ArrayList<MeanBlackEntry>(
            FcConstants.MODULE_OUTPUTS);
        for (int i = 0; i < FcConstants.MODULE_OUTPUTS; i++) {
            meanBlackEntries.add(new MeanBlackEntry(i));
        }

        return meanBlackEntries;
    }

    private RequantTable createRequantTable(List<RequantEntry> requantEntries,
        List<MeanBlackEntry> meanBlackEntries) {

        RequantTable requantTable = new RequantTable();
        requantTable.setExternalId(1);
        requantTable.setPlannedStartTime(new Date());
        requantTable.setPlannedEndTime(new Date(
            requantTable.getPlannedStartTime()
                .getTime() + 3 * MILLIS_PER_MONTH));
        requantTable.setRequantEntries(requantEntries);
        requantTable.setMeanBlackEntries(meanBlackEntries);

        return requantTable;
    }

    private void validate(File file, RequantTable requantTable,
        List<RequantEntry> requantEntries, List<MeanBlackEntry> meanBlackEntries)
        throws XmlException, IOException {

        log.info("Validating " + file.getAbsolutePath());
        RequantTableDocument doc = RequantTableDocument.Factory.parse(file);

        RequantTableXB requantTableXB = doc.getRequantTable();
        assertEquals(requantTable.getExternalId(), requantTableXB.getTableId());
        assertEquals(requantTable.getPlannedStartTime(),
            requantTableXB.getPlannedStartTime()
                .getTime());

        validateRequantEntries(requantEntries,
            requantTableXB.getRequantEntries());
        validateMeanBlackEntries(meanBlackEntries,
            requantTableXB.getMeanBlackEntries());
    }

    private void validateRequantEntries(List<RequantEntry> requantEntries,
        RequantEntriesXB requantEntriesXB) {

        log.info("Validating " + requantEntries.size() + " requant entries");
        int i = 0;
        for (RequantEntryXB requantEntryXB : requantEntriesXB.getEntryArray()) {
            // The int cast is because the XML schema says these values are
            // longs for historical reasons.
            if (i % 100 == 0) {
                log.debug("Validated " + i + " entries");
            }
            assertEquals(requantEntries.get(i++)
                .getRequantFlux(), requantEntryXB.getRequantflux());
        }
    }

    private void validateMeanBlackEntries(
        List<MeanBlackEntry> meanBlackEntries,
        MeanBlackEntriesXB meanBlackEntriesXB) {

        log.info("Validating " + meanBlackEntries.size()
            + " mean black entries");
        int i = 0;
        for (MeanBlackEntryXB meanBlackEntryXB : meanBlackEntriesXB.getEntryArray()) {
            assertEquals(meanBlackEntries.get(i++)
                .getMeanBlackValue(), meanBlackEntryXB.getMeanBlack());
        }
    }
}
