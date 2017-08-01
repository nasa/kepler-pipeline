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

import static gov.nasa.kepler.mc.fs.CalFsIdFactory.MetricsTimeSeriesType.ACHIEVED_COMPRESSION_EFFICIENCY;
import static gov.nasa.kepler.mc.fs.CalFsIdFactory.MetricsTimeSeriesType.ACHIEVED_COMPRESSION_EFFICIENCY_COUNTS;
import static gov.nasa.kepler.mc.fs.CalFsIdFactory.MetricsTimeSeriesType.THEORETICAL_COMPRESSION_EFFICIENCY;
import static gov.nasa.kepler.mc.fs.CalFsIdFactory.MetricsTimeSeriesType.THEORETICAL_COMPRESSION_EFFICIENCY_COUNTS;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Input time series data from CAL needed by PPA:PAG.
 * 
 * @author Bill Wohler
 */
public class PagInputTsData implements Persistable {

    /**
     * The CCD module that this record represents.
     */
    private int ccdModule;

    /**
     * The CCD output that this record represents.
     */
    private int ccdOutput;

    /**
     * Theoretical compression efficiency data from CAL (across entire focal
     * plane).
     */
    private PagCompressionTimeSeries theoreticalCompressionEfficiency = new PagCompressionTimeSeries();

    /**
     * Achieved compression efficiency data from CAL (across entire focal
     * plane).
     */
    private PagCompressionTimeSeries achievedCompressionEfficiency = new PagCompressionTimeSeries();

    /**
     * Creates a {@link PagInputTsData}.
     */
    public PagInputTsData() {
    }

    /**
     * Creates a {@link PagInputTsData} with the given CCD module and output.
     */
    public PagInputTsData(int ccdModule, int ccdOutput) {
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
    }

    /**
     * Returns all {@link FsId}s required to fill the int time series for this
     * object.
     * 
     * @param ccdModule the CCD module
     * @param ccdOutput the CCD output
     * @return a non-{@code null} list of {@link FsId}s
     */
    public static List<FsId> getIntFsIds(int ccdModule, int ccdOutput) {
        List<FsId> fsIds = new ArrayList<FsId>();

        fsIds.add(getTheoreticalCompressionEfficiencyCountsFsId(ccdModule,
            ccdOutput));
        fsIds.add(getAchievedCompressionEfficiencyCountsFsId(ccdModule,
            ccdOutput));

        return fsIds;
    }

    /**
     * Returns all {@link FsId}s required to fill the float time series for this
     * object.
     * 
     * @param ccdModule the CCD module
     * @param ccdOutput the CCD output
     * @return a non-{@code null} list of {@link FsId}s
     */
    public static List<FsId> getFloatFsIds(int ccdModule, int ccdOutput) {
        List<FsId> fsIds = new ArrayList<FsId>();

        fsIds.add(getTheoreticalCompressionEfficiencyFsId(ccdModule, ccdOutput));
        fsIds.add(getAchievedCompressionEfficiencyFsId(ccdModule, ccdOutput));

        return fsIds;
    }

    /**
     * Checks whether the given time series maps contain all the needed time
     * series for the given module and output.
     * 
     * @param ccdModule the CCD module
     * @param ccdOutput the CCD output
     * @param intTimeSeriesByFsId a map of {@link FsId} to {@link IntTimeSeries}
     * @param floatTimeSeriesByFsId a map of {@link FsId} to
     * {@link FloatTimeSeries}
     * 
     * @return {@code true} if all reports are present; otherwise, {@code false}
     */
    public static boolean containsTimeSeries(int ccdModule, int ccdOutput,
        Map<FsId, IntTimeSeries> intTimeSeriesByFsId,
        Map<FsId, FloatTimeSeries> floatTimeSeriesByFsId) {

        if (intTimeSeriesByFsId == null || floatTimeSeriesByFsId == null) {
            return false;
        }

        if (!floatTimeSeriesByFsId.containsKey(getTheoreticalCompressionEfficiencyFsId(
            ccdModule, ccdOutput))) {
            return false;
        }
        if (!intTimeSeriesByFsId.containsKey(getTheoreticalCompressionEfficiencyCountsFsId(
            ccdModule, ccdOutput))) {
            return false;
        }
        if (!floatTimeSeriesByFsId.containsKey(getAchievedCompressionEfficiencyFsId(
            ccdModule, ccdOutput))) {
            return false;
        }
        if (!intTimeSeriesByFsId.containsKey(getAchievedCompressionEfficiencyCountsFsId(
            ccdModule, ccdOutput))) {
            return false;
        }

        return true;
    }

    /**
     * Sets all of the time series in this object.
     * <p>
     * Use {@link #getIntFsIds(int, int)} and {@link #getFloatFsIds(int, int)}
     * to retrieve the fs IDs for your calls to {@code readTimeSeriesAsInt} and
     * {@code readTimeSeriesAsFloat} and then build a couple of maps from fs ID
     * to {@code IntTimeSeries} and {@code FloatTimeSeries} for each time
     * series.
     * 
     * @param intTimeSeriesByFsId a map of {@link FsId} to {@link IntTimeSeries}
     * @param floatTimeSeriesByFsId a map of {@link FsId} to
     * {@link FloatTimeSeries}
     * @throws NullPointerException if {@code timeSeriesByFsId} or
     * {@code timeSeriesByFsId} are {@code null}
     * @throws IllegalStateException if {@code ccdModule} or {@code ccdOutput}
     * have not been set
     */
    public void setTimeSeries(Map<FsId, IntTimeSeries> intTimeSeriesByFsId,
        Map<FsId, FloatTimeSeries> floatTimeSeriesByFsId) {

        if (ccdModule == 0 || ccdOutput == 0) {
            throw new IllegalStateException(
                "ccdModule and ccdOutput have not been set");
        }

        setTheoreticalCompressionEfficiency(PagCompressionTimeSeries.getInstance(
            getTheoreticalCompressionEfficiencyFsId(ccdModule, ccdOutput),
            getTheoreticalCompressionEfficiencyCountsFsId(ccdModule, ccdOutput),
            intTimeSeriesByFsId, floatTimeSeriesByFsId));
        setAchievedCompressionEfficiency(PagCompressionTimeSeries.getInstance(
            getAchievedCompressionEfficiencyFsId(ccdModule, ccdOutput),
            getAchievedCompressionEfficiencyCountsFsId(ccdModule, ccdOutput),
            intTimeSeriesByFsId, floatTimeSeriesByFsId));
    }

    public int getCcdModule() {
        return ccdModule;
    }

    public void setCcdModule(int ccdModule) {
        this.ccdModule = ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public void setCcdOutput(int ccdOutput) {
        this.ccdOutput = ccdOutput;
    }

    private static FsId getTheoreticalCompressionEfficiencyFsId(int ccdModule,
        int ccdOutput) {
        return CalFsIdFactory.getMetricsTimeSeriesFsId(CadenceType.LONG,
            THEORETICAL_COMPRESSION_EFFICIENCY, ccdModule, ccdOutput);
    }

    private static FsId getTheoreticalCompressionEfficiencyCountsFsId(
        int ccdModule, int ccdOutput) {
        return CalFsIdFactory.getMetricsTimeSeriesFsId(CadenceType.LONG,
            THEORETICAL_COMPRESSION_EFFICIENCY_COUNTS, ccdModule, ccdOutput);
    }

    private static FsId getAchievedCompressionEfficiencyFsId(int ccdModule,
        int ccdOutput) {
        return CalFsIdFactory.getMetricsTimeSeriesFsId(CadenceType.LONG,
            ACHIEVED_COMPRESSION_EFFICIENCY, ccdModule, ccdOutput);
    }

    private static FsId getAchievedCompressionEfficiencyCountsFsId(
        int ccdModule, int ccdOutput) {
        return CalFsIdFactory.getMetricsTimeSeriesFsId(CadenceType.LONG,
            ACHIEVED_COMPRESSION_EFFICIENCY_COUNTS, ccdModule, ccdOutput);
    }

    public PagCompressionTimeSeries getTheoreticalCompressionEfficiency() {
        return theoreticalCompressionEfficiency;
    }

    public void setTheoreticalCompressionEfficiency(
        PagCompressionTimeSeries theoreticalCompressionEfficiencies) {
        theoreticalCompressionEfficiency = theoreticalCompressionEfficiencies;
    }

    public PagCompressionTimeSeries getAchievedCompressionEfficiency() {
        return achievedCompressionEfficiency;
    }

    public void setAchievedCompressionEfficiency(
        PagCompressionTimeSeries achievedCompressionEfficiencies) {
        achievedCompressionEfficiency = achievedCompressionEfficiencies;
    }
}
