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

import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.common.AncillaryPipelineData;
import gov.nasa.kepler.common.pi.AncillaryEngineeringParameters;
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.common.pi.TpsType;
import gov.nasa.kepler.common.pi.TpsTypeParameters;
import gov.nasa.kepler.fc.invalidpixels.PixelOperations;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.PlannedTarget.TargetLabel;
import gov.nasa.kepler.hibernate.fc.Pixel;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.mc.BadPixel;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.kepler.ppa.AbstractPpaPipelineModule;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * PPA:PMD pipeline module.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard (fgirouard@arc.nasa.gov)
 */
public class PmdPipelineModule extends AbstractPpaPipelineModule {

    private static final Log log = LogFactory.getLog(PmdPipelineModule.class);

    public static final String MODULE_NAME = "pmd";

    private CelestialObjectOperations celestialObjectOperations;
    private PixelOperations pixelOperations = new PixelOperations();
    private TpsCrud tpsCrud;

    private int ccdModule;
    private int ccdOutput;

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return ModOutCadenceUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> requiredParameters = new ArrayList<Class<? extends Parameters>>();
        requiredParameters.add(PmdModuleParameters.class);
        requiredParameters.add(AncillaryEngineeringParameters.class);
        requiredParameters.add(AncillaryPipelineParameters.class);
        // requiredParameters.add(CustomTargetParameters.class);
        requiredParameters.add(FluxTypeParameters.class);
        requiredParameters.add(TpsTypeParameters.class);

        return requiredParameters;
    }

    @Override
    protected void initializeTask() {
        ModOutCadenceUowTask task = pipelineTask.uowTaskInstance();
        log.info("uow=" + task);

        startCadence = task.getStartCadence();
        endCadence = task.getEndCadence();
        ccdModule = task.getCcdModule();
        ccdOutput = task.getCcdOutput();
    }

    @Override
    protected Persistable createInputs() {
        setInputs(new PmdInputs());

        return getInputs();
    }

    @Override
    protected void retrieveInputs(Persistable inputs, TargetTable targetTable) {

        PmdInputs pmdInputs = (PmdInputs) inputs;

        TimestampSeries cadenceTimes = retrieveCadenceTimes();
        double startMjd = cadenceTimes.startMjd();
        double endMjd = cadenceTimes.endMjd();

        pmdInputs.setCcdModule(ccdModule);
        pmdInputs.setCcdOutput(ccdOutput);
        pmdInputs.setPmdModuleParameters(getPmdModuleParameters());
        pmdInputs.setSpacecraftConfigMaps(retrieveConfigMaps(startMjd, endMjd));

        List<ObservedTarget> targets = retrieveObservedTargets(targetTable);
        pmdInputs.setCadenceTimes(cadenceTimes);
        pmdInputs.setRaDec2PixModel(retrieveRaDec2PixModel(startMjd, endMjd));
        pmdInputs.setInputTsData(retrieveInputTsData(targets));
        pmdInputs.setCdppTsData(retrieveCdppTsData(targets));
        pmdInputs.setBadPixels(retrieveBadPixels(startMjd, endMjd));
        pmdInputs.setBackgroundBlobs(retrieveBackgroundBlobs(ccdModule,
            ccdOutput));
        pmdInputs.setMotionBlobs(retrieveMotionBlobs(ccdModule, ccdOutput));
        pmdInputs.setAncillaryEngineeringParameters(getAncillaryEngineeringParameters());
        pmdInputs.setAncillaryEngineeringData(retrieveAncillaryEngineeringData(
            pmdInputs.getAncillaryEngineeringParameters(), startMjd, endMjd));
        pmdInputs.setAncillaryPipelineParameters(getAncillaryPipelineParameters());
        pmdInputs.setAncillaryPipelineData(retrieveAncillaryPipelineData(
            pmdInputs.getAncillaryPipelineParameters(), targetTable,
            cadenceTimes));
    }

    private PmdModuleParameters getPmdModuleParameters() {
        return pipelineTask.getParameters(PmdModuleParameters.class);
    }

    private PmdInputTsData retrieveInputTsData(List<ObservedTarget> targets) {
        List<FsId> fsIds = PmdInputTsData.getFsIds(ccdModule, ccdOutput,
            targets);
        Map<FsId, FloatTimeSeries> timeSeriesByFsId = retrieveFloatTimeSeries(fsIds);
        PmdInputTsData inputTsData = new PmdInputTsData();
        inputTsData.setTimeSeries(ccdModule, ccdOutput, targets,
            timeSeriesByFsId);

        return inputTsData;
    }

    private List<PmdCdppTsData> retrieveCdppTsData(List<ObservedTarget> targets) {
        FluxType fluxType = getFluxType();
        TpsType tpsType = getTpsType();
        List<FsId> fsIds = new ArrayList<FsId>();
        List<FsId> intFsIds = new ArrayList<FsId>();

        log.info("Retrieving CDPP time series data.");
        final TpsCrud tpsCrud = getTpsCrud();
        /*
        final PipelineInstance pipelineInstance =
            tpsCrud.retrieveLatestTpsRun(tpsType);
        */
        final ModOutCadenceUowTask task = pipelineTask.uowTaskInstance();

        final int startCadence = task.getStartCadence();
        final int endCadence = task.getEndCadence();
        final PipelineInstance pipelineInstance =
            tpsCrud.retrieveLatestTpsRunForCadenceRange(tpsType, startCadence, endCadence);

        final long tpsPipelineInstanceId = pipelineInstance.getId();
        
        for (ObservedTarget target : targets) {
            if (target.containsLabel(TargetLabel.PLANETARY) ||
                target.containsLabel(TargetLabel.CDPP_TARGET)) {
                fsIds.addAll(PmdCdppTsData.getFsIds(tpsPipelineInstanceId, target.getKeplerId(),
                    fluxType, tpsType));
                intFsIds.addAll(PmdCdppTsData.getIntFsIds(target.getKeplerId(),
                    fluxType));
            }
        }

        Map<FsId, TimeSeries> timeSeriesByFsId = new HashMap<FsId, TimeSeries>();
        timeSeriesByFsId.putAll(retrieveFloatTimeSeries(fsIds));
        timeSeriesByFsId.putAll(retrieveIntTimeSeries(intFsIds));

        List<PmdCdppTsData> cdppTsDataList = new ArrayList<PmdCdppTsData>();
        for (ObservedTarget target : targets) {
            if (PmdCdppTsData.containsTimeSeries(tpsPipelineInstanceId, target.getKeplerId(),
                fluxType, tpsType, timeSeriesByFsId)) {
                CelestialObjectParameters celestialObjectParameters = getCelestialObjectOperations().retrieveCelestialObjectParameters(
                    target.getKeplerId());
                if (celestialObjectParameters != null) {
                    PmdCdppTsData cdppTsData = new PmdCdppTsData(
                        celestialObjectParameters.getKeplerId(),
                        (float) celestialObjectParameters.getKeplerMag()
                            .getValue(),
                        (float) celestialObjectParameters.getEffectiveTemp()
                            .getValue(),
                        (float) celestialObjectParameters.getLog10SurfaceGravity()
                            .getValue());
                    cdppTsData.setTimeSeries(tpsPipelineInstanceId, fluxType, tpsType, startCadence,
                        endCadence - startCadence + 1, timeSeriesByFsId);
                    cdppTsDataList.add(cdppTsData);
                }
            }
        }
        log.info("Done retrieving CDPP time series data.");
        return cdppTsDataList;
    }

    private FluxType getFluxType() {
        FluxTypeParameters fluxTypeParameters = pipelineTask.getParameters(FluxTypeParameters.class);
        FluxType fluxType = FluxType.valueOf(fluxTypeParameters.getFluxType());

        return fluxType;
    }

    private TpsType getTpsType() {
        TpsTypeParameters fluxTypeParameters = pipelineTask.getParameters(TpsTypeParameters.class);
        TpsType fluxType = TpsType.valueOf(fluxTypeParameters.getTpsType());

        return fluxType;
    }

    private List<ObservedTarget> retrieveObservedTargets(TargetTable targetTable) {
        log.info("Retrieving observed targets...");
        List<ObservedTarget> targets = getTargetCrud().retrieveObservedTargets(
            targetTable, ccdModule, ccdOutput);
        getDatabaseService().evictAll(targets);
        log.info("Retrieving observed targets...done (" + targets.size()
            + " targets)");

        return targets;
    }

    private List<BadPixel> retrieveBadPixels(double startMjd, double endMjd) {
        log.info("Retrieving bad pixel data");
        Pixel[] pixels = pixelOperations.retrievePixelRange(ccdModule,
            ccdOutput, startMjd, endMjd);

        List<BadPixel> badPixels = new ArrayList<BadPixel>();
        for (Pixel pixel : pixels) {
            badPixels.add(new BadPixel(pixel));
        }

        return badPixels;
    }

    private AncillaryEngineeringParameters getAncillaryEngineeringParameters() {
        return pipelineTask.getParameters(AncillaryEngineeringParameters.class);
    }

    private List<AncillaryEngineeringData> retrieveAncillaryEngineeringData(
        AncillaryEngineeringParameters ancillaryEngineeringParameters,
        double startMjd, double endMjd) {

        log.info("Retrieving ancillary engineering data");

        List<AncillaryEngineeringData> ancillaryEngineeringData = new ArrayList<AncillaryEngineeringData>();
        String[] mnemonics = ancillaryEngineeringParameters.getMnemonics();
        if (mnemonics == null || mnemonics.length == 0) {
            return ancillaryEngineeringData;
        }

        ancillaryEngineeringData = retrieveAncillaryEngineeringData(startMjd,
            endMjd, mnemonics);

        return ancillaryEngineeringData;
    }

    private AncillaryPipelineParameters getAncillaryPipelineParameters() {
        return pipelineTask.getParameters(AncillaryPipelineParameters.class);
    }

    private List<AncillaryPipelineData> retrieveAncillaryPipelineData(
        AncillaryPipelineParameters ancillaryPipelineParameters,
        TargetTable targetTable, TimestampSeries cadenceTimes) {

        log.info("Retrieving ancillary pipeline data");

        List<AncillaryPipelineData> ancillaryPipelineData = new ArrayList<AncillaryPipelineData>();
        String[] mnemonics = ancillaryPipelineParameters.getMnemonics();
        if (mnemonics == null || mnemonics.length == 0) {
            return ancillaryPipelineData;
        }

        ancillaryPipelineData = retrieveAncillaryPipelineData(mnemonics,
            targetTable, ccdModule, ccdOutput, cadenceTimes);

        return ancillaryPipelineData;
    }

    @Override
    protected Persistable createOutputs() {
        setOutputs(new PmdOutputs());

        return getOutputs();
    }

    @Override
    protected void storeOutputs(Persistable outputs, TargetTable targetTable) {
        PmdOutputs pmdOutputs = (PmdOutputs) outputs;

        storeTsData(pmdOutputs.getOutputTsData());
        storeReports(pmdOutputs.getReport(), targetTable);
        storeMissionReport(pmdOutputs.getReportFilename());

        generateAlerts(pmdOutputs.getReport()
            .alerts());

        updateDataAccountability();
    }

    private void storeTsData(PmdOutputTsData outputTsData) {
        log.info("Preparing to write time series");
        List<FloatTimeSeries> timeSeries = outputTsData.toTimeSeries(ccdModule,
            ccdOutput, startCadence, endCadence, pipelineTask.getId());

        log.info(String.format("Writing %d time series from %d to %d...",
            timeSeries.size(), startCadence, endCadence));
        FileStoreClientFactory.getInstance()
            .writeTimeSeries(timeSeries.toArray(new FloatTimeSeries[0]));
        log.info(String.format("Writing %d time series from %d to %d...done",
            timeSeries.size(), startCadence, endCadence));
    }

    private void storeReports(PmdReport report, TargetTable targetTable) {
        List<gov.nasa.kepler.hibernate.ppa.PmdMetricReport> reports = report.createReports(
            pipelineTask, targetTable, ccdModule, ccdOutput, startCadence,
            endCadence);

        log.info(String.format("Saving %d reports", reports.size()));
        getPpaCrud().createMetricReports(reports);
    }

    private void generateAlerts(Map<List<String>, List<ModuleAlert>> alerts) {
        for (Entry<List<String>, List<ModuleAlert>> type : alerts.entrySet()) {
            generateAlerts(type.getKey()
                .toString(), ccdModule, ccdOutput, type.getValue());
        }
    }

    /**
     * Sets the {@link PixelOperations} object during testing.
     */
    void setPixelOperations(PixelOperations pixelOperations) {
        this.pixelOperations = pixelOperations;
    }

    private CelestialObjectOperations getCelestialObjectOperations() {
        if (celestialObjectOperations == null) {
            boolean customTargetProcessingEnabled = false;
            // Replace the statement above with the following when PMD supports
            // custom targets.
            // boolean customTargetProcessingEnabled =
            // pipelineTask.getParameters(
            // CustomTargetParameters.class)
            // .isProcessingEnabled();
            celestialObjectOperations = new CelestialObjectOperations(
                new ModelMetadataRetrieverPipelineInstance(pipelineInstance),
                !customTargetProcessingEnabled);
        }

        return celestialObjectOperations;
    }

    /**
     * Sets the {@link CelestialObjectOperations} object during testing.
     */
    void setCelestialObjectOperations(
        CelestialObjectOperations celestialObjectOperations) {
        this.celestialObjectOperations = celestialObjectOperations;
    }
    
    private TpsCrud getTpsCrud() {
        if (tpsCrud == null) {
            tpsCrud = new TpsCrud();
        }
        return tpsCrud;
    }
    
    void setTpsCrud(TpsCrud tpsCrud) {
        this.tpsCrud = tpsCrud;
    }
}
