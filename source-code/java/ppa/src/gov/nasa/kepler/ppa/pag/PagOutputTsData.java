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

package gov.nasa.kepler.ppa.pag;

import static gov.nasa.kepler.mc.fs.PpaFsIdFactory.TimeSeriesType.ACHIEVED_COMPRESSION_EFFICIENCY;
import static gov.nasa.kepler.mc.fs.PpaFsIdFactory.TimeSeriesType.THEORETICAL_COMPRESSION_EFFICIENCY;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.SimpleTimeSeries;
import gov.nasa.kepler.mc.fs.PpaFsIdFactory;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Output time series data.
 * 
 * @author Bill Wohler
 */
public class PagOutputTsData implements Persistable {

    /**
     * Theoretical compression efficiency data (across entire focal plane).
     */
    private SimpleFloatTimeSeries theoreticalCompressionEfficiency = new SimpleFloatTimeSeries();

    /**
     * Achieved compression efficiency data (across entire focal plane).
     */
    private SimpleFloatTimeSeries achievedCompressionEfficiency = new SimpleFloatTimeSeries();

    /**
     * Returns all {@link FsId}s required to fill the time series for this
     * object.
     * 
     * @return a non-{@code null} list of {@link FsId}s
     */
    public static List<FsId> getAllFsIds() {
        List<FsId> fsIds = new ArrayList<FsId>();

        fsIds.add(getTheoreticalCompressionEfficiencyFsId());
        fsIds.add(getAchievedCompressionEfficiencyFsId());

        return fsIds;
    }

    /**
     * Sets all of the time series in this object.
     * <p>
     * Use {@link #getAllFsIds()} to retrieve the fs IDs for your call to
     * {@code readTimeSeriesAsFloat} and then build a map from fs ID to
     * {@code FloatTimeSeries} for each time series.
     * 
     * @param timeSeriesByFsId a map of {@link FsId} to {@link FloatTimeSeries}
     */
    public void setAllTimeSeries(Map<FsId, FloatTimeSeries> timeSeriesByFsId) {
        setTheoreticalCompressionEfficiency(SimpleTimeSeries.getFloatInstance(
            getTheoreticalCompressionEfficiencyFsId(), timeSeriesByFsId));
        setAchievedCompressionEfficiency(SimpleTimeSeries.getFloatInstance(
            getAchievedCompressionEfficiencyFsId(), timeSeriesByFsId));
    }

    /**
     * Returns a single list of time series for elements of this object. This
     * list can be written to the file store with:
     * {@code FileStoreClientFactory.getInstance().writeTimeSeries(timeSeries.toArray(new FloatTimeSeries[0]));}
     * 
     * @param startCadence the starting cadence
     * @param endCadence the end cadence
     * @param producerTaskId the pipeline task ID
     */
    public List<FloatTimeSeries> toTimeSeries(int startCadence, int endCadence,
        long producerTaskId) {

        List<FloatTimeSeries> floatTimeSeries = new ArrayList<FloatTimeSeries>();

        floatTimeSeries.add(SimpleTimeSeries.toFloatTimeSeries(
            getTheoreticalCompressionEfficiency(),
            getTheoreticalCompressionEfficiencyFsId(), startCadence,
            endCadence, producerTaskId));
        floatTimeSeries.add(SimpleTimeSeries.toFloatTimeSeries(
            getAchievedCompressionEfficiency(),
            getAchievedCompressionEfficiencyFsId(), startCadence, endCadence,
            producerTaskId));

        return floatTimeSeries;
    }

    private static FsId getTheoreticalCompressionEfficiencyFsId() {
        return PpaFsIdFactory.getTimeSeriesFsId(THEORETICAL_COMPRESSION_EFFICIENCY);
    }

    private static FsId getAchievedCompressionEfficiencyFsId() {
        return PpaFsIdFactory.getTimeSeriesFsId(ACHIEVED_COMPRESSION_EFFICIENCY);
    }

    public SimpleFloatTimeSeries getTheoreticalCompressionEfficiency() {
        return theoreticalCompressionEfficiency;
    }

    public void setTheoreticalCompressionEfficiency(
        SimpleFloatTimeSeries theoreticalCompressionEfficiency) {
        this.theoreticalCompressionEfficiency = theoreticalCompressionEfficiency;
    }

    public SimpleFloatTimeSeries getAchievedCompressionEfficiency() {
        return achievedCompressionEfficiency;
    }

    public void setAchievedCompressionEfficiency(
        SimpleFloatTimeSeries achievedCompressionEfficiency) {
        this.achievedCompressionEfficiency = achievedCompressionEfficiency;
    }
}
