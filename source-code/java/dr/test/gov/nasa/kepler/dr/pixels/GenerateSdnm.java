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

package gov.nasa.kepler.dr.pixels;

import gov.nasa.kepler.nm.DataProductMessageDocument;
import gov.nasa.kepler.nm.DataProductMessageXB;
import gov.nasa.kepler.nm.FileListXB;
import gov.nasa.kepler.nm.FileXB;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.TimeZone;

import org.apache.xmlbeans.XmlOptions;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class GenerateSdnm {

    private static final int CADENCE_ZERO_YEAR = 2008;
    private static final int CADENCE_ZERO_MONTH = Calendar.DECEMBER;
    private static final int CADENCE_ZERO_DAY = 13;

    public GenerateSdnm() {
    }

    /**
     * @throws Exception
     * 
     */
    public void generate(String destinationFileName) throws Exception {

        DataProductMessageDocument doc = DataProductMessageDocument.Factory.newInstance();
        DataProductMessageXB dataProductMessage = doc.addNewDataProductMessage();

        dataProductMessage.setMessageType("SDNM");
        dataProductMessage.setIdentifier("kplr2008347160000.sdnm");

        FileListXB fileList = dataProductMessage.addNewFileList();

        for (int cadenceNumber = 0; cadenceNumber < 1440; cadenceNumber++) {
            FileXB dataProductFile = fileList.addNewFile();
            String fileName = "kplr"
                + createCadenceTimestamp(cadenceNumber, 30) + "_lcs_targ.fits";

            dataProductFile.setFilename(fileName);
            dataProductFile.setSize(42);
            dataProductFile.setChecksum("ra-ra-ra");
        }

        File file = new File(destinationFileName);
        XmlOptions opts = new XmlOptions().setSavePrettyPrint()
            .setSavePrettyPrintIndent(2);
        doc.save(file, opts);
    }

    private String createCadenceTimestamp(int cadenceNumber,
        int minutesPerCadence) {
        Calendar cadenceTimestamp = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
        cadenceTimestamp.set(CADENCE_ZERO_YEAR, CADENCE_ZERO_MONTH,
            CADENCE_ZERO_DAY, 0, 0, 0);
        cadenceTimestamp.add(Calendar.MINUTE, minutesPerCadence * cadenceNumber);

        SimpleDateFormat filenameTsFormat = new SimpleDateFormat(
            "yyyyDDDHHmmss");
        String filenameTs = filenameTsFormat.format(cadenceTimestamp.getTime());
        return filenameTs;
    }

    /**
     * @param args
     * @throws Exception
     */
    public static void main(String[] args) throws Exception {
        GenerateSdnm generateSdnm = new GenerateSdnm();
        generateSdnm.generate("testdata/pixel/kplr2008347160000.sdnm");
    }

}
