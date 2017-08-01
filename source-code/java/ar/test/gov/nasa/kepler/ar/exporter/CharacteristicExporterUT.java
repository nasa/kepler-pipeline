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

package gov.nasa.kepler.ar.exporter;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import gov.nasa.kepler.ar.ProgressIndicator;
import gov.nasa.kepler.hibernate.cm.Characteristic;
import gov.nasa.kepler.hibernate.cm.CharacteristicType;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;

import org.hibernate.Session;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class CharacteristicExporterUT implements ProgressIndicator {
    private int progressCount;
    private String progressMessage;
    private int sequence = 0;

    private Kic generateKic() {
        return new Kic.Builder(++sequence, 0, 0).build();
    }

    private Characteristic generateCharacteristicForType(Kic kic,
        CharacteristicType cType) {

        sequence++;

        return new Characteristic(kic.getKeplerId(), cType, sequence++);
    }

    private CharacteristicType generateCharacteristicType(String mnemonic) {
        sequence++;

        return new CharacteristicType(mnemonic, "%05.2f");
    }

    @Before
    public void setUp() throws Exception {
        progressCount = 0;
        progressMessage = null;

        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        dbService.getDdlInitializer().initDB();
        dbService.beginTransaction();
        Session session = DatabaseServiceFactory.getInstance().getSession();

        try {
            String[] names = new String[] { "variability", "crowding",
                "expectedCDPP", "target rank", "stellar type", "active pixels" };
            CharacteristicType[] types = new CharacteristicType[names.length];
            for (int i = 0; i < names.length; i++) {
                types[i] = generateCharacteristicType(names[i]);
                session.save(types[i]);
            }
            for (int i = 0; i < 10; i++) {
                for (CharacteristicType ct : types) {
                    Kic kic = generateKic();
                    Characteristic c = generateCharacteristicForType(kic, ct);
                    session.save(kic);
                    session.save(c);
                }
            }
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
        }
    }

    private File getOutputFile() {
        File outputFile = new File(Filenames.BUILD_TEST
            + "/CharacteristicExporterUT.test.txt");
        outputFile.getParentFile().mkdirs();
        return outputFile;
    }

    @After
    public void tearDown() throws Exception {
        DatabaseServiceFactory.getInstance().closeCurrentSession();
        DatabaseServiceFactory.getInstance().getDdlInitializer().cleanDB();
    }

    @Test
    public void testLengthOfTask() throws Exception {
        CharacteristicExporter exp = new CharacteristicExporter();
        ExportOptions xo = new ExportOptions(1, 1000, getOutputFile(), "1");

        int lot = exp.lengthOfTask(xo);
        assertEquals(60, lot);
    }

    @Test
    public void testExport() throws Exception {
        CharacteristicExporter exp = new CharacteristicExporter();
        ExportOptions xo = new ExportOptions(1, 1000, getOutputFile(), "1");
        exp.export(this, xo);

        assertEquals(60, progressCount);
        assertNotNull(progressMessage);
    }

    public void progress(int progress, String message) {
        progressCount = progress;
        progressMessage = message;
    }

    public void progress(Throwable t, String message) {
        System.err.println(message);
        t.printStackTrace();
    }
}
