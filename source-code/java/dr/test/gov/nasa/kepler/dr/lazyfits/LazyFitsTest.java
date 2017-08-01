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

package gov.nasa.kepler.dr.lazyfits;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.SocEnvVars;

import java.io.EOFException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Test;

public class LazyFitsTest {
    private static final Log log = LogFactory.getLog(LazyFitsTest.class);

    private static final String LAZY_FITS_PATH = SocEnvVars.getLocalTestDataDir()
        + "/dr/lazy-fits";

    private static final String TEST_FITS_PMRF = LAZY_FITS_PATH
        + "/kplr2008347160000-targ-001-001-pmrf.fits";
    private static final String TEST_FITS_TARGET_1 = LAZY_FITS_PATH
        + "/kplr2008347160000-lcs-targ.fits";
    private static final String TEST_FITS_TARGET_2 = LAZY_FITS_PATH
        + "/kplr2008347163000-lcs-targ.fits";

    @Test
    public void testFullParse() throws LazyFitsException, EOFException {
        LazyFits fits = new LazyFits(TEST_FITS_PMRF);
        int hduCount = 0;

        Hdu hdu = fits.readNextHdu();
        log.info("HDU #" + hduCount++);
        Header header = hdu.getHeader();
        Data data = hdu.getData();
        logHeader(header);

        hdu = fits.readNextHdu();
        log.info("HDU #" + hduCount++);
        header = hdu.getHeader();
        data = hdu.getData();

        int[] column0 = (int[]) data.getColumn(0);
        short[] column1 = (short[]) data.getColumn(1);
        short[] column2 = (short[]) data.getColumn(2);
        short[] column3 = (short[]) data.getColumn(3);

        assertEquals("column0[0]", 0, column0[0]);
        assertEquals("column1[0]", (short) 414, column1[0]);
        assertEquals("column2[0]", (short) 503, column2[0]);
        assertEquals("column3[0]", (short) 154, column3[0]);

        assertEquals("column0[9]", 0, column0[9]);
        assertEquals("column1[9]", (short) 414, column1[9]);
        assertEquals("column2[9]", (short) 505, column2[9]);
        assertEquals("column3[9]", (short) 153, column3[9]);

        logHeader(header);

        hdu = fits.readNextHdu();
        log.info("HDU #" + hduCount++);
        header = hdu.getHeader();
        data = hdu.getData();

        column0 = (int[]) data.getColumn(0);
        column1 = (short[]) data.getColumn(1);
        column2 = (short[]) data.getColumn(2);
        column3 = (short[]) data.getColumn(3);

        assertEquals("column0[0]", 0, column0[0]);
        assertEquals("column1[0]", (short) 162, column1[0]);
        assertEquals("column2[0]", (short) 828, column2[0]);
        assertEquals("column3[0]", (short) 902, column3[0]);

        assertEquals("column0[9]", 0, column0[9]);
        assertEquals("column1[9]", (short) 162, column1[9]);
        assertEquals("column2[9]", (short) 829, column2[9]);
        assertEquals("column3[9]", (short) 906, column3[9]);

        logHeader(header);

        // Hdu hdu = fits.readNextHdu();
        // while(hdu != null){
        // log.info("HDU #" + hduCount);
        //
        // Header header = hdu.getHeader();
        //
        // logHeader(header);
        //
        // hdu = fits.readNextHdu();
        // hduCount++;
        // }
    }

    private void logHeader(Header header) throws LazyFitsException,
        EOFException {
        for (String keyword : header.keySet()) {
            log.info("  " + keyword + " = " + header.getStringValue(keyword));
        }
    }

    @Test
    public void testReferenceLazyLoad() throws LazyFitsException, EOFException {
        LazyFits referenceFits = new LazyFits(TEST_FITS_TARGET_1);
        LazyFits secondFits = new LazyFits(TEST_FITS_TARGET_2, referenceFits);

        Hdu hdu = secondFits.getHdu(2);
        log.info("HDU #2");
        Data data = hdu.getData();

        int[] column0 = (int[]) data.getColumn(0);
        int[] column1 = (int[]) data.getColumn(1);

        assertEquals("column0[5]", 38848, column0[5]);
        assertEquals("column1[5]", 38848, column1[5]);

        assertEquals("column0[6]", 27618, column0[6]);
        assertEquals("column1[6]", 27618, column1[6]);

    }

    @Test
    public void testReferencePreLoad() throws LazyFitsException, EOFException {
        LazyFits referenceFits = new LazyFits(TEST_FITS_TARGET_1);
        LazyFits secondFits = new LazyFits(TEST_FITS_TARGET_2, referenceFits);

        referenceFits.readAllHdus();

        log.info("after pre-load, reading hdu");

        Hdu hdu = secondFits.getHdu(2);
        log.info("HDU #2");
        Data data = hdu.getData();

        log.info("read complete");

        int[] column0 = (int[]) data.getColumn(0);
        int[] column1 = (int[]) data.getColumn(1);

        assertEquals("column0[5]", 38848, column0[5]);
        assertEquals("column1[5]", 38848, column1[5]);

        assertEquals("column0[6]", 27618, column0[6]);
        assertEquals("column1[6]", 27618, column1[6]);

    }
}