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

package gov.nasa.kepler.dv.io;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.dv.DvUtils;
import gov.nasa.kepler.dv.io.DvTransit;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.FsIdSet;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.MjdFsIdSet;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.mc.CompoundTimeSeries;
import gov.nasa.kepler.mc.CorrectedFluxTimeSeries;
import gov.nasa.kepler.mc.OutliersTimeSeries;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.RollingBandArtifactParameters;
import gov.nasa.kepler.mc.cm.CelestialObjectParameter;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFilledIndicesTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFluxTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcOutliersTimeSeriesType;
import gov.nasa.kepler.mc.pa.RollingBandContamination;
import gov.nasa.kepler.mc.pdc.FilledCadencesUtil;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import static com.google.common.base.Preconditions.checkNotNull;

import org.apache.commons.lang.ArrayUtils;

/**
 * All information related to a single target.
 * 
 * @author Forrest Girouard
 */
@ProxyIgnoreStatics
public class DvTarget implements Persistable {

    private String[] categories = ArrayUtils.EMPTY_STRING_ARRAY;
    private DvCentroidData centroids = new DvCentroidData();
    private CorrectedFluxTimeSeries correctedFluxTimeSeries = new CorrectedFluxTimeSeries();
    private CelestialObjectParameter decDegrees = new CelestialObjectParameter();
    private int[] discontinuityIndices = ArrayUtils.EMPTY_INT_ARRAY;
    private CelestialObjectParameter effectiveTemp = new CelestialObjectParameter();
    private int keplerId;
    private CelestialObjectParameter keplerMag = new CelestialObjectParameter();
    private CelestialObjectParameter log10Metallicity = new CelestialObjectParameter();
    private CelestialObjectParameter log10SurfaceGravity = new CelestialObjectParameter();
    private OutliersTimeSeries outliers = new OutliersTimeSeries();
    private CelestialObjectParameter radius = new CelestialObjectParameter();
    private CelestialObjectParameter raHours = new CelestialObjectParameter();
    private CompoundFloatTimeSeries rawFluxTimeSeries = new CompoundFloatTimeSeries();
    /**
     * One RollingBandContamination object per pulse duration.
     * Order is not important because the elements specify the pulse duration.
     */
    private List<RollingBandContamination> rollingBandContaminationStruct = new ArrayList<RollingBandContamination>();
    private List<DvTargetData> targetDataStruct = new ArrayList<DvTargetData>();
    private List<DvThresholdCrossingEvent> thresholdCrossingEvent = new ArrayList<DvThresholdCrossingEvent>();
    private List<DvTransit> transits = new ArrayList<DvTransit>();
    private String ukirtImageFileName = "";

    @ProxyIgnore
    private FluxType fluxType;

    // Initialized lazily
    @ProxyIgnore
    private List<FsIdSet> fsIdSets;

    // Initialized lazily
    @ProxyIgnore
    private List<MjdFsIdSet> mjdFsIdSets;

    /**
     * Creates a {@link DvTarget}. For use only by mock objects and Hibernate.
     */
    public DvTarget() {
    }

    /**
     * Creates a {@link DvTarget} from the given {@link Builder} object.
     */
    protected DvTarget(Builder builder) {
        categories = builder.categories;
        centroids = builder.centroids;
        correctedFluxTimeSeries = builder.correctedFluxTimeSeries;
        decDegrees = builder.decDegrees;
        discontinuityIndices = builder.discontinuityIndices;
        effectiveTemp = builder.effectiveTemp;
        fluxType = builder.fluxType;
        keplerId = builder.keplerId;
        keplerMag = builder.keplerMag;
        log10Metallicity = builder.log10Metallicity;
        log10SurfaceGravity = builder.log10SurfaceGravity;
        outliers = builder.outliers;
        radius = builder.radius;
        raHours = builder.raHours;
        rawFluxTimeSeries = builder.rawFluxTimeSeries;
        rollingBandContaminationStruct = builder.rollingBandContaminations;
        targetDataStruct = builder.targetDataStruct;
        thresholdCrossingEvent = builder.thresholdCrossingEvent;
        transits = builder.transits;
        ukirtImageFileName = builder.ukirtImageFileName;
    }

    /**
     * Return a List with one element, an object that contains a set of FsId
     * objects as well as the start cadence and end cadence.
     * This list is created on the first call to this method.
     */
    public List<FsIdSet> getFsIdSets(int startCadence, int endCadence,
        final int[] pulseDurations) {
        checkNotNull(pulseDurations, "pulseDurations can't be null");

        if (fsIdSets == null) {
            Map<Pair<Integer, Integer>, Set<FsId>> fsIdsByCadenceRange = new HashMap<Pair<Integer, Integer>, Set<FsId>>();
            DvUtils.addAllFsIds(Arrays.asList(new FsIdSet(startCadence,
                endCadence, getTargetFsIds(pulseDurations))), fsIdsByCadenceRange);
            fsIdSets = DvUtils.createFsIdSets(fsIdsByCadenceRange);
        }

        return fsIdSets;
    }

    /**
     * Return a List with one element, an object that contains a set of FsId
     * objects as well as the start MJD and end MJD.
     * This list is created on the first call to this method.
     */
    public List<MjdFsIdSet> getMjdFsIdSets(double startMjd, double endMjd) {

        if (mjdFsIdSets == null) {
            Map<Pair<Double, Double>, Set<FsId>> mjdFsIdByTimeRange = new HashMap<Pair<Double, Double>, Set<FsId>>();
            DvUtils.addAllMjdFsIds(Arrays.asList(new MjdFsIdSet(startMjd,
                endMjd, getTargetMjdFsIds())), mjdFsIdByTimeRange);
            mjdFsIdSets = DvUtils.createMjdFsIdSets(mjdFsIdByTimeRange);
        }

        return mjdFsIdSets;
    }

    /**
     * Return a List with one element, an object that contains a set of FsId
     * objects as well as the start cadence and end cadence, for only those
     * time series that are required (not optional).
     * This is used for testing.
     */
    public List<FsIdSet> getRequiredFsIdSets(int startCadence, int endCadence) {

        Map<Pair<Integer, Integer>, Set<FsId>> fsIdsByCadenceRange = new HashMap<Pair<Integer, Integer>, Set<FsId>>();
        DvUtils.addAllFsIds(getPixelFsIdSets(), fsIdsByCadenceRange);
        DvUtils.addAllFsIds(Arrays.asList(new FsIdSet(startCadence, endCadence,
            getRequiredTargetFsIds())), fsIdsByCadenceRange);

        return DvUtils.createFsIdSets(fsIdsByCadenceRange);
    }

    /**
     * Return a set of FsId objects for all time series, both required and
     * optional.
     * This has no callers. Make it public if another class starts calling it.
     */
    private Set<FsId> getTargetFsIds(final int[] pulseDurations) {

        checkNotNull(pulseDurations, "pulseDurations can't be null");
        Set<FsId> fsIds = new HashSet<FsId>();
        fsIds.addAll(getRequiredTargetFsIds());
        fsIds.addAll(getOptionalTargetFsIds(pulseDurations));

        return fsIds;
    }

    /**
     * Return a set of FsId objects for all required (non-optional) time series.
     */
    private Set<FsId> getRequiredTargetFsIds() {

        Set<FsId> fsIds = new HashSet<FsId>();
        fsIds.addAll(CorrectedFluxTimeSeries.getAllFloatFsIds(fluxType,
            CadenceType.LONG, keplerId));
        fsIds.addAll(CorrectedFluxTimeSeries.getAllIntFsIds(fluxType,
            CadenceType.LONG, keplerId));
        fsIds.add(PdcFsIdFactory.getDiscontinuityIndicesFsId(fluxType,
            CadenceType.LONG, keplerId));
        fsIds.addAll(DvCentroidData.getRequiredFsIds(fluxType, keplerId));
        fsIds.add(PaFsIdFactory.getTimeSeriesFsId(
            PaFsIdFactory.TimeSeriesType.RAW_FLUX, fluxType, CadenceType.LONG,
            keplerId));
        fsIds.add(PaFsIdFactory.getTimeSeriesFsId(
            PaFsIdFactory.TimeSeriesType.RAW_FLUX_UNCERTAINTIES, fluxType,
            CadenceType.LONG, keplerId));

        return fsIds;
    }

    /**
     * Return a set of FsId objects for all optional (non-required) time series.
     */
    private Set<FsId> getOptionalTargetFsIds(final int[] pulseDurations) {

        checkNotNull(pulseDurations, "pulseDurations can't be null");
        Set<FsId> fsIds = new HashSet<FsId>();
        fsIds.addAll(DvCentroidData.getOptionalFsIds(fluxType, keplerId));
        // Add fsIds for RollingBandContamination for each pulse duration
        for (int pulseDuration : pulseDurations) {
            fsIds.addAll(RollingBandContamination.getFsIds(pulseDuration,
                keplerId));
        }
        return fsIds;
    }

    public Set<FsId> getTargetMjdFsIds() {
        return new HashSet<FsId>(OutliersTimeSeries.getAllFloatMjdFsIds(
            fluxType, CadenceType.LONG, keplerId));
    }

    private List<FsIdSet> getPixelFsIdSets() {

        List<FsIdSet> fsIdSets = new ArrayList<FsIdSet>(targetDataStruct.size());
        for (DvTargetData targetData : targetDataStruct) {
            fsIdSets.add(new FsIdSet(targetData.getStartCadence(),
                targetData.getEndCadence(),
                Pixel.getAllFsIds(targetData.getPixels())));
        }

        return fsIdSets;
    }

    /**
     * Clears all data and in doing so renders this object unusable.
     */
    public void clearTimeSeries() {
        centroids = null;
        correctedFluxTimeSeries = null;
        outliers = null;
        rawFluxTimeSeries = null;
        if (targetDataStruct != null) {
            for (DvTargetData targetData : targetDataStruct) {
                targetData.getPixelData()
                    .clear();
            }
        }
    }

    public boolean isPopulated() {

        if (centroids == null || correctedFluxTimeSeries == null
            || outliers == null || rawFluxTimeSeries == null
            || targetDataStruct == null || targetDataStruct.isEmpty()) {
            return false;
        }
        if (!centroids.isPopulated()) {
            return false;
        }
        if (correctedFluxTimeSeries.isEmpty() || rawFluxTimeSeries.isEmpty()) {
            return false;
        }
        // Cannot verify that the outliers are populated.
        for (DvTargetData targetData : targetDataStruct) {
            if (!targetData.isPopulated()) {
                return false;
            }
        }

        return true;
    }

    /**
     * Populate all of the time series in the target. Note that it is assumed
     * that {@code timeSeries} and {@code mjdTimeSeries} have all of the
     * required time series. Otherwise, the target can be left in an partially
     * populated state. Use {@link #isPopulated()} to verify that the this call
     * succeeded.
     */
    public void setTimeSeries(MjdToCadence mjdToCadence, int startCadence,
        int endCadence, double startMjd, double endMjd,
        Map<Pair<Integer, Integer>, Map<FsId, TimeSeries>> timeSeries,
        Map<Pair<Double, Double>, Map<FsId, FloatMjdTimeSeries>> mjdTimeSeries,
        final int[] pulseDurations) {

        setTargetTimeSeries(mjdToCadence, startCadence, endCadence,
            timeSeries.get(Pair.of(startCadence, endCadence)),
            mjdTimeSeries.get(Pair.of(startMjd, endMjd)), pulseDurations);
    }

    /**
     * Save in fields of this class the fetched time series.
     */
    public void setTargetTimeSeries(MjdToCadence mjdToCadence,
        int startCadence, int endCadence, Map<FsId, TimeSeries> timeSeries,
        Map<FsId, FloatMjdTimeSeries> mjdTimeSeries, int[] pulseDurations) {

        checkNotNull(pulseDurations, "pulseDurations can't be null");
        centroids = DvCentroidData.getInstance(fluxType, keplerId, endCadence
            - startCadence + 1, timeSeries);
        correctedFluxTimeSeries = CorrectedFluxTimeSeries.getInstance(
            PdcFluxTimeSeriesType.CORRECTED_FLUX,
            PdcFluxTimeSeriesType.CORRECTED_FLUX_UNCERTAINTIES,
            PdcFilledIndicesTimeSeriesType.FILLED_INDICES, fluxType,
            CadenceType.LONG, endCadence - startCadence + 1, keplerId,
            timeSeries);
        discontinuityIndices = getDiscontinuityIndices(startCadence,
            endCadence, timeSeries);
        outliers = OutliersTimeSeries.getInstance(
            PdcOutliersTimeSeriesType.OUTLIERS,
            PdcOutliersTimeSeriesType.OUTLIER_UNCERTAINTIES, fluxType,
            CadenceType.LONG, keplerId, mjdToCadence, startCadence, endCadence,
            mjdTimeSeries);
        rawFluxTimeSeries = CompoundTimeSeries.getFloatInstance(
            PaFsIdFactory.getTimeSeriesFsId(
                PaFsIdFactory.TimeSeriesType.RAW_FLUX, fluxType,
                CadenceType.LONG, keplerId), PaFsIdFactory.getTimeSeriesFsId(
                PaFsIdFactory.TimeSeriesType.RAW_FLUX_UNCERTAINTIES, fluxType,
                CadenceType.LONG, keplerId), timeSeries);
        // Create one RollingBandContamination object for each pulse duration
        final int length = endCadence - startCadence + 1;
        for (Integer pulseDuration : pulseDurations) {
            RollingBandContamination rollingBandContamination =
                RollingBandContamination.getInstance(keplerId, pulseDuration, length, timeSeries);
            // Add it to the List of RollingBandContaminations
            rollingBandContaminationStruct.add(rollingBandContamination);
        }
    }

    private int[] getDiscontinuityIndices(int startCadence, int endCadence,
        Map<FsId, TimeSeries> timeSeries) {

        int[] discontinuityIndices = ArrayUtils.EMPTY_INT_ARRAY;
        FsId fsId = PdcFsIdFactory.getDiscontinuityIndicesFsId(fluxType,
            CadenceType.LONG, keplerId);
        IntTimeSeries filledTimeSeries = (IntTimeSeries) timeSeries.get(fsId);
        if (filledTimeSeries != null) {
            discontinuityIndices = FilledCadencesUtil.indicatorsToIndices(filledTimeSeries);
        }
        return discontinuityIndices;
    }

    public String[] getCategories() {
        return categories;
    }

    public DvCentroidData getCentroids() {
        return centroids;
    }

    public CorrectedFluxTimeSeries getCorrectedFluxTimeSeries() {
        return correctedFluxTimeSeries;
    }

    public CelestialObjectParameter getDecDegrees() {
        return decDegrees;
    }

    public int[] getDiscontinuityIndices() {
        return discontinuityIndices;
    }

    public CelestialObjectParameter getEffectiveTemp() {
        return effectiveTemp;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public CelestialObjectParameter getKeplerMag() {
        return keplerMag;
    }

    public CelestialObjectParameter getLog10Metallicity() {
        return log10Metallicity;
    }

    public CelestialObjectParameter getLog10SurfaceGravity() {
        return log10SurfaceGravity;
    }

    public OutliersTimeSeries getOutliers() {
        return outliers;
    }

    public CelestialObjectParameter getRadius() {
        return radius;
    }

    public CelestialObjectParameter getRaHours() {
        return raHours;
    }

    public CompoundFloatTimeSeries getRawFluxTimeSeries() {
        return rawFluxTimeSeries;
    }
    
    public List<RollingBandContamination> getRollingBandContaminations() {
        return rollingBandContaminationStruct;
    }

    public List<DvTargetData> getTargetData() {
        return targetDataStruct;
    }

    public List<DvThresholdCrossingEvent> getThresholdCrossingEvent() {
        return thresholdCrossingEvent;
    }

    public List<DvTransit> getTransits() {
        return transits;
    }

    public void setTransits(List<DvTransit> transits) {
        this.transits = transits;
    }

    public String getUkirtImageFileName() {
        return ukirtImageFileName;
    }

    public void setUkirtImageFileName(String ukirtImageFileName) {
        this.ukirtImageFileName = ukirtImageFileName;
    }

    /**
     * Used to construct a {@link DvTarget} object. To use this class, a
     * {@link Builder} object is created and then non-null fields are set using
     * the available builder methods. Finally, a {@link DvTarget} object is
     * created using the {@code build} method. For example:
     * 
     * <pre>
     * DvTarget binaryDiscriminationResults = new DvTarget.Builder().foo(fozar)
     *     .bar(bazar)
     *     .build();
     * </pre>
     * 
     * This pattern is based upon <a href=
     * "http://developers.sun.com/learning/javaoneonline/2006/coreplatform/TS-1512.pdf"
     * > Josh Bloch's JavaOne 2006 talk, Effective Java Reloaded, TS-1512</a>.
     * 
     * @author Forrest Girouard
     */
    public static class Builder {
        private String[] categories = ArrayUtils.EMPTY_STRING_ARRAY;
        private DvCentroidData centroids = new DvCentroidData();
        private CorrectedFluxTimeSeries correctedFluxTimeSeries = new CorrectedFluxTimeSeries();
        private CelestialObjectParameter decDegrees = new CelestialObjectParameter();
        private int[] discontinuityIndices = ArrayUtils.EMPTY_INT_ARRAY;
        private CelestialObjectParameter effectiveTemp = new CelestialObjectParameter();
        private FluxType fluxType;
        private int keplerId;
        private CelestialObjectParameter keplerMag = new CelestialObjectParameter();
        private CelestialObjectParameter log10Metallicity = new CelestialObjectParameter();
        private CelestialObjectParameter log10SurfaceGravity = new CelestialObjectParameter();
        private OutliersTimeSeries outliers = new OutliersTimeSeries();
        private CelestialObjectParameter radius = new CelestialObjectParameter();
        private CelestialObjectParameter raHours = new CelestialObjectParameter();
        private CompoundFloatTimeSeries rawFluxTimeSeries = new CompoundFloatTimeSeries();
        private List<RollingBandContamination> rollingBandContaminations = new ArrayList<RollingBandContamination>();
        private List<DvTargetData> targetDataStruct = new ArrayList<DvTargetData>();
        private List<DvThresholdCrossingEvent> thresholdCrossingEvent = new ArrayList<DvThresholdCrossingEvent>();
        private List<DvTransit> transits = new ArrayList<DvTransit>();
        private String ukirtImageFileName = "";

        public Builder(final int keplerId, final FluxType fluxType) {
            this.fluxType = fluxType;
            this.keplerId = keplerId;
        }

        public Builder categories(String[] categories) {
            this.categories = categories;
            return this;
        }

        public Builder centroids(DvCentroidData centroids) {
            this.centroids = centroids;
            return this;
        }

        public Builder correctedFluxTimeSeries(
            CorrectedFluxTimeSeries correctedFluxTimeSeries) {
            this.correctedFluxTimeSeries = correctedFluxTimeSeries;
            return this;
        }

        public Builder decDegrees(CelestialObjectParameter decDegrees) {
            this.decDegrees = decDegrees;
            return this;
        }

        public Builder discontinuityIndices(int[] discontinuityIndices) {
            this.discontinuityIndices = discontinuityIndices;
            return this;
        }

        public Builder effectiveTemp(CelestialObjectParameter effectiveTemp) {
            this.effectiveTemp = effectiveTemp;
            return this;
        }

        public Builder keplerMag(CelestialObjectParameter keplerMag) {
            this.keplerMag = keplerMag;
            return this;
        }

        public Builder log10Metallicity(
            CelestialObjectParameter log10Metallicity) {
            this.log10Metallicity = log10Metallicity;
            return this;
        }

        public Builder log10SurfaceGravity(
            CelestialObjectParameter log10SurfaceGravity) {
            this.log10SurfaceGravity = log10SurfaceGravity;
            return this;
        }

        public Builder outliers(OutliersTimeSeries outliers) {
            this.outliers = outliers;
            return this;
        }

        public Builder radius(CelestialObjectParameter radius) {
            this.radius = radius;
            return this;
        }

        public Builder raHours(CelestialObjectParameter raHours) {
            this.raHours = raHours;
            return this;
        }

        public Builder rawFluxTimeSeries(
            CompoundFloatTimeSeries rawFluxTimeSeries) {
            this.rawFluxTimeSeries = rawFluxTimeSeries;
            return this;
        }

        public Builder rollingBandContaminations(
            List<RollingBandContamination> rollingBandContaminations) {
            checkNotNull(rollingBandContaminations, "rollingBandContaminations can't be null");
            this.rollingBandContaminations = rollingBandContaminations;
            return this;
        }

        public Builder targetData(List<DvTargetData> targetData) {
            targetDataStruct = targetData;
            return this;
        }

        public Builder thresholdCrossingEvent(
            List<DvThresholdCrossingEvent> thresholdCrossingEvent) {
            this.thresholdCrossingEvent = thresholdCrossingEvent;
            return this;
        }

        public Builder transits(List<DvTransit> transits) {
            this.transits = transits;
            return this;
        }

        public Builder ukirtImageFileName(String ukirtImageFileName) {
            this.ukirtImageFileName = ukirtImageFileName;
            return this;
        }

        public DvTarget build() {
            return new DvTarget(this);
        }
    }
}
