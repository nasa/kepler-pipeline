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

package gov.nasa.kepler.mc;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFilledIndicesTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFluxTimeSeriesType;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * A {@link CompoundFloatTimeSeries} with an additional {@code filledIndices}
 * field.
 * 
 * @author Forrest Girouard
 * @author Jay Gunter
 * @author Bill Wohler
 */
public class CorrectedFluxTimeSeries extends CompoundFloatTimeSeries {

    /**
     * Indices of filled flux values.
     */
    private int[] filledIndices = ArrayUtils.EMPTY_INT_ARRAY;

    /**
     * A {@link List} of {@link FsId}s used to populate and/or persist the float
     * contents of an instance of this class.
     * 
     * @param fluxType the {@link FluxType} of interest.
     * @param keplerId corresponding target's Kepler ID.
     * @return a {@link List} of {@link FsId}s.
     */
    public static List<FsId> getAllFloatFsIds(FluxType fluxType,
        CadenceType cadenceType, int keplerId) {

        List<FsId> fsIds = new ArrayList<FsId>(4);
        fsIds.add(PdcFsIdFactory.getFluxTimeSeriesFsId(
            PdcFluxTimeSeriesType.CORRECTED_FLUX, fluxType, cadenceType,
            keplerId));
        fsIds.add(PdcFsIdFactory.getFluxTimeSeriesFsId(
            PdcFluxTimeSeriesType.CORRECTED_FLUX_UNCERTAINTIES, fluxType,
            cadenceType, keplerId));
        fsIds.add(PdcFsIdFactory.getFluxTimeSeriesFsId(
            PdcFluxTimeSeriesType.HARMONIC_FREE_CORRECTED_FLUX, fluxType,
            cadenceType, keplerId));
        fsIds.add(PdcFsIdFactory.getFluxTimeSeriesFsId(
            PdcFluxTimeSeriesType.HARMONIC_FREE_CORRECTED_FLUX_UNCERTAINTIES,
            fluxType, cadenceType, keplerId));
        return fsIds;
    }

    /**
     * A {@link List} of {@link FsId}s used to populate and/or persist the
     * integer contents of an instance of this class.
     * 
     * @param fluxType the {@link FluxType} of interest.
     * @param keplerId corresponding target's Kepler ID.
     * @return a {@link List} of {@link FsId}s.
     */
    public static List<FsId> getAllIntFsIds(FluxType fluxType,
        CadenceType cadenceType, int keplerId) {

        List<FsId> fsIds = new ArrayList<FsId>(3);
        fsIds.add(PdcFsIdFactory.getFilledIndicesFsId(
            PdcFilledIndicesTimeSeriesType.FILLED_INDICES, fluxType,
            cadenceType, keplerId));
        fsIds.add(PdcFsIdFactory.getFilledIndicesFsId(
            PdcFilledIndicesTimeSeriesType.HARMONIC_FREE_FILLED_INDICES,
            fluxType, cadenceType, keplerId));
        fsIds.add(PdcFsIdFactory.getDiscontinuityIndicesFsId(fluxType,
            cadenceType, keplerId));
        return fsIds;
    }

    public CorrectedFluxTimeSeries() {
    }

    public CorrectedFluxTimeSeries(int length) {
        super(length);
    }

    /**
     * Creates a {@link CorrectFluxTimeSeries} object.
     * 
     * @param values the {@link FloatTimeSeries} from which to extract the
     * values and gap indicators.
     * @param uncertainties the {@link FloatTimeSeries} from which to extract
     * the uncertainties.
     * @param filled the {@link IntTimeSeries} from which to extract the filled
     * indices.
     */
    public CorrectedFluxTimeSeries(FloatTimeSeries values,
        FloatTimeSeries uncertainties, IntTimeSeries filled) {

        super(values.fseries(), uncertainties.fseries(),
            values.getGapIndicators());

        setFilledIndices(filled);
    }

    public int[] getFilledIndices() {
        return filledIndices;
    }

    public void setFilledIndices(int[] filledIndices) {

        if (filledIndices == null) {
            throw new NullPointerException("filledIndices can't be null");
        }
        this.filledIndices = filledIndices;
    }

    /**
     * Creates a {@link CorrectedFluxTimeSeries} object.
     * 
     * @param fluxType the {@link FluxType} of interest
     * @param keplerId corresponding target's Kepler ID
     * @param timeSeriesByFsId a map of {@link FsId}s to {@link TimeSeries} from
     * which to extract the values and uncertainties time series
     * @return a {@link CorrectedFluxTimeSeries}, which will contain arrays of
     * size 0 if any of {@code valuesFsId}, {@code uncertaintiesFsId}, or
     * {@code filledIndicesFsId} was not found in the map, or arrays of the
     * proper size but where the gap indicators are all {@code true} if the time
     * series is empty
     * @throws NullPointerException if any of the arguments are {@code null}
     */
    public static CorrectedFluxTimeSeries getInstance(
        PdcFluxTimeSeriesType valuesType,
        PdcFluxTimeSeriesType uncertaintiesType,
        PdcFilledIndicesTimeSeriesType filledIndicesType, FluxType fluxType,
        CadenceType cadenceType, int length, int keplerId,
        Map<FsId, ? extends TimeSeries> timeSeriesByFsId) {

        if (fluxType == null) {
            throw new NullPointerException("fluxType can't be null");
        }
        if (cadenceType == null) {
            throw new NullPointerException("cadenceType can't be null");
        }
        if (timeSeriesByFsId == null) {
            throw new NullPointerException("timeSeriesByFsId can't be null");
        }

        return getInstance(PdcFsIdFactory.getFluxTimeSeriesFsId(valuesType,
            fluxType, cadenceType, keplerId),
            PdcFsIdFactory.getFluxTimeSeriesFsId(uncertaintiesType, fluxType,
                cadenceType, keplerId), PdcFsIdFactory.getFilledIndicesFsId(
                filledIndicesType, fluxType, cadenceType, keplerId), length,
            timeSeriesByFsId);
    }

    /**
     * Creates a {@link CorrectedFluxTimeSeries} object.
     * 
     * @param valuesFsId the {@code FsId} for the values
     * @param uncertaintiesFsId the {@code FsId} for the uncertainties
     * @param filledIndicesFsId the {@code FsId} for the filled indices
     * @param timeSeriesByFsId a map of {@link FsId}s to {@link TimeSeries} from
     * which to extract the values and uncertainties time series
     * @return a {@link CorrectedFluxTimeSeries}, which will contain arrays of
     * size 0 if any of {@code valuesFsId}, {@code uncertaintiesFsId}, or
     * {@code filledIndicesFsId} was not found in the map, or arrays of the
     * proper size but where the gap indicators are all {@code true} if the time
     * series is empty
     * @throws NullPointerException if any of the arguments are {@code null}
     */
    public static CorrectedFluxTimeSeries getInstance(FsId valuesFsId,
        FsId uncertaintiesFsId, FsId filledIndicesFsId, int length,
        Map<FsId, ? extends TimeSeries> timeSeriesByFsId) {

        if (valuesFsId == null) {
            throw new NullPointerException("valuesFsId can't be null");
        }
        if (uncertaintiesFsId == null) {
            throw new NullPointerException("uncertaintiesFsId can't be null");
        }
        if (filledIndicesFsId == null) {
            throw new NullPointerException("filledIndicesFsId can't be null");
        }
        if (timeSeriesByFsId == null) {
            throw new NullPointerException("timeSeriesByFsId can't be null");
        }

        FloatTimeSeries values = (FloatTimeSeries) timeSeriesByFsId.get(valuesFsId);
        FloatTimeSeries uncertainties = (FloatTimeSeries) timeSeriesByFsId.get(uncertaintiesFsId);
        IntTimeSeries filled = (IntTimeSeries) timeSeriesByFsId.get(filledIndicesFsId);
        if (values != null && uncertainties != null) {
            return new CorrectedFluxTimeSeries(values, uncertainties, filled);
        }

        return new CorrectedFluxTimeSeries(length);
    }

    /**
     * Sets the {@code filledIndices} field by unpacking the
     * {@link IntTimeSeries} holding the PDC filled indices.
     * 
     * @param filledTimeSeries
     */
    private void setFilledIndices(IntTimeSeries filledTimeSeries) {

        if (filledTimeSeries == null) {
            throw new NullPointerException("filledTimeSeries can't be null");
        }
        int[] filledTimeSeriesValues = filledTimeSeries.iseries();

        List<Integer> filledCadences = new ArrayList<Integer>();
        for (int cadence = 0; cadence < filledTimeSeriesValues.length; cadence++) {
            if (filledTimeSeriesValues[cadence] == 1) {
                filledCadences.add(cadence);
            }
        }
        filledIndices = filledCadences.size() == 0 ? ArrayUtils.EMPTY_INT_ARRAY
            : new int[filledCadences.size()];
        int i = 0;
        for (int cadence : filledCadences) {
            filledIndices[i++] = cadence;
        }
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = super.hashCode();
        result = prime * result + Arrays.hashCode(filledIndices);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!super.equals(obj)) {
            return false;
        }
        if (!(obj instanceof CorrectedFluxTimeSeries)) {
            return false;
        }
        CorrectedFluxTimeSeries other = (CorrectedFluxTimeSeries) obj;
        if (!Arrays.equals(filledIndices, other.filledIndices)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).appendSuper(super.toString())
            .append("filledIndices.length", filledIndices.length)
            .toString();
    }

    /**
     * Returns an {@link IntTimeSeries} representation of the internal filled
     * indices.
     * 
     * @param valuesFsId the {@link FsId} for the values field
     * @param uncertaintiesFsId the {@link FsId} for the uncertainties field
     * @param filledIndicesFsId the {@link FsId} for the filledIndices field
     * @param startCadence absolute start cadence of the returned time series
     * @param endCadence end cadence of the returned time series
     * @param originator originator of the returned time series
     * @return an {@link IntTimeSeries} representation of the filled values for
     * this corrected flux time series where a value of 1 indicates that the
     * corresponding value in the flux time series has been filled. All values
     * in the returned time series are gapped unless they have been filled.
     */
    public List<TimeSeries> toTimeSeries(FsId valuesFsId,
        FsId uncertaintiesFsId, FsId filledIndicesFsId, int startCadence,
        int endCadence, long originator) {

        List<TimeSeries> timeSeries = new ArrayList<TimeSeries>();

        timeSeries.addAll(CompoundTimeSeries.toFloatTimeSeries(valuesFsId, uncertaintiesFsId,
            getValues(), getUncertainties(), getGapIndicators(), startCadence, endCadence, originator));
        timeSeries.add(toFilledTimeSeries(filledIndicesFsId, startCadence,
            endCadence, originator));

        return timeSeries;
    }

    /**
     * Returns an {@link IntTimeSeries} representation of the internal filled
     * indices.
     * 
     * @param fsId {@link FsId} of the returned time series
     * @param startCadence absolute start cadence of the returned time series
     * @param endCadence end cadence of the returned time series
     * @param originator originator of the returned time series
     * @return an {@link IntTimeSeries} representation of the filled values for
     * this corrected flux time series where a value of 1 indicates that the
     * corresponding value in the flux time series has been filled. All values
     * in the returned time series are gapped unless they have been filled.
     */
    public IntTimeSeries toFilledTimeSeries(FsId fsId, int startCadence,
        int endCadence, long originator) {

        int[] filledValues = new int[endCadence - startCadence + 1];
        boolean[] filledGapIndicators = new boolean[endCadence - startCadence
            + 1];
        Arrays.fill(filledGapIndicators, true);
        for (int filledIndice : filledIndices) {
            int filledCadence = filledIndice;
            filledValues[filledCadence] = 1;
            filledGapIndicators[filledCadence] = false;
        }

        return new IntTimeSeries(fsId, filledValues, startCadence, endCadence,
            filledGapIndicators, originator);
    }
}
