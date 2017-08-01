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

import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.mc.CorrectedFluxTimeSeries;
import gov.nasa.kepler.mc.OutliersTimeSeries;
import gov.nasa.kepler.mc.PdcProcessingCharacteristics;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Arrays;
import java.util.List;

import org.apache.commons.lang.ArrayUtils;

public class PdcTargetOutputData implements Persistable {

    /**
     * Kepler target ID
     */
    private int keplerId;

    /**
     * Corrected flux time series.
     */
    private CorrectedFluxTimeSeries correctedFluxTimeSeries;

    /**
     * Outlier values and timestamps.
     */
    private OutliersTimeSeries outliers;

    /**
     * Corrected flux time series with harmonics removed.
     */
    private CorrectedFluxTimeSeries harmonicFreeCorrectedFluxTimeSeries;

    /**
     * Outlier values and timestamps associated with the correct flux time
     * series with harmonics removed.
     */
    private OutliersTimeSeries harmonicFreeOutliers;

    /**
     * Indices of identified discontinuities.
     */
    private int[] discontinuityIndices = ArrayUtils.EMPTY_INT_ARRAY;

    /**
     * PDC processing characteristics.
     */
    private PdcProcessingCharacteristics pdcProcessingStruct;

    /**
     * Metrics concerning the goodness of the MAP processing.
     */
    private PdcGoodnessMetric pdcGoodnessMetric;

    public PdcTargetOutputData() {
    }

    /**
     * Creates a new immutable {@link PdcTargetOutputData} object.
     */
    public PdcTargetOutputData(int keplerId,
        CorrectedFluxTimeSeries correctedFluxTimeSeries,
        OutliersTimeSeries outliers,
        CorrectedFluxTimeSeries harmonicFreeCorrectedFluxTimeSeries,
        OutliersTimeSeries harmonicFreeOutliers, int[] discontinuityIndices,
        PdcProcessingCharacteristics pdcProcessingCharacteristics,
        PdcGoodnessMetric pdcGoodnessMetric) {

        checkNotNull(correctedFluxTimeSeries,
            "correctedFluxTimeSeries can't be null");
        checkNotNull(outliers, "outliers can't be null");
        checkNotNull(harmonicFreeCorrectedFluxTimeSeries,
            "harmonicFreeCorrectedFluxTimeSeries can't be null");
        checkNotNull(harmonicFreeOutliers, "harmonicFreeOutliers can't be null");
        checkNotNull(discontinuityIndices, "discontinuityIndices can't be null");
        checkNotNull(pdcProcessingCharacteristics,
            "pdcProcessingCharacteristics can't be null");
        checkNotNull(pdcGoodnessMetric, "pdcGoodnessMetric can't be null");

        this.keplerId = keplerId;
        this.correctedFluxTimeSeries = correctedFluxTimeSeries;
        this.outliers = outliers;
        this.harmonicFreeCorrectedFluxTimeSeries = harmonicFreeCorrectedFluxTimeSeries;
        this.harmonicFreeOutliers = harmonicFreeOutliers;
        this.discontinuityIndices = discontinuityIndices;
        pdcProcessingStruct = pdcProcessingCharacteristics;
        this.pdcGoodnessMetric = pdcGoodnessMetric;
    }

    /**
     * Returns an {@link IntTimeSeries} representation of the internal
     * discontinuities indices.
     * 
     * @param fsId {@link FsId} of the returned time series
     * @param startCadence absolute start cadence of the returned time series
     * @param endCadence end cadence of the returned time series
     * @param originator originator of the returned time series
     * @return an {@link IntTimeSeries} representation of the discontinuities
     * values for this corrected flux time series where a value of 1 indicates
     * that the corresponding value in the flux time series has a discontinuity.
     * All values in the returned time series are gapped unless they have been
     * identified as a discontinuity.
     */
    public IntTimeSeries toDiscontinuitiesTimeSeries(FsId fsId,
        int startCadence, int endCadence, long originator) {

        int[] discontinuitiesValues = new int[endCadence - startCadence + 1];
        boolean[] discontinuitiesGapIndicators = new boolean[endCadence
            - startCadence + 1];
        Arrays.fill(discontinuitiesGapIndicators, true);
        for (int discontinuityIndice : discontinuityIndices) {
            int discontinuityCadence = discontinuityIndice;
            discontinuitiesValues[discontinuityCadence] = 1;
            discontinuitiesGapIndicators[discontinuityCadence] = false;
        }

        return new IntTimeSeries(fsId, discontinuitiesValues, startCadence,
            endCadence, discontinuitiesGapIndicators, originator);
    }

    /**
     * Sets the {@code filledIndices} field by unpacking the
     * {@link IntTimeSeries} holding the PDC filled indices.
     * 
     * @param discontinuitiesTimeSeries
     */
    public void setDiscontinuityIndices(IntTimeSeries discontinuitiesTimeSeries) {

        checkNotNull(discontinuitiesTimeSeries,
            "discontinuitiesTimeSeries can't be null");
        int[] discontinuitiesTimeSeriesValues = discontinuitiesTimeSeries.iseries();

        List<Integer> discontinuitiesCadences = newArrayList();
        for (int cadence = 0; cadence < discontinuitiesTimeSeriesValues.length; cadence++) {
            if (discontinuitiesTimeSeriesValues[cadence] == 1) {
                discontinuitiesCadences.add(cadence);
            }
        }
        discontinuityIndices = discontinuitiesCadences.size() == 0 ? ArrayUtils.EMPTY_INT_ARRAY
            : new int[discontinuitiesCadences.size()];
        int i = 0;
        for (int cadence : discontinuitiesCadences) {
            discontinuityIndices[i++] = cadence;
        }
    }

    public int getKeplerId() {
        return keplerId;
    }

    public CorrectedFluxTimeSeries getCorrectedFluxTimeSeries() {
        return correctedFluxTimeSeries;
    }

    public OutliersTimeSeries getOutliers() {
        return outliers;
    }

    public CorrectedFluxTimeSeries getHarmonicFreeCorrectedFluxTimeSeries() {
        return harmonicFreeCorrectedFluxTimeSeries;
    }

    public OutliersTimeSeries getHarmonicFreeOutliers() {
        return harmonicFreeOutliers;
    }

    public int[] getDiscontinuityIndices() {
        return discontinuityIndices;
    }

    public PdcProcessingCharacteristics getPdcProcessingCharacteristics() {
        return pdcProcessingStruct;
    }

    public PdcGoodnessMetric getPdcGoodnessMetric() {
        return pdcGoodnessMetric;
    }
}
