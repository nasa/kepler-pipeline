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

package gov.nasa.kepler.mc.ancillary;

import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.common.AncillaryPipelineData;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.TimeSeriesOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.AncillaryFsIdFactory;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.PpaFsIdFactory;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class AncillaryOperations {

    private static final Log log = LogFactory.getLog(AncillaryOperations.class);

    private static final String SOC_MNEMONIC_PREFIX = "SOC_";

    public static enum ModuleType {
        ANC, CAL, PA, PPA;
    }

    private Set<Long> producerTaskIds = new HashSet<Long>();

    /**
     * Get the task ids of the data retrieved since the last call to this
     * method.
     * 
     * @return a {@code Set} of producer task ids
     */
    public Set<Long> producerTaskIds() {
        Set<Long> currentTaskIds = producerTaskIds;
        producerTaskIds = new HashSet<Long>();
        return currentTaskIds;
    }

    public void storeAncillaryEngineeringData(
        Collection<AncillaryEngineeringData> ancillaryEngineeringDataList,
        long originator) {

        sortByTimestamp(ancillaryEngineeringDataList);

        List<FloatMjdTimeSeries> timeSeriesList = new ArrayList<FloatMjdTimeSeries>();
        for (AncillaryEngineeringData ancillaryEngineeringData : ancillaryEngineeringDataList) {
            FsId fsId = AncillaryFsIdFactory.getId(ancillaryEngineeringData.getMnemonic());
            double[] timestamps = ancillaryEngineeringData.getTimestamps();
            float[] values = ancillaryEngineeringData.getValues();

            if (timestamps.length != 0) {
                FloatMjdTimeSeries timeSeries = new FloatMjdTimeSeries(fsId,
                    timestamps[0], timestamps[timestamps.length - 1],
                    timestamps, values, originator);

                timeSeriesList.add(timeSeries);
            }
        }

        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        fsClient.writeMjdTimeSeries(
            timeSeriesList.toArray(new FloatMjdTimeSeries[0]), false);
    }

    private void sortByTimestamp(
        Collection<AncillaryEngineeringData> ancillaryEngineeringDataList) {
        for (AncillaryEngineeringData ancillaryEngineeringData : ancillaryEngineeringDataList) {
            double[] timestamps = ancillaryEngineeringData.getTimestamps();
            float[] values = ancillaryEngineeringData.getValues();

            Map<Double, Float> timestampToValueMap = new TreeMap<Double, Float>();
            for (int i = 0; i < timestamps.length; i++) {
                double timestamp = timestamps[i];
                float value = values[i];

                Float existingValue = timestampToValueMap.get(timestamp);
                if (existingValue == null) {
                    // Doesn't exist, so add it to the list.
                    timestampToValueMap.put(timestamp, value);
                } else {
                    if (value == existingValue) {
                        // Found a dup; don't add it to the list.
                        AlertServiceFactory.getInstance()
                            .generateAlert(
                                AncillaryOperations.class.getName(),
                                "Found a duplicate timestamp/value pair:\n  mnemonic: "
                                    + ancillaryEngineeringData.getMnemonic()
                                    + "\n  firstTimestamp: " + timestamp
                                    + "\n  firstValue: " + existingValue
                                    + "\n  secondTimestamp: " + timestamp
                                    + "\n  secondValue: " + value);
                    } else {
                        // Error:
                        throw new PipelineException(
                            "Found duplicate timestamps with differing values:\n  mnemonic: "
                                + ancillaryEngineeringData.getMnemonic()
                                + "\n  firstTimestamp: " + timestamp
                                + "\n  firstValue: " + existingValue
                                + "\n  secondTimestamp: " + timestamp
                                + "\n  secondValue: " + value);
                    }
                }
            }

            // Write the sorted values back to the input arrays.
            Set<Double> sortedTimestamps = timestampToValueMap.keySet();
            timestamps = new double[sortedTimestamps.size()];
            values = new float[sortedTimestamps.size()];
            int i = 0;
            for (Double timestamp : sortedTimestamps) {
                timestamps[i] = timestamp;
                values[i] = timestampToValueMap.get(timestamp);
                i++;
            }
            ancillaryEngineeringData.setTimestamps(timestamps);
            ancillaryEngineeringData.setValues(values);
        }
    }

    public List<AncillaryEngineeringData> retrieveAncillaryEngineeringData(
        String[] mnemonics, double timestampStart, double timestampEnd) {
        return retrieveAncillaryEngineeringData(mnemonics, timestampStart,
            timestampEnd, true);
    }

    public List<AncillaryEngineeringData> retrieveAncillaryEngineeringData(
        String[] mnemonics, double timestampStart, double timestampEnd,
        boolean checkForMissingMnemonics) {

        List<AncillaryEngineeringData> ancillaryEngineeringDataList = new ArrayList<AncillaryEngineeringData>();
        if (mnemonics == null || mnemonics.length == 0) {
            return ancillaryEngineeringDataList;
        }

        List<FsId> fsIds = new ArrayList<FsId>();
        for (String mnemonic : mnemonics) {
            fsIds.add(AncillaryFsIdFactory.getId(mnemonic));
        }

        FloatMjdTimeSeries[] mjdTimeSeriesArray = FileStoreClientFactory.getInstance()
            .readMjdTimeSeries(fsIds.toArray(new FsId[0]), timestampStart,
                timestampEnd);

        List<String> invalidMnemonics = new ArrayList<String>();
        for (int i = 0; i < mnemonics.length; i++) {
            String mnemonic = mnemonics[i];
            FloatMjdTimeSeries timeSeries = mjdTimeSeriesArray[i];

            if (!timeSeries.exists()) {
                invalidMnemonics.add(mnemonic);

            } else if (timeSeries.mjd().length > 0) {
                AncillaryEngineeringData ancillaryEngineeringData = new AncillaryEngineeringData(
                    mnemonic);
                ancillaryEngineeringData.setTimestamps(timeSeries.mjd());
                ancillaryEngineeringData.setValues(timeSeries.values());

                ancillaryEngineeringDataList.add(ancillaryEngineeringData);
            }
        }

        if (checkForMissingMnemonics && invalidMnemonics.size() > 0) {
            StringBuilder buffer = new StringBuilder();
            for (String mnemonic : invalidMnemonics) {
                if (buffer.length() > 0) {
                    buffer.append(", ");
                }
                buffer.append(mnemonic);
            }
            throw new IllegalArgumentException(buffer.toString()
                + ": no such mnemonic"
                + (invalidMnemonics.size() > 1 ? "s" : ""));
        }

        return ancillaryEngineeringDataList;
    }

    public void storeAncillaryPipelineData(
        Collection<AncillaryPipelineData> ancillaryPipelineDataList,
        long originator) {

        // Store data.
        List<FloatMjdTimeSeries> timeSeriesList = new ArrayList<FloatMjdTimeSeries>();
        for (AncillaryPipelineData ancillaryPipelineData : ancillaryPipelineDataList) {
            FsId fsId = AncillaryFsIdFactory.getId(ancillaryPipelineData.getMnemonic());
            double[] timestamps = ancillaryPipelineData.getTimestamps();
            float[] values = ancillaryPipelineData.getValues();
            FloatMjdTimeSeries timeSeries = new FloatMjdTimeSeries(fsId,
                timestamps[0], timestamps[timestamps.length - 1], timestamps,
                values, originator);

            timeSeriesList.add(timeSeries);
        }

        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        fsClient.writeMjdTimeSeries(timeSeriesList.toArray(new FloatMjdTimeSeries[0]));

        // Store uncertainties.
        List<FloatMjdTimeSeries> uncertTimeSeriesList = new ArrayList<FloatMjdTimeSeries>();
        for (AncillaryPipelineData ancillaryPipelineData : ancillaryPipelineDataList) {
            FsId fsId = AncillaryFsIdFactory.getId(getUncertaintyMnemonic(ancillaryPipelineData.getMnemonic()));
            double[] timestamps = ancillaryPipelineData.getTimestamps();
            float[] values = ancillaryPipelineData.getUncertainties();
            FloatMjdTimeSeries timeSeries = new FloatMjdTimeSeries(fsId,
                timestamps[0], timestamps[timestamps.length - 1], timestamps,
                values, originator);

            uncertTimeSeriesList.add(timeSeries);
        }

        fsClient.writeMjdTimeSeries(uncertTimeSeriesList.toArray(new FloatMjdTimeSeries[0]));
    }

    public List<AncillaryPipelineData> retrieveAncillaryPipelineData(
        String[] mnemonics, double startMjd, double endMjd) {

        List<AncillaryPipelineData> ancillaryPipelineDataList = new ArrayList<AncillaryPipelineData>();
        if (mnemonics == null || mnemonics.length == 0) {
            return ancillaryPipelineDataList;
        }

        // Retrieve data.
        List<FsId> fsIds = new ArrayList<FsId>();
        for (String mnemonic : mnemonics) {
            fsIds.add(AncillaryFsIdFactory.getId(mnemonic));
        }

        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        FloatMjdTimeSeries[] mjdTimeSeriesArray = fsClient.readMjdTimeSeries(
            fsIds.toArray(new FsId[0]), startMjd, endMjd);

        Map<String, AncillaryPipelineData> mnemonicToAncillaryPipelineData = new HashMap<String, AncillaryPipelineData>(
            mnemonics.length);
        for (int i = 0; i < mnemonics.length; i++) {
            String mnemonic = mnemonics[i];
            FloatMjdTimeSeries timeSeries = mjdTimeSeriesArray[i];

            if (timeSeries.exists()) {
                TimeSeriesOperations.addToDataAccountability(timeSeries,
                    producerTaskIds);

                AncillaryPipelineData ancillaryPipelineData = new AncillaryPipelineData(
                    mnemonic);
                ancillaryPipelineData.setTimestamps(timeSeries.mjd());
                ancillaryPipelineData.setValues(timeSeries.values());

                ancillaryPipelineDataList.add(ancillaryPipelineData);
                mnemonicToAncillaryPipelineData.put(mnemonic,
                    ancillaryPipelineData);
            }
        }

        // Retrieve uncertainties.
        List<FsId> uncertFsIds = new ArrayList<FsId>();
        for (String mnemonic : mnemonics) {
            uncertFsIds.add(AncillaryFsIdFactory.getId(getUncertaintyMnemonic(mnemonic)));
        }

        FloatMjdTimeSeries[] uncertTimeSeriesArray = fsClient.readMjdTimeSeries(
            uncertFsIds.toArray(new FsId[0]), startMjd, endMjd);

        for (int i = 0; i < mnemonics.length; i++) {
            AncillaryPipelineData ancillaryPipelineData = mnemonicToAncillaryPipelineData.get(mnemonics[i]);
            if (ancillaryPipelineData != null) {
                FloatMjdTimeSeries timeSeries = uncertTimeSeriesArray[i];

                if (timeSeries.exists()) {
                    TimeSeriesOperations.addToDataAccountability(timeSeries,
                        producerTaskIds);

                    ancillaryPipelineData.setUncertainties(timeSeries.values());
                }
            }
        }

        return ancillaryPipelineDataList;
    }

    private String getUncertaintyMnemonic(String mnemonic) {
        return mnemonic + "_U";
    }

    /**
     * Return a {@code Set} containing the supported ancillary pipeline data
     * mnemonics.
     * 
     * @return a {@code Set} of {@code String} intances whose values are
     * ancillary pipeline data mnemonics.
     */
    public Set<String> getAncillaryPipelineDataMnemonics() {

        Set<String> mnemonics = new HashSet<String>();
        for (String mnemonic : CalFsIdFactory.getAncillaryPipelineDataMnemonics()) {
            mnemonics.add(SOC_MNEMONIC_PREFIX + ModuleType.CAL + "_" + mnemonic);
        }
        for (String mnemonic : PaFsIdFactory.getAncillaryPipelineDataMnemonics()) {
            mnemonics.add(SOC_MNEMONIC_PREFIX + ModuleType.PA + "_" + mnemonic);
        }
        for (String mnemonic : PpaFsIdFactory.getAncillaryPipelineDataMnemonics()) {
            mnemonics.add(SOC_MNEMONIC_PREFIX + ModuleType.PPA + "_" + mnemonic);
        }
        return mnemonics;
    }

    // model orders and interactions?
    // will all ancillary pipeline data be time series?

    /**
     * Return a map of pairs of {@code FsId}s, if any, keyed by their
     * {@code mnemonics}.
     * 
     * @param mnemonics an array of {@code String}s whose values are ancillary
     * pipeline data mnemonics.
     * @param targetTable constrain the {@code FsId}s to this
     * {@code TargetTable}.
     * @param ccdModule constrain the {@code FsId}s to this CCD module.
     * @param ccdOutput constrain the {@code FsId}s to this CCD output.
     * @return a {@code Map} whose keys are the given {@code mnemonics} and
     * whose values are {@code Pair<Integer, Integer>}s where the {@code left}
     * value is the {@code FsId} for the ancillary data values and the
     * {@code right} value is the {@code FsId} for the corresponding
     * uncertainties, if any.
     * @see #getAncillaryPipelineDataMnemonics()
     */
    public static Map<String, Pair<FsId, FsId>> getAncillaryMnemonicToTimeSeriesFsIds(
        String[] mnemonics, TargetTable targetTable, int ccdModule,
        int ccdOutput) {

        Map<String, Pair<FsId, FsId>> mnemonicToFsIds = new HashMap<String, Pair<FsId, FsId>>(
            mnemonics.length);

        for (String mnemonic : mnemonics) {
            if (!mnemonic.startsWith(SOC_MNEMONIC_PREFIX)) {
                throw new IllegalArgumentException(String.format(
                    "%s: unexpected mnemonic, all ancillary pipeline"
                        + " data mnemonics must start with '%s'.", mnemonic,
                    SOC_MNEMONIC_PREFIX));
            } else if (mnemonic.length() <= SOC_MNEMONIC_PREFIX.length()) {
                throw new IllegalArgumentException(String.format(
                    "%s: unexpected mnemonic, missing module component.",
                    mnemonic));
            }

            int endIndex = mnemonic.indexOf('_', SOC_MNEMONIC_PREFIX.length());
            if (endIndex == -1) {
                throw new IllegalArgumentException(
                    String.format(
                        "%s: unexpected mnemonic, unable to determine module component.",
                        mnemonic));
            }
            String module = mnemonic.substring(SOC_MNEMONIC_PREFIX.length(),
                endIndex);

            ModuleType moduleType = ModuleType.valueOf(module);
            if (mnemonic.length() < SOC_MNEMONIC_PREFIX.length()
                + module.length() + 2) {
                throw new IllegalArgumentException(String.format(
                    "%s: unexpected mnemonic, missing '%s'"
                        + " module specific component.", mnemonic, module));
            }

            String moduleMnemonic = mnemonic.substring(endIndex + 1);
            FsId dataFsId = null;
            FsId uncertFsId = null;
            switch (moduleType) {
                case ANC:
                    dataFsId = AncillaryFsIdFactory.getId(moduleMnemonic);
                    break;
                case CAL:
                    dataFsId = CalFsIdFactory.getAncillaryPipelineDataFsId(
                        moduleMnemonic, CadenceType.LONG, ccdModule, ccdOutput);
                    uncertFsId = CalFsIdFactory.getAncillaryPipelineDataUncertaintiesFsId(
                        moduleMnemonic, CadenceType.LONG, ccdModule, ccdOutput);
                    break;
                case PA:
                    dataFsId = PaFsIdFactory.getAncillaryPipelineDataFsId(
                        moduleMnemonic, ccdModule, ccdOutput);
                    uncertFsId = PaFsIdFactory.getAncillaryPipelineDataUncertaintiesFsId(
                        moduleMnemonic, ccdModule, ccdOutput);
                    break;
                case PPA:
                    // TODO: determine why the target table external id is
                    // required
                    dataFsId = PpaFsIdFactory.getAncillaryPipelineDataFsId(
                        moduleMnemonic, ccdModule, ccdOutput);
                    uncertFsId = PpaFsIdFactory.getAncillaryPipelineDataUncertaintiesFsId(
                        moduleMnemonic, ccdModule, ccdOutput);
                    break;
                default:
                    log.error(String.format(
                        "%s: ancillary pipeline data not implemented for '%s'.",
                        mnemonic, moduleType));
                    break;
            }
            if (dataFsId != null) {
                mnemonicToFsIds.put(mnemonic, Pair.of(dataFsId, uncertFsId));
            }
        }
        return mnemonicToFsIds;
    }

    /**
     * Retrieve the pipeline data associated with the requested
     * {@code mnemonics} using the remaining parameters to constrain the
     * request.
     * 
     * @param mnemonics a {@code String[]} of ancillary pipeline data mnemonics.
     * @param targetTable a {@code TargetTable} to use as a constraint.
     * @param ccdModule a CCD module.
     * @param ccdOutput a CCD output.
     * @param cadenceTimes a {@code TimestampSeries} spanning the time frame of
     * interest.
     * @return list of available matching {@code AncillaryPipelineData}
     * instances.
     */
    public List<AncillaryPipelineData> retrieveAncillaryPipelineData(
        String[] mnemonics, TargetTable targetTable, int ccdModule,
        int ccdOutput, TimestampSeries cadenceTimes) {

        Map<String, Pair<FsId, FsId>> mnemonicToFsIds = getAncillaryMnemonicToTimeSeriesFsIds(
            mnemonics, targetTable, ccdModule, ccdOutput);

        List<FsId> timeSeriesFsIds = new ArrayList<FsId>(mnemonics.length * 2);
        List<String> mjdTimeSeriesFsIds = new ArrayList<String>();
        for (String mnemonic : mnemonics) {
            Pair<FsId, FsId> mnemonicFsIds = mnemonicToFsIds.get(mnemonic);
            if (mnemonicFsIds != null) {
                timeSeriesFsIds.add(mnemonicFsIds.left);
                if (mnemonicFsIds.right != null) {
                    timeSeriesFsIds.add(mnemonicFsIds.right);
                }
            } else {
                mjdTimeSeriesFsIds.add(mnemonic);
            }
        }

        List<AncillaryPipelineData> ancillaryData = new ArrayList<AncillaryPipelineData>(
            mnemonics.length);
        if (timeSeriesFsIds.size() > 0) {
            int startCadence = cadenceTimes.cadenceNumbers[0];
            int endCadence = cadenceTimes.cadenceNumbers[cadenceTimes.cadenceNumbers.length - 1];
            FloatTimeSeries[] timeSeries = FileStoreClientFactory.getInstance()
                .readTimeSeriesAsFloat(
                    timeSeriesFsIds.toArray(new FsId[timeSeriesFsIds.size()]),
                    startCadence, endCadence, false);
            // only include existing time series
            Map<FsId, FloatTimeSeries> timeSeriesByFsId = TimeSeriesOperations.getFloatTimeSeriesByFsId(timeSeries);

            for (String mnemonic : mnemonics) {
                Pair<FsId, FsId> ancillaryFsIds = mnemonicToFsIds.get(mnemonic);
                if (ancillaryFsIds == null) {
                    continue;
                }
                FloatTimeSeries valuesTimeSeries = timeSeriesByFsId.get(ancillaryFsIds.left);
                if (valuesTimeSeries == null) {
                    continue;
                }
                TimeSeriesOperations.addToDataAccountability(valuesTimeSeries,
                    producerTaskIds);

                AncillaryPipelineData pipelineData = new AncillaryPipelineData(
                    mnemonic);
                FloatTimeSeries uncertaintiesTimeSeries = null;
                if (ancillaryFsIds.right != null) {
                    uncertaintiesTimeSeries = timeSeriesByFsId.get(ancillaryFsIds.right);
                    if (uncertaintiesTimeSeries != null) {
                        TimeSeriesOperations.addToDataAccountability(
                            uncertaintiesTimeSeries, producerTaskIds);
                    }
                }

                pipelineData = createAncillaryPipelineData(mnemonic,
                    cadenceTimes, valuesTimeSeries, uncertaintiesTimeSeries);
                ancillaryData.add(pipelineData);
            }
        }
        if (mjdTimeSeriesFsIds.size() > 0) {
            List<AncillaryPipelineData> nonFsAncillaryData = retrieveAncillaryPipelineData(
                mjdTimeSeriesFsIds.toArray(new String[mjdTimeSeriesFsIds.size()]),
                cadenceTimes.startMjd(), cadenceTimes.endMjd());
            ancillaryData.addAll(nonFsAncillaryData);
        }
        return ancillaryData;
    }

    /**
     * Create a {@code AncillaryPipelineData} intance populated with the given
     * parameter values.
     * 
     * @param mnemonic the name for this ancillary data.
     * @param cadenceTimes the {@code TimestampSeries} spanning the cadences of
     * interest.
     * @param valuesTimeSeries the {@code FloatTimeSeries} containing the values
     * corresponding to the given {@code mnemonic}.
     * @param uncertaintiesTimeSeries a {@code FloatTimeSeries} containing the
     * uncertainties associated with the given {@code valueTimeSeries}
     * parameter.
     * @return a {@code AncillaryPipelineData} instance populated using the
     * given parameter values.
     */
    public static AncillaryPipelineData createAncillaryPipelineData(
        String mnemonic, TimestampSeries cadenceTimes,
        FloatTimeSeries valuesTimeSeries,
        FloatTimeSeries uncertaintiesTimeSeries) {

        int length = valuesTimeSeries.cadenceLength()
            - valuesTimeSeries.getGapIndices().length;
        float[] values = new float[length];
        float[] uncertainties = ArrayUtils.EMPTY_FLOAT_ARRAY;
        if (uncertaintiesTimeSeries != null) {
            uncertainties = new float[length];
        }
        double[] timestamps = new double[length];
        for (int i = 0, j = 0; i < valuesTimeSeries.cadenceLength(); i++) {
            if (!valuesTimeSeries.getGapIndicators()[i]) {
                values[j] = valuesTimeSeries.fseries()[i];
                timestamps[j] = cadenceTimes.midTimestamps[i];
                if (uncertaintiesTimeSeries != null) {
                    uncertainties[j] = uncertaintiesTimeSeries.fseries()[i];
                }
                j++;
            }
        }

        AncillaryPipelineData pipelineData = new AncillaryPipelineData(mnemonic);
        pipelineData.setValues(values);
        pipelineData.setTimestamps(timestamps);
        if (uncertaintiesTimeSeries != null) {
            pipelineData.setUncertainties(uncertainties);
        }
        return pipelineData;
    }

}
