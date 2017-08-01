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

package gov.nasa.kepler.dr.refpixels;

import gov.nasa.kepler.common.FilenameConstants;

import java.io.BufferedOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.xml.DOMConfigurator;

/**
 * Create a test reference pixel file to use for testing until we get a real one
 * from the MOC
 * 
 * @author tklaus
 * 
 */
public class CreateTestReferencePixelFile {
    private static final Log log = LogFactory.getLog(CreateTestReferencePixelFile.class);
    private DataOutputStream dos;

    private int referencePixelTargetTableId = 0;
    private int numberOfPixels = 0;
    private long startingTimestamp = 0;

    public CreateTestReferencePixelFile(int referencePixelTargetTableId,
        int numberOfPixels, long startingTimestamp) {
        this.referencePixelTargetTableId = referencePixelTargetTableId;
        this.numberOfPixels = numberOfPixels;
        this.startingTimestamp = startingTimestamp;
    }

    public void writeFiles(List<String> fileTimestamps) throws Exception {

        long timestamp = startingTimestamp;

        for (String name : fileTimestamps) {
            File referencePixelFile = new File(FilenameConstants.SOC_ROOT
                + "/java/dr/refpixels/contact/kplr" + name + "_ref-pixel.bin");

            log.info("Creating: " + referencePixelFile);

            dos = new DataOutputStream(new BufferedOutputStream(
                new FileOutputStream(referencePixelFile)));

            /*
             * from ReferencePixelFileReader:
             * 
             * timestamp = readTimestamp(); headerFlags =
             * dis.readUnsignedByte(); longCadenceTargetTableId = dis.readInt();
             * shortCadenceTargetTableId = dis.readInt();
             * backgroundTargetTableId = dis.readInt();
             * backgroundApertureTableId = dis.readInt(); scienceApertureTableId
             * = dis.readInt(); referencePixelTargetTableId = dis.readInt();
             * compressionTableId = dis.readInt();
             */

            writeTimestamp(timestamp);
            dos.write(0); // headerFlags
            dos.write(1); // longCadenceTargetTableId
            dos.write(2); // shortCadenceTargetTableId
            dos.write(1); // backgroundTargetTableId
            dos.write(3); // backgroundApertureTableId
            dos.write(3); // scienceApertureTableId
            dos.write(referencePixelTargetTableId); // referencePixelTargetTableId
            dos.write(1); // compressionTableId

            for (int i = 0; i < numberOfPixels; i++) {
                dos.writeInt(0);
            }

            dos.close();

            timestamp += 86400; // secs per day? Assumes ts is in secs
            // resolution
        }
    }

    /**
     * Write the specified 40-bit timestamp to the file Assumes big-endian
     * 
     * @return
     * @throws IOException
     */
    private void writeTimestamp(long timestamp) throws IOException {

        dos.write((int) (timestamp >>> 32));
        dos.write((int) (timestamp >>> 24));
        dos.write((int) (timestamp >>> 16));
        dos.write((int) (timestamp >>> 8));
        dos.write((int) (timestamp >>> 0));
    }

    /**
     * @param args
     * @throws Exception
     */
    public static void main(String[] args) throws Exception {
        DOMConfigurator.configure("etc/log4j.xml");

        /*
         * See MockTargetCrud for the origin of this number
         */
        int numRefPixels = 117180;

        CreateTestReferencePixelFile createTestReferencePixelFile = new CreateTestReferencePixelFile(
            1, numRefPixels, 1000);

        List<String> fileTimestamps = new LinkedList<String>();
        fileTimestamps.add("2008347160000");
        fileTimestamps.add("2008348160000");
        fileTimestamps.add("2008349160000");
        fileTimestamps.add("2008350160000");

        createTestReferencePixelFile.writeFiles(fileTimestamps);
    }

}
