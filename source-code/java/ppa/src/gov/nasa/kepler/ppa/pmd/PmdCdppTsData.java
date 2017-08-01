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

package gov.nasa.kepler.ppa.pmd;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.common.pi.TpsType;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.mc.CorrectedFluxTimeSeries;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.fs.TpsFsIdFactory;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFilledIndicesTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFluxTimeSeriesType;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * Combined Differential Photometric Precision time series data.
 * <p>
 * The fields like {@code cddp3Hr} may cover data from T0 to Tcurrent and
 * therefore require the flexibility to cross target table boundaries.
 * 
 * @author Bill Wohler
 */
public class PmdCdppTsData implements Persistable {
    private int keplerId;
    private float keplerMag;
    private float effectiveTemp;
    private float log10SurfaceGravity;

    /**
     * Measured CDPP for three-hour transit (from TPS).
     */
    private float[] cdpp3Hr = ArrayUtils.EMPTY_FLOAT_ARRAY;

    /**
     * Measured CDPP for six-hour transit (from TPS).
     */
    private float[] cdpp6Hr = ArrayUtils.EMPTY_FLOAT_ARRAY;

    /**
     * Measured CDPP for 12-hour transit (from TPS).
     */
    private float[] cdpp12Hr = ArrayUtils.EMPTY_FLOAT_ARRAY;

    /**
     * Flux time series from PDC.
     */
    private CorrectedFluxTimeSeries fluxTimeSeries = new CorrectedFluxTimeSeries();

    /**
     * Call {@link #PmdCdppTsData(int, float)}. This constructor is for use by
     * the serializer only.
     * 
     * @deprecated Use {@link #PmdCdppTsData(int, float, float, float)}
     */
    @Deprecated
    public PmdCdppTsData() {
    }

    /**
     * Creates a {@link PmdCdppTsData} with the given Kepler ID and magnitude.
     * 
     * @param keplerId the Kepler ID
     * @param keplerMag the Kepler magnitude
     * @param effectiveTemp the effective temperature
     * @param log10SurfaceGravity the log10 surface gravity
     */
    public PmdCdppTsData(int keplerId, float keplerMag, float effectiveTemp,
        float log10SurfaceGravity) {
        this.keplerId = keplerId;
        this.keplerMag = keplerMag;
        this.effectiveTemp = effectiveTemp;
        this.log10SurfaceGravity = log10SurfaceGravity;
    }

    /**
     * Returns all {@link FsId}s required to fill the time series for this
     * object.
     * 
     * @param keplerId the kepler ID
     * @param fluxType a valid {@link FluxType}
     * 
     * @return a non-{@code null} list of {@link FsId}s
     * @throws IllegalArgumentException if {@code fluxType} is {@code null}
     */
    public static List<FsId> getFsIds(long tpsPipelineInstanceId, int keplerId, FluxType fluxType,
        TpsType tpsType) {

        List<FsId> fsIds = new ArrayList<FsId>();

        fsIds.add(getCdppFsId(tpsPipelineInstanceId, keplerId, 3.0F, fluxType, tpsType));
        fsIds.add(getCdppFsId(tpsPipelineInstanceId, keplerId, 6.0F, fluxType, tpsType));
        fsIds.add(getCdppFsId(tpsPipelineInstanceId, keplerId, 12.0F, fluxType, tpsType));

        fsIds.addAll(CorrectedFluxTimeSeries.getAllFloatFsIds(fluxType,
            CadenceType.LONG, keplerId));

        return fsIds;
    }

    /**
     * Returns all {@link FsId}s required to fill the MJD time series for this
     * object.
     * 
     * @param keplerId the kepler ID
     * @param fluxType a valid {@link FluxType}
     * 
     * @return a non-{@code null} list of {@link FsId}s
     * @throws IllegalArgumentException if {@code fluxType} is {@code null}
     */
    public static List<FsId> getIntFsIds(int keplerId, FluxType fluxType) {

        return CorrectedFluxTimeSeries.getAllIntFsIds(fluxType,
            CadenceType.LONG, keplerId);
    }

    public static boolean containsTimeSeries(long tpsPipelineInstanceId, int keplerId, FluxType fluxType,
        TpsType tpsType, Map<FsId, TimeSeries> timeSeriesByFsId) {

        if (timeSeriesByFsId == null) {
            return false;
        }

        if (!timeSeriesByFsId.containsKey(getCdppFsId(tpsPipelineInstanceId, keplerId, 3.0F, fluxType,
            tpsType))) {
            return false;
        }
        if (!timeSeriesByFsId.containsKey(getCdppFsId(tpsPipelineInstanceId, keplerId, 6.0F, fluxType,
            tpsType))) {
            return false;
        }
        if (!timeSeriesByFsId.containsKey(getCdppFsId(tpsPipelineInstanceId, keplerId, 12.0F,
            fluxType, tpsType))) {
            return false;
        }
        List<FsId> fsIds = CorrectedFluxTimeSeries.getAllFloatFsIds(fluxType,
            CadenceType.LONG, keplerId);
        for (FsId fsId : fsIds) {
            if (!timeSeriesByFsId.containsKey(fsId)) {
                return false;
            }
        }
        fsIds = CorrectedFluxTimeSeries.getAllIntFsIds(fluxType,
            CadenceType.LONG, keplerId);
        for (FsId fsId : fsIds) {
            if (!timeSeriesByFsId.containsKey(fsId)) {
                return false;
            }
        }

        return true;
    }

    /**
     * Sets all of the time series in this object. The method
     * {@link #setKeplerId(int)} (or appropriate constructor) must have been
     * called prior to this call.
     * <p>
     * Use {@code getFsIds(FluxType, int, int)} to retrieve the fs IDs for your
     * call to {@code readTimeSeriesAsFloat} and then build a map from fs ID to
     * {@code FloatTimeSeries} for each time series.
     * <p>
     * Use {@code getMjdFsIds(FluxType, int, int)} to retrieve the fs IDs for
     * your call to {@code readMjdTimeSeriesAsFloat} TODO and then build a map
     * from fs ID to {@code FloatMjdTimeSeries} for each time series.
     * 
     * @param mjdToCadence an {@link MjdToCadence} object
     * @param fluxType a valid {@link FluxType}
     * @param startCadence the starting cadence
     * @param timeSeriesByFsId a map of {@link FsId} to {@link FloatTimeSeries}
     * @param mjdTimeSeriesByFsId a map of {@link FsId} to
     * {@link FloatMjdTimeSeries}
     * 
     * @throws IllegalStateException if the Kepler ID has not been set
     * @throws IllegalArgumentException if {@code fluxType} is {@code null}
     * @throws NullPointerException if {@code timeSeriesByFsId} is {@code null}
     */
    public void setTimeSeries(long tpsPipelineInstanceId, FluxType fluxType, TpsType tpsType,
        int startCadence, int length,
        Map<FsId, ? extends TimeSeries> timeSeriesByFsId) {

        if (keplerId == 0) {
            throw new IllegalStateException("Kepler ID has not been set");
        }

        setCdpp3Hr(((FloatTimeSeries) timeSeriesByFsId.get(getCdppFsId(tpsPipelineInstanceId, 
            keplerId, 3.0F, fluxType, tpsType))).fseries());
        setCdpp6Hr(((FloatTimeSeries) timeSeriesByFsId.get(getCdppFsId(tpsPipelineInstanceId, 
            keplerId, 6.0F, fluxType, tpsType))).fseries());
        setCdpp12Hr(((FloatTimeSeries) timeSeriesByFsId.get(getCdppFsId(tpsPipelineInstanceId,
            keplerId, 12.0F, fluxType, tpsType))).fseries());

        setFluxTimeSeries(CorrectedFluxTimeSeries.getInstance(
            PdcFluxTimeSeriesType.CORRECTED_FLUX,
            PdcFluxTimeSeriesType.CORRECTED_FLUX_UNCERTAINTIES,
            PdcFilledIndicesTimeSeriesType.FILLED_INDICES, fluxType,
            CadenceType.LONG, length, keplerId, timeSeriesByFsId));
    }

    private static FsId getCdppFsId(long tpsPipelineInstanceId, int keplerId, float duration,
        FluxType fluxType, TpsType tpsType) {
        return TpsFsIdFactory.getCdppId(tpsPipelineInstanceId, keplerId, duration, tpsType, fluxType);
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

    public void setKeplerMag(float keplerMag) {
        this.keplerMag = keplerMag;
    }

    public float getEffectiveTemp() {
        return effectiveTemp;
    }

    public void setEffectiveTemp(float effectiveTemp) {
        this.effectiveTemp = effectiveTemp;
    }

    public float getLog10SurfaceGravity() {
        return log10SurfaceGravity;
    }

    public void setLog10SurfaceGravity(float log10SurfaceGravity) {
        this.log10SurfaceGravity = log10SurfaceGravity;
    }

    public float[] getCdpp3Hr() {
        return cdpp3Hr;
    }

    public void setCdpp3Hr(float[] cdpp3Hr) {
        this.cdpp3Hr = cdpp3Hr;
    }

    public float[] getCdpp6Hr() {
        return cdpp6Hr;
    }

    public void setCdpp6Hr(float[] cdpp6Hr) {
        this.cdpp6Hr = cdpp6Hr;
    }

    public float[] getCdpp12Hr() {
        return cdpp12Hr;
    }

    public void setCdpp12Hr(float[] cdpp12Hr) {
        this.cdpp12Hr = cdpp12Hr;
    }

    public CorrectedFluxTimeSeries getFluxTimeSeries() {
        return fluxTimeSeries;
    }

    public void setFluxTimeSeries(CorrectedFluxTimeSeries fluxTimeSeries) {
        this.fluxTimeSeries = fluxTimeSeries;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("keplerId", keplerId)
            .append("keplerMag", keplerMag)
            .append("cdpp3Hr.length", cdpp3Hr.length)
            .append("cdpp6Hr.length", cdpp6Hr.length)
            .append("cdpp12Hr.length", cdpp12Hr.length)
            .append("fluxTimeSeries", fluxTimeSeries)
            .toString();
    }
}
