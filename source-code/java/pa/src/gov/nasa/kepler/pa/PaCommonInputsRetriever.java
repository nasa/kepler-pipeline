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

package gov.nasa.kepler.pa;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Lists.newArrayListWithExpectedSize;
import static com.google.common.collect.Sets.newHashSet;
import static com.google.common.collect.Sets.newTreeSet;
import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.common.AncillaryPipelineData;
import gov.nasa.kepler.common.pi.AncillaryEngineeringParameters;
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.mc.CalibratedPixel;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.RollingBandArtifactFlags;
import gov.nasa.kepler.mc.TimeSeriesOperations;
import gov.nasa.kepler.mc.ancillary.AncillaryOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.DynablackFsIdFactory;
import gov.nasa.kepler.mc.pa.PaTarget;
import gov.nasa.kepler.mc.pa.ThrusterDataAncillaryEngineeringParameters;
import gov.nasa.kepler.pa.ffi.PaFfiInputsRetriever;
import gov.nasa.spiffy.common.SimpleDoubleTimeSeries;
import gov.nasa.spiffy.common.SimpleIntTimeSeries;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Code common to both {@link PaInputsRetriever} and
 * {@link PaFfiInputsRetriever}.
 * 
 * @author Forrest Girouard
 */
public class PaCommonInputsRetriever {

    private static final String REACTION_WHEEL_2_MNEMONIC = "ADRW2SPD_";

    public static TargetTable getLongCadenceTargetTable(String moduleName,
        TargetCrud targetCrud, int startCadence, int endCadence) {
        List<TargetTableLog> targetTableLogs = targetCrud.retrieveTargetTableLogs(
            TargetType.LONG_CADENCE, startCadence, endCadence);
        if (targetTableLogs.isEmpty()) {
            throw new ModuleFatalProcessingException(
                String.format(
                    "Long cadence target table missing for cadence interval [%d, %d].",
                    startCadence, endCadence));
        }

        if (targetTableLogs.size() > 1) {
            throw new ModuleFatalProcessingException(String.format(
                "Found %s target tables for cadence interval [%d, %d].",
                targetTableLogs.size(), startCadence, endCadence));
        }

        TargetTableLog targetTableLog = targetTableLogs.get(0);
        TargetTable targetTable = targetTableLog.getTargetTable();
        if (targetTable == null) {
            throw new ModuleFatalProcessingException(String.format(
                "Target table can't be null for cadence interval [%d, %d].",
                startCadence, endCadence));
        }

        PaFfiInputsRetriever.log.info("[" + moduleName
            + "]targetTableLog.getCadenceStart(): "
            + targetTableLog.getCadenceStart());
        PaFfiInputsRetriever.log.info("[" + moduleName
            + "]targetTableLog.getCadenceEnd(): "
            + targetTableLog.getCadenceEnd());

        return targetTableLog.getTargetTable();
    }

    public static TargetTable getShortCadenceTargetTable(TargetCrud targetCrud,
        int startCadence, int endCadence) {
        List<TargetTableLog> targetTableLogs = targetCrud.retrieveTargetTableLogs(
            TargetType.SHORT_CADENCE, startCadence, endCadence);

        if (targetTableLogs.isEmpty()) {
            throw new ModuleFatalProcessingException(String.format(
                "Short cadence target tables"
                    + " missing for cadence interval [%d, %d].", startCadence,
                endCadence));
        }

        if (targetTableLogs.size() > 1) {
            throw new ModuleFatalProcessingException(String.format(
                "Expected exactly one but found %d target tables"
                    + " for cadence interval [%d, %d].",
                targetTableLogs.size(), startCadence, endCadence));
        }

        TargetTable targetTable = targetTableLogs.get(0)
            .getTargetTable();
        if (targetTable == null) {
            throw new ModuleFatalProcessingException(String.format(
                "Target table can't be null for cadence interval [%d, %d].",
                startCadence, endCadence));
        }

        return targetTable;
    }

    public static TargetTable getBackgroundTargetTable(TargetCrud targetCrud,
        int startCadence, int endCadence) {

        List<TargetTableLog> backgroundLogs = targetCrud.retrieveTargetTableLogs(
            TargetType.BACKGROUND, startCadence, endCadence);
        if (backgroundLogs.size() != 1) {
            throw new ModuleFatalProcessingException(String.format(
                "Long cadence target table must have"
                    + " exactly one backgroundtarget table"
                    + " but found %d tables for cadence interval [%d, %d].",
                backgroundLogs.size(), startCadence, endCadence));
        }

        return backgroundLogs.get(0)
            .getTargetTable();
    }

    public static List<AncillaryEngineeringData> retrieveAncillaryEngineeringData(
        final AncillaryOperations ancillaryOperations, final double startMjd,
        final double endMjd, final AncillaryEngineeringParameters parameters,
        Set<Long> producerTaskIds) {
        return retrieveAncillaryEngineeringData(ancillaryOperations, startMjd,
            endMjd, parameters, producerTaskIds, true);
    }

    public static List<AncillaryEngineeringData> retrieveAncillaryEngineeringData(
        final AncillaryOperations ancillaryOperations, final double startMjd,
        final double endMjd, final AncillaryEngineeringParameters parameters,
        Set<Long> producerTaskIds, boolean checkForMissingMnemonics) {

        if (parameters == null) {
            throw new NullPointerException("parameters is null");
        }
        List<AncillaryEngineeringData> ancillaryData = newArrayList();
        String[] mnemonics = parameters.getMnemonics();
        if (mnemonics != null && mnemonics.length > 0) {
            ancillaryData = ancillaryOperations.retrieveAncillaryEngineeringData(
                mnemonics, startMjd, endMjd, checkForMissingMnemonics);
        }
        producerTaskIds.addAll(ancillaryOperations.producerTaskIds());

        ancillaryData = filterOutFailedReactionWheel2Data(ancillaryData);

        return ancillaryData;
    }

    public static List<AncillaryPipelineData> retrieveAncillaryPipelineData(
        final AncillaryOperations ancillaryOperations,
        final TargetTable targetTable, final int ccdModule,
        final int ccdOutput, final TimestampSeries cadenceTimes,
        final AncillaryPipelineParameters parameters, Set<Long> producerTaskIds) {

        if (parameters == null) {
            throw new NullPointerException("parameters is null");
        }
        List<AncillaryPipelineData> ancillaryData = newArrayList();
        String[] mnemonics = parameters.getMnemonics();
        if (mnemonics != null && mnemonics.length > 0) {
            ancillaryData = ancillaryOperations.retrieveAncillaryPipelineData(
                mnemonics, targetTable, ccdModule, ccdOutput, cadenceTimes);
        }
        producerTaskIds.addAll(ancillaryOperations.producerTaskIds());

        return ancillaryData;
    }

    public static OapAncillaryEngineeringParameters retrieveOapAncillaryEngineeringParameters(
        PipelineTask pipelineTask) {
        OapAncillaryEngineeringParameters oapAncillaryEngineeringParameters = pipelineTask.getParameters(OapAncillaryEngineeringParameters.class);
        if (oapAncillaryEngineeringParameters.getMnemonics() != null
            && oapAncillaryEngineeringParameters.getMnemonics().length == 1
            && oapAncillaryEngineeringParameters.getMnemonics()[0] == null) {
            oapAncillaryEngineeringParameters = new OapAncillaryEngineeringParameters();
        }

        return oapAncillaryEngineeringParameters;
    }

    public static AncillaryPipelineParameters retrieveAncillaryPipelineParameters(
        PipelineTask pipelineTask) {
        AncillaryPipelineParameters ancillaryPipelineParameters = pipelineTask.getParameters(AncillaryPipelineParameters.class);
        if (ancillaryPipelineParameters.getMnemonics() != null
            && ancillaryPipelineParameters.getMnemonics().length == 1
            && ancillaryPipelineParameters.getMnemonics()[0] == null) {
            ancillaryPipelineParameters = new AncillaryPipelineParameters();
        }

        return ancillaryPipelineParameters;
    }

    public static ReactionWheelAncillaryEngineeringParameters retrieveReactionWheelAncillaryEngineeringParameters(
        PipelineTask pipelineTask) {
        ReactionWheelAncillaryEngineeringParameters reactionWheelAncillaryEngineeringParameters = pipelineTask.getParameters(ReactionWheelAncillaryEngineeringParameters.class);
        if (reactionWheelAncillaryEngineeringParameters.getMnemonics() != null
            && reactionWheelAncillaryEngineeringParameters.getMnemonics().length == 1
            && reactionWheelAncillaryEngineeringParameters.getMnemonics()[0] == null) {
            reactionWheelAncillaryEngineeringParameters = new ReactionWheelAncillaryEngineeringParameters();
        }

        return reactionWheelAncillaryEngineeringParameters;
    }

    public static ThrusterDataAncillaryEngineeringParameters retrieveThrusterDataAncillaryEngineeringParameters(
        PipelineTask pipelineTask) {
        ThrusterDataAncillaryEngineeringParameters thrusterDataAncillaryEngineeringParameters = pipelineTask.getParameters(ThrusterDataAncillaryEngineeringParameters.class);
        if (thrusterDataAncillaryEngineeringParameters.getMnemonics() != null
            && thrusterDataAncillaryEngineeringParameters.getMnemonics().length == 1
            && thrusterDataAncillaryEngineeringParameters.getMnemonics()[0] == null) {
            thrusterDataAncillaryEngineeringParameters = new ThrusterDataAncillaryEngineeringParameters();
        }

        return thrusterDataAncillaryEngineeringParameters;
    }

    public static Set<FsId> createTargetBatchCosmicRayFsIds(
        final List<PaTarget> nextTargets) {

        Set<FsId> cosmicRayFsIds = newHashSet();
        for (PaTarget target : nextTargets) {
            for (Pixel pixel : target.getPixels()) {
                cosmicRayFsIds.add(((CalibratedPixel) pixel).getCosmicRayEventsFsId());
            }
        }
        return cosmicRayFsIds;
    }

    public static List<RollingBandArtifactFlags> retrieveRollingBandArtifactFlags(
        int ccdModule, int ccdOutput, int startCadence, int endCadence,
        Set<Integer> rows, Set<Integer> durations, Set<Long> producerTaskIds) {

        List<RollingBandArtifactFlags> flagsList = newArrayListWithExpectedSize(rows.size()
            * durations.size());

        Set<FsId> fsIds = newTreeSet();
        for (int row : rows) {
            for (int duration : durations) {
                fsIds.add(DynablackFsIdFactory.getRollingBandArtifactFlagsFsId(
                    ccdModule, ccdOutput, row, duration));
                fsIds.add(DynablackFsIdFactory.getRollingBandArtifactVariationFsId(
                    ccdModule, ccdOutput, row, duration));
            }
        }

        Map<FsId, TimeSeries> timeSeriesByFsId = FileStoreClientFactory.getInstance()
            .readTimeSeries(fsIds, startCadence, endCadence, false);

        for (int row : rows) {
            for (int duration : durations) {
                FsId flagsFsId = DynablackFsIdFactory.getRollingBandArtifactFlagsFsId(
                    ccdModule, ccdOutput, row, duration);
                IntTimeSeries flagsTimeSeries = timeSeriesByFsId.get(flagsFsId)
                    .asIntTimeSeries();
                FsId variationFsId = DynablackFsIdFactory.getRollingBandArtifactVariationFsId(
                    ccdModule, ccdOutput, row, duration);
                DoubleTimeSeries variationTimeSeries = timeSeriesByFsId.get(
                    variationFsId)
                    .asDoubleTimeSeries();
                if (flagsTimeSeries != null && flagsTimeSeries.exists()
                    && variationTimeSeries != null
                    && variationTimeSeries.exists()) {
                    RollingBandArtifactFlags rollingBandArtifactFlags = new RollingBandArtifactFlags();
                    rollingBandArtifactFlags.setRow(row);
                    rollingBandArtifactFlags.setTestPulseDurationLc(duration);
                    rollingBandArtifactFlags.setFlags(new SimpleIntTimeSeries(
                        flagsTimeSeries.iseries(),
                        flagsTimeSeries.getGapIndicators()));
                    rollingBandArtifactFlags.setVariationLevel(new SimpleDoubleTimeSeries(
                        variationTimeSeries.dseries(),
                        variationTimeSeries.getGapIndicators()));

                    flagsList.add(rollingBandArtifactFlags);

                    TimeSeriesOperations.addToDataAccountability(
                        flagsTimeSeries, producerTaskIds);
                    TimeSeriesOperations.addToDataAccountability(
                        variationTimeSeries, producerTaskIds);
                }
            }
        }

        return flagsList;
    }

    public static List<AncillaryEngineeringData> filterOutFailedReactionWheel2Data(
        List<AncillaryEngineeringData> ancillaryData) {

        List<AncillaryEngineeringData> filteredAncillaryData = new ArrayList<AncillaryEngineeringData>(
            ancillaryData.size());
        for (AncillaryEngineeringData data : ancillaryData) {
            if (data.getMnemonic()
                .equals(REACTION_WHEEL_2_MNEMONIC)) {

                int zeroCount = 0;
                for (int i = 0; i < data.getValues().length; i++) {
                    float value = data.getValues()[i];
                    if (value == 0F) {
                        zeroCount++;
                    } else {
                        break;
                    }
                }

                if (zeroCount == data.getValues().length) {
                    data = null;
                }
            }
            if (data != null) {
                filteredAncillaryData.add(data);
            }
        }

        return filteredAncillaryData;
    }
}
