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

import static gov.nasa.kepler.mc.fs.PpaFsIdFactory.TimeSeriesType.CDPP_EXPECTED_UNCERTAINTIES;
import static gov.nasa.kepler.mc.fs.PpaFsIdFactory.TimeSeriesType.CDPP_EXPECTED_VALUES;
import static gov.nasa.kepler.mc.fs.PpaFsIdFactory.TimeSeriesType.CDPP_MEASURED_UNCERTAINTIES;
import static gov.nasa.kepler.mc.fs.PpaFsIdFactory.TimeSeriesType.CDPP_MEASURED_VALUES;
import static gov.nasa.kepler.mc.fs.PpaFsIdFactory.TimeSeriesType.CDPP_RATIO_UNCERTAINTIES;
import static gov.nasa.kepler.mc.fs.PpaFsIdFactory.TimeSeriesType.CDPP_RATIO_VALUES;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.CompoundTimeSeries;
import gov.nasa.kepler.mc.fs.PpaFsIdFactory;
import gov.nasa.kepler.mc.fs.PpaFsIdFactory.TimeSeriesType;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Output time series data.
 * 
 * @author Bill Wohler
 */
public class PmdOutputTsData implements Persistable {

    private CompoundFloatTimeSeries backgroundLevel = new CompoundFloatTimeSeries();
    private CompoundFloatTimeSeries centroidsMeanRow = new CompoundFloatTimeSeries();
    private CompoundFloatTimeSeries centroidsMeanColumn = new CompoundFloatTimeSeries();
    private CompoundFloatTimeSeries plateScale = new CompoundFloatTimeSeries();

    private PmdCdppMetrics cdppExpected = new PmdCdppMetrics();
    private PmdCdppMetrics cdppMeasured = new PmdCdppMetrics();
    private PmdCdppMetrics cdppRatio = new PmdCdppMetrics();

    /**
     * Returns all {@link FsId}s required to fill the time series for this
     * object.
     * 
     * @param ccdModule the CCD module
     * @param ccdOutput the CCD output
     * 
     * @return a non-{@code null} list of {@link FsId}s
     */
    public static List<FsId> getAllFsIds(int ccdModule, int ccdOutput) {

        List<FsId> fsIds = new ArrayList<FsId>();

        fsIds.add(getBackgroundLevelFsId(ccdModule, ccdOutput));
        fsIds.add(getBackgroundLevelUncertaintiesFsId(ccdModule, ccdOutput));
        fsIds.add(getCentroidsMeanRowFsId(ccdModule, ccdOutput));
        fsIds.add(getCentroidsMeanRowUncertaintiesFsId(ccdModule, ccdOutput));
        fsIds.add(getCentroidsMeanColumnFsId(ccdModule, ccdOutput));
        fsIds.add(getCentroidsMeanColumnUncertaintiesFsId(ccdModule, ccdOutput));
        fsIds.add(getPlateScaleFsId(ccdModule, ccdOutput));
        fsIds.add(getPlateScaleUncertaintiesFsId(ccdModule, ccdOutput));

        fsIds.addAll(PmdCdppMetrics.getAllFsIds(CDPP_EXPECTED_VALUES,
            CDPP_EXPECTED_UNCERTAINTIES, ccdModule, ccdOutput));
        fsIds.addAll(PmdCdppMetrics.getAllFsIds(CDPP_MEASURED_VALUES,
            CDPP_MEASURED_UNCERTAINTIES, ccdModule, ccdOutput));
        fsIds.addAll(PmdCdppMetrics.getAllFsIds(CDPP_RATIO_VALUES,
            CDPP_RATIO_UNCERTAINTIES, ccdModule, ccdOutput));

        return fsIds;
    }

    /**
     * Sets all of the time series in this object.
     * <p>
     * Use {@link #getAllFsIds(int, int)} to retrieve the fs IDs for your call
     * to {@code readTimeSeriesAsFloat} and then build a map from fs ID to
     * {@code FloatTimeSeries} for each time series.
     * 
     * @param ccdModule the CCD module
     * @param ccdOutput the CCD output
     * @param timeSeriesByFsId a map of {@link FsId} to {@link FloatTimeSeries}
     */
    public void setAllTimeSeries(int ccdModule, int ccdOutput,
        Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        setBackgroundLevel(CompoundTimeSeries.getFloatInstance(
            getBackgroundLevelFsId(ccdModule, ccdOutput),
            getBackgroundLevelUncertaintiesFsId(ccdModule, ccdOutput),
            timeSeriesByFsId));
        setCentroidsMeanRow(CompoundTimeSeries.getFloatInstance(
            getCentroidsMeanRowFsId(ccdModule, ccdOutput),
            getCentroidsMeanRowUncertaintiesFsId(ccdModule, ccdOutput),
            timeSeriesByFsId));
        setCentroidsMeanColumn(CompoundTimeSeries.getFloatInstance(
            getCentroidsMeanColumnFsId(ccdModule, ccdOutput),
            getCentroidsMeanColumnUncertaintiesFsId(ccdModule, ccdOutput),
            timeSeriesByFsId));
        setPlateScale(CompoundTimeSeries.getFloatInstance(
            getPlateScaleFsId(ccdModule, ccdOutput),
            getPlateScaleUncertaintiesFsId(ccdModule, ccdOutput),
            timeSeriesByFsId));

        setCdppExpected(createCdppMetrics(CDPP_EXPECTED_VALUES,
            CDPP_EXPECTED_UNCERTAINTIES, ccdModule, ccdOutput, timeSeriesByFsId));
        setCdppMeasured(createCdppMetrics(CDPP_MEASURED_VALUES,
            CDPP_MEASURED_UNCERTAINTIES, ccdModule, ccdOutput, timeSeriesByFsId));
        setCdppRatio(createCdppMetrics(CDPP_RATIO_VALUES,
            CDPP_RATIO_UNCERTAINTIES, ccdModule, ccdOutput, timeSeriesByFsId));
    }

    /**
     * Returns a single list of time series for elements of this object. This
     * list can be written to the file store with:
     * {@code FileStoreClientFactory.getInstance().writeTimeSeries(timeSeries.toArray(new FloatTimeSeries[0]));}
     * 
     * @param ccdModule the CCD module
     * @param ccdOutput the CCD output
     * @param startCadence the starting cadence
     * @param endCadence the end cadence
     * @param producerTaskId the pipeline task ID
     */
    public List<FloatTimeSeries> toTimeSeries(int ccdModule, int ccdOutput,
        int startCadence, int endCadence, long producerTaskId) {

        List<FloatTimeSeries> floatTimeSeries = new ArrayList<FloatTimeSeries>();

        floatTimeSeries.addAll(CompoundTimeSeries.toFloatTimeSeries(
            getBackgroundLevel(), getBackgroundLevelFsId(ccdModule, ccdOutput),
            getBackgroundLevelUncertaintiesFsId(ccdModule, ccdOutput),
            startCadence, endCadence, producerTaskId));
        floatTimeSeries.addAll(CompoundTimeSeries.toFloatTimeSeries(
            getCentroidsMeanRow(),
            getCentroidsMeanRowFsId(ccdModule, ccdOutput),
            getCentroidsMeanRowUncertaintiesFsId(ccdModule, ccdOutput),
            startCadence, endCadence, producerTaskId));
        floatTimeSeries.addAll(CompoundTimeSeries.toFloatTimeSeries(
            getCentroidsMeanColumn(),
            getCentroidsMeanColumnFsId(ccdModule, ccdOutput),
            getCentroidsMeanColumnUncertaintiesFsId(ccdModule, ccdOutput),
            startCadence, endCadence, producerTaskId));
        floatTimeSeries.addAll(CompoundTimeSeries.toFloatTimeSeries(
            getPlateScale(), getPlateScaleFsId(ccdModule, ccdOutput),
            getPlateScaleUncertaintiesFsId(ccdModule, ccdOutput), startCadence,
            endCadence, producerTaskId));

        floatTimeSeries.addAll(getCdppExpected().toTimeSeries(
            CDPP_EXPECTED_VALUES, CDPP_EXPECTED_UNCERTAINTIES, ccdModule,
            ccdOutput, startCadence, endCadence, producerTaskId));
        floatTimeSeries.addAll(getCdppMeasured().toTimeSeries(
            CDPP_MEASURED_VALUES, CDPP_MEASURED_UNCERTAINTIES, ccdModule,
            ccdOutput, startCadence, endCadence, producerTaskId));
        floatTimeSeries.addAll(getCdppRatio().toTimeSeries(CDPP_RATIO_VALUES,
            CDPP_RATIO_UNCERTAINTIES, ccdModule, ccdOutput, startCadence,
            endCadence, producerTaskId));

        return floatTimeSeries;
    }

    private PmdCdppMetrics createCdppMetrics(TimeSeriesType valuesType,
        TimeSeriesType uncertaintiesType, int ccdModule, int ccdOutput,
        Map<FsId, FloatTimeSeries> timeSeriesByFsId) {
        PmdCdppMetrics cdppMetrics = new PmdCdppMetrics();
        cdppMetrics.setAllTimeSeries(valuesType, uncertaintiesType, ccdModule,
            ccdOutput, timeSeriesByFsId);
        return cdppMetrics;
    }

    private static FsId getBackgroundLevelFsId(int ccdModule, int ccdOutput) {
        return PpaFsIdFactory.getTimeSeriesFsId(
            TimeSeriesType.BACKGROUND_LEVEL, ccdModule, ccdOutput);
    }

    private static FsId getBackgroundLevelUncertaintiesFsId(int ccdModule,
        int ccdOutput) {
        return PpaFsIdFactory.getTimeSeriesFsId(
            TimeSeriesType.BACKGROUND_LEVEL_UNCERTAINTIES, ccdModule, ccdOutput);
    }

    private static FsId getCentroidsMeanRowFsId(int ccdModule, int ccdOutput) {
        return PpaFsIdFactory.getTimeSeriesFsId(
            TimeSeriesType.CENTROIDS_MEAN_ROW, ccdModule, ccdOutput);
    }

    private static FsId getCentroidsMeanRowUncertaintiesFsId(int ccdModule,
        int ccdOutput) {
        return PpaFsIdFactory.getTimeSeriesFsId(
            TimeSeriesType.CENTROIDS_MEAN_ROW_UNCERTAINTIES, ccdModule,
            ccdOutput);
    }

    private static FsId getCentroidsMeanColumnFsId(int ccdModule, int ccdOutput) {
        return PpaFsIdFactory.getTimeSeriesFsId(
            TimeSeriesType.CENTROIDS_MEAN_COLUMN, ccdModule, ccdOutput);
    }

    private static FsId getCentroidsMeanColumnUncertaintiesFsId(int ccdModule,
        int ccdOutput) {
        return PpaFsIdFactory.getTimeSeriesFsId(
            TimeSeriesType.CENTROIDS_MEAN_COLUMN_UNCERTAINTIES, ccdModule,
            ccdOutput);
    }

    private static FsId getPlateScaleFsId(int ccdModule, int ccdOutput) {
        return PpaFsIdFactory.getTimeSeriesFsId(TimeSeriesType.PLATE_SCALE,
            ccdModule, ccdOutput);
    }

    private static FsId getPlateScaleUncertaintiesFsId(int ccdModule,
        int ccdOutput) {
        return PpaFsIdFactory.getTimeSeriesFsId(
            TimeSeriesType.PLATE_SCALE_UNCERTAINTIES, ccdModule, ccdOutput);
    }

    public CompoundFloatTimeSeries getBackgroundLevel() {
        return backgroundLevel;
    }

    public void setBackgroundLevel(CompoundFloatTimeSeries backgroundLevel) {
        this.backgroundLevel = backgroundLevel;
    }

    public CompoundFloatTimeSeries getCentroidsMeanRow() {
        return centroidsMeanRow;
    }

    public void setCentroidsMeanRow(CompoundFloatTimeSeries centroidsMeanRow) {
        this.centroidsMeanRow = centroidsMeanRow;
    }

    public CompoundFloatTimeSeries getCentroidsMeanColumn() {
        return centroidsMeanColumn;
    }

    public void setCentroidsMeanColumn(
        CompoundFloatTimeSeries centroidsMeanColumn) {
        this.centroidsMeanColumn = centroidsMeanColumn;
    }

    public CompoundFloatTimeSeries getPlateScale() {
        return plateScale;
    }

    public void setPlateScale(CompoundFloatTimeSeries plateScale) {
        this.plateScale = plateScale;
    }

    public PmdCdppMetrics getCdppExpected() {
        return cdppExpected;
    }

    public void setCdppExpected(PmdCdppMetrics cdppExpected) {
        this.cdppExpected = cdppExpected;
    }

    public PmdCdppMetrics getCdppMeasured() {
        return cdppMeasured;
    }

    public void setCdppMeasured(PmdCdppMetrics cdppMeasured) {
        this.cdppMeasured = cdppMeasured;
    }

    public PmdCdppMetrics getCdppRatio() {
        return cdppRatio;
    }

    public void setCdppRatio(PmdCdppMetrics cdppMetrics) {
        cdppRatio = cdppMetrics;
    }
}
