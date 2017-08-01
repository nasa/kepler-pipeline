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

package gov.nasa.kepler.cm;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.hibernate.cm.Characteristic;
import gov.nasa.kepler.hibernate.cm.CharacteristicCrud;
import gov.nasa.kepler.hibernate.cm.CharacteristicType;
import gov.nasa.kepler.hibernate.cm.Kic.Field;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Collection;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class CharacteristicsImporterTest {

    private static final double VALUE = 1.1;
    private static final double UPDATED_VALUE = 2.2;
    private static final int KEPLER_ID = 3;
    private static final String FORMAT = "%f";

    @Before
    public void setUp() throws Exception {
        TestUtils.setUpDatabase(DatabaseServiceFactory.getInstance());
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(DatabaseServiceFactory.getInstance());
    }

    @Test
    public void testReplace() throws Exception {
        testReplace(VALUE);
    }

    private void testReplace(double value) throws IOException {
        File characteristicsImportDir = new File(Filenames.BUILD_TMP + "/char");
        FileUtil.cleanDir(characteristicsImportDir);

        BufferedWriter characteristicTypeFile = new BufferedWriter(
            new FileWriter(new File(characteristicsImportDir, "t-char-ra.mrg")));
        characteristicTypeFile.write(Field.RA + "|" + FORMAT + "\n");
        characteristicTypeFile.close();

        BufferedWriter characteristicsFile = new BufferedWriter(new FileWriter(
            new File(characteristicsImportDir, "r-char-ra.mrg")));
        characteristicsFile.write(KEPLER_ID + "|" + Field.RA + "|" + value
            + "\n");
        characteristicsFile.close();

        DatabaseServiceFactory.getInstance()
            .beginTransaction();
        CharacteristicsImporter characteristicsImporter = new CharacteristicsImporter();
        characteristicsImporter.replaceCharacteristics(characteristicsImportDir);
        DatabaseServiceFactory.getInstance()
            .commitTransaction();

        DatabaseServiceFactory.getInstance()
            .closeCurrentSession();

        CharacteristicCrud characteristicCrud = new CharacteristicCrud();
        Collection<CharacteristicType> actualTypes = characteristicCrud.retrieveAllCharacteristicTypes();

        CharacteristicType expectedType = new CharacteristicType(
            Field.RA.toString(), FORMAT);
        Collection<CharacteristicType> expectedTypes = ImmutableList.of(expectedType);
        assertEquals(expectedTypes, actualTypes);

        List<Characteristic> actualCharacteristics = characteristicCrud.retrieveCharacteristics(KEPLER_ID);

        List<Characteristic> expectedCharacteristics = ImmutableList.of(new Characteristic(
            KEPLER_ID, expectedType, value));
        assertEquals(expectedCharacteristics, actualCharacteristics);
    }

    @Test
    public void testReplaceWithUpdatedValue() throws Exception {
        testReplace(VALUE);

        testReplace(UPDATED_VALUE);
    }

    @Test
    public void testAppend() throws IOException {
        double value1 = 1.1;
        double value2 = 2.2;
        int quarter1 = 15;
        int quarter2 = 16;

        testAppend(value1, quarter1);
        testAppend(value2, quarter2);

        CharacteristicCrud characteristicCrud = new CharacteristicCrud();
        Collection<CharacteristicType> actualTypes = characteristicCrud.retrieveAllCharacteristicTypes();

        CharacteristicType expectedType = new CharacteristicType(
            Field.RA.toString(), FORMAT);
        Collection<CharacteristicType> expectedTypes = ImmutableList.of(expectedType);
        assertEquals(expectedTypes, actualTypes);

        List<Characteristic> actualCharacteristics1 = characteristicCrud.retrieveCharacteristics(
            KEPLER_ID, quarter1);

        List<Characteristic> expectedCharacteristics1 = ImmutableList.of(new Characteristic(
            KEPLER_ID, expectedType, value1, quarter1));
        assertEquals(expectedCharacteristics1, actualCharacteristics1);

        List<Characteristic> actualCharacteristics2 = characteristicCrud.retrieveCharacteristics(
            KEPLER_ID, quarter2);

        List<Characteristic> expectedCharacteristics2 = ImmutableList.of(new Characteristic(
            KEPLER_ID, expectedType, value2, quarter2));
        assertEquals(expectedCharacteristics2, actualCharacteristics2);
    }

    private void testAppend(double value, int quarter) throws IOException {
        File characteristicsImportDir = new File(Filenames.BUILD_TMP + "/char");
        FileUtil.cleanDir(characteristicsImportDir);

        BufferedWriter characteristicTypeFile = new BufferedWriter(
            new FileWriter(new File(characteristicsImportDir, "t-char-ra.mrg")));
        characteristicTypeFile.write(Field.RA + "|" + FORMAT + "\n");
        characteristicTypeFile.close();

        BufferedWriter characteristicsFile = new BufferedWriter(new FileWriter(
            new File(characteristicsImportDir, "r-char-ra.mrg")));
        characteristicsFile.write(KEPLER_ID + "|" + Field.RA + "|" + value
            + "\n");
        characteristicsFile.close();

        DatabaseServiceFactory.getInstance()
            .beginTransaction();
        CharacteristicsImporter characteristicsImporter = new CharacteristicsImporter();
        characteristicsImporter.appendCharacteristics(characteristicsImportDir,
            quarter);
        DatabaseServiceFactory.getInstance()
            .commitTransaction();

        DatabaseServiceFactory.getInstance()
            .closeCurrentSession();
    }

    @Test
    public void testAppendWithExistingQuarter() throws IOException {
        double value1 = 1.1;
        double value2 = 2.2;
        double value3 = 3.3;
        int quarter1 = 15;
        int quarter2 = 16;

        testAppend(value1, quarter1);
        testAppend(value2, quarter2);
        testAppend(value3, quarter1);

        CharacteristicCrud characteristicCrud = new CharacteristicCrud();
        Collection<CharacteristicType> actualTypes = characteristicCrud.retrieveAllCharacteristicTypes();

        CharacteristicType expectedType = new CharacteristicType(
            Field.RA.toString(), FORMAT);
        Collection<CharacteristicType> expectedTypes = ImmutableList.of(expectedType);
        assertEquals(expectedTypes, actualTypes);

        List<Characteristic> actualCharacteristics1 = characteristicCrud.retrieveCharacteristics(
            KEPLER_ID, quarter1);

        List<Characteristic> expectedCharacteristics1 = ImmutableList.of(new Characteristic(
            KEPLER_ID, expectedType, value3, quarter1));
        assertEquals(expectedCharacteristics1, actualCharacteristics1);

        List<Characteristic> actualCharacteristics2 = characteristicCrud.retrieveCharacteristics(
            KEPLER_ID, quarter2);

        List<Characteristic> expectedCharacteristics2 = ImmutableList.of(new Characteristic(
            KEPLER_ID, expectedType, value2, quarter2));
        assertEquals(expectedCharacteristics2, actualCharacteristics2);
    }
}
