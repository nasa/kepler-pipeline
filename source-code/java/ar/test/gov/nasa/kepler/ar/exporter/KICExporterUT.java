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
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.ar.ProgressIndicator;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class KICExporterUT implements ProgressIndicator {
    private int kicID = 0;
    private int progressCount = 0;
    private String progressMessage = null;
    private final String goodPrefix = "1.0000000|-2.000000|3.0000|-4.0000|5.000|"
        + "6.000|7.000|8.000|9.000|10.000|11.000|12.000|13.000|"
        + "14.000|15.000|";
    private final String goodSuffix = "16|17|18|20|11|1|0|21|2.200|2.300|2.400|"
        + "2.500|26.000|Use the source Luke|27|28|29|30|"
        + "-3.1000|32.000000|-33.000000|34.0000|3.500|3.600|3.700";

    private Kic generateKIC() {
        Kic kic = new Kic.Builder(kicID++, 1.0F, -2.0F).raProperMotion(3.0f)
            .decProperMotion(-4.0f)
            .uMag(5.0f)
            .gMag(6.0f)
            .rMag(7.0f)
            .iMag(8.0f)
            .zMag(9.0f)
            .gredMag(10.0f)
            .d51Mag(11.0f)
            .twoMassJMag(12.0f)
            .twoMassHMag(13.0f)
            .twoMassKMag(14.0f)
            .keplerMag(15.0f)
            .twoMassId(16)
            .internalScpId(17)
            .alternateId(18)
            .alternateSource(20)
            .galaxyIndicator(11)
            .blendIndicator(1)
            .variableIndicator(0)
            .effectiveTemp(21)
            .log10SurfaceGravity(2.2f)
            .log10Metallicity(2.3f)
            .ebMinusVRedding(2.4f)
            .avExtinction(2.5f)
            .radius(26.0f)
            .source("Use the source Luke")
            .photometryQuality(27)
            .astrophysicsQuality(28)
            .catalogId(29)
            .scpId(30)
            .parallax(-3.1f)
            .galacticLongitude(32.0)
            .galacticLatitude(-33.0)
            .totalProperMotion(34.0f)
            .grColor(3.5f)
            .jkColor(3.6f)
            .gkColor(3.7f)
            .skyGroupId(1)
            .build();
        return kic;
    }

    private File getOutputFile() {
        if (File.separatorChar == '/') {
            return new File(Filenames.BUILD_TEST + "/KICExporterUT.txt");
        } else {
            return new File("c:\\KICExporterUT.txt");
        }
    }

    @Before
    public void setUp() throws Exception {
        DatabaseServiceFactory.getInstance()
            .getDdlInitializer()
            .initDB();
        Session session = DatabaseServiceFactory.getInstance()
            .getSession();
        Transaction tx = null;
        try {
            tx = session.getTransaction();
            tx.begin();
            for (int i = 0; i < 10; i++) {
                Kic kic = generateKIC();
                session.save(kic);
            }
            tx.commit();
        } finally {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
        }
    }

    /** Required by progress indicator interface. */
    public void progress(int count, String message) {
        progressCount = count;
        progressMessage = message;
    }

    @After
    public void tearDown() throws Exception {
        DatabaseServiceFactory.getInstance()
            .closeCurrentSession();
        DatabaseServiceFactory.getInstance()
            .getDdlInitializer()
            .cleanDB();
        getOutputFile().delete();
    }

    @Test
    public void testExport() throws IOException {
        InputCatalogExporter x = new InputCatalogExporter();
        String currentKICVersion = KicCrud.getKicVersion();
        ExportOptions xo = new ExportOptions(0, Integer.MAX_VALUE,
            getOutputFile(), currentKICVersion);

        x.export(this, xo);
        assertEquals(10, progressCount);
        assertNotNull(progressMessage, "progressMessage");

        BufferedReader br = new BufferedReader(new FileReader(getOutputFile()));
        String header = br.readLine();
        assertTrue("timestamp", header.indexOf(" timestamp") != -1);
        assertTrue(header.indexOf("version") != -1);
        int kicId = 0;
        for (String data = br.readLine(); !data.startsWith("#"); kicId++, data = br.readLine()) {

            assertEquals(goodPrefix + kicId + "|" + goodSuffix, data);
        }
        br.close();

    }

    @Test
    public void testLengthOfTask() {
        InputCatalogExporter x = new InputCatalogExporter();
        String currentKICVersion = KicCrud.getKicVersion();
        ExportOptions xo = new ExportOptions(0, Integer.MAX_VALUE, null,
            currentKICVersion);

        int lot = x.lengthOfTask(xo);
        assertEquals(10, lot);
    }

    public void progress(Throwable t, String message) {
        System.err.println(message);
        t.printStackTrace();
        assertTrue(false);
    }
}
