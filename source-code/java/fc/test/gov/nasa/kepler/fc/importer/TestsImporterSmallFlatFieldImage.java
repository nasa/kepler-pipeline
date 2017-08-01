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
import gov.nasa.kepler.fc.flatfield.FlatFieldOperations;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.fc.SmallFlatFieldImage;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class TestsImporterSmallFlatFieldImage {
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
        ImporterSmallFlatField importer = new ImporterSmallFlatField();
        try {
            dbService.beginTransaction();
            importer.rewriteHistory(module, output,
                "TestsImporterSmallFlatFieldImage loadStuff");
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
    }

    @Test
    public void testImportIntegrity() throws Exception {

        int numImports = 1;

        ImporterSmallFlatField importer = new ImporterSmallFlatField();

        String[] flatFieldFiles = new ImporterSmallFlatField().getDataFilenames(
            ImporterSmallFlatField.DATAFILE_REGEX,
            ImporterSmallFlatField.DATAFILE_DIRECTORY_NAME);

        // Get small flats from file, via importer:
        //
        List<SmallFlatFieldImage> importerFlats = new ArrayList<SmallFlatFieldImage>();
        // for (String flatFile : flatFieldFiles[0]) {
        for (int ii = 0; ii < numImports; ++ii) {
            String flatFile = flatFieldFiles[ii];
            importerFlats.add(importer.parseFile(flatFile));
        }

        // Get small flats from db for the MJD from the prfFile:
        //
        List<SmallFlatFieldImage> databaseFlats = new ArrayList<SmallFlatFieldImage>();
        FlatFieldOperations ops = new FlatFieldOperations();
        for (int ii = 0; ii < numImports; ++ii) {
            String filename = flatFieldFiles[ii];

            double mjd = importer.getMjdFromFile(filename);
            Pair<Integer, Integer> modOut = importer.getModuleOutputNumberFromFile(filename);
            
            loadStuff(modOut.left, modOut.right);

            SmallFlatFieldImage flat = ops.retrieveSmallFlatFieldImageExact(
                mjd, modOut.left, modOut.right);
            databaseFlats.add(flat);
        }

        // Check for sameness:
        //
        reflectionEquals.excludeField(".*\\.id");
        reflectionEquals.excludeField(".*\\.history");
        reflectionEquals.assertEquals(importerFlats, databaseFlats);
    }

    @Test
    public void TestAppendNewNominal() throws IOException {
        ImporterSmallFlatField importer = new ImporterSmallFlatField();
        try {
            dbService.beginTransaction();
            importer.rewriteHistory(2, 1, SocEnvVars.getLocalTestDataDir()
                + "/fc/small-flat/v1", "this should work");
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
        try {
            dbService.beginTransaction();
            importer.rewriteHistory(2, 1, SocEnvVars.getLocalTestDataDir()
                + "/fc/small-flat/v2",
                "this should work; the v2 data has a later MJD");
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
    }

    @Test
    public void TestRewriteHistoryNominal() throws
        IOException {
        ImporterSmallFlatField importer = new ImporterSmallFlatField();
        try {
            dbService.beginTransaction();
            importer.rewriteHistory(2, 1, SocEnvVars.getLocalTestDataDir()
                + "/fc/small-flat/v1", "this should work");
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
        try {
            dbService.beginTransaction();
            importer.rewriteHistory(2, 1, SocEnvVars.getLocalTestDataDir()
                + "/fc/small-flat/v2", "this should also work");
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
            dbService.closeCurrentSession();
        }
    }

}
