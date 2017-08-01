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

package gov.nasa.kepler.mc.fs;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.FfiType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.FileLog;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.lang.StringUtils;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class creates FsId objects for items stored in the File Store by Data
 * Receipt
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class DrFsIdFactory extends PixelFsIdFactory {
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(DrFsIdFactory.class);

    public static final String DR_PATH = "/dr";

    private static final String PIXEL_PATH = DR_PATH + "/pixel";
    private static final String SCIENCE_PIXEL_PATH = PIXEL_PATH + "/sci/";
    private static final String COLLATERAL_PIXEL_PATH = PIXEL_PATH + "/col/";
    private static final String PIXEL_FITS_PATH = PIXEL_PATH + "/fits/";

    public static final String LONG_CADENCE_TARGET_PMRF = DispatchLog.LONG_CADENCE_TARGET_PMRF;
    public static final String SHORT_CADENCE_TARGET_PMRF = DispatchLog.SHORT_CADENCE_TARGET_PMRF;
    public static final String BACKGROUND_PMRF = DispatchLog.BACKGROUND_PMRF;
    public static final String LONG_CADENCE_COLLATERAL_PMRF = DispatchLog.LONG_CADENCE_COLLATERAL_PMRF;
    public static final String SHORT_CADENCE_COLLATERAL_PMRF = DispatchLog.SHORT_CADENCE_COLLATERAL_PMRF;

    public enum TimeSeriesType {
        ORIG, DMC_CAL, REF_PIXEL;

        private String name;

        public static TimeSeriesType valueOfName(String name) {

            for (TimeSeriesType type : values()) {
                if (type.getName()
                    .equals(name)) {
                    return type;
                }
            }
            throw new IllegalArgumentException(name
                + ": unknown collateral type.");
        }

        private TimeSeriesType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }
    }

    private static final Pattern COLLATERAL_PATTERN;

    static {
        StringBuilder regex = new StringBuilder(COLLATERAL_PIXEL_PATH);

        // group 1 - TimeSeriesType
        regex.append("(");
        for (TimeSeriesType type : TimeSeriesType.values()) {
            regex.append(type.getName());
            regex.append('|');
        }
        regex.setLength(regex.length() - 1);
        regex.append(")");

        // group 2 - CadenceType
        regex.append("/(");
        for (CadenceType type : CadenceType.values()) {
            regex.append(type.getName());
            regex.append('|');
        }
        regex.setLength(regex.length() - 1);
        regex.append(")");

        // group 3 - CollateralType
        regex.append("/(");
        for (CollateralType type : CollateralType.values()) {
            regex.append(type.getName());
            regex.append('|');
        }
        regex.setLength(regex.length() - 1);
        regex.append(")");
        regex.append(PixelFsIdFactory.SEP);

        // Group 4 - module, Group 5 - output, Group 6 - row or column
        regex.append("(\\d+)")
            .append(PixelFsIdFactory.SEP)
            .append("(\\d+)")
            .append(PixelFsIdFactory.SEP)
            .append("(\\d+)");

        COLLATERAL_PATTERN = Pattern.compile(regex.toString());
    }

    /**
     * private to prevent instantiation
     * 
     */
    private DrFsIdFactory() {
    }

    /**
     * Get a single pixel time series
     * 
     * @param timeSeriesType
     * @param targetTableType
     * @param ccdModule
     * @param ccdOutput
     * @param row
     * @param column
     * @return
     * @throws PipelineException
     * @throws PipelineException
     */
    public static FsId getSciencePixelTimeSeries(TimeSeriesType timeSeriesType,
        TargetType targetTableType, int ccdModule, int ccdOutput, int row,
        int column) {

        return getPixelFsId(SCIENCE_PIXEL_PATH + timeSeriesType.getName(),
            targetTableType, ccdModule, ccdOutput, row, column);
    }

    /**
     * Get all pixel time series for the specified Target
     * 
     * @param timeSeriesType
     * @param target
     * @return
     * @throws PipelineException
     * @throws PipelineException
     */
    public static List<FsId> getSciencePixelTimeSeries(
        TimeSeriesType timeSeriesType, ObservedTarget target) {
        return getPixelFsIdsForTarget(
            SCIENCE_PIXEL_PATH + timeSeriesType.getName(), target);
    }

    /**
     * Get original (uncalibrated) collateral pixel time series
     * 
     * @param collateralType
     * @param ccdModule
     * @param ccdOutput
     * @param rowOrColumn
     * @return
     * @throws PipelineException
     * @throws PipelineException
     */
    public static FsId getCollateralPixelTimeSeries(
        TimeSeriesType timeSeriesType, CadenceType cadenceType,
        CollateralType collateralType, int ccdModule, int ccdOutput,
        int rowOrColumn) {

        String path = COLLATERAL_PIXEL_PATH + timeSeriesType.getName() + "/"
            + cadenceType.getName();
        return getCollateralPixelFsId(path, collateralType, ccdModule,
            ccdOutput, rowOrColumn);
    }

    /**
     * Get Stripped FITS These are the cadence data set FITS files as received
     * from the DMC with all binary tables removed, leaving only the primary HDU
     * header. These FITS files are not used by the pipeline, but they are
     * archived in the file store for possible use by SOC personnel.
     * 
     * @param pmrfName
     * @return
     * @throws PipelineException
     */
    public static FsId getPixelFitsHeaderFile(String fitsName) {
        return new FsId(PIXEL_FITS_PATH, fitsName);
    }

    public static FsId getPmrfFile(String filename) {
        DispatcherType type = null;

        if (filename.contains(LONG_CADENCE_TARGET_PMRF)) {
            type = DispatcherType.LONG_CADENCE_TARGET_PMRF;
        } else if (filename.contains(SHORT_CADENCE_TARGET_PMRF)) {
            type = DispatcherType.SHORT_CADENCE_TARGET_PMRF;
        } else if (filename.contains(BACKGROUND_PMRF)) {
            type = DispatcherType.BACKGROUND_PMRF;
        } else if (filename.contains(LONG_CADENCE_COLLATERAL_PMRF)) {
            type = DispatcherType.LONG_CADENCE_COLLATERAL_PMRF;
        } else if (filename.contains(SHORT_CADENCE_COLLATERAL_PMRF)) {
            type = DispatcherType.SHORT_CADENCE_COLLATERAL_PMRF;
        } else {
            throw new IllegalArgumentException("File with name \"" + filename
                + "\" does not match any dispatcher type.");
        }

        return getFile(type, filename);
    }

    /**
     * Get a generic blob file from the filestore.
     * 
     * @param dispatcherType the type of file to retrieve.
     * @param filename the filename from the {@link FileLog}.
     * @return
     */
    public static FsId getFile(DispatcherType dispatcherType, String filename) {
        return new FsId(DR_PATH + "/" + dispatcherType.getName() + "/",
            filename);
    }

    /**
     * Gets the {@link FsId} for one of the single-channel FFI files.
     * 
     * @param timestamp is the timestamp from the FFI file name itself.
     * @param ffiType is one of the {@link FfiType}s.
     * @param ccdModule
     * @param ccdOutput
     * @return the {@link FsId}
     */
    public static FsId getSingleChannelFfiFile(String timestamp,
        FfiType ffiType, int ccdModule, int ccdOutput) {

        if (ffiType != FfiType.ORIG) {
            throw new IllegalStateException("Can't make id for ffi type "
                + ffiType);
        }

        return new FsId(DR_PATH + "/" + DispatcherType.FFI.getName() + "/",
            timestamp + ":" + ffiType.getName() + ":" + ccdModule + ":"
                + ccdOutput);
    }

    /**
     * Break an FsId generated by getSingleChannelFfiFile into its component
     * parts.
     * 
     * @param ffiId
     * @return A map with component parts or a runtime exception. The parts have
     * correct types of String, FfiType, Integer, and Integer for keys
     * FILE_TIMESTAMP, FFI_TYPE, CCD_MODULE, CCD_OUTPUT. These constants are
     * defined in PixelFsIdFactory.
     */
    public static Map<String, Object> parseSingleChannelFfi(FsId ffiId) {
        Map<String, Object> rv = new HashMap<String, Object>();
        String ffiIdStr = ffiId.name();
        String[] nameParts = ffiIdStr.split(":");
        rv.put(FILE_TIMESTAMP, nameParts[0]);
        rv.put(FFI_TYPE, FfiType.valueOfName(nameParts[1]));
        rv.put(CCD_MODULE, Integer.parseInt(nameParts[2]));
        rv.put(CCD_OUTPUT, Integer.parseInt(nameParts[3]));
        return rv;
    }

    public static Map<String, Object> parseCollateralPixelTimeSeries(
        FsId collateralPixelFsId) {

        Matcher matcher = COLLATERAL_PATTERN.matcher(collateralPixelFsId.toString());
        if (!matcher.matches()) {
            throw new PipelineException(collateralPixelFsId
                + ": invalid DR collateral pixel FsId.");
        }

        TimeSeriesType timeSeriesType = TimeSeriesType.valueOfName(matcher.group(1));
        CadenceType cadenceType = CadenceType.valueOfName(matcher.group(2));
        CollateralType collateralType = CollateralType.valueOfName(matcher.group(3));
        int module = Integer.parseInt(matcher.group(4));
        int output = Integer.parseInt(matcher.group(5));
        int rowOrColumn = Integer.parseInt(matcher.group(6));

        validateCollateralPixelParameters(collateralType, module, output,
            rowOrColumn);

        Map<String, Object> rv = new HashMap<String, Object>();
        rv.put(TIME_SERIES_TYPE, timeSeriesType);
        rv.put(CADENCE_TYPE, cadenceType);
        rv.put(COLLATERAL_TYPE, collateralType);
        rv.put(CCD_MODULE, module);
        rv.put(CCD_OUTPUT, output);
        rv.put(ROW_OR_COLUMN, rowOrColumn);

        return rv;
    }

    public static boolean isCollateralPixelTimeSeries(FsId fsId) {
        Matcher matcher = COLLATERAL_PATTERN.matcher(fsId.toString());
        return matcher.matches();
    }

    public static FsId getRclcPixelBlobFsId(DataSetType dataSetType,
        int ccdModule, int ccdOutput) {
        StringBuilder fullPath = new StringBuilder();
        fullPath.append(DrFsIdFactory.DR_PATH)
            .append('/')
            .append("rclcPixelBlob")
            .append('/')
            .append(dataSetType)
            .append(PixelFsIdFactory.SEP)
            .append(ccdModule)
            .append(PixelFsIdFactory.SEP)
            .append(ccdOutput);

        return new FsId(fullPath.toString());
    }

    public static FsId getRclcPixelBlobFsId(DataSetType dataSetType,
        int ccdModule, int ccdOutput, int startCadence, int length) {
        StringBuilder fullPath = new StringBuilder();
        fullPath.append(DrFsIdFactory.DR_PATH)
            .append('/')
            .append("rclcPixelBlob")
            .append('/')
            .append(dataSetType)
            .append(PixelFsIdFactory.SEP)
            .append(ccdModule)
            .append(PixelFsIdFactory.SEP)
            .append(ccdOutput)
            .append(PixelFsIdFactory.SEP)
            .append(startCadence)
            .append(PixelFsIdFactory.SEP)
            .append(length);

        return new FsId(fullPath.toString());
    }

    public static FsId getUkirtImageBlobFsId(int keplerId,
        String fileExtension, long createTime) {

        String type = fileExtension;
        if (type.indexOf('.') == 0) {
            type = type.substring(1);
        }
        StringBuilder path = new StringBuilder().append(DR_PATH)
            .append("/UkirtImages/")
            .append(type)
            .append('/')
            .append(createTime)
            .append('/')
            .append(keplerId);

        return new FsId(path.toString());
    }

}
