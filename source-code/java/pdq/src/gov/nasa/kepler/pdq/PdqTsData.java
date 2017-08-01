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

package gov.nasa.kepler.pdq;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.pdq.PdqDbTimeSeries;
import gov.nasa.kepler.hibernate.pdq.PdqDbTimeSeriesCrud;
import gov.nasa.kepler.hibernate.pdq.PdqDoubleTimeSeriesType;
import gov.nasa.kepler.mc.TimeSeriesOperations;
import gov.nasa.kepler.mc.fs.PdqFsIdFactory;
import gov.nasa.kepler.mc.fs.PdqFsIdFactory.TimeSeriesType;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * All the metric time series produced by the PDQ pipeline module for a single
 * target table. Instances of this class are used in both the PDQ MI inputs and
 * outputs.
 * 
 * @author Forrest Girouard
 * 
 */
public class PdqTsData implements Persistable {

    /**
     * For convenience a set containing all the time series types that are
     * calculated on a per CCD module output basis.
     */
    @ProxyIgnore
    private static final Set<TimeSeriesType> perModuleOutputTimeSeriesTypes = new HashSet<TimeSeriesType>();

    /**
     * For convenience a set containing all the time series types that are
     * calculated once per reference pixel file.
     */
    @ProxyIgnore
    private static final Set<TimeSeriesType> timeSeriesTypes = new HashSet<TimeSeriesType>();

    static {
        perModuleOutputTimeSeriesTypes.add(TimeSeriesType.BACKGROUND_LEVELS);
        perModuleOutputTimeSeriesTypes.add(TimeSeriesType.BLACK_LEVELS);
        perModuleOutputTimeSeriesTypes.add(TimeSeriesType.CENTROIDS_MEAN_COLS);
        perModuleOutputTimeSeriesTypes.add(TimeSeriesType.CENTROIDS_MEAN_ROWS);
        perModuleOutputTimeSeriesTypes.add(TimeSeriesType.DARK_CURRENTS);
        perModuleOutputTimeSeriesTypes.add(TimeSeriesType.DYNAMIC_RANGES);
        perModuleOutputTimeSeriesTypes.add(TimeSeriesType.ENCIRCLED_ENERGIES);
        perModuleOutputTimeSeriesTypes.add(TimeSeriesType.MEAN_FLUXES);
        perModuleOutputTimeSeriesTypes.add(TimeSeriesType.PLATE_SCALES);
        perModuleOutputTimeSeriesTypes.add(TimeSeriesType.SMEAR_LEVELS);

        timeSeriesTypes.add(TimeSeriesType.MAX_ATTITUDE_RESIDUAL_IN_PIXELS);
    }

    /**
     * The number of distinct time series types for each module output.
     */
    @ProxyIgnore
    public static final int PDQ_MODOUT_TIMESERIES_TYPES = perModuleOutputTimeSeriesTypes.size();

    /**
     * The number of distinct time series types per target table (does not
     * include time series types that for which distinct values exist per module
     * output).
     */
    @ProxyIgnore
    public static final int PDQ_NONMODULEOUT_TIMESERIES_TYPES = timeSeriesTypes.size();

    /**
     * All the per module output time series.
     */
    private List<PdqModuleOutputTsData> pdqModuleOutputTsData = new ArrayList<PdqModuleOutputTsData>(
        FcConstants.MODULE_OUTPUTS);

    /**
     * The time in MJD of the reference pixel file from which each value in the
     * contained time seres was calculated.
     */
    private double[] cadenceTimes = new double[0];

    private PdqDoubleTimeSeries attitudeSolutionRa = new PdqDoubleTimeSeries();
    private PdqDoubleTimeSeries attitudeSolutionDec = new PdqDoubleTimeSeries();
    private PdqDoubleTimeSeries attitudeSolutionRoll = new PdqDoubleTimeSeries();
    private PdqDoubleTimeSeries deltaAttitudeRa = new PdqDoubleTimeSeries();
    private PdqDoubleTimeSeries deltaAttitudeDec = new PdqDoubleTimeSeries();
    private PdqDoubleTimeSeries deltaAttitudeRoll = new PdqDoubleTimeSeries();
    private PdqDoubleTimeSeries desiredAttitudeRa = new PdqDoubleTimeSeries();
    private PdqDoubleTimeSeries desiredAttitudeDec = new PdqDoubleTimeSeries();
    private PdqDoubleTimeSeries desiredAttitudeRoll = new PdqDoubleTimeSeries();

    private CompoundFloatTimeSeries maxAttitudeResidualInPixels = new CompoundFloatTimeSeries();

    public PdqTsData() {
    }

    /**
     * Constructor that populates the contents with the current data from the
     * file store and updates the specified set of task ids.
     * 
     * @param targetTableId
     * @param producerTaskIds
     * @throws PipelineException
     */
    public PdqTsData(PdqDbTimeSeriesCrud dbTimeSeriesCrud, int targetTableId,
        Set<Long> producerTaskIds, double[] cadenceTimes) {

        this.cadenceTimes = Arrays.copyOf(cadenceTimes, cadenceTimes.length);
        if (cadenceTimes.length > 0) {
            FsId[] fsIds = PdqTsData.getAllTimeSeriesFsIds(targetTableId);
            FileStoreClient fsClient = FileStoreClientFactory.getInstance();
            FloatTimeSeries[] timeSeriesArray = fsClient.readTimeSeriesAsFloat(
                fsIds, 0, cadenceTimes.length - 1, false);
            TimeSeriesOperations.addToDataAccountability(timeSeriesArray,
                producerTaskIds);
            Map<FsId, FloatTimeSeries> timeSeriesByFsId = TimeSeriesOperations.getFloatTimeSeriesByFsId(timeSeriesArray);
            setAllFloatTimeSeries(targetTableId, timeSeriesByFsId);

            Map<PdqDoubleTimeSeriesType, PdqDbTimeSeries> dbTimeSeriesMap = new HashMap<PdqDoubleTimeSeriesType, PdqDbTimeSeries>();
            for (PdqDoubleTimeSeriesType timeSeriesType : PdqDoubleTimeSeriesType.values()) {
                PdqDbTimeSeries dbTimeSeries = dbTimeSeriesCrud.retrieve(
                    targetTableId, 0, cadenceTimes.length - 1, timeSeriesType);
                addToDataAccountability(dbTimeSeries, producerTaskIds);
                dbTimeSeriesMap.put(timeSeriesType, dbTimeSeries);
            }
            setAllDoubleTimeSeries(dbTimeSeriesMap);
        }
    }

    private static void addToDataAccountability(PdqDbTimeSeries dbTimeSeries,
        Set<Long> producerTaskIds) {

        for (long originator : dbTimeSeries.getOriginators()) {
            producerTaskIds.add(originator);
        }
    }

    public List<FloatTimeSeries> getAllFloatTimeSeries(int targetTableId,
        long pipelineTaskId, int minEndCadence) {

        List<FloatTimeSeries> timeSeries = new ArrayList<FloatTimeSeries>();
        timeSeries.addAll(getAllModuleOutputTimeSeries(targetTableId,
            pipelineTaskId, minEndCadence));
        timeSeries.addAll(getMaxAttitudeResidualInPixels(targetTableId,
            pipelineTaskId, minEndCadence));
        return timeSeries;
    }

    public List<PdqDbTimeSeries> getAllDbTimeSeries(int targetTableId,
        long pipelineTaskId, int minEndCadence) {

        List<PdqDbTimeSeries> dbTimeSeries = new ArrayList<PdqDbTimeSeries>();
        dbTimeSeries.addAll(getAttitudeSolutionDec(targetTableId,
            pipelineTaskId, minEndCadence));
        dbTimeSeries.addAll(getAttitudeSolutionRa(targetTableId,
            pipelineTaskId, minEndCadence));
        dbTimeSeries.addAll(getAttitudeSolutionRoll(targetTableId,
            pipelineTaskId, minEndCadence));
        dbTimeSeries.addAll(getDeltaAttitudeDec(targetTableId, pipelineTaskId,
            minEndCadence));
        dbTimeSeries.addAll(getDeltaAttitudeRa(targetTableId, pipelineTaskId,
            minEndCadence));
        dbTimeSeries.addAll(getDeltaAttitudeRoll(targetTableId, pipelineTaskId,
            minEndCadence));
        dbTimeSeries.addAll(getDesiredAttitudeDec(targetTableId,
            pipelineTaskId, minEndCadence));
        dbTimeSeries.addAll(getDesiredAttitudeRa(targetTableId, pipelineTaskId,
            minEndCadence));
        dbTimeSeries.addAll(getDesiredAttitudeRoll(targetTableId,
            pipelineTaskId, minEndCadence));
        return dbTimeSeries;
    }

    public void writeTimeSeries(int targetTableId, long pipelineTaskId,
        int minEndCadence) {

        List<FloatTimeSeries> timeSeries = getAllFloatTimeSeries(targetTableId,
            pipelineTaskId, minEndCadence);
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        fsClient.writeTimeSeries(timeSeries.toArray(new FloatTimeSeries[0]));
    }

    public void createDbTimeSeries(PdqDbTimeSeriesCrud dbTimeSeriesCrud,
        int targetTableId, long pipelineTaskId, int minEndCadence) {

        List<PdqDbTimeSeries> dbTimeSeriesList = getAllDbTimeSeries(
            targetTableId, pipelineTaskId, minEndCadence);
        dbTimeSeriesCrud.create(dbTimeSeriesList);
    }

    /**
     * Returns a list of all the time series identifiers for the given target
     * table and module output.
     * 
     * @param targetTableId
     * @param ccdModule
     * @param ccdOutput
     * @return array of time series identifiers
     */
    public static List<FsId> getModuleOutputTimeSeriesFsIds(
        final int targetTableId, final int ccdModule, final int ccdOutput) {

        List<FsId> fsIds = new ArrayList<FsId>();
        for (TimeSeriesType type : perModuleOutputTimeSeriesTypes) {
            FsId fsId = PdqFsIdFactory.getPdqTimeSeriesFsId(type,
                targetTableId, ccdModule, ccdOutput);
            fsIds.add(fsId);
            fsId = PdqFsIdFactory.getPdqUncertaintiesFsId(type, targetTableId,
                ccdModule, ccdOutput);
            fsIds.add(fsId);
        }
        return fsIds;
    }

    /**
     * Returns a list of all the focal plane time series identifiers for the
     * given target table.
     * 
     * @param targetTableId
     * @return array of time series identifiers
     */
    public static List<FsId> getFocalPlaneTimeSeriesFsIds(
        final int targetTableId) {

        List<FsId> fsIds = new ArrayList<FsId>();
        for (TimeSeriesType type : timeSeriesTypes) {
            FsId fsId = PdqFsIdFactory.getPdqTimeSeriesFsId(type, targetTableId);
            fsIds.add(fsId);
            fsId = PdqFsIdFactory.getPdqUncertaintiesFsId(type, targetTableId);
            fsIds.add(fsId);
        }
        return fsIds;
    }

    /**
     * Returns a list of all the time series identifiers for the given target
     * table.
     * 
     * @param targetTableId
     * @return array of time series identifiers
     */
    public static FsId[] getAllTimeSeriesFsIds(final int targetTableId) {

        List<FsId> fsIds = new ArrayList<FsId>();
        for (int channelNumber = 1; channelNumber <= FcConstants.MODULE_OUTPUTS; channelNumber++) {
            Pair<Integer, Integer> moduleOutput = FcConstants.getModuleOutput(channelNumber);
            fsIds.addAll(getModuleOutputTimeSeriesFsIds(targetTableId,
                moduleOutput.left, moduleOutput.right));
        }
        fsIds.addAll(getFocalPlaneTimeSeriesFsIds(targetTableId));
        return fsIds.toArray(new FsId[0]);
    }

    /**
     * Returns a list of all the time series identifiers for the given target
     * table and module outputs.
     * 
     * @param targetTableId
     * @param moduleOutputs
     * @return array of time series identifiers
     */
    public static FsId[] getAllTimeSeriesFsIds(final int targetTableId,
        final List<Integer> moduleOutputs) {

        List<FsId> fsIds = new ArrayList<FsId>();
        for (int channelNumber : moduleOutputs) {
            Pair<Integer, Integer> moduleOutput = FcConstants.getModuleOutput(channelNumber);
            fsIds.addAll(getModuleOutputTimeSeriesFsIds(targetTableId,
                moduleOutput.left, moduleOutput.right));
        }
        fsIds.addAll(getFocalPlaneTimeSeriesFsIds(targetTableId));
        return fsIds.toArray(new FsId[0]);
    }

    /**
     * Sets the contents of the time series whose identifiers are present as
     * keys in the given map.
     * 
     * @param targetTableId
     * @param timeSeriesByFsId
     */
    private void setAllFloatTimeSeries(final int targetTableId,
        final Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        for (int module : FcConstants.modulesList) {
            for (int output : FcConstants.outputsList) {
                PdqModuleOutputTsData tsData = new PdqModuleOutputTsData(
                    module, output, targetTableId, timeSeriesByFsId);
                if (!tsData.isEmpty()) {
                    pdqModuleOutputTsData.add(tsData);
                }
            }
        }
        setMaxAttitudeResidualInPixels(targetTableId, timeSeriesByFsId);
    }

    private void setAllDoubleTimeSeries(
        Map<PdqDoubleTimeSeriesType, PdqDbTimeSeries> dbTimeSeriesByType) {

        setAttitudeSolutionDec(dbTimeSeriesByType);
        setAttitudeSolutionRa(dbTimeSeriesByType);
        setAttitudeSolutionRoll(dbTimeSeriesByType);
        setDeltaAttitudeDec(dbTimeSeriesByType);
        setDeltaAttitudeRa(dbTimeSeriesByType);
        setDeltaAttitudeRoll(dbTimeSeriesByType);
        setDesiredAttitudeDec(dbTimeSeriesByType);
        setDesiredAttitudeRa(dbTimeSeriesByType);
        setDesiredAttitudeRoll(dbTimeSeriesByType);
    }

    /**
     * Convenience method for creating a time series from the given inputs. The
     * cadence numbers used are the indexes in the array of values.
     * 
     * @param targetTableId
     * @param pipelineTaskId
     * @param type
     * @param pdqTimeSeries
     * @param minEndCadence
     * @return
     */
    private static List<FloatTimeSeries> getFloatTimeSeries(int targetTableId,
        long pipelineTaskId, TimeSeriesType type,
        CompoundFloatTimeSeries pdqTimeSeries, int minEndCadence) {

        List<FloatTimeSeries> timeSeries = new ArrayList<FloatTimeSeries>();
        if (pdqTimeSeries != null && pdqTimeSeries.size() > 0) {
            FsId fsId = PdqFsIdFactory.getPdqTimeSeriesFsId(type, targetTableId);
            float[] values = pdqTimeSeries.getValues();
            float[] uncertainties = pdqTimeSeries.getUncertainties();
            boolean[] gapIndicators = pdqTimeSeries.getGapIndicators();
            int endCadence = pdqTimeSeries.size() - 1;
            if (minEndCadence > endCadence) {
                int newLength = minEndCadence + 1;
                values = Arrays.copyOf(values, newLength);
                uncertainties = Arrays.copyOf(uncertainties, newLength);
                gapIndicators = Arrays.copyOf(gapIndicators, newLength);
                Arrays.fill(gapIndicators, endCadence, minEndCadence, false);
                endCadence = minEndCadence;
            }
            timeSeries.add(new FloatTimeSeries(fsId, values, 0, endCadence,
                gapIndicators, pipelineTaskId));
            fsId = PdqFsIdFactory.getPdqUncertaintiesFsId(type, targetTableId);
            timeSeries.add(new FloatTimeSeries(fsId, uncertainties, 0,
                endCadence, gapIndicators, pipelineTaskId));
        }
        return timeSeries;
    }

    private static List<PdqDbTimeSeries> getDbTimeSeries(int targetTableId,
        long pipelineTaskId, PdqDoubleTimeSeriesType timeSeriesType,
        PdqDoubleTimeSeries timeSeries, int minEndCadence) {

        List<PdqDbTimeSeries> dbTimeSeriesList = new ArrayList<PdqDbTimeSeries>();
        if (timeSeries != null && timeSeries.size() > 0) {
            int endCadence = timeSeries.size() - 1;
            if (minEndCadence > endCadence) {
                endCadence = minEndCadence;
            }
            dbTimeSeriesList.add(timeSeries.toDbTimeSeries(timeSeriesType,
                targetTableId, 0, endCadence, pipelineTaskId));
        }
        return dbTimeSeriesList;
    }

    public PdqDoubleTimeSeries getAttitudeSolutionDec() {
        return attitudeSolutionDec;
    }

    public void setAttitudeSolutionDec(
        final PdqDoubleTimeSeries attitudeSolutionDec) {
        this.attitudeSolutionDec = attitudeSolutionDec;
    }

    public PdqDoubleTimeSeries getAttitudeSolutionRa() {
        return attitudeSolutionRa;
    }

    public void setAttitudeSolutionRa(
        final PdqDoubleTimeSeries attitudeSolutionRa) {
        this.attitudeSolutionRa = attitudeSolutionRa;
    }

    public PdqDoubleTimeSeries getAttitudeSolutionRoll() {
        return attitudeSolutionRoll;
    }

    public void setAttitudeSolutionRoll(
        final PdqDoubleTimeSeries attitudeSolutionRoll) {
        this.attitudeSolutionRoll = attitudeSolutionRoll;
    }

    public double[] getCadenceTimes() {
        return Arrays.copyOf(cadenceTimes, cadenceTimes.length);
    }

    public void setCadenceTimes(final double[] cadenceTimes) {
        this.cadenceTimes = Arrays.copyOf(cadenceTimes, cadenceTimes.length);
    }

    public PdqDoubleTimeSeries getDeltaAttitudeDec() {
        return deltaAttitudeDec;
    }

    public void setDeltaAttitudeDec(final PdqDoubleTimeSeries deltaAttitudeDec) {
        this.deltaAttitudeDec = deltaAttitudeDec;
    }

    public PdqDoubleTimeSeries getDeltaAttitudeRa() {
        return deltaAttitudeRa;
    }

    public void setDeltaAttitudeRa(final PdqDoubleTimeSeries deltaAttitudeRa) {
        this.deltaAttitudeRa = deltaAttitudeRa;
    }

    public PdqDoubleTimeSeries getDeltaAttitudeRoll() {
        return deltaAttitudeRoll;
    }

    public void setDeltaAttitudeRoll(final PdqDoubleTimeSeries deltaAttitudeRoll) {
        this.deltaAttitudeRoll = deltaAttitudeRoll;
    }

    public PdqDoubleTimeSeries getDesiredAttitudeDec() {
        return desiredAttitudeDec;
    }

    public void setDesiredAttitudeDec(
        final PdqDoubleTimeSeries desiredAttitudeDec) {
        this.desiredAttitudeDec = desiredAttitudeDec;
    }

    public PdqDoubleTimeSeries getDesiredAttitudeRa() {
        return desiredAttitudeRa;
    }

    public void setDesiredAttitudeRa(final PdqDoubleTimeSeries desiredAttitudeRa) {
        this.desiredAttitudeRa = desiredAttitudeRa;
    }

    public PdqDoubleTimeSeries getDesiredAttitudeRoll() {
        return desiredAttitudeRoll;
    }

    public void setDesiredAttitudeRoll(
        final PdqDoubleTimeSeries desiredAttitudeRoll) {
        this.desiredAttitudeRoll = desiredAttitudeRoll;
    }

    public CompoundFloatTimeSeries getMaxAttitudeResidualInPixels() {
        return maxAttitudeResidualInPixels;
    }

    public void setMaxAttitudeResidualInPixels(
        final CompoundFloatTimeSeries maxAttitudeResidualInPixels) {
        this.maxAttitudeResidualInPixels = maxAttitudeResidualInPixels;
    }

    public List<PdqModuleOutputTsData> getPdqModuleOutputTsData() {
        return pdqModuleOutputTsData;
    }

    private List<PdqDbTimeSeries> getAttitudeSolutionDec(int targetTableId,
        long pipelineTaskId, int minEndCadence) {

        return getDbTimeSeries(targetTableId, pipelineTaskId,
            PdqDoubleTimeSeriesType.ATTITUDE_DEC, getAttitudeSolutionDec(),
            minEndCadence);
    }

    private List<PdqDbTimeSeries> getAttitudeSolutionRa(int targetTableId,
        long pipelineTaskId, int minEndCadence) {

        return getDbTimeSeries(targetTableId, pipelineTaskId,
            PdqDoubleTimeSeriesType.ATTITUDE_RA, getAttitudeSolutionRa(),
            minEndCadence);
    }

    private List<PdqDbTimeSeries> getAttitudeSolutionRoll(int targetTableId,
        long pipelineTaskId, int minEndCadence) {

        return getDbTimeSeries(targetTableId, pipelineTaskId,
            PdqDoubleTimeSeriesType.ATTITUDE_ROLL, getAttitudeSolutionRoll(),
            minEndCadence);
    }

    private List<PdqDbTimeSeries> getDeltaAttitudeDec(int targetTableId,
        long pipelineTaskId, int minEndCadence) {

        return getDbTimeSeries(targetTableId, pipelineTaskId,
            PdqDoubleTimeSeriesType.DELTA_DEC, getDeltaAttitudeDec(),
            minEndCadence);
    }

    private List<PdqDbTimeSeries> getDeltaAttitudeRa(int targetTableId,
        long pipelineTaskId, int minEndCadence) {

        return getDbTimeSeries(targetTableId, pipelineTaskId,
            PdqDoubleTimeSeriesType.DELTA_RA, getDeltaAttitudeRa(),
            minEndCadence);
    }

    private List<PdqDbTimeSeries> getDeltaAttitudeRoll(int targetTableId,
        long pipelineTaskId, int minEndCadence) {

        return getDbTimeSeries(targetTableId, pipelineTaskId,
            PdqDoubleTimeSeriesType.DELTA_ROLL, getDeltaAttitudeRoll(),
            minEndCadence);
    }

    private List<PdqDbTimeSeries> getDesiredAttitudeDec(int targetTableId,
        long pipelineTaskId, int minEndCadence) {

        return getDbTimeSeries(targetTableId, pipelineTaskId,
            PdqDoubleTimeSeriesType.DESIRED_DEC, getDesiredAttitudeDec(),
            minEndCadence);
    }

    private List<PdqDbTimeSeries> getDesiredAttitudeRa(int targetTableId,
        long pipelineTaskId, int minEndCadence) {

        return getDbTimeSeries(targetTableId, pipelineTaskId,
            PdqDoubleTimeSeriesType.DESIRED_RA, getDesiredAttitudeRa(),
            minEndCadence);
    }

    private List<PdqDbTimeSeries> getDesiredAttitudeRoll(int targetTableId,
        long pipelineTaskId, int minEndCadence) {

        return getDbTimeSeries(targetTableId, pipelineTaskId,
            PdqDoubleTimeSeriesType.DESIRED_ROLL, getDesiredAttitudeRoll(),
            minEndCadence);
    }

    private List<FloatTimeSeries> getMaxAttitudeResidualInPixels(
        int targetTableId, long pipelineTaskId, int minEndCadence) {

        return getFloatTimeSeries(targetTableId, pipelineTaskId,
            TimeSeriesType.MAX_ATTITUDE_RESIDUAL_IN_PIXELS,
            getMaxAttitudeResidualInPixels(), minEndCadence);
    }

    public static Set<TimeSeriesType> getPerModuleOutputTimeSeriesTypes() {
        return perModuleOutputTimeSeriesTypes;
    }

    private List<FloatTimeSeries> getAllModuleOutputTimeSeries(
        int targetTableId, long pipelineTaskId, int minEndCadence) {

        List<FloatTimeSeries> timeSeriesList = new ArrayList<FloatTimeSeries>();
        for (PdqModuleOutputTsData tsData : getPdqModuleOutputTsData()) {
            timeSeriesList.addAll(tsData.getAvailableTimeSeries(targetTableId,
                pipelineTaskId, minEndCadence));
        }
        return timeSeriesList;
    }

    private void setAttitudeSolutionDec(
        Map<PdqDoubleTimeSeriesType, PdqDbTimeSeries> timeSeriesMap) {

        PdqDbTimeSeries dbTimeSeries = timeSeriesMap.get(PdqDoubleTimeSeriesType.ATTITUDE_DEC);
        if (dbTimeSeries != null) {
            PdqDoubleTimeSeries timeSeries = new PdqDoubleTimeSeries(
                dbTimeSeries.getValues(), dbTimeSeries.getUncertainties(),
                dbTimeSeries.getGapIndicators());
            setAttitudeSolutionDec(timeSeries);
        }
    }

    private void setAttitudeSolutionRa(
        Map<PdqDoubleTimeSeriesType, PdqDbTimeSeries> timeSeriesMap) {

        PdqDbTimeSeries dbTimeSeries = timeSeriesMap.get(PdqDoubleTimeSeriesType.ATTITUDE_RA);
        if (dbTimeSeries != null) {
            PdqDoubleTimeSeries timeSeries = new PdqDoubleTimeSeries(
                dbTimeSeries.getValues(), dbTimeSeries.getUncertainties(),
                dbTimeSeries.getGapIndicators());
            setAttitudeSolutionRa(timeSeries);
        }
    }

    private void setAttitudeSolutionRoll(
        Map<PdqDoubleTimeSeriesType, PdqDbTimeSeries> timeSeriesMap) {

        PdqDbTimeSeries dbTimeSeries = timeSeriesMap.get(PdqDoubleTimeSeriesType.ATTITUDE_ROLL);
        if (dbTimeSeries != null) {
            PdqDoubleTimeSeries timeSeries = new PdqDoubleTimeSeries(
                dbTimeSeries.getValues(), dbTimeSeries.getUncertainties(),
                dbTimeSeries.getGapIndicators());
            setAttitudeSolutionRoll(timeSeries);
        }
    }

    private void setDesiredAttitudeDec(
        Map<PdqDoubleTimeSeriesType, PdqDbTimeSeries> timeSeriesMap) {

        PdqDbTimeSeries dbTimeSeries = timeSeriesMap.get(PdqDoubleTimeSeriesType.DESIRED_DEC);
        if (dbTimeSeries != null) {
            PdqDoubleTimeSeries timeSeries = new PdqDoubleTimeSeries(
                dbTimeSeries.getValues(), dbTimeSeries.getUncertainties(),
                dbTimeSeries.getGapIndicators());
            setDesiredAttitudeDec(timeSeries);
        }
    }

    private void setDesiredAttitudeRa(
        Map<PdqDoubleTimeSeriesType, PdqDbTimeSeries> timeSeriesMap) {

        PdqDbTimeSeries dbTimeSeries = timeSeriesMap.get(PdqDoubleTimeSeriesType.DESIRED_RA);
        if (dbTimeSeries != null) {
            PdqDoubleTimeSeries timeSeries = new PdqDoubleTimeSeries(
                dbTimeSeries.getValues(), dbTimeSeries.getUncertainties(),
                dbTimeSeries.getGapIndicators());
            setDesiredAttitudeRa(timeSeries);
        }
    }

    private void setDesiredAttitudeRoll(
        Map<PdqDoubleTimeSeriesType, PdqDbTimeSeries> timeSeriesMap) {

        PdqDbTimeSeries dbTimeSeries = timeSeriesMap.get(PdqDoubleTimeSeriesType.DESIRED_ROLL);
        if (dbTimeSeries != null) {
            PdqDoubleTimeSeries timeSeries = new PdqDoubleTimeSeries(
                dbTimeSeries.getValues(), dbTimeSeries.getUncertainties(),
                dbTimeSeries.getGapIndicators());
            setDesiredAttitudeRoll(timeSeries);
        }
    }

    private void setDeltaAttitudeDec(
        Map<PdqDoubleTimeSeriesType, PdqDbTimeSeries> timeSeriesMap) {

        PdqDbTimeSeries dbTimeSeries = timeSeriesMap.get(PdqDoubleTimeSeriesType.DELTA_DEC);
        if (dbTimeSeries != null) {
            PdqDoubleTimeSeries timeSeries = new PdqDoubleTimeSeries(
                dbTimeSeries.getValues(), dbTimeSeries.getUncertainties(),
                dbTimeSeries.getGapIndicators());
            setDeltaAttitudeDec(timeSeries);
        }
    }

    private void setDeltaAttitudeRa(
        Map<PdqDoubleTimeSeriesType, PdqDbTimeSeries> timeSeriesMap) {

        PdqDbTimeSeries dbTimeSeries = timeSeriesMap.get(PdqDoubleTimeSeriesType.DELTA_RA);
        if (dbTimeSeries != null) {
            PdqDoubleTimeSeries timeSeries = new PdqDoubleTimeSeries(
                dbTimeSeries.getValues(), dbTimeSeries.getUncertainties(),
                dbTimeSeries.getGapIndicators());
            setDeltaAttitudeRa(timeSeries);
        }
    }

    private void setDeltaAttitudeRoll(
        Map<PdqDoubleTimeSeriesType, PdqDbTimeSeries> timeSeriesMap) {

        PdqDbTimeSeries dbTimeSeries = timeSeriesMap.get(PdqDoubleTimeSeriesType.DELTA_ROLL);
        if (dbTimeSeries != null) {
            PdqDoubleTimeSeries timeSeries = new PdqDoubleTimeSeries(
                dbTimeSeries.getValues(), dbTimeSeries.getUncertainties(),
                dbTimeSeries.getGapIndicators());
            setDeltaAttitudeRoll(timeSeries);
        }
    }

    private void setMaxAttitudeResidualInPixels(final int targetTableId,
        final Map<FsId, FloatTimeSeries> timeSeriesMap) {

        FsId fsId = PdqFsIdFactory.getPdqTimeSeriesFsId(
            TimeSeriesType.MAX_ATTITUDE_RESIDUAL_IN_PIXELS, targetTableId);
        FloatTimeSeries timeSeries = timeSeriesMap.get(fsId);
        if (timeSeries != null) {
            fsId = PdqFsIdFactory.getPdqUncertaintiesFsId(
                TimeSeriesType.MAX_ATTITUDE_RESIDUAL_IN_PIXELS, targetTableId);
            FloatTimeSeries uncertainties = timeSeriesMap.get(fsId);
            setMaxAttitudeResidualInPixels(new CompoundFloatTimeSeries(
                timeSeries.fseries(), uncertainties.fseries(),
                timeSeries.getGapIndicators()));
        }
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME
            * result
            + (attitudeSolutionDec == null ? 0 : attitudeSolutionDec.hashCode());
        result = PRIME * result
            + (attitudeSolutionRa == null ? 0 : attitudeSolutionRa.hashCode());
        result = PRIME
            * result
            + (attitudeSolutionRoll == null ? 0
                : attitudeSolutionRoll.hashCode());
        result = PRIME * result + Arrays.hashCode(cadenceTimes);
        result = PRIME * result
            + (deltaAttitudeDec == null ? 0 : deltaAttitudeDec.hashCode());
        result = PRIME * result
            + (deltaAttitudeRa == null ? 0 : deltaAttitudeRa.hashCode());
        result = PRIME * result
            + (deltaAttitudeRoll == null ? 0 : deltaAttitudeRoll.hashCode());
        result = PRIME * result
            + (desiredAttitudeDec == null ? 0 : desiredAttitudeDec.hashCode());
        result = PRIME * result
            + (desiredAttitudeRa == null ? 0 : desiredAttitudeRa.hashCode());
        result = PRIME
            * result
            + (desiredAttitudeRoll == null ? 0 : desiredAttitudeRoll.hashCode());
        result = PRIME
            * result
            + (maxAttitudeResidualInPixels == null ? 0
                : maxAttitudeResidualInPixels.hashCode());
        result = PRIME
            * result
            + (pdqModuleOutputTsData == null ? 0
                : pdqModuleOutputTsData.hashCode());
        return result;
    }

    @Override
    public boolean equals(final Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final PdqTsData other = (PdqTsData) obj;
        if (attitudeSolutionDec == null) {
            if (other.attitudeSolutionDec != null) {
                return false;
            }
        } else if (!attitudeSolutionDec.equals(other.attitudeSolutionDec)) {
            return false;
        }
        if (attitudeSolutionRa == null) {
            if (other.attitudeSolutionRa != null) {
                return false;
            }
        } else if (!attitudeSolutionRa.equals(other.attitudeSolutionRa)) {
            return false;
        }
        if (attitudeSolutionRoll == null) {
            if (other.attitudeSolutionRoll != null) {
                return false;
            }
        } else if (!attitudeSolutionRoll.equals(other.attitudeSolutionRoll)) {
            return false;
        }
        if (!Arrays.equals(cadenceTimes, other.cadenceTimes)) {
            return false;
        }
        if (deltaAttitudeDec == null) {
            if (other.deltaAttitudeDec != null) {
                return false;
            }
        } else if (!deltaAttitudeDec.equals(other.deltaAttitudeDec)) {
            return false;
        }
        if (deltaAttitudeRa == null) {
            if (other.deltaAttitudeRa != null) {
                return false;
            }
        } else if (!deltaAttitudeRa.equals(other.deltaAttitudeRa)) {
            return false;
        }
        if (deltaAttitudeRoll == null) {
            if (other.deltaAttitudeRoll != null) {
                return false;
            }
        } else if (!deltaAttitudeRoll.equals(other.deltaAttitudeRoll)) {
            return false;
        }
        if (desiredAttitudeDec == null) {
            if (other.desiredAttitudeDec != null) {
                return false;
            }
        } else if (!desiredAttitudeDec.equals(other.desiredAttitudeDec)) {
            return false;
        }
        if (desiredAttitudeRa == null) {
            if (other.desiredAttitudeRa != null) {
                return false;
            }
        } else if (!desiredAttitudeRa.equals(other.desiredAttitudeRa)) {
            return false;
        }
        if (desiredAttitudeRoll == null) {
            if (other.desiredAttitudeRoll != null) {
                return false;
            }
        } else if (!desiredAttitudeRoll.equals(other.desiredAttitudeRoll)) {
            return false;
        }
        if (maxAttitudeResidualInPixels == null) {
            if (other.maxAttitudeResidualInPixels != null) {
                return false;
            }
        } else if (!maxAttitudeResidualInPixels.equals(other.maxAttitudeResidualInPixels)) {
            return false;
        }
        if (pdqModuleOutputTsData == null) {
            if (other.pdqModuleOutputTsData != null) {
                return false;
            }
        } else if (!pdqModuleOutputTsData.equals(other.pdqModuleOutputTsData)) {
            return false;
        }
        return true;
    }
}
