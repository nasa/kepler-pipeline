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

package gov.nasa.kepler.pa;

import static com.google.common.collect.Lists.newArrayList;
import static gov.nasa.kepler.mc.fs.PaFsIdFactory.getCentroidTimeSeriesFsId;
import static gov.nasa.kepler.mc.fs.PaFsIdFactory.getTimeSeriesFsId;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.mc.CompoundTimeSeries;
import gov.nasa.kepler.mc.CompoundTimeSeries.Centroids;
import gov.nasa.kepler.mc.SimpleTimeSeries;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidTimeSeriesType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.TimeSeriesType;
import gov.nasa.kepler.mc.pa.RollingBandContamination;
import gov.nasa.kepler.mc.tad.OptimalAperture;
import gov.nasa.spiffy.common.CentroidTimeSeries;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleDoubleTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.persistable.OracleDouble;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * PA output target flux and centroid time series.
 * 
 * @author Forrest Girouard
 * 
 */
public class PaFluxTarget implements Persistable {

    /**
     * The Kepler ID for this target (directly from the KIC).
     */
    private int keplerId;

    /**
     * The right ascension for this target in hours (directly from the KIC).
     */
    @OracleDouble
    private double raHours;

    /**
     * The declination of this target in degrees (directly from the KIC).
     */
    @OracleDouble
    private double decDegrees;

    /**
     * The row relative to which the pixels in the target are located.
     */
    private int referenceRow;

    /**
     * The column relative to which the pixels in the target are located.
     */
    private int referenceColumn;

    /**
     * The measured target flux.
     */
    private CompoundFloatTimeSeries fluxTimeSeries;

    /**
     * The background flux.
     */
    private CompoundFloatTimeSeries backgroundFluxTimeSeries;

    /**
     * The flux-weighted centroids.
     */
    private CentroidTimeSeries fluxWeightedCentroids;

    /**
     * The prf-based centroids.
     */
    private CentroidTimeSeries prfCentroids;

    /**
     * Barycentric time offset from MJD.
     */
    private SimpleFloatTimeSeries barycentricTimeOffset;

    /**
     * Per-pixel aperture flags.
     */
    private List<PaCentroidPixel> pixelApertureStruct = newArrayList();

    /**
     * The rolling band artifact contamination for target.
     */
    private List<RollingBandContamination> rollingBandContaminationStruct = new ArrayList<RollingBandContamination>();

    /**
     * TAD-COA per target outputs.
     */
    private SimpleDoubleTimeSeries signalToNoiseRatioTimeSeries;
    private SimpleDoubleTimeSeries fluxFractionInApertureTimeSeries;
    private SimpleDoubleTimeSeries crowdingMetricTimeSeries;
    private SimpleDoubleTimeSeries skyCrowdingMetricTimeSeries;
    private OptimalAperture optimalAperture;

    public PaFluxTarget() {
    }

    public PaFluxTarget(int keplerId, double raHours, double decDegrees,
        int referenceRow, int referenceColumn) {
        this.keplerId = keplerId;
        this.raHours = raHours;
        this.decDegrees = decDegrees;
        this.referenceRow = referenceRow;
        this.referenceColumn = referenceColumn;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + keplerId;
        result = prime * result + referenceColumn;
        result = prime * result + referenceRow;
        return result;
    }

    @Override
    public boolean equals(final Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof PaFluxTarget)) {
            return false;
        }
        PaFluxTarget other = (PaFluxTarget) obj;
        if (keplerId != other.keplerId) {
            return false;
        }
        if (referenceColumn != other.referenceColumn) {
            return false;
        }
        if (referenceRow != other.referenceRow) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("keplerId", keplerId)
            .append("raHours", raHours)
            .append("decDegrees", decDegrees)
            .append("referenceRow", referenceRow)
            .append("referenceColumn", referenceColumn)
            .append("fluxTimeSeries", fluxTimeSeries)
            .append("pixelApertureStruct.size()", pixelApertureStruct.size())
            .toString();
    }

    public List<FsId> getAllFsIds(FluxType fluxType, CadenceType cadenceType,
        boolean coaEnabled, Set<Integer> pulseDurations) {

        List<FsId> fsIds = newArrayList();

        // barcentric time offsets
        fsIds.add(PaFsIdFactory.getBarcentricTimeOffsetFsId(cadenceType,
            keplerId));

        // flux time series
        fsIds.add(getTimeSeriesFsId(TimeSeriesType.RAW_FLUX, fluxType,
            cadenceType, keplerId));
        fsIds.add(getTimeSeriesFsId(TimeSeriesType.RAW_FLUX_UNCERTAINTIES,
            fluxType, cadenceType, keplerId));
        fsIds.add(getTimeSeriesFsId(TimeSeriesType.BACKGROUND_FLUX, fluxType,
            cadenceType, keplerId));
        fsIds.add(getTimeSeriesFsId(
            TimeSeriesType.BACKGROUND_FLUX_UNCERTAINTIES, fluxType,
            cadenceType, keplerId));

        // PA-COA time series
        fsIds.addAll(getAttributeFsIds(fluxType, cadenceType, coaEnabled));

        // rolling band artifact contamination
        for (int pulseDuration : pulseDurations) {
            fsIds.addAll(RollingBandContamination.getFsIds(pulseDuration,
                keplerId));
        }

        // flux-weighted centroids
        fsIds.addAll(getCentroidsFsIds(fluxType, CentroidType.FLUX_WEIGHTED,
            cadenceType));

        // PRF centroids
        fsIds.addAll(getCentroidsFsIds(fluxType, CentroidType.PRF, cadenceType));

        // default centroids
        fsIds.addAll(getCentroidsFsIds(fluxType, cadenceType));

        // original, context-free centroids
        fsIds.addAll(getCentroidsFsIds(cadenceType));

        return fsIds;
    }

    public List<FsId> getAttributeFsIds(FluxType fluxType,
        CadenceType cadenceType, boolean coaEnabled) {

        if (coaEnabled) {
            return getAttributeFsIds(fluxType, cadenceType, keplerId);
        }

        return newArrayList();
    }

    public static List<FsId> getAttributeFsIds(FluxType fluxType,
        CadenceType cadenceType, int keplerId) {

        List<FsId> fsIds = newArrayList();

        fsIds.add(getTimeSeriesFsId(TimeSeriesType.SIGNAL_TO_NOISE_RATIO,
            fluxType, cadenceType, keplerId));
        fsIds.add(getTimeSeriesFsId(TimeSeriesType.FLUX_FRACTION_IN_APERTURE,
            fluxType, cadenceType, keplerId));
        fsIds.add(getTimeSeriesFsId(TimeSeriesType.CROWDING_METRIC, fluxType,
            cadenceType, keplerId));
        fsIds.add(getTimeSeriesFsId(TimeSeriesType.SKY_CROWDING_METRIC,
            fluxType, cadenceType, keplerId));

        return fsIds;
    }

    public List<FsId> getCentroidsFsIds(FluxType fluxType,
        CentroidType centroidType, CadenceType cadenceType) {

        return getCentroidsFsIds(fluxType, centroidType, cadenceType, keplerId);
    }

    public static List<FsId> getCentroidsFsIds(FluxType fluxType,
        CentroidType centroidType, CadenceType cadenceType, int keplerId) {

        List<FsId> fsIds = newArrayList();

        fsIds.add(getCentroidTimeSeriesFsId(fluxType, centroidType,
            CentroidTimeSeriesType.CENTROID_ROWS, cadenceType, keplerId));
        fsIds.add(getCentroidTimeSeriesFsId(fluxType, centroidType,
            CentroidTimeSeriesType.CENTROID_ROWS_UNCERTAINTIES, cadenceType,
            keplerId));
        fsIds.add(getCentroidTimeSeriesFsId(fluxType, centroidType,
            CentroidTimeSeriesType.CENTROID_COLS, cadenceType, keplerId));
        fsIds.add(getCentroidTimeSeriesFsId(fluxType, centroidType,
            CentroidTimeSeriesType.CENTROID_COLS_UNCERTAINTIES, cadenceType,
            keplerId));
        return fsIds;
    }

    public List<FsId> getCentroidsFsIds(FluxType fluxType,
        CadenceType cadenceType) {

        return getCentroidsFsIds(fluxType, cadenceType, keplerId);
    }

    public static List<FsId> getCentroidsFsIds(FluxType fluxType,
        CadenceType cadenceType, int keplerId) {

        List<FsId> fsIds = newArrayList();

        fsIds.add(getCentroidTimeSeriesFsId(fluxType,
            CentroidTimeSeriesType.CENTROID_ROWS, cadenceType, keplerId));
        fsIds.add(getCentroidTimeSeriesFsId(fluxType,
            CentroidTimeSeriesType.CENTROID_ROWS_UNCERTAINTIES, cadenceType,
            keplerId));
        fsIds.add(getCentroidTimeSeriesFsId(fluxType,
            CentroidTimeSeriesType.CENTROID_COLS, cadenceType, keplerId));
        fsIds.add(getCentroidTimeSeriesFsId(fluxType,
            CentroidTimeSeriesType.CENTROID_COLS_UNCERTAINTIES, cadenceType,
            keplerId));
        return fsIds;
    }

    public List<FsId> getCentroidsFsIds(CadenceType cadenceType) {
        return getCentroidsFsIds(cadenceType, keplerId);
    }

    public static List<FsId> getCentroidsFsIds(CadenceType cadenceType,
        int keplerId) {

        List<FsId> fsIds = newArrayList();

        fsIds.add(getCentroidTimeSeriesFsId(
            CentroidTimeSeriesType.CENTROID_ROWS, cadenceType, keplerId));
        fsIds.add(getCentroidTimeSeriesFsId(
            CentroidTimeSeriesType.CENTROID_ROWS_UNCERTAINTIES, cadenceType,
            keplerId));
        fsIds.add(getCentroidTimeSeriesFsId(
            CentroidTimeSeriesType.CENTROID_COLS, cadenceType, keplerId));
        fsIds.add(getCentroidTimeSeriesFsId(
            CentroidTimeSeriesType.CENTROID_COLS_UNCERTAINTIES, cadenceType,
            keplerId));
        return fsIds;
    }

    /**
     * Only used for testing.
     * 
     * @param fluxType
     * @param cadenceType
     * @param floatTimeSeriesByFsId
     * @param doubleTimeSeriesByFsId
     */
    public void setTimeSeries(Set<Integer> pulseDurations, FluxType fluxType,
        CadenceType cadenceType, int length,
        Map<FsId, ? extends TimeSeries> timeSeriesByFsId) {

        setBarycentricTimeOffset(SimpleTimeSeries.getFloatInstance(
            PaFsIdFactory.getBarcentricTimeOffsetFsId(cadenceType, keplerId),
            timeSeriesByFsId));

        for (int pulseDuration : pulseDurations) {
            if (getRollingBandContaminations() == null) {
                setRollingBandContaminations(new ArrayList<RollingBandContamination>());
            }
            getRollingBandContaminations().add(
                RollingBandContamination.getInstance(pulseDuration, keplerId,
                    length, timeSeriesByFsId));
        }

        setFluxTimeSeries(CompoundTimeSeries.getFloatInstance(
            getTimeSeriesFsId(TimeSeriesType.RAW_FLUX, fluxType, cadenceType,
                keplerId),
            getTimeSeriesFsId(TimeSeriesType.RAW_FLUX_UNCERTAINTIES, fluxType,
                cadenceType, keplerId), timeSeriesByFsId));

        setBackgroundFluxTimeSeries(CompoundTimeSeries.getFloatInstance(
            getTimeSeriesFsId(TimeSeriesType.BACKGROUND_FLUX, fluxType,
                cadenceType, keplerId),
            getTimeSeriesFsId(TimeSeriesType.BACKGROUND_FLUX_UNCERTAINTIES,
                fluxType, cadenceType, keplerId), timeSeriesByFsId));

        setSignalToNoiseRatioTimeSeries(SimpleTimeSeries.getDoubleInstance(
            getTimeSeriesFsId(TimeSeriesType.SIGNAL_TO_NOISE_RATIO, fluxType,
                cadenceType, keplerId), timeSeriesByFsId));

        setFluxFractionInApertureTimeSeries(SimpleTimeSeries.getDoubleInstance(
            getTimeSeriesFsId(TimeSeriesType.FLUX_FRACTION_IN_APERTURE,
                fluxType, cadenceType, keplerId), timeSeriesByFsId));

        setCrowdingMetricTimeSeries(SimpleTimeSeries.getDoubleInstance(
            getTimeSeriesFsId(TimeSeriesType.CROWDING_METRIC, fluxType,
                cadenceType, keplerId), timeSeriesByFsId));

        setSkyCrowdingMetricTimeSeries(SimpleTimeSeries.getDoubleInstance(
            getTimeSeriesFsId(TimeSeriesType.SKY_CROWDING_METRIC, fluxType,
                cadenceType, keplerId), timeSeriesByFsId));

        setFluxWeightedCentroids(Centroids.getInstance(fluxType,
            CentroidType.FLUX_WEIGHTED, cadenceType, length, keplerId,
            timeSeriesByFsId));

        setPrfCentroids(Centroids.getInstance(fluxType, CentroidType.PRF,
            cadenceType, length, keplerId, timeSeriesByFsId));
    }

    public List<TimeSeries> toTimeSeries(boolean apertureUpdatedWithPaCoa, FluxType fluxType,
        CadenceType cadenceType, int startCadence, int endCadence,
        long originator) {

        List<TimeSeries> timeSeries = newArrayList();

        timeSeries.add(SimpleTimeSeries.toFloatTimeSeries(
            barycentricTimeOffset,
            PaFsIdFactory.getBarcentricTimeOffsetFsId(cadenceType, keplerId),
            startCadence, endCadence, originator));

        for (RollingBandContamination rollingBandContamination : rollingBandContaminationStruct) {
            timeSeries.addAll(rollingBandContamination.toTimeSeries(
                rollingBandContamination.getTestPulseDurationLc(), keplerId,
                startCadence, endCadence, originator));
        }

        timeSeries.addAll(CompoundTimeSeries.toFloatTimeSeries(
            fluxTimeSeries,
            getTimeSeriesFsId(TimeSeriesType.RAW_FLUX, fluxType, cadenceType,
                keplerId),
            getTimeSeriesFsId(TimeSeriesType.RAW_FLUX_UNCERTAINTIES, fluxType,
                cadenceType, keplerId), startCadence, endCadence, originator));

        timeSeries.addAll(CompoundTimeSeries.toFloatTimeSeries(
            backgroundFluxTimeSeries,
            getTimeSeriesFsId(TimeSeriesType.BACKGROUND_FLUX, fluxType,
                cadenceType, keplerId),
            getTimeSeriesFsId(TimeSeriesType.BACKGROUND_FLUX_UNCERTAINTIES,
                fluxType, cadenceType, keplerId), startCadence, endCadence,
            originator));

        if (apertureUpdatedWithPaCoa) {
            timeSeries.add(SimpleTimeSeries.toDoubleTimeSeries(
                signalToNoiseRatioTimeSeries,
                getTimeSeriesFsId(TimeSeriesType.SIGNAL_TO_NOISE_RATIO,
                    fluxType, cadenceType, keplerId), startCadence, endCadence,
                originator));

            timeSeries.add(SimpleTimeSeries.toDoubleTimeSeries(
                fluxFractionInApertureTimeSeries,
                getTimeSeriesFsId(TimeSeriesType.FLUX_FRACTION_IN_APERTURE,
                    fluxType, cadenceType, keplerId), startCadence, endCadence,
                originator));

            timeSeries.add(SimpleTimeSeries.toDoubleTimeSeries(
                crowdingMetricTimeSeries,
                getTimeSeriesFsId(TimeSeriesType.CROWDING_METRIC, fluxType,
                    cadenceType, keplerId), startCadence, endCadence,
                originator));

            timeSeries.add(SimpleTimeSeries.toDoubleTimeSeries(
                skyCrowdingMetricTimeSeries,
                getTimeSeriesFsId(TimeSeriesType.SKY_CROWDING_METRIC, fluxType,
                    cadenceType, keplerId), startCadence, endCadence,
                originator));
        }

        timeSeries.addAll(CompoundTimeSeries.toDoubleTimeSeries(
            fluxWeightedCentroids, fluxType, CentroidType.FLUX_WEIGHTED,
            cadenceType, keplerId, startCadence, endCadence, originator));

        CentroidTimeSeries defaultCentroids = fluxWeightedCentroids;
        if (!prfCentroids.isAllGaps()) {
            timeSeries.addAll(CompoundTimeSeries.toDoubleTimeSeries(
                prfCentroids, fluxType, CentroidType.PRF, cadenceType,
                keplerId, startCadence, endCadence, originator));
            defaultCentroids = prfCentroids;
        }

        timeSeries.addAll(CompoundTimeSeries.toDoubleTimeSeries(
            defaultCentroids, fluxType, null, cadenceType, keplerId,
            startCadence, endCadence, originator));

        timeSeries.addAll(CompoundTimeSeries.toDoubleTimeSeries(
            defaultCentroids, null, null, cadenceType, keplerId, startCadence,
            endCadence, originator));
        return timeSeries;
    }

    public List<PaCentroidPixel> getPixelAperture() {
        return pixelApertureStruct;
    }

    public void setPixelAperture(List<PaCentroidPixel> pixelAperture) {
        pixelApertureStruct = pixelAperture;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public double getRaHours() {
        return raHours;
    }

    public double getDecDegrees() {
        return decDegrees;
    }

    public int getReferenceRow() {
        return referenceRow;
    }

    public int getReferenceColumn() {
        return referenceColumn;
    }

    public CompoundFloatTimeSeries getFluxTimeSeries() {
        return fluxTimeSeries;
    }

    private void setFluxTimeSeries(CompoundFloatTimeSeries fluxTimeSeries) {
        this.fluxTimeSeries = fluxTimeSeries;
    }

    public CompoundFloatTimeSeries getBackgroundFluxTimeSeries() {
        return backgroundFluxTimeSeries;
    }

    private void setBackgroundFluxTimeSeries(
        CompoundFloatTimeSeries backgroundFluxTimeSeries) {
        this.backgroundFluxTimeSeries = backgroundFluxTimeSeries;
    }

    public CentroidTimeSeries getFluxWeightedCentroids() {
        return fluxWeightedCentroids;
    }

    private void setFluxWeightedCentroids(
        CentroidTimeSeries fluxWeightedCentroids) {
        this.fluxWeightedCentroids = fluxWeightedCentroids;
    }

    public CentroidTimeSeries getPrfCentroids() {
        return prfCentroids;
    }

    private void setPrfCentroids(CentroidTimeSeries prfCentroids) {
        this.prfCentroids = prfCentroids;
    }

    public SimpleFloatTimeSeries getBarycentricTimeOffset() {
        return barycentricTimeOffset;
    }

    private void setBarycentricTimeOffset(
        SimpleFloatTimeSeries barycentricTimeOffset) {
        this.barycentricTimeOffset = barycentricTimeOffset;
    }

    public List<RollingBandContamination> getRollingBandContaminations() {
        return rollingBandContaminationStruct;
    }

    public void setRollingBandContaminations(
        List<RollingBandContamination> rollingBandContaminations) {
        rollingBandContaminationStruct = rollingBandContaminations;
    }

    public SimpleDoubleTimeSeries getSignalToNoiseRatioTimeSeries() {
        return signalToNoiseRatioTimeSeries;
    }

    public void setSignalToNoiseRatioTimeSeries(
        SimpleDoubleTimeSeries signalToNoiseRatioTimeSeries) {
        this.signalToNoiseRatioTimeSeries = signalToNoiseRatioTimeSeries;
    }

    public SimpleDoubleTimeSeries getFluxFractionInApertureTimeSeries() {
        return fluxFractionInApertureTimeSeries;
    }

    public void setFluxFractionInApertureTimeSeries(
        SimpleDoubleTimeSeries fluxFractionInApertureTimeSeries) {
        this.fluxFractionInApertureTimeSeries = fluxFractionInApertureTimeSeries;
    }

    public SimpleDoubleTimeSeries getCrowdingMetricTimeSeries() {
        return crowdingMetricTimeSeries;
    }

    public void setCrowdingMetricTimeSeries(
        SimpleDoubleTimeSeries crowdingMetricTimeSeries) {
        this.crowdingMetricTimeSeries = crowdingMetricTimeSeries;
    }

    public SimpleDoubleTimeSeries getSkyCrowdingMetricTimeSeries() {
        return skyCrowdingMetricTimeSeries;
    }

    public void setSkyCrowdingMetricTimeSeries(
        SimpleDoubleTimeSeries skyCrowdingMetricTimeSeries) {
        this.skyCrowdingMetricTimeSeries = skyCrowdingMetricTimeSeries;
    }

    public List<PaCentroidPixel> getPixelApertureStruct() {
        return pixelApertureStruct;
    }

    public OptimalAperture getOptimalAperture() {
        return optimalAperture;
    }

    public void setOptimalAperture(OptimalAperture optimalAperture) {
        this.optimalAperture = optimalAperture;
    }
}
