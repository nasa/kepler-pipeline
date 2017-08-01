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

package gov.nasa.kepler.tad.peer.tadval;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Sets.newHashSet;
import gov.nasa.kepler.common.CcdRegion;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.hibernate.cm.PlannedTarget.TargetLabel;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.BadPixelRateBin;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.SupplementalTargetListSetSetter;
import gov.nasa.kepler.hibernate.tad.TadModOutReport;
import gov.nasa.kepler.hibernate.tad.TadReport;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetDefinitionAndPixelCounts;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.TargetListSetOperations;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.tad.operations.TadRevisedParameters;
import gov.nasa.kepler.tad.peer.ama.AmaPipelineModule;
import gov.nasa.kepler.tad.peer.rpts.RptsPipelineModule;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Reports summary information at the end of a TAD pipeline run. Preconditions:
 * {@link AmaPipelineModule} or {@link RptsPipelineModule} has run on the
 * {@link TargetListSet}. Postconditions: {@link TadReport} is generated for the
 * {@link TargetListSet}.
 * 
 * <pre>
 * The SOC will check the following constraints and raise an ERROR if they are
 * exceeded (XML files not generated or sent to SO, these are hard limits): 
 *  - Less than or equal to 87,040 total pixels in the mask aperture table. 
 *  - Less than or equal to 1024 target apertures 
 *  - Less than or equal to 1024 background apertures 
 *  - Less than or equal to 512 total short cadence targets 
 *  - Less than or equal to 3000 total reference pixel targets 
 *  - Less than or equal to 16383 targets on any single module/output 
 *  - Less than or equal to 5,440,000 total pixels in the target definition table.
 * </pre>
 * 
 * @author Miles Cote
 */
public class TadValPipelineModule extends PipelineModule {

    public static final String MODULE_NAME = "tadval";

    private PipelineTask pipelineTask;
    private TargetListSet targetListSet;
    private TadParameters tadParameters;
    private boolean valid = true;

    private TargetCrud targetCrud;
    private TargetSelectionCrud targetSelectionCrud;

    private static final Log log = LogFactory.getLog(TadValPipelineModule.class);

    public TadValPipelineModule() {
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        targetCrud = new TargetCrud(databaseService);
        targetSelectionCrud = new TargetSelectionCrud(databaseService);
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
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        this.pipelineTask = pipelineTask;

        tadParameters = pipelineTask.getParameters(TadParameters.class);
        targetListSet = targetSelectionCrud.retrieveTargetListSet(tadParameters.getTargetListSetName());

        log.info(TargetListSetOperations.getTlsInfo(targetListSet));

        if (targetListSet.getState() != State.LOCKED) {
            throw new ModuleFatalProcessingException(
                TargetListSetOperations.getNotLockedTlsErrorText(targetListSet));
        }

        String suppForTlsName = tadParameters.getSupplementalFor();
        if (suppForTlsName != null && !suppForTlsName.isEmpty()) {
            // If it's a supp tad run, do the supp validation.
            SupplementalTargetListSetSetter setter = new SupplementalTargetListSetSetter(
                targetSelectionCrud);
            setter.set(suppForTlsName, tadParameters.getTargetListSetName());

            TargetListSet origTls = targetSelectionCrud.retrieveTargetListSet(suppForTlsName);
            if (origTls == null) {
                throw new IllegalArgumentException(
                    "The origTls must exist in the database.\n  origTlsName: "
                        + suppForTlsName);
            }

            // This call is here to ensure that targetTableComparator is called
            // to
            // validate the suppTT against the origTT.
            // targetCrud.retrieveObservedTargets() methods call
            // targetTableComparator.
            for (int ccdModule : FcConstants.modulesList) {
                for (int ccdOutput : FcConstants.outputsList) {
                    log.info("Validating supplemental targets for mod/out "
                        + ccdModule + "/" + ccdOutput);
                    targetCrud.retrieveObservedTargets(
                        origTls.getTargetTable(), ccdModule, ccdOutput);
                }
            }
        } else {
            // Otherwise, do the real validation.
            validateTargetListSet(targetListSet);
        }

        if (valid) {
            targetListSet.setState(State.TAD_COMPLETED);
        }
    }

    private void validateTargetListSet(TargetListSet targetListSet) {

        validateTargetTable(targetListSet.getTargetTable());

        if (targetListSet.getType() == TargetType.LONG_CADENCE) {
            TargetTable backgroundTable = targetListSet.getBackgroundTable();
            if (backgroundTable == null) {
                valid = false;
                targetListSet.getTargetTable()
                    .getTadReport()
                    .getErrors()
                    .add(
                        "A long cadence target list set must have a background target table.");
            } else {
                validateTargetTable(backgroundTable);
            }
        }
    }

    private void validateTargetTable(TargetTable targetTable) {
        TadReport report = new TadReport();
        report.setPipelineTask(pipelineTask);
        targetTable.setTadReport(report);

        TargetType targetType = targetTable.getType();

        log.info("retrieving " + Mask.class.getName() + "(s)");
        MaskTable maskTable = targetTable.getMaskTable();
        MaskType maskType = maskTable.getType();
        List<Mask> masks = targetCrud.retrieveMasks(maskTable);

        report.setTotalMaskCount(masks.size());

        int totalMaskOffsetCount = 0;
        int expectedMaskIndex = 0;
        for (Mask mask : masks) {
            if (mask.isSupermask()) {
                report.setSupermaskCount(report.getSupermaskCount() + 1);
            }

            if (mask.isUsed()) {
                report.setUsedMaskCount(report.getUsedMaskCount() + 1);
            }

            if (expectedMaskIndex != mask.getIndexInTable()) {
                valid = false;
                report.getErrors()
                    .add(
                        "Mask indices must start at 0 and increment by 1.  Expected mask index "
                            + expectedMaskIndex + ", but was "
                            + mask.getIndexInTable() + ".");
            }

            totalMaskOffsetCount += mask.getOffsets()
                .size();
            expectedMaskIndex++;
        }

        if (totalMaskOffsetCount > TargetManagementConstants.MAX_TOTAL_APERTURE_OFFSETS) {
            valid = false;
            report.getErrors()
                .add(
                    "Expected less than or equal to "
                        + TargetManagementConstants.MAX_TOTAL_APERTURE_OFFSETS
                        + " total aperture definition pixels, but there were "
                        + totalMaskOffsetCount + ".");
        }

        log.info("retrieving " + ObservedTarget.class.getName() + "(s)");
        List<ObservedTarget> targets = targetCrud.retrieveObservedTargetsPlusRejected(targetTable);
        log.info("Completed retrieving " + ObservedTarget.class.getName()
            + "(s)");

        // Count up unique pixels.
        List<Set<Offset>> absolutePixels = newArrayList();
        for (int i = 0; i < FcConstants.MODULE_OUTPUTS; i++) {
            Set<Offset> channelPixels = newHashSet();
            absolutePixels.add(channelPixels);
        }

        for (ObservedTarget target : targets) {
            if (target.isRejected()) {
                report.setRejectedByCoaTargetCount(report.getRejectedByCoaTargetCount() + 1);

                // There's no mod/out report if the skyGroupId is 0.
                if (target.getCcdModule() != 0) {
                    TadModOutReport modOutReport = report.getModuleOutputSummary(
                        target.getCcdModule(), target.getCcdOutput());
                    modOutReport.setRejectedByCoaTargetCount(modOutReport.getRejectedByCoaTargetCount() + 1);
                }
            }

            if (TargetManagementConstants.isCustomTarget(target.getKeplerId())
                && target.getAperture() == null) {
                report.getWarnings()
                    .add(
                        "Each custom target should have a user-defined aperture (keplerId="
                            + target.getKeplerId() + ").");
                report.setCustomTargetsWithNoApertureCount(report.getCustomTargetsWithNoApertureCount() + 1);
            }

            if (target.getAperture() != null && !target.isRejected()) {
                if (!doesMaskContainAperture(target)) {
                    valid = false;
                    report.getErrors()
                        .add(
                            "Target definitions should contain their optimal aperture (keplerId = "
                                + target.getKeplerId() + ")  (rejected = "
                                + target.isRejected() + ").");
                    report.setTargetsWithMasksSmallerThanOptimalApertureCount(report.getTargetsWithMasksSmallerThanOptimalApertureCount() + 1);
                }

                // Bin based on bad pixel rate.
                if (target.getAperturePixelCount() != 0) {
                    float badPixelRate = target.getBadPixelCount()
                        / (float) target.getAperturePixelCount();
                    for (BadPixelRateBin bin : report.getBadPixelRateBins()) {
                        if (badPixelRate > bin.getExclusiveLowerBoundForBadPixelRate()
                            && badPixelRate <= bin.getInclusiveUpperBoundForBadPixelRate()) {
                            bin.setTargetCount(bin.getTargetCount() + 1);
                        }
                    }
                }
            }

            // Log a warning in the report if a target has opAp pixels and no
            // targetDef pixels.
            if (target.getAperture() != null && !target.getAperture()
                .getOffsets()
                .isEmpty()) {
                int targetDefPixelCount = 0;
                for (TargetDefinition targetDef : target.getTargetDefinitions()) {
                    targetDefPixelCount += targetDef.getMask()
                        .getOffsets()
                        .size();
                }

                if (targetDefPixelCount == 0) {
                    report.getWarnings()
                        .add(
                            "Targets that have optimal aperture pixels should have target definition pixels.\n  keplerId: "
                                + target.getKeplerId()
                                + "\n  rejected: "
                                + target.isRejected()
                                + "\n  aperturePixelCount: "
                                + target.getAperture()
                                    .getOffsets()
                                    .size()
                                + "\n  targetDefPixelCount: "
                                + targetDefPixelCount);
                }
            }

            // Only count targets and pixels for targets that actually have
            // targetDefs.
            if (target.getTargetDefinitions()
                .size() != 0) {
                TadModOutReport modOutReport = report.getModuleOutputSummary(
                    target.getCcdModule(), target.getCcdOutput());
                Set<Offset> pixelSet = absolutePixels.get(FcConstants.getChannelNumber(
                    target.getCcdModule(), target.getCcdOutput()) - 1);
                countTargetsAndPixels(target, report, modOutReport, pixelSet);
            }
        }

        // Store unique pixel counts.
        int i = 0;
        for (Set<Offset> pixelSet : absolutePixels) {
            TargetDefinitionAndPixelCounts summaryCounts = report.getTargetDefinitionAndPixelCounts();
            TargetDefinitionAndPixelCounts modOutCounts = report.getModOutReports()
                .get(i)
                .getTargetDefinitionAndPixelCounts();

            summaryCounts.setUniquePixelCount(summaryCounts.getUniquePixelCount()
                + pixelSet.size());
            modOutCounts.setUniquePixelCount(modOutCounts.getUniquePixelCount()
                + pixelSet.size());

            i++;
        }

        if (report.getTargetDefinitionAndPixelCounts()
            .getTotalTargetDefCount() != 0) {
            report.setAveragePixelsPerTargetDef((float) report.getTargetDefinitionAndPixelCounts()
                .getTotalPixelCount()
                / report.getTargetDefinitionAndPixelCounts()
                    .getTotalTargetDefCount());
        } else {
            report.setAveragePixelsPerTargetDef(0);
        }

        report.setMergedTargetCount(targets.size());

        switch (maskType) {
            case TARGET:
                // * - Less than or equal to 1024 target apertures
                if (masks.size() > TargetManagementConstants.MAX_TARGET_APERTURES) {
                    valid = false;
                    report.getErrors()
                        .add(
                            "Expected less than or equal to "
                                + TargetManagementConstants.MAX_TARGET_APERTURES
                                + " target apertures, but there were "
                                + masks.size() + ".");
                }
                break;
            case BACKGROUND:
                // * - Less than or equal to 1024 background apertures
                if (masks.size() > TargetManagementConstants.MAX_BACKGROUND_APERTURES) {
                    valid = false;
                    report.getErrors()
                        .add(
                            "Expected less than or equal to "
                                + TargetManagementConstants.MAX_BACKGROUND_APERTURES
                                + " background apertures, but there were "
                                + masks.size() + ".");
                }
                break;
        }

        // int specificMaxTargetsPerChannel = Integer.MAX_VALUE;
        switch (targetType) {
            case LONG_CADENCE:
                // * - Less than or equal to 170,000 total long cadence targets
                if (report.getTargetDefinitionAndPixelCounts()
                    .getTotalTargetDefCount() > TargetManagementConstants.MAX_LONG_CADENCE_TARGET_DEFS) {
                    valid = false;
                    report.getErrors()
                        .add(
                            "Expected less than or equal to "
                                + TargetManagementConstants.MAX_LONG_CADENCE_TARGET_DEFS
                                + " total long cadence targets, but there were "
                                + report.getTargetDefinitionAndPixelCounts()
                                    .getTotalTargetDefCount());
                }
                // Flight constaint:
                if (report.getTargetDefinitionAndPixelCounts()
                    .getTotalPixelCount() > TargetManagementConstants.MAX_LONG_CADENCE_PIXELS) {
                    valid = false;
                    report.getErrors()
                        .add(
                            "Expected less than or equal to "
                                + TargetManagementConstants.MAX_LONG_CADENCE_PIXELS
                                + " total long cadence pixels, but there were "
                                + report.getTargetDefinitionAndPixelCounts()
                                    .getTotalPixelCount());
                }
                break;
            case SHORT_CADENCE:
                // * - Less than or equal to 512 total short cadence targets
                if (report.getTargetDefinitionAndPixelCounts()
                    .getTotalTargetDefCount() > TargetManagementConstants.MAX_SHORT_CADENCE_TARGET_DEFS) {
                    valid = false;
                    report.getErrors()
                        .add(
                            "Expected less than or equal to "
                                + TargetManagementConstants.MAX_SHORT_CADENCE_TARGET_DEFS
                                + " total short cadence targets, but there were "
                                + report.getTargetDefinitionAndPixelCounts()
                                    .getTotalTargetDefCount());
                }
                // Flight constaint:
                if (report.getTargetDefinitionAndPixelCounts()
                    .getTotalPixelCount() > TargetManagementConstants.MAX_SHORT_CADENCE_PIXELS) {
                    valid = false;
                    report.getErrors()
                        .add(
                            "Expected less than or equal to "
                                + TargetManagementConstants.MAX_SHORT_CADENCE_PIXELS
                                + " total short cadence pixels, but there were "
                                + report.getTargetDefinitionAndPixelCounts()
                                    .getTotalPixelCount());
                }
                break;
            case REFERENCE_PIXEL:
                // * - Less than or equal to 3000 total reference pixel targets
                if (report.getTargetDefinitionAndPixelCounts()
                    .getTotalTargetDefCount() > TargetManagementConstants.MAX_REFERENCE_PIXEL_TARGET_DEFS) {
                    valid = false;
                    report.getErrors()
                        .add(
                            "Expected less than or equal to "
                                + TargetManagementConstants.MAX_REFERENCE_PIXEL_TARGET_DEFS
                                + " total reference pixel targets, but there were "
                                + report.getTargetDefinitionAndPixelCounts()
                                    .getTotalTargetDefCount());
                }
                // Flight constaint:
                if (report.getTargetDefinitionAndPixelCounts()
                    .getTotalPixelCount() > TargetManagementConstants.MAX_REFERENCE_PIXEL_PIXELS) {
                    valid = false;
                    report.getErrors()
                        .add(
                            "Expected less than or equal to "
                                + TargetManagementConstants.MAX_REFERENCE_PIXEL_PIXELS
                                + " total reference pixel pixels, but there were "
                                + report.getTargetDefinitionAndPixelCounts()
                                    .getTotalPixelCount());
                }
                break;
            case BACKGROUND:
                // specificMaxTargetsPerChannel =
                // TargetManagementConstants.MAX_BG_TARGETS_PER_CHANNEL;
                break;
        }

        // Assume all chains are missing until we find one mod/out with targets
        // on it.
        for (Integer chain : FcConstants.signalProcessingChains) {
            report.getMissingSignalProcessingChains()
                .add(chain);
        }

        // * - Less than or equal to 16383 targets on any single module/output
        // * - Less than or equal to ??? background targets on any single
        // module/output (need to get this number from FS)
        // * - Less than or equal to ??? reference pixel targets on any single
        // module/output (need to get this number from FS)
        for (TadModOutReport modOutReport : report.getModOutReports()) {
            int totalTargetCount = modOutReport.getTargetDefinitionAndPixelCounts()
                .getTotalTargetDefCount();

            if (totalTargetCount > TargetManagementConstants.MAX_TARGET_DEFS_PER_CHANNEL) {
                valid = false;
                report.getErrors()
                    .add(
                        "Expected less than or equal to "
                            + TargetManagementConstants.MAX_TARGET_DEFS_PER_CHANNEL
                            + " targets on any single module/output, but there were "
                            + totalTargetCount);
            }

            // if (totalTargetCount > specificMaxTargetsPerChannel) {
            // valid = false;
            // report.getErrors()
            // .add(
            // String.format(
            // "Must be less than or equal to %,d %s targets on any single
            // module/output.",
            // specificMaxTargetsPerChannel, targetType.toString()));
            // }

            if (totalTargetCount > 0) {
                report.getMissingSignalProcessingChains()
                    .remove(
                        FcConstants.getSignalProcessingChain(modOutReport.getCcdModule()));
            }
        }

        // Set targetTable state.
        if (targetTable.getState() != State.UPLINKED) {
            targetTable.setState(State.TAD_COMPLETED);
        }

        // Set maskTable state.
        if (maskTable.getState() != State.UPLINKED) {
            maskTable.setState(State.TAD_COMPLETED);
        }

        TadRevisedParameters tadRevisedParameters = pipelineTask.getParameters(
            TadRevisedParameters.class, false);
        if (tadRevisedParameters != null) {
            setStateForRevisedTls(targetTable, maskTable, tadRevisedParameters);
        }
    }

    private void setStateForRevisedTls(TargetTable targetTable,
        MaskTable maskTable, TadRevisedParameters tadRevisedParameters) {
        // Set targetTable state.
        if (targetTable.getState() != State.UPLINKED) {
            if (tadRevisedParameters.isRevised()) {
                switch (targetTable.getType()) {
                    case BACKGROUND:
                        if (tadRevisedParameters.isRevisedBackgroundEnabled()) {
                            targetTable.setState(State.REVISED);
                            targetTable.setExternalId(tadRevisedParameters.getBgpExternalId());
                        }
                        break;
                    case LONG_CADENCE:
                        targetTable.setState(State.REVISED);
                        targetTable.setExternalId(tadRevisedParameters.getLctExternalId());
                        break;
                    case SHORT_CADENCE:
                        targetTable.setState(State.REVISED);
                        targetTable.setExternalId(tadRevisedParameters.getSctExternalId());
                        break;
                    case REFERENCE_PIXEL:
                        targetTable.setState(State.REVISED);
                        targetTable.setExternalId(tadRevisedParameters.getRptExternalId());
                        break;
                    default:
                        throw new IllegalArgumentException("Unexpected type: "
                            + targetTable.getType());
                }
            }
        }

        // Set maskTable state.
        if (maskTable.getState() != State.UPLINKED) {
            if (tadRevisedParameters.isRevised()) {
                switch (maskTable.getType()) {
                    case BACKGROUND:
                        if (tadRevisedParameters.isRevisedBackgroundEnabled()) {
                            maskTable.setState(State.REVISED);
                            maskTable.setExternalId(tadRevisedParameters.getBadExternalId());
                        }
                        break;
                    case TARGET:
                        maskTable.setState(State.REVISED);
                        maskTable.setExternalId(tadRevisedParameters.getTadExternalId());
                        break;
                    default:
                        throw new IllegalArgumentException("Unexpected type: "
                            + maskTable.getType());
                }
            }
        }
    }

    private boolean doesMaskContainAperture(ObservedTarget target) {
        Set<gov.nasa.kepler.mc.tad.Offset> absAperturePixels = newHashSet();
        for (Offset offset : target.getAperture()
            .getOffsets()) {
            absAperturePixels.add(new gov.nasa.kepler.mc.tad.Offset(
                offset.getRow() + target.getAperture()
                    .getReferenceRow(), offset.getColumn()
                    + target.getAperture()
                        .getReferenceColumn()));
        }

        Set<gov.nasa.kepler.mc.tad.Offset> absMaskPixels = newHashSet();
        for (TargetDefinition targetDefinition : target.getTargetDefinitions()) {
            for (Offset offset : targetDefinition.getMask()
                .getOffsets()) {
                absMaskPixels.add(new gov.nasa.kepler.mc.tad.Offset(
                    offset.getRow() + targetDefinition.getReferenceRow(),
                    offset.getColumn() + targetDefinition.getReferenceColumn()));
            }
        }

        for (gov.nasa.kepler.mc.tad.Offset absAperturePixel : absAperturePixels) {
            if (!absMaskPixels.contains(absAperturePixel)) {
                return false;
            }
        }

        return true;
    }

    private void countTargetsAndPixels(ObservedTarget target, TadReport report,
        TadModOutReport modOutReport, Set<Offset> absolutePixels) {
        TargetDefinitionAndPixelCounts summaryCounts = report.getTargetDefinitionAndPixelCounts();
        TargetDefinitionAndPixelCounts modOutCounts = modOutReport.getTargetDefinitionAndPixelCounts();

        boolean loggedNotOnCcdWarningForTargetDef = false;
        for (TargetDefinition targetDef : target.getTargetDefinitions()) {
            int refRow = targetDef.getReferenceRow();
            int refColumn = targetDef.getReferenceColumn();
            List<Offset> offsets = targetDef.getMask()
                .getOffsets();

            // Check regions.
            CcdRegion firstCcdRegion = null;
            int absRow = 0;
            int absColumn = 0;
            for (Offset offset : offsets) {
                absRow = refRow + offset.getRow();
                absColumn = refColumn + offset.getColumn();

                absolutePixels.add(new Offset(absRow, absColumn));

                if (firstCcdRegion == null) {
                    firstCcdRegion = CcdRegion.valueOf(absRow, absColumn);
                }

                CcdRegion ccdRegion = CcdRegion.valueOf(absRow, absColumn);

                if (ccdRegion == CcdRegion.NONE) {
                    if (!loggedNotOnCcdWarningForTargetDef) {
                        valid = false;
                        report.getErrors()
                            .add(
                                "Masks must be on the CCD" + " (keplerId="
                                    + targetDef.getKeplerId()
                                    + ", targetDefHibernateId = "
                                    + targetDef.getId() + ").");
                        loggedNotOnCcdWarningForTargetDef = true;
                    }
                }

                // Count pixels.
                switch (ccdRegion) {
                    case LEADING_BLACK:
                        summaryCounts.setLeadingBlackPixelCount(summaryCounts.getLeadingBlackPixelCount() + 1);
                        modOutCounts.setLeadingBlackPixelCount(modOutCounts.getLeadingBlackPixelCount() + 1);
                        break;
                    case TRAILING_BLACK:
                        summaryCounts.setTrailingBlackPixelCount(summaryCounts.getTrailingBlackPixelCount() + 1);
                        modOutCounts.setTrailingBlackPixelCount(modOutCounts.getTrailingBlackPixelCount() + 1);
                        break;
                    case MASKED_SMEAR:
                        summaryCounts.setMaskedSmearPixelCount(summaryCounts.getMaskedSmearPixelCount() + 1);
                        modOutCounts.setMaskedSmearPixelCount(modOutCounts.getMaskedSmearPixelCount() + 1);
                        break;
                    case VIRTUAL_SMEAR:
                        summaryCounts.setVirtualSmearPixelCount(summaryCounts.getVirtualSmearPixelCount() + 1);
                        modOutCounts.setVirtualSmearPixelCount(modOutCounts.getVirtualSmearPixelCount() + 1);
                        break;
                    default:
                        break;
                }

                if (target.containsLabel(TargetLabel.PDQ_DYNAMIC_RANGE)) {
                    summaryCounts.setDynamicRangePixelCount(summaryCounts.getDynamicRangePixelCount() + 1);
                    modOutCounts.setDynamicRangePixelCount(modOutCounts.getDynamicRangePixelCount() + 1);
                } else if (target.containsLabel(TargetLabel.PDQ_STELLAR)) {
                    summaryCounts.setStellarPixelCount(summaryCounts.getStellarPixelCount() + 1);
                    modOutCounts.setStellarPixelCount(modOutCounts.getStellarPixelCount() + 1);
                } else if (target.containsLabel(TargetLabel.PDQ_BACKGROUND)) {
                    summaryCounts.setBackgroundPixelCount(summaryCounts.getBackgroundPixelCount() + 1);
                    modOutCounts.setBackgroundPixelCount(modOutCounts.getBackgroundPixelCount() + 1);
                }
            }

            // Count targets.
            if (target.containsLabel(TargetLabel.PDQ_DYNAMIC_RANGE)) {
                summaryCounts.setDynamicRangeTargetDefCount(summaryCounts.getDynamicRangeTargetDefCount() + 1);
                modOutCounts.setDynamicRangeTargetDefCount(modOutCounts.getDynamicRangeTargetDefCount() + 1);
            } else if (target.containsLabel(TargetLabel.PDQ_STELLAR)) {
                summaryCounts.setStellarTargetDefCount(summaryCounts.getStellarTargetDefCount() + 1);
                modOutCounts.setStellarTargetDefCount(modOutCounts.getStellarTargetDefCount() + 1);
            } else if (target.containsLabel(TargetLabel.PDQ_BACKGROUND)) {
                summaryCounts.setBackgroundTargetDefCount(summaryCounts.getBackgroundTargetDefCount() + 1);
                modOutCounts.setBackgroundTargetDefCount(modOutCounts.getBackgroundTargetDefCount() + 1);
            } else if (target.containsLabel(TargetLabel.PDQ_BLACK_COLLATERAL)) {
                if (absColumn <= FcConstants.LEADING_BLACK_END) {
                    summaryCounts.setLeadingBlackTargetDefCount(summaryCounts.getLeadingBlackTargetDefCount() + 1);
                    modOutCounts.setLeadingBlackTargetDefCount(modOutCounts.getLeadingBlackTargetDefCount() + 1);
                } else if (absColumn >= FcConstants.TRAILING_BLACK_START) {
                    summaryCounts.setTrailingBlackTargetDefCount(summaryCounts.getTrailingBlackTargetDefCount() + 1);
                    modOutCounts.setTrailingBlackTargetDefCount(modOutCounts.getTrailingBlackTargetDefCount() + 1);
                }
            } else if (target.containsLabel(TargetLabel.PDQ_SMEAR_COLLATERAL)) {
                if (absRow <= FcConstants.MASKED_SMEAR_END) {
                    summaryCounts.setMaskedSmearTargetDefCount(summaryCounts.getMaskedSmearTargetDefCount() + 1);
                    modOutCounts.setMaskedSmearTargetDefCount(modOutCounts.getMaskedSmearTargetDefCount() + 1);
                } else if (absRow >= FcConstants.VIRTUAL_SMEAR_START) {
                    summaryCounts.setVirtualSmearTargetDefCount(summaryCounts.getVirtualSmearTargetDefCount() + 1);
                    modOutCounts.setVirtualSmearTargetDefCount(modOutCounts.getVirtualSmearTargetDefCount() + 1);
                }
            }

            // Count total targets and pixels.
            summaryCounts.setTotalTargetDefCount(summaryCounts.getTotalTargetDefCount() + 1);
            summaryCounts.setTotalPixelCount(summaryCounts.getTotalPixelCount()
                + offsets.size());
            summaryCounts.setExcessPixelCount(summaryCounts.getExcessPixelCount()
                + targetDef.getExcessPixels());

            modOutCounts.setTotalTargetDefCount(modOutCounts.getTotalTargetDefCount() + 1);
            modOutCounts.setTotalPixelCount(modOutCounts.getTotalPixelCount()
                + offsets.size());
            modOutCounts.setExcessPixelCount(modOutCounts.getExcessPixelCount()
                + targetDef.getExcessPixels());

            // Reset flags.
            loggedNotOnCcdWarningForTargetDef = false;
        }

        // Count labels for summary.
        countLabels(target, summaryCounts.getLabelCounts());

        // Count labels for mod/out.
        countLabels(target, modOutCounts.getLabelCounts());
    }

    private void countLabels(ObservedTarget target,
        Map<String, Integer> labelCounts) {
        for (String label : target.getLabels()) {
            Integer labelCount = labelCounts.get(label);

            if (labelCount == null) {
                labelCount = 0;
            }

            labelCounts.put(label, labelCount + 1);
        }
    }

}
