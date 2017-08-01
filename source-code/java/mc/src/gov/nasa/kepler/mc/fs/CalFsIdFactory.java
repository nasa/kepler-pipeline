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

import gov.nasa.kepler.common.*;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.lang.StringUtils;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * FSID factory for CAL.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 * @author Todd Klaus tklaus@arc.nasa.gov
 * @author Sean McCauliff
 */
public class CalFsIdFactory extends PixelFsIdFactory {

    public static final String CAL_PATH = "/cal/";
    public static final String CAL_PIXEL_PATH = "/cal/pixels/";
    private static final String CAL_METRICS_PATH = "/cal/metrics/";
    public static final String CAL_UNCERTAINTY_BLOB_PATH = "/cal/uncert/";
    public static final String CAL_ONE_D_BLACK_BLOB_PATH = "/cal/1dblack/";
    public static final String CAL_SMEAR_BLOB_PATH = "/cal/smear/";
    static final String CAL_CRS_PATH = "/cal/crs/";
    public static final String CAL_FFI_PATH = "/cal/ffi/";

    public enum PixelTimeSeriesType {
        SOC_CAL, SOC_CAL_UNCERTAINTIES;

        private final String name;

        private PixelTimeSeriesType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }
    }
    
   

    public enum TargetMetricsTimeSeriesType {
        TWOD_BLACK,
        TWOD_BLACK_UNCERTAINTIES,
        UNDERSHOOT,
        UNDERSHOOT_UNCERTAINTIES;

        private final String name;

        private TargetMetricsTimeSeriesType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }
    }

    public enum MetricsTimeSeriesType {
        BLACK_LEVEL_UNCERTAINTIES,
        BLACK_LEVEL(BLACK_LEVEL_UNCERTAINTIES),
        DARK_CURRENT_UNCERTAINTIES,
        DARK_CURRENT(DARK_CURRENT_UNCERTAINTIES),
        SMEAR_LEVEL_UNCERTAINTIES,
        SMEAR_LEVEL(SMEAR_LEVEL_UNCERTAINTIES),
        THEORETICAL_COMPRESSION_EFFICIENCY,
        THEORETICAL_COMPRESSION_EFFICIENCY_COUNTS,
        ACHIEVED_COMPRESSION_EFFICIENCY,
        ACHIEVED_COMPRESSION_EFFICIENCY_COUNTS;

        private final String name;
        private final MetricsTimeSeriesType uncertaintiesType;

        private MetricsTimeSeriesType() {
            this(null);
        }

        private MetricsTimeSeriesType(MetricsTimeSeriesType uncertaintiesType) {
            this.name = StringUtils.constantToCamel(super.toString())
                .intern();
            this.uncertaintiesType = uncertaintiesType;
        }

        public String getName() {
            return name;
        }

        public MetricsTimeSeriesType uncertaintiesType() {
            return uncertaintiesType;
        }
    }

    public enum CosmicRayMetricType {
        HIT_RATES,
        MEAN_ENERGY,
        ENERGY_VARIANCE,
        ENERGY_SKEWNESS,
        ENERGY_KURTOSIS;

        private final String name;

        CosmicRayMetricType() {
            this.name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }

    }

    private static final Pattern COSMIC_RAY_PATTERN;

    static {
        StringBuilder regex = new StringBuilder(CAL_CRS_PATH);

        // group 1 - CollateralType
        regex.append("(");
        for (CollateralType cType : CollateralType.values()) {
            regex.append(cType.getName());
            regex.append('|');
        }
        regex.setLength(regex.length() - 1);
        regex.append(")");

        // group 2 - CadenceType
        regex.append("/(");
        for (CadenceType cadenceType : CadenceType.values()) {
            regex.append(cadenceType.name());
            regex.append('|');
        }
        regex.setLength(regex.length() - 1);
        regex.append(")");
        regex.append(PixelFsIdFactory.SEP);

        // Group 3 - module, Group 4 output, Group 5 offset
        regex.append("(\\d+)")
            .append(PixelFsIdFactory.SEP)
            .append("(\\d+)")
            .append(SEP)
            .append("(\\d+)");

        // System.out.println("regex = " + regex);

        COSMIC_RAY_PATTERN = Pattern.compile(regex.toString());
    }

    /**
     * No instances allowed.
     */
    private CalFsIdFactory() {
    }

    public static boolean isCollateralTimeSeriesFsId(FsId id) {
        return id.path()
            .indexOf("collateral") != -1;
    }

    /**
     * Generates the time series FSID for the given {@link TargetType} and
     * {@link PixelTimeSeriesType}.
     */
    public static FsId getTimeSeriesFsId(PixelTimeSeriesType timeSeriesType,
        TargetType targetTableType, int ccdModule, int ccdOutput, int row,
        int column) {

        return getPixelFsId(CAL_PIXEL_PATH + timeSeriesType.getName(),
            targetTableType, ccdModule, ccdOutput, row, column);
    }

    public static FsId getMetricsTimeSeriesFsId(CadenceType cadenceType,
        MetricsTimeSeriesType metricsType, int ccdModule, int ccdOutput) {

        return new FsId(CAL_METRICS_PATH + cadenceType.getName() + SEP
            + metricsType.getName() + SEP + ccdModule + SEP + ccdOutput);

    }

    /**
     * Generates the target time series for the given TimeSeriesType.
     */
    public static FsId getTargetMetricsTimeSeriesFsId(CadenceType cadenceType,
        TargetMetricsTimeSeriesType timeSeriesType, int ccdModule,
        int ccdOutput, int keplerId) {

        return new FsId(CAL_METRICS_PATH + timeSeriesType.getName(), ccdModule
            + PixelFsIdFactory.SEP + ccdOutput + PixelFsIdFactory.SEP
            + keplerId);
    }

    /**
     * Generates the cosmic ray series FSID for the given
     * {@link CosmicRaySeriesType}.
     * 
     * @param cosmicRaySeriesType
     * @param ccdModule
     * @param ccdOutput
     * @param rowOrColumn
     * @return
     * @throws PipelineException
     */
    public static FsId getCosmicRaySeriesFsId(CollateralType collateralType,
        CadenceType cadenceType, int ccdModule, int ccdOutput, int rowOrColumn) {

        validateCollateralPixelParameters(collateralType, ccdModule, ccdOutput,
            rowOrColumn);
        return new FsId(CAL_CRS_PATH + collateralType.getName(),
            cadenceType.name() + PixelFsIdFactory.SEP + ccdModule
                + PixelFsIdFactory.SEP + ccdOutput + PixelFsIdFactory.SEP
                + rowOrColumn);
    }

    public static Map<String, Object> parseCosmicRaySeriesFsId(
        FsId cosmicRaySeriesId) {

        Matcher matcher = COSMIC_RAY_PATTERN.matcher(cosmicRaySeriesId.toString());
        if (!matcher.matches()) {
            throw new PipelineException("Invalid CAL cosmic ray FsId \""
                + cosmicRaySeriesId + "\".");
        }

        CollateralType collateralType = CollateralType.valueOfName(matcher.group(1));
        CadenceType cadenceType = CadenceType.valueOf(matcher.group(2));
        int module = Integer.parseInt(matcher.group(3));
        int output = Integer.parseInt(matcher.group(4));
        int offset = Integer.parseInt(matcher.group(5));

        validateCollateralPixelParameters(collateralType, module, output,
            offset);

        Map<String, Object> rv = new HashMap<String, Object>();
        rv.put(CADENCE_TYPE, cadenceType);
        rv.put(COLLATERAL_TYPE, collateralType);
        rv.put(CCD_MODULE, module);
        rv.put(CCD_OUTPUT, output);
        rv.put(OFFSET, offset);

        return rv;
    }

    public static boolean isCosmicRaySeriesFsId(FsId id) {
        Matcher matcher = COSMIC_RAY_PATTERN.matcher(id.toString());
        return matcher.matches();
    }

    public static FsId getCosmicRayMetricFsId(CadenceType cadenceType,
        CollateralType collateralType, CosmicRayMetricType metricType,
        int ccdModule, int ccdOutput) {

        StringBuilder bldr = new StringBuilder();
        bldr.append(CAL_METRICS_PATH)
            .append("CosmicRayMetrics/")
            .append(cadenceType.getName())
            .append(SEP)
            .append(ccdModule)
            .append(SEP)
            .append(ccdOutput)
            .append(SEP)
            .append(collateralType.getName())
            .append(SEP)
            .append(metricType.getName());
        return new FsId(bldr.toString());
    }

    public static FsId getUncertaintyTransformBlobFsId(CadenceType cadenceType,
        int ccdModule, int ccdOutput, long taskId) {

        return new FsId(CAL_UNCERTAINTY_BLOB_PATH + "UncertaintyXform/"
            + cadenceType.getName() + SEP + ccdModule + SEP + ccdOutput + SEP
            + taskId);
    }
    
    public static FsId getOneDBlackFitBlobFsId(CadenceType cadenceType, int ccdModule, int ccdOutput, long taskId) {
        return new FsId(CAL_ONE_D_BLACK_BLOB_PATH + "1DBlackFitBlob" + SEP
                        + cadenceType.getName() + SEP + ccdModule + SEP + ccdOutput + SEP
                        + taskId);
    }
    
    public static FsId getSmearBlobFsId(CadenceType cadenceType, int ccdModule, int ccdOutput, long taskId) {
        return new FsId(CAL_SMEAR_BLOB_PATH + "SmearBlob" + SEP
            + cadenceType.getName() + SEP + ccdModule + SEP + ccdOutput + SEP 
            + taskId);
    }

    public static FsId getCalibratedCollateralFsId(
        CollateralType collateralType, PixelTimeSeriesType pixelTimeSeriesType,
        CadenceType cadenceType, int ccdModule, int ccdOutput, int rowOrColumn) {

        StringBuilder bldr = new StringBuilder();
        bldr.append(CAL_PIXEL_PATH)
            .append(pixelTimeSeriesType.getName())
            .append('/')
            .append("collateral")
            .append('/')
            .append(cadenceType.getName())
            .append('/')
            .append(ccdModule)
            .append('/')
            .append(ccdOutput)
            .append('/')
            .append(collateralType.name())
            .append(SEP)
            .append(rowOrColumn);
        return new FsId(bldr.toString());
    }
    
    /**
     * Returns a {@code Set} containing all the mnemonics supported by this
     * {@code FsId} factory.
     */
    public static Set<String> getAncillaryPipelineDataMnemonics() {
        
        Set<String> mnemonics = new HashSet<String>();
        for (MetricsTimeSeriesType metricType : MetricsTimeSeriesType.values()) {
            if (!metricType.toString().endsWith("_UNCERTAINTIES")) {
                mnemonics.add(metricType.toString());
            }
        }
        return mnemonics;
    }

    /**
     * Returns the {@code FsId} for the given {@code mnemonic}'s data values.
     * 
     * @param mnemonic a {@code String} whose value is a valid ancillary
     * pipeline data mnemonic for this factory.
     * @param cadenceType a {@code CadenceType}.
     * @param ccdModule a CCD module.
     * @param ccdOutput a CCD output.
     * @return the {@code FsId} for the corresponding ancillary pipeline data
     * values.
     * @see #getAncillaryPipelineDataMnemonics()
     */
    public static FsId getAncillaryPipelineDataFsId(String mnemonic,
        CadenceType cadenceType, int ccdModule, int ccdOutput) {

        for (MetricsTimeSeriesType metricType : MetricsTimeSeriesType.values()) {
            if (metricType.toString()
                .equals(mnemonic)) {
                return getMetricsTimeSeriesFsId(cadenceType, metricType,
                    ccdModule, ccdOutput);
            }
        }
        throw new IllegalArgumentException(String.format(
            "%s: invalid ancillary pipeline data mnemonic", mnemonic));
    }

    /**
     * Returns the {@code FsId} for the given {@code mnemonic}'s uncertainties values.
     * 
     * @param mnemonic a {@code String} whose value is a valid ancillary
     * pipeline data mnemonic for this factory.
     * @param cadenceType a {@code CadenceType}.
     * @param ccdModule a CCD module.
     * @param ccdOutput a CCD output.
     * @return the {@code FsId} for the corresponding ancillary pipeline data
     * uncertainties.
     * @see #getAncillaryPipelineDataMnemonics()
     */
    public static FsId getAncillaryPipelineDataUncertaintiesFsId(
        String mnemonic, CadenceType cadenceType, int ccdModule, int ccdOutput) {

        for (MetricsTimeSeriesType metricType : MetricsTimeSeriesType.values()) {
            if (metricType.toString()
                .equals(mnemonic)) {
                if (metricType.uncertaintiesType() != null) {
                    return getMetricsTimeSeriesFsId(cadenceType,
                        metricType.uncertaintiesType(), ccdModule, ccdOutput);
                }
                return null;
            }
        }
        throw new IllegalArgumentException(String.format(
            "%s: invalid ancillary pipeline data mnemonic", mnemonic));
    }
    
    /**
     * Generates FsIds for SOC calibrated FsIds
     * @param fileTimeStamp  This is the timestamp format used by the DMC.
     * @param ccdModule
     * @param ccdOutput
     * @return
     */
    public static FsId getSingleChannelFfiFile(String fileTimeStamp, 
            FfiType ffiType, int ccdModule, int ccdOutput) {
       
        if (ffiType == FfiType.DMC_CAL || ffiType == FfiType.ORIG) {
            throw new IllegalArgumentException("Can't make id for ffi type " + ffiType);
        }
        return new FsId(CAL_FFI_PATH, fileTimeStamp + 
            ":" + ffiType.getName() + ":" + ccdModule + ":" + ccdOutput);
    }

    /**
     * Creates an unofficial soc calibrated FFI file name.
     * @param fileTimeStamp
     * @param ffiType
     * @return
     */
    public static FsId getFfiFile(String fileTimeStamp, FfiType ffiType) {
        return new FsId(CAL_FFI_PATH, "kplr" + fileTimeStamp + "_" + 
            ffiType.getName() + "-ffi.fits");
    }
    

}
