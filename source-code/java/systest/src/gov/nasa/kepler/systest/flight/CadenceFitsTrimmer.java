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

import static gov.nasa.kepler.common.FitsConstants.*;
import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.primitives.Ints.toArray;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.FileInputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.BinaryTable;
import nom.tam.fits.BinaryTableHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.Header;
import nom.tam.util.BufferedFile;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class trims cadence fits files according to the input
 * {@link IncludedHdu}s.
 * 
 * @author Miles Cote
 * 
 */
public class CadenceFitsTrimmer {

    private static final Log log = LogFactory.getLog(CadenceFitsTrimmer.class);

    public void trim(List<File> cadenceFitsFiles, List<IncludedHdu> includedHdus) {
        try {
            Map<Integer, IncludedHdu> channelToIncludedHdu = new HashMap<Integer, IncludedHdu>();
            for (IncludedHdu includedHdu : includedHdus) {
                channelToIncludedHdu.put(includedHdu.getIndex(), includedHdu);
            }

            int fileCount = 0;
            for (File cadenceFitsFile : cadenceFitsFiles) {
                if (fileCount % 100 == 0) {
                    log.info("Completed trimming " + fileCount + " of "
                        + cadenceFitsFiles.size() + " cadence fits files.");
                }

                File outputFile = new File(cadenceFitsFile.getParent(),
                    "temp-cadenceFits.fits");
                BufferedFile bufferedFile = new BufferedFile(
                    outputFile.getAbsolutePath(), "rw");

                Fits fits = new Fits(new FileInputStream(cadenceFitsFile));
                BasicHDU primaryHdu = fits.getHDU(0);
                primaryHdu.write(bufferedFile);
                bufferedFile.flush();

                for (int channel = 1; channel <= FcConstants.MODULE_OUTPUTS; channel++) {
                    BinaryTableHDU binaryTableHDU = (BinaryTableHDU) fits.getHDU(channel);
                    int[] rawValues = (int[]) binaryTableHDU.getColumn(0);

                    IncludedHdu includedHdu = channelToIncludedHdu.get(channel);

                    List<Integer> trimmedRawValues = newArrayList();
                    if (includedHdu != null) {
                        for (Integer hduRowIndex : includedHdu.getIncludedHduRowIndices()) {
                            trimmedRawValues.add(rawValues[hduRowIndex]);
                        }
                    }

                    Header header = binaryTableHDU.getHeader();

                    // Add NAXIS2. This is the one field that is not copied
                    // correctly.
                    header.addValue(
                        NAXIS2_KW,
                        trimmedRawValues.size(), "");

                    BinaryTable binaryTable = new BinaryTable(
                        new Object[] { toArray(trimmedRawValues) });

                    BinaryTableHDU newHdu = new BinaryTableHDU(header,
                        binaryTable);

                    newHdu.write(bufferedFile);
                    bufferedFile.flush();
                }

                fits.getStream()
                    .close();
                bufferedFile.close();

                outputFile.renameTo(cadenceFitsFile);

                fileCount++;
            }
        } catch (Exception e) {
            throw new PipelineException("Unable to trim.", e);
        }
    }

}
