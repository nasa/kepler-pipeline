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

package gov.nasa.kepler.dr.sclk;

import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.dr.dispatch.DispatchException;
import gov.nasa.kepler.dr.sclk.SclkFileReader.CoefficientsIterator;
import gov.nasa.kepler.hibernate.dr.SclkCoefficients;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.io.File;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class SclkFileReaderTest {
    /**
     * Logger for this class
     */
    private static final Log log = LogFactory.getLog(SclkFileReaderTest.class);

    private static final String SCLK_FILENAME_NO_PROLOG = "testdata/sclk/sclk.txt";
    private static final String SCLK_FILENAME_PROLOG = "testdata/sclk/kplr2007108180000.tsc";
    private static final String INVALID_SCLK_FILENAME = "testdata/sclk/invalid-sclk.txt";

    private ReflectionEquals reflectionEquals = new ReflectionEquals();

    @Before
    public void setUp() throws Exception {
    }

    @Test
    public void testParseWithPrologText() throws Exception {
        SclkFileReader sclkFileReader = new SclkFileReader(new File(
            SCLK_FILENAME_PROLOG));

        sclkFileReader.parse();

        Set<String> keysFound = sclkFileReader.keySet();
        for (String key : keysFound) {
            log.info("key = " + key);
        }

        reflectionEquals.assertEquals("key count", 10, keysFound.size());

        reflectionEquals.assertEquals("SCLK_KERNEL_ID", "@2007-108T18:00:00",
            sclkFileReader.get("SCLK_KERNEL_ID"));
        reflectionEquals.assertEquals("SCLK_DATA_TYPE_227", "1",
            sclkFileReader.get("SCLK_DATA_TYPE_227"));
        reflectionEquals.assertEquals("SCLK01_TIME_SYSTEM_227", "1",
            sclkFileReader.get("SCLK01_TIME_SYSTEM_227"));
        reflectionEquals.assertEquals("SCLK01_N_FIELDS_227", "2",
            sclkFileReader.get("SCLK01_N_FIELDS_227"));
        reflectionEquals.assertEquals("SCLK01_MODULI_227", "4294967296 256",
            sclkFileReader.get("SCLK01_MODULI_227"));
        reflectionEquals.assertEquals("SCLK01_OFFSETS_227", "0 0",
            sclkFileReader.get("SCLK01_OFFSETS_227"));
        reflectionEquals.assertEquals("SCLK01_OUTPUT_DELIM_227", "1",
            sclkFileReader.get("SCLK01_OUTPUT_DELIM_227"));
        reflectionEquals.assertEquals("SCLK_PARTITION_START_227",
            "0.0000000000000E+00",
            sclkFileReader.get("SCLK_PARTITION_START_227"));
        reflectionEquals.assertEquals("SCLK_PARTITION_END_227",
            "1.0995116277750E+12", sclkFileReader.get("SCLK_PARTITION_END_227"));

        List<SclkCoefficients> expectedSclkCoefficients = new LinkedList<SclkCoefficients>();
        expectedSclkCoefficients.add(new SclkCoefficients(0.0000000000000E+00,
            6.4184000000000E+01, 1.0000000000000E+00));
        expectedSclkCoefficients.add(new SclkCoefficients(7.1575159086761E+10,
            2.7959046518266E+08, 9.9730398999001E-01));
        expectedSclkCoefficients.add(new SclkCoefficients(7.4904899887523E+10,
            2.9259726518564E+08, 1.0001884629544E+00));

        int expectedIndex = 0;
        for (CoefficientsIterator it = sclkFileReader.getCoefficientsIterator(); it.hasNext();) {
            SclkCoefficients sclkCoefficients = it.next();
            log.info("sclkCoefficients = " + sclkCoefficients);
            assertTrue(
                "SclkCoefficients[" + expectedIndex + "] comparison failed",
                compareCoefficients(
                    expectedSclkCoefficients.get(expectedIndex++),
                    sclkCoefficients));
        }
    }

    @Test
    public void testParseWithoutPrologText() throws Exception {
        SclkFileReader sclkFileReader = new SclkFileReader(new File(
            SCLK_FILENAME_NO_PROLOG));

        sclkFileReader.parse();

        Set<String> keysFound = sclkFileReader.keySet();
        for (String key : keysFound) {
            log.info("key = " + key);
        }

        reflectionEquals.assertEquals("key count", 10, keysFound.size());

        reflectionEquals.assertEquals("SCLK_KERNEL_ID",
            "@2006-02-13/09:23:06.00", sclkFileReader.get("SCLK_KERNEL_ID"));
        reflectionEquals.assertEquals("SCLK_DATA_TYPE_227", "1",
            sclkFileReader.get("SCLK_DATA_TYPE_227"));
        reflectionEquals.assertEquals("SCLK01_TIME_SYSTEM_227", "2",
            sclkFileReader.get("SCLK01_TIME_SYSTEM_227"));
        reflectionEquals.assertEquals("SCLK01_N_FIELDS_227", "2",
            sclkFileReader.get("SCLK01_N_FIELDS_227"));
        reflectionEquals.assertEquals("SCLK01_MODULI_227", "4294967296 256",
            sclkFileReader.get("SCLK01_MODULI_227"));
        reflectionEquals.assertEquals("SCLK01_OFFSETS_227", "0 0",
            sclkFileReader.get("SCLK01_OFFSETS_227"));
        reflectionEquals.assertEquals("SCLK01_OUTPUT_DELIM_227", "1",
            sclkFileReader.get("SCLK01_OUTPUT_DELIM_227"));
        reflectionEquals.assertEquals("SCLK_PARTITION_START_227",
            "0.0000000000000E+00",
            sclkFileReader.get("SCLK_PARTITION_START_227"));
        reflectionEquals.assertEquals("SCLK_PARTITION_END_227",
            "1.0995116277750E+12", sclkFileReader.get("SCLK_PARTITION_END_227"));

        List<SclkCoefficients> expectedSclkCoefficients = new LinkedList<SclkCoefficients>();
        expectedSclkCoefficients.add(new SclkCoefficients(0.0000000000000E+00,
            6.4184000000000E+01, 1.0000000000000E+00));
        expectedSclkCoefficients.add(new SclkCoefficients(4.2099968000000E+10,
            1.6445306418400E+08, 9.8630399999022E-01));
        expectedSclkCoefficients.add(new SclkCoefficients(4.2100224000000E+10,
            1.6445405048800E+08, 1.0001884629544E+00));
        expectedSclkCoefficients.add(new SclkCoefficients(4.3769088000000E+10,
            1.7097427907800E+08, 9.7510030000031E-01));
        expectedSclkCoefficients.add(new SclkCoefficients(4.3781888000000E+10,
            1.7102303409300E+08, 1.0000023630214E+00));
        expectedSclkCoefficients.add(new SclkCoefficients(4.4008960000000E+10,
            1.7191003618900E+08, 1.0019596000016E+00));
        expectedSclkCoefficients.add(new SclkCoefficients(4.4010240000000E+10,
            1.7191504598700E+08, 1.0000093700000E+00));

        int expectedIndex = 0;
        for (CoefficientsIterator it = sclkFileReader.getCoefficientsIterator(); it.hasNext();) {
            SclkCoefficients sclkCoefficients = it.next();
            log.info("sclkCoefficients = " + sclkCoefficients);
            assertTrue(
                "SclkCoefficients[" + expectedIndex + "] comparison failed",
                compareCoefficients(
                    expectedSclkCoefficients.get(expectedIndex++),
                    sclkCoefficients));
        }
    }

    /**
     * @param coefficients
     * @param sclkCoefficients
     * @return
     */
    private boolean compareCoefficients(
        SclkCoefficients expectedSclkCoefficients,
        SclkCoefficients actualSclkCoefficients) {

        if (expectedSclkCoefficients.getVtcEventTime() == actualSclkCoefficients.getVtcEventTime()
            && expectedSclkCoefficients.getSecondsSinceEpoch() == actualSclkCoefficients.getSecondsSinceEpoch()
            && expectedSclkCoefficients.getClockRate() == actualSclkCoefficients.getClockRate()) {
            return true;
        } else {
            log.info("expected: " + expectedSclkCoefficients + ", was: "
                + actualSclkCoefficients);
            return false;
        }
    }

    @Test(expected = DispatchException.class)
    public void attemptToReadBadFormat() {
        SclkFileReader sclkFileReader = new SclkFileReader(new File(
            INVALID_SCLK_FILENAME));

        sclkFileReader.parse();
    }

}
