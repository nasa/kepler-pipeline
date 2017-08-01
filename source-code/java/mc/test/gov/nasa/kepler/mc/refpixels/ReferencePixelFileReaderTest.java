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

package gov.nasa.kepler.mc.refpixels;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.DataOutputStream;
import java.io.EOFException;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Random;

import org.junit.Test;

/**
 * Unit test for the ReferencePixelFile class
 * 
 * @author Forrest Girouard
 * @author Todd Klaus
 * 
 */
public class ReferencePixelFileReaderTest {

    private static final int NUM_REF_PIXELS = 2840;
    private static final int MAX_REF_PIXEL_VALUE = (1 << 23) - 1;
    private static final long RANDOM_SEED = 88673117554L;
    private static final int SECONDS = 42;
    private static final int FRAC_SECONDS = 8;

    @Test
    public void testRead() throws EOFException, FileNotFoundException,
        IOException {

        RefPixelFileReader reader = new RefPixelFileReader(createRefPixelFile());

        assertEquals("timestamp", ((long) SECONDS << 8) + FRAC_SECONDS,
            reader.getTimestamp());
        assertEquals("headerFlags", 0, reader.getHeaderFlags());
        assertEquals("longCadenceTargetTableId", 1,
            reader.getLongCadenceTargetTableId());
        assertEquals("shortCadenceTargetTableId", 2,
            reader.getShortCadenceTargetTableId());
        assertEquals("backgroundTargetTableId", 3,
            reader.getBackgroundTargetTableId());
        assertEquals("backgroundApertureTableId", 4,
            reader.getBackgroundApertureTableId());
        assertEquals("scienceApertureTableId", 5,
            reader.getScienceApertureTableId());
        assertEquals("referencePixelTargetTableId", 6,
            reader.getReferencePixelTargetTableId());
        assertEquals("compressionTableId", 7, reader.getCompressionTableId());
        assertEquals("numberOfReferencePixels", NUM_REF_PIXELS,
            reader.getNumberOfReferencePixels());

        for (int i = 0; i < NUM_REF_PIXELS; i++) {
            int pixel = reader.readNextPixel();
            assertTrue("refPixlValue[" + i + "]=" + pixel, pixel > 0
                && pixel <= MAX_REF_PIXEL_VALUE);
        }
    }

    @Test(expected = EOFException.class)
    public void attemptToReadInvalidRefPixels() throws EOFException,
        FileNotFoundException {
        RefPixelFileReader rpf = new RefPixelFileReader(new File("/etc/motd"));

        for (int i = 0; i < NUM_REF_PIXELS; i++) {
            rpf.readNextPixel();
        }
    }

    private File createRefPixelFile() throws FileNotFoundException, IOException {

        File refPixelFile = new File(Filenames.BUILD_TMP,
            "unit-test_rp.rp");
        DataOutputStream dataOutputStream = new DataOutputStream(
            new FileOutputStream(refPixelFile));
        dataOutputStream.writeInt(SECONDS);
        dataOutputStream.writeByte(FRAC_SECONDS);
        for (int i = 0; i < 8; i++) {
            dataOutputStream.writeByte(i);
        }

        Random random = new Random(RANDOM_SEED);
        for (int i = 0; i < NUM_REF_PIXELS; i++) {
            dataOutputStream.writeInt(random.nextInt());
        }

        dataOutputStream.close();
        return refPixelFile;
    }

}
