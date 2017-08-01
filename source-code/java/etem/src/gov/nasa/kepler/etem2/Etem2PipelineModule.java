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

package gov.nasa.kepler.etem2;

import gov.nasa.kepler.cm.TargetSelectionOperations;
import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.MatlabDateFormatter;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.common.pi.PlannedPhotometerConfigParameters;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.fc.RollTime;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.DataRepoParameters;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.text.DateFormat;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This module executes the MATLAB-compiled version of etem2, which sets up and
 * executes ETEM2 for the module/output specified by the unit of work.
 * 
 * @author tklaus
 * 
 */
public class Etem2PipelineModule extends MatlabPipelineModule {
    private static final Log log = LogFactory.getLog(Etem2PipelineModule.class);

    public static final String MODULE_NAME = "etem2";

    private static final double SECONDS_PER_DAY = 24.0 * 60.0 * 60.0;

    private int ccdModule;
    private int ccdOutput;
    private int runDurationCadences;
    private double etemStartMjd;
    private String cadenceType;
    private String tlsName;
    private Etem2ModuleParameters etem2ModuleParams;
    private Etem2DitherParameters etem2DitherParams;
    private DataGenDirManager dataGenDirManager;
    private DataGenParameters dataGenParams;
    private TadParameters tadParameters;
    private PackerParameters packerParams;
    private PlannedSpacecraftConfigParameters spacecraftConfigParams;
    private PlannedPhotometerConfigParameters photometerConfigParams;
    private TargetListSet rpTls;
    private ModOutRunNumberUowTask unitOfWork;
    private String runDir;

    private TargetSelectionOperations targetSelectionOperations;

    public Etem2PipelineModule() {
    }

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    /*
     * (non-Javadoc)
     * 
     * @see gov.nasa.kepler.pi.module.StandardMatlabPipelineModule#
     * unitOfWorkDefinitionType()
     */
    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return ModOutRunNumberUowTask.class;
    }

    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> p = new ArrayList<Class<? extends Parameters>>();

        p.add(Etem2ModuleParameters.class);
        p.add(Etem2DitherParameters.class);
        p.add(DataGenParameters.class);
        p.add(DataRepoParameters.class);
        p.add(TadParameters.class);
        p.add(PackerParameters.class);
        p.add(PlannedSpacecraftConfigParameters.class);
        p.add(PlannedPhotometerConfigParameters.class);

        return p;
    }

    /**
     * 
     */
    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        targetSelectionOperations = new TargetSelectionOperations();

        IntervalMetricKey key = null;
        try {
            key = IntervalMetric.start();

            setup(pipelineTask);

            if (etem2DitherParams.isDoDithering()) {
                doDithering(pipelineTask);
            } else {
                Etem2OutputManager outputManager = new Etem2OutputManager(
                    dataGenDirManager, pipelineTask.getId());
                outputManager.initializeDirectories(runDir);

                Etem2Inputs inputs = new Etem2Inputs();
                Etem2Outputs outputs = new Etem2Outputs();

                populateInputs(outputManager.getLocalDir(), inputs,
                    etem2ModuleParams.getRaOffset(),
                    etem2ModuleParams.getDecOffset(),
                    etem2ModuleParams.getPhiOffset());

                executeAlgorithm(pipelineTask, inputs, outputs);

                outputManager.publishResults(runDir);
            }

        } catch (Exception e) {
            throw new ModuleFatalProcessingException(
                "failed to execute ETEM, e = " + e, e);
        } finally {
            IntervalMetric.stop("etem.exectime", key);
        }

    }

    private void setup(PipelineTask pipelineTask) throws ParseException {
        unitOfWork = pipelineTask.uowTaskInstance();

        ccdModule = unitOfWork.getCcdModule();
        ccdOutput = unitOfWork.getCcdOutput();

        log.info("UOW: ccdModule=" + ccdModule);
        log.info("UOW: ccdOutput=" + ccdOutput);

        etem2ModuleParams = pipelineTask.getParameters(Etem2ModuleParameters.class);
        etem2DitherParams = pipelineTask.getParameters(Etem2DitherParameters.class);
        dataGenParams = pipelineTask.getParameters(DataGenParameters.class);
        tadParameters = pipelineTask.getParameters(TadParameters.class);
        packerParams = pipelineTask.getParameters(PackerParameters.class);
        dataGenDirManager = new DataGenDirManager(dataGenParams, packerParams,
            tadParameters);

        spacecraftConfigParams = pipelineTask.getParameters(PlannedSpacecraftConfigParameters.class);
        photometerConfigParams = pipelineTask.getParameters(PlannedPhotometerConfigParameters.class);

        /*
         * Make sure that the target list set exists and that the ETEM date
         * range is within the target list set date range
         */
        tlsName = tadParameters.getTargetListSetName();
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        TargetListSet tls = targetSelectionCrud.retrieveTargetListSet(tlsName);
        if (tls == null) {
            throw new ModuleFatalProcessingException(
                "No target list set found for name = " + tlsName);
        }
        
        rpTls = targetSelectionCrud.retrieveTargetListSetByTargetTable(tls.getRefPixTable());

        double tlsStartMjd = ModifiedJulianDate.dateToMjd(tls.getStart());
        double tlsEndMjd = ModifiedJulianDate.dateToMjd(tls.getEnd());

        DateFormat formatter = MatlabDateFormatter.dateFormatter();
        etemStartMjd = ModifiedJulianDate.dateToMjd(formatter.parse(packerParams.getStartDate()));

        if (etemStartMjd < tlsStartMjd || etemStartMjd > tlsEndMjd) {
            log.warn("ETEM start date ("
                + packerParams.getStartDate()
                + ") does not fall within the time range specified by the target list set ("
                + formatter.format(tls.getStart()) + " to "
                + formatter.format(tls.getEnd()) + ")");
        }

        cadenceType = null;
        runDurationCadences = 0;
        switch (tls.getType()) {
            case SHORT_CADENCE:
                cadenceType = Cadence.CadenceType.SHORT.toString()
                    .toLowerCase();
                runDurationCadences = packerParams.getLongCadenceCount()
                    * spacecraftConfigParams.getShortCadencesPerLongCadence();
                break;

            case LONG_CADENCE:
                cadenceType = Cadence.CadenceType.LONG.toString()
                    .toLowerCase();
                runDurationCadences = packerParams.getLongCadenceCount();
                break;

            default:
                throw new IllegalStateException(
                    "Unexpected TargetTable.type = " + tls.getType());
        }

        runDir = EtemUtils.runDir(ccdModule, ccdOutput, "1", cadenceType);

    }

    /**
     * This function returns the absolute path to the ETEM run dir for the
     * previous quarter if Etem2ModuleParams.previousQuarterRunsRootPath is
     * defined.
     * 
     * This function uses {@link RollTimeOperations} to determine the current
     * season, then uses the sky group table to determine the mod/out for the
     * previous season.
     * 
     * @return
     */
    private String previousQuarterRunDir() {
        String prevRunDirPath = etem2ModuleParams.getPreviousQuarterRunsRootPath();

        if (prevRunDirPath == null || prevRunDirPath.isEmpty()) {
            return "";
        }

        RollTimeOperations rollTimeOps = new RollTimeOperations();
        RollTime currentRollTime = rollTimeOps.retrieveRollTime(etemStartMjd);

        if (currentRollTime == null) {
            throw new ModuleFatalProcessingException(
                "No RollTime found for etemStartMjd = " + etemStartMjd);
        }

        int currentSeason = currentRollTime.getSeason();
        int previousSeason = currentSeason == 0 ? 3 : currentSeason - 1;

        log.info("currentSeason = " + currentSeason);
        log.info("previousSeason = " + previousSeason);

        int skyGroupIdCurrentSeason = targetSelectionOperations.skyGroupIdFor(
            ccdModule, ccdOutput, currentSeason);

        log.info("skyGroupId = " + skyGroupIdCurrentSeason);

        SkyGroup skyGroupPrevSeason = targetSelectionOperations.skyGroupFor(
            skyGroupIdCurrentSeason, previousSeason);

        String prevRunDir = EtemUtils.runDir(skyGroupPrevSeason.getCcdModule(),
            skyGroupPrevSeason.getCcdOutput(), "1", cadenceType);

        prevRunDirPath = new File(prevRunDirPath, prevRunDir).getAbsolutePath();

        log.info("prevRunDirPath = " + prevRunDirPath);

        return prevRunDirPath;
    }

    private void populateInputs(String localDir, Etem2Inputs inputs,
        double raOffset, double decOffset, double phiOffset) {
        inputs.setCcdModule(ccdModule);
        inputs.setCcdOutput(ccdOutput);
        inputs.setNumCadences(runDurationCadences);
        inputs.setCadenceType(cadenceType);
        inputs.setStartDate(packerParams.getStartDate());
        inputs.setOutputDir(localDir);
        inputs.setTargetListSetName(tlsName);
        inputs.setRequantExternalId(photometerConfigParams.getCompressionExternalId());
        inputs.setPlannedConfigMap(spacecraftConfigParams);
        inputs.setEtemInputsFile(packerParams.getEtemInputsFile());
        inputs.setRefPixelCadenceInterval(spacecraftConfigParams.getLongCadencesPerBaseline());
        inputs.setRefPixelCadenceOffset(dataGenParams.getRefPixelCadenceOffset());
        inputs.setPreviousQuarterRunDir(previousQuarterRunDir());
        inputs.setRaOffset(raOffset);
        inputs.setDecOffset(decOffset);
        inputs.setPhiOffset(phiOffset);

        if (rpTls != null && rpTls.getName() != null && rpTls.getName()
            .length() > 0) {
            inputs.setRefPixTargetListSetName(rpTls.getName());
        } else {
            // if not set, make sure it's empty so it shows up
            // as [] on the MATLAB side
            inputs.setRefPixTargetListSetName("");
        }

        if (etem2ModuleParams.isAstrophysicsEnabled()) {
            ModuleOutputListsParameters modOutLists = new ModuleOutputListsParameters(
                etem2ModuleParams.getAstrophysicsIncludeArray(),
                etem2ModuleParams.getAstrophysicsExcludeArray());

            inputs.setEnableAstrophysics(modOutLists.included(ccdModule,
                ccdOutput));
        } else {
            inputs.setEnableAstrophysics(false);
        }
    }

    /**
     * @param pipelineTask
     * @throws Exception
     * 
     */
    private void doDithering(PipelineTask pipelineTask) throws Exception {

        Etem2OutputManager outputManager = new Etem2OutputManager(
            dataGenDirManager, pipelineTask.getId());

        double[] raOffsets = etem2DitherParams.getRaOffsets();
        double[] decOffsets = etem2DitherParams.getDecOffsets();
        double[] phiOffsets = etem2DitherParams.getPhiOffsets();

        int numOffsets = etem2DitherParams.numOffsets();
        int startRunNumber = unitOfWork.getStartRunNumber();
        int endRunNumber = unitOfWork.getEndRunNumber();

        DateFormat formatter = MatlabDateFormatter.dateFormatter();
        Date currentRunStartDate = formatter.parse(packerParams.getStartDate());
        double currentMjd = ModifiedJulianDate.dateToMjd(currentRunStartDate);
        double daysPerOffset = spacecraftConfigParams.getSecondsPerShortCadence()
            * spacecraftConfigParams.getShortCadencesPerLongCadence()
            * etem2DitherParams.getCadencesPerOffset() / SECONDS_PER_DAY;

        currentMjd += (startRunNumber - 1) * daysPerOffset;

        for (int runNumber = startRunNumber; runNumber <= endRunNumber; runNumber++) {

            if (runNumber > numOffsets) {
                throw new ModuleFatalProcessingException(
                    "Configuration Error: runNumber(" + runNumber
                        + ") exceeds number of offsets(" + numOffsets + ")");
            }

            outputManager.setRunNumber(runNumber);
            String runSubDir = EtemUtils.runDir(ccdModule, ccdOutput, "1",
                "long");
            outputManager.initializeDirectories(runSubDir);

            currentRunStartDate = ModifiedJulianDate.mjdToDate(currentMjd);
            String startDateString = formatter.format(currentRunStartDate);

            Etem2Inputs inputs = new Etem2Inputs();
            Etem2Outputs outputs = new Etem2Outputs();

            populateInputs(outputManager.getLocalDir(), inputs,
                raOffsets[runNumber - 1], decOffsets[runNumber - 1],
                phiOffsets[runNumber - 1]);

            inputs.setCadenceType("long"); // dithering only supports long
            // cadence
            inputs.setNumCadences(etem2DitherParams.getCadencesPerOffset());
            inputs.setStartDate(startDateString);

            log.info("ETEM: Dither Mode: run number: " + runNumber);
            log.info("ETEM: Dither Mode: start date: " + startDateString);

            executeAlgorithm(pipelineTask, inputs, outputs);

            outputManager.publishResults(runSubDir);

            currentMjd += daysPerOffset;
        }
    }
}
