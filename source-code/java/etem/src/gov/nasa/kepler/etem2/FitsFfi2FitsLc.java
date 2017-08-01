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

package gov.nasa.kepler.etem2;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.primitives.Ints.toArray;
import static gov.nasa.kepler.common.FcConstants.CCD_COLUMNS;
import static gov.nasa.kepler.common.FcConstants.CCD_ROWS;
import static gov.nasa.kepler.common.FcConstants.getChannelNumber;
import static gov.nasa.kepler.common.FcConstants.nColsImaging;
import static gov.nasa.kepler.common.FcConstants.nLeadingBlack;
import static gov.nasa.kepler.common.FitsConstants.*;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.ConfigMap.ConfigMapMnemonic;
import gov.nasa.kepler.dr.NmGenerator;
import gov.nasa.kepler.etem.CollateralCadenceFits;
import gov.nasa.kepler.etem.KeplerFits;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.Header;
import nom.tam.fits.ImageData;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;

public class FitsFfi2FitsLc extends Etem2FitsLong {
    private static final Log log = LogFactory.getLog(FitsFfi2FitsLc.class);

    /**
     * This class consumes FFI data (see FS-GS ICD 5.3.1.3.4) from a FITS file
     * to produce Long Cadence data file (5.3.1.3.1) in a new FITS file.
     * 
     * Each FFI data file contains the FFI data for a given module. 1132 columns
     * * 1070 rows * 4 bytes per pixel * 4 outputs per module = 19,379,960
     * bytes. FFI data is pixels in row/column order. Target pixels are
     * extracted using target definitions retrieved from the database.
     * Background pixels are likewise extracted. Collateral data are extracted
     * by predefined rows and columns: Black: 1070 values, each a sum of
     * specified pixels in each MODOUT row. Masked smear: 1100 values, each a
     * sum of specified pixels in each MODOUT column. Virtual smear: 1100
     * values, each a sum of specified pixels in each MODOUT column.
     * 
     * After extraction, data is written to the Long Cadence data file. Target
     * pixels, then background pixels, then collateral values.
     * 
     * Implementation note: This class extends Etem2FitsLong. It overrides the
     * init() method to point to data in the FFI FITS file rather than the ETEM
     * data file. It overrides the readPixel() method to retrieve FFI data
     * rather than ETEM data. We may want to refactor Etem2FitsLong to split out
     * a separate FitsLongWriter class, and FfiFits2LcFits could then use
     * FitsLongWriter rather than extend Etem2FitsLong.
     */

    public static final int NUM_MASKED_SMEAR_VALUES = nColsImaging;
    public static final int NUM_VIRTUAL_SMEAR_VALUES = nColsImaging;

    public static final int NUM_BLACK_VALUES = CCD_ROWS;

    public static final int NUM_PIXELS_PER_MODOUT = CCD_COLUMNS * CCD_ROWS;
    public static final int NUM_BYTES_PER_PIXEL = 4;
    public static final int NUM_BYTES_PER_MODOUT = NUM_PIXELS_PER_MODOUT
        * NUM_BYTES_PER_PIXEL;

    private final static int MAX_PIXEL_VALUE = 8388607; // 2^23-1

    private String inputFfiFitsFilename;
    private Fits ffi;
    private BasicHDU ffiPrimaryHdu;
    private Header ffiPrimaryHeader;

    /*
     * Collateral data values get requantization adjustment to bring them into
     * the range of target pixel values so that compression table works for both
     * target data and collateral data. Etem2Fits.loadRequantizationTable()
     * loads int[] meanBlackValues, one int per CCD. The meanBlackValue is
     * subtracted from each black value as they are co-added. There is also a
     * global fixedOffsetForRequantAdjustment which is added after the
     * co-adding.
     */
    // private int fixedOffsetForRequantAdjustment = (int) (new
    // PlannedSpacecraftConfigParameters()).getLcRequantFixedOffset();
    // 419405;
    private int fixedOffsetForRequantAdjustment;

    private int smearStartRow;
    private int smearEndRow;

    private int maskedStartRow;
    private int maskedEndRow;

    private int darkStartCol;
    private int darkEndCol;

    // private int fgsFramesPerIntegration;
    // private double millisecondsPerFgsFrame;
    // private double millisecondsPerReadout;
    // private int integrationsPerShortCadence;
    private double startTime;
    private double endTime;

    private int numFfiIntegrations;
    private int numLcIntegrations;

    protected int[][] modoutData = new int[CCD_ROWS][CCD_COLUMNS];

    private byte[] lcData = new byte[NUM_BYTES_PER_MODOUT];
    private int lcDataIndex = 0;
    private int lcDataLength = 0;

    private int inputGapPixels = 0;
    private int usedGapPixels = 0;
    private int hduCount = 1;

    protected int channel;
    private int ccdModule;
    private int ccdOutput;

    /**
     * 
     * @param outputDir here we write _lcs-targ.fits, _lcs-bkg.fits, and
     * _lcs-col.fits
     * @param inputFfiFitsFilename input _ffi.fits file
     * @param targetListSetName must be a value in database
     * CM_TARGET_LIST_SET.NAME
     */
    public FitsFfi2FitsLc(String targetListSetName, int cadenceNumber,
        int compressionId, String masterFitsDir, String inputFfiFitsFilename,
        String outputDir) throws Exception {
        // we must call super() before we can extract certain values from the
        // FFI FITS file,
        // so for those values we pass nulls and zeros to our parent's
        // constructor.
        super(outputDir, null, // inputDir,
            0, // cadenceZeroMjd
            cadenceNumber, cadenceNumber, null,// startCadence, endCadence,
            targetListSetName, //
            0, // scConfigId, value set in
               // initializeFromInput
            masterFitsDir, //
            0, // secsPerShortCadence
            0, // shortCadencesPerLong
            compressionId, //
            0, // badId, value set in initializeTableIds
            0, // bgpId, value set in initializeTableIds
            0, // tadId, value set in initializeTableIds
            0, // lctId, value set in initializeTableIds
            0, // sctId, value doesn't matter according to MCote
            0 // rptId, value doesn't matter according to MCote
        );

        this.inputFfiFitsFilename = inputFfiFitsFilename;

        initializeFromInput(); // FFI FITS file primary header has values that
        // we must set in our parent class

        initializeFromConfig(); // Config has CCD dimensions

        initializeTableIds(targetListSetName);

        loadRequantizationTable(compressionId); // get mean black values
        log.info("meanBlackValues.length=" + meanBlackValues.length);
        for (int i = 0; i < meanBlackValues.length; i++) {
            log.info("meanBlackValues[" + i + "]=" + meanBlackValues[i]);
        }

        setRequantEnabled(false);
    }

    /**
     * FFI FITS file primary header has values that we must set in our parent
     * class.
     */
    private void initializeFromInput() throws Exception {
        // get some values for the LC FITS file from the FFI FITS file
        ffi = new Fits(inputFfiFitsFilename);
        ffiPrimaryHdu = ffi.readHDU();
        if (ffiPrimaryHdu == null) {
            exception("primary HDU not found");
        }
        ffiPrimaryHeader = ffiPrimaryHdu.getHeader();

        startTime = getFfiDoubleValue(STARTIME_KW);
        endTime = getFfiDoubleValue(END_TIME_KW);

        // startTime is NOT the correct value for cadenceZeroMjd.
        // In generateFits(), the start-time value written into the output
        // FITS files is computed as cadenceZeroMjd offset by the cadenceNumber.
        // But FitsFfi2FitsLc will be run with a very large cadenceNumber
        // because it will process an FFI at the time of commissioning
        // and we do not want to specify a cadence number that will conflict
        // with any cadence numbers used during the mission.
        // So, the output FITS files will have incorrect STARTIME and END_TIME
        // values in their primary headers.
        // In run(), these values are corrected.
        // Note: We discussed adjusting the cadenceZeroMjd
        // time by subtracting the offset caused by the cadenceNumber.
        // But we have had trouble with date arithmetic.
        setCadenceZeroMjd(startTime);
        log.info("INPUT startTime=" + startTime);
        log.info("INPUT endTime=" + endTime);

        setScConfigId(getFfiIntValue(SCCONFID_KW));

        // setCompressionId( getFfiIntValue( COMPTABL_KW )); // TODO correct?
        // setExternalId( getFfiIntValue( "???" ));
        // TODO is externalId in FFI FITS header?
        // In other Etem2Fits classes, externalId is used both as targetTableId
        // and apertureId to create the filename:
        // kplr<time>-<targtableid>-<apertureid>.<filetype>.fits
    }

    /**
     * ConfigMap has meanBlack values we need.
     */
    private void initializeFromConfig() throws Exception {
        // double cadenceZeroMjd = getStartMjd();
        int scConfigId = getScConfigId();
        ConfigMapOperations cmo = new ConfigMapOperations();
        ConfigMap map = cmo.retrieveConfigMap(scConfigId);

        // for (int i = 0; i < configMnemonics.length; i++) {
        // configValues[i] = map.getInt(configMnemonics[i]);
        // log.info("init: " + configMnemonics[i] + "=" + configValues[i]);
        // }

        smearStartRow = map.getInt(ConfigMapMnemonic.smearStartRow);
        smearEndRow = map.getInt(ConfigMapMnemonic.smearEndRow);
        log.info("smearStartRow = " + smearStartRow);
        log.info("smearEndRow = " + smearEndRow);

        maskedStartRow = map.getInt(ConfigMapMnemonic.maskedStartRow);
        maskedEndRow = map.getInt(ConfigMapMnemonic.maskedEndRow);
        log.info("maskedStartRow = " + maskedStartRow);
        log.info("maskedEndRow = " + maskedEndRow);

        darkStartCol = map.getInt(ConfigMapMnemonic.darkStartCol);
        darkEndCol = map.getInt(ConfigMapMnemonic.darkEndCol);
        log.info("darkStartCol = " + darkStartCol);
        log.info("darkEndCol = " + darkEndCol);

        fixedOffsetForRequantAdjustment = map.getInt(ConfigMapMnemonic.lcRequantFixedOffset);
        log.info("fixedOffsetForRequantAdjustment = "
            + fixedOffsetForRequantAdjustment);

        numFfiIntegrations = map.getInt(ConfigMapMnemonic.integrationsPerScienceFfi);
        numLcIntegrations = map.getInt(ConfigMapMnemonic.integrationsPerShortCadence)
            * map.getInt(ConfigMapMnemonic.shortCadencesPerLongCadence);

        log.info("numFfiIntegrations = " + numFfiIntegrations);
        log.info("numLcIntegrations = " + numFfiIntegrations);

        if (numFfiIntegrations != numLcIntegrations) {
            throw new PipelineException(
                "Number of FFI integrations ("
                    + numFfiIntegrations
                    + ") does not match the number of LC integrations ("
                    + numLcIntegrations
                    + ") in the config map.  This will cause problems later in CAL because it uses the number of LC integrations");
        }

        log.info("startTime=" + startTime);
        log.info("endTime=" + endTime);
    }

    /**
     * @param args[0] target list set name
     * @param args[1] cadence number
     * @param args[2] compression ID
     * @param args[3] master FITS directory
     * @param args[4] input FFI FITS filename
     * @param args[5] output directory for LC FITS files
     */
    public static void main(String[] args) throws Exception {
        Logger logger = Logger.getLogger(FitsFfi2FitsLc.class);
        logger.setLevel(Level.INFO);

        org.apache.log4j.BasicConfigurator.configure();

        clearState(); // prepare caches, including targetdefs

        log.debug("args.length = " + args.length);
        for (int i = 0; i < args.length; i++) {
            log.debug("arg " + i + " = " + args[i]);
        }

        if (args.length != 6) {
            throw new Exception("usage: "
                + "java FitsFfi2FitsLc <targetListSetName> "
                + "<cadenceNumber> <compressionId> " + "<masterFitsDir> "
                + "<inputFilename> <outputDirectory>");
        }

        String targetListSetName = args[0];
        int cadenceNumber = Integer.parseInt(args[1]);
        int compressionId = Integer.parseInt(args[2]);
        String masterFitsDir = args[3];
        String inputFfiFitsFilename = args[4];
        String outputDir = args[5];

        log.info("targetListSetName = " + targetListSetName);
        log.info("cadenceNumber = " + cadenceNumber);
        log.info("compressionId = " + compressionId);
        log.info("masterFitsDir = " + masterFitsDir);
        log.info("inputFfiFitsFilename = " + inputFfiFitsFilename);
        log.info("outputDir = " + outputDir);

        FitsFfi2FitsLc x = new FitsFfi2FitsLc(targetListSetName, cadenceNumber,
            compressionId, masterFitsDir, inputFfiFitsFilename, outputDir);

        log.info("FitsFfi2FitsLc running");
        x.run();

        log.info("FitsFfi2FitsLc DONE");
    }

    private void initializeTableIds(String targetListSetName) {
        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud(
            dbService);

        TargetListSet targetListSet = targetSelectionCrud.retrieveTargetListSet(targetListSetName);

        if (targetListSet == null) {
            throw new PipelineException("No targetListSet found for name: "
                + targetListSetName);
        }

        TargetTable targetTable = targetListSet.getTargetTable();

        if (targetTable == null) {
            throw new PipelineException(
                "No targetTable found for targetListSetName: "
                    + targetListSetName);
        }

        TargetTable backgroundTable = targetListSet.getBackgroundTable();

        if (backgroundTable == null) {
            throw new PipelineException(
                "No backgroundTable found for targetListSetName: "
                    + targetListSetName);
        }

        badId = backgroundTable.getMaskTable()
            .getExternalId();
        if (badId < 0) {
            throw new PipelineException("Invalid background mask table ID: "
                + badId);
        }

        bgpId = backgroundTable.getExternalId();
        if (bgpId < 0) {
            throw new PipelineException("Invalid background table ID: " + bgpId);
        }

        tadId = targetTable.getMaskTable()
            .getExternalId();
        if (bgpId < 0) {
            throw new PipelineException("Invalid target mask table ID: "
                + tadId);
        }

        lctId = targetTable.getExternalId();
        if (bgpId < 0) {
            throw new PipelineException("Invalid target table ID: " + lctId);
        }
    }

    public void run() throws Exception {
        generateFits();

        // Now generate PMRF files.
        Tad2PmrfLong pmrfGenerator = new Tad2PmrfLong(targetListSetName,
            outputDir, getCadenceZeroMjd(), getScConfigId(), masterFitsPath, // null,
            0, 0, compressionId, badId, bgpId, tadId, lctId, sctId, rptId);
        pmrfGenerator.export();

        // See comment in initFromInput().
        fixHeaderValuesInOutputFitsFile(targetPixelData);
        fixHeaderValuesInOutputFitsFile(bkgrndPixelData);
        fixHeaderValuesInOutputFitsFile(ctlPixelData);

        NmGenerator.generateNotificationMessage(outputDir, "sfnm");
    }

    private void fixHeaderValuesInOutputFitsFile(KeplerFits output)
        throws Exception {
        String outputFilename = output.getFilename();

        log.info("fixing STARTIME and END_TIME in " + outputFilename);

        FitsHeaderEditor fhe = new FitsHeaderEditor();

        HashMap<String, Object> primaryHeaderAttributeValuePairs = new HashMap<String, Object>();
        primaryHeaderAttributeValuePairs.put(
            STARTIME_KW, startTime);
        primaryHeaderAttributeValuePairs.put(
            END_TIME_KW, endTime);

        File outputFile = new File(outputFilename);
        File newOutputFile = new File(outputFilename + ".new");

        fhe.editFile(outputFile, newOutputFile,
            primaryHeaderAttributeValuePairs, null);

        // outputFile.renameTo(new File(outputFilename + ".old"));
        if (!outputFile.delete()) {
            throw new Exception("unable to delete " + outputFilename);
        }
        if (!newOutputFile.renameTo(outputFile)) {
            throw new Exception("unable to rename "
                + newOutputFile.getAbsolutePath());
        }

        // String filename = output.getFilename();
        // Fits fits = new Fits(filename);
        // BasicHDU primaryHdu = fits.readHDU();
        // if (primaryHdu == null) {
        // exception("primary HDU not found in " + filename);
        // }
        //
        // Header primaryHeader = primaryHdu.getHeader();
        // primaryHeader.addValue(PixelDispatcher.HDR_MJD_STRT_KEYWORD,
        // startTime,
        // "boogie");
        // primaryHeader.addValue(PixelDispatcher.HDR_MJD_END_KEYWORD, endTime,
        // "woogie");
        //
        // output.save();
    }

    private void clearLcData() {
        lcDataIndex = 0;
        lcDataLength = 0;
    }

    private void addByteToLcData(byte b) {
        // log.info("byte="+Integer.toHexString(b));
        lcData[lcDataLength++] = b;
    }

    private void addIntToLcData(int i) {
        if (i > MAX_PIXEL_VALUE) {
            log.error("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ too large pixel value: "
                + i);
            log.error("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ MAX_PIXEL_VALUE: "
                + MAX_PIXEL_VALUE);
            System.exit(0);
        }
        addByteToLcData(getByte(i, 0));
        addByteToLcData(getByte(i, 1));
        addByteToLcData(getByte(i, 2));
        addByteToLcData(getByte(i, 3));
    }

    private void addPixelsToLcData(List<TargetDefinition> targetDefinitions) {
        int targetIdx = 0;
        for (TargetDefinition targetDef : targetDefinitions) {
            targetIdx++;
            log.debug("targetIdx=" + targetIdx);
            if (0 == targetIdx % 100) {
                log.debug("target=" + targetIdx);
            }

            int refCol = targetDef.getReferenceColumn();
            int refRow = targetDef.getReferenceRow();
            // log.debug("refRow=" + refRow + ", refCol=" + refCol);
            Mask mask = targetDef.getMask();
            List<Offset> offsets = mask.getOffsets();
            for (Offset offset : offsets) {
                int row = refRow + offset.getRow();
                int col = refCol + offset.getColumn();
                int pixel = modoutData[row][col];
                // log.info("row="+row+", col="+col+", pixel=" + pixel + " + " +
                // Integer.toHexString(pixel));
                if (isPixelGap(pixel)) {
                    addIntToLcData(pixel);
                } else {
                    int value = pixel - adjustedMeanBlack(channel)
                        + fixedOffsetForRequantAdjustment;
                    if (targetIdx == 1) {
                        log.info("row=" + row + ", col=" + col + ": pixel ("
                            + pixel + ") - mb(" + adjustedMeanBlack(channel)
                            + ") + fo(" + fixedOffsetForRequantAdjustment
                            + ") = " + value);
                    }
                    addIntToLcData(value);
                }
            }
        }
    }

    protected List<Integer> getRawValueColumn(
        List<TargetDefinition> targetDefinitions) throws Exception {
        int nTargets = targetDefinitions.size();
        int targetIdx = 0;
        log.debug("nTargets=" + nTargets);

        List<Integer> rawValueColumn = newArrayList();

        for (TargetDefinition targetDef : targetDefinitions) {
            if (0 == targetIdx % 100) {
                log.debug("target=" + targetIdx);
            }

            int numOffsets = targetDef.getMask()
                .getOffsets()
                .size();

            for (int i = 0; i < numOffsets; i++) {
                pixelValue = readPixel();
                rawValueColumn.add(pixelValue);
            }

            numStarPixelsRead++;
            pixelsReadThisCadence++;
            targetIdx++;
        }
        return rawValueColumn;
    }

    @Override
    protected void processCollateralPixels(CollateralCadenceFits ctlPixelData,
        Etem2Metadata etemMetadata, int ccdModule, int ccdOutput)
        throws Exception {

        PixelCounts pixelCounts = etemMetadata.getPixelCounts();

        List<Integer> rawValueColumn = newArrayList();

        // leading black
        // for (int i = 0; i < NUM_CCD_ROWS; i++)
        for (int i = 0; i < pixelCounts.getNBlackValues(); i++) {
            pixelValue = readPixel();
            rawValueColumn.add(pixelValue);
            numCollateralPixelsRead++;
        }

        // masked smear
        // for (int i = 0; i < NUM_CCD_COLS; i++)
        for (int i = 0; i < pixelCounts.getNMaskedSmearValues(); i++) {
            pixelValue = readPixel();
            rawValueColumn.add(pixelValue);
            numCollateralPixelsRead++;
        }

        // virtual smear
        // for (int i = 0; i < NUM_CCD_COLS; i++)
        for (int i = 0; i < pixelCounts.getNVirtualSmearValues(); i++) {
            pixelValue = readPixel();
            rawValueColumn.add(pixelValue);
            numCollateralPixelsRead++;
        }

        ctlPixelData.addColumns(toArray(rawValueColumn));
    }

    private boolean isPixelGap(int pixel) {
        if (pixel == MISSING_PIXEL_VALUE) {
            usedGapPixels++;
            return true;
        }
        return false;
    }

    private int adjustedPixel(int row, int col, int channel) {
        int pixel = modoutData[row][col];
        if (isPixelGap(pixel)) {
            // gaps are not co-added
            return 0;
        }
        return pixel - adjustedMeanBlack(channel);
    }

    private int adjustedMeanBlack(int channel) {
        return meanBlackValues[channel - 1] * numFfiIntegrations;
    }

    // The spacecraft can only hold pixels values up to 2^23-1.
    // While co-adding pixel values, the value wraps if it exceeds that limit.
    private int wrap(int i) {
        return i % (MAX_PIXEL_VALUE + 1);
    }

    protected void readNextFfiModoutData() throws Exception {
        BasicHDU hdu = null;
        Header hdr;
        ffi = new Fits(inputFfiFitsFilename);
        hduCount = 0;
        int ichannel = -1;

        hduCount = channel;
        hdu = ffi.getHDU(hduCount);
        if (hdu == null) {
            exception("HDU #" + hduCount + " not found");
        }
        hdr = hdu.getHeader();
        ichannel = hdr.getIntValue(CHANNEL_KW);
        if (ichannel != channel) {
            exception("HDU #" + hduCount + " has CHANNEL=" + ichannel);
        }

        //
        ImageData data = (ImageData) hdu.getData();
        log.info("@@@@@@@@@@@@@@@@@ channel=" + channel + ", datasize="
            + data.getSize());

        int[][] image = (int[][]) data.getData();
        if (image == null) {
            exception("HDU getData returned null");
        }
        log.debug("image.length=" + image.length);

        // put data into convenient arrays
        int nNonZero = 0;
        usedGapPixels = 0;
        inputGapPixels = 0;
        for (int row = 0; row < CCD_ROWS; row++) {
            int[] rowData = image[row];
            // log.debug("rowData.length="+rowData.length);
            if (rowData == null) {
                exception("HDU getData element " + row + " is null");
            }
            for (int column = 0; column < CCD_COLUMNS; column++) {
                // int bits = Float.floatToRawIntBits(rowData[column]);
                int bits = rowData[column];
                if (bits == MISSING_PIXEL_VALUE) {
                    inputGapPixels++;
                }
                log.debug("col=" + column + ": f=" + rowData[column] + " bits="
                    + Integer.toHexString(bits));
                modoutData[row][column] = bits;
                if (modoutData[row][column] != 0) {
                    nNonZero++;
                }
            }
        }
        // log.info("number of non-zero pixels = " + nNonZero);
        log.info("channel=" + channel + ", inputGapPixels=" + inputGapPixels);
        if (nNonZero == 0) {
            log.error("ALL PIXELS HAD A VALUE OF ZERO FOR CHANNEL " + channel);
        }

    }

    /**
     * Load data from FFI FITS file HDU (one mod/out of data) into the lcData
     * array. The overridden readPixel() method will read from the lcData array
     * (instead of a file as Etem2FitsLong, our parent class, usually does).
     * 
     * Each target/background pixel value is adjusted by the "mean black" and
     * fixed offset.
     * 
     * Black pixel values are adjusted by the "mean black" and co-added. These
     * row sums are adjusted by the fixed offset.
     * 
     * Masked smear and virtual smear pixels are similarly adjusted and co-added
     * to produce column sums which are then adjusted by the fixed offset.
     * 
     * @throws Exception
     */
    private void loadLcData() throws Exception {
        clearLcData();

        readNextFfiModoutData();

        // extract target pixels into lcData
        addPixelsToLcData(targetDefinitions);
        log.info("after target pixels: lcDataLength=" + lcDataLength);

        // extract background target pixels into lcData
        addPixelsToLcData(backgroundTargetDefinitions);
        log.info("after bkgrnd pixels: lcDataLength=" + lcDataLength);

        // Extract black values into lcData,
        // one co-added black value per CCD row.
        for (int row = 0; row < CCD_ROWS; row++) {
            int blackValue = 0;
            for (int col = darkStartCol; col <= darkEndCol; col++) {
                blackValue += adjustedPixel(row, col, channel);
            }
            blackValue += fixedOffsetForRequantAdjustment;
            addIntToLcData(wrap(blackValue));
            log.debug("BLACK: row=" + row + ", value=" + blackValue);
        }
        log.info("after black values: lcDataLength=" + lcDataLength);

        // Extract masked values into lcData,
        // one co-added masked smear value per CCD column.
        for (int col = nLeadingBlack; col < nLeadingBlack + nColsImaging; col++) {
            int maskedSmearValue = 0;
            for (int row = maskedStartRow; row <= maskedEndRow; row++) {
                maskedSmearValue += adjustedPixel(row, col, channel);
            }
            maskedSmearValue += fixedOffsetForRequantAdjustment;
            addIntToLcData(wrap(maskedSmearValue));
            log.debug("MASKED SMEAR: col=" + col + ", value="
                + maskedSmearValue);
        }
        log.info("after masked values: lcDataLength=" + lcDataLength);

        // Extract virtual smear values into lcData,
        // one co-added virtual smear value per CCD column.
        for (int col = nLeadingBlack; col < nLeadingBlack + nColsImaging; col++) {
            int virtualSmearValue = 0;
            for (int row = smearStartRow; row < smearEndRow; row++) {
                virtualSmearValue += adjustedPixel(row, col, channel);
            }
            virtualSmearValue += fixedOffsetForRequantAdjustment;
            addIntToLcData(wrap(virtualSmearValue));
            log.debug("VIRTUAL SMEAR: col=" + col + ", value="
                + virtualSmearValue);
        }
        log.info("after virtual values: lcDataLength=" + lcDataLength);
        log.info("usedGapPixels=" + usedGapPixels);
    }

    @Override
    /**
     * called by mod/out loop in Etem2FitsLong.generateFits() which loads
     * targetDefs for current mod/out
     */
    protected boolean init(int ccdModule, int ccdOutput) throws Exception {
        // setup Etem2Fits.pixelData for this modout

        this.channel = getChannelNumber(ccdModule, ccdOutput);
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;

        loadLcData();
        /*
         * pixelData = new DataInputStream( new ByteArrayInputStream( lcData )
         * );
         * 
         * PixelCounts pixelCounts = new PixelCounts();
         * pixelCounts.setNBlackValues(NUM_BLACK_VALUES);
         * pixelCounts.setNMaskedSmearValues(NUM_MASKED_SMEAR_VALUES);
         * pixelCounts.setNVirtualSmearValues(NUM_VIRTUAL_SMEAR_VALUES);
         * //metadataCache[0] = new Etem2Metadata(pixelCounts);
         * 
         * setEtemMetadata( channel, new Etem2Metadata(pixelCounts) );
         */

        // init successful.
        return true;
    }

    @Override
    protected void openEtemPixelDataFile() throws IOException {
        pixelData = new DataInputStream(new ByteArrayInputStream(lcData));

        PixelCounts pixelCounts = new PixelCounts();
        pixelCounts.setNBlackValues(NUM_BLACK_VALUES);
        pixelCounts.setNMaskedSmearValues(NUM_MASKED_SMEAR_VALUES);
        pixelCounts.setNVirtualSmearValues(NUM_VIRTUAL_SMEAR_VALUES);
        // metadataCache[0] = new Etem2Metadata(pixelCounts);

        setEtemMetadata(channel, new Etem2Metadata(pixelCounts));
    }

    @Override
    protected int readPixel() throws Exception {
        int pixel = readByte(24);
        pixel = pixel | readByte(16);
        pixel = pixel | readByte(8);
        pixel = pixel | readByte(0);

        return pixelValue = pixel;
        // return pixelValue = findBestRequantizedIndex(pixel);
    }

    int x = 0;

    HashMap<Integer, Integer> knownBestIndexes = new HashMap<Integer, Integer>();

    // private int findBestRequantizedIndex(int pixelValue) {
    // Integer knownBest = knownBestIndexes.get(pixelValue);
    // if (knownBest != null) {
    // // System.err.println( knownBest);
    // return knownBest;
    // }
    //
    // int indexOfLeastDiff = 0;
    // int leastDiff = Math.abs(pixelValue
    // - indexedPixelValues[indexOfLeastDiff]);
    //
    // for (int i = 1; i < indexedPixelValues.length; i++) {
    // int diff = Math.abs(pixelValue - indexedPixelValues[i]);
    // if (diff > leastDiff) {
    // break;
    // }
    // if (diff < leastDiff) {
    // indexOfLeastDiff = i;
    // leastDiff = diff;
    // }
    // }
    // // System.err.println(
    // // indexedPixelValues.length+":"+pixelValue+","+indexOfLeastDiff);
    // knownBestIndexes.put(pixelValue, indexOfLeastDiff);
    // return indexOfLeastDiff;
    // }

    protected int readByte(int shift) throws Exception {
        if (lcDataIndex >= lcDataLength) {
            exception("readPixel ran out of data: lcDataLength=" + lcDataLength);
        }
        int i = lcData[lcDataIndex++];
        // log.info(lcDataIndex + ", " + Integer.toHexString(i));
        i = i << 24;
        i = i >>> 24;
        i = i << shift;
        return i;
    }

    protected byte getByte(int i, int byteOffset) {
        final int[] left_shifts = { 24, 16, 8, 0 };
        i = i >> left_shifts[byteOffset];
        i = i << 24;
        i = i >>> 24;
        return (byte) i;
    }

    private void exception(String msg) throws Exception {
        msg = "FFI=" + inputFfiFitsFilename + "\nmod/out/channel=" + ccdModule
            + "/" + ccdOutput + "/" + channel + ": " + msg;
        log.error(msg);
        throw new Exception(msg);
    }

    private void exceptionOnInit(String msg) throws Exception {
        msg = "FFI=" + inputFfiFitsFilename + msg;
        log.error(msg);
        throw new Exception(msg);
    }

    /*
     * private String getHeaderValue( Header hdr, String key ) { // For some
     * weird reason, hdr.getStringValue worked for the first HDU // but returned
     * null for all keys for all subsequent HDUs. // return
     * hdr.getStringValue(key); String value = null; Cursor iter =
     * hdr.iterator(); while ( iter.hasNext() ) { HeaderCard card = (HeaderCard)
     * iter.next(); if ( card.isKeyValuePair() ) { String cardKey =
     * card.getKey(); String cardValue = card.getValue(); //log.debug( "key=" +
     * key + ", =" + value1 ); if ( key.equals(cardKey)) { value = cardValue;
     * break; } } } log.debug("key="+key+", value="+value); return value; }
     */

    /*
     * private String getFfiStringValue( String attrName ) throws Exception {
     * String x = null; try { x = ffiPrimaryHeader.getStringValue( attrName ); }
     * catch ( Exception e ) { exceptionOnInit( e.getMessage()); } return x; }
     */

    private int getFfiIntValue(String attrName) throws Exception {
        int x = -1;
        try {
            x = ffiPrimaryHeader.getIntValue(attrName);
        } catch (Exception e) {
            exceptionOnInit(e.getMessage());
        }
        return x;
    }

    private double getFfiDoubleValue(String attrName) throws Exception {
        double x = -1;
        try {
            x = ffiPrimaryHeader.getDoubleValue(attrName);
        } catch (Exception e) {
            exceptionOnInit(e.getMessage());
        }
        return x;
    }

}
