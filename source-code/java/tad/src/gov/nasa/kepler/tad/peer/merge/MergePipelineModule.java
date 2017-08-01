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

package gov.nasa.kepler.tad.peer.merge;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Maps.newHashMap;
import static com.google.common.collect.Sets.newHashSet;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.MaskTableFactory;
import gov.nasa.kepler.hibernate.tad.ModOut;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.ObservedTargetFactory;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableFactory;
import gov.nasa.kepler.mc.TargetListSetOperations;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.tad.peer.AmaModuleParameters;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Creates the {@link TargetTable} and {@link ObservedTarget}s for a TAD
 * pipeline run. Preconditions: {@link TargetListSet} is LOCKED or TAD_COMPLETE.
 * Postconditions: {@link TargetTable} and {@link ObservedTarget}s are generated
 * for the {@link TargetListSet}.
 * 
 * @author Miles Cote
 */
public class MergePipelineModule extends PipelineModule {

    static final MaskType MASK_TYPE = MaskType.TARGET;

    public static final String MODULE_NAME = "merge";

    private static final Log log = LogFactory.getLog(MergePipelineModule.class);

    private PipelineTask pipelineTask;
    private TargetListSet targetListSet;
    private TargetListSet associatedLcTargetListSet;

    private Map<Integer, Set<String>> targetLabelMap;
    private Map<Integer, PlannedTarget> includeMap;
    private Set<Integer> excludeKeplerIds;

    private final TargetCrud targetCrud;
    private final TargetSelectionCrud targetSelectionCrud;
    private final KicCrud kicCrud;
    private final TargetTableFactory targetTableFactory;
    private final MaskTableFactory maskTableFactory;
    private final RollTimeOperations rollTimeOperations;
    private final TadLabelValidatorFactory tadLabelValidatorFactory;
    private final DatabaseService databaseService;
    private final ObservedTargetFactory observedTargetFactory;

    public MergePipelineModule() {
        this(new TargetCrud(), new TargetSelectionCrud(), new KicCrud(),
            new TargetTableFactory(), new MaskTableFactory(),
            new RollTimeOperations(), new TadLabelValidatorFactory(),
            DatabaseServiceFactory.getInstance(), new ObservedTargetFactory());
    }

    MergePipelineModule(TargetCrud targetCrud,
        TargetSelectionCrud targetSelectionCrud, KicCrud kicCrud,
        TargetTableFactory targetTableFactory,
        MaskTableFactory maskTableFactory,
        RollTimeOperations rollTimeOperations,
        TadLabelValidatorFactory tadLabelValidatorFactory,
        DatabaseService databaseService,
        ObservedTargetFactory observedTargetFactory) {
        this.targetCrud = targetCrud;
        this.targetSelectionCrud = targetSelectionCrud;
        this.kicCrud = kicCrud;
        this.targetTableFactory = targetTableFactory;
        this.maskTableFactory = maskTableFactory;
        this.rollTimeOperations = rollTimeOperations;
        this.tadLabelValidatorFactory = tadLabelValidatorFactory;
        this.databaseService = databaseService;
        this.observedTargetFactory = observedTargetFactory;
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
        List<Class<? extends Parameters>> requiredParams = newArrayList();
        requiredParams.add(TadParameters.class);
        requiredParams.add(AmaModuleParameters.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        this.pipelineTask = pipelineTask;

        TadParameters params = pipelineTask.getParameters(TadParameters.class);
        String targetListSetName = params.getTargetListSetName();
        if (targetListSetName == null || targetListSetName.isEmpty()) {
            throw new NullPointerException("target list set name is null");
        }

        targetListSet = targetSelectionCrud.retrieveTargetListSet(targetListSetName);
        if (targetListSet == null) {
            throw new NullPointerException(targetListSetName
                + ": no such target list set"
                + TargetListSetOperations.getTlsInfo(targetListSet));
        }

        TargetListSetOperations.validateNoExistingProducts(targetListSet);

        log.info("Checking the targetListSet state.");
        if (targetListSet.getState() != State.LOCKED) {
            throw new ModuleFatalProcessingException(
                TargetListSetOperations.getNotLockedTlsErrorText(targetListSet));
        }

        String associatedLcTargetListSetName = params.getAssociatedLcTargetListSetName();
        if (associatedLcTargetListSetName != null
            && !associatedLcTargetListSetName.isEmpty()) {
            associatedLcTargetListSet = targetSelectionCrud.retrieveTargetListSet(associatedLcTargetListSetName);
            if (associatedLcTargetListSet == null) {
                throw new NullPointerException(associatedLcTargetListSetName
                    + ": no such target list set"
                    + TargetListSetOperations.getTlsInfo(targetListSet,
                        associatedLcTargetListSet));
            }
        }

        log.info(TargetListSetOperations.getTlsInfo(targetListSet,
            associatedLcTargetListSet));

        log.info("Set the associatedLcTargetListSet.");
        targetListSet.setAssociatedLcTls(associatedLcTargetListSet);

        manageTargetTablesAndMaskTables();

        int startSeason = TargetListSetOperations.validateDates(targetListSet,
            rollTimeOperations);

        TargetTable targetTable = targetListSet.getTargetTable();
        targetTable.setObservingSeason(startSeason);
        targetTable.setPlannedStartTime(targetListSet.getStart());
        targetTable.setPlannedEndTime(targetListSet.getEnd());

        if (targetListSet.getType() != TargetType.LONG_CADENCE) {
            if (associatedLcTargetListSet.getType() != TargetType.LONG_CADENCE) {
                throw new ModuleFatalProcessingException(
                    "The associated long cadence target list set must be of type LONG_CADENCE.\n  type:"
                        + associatedLcTargetListSet.getType()
                        + TargetListSetOperations.getTlsInfo(targetListSet,
                            associatedLcTargetListSet));
            }
        }

        merge();
    }

    private void manageTargetTablesAndMaskTables() {
        TargetTable oldTargetTable = targetListSet.getTargetTable();
        MaskTable oldMaskTable = null;
        if (oldTargetTable != null) {
            oldMaskTable = oldTargetTable.getMaskTable();
        }

        deleteOldAndCreateNewTargetTable(targetListSet);

        switch (targetListSet.getType()) {
            case LONG_CADENCE:
                // Create new mask table.
                MaskTable newMaskTable = maskTableFactory.create(MASK_TYPE);
                targetCrud.createMaskTable(newMaskTable);
                targetListSet.getTargetTable()
                    .setMaskTable(newMaskTable);

                // Delete all targetTables of tls's that use the old mask table.
                List<TargetListSet> associatedTargetListSets = targetSelectionCrud.retrieveTargetListSets(oldMaskTable);
                for (TargetListSet associatedTargetListSet : associatedTargetListSets) {
                    deleteOldAndCreateNewTargetTable(associatedTargetListSet);
                    associatedTargetListSet.getTargetTable()
                        .setMaskTable(newMaskTable);
                }

                // Delete the old maskTable.
                targetCrud.delete(oldMaskTable);
                break;
            case SHORT_CADENCE:
                targetListSet.getTargetTable()
                    .setMaskTable(associatedLcTargetListSet.getTargetTable()
                        .getMaskTable());
                break;
            case REFERENCE_PIXEL:
                targetListSet.getTargetTable()
                    .setMaskTable(associatedLcTargetListSet.getTargetTable()
                        .getMaskTable());
                targetCrud.deleteSupermasks(targetListSet.getTargetTable()
                    .getMaskTable());
                break;
        }
    }

    private void deleteOldAndCreateNewTargetTable(TargetListSet targetListSet) {
        if (targetListSet.getState() != State.LOCKED) {
            throw new ModuleFatalProcessingException(
                "targetListSet must be in the LOCKED state in order for tad to modify it."
                    + TargetListSetOperations.getTlsInfo(targetListSet));
        }

        TargetTable oldTargetTable = targetListSet.getTargetTable();
        MaskTable oldMaskTable = null;
        if (oldTargetTable != null) {
            oldMaskTable = oldTargetTable.getMaskTable();
        }

        // Create a new targetTable for the tls.
        TargetTable newTargetTable = targetTableFactory.create(targetListSet.getType());
        newTargetTable.setMaskTable(oldMaskTable);
        targetCrud.createTargetTable(newTargetTable);
        targetListSet.setTargetTable(newTargetTable);

        // Delete the old target table.
        targetCrud.delete(oldTargetTable);
    }

    /**
     * Uses the targetLists and the excludedTargetLists fields of the input
     * {@link TargetListSet} object and merges them into a {@link TargetTable}
     * by creating {@link ObservedTarget}s associated with the
     * {@link TargetTable}. If the {@link PlannedTarget}s to merge have
     * {@link Aperture}s, they are copied into the {@link ObservedTarget}s.
     * 
     * @throws PipelineException
     * 
     * @throws PipelineException
     */
    private void merge() {
        TargetTable targetTable = targetListSet.getTargetTable();

        log.info("Retrieve the existing observedTargets from the last merge.");
        List<ObservedTarget> observedTargets = targetCrud.retrieveObservedTargetsPlusRejected(targetTable);

        log.info("Found " + observedTargets.size()
            + " ObservedTargets. Create the includeMap of PlannedTargets.");
        includeMap = newHashMap();
        targetLabelMap = newHashMap();
        AmaModuleParameters amaModuleParams = pipelineTask.getParameters(AmaModuleParameters.class);
        TadLabelValidator tadLabelValidator = tadLabelValidatorFactory.create(amaModuleParams);
        for (TargetList targetList : targetListSet.getTargetLists()) {
            List<PlannedTarget> targets = targetSelectionCrud.retrievePlannedTargets(targetList);

            tadLabelValidator.validate(targets);

            log.info("Found " + targets.size() + " PlannedTargets.");
            for (PlannedTarget plannedTarget : targets) {
                int keplerId = plannedTarget.getKeplerId();

                // Fail if an invalid keplerId is found.
                if (keplerId == TargetManagementConstants.INVALID_KEPLER_ID) {
                    throw new ModuleFatalProcessingException(
                        "PlannedTargets on inclusion lists must have valid keplerIds."
                            + TargetListSetOperations.getTlsInfo(targetListSet));
                }

                includeMap.put(keplerId, plannedTarget);

                // Labels logic.
                Set<String> targetLabels = targetLabelMap.get(keplerId);
                if (targetLabels == null) {
                    targetLabels = newHashSet();
                    targetLabelMap.put(keplerId, targetLabels);
                }

                for (String label : plannedTarget.getLabels()) {
                    targetLabels.add(label);
                }
            }
        }

        log.info("Checking that the includeMap is not empty.");
        if (includeMap.isEmpty()) {
            throw new ModuleFatalProcessingException(
                "No PlannedTargets or ObservedTargets were retrieved from the database."
                    + TargetListSetOperations.getTlsInfo(targetListSet));
        }

        log.info("Create the excludeSet of keplerIds.");
        excludeKeplerIds = newHashSet();
        for (TargetList excludeList : targetListSet.getExcludedTargetLists()) {
            for (PlannedTarget excludeTarget : targetSelectionCrud.retrievePlannedTargets(excludeList)) {
                int keplerId = excludeTarget.getKeplerId();

                // Fail if an invalid keplerId is found.
                if (keplerId == TargetManagementConstants.INVALID_KEPLER_ID) {
                    throw new ModuleFatalProcessingException(
                        "PlannedTargets on exclusion lists must have valid keplerIds."
                            + TargetListSetOperations.getTlsInfo(targetListSet));
                }

                excludeKeplerIds.add(keplerId);
            }
        }

        // Caching includeMapSize so that includeMap can be garbage collected.
        int includeMapSize = includeMap.size();

        int createdTargetsSize = createNewObservedTargets(targetTable,
            observedTargets);

        log.info("Merged " + includeMapSize + " targets in "
            + targetListSet.getTargetLists()
                .size() + " target lists into " + createdTargetsSize
            + " distinct targets in " + targetListSet.getName()
            + " target list set.");
    }

    /**
     * Create new {@link ObservedTarget}s.
     * 
     * @throws PipelineException
     */
    private int createNewObservedTargets(TargetTable targetTable,
        List<ObservedTarget> observedTargets) {
        Set<ObservedTarget> targetsToCreate = newHashSet();

        log.info("Add new observedTargets to observedTargets.");
        for (PlannedTarget plannedTarget : includeMap.values()) {
            ObservedTarget observedTarget = observedTargetFactory.create(plannedTarget.getKeplerId());
            observedTarget.setTargetTable(targetTable);
            observedTarget.setPipelineTask(pipelineTask);
            observedTarget.setLabels(targetLabelMap.get(plannedTarget.getKeplerId()));

            if (plannedTarget.getAperture() != null) {
                Aperture aperture = plannedTarget.getAperture()
                    .createCopy();
                observedTarget.setAperture(aperture);
                aperture.setTargetTable(targetTable);
                observedTarget.setAperturePixelCount(aperture.getOffsets()
                    .size());
            }

            if (!observedTargets.contains(observedTarget)
                && !excludeKeplerIds.contains(plannedTarget.getKeplerId())) {
                targetsToCreate.add(observedTarget);
            }
        }

        log.info("Retrieving all SkyGroups for this season for in-memory lookup.");
        int observingSeason = targetListSet.getTargetTable()
            .getObservingSeason();
        Map<Integer, SkyGroup> skyGroupIdToSkyGroupMap = newHashMap();
        for (SkyGroup skyGroup : kicCrud.retrieveAllSkyGroups()) {
            // Only add the skyGroup if it's in this season.
            if (skyGroup.getObservingSeason() == observingSeason) {
                skyGroupIdToSkyGroupMap.put(skyGroup.getSkyGroupId(), skyGroup);
            }
        }

        log.info("Set the module/outputs of the new observedTargets.");
        for (ObservedTarget observedTarget : targetsToCreate) {
            int skyGroupId = includeMap.get(observedTarget.getKeplerId())
                .getSkyGroupId();

            // Reject targets whose skyGroupId == 0.
            if (skyGroupId == 0) {
                observedTarget.setRejected(true);
            } else {
                SkyGroup skyGroup = skyGroupIdToSkyGroupMap.get(skyGroupId);

                observedTarget.setModOut(ModOut.of(skyGroup.getCcdModule(),
                    skyGroup.getCcdOutput()));
            }
        }

        databaseService.evictAll(newArrayList(includeMap.values()));
        includeMap = null;

        targetCrud.createObservedTargets(targetsToCreate);

        return targetsToCreate.size();
    }

}
