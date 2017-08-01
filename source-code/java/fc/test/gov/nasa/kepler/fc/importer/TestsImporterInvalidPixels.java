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

package gov.nasa.kepler.fc.importer;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.fc.PixelModel;
import gov.nasa.kepler.fc.invalidpixels.PixelOperations;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.fc.Pixel;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class TestsImporterInvalidPixels {
    private static DatabaseService dbService;

    private ReflectionEquals reflectionEquals = new ReflectionEquals();

    @Before
    public void setUp() throws Exception {

        dbService = DatabaseServiceFactory.getInstance();

        TestUtils.setUpDatabase(dbService);
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(dbService);
    }

    public void loadStuff() throws IOException {
        ImporterInvalidPixels importer = new ImporterInvalidPixels();
        try {
            dbService.beginTransaction();
            importer.appendNew(SocEnvVars.getLocalTestDataDir()
                + "/fc/invalid-pixels/v1/", "TestsImporterPixel loadStuff",
                new Date());
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
    }

    @Test
    public void testImportIntegrity() throws Exception {
        loadStuff();

        ImporterInvalidPixels importer = new ImporterInvalidPixels();

        String[] pixelFiles = ImporterParentNonImage.getDataFilenames(
            ImporterInvalidPixels.DATAFILE_REGEX,
            SocEnvVars.getLocalTestDataDir() + "/fc/invalid-pixels/v1/");
        for (String pixelFile : pixelFiles) {

            // Get pixels from file, via importer:
            //
            List<Pixel> importerPixels = importer.parseFile(pixelFile);

            // Get pixels from db for the MJD from the pixelFile:
            //
            List<Pixel> databasePixels = new ArrayList<Pixel>();
            PixelOperations ops = new PixelOperations();
            for (Pixel importerPixel : importerPixels) {
                Pixel pixel = ops.retrievePixelExact(importerPixel);
                databasePixels.add(pixel);
            }

            // Check for sameness:
            //
            for (int ii = 0; ii < databasePixels.size(); ++ii) {
                assertEquals(databasePixels.get(ii)
                    .getCcdModule(), importerPixels.get(ii)
                    .getCcdModule());
                assertEquals(databasePixels.get(ii)
                    .getCcdOutput(), importerPixels.get(ii)
                    .getCcdOutput());
                assertEquals(databasePixels.get(ii)
                    .getCcdRow(), importerPixels.get(ii)
                    .getCcdRow());
                assertEquals(databasePixels.get(ii)
                    .getCcdColumn(), importerPixels.get(ii)
                    .getCcdColumn());
                assertTrue(Math.abs(databasePixels.get(ii)
                    .getPixelValue() - importerPixels.get(ii)
                    .getPixelValue()) < 0.01);
            }

            reflectionEquals.excludeField(".*\\.id");
            reflectionEquals.excludeField(".*\\.history");
            reflectionEquals.assertEquals(importerPixels, databasePixels);
        }
    }

    @Test
    public void testImportIntegrityModel() throws Exception {
        loadStuff();

        ImporterInvalidPixels importer = new ImporterInvalidPixels();

        // Get pixels from file, via importer:
        //
        String[] pixelFiles = ImporterParentNonImage.getDataFilenames(
            ImporterInvalidPixels.DATAFILE_REGEX,
            SocEnvVars.getLocalTestDataDir() + "/fc/invalid-pixels/v1/");
        List<Pixel> importerPixels = importer.parseFile(pixelFiles[0]);

        // Get pixels from db for the MJD from the pixelFile:
        //
        PixelOperations ops = new PixelOperations();

        // Check for sameness:
        //
        for (Pixel pixel : importerPixels) {
            PixelModel model = ops.retrievePixelModel(pixel.getCcdModule(),
                pixel.getCcdOutput(), pixel.getStartTime(), pixel.getEndTime(),
                pixel.getType());
            assertTrue(model.size() > 0);

            int matches = 0;
            for (int im = 0; im < model.size(); ++im) {
                Pixel modelPixel = model.getPixel(im);
                if (modelPixel.equals(pixel)) {
                    ++matches;
                }
            }
            assertTrue(matches > 0);
        }
    }

    @Test
    public void TestAppendNewNominal() throws IOException {
        ImporterInvalidPixels importer = new ImporterInvalidPixels();
        try {
            dbService.beginTransaction();
            importer.appendNew(SocEnvVars.getLocalTestDataDir()
                + "/fc/invalid-pixels/v1/", "this should also work", new Date());
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
        try {
            dbService.beginTransaction();
            importer.appendNew(SocEnvVars.getLocalTestDataDir()
                + "/fc/invalid-pixels/v2/",
                "this should work; the v2 data has a later MJ", new Date());
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
    }

    @Test
    public void TestRewriteHistoryNominal() throws
        IOException {
        ImporterInvalidPixels importer = new ImporterInvalidPixels();
        try {
            dbService.beginTransaction();
            importer.rewriteHistory(SocEnvVars.getLocalTestDataDir()
                + "/fc/invalid-pixels/v2/", "this should work");
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
        try {
            dbService.beginTransaction();
            importer.rewriteHistory(SocEnvVars.getLocalTestDataDir()
                + "/fc/invalid-pixels/v2/", "this should also work");
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
    }

    @Test
    public void TestChangeExistingNominal() throws
        IOException {
        ImporterInvalidPixels importer = new ImporterInvalidPixels();
        try {
            dbService.beginTransaction();
            importer.appendNew(SocEnvVars.getLocalTestDataDir()
                + "/fc/invalid-pixels/v2/", "this should work", new Date());
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
        try {
            dbService.beginTransaction();
            importer.changeExisting(SocEnvVars.getLocalTestDataDir()
                + "/fc/invalid-pixels/v2/", "this should also work");
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
    }

    @Test(expected = FocalPlaneException.class)
    public void TestAppendNewFail() throws IOException {
        ImporterInvalidPixels importer = new ImporterInvalidPixels();
        try {
            dbService.beginTransaction();
            importer.appendNew(SocEnvVars.getLocalTestDataDir()
                + "/fc/invalid-pixels/v2/", "this should work", new Date());
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }

        try {
            dbService.beginTransaction();
            importer.appendNew(SocEnvVars.getLocalTestDataDir()
                + "/fc/invalid-pixels/v2/", "this should fail", new Date());
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
    }

    @Test(expected = FocalPlaneException.class)
    public void TestChangeExistingFail() throws IOException,
        FocalPlaneException {
        ImporterInvalidPixels importer = new ImporterInvalidPixels();
        try {
            dbService.beginTransaction();
            importer.appendNew(SocEnvVars.getLocalTestDataDir()
                + "/fc/invalid-pixels/v1/", "this should also work", new Date());
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
        try {
            dbService.beginTransaction();
            importer.changeExisting(SocEnvVars.getLocalTestDataDir()
                + "/fc/invalid-pixels/v2/",
                "this should fail; the v2 dates have a different later MJD");
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
    }

}
