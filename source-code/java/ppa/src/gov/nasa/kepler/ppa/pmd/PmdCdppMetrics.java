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
import gov.nasa.kepler.mc.fs.PpaFsIdFactory.TimeSeriesType;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * A CDPP metrics class spanning magnitudes 9 through 15.
 * 
 * @author Bill Wohler
 */
public class PmdCdppMetrics implements Persistable {

    private PmdCdppMagMetrics mag9 = new PmdCdppMagMetrics();
    private PmdCdppMagMetrics mag10 = new PmdCdppMagMetrics();
    private PmdCdppMagMetrics mag11 = new PmdCdppMagMetrics();
    private PmdCdppMagMetrics mag12 = new PmdCdppMagMetrics();
    private PmdCdppMagMetrics mag13 = new PmdCdppMagMetrics();
    private PmdCdppMagMetrics mag14 = new PmdCdppMagMetrics();
    private PmdCdppMagMetrics mag15 = new PmdCdppMagMetrics();

    /**
     * Returns all {@link FsId}s required to fill the time series for this
     * object.
     * 
     * @param valuesType the CDPP {@link TimeSeriesType}
     * @param uncertaintiesType the CDPP uncertainties {@link TimeSeriesType}
     * @param ccdModule the CCD module
     * @param ccdOutput the CCD output
     * @return a non-{@code null} list of {@link FsId}s
     */
    public static List<FsId> getAllFsIds(TimeSeriesType valuesType,
        TimeSeriesType uncertaintiesType, int ccdModule, int ccdOutput) {

        List<FsId> fsIds = new ArrayList<FsId>();

        fsIds.addAll(PmdCdppMagMetrics.getAllFsIds(valuesType,
            uncertaintiesType, ccdModule, ccdOutput, 9));
        fsIds.addAll(PmdCdppMagMetrics.getAllFsIds(valuesType,
            uncertaintiesType, ccdModule, ccdOutput, 10));
        fsIds.addAll(PmdCdppMagMetrics.getAllFsIds(valuesType,
            uncertaintiesType, ccdModule, ccdOutput, 11));
        fsIds.addAll(PmdCdppMagMetrics.getAllFsIds(valuesType,
            uncertaintiesType, ccdModule, ccdOutput, 12));
        fsIds.addAll(PmdCdppMagMetrics.getAllFsIds(valuesType,
            uncertaintiesType, ccdModule, ccdOutput, 13));
        fsIds.addAll(PmdCdppMagMetrics.getAllFsIds(valuesType,
            uncertaintiesType, ccdModule, ccdOutput, 14));
        fsIds.addAll(PmdCdppMagMetrics.getAllFsIds(valuesType,
            uncertaintiesType, ccdModule, ccdOutput, 15));

        return fsIds;
    }

    /**
     * Sets all of the time series in this object.
     * <p>
     * Use {@code getAllFsIds(TimeSeriesType, TimeSeriesType, int, int, int)} to
     * retrieve the fs IDs for your call to {@code readTimeSeriesAsFloat} and
     * then build a map from fs ID to {@code FloatTimeSeries} for each time
     * series.
     * 
     * @param valuesType the CDPP {@link TimeSeriesType}
     * @param uncertaintiesType the CDPP uncertainties {@link TimeSeriesType}
     * @param ccdModule the CCD module
     * @param ccdOutput the CCD output
     * @param timeSeriesByFsId a map of {@link FsId} to {@link FloatTimeSeries}
     */
    public void setAllTimeSeries(TimeSeriesType valuesType,
        TimeSeriesType uncertaintiesType, int ccdModule, int ccdOutput,
        Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        setMag9(createCdppMagMetrics(valuesType, uncertaintiesType, ccdModule,
            ccdOutput, 9, timeSeriesByFsId));
        setMag10(createCdppMagMetrics(valuesType, uncertaintiesType, ccdModule,
            ccdOutput, 10, timeSeriesByFsId));
        setMag11(createCdppMagMetrics(valuesType, uncertaintiesType, ccdModule,
            ccdOutput, 11, timeSeriesByFsId));
        setMag12(createCdppMagMetrics(valuesType, uncertaintiesType, ccdModule,
            ccdOutput, 12, timeSeriesByFsId));
        setMag13(createCdppMagMetrics(valuesType, uncertaintiesType, ccdModule,
            ccdOutput, 13, timeSeriesByFsId));
        setMag14(createCdppMagMetrics(valuesType, uncertaintiesType, ccdModule,
            ccdOutput, 14, timeSeriesByFsId));
        setMag15(createCdppMagMetrics(valuesType, uncertaintiesType, ccdModule,
            ccdOutput, 15, timeSeriesByFsId));
    }

    private PmdCdppMagMetrics createCdppMagMetrics(TimeSeriesType valuesType,
        TimeSeriesType uncertaintiesType, int ccdModule, int ccdOutput,
        int magnitude, Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        PmdCdppMagMetrics cdppMagMetrics = new PmdCdppMagMetrics();
        cdppMagMetrics.setAllTimeSeries(valuesType, uncertaintiesType,
            ccdModule, ccdOutput, magnitude, timeSeriesByFsId);

        return cdppMagMetrics;
    }

    /**
     * Returns a single list of time series for elements of this object. This
     * list can be written to the filestore with:
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
        int startCadence, int endCadence, long producerTaskId) {

        List<FloatTimeSeries> floatTimeSeries = new ArrayList<FloatTimeSeries>();

        floatTimeSeries.addAll(getMag9().toTimeSeries(valuesType,
            uncertaintiesType, ccdModule, ccdOutput, startCadence, endCadence,
            producerTaskId, 9));
        floatTimeSeries.addAll(getMag10().toTimeSeries(valuesType,
            uncertaintiesType, ccdModule, ccdOutput, startCadence, endCadence,
            producerTaskId, 10));
        floatTimeSeries.addAll(getMag11().toTimeSeries(valuesType,
            uncertaintiesType, ccdModule, ccdOutput, startCadence, endCadence,
            producerTaskId, 11));
        floatTimeSeries.addAll(getMag12().toTimeSeries(valuesType,
            uncertaintiesType, ccdModule, ccdOutput, startCadence, endCadence,
            producerTaskId, 12));
        floatTimeSeries.addAll(getMag13().toTimeSeries(valuesType,
            uncertaintiesType, ccdModule, ccdOutput, startCadence, endCadence,
            producerTaskId, 13));
        floatTimeSeries.addAll(getMag14().toTimeSeries(valuesType,
            uncertaintiesType, ccdModule, ccdOutput, startCadence, endCadence,
            producerTaskId, 14));
        floatTimeSeries.addAll(getMag15().toTimeSeries(valuesType,
            uncertaintiesType, ccdModule, ccdOutput, startCadence, endCadence,
            producerTaskId, 15));

        return floatTimeSeries;
    }

    public PmdCdppMagMetrics getMag9() {
        return mag9;
    }

    public void setMag9(PmdCdppMagMetrics mag9) {
        this.mag9 = mag9;
    }

    public PmdCdppMagMetrics getMag10() {
        return mag10;
    }

    public void setMag10(PmdCdppMagMetrics mag10) {
        this.mag10 = mag10;
    }

    public PmdCdppMagMetrics getMag11() {
        return mag11;
    }

    public void setMag11(PmdCdppMagMetrics mag11) {
        this.mag11 = mag11;
    }

    public PmdCdppMagMetrics getMag12() {
        return mag12;
    }

    public void setMag12(PmdCdppMagMetrics mag12) {
        this.mag12 = mag12;
    }

    public PmdCdppMagMetrics getMag13() {
        return mag13;
    }

    public void setMag13(PmdCdppMagMetrics mag13) {
        this.mag13 = mag13;
    }

    public PmdCdppMagMetrics getMag14() {
        return mag14;
    }

    public void setMag14(PmdCdppMagMetrics mag14) {
        this.mag14 = mag14;
    }

    public PmdCdppMagMetrics getMag15() {
        return mag15;
    }

    public void setMag15(PmdCdppMagMetrics mag15) {
        this.mag15 = mag15;
    }
}
