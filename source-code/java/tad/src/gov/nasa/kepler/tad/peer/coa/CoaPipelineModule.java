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

package gov.nasa.kepler.tad.peer.coa;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.MatlabDateFormatter;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.intervals.BlobFileSeriesFactory;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.fc.SaturationOperations;
import gov.nasa.kepler.fc.flatfield.FlatFieldOperations;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.linearity.LinearityOperations;
import gov.nasa.kepler.fc.prf.PrfOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fc.twodblack.TwoDBlackOperations;
import gov.nasa.kepler.fc.undershoot.UndershootOperations;
import gov.nasa.kepler.hibernate.cm.CharacteristicCrud;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.ModOut;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.TargetListSetOperations;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperationsFactory;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.tad.CoaCommon;
import gov.nasa.kepler.mc.tad.CoaObservedTargetRejecter;
import gov.nasa.kepler.mc.tad.DistanceFromEdgeCalculator;
import gov.nasa.kepler.mc.tad.KicEntryData;
import gov.nasa.kepler.mc.tad.PersistableFactory;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.kepler.tad.peer.CoaModuleParameters;
import gov.nasa.kepler.tad.peer.merge.MergePipelineModule;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Computes optimal {@link Aperture}s. Preconditions:
 * {@link MergePipelineModule} has run on the {@link TargetListSet}.
 * Postconditions: {@link Aperture}s are generated for the {@link TargetListSet}
 * .
 * 
 * @author Miles Cote
 */
public class CoaPipelineModule extends MatlabPipelineModule {

    public static final String MODULE_NAME = "coa";

    private static final Log log = LogFactory.getLog(CoaPipelineModule.class);

    private PipelineInstance pipelineInstance;
    private PipelineTask pipelineTask;

    private ModOut modOut;
    private TargetListSet targetListSet;
    private TargetListSet associatedLcTargetListSet;
    private List<ObservedTarget> observedTargets;
    private List<ObservedTarget> observedTargetsCustom;

    private File matlabWorkingDir;
    private TadParameters tadParameters;

    private final TargetCrud targetCrud;
    private final TargetSelectionCrud targetSelectionCrud;
    private final KicCrud kicCrud;
    private final CharacteristicCrud characteristicCrud;
    private final RaDec2PixOperations raDec2PixOperations;
    private final ReadNoiseOperations readNoiseOperations;
    private final GainOperations gainOperations;
    private final SaturationOperations saturationOperations;
    private final TwoDBlackOperations twoDBlackOperations;
    private final PrfOperations prfOperations;
    private final LinearityOperations linearityOperations;
    private final UndershootOperations undershootOperations;
    private final FlatFieldOperations flatFieldOperations;
    private final BlobOperations blobOperations;
    private final LogCrud logCrud;
    private final CoaObservedTargetRejecter coaObservedTargetRejecter;
    private final PersistableFactory persistableFactory;
    private final BlobFileSeriesFactory blobFileSeriesFactory;
    private final CelestialObjectOperationsFactory celestialObjectOperationsFactory;
    private final DistanceFromEdgeCalculator distanceFromEdgeCalculator;

    private List<KicEntryData> kicEntryData;

    public CoaPipelineModule() {
        this(new TargetCrud(), new TargetSelectionCrud(), new KicCrud(),
            new CharacteristicCrud(), new RaDec2PixOperations(),
            new ReadNoiseOperations(), new GainOperations(),
            new SaturationOperations(), new TwoDBlackOperations(),
            new PrfOperations(), new LinearityOperations(),
            new UndershootOperations(), new FlatFieldOperations(),
            new BlobOperations(), new LogCrud(),
            new CoaObservedTargetRejecter(), new PersistableFactory(),
            new BlobFileSeriesFactory(),
            new CelestialObjectOperationsFactory(),
            new DistanceFromEdgeCalculator(), null);
    }

    CoaPipelineModule(TargetCrud targetCrud,
        TargetSelectionCrud targetSelectionCrud, KicCrud kicCrud,
        CharacteristicCrud characteristicCrud,
        RaDec2PixOperations raDec2PixOperations,
        ReadNoiseOperations readNoiseOperations, GainOperations gainOperations,
        SaturationOperations saturationOperations,
        TwoDBlackOperations twoDBlackOperations, PrfOperations prfOperations,
        LinearityOperations linearityOperations,
        UndershootOperations undershootOperations,
        FlatFieldOperations flatFieldOperations, BlobOperations blobOperations,
        LogCrud logCrud, CoaObservedTargetRejecter coaObservedTargetRejecter,
        PersistableFactory persistableFactory,
        BlobFileSeriesFactory blobFileSeriesFactory,
        CelestialObjectOperationsFactory celestialObjectOperationsFactory,
        DistanceFromEdgeCalculator distanceFromEdgeCalculator,
        File matlabWorkingDir) {
        this.targetCrud = targetCrud;
        this.targetSelectionCrud = targetSelectionCrud;
        this.kicCrud = kicCrud;
        this.characteristicCrud = characteristicCrud;
        this.raDec2PixOperations = raDec2PixOperations;
        this.readNoiseOperations = readNoiseOperations;
        this.gainOperations = gainOperations;
        this.saturationOperations = saturationOperations;
        this.twoDBlackOperations = twoDBlackOperations;
        this.prfOperations = prfOperations;
        this.linearityOperations = linearityOperations;
        this.undershootOperations = undershootOperations;
        this.flatFieldOperations = flatFieldOperations;
        this.blobOperations = blobOperations;
        this.logCrud = logCrud;
        this.coaObservedTargetRejecter = coaObservedTargetRejecter;
        this.persistableFactory = persistableFactory;
        this.blobFileSeriesFactory = blobFileSeriesFactory;
        this.celestialObjectOperationsFactory = celestialObjectOperationsFactory;
        this.distanceFromEdgeCalculator = distanceFromEdgeCalculator;
        this.matlabWorkingDir = matlabWorkingDir;
    }

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return ModOutUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> requiredParams = newArrayList();
        requiredParams.add(TadParameters.class);
        requiredParams.add(CoaModuleParameters.class);
        requiredParams.add(PlannedSpacecraftConfigParameters.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        try {
            this.pipelineInstance = pipelineInstance;
            this.pipelineTask = pipelineTask;

            ModOutUowTask modOutUowTask = pipelineTask.uowTaskInstance();
            modOut = modOutUowTask.modOut();

            tadParameters = pipelineTask.getParameters(TadParameters.class);
            targetListSet = targetSelectionCrud.retrieveTargetListSet(tadParameters.getTargetListSetName());
            if (tadParameters.getAssociatedLcTargetListSetName() != null) {
                associatedLcTargetListSet = targetSelectionCrud.retrieveTargetListSet(tadParameters.getAssociatedLcTargetListSetName());
            }

            log.info(TargetListSetOperations.getTlsInfo(targetListSet,
                associatedLcTargetListSet));

            validate();

            log.info("[" + getModuleName() + "]set blob operations directory: "
                + getMatlabWorkingDir());
            blobOperations.setOutputDir(getMatlabWorkingDir());

            log.info("Retrieving observed targets...");
            List<ObservedTarget> retrievedObservedTargets = targetCrud.retrieveObservedTargetsPlusRejected(
                targetListSet.getTargetTable(), modOut.getCcdModule(),
                modOut.getCcdOutput(), CoaCommon.INCLUDE_NULL_APERTURES);

            log.info("Retrieved " + retrievedObservedTargets.size()
                + " ObservedTargets.");

            log.info("Setting distanceFromEdge for custom targets.");
            for (ObservedTarget observedTarget : retrievedObservedTargets) {
                if (TargetManagementConstants.isCustomTarget(observedTarget.getKeplerId())) {
                    observedTarget.setDistanceFromEdge(distanceFromEdgeCalculator.getDistanceFromEdge(observedTarget.getAperture()));
                }
            }

            if (targetListSet.getType() == TargetType.LONG_CADENCE) {
                log.info("Determine which targets need to be passed to matlab because they need an aperture...");
                observedTargets = newArrayList();
                observedTargetsCustom = newArrayList();
                for (ObservedTarget observedTarget : retrievedObservedTargets) {
                    if (!TargetManagementConstants.isCustomTarget(observedTarget.getKeplerId())) {
                        if (!observedTarget.isRejected()) {
                            if (observedTarget.getAperture() == null
                                || observedTarget.getAperture()
                                    .getOffsets()
                                    .isEmpty()) {
                                observedTargets.add(observedTarget);
                            }
                        }
                    } else {
                        observedTargetsCustom.add(observedTarget);
                    }
                }

                Persistable inputs = createInputs();

                retrieveInputs(inputs);

                Persistable outputs = createOutputs();

                executeAlgorithm(pipelineTask, inputs, outputs);

                storeOutputs(outputs);
            } else {
                log.info("Running on short cadence, so copying the long cadence optimal apertures.");
                CoaCommon.copyLcApertures(targetCrud, targetListSet, associatedLcTargetListSet,
                    modOut.getCcdModule(), modOut.getCcdOutput(), retrievedObservedTargets,
                    tadParameters.isLcTargetRequiredForScCopy());
            }
        } catch (Throwable e) {
            throw new PipelineException("Unable to process coa task."
                + TargetListSetOperations.getTlsInfo(targetListSet), e);
        }
    }

    private void validate() {
        CoaCommon.validate(targetSelectionCrud, tadParameters.getSupplementalFor(), targetListSet);
    }

    private Persistable createInputs() {
        return persistableFactory.create(CoaInputs.class);
    }

    private void retrieveInputs(Persistable inputs) {
        CoaInputs coaInputs = (CoaInputs) inputs;

        coaInputs.setSpacecraftConfigurationStruct(pipelineTask.getParameters(PlannedSpacecraftConfigParameters.class));
        coaInputs.setCoaConfigurationStruct(pipelineTask.getParameters(CoaModuleParameters.class));

        coaInputs.setModule(modOut.getCcdModule());
        coaInputs.setOutput(modOut.getCcdOutput());

        setStartTime(coaInputs);

        setDuration(coaInputs);

        log.info("Retrieving kic entries...");
        kicEntryData = retrieveKicEntryData();
        coaInputs.setKicEntryData(kicEntryData);

        coaInputs.setTargetKeplerIDList(retrieveKeplerIds());

        coaInputs.setPrfBlob(retrievePrf());

        double startMjd = ModifiedJulianDate.dateToMjd(targetListSet.getStart());
        double endMjd = ModifiedJulianDate.dateToMjd(targetListSet.getEnd());

        setModels(coaInputs, startMjd, endMjd);

        log.info("[" + getModuleName() + "]retrieve motion blobs.");
        coaInputs.setMotionBlobs(retrieveMotionBlobFileSeries(startMjd, endMjd));

        log.info("[" + getModuleName() + "]retrieve background blobs.");
        coaInputs.setBackgroundBlobs(retrieveBackgroundBlobFileSeries(startMjd,
            endMjd));
    }

    private void setModels(CoaInputs coaInputs, double startMjd, double endMjd) {
        coaInputs.setRaDec2PixModel(raDec2PixOperations.retrieveRaDec2PixModel(
            startMjd, endMjd));
        coaInputs.setReadNoiseModel(readNoiseOperations.retrieveReadNoiseModel(
            startMjd, endMjd));
        coaInputs.setGainModel(gainOperations.retrieveGainModel(startMjd,
            endMjd));
        coaInputs.setSaturationModel(saturationOperations.retrieveSaturationModel(
            startMjd, modOut.getCcdModule(), modOut.getCcdOutput()));
        coaInputs.setTwoDBlackModel(twoDBlackOperations.retrieveTwoDBlackModel(
            startMjd, endMjd, modOut.getCcdModule(), modOut.getCcdOutput()));
        coaInputs.setLinearityModel(linearityOperations.retrieveLinearityModel(
            modOut.getCcdModule(), modOut.getCcdOutput(), startMjd, endMjd));
        coaInputs.setUndershootModel(undershootOperations.retrieveUndershootModel(
            startMjd, endMjd));
        coaInputs.setFlatFieldModel(flatFieldOperations.retrieveFlatFieldModel(
            startMjd, endMjd, modOut.getCcdModule(), modOut.getCcdOutput()));
    }

    private void setDuration(CoaInputs coaInputs) {
        long durationMilliseconds = targetListSet.getEnd()
            .getTime() - targetListSet.getStart()
            .getTime();
        double durationDays = (double) durationMilliseconds
            / (double) (1000 * 60 * 60 * 24);
        coaInputs.setDuration(durationDays);
        log.info("duration = " + coaInputs.getDuration());
    }

    private void setStartTime(CoaInputs coaInputs) {
        coaInputs.setStartTime(MatlabDateFormatter.dateFormatter()
            .format(targetListSet.getStart()));
        log.info("startTime = " + coaInputs.getStartTime());
    }

    private Persistable createOutputs() {
        return persistableFactory.create(CoaOutputs.class);
    }

    private void storeOutputs(Persistable outputs) {
        CoaOutputs coaOutputs = (CoaOutputs) outputs;
        
        log.info(String.format("\tccdModule: %d", modOut.getCcdModule()));
        log.info(String.format("\tccdOutput: %d", modOut.getCcdOutput()));
        log.info(String.format("\ttarget list set: %s", targetListSet.getName()));
        
        log.info("kicEntryData.size(); " + kicEntryData.size());
        Map<Integer, KicEntryData> keplerIdToKicEntryData = new HashMap<Integer, KicEntryData>();
        for (KicEntryData kicEntry : kicEntryData) {
            keplerIdToKicEntryData.put(kicEntry.getKeplerId(), kicEntry);
        }

        log.info("Storing optimal apertures...");
        log.info(String.format("\toptimal aperture count: %d",
            coaOutputs.getOptimalApertures()
                .size()));
        CoaCommon.storeOptimalApertures(pipelineTask, this.getClass(),
            targetCrud, targetSelectionCrud, modOut.getCcdModule(),
            modOut.getCcdOutput(), targetListSet, coaObservedTargetRejecter,
            observedTargets, observedTargetsCustom, 
            coaOutputs.getOptimalApertures(), tadParameters.getSupplementalFor(), keplerIdToKicEntryData);

        log.info("Storing image...");
        CoaCommon.storeImage(pipelineTask, targetCrud, modOut.getCcdModule(),
            modOut.getCcdOutput(), targetListSet,
            coaOutputs.getCompleteOutputImage(), coaOutputs.getMinRow(),
            coaOutputs.getMaxRow(), coaOutputs.getMinCol(),
            coaOutputs.getMaxCol());
    }

    private File getMatlabWorkingDir() {
        if (matlabWorkingDir == null) {
            matlabWorkingDir = allocateWorkingDir(pipelineTask);
        }
        return matlabWorkingDir;
    }

    /**
     * Returns {@link KicEntryData}s for a {@link UOWTask} (ccdModule,
     * ccdOutput, season).
     */
    private List<KicEntryData> retrieveKicEntryData() {
        String stringQuarter = tadParameters.getQuarters();
        stringQuarter = stringQuarter.replace("q", "");
        stringQuarter = stringQuarter.replace("Q", "");
        int quarter = Integer.parseInt(stringQuarter);

        return CoaCommon.retrieveKicEntryData(pipelineInstance, kicCrud,
            characteristicCrud, modOut.getCcdModule(), modOut.getCcdOutput(),
            celestialObjectOperationsFactory, persistableFactory,
            targetListSet, quarter);
    }

    private int[] retrieveKeplerIds() {
        int[] keplerIds = new int[observedTargets.size()];
        int i = 0;
        for (ObservedTarget target : observedTargets) {
            keplerIds[i] = target.getKeplerId();
            i++;
        }

        return keplerIds;
    }

    private byte[] retrievePrf() throws ModuleFatalProcessingException {
        byte[] prf = prfOperations.retrieveMostRecentPrfModel(
            modOut.getCcdModule(), modOut.getCcdOutput())
            .getBlob();

        if (prf == null) {
            throw new ModuleFatalProcessingException("No prf was retrieved."
                + TargetListSetOperations.getTlsInfo(targetListSet));
        }

        return prf;
    }

    private BlobFileSeries retrieveMotionBlobFileSeries(final double startMjd,
        final double endMjd) {
        BlobFileSeries blobFileSeries = blobFileSeriesFactory.create();

        CoaModuleParameters coaModuleParameters = pipelineTask.getParameters(CoaModuleParameters.class);
        if (coaModuleParameters.isMotionPolynomialsEnabled()) {
            List<PixelLog> pixelLogs = logCrud.retrievePixelLog(
                CadenceType.LONG.intValue(), startMjd, endMjd);

            if (!pixelLogs.isEmpty()) {
                BlobSeries<String> motionBlobs = blobOperations.retrieveMotionBlobFileSeries(
                    modOut.getCcdModule(), modOut.getCcdOutput(),
                    pixelLogs.get(0)
                        .getCadenceNumber(),
                    pixelLogs.get(pixelLogs.size() - 1)
                        .getCadenceNumber());

                blobFileSeries = blobFileSeriesFactory.create(motionBlobs);
            }
        }

        return blobFileSeries;
    }

    private BlobFileSeries retrieveBackgroundBlobFileSeries(
        final double startMjd, final double endMjd) {
        BlobFileSeries blobFileSeries = blobFileSeriesFactory.create();

        CoaModuleParameters coaModuleParameters = pipelineTask.getParameters(CoaModuleParameters.class);
        if (coaModuleParameters.isBackgroundPolynomialsEnabled()) {
            List<PixelLog> pixelLogs = logCrud.retrievePixelLog(
                CadenceType.LONG.intValue(), startMjd, endMjd);

            if (!pixelLogs.isEmpty()) {
                BlobSeries<String> backgroundBlobs = blobOperations.retrieveBackgroundBlobFileSeries(
                    modOut.getCcdModule(), modOut.getCcdOutput(),
                    pixelLogs.get(0)
                        .getCadenceNumber(),
                    pixelLogs.get(pixelLogs.size() - 1)
                        .getCadenceNumber());

                blobFileSeries = blobFileSeriesFactory.create(backgroundBlobs);
            }
        }

        return blobFileSeries;
    }
}
