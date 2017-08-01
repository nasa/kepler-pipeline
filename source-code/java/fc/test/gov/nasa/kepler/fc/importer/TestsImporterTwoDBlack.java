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

import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.fc.twodblack.TwoDBlackOperations;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.fc.TwoDBlackImage;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class TestsImporterTwoDBlack {

    private static final int MODULE = 9;
    private static final int OUTPUT = 3;

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

    public void loadStuff(int module, int output) throws IOException {
        ImporterTwoDBlack importer = new ImporterTwoDBlack();
        String[] args = new String[3];
        args[0] = "load";
        args[1] = "TestImporterTwoDBlack load";
        args[2] = "fake-black2d-mod2out1.*";
        try {
            dbService.beginTransaction();
            importer.appendNew(module, output, "TestImporterTwoDBlack load",
                new Date());
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
    }

    @Test
    public void testImportIntegrity() throws Exception {

        ImporterTwoDBlack importer = new ImporterTwoDBlack();

        // Get twoDBlacks from file, via importer:
        //
        List<TwoDBlackImage> importerTwoDBlacks = new ArrayList<TwoDBlackImage>();
        List<Double> mjds = new ArrayList<Double>();
        List<Pair<Integer, Integer>> modOuts = new ArrayList<Pair<Integer, Integer>>();
        String[] twoDBlackFiles = new ImporterTwoDBlack().getDataFilenames(
            ImporterTwoDBlack.DATAFILE_REGEX,
            ImporterTwoDBlack.DATAFILE_DIRECTORY_NAME);

        // for (String twoDBlackFile : twoDBlackFiles[0]) {
        for (int ii = 0; ii < 1; ++ii) {
            String twoDBlackFile = twoDBlackFiles[ii];
            importerTwoDBlacks.add(importer.parseFile(twoDBlackFile));
            mjds.add(importer.getMjdFromFile(twoDBlackFile));
            modOuts.add(importer.getModuleOutputNumberFromFile(twoDBlackFile));
            
            Pair<Integer, Integer> modOut = modOuts.get(modOuts.size() - 1);
            loadStuff(modOut.left, modOut.right);
        }

        // Get twoDBlacks from db for the MJD from the twoDBlackFile:
        //
        List<TwoDBlackImage> databaseTwoDBlacks = new ArrayList<TwoDBlackImage>();
        TwoDBlackOperations ops = new TwoDBlackOperations();
        for (int ii = 0; ii < importerTwoDBlacks.size(); ++ii) {
            TwoDBlackImage twoDBlack = ops.retrieveTwoDBlackImage(mjds.get(ii),
                modOuts.get(ii).left, modOuts.get(ii).right);
            databaseTwoDBlacks.add(twoDBlack);
        }

        // Check for sameness:
        //
        reflectionEquals.excludeField(".*\\.id");
        reflectionEquals.excludeField(".*\\.history");
        reflectionEquals.assertEquals(importerTwoDBlacks, databaseTwoDBlacks);
    }

    @Test
    public void TestAppendNewNominal() throws IOException {
        ImporterTwoDBlack importer = new ImporterTwoDBlack();
        try {
            dbService.beginTransaction();
            importer.appendNew(MODULE, OUTPUT, SocEnvVars.getLocalTestDataDir()
                + "/fc/two-d-black/v2", "this should work", new Date());
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
        try {
            dbService.beginTransaction();
            importer.appendNew(MODULE, OUTPUT, SocEnvVars.getLocalTestDataDir()
                + "/fc/two-d-black/v3",
                "this should work; the v2 data has a later MJD", new Date());
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
    }

    @Test
    public void TestRewriteHistoryNominal() throws
        IOException {
        ImporterTwoDBlack importer = new ImporterTwoDBlack();
        try {
            dbService.beginTransaction();
            importer.rewriteHistory(MODULE, OUTPUT,
                SocEnvVars.getLocalTestDataDir() + "/fc/two-d-black/v2",
                "this should work");
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
        try {
            dbService.beginTransaction();
            importer.rewriteHistory(MODULE, OUTPUT,
                SocEnvVars.getLocalTestDataDir() + "/fc/two-d-black/v3",
                "this should also work");
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
    }

    @Test(expected = FocalPlaneException.class)
    public void TestAppendNewFail() throws IOException {
        ImporterTwoDBlack importer = new ImporterTwoDBlack();
        try {
            dbService.beginTransaction();
            importer.appendNew(MODULE, OUTPUT, SocEnvVars.getLocalTestDataDir()
                + "/fc/two-d-black/v3", "this should work", new Date());
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
        try {
            dbService.beginTransaction();
            importer.appendNew(MODULE, OUTPUT, SocEnvVars.getLocalTestDataDir()
                + "/fc/two-d-black/v2", "this should fail", new Date());
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
    }
}