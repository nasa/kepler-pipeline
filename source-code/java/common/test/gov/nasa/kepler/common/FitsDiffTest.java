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

package gov.nasa.kepler.common;

import static gov.nasa.kepler.common.FcConstants.MODULE_OUTPUTS;
import static gov.nasa.kepler.common.FitsConstants.*;
import static org.junit.Assert.assertTrue;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.BufferedOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.BinaryTableHDU;
import nom.tam.fits.Data;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCard;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 * 
 */
public class FitsDiffTest {

    private File rootDir;

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        rootDir = new File(Filenames.BUILD_TEST + "/FitsDiffTest");
        rootDir.mkdirs();
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        FileUtil.removeAll(rootDir);
        rootDir.delete();
    }

    private void buildBasicHeader(Fits fits) throws Exception {
        Header header = new Header();
        header.setSimple(true);
        header.setNaxes(0);
        header.setBitpix(32); // Otherwise this will not parse.
        header.addValue(EXTEND_KW, true, "File may contain standard extensions.");
        header.addValue(NEXTEND_KW, MODULE_OUTPUTS,
            "Number of standard extensions.");
        header.addValue(TELESCOP_KW, "Kepler", "");
        header.addValue(INSTRUME_KW, "CCD", "");
        header.addValue(EQUINOX, 2000.0f, "");
        header.addValue(ORIGIN_KW, "NASA/Ames", "");
        header.addValue(FILENAME_KW, "blah.fits", "");

        header.addValue(DATSETNM_KW, "", "");
        header.addValue(DATATYPE_KW, 1, "");
        header.addValue(PIXELTYP_KW, 2, "");

        header.addValue(CADENNUM_KW, 3, "");

        HeaderCard nullValueCard = new HeaderCard("NULLV");

        header.addLine(nullValueCard);

        BasicHDU hdu = Fits.makeHDU(header);
        fits.addHDU(hdu);
    }

    private void buildBinaryTable(Fits fits, int differenceValue)
        throws Exception {
        byte[] bData = new byte[1];
        short[] sData = new short[1];
        int[] iData = new int[1];
        float[] fData = new float[1];
        double[] dData = new double[1];
        int[] diffData = new int[1];
        diffData[0] = differenceValue;

        Object[] dataCols = new Object[6];
        dataCols[0] = bData;
        dataCols[1] = sData;
        dataCols[2] = iData;
        dataCols[3] = fData;
        dataCols[4] = dData;
        dataCols[5] = diffData;

        Data fitsBinaryData = BinaryTableHDU.encapsulate(dataCols);
        Header binaryTableHeader = BinaryTableHDU.manufactureHeader(fitsBinaryData);
        binaryTableHeader.addValue("BLAH", 1, "");
        binaryTableHeader.addValue("TTYPE1", "bData", "");
        binaryTableHeader.addValue("TFORM1", "1B", "");
        binaryTableHeader.addValue("TTYPE2", "sData", "");
        binaryTableHeader.addValue("TFORM2", "1I", "");
        binaryTableHeader.addValue("TTYPE3", "iData", "");
        binaryTableHeader.addValue("TFORM3", "1J", "");
        binaryTableHeader.addValue("TTYPE4", "fData", "");
        binaryTableHeader.addValue("TFORM4", "1E", "");
        binaryTableHeader.addValue("TTYPE5", "dData", "");
        binaryTableHeader.addValue("TFORM5", "1D", "");
        binaryTableHeader.addValue("TTYPE6", "diffData", "");
        binaryTableHeader.addValue("TFORM6", "1J", "");

        fits.addHDU(new BinaryTableHDU(binaryTableHeader, fitsBinaryData));
    }

    /**
     * One of the fields in the basic header has a different field.
     */
    @Test
    public void differInHeader() throws Exception {
        File fits1File = new File(rootDir, "fits1.fits");
        File fits2File = new File(rootDir, "fits2.fits");

        Fits fits1 = new Fits();
        Fits fits2 = new Fits();

        buildBasicHeader(fits1);
        buildBasicHeader(fits2);

        fits1.getHDU(0).addValue("BLAH", false, "blah");
        fits2.getHDU(0).addValue("BLAH", true, "");

        diffAndAssert(fits1File, fits2File, fits1, fits2);

    }

    /**
     * @param fits1File
     * @param fits2File
     * @param fits1
     * @param fits2
     * @throws FileNotFoundException
     * @throws FitsException
     * @throws IOException
     */
    private void diffAndAssert(File fits1File, File fits2File, Fits fits1,
        Fits fits2) throws FileNotFoundException, FitsException, IOException {
        DataOutputStream dout = new DataOutputStream(new BufferedOutputStream(
            new FileOutputStream(fits1File)));
        fits1.write(dout);
        dout.close();
        dout = new DataOutputStream(new BufferedOutputStream(
            new FileOutputStream(fits2File)));
        fits2.write(dout);
        dout.close();

        FitsDiff differ = new FitsDiff();

        List<String> diffs = new ArrayList<String>();
        boolean isDifferent = differ.diff(fits1File, fits2File, diffs);
        assertTrue("Files should be different.", isDifferent);
        assertTrue("Messages should be returned.", diffs.size() != 0);
        for (String s : diffs) {
            System.out.println(s);
        }
    }

    /**
     * Test that binary columns differ.
     */
    @Test
    public void binaryTableValueDiffers() throws Exception {
        File fits1File = new File(rootDir, "fits1.fits");
        File fits2File = new File(rootDir, "fits2.fits");

        Fits fits1 = new Fits();
        Fits fits2 = new Fits();

        buildBasicHeader(fits1);
        buildBasicHeader(fits2);

        buildBinaryTable(fits1, 1);
        buildBinaryTable(fits2, 2);

        diffAndAssert(fits1File, fits2File, fits1, fits2);
    }

}
