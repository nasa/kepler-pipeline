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

package gov.nasa.kepler.systest.validation.pixels;

import static gov.nasa.kepler.common.FitsConstants.BACKGROUND_PMRF_KW;
import static gov.nasa.kepler.common.FitsConstants.CADENNUM_KW;
import static gov.nasa.kepler.common.FitsConstants.DATATYPE_KW;
import static gov.nasa.kepler.common.FitsConstants.LC_INTER_KW;
import static gov.nasa.kepler.common.FitsConstants.LONG_CADENCE_COLLATERAL_PMRF_KW;
import static gov.nasa.kepler.common.FitsConstants.LONG_CADENCE_PMRF_KW;
import static gov.nasa.kepler.common.FitsConstants.MODULE_KW;
import static gov.nasa.kepler.common.FitsConstants.OUTPUT_KW;
import static gov.nasa.kepler.common.FitsConstants.SC_INTER_KW;
import static gov.nasa.kepler.common.FitsConstants.SHORT_CADENCE_COLLATERAL_PMRF_KW;
import static gov.nasa.kepler.common.FitsConstants.SHORT_CADENCE_PMRF_KW;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.systest.validation.ValidationUtils;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;
import java.util.TreeMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.BinaryTable;
import nom.tam.fits.Data;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;
import nom.tam.fits.Header;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Extracts a cadence slice of pixel data from FITS file.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class FitsPixelExtractor {

    private static final Log log = LogFactory.getLog(FitsPixelExtractor.class);

    // Indices into Number list that appear in returned maps.
    public static final int ORIGINAL_VALUE = 0;
    public static final int CALIBRATED_VALUE = 1;
    public static final int CALIBRATED_UNCERTAINTY = 2;
    public static final int TARGET_ID = 3;

    /**
     * Filename format for FITS pixel files. The %ss contain: 1. The date (see
     * {@link #mjdToDate(double)}). 2. The cadence type (`l' or `s'). 3. The
     * pixel type (see {@link FitsPixelType#getName()}).
     * 
     */
    private static final String FITS_PIXEL_FILE_REGEXP = "kplr%s_%scs-%s.fits";

    private static final String FITS_SUFFIX = ".fits";

    public enum FitsPixelType {
        BKG, COL, TARG;

        private static boolean isMember(String name) {
            for (FitsPixelType type : values()) {
                if (type.toString()
                    .equalsIgnoreCase(name)) {
                    return true;
                }
            }
            return false;
        }
    };

    private enum FitsCosmicRayType {
        CRCC, CRCT;

        private static boolean isMember(String name) {
            for (FitsCosmicRayType type : values()) {
                if (type.toString()
                    .equalsIgnoreCase(name)) {
                    return true;
                }
            }
            return false;
        }
    };

    private enum PixelPmrfFormat {
        ROW(0), COLUMN(1);
        private int column;

        private PixelPmrfFormat(int column) {
            this.column = column;
        }

        private int getColumn() {
            return column;
        }
    }

    private enum CollateralPmrfFormat {
        TYPE(0), OFFSET(1), TARGET_ID(2);
        private int column;

        private CollateralPmrfFormat(int column) {
            this.column = column;
        }

        private int getColumn() {
            return column;
        }
    }

    private enum PixelFileFormat {
        ORIGINAL_VALUE(0), CALIBRATED_VALUE(1), CALIBRATED_UNCERTAINTY(2);
        private int column;

        private PixelFileFormat(int column) {
            this.column = column;
        }

        private int getColumn() {
            return column;
        }
    }

    private enum CosmicRayFileFormat {
        ROW(0), COLUMN(1), CORRECTION_VALUE(2), TARGET_ID(3), APERTURE_ID(4);
        private int column;

        private CosmicRayFileFormat(int column) {
            this.column = column;
        }

        private int getColumn() {
            return column;
        }
    }

    private enum CollateralCosmicRayFileFormat {
        TYPE(0), OFFSET(1), CORRECTION_VALUE(2);
        private int column;

        private CollateralCosmicRayFileFormat(int column) {
            this.column = column;
        }

        private int getColumn() {
            return column;
        }
    }

    private TimestampSeries cadenceTimes;
    private int startCadence;
    private int endCadence = -1;
    private CadenceType cadenceType;
    private int ccdModule;
    private int ccdOutput;
    private File pmrfDirectory;
    private File fitsDirectory;
    private Map<FitsPixelType, PmrfMappings> pmrfCache = new HashMap<FitsPixelType, PmrfMappings>();
    private Map<Pair<Integer, String>, File> fileByCadenceAndType;

    public FitsPixelExtractor(int startCadence, int endCadence,
        CadenceType cadenceType, File fitsDirectory) {

        if (cadenceType == null) {
            throw new NullPointerException("cadenceType can't be null");
        }
        if (fitsDirectory == null) {
            throw new NullPointerException("fitsDirectory can't be null");
        }

        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.cadenceType = cadenceType;
        this.fitsDirectory = fitsDirectory;
    }

    public FitsPixelExtractor(TimestampSeries cadenceTimes, int startCadence,
        CadenceType cadenceType, int ccdModule, int ccdOutput,
        File pmrfDirectory, File fitsDirectory) {

        if (cadenceTimes == null) {
            throw new NullPointerException("cadenceTimes can't be null");
        }
        if (cadenceType == null) {
            throw new NullPointerException("cadenceType can't be null");
        }
        if (pmrfDirectory == null) {
            throw new NullPointerException("pmrfDirectory can't be null");
        }
        if (fitsDirectory == null) {
            throw new NullPointerException("fitsDirectory can't be null");
        }

        this.cadenceTimes = cadenceTimes;
        this.startCadence = startCadence;
        this.cadenceType = cadenceType;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.pmrfDirectory = pmrfDirectory;
        this.fitsDirectory = fitsDirectory;
    }

    public boolean extractPixels(
        int cadence,
        Map<Pair<Integer, Integer>, List<Number>> targetPixelValuesByRowColumn,
        Map<Pair<Integer, Integer>, List<Number>> backgroundPixelValuesByRowColumn,
        Map<Pair<CollateralType, Integer>, List<Number>> pixelValuesByCollateralTypeOffset)
        throws FitsException, IOException {

        // Check that correct constructor was used.
        if (pmrfDirectory == null || cadenceTimes == null) {
            throw new IllegalStateException("Wrong constructor used");
        }

        if (cadenceTimes.gapIndicators[cadence - startCadence]) {
            return true;
        }

        boolean success = true;
        for (FitsPixelType pixelType : FitsPixelType.values()) {
            if (pixelType == FitsPixelType.BKG
                && cadenceType == CadenceType.SHORT) {
                // Short cadence doesn't have background.
                continue;
            }

            File file = getFitsFile(cadence, pixelType.toString());
            Fits fitsFile = new Fits(file);
            try {
                String pmrfHeaderField = getPmrfHeaderField(pixelType);
                Header header = getFitsFileHeader(file, fitsFile, cadence);
                BinaryTable pixelTable = extractModOutBinaryTable(file,
                    fitsFile);
                PmrfMappings pmrfMappings = pmrfMappings(
                    header.getStringValue(pmrfHeaderField), pixelType);
                if (pixelType == FitsPixelType.COL) {
                    if (pixelValuesByCollateralTypeOffset != null
                        && !extractCollateralPixelValues(
                            (PmrfCollateralMappings) pmrfMappings, pixelTable,
                            pixelValuesByCollateralTypeOffset)) {
                        success = false;
                    }
                } else if (pixelType == FitsPixelType.BKG) {
                    if (backgroundPixelValuesByRowColumn != null) {
                        extractPixelValues((PmrfPixelMappings) pmrfMappings,
                            pixelTable, backgroundPixelValuesByRowColumn);
                    }
                } else if (targetPixelValuesByRowColumn != null) {
                    extractPixelValues((PmrfPixelMappings) pmrfMappings,
                        pixelTable, targetPixelValuesByRowColumn);
                }
            } finally {
                fitsFile.getStream()
                    .close();
            }
        }

        return success;
    }

    private File getFitsFile(int cadence, String type) throws FitsException,
        IOException {

        File file = getFileByCadenceAndTypeMap().get(Pair.of(cadence, type));
        if (file == null) {
            throw new IllegalStateException(
                String.format(
                    "Could not find FITS file in %s for cadence %d (approx %s), type %s",
                    fitsDirectory,
                    cadence,
                    mjdToDate(cadenceTimes.endTimestamps[cadence - startCadence]),
                    type));
        }

        return file;
    }

    private Map<Pair<Integer, String>, File> getFileByCadenceAndTypeMap()
        throws FitsException, IOException {

        if (fileByCadenceAndType == null) {
            fileByCadenceAndType = createFileByCadenceAndTypeMap(fitsDirectory);
        }

        return fileByCadenceAndType;
    }

    private Map<Pair<Integer, String>, File> createFileByCadenceAndTypeMap(
        File fitsDirectory) throws FitsException, IOException {

        long start = System.currentTimeMillis();
        log.info(String.format(
            "Reading cadence numbers from FITS files in %s...", fitsDirectory));

        Map<Pair<Integer, String>, File> fileByCadenceAndType = new TreeMap<Pair<Integer, String>, File>(
            new IntegerStringPairComparator());

        Pattern pattern = Pattern.compile(String.format(FITS_PIXEL_FILE_REGEXP,
            "\\d{13}", "[ls]", "([a-z]{3,4})"));
        File[] files = fitsDirectory.listFiles();
        for (File file : files) {
            if (!file.getName()
                .endsWith(FITS_SUFFIX)) {
                continue;
            }

            Matcher matcher = pattern.matcher(file.getName());
            if (!matcher.matches()) {
                throw new IllegalStateException(String.format(
                    "Failed to extract FITS pixel type from filename %s",
                    file.getName()));
            }
            String type = matcher.group(1)
                .toUpperCase();

            Fits fitsFile = new Fits(file);
            int cadence = -1;
            try {
                if (FitsPixelType.isMember(type)) {
                    cadence = getFitsFileHeader(fitsFile).getIntValue(
                        cadenceType == CadenceType.LONG ? LC_INTER_KW
                            : SC_INTER_KW);
                } else if (FitsCosmicRayType.isMember(type)) {
                    cadence = getFitsFileHeader(fitsFile).getIntValue(
                        CADENNUM_KW);
                } else {
                    log.warn(String.format(
                        "Unexpected type %s of FITS file %s", type,
                        file.getAbsolutePath()));
                    continue;
                }
            } finally {
                fitsFile.getStream()
                    .close();
            }

            fileByCadenceAndType.put(Pair.of(cadence, type), file);
        }

        log.info(String.format(
            "Reading cadence numbers from FITS files in %s...done (%d seconds)",
            fitsDirectory, (System.currentTimeMillis() - start) / 1000));

        return fileByCadenceAndType;
    }

    public Map<Pair<Integer, FitsPixelType>, String> findFitsFilesInCadenceRange()
        throws FitsException, IOException {

        if (endCadence < startCadence) {
            throw new IllegalStateException("Wrong constructor used");
        }

        Map<Pair<Integer, FitsPixelType>, String> filenameByCadence = new TreeMap<Pair<Integer, FitsPixelType>, String>(
            new IntegerFitsPixelTypePairComparator());

        Map<Pair<Integer, String>, File> fileByCadenceAndType = getFileByCadenceAndTypeMap();
        for (Map.Entry<Pair<Integer, String>, File> entry : fileByCadenceAndType.entrySet()) {
            int cadence = entry.getKey().left;
            String type = entry.getKey().right;
            File file = entry.getValue();

            if (cadence < startCadence || cadence > endCadence
                || !FitsPixelType.isMember(type)) {
                continue;
            }

            filenameByCadence.put(
                Pair.of(cadence, FitsPixelType.valueOf(type)), file.getName());
        }

        return filenameByCadence;
    }

    private String mjdToDate(double mjd) {

        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyDDDHHmmss",
            Locale.US);
        dateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
        String date = dateFormat.format(ModifiedJulianDate.mjdToDate(mjd));

        return date;
    }

    private String getPmrfHeaderField(FitsPixelType pixelType) {
        String headerField = null;
        switch (pixelType) {
            case TARG:
                headerField = cadenceType == CadenceType.LONG ? LONG_CADENCE_PMRF_KW
                    : SHORT_CADENCE_PMRF_KW;
                break;
            case BKG:
                headerField = BACKGROUND_PMRF_KW;
                break;
            case COL:
                headerField = cadenceType == CadenceType.LONG ? LONG_CADENCE_COLLATERAL_PMRF_KW
                    : SHORT_CADENCE_COLLATERAL_PMRF_KW;
                break;
        }

        return headerField;
    }

    private Header getFitsFileHeader(File file, Fits fitsFile, int cadence)
        throws FitsException, IOException {

        Header header = getFitsFileHeader(fitsFile);
        if (header.getIntValue(cadenceType == CadenceType.LONG ? LC_INTER_KW
            : SC_INTER_KW) != cadence) {
            throw new IllegalStateException(String.format(
                "Expected cadence %d within header in FITS file %s, not %d",
                cadence, file.getName(), header.getIntValue(LC_INTER_KW)));
        }

        return header;
    }

    private Header getFitsFileHeader(Fits fitsFile) throws FitsException,
        IOException {

        BasicHDU headerHdu = fitsFile.readHDU();
        Header header = headerHdu.getHeader();

        return header;
    }

    private BinaryTable extractModOutBinaryTable(File file, Fits fitsFile)
        throws FitsException, IOException {

        BinaryTable table = findModuleOutputTable(fitsFile, file.getName());
        log.debug("Successfully read " + file);

        return table;
    }

    private BinaryTable findModuleOutputTable(Fits fitsFile, String filename)
        throws FitsException, IOException {

        BasicHDU headerHdu;
        int fitsModule = 0;
        int fitsOutput = 0;
        do {
            headerHdu = fitsFile.readHDU();
            if (headerHdu == null) {
                throw new IllegalStateException(String.format(
                    "Did not find header in FITS file %s", filename));
            }
            Header header = headerHdu.getHeader();
            fitsModule = header.getIntValue(MODULE_KW);
            fitsOutput = header.getIntValue(OUTPUT_KW);
        } while (fitsModule != ccdModule || fitsOutput != ccdOutput);

        if (fitsModule != ccdModule) {
            throw new IllegalStateException(String.format(
                "Did not find CCD module %d within header in FITS file %s",
                ccdModule, filename));
        }
        if (fitsOutput != ccdOutput) {
            throw new IllegalStateException(String.format(
                "Did not find CCD output %d within header in FITS file %s",
                ccdOutput, filename));
        }

        Data data = headerHdu.getData();
        if (!(data instanceof BinaryTable)) {
            throw new IllegalStateException(String.format(
                "Expected BinaryTable data section in FITS file %s, not %s",
                filename, data.getClass()
                    .getSimpleName()));
        }
        BinaryTable table = (BinaryTable) data;

        return table;
    }

    private PmrfMappings pmrfMappings(String pmrfFilename,
        FitsPixelType pixelType) throws FitsException, IOException {

        PmrfMappings pmrfMappings = pmrfCache.get(pixelType);
        if (pmrfMappings == null) {
            File file = new File(pmrfDirectory, pmrfFilename);
            Fits fitsFile = new Fits(file);

            try {
                BinaryTable pmrfTable = extractModOutBinaryTable(file, fitsFile);
                switch (pixelType) {
                    case COL:
                        PmrfCollateralMappings collateralMappings = new PmrfCollateralMappings();
                        collateralMappings.types = (byte[]) pmrfTable.getFlattenedColumn(CollateralPmrfFormat.TYPE.getColumn());
                        collateralMappings.offsets = (short[]) pmrfTable.getFlattenedColumn(CollateralPmrfFormat.OFFSET.getColumn());
                        if (cadenceType == CadenceType.SHORT) {
                            collateralMappings.targetIds = (int[]) pmrfTable.getFlattenedColumn(CollateralPmrfFormat.TARGET_ID.getColumn());
                        } else {
                            collateralMappings.targetIds = new int[collateralMappings.types.length];
                        }
                        pmrfMappings = collateralMappings;
                        break;
                    default:
                        PmrfPixelMappings pixelMappings = new PmrfPixelMappings();
                        pixelMappings.rows = (short[]) pmrfTable.getFlattenedColumn(PixelPmrfFormat.ROW.getColumn());
                        pixelMappings.columns = (short[]) pmrfTable.getFlattenedColumn(PixelPmrfFormat.COLUMN.getColumn());
                        pmrfMappings = pixelMappings;
                        break;
                }
                pmrfCache.put(pixelType, pmrfMappings);
            } finally {
                fitsFile.getStream()
                    .close();
            }
        }

        return pmrfMappings;
    }

    private void extractPixelValues(PmrfPixelMappings pmrfMappings,
        BinaryTable pixelTable,
        Map<Pair<Integer, Integer>, List<Number>> pixelValuesByRowColumn)
        throws FitsException {

        if (pmrfMappings.getNRows() != pixelTable.getNRows()) {
            throw new IllegalStateException(String.format(
                "PMRF table has %d rows and pixel table has %d rows",
                pmrfMappings.getNRows(), pixelTable.getNRows()));
        }

        int[] originalValues = (int[]) pixelTable.getFlattenedColumn(PixelFileFormat.ORIGINAL_VALUE.getColumn());
        float[] calibratedValues;
        float[] calibratedUncertainties;
        if (pixelTable.getNCols() == 1) {
            // Original FITS file does not have calibrated values or
            // uncertainties.
            calibratedValues = new float[originalValues.length];
            Arrays.fill(calibratedValues, ValidationUtils.FITS_FILL_VALUE);
            calibratedUncertainties = new float[originalValues.length];
            Arrays.fill(calibratedUncertainties,
                ValidationUtils.FITS_FILL_VALUE);
        } else {
            calibratedValues = (float[]) pixelTable.getFlattenedColumn(PixelFileFormat.CALIBRATED_VALUE.getColumn());
            calibratedUncertainties = (float[]) pixelTable.getFlattenedColumn(PixelFileFormat.CALIBRATED_UNCERTAINTY.getColumn());
        }

        for (int i = 0; i < pmrfMappings.rows.length; i++) {
            pixelValuesByRowColumn.put(Pair.of(
                Integer.valueOf(pmrfMappings.rows[i]),
                Integer.valueOf(pmrfMappings.columns[i])),
                Arrays.asList(new Number[] { originalValues[i],
                    calibratedValues[i], calibratedUncertainties[i] }));
        }
    }

    private boolean extractCollateralPixelValues(
        PmrfCollateralMappings collateralMappings,
        BinaryTable pixelTable,
        Map<Pair<CollateralType, Integer>, List<Number>> pixelValuesByCollateralTypeOffset)
        throws FitsException {

        if (collateralMappings.getNRows() != pixelTable.getNRows()) {
            throw new IllegalStateException(String.format(
                "PMRF table has %d rows and pixel table has %d rows",
                collateralMappings.getNRows(), pixelTable.getNRows()));
        }

        boolean success = true;
        int[] originalValues = (int[]) pixelTable.getFlattenedColumn(PixelFileFormat.ORIGINAL_VALUE.getColumn());
        float[] calibratedValues;
        float[] calibratedUncertainties;
        if (pixelTable.getNCols() == 1) {
            // Original FITS file does not have calibrated values or
            // uncertainties. The calibrated values in short cadence files are
            // written to the orig_value column.
            calibratedValues = new float[originalValues.length];
            Arrays.fill(calibratedValues, ValidationUtils.FITS_FILL_VALUE);
            calibratedUncertainties = new float[originalValues.length];
            Arrays.fill(calibratedUncertainties,
                ValidationUtils.FITS_FILL_VALUE);
        } else {
            calibratedValues = (float[]) pixelTable.getFlattenedColumn(PixelFileFormat.CALIBRATED_VALUE.getColumn());
            calibratedUncertainties = (float[]) pixelTable.getFlattenedColumn(PixelFileFormat.CALIBRATED_UNCERTAINTY.getColumn());
        }

        // TODO Short cadence PMRF files have a third column for target.
        // This would have to be added to the key to avoid duplicate keys.
        // However, long cadence does not have this column, so a long cadence
        // key would have to be synthesized. (say, 0).
        for (int i = 0; i < collateralMappings.types.length; i++) {
            CollateralType collateralType = CollateralType.valueOf(collateralMappings.types[i]);
            Pair<CollateralType, Integer> key = Pair.of(collateralType,
                Integer.valueOf(collateralMappings.offsets[i]));
            if (collateralType == CollateralType.BLACK_MASKED
                || collateralType == CollateralType.BLACK_VIRTUAL) {
                List<Number> values = pixelValuesByCollateralTypeOffset.get(key);
                if (values != null
                    && collateralMappings.targetIds[i] == values.get(TARGET_ID)
                        .intValue()) {
                    if (!intValuesEqual(key.left, values.get(ORIGINAL_VALUE)
                        .intValue(), originalValues[i])
                        || !floatValuesEqual(key.left, values.get(
                            CALIBRATED_VALUE)
                            .floatValue(), calibratedValues[i])
                        || !floatValuesEqual(key.left, values.get(
                            CALIBRATED_UNCERTAINTY)
                            .floatValue(), calibratedUncertainties[i])) {
                        success = false;
                    }
                }
            }
            pixelValuesByCollateralTypeOffset.put(key,
                Arrays.asList(new Number[] { originalValues[i],
                    calibratedValues[i], calibratedUncertainties[i],
                    collateralMappings.targetIds[i] }));
        }

        return success;
    }

    private boolean intValuesEqual(CollateralType type, int previousValue,
        int currentValue) {
        if (currentValue != previousValue) {
            log.error(String.format(
                "FITS %s value %d differs from previous value of %d", type,
                currentValue, previousValue));
            return false;
        }

        return true;
    }

    private boolean floatValuesEqual(CollateralType type, float previousValue,
        float currentValue) {
        if (currentValue != previousValue) {
            log.error(String.format(
                "FITS %s value %d differs from previous value of %d", type,
                currentValue, previousValue));
            return false;
        }

        return true;
    }

    public void extractCosmicRays(
        int cadence,
        Map<Pair<Integer, Integer>, Float> targetCosmicRayByRowColumn,
        Map<Pair<Integer, Integer>, Float> backgroundCosmicRayByRowColumn,
        Map<Pair<CollateralType, Integer>, Float> cosmicRayByCollateralTypeOffset)
        throws FitsException, IOException {

        if (targetCosmicRayByRowColumn == null) {
            throw new NullPointerException(
                "targetCosmicRayByRowColumn can't be null");
        }
        if (backgroundCosmicRayByRowColumn == null) {
            throw new NullPointerException(
                "backgroundCosmicRayByRowColumn can't be null");
        }
        if (cosmicRayByCollateralTypeOffset == null) {
            throw new NullPointerException(
                "cosmicRayByCollateralTypeOffset can't be null");
        }

        if (cadenceTimes.gapIndicators[cadence - startCadence]) {
            return;
        }

        File file = getFitsFile(cadence, FitsCosmicRayType.CRCT.toString());
        Fits fitsFile = new Fits(file);
        try {
            BinaryTable cosmicRayTable = extractCosmicRayTable(file, fitsFile,
                cadence);
            extractCosmicRays(cosmicRayTable, targetCosmicRayByRowColumn,
                backgroundCosmicRayByRowColumn);
        } finally {
            fitsFile.getStream()
                .close();
        }

        file = getFitsFile(cadence, FitsCosmicRayType.CRCC.toString());
        fitsFile = new Fits(file);
        try {
            BinaryTable cosmicRayTable = extractCosmicRayTable(file, fitsFile,
                cadence);
            extractCollateralCosmicRays(cosmicRayTable,
                cosmicRayByCollateralTypeOffset);
        } finally {
            fitsFile.getStream()
                .close();
        }
    }

    private BinaryTable extractCosmicRayTable(File file, Fits fitsFile,
        int cadence) throws FitsException, IOException {

        BasicHDU headerHdu = fitsFile.readHDU();
        Header header = headerHdu.getHeader();
        if (!header.getStringValue(DATATYPE_KW)
            .equals(
                cadenceType == CadenceType.LONG ? "long cadence"
                    : "short cadence")) {
            throw new IllegalStateException(
                String.format(
                    "Expected cadence type %s within header in FITS file %s, not %s",
                    cadenceType.toString(), file.getName(),
                    header.getStringValue(DATATYPE_KW)));
        }
        if (header.getIntValue(CADENNUM_KW) != cadence) {
            throw new IllegalStateException(String.format(
                "Expected cadence %d within header in FITS file %s, not %d",
                cadence, file.getName(), header.getIntValue(CADENNUM_KW)));
        }

        BinaryTable table = findModuleOutputTable(fitsFile, file.getName());

        log.debug("Successfully read " + file);

        return table;
    }

    private void extractCosmicRays(BinaryTable cosmicRayTable,
        Map<Pair<Integer, Integer>, Float> targetCosmicRayByRowColumn,
        Map<Pair<Integer, Integer>, Float> backgroundCosmicRayByRowColumn)
        throws FitsException {

        short[] rows = (short[]) cosmicRayTable.getFlattenedColumn(CosmicRayFileFormat.ROW.getColumn());
        short[] columns = (short[]) cosmicRayTable.getFlattenedColumn(CosmicRayFileFormat.COLUMN.getColumn());
        float[] correctionValues = (float[]) cosmicRayTable.getFlattenedColumn(CosmicRayFileFormat.CORRECTION_VALUE.getColumn());
        int[] targetIds = (int[]) cosmicRayTable.getFlattenedColumn(CosmicRayFileFormat.TARGET_ID.getColumn());

        for (int i = 0; i < rows.length; i++) {
            // If the target_id is less than zero (for example, -1) it is
            // assumed to be background.
            if (targetIds[i] < 0) {
                backgroundCosmicRayByRowColumn.put(Pair.of(
                    Integer.valueOf(rows[i]), Integer.valueOf(columns[i])),
                    correctionValues[i]);
            } else {
                targetCosmicRayByRowColumn.put(Pair.of(
                    Integer.valueOf(rows[i]), Integer.valueOf(columns[i])),
                    correctionValues[i]);
            }
        }
    }

    private void extractCollateralCosmicRays(
        BinaryTable cosmicRayTable,
        Map<Pair<CollateralType, Integer>, Float> cosmicRayByCollateralTypeOffset)
        throws FitsException {

        byte[] types = (byte[]) cosmicRayTable.getFlattenedColumn(CollateralCosmicRayFileFormat.TYPE.getColumn());
        short[] offsets = (short[]) cosmicRayTable.getFlattenedColumn(CollateralCosmicRayFileFormat.OFFSET.getColumn());
        float[] correctionValues = (float[]) cosmicRayTable.getFlattenedColumn(CollateralCosmicRayFileFormat.CORRECTION_VALUE.getColumn());

        for (int i = 0; i < types.length; i++) {
            cosmicRayByCollateralTypeOffset.put(Pair.of(
                CollateralType.valueOf(types[i]), Integer.valueOf(offsets[i])),
                correctionValues[i]);
        }
    }

    private static interface PmrfMappings {
        int getNRows();
    }

    private static class PmrfPixelMappings implements PmrfMappings {
        private short[] rows;
        private short[] columns;

        @Override
        public int getNRows() {
            return rows.length;
        }
    }

    private static class PmrfCollateralMappings implements PmrfMappings {
        private byte[] types;
        private short[] offsets;
        private int[] targetIds;

        @Override
        public int getNRows() {
            return types.length;
        }
    }

    private static class IntegerStringPairComparator implements
        Comparator<Pair<Integer, String>> {

        @Override
        public int compare(Pair<Integer, String> o1, Pair<Integer, String> o2) {

            if (o1.left.compareTo(o2.left) == 0) {
                return o1.right.compareTo(o2.right);
            }

            return o1.left.compareTo(o2.left);
        }
    }

    private static class IntegerFitsPixelTypePairComparator implements
        Comparator<Pair<Integer, FitsPixelType>> {

        @Override
        public int compare(Pair<Integer, FitsPixelType> o1,
            Pair<Integer, FitsPixelType> o2) {

            if (o1.left.compareTo(o2.left) == 0) {
                return o1.right.compareTo(o2.right);
            }

            return o1.left.compareTo(o2.left);
        }
    }
}
