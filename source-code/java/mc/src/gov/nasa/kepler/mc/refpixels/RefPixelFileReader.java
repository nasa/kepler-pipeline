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

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.Iso8601Formatter;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.spice.SpiceException;
import gov.nasa.kepler.mc.vtc.VtcOperations;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;

import java.io.BufferedInputStream;
import java.io.DataInputStream;
import java.io.EOFException;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class knows how to parse the Reference Pixel File sent by the MOC to the
 * SOC after an X-Band contact.
 * 
 * This file contains values for all reference pixels from the baseline image.
 * There is one reference pixel file per long cadence baseline (nominally one
 * per day, and 4 per x-band contact). The order of the pixels in the file is
 * the same as the order that the pixels are listed in the reference pixel
 * target table.
 * 
 * The file has the following format (from the FS-GS ICD, section 5.3.1.3.6):
 * 
 * <pre>
 * Byte
 * Offset   Content
 * ------------------------------------------
 *  0-4     timestamp
 *  0-3       seconds
 *  4         fraction of seconds (LSB is 4.096 msec)
 *  5-12      photometer config id
 *  5           flags
 *  6           long cadence target table id
 *  7           short cadence target table id
 *  8           background target table id
 *  9           background aperture table id
 * 10           science aperture table id
 * 11           reference pixel target table id
 * 12           compression table id
 * 13-16    reference pixel #1
 * 17-20    reference pixel #2
 * 21+      ...continues for all reference pixels
 * </pre>
 * 
 * This code assumes all values in the reference pixel file are BIG-ENDIAN. Of
 * the 32-bit reference pixel only the least significant 23-bits are the value,
 * the remaining bits are used for other purposes.
 * 
 * @author Forrest Girouard
 * @author Todd Klaus
 * 
 */
public class RefPixelFileReader {
    private static final Log log = LogFactory.getLog(RefPixelFileReader.class);

    /**
     * Number of bytes in the file that are *not* reference pixel values. Used
     * to compute the number of reference pixels based on the file size.
     */
    public static final int NUM_HEADER_BYTES = 13;

    /**
     * Reference pixels are the RAW 32-bit pixel value from the hardware. The
     * lower 23-bits are valid pixel values (and the value has been shifted by
     * the black level offset) with the upper bits composing the hamming code,
     * error and lockout bits (bits 24-32 are "don't care" bits).
     */
    private static final int PIXEL_VALUE_MASK = 0x007fffff;

    /**
     * As per the SOC-MOC ICD, if a reference pixel value matches this value it
     * is considered to be a gap.
     */
    @ProxyIgnore
    public static final int GAP_INDICATOR_VALUE = 0xFFFFFFFF; // (2^32 - 1)

    private static final long BYTES_PER_PIXEL = 4;

    private String referencePixelFile;
    private DataInputStream dataInputStream;
    private int numberOfReferencePixels;

    private long timestamp;
    private int headerFlags;
    private int longCadenceTargetTableId;
    private int shortCadenceTargetTableId;
    private int backgroundTargetTableId;
    private int backgroundApertureTableId;
    private int scienceApertureTableId;
    private int referencePixelTargetTableId;
    private int compressionTableId;

    /**
     * Parses the header of the file and positions the file pointer to the first
     * pixel value.
     * 
     * @param referencePixelFile the {@code FsId} of the given {@code dis}.
     * @param dataInputStream
     */
    public RefPixelFileReader(FsId fsId, DataInputStream dataInputStream) {
        this.referencePixelFile = fsId.toString();
        this.dataInputStream = dataInputStream;
        parseHeader();
    }

    public RefPixelFileReader(File referencePixelFile)
        throws FileNotFoundException {
        this.referencePixelFile = referencePixelFile.getPath();
        this.dataInputStream = new DataInputStream(new BufferedInputStream(
            new FileInputStream(referencePixelFile)));
        parseHeader();
    }

    private void parseHeader() {
        log.debug("RefPixelFileReader: referencePixelFile: "
            + referencePixelFile);

        try {
            log.debug("Parsing header for reference pixel file:"
                + referencePixelFile);

            this.numberOfReferencePixels = (int) ((dataInputStream.available() - NUM_HEADER_BYTES) / BYTES_PER_PIXEL);

            timestamp = readTimestamp();
            headerFlags = dataInputStream.readUnsignedByte();
            longCadenceTargetTableId = dataInputStream.readUnsignedByte();
            shortCadenceTargetTableId = dataInputStream.readUnsignedByte();
            backgroundTargetTableId = dataInputStream.readUnsignedByte();
            backgroundApertureTableId = dataInputStream.readUnsignedByte();
            scienceApertureTableId = dataInputStream.readUnsignedByte();
            referencePixelTargetTableId = dataInputStream.readUnsignedByte();
            compressionTableId = dataInputStream.readUnsignedByte();

        } catch (Exception e) {
            log.error("RefPixelFileReader: referencePixelFile="
                + referencePixelFile, e);

            throw new ModuleFatalProcessingException(
                "Failed to parse reference pixel file:" + referencePixelFile, e);
        }
    }

    /**
     * Read the 40-bit timestamp from the file and return it as a long. Method
     * assumes big-endian data.
     * 
     * @return
     * @throws IOException
     */
    private long readTimestamp() throws IOException {
        int seconds = dataInputStream.readInt();

        int fracSeconds = dataInputStream.readUnsignedByte();

        long ts = ((long) seconds << 8) + fracSeconds;

        return ts;
    }

    /**
     * Read the next pixel value from the file
     * 
     * @return integer reference pixel value
     * @throws EOFException
     */
    public int readNextPixel() throws EOFException {
        try {
            int pixelValue = dataInputStream.readInt();
            if (pixelValue != GAP_INDICATOR_VALUE) {
                pixelValue &= PIXEL_VALUE_MASK;
            }
            return pixelValue;
        } catch (EOFException e) {
            throw e;
        } catch (IOException e) {
            throw new ModuleFatalProcessingException(
                "Caught exception reading reference pixel file:"
                    + referencePixelFile, e);
        }
    }

    public int getBackgroundApertureTableId() {
        return backgroundApertureTableId;
    }

    public int getBackgroundTargetTableId() {
        return backgroundTargetTableId;
    }

    public int getCompressionTableId() {
        return compressionTableId;
    }

    public int getHeaderFlags() {
        return headerFlags;
    }

    public int getLongCadenceTargetTableId() {
        return longCadenceTargetTableId;
    }

    public int getReferencePixelTargetTableId() {
        return referencePixelTargetTableId;
    }

    public int getScienceApertureTableId() {
        return scienceApertureTableId;
    }

    public int getShortCadenceTargetTableId() {
        return shortCadenceTargetTableId;
    }

    public long getTimestamp() {
        return timestamp;
    }

    public int getNumberOfReferencePixels() {
        return numberOfReferencePixels;
    }

    public static void main(String[] args) throws Exception {
        String nodb = "nodb";
        if (args.length != 1 && (args.length != 2 || !args[1].equals(nodb))) {
            throw new Exception("USAGE: rpdump RP_PATH [" + nodb + "]");
        }

        boolean dbEnabled = !(args.length == 2 && args[1].equals(nodb));

        File rpFile = new File(args[0]);

        if (rpFile.exists() && rpFile.isFile()) {
            RefPixelFileReader reader = new RefPixelFileReader(rpFile);

            int pixelCount = reader.getNumberOfReferencePixels();

            System.out.println(String.format("timestamp = %d",
                reader.getTimestamp()));
            System.out.println(String.format("flags = %x",
                reader.getHeaderFlags()));
            System.out.println(String.format("Num ref pixels = %d", pixelCount));
            System.out.println(String.format("LCT ID = %d",
                reader.getLongCadenceTargetTableId()));
            System.out.println(String.format("SCT ID = %d",
                reader.getShortCadenceTargetTableId()));
            System.out.println(String.format("BGT ID = %d",
                reader.getBackgroundTargetTableId()));
            System.out.println(String.format("BAD ID = %d",
                reader.getBackgroundApertureTableId()));
            System.out.println(String.format("TAD ID = %d",
                reader.getScienceApertureTableId()));
            System.out.println(String.format("RPT ID = %d",
                reader.getReferencePixelTargetTableId()));
            System.out.println(String.format("CMP ID = %d",
                reader.getCompressionTableId()));

            if (dbEnabled) {
                printDates(reader);
            }

            List<Integer> pixelValues = printCompletenessPercentage(reader,
                pixelCount);

            if (dbEnabled) {
                printGappedModOuts(reader, pixelValues);
            }
        } else {
            throw new Exception(
                "Specified RP does not exist or is not a regular file: "
                    + rpFile);
        }
    }

    private static void printGappedModOuts(RefPixelFileReader reader,
        List<Integer> pixelValues) {
        Iterator<Integer> pixelValuesIterator = pixelValues.iterator();
        Set<Pair<Integer, Integer>> gappedModOuts = new LinkedHashSet<Pair<Integer, Integer>>();
        TargetCrud targetCrud = new TargetCrud();
        TargetTable targetTable = targetCrud.retrieveUplinkedTargetTable(
            reader.getReferencePixelTargetTableId(), TargetType.REFERENCE_PIXEL);
        int targetTablePixelCount = 0;
        int actualPixelCount = 0;

        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                List<TargetDefinition> targetDefs = targetCrud.retrieveTargetDefinitions(
                    targetTable, ccdModule, ccdOutput);
                for (TargetDefinition targetDef : targetDefs) {
                    targetTablePixelCount += targetDef.getMask().getOffsets().size();
                    for (@SuppressWarnings("unused")
                    Offset offset : targetDef.getMask()
                        .getOffsets()) {
                        if(pixelValuesIterator.hasNext()){
                            actualPixelCount++;
                            Integer pixelValue = pixelValuesIterator.next();
                            if (pixelValue == GAP_INDICATOR_VALUE) {
                                gappedModOuts.add(Pair.of(ccdModule, ccdOutput));
                            }
                        }
                    }
                }
            }
        }
        
        if (!gappedModOuts.isEmpty()) {
            System.out.println("Gapped Mod/Outs:");
            for (Pair<Integer, Integer> gappedModOut : gappedModOuts) {
                System.out.println(gappedModOut.left + "/" + gappedModOut.right);
            }
        }
        
        if(targetTablePixelCount != actualPixelCount){
            System.out.println("*** ERROR ***: Num actual pixels does not match number of target pixels, .rp file is truncated");
            System.out.println("Num target table pixels: " + targetTablePixelCount);
            System.out.println("Num actual pixels: " + actualPixelCount);
        }
    }

    private static List<Integer> printCompletenessPercentage(
        RefPixelFileReader reader, int pixelCount) throws EOFException {
        int gappedPixelCount = 0;
        List<Integer> pixelValues = new ArrayList<Integer>();
        for (int i = 0; i < pixelCount; i++) {
            int pixelValue = reader.readNextPixel();
            pixelValues.add(pixelValue);

            if (pixelValue == GAP_INDICATOR_VALUE) {
                gappedPixelCount++;
            }
        }
        DecimalFormat decimalFormat = new DecimalFormat();
        double percentComplete = ((pixelCount - gappedPixelCount) / (double) pixelCount) * 100;
        System.out.println(decimalFormat.format(gappedPixelCount) + " out of "
            + decimalFormat.format(pixelCount) + " pixels are gapped ("
            + String.format("%.1f", percentComplete) + "% complete)");

        return pixelValues;
    }

    private static void printDates(RefPixelFileReader reader)
        throws SpiceException {
        VtcOperations vtcOperations = new VtcOperations();
        double mjd = vtcOperations.getMjd(reader.getTimestamp());
        System.out.println("mjd = " + mjd);

        Date date = ModifiedJulianDate.mjdToDate(mjd);
        String iso8601FormattedDate = Iso8601Formatter.dateTimeFormatter()
            .format(date);
        System.out.println("iso8601FormattedDate = " + iso8601FormattedDate);
    }
}
