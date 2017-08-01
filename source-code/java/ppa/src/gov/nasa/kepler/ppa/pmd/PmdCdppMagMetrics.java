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
 * CDPP metrics at a given magnitude for 3, 6, and 12 hours.
 * 
 * @author Bill Wohler
 */
public class PmdCdppMagMetrics implements Persistable {

    private CompoundFloatTimeSeries threeHour = new CompoundFloatTimeSeries();
    private CompoundFloatTimeSeries sixHour = new CompoundFloatTimeSeries();
    private CompoundFloatTimeSeries twelveHour = new CompoundFloatTimeSeries();

    /**
     * Returns all {@link FsId}s required to fill the time series for this
     * object.
     * 
     * @param valuesType the CDPP {@link TimeSeriesType}
     * @param uncertaintiesType the CDPP uncertainties {@link TimeSeriesType}
     * @param ccdModule the CCD module
     * @param ccdOutput the CCD output
     * @param magnitude the magnitude
     * @return a non-{@code null} list of {@link FsId}s
     */
    public static List<FsId> getAllFsIds(TimeSeriesType valuesType,
        TimeSeriesType uncertaintiesType, int ccdModule, int ccdOutput,
        int magnitude) {

        List<FsId> fsIds = new ArrayList<FsId>();

        fsIds.add(getCdppFsId(valuesType, ccdModule, ccdOutput, magnitude, 3));
        fsIds.add(getCdppFsId(uncertaintiesType, ccdModule, ccdOutput,
            magnitude, 3));
        fsIds.add(getCdppFsId(valuesType, ccdModule, ccdOutput, magnitude, 6));
        fsIds.add(getCdppFsId(uncertaintiesType, ccdModule, ccdOutput,
            magnitude, 6));
        fsIds.add(getCdppFsId(valuesType, ccdModule, ccdOutput, magnitude, 12));
        fsIds.add(getCdppFsId(uncertaintiesType, ccdModule, ccdOutput,
            magnitude, 12));

        return fsIds;
    }

    /**
     * Sets all of the time series in this object.
     * <p>
     * Use
     * {@code getAllFsIds(TimeSeriesType, TimeSeriesType, int, int, int, int)}
     * to retrieve the fs IDs for your call to {@code readTimeSeriesAsFloat} and
     * then build a map from fs ID to {@code FloatTimeSeries} for each time
     * series.
     * 
     * @param valuesType the CDPP {@link TimeSeriesType}
     * @param uncertaintiesType the CDPP uncertainties {@link TimeSeriesType}
     * @param ccdModule the CCD module
     * @param ccdOutput the CCD output
     * @param magnitude the magnitude
     * @param timeSeriesByFsId a map of {@link FsId} to {@link FloatTimeSeries}
     */
    public void setAllTimeSeries(TimeSeriesType valuesType,
        TimeSeriesType uncertaintiesType, int ccdModule, int ccdOutput,
        int magnitude, Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        setThreeHour(CompoundTimeSeries.getFloatInstance(
            getCdppFsId(valuesType, ccdModule, ccdOutput, magnitude, 3),
            getCdppFsId(uncertaintiesType, ccdModule, ccdOutput, magnitude, 3),
            timeSeriesByFsId));
        setSixHour(CompoundTimeSeries.getFloatInstance(
            getCdppFsId(valuesType, ccdModule, ccdOutput, magnitude, 6),
            getCdppFsId(uncertaintiesType, ccdModule, ccdOutput, magnitude, 6),
            timeSeriesByFsId));
        setTwelveHour(CompoundTimeSeries.getFloatInstance(
            getCdppFsId(valuesType, ccdModule, ccdOutput, magnitude, 12),
            getCdppFsId(uncertaintiesType, ccdModule, ccdOutput, magnitude, 12),
            timeSeriesByFsId));
    }

    /**
     * Returns a single list of time series for elements of this object. This
     * list can be written to the file store with:
     * {@code FileStoreClientFactory.getInstance().writeTimeSeries(timeSeries.toArray(new FloatTimeSeries[0]));}
     * 
     * @param valuesType the CDPP {@link TimeSeriesType}
     * @param uncertaintiesType the CDPP uncertainties {@link TimeSeriesType}
     * @param ccdModule the CCD module
     * @param ccdOutput the CCD output
     * @param startCadence the starting cadence
     * @param endCadence the end cadence
     * @param producerTaskId the pipeline task ID
     */
    public List<FloatTimeSeries> toTimeSeries(TimeSeriesType valuesType,
        TimeSeriesType uncertaintiesType, int ccdModule, int ccdOutput,
        int startCadence, int endCadence, long producerTaskId, int magnitude) {

        List<FloatTimeSeries> floatTimeSeries = new ArrayList<FloatTimeSeries>();

        floatTimeSeries.addAll(CompoundTimeSeries.toFloatTimeSeries(
            getThreeHour(),
            getCdppFsId(valuesType, ccdModule, ccdOutput, magnitude, 3),
            getCdppFsId(uncertaintiesType, ccdModule, ccdOutput, magnitude, 3),
            startCadence, endCadence, producerTaskId));
        floatTimeSeries.addAll(CompoundTimeSeries.toFloatTimeSeries(
            getSixHour(),
            getCdppFsId(valuesType, ccdModule, ccdOutput, magnitude, 6),
            getCdppFsId(uncertaintiesType, ccdModule, ccdOutput, magnitude, 6),
            startCadence, endCadence, producerTaskId));
        floatTimeSeries.addAll(CompoundTimeSeries.toFloatTimeSeries(
            getTwelveHour(),
            getCdppFsId(valuesType, ccdModule, ccdOutput, magnitude, 12),
            getCdppFsId(uncertaintiesType, ccdModule, ccdOutput, magnitude, 12),
            startCadence, endCadence, producerTaskId));

        return floatTimeSeries;
    }

    private static FsId getCdppFsId(TimeSeriesType type, int ccdModule,
        int ccdOutput, int magnitude, int duration) {
        return PpaFsIdFactory.getTimeSeriesFsId(type, ccdModule, ccdOutput,
            magnitude, duration);
    }

    public CompoundFloatTimeSeries getThreeHour() {
        return threeHour;
    }

    public void setThreeHour(CompoundFloatTimeSeries threeHour) {
        this.threeHour = threeHour;
    }

    public CompoundFloatTimeSeries getSixHour() {
        return sixHour;
    }

    public void setSixHour(CompoundFloatTimeSeries sixHour) {
        this.sixHour = sixHour;
    }

    public CompoundFloatTimeSeries getTwelveHour() {
        return twelveHour;
    }

    public void setTwelveHour(CompoundFloatTimeSeries twelveHour) {
        this.twelveHour = twelveHour;
    }
}
