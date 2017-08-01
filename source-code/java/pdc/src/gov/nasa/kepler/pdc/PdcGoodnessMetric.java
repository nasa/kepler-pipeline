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

package gov.nasa.kepler.pdc;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcGoodnessComponentType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcGoodnessMetricType;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Arrays;
import java.util.List;

/**
 * The goodness metric.
 * 
 * @author Forrest Girouard
 * 
 */
public class PdcGoodnessMetric implements Persistable {

    private PdcGoodnessComponent correlation;
    private PdcGoodnessComponent deltaVariability;
    private PdcGoodnessComponent earthPointRemoval;
    private PdcGoodnessComponent introducedNoise;
    private PdcGoodnessComponent total;

    public PdcGoodnessMetric() {
    }

    /**
     * Creates a new immutable {@link PdcGoodnessMetric} object.
     */
    public PdcGoodnessMetric(PdcGoodnessComponent correlation,
        PdcGoodnessComponent deltaVariability,
        PdcGoodnessComponent earthPointRemoval,
        PdcGoodnessComponent introducedNoise, PdcGoodnessComponent total) {

        this.correlation = correlation;
        this.deltaVariability = deltaVariability;
        this.earthPointRemoval = earthPointRemoval;
        this.introducedNoise = introducedNoise;
        this.total = total;
    }

    public static List<FsId> getAllFsIds(FluxType fluxType,
        CadenceType cadenceType, int keplerId) {

        List<FsId> fsIds = newArrayList();
        fsIds.add(PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.CORRELATION, PdcGoodnessComponentType.VALUE,
            fluxType, cadenceType, keplerId));
        fsIds.add(PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.CORRELATION,
            PdcGoodnessComponentType.PERCENTILE, fluxType, cadenceType,
            keplerId));
        fsIds.add(PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.DELTA_VARIABILITY,
            PdcGoodnessComponentType.VALUE, fluxType, cadenceType, keplerId));
        fsIds.add(PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.DELTA_VARIABILITY,
            PdcGoodnessComponentType.PERCENTILE, fluxType, cadenceType,
            keplerId));
        fsIds.add(PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.EARTH_POINT_REMOVAL,
            PdcGoodnessComponentType.VALUE, fluxType, cadenceType, keplerId));
        fsIds.add(PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.EARTH_POINT_REMOVAL,
            PdcGoodnessComponentType.PERCENTILE, fluxType, cadenceType,
            keplerId));
        fsIds.add(PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.INTRODUCED_NOISE,
            PdcGoodnessComponentType.VALUE, fluxType, cadenceType, keplerId));
        fsIds.add(PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.INTRODUCED_NOISE,
            PdcGoodnessComponentType.PERCENTILE, fluxType, cadenceType,
            keplerId));
        fsIds.add(PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.TOTAL, PdcGoodnessComponentType.VALUE,
            fluxType, cadenceType, keplerId));
        fsIds.add(PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.TOTAL, PdcGoodnessComponentType.PERCENTILE,
            fluxType, cadenceType, keplerId));

        return fsIds;
    }

    public List<FloatTimeSeries> toTimeSeries(FluxType fluxType,
        CadenceType cadenceType, int startCadence, int endCadence,
        int keplerId, boolean[] gapIndicators, long originator) {

        List<FloatTimeSeries> floatTimeSeriesList = newArrayList();
        float[] fseries = new float[endCadence - startCadence + 1];
        boolean[] fullyGapped = new boolean[endCadence - startCadence + 1];

        Arrays.fill(fullyGapped, true);

        Arrays.fill(fseries, correlation.getValue());
        FsId fsId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.CORRELATION, PdcGoodnessComponentType.VALUE,
            fluxType, cadenceType, keplerId);
        floatTimeSeriesList.add(new FloatTimeSeries(fsId, fseries,
            startCadence, endCadence,
            Float.isNaN(correlation.getValue()) ? fullyGapped : gapIndicators,
            originator));

        fseries = new float[endCadence - startCadence + 1];
        Arrays.fill(fseries, correlation.getPercentile());
        fsId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.CORRELATION,
            PdcGoodnessComponentType.PERCENTILE, fluxType, cadenceType,
            keplerId);
        floatTimeSeriesList.add(new FloatTimeSeries(fsId, fseries,
            startCadence, endCadence,
            Float.isNaN(correlation.getPercentile()) ? fullyGapped
                : gapIndicators, originator));

        fseries = new float[endCadence - startCadence + 1];
        Arrays.fill(fseries, deltaVariability.getValue());
        fsId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.DELTA_VARIABILITY,
            PdcGoodnessComponentType.VALUE, fluxType, cadenceType, keplerId);
        floatTimeSeriesList.add(new FloatTimeSeries(fsId, fseries,
            startCadence, endCadence,
            Float.isNaN(deltaVariability.getValue()) ? fullyGapped
                : gapIndicators, originator));

        fseries = new float[endCadence - startCadence + 1];
        Arrays.fill(fseries, deltaVariability.getPercentile());
        fsId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.DELTA_VARIABILITY,
            PdcGoodnessComponentType.PERCENTILE, fluxType, cadenceType,
            keplerId);
        floatTimeSeriesList.add(new FloatTimeSeries(fsId, fseries,
            startCadence, endCadence,
            Float.isNaN(deltaVariability.getPercentile()) ? fullyGapped
                : gapIndicators, originator));

        fseries = new float[endCadence - startCadence + 1];
        Arrays.fill(fseries, earthPointRemoval.getValue());
        fsId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.EARTH_POINT_REMOVAL,
            PdcGoodnessComponentType.VALUE, fluxType, cadenceType, keplerId);
        floatTimeSeriesList.add(new FloatTimeSeries(fsId, fseries,
            startCadence, endCadence,
            Float.isNaN(earthPointRemoval.getValue()) ? fullyGapped
                : gapIndicators, originator));

        fseries = new float[endCadence - startCadence + 1];
        Arrays.fill(fseries, earthPointRemoval.getPercentile());
        fsId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.EARTH_POINT_REMOVAL,
            PdcGoodnessComponentType.PERCENTILE, fluxType, cadenceType,
            keplerId);
        floatTimeSeriesList.add(new FloatTimeSeries(fsId, fseries,
            startCadence, endCadence,
            Float.isNaN(earthPointRemoval.getPercentile()) ? fullyGapped
                : gapIndicators, originator));

        fseries = new float[endCadence - startCadence + 1];
        Arrays.fill(fseries, introducedNoise.getValue());
        fsId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.INTRODUCED_NOISE,
            PdcGoodnessComponentType.VALUE, fluxType, cadenceType, keplerId);
        floatTimeSeriesList.add(new FloatTimeSeries(fsId, fseries,
            startCadence, endCadence,
            Float.isNaN(introducedNoise.getValue()) ? fullyGapped
                : gapIndicators, originator));

        fseries = new float[endCadence - startCadence + 1];
        Arrays.fill(fseries, introducedNoise.getPercentile());
        fsId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.INTRODUCED_NOISE,
            PdcGoodnessComponentType.PERCENTILE, fluxType, cadenceType,
            keplerId);
        floatTimeSeriesList.add(new FloatTimeSeries(fsId, fseries,
            startCadence, endCadence,
            Float.isNaN(introducedNoise.getPercentile()) ? fullyGapped
                : gapIndicators, originator));

        fseries = new float[endCadence - startCadence + 1];
        Arrays.fill(fseries, total.getValue());
        fsId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.TOTAL, PdcGoodnessComponentType.VALUE,
            fluxType, cadenceType, keplerId);
        floatTimeSeriesList.add(new FloatTimeSeries(fsId, fseries,
            startCadence, endCadence,
            Float.isNaN(total.getValue()) ? fullyGapped : gapIndicators,
            originator));

        fseries = new float[endCadence - startCadence + 1];
        Arrays.fill(fseries, total.getPercentile());
        fsId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.TOTAL, PdcGoodnessComponentType.PERCENTILE,
            fluxType, cadenceType, keplerId);
        floatTimeSeriesList.add(new FloatTimeSeries(fsId, fseries,
            startCadence, endCadence,
            Float.isNaN(total.getPercentile()) ? fullyGapped : gapIndicators,
            originator));

        return floatTimeSeriesList;
    }

    public PdcGoodnessComponent getCorrelation() {
        return correlation;
    }

    public PdcGoodnessComponent getDeltaVariability() {
        return deltaVariability;
    }

    public PdcGoodnessComponent getEarthPointRemoval() {
        return earthPointRemoval;
    }

    public PdcGoodnessComponent getIntroducedNoise() {
        return introducedNoise;
    }

    public PdcGoodnessComponent getTotal() {
        return total;
    }
}
