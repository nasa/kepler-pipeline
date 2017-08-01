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

import static com.google.common.collect.Lists.newArrayList;
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.List;
import java.util.Set;

import nom.tam.fits.BinaryTableHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;

import org.apache.commons.io.FileUtils;
import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableSet;

/**
 * @author Miles Cote
 * 
 */
public class PmrfTrimmerTest {

    private static final int CHANNEL = 1;
    private static final int KEPLER_ID = 8077555;
    private static final int KEPLER_ID_ROW_COUNT = 59;

    @Test
    public void testTrim() throws IOException, FitsException {
        String pmrfFileName = "kplr2009118020356-14-14_lcm.fits";

        File srcPmrfFile = new File(SocEnvVars.getLocalTestDataDir()
            + "/systest/fits/" + pmrfFileName);

        FileUtils.copyFileToDirectory(srcPmrfFile, new File(
            Filenames.BUILD_TMP));
        File tempPmrfFile = new File(Filenames.BUILD_TMP, pmrfFileName);

        ModuleOutputListsParameters moduleOutputListsParams = new ModuleOutputListsParameters(
            new int[] { CHANNEL }, null);

        Set<Integer> keplerIds = ImmutableSet.of(KEPLER_ID);

        PmrfTrimmer pmrfTrimmer = new PmrfTrimmer();
        List<IncludedHdu> includedHdus = pmrfTrimmer.trim(tempPmrfFile,
            moduleOutputListsParams, keplerIds);

        // The first keplerId uses the first KEPLER_ID_ROW_COUNT rows in the
        // hdu.
        List<Integer> expectedIncludedHduRowIndices = newArrayList();
        for (int i = 0; i < KEPLER_ID_ROW_COUNT; i++) {
            expectedIncludedHduRowIndices.add(i);
        }

        List<IncludedHdu> expectedIncludedHdus = ImmutableList.of(new IncludedHdu(
            CHANNEL, expectedIncludedHduRowIndices));
        assertEquals(expectedIncludedHdus, includedHdus);

        Fits fits = new Fits(new FileInputStream(tempPmrfFile));
        fits.getHDU(0);

        for (int i = 1; i <= FcConstants.MODULE_OUTPUTS; i++) {
            BinaryTableHDU binaryTableHDU = (BinaryTableHDU) fits.getHDU(i);
            int[] pmrfTargetIds = (int[]) binaryTableHDU.getColumn(2);
            if (i != CHANNEL) {
                assertEquals(0, pmrfTargetIds.length);
            } else {
                assertEquals(KEPLER_ID_ROW_COUNT, pmrfTargetIds.length);

                for (int j = 0; j < pmrfTargetIds.length; j++) {
                    assertEquals(KEPLER_ID, pmrfTargetIds[j]);
                }
            }
        }

        assertEquals(FcConstants.MODULE_OUTPUTS + 1, fits.getNumberOfHDUs());

        fits.getStream()
            .close();
    }

}
