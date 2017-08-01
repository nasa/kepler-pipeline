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

import gov.nasa.kepler.cm.TargetListImporter;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.MatlabDateFormatter;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapper;
import gov.nasa.kepler.dr.target.TargetListSetImporter;
import gov.nasa.kepler.dr.targetlistset.TargetListSetDocument;
import gov.nasa.kepler.dr.targetlistset.TargetListSetXB;
import gov.nasa.kepler.etem2.PackerParameters;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetList.SourceType;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.fc.RollTime;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.DataRepoParameters;
import gov.nasa.kepler.mc.TargetListParameters;
import gov.nasa.kepler.mc.TargetListSetValidator;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.nm.DataProductMessageDocument;
import gov.nasa.kepler.nm.DataProductMessageXB;
import gov.nasa.kepler.nm.FileXB;
import gov.nasa.kepler.ops.seed.CommonPipelineSeedData;
import gov.nasa.kepler.ops.seed.TadQuarterlyPipelineSeedData;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.kepler.tad.peer.AmtModuleParameters;
import gov.nasa.kepler.tad.peer.amt.AmtPipelineModule;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.text.DateFormat;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Pipeline module that ingests target lists and target list sets
 * 
 * For DEV use only.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class TargetImportPipelineModule extends PipelineModule {

    private static final double ROLL_TIME_OFFSET_DAYS = 0.5;

    private static final Log log = LogFactory.getLog(TargetImportPipelineModule.class);

    public static final String MODULE_NAME = "targetImport";

    private KicCrud kicCrud;
    private TargetSelectionCrud targetSelectionCrud;
    private TargetCrud targetCrud;
    private ParameterSetCrud parameterSetCrud;

    private LinkedList<File> targetListSets;
    private LinkedList<File> targetListFiles;

    private String dataRepoRoot;
    private DataRepoParameters dataRepoParameters;
    private ModuleOutputListsParameters modOutListsParameters;
    private PackerParameters packerParameters;
    private TargetImportParameters targetImportParameters;

    private List<String> planetaryTargetLists = new LinkedList<String>();

    private String lcTlsName = "";
    private String rpTlsName = "";
    private String sc1TlsName = "";
    private String sc2TlsName = "";
    private String sc3TlsName = "";

    private PipelineOperations pipelineOps;

    private double firstPointingMjd;

    private HashSet<Integer> validSkyGroups;

    public TargetImportPipelineModule() {
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
        requiredParams.add(DataRepoParameters.class);
        requiredParams.add(ModuleOutputListsParameters.class);
        requiredParams.add(PackerParameters.class);
        requiredParams.add(TargetImportParameters.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) throws PipelineException {

        dataRepoParameters = pipelineTask.getParameters(DataRepoParameters.class);
        modOutListsParameters = pipelineTask.getParameters(ModuleOutputListsParameters.class);
        packerParameters = pipelineTask.getParameters(PackerParameters.class);
        targetImportParameters = pipelineTask.getParameters(TargetImportParameters.class);
        dataRepoRoot = dataRepoParameters.getDataRepoPath();

        kicCrud = new KicCrud();
        targetCrud = new TargetCrud();
        targetSelectionCrud = new TargetSelectionCrud();
        parameterSetCrud = new ParameterSetCrud();
        pipelineOps = new PipelineOperations();

        RaDec2PixOperations raDec2PixOperations = new RaDec2PixOperations();
        RaDec2PixModel raDec2PixModel = raDec2PixOperations.retrieveRaDec2PixModel();
        double[] pointingMjds = raDec2PixModel.getPointingModel()
            .getMjds();
        if (pointingMjds.length <= 0) {
            throw new ModuleFatalProcessingException(
                "mjds array in pointing model is empty!");
        }
        firstPointingMjd = pointingMjds[0];

        computeValidSkyGroups();

        loadTargetLists();
        loadTargetListSets();

        deleteExisting();

        createTargetLists();
        createTargetListSets();

        storeMaskTableFile();

        /*
         * Update TAD and targetList parameters based on the TL & TLS names we
         * just imported
         */
        updateTadParams(TadQuarterlyPipelineSeedData.TAD_PARAMETERS_LC,
            lcTlsName, "");
        updateTadParams(TadQuarterlyPipelineSeedData.TAD_PARAMETERS_RP,
            rpTlsName, lcTlsName);
        try {
            // Use sc2TlsName here, since the etem q6 start date is 30 days later.
            updateTadParams(TadQuarterlyPipelineSeedData.TAD_PARAMETERS_SC_M1,
                sc2TlsName, lcTlsName);
            updateTadParams(TadQuarterlyPipelineSeedData.TAD_PARAMETERS_SC_M2,
                sc2TlsName, lcTlsName);
            updateTadParams(TadQuarterlyPipelineSeedData.TAD_PARAMETERS_SC_M3,
                sc3TlsName, lcTlsName);
        } catch (NullPointerException e) {
            log.warn("Unable to update parameters for "
                + TadQuarterlyPipelineSeedData.TAD_PARAMETERS_SC_M2
                + " and/or "
                + TadQuarterlyPipelineSeedData.TAD_PARAMETERS_SC_M3 + ".\n", e);
        }

        ParameterSet tlPs = parameterSetCrud.retrieveLatestVersionForName(CommonPipelineSeedData.TARGET_LIST_PARAMS);
        TargetListParameters tlBean = tlPs.parametersInstance();
        tlBean.setTargetListNames(planetaryTargetLists.toArray(new String[0]));
        pipelineOps.updateParameterSet(tlPs, tlBean, false);

        createPseudoTargetList();

        DatabaseServiceFactory.getInstance()
            .flush();
    }

    private void createPseudoTargetList() {
        File pseudoTargetListFile = new File(dataRepoRoot,
            targetImportParameters.getPseudoTargetListPath());
        if (pseudoTargetListFile.isFile()) {
            createTargetList(pseudoTargetListFile,
                targetImportParameters.getMaxTargetsPerTargetList());
        }
    }

    /**
     * Since sggen has been run since the KIC was copied, the sky groups may
     * have changed, so the mini-KIC may contain entries that are not on the sky
     * groups covered by moduleOutputListsParameters. This method builds a list
     * of the sky groups represented by moduleOutputListsParameters so that
     * loadTargetList() can throw out imported targets that are not on this
     * list.
     */
    private void computeValidSkyGroups() {
        RollTimeOperations rollTimeOperations = new RollTimeOperations();
        DateFormat formatter = MatlabDateFormatter.dateFormatter();
        double startMjd = 0.0;
        try {
            startMjd = ModifiedJulianDate.dateToMjd(formatter.parse(packerParameters.getStartDate()));
        } catch (ParseException e) {
            throw new PipelineException("unable to parse date: "
                + packerParameters.getStartDate(), e);
        }
        int season = rollTimeOperations.mjdToSeason(startMjd);
        validSkyGroups = new HashSet<Integer>();
        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                if (modOutListsParameters.included(ccdModule, ccdOutput)) {
                    int skyGroupId = kicCrud.retrieveSkyGroupId(ccdModule,
                        ccdOutput, season);
                    validSkyGroups.add(skyGroupId);
                }
            }
        }
    }

    private void updateTadParams(String paramSetName, String tlsName,
        String associatedLcTlsName) {
        ParameterSet tadPs = parameterSetCrud.retrieveLatestVersionForName(paramSetName);
        TadParameters tadBean = tadPs.parametersInstance();
        tadBean.setTargetListSetName(tlsName);
        tadBean.setAssociatedLcTargetListSetName(associatedLcTlsName);
        pipelineOps.updateParameterSet(tadPs, tadBean, false);

        // TODO: also import amt, ama, and maskTable params

    }

    /**
     * Delete existing TLS's and TL's with the same names as the new ones if
     * they already exist in the database
     */
    private void deleteExisting() {
        for (File newTlsFile : targetListSets) {

            TargetListSetDocument doc;
            try {
                doc = TargetListSetDocument.Factory.parse(newTlsFile);
            } catch (Exception e) {
                throw new ModuleFatalProcessingException(
                    "failed to parse TLS XML file: " + newTlsFile.getName(), e);
            }
            TargetListSetXB targetListSetXB = doc.getTargetListSet();
            String tlsName = targetListSetXB.getName();

            TargetListSet existingTls = targetSelectionCrud.retrieveTargetListSet(tlsName);
            if (existingTls != null) {
                log.info("Deleting existing TLS: " + existingTls.getName());

                deleteTargetListSet(existingTls);
            }
        }

        log.info("DONE Deleting existing TLS's");

        for (File tlFile : targetListFiles) {
            String tlName = tlFile.getName();

            TargetList existingTl = targetSelectionCrud.retrieveTargetList(tlName);
            if (existingTl != null) {
                List<TargetListSet> referencedTlsList = targetSelectionCrud.retrieveReferencingTls(existingTl);

                for (TargetListSet referencedTls : referencedTlsList) {
                    log.info("Deleting TLS: " + referencedTls.getName()
                        + " because it is referenced by TL: " + tlName);

                    deleteTargetListSet(referencedTls);
                }

                log.info("Deleting existing TL: " + existingTl);
                targetSelectionCrud.delete(existingTl);
            }
        }

        // TODO: clean up orphaned MaskTable(s)
    }

    private void deleteTargetListSet(TargetListSet tls) {
        // first delete TAD products, if any
        log.info("Deleting TAD products for TLS: " + tls.getName());
        TargetTable tt = tls.getTargetTable();
        TargetTable bt = tls.getBackgroundTable();
        TargetTable rt = tls.getRefPixTable();

        if (tt != null) {
            targetCrud.delete(tt);
        }
        if (bt != null) {
            targetCrud.delete(bt);
        }
        if (rt != null) {
            targetCrud.delete(rt);
        }
        targetSelectionCrud.delete(tls);
    }

    private void loadTargetLists() {
        File tlnmFile = new File(dataRepoRoot,
            targetImportParameters.getTlnmPath());
        targetListFiles = new LinkedList<File>();

        log.info("parsing TLNM notification message = " + tlnmFile);

        DataProductMessageDocument doc;
        try {
            doc = DataProductMessageDocument.Factory.parse(tlnmFile);
        } catch (Exception e1) {
            throw new ModuleFatalProcessingException(
                "failed to read TLNM file, caught e = " + e1, e1);
        }

        DataProductMessageXB message = doc.getDataProductMessage();
        FileXB[] fileList = message.getFileList()
            .getFileArray();

        for (FileXB fileXB : fileList) {
            String filename = fileXB.getFilename();
            targetListFiles.add(new File(tlnmFile.getParent(), filename));
            planetaryTargetLists.add(filename);
        }
    }

    private void createTargetLists() {
        for (File tlFile : targetListFiles) {
            log.info("Importing target list: " + tlFile.getName());

            createTargetList(tlFile,
                targetImportParameters.getMaxTargetsPerTargetList());
        }
    }

    private void createTargetList(File targetListFile,
        int maxTargetsPerTargetList) {

        if (targetListFile.exists()) {
            List<PlannedTarget> plannedTargets = new ArrayList<PlannedTarget>();
            String targetListName = targetListFile.getName();
            TargetList targetList = new TargetList(targetListName);

            TargetListImporter importer = new TargetListImporter(targetList);
            importer.setSkipMissingKeplerIds(true);
            importer.setTreatCustomTargetsAsNew(false);
            List<PlannedTarget> allTargets;
            try {
                allTargets = importer.ingestTargetFile(targetListFile.getAbsolutePath());
            } catch (Exception e) {
                throw new ModuleFatalProcessingException(
                    "Failed to parse target list file: " + targetListFile, e);
            }

            Map<Integer, Integer> skyGroupToTargetCountMap = new HashMap<Integer, Integer>();

            for (PlannedTarget plannedTarget : allTargets) {
                int skyGroup = plannedTarget.getSkyGroupId();

                if (validSkyGroups.contains(skyGroup)) {
                    Integer targetCount = skyGroupToTargetCountMap.get(skyGroup);
                    if (targetCount == null) {
                        targetCount = 0;
                    }

                    int keplerId = plannedTarget.getKeplerId();

                    if (!forceExcluded(keplerId)
                        && (forceIncluded(keplerId) || targetCount < maxTargetsPerTargetList)) {
                        plannedTargets.add(plannedTarget);
                        skyGroupToTargetCountMap.put(skyGroup, targetCount + 1);
                    }
                }
            }

            log.info("After trimming, target list: " + targetListName
                + " contains: " + plannedTargets.size() + " targets");

            targetList.setCategory(importer.getCategory());
            targetList.setSource(targetListFile.getAbsolutePath());
            targetList.setSourceType(SourceType.FILE);

            TargetList existingTargetList = targetSelectionCrud.retrieveTargetList(targetListName);
            if (existingTargetList != null) {
                throw new ModuleFatalProcessingException(
                    "Target list already exists in the database: "
                        + targetListName);
            }

            targetSelectionCrud.create(targetList);
            targetSelectionCrud.create(plannedTargets);
        } else {
            throw new ModuleFatalProcessingException(
                "Target list file does not exist: " + targetListFile);
        }
    }

    private boolean forceIncluded(int keplerId) {
        int[] includeArray = targetImportParameters.getForceIncludedKeplerIdArray();

        if (includeArray != null && includeArray.length != 0) {
            boolean included = ArrayUtils.contains(includeArray, keplerId);
            if (included) {
                log.info("Including keplerId=" + keplerId
                    + " because it is in the forceIncludedKeplerIdArray");
            }
            return included;
        }
        return false;
    }

    private boolean forceExcluded(int keplerId) {
        int[] excludeArray = targetImportParameters.getForceExcludedKeplerIdArray();

        if (excludeArray != null && excludeArray.length != 0
            && ArrayUtils.contains(excludeArray, keplerId)) {
            log.info("Excluding keplerId=" + keplerId
                + " because it is in the forceExcludedKeplerIdArray");
            return true;
        }
        return false;
    }

    private void loadTargetListSets() {

        File tlsnmFile = new File(dataRepoRoot,
            targetImportParameters.getTlsnmPath());

        log.info("parsing TLSNM notification message = " + tlsnmFile);

        DataProductMessageDocument doc;
        try {
            doc = DataProductMessageDocument.Factory.parse(tlsnmFile);
        } catch (Exception e1) {
            throw new ModuleFatalProcessingException(
                "failed to read TLSNM file, caught e = " + e1, e1);
        }

        DataProductMessageXB message = doc.getDataProductMessage();
        FileXB[] fileList = message.getFileList()
            .getFileArray();

        targetListSets = new LinkedList<File>();

        for (FileXB fileXB : fileList) {
            String filename = fileXB.getFilename();

            targetListSets.add(new File(tlsnmFile.getParent(), filename));
        }
    }

    private TargetListSet loadTargetListSet(File tlsXmlFile) {
        TargetListSetImporter importer = new TargetListSetImporter();

        if (!tlsXmlFile.exists()) {
            throw new ModuleFatalProcessingException(
                "tls file does not exist: " + tlsXmlFile);
        }

        TargetListSet tls = importer.importFile(tlsXmlFile, false);

        tls.setState(State.UNLOCKED);
        RollTimeOperations rollTimeOperations = new RollTimeOperations();
        trimDates(tls, rollTimeOperations);
        tls.setState(State.LOCKED);

        List<TargetListSet> tlsList = new ArrayList<TargetListSet>();
        tlsList.add(tls);
        TargetListSetValidator validator = new TargetListSetValidator(
            rollTimeOperations);
        validator.validate(tlsList);

        return tls;
    }

    private void trimDates(TargetListSet tls,
        RollTimeOperations rollTimeOperations) {
        ModifiedJulianDate startMjd = new ModifiedJulianDate(tls.getStart()
            .getTime());
        int startSeason = rollTimeOperations.mjdToSeason(startMjd.getMjd());

        ModifiedJulianDate endMjd = new ModifiedJulianDate(tls.getEnd()
            .getTime());
        int endSeason = rollTimeOperations.mjdToSeason(endMjd.getMjd());

        if (startSeason != endSeason) {
            RollTime rollTime = rollTimeOperations.retrieveRollTime(endMjd.getMjd());

            double startMjdToRoll = rollTime.getMjd() - startMjd.getMjd();
            double RollToEndMjd = endMjd.getMjd() - rollTime.getMjd();

            if (startMjdToRoll > RollToEndMjd) {
                // Trim roll to endMjd.
                tls.setEnd(new ModifiedJulianDate(rollTime.getMjd()
                    - ROLL_TIME_OFFSET_DAYS).getTime());
            } else {
                // Trim startMjd to roll.
                tls.setStart(new ModifiedJulianDate(rollTime.getMjd()
                    + ROLL_TIME_OFFSET_DAYS).getTime());
            }
        }
    }

    private void createTargetListSets() {

        for (File tlsFile : targetListSets) {
            log.info("creating TLS: " + tlsFile.getName());
            TargetListSet tls = loadTargetListSet(tlsFile);
            TargetType tlsType = tls.getType();
            String tlsName = tls.getName();

            switch (tlsType) {
                case LONG_CADENCE:
                    lcTlsName = tlsName;
                    break;

                case REFERENCE_PIXEL:
                    rpTlsName = tlsName;
                    break;

                case SHORT_CADENCE:
                    if (tlsName.contains("sc1")) {
                        sc1TlsName = tlsName;
                    } else if (tlsName.contains("sc2")) {
                        sc2TlsName = tlsName;
                    } else if (tlsName.contains("sc3")) {
                        sc3TlsName = tlsName;
                    } else {
                        log.warn("Can't tell which table this is from the name, not setting TadParameters: "
                            + tlsName);
                    }
                    break;
            }
            createTargetListSet(tls);
        }
    }

    private void createTargetListSet(TargetListSet targetListSet) {

        // fix start date if before pointing model
        Date tlsStartDate = targetListSet.getStart();
        double tlsStartMjd = ModifiedJulianDate.dateToMjd(tlsStartDate);
        if (tlsStartMjd < firstPointingMjd) {
            Date newTlsStart = ModifiedJulianDate.mjdToDate(firstPointingMjd + 1.0);
            targetListSet.setState(State.UNLOCKED);
            targetListSet.setStart(newTlsStart);
            targetListSet.setState(State.LOCKED);
        }

        targetSelectionCrud.create(targetListSet);
    }

    private void storeMaskTableFile() {
        try {
            File mtnmFile = new File(dataRepoRoot,
                targetImportParameters.getMtnmPath());

            DataProductMessageDocument doc = DataProductMessageDocument.Factory.parse(mtnmFile);
            DataProductMessageXB message = doc.getDataProductMessage();
            FileXB[] fileList = message.getFileList()
                .getFileArray();
            String maskFileName = fileList[0]
                .getFilename();

            FsId fsId = DrFsIdFactory.getFile(DispatcherType.MASK_TABLE,
                maskFileName);

            FileStoreClient fsClient = FileStoreClientFactory.getInstance();
            fsClient.writeBlob(fsId, DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID,
                new File(mtnmFile.getParent(), maskFileName));

            // Update amt params.
            ParameterSet amtPs = parameterSetCrud.retrieveLatestVersionForName(AmtPipelineModule.MODULE_NAME);
            AmtModuleParameters amtParameters = amtPs.parametersInstance();
            amtParameters.setUseOptimalApertureInputs(0);
            amtParameters.setMaskTableImportSourceFileName(maskFileName);
            pipelineOps.updateParameterSet(amtPs, amtParameters, false);
        } catch (Exception e) {
            throw new PipelineException("Unable to store mask table file.", e);
        }
    }
}
