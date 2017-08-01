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

package gov.nasa.kepler.pdq.xml;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;
import gov.nasa.kepler.hibernate.dr.RefPixelLog;
import gov.nasa.kepler.hibernate.pdq.AttitudeAdjustment;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.pdq.attitudeAdjustment.AttitudeAdjustmentDocument;
import gov.nasa.kepler.pdq.attitudeAdjustment.AttitudeAdjustmentXB;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.IOException;
import java.util.Date;

import org.apache.commons.io.FileUtils;
import org.apache.xmlbeans.XmlException;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Miles Cote
 * 
 */
public class AttitudeAdjustmentExporterTest {

    private static final float X = 1.1F;
    private static final float Y = 2.2F;
    private static final float Z = 3.3F;
    private static final float W = 4.4F;

    private RefPixelLog refPixelLog = new RefPixelLog(0L, 1, 1, 1,
        ModifiedJulianDate.dateToMjd(new Date()));
    private String directoryPath = Filenames.BUILD_TMP + File.separator
        + System.getProperty("user.name") + File.separator + "pdq-unit-tests";

    private TargetTable refPixelTable = new TargetTable(
        TargetType.REFERENCE_PIXEL);
    private AttitudeAdjustmentExporter exporter;

    private DatabaseService databaseService;
    private DdlInitializer ddlInitializer = null;

    private TargetCrud targetCrud;

    private AttitudeAdjustment attitudeAdjustment;

    public DatabaseService getDatabaseService() {
        return databaseService;
    }

    public void setDatabaseService(DatabaseService databaseService) {
        this.databaseService = databaseService;
    }

    public TargetCrud getTargetCrud() {
        return targetCrud;
    }

    public void setTargetCrud(TargetCrud targetCrud) {
        this.targetCrud = targetCrud;
    }

    @Before
    public void setUp() throws Exception {

        setDatabaseService(DatabaseServiceFactory.getInstance());
        ddlInitializer = getDatabaseService().getDdlInitializer();
        ddlInitializer.initDB();
        setTargetCrud(new TargetCrud(getDatabaseService()));
        removeAll(new File(directoryPath));

        exporter = new AttitudeAdjustmentExporter();
    }

    @After
    public void tearDown() throws Exception {

        getDatabaseService().closeCurrentSession();
        ddlInitializer.cleanDB();
        removeAll(new File(directoryPath));
    }

    @Test(expected = IllegalArgumentException.class)
    public void exportToNonexistentPath() throws Exception {

        populateObjects();
        exporter.export(directoryPath, attitudeAdjustment);
    }

    @Test(expected = IllegalArgumentException.class)
    public void exportToFilePath() throws Exception {

        populateObjects();
        File dir = new File(directoryPath);
        assertTrue(dir.getParentFile()
            .mkdirs());
        assertTrue(dir.createNewFile());
        exporter.export(directoryPath, attitudeAdjustment);
    }

    @Test(expected = NullPointerException.class)
    public void exportNull() throws Exception {

        File dir = new File(directoryPath);
        assertTrue(dir.mkdirs());
        exporter.export(directoryPath, null);
    }

    @Test
    public void export() throws Exception {

        populateObjects();
        File dir = new File(directoryPath);
        assertTrue(dir.mkdirs());
        File file = exporter.export(directoryPath, attitudeAdjustment);

        validateAttitudeAdjustment(file, attitudeAdjustment);
    }

    private void populateObjects() throws Exception {

        refPixelTable.setExternalId(1);
        getDatabaseService().beginTransaction();
        refPixelTable.setExternalId(1);
        getTargetCrud().createTargetTable(refPixelTable);
        getDatabaseService().commitTransaction();
        getDatabaseService().closeCurrentSession();
        getDatabaseService().beginTransaction();
        refPixelTable = getTargetCrud().retrieveTargetTable(1);
        getDatabaseService().commitTransaction();

        attitudeAdjustment = new AttitudeAdjustment(null, refPixelLog, X, Y, Z,
            W);
    }

    private void validateAttitudeAdjustment(File file,
        AttitudeAdjustment attitudeAdjustment) throws IOException, XmlException {

        AttitudeAdjustmentDocument doc = AttitudeAdjustmentDocument.Factory.parse(file);
        AttitudeAdjustmentXB attitudeAdjustmentXB = doc.getAttitudeAdjustment();

        assertNotNull(attitudeAdjustmentXB);
        assertEquals(attitudeAdjustment.getX(),
            attitudeAdjustmentXB.getDeltaQuaternion()
                .getX(), 0);
        assertEquals(attitudeAdjustment.getY(),
            attitudeAdjustmentXB.getDeltaQuaternion()
                .getY(), 0);
        assertEquals(attitudeAdjustment.getZ(),
            attitudeAdjustmentXB.getDeltaQuaternion()
                .getZ(), 0);
        assertEquals(attitudeAdjustment.getW(),
            attitudeAdjustmentXB.getDeltaQuaternion()
                .getW(), 0);
    }

    private void removeAll(File path) {

        if (path.exists()) {
            if (path.isDirectory()) {
                try {
                    FileUtils.deleteDirectory(path);
                } catch (IOException ignore) {
                }
            } else {
                assertTrue(path.delete());
            }
        }
        File parent = path.getParentFile();
        if (parent.exists()) {
            assertTrue(parent.delete());
        }
    }
}
