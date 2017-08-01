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

package gov.nasa.kepler.dev.seed;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.primitives.Ints.toArray;
import gov.nasa.kepler.ar.exporter.ExporterParameters;
import gov.nasa.kepler.ar.exporter.cdpp.CdppExporterModuleParameters;
import gov.nasa.kepler.ar.exporter.dv.DvTimeSeriesExporterPipelineModuleParameters;
import gov.nasa.kepler.ar.exporter.ffi.FfiAssemblerModuleParameters;
import gov.nasa.kepler.cal.io.CalModuleParameters;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.MatlabDateFormatter;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.pi.AncillaryEngineeringParameters;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.common.pi.CalFfiModuleParameters;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.common.pi.PlannedPhotometerConfigParameters;
import gov.nasa.kepler.common.pi.SkyGroupIdListsParameters;
import gov.nasa.kepler.dev.seed.QuarterlyPipelineDescriptor.Activity;
import gov.nasa.kepler.dev.seed.QuarterlyPipelineDescriptor.DataType;
import gov.nasa.kepler.dev.seed.QuarterlyPipelineDescriptor.Quarter;
import gov.nasa.kepler.dr.dispatch.NotificationMessageHandler;
import gov.nasa.kepler.etem2.DataGenDirManager;
import gov.nasa.kepler.etem2.DataGenParameters;
import gov.nasa.kepler.etem2.Etem2ModuleParameters;
import gov.nasa.kepler.etem2.PackerParameters;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.gar.huffman.HuffmanPipelineModule;
import gov.nasa.kepler.gar.requant.RequantPipelineModule;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.FileLog;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLogResult;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pdq.RefPixelPipelineParameters;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.TargetTableParameters;
import gov.nasa.kepler.mc.dv.DvModuleParameters;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.pa.MotionModuleParameters;
import gov.nasa.kepler.pa.PaCoaModuleParameters;
import gov.nasa.kepler.pa.PaModuleParameters;
import gov.nasa.kepler.pi.module.MatlabMcrExecutable;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.kepler.systest.TargetListSetUnUplinker;
import gov.nasa.kepler.systest.validation.FitsValidationParameters;
import gov.nasa.kepler.tad.operations.TadXmlImportParameters;
import gov.nasa.kepler.tad.peer.CoaModuleParameters;
import gov.nasa.kepler.tps.TpsModuleParameters;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class QuarterlyPipelineLauncherPipelineModule extends PipelineModule {

    private static final Log log = LogFactory.getLog(QuarterlyPipelineLauncherPipelineModule.class);

    public static final String MODULE_NAME = "quarterly-launcher";

    private static final String PARAMETER_SET_VARIANT_START = " (";
    private static final String PARAMETER_SET_VARIANT_END = ")";
    private static final String DATA_GEN = "dataGen";
    private static final String MODULE_OUTPUT_LISTS = "moduleOutputLists";
    private static final String SKY_GROUP_ID_LISTS = "skyGroupIdLists";
    private static final String PACKER = "packer";
    private static final String PACKER_COMMON = "packer (common)";
    private static final String CADENCE_TYPE = "cadenceType";
    private static final String CADENCE_RANGE = "cadenceRange";
    private static final String PLANNED_PHOTOMETER_CONFIG = "plannedPhotometerConfig";
    private static final String TARGET_IMPORT = "targetImport";
    private static final String TARGET_IMPORT_COMMON = "targetImport (common)";
    private static final String EXPORTER = "exporter";
    private static final String CDPP_EXPORTER = "cdppExporter";
    private static final String DV_TIME_SERIES_EXPORTER = "dvTimeSeriesExporter";
    private static final String FFI_ASSEMBLER = "ffiAssembler";
    private static final String TAD = "tad";
    private static final String PA = "pa";
    private static final String TARGET_TABLE = "targetTable";
    private static final String TARGET_TABLE_BACKGROUND = "targetTable (background)";
    private static final String TPS_LITE = "tps (lite)";
    private static final String TPS_FULL = "tps (full)";
    private static final String ANCILLARY_ENGINEERING_PDC = "ancillaryEngineering (PDC)";
    private static final String ANCILLARY_ENGINEERING_DV = "ancillaryEngineering (DV)";
    private static final String RELEASE = "release";
    private static final String REF_PIXEL = "refPixel";
    private static final String CAL_FFI = "calFfi";
    private static final String ETEM_2 = "etem2";
    private static final String COA = "coa";
    private static final String PA_COA = "paCoa";
    private static final String TAD_XML_IMPORT = "tadXmlImport";
    private static final String MOTION = "motion";
    public static final String COMPLETED_DV_PIPELINE_INSTANCE_SELECTION = "completedDvPipelineInstanceSelection";
    public static final String DV_EXPORTER = "dvExporter";
    public static final String TPS_RESULT = "tpsResult";
    public static final String FITS_VALIDATION = "fitsValidation";
    private static final String CAL = "cal";
    private static final String CAL_COMMON = "cal (common)";
    private static final String DV = "dv";
    private static final String DV_COMMON = "dv (common)";
    private static final String INIT = "INIT";

    private static final int VARIANCE_WINDOW_LENGTH_MULTIPLIER_FACTOR = 30;
    private static final int SKIP_COUNT_REDUCTION_FACTOR = 5;
    private static final int CADENCE_STEP = 2;

    private ParameterSetCrud parameterSetCrud;
    private PipelineModuleDefinitionCrud pipelineModuleDefinitionCrud;
    private PipelineOperations pipelineOperations;
    private TriggerDefinitionCrud triggerDefinitionCrud;
    private TargetSelectionCrud targetSelectionCrud;
    private LogCrud logCrud;

    private CadenceType cadenceType;
    private TadParameters tadParameters;

    public QuarterlyPipelineLauncherPipelineModule() {
    }

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return SingleUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> requiredParams = new ArrayList<Class<? extends Parameters>>();
        requiredParams.add(QuarterlyPipelineLauncherParameters.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) throws PipelineException {
        parameterSetCrud = new ParameterSetCrud();
        pipelineModuleDefinitionCrud = new PipelineModuleDefinitionCrud();
        pipelineOperations = new PipelineOperations();
        triggerDefinitionCrud = new TriggerDefinitionCrud();
        targetSelectionCrud = new TargetSelectionCrud();
        logCrud = new LogCrud();

        try {
            QuarterlyPipelineLauncherParameters quarterlyLauncherParameters = pipelineTask.getParameters(QuarterlyPipelineLauncherParameters.class);
            List<QuarterlyPipelineDescriptor> quarterlyPipelineDescriptors = quarterlyLauncherParameters.toQuarterlyPipelineDescriptors();

            QuarterlyPipelineDescriptor nextQuarterlyPipelineDescriptor = getNextQuarterlyPipelineDescriptor(
                pipelineTask, quarterlyPipelineDescriptors);

            setBaseParameters(nextQuarterlyPipelineDescriptor);

            setCommonPackerParameters();
            setCommonTargetImportParameters();

            setLongCadenceCount();
            setMaxTargetsPerTargetList();

            setDataGenParameters(quarterlyLauncherParameters);

            setModuleOutputListsParameters();

            CadenceRangeParameters cadenceRangeParameters = setCadenceRangeParameters();

            setExporterParameters(nextQuarterlyPipelineDescriptor, cadenceRangeParameters);
            setCdppExporterParameters();
            setDvTimeSeriesExporterParameters();
            setFfiAssemblerParameters();

            setTadParameters(nextQuarterlyPipelineDescriptor);

            setTargetTableParameters();

            setTpsParameters();

            clearAncillaryEngineeringParameters();

            setGarClasses();

            setRefPixelParameters();

            setCalFfiParameters();

            setEtem2Parameters();

            setCoaParameters(nextQuarterlyPipelineDescriptor);

            setPaCoaParameters();

            setTadXmlImportParameters();

            setTargetListSetStartDate();

            setMotionParameters();

            setFitsValidationParameters();

            setCommonCalParameters();
            setCommonDvParameters();

            DatabaseServiceFactory.getInstance()
                .flush();

            launchNextPipeline(pipelineTask, quarterlyLauncherParameters,
                nextQuarterlyPipelineDescriptor);
        } catch (Throwable e) {
            throw new PipelineException("Unable to process task.", e);
        }
    }

    private void setCalFfiParameters() {
        LogCrud logCrud = new LogCrud();
        List<FileLog> fileLogs = logCrud.retrieveFileLogsWhereFilenameContains(DispatcherType.FFI.toString()
            .toLowerCase());
        if (!fileLogs.isEmpty()) {
            String lastFileName = fileLogs.get(fileLogs.size() - 1)
                .getFilename();
            Pair<String, String> filenameTimestampSuffixPair = NotificationMessageHandler.getFilenameTimestampSuffixPair(lastFileName);
            String timestamp = filenameTimestampSuffixPair.left;

            ParameterSet destPs = parameterSetCrud.retrieveLatestVersionForName(CAL_FFI);
            CalFfiModuleParameters destParameters = destPs.parametersInstance();
            destParameters.setFileTimeStamp(timestamp);
            pipelineOperations.updateParameterSet(destPs, destParameters, false);
        }
    }

    private void setRefPixelParameters() {
        ParameterSet srcPs = parameterSetCrud.retrieveLatestVersionForName(PLANNED_PHOTOMETER_CONFIG);
        PlannedPhotometerConfigParameters srcParmeters = srcPs.parametersInstance();

        ParameterSet destPs = parameterSetCrud.retrieveLatestVersionForName(REF_PIXEL);
        RefPixelPipelineParameters destParameters = destPs.parametersInstance();
        destParameters.setReferencePixelTargetTableId(srcParmeters.getRptExternalId());
        pipelineOperations.updateParameterSet(destPs, destParameters, false);
    }

    private void setCommonPackerParameters() {
        ParameterSet psCommon = parameterSetCrud.retrieveLatestVersionForName(PACKER_COMMON);
        PackerParameters parametersCommon = psCommon.parametersInstance();

        ParameterSet ps = parameterSetCrud.retrieveLatestVersionForName(PACKER);
        PackerParameters parameters = ps.parametersInstance();
        parameters.setCadenceGapOffsets(parametersCommon.getCadenceGapOffsets());
        parameters.setIncludeFfi(parametersCommon.isIncludeFfi());
        parameters.setGenDmcFiles(parametersCommon.isGenDmcFiles());
        parameters.setEtemInputsFile(parametersCommon.getEtemInputsFile());
        pipelineOperations.updateParameterSet(ps, parameters, false);
    }

    private void setCommonTargetImportParameters() {
        ParameterSet psCommon = parameterSetCrud.retrieveLatestVersionForName(TARGET_IMPORT_COMMON);
        TargetImportParameters parametersCommon = psCommon.parametersInstance();

        ParameterSet ps = parameterSetCrud.retrieveLatestVersionForName(TARGET_IMPORT);
        TargetImportParameters parameters = ps.parametersInstance();
        parameters.setFitMinPointsFraction(parametersCommon.getFitMinPointsFraction());
        pipelineOperations.updateParameterSet(ps, parameters, false);
    }

    private void setCommonCalParameters() {
        ParameterSet psCommon = parameterSetCrud.retrieveLatestVersionForName(CAL_COMMON);
        CalModuleParameters parametersCommon = psCommon.parametersInstance();

        ParameterSet ps = parameterSetCrud.retrieveLatestVersionForName(CAL);
        CalModuleParameters parameters = ps.parametersInstance();
        parameters.setBlackAlgorithmQuarters(parametersCommon.getBlackAlgorithmQuarters());
        parameters.setBlackAlgorithm(parametersCommon.getBlackAlgorithm());
        pipelineOperations.updateParameterSet(ps, parameters, false);
    }

    private void setCommonDvParameters() {
        ParameterSet psCommon = parameterSetCrud.retrieveLatestVersionForName(DV_COMMON);
        DvModuleParameters parametersCommon = psCommon.parametersInstance();

        ParameterSet ps = parameterSetCrud.retrieveLatestVersionForName(DV);
        DvModuleParameters parameters = ps.parametersInstance();
        parameters.setLimbDarkeningModelName(parametersCommon.getLimbDarkeningModelName());
        pipelineOperations.updateParameterSet(ps, parameters, false);
    }

    @SuppressWarnings({ "unchecked", "rawtypes" })
    private void setGarClasses() throws ClassNotFoundException {
        ParameterSet releasePs = parameterSetCrud.retrieveLatestVersionForName(RELEASE);
        ReleasePipelineParameters releaseParmeters = releasePs.parametersInstance();

        PipelineModuleDefinition requantModDef = pipelineModuleDefinitionCrud.retrieveLatestVersionForName(RequantPipelineModule.MODULE_NAME);
        requantModDef.setImplementingClass(new ClassWrapper(
            Class.forName(releaseParmeters.getRequantClassName())));

        PipelineModuleDefinition huffmanModDef = pipelineModuleDefinitionCrud.retrieveLatestVersionForName(HuffmanPipelineModule.MODULE_NAME);
        huffmanModDef.setImplementingClass(new ClassWrapper(
            Class.forName(releaseParmeters.getHuffmanClassName())));
    }

    private void clearAncillaryEngineeringParameters() {
        // Clear ancillaryEngineering parmeters because etem doesn't do
        // ancillary data.
        ParameterSet ancillaryPs = parameterSetCrud.retrieveLatestVersionForName(ANCILLARY_ENGINEERING_PDC);
        AncillaryEngineeringParameters ancillaryParmeters = ancillaryPs.parametersInstance();
        ancillaryParmeters.setInteractions(ArrayUtils.EMPTY_STRING_ARRAY);
        ancillaryParmeters.setIntrinsicUncertainties(ArrayUtils.EMPTY_FLOAT_ARRAY);
        ancillaryParmeters.setMnemonics(ArrayUtils.EMPTY_STRING_ARRAY);
        ancillaryParmeters.setModelOrders(ArrayUtils.EMPTY_INT_ARRAY);
        ancillaryParmeters.setQuantizationLevels(ArrayUtils.EMPTY_FLOAT_ARRAY);
        pipelineOperations.updateParameterSet(ancillaryPs, ancillaryParmeters,
            false);

        ancillaryPs = parameterSetCrud.retrieveLatestVersionForName(ANCILLARY_ENGINEERING_DV);
        ancillaryParmeters = ancillaryPs.parametersInstance();
        ancillaryParmeters.setInteractions(ArrayUtils.EMPTY_STRING_ARRAY);
        ancillaryParmeters.setIntrinsicUncertainties(ArrayUtils.EMPTY_FLOAT_ARRAY);
        ancillaryParmeters.setMnemonics(ArrayUtils.EMPTY_STRING_ARRAY);
        ancillaryParmeters.setModelOrders(ArrayUtils.EMPTY_INT_ARRAY);
        ancillaryParmeters.setQuantizationLevels(ArrayUtils.EMPTY_FLOAT_ARRAY);
        pipelineOperations.updateParameterSet(ancillaryPs, ancillaryParmeters,
            false);
    }

    private void setTpsParameters() {
        ParameterSet packerPs = parameterSetCrud.retrieveLatestVersionForName(PACKER);
        PackerParameters packerParameters = packerPs.parametersInstance();
        int longCadenceCount = packerParameters.getLongCadenceCount();

        if (cadenceType == null) {
            ParameterSet cadenceTypePs = parameterSetCrud.retrieveLatestVersionForName(CADENCE_TYPE);
            CadenceTypePipelineParameters cadenceTypeParameters = cadenceTypePs.parametersInstance();
            cadenceType = CadenceType.valueOf(cadenceTypeParameters.getCadenceType());
        }

        if (cadenceType.equals(CadenceType.LONG)) {
            ParameterSet tpsLitePs = parameterSetCrud.retrieveLatestVersionForName(TPS_LITE);
            TpsModuleParameters tpsLiteParmeters = tpsLitePs.parametersInstance();
            tpsLiteParmeters.setVarianceWindowLengthMultiplier(getVarianceWindowLengthMultiplier(
                longCadenceCount, tpsLiteParmeters));
            pipelineOperations.updateParameterSet(tpsLitePs, tpsLiteParmeters,
                false);

            ParameterSet tpsFullPs = parameterSetCrud.retrieveLatestVersionForName(TPS_FULL);
            TpsModuleParameters tpsFullParmeters = tpsFullPs.parametersInstance();
            tpsFullParmeters.setVarianceWindowLengthMultiplier(getVarianceWindowLengthMultiplier(
                longCadenceCount, tpsFullParmeters));
            pipelineOperations.updateParameterSet(tpsFullPs, tpsFullParmeters,
                false);
        }
    }

    private void setMotionParameters() {
        ParameterSet targetImportPs = parameterSetCrud.retrieveLatestVersionForName(TARGET_IMPORT);
        TargetImportParameters targetImportParameters = targetImportPs.parametersInstance();

        ParameterSet motionPs = parameterSetCrud.retrieveLatestVersionForName(MOTION);
        MotionModuleParameters motionParameters = motionPs.parametersInstance();
        motionParameters.setFitMinPoints((int) Math.min(
            motionParameters.getFitMinPoints(),
            targetImportParameters.getMaxTargetsPerTargetList()
                * targetImportParameters.getFitMinPointsFraction()));
        pipelineOperations.updateParameterSet(motionPs, motionParameters, false);
    }

    private void setFitsValidationParameters() {
        String moduleExeDataDir = ConfigurationServiceFactory.getInstance()
            .getString(MatlabMcrExecutable.MODULE_EXE_DATA_DIR_PROPERTY_NAME);

        ParameterSet releasePs = parameterSetCrud.retrieveLatestVersionForName(RELEASE);
        ReleasePipelineParameters releaseParmeters = releasePs.parametersInstance();

        ParameterSet fitsValidationPs = parameterSetCrud.retrieveLatestVersionForName(FITS_VALIDATION);
        FitsValidationParameters fitsValidationParameters = fitsValidationPs.parametersInstance();
        fitsValidationParameters.setTasksRootDirectory(moduleExeDataDir);
        int skipCount = releaseParmeters.getPerQuarterLongCadenceCount()
            / SKIP_COUNT_REDUCTION_FACTOR;
        fitsValidationParameters.setSkipCount(skipCount);
        fitsValidationParameters.setChunkSize(skipCount);
        pipelineOperations.updateParameterSet(fitsValidationPs,
            fitsValidationParameters, false);
    }

    private int getVarianceWindowLengthMultiplier(int longCadenceCount,
        TpsModuleParameters tpsParmeters) {
        // Integer division is required because tps matlab requires the
        // parameter to be an integer, even though it is defined as a float.
        return Math.min((int) tpsParmeters.getVarianceWindowLengthMultiplier(),
            longCadenceCount / VARIANCE_WINDOW_LENGTH_MULTIPLIER_FACTOR);
    }

    private void setLongCadenceCount() {
        if (cadenceType == null) {
            ParameterSet cadenceTypePs = parameterSetCrud.retrieveLatestVersionForName(CADENCE_TYPE);
            CadenceTypePipelineParameters cadenceTypeParameters = cadenceTypePs.parametersInstance();
            cadenceType = CadenceType.valueOf(cadenceTypeParameters.getCadenceType());
        }

        ParameterSet releasePs = parameterSetCrud.retrieveLatestVersionForName(RELEASE);
        ReleasePipelineParameters releaseParmeters = releasePs.parametersInstance();
        int longCadenceCount = releaseParmeters.getPerQuarterLongCadenceCount();
        int shortCadenceReductionFactor = releaseParmeters.getShortCadenceReductionFactor();

        if (cadenceType.equals(CadenceType.SHORT)) {
            longCadenceCount = longCadenceCount / shortCadenceReductionFactor;
        }

        ParameterSet ps = parameterSetCrud.retrieveLatestVersionForName(PACKER);
        PackerParameters parameters = ps.parametersInstance();
        parameters.setLongCadenceCount(longCadenceCount);
        pipelineOperations.updateParameterSet(ps, parameters, false);
    }

    private void setMaxTargetsPerTargetList() {
        ParameterSet releasePs = parameterSetCrud.retrieveLatestVersionForName(RELEASE);
        ReleasePipelineParameters releaseParameters = releasePs.parametersInstance();

        ParameterSet ps = parameterSetCrud.retrieveLatestVersionForName(TARGET_IMPORT);
        TargetImportParameters parameters = ps.parametersInstance();
        parameters.setMaxTargetsPerTargetList(releaseParameters.getMaxTargetsPerTargetList());
        pipelineOperations.updateParameterSet(ps, parameters, false);
    }

    private CadenceRangeParameters setCadenceRangeParameters() {
        if (cadenceType == null) {
            ParameterSet cadenceTypePs = parameterSetCrud.retrieveLatestVersionForName(CADENCE_TYPE);
            CadenceTypePipelineParameters cadenceTypeParameters = cadenceTypePs.parametersInstance();
            cadenceType = CadenceType.valueOf(cadenceTypeParameters.getCadenceType());
        }

        ParameterSet plannedPhotometerConfigPs = parameterSetCrud.retrieveLatestVersionForName(PLANNED_PHOTOMETER_CONFIG);
        PlannedPhotometerConfigParameters plannedPhotometerConfigParmeters = plannedPhotometerConfigPs.parametersInstance();

        int externalId = -1;
        switch (cadenceType) {
            case LONG:
                externalId = plannedPhotometerConfigParmeters.getLctExternalId();
                break;
            case SHORT:
                externalId = plannedPhotometerConfigParmeters.getSctExternalId();
                break;
            default:
                throw new IllegalArgumentException("Unexpected type: "
                    + cadenceType);
        }

        List<PixelLogResult> pixelLogResults = logCrud.retrieveTableIdsForCadenceRange(
            TargetType.valueOf(cadenceType), Integer.MIN_VALUE,
            Integer.MAX_VALUE);

        ParameterSet cadenceRangePs = parameterSetCrud.retrieveLatestVersionForName(CADENCE_RANGE);
        CadenceRangeParameters cadenceRangeParameters = cadenceRangePs.parametersInstance();
        for (PixelLogResult pixelLogResult : pixelLogResults) {
            if (pixelLogResult.getTableId() == externalId) {
                cadenceRangePs = parameterSetCrud.retrieveLatestVersionForName(CADENCE_RANGE);
                cadenceRangeParameters = cadenceRangePs.parametersInstance();
                cadenceRangeParameters.setStartCadence(pixelLogResult.getCadenceStart());
                cadenceRangeParameters.setEndCadence(pixelLogResult.getCadenceEnd());
                pipelineOperations.updateParameterSet(cadenceRangePs,
                    cadenceRangeParameters, false);
            }
        }
        
        return cadenceRangeParameters;
    }

    private void setTargetTableParameters() {

        TargetListSet tls = targetSelectionCrud.retrieveTargetListSet(tadParameters.getTargetListSetName());
        if (tls != null) {
            TargetTable targetTable = tls.getTargetTable();
            if (targetTable != null) {
                ParameterSet targetTablePs = parameterSetCrud.retrieveLatestVersionForName(TARGET_TABLE);
                TargetTableParameters targetTableParams = targetTablePs.parametersInstance();
                targetTableParams.setTargetTableDbId(targetTable.getId());
                log.info(String.format(
                    "Update '%s' with targetTableDbId '%d'.", TARGET_TABLE,
                    targetTable.getId()));
                pipelineOperations.updateParameterSet(targetTablePs,
                    targetTableParams, false);
            }

            TargetTable backgroundTable = tls.getBackgroundTable();
            if (backgroundTable != null) {
                ParameterSet backgroundTablePs = parameterSetCrud.retrieveLatestVersionForName(TARGET_TABLE_BACKGROUND);
                TargetTableParameters backgroundTableParams = backgroundTablePs.parametersInstance();
                backgroundTableParams.setTargetTableDbId(backgroundTable.getId());
                pipelineOperations.updateParameterSet(backgroundTablePs,
                    backgroundTableParams, false);
            }
        }
    }

    private void setEtem2Parameters() {
        ParameterSet dataGenPs = parameterSetCrud.retrieveLatestVersionForName(DATA_GEN);
        DataGenParameters dataGenParameters = dataGenPs.parametersInstance();

        ParameterSet packerPs = parameterSetCrud.retrieveLatestVersionForName(PACKER);
        PackerParameters packerParameters = packerPs.parametersInstance();

        String firstDataSetName = dataGenParameters.getDataSetNames()
            .split(",")[0];
        String thisDataSetName = packerParameters.getDataSetName();

        String tlsName = tadParameters.getTargetListSetName();
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        TargetListSet tls = targetSelectionCrud.retrieveTargetListSet(tlsName);

        String previousQuarterRunsRootPath = "";
        if (tls != null && !tls.getType()
            .equals(TargetType.REFERENCE_PIXEL)
            && !thisDataSetName.equals(firstDataSetName)) {
            PackerParameters firstDataSetPackerParams = new PackerParameters();
            firstDataSetPackerParams.setDataSetName(firstDataSetName);
        }

        ParameterSet etem2Ps = parameterSetCrud.retrieveLatestVersionForName(ETEM_2);
        Etem2ModuleParameters etem2Params = etem2Ps.parametersInstance();
        etem2Params.setPreviousQuarterRunsRootPath(previousQuarterRunsRootPath);
        pipelineOperations.updateParameterSet(etem2Ps, etem2Params, false);
    }

    private void setTargetListSetStartDate() throws ParseException {
        ParameterSet packerPs = parameterSetCrud.retrieveLatestVersionForName(PACKER);
        PackerParameters packerParameters = packerPs.parametersInstance();
        String startDate = packerParameters.getStartDate();

        String tlsName = tadParameters.getTargetListSetName();
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        TargetListSet tls = targetSelectionCrud.retrieveTargetListSet(tlsName);
        if (tls != null) {
            State state = tls.getState();
            tls.setState(State.UNLOCKED);
            tls.setStart(MatlabDateFormatter.dateFormatter()
                .parse(startDate));
            tls.setState(state);
        }
    }

    private void setTadXmlImportParameters() {
        ParameterSet dataGenPs = parameterSetCrud.retrieveLatestVersionForName(DATA_GEN);
        DataGenParameters dataGenParameters = dataGenPs.parametersInstance();

        ParameterSet packerPs = parameterSetCrud.retrieveLatestVersionForName(PACKER);
        PackerParameters packerParameters = packerPs.parametersInstance();

        DataGenDirManager dataGenDirManager = new DataGenDirManager(
            dataGenParameters, packerParameters);
        String tadXmlDir = dataGenDirManager.getUplinkedTablesExportDir();

        ParameterSet tadXmlImportPs = parameterSetCrud.retrieveLatestVersionForName(TAD_XML_IMPORT);
        TadXmlImportParameters tadXmlImportParams = tadXmlImportPs.parametersInstance();
        tadXmlImportParams.setTadXmlAbsPath(tadXmlDir);
        pipelineOperations.updateParameterSet(tadXmlImportPs,
            tadXmlImportParams, false);
    }

    private void setTadParameters(
        QuarterlyPipelineDescriptor nextQuarterlyPipelineDescriptor)
        throws Exception {
        // Set tadParameters.quarters.
        Quarter quarter = nextQuarterlyPipelineDescriptor.getQuarter();
        ParameterSet tadPs = parameterSetCrud.retrieveLatestVersionForName(TAD);
        tadParameters.setQuarters(quarter.toString());
        pipelineOperations.updateParameterSet(tadPs, tadParameters, false);
        
        Activity activity = nextQuarterlyPipelineDescriptor.getActivity();

        String origTlsName = tadParameters.getTargetListSetName();
        TargetListSet origTls = targetSelectionCrud.retrieveTargetListSet(origTlsName);
        if (origTls != null) {
            String newTlsName = origTlsName + "_" + activity;
            TargetListSet newTls = new TargetListSet(newTlsName, origTls);
            newTls.clearTadFields();

            if (activity.equals(Activity.TADIMPORT)) {
                targetSelectionCrud.create(newTls);

                TargetListSetUnUplinker unUplinker = new TargetListSetUnUplinker(
                    origTlsName);
                unUplinker.unUplink();

                origTls.setState(State.UNLOCKED);
                origTls.setName(getOldTlsName(origTlsName));

                newTls.setState(State.UNLOCKED);
                newTls.setName(origTlsName);
            }

            if (activity.equals(Activity.TADMPE)
                || activity.equals(Activity.COAPHOTOMETRY)) {
                tadPs = parameterSetCrud.retrieveLatestVersionForName(TAD);

                targetSelectionCrud.create(newTls);

                tadParameters.setTargetListSetName(newTlsName);
                tadParameters.setSupplementalFor(origTlsName);
                pipelineOperations.updateParameterSet(tadPs, tadParameters,
                    false);
            }

            newTls.setState(State.LOCKED);
        }
    }

    public static final String getOldTlsName(String tlsName) {
        return tlsName + "_OLD";
    }

    private void setCoaParameters(
        QuarterlyPipelineDescriptor nextQuarterlyPipelineDescriptor) {
        Activity activity = nextQuarterlyPipelineDescriptor.getActivity();

        ParameterSet coaPs = parameterSetCrud.retrieveLatestVersionForName(COA);
        CoaModuleParameters coaParameters = coaPs.parametersInstance();
        coaParameters.setMotionPolynomialsEnabled(activity.equals(Activity.TADMPE));
        pipelineOperations.updateParameterSet(coaPs, coaParameters, false);
    }

    private void setPaCoaParameters() {
        ParameterSet paCoaPs = parameterSetCrud.retrieveLatestVersionForName(PA_COA);
        PaCoaModuleParameters paCoaParameters = paCoaPs.parametersInstance();
        paCoaParameters.setCadenceStep(CADENCE_STEP);
        pipelineOperations.updateParameterSet(paCoaPs, paCoaParameters, false);
    }

    private void setExporterParameters(QuarterlyPipelineDescriptor nextQuarterlyPipelineDescriptor, CadenceRangeParameters cadenceRangeParameters) {
        ParameterSet dataGenPs = parameterSetCrud.retrieveLatestVersionForName(DATA_GEN);
        DataGenParameters dataGenParameters = dataGenPs.parametersInstance();

        ParameterSet packerPs = parameterSetCrud.retrieveLatestVersionForName(PACKER);
        PackerParameters packerParameters = packerPs.parametersInstance();

        // ExporterParameters are used for targetPixels and dvts, so set the exportDir to one or the other.
        String exportDir = null;
        if (nextQuarterlyPipelineDescriptor.getActivity().equals(Activity.PLANETSEARCHEXPORT)) {
            exportDir = new DataGenDirManager(
                dataGenParameters, packerParameters).getDvTimeSeriesExportDir();
        } else {
            exportDir = new DataGenDirManager(
                dataGenParameters, packerParameters).getTargetPixelExportDir();
        }
        
        ParameterSet exporterPs = parameterSetCrud.retrieveLatestVersionForName(EXPORTER);
        ExporterParameters exporterParams = exporterPs.parametersInstance();
        exporterParams.setNfsExportDirectory(exportDir);
        exporterParams.setStartCadence(cadenceRangeParameters.getStartCadence());
        exporterParams.setEndCadence(cadenceRangeParameters.getEndCadence());
        pipelineOperations.updateParameterSet(exporterPs, exporterParams, false);
    }

    private void setCdppExporterParameters() {
        ParameterSet dataGenPs = parameterSetCrud.retrieveLatestVersionForName(DATA_GEN);
        DataGenParameters dataGenParameters = dataGenPs.parametersInstance();

        ParameterSet packerPs = parameterSetCrud.retrieveLatestVersionForName(PACKER);
        PackerParameters packerParameters = packerPs.parametersInstance();

        ParameterSet cdppPs = parameterSetCrud.retrieveLatestVersionForName(CDPP_EXPORTER);
        CdppExporterModuleParameters cdppExporter = cdppPs.parametersInstance();
        cdppExporter.setExportDirectory(new DataGenDirManager(
            dataGenParameters, packerParameters).getCdppExportDir());
        pipelineOperations.updateParameterSet(cdppPs, cdppExporter, false);
    }

    private void setDvTimeSeriesExporterParameters() {
        ParameterSet dataGenPs = parameterSetCrud.retrieveLatestVersionForName(DATA_GEN);
        DataGenParameters dataGenParameters = dataGenPs.parametersInstance();

        ParameterSet packerPs = parameterSetCrud.retrieveLatestVersionForName(PACKER);
        PackerParameters packerParameters = packerPs.parametersInstance();

        ParameterSet dvTimeSeriesExporterPs = parameterSetCrud.retrieveLatestVersionForName(DV_TIME_SERIES_EXPORTER);
        DvTimeSeriesExporterPipelineModuleParameters dvTimeSeriesExport = dvTimeSeriesExporterPs.parametersInstance();
        dvTimeSeriesExport.setNfsExportDir(new DataGenDirManager(
            dataGenParameters, packerParameters).getDvTimeSeriesExportDir());
        pipelineOperations.updateParameterSet(dvTimeSeriesExporterPs,
            dvTimeSeriesExport, false);
    }

    private void setFfiAssemblerParameters() {
        ParameterSet dataGenPs = parameterSetCrud.retrieveLatestVersionForName(DATA_GEN);
        DataGenParameters dataGenParameters = dataGenPs.parametersInstance();

        ParameterSet packerPs = parameterSetCrud.retrieveLatestVersionForName(PACKER);
        PackerParameters packerParameters = packerPs.parametersInstance();

        ParameterSet ffiAssemblerPs = parameterSetCrud.retrieveLatestVersionForName(FFI_ASSEMBLER);
        FfiAssemblerModuleParameters ffiAssembler = ffiAssemblerPs.parametersInstance();
        ffiAssembler.setNfsExportDirectory(new DataGenDirManager(
            dataGenParameters, packerParameters).getCalFfiExportDir());
        pipelineOperations.updateParameterSet(ffiAssemblerPs, ffiAssembler,
            false);
    }

    public static void setModuleOutputListsParameters() throws ParseException {
        ParameterSetCrud parameterSetCrud = new ParameterSetCrud();
        ParameterSet skyGroupIdListsPs = parameterSetCrud.retrieveLatestVersionForName(SKY_GROUP_ID_LISTS);
        SkyGroupIdListsParameters skyGroupIdListsParameters = skyGroupIdListsPs.parametersInstance();

        ParameterSet packerPs = parameterSetCrud.retrieveLatestVersionForName(PACKER);
        PackerParameters packerParameters = packerPs.parametersInstance();
        ParameterSet moduleOutputListsPs = parameterSetCrud.retrieveLatestVersionForName(MODULE_OUTPUT_LISTS);
        ModuleOutputListsParameters moduleOutputListsParameters = moduleOutputListsPs.parametersInstance();

        double startMjd = ModifiedJulianDate.dateToMjd(MatlabDateFormatter.dateFormatter()
            .parse(packerParameters.getStartDate()));
        int season = new RollTimeOperations().mjdToSeason(startMjd);
        moduleOutputListsParameters.setChannelIncludeArray(getChannels(
            skyGroupIdListsParameters.getSkyGroupIdIncludeArray(), season));
        moduleOutputListsParameters.setChannelExcludeArray(getChannels(
            skyGroupIdListsParameters.getSkyGroupIdExcludeArray(), season));

        new PipelineOperations().updateParameterSet(moduleOutputListsPs,
            moduleOutputListsParameters, false);
    }

    private static int[] getChannels(int[] skyGroupIds, int season) {
        List<Integer> channels = newArrayList();
        for (int skyGroupId : skyGroupIds) {
            SkyGroup skyGroup = new KicCrud().retrieveSkyGroup(skyGroupId,
                season);
            channels.add(FcConstants.getChannelNumber(skyGroup.getCcdModule(),
                skyGroup.getCcdOutput()));
        }

        return toArray(channels);
    }

    private void setBaseParameters(
        QuarterlyPipelineDescriptor nextQuarterlyPipelineDescriptor) {

        if (nextQuarterlyPipelineDescriptor == null) {
            throw new NullPointerException(
                "nextQuarterlyPipelineDescriptor can't be null");
        }
        List<ParameterSet> parameterSets = parameterSetCrud.retrieveLatestVersions();
        for (ParameterSet parameterSet : parameterSets) {
            Activity activity = nextQuarterlyPipelineDescriptor.getActivity();

            String quarterString = nextQuarterlyPipelineDescriptor.getQuarter()
                .toString();
            setBaseParameters(parameterSetCrud, parameterSet, quarterString,
                activity);

            String dataTypeString = nextQuarterlyPipelineDescriptor.getDataType()
                .toString();
            setBaseParameters(parameterSetCrud, parameterSet, dataTypeString,
                activity);

            String activityString = activity.toString();
            setBaseParameters(parameterSetCrud, parameterSet, activityString,
                activity);
        }
    }

    private void setBaseParameters(ParameterSetCrud parameterSetCrud,
        ParameterSet parameterSet, String variant, Activity activity) {
        String name = parameterSet.getName()
            .getName();
        if (name.endsWith(parameterSetNameVariantString(variant))) {
            String trimmedName = name.split("\\"
                + PARAMETER_SET_VARIANT_START.trim())[0].trim();
            ParameterSet baseParameterSet = parameterSetCrud.retrieveLatestVersionForName(trimmedName);
            PipelineOperations pipelineOps = new PipelineOperations();
            log.info(String.format("Update '%s' with '%s'.", trimmedName, name));
            pipelineOps.updateParameterSet(baseParameterSet,
                parameterSet.parametersInstance(), false);
            if (trimmedName.equals(CADENCE_TYPE)) {
                CadenceTypePipelineParameters cadenceTypeParameters = parameterSet.parametersInstance();
                cadenceType = CadenceType.valueOf(cadenceTypeParameters.getCadenceType());
            }
            if (trimmedName.equals(TAD)) {
                tadParameters = parameterSet.parametersInstance();
            }
        }

        // Set paCoaEnabled=true for COAPHOTOMETRY; else, set paCoaEnabled=false
        if (name.startsWith(PA + PARAMETER_SET_VARIANT_START)) {
            PaModuleParameters paParameters = parameterSet.parametersInstance();
            paParameters.setPaCoaEnabled(activity.equals(Activity.COAPHOTOMETRY));
            pipelineOperations.updateParameterSet(parameterSet, paParameters,
                false);
        }
    }

    public static String parameterSetNameVariantString(String variant) {
        return PARAMETER_SET_VARIANT_START + variant
            + PARAMETER_SET_VARIANT_END;
    }

    private void setDataGenParameters(
        QuarterlyPipelineLauncherParameters quarterlyLauncherParameters) {
        String[] dataSetNames = quarterlyLauncherParameters.getQuarters();
        StringBuffer dataSetNamesBuffer = new StringBuffer();
        for (String dataSetName : dataSetNames) {
            dataSetNamesBuffer.append(dataSetName)
                .append(",");
        }
        dataSetNamesBuffer.substring(0, dataSetNamesBuffer.length() - 1);

        ParameterSet dataGenPs = parameterSetCrud.retrieveLatestVersionForName(DATA_GEN);
        DataGenParameters dataGenParameters = dataGenPs.parametersInstance();
        dataGenParameters.setDataSetNames(dataSetNamesBuffer.toString());
        pipelineOperations.updateParameterSet(dataGenPs, dataGenParameters,
            false);
    }

    private void launchNextPipeline(PipelineTask pipelineTask,
        QuarterlyPipelineLauncherParameters quarterlyLauncherParameters,
        QuarterlyPipelineDescriptor nextQuarterlyPipelineDescriptor) {
        String triggerName = getTriggerName(
            nextQuarterlyPipelineDescriptor.getActivity(),
            nextQuarterlyPipelineDescriptor.getDataType());
        String quarter = nextQuarterlyPipelineDescriptor.getQuarter()
            .toString();

        triggerDefinitionCrud = new TriggerDefinitionCrud();
        TriggerDefinition trigger = triggerDefinitionCrud.retrieve(triggerName);

        pipelineOperations.fireTrigger(trigger, quarter);
    }

    private QuarterlyPipelineDescriptor getNextQuarterlyPipelineDescriptor(
        PipelineTask pipelineTask,
        List<QuarterlyPipelineDescriptor> quarterlyPipelineDescriptors) {
        ParameterSet packerPs = parameterSetCrud.retrieveLatestVersionForName(PACKER);
        PackerParameters packerParameters = packerPs.parametersInstance();
        String dataSetName = packerParameters.getDataSetName();

        QuarterlyPipelineDescriptor quarterlyPipelineDescriptor = new QuarterlyPipelineDescriptor();
        if (!dataSetName.equals(INIT)) {
            Quarter quarter = Quarter.valueOf(dataSetName);

            String triggerName = pipelineTask.getPipelineInstance()
                .getTriggerName();
            Pair<Activity, DataType> activityAndDataType = getActivityAndDataType(triggerName);
            Activity activity = activityAndDataType.left;
            DataType dataType = activityAndDataType.right;

            quarterlyPipelineDescriptor = new QuarterlyPipelineDescriptor(
                quarter, dataType, activity);
        }

        // Add an empty element at the beginning to indicate the very first
        // pipeline.
        quarterlyPipelineDescriptors.add(0, new QuarterlyPipelineDescriptor());

        QuarterlyPipelineDescriptor nextQuarterlyPipelineDescriptor = null;
        for (int i = 0; i < quarterlyPipelineDescriptors.size(); i++) {
            if (quarterlyPipelineDescriptors.get(i)
                .equals(quarterlyPipelineDescriptor)) {
                if (i != quarterlyPipelineDescriptors.size() - 1) {
                    QuarterlyPipelineDescriptor temp = quarterlyPipelineDescriptors.get(i + 1);

                    // See if the next trigger exists.
                    String triggerName = getTriggerName(temp.getActivity(),
                        temp.getDataType());
                    TriggerDefinition trigger = triggerDefinitionCrud.retrieve(triggerName);

                    if (trigger != null) {
                        // Found one that exists; launch it.
                        nextQuarterlyPipelineDescriptor = temp;
                    } else {
                        // It doesn't exist; see if the next one exists.
                        quarterlyPipelineDescriptor = temp;
                    }
                }
            }
        }

        return nextQuarterlyPipelineDescriptor;
    }

    private String getTriggerName(Activity activity, DataType dataType) {
        return activity + "_" + dataType;
    }

    private Pair<Activity, DataType> getActivityAndDataType(String triggerName) {
        String[] strings = triggerName.split("_");
        return Pair.of(Activity.valueOf(strings[0]),
            DataType.valueOf(strings[1]));
    }

}
