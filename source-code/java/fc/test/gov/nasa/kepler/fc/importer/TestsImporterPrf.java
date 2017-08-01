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

import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.fc.prf.PrfModel;
import gov.nasa.kepler.fc.prf.PrfOperations;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.Prf;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class TestsImporterPrf {
    private static DatabaseService dbService;

    private static final int CCD_MODULE = 19;
    private static final int CCD_OUTPUT = 3;

    int[] CHANNELS = { 19, 67 };

    private ReflectionEquals reflectionEquals = new ReflectionEquals();

    public static String[] names = {
        "kplr2008081921-244_prf.bin",
        "kplr2008081921-021_prf.bin",

        // leading zeros
        "kplr2008081921-244_prf.bin",
        "kplr2008081921-021_prf.bin",

        // fractional dates
        "kplr2008081921-244_prf.bin",
        "kplr2008081921-021_prf.bin",

        // Full paths:
        "/path/to/kplr2008081921-244_prf.bin",
        "/path/to/kplr2008081921-021_prf.bin",

        // leading zeros
        "/path/to/kplr2008081921-244_prf.bin",
        "/path/to/kplr2008081921-021_prf.bin",

        // fractional dates
        "/path/to/kplr2008081921-244_prf.bin",
        "/path/to/kplr2008081921-021_prf.bin" };

    public static int[] correctModules = new int[] { 24, 2, 24, 2, 24, 2, 24,
        2, 24, 2, 24, 2 };
    public static int[] correctOutputs = new int[] { 4, 1, 4, 1, 4, 1, 4, 1, 4,
        1, 4, 1 };

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

        ImporterPrf importer = new ImporterPrf();
        try {
            dbService.beginTransaction();
            importer.rewriteHistory(CHANNELS, "TestsImporterPrf rewriteHistory");
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
    }

    @Test
    public void TestFilenameParsing() throws NumberFormatException, IOException {
        System.out.println("start TestFilenameParsing " + new Date());
        ImporterPrf importer = new ImporterPrf();

        for (int ii = 0; ii < names.length; ++ii) {
            String name = names[ii];
            int module = importer.getModuleNumberFromFile(name);
            int output = importer.getOutputNumberFromFile(name);

            assertTrue(module == correctModules[ii]);
            assertTrue(output == correctOutputs[ii]);
        }
        System.out.println("end TestFilenameParsing " + new Date());
    }

    @Test
    public void TestRun() {
        System.out.println("start TestRun " + new Date());
        ImporterPrf importer = new ImporterPrf();

        try {
            dbService.beginTransaction();
            importer.rewriteHistory(CCD_MODULE, CCD_OUTPUT,
                "TestsImporterPrf load");
            dbService.commitTransaction();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            dbService.rollbackTransactionIfActive();
        }
        System.out.println("end TestRun " + new Date());
    }

    @Test
    public void testImportIntegrity() throws Exception {
        System.out.println("start testImportIntegrity " + new Date());
        loadStuff();
        double now = ModifiedJulianDate.dateToMjd(new Date());

        ImporterPrf importer = new ImporterPrf();

        // Get prfs from file, via importer:
        //
        List<Prf> importerPrfs = new ArrayList<Prf>();
        List<Integer> modules = new ArrayList<Integer>();
        List<Integer> outputs = new ArrayList<Integer>();

        String[] prfFiles = new ImporterPrf().getDataFilenames(
            ImporterPrf.DATAFILE_REGEX, ImporterPrf.DATAFILE_DIRECTORY_NAME);
        for (int ii = 0; ii < 1; ++ii) {
            String prfFile = prfFiles[ii];
            importerPrfs.add(importer.parseFile(prfFile));
            modules.add(importer.getModuleNumberFromFile(prfFile));
            outputs.add(importer.getModuleNumberFromFile(prfFile));
        }

        // Get prfs from db for the MJD from the prfFile:
        //
        List<Prf> databasePrfs = new ArrayList<Prf>();
        FcCrud fcCrud = new FcCrud();
        for (int ii = 0; ii < importerPrfs.size(); ++ii) {
            Prf prf = fcCrud.retrievePrf(now, CCD_MODULE, CCD_OUTPUT);
            assertTrue(prf != null);
            databasePrfs.add(prf);
        }

        // Check for sameness:
        //
        reflectionEquals.excludeField(".*\\.id");
        reflectionEquals.excludeField(".*\\.history");
        // reflectionEquals.assertEquals(importerPrfs, databasePrfs);

        System.out.println("end testImportIntegrity " + new Date());
    }

    @Test
    public void TestAppendNewNominal() throws IOException {
        System.out.println("start TestAppendNewNominal " + new Date());
        ImporterPrf importer = new ImporterPrf();
        try {
            dbService.beginTransaction();
            importer.rewriteHistory(2, 1, SocEnvVars.getLocalTestDataDir()
                + "/fc/prf/v1", "this should work");
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
        try {
            dbService.beginTransaction();
            importer.rewriteHistory(2, 1, SocEnvVars.getLocalTestDataDir()
                + "/fc/prf/v2", "this should work");
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
        System.out.println("end TestAppendNewNominal " + new Date());
    }

    @Test
    public void TestRewriteHistoryNominal() throws
        IOException {
        System.out.println("start TestRewriteHistoryNominal " + new Date());
        ImporterPrf importer = new ImporterPrf();
        try {
            dbService.beginTransaction();
            importer.rewriteHistory(2, 1, "this should work");
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
        try {
            dbService.beginTransaction();
            importer.rewriteHistory(2, 1, "this should also work");
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
        System.out.println("end TestRewriteHistoryNominal " + new Date());
    }

    @Test
    public void TestChannels() throws IOException {
        System.out.println("start TestChannels " + new Date());
        loadStuff();

        PrfOperations prfOperations = new PrfOperations();

        for (int channel : CHANNELS) {
            Pair<Integer, Integer> moduleOutput = FcConstants.getModuleOutput(channel);
            int ccdModule = moduleOutput.left;
            int ccdOutput = moduleOutput.right;
            PrfModel prfModel = prfOperations.retrieveMostRecentPrfModel(
                ccdModule, ccdOutput);
            assert prfModel.getCcdModule() > 1 && prfModel.getCcdModule() < 25;
            assert prfModel.getCcdOutput() > 0 && prfModel.getCcdOutput() < 4;
        }
        System.out.println("end TestChannels " + new Date());
    }

}
