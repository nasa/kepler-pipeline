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
import static com.google.common.primitives.Bytes.toArray;
import static com.google.common.primitives.Ints.toArray;
import static com.google.common.primitives.Shorts.toArray;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.BinaryTable;
import nom.tam.fits.BinaryTableHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;
import nom.tam.util.BufferedFile;

/**
 * This class trims pmrf files according to the input keplerIds.
 * 
 * @author Miles Cote
 * 
 */
public class PmrfTrimmer {

    public List<IncludedHdu> trim(File pmrfFile,
        ModuleOutputListsParameters moduleOutputListsParams,
        Set<Integer> keplerIds) {
        try {
            File outputFile = new File(pmrfFile.getParent(), "temp-pmrf.fits");
            BufferedFile bufferedFile = new BufferedFile(
                outputFile.getAbsolutePath(), "rw");

            Fits fits = new Fits(new FileInputStream(pmrfFile));
            BasicHDU primaryHdu = fits.getHDU(0);
            primaryHdu.write(bufferedFile);
            bufferedFile.flush();

            List<IncludedHdu> includedHdus = new ArrayList<IncludedHdu>();
            for (int channel = 1; channel <= FcConstants.MODULE_OUTPUTS; channel++) {
                BinaryTableHDU binaryTableHDU = (BinaryTableHDU) fits.getHDU(channel);

                BinaryTableHDU newHdu = null;
                int columnCount = binaryTableHDU.getNCols();
                switch (columnCount) {
                    case 4:
                        newHdu = generateTrimmedHduWithTargetIds(
                            moduleOutputListsParams, keplerIds, includedHdus,
                            channel, binaryTableHDU);
                        break;
                    case 2:
                        newHdu = generateTrimmedHduWithoutTargetIds(
                            moduleOutputListsParams, includedHdus, channel,
                            binaryTableHDU);
                        break;
                    default:
                        break;
                }

                newHdu.write(bufferedFile);
                bufferedFile.flush();
            }

            fits.getStream()
                .close();
            bufferedFile.close();

            outputFile.renameTo(pmrfFile);

            return includedHdus;
        } catch (Exception e) {
            throw new PipelineException("Unable to trim.", e);
        }
    }

    private BinaryTableHDU generateTrimmedHduWithTargetIds(
        ModuleOutputListsParameters moduleOutputListsParams,
        Set<Integer> keplerIds, List<IncludedHdu> includedHdus, int channel,
        BinaryTableHDU binaryTableHDU) throws FitsException,
        HeaderCardException {
        short[] pmrfRows = (short[]) binaryTableHDU.getColumn(0);
        short[] pmrfCols = (short[]) binaryTableHDU.getColumn(1);
        int[] pmrfTargetIds = (int[]) binaryTableHDU.getColumn(2);
        short[] pmrfApertureIds = (short[]) binaryTableHDU.getColumn(3);

        Pair<Integer, Integer> moduleOutput = FcConstants.getModuleOutput(channel);

        List<Short> trimmedPmrfRows = newArrayList();
        List<Short> trimmedPmrfCols = newArrayList();
        List<Integer> trimmedPmrfTargetIds = newArrayList();
        List<Short> trimmedPmrfApertureIds = newArrayList();
        if (moduleOutputListsParams.included(moduleOutput.left,
            moduleOutput.right)) {
            List<Integer> includedHduRowIndices = new ArrayList<Integer>();
            for (int i = 0; i < pmrfTargetIds.length; i++) {
                if (keplerIds.contains(pmrfTargetIds[i])) {
                    trimmedPmrfRows.add(pmrfRows[i]);
                    trimmedPmrfCols.add(pmrfCols[i]);
                    trimmedPmrfTargetIds.add(pmrfTargetIds[i]);
                    trimmedPmrfApertureIds.add(pmrfApertureIds[i]);

                    includedHduRowIndices.add(i);
                }
            }

            includedHdus.add(new IncludedHdu(channel, includedHduRowIndices));
        }

        Header header = binaryTableHDU.getHeader();

        // Add NAXIS2. This is the one field that is not copied
        // correctly.
        header.addValue(NAXIS2_KW,
            trimmedPmrfTargetIds.size(), "");

        BinaryTable binaryTable = new BinaryTable(new Object[] {
            toArray(trimmedPmrfRows), toArray(trimmedPmrfCols),
            toArray(trimmedPmrfTargetIds), toArray(trimmedPmrfApertureIds) });

        BinaryTableHDU newHdu = new BinaryTableHDU(header, binaryTable);
        return newHdu;
    }

    private BinaryTableHDU generateTrimmedHduWithoutTargetIds(
        ModuleOutputListsParameters moduleOutputListsParams,
        List<IncludedHdu> includedHdus, int channel,
        BinaryTableHDU binaryTableHDU) throws FitsException,
        HeaderCardException {
        byte[] pixelTypes = (byte[]) binaryTableHDU.getColumn(0);
        short[] rowOrColOffsets = (short[]) binaryTableHDU.getColumn(1);

        Pair<Integer, Integer> moduleOutput = FcConstants.getModuleOutput(channel);

        List<Byte> trimmedPixelTypes = newArrayList();
        List<Short> trimmedRowOrColOffsets = newArrayList();
        if (moduleOutputListsParams.included(moduleOutput.left,
            moduleOutput.right)) {
            List<Integer> includedHduRowIndices = new ArrayList<Integer>();
            for (int i = 0; i < pixelTypes.length; i++) {
                trimmedPixelTypes.add(pixelTypes[i]);
                trimmedRowOrColOffsets.add(rowOrColOffsets[i]);

                includedHduRowIndices.add(i);
            }

            includedHdus.add(new IncludedHdu(channel, includedHduRowIndices));
        }

        Header header = binaryTableHDU.getHeader();

        // Add NAXIS2. This is the one field that is not copied
        // correctly.
        header.addValue(NAXIS2_KW,
            trimmedPixelTypes.size(), "");

        BinaryTable binaryTable = new BinaryTable(new Object[] {
            toArray(trimmedPixelTypes), toArray(trimmedRowOrColOffsets) });

        BinaryTableHDU newHdu = new BinaryTableHDU(header, binaryTable);
        return newHdu;
    }

}
