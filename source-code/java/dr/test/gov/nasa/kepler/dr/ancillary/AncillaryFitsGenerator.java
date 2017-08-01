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

package gov.nasa.kepler.dr.ancillary;

import static gov.nasa.kepler.common.FitsConstants.*;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.dr.NmGenerator;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapperFactory;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.IOException;

import nom.tam.fits.BinaryTableHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;
import nom.tam.fits.FitsFactory;
import nom.tam.util.BufferedFile;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.xml.DOMConfigurator;

public class AncillaryFitsGenerator {

    private static final Log log = LogFactory.getLog(AncillaryFitsGenerator.class);

    public static void generate(String outDir, int lcPerContact,
        int mnemonicsPerFile, int samplesPerLc) throws FitsException,
        IOException, InterruptedException {
        for (int i = 0; i < lcPerContact; i++) {
            // Create 1 fits file for each cadence in a contact.
            FitsFactory.setUseAsciiTables(false);
            Fits fits = new Fits();

            for (int j = 0; j < mnemonicsPerFile; j++) {
                double[] timestamps = new double[samplesPerLc];
                double[] values = new double[samplesPerLc];

                for (int k = 0; k < samplesPerLc; k++) {
                    timestamps[k] = j + 1;
                    values[k] = j + 1;
                }

                fits.addHDU(Fits.makeHDU(new Object[] { timestamps, values }));

                BinaryTableHDU bhdu = (BinaryTableHDU) fits.getHDU(j + 1);
                bhdu.setColumnName(0, TIME_TCOLUMN, "Mnemonic readout time");
                bhdu.setColumnName(1, "VALUE", "Mnemonic value at readout time");

                bhdu.addValue(MNEMONIC_KW,
                    "mnemonic" + (j + 1), "Mnemonic name");
            }

            File dir = new File(outDir);
            boolean directoryCreated = dir.mkdir();
            if (!directoryCreated) {
                AlertServiceFactory.getInstance()
                    .generateAlert(AncillaryFitsGenerator.class.getName(),
                        "Unable to mkdir.\n  dir: " + dir);
            }

            BufferedFile bf = new BufferedFile(outDir + "kplr" + (i * 1000)
                + "a" + DispatcherWrapperFactory.ANCILLARY, "rw");

            fits.write(bf);
            bf.flush();
            bf.close();
        }

        log.info("Completed creating " + lcPerContact
            + " ancillary fits files.");
    }

    public static void main(String[] args) throws IOException, FitsException,
        InterruptedException {
        DOMConfigurator.configure(Filenames.ETC
            + Filenames.LOG4J_CONFIG);

        File dir = new File(DefaultProperties.getUnitTestDataDir("dr")
            + "/ancillary/contact/");
        FileUtils.forceMkdir(dir);
        FileUtils.cleanDirectory(dir);

        // generate(dir.getAbsolutePath() + "/", 1440, 200, 60);
        generate(dir.getAbsolutePath() + "/", 3, 3, 3);

        NmGenerator.generateNotificationMessage(dir.getAbsolutePath() + "/",
            "aednm");

        log.info("Completed creating .fits files and .sdnm file.");
    }

}
