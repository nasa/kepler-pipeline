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
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
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

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class creates FsId objects for items stored in the File Store by PA.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 * @author Todd Klaus tklaus@arc.nasa.gov
 */
public class PaFsIdFactory extends PixelFsIdFactory {

    public enum TimeSeriesType {
        RAW_FLUX,
        RAW_FLUX_UNCERTAINTIES,
        BACKGROUND_FLUX,
        BACKGROUND_FLUX_UNCERTAINTIES,
        SIGNAL_TO_NOISE_RATIO,
        FLUX_FRACTION_IN_APERTURE,
        CROWDING_METRIC,
        SKY_CROWDING_METRIC;

        private String name;

        private TimeSeriesType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }
    }

    public enum CentroidType {
        FLUX_WEIGHTED, PRF;

        private String name;

        private CentroidType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }
    }

    public enum CentroidTimeSeriesType {
        CENTROID_ROWS,
        CENTROID_ROWS_UNCERTAINTIES,
        CENTROID_COLS,
        CENTROID_COLS_UNCERTAINTIES;

        private String name;

        private CentroidTimeSeriesType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }
    }

    public enum CosmicRayMetricType {
        HIT_RATE,
        MEAN_ENERGY,
        ENERGY_VARIANCE,
        ENERGY_SKEWNESS,
        ENERGY_KURTOSIS;

        private String name;

        private CosmicRayMetricType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }
    }

    public enum MetricTimeSeriesType {
        ENCIRCLED_ENERGY_UNCERTAINTIES,
        ENCIRCLED_ENERGY(ENCIRCLED_ENERGY_UNCERTAINTIES),
        BRIGHTNESS_UNCERTAINTIES,
        BRIGHTNESS(BRIGHTNESS_UNCERTAINTIES);

        private final String name;
        private final MetricTimeSeriesType uncertaintiesType;

        private MetricTimeSeriesType() {
            this(null);
        }

        private MetricTimeSeriesType(MetricTimeSeriesType uncertaintiesType) {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
            this.uncertaintiesType = uncertaintiesType;
        }

        public String getName() {
            return name;
        }

        public MetricTimeSeriesType uncertaintiesType() {
            return uncertaintiesType;
        }
    }

    public enum BlobSeriesType {
        BACKGROUND, MOTION, UNCERTAINTIES, FFI_MOTION;

        private String name;

        private BlobSeriesType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }
    }

    public enum ThrusterActivityType {
        DEFINITE_THRUSTER_ACTIVITY, POSSIBLE_THRUSTER_ACTIVITY;

        private String name;

        private ThrusterActivityType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }
    }

    private static final Log log = LogFactory.getLog(PaFsIdFactory.class);

    public static final String PA_PATH = "/pa/";
    static final String PA_TARGETS_PATH = "/pa/targets/";
    static final String PA_CENTROIDS_PATH = "/pa/centroids/";
    static final String PA_CRS_PATH = "/pa/crs/";
    static final String PA_METRICS_PATH = "/pa/metrics/";
    static final String PA_CR_METRICS_PATH = "/pa/metrics/CosmicRay/";

    private static final Pattern cosmicRaySeriesPattern;

    static {
        String regex = PA_CRS_PATH;
        regex = getPixelFsIdRegex(regex, PixelFsIdFactory.SEP);
        log.debug("cosmic ray regex " + regex);
        cosmicRaySeriesPattern = Pattern.compile(regex);
    }

    /**
     * private to prevent instantiation
     * 
     */
    private PaFsIdFactory() {
    }

    public static FsId getRollingBandContaminationFsId(FluxType fluxType,
        int pulseDurationLc, int keplerId) {

        StringBuilder fullPath = new StringBuilder().append(PA_TARGETS_PATH)
            .append(fluxType)
            .append('/')
            .append("RollingBandContamination")
            .append('/')
            .append(pulseDurationLc)
            .append('/')
            .append(keplerId);
        return new FsId(fullPath.toString());
    }

    public static FsId getArgabrighteningFsId(CadenceType cadenceType,
        int targetTableId, int ccdModule, int ccdOutput) {

        StringBuilder fullPath = new StringBuilder().append(PA_TARGETS_PATH)
            .append("Argabrightening")
            .append('/')
            .append(cadenceType.getName())
            .append('/')
            .append(targetTableId)
            .append('/')
            .append(ccdModule)
            .append(PixelFsIdFactory.SEP)
            .append(ccdOutput);
        return new FsId(fullPath.toString());
    }

    public static FsId getZeroCrossingFsId(CadenceType cadenceType) {

        StringBuilder fullPath = new StringBuilder().append(PA_PATH)
            .append("ReactionWheelZeroCrossing")
            .append('/')
            .append(cadenceType.getName());
        return new FsId(fullPath.toString());
    }

    public static FsId getBarcentricTimeOffsetFsId(CadenceType cadenceType,
        int keplerId) {

        StringBuilder fullPath = new StringBuilder().append(PA_TARGETS_PATH)
            .append("BarycentricTimeOffset")
            .append('/')
            .append(cadenceType.getName())
            .append('/')
            .append(keplerId);
        return new FsId(fullPath.toString());
    }

    public static FsId getTimeSeriesFsId(TimeSeriesType timeSeriesType,
        FluxType fluxType, CadenceType cadenceType, int keplerId) {

        StringBuilder fullPath = new StringBuilder().append(PA_TARGETS_PATH)
            .append(fluxType.getName())
            .append(timeSeriesType.getName())
            .append('/')
            .append(cadenceType.getName())
            .append('/')
            .append(keplerId);
        return new FsId(fullPath.toString());
    }

    public static FsId getCentroidTimeSeriesFsId(
        CentroidTimeSeriesType timeSeriesType, CadenceType cadenceType,
        int keplerId) {

        StringBuilder fullPath = new StringBuilder().append(PA_CENTROIDS_PATH)
            .append(timeSeriesType.getName())
            .append('/')
            .append(cadenceType.getName())
            .append('/')
            .append(keplerId);
        return new FsId(fullPath.toString());
    }

    public static FsId getCentroidTimeSeriesFsId(FluxType fluxType,
        CentroidTimeSeriesType timeSeriesType, CadenceType cadenceType,
        int keplerId) {

        StringBuilder fullPath = new StringBuilder().append(PA_CENTROIDS_PATH)
            .append(fluxType.getName())
            .append('/')
            .append(timeSeriesType.getName())
            .append('/')
            .append(cadenceType.getName())
            .append('/')
            .append(keplerId);
        return new FsId(fullPath.toString());
    }

    public static FsId getCentroidTimeSeriesFsId(FluxType fluxType,
        CentroidType centroidType, CentroidTimeSeriesType timeSeriesType,
        CadenceType cadenceType, int keplerId) {

        StringBuilder fullPath = new StringBuilder().append(PA_CENTROIDS_PATH)
            .append(fluxType.getName())
            .append('/')
            .append(centroidType.getName())
            .append('/')
            .append(timeSeriesType.getName())
            .append('/')
            .append(cadenceType.getName())
            .append('/')
            .append(keplerId);
        return new FsId(fullPath.toString());
    }

    public static FsId getCosmicRayMetricFsId(CosmicRayMetricType metricType,
        TargetType targetTableType, int ccdModule, int ccdOutput) {

        StringBuilder fullPath = new StringBuilder();
        fullPath.append(PA_CR_METRICS_PATH)
            .append(ccdModule)
            .append(PixelFsIdFactory.SEP)
            .append(ccdOutput)
            .append(PixelFsIdFactory.SEP)
            .append(targetTableType.shortName())
            .append(PixelFsIdFactory.SEP)
            .append(metricType.getName());
        return new FsId(fullPath.toString());
    }

    public static FsId getMetricTimeSeriesFsId(MetricTimeSeriesType metricType,
        int ccdModule, int ccdOutput) {

        StringBuilder fullPath = new StringBuilder();
        fullPath.append(PA_METRICS_PATH)
            .append(metricType.getName())
            .append('/')
            .append(ccdModule)
            .append(PixelFsIdFactory.SEP)
            .append(ccdOutput);
        return new FsId(fullPath.toString());
    }

    public static FsId getCosmicRaySeriesFsId(TargetType targetTableType,
        int ccdModule, int ccdOutput, int row, int column) {

        return getPixelFsId(PA_CRS_PATH, targetTableType, ccdModule, ccdOutput,
            row, column, PixelFsIdFactory.SEP);
    }

    public static Map<String, Object> parseCosmicRaySeriesFsId(
        FsId cosmicRaySeriesId) {

        Matcher matcher = cosmicRaySeriesPattern.matcher(cosmicRaySeriesId.toString());
        if (!matcher.matches()) {
            throw new PipelineException("Bad PA ComsicRaySeries FsId \""
                + cosmicRaySeriesId + "\".");
        }
        Map<String, Object> rv = new HashMap<String, Object>();
        parsePixelFsId(rv, matcher, 1);

        return rv;
    }

    public static FsId getMatlabBlobFsId(BlobSeriesType blobType,
        int ccdModule, int ccdOutput, CadenceType cadenceType,
        long pipelineTaskId) {

        if (blobType == null) {
            throw new NullPointerException("blobType is null");
        }
        if (blobType != BlobSeriesType.UNCERTAINTIES) {
            throw new IllegalArgumentException(
                "Only uncertainties are produced for short OR long cadence.");
        }

        StringBuilder fullPath = new StringBuilder();
        fullPath.append(PaFsIdFactory.PA_PATH)
            .append(blobType.getName())
            .append('/')
            .append(cadenceType.getName())
            .append(PixelFsIdFactory.SEP)
            .append(ccdModule)
            .append(PixelFsIdFactory.SEP)
            .append(ccdOutput)
            .append(PixelFsIdFactory.SEP)
            .append(pipelineTaskId);
        return new FsId(fullPath.toString());
    }

    /**
     * Get FsId for matlab blob data.
     * 
     * @return
     */
    public static FsId getMatlabBlobFsId(BlobSeriesType blobType,
        int ccdModule, int ccdOutput, long pipelineTaskId) {

        if (blobType == null) {
            throw new NullPointerException("blobType is null");
        }

        if (blobType != BlobSeriesType.BACKGROUND
            && blobType != BlobSeriesType.MOTION
            && blobType != BlobSeriesType.FFI_MOTION) {
            throw new IllegalArgumentException(
                "Only background and motion blobs are cadence typeless.");
        }

        StringBuilder fullPath = new StringBuilder();
        fullPath.append(PaFsIdFactory.PA_PATH)
            .append(blobType.getName())
            .append('/')
            .append(ccdModule)
            .append(PixelFsIdFactory.SEP)
            .append(ccdOutput)
            .append(PixelFsIdFactory.SEP)
            .append(pipelineTaskId);
        return new FsId(fullPath.toString());
    }

    /**
     * Returns a {@code Set} containing all the mnemonics supported by this
     * {@code FsId} factory.
     */
    public static Set<String> getAncillaryPipelineDataMnemonics() {

        Set<String> mnemonics = new HashSet<String>();
        for (MetricTimeSeriesType metricType : MetricTimeSeriesType.values()) {
            if (!metricType.toString()
                .endsWith("_UNCERTAINTIES")) {
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
        int ccdModule, int ccdOutput) {

        for (MetricTimeSeriesType metricType : MetricTimeSeriesType.values()) {
            if (metricType.toString()
                .equals(mnemonic)) {
                return getMetricTimeSeriesFsId(metricType, ccdModule, ccdOutput);
            }
        }
        throw new IllegalArgumentException(String.format(
            "%s: invalid ancillary pipeline data mnemonic", mnemonic));
    }

    /**
     * Returns the {@code FsId} for the given {@code mnemonic}'s uncertainties
     * values.
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
        String mnemonic, int ccdModule, int ccdOutput) {

        for (MetricTimeSeriesType metricType : MetricTimeSeriesType.values()) {
            if (metricType.toString()
                .equals(mnemonic)) {
                if (metricType.uncertaintiesType() != null) {
                    return getMetricTimeSeriesFsId(
                        metricType.uncertaintiesType(), ccdModule, ccdOutput);
                }
                return null;
            }
        }
        throw new IllegalArgumentException(String.format(
            "%s: invalid ancillary pipeline data mnemonic", mnemonic));
    }

    /**
     * Returns the {@code FsId} for thruster firing time series.
     * 
     * @param cadenceType the {@code CadenceType}
     * @return the {@code FsId} for the thruster firing data
     */
    public static FsId getThrusterActivityFsId(CadenceType cadenceType,
        ThrusterActivityType thrusterActivityType) {

        StringBuilder fullPath = new StringBuilder().append(PA_PATH)
            .append(thrusterActivityType.getName())
            .append('/')
            .append(cadenceType.getName());
        return new FsId(fullPath.toString());
    }
}
