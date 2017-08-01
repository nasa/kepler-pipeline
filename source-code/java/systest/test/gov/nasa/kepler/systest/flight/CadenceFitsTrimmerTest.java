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

package gov.nasa.kepler.systest.flight;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.List;

import nom.tam.fits.BinaryTableHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;

import org.apache.commons.io.FileUtils;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class CadenceFitsTrimmerTest {

    private static final int CHANNEL = 1;
    private static final int RAW_VALUE = 422177;

    @Test
    public void testTrim() throws IOException, FitsException {
        String cadenceFitsFileName = "kplr2009124221829_lcs-targ.fits";

        File srcCadenceFitsFile = new File(SocEnvVars.getLocalTestDataDir()
            + "/systest/fits/" + cadenceFitsFileName);

        FileUtils.copyFileToDirectory(srcCadenceFitsFile, new File(
            Filenames.BUILD_TMP));
        File tempCadenceFitsFile = new File(Filenames.BUILD_TMP,
            cadenceFitsFileName);

        List<File> tempCadenceFitsFiles = ImmutableList.of(tempCadenceFitsFile);

        List<Integer> includedHduRowIndices = ImmutableList.of(0);

        List<IncludedHdu> includedHdus = ImmutableList.of(new IncludedHdu(
            CHANNEL, includedHduRowIndices));

        CadenceFitsTrimmer cadenceFitsTrimmer = new CadenceFitsTrimmer();
        cadenceFitsTrimmer.trim(tempCadenceFitsFiles, includedHdus);

        Fits fits = new Fits(new FileInputStream(tempCadenceFitsFile));
        fits.getHDU(0);

        for (int i = 1; i <= FcConstants.MODULE_OUTPUTS; i++) {
            BinaryTableHDU binaryTableHDU = (BinaryTableHDU) fits.getHDU(i);
            int[] rawValues = (int[]) binaryTableHDU.getColumn(0);

            if (i != CHANNEL) {
                assertEquals(0, rawValues.length);
            } else {
                assertEquals(1, rawValues.length);
                assertEquals(RAW_VALUE, rawValues[0]);
            }
        }

        assertEquals(FcConstants.MODULE_OUTPUTS + 1, fits.getNumberOfHDUs());

        fits.getStream()
            .close();
    }

}
