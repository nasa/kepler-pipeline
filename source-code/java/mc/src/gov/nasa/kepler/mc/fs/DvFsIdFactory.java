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

import static gov.nasa.kepler.mc.fs.PixelFsIdFactory.SEP;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.dv.DvPlanetModelFit.PlanetModelFitType;
import gov.nasa.spiffy.common.lang.StringUtils;

import java.util.Collection;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * FsId creation methods.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class DvFsIdFactory {

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(DvFsIdFactory.class);

    public static final String DV_PATH = "/dv/";

    public enum DvTimeSeriesType {
        FLUX, UNCERTAINTIES, FILLED_INDICES;

        private String name;

        private DvTimeSeriesType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }
    }

    public enum DvSingleEventStatisticsType {
        CORRELATION, NORMALIZATION;

        private String name;

        private DvSingleEventStatisticsType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }

        public static DvSingleEventStatisticsType parseName(String name) {
            for (DvSingleEventStatisticsType type : values()) {
                if (type.name.equals(name)) {
                    return type;
                }
            }
            throw new IllegalArgumentException("Bad "
                + "DvSingleEventStatisticsType name \"" + name + "\".");
        }
    }

    public enum DvLightCurveType {
        MODEL_LIGHT_CURVE,
        WHITENED_MODEL_LIGHT_CURVE,
        TRAPEZOIDAL_MODEL_LIGHT_CURVE;

        private String name;

        private DvLightCurveType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }

        @Override
        public String toString() {
            return getName();
        }
    }

    public enum DvCorrectedFluxType {
        INITIAL, DETRENDED;

        private String name;

        private DvCorrectedFluxType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }

        @Override
        public String toString() {
            return getName();
        }
    }

    /**
     * No instances.
     */
    private DvFsIdFactory() {
    }

    /**
     * Obtains the {@link FsId} for a residual time series. This {@link FsId}
     * has the form:
     * 
     * <pre>
     * /dv/fluxType/Residual/timeSeriesType/pipelineInstanceId/keplerId
     * </pre>
     */
    public static FsId getResidualTimeSeriesFsId(FluxType fluxType,
        DvTimeSeriesType timeSeriesType, long pipelineInstanceId, int keplerId) {

        StringBuilder path = new StringBuilder().append(DV_PATH)
            .append(fluxType.getName())
            .append("/Residual/")
            .append(timeSeriesType.getName())
            .append('/')
            .append(pipelineInstanceId)
            .append('/')
            .append(keplerId);

        return new FsId(path.toString());
    }

    /**
     * Obtains the {@link FsId} for an initial per-planet time series. This
     * {@link FsId} has the form:
     * 
     * <pre>
     * /dv/fluxType/Initial/timeSeriesType/pipelineInstanceId/keplerId:planetNumber
     * </pre>
     */
    public static FsId getCorrectedFluxTimeSeriesFsId(FluxType fluxType,
        DvCorrectedFluxType correctedFluxType, DvTimeSeriesType timeSeriesType,
        long pipelineInstanceId, int keplerId, int planetNumber) {

        StringBuilder path = new StringBuilder().append(DV_PATH)
            .append(fluxType.getName())
            .append("/")
            .append(correctedFluxType)
            .append("/")
            .append(timeSeriesType.getName())
            .append('/')
            .append(pipelineInstanceId)
            .append('/')
            .append(keplerId)
            .append(SEP)
            .append(planetNumber);

        return new FsId(path.toString());
    }

    /**
     * Obtains the {@link FsId} for the per-planet model light curve time
     * series. This {@link FsId} has the form:
     * 
     * <pre>
     * /dv/fluxType/ModelLightCurve/pipelineInstanceId/keplerId:planetNumber
     * </pre>
     */
    public static FsId getLightCurveTimeSeriesFsId(FluxType fluxType,
        DvLightCurveType lightCurveType, long pipelineInstanceId, int keplerId,
        int planetNumber) {

        StringBuilder path = new StringBuilder().append(DV_PATH)
            .append(fluxType.getName())
            .append("/")
            .append(lightCurveType)
            .append("/")
            .append(pipelineInstanceId)
            .append('/')
            .append(keplerId)
            .append(SEP)
            .append(planetNumber);

        return new FsId(path.toString());
    }

    /**
     * Obtains the {@link FsId} for the per-planet model light curve time
     * series. This {@link FsId} has the form:
     * 
     * <pre>
     * /dv/fluxType/ModelLightCurve/pipelineInstanceId/keplerId:planetNumber
     * </pre>
     */
    public static FsId getFluxTimeSeriesFsId(FluxType fluxType,
        String lightCurveType, long pipelineInstanceId, int keplerId,
        int planetNumber) {

        StringBuilder path = new StringBuilder().append(DV_PATH)
            .append(fluxType.getName())
            .append("/")
            .append(lightCurveType)
            .append("/")
            .append(pipelineInstanceId)
            .append('/')
            .append(keplerId)
            .append(SEP)
            .append(planetNumber);

        return new FsId(path.toString());
    }

    /**
     * Obtains the {@link FsId} for single event statistics. This {@link FsId}
     * has the form:
     * 
     * <pre>
     * /dv/fluxType/SingleEventStatistics/singleEventStatisticsType/pipelineInstanceId/keplerId:trialTransitPulseDuration
     * </pre>
     */
    public static FsId getSingleEventStatisticsFsId(FluxType fluxType,
        DvSingleEventStatisticsType singleEventStatisticsType,
        long pipelineInstanceId, int keplerId, float trialTransitPulseDuration) {

        StringBuilder path = new StringBuilder().append(DV_PATH)
            .append(fluxType.getName())
            .append("/SingleEventStatistics/")
            .append(singleEventStatisticsType.getName())
            .append('/')
            .append(pipelineInstanceId)
            .append('/')
            .append(keplerId)
            .append(SEP)
            .append(String.format("%.2f", trialTransitPulseDuration));

        return new FsId(path.toString());
    }

    /**
     * Obtains the {@link FsId} for the per-planet robust weights time series.
     * This {@link FsId} has the form:
     * 
     * <pre>
     * /dv/fluxType/RobustWeights/planetModelFitType/pipelineInstanceId/keplerId:planetNumber
     * </pre>
     * 
     * @throws IllegalArgumentException if {@code planetModelFitType} is SINGLE;
     * use
     * {@link #getSingleRobustWeightsTimeSeriesFsId(FluxType, int, long, int, int)
     * instead
     */
    public static FsId getRobustWeightsTimeSeriesFsId(FluxType fluxType,
        PlanetModelFitType planetModelFitType, long pipelineInstanceId,
        int keplerId, int planetNumber) {

        if (planetModelFitType == PlanetModelFitType.SINGLE) {
            throw new IllegalArgumentException(
                "planetModelFitType can't be SINGLE");
        }

        StringBuilder path = new StringBuilder().append(DV_PATH)
            .append(fluxType.getName())
            .append("/RobustWeights/")
            .append(planetModelFitType.getName())
            .append('/')
            .append(pipelineInstanceId)
            .append('/')
            .append(keplerId)
            .append(SEP)
            .append(planetNumber);

        return new FsId(path.toString());
    }

    /**
     * Obtains the {@link FsId} for the per-planet per-transit per-parameter
     * robust weights time series. This {@link FsId} has the form:
     * 
     * <pre>
     * /dv/fluxType/RobustWeights/ReducedParameter/pipelineInstanceId/keplerId:planetNumber:parameterName:parameterValue
     * </pre>
     */
    public static FsId getReducedParameterRobustWeightsTimeSeriesFsId(
        FluxType fluxType, long pipelineInstanceId, int keplerId,
        int planetNumber, String parameterName, double parameterValue) {

        StringBuilder path = new StringBuilder().append(DV_PATH)
            .append(fluxType.getName())
            .append("/RobustWeights/")
            .append(PlanetModelFitType.REDUCED_PARAMETER.getName())
            .append('/')
            .append(pipelineInstanceId)
            .append('/')
            .append(keplerId)
            .append(SEP)
            .append(planetNumber)
            .append(SEP)
            .append(parameterName)
            .append(SEP)
            .append(String.format("%.3f", parameterValue));

        return new FsId(path.toString());
    }

    /**
     * Obtains the {@link FsId} for the per-planet per-transit robust weights
     * time series. This {@link FsId} has the form:
     * 
     * <pre>
     * /dv/fluxType/RobustWeights/Single/pipelineInstanceId/keplerId:planetNumber:transitNumber
     * </pre>
     */
    public static FsId getSingleRobustWeightsTimeSeriesFsId(FluxType fluxType,
        long pipelineInstanceId, int keplerId, int planetNumber,
        int transitNumber) {

        StringBuilder path = new StringBuilder().append(DV_PATH)
            .append(fluxType.getName())
            .append("/RobustWeights/")
            .append(PlanetModelFitType.SINGLE.getName())
            .append('/')
            .append(pipelineInstanceId)
            .append('/')
            .append(keplerId)
            .append(SEP)
            .append(planetNumber)
            .append(SEP)
            .append(transitNumber);

        return new FsId(path.toString());
    }

    /**
     * Obtains the {@link FsId} for the barycentric-corrected time series. This
     * {@link FsId} has the form:
     * 
     * <pre>
     * /dv/fluxType/BarycentricCorrectedTimestamps/pipelineInstanceId/keplerId
     * </pre>
     */
    public static FsId getBarycentricCorrectedTimestampsFsId(FluxType fluxType,
        long pipelineInstanceId, int keplerId) {

        StringBuilder path = new StringBuilder().append(DV_PATH)
            .append(fluxType.getName())
            .append("/BarycentricCorrectedTimestamps/")
            .append(pipelineInstanceId)
            .append('/')
            .append(keplerId);

        return new FsId(path.toString());
    }

    /**
     * Obtains the {@link FsId} for the per-planet robust weights time series.
     * This {@link FsId} has the form:
     * 
     * <pre>
     * /dv/fluxType/FoldedPhase/pipelineInstanceId/keplerId:planetNumber
     * </pre>
     */
    public static FsId getFoldedPhaseTimeSeriesFsId(FluxType fluxType,
        long pipelineInstanceId, int keplerId, int planetNumber) {

        StringBuilder path = new StringBuilder().append(DV_PATH)
            .append(fluxType.getName())
            .append("/FoldedPhase/")
            .append(pipelineInstanceId)
            .append('/')
            .append(keplerId)
            .append(SEP)
            .append(planetNumber);

        return new FsId(path.toString());
    }

    /**
     * Generates a file store query string to find the single event statistic
     * time series for a particular range of Kepler IDs.
     */
    public static String createSingleEventStatisticsQuery(FluxType fluxType,
        Collection<Long> pipelineInstanceIds, int minKeplerId, int maxKeplerId) {

        StringBuilder query = new StringBuilder();
        query.append("TimeSeries@")
            .append(DV_PATH)
            .append(fluxType.getName())
            .append("/SingleEventStatistics/");

        query.append('[');
        for (DvSingleEventStatisticsType type : DvSingleEventStatisticsType.values()) {
            query.append(type.getName());
            query.append(',');
        }
        query.setLength(query.length() - 1);
        query.append(']');

        query.append('/')
            .append('[');
        for (long instanceId : pipelineInstanceIds) {
            query.append(instanceId)
                .append(',');
        }
        query.setLength(query.length() - 1);
        query.append(']');

        query.append('/')
            .append('[')
            .append(minKeplerId)
            .append('-')
            .append(maxKeplerId)
            .append(']')
            .append(SEP)
            .append("\\d");

        return query.toString();
    }

    public static SingleEventParse parseSingleEventStatisticsFsId(
        FsId singleEventStatisticsFsId) {

        String fullPath = singleEventStatisticsFsId.toString();
        String remainder = fullPath.substring(DV_PATH.length());
        FluxType fluxType = FluxType.parseName(remainder.substring(0,
            remainder.indexOf('/')));
        remainder = remainder.substring(remainder.indexOf('/')
            + "/SingleEventStatistics/".length());
        DvSingleEventStatisticsType type = DvSingleEventStatisticsType.parseName(remainder.substring(
            0, remainder.indexOf('/')));
        remainder = remainder.substring(remainder.indexOf('/') + 1);
        long pipelineInstanceId = Long.parseLong(remainder.substring(0,
            remainder.indexOf('/')));
        remainder = remainder.substring(remainder.indexOf('/') + 1);
        int keplerId = Integer.parseInt(remainder.substring(0,
            remainder.indexOf(SEP)));
        remainder = remainder.substring(remainder.indexOf(SEP) + 1);
        float trialTransitPulse = Float.parseFloat(remainder);

        return new SingleEventParse(fluxType, type, pipelineInstanceId,
            keplerId, trialTransitPulse);
    }

    public static class SingleEventParse {
        public final FluxType fluxType;
        public final DvSingleEventStatisticsType singleEventStatisticsType;
        public final int keplerId;
        public final long pipelineInstanceId;
        public final float trialTransitPulseDuration;

        public SingleEventParse(FluxType fluxType,
            DvSingleEventStatisticsType singleEventStatisticsType,
            long pipelineInstanceId, int keplerId,
            float trialTransitPulseDuration) {
            super();
            this.fluxType = fluxType;
            this.singleEventStatisticsType = singleEventStatisticsType;
            this.keplerId = keplerId;
            this.pipelineInstanceId = pipelineInstanceId;
            this.trialTransitPulseDuration = trialTransitPulseDuration;
        }
    }
}
