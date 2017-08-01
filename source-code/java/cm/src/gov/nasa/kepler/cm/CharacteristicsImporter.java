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

import gov.nasa.kepler.hibernate.cm.Characteristic;
import gov.nasa.kepler.hibernate.cm.CharacteristicCrud;
import gov.nasa.kepler.hibernate.cm.CharacteristicType;
import gov.nasa.kepler.hibernate.dbservice.TransactionWrapper;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Imports {@link Characteristic}s and {@link CharacteristicType}s into the
 * database.
 * 
 * @author Miles Cote
 * 
 */
public class CharacteristicsImporter {

    private static final Log log = LogFactory.getLog(CharacteristicsImporter.class);

    private static final String CHAR_FILE_SUFFIX = ".mrg";
    private CharacteristicCrud characteristicCrud;
    private Map<String, CharacteristicType> nameToCharacteristicTypeMap;

    public void replaceCharacteristics(File charImportDir) throws IOException {
        characteristicCrud = new CharacteristicCrud();
        nameToCharacteristicTypeMap = new HashMap<String, CharacteristicType>();

        log.info("Ingest char types.");
        for (File file : charImportDir.listFiles()) {
            if (file.getName()
                .startsWith("t-") && file.getName()
                .endsWith(CHAR_FILE_SUFFIX)) {
                replaceCharacteristicTypes(file);
            }
        }

        log.info("Ingest char values.");
        for (File file : charImportDir.listFiles()) {
            if (file.getName()
                .startsWith("r-") && file.getName()
                .endsWith(CHAR_FILE_SUFFIX)) {
                // Pass null, since there is no quarter info for the target
                // management case.
                ingestCharacteristicValues(file, null);
            }
        }
    }

    private void replaceCharacteristicTypes(File file) throws IOException {
        BufferedReader br = new BufferedReader(new FileReader(
            file.getAbsolutePath()));

        for (String s = br.readLine(); s != null; s = br.readLine()) {
            String[] strings = s.split("\\|");
            String name = strings[0];
            String format = strings[1];

            // Delete existing characteristics and type.
            deleteExisting(name);

            CharacteristicType characteristicType = new CharacteristicType(
                name, format);
            characteristicCrud.create(characteristicType);

            nameToCharacteristicTypeMap.put(name, characteristicType);
        }

        br.close();
    }

    private void deleteExisting(String name) {
        CharacteristicType characteristicType = characteristicCrud.retrieveCharacteristicType(name);

        if (characteristicType != null) {
            characteristicCrud.delete(characteristicType);
        }
    }

    private void ingestCharacteristicValues(File file, Integer quarter)
        throws IOException {
        log.info("Ingesting characteristic values from file: " + file);

        BufferedReader br = new BufferedReader(new FileReader(
            file.getAbsolutePath()));

        int lineCount = 0;
        for (String s = br.readLine(); s != null; s = br.readLine()) {
            if (lineCount % 10000 == 0) {
                log.info("Ingested " + lineCount
                    + " characteristic values so far.");
            }

            String[] strings = s.split("\\|");
            String keplerId = strings[0];
            String name = strings[1];
            String value = strings[2];

            CharacteristicType characteristicType = nameToCharacteristicTypeMap.get(name);

            Characteristic characteristic = new Characteristic(
                Integer.valueOf(keplerId), characteristicType,
                Double.valueOf(value), quarter);
            characteristicCrud.create(characteristic);

            lineCount++;
        }
        log.info("Ingested " + lineCount + " characteristic values so far.");

        br.close();
    }

    public void appendCharacteristics(File charImportDir, int quarter)
        throws IOException {
        characteristicCrud = new CharacteristicCrud();
        nameToCharacteristicTypeMap = new HashMap<String, CharacteristicType>();

        log.info("Replace existing characteristics for this quarter with the given characteristics.");
        characteristicCrud.deleteCharacteristics(quarter);

        log.info("Ingest char types.");
        for (File file : charImportDir.listFiles()) {
            if (file.getName()
                .startsWith("t-") && file.getName()
                .endsWith(CHAR_FILE_SUFFIX)) {
                appendCharacteristicTypes(file);
            }
        }

        log.info("Ingest char values.");
        for (File file : charImportDir.listFiles()) {
            if (file.getName()
                .startsWith("r-") && file.getName()
                .endsWith(CHAR_FILE_SUFFIX)) {
                ingestCharacteristicValues(file, quarter);
            }
        }
    }

    private void appendCharacteristicTypes(File file) throws IOException {
        BufferedReader br = new BufferedReader(new FileReader(
            file.getAbsolutePath()));

        for (String s = br.readLine(); s != null; s = br.readLine()) {
            String[] strings = s.split("\\|");
            String name = strings[0];
            String format = strings[1];

            CharacteristicType characteristicType = characteristicCrud.retrieveCharacteristicType(name);
            if (characteristicType == null) {
                characteristicType = new CharacteristicType(name, format);
                characteristicCrud.create(characteristicType);
            }

            nameToCharacteristicTypeMap.put(name, characteristicType);
        }

        br.close();
    }

    public static void main(final String[] args) {
        if (args.length != 2 && args.length != 3) {
            System.err.println("USAGE:import-characteristics COMMAND ARGS");
            System.err.println("  import-characteristics replace CHAR_IMPORT_DIR");
            System.err.println("  import-characteristics append CHAR_IMPORT_DIR QUARTER_NUMBER");
            System.err.println("  CHAR_IMPORT_DIR: directory that contains t-* and r-* files to import");
            System.err.println("");
            System.err.println("EXAMPLES:");
            System.err.println("");
            System.err.println("  The following command deletes all existing characteristics from the database "
                + "and imports characteristics from the given directory. This is the historical behavior and "
                + "is intended for use by target management.");
            System.err.println("    import-characteristics replace /path/to/char-table/smoke-test/");
            System.err.println("");
            System.err.println("  The following command leaves existing characteristics in the database and "
                + "appends characteristics from the given directory as characteristics for a given quarter. If "
                + "characteristics already exist for the given quarter, then they are replaced with the "
                + "given characteristics. This is the new behavior and is intended for use by the science pipeline.");
            System.err.println("    import-characteristics append /path/to/char-table/smoke-test/ 15");
            System.exit(-1);
        }

        TransactionWrapper.run(new Runnable() {
            @Override
            public void run() {
                try {
                    CharacteristicsImporter characteristicsImporter = new CharacteristicsImporter();

                    String command = args[0];

                    File charImportDir = new File(args[1]);
                    if (!charImportDir.exists()) {
                        throw new IllegalArgumentException(
                            "The charImportDir cannot be missing."
                                + "\n  charImportDir: " + charImportDir);
                    }

                    if (command.equals("replace")) {
                        characteristicsImporter.replaceCharacteristics(charImportDir);
                    } else if (command.equals("append")) {
                        if (args.length != 3) {
                            throw new IllegalArgumentException(
                                "The append command cannot be missing args.");
                        }
                        int quarter = Integer.parseInt(args[2]);

                        characteristicsImporter.appendCharacteristics(
                            charImportDir, quarter);
                    } else {
                        throw new IllegalArgumentException(
                            "Unexpected command." + "\n  command: " + command);
                    }
                } catch (Exception e) {
                    throw new IllegalArgumentException("Unable to import.", e);
                }
            }
        });
    }
}
