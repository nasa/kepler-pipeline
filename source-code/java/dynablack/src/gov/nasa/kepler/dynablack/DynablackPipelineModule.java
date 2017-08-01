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

package gov.nasa.kepler.dynablack;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Maps.newHashMap;
import static com.google.common.collect.Sets.newHashSet;
import static com.google.common.primitives.Ints.toArray;
import gov.nasa.kepler.cal.ffi.FfiModOut;
import gov.nasa.kepler.cal.ffi.FfiReader;
import gov.nasa.kepler.cal.io.BlackTimeSeries;
import gov.nasa.kepler.cal.io.CalInputPixelTimeSeries;
import gov.nasa.kepler.cal.io.HuffmanTable;
import gov.nasa.kepler.cal.io.SmearTimeSeries;
import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.FfiType;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.fc.FlatFieldModel;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.LinearityModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.TwoDBlackModel;
import gov.nasa.kepler.fc.UndershootModel;
import gov.nasa.kepler.fc.flatfield.FlatFieldOperations;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.linearity.LinearityOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fc.twodblack.TwoDBlackOperations;
import gov.nasa.kepler.fc.undershoot.UndershootOperations;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.PlannedTarget.TargetLabel;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.dr.PixelLogCrud;
import gov.nasa.kepler.hibernate.dr.RclcPixelLogCrud;
import gov.nasa.kepler.hibernate.dynablack.DynablackCrud;
import gov.nasa.kepler.hibernate.dynablack.DynamicTwoDBlackBlobMetadata;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.mc.CollateralTimeSeriesOperations;
import gov.nasa.kepler.mc.FitsImage;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.RollingBandArtifactFlags;
import gov.nasa.kepler.mc.RollingBandArtifactParameters;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.kepler.mc.ancillary.AncillaryOperations;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.DataAnomalyFlags;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.dr.PixelTimeSeriesOperations;
import gov.nasa.kepler.mc.dr.PixelTimeSeriesReader;
import gov.nasa.kepler.mc.dr.RclcPixelTimeSeriesOperations;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.gar.RequantTable;
import gov.nasa.kepler.mc.pmrf.PmrfOperations;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Set;

import nom.tam.fits.FitsException;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.primitives.Booleans;
import com.google.common.primitives.Doubles;
import com.google.common.primitives.Ints;

/**
 * This {@link PipelineModule} creates the dynamic part of the two-d black model
 * and stores suspect pixel flags.
 * 
 * @author Miles Cote
 * 
 */
public class DynablackPipelineModule extends MatlabPipelineModule {

    private static final int MAX_PIXEL_COUNT = FcConstants.CCD_ROWS
        * FcConstants.CCD_COLUMNS;

    private static final Log log = LogFactory.getLog(DynablackPipelineModule.class);

    public static final String MODULE_NAME = "dynablack";

    private int ccdModule;
    private int ccdOutput;
    private CadenceType cadenceType;
    private int startCadence;
    private int endCadence;
    private int rclcStartCadence;
    private int rclcEndCadence;
    private DynablackModuleParameters dynablackModuleParameters;
    private RollingBandArtifactParameters rollingBandArtifactParameters;

    private PipelineInstance pipelineInstance;
    private PipelineTask pipelineTask;
    private ModOutCadenceUowTask task;

    private File matlabWorkingDir;

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return ModOutCadenceUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> rv = newArrayList();
        rv.add(CadenceRangeParameters.class);
        rv.add(CadenceTypePipelineParameters.class);
        rv.add(DynablackModuleParameters.class);
        rv.add(RollingBandArtifactParameters.class);
        return rv;
    }

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        this.pipelineInstance = pipelineInstance;
        this.pipelineTask = pipelineTask;
        task = pipelineTask.uowTaskInstance();

        try {
            ccdModule = task.getCcdModule();
            ccdOutput = task.getCcdOutput();
            startCadence = task.getStartCadence();
            endCadence = task.getEndCadence();

            CadenceTypePipelineParameters cadenceTypeParameters = pipelineTask.getParameters(CadenceTypePipelineParameters.class);
            cadenceType = CadenceType.valueOf(cadenceTypeParameters.getCadenceType());

            CadenceRangeParameters cadenceRangeParameters = pipelineTask.getParameters(CadenceRangeParameters.class);
            rclcStartCadence = cadenceRangeParameters.getStartCadence();
            rclcEndCadence = cadenceRangeParameters.getEndCadence();

            dynablackModuleParameters = pipelineTask.getParameters(DynablackModuleParameters.class);
            rollingBandArtifactParameters = pipelineTask.getParameters(RollingBandArtifactParameters.class);

            Persistable inputs = createInputs();

            retrieveInputs(inputs);

            Persistable outputs = createOutputs();

            executeAlgorithm(pipelineTask, inputs, outputs);

            storeOutputs(outputs);
        } catch (Exception e) {
            throw new PipelineException("Unable to process task.", e);
        }
    }

    private Persistable createInputs() {
        return new DynablackInputs();
    }

    private void retrieveInputs(Persistable inputs) throws FitsException,
        IOException {
        log.info("Retrieving inputs.");

        TimestampSeries cadenceTimes = retrieveCadenceTimes(cadenceType,
            startCadence, endCadence);

        TargetTableLog targetTableLog = retrieveTargetTableLog(TargetType.valueOf(cadenceType));
        TargetTableLog bgTargetTableLog = retrieveTargetTableLog(TargetType.BACKGROUND);

        CollateralTimeSeriesOperations collateralTimeSeriesOps = getCollateralTimeSeriesOperations(targetTableLog);
        IntTimeSeries[] collateralTimeSeries = collateralTimeSeriesOps.readCollateralTimeSeries(
            startCadence, endCadence);

        TargetTable targetTable = targetTableLog.getTargetTable();
        SciencePixelOperations sciencePixelOps = new SciencePixelOperations(
            targetTable, bgTargetTableLog.getTargetTable(), ccdModule,
            ccdOutput);
        sciencePixelOps.setTargetCrud(new TargetCrud());

        DynablackInputs dynablackInputs = (DynablackInputs) inputs;

        dynablackInputs.setCcdModule(ccdModule);
        dynablackInputs.setCcdOutput(ccdOutput);
        dynablackInputs.setSeason(targetTable.getObservingSeason());

        dynablackInputs.setDynablackModuleParameters(dynablackModuleParameters);
        dynablackInputs.setRollingBandArtifactParameters(rollingBandArtifactParameters);

        dynablackInputs.setAncillaryEngineeringDataStruct(retrieveAncillaryEngineeringDataStruct(cadenceTimes));

        log.info("Retrieving rawFfis.");
        dynablackInputs.setRawFfis(retrieveRawFfis());

        log.info("Retrieving cadenceTimes.");
        dynablackInputs.setCadenceTimes(cadenceTimes);
        log.info("Retrieving backgroundPixels.");
        dynablackInputs.setBackgroundPixels(retrieveBackgroundPixels(sciencePixelOps));
        log.info("Retrieving blackPixels.");
        dynablackInputs.setBlackPixels(retrieveBlackPixels(
            collateralTimeSeriesOps.getBlackLevelFsIds(), collateralTimeSeries));
        log.info("Retrieving maskedSmearPixels.");
        dynablackInputs.setMaskedSmearPixels(retrieveSmearPixels(
            collateralTimeSeriesOps.getMaskedSmearFsIds(), collateralTimeSeries));
        log.info("Retrieving virtualSmearPixels.");
        dynablackInputs.setVirtualSmearPixels(retrieveSmearPixels(
            collateralTimeSeriesOps.getVirtualSmearFsIds(),
            collateralTimeSeries));
        log.info("Retrieving arpTargetPixels.");
        dynablackInputs.setArpTargetPixels(retrieveArpTargetPixels(sciencePixelOps));

        TargetTableLog rclcTargetTableLog = retrieveRclcTargetTableLog(TargetType.valueOf(cadenceType));
        TargetTableLog rclcBgTargetTableLog = retrieveRclcTargetTableLog(TargetType.BACKGROUND);

        TimestampSeries times = cadenceTimes;
        if (dynablackModuleParameters.isReverseClockedEnabled()
            && rclcTargetTableLog != null) {
            retrieveRclcInputs(dynablackInputs, rclcTargetTableLog,
                rclcBgTargetTableLog);
            times = dynablackInputs.getReverseClockedCadenceTimes();
        }

        log.info("Retrieving models.");
        dynablackInputs.setTwoDBlackModel(retrieveTwoDBlackModel(times));
        dynablackInputs.setUndershootModel(retrieveUndershootModel(times));
        dynablackInputs.setGainModel(retrieveGainModel(times));
        dynablackInputs.setFlatFieldModel(retrieveFlatFieldModel(times));
        dynablackInputs.setLinearityModel(retrieveLinearityModel(times));
        dynablackInputs.setReadNoiseModel(retrieveReadNoiseModel(times));

        log.info("Retrieving compression tables.");
        dynablackInputs.setRequantTables(retrieveRequantTables(times));
        dynablackInputs.setHuffmanTables(retrieveHuffmanTables(times));

        dynablackInputs.setSpacecraftConfigMap(retrieveConfigMaps(times));
    }

    private List<CalInputPixelTimeSeries> trimReverseClockedCalInputPixels(
        List<Integer> validIndices, List<CalInputPixelTimeSeries> inputList) {
        List<CalInputPixelTimeSeries> calInputPixelTimeSeriesList = newArrayList();
        for (CalInputPixelTimeSeries calInputPixelTimeSeries : inputList) {

            List<Integer> values = newArrayList();
            List<Boolean> gapIndicators = newArrayList();
            for (Integer index : validIndices) {
                values.add(calInputPixelTimeSeries.getValues()[index]);
                gapIndicators.add(calInputPixelTimeSeries.getGapIndicators()[index]);
            }
            calInputPixelTimeSeriesList.add(new CalInputPixelTimeSeries(
                calInputPixelTimeSeries.getRow(),
                calInputPixelTimeSeries.getColumn(), toArray(values),
                Booleans.toArray(gapIndicators)));
        }

        return calInputPixelTimeSeriesList;
    }

    private List<SmearTimeSeries> trimReverseClockedSmearPixels(
        List<Integer> validIndices, List<SmearTimeSeries> inputList) {
        List<SmearTimeSeries> smearTimeSeriesList = newArrayList();
        for (SmearTimeSeries smearTimeSeries : inputList) {

            List<Integer> values = newArrayList();
            List<Boolean> gapIndicators = newArrayList();
            for (Integer index : validIndices) {
                values.add(smearTimeSeries.getValues()[index]);
                gapIndicators.add(smearTimeSeries.getGapIndicators()[index]);
            }
            smearTimeSeriesList.add(new SmearTimeSeries(
                smearTimeSeries.getColumn(), toArray(values),
                Booleans.toArray(gapIndicators)));
        }

        return smearTimeSeriesList;
    }

    private List<BlackTimeSeries> trimReverseClockedBlackPixels(
        List<Integer> validIndices, List<BlackTimeSeries> inputList) {
        List<BlackTimeSeries> blackTimeSeriesList = newArrayList();
        for (BlackTimeSeries blackTimeSeries : inputList) {

            List<Integer> values = newArrayList();
            List<Boolean> gapIndicators = newArrayList();
            for (Integer index : validIndices) {
                values.add(blackTimeSeries.getValues()[index]);
                gapIndicators.add(blackTimeSeries.getGapIndicators()[index]);
            }
            blackTimeSeriesList.add(new BlackTimeSeries(
                blackTimeSeries.getRow(), toArray(values),
                Booleans.toArray(gapIndicators)));
        }

        return blackTimeSeriesList;
    }

    private List<Integer> trimReverseClockedCadenceTimes(
        TimestampSeries reverseClockedCadenceTimes) {
        boolean[] gapIndicatorsArray = reverseClockedCadenceTimes.gapIndicators;
        List<Integer> validIndices = newArrayList();
        for (int i = 0; i < gapIndicatorsArray.length; i++) {
            if (gapIndicatorsArray[i] == false) {
                validIndices.add(i);
            }
        }

        List<Double> startTimestamps = newArrayList();
        List<Double> midTimestamps = newArrayList();
        List<Double> endTimestamps = newArrayList();
        List<Boolean> gapIndicators = newArrayList();
        List<Boolean> requantEnabled = newArrayList();
        List<Integer> cadenceNumbers = newArrayList();
        List<Boolean> isSefiAcc = newArrayList();
        List<Boolean> isSefiCad = newArrayList();
        List<Boolean> isLdeOos = newArrayList();
        List<Boolean> isFinePnt = newArrayList();
        List<Boolean> isMmntmDmp = newArrayList();
        List<Boolean> isLdeParEr = newArrayList();
        List<Boolean> isScrcErr = newArrayList();
        List<Boolean> attitudeTweakFlag = newArrayList();
        List<Boolean> safeModeFlag = newArrayList();
        List<Boolean> coarsePointFlag = newArrayList();
        List<Boolean> argabrighteningFlag = newArrayList();
        List<Boolean> excludeFlag = newArrayList();
        List<Boolean> earthPointFlag = newArrayList();
        List<Boolean> planetSearchExcludeFlag = newArrayList();
        for (Integer index : validIndices) {
            startTimestamps.add(reverseClockedCadenceTimes.startTimestamps[index]);
            midTimestamps.add(reverseClockedCadenceTimes.midTimestamps[index]);
            endTimestamps.add(reverseClockedCadenceTimes.endTimestamps[index]);
            gapIndicators.add(reverseClockedCadenceTimes.gapIndicators[index]);
            requantEnabled.add(reverseClockedCadenceTimes.requantEnabled[index]);
            cadenceNumbers.add(reverseClockedCadenceTimes.cadenceNumbers[index]);
            isSefiAcc.add(reverseClockedCadenceTimes.isSefiAcc[index]);
            isSefiCad.add(reverseClockedCadenceTimes.isSefiCad[index]);
            isLdeOos.add(reverseClockedCadenceTimes.isLdeOos[index]);
            isFinePnt.add(reverseClockedCadenceTimes.isFinePnt[index]);
            isMmntmDmp.add(reverseClockedCadenceTimes.isMmntmDmp[index]);
            isLdeParEr.add(reverseClockedCadenceTimes.isLdeParEr[index]);
            isScrcErr.add(reverseClockedCadenceTimes.isScrcErr[index]);
            attitudeTweakFlag.add(reverseClockedCadenceTimes.dataAnomalyFlags.attitudeTweakIndicators[index]);
            safeModeFlag.add(reverseClockedCadenceTimes.dataAnomalyFlags.safeModeIndicators[index]);
            coarsePointFlag.add(reverseClockedCadenceTimes.dataAnomalyFlags.coarsePointIndicators[index]);
            argabrighteningFlag.add(reverseClockedCadenceTimes.dataAnomalyFlags.argabrighteningIndicators[index]);
            excludeFlag.add(reverseClockedCadenceTimes.dataAnomalyFlags.excludeIndicators[index]);
            earthPointFlag.add(reverseClockedCadenceTimes.dataAnomalyFlags.earthPointIndicators[index]);
            planetSearchExcludeFlag.add(reverseClockedCadenceTimes.dataAnomalyFlags.planetSearchExcludeIndicators[index]);

        }
        reverseClockedCadenceTimes.startTimestamps = Doubles.toArray(startTimestamps);
        reverseClockedCadenceTimes.midTimestamps = Doubles.toArray(midTimestamps);
        reverseClockedCadenceTimes.endTimestamps = Doubles.toArray(endTimestamps);
        reverseClockedCadenceTimes.gapIndicators = Booleans.toArray(gapIndicators);
        reverseClockedCadenceTimes.requantEnabled = Booleans.toArray(requantEnabled);
        reverseClockedCadenceTimes.cadenceNumbers = Ints.toArray(cadenceNumbers);
        reverseClockedCadenceTimes.isSefiAcc = Booleans.toArray(isSefiAcc);
        reverseClockedCadenceTimes.isSefiCad = Booleans.toArray(isSefiCad);
        reverseClockedCadenceTimes.isLdeOos = Booleans.toArray(isLdeOos);
        reverseClockedCadenceTimes.isFinePnt = Booleans.toArray(isFinePnt);
        reverseClockedCadenceTimes.isMmntmDmp = Booleans.toArray(isMmntmDmp);
        reverseClockedCadenceTimes.isLdeParEr = Booleans.toArray(isLdeParEr);
        reverseClockedCadenceTimes.isScrcErr = Booleans.toArray(isScrcErr);
        reverseClockedCadenceTimes.dataAnomalyFlags = new DataAnomalyFlags(
            Booleans.toArray(attitudeTweakFlag),
            Booleans.toArray(safeModeFlag), Booleans.toArray(coarsePointFlag),
            Booleans.toArray(argabrighteningFlag),
            Booleans.toArray(excludeFlag), Booleans.toArray(earthPointFlag),
            Booleans.toArray(planetSearchExcludeFlag));

        return validIndices;
    }

    private void retrieveRclcInputs(DynablackInputs dynablackInputs,
        TargetTableLog rclcTargetTableLog, TargetTableLog rclcBgTargetTableLog) {
        CollateralTimeSeriesOperations rclcCollateralTimeSeriesOps = getRclcCollateralTimeSeriesOperations(rclcTargetTableLog);
        IntTimeSeries[] rclcCollateralTimeSeries = rclcCollateralTimeSeriesOps.readCollateralTimeSeries(
            rclcStartCadence, rclcEndCadence);

        SciencePixelOperations rclcSciencePixelOps = new SciencePixelOperations(
            rclcTargetTableLog.getTargetTable(),
            rclcBgTargetTableLog != null ? rclcBgTargetTableLog.getTargetTable()
                : null, ccdModule, ccdOutput);
        rclcSciencePixelOps.setTargetCrud(new TargetCrud());

        log.info("Retrieving reverseClockedCadenceTimes.");
        dynablackInputs.setReverseClockedCadenceTimes(retrieveReverseClockedCadenceTimes(
            cadenceType, rclcStartCadence, rclcEndCadence));
        List<Integer> validIndices = trimReverseClockedCadenceTimes(dynablackInputs.getReverseClockedCadenceTimes());

        if (log.isDebugEnabled()) {
            log.debug(String.format(
                "reverseClockedCadenceTimes range: [%d,%d]",
                dynablackInputs.getReverseClockedCadenceTimes().cadenceNumbers[0],
                dynablackInputs.getReverseClockedCadenceTimes().cadenceNumbers[dynablackInputs.getReverseClockedCadenceTimes().cadenceNumbers.length - 1]));
            log.debug("validIndices.size(): " + validIndices.size());
            for (int i = 0; i < validIndices.size(); i++) {
                log.debug(String.format("validIndices.get(%d): ",
                    validIndices.get(i)));
            }
        }
        log.info("Retrieving reverseClockedBlackPixels.");
        dynablackInputs.setReverseClockedBlackPixels(trimReverseClockedBlackPixels(
            validIndices,
            retrieveBlackPixels(
                rclcCollateralTimeSeriesOps.getBlackLevelFsIds(),
                rclcCollateralTimeSeries)));
        log.info("Retrieving reverseClockedMaskedSmearPixels.");
        dynablackInputs.setReverseClockedMaskedSmearPixels(trimReverseClockedSmearPixels(
            validIndices,
            retrieveSmearPixels(
                rclcCollateralTimeSeriesOps.getMaskedSmearFsIds(),
                rclcCollateralTimeSeries)));
        log.info("Retrieving reverseClockedVirtualSmearPixels.");
        dynablackInputs.setReverseClockedVirtualSmearPixels(trimReverseClockedSmearPixels(
            validIndices,
            retrieveSmearPixels(
                rclcCollateralTimeSeriesOps.getVirtualSmearFsIds(),
                rclcCollateralTimeSeries)));
        log.info("Retrieving reverseClockedBackgroundPixels.");
        dynablackInputs.setReverseClockedBackgroundPixels(trimReverseClockedCalInputPixels(
            validIndices, retrieveRclcBackgroundPixels(rclcSciencePixelOps)));
        log.info("Retrieving reverseClockedTargetPixels.");
        dynablackInputs.setReverseClockedTargetPixels(trimReverseClockedCalInputPixels(
            validIndices, retrieveRclcTargetPixels(rclcSciencePixelOps)));
    }

    private CollateralTimeSeriesOperations getCollateralTimeSeriesOperations(
        TargetTableLog targetTableLog) {
        return getCollateralTimeSeriesOperations(targetTableLog,
            new PixelTimeSeriesOperations());
    }

    private CollateralTimeSeriesOperations getRclcCollateralTimeSeriesOperations(
        TargetTableLog targetTableLog) {
        return getCollateralTimeSeriesOperations(
            targetTableLog,
            new RclcPixelTimeSeriesOperations(DataSetType.Collateral,
                task.getCcdModule(), task.getCcdOutput()));
    }

    private CollateralTimeSeriesOperations getCollateralTimeSeriesOperations(
        TargetTableLog targetTableLog,
        PixelTimeSeriesReader pixelTimeSeriesReader) {
        CollateralTimeSeriesOperations collateralTimeSeriesOps = new CollateralTimeSeriesOperations(
            cadenceType, targetTableLog.getTargetTable()
                .getExternalId(), ccdModule, ccdOutput, pixelTimeSeriesReader);
        collateralTimeSeriesOps.setPmrfOperations(new PmrfOperations());

        return collateralTimeSeriesOps;
    }

    private TargetTableLog retrieveTargetTableLog(TargetType targetType) {
        List<TargetTableLog> targetTableLogs = retrieveTargetTableLog(
            targetType, new LogCrud(), startCadence, endCadence);
        if (targetTableLogs.size() != 1) {
            throw new IllegalArgumentException(
                "The cadence range must be associated with exactly one targetTableLog."
                    + "\n  targetTableType: " + targetType
                    + "\n  startCadence: " + startCadence + "\n  endCadence: "
                    + endCadence + "\n  targetTableCount: "
                    + targetTableLogs.size());
        }

        return targetTableLogs.get(0);
    }

    private TargetTableLog retrieveRclcTargetTableLog(TargetType targetType) {
        List<TargetTableLog> targetTableLogs = retrieveTargetTableLog(
            targetType, new RclcPixelLogCrud(), rclcStartCadence,
            rclcEndCadence);

        TargetTableLog rclcTargetTableLog = null;
        if (!targetTableLogs.isEmpty()) {
            rclcTargetTableLog = targetTableLogs.get(0);

            if (rclcTargetTableLog.getTargetTable() == null) {
                if (targetType == TargetType.BACKGROUND) {
                    rclcTargetTableLog = null;
                } else {
                    throw new IllegalArgumentException(
                        "rclcTargetTable cannot be null."
                            + "\n  startCadence: " + rclcStartCadence
                            + "\n  endCadence: " + rclcEndCadence);
                }
            }
        }

        return rclcTargetTableLog;
    }

    private List<TargetTableLog> retrieveTargetTableLog(TargetType targetType,
        PixelLogCrud pixelLogCrud, int startCadence, int endCadence) {
        TargetCrud targetCrud = new TargetCrud();
        targetCrud.setPixelLogCrud(pixelLogCrud);

        List<TargetTableLog> targetTableLogs = targetCrud.retrieveTargetTableLogs(
            targetType, startCadence, endCadence);

        return targetTableLogs;
    }

    private List<AncillaryEngineeringData> retrieveAncillaryEngineeringDataStruct(
        TimestampSeries cadenceTimes) {
        AncillaryOperations ancillaryOperations = new AncillaryOperations();
        List<AncillaryEngineeringData> ancillaryData = ancillaryOperations.retrieveAncillaryEngineeringData(
            dynablackModuleParameters.getAncillaryEngineeringMnemonics(),
            cadenceTimes.startMjd(), cadenceTimes.endMjd());

        return ancillaryData;
    }

    private List<FitsImage> retrieveRawFfis() throws FitsException, IOException {
        List<FitsImage> fitsImages = newArrayList();
        for (String rawFfiFileTimestamp : dynablackModuleParameters.getRawFfiFileTimestamps()) {
            FsId ffiFsId = DrFsIdFactory.getSingleChannelFfiFile(
                rawFfiFileTimestamp, FfiType.ORIG, ccdModule, ccdOutput);

            FfiReader ffiReader = new FfiReader();
            FfiModOut ffiModOut = ffiReader.readFFiModOut(ffiFsId);

            FitsImage fitsImage = ffiModOut.toFitsImage();

            fitsImages.add(fitsImage);
        }

        return fitsImages;
    }

    private TimestampSeries retrieveCadenceTimes(CadenceType cadenceType,
        int startCadence, int endCadence) {
        return retrieveTimestampSeries(cadenceType, startCadence, endCadence,
            new LogCrud());
    }

    private TimestampSeries retrieveReverseClockedCadenceTimes(
        CadenceType cadenceType, int startCadence, int endCadence) {
        return retrieveTimestampSeries(cadenceType, startCadence, endCadence,
            new RclcPixelLogCrud());
    }

    private TimestampSeries retrieveTimestampSeries(CadenceType cadenceType,
        int startCadence, int endCadence, PixelLogCrud pixelLogCrud) {
        MjdToCadence mjdToCadence = new MjdToCadence(pixelLogCrud,
            new DataAnomalyOperations(
                new ModelMetadataRetrieverPipelineInstance(pipelineInstance)),
            cadenceType);
        TimestampSeries timestampSeries = mjdToCadence.cadenceTimes(
            startCadence, endCadence);

        return timestampSeries;
    }

    private List<CalInputPixelTimeSeries> retrieveBackgroundPixels(
        SciencePixelOperations sciencePixelOps) {
        return retrieveCalInputPixelTimeSeries(
            sciencePixelOps.getBackgroundPixels(),
            new PixelTimeSeriesOperations(), startCadence, endCadence);
    }

    private List<CalInputPixelTimeSeries> retrieveRclcBackgroundPixels(
        SciencePixelOperations sciencePixelOps) {
        return retrieveCalInputPixelTimeSeries(
            sciencePixelOps.getBackgroundPixels(),
            new RclcPixelTimeSeriesOperations(DataSetType.Background,
                task.getCcdModule(), task.getCcdOutput()), rclcStartCadence,
            rclcEndCadence);
    }

    private List<CalInputPixelTimeSeries> retrieveRclcTargetPixels(
        SciencePixelOperations sciencePixelOps) {
        return retrieveCalInputPixelTimeSeries(
            sciencePixelOps.getTargetPixels(),
            new RclcPixelTimeSeriesOperations(DataSetType.Target,
                task.getCcdModule(), task.getCcdOutput()), rclcStartCadence,
            rclcEndCadence);
    }

    private List<CalInputPixelTimeSeries> retrieveCalInputPixelTimeSeries(
        Set<Pixel> pixels, PixelTimeSeriesReader pixelTimeSeriesReader,
        int startCadence, int endCadence) {
        Map<FsId, Pixel> fsIdToPixel = newHashMap();
        for (Pixel pixel : pixels) {
            fsIdToPixel.put(pixel.getFsId(), pixel);
        }

        TimeSeriesCollator pixelCollator = new TimeSeriesCollator(pixels,
            pixelTimeSeriesReader, MAX_PIXEL_COUNT, MAX_PIXEL_COUNT,
            startCadence, endCadence);

        IntTimeSeries[] timeSeriesArray = pixelCollator.nextChunk();
        if (pixelCollator.hasNext()) {
            throw new IllegalStateException(
                "The pixelCollator must have exactly one chunk, but "
                    + "the pixelCollator actually had more than one chunk.");
        }

        List<CalInputPixelTimeSeries> calTimeSeriesList = newArrayList();
        for (IntTimeSeries timeSeries : timeSeriesArray) {
            Pixel pixel = fsIdToPixel.get(timeSeries.id());
            CalInputPixelTimeSeries calTimeSeries = new CalInputPixelTimeSeries(
                pixel.getRow(), pixel.getColumn(), timeSeries.iseries(),
                timeSeries.getGapIndicators());

            calTimeSeriesList.add(calTimeSeries);
        }
        return calTimeSeriesList;
    }

    private List<BlackTimeSeries> retrieveBlackPixels(Set<FsId> blackFsIds,
        IntTimeSeries[] collateralTimeSeries) {
        List<BlackTimeSeries> blackTimeSeriesList = newArrayList();
        for (IntTimeSeries timeSeries : collateralTimeSeries) {
            if (blackFsIds.contains(timeSeries.id())) {
                blackTimeSeriesList.add(new BlackTimeSeries(timeSeries));
            }
        }

        return blackTimeSeriesList;
    }

    private List<SmearTimeSeries> retrieveSmearPixels(Set<FsId> smearFsIds,
        IntTimeSeries[] collateralTimeSeries) {
        List<SmearTimeSeries> smearTimeSeriesList = newArrayList();
        for (IntTimeSeries timeSeries : collateralTimeSeries) {
            if (smearFsIds.contains(timeSeries.id())) {
                smearTimeSeriesList.add(new SmearTimeSeries(timeSeries));
            }
        }

        return smearTimeSeriesList;
    }

    private List<CalInputPixelTimeSeries> retrieveArpTargetPixels(
        SciencePixelOperations sciencePixelOps) {
        Set<Pair<Integer, Integer>> arpPixelCoordinates = getArpPixelCoordinates();
        if (arpPixelCoordinates.isEmpty()) {
            throw new IllegalArgumentException("arpPixels cannot be empty.");
        }

        Set<Pixel> targetPixels = sciencePixelOps.getTargetPixels();

        Set<Pixel> arpPixels = newHashSet();
        for (Pixel targetPixel : targetPixels) {
            Pair<Integer, Integer> pair = Pair.of(targetPixel.getRow(),
                targetPixel.getColumn());
            if (arpPixelCoordinates.contains(pair)) {
                arpPixels.add(targetPixel);
            }
        }

        Map<FsId, Pixel> fsIdToPixel = newHashMap();
        for (Pixel pixel : arpPixels) {
            fsIdToPixel.put(pixel.getFsId(), pixel);
        }

        TimeSeriesCollator pixelCollator = new TimeSeriesCollator(arpPixels,
            new PixelTimeSeriesOperations(), MAX_PIXEL_COUNT, MAX_PIXEL_COUNT,
            startCadence, endCadence);

        IntTimeSeries[] timeSeriesArray = pixelCollator.nextChunk();
        if (pixelCollator.hasNext()) {
            throw new IllegalStateException(
                "pixelCollator must have exactly one chunk, but "
                    + "the pixelCollator actually had more than one chunk.");
        }

        List<CalInputPixelTimeSeries> calTimeSeriesList = newArrayList();
        for (IntTimeSeries timeSeries : timeSeriesArray) {
            Pixel pixel = fsIdToPixel.get(timeSeries.id());
            CalInputPixelTimeSeries calTimeSeries = new CalInputPixelTimeSeries(
                pixel.getRow(), pixel.getColumn(), timeSeries.iseries(),
                timeSeries.getGapIndicators());

            calTimeSeriesList.add(calTimeSeries);
        }

        return calTimeSeriesList;
    }

    private Set<Pair<Integer, Integer>> getArpPixelCoordinates() {
        TargetCrud targetCrud = new TargetCrud();
        List<TargetTableLog> targetTableLogs = targetCrud.retrieveTargetTableLogs(
            TargetType.valueOf(cadenceType), startCadence, endCadence);
        if (targetTableLogs.isEmpty()) {
            throw new IllegalStateException(
                String.format(
                    "Long cadence target table missing for cadence interval [%d, %d].",
                    startCadence, endCadence));
        }
        if (targetTableLogs.size() > 1) {
            throw new IllegalStateException(String.format(
                "Found %s target tables for cadence interval [%d, %d].",
                targetTableLogs.size(), startCadence, endCadence));
        }
        TargetTableLog targetTableLog = targetTableLogs.get(0);

        List<ObservedTarget> observedTargets = targetCrud.retrieveObservedTargets(
            targetTableLog.getTargetTable(), ccdModule, ccdOutput);
        Set<Pair<Integer, Integer>> arpPixelCoordinates = newHashSet();
        for (ObservedTarget observedTarget : observedTargets) {
            for (String label : observedTarget.getLabels()) {
                if (TargetLabel.isArpLabel(label)) {
                    for (TargetDefinition targetDef : observedTarget.getTargetDefinitions()) {
                        for (Offset offset : targetDef.getMask()
                            .getOffsets()) {
                            int row = targetDef.getReferenceRow()
                                + offset.getRow();
                            int col = targetDef.getReferenceColumn()
                                + offset.getColumn();
                            arpPixelCoordinates.add(Pair.of(row, col));
                        }
                    }
                }
            }
        }

        return arpPixelCoordinates;
    }

    private TwoDBlackModel retrieveTwoDBlackModel(TimestampSeries cadenceTimes) {
        TwoDBlackOperations twoDBlackOperations = new TwoDBlackOperations();
        TwoDBlackModel twoDBlackModel = twoDBlackOperations.retrieveTwoDBlackModel(
            cadenceTimes.startMjd(), cadenceTimes.endMjd(), ccdModule,
            ccdOutput);

        return twoDBlackModel;
    }

    private UndershootModel retrieveUndershootModel(TimestampSeries cadenceTimes) {
        UndershootOperations undershootOperations = new UndershootOperations();
        UndershootModel undershootModel = undershootOperations.retrieveUndershootModel(
            cadenceTimes.startMjd(), cadenceTimes.endMjd());

        return undershootModel;
    }

    private GainModel retrieveGainModel(TimestampSeries cadenceTimes) {
        GainOperations gainOperations = new GainOperations();
        GainModel gainModel = gainOperations.retrieveGainModel(
            cadenceTimes.startMjd(), cadenceTimes.endMjd());

        return gainModel;
    }

    private FlatFieldModel retrieveFlatFieldModel(TimestampSeries cadenceTimes) {
        FlatFieldOperations flatFieldOperations = new FlatFieldOperations();
        FlatFieldModel flatFieldModel = flatFieldOperations.retrieveFlatFieldModel(
            cadenceTimes.startMjd(), cadenceTimes.endMjd(), ccdModule,
            ccdOutput);

        return flatFieldModel;
    }

    private LinearityModel retrieveLinearityModel(TimestampSeries cadenceTimes) {
        LinearityOperations linearityOperations = new LinearityOperations();
        LinearityModel linearityModel = linearityOperations.retrieveLinearityModel(
            ccdModule, ccdOutput, cadenceTimes.startMjd(),
            cadenceTimes.endMjd());

        return linearityModel;
    }

    private ReadNoiseModel retrieveReadNoiseModel(TimestampSeries cadenceTimes) {
        ReadNoiseOperations readNoiseOperations = new ReadNoiseOperations();
        ReadNoiseModel readNoiseModel = readNoiseOperations.retrieveReadNoiseModel(
            cadenceTimes.startMjd(), cadenceTimes.endMjd());

        return readNoiseModel;
    }

    private List<RequantTable> retrieveRequantTables(
        TimestampSeries cadenceTimes) {
        CompressionCrud compressionCrud = new CompressionCrud();
        List<gov.nasa.kepler.hibernate.gar.RequantTable> hRequantTables = compressionCrud.retrieveRequantTables(
            cadenceTimes.startMjd(), cadenceTimes.endMjd());

        List<RequantTable> rv = newArrayList();
        for (gov.nasa.kepler.hibernate.gar.RequantTable hRequant : hRequantTables) {
            Pair<Double, Double> startEndTimes = compressionCrud.retrieveStartEndTimes(hRequant.getExternalId());
            RequantTable persistableRequant = new RequantTable(hRequant,
                startEndTimes.left);

            rv.add(persistableRequant);
        }

        if (rv.size() == 0) {
            throw new IllegalArgumentException(
                "The list of requant tables must not be empty.");
        }

        return rv;
    }

    private List<HuffmanTable> retrieveHuffmanTables(
        TimestampSeries cadenceTimes) {
        CompressionCrud compressionCrud = new CompressionCrud();
        List<gov.nasa.kepler.hibernate.gar.HuffmanTable> hHuffmanTable = compressionCrud.retrieveHuffmanTables(
            cadenceTimes.startMjd(), cadenceTimes.endMjd());

        List<HuffmanTable> rv = newArrayList();
        for (gov.nasa.kepler.hibernate.gar.HuffmanTable hht : hHuffmanTable) {
            Pair<Double, Double> startEndTime = compressionCrud.retrieveStartEndTimes(hht.getExternalId());
            HuffmanTable persistableTable = new HuffmanTable(hht,
                startEndTime.left);
            rv.add(persistableTable);
        }

        if (rv.size() == 0) {
            throw new IllegalArgumentException(
                "The list of huffman tables must not be empty.");
        }

        return rv;
    }

    private List<ConfigMap> retrieveConfigMaps(TimestampSeries cadenceTimes) {
        ConfigMapOperations configMapOperations = new ConfigMapOperations();
        List<ConfigMap> cMaps = configMapOperations.retrieveAllConfigMaps(
            CadenceType.LONG, cadenceTimes.startMjd(), cadenceTimes.endMjd());
        if (cMaps == null || cMaps.size() == 0) {
            throw new IllegalArgumentException(
                "The list of config maps must not be empty.");
        }

        return cMaps;
    }

    private Persistable createOutputs() {
        return new DynablackOutputs();
    }

    private void storeOutputs(Persistable outputs) {
        log.info("Storing outputs.");

        DynablackOutputs dynablackOutputs = (DynablackOutputs) outputs;

        storeDynamicTwoDBlackBlob(dynablackOutputs.getDynablackBlobFilename());
        storeRollingBandArtifactFlags(dynablackOutputs.getRollingBandArtifactFlags());
    }

    private void storeDynamicTwoDBlackBlob(String blobFileName) {
        DynamicTwoDBlackBlobMetadata dynamicTwoDBlackBlobMetadata = new DynamicTwoDBlackBlobMetadata(
            pipelineTask.getId(), ccdModule, ccdOutput, startCadence,
            endCadence, FilenameUtils.getExtension(blobFileName));

        DynablackCrud dynablackCrud = new DynablackCrud();
        dynablackCrud.createDynamicTwoDBlackBlobMetadata(dynamicTwoDBlackBlobMetadata);

        FileStoreClientFactory.getInstance()
            .writeBlob(BlobOperations.getFsId(dynamicTwoDBlackBlobMetadata),
                pipelineTask.getId(),
                new File(getMatlabWorkingDir(), blobFileName));
    }

    private void storeRollingBandArtifactFlags(
        List<RollingBandArtifactFlags> rollingBandArtifactFlagsList) {

        List<IntTimeSeries> intTimeSeriesList = newArrayList();
        List<DoubleTimeSeries> doubleTimeSeriesList = newArrayList();
        for (RollingBandArtifactFlags rollingBandArtifactFlags : rollingBandArtifactFlagsList) {
            intTimeSeriesList.add(new IntTimeSeries(
                rollingBandArtifactFlags.getRowFsId(ccdModule, ccdOutput),
                rollingBandArtifactFlags.getFlags()
                    .getValues(), startCadence, endCadence,
                rollingBandArtifactFlags.getFlags()
                    .getGapIndicators(), pipelineTask.getId()));
            doubleTimeSeriesList.add(new DoubleTimeSeries(
                rollingBandArtifactFlags.getVariationFsId(ccdModule, ccdOutput),
                rollingBandArtifactFlags.getVariationLevel()
                    .getValues(), startCadence, endCadence,
                rollingBandArtifactFlags.getVariationLevel()
                    .getGapIndicators(), pipelineTask.getId()));
        }

        if (!intTimeSeriesList.isEmpty() || !doubleTimeSeriesList.isEmpty()) {
            IntTimeSeries[] intTimeSeries = intTimeSeriesList.toArray(new IntTimeSeries[intTimeSeriesList.size()]);
            DoubleTimeSeries[] doubleTimeSeries = doubleTimeSeriesList.toArray(new DoubleTimeSeries[doubleTimeSeriesList.size()]);

            TimeSeries[] timeSeries = addAllTimeSeries(intTimeSeries,
                doubleTimeSeries);

            FileStoreClientFactory.getInstance()
                .writeTimeSeries(timeSeries);
        }
    }

    protected TimeSeries[] addAllTimeSeries(TimeSeries[] timeSeries1,
        TimeSeries[] timeSeries2) {

        if (timeSeries1 == null || timeSeries1.length < 1) {
            if (timeSeries2 == null || timeSeries2.length < 1) {
                return new TimeSeries[0];
            }
            return timeSeries2;
        } else if (timeSeries2 == null || timeSeries2.length < 1) {
            return timeSeries1;
        }

        TimeSeries[] timeSeries = new TimeSeries[timeSeries1.length
            + timeSeries2.length];
        for (int index = 0; index < timeSeries1.length; index++) {
            timeSeries[index] = timeSeries1[index];
        }
        for (int index = 0; index < timeSeries2.length; index++) {
            timeSeries[timeSeries1.length + index] = timeSeries2[index];
        }

        return timeSeries;
    }

    private File getMatlabWorkingDir() {
        if (matlabWorkingDir == null) {
            matlabWorkingDir = allocateWorkingDir(pipelineTask);
        }

        return matlabWorkingDir;
    }
}
