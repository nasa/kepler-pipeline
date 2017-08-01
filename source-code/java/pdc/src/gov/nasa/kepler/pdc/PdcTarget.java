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
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.mc.Transit;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang.builder.ToStringBuilder;

public class PdcTarget extends CompoundFloatTimeSeries {

    // SOC PDC2.1 inputs: uncertainties in relative flux comes from
    // CompoundFloatTimeSeries.uncertainties.
    // SOC PDC2.6 inputs: gap locations in relative flux comes from
    // CompoundFloatTimeSeries->SimpleFloatTimeSeries.gapIndicators.

    /**
     * The Kepler ID for this target (directly from the KIC).
     */
    private int keplerId;

    /**
     * The magnitude of this target (directly from the KIC)
     */
    private float keplerMag;

    /**
     * The fraction of the flux in the aperture (from TAD). This is used for
     * determining the brightness metric.
     */
    private float fluxFractionInAperture;

    private float crowdingMetric;

    private String[] labels;

    /**
     * KIC parameters for this target.
     */
    private CelestialObjectParameters kic;

    private List<Transit> transits = new ArrayList<Transit>();

    private ApertureMask optimalAperture = new ApertureMask();

    public PdcTarget() {
    }

    public PdcTarget(int keplerId, float stellarMagnitude,
        float fluxFractionInAperture, float crowdingMetric, String[] labels,
        CompoundFloatTimeSeries fluxTimeSeries, CelestialObjectParameters kic,
        List<Transit> transits) {

        super(fluxTimeSeries.getValues(), fluxTimeSeries.getUncertainties(),
            fluxTimeSeries.getGapIndicators());
        this.keplerId = keplerId;
        keplerMag = stellarMagnitude;
        this.fluxFractionInAperture = fluxFractionInAperture;
        this.crowdingMetric = crowdingMetric;
        this.labels = labels;
        this.kic = kic;
        this.transits = transits;
    }

    public static FsId getFsIdForValues(FluxType fluxType,
        CadenceType cadenceType, int keplerId) {
        return PaFsIdFactory.getTimeSeriesFsId(
            PaFsIdFactory.TimeSeriesType.RAW_FLUX, fluxType, cadenceType,
            keplerId);
    }

    public static FsId getFsIdForUncertainties(FluxType fluxType,
        CadenceType cadenceType, int keplerId) {
        return PaFsIdFactory.getTimeSeriesFsId(
            PaFsIdFactory.TimeSeriesType.RAW_FLUX_UNCERTAINTIES, fluxType,
            cadenceType, keplerId);
    }

    public static List<FsId> getFluxFloatTimeSeriesFsIds(FluxType fluxType,
        CadenceType cadenceType, int keplerId) {

        List<FsId> fsIds = newArrayList();
        fsIds.add(getFsIdForValues(fluxType, cadenceType, keplerId));
        fsIds.add(getFsIdForUncertainties(fluxType, cadenceType, keplerId));

        return fsIds;
    }

    public void setTimeSeries(FluxType fluxType, CadenceType cadenceType,
        int length, Map<FsId, TimeSeries> timeSeriesByFsId) {

        TimeSeries values = timeSeriesByFsId.get(getFsIdForValues(fluxType,
            cadenceType, keplerId));
        TimeSeries uncertainties = timeSeriesByFsId.get(getFsIdForUncertainties(
            fluxType, cadenceType, keplerId));
        if (values != null && values.exists() && uncertainties != null
            && uncertainties.exists()) {
            if (!(values instanceof FloatTimeSeries)) {
                throw new IllegalArgumentException(
                    "values must be FloatTimeSeries");
            }
            if (!(uncertainties instanceof FloatTimeSeries)) {
                throw new IllegalArgumentException(
                    "uncertainties must be FloatTimeSeries");
            }
            setValues(((FloatTimeSeries) values).fseries());
            setUncertainties(((FloatTimeSeries) uncertainties).fseries());
            setGapIndicators(values.getGapIndicators());
        } else {
            float[] fseries = new float[length];
            setValues(fseries);
            setUncertainties(fseries);

            boolean[] gapIndicators = new boolean[length];
            Arrays.fill(gapIndicators, true);
            setGapIndicators(gapIndicators);
        }
    }

    public int getKeplerId() {
        return keplerId;
    }

    public void setKeplerId(int keplerId) {
        this.keplerId = keplerId;
    }

    public float getKeplerMag() {
        return keplerMag;
    }

    public void setKeplerMag(float stellarMagnitude) {
        keplerMag = stellarMagnitude;
    }

    public float getFluxFractionInAperture() {
        return fluxFractionInAperture;
    }

    public void setFluxFractionInAperture(float fluxFractionInAperture) {
        this.fluxFractionInAperture = fluxFractionInAperture;
    }

    public float getCrowdingMetric() {
        return crowdingMetric;
    }

    public void setCrowdingMetric(float crowdingMetric) {
        this.crowdingMetric = crowdingMetric;
    }

    public String[] getLabels() {
        return labels;
    }

    public void setLabels(String[] labels) {
        this.labels = labels;
    }

    public CelestialObjectParameters getKic() {
        return kic;
    }

    public void setKic(CelestialObjectParameters kic) {
        this.kic = kic;
    }

    public List<Transit> getTransits() {
        return transits;
    }

    public void setTransits(List<Transit> transits) {
        this.transits = transits;
    }

    public ApertureMask getOptimalAperture() {
        return optimalAperture;
    }

    public void setOptimalAperture(ApertureMask optimalAperture) {
        this.optimalAperture = optimalAperture;
    }

    /**
     * Constructs a {@link String} with all attributes in name = value format.
     * 
     * @return a {@link String} representation of this object.
     */
    @Override
    public String toString() {
        return new ToStringBuilder(this).append("keplerId", keplerId)
            .toString();
    }
}
