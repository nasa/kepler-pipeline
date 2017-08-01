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

package gov.nasa.kepler.systest.validation.cmtad;

import gov.nasa.kepler.common.UsageException;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.systest.validation.ValidationException;
import gov.nasa.kepler.systest.validation.ValidationUtils;
import gov.nasa.kepler.systest.validation.cmtad.CmTadExtractor.CustomPlannedTargetEntry;
import gov.nasa.kepler.systest.validation.cmtad.CmTadExtractor.MaskTableEntry;
import gov.nasa.kepler.systest.validation.cmtad.CmTadExtractor.ObservedTargetEntry;
import gov.nasa.kepler.systest.validation.cmtad.CmTadExtractor.PlannedTargetEntry;
import gov.nasa.kepler.systest.validation.cmtad.CmTadExtractor.TadModOutReportEntry;
import gov.nasa.kepler.systest.validation.cmtad.CmTadExtractor.TadReportAlertEntry;
import gov.nasa.kepler.systest.validation.cmtad.CmTadExtractor.TadReportEntry;
import gov.nasa.kepler.systest.validation.cmtad.CmTadExtractor.TargetDefinitionValidationEntry;
import gov.nasa.kepler.systest.validation.cmtad.CmTadExtractor.TargetTableEntry;
import gov.nasa.kepler.systest.validation.cmtad.DbValidationParameters.Command;

import java.io.File;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Validates CM/TAD tables in two databases.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class CmTadValidator {

    private static final Log log = LogFactory.getLog(CmTadValidator.class);

    private DbValidationParameters parameters;

    public CmTadValidator(DbValidationParameters parameters)
        throws URISyntaxException {

        if (parameters == null) {
            throw new NullPointerException("parameters can't be null");
        }

        this.parameters = parameters;
        validateParameters();
    }

    private void validateParameters() throws URISyntaxException {
        if (parameters.getCommand() != Command.VALIDATE_CM_TAD) {
            throw new IllegalStateException("Unexpected command "
                + parameters.getCommand()
                    .getName());
        }

        int urlCount = 0;
        if (parameters.getUrls() != null) {
            for (String url : parameters.getUrls()) {
                ValidationUtils.checkUri(url, "jdbc", "URL");
            }
            urlCount += parameters.getUrls().length;
        }
        if (urlCount < 2) {
            throw new UsageException("Not enough URLs provided; expected two");
        }
        if (urlCount > 2) {
            throw new UsageException("Too many URLs provided; expected two");
        }

        if (parameters.getMaxErrorsDisplayed() < 0) {
            throw new UsageException("Max errors displayed can't be negative");
        }
    }

    public void validate() throws ValidationException {

        List<CmTadExtractor> cmTadExtractors = new ArrayList<CmTadExtractor>();
        for (String uri : parameters.getUrls()) {
            cmTadExtractors.add(new CmTadExtractor(uri));
        }

        boolean failed = false;
        log.info("Validating included planned targets");
        if (diffPlannedTargets(parameters.getMaxErrorsDisplayed(), "Included",
            cmTadExtractors.get(0)
                .extractIncludedPlannedTargets(), cmTadExtractors.get(1)
                .extractIncludedPlannedTargets())) {
            failed = true;
        }
        log.info("Validating excluded planned targets");
        if (diffPlannedTargets(parameters.getMaxErrorsDisplayed(), "Excluded",
            cmTadExtractors.get(0)
                .extractExcludedPlannedTargets(), cmTadExtractors.get(1)
                .extractExcludedPlannedTargets())) {
            failed = true;
        }
        log.info("Validating custom planned targets");
        if (diffCustomPlannedTargets(parameters.getMaxErrorsDisplayed(),
            cmTadExtractors.get(0)
                .extractCustomPlannedTargets(), cmTadExtractors.get(1)
                .extractCustomPlannedTargets())) {
            failed = true;
        }
        log.info("Validating target table");
        if (diffTargetTable(parameters.getMaxErrorsDisplayed(),
            cmTadExtractors.get(0)
                .extractTargetTable(), cmTadExtractors.get(1)
                .extractTargetTable())) {
            failed = true;
        }
        log.info("Validating mask table");
        if (diffMaskTable(parameters.getMaxErrorsDisplayed(),
            cmTadExtractors.get(0)
                .extractMaskTable(), cmTadExtractors.get(1)
                .extractMaskTable())) {
            failed = true;
        }
        log.info("Validating observed targets");
        if (diffObservedTargets(parameters.getMaxErrorsDisplayed(),
            cmTadExtractors.get(0)
                .extractObservedTargets(), cmTadExtractors.get(1)
                .extractObservedTargets())) {
            failed = true;
        }
        log.info("Matching target definition and observed target Kepler IDs");
        if (diffTargetDefinitionValidationEntries(cmTadExtractors.get(0)
            .extractTargetDefinitionValidationEntries(), cmTadExtractors.get(1)
            .extractTargetDefinitionValidationEntries())) {
            failed = true;
        }
        log.info("Validating report");
        if (diffReport(parameters.getMaxErrorsDisplayed(), cmTadExtractors.get(
            0)
            .extractTadReport(), cmTadExtractors.get(1)
            .extractTadReport())) {
            failed = true;
        }
        log.info("Validating mod/out report");
        if (diffModOutReport(parameters.getMaxErrorsDisplayed(),
            cmTadExtractors.get(0)
                .extractTadModOutReport(), cmTadExtractors.get(1)
                .extractTadModOutReport())) {
            failed = true;
        }
        log.info("Validating alerts");
        if (diffAlerts(parameters.getMaxErrorsDisplayed(), cmTadExtractors.get(
            0)
            .extractTadReportAlerts(), cmTadExtractors.get(1)
            .extractTadReportAlerts())) {
            failed = true;
        }

        if (failed) {
            throw new ValidationException("Given databases differ; see log");
        }
    }

    private boolean diffPlannedTargets(int maxErrorsDisplayed, String type,
        List<PlannedTargetEntry> plannedTargetsA,
        List<PlannedTargetEntry> plannedTargetsB) {

        if (plannedTargetsA.size() != plannedTargetsB.size()) {
            log.error(String.format(
                "The first planned target list has %d entries "
                    + "and the second planned target list has %d entries",
                plannedTargetsA.size(), plannedTargetsB.size()));
        }

        StringBuffer output = new StringBuffer();
        output.append("\n")
            .append(type)
            .append(" planned targets differ")
            .append(
                "\nIndex\tcategory, name, source, sourceType, keplerId, "
                    + "skyGroupId, label\n");

        int errorCount = 0;
        int n = Math.min(plannedTargetsA.size(), plannedTargetsB.size());
        for (int i = 0; i < n; i++) {
            PlannedTargetEntry plannedTargetEntryA = plannedTargetsA.get(i);
            PlannedTargetEntry plannedTargetEntryB = plannedTargetsB.get(i);
            boolean localDifferent = false;
            if (plannedTargetEntryA == null || plannedTargetEntryB == null) {
                if (plannedTargetEntryA != null || plannedTargetEntryB != null) {
                    localDifferent = true;
                }
            } else if (!objectsEqual(plannedTargetEntryA.category,
                plannedTargetEntryB.category)
                || !objectsEqual(plannedTargetEntryA.name,
                    plannedTargetEntryB.name)
                || !objectsEqual(basename(plannedTargetEntryA.source),
                    basename(plannedTargetEntryB.source))
                || plannedTargetEntryA.sourceType != plannedTargetEntryB.sourceType
                || plannedTargetEntryA.keplerId != plannedTargetEntryB.keplerId
                || plannedTargetEntryA.skyGroupId != plannedTargetEntryB.skyGroupId
                || !objectsEqual(plannedTargetEntryA.label,
                    plannedTargetEntryB.label)) {

                localDifferent = true;
            }

            if (localDifferent) {
                if (errorCount++ >= maxErrorsDisplayed) {
                    continue;
                }
                output.append(i)
                    .append("\t");
                if (plannedTargetEntryA != null) {
                    output.append(plannedTargetEntryA.category)
                        .append(" ")
                        .append(plannedTargetEntryA.name)
                        .append(" ")
                        .append(basename(plannedTargetEntryA.source))
                        .append(" ")
                        .append(plannedTargetEntryA.sourceType)
                        .append(" ")
                        .append(plannedTargetEntryA.keplerId)
                        .append(" ")
                        .append(plannedTargetEntryA.skyGroupId)
                        .append(" ")
                        .append(plannedTargetEntryA.label);
                } else {
                    output.append("NULL");
                }
                output.append("\n\t");
                if (plannedTargetEntryB != null) {
                    output.append(plannedTargetEntryB.category)
                        .append(" ")
                        .append(plannedTargetEntryB.name)
                        .append(" ")
                        .append(basename(plannedTargetEntryB.source))
                        .append(" ")
                        .append(plannedTargetEntryB.sourceType)
                        .append(" ")
                        .append(plannedTargetEntryB.keplerId)
                        .append(" ")
                        .append(plannedTargetEntryB.skyGroupId)
                        .append(" ")
                        .append(plannedTargetEntryB.label);
                } else {
                    output.append("NULL");
                }
                output.append("\n");
            }
        }

        errorCount += Math.abs(plannedTargetsA.size() - plannedTargetsB.size());
        displaySummary(type + " planned targets", plannedTargetsA.size(),
            errorCount, output, maxErrorsDisplayed);

        return errorCount > 0;
    }

    private boolean diffCustomPlannedTargets(int maxErrorsDisplayed,
        List<CustomPlannedTargetEntry> customPlannedTargetsA,
        List<CustomPlannedTargetEntry> customPlannedTargetsB) {

        if (customPlannedTargetsA.size() != customPlannedTargetsB.size()) {
            log.error(String.format(
                "The first custom planned target list has %d entries "
                    + "and the second custom planned target list has %d entries",
                customPlannedTargetsA.size(), customPlannedTargetsB.size()));
        }

        StringBuffer output = new StringBuffer();
        output.append("\nCustom planned targets differ");
        output.append("\nIndex\tcategory, name, source, sourceType, keplerId, "
            + "skyGroupId, referenceColumn, referenceRow, userDefined, "
            + "columnOffset, rowOffset, label\n");

        int errorCount = 0;
        int n = Math.min(customPlannedTargetsA.size(),
            customPlannedTargetsB.size());
        for (int i = 0; i < n; i++) {
            CustomPlannedTargetEntry customPlannedTargetEntryA = customPlannedTargetsA.get(i);
            CustomPlannedTargetEntry customPlannedTargetEntryB = customPlannedTargetsB.get(i);
            boolean localDifferent = false;
            if (customPlannedTargetEntryA == null
                || customPlannedTargetEntryB == null) {
                if (customPlannedTargetEntryA != null
                    || customPlannedTargetEntryB != null) {
                    localDifferent = true;
                }
            } else if (!objectsEqual(customPlannedTargetEntryA.category,
                customPlannedTargetEntryB.category)
                || !objectsEqual(customPlannedTargetEntryA.name,
                    customPlannedTargetEntryB.name)
                || !objectsEqual(basename(customPlannedTargetEntryA.source),
                    basename(customPlannedTargetEntryB.source))
                || customPlannedTargetEntryA.sourceType != customPlannedTargetEntryB.sourceType
                || customPlannedTargetEntryA.keplerId != customPlannedTargetEntryB.keplerId
                || customPlannedTargetEntryA.skyGroupId != customPlannedTargetEntryB.skyGroupId
                || customPlannedTargetEntryA.referenceColumn != customPlannedTargetEntryB.referenceColumn
                || customPlannedTargetEntryA.referenceRow != customPlannedTargetEntryB.referenceRow
                || customPlannedTargetEntryA.userDefined != customPlannedTargetEntryB.userDefined
                || customPlannedTargetEntryA.columnOffset != customPlannedTargetEntryB.columnOffset
                || customPlannedTargetEntryA.rowOffset != customPlannedTargetEntryB.rowOffset
                || !objectsEqual(customPlannedTargetEntryA.label,
                    customPlannedTargetEntryB.label)) {

                localDifferent = true;
            }

            if (localDifferent) {
                if (errorCount++ >= maxErrorsDisplayed) {
                    continue;
                }
                output.append(i)
                    .append("\t");
                if (customPlannedTargetEntryA != null) {
                    output.append(customPlannedTargetEntryA.category)
                        .append(" ")
                        .append(customPlannedTargetEntryA.name)
                        .append(" ")
                        .append(basename(customPlannedTargetEntryA.source))
                        .append(" ")
                        .append(customPlannedTargetEntryA.sourceType)
                        .append(" ")
                        .append(customPlannedTargetEntryA.keplerId)
                        .append(" ")
                        .append(customPlannedTargetEntryA.skyGroupId)
                        .append(" ")
                        .append(customPlannedTargetEntryA.referenceColumn)
                        .append(" ")
                        .append(customPlannedTargetEntryA.referenceRow)
                        .append(" ")
                        .append(customPlannedTargetEntryA.userDefined)
                        .append(" ")
                        .append(customPlannedTargetEntryA.columnOffset)
                        .append(" ")
                        .append(customPlannedTargetEntryA.rowOffset)
                        .append(" ")
                        .append(customPlannedTargetEntryA.label);
                } else {
                    output.append("NULL");
                }
                output.append("\n\t");
                if (customPlannedTargetEntryB != null) {
                    output.append(customPlannedTargetEntryB.category)
                        .append(" ")
                        .append(customPlannedTargetEntryB.name)
                        .append(" ")
                        .append(basename(customPlannedTargetEntryB.source))
                        .append(" ")
                        .append(customPlannedTargetEntryB.sourceType)
                        .append(" ")
                        .append(customPlannedTargetEntryB.keplerId)
                        .append(" ")
                        .append(customPlannedTargetEntryB.skyGroupId)
                        .append(" ")
                        .append(customPlannedTargetEntryB.referenceColumn)
                        .append(" ")
                        .append(customPlannedTargetEntryB.referenceRow)
                        .append(" ")
                        .append(customPlannedTargetEntryB.userDefined)
                        .append(" ")
                        .append(customPlannedTargetEntryB.columnOffset)
                        .append(" ")
                        .append(customPlannedTargetEntryB.rowOffset)
                        .append(" ")
                        .append(customPlannedTargetEntryB.label);
                } else {
                    output.append("NULL");
                }
                output.append("\n");
            }
        }

        errorCount += Math.abs(customPlannedTargetsA.size()
            - customPlannedTargetsB.size());
        displaySummary("Custom planned targets", customPlannedTargetsA.size(),
            errorCount, output, maxErrorsDisplayed);

        return errorCount > 0;
    }

    private boolean diffTargetTable(int maxErrorsDisplayed,
        List<TargetTableEntry> targetTableA, List<TargetTableEntry> targetTableB) {

        if (targetTableA.size() != targetTableB.size()) {
            log.error(String.format("The first target table has %d rows "
                + "and the second target table has %d rows",
                targetTableA.size(), targetTableB.size()));
        }

        StringBuffer output = new StringBuffer();
        output.append("\nTarget tables differ");
        output.append("\nIndex\t"
            + "plannedStartTime, plannedEndTime, observingSeason, type, "
            + "ccdModule, ccdOutput, excessPixels, ");
        if (!parameters.isIgnoreIndexInModuleOutput()) {
            output.append("indexInModuleOutput, ");
        }
        output.append("keplerId, referenceRow, referenceColumn, status, indexInTable\n");

        int errorCount = 0;
        int n = Math.min(targetTableA.size(), targetTableB.size());
        for (int i = 0; i < n; i++) {
            TargetTableEntry targetTableEntryA = targetTableA.get(i);
            TargetTableEntry targetTableEntryB = targetTableB.get(i);
            boolean localDifferent = false;
            if (targetTableEntryA == null || targetTableEntryB == null) {
                if (targetTableEntryA != null || targetTableEntryB != null) {
                    localDifferent = true;
                }
            } else if (!parameters.isIgnoreBackgroundTargetTableType()
                || targetTableEntryA.type != TargetType.BACKGROUND.ordinal()) {
                if (targetTableEntryA.ccdModule != targetTableEntryB.ccdModule
                    || targetTableEntryA.ccdOutput != targetTableEntryB.ccdOutput
                    || targetTableEntryA.excessPixels != targetTableEntryB.excessPixels
                    || !parameters.isIgnoreIndexInModuleOutput()
                    && targetTableEntryA.indexInModuleOutput != targetTableEntryB.indexInModuleOutput
                    || targetTableEntryA.indexInTable != targetTableEntryB.indexInTable
                    || targetTableEntryA.keplerId != targetTableEntryB.keplerId
                    || targetTableEntryA.observingSeason != targetTableEntryB.observingSeason
                    || !objectsEqual(targetTableEntryA.plannedEndTime,
                        targetTableEntryB.plannedEndTime)
                    || !objectsEqual(targetTableEntryA.plannedStartTime,
                        targetTableEntryB.plannedStartTime)
                    || targetTableEntryA.referenceColumn != targetTableEntryB.referenceColumn
                    || targetTableEntryA.referenceRow != targetTableEntryB.referenceRow
                    || targetTableEntryA.status != targetTableEntryB.status
                    || targetTableEntryA.type != targetTableEntryB.type) {
                    localDifferent = true;
                }
            }

            if (localDifferent) {
                if (errorCount++ >= maxErrorsDisplayed) {
                    continue;
                }
                output.append(i)
                    .append("\t");
                if (targetTableEntryA != null) {
                    output.append(targetTableEntryA.plannedStartTime)
                        .append(" ")
                        .append(targetTableEntryA.plannedEndTime)
                        .append(" ")
                        .append(targetTableEntryA.observingSeason)
                        .append(" ")
                        .append(targetTableEntryA.type)
                        .append(" ")
                        .append(targetTableEntryA.ccdModule)
                        .append(" ")
                        .append(targetTableEntryA.ccdOutput)
                        .append(" ")
                        .append(targetTableEntryA.excessPixels)
                        .append(" ");
                    if (!parameters.isIgnoreIndexInModuleOutput()) {
                        output.append(targetTableEntryA.indexInModuleOutput)
                            .append(" ");
                    }
                    output.append(targetTableEntryA.keplerId)
                        .append(" ")
                        .append(targetTableEntryA.referenceRow)
                        .append(" ")
                        .append(targetTableEntryA.referenceColumn)
                        .append(" ")
                        .append(targetTableEntryA.status)
                        .append(" ")
                        .append(targetTableEntryA.indexInTable);
                } else {
                    output.append("NULL");
                }
                output.append("\n\t");
                if (targetTableEntryB != null) {
                    output.append(targetTableEntryB.plannedStartTime)
                        .append(" ")
                        .append(targetTableEntryB.plannedEndTime)
                        .append(" ")
                        .append(targetTableEntryB.observingSeason)
                        .append(" ")
                        .append(targetTableEntryB.type)
                        .append(" ")
                        .append(targetTableEntryB.ccdModule)
                        .append(" ")
                        .append(targetTableEntryB.ccdOutput)
                        .append(" ")
                        .append(targetTableEntryB.excessPixels)
                        .append(" ");
                    if (!parameters.isIgnoreIndexInModuleOutput()) {
                        output.append(targetTableEntryB.indexInModuleOutput)
                            .append(" ");
                    }
                    output.append(targetTableEntryB.keplerId)
                        .append(" ")
                        .append(targetTableEntryB.referenceRow)
                        .append(" ")
                        .append(targetTableEntryB.referenceColumn)
                        .append(" ")
                        .append(targetTableEntryB.status)
                        .append(" ")
                        .append(targetTableEntryB.indexInTable);
                } else {
                    output.append("NULL");
                }
                output.append("\n");
            }
        }

        errorCount += Math.abs(targetTableA.size() - targetTableB.size());
        displaySummary("Target table", targetTableA.size(), errorCount, output,
            maxErrorsDisplayed);

        return errorCount > 0;
    }

    private boolean diffMaskTable(int maxErrorsDisplayed,
        List<MaskTableEntry> maskTableA, List<MaskTableEntry> maskTableB) {

        if (maskTableA.size() != maskTableB.size()) {
            log.error(String.format("The first mask table has %d rows "
                + "and the second mask table has %d rows", maskTableA.size(),
                maskTableB.size()));
        }

        StringBuffer output = new StringBuffer();
        output.append("\nMask tables differ");
        output.append("\nIndex\t"
            + "plannedStartTime, plannedEndTime, type, indexInTable, "
            + "supermask, used, columnOffset, rowOffset\n");
        int errorCount = 0;
        int n = Math.min(maskTableA.size(), maskTableB.size());
        for (int i = 0; i < n; i++) {
            MaskTableEntry maskTableEntryA = maskTableA.get(i);
            MaskTableEntry maskTableEntryB = maskTableB.get(i);
            boolean localDifferent = false;
            if (maskTableEntryA == null || maskTableEntryB == null) {
                if (maskTableEntryA != null || maskTableEntryB != null) {
                    localDifferent = true;
                }
            } else if (maskTableEntryA.columnOffset != maskTableEntryB.columnOffset
                || maskTableEntryA.indexInTable != maskTableEntryB.indexInTable
                || !objectsEqual(maskTableEntryA.plannedEndTime,
                    maskTableEntryB.plannedEndTime)
                || !objectsEqual(maskTableEntryA.plannedStartTime,
                    maskTableEntryB.plannedStartTime)
                || maskTableEntryA.rowOffset != maskTableEntryB.rowOffset
                || maskTableEntryA.supermask != maskTableEntryB.supermask
                || maskTableEntryA.type != maskTableEntryB.type
                || maskTableEntryA.used != maskTableEntryB.used) {
                localDifferent = true;
            }

            if (localDifferent) {
                if (errorCount++ >= maxErrorsDisplayed) {
                    continue;
                }
                output.append(i)
                    .append("\t");
                if (maskTableEntryA != null) {
                    output.append(maskTableEntryA.plannedStartTime)
                        .append(" ")
                        .append(maskTableEntryA.plannedEndTime)
                        .append(" ")
                        .append(maskTableEntryA.type)
                        .append(" ")
                        .append(maskTableEntryA.indexInTable)
                        .append(" ")
                        .append(maskTableEntryA.supermask)
                        .append(" ")
                        .append(maskTableEntryA.used)
                        .append(" ")
                        .append(maskTableEntryA.columnOffset)
                        .append(" ")
                        .append(maskTableEntryA.rowOffset);
                } else {
                    output.append("NULL");
                }
                output.append("\n\t");
                if (maskTableEntryB != null) {
                    output.append(maskTableEntryB.plannedStartTime)
                        .append(" ")
                        .append(maskTableEntryB.plannedEndTime)
                        .append(" ")
                        .append(maskTableEntryB.type)
                        .append(" ")
                        .append(maskTableEntryB.indexInTable)
                        .append(" ")
                        .append(maskTableEntryB.supermask)
                        .append(" ")
                        .append(maskTableEntryB.used)
                        .append(" ")
                        .append(maskTableEntryB.columnOffset)
                        .append(" ")
                        .append(maskTableEntryB.rowOffset);
                } else {
                    output.append("NULL");
                }
                output.append("\n");
            }
        }

        errorCount += Math.abs(maskTableA.size() - maskTableB.size());
        displaySummary("Mask table", maskTableA.size(), errorCount, output,
            maxErrorsDisplayed);

        return errorCount > 0;
    }

    private boolean diffObservedTargets(int maxErrorsDisplayed,
        List<ObservedTargetEntry> observedTargetsA,
        List<ObservedTargetEntry> observedTargetsB) {

        if (observedTargetsA.size() != observedTargetsB.size()) {
            log.error(String.format(
                "The first observed target list has %d entries "
                    + "and the second observed target list has %d entries",
                observedTargetsA.size(), observedTargetsB.size()));
        }

        StringBuffer output = new StringBuffer();
        output.append("\nObserved targets differ");
        output.append("\nIndex\t"
            + "aperturePixelCount, badPixelCount, ccdModule, ccdOutput, "
            + "crowdingMetric, distanceFromEdge, fluxFractionInAperture, "
            + "keplerId, magnitude, rejected, signalToNoiseRatio, "
            + "skyCrowdingMetric, targetDefsPixelCount, saturatedRowCount, referenceColumn, "
            + "referenceRow, userDefined, columnOffset, rowOffset, label\n");

        int errorCount = 0;
        int n = Math.min(observedTargetsA.size(), observedTargetsB.size());
        for (int i = 0; i < n; i++) {
            ObservedTargetEntry observedTargetEntryA = observedTargetsA.get(i);
            ObservedTargetEntry observedTargetEntryB = observedTargetsB.get(i);
            boolean localDifferent = false;
            if (observedTargetEntryA == null || observedTargetEntryB == null) {
                if (observedTargetEntryA != null
                    || observedTargetEntryB != null) {
                    localDifferent = true;
                }
            } else if (observedTargetEntryA.aperturePixelCount != observedTargetEntryB.aperturePixelCount
                || observedTargetEntryA.badPixelCount != observedTargetEntryB.badPixelCount
                || observedTargetEntryA.ccdModule != observedTargetEntryB.ccdModule
                || observedTargetEntryA.ccdOutput != observedTargetEntryB.ccdOutput
                || observedTargetEntryA.columnOffset != observedTargetEntryB.columnOffset
                || observedTargetEntryA.crowdingMetric != observedTargetEntryB.crowdingMetric
                || observedTargetEntryA.distanceFromEdge != observedTargetEntryB.distanceFromEdge
                || observedTargetEntryA.fluxFractionInAperture != observedTargetEntryB.fluxFractionInAperture
                || observedTargetEntryA.keplerId != observedTargetEntryB.keplerId
                || !objectsEqual(observedTargetEntryA.label,
                    observedTargetEntryB.label)
                || observedTargetEntryA.magnitude != observedTargetEntryB.magnitude
                || observedTargetEntryA.referenceColumn != observedTargetEntryB.referenceColumn
                || observedTargetEntryA.referenceRow != observedTargetEntryB.referenceRow
                || observedTargetEntryA.rejected != observedTargetEntryB.rejected
                || observedTargetEntryA.rowOffset != observedTargetEntryB.rowOffset
                || observedTargetEntryA.signalToNoiseRatio != observedTargetEntryB.signalToNoiseRatio
                || observedTargetEntryA.skyCrowdingMetric != observedTargetEntryB.skyCrowdingMetric
                || observedTargetEntryA.targetDefsPixelCount != observedTargetEntryB.targetDefsPixelCount
                || observedTargetEntryA.saturatedRowCount != observedTargetEntryB.saturatedRowCount
                || observedTargetEntryA.userDefined != observedTargetEntryB.userDefined) {
                localDifferent = true;
            }

            if (localDifferent) {
                if (errorCount++ >= maxErrorsDisplayed) {
                    continue;
                }
                output.append(i)
                    .append("\t");
                if (observedTargetEntryA != null) {
                    output.append(observedTargetEntryA.aperturePixelCount)
                        .append(" ")
                        .append(observedTargetEntryA.badPixelCount)
                        .append(" ")
                        .append(observedTargetEntryA.ccdModule)
                        .append(" ")
                        .append(observedTargetEntryA.ccdOutput)
                        .append(" ")
                        .append(observedTargetEntryA.crowdingMetric)
                        .append(" ")
                        .append(observedTargetEntryA.distanceFromEdge)
                        .append(" ")
                        .append(observedTargetEntryA.fluxFractionInAperture)
                        .append(" ")
                        .append(observedTargetEntryA.keplerId)
                        .append(" ")
                        .append(observedTargetEntryA.magnitude)
                        .append(" ")
                        .append(observedTargetEntryA.rejected)
                        .append(" ")
                        .append(observedTargetEntryA.signalToNoiseRatio)
                        .append(" ")
                        .append(observedTargetEntryA.skyCrowdingMetric)
                        .append(" ")
                        .append(observedTargetEntryA.targetDefsPixelCount)
                        .append(" ")
                        .append(observedTargetEntryA.saturatedRowCount)
                        .append(" ")
                        .append(observedTargetEntryA.referenceColumn)
                        .append(" ")
                        .append(observedTargetEntryA.referenceRow)
                        .append(" ")
                        .append(observedTargetEntryA.userDefined)
                        .append(" ")
                        .append(observedTargetEntryA.columnOffset)
                        .append(" ")
                        .append(observedTargetEntryA.rowOffset)
                        .append(" ")
                        .append(observedTargetEntryA.label);
                } else {
                    output.append("NULL");
                }
                output.append("\n\t");
                if (observedTargetEntryB != null) {
                    output.append(observedTargetEntryB.aperturePixelCount)
                        .append(" ")
                        .append(observedTargetEntryB.badPixelCount)
                        .append(" ")
                        .append(observedTargetEntryB.ccdModule)
                        .append(" ")
                        .append(observedTargetEntryB.ccdOutput)
                        .append(" ")
                        .append(observedTargetEntryB.crowdingMetric)
                        .append(" ")
                        .append(observedTargetEntryB.distanceFromEdge)
                        .append(" ")
                        .append(observedTargetEntryB.fluxFractionInAperture)
                        .append(" ")
                        .append(observedTargetEntryB.keplerId)
                        .append(" ")
                        .append(observedTargetEntryB.magnitude)
                        .append(" ")
                        .append(observedTargetEntryB.rejected)
                        .append(" ")
                        .append(observedTargetEntryB.signalToNoiseRatio)
                        .append(" ")
                        .append(observedTargetEntryB.skyCrowdingMetric)
                        .append(" ")
                        .append(observedTargetEntryB.targetDefsPixelCount)
                        .append(" ")
                        .append(observedTargetEntryB.saturatedRowCount)
                        .append(" ")
                        .append(observedTargetEntryB.referenceColumn)
                        .append(" ")
                        .append(observedTargetEntryB.referenceRow)
                        .append(" ")
                        .append(observedTargetEntryB.userDefined)
                        .append(" ")
                        .append(observedTargetEntryB.columnOffset)
                        .append(" ")
                        .append(observedTargetEntryB.rowOffset)
                        .append(" ")
                        .append(observedTargetEntryB.label);
                } else {
                    output.append("NULL");
                }
                output.append("\n");
            }
        }

        errorCount += Math.abs(observedTargetsA.size()
            - observedTargetsB.size());
        displaySummary("Observed targets", observedTargetsA.size(), errorCount,
            output, maxErrorsDisplayed);

        return errorCount > 0;
    }

    private boolean diffTargetDefinitionValidationEntries(
        List<TargetDefinitionValidationEntry> targetDefinitionValidationEntriesA,
        List<TargetDefinitionValidationEntry> targetDefinitionValidationEntriesB) {

        if (targetDefinitionValidationEntriesA.size() != 2) {
            log.error(String.format(
                "The first target definition validation list has %d entries; "
                    + "2 were expected",
                targetDefinitionValidationEntriesA.size()));
        }
        if (targetDefinitionValidationEntriesB.size() != 2) {
            log.error(String.format(
                "The second target definition validation list has %d entries; "
                    + "2 were expected",
                targetDefinitionValidationEntriesB.size()));
        }

        StringBuffer output = new StringBuffer();
        output.append("\nTarget definition validation failed");
        output.append("\nIndex\tmismatch count\n");

        int errorCount = 0;
        int n = Math.min(targetDefinitionValidationEntriesA.size(),
            targetDefinitionValidationEntriesB.size());
        for (int i = 0; i < n; i++) {
            TargetDefinitionValidationEntry targetDefinitionValidationEntryA = targetDefinitionValidationEntriesA.get(i);
            TargetDefinitionValidationEntry targetDefinitionValidationEntryB = targetDefinitionValidationEntriesB.get(i);
            if (targetDefinitionValidationEntryA == null
                || targetDefinitionValidationEntryA.observedTargetKeplerIdMismatchCount != 0) {
                errorCount++;
            }
            if (targetDefinitionValidationEntryB == null
                || targetDefinitionValidationEntryB.observedTargetKeplerIdMismatchCount != 0) {
                errorCount++;
            }

            output.append(i)
                .append("\t")
                .append(
                    targetDefinitionValidationEntryA != null ? targetDefinitionValidationEntryA.observedTargetKeplerIdMismatchCount
                        : "NULL")
                .append("\t")
                .append(
                    targetDefinitionValidationEntryB != null ? targetDefinitionValidationEntryB.observedTargetKeplerIdMismatchCount
                        : "NULL")
                .append("\n");
        }

        errorCount += Math.abs(targetDefinitionValidationEntriesA.size()
            - targetDefinitionValidationEntriesB.size());
        displaySummary(
            "Matching target definition and observed target Kepler IDs",
            targetDefinitionValidationEntriesA.size(), errorCount, output,
            Integer.MAX_VALUE);

        return errorCount > 0;
    }

    private boolean diffReport(int maxErrorsDisplayed,
        List<TadReportEntry> tadReportA, List<TadReportEntry> tadReportB) {

        if (tadReportA.size() != tadReportB.size()) {
            log.error(String.format("The first report has %d rows "
                + "and the second report has %d rows", tadReportA.size(),
                tadReportB.size()));
        }

        StringBuffer output = new StringBuffer();
        output.append("\nReports differ");
        output.append("\nIndex\t"
            + "averagePixelsPerTargetDef, cstmTrgsNoAptCnt, "
            + "mergedTargetCount, reportRejectedByCoaTargetCount, "
            + "supermaskCount, msksSmlrThnAprtrCnt, totalMaskCount, "
            + "usedMaskCount, exclusiveLowerBound, "
            + "inclusiveUpperBound, targetCount, sigProcChainsCount, "
            + "backgroundPixelCount, backgroundTargetDefCnt, "
            + "dynamicRangePixelCount, dynamicRangeTargetDefCnt, "
            + "excessPixelCount, leadingBlackPixelCount, "
            + "leadingBlackTargetDefCnt, maskedSmearPixelCount, "
            + "maskedSmearTargetDefCnt, stellarPixelCount, "
            + "stellarTargetDefCnt, totalPixelCount, totalTargetDefCnt, "
            + "trailingBlackPixelCount, trailingBlackTargetDefCnt, "
            + "uniquePixelCount, virtualSmearPixelCount, "
            + "virtualSmearTargetDefCnt, labelCount, mapkey\n");

        int errorCount = 0;
        int n = Math.min(tadReportA.size(), tadReportB.size());
        for (int i = 0; i < n; i++) {
            TadReportEntry tadReportEntryA = tadReportA.get(i);
            TadReportEntry tadReportEntryB = tadReportB.get(i);
            boolean localDifferent = false;
            if (tadReportEntryA == null || tadReportEntryB == null) {
                if (tadReportEntryA != null || tadReportEntryB != null) {
                    localDifferent = true;
                }
            } else if (tadReportEntryA.averagePixelsPerTargetDef != tadReportEntryB.averagePixelsPerTargetDef
                || tadReportEntryA.backgroundPixelCount != tadReportEntryB.backgroundPixelCount
                || tadReportEntryA.backgroundTargetDefCnt != tadReportEntryB.backgroundTargetDefCnt
                || tadReportEntryA.cstmTrgsNoAptCnt != tadReportEntryB.cstmTrgsNoAptCnt
                || tadReportEntryA.dynamicRangePixelCount != tadReportEntryB.dynamicRangePixelCount
                || tadReportEntryA.dynamicRangeTargetDefCnt != tadReportEntryB.dynamicRangeTargetDefCnt
                || tadReportEntryA.excessPixelCount != tadReportEntryB.excessPixelCount
                || tadReportEntryA.exclusiveLowerBound != tadReportEntryB.exclusiveLowerBound
                || tadReportEntryA.inclusiveUpperBound != tadReportEntryB.inclusiveUpperBound
                || tadReportEntryA.labelCount != tadReportEntryB.labelCount
                || tadReportEntryA.leadingBlackPixelCount != tadReportEntryB.leadingBlackPixelCount
                || tadReportEntryA.leadingBlackTargetDefCnt != tadReportEntryB.leadingBlackTargetDefCnt
                || !objectsEqual(tadReportEntryA.mapkey, tadReportEntryB.mapkey)
                || tadReportEntryA.maskedSmearPixelCount != tadReportEntryB.maskedSmearPixelCount
                || tadReportEntryA.maskedSmearTargetDefCnt != tadReportEntryB.maskedSmearTargetDefCnt
                || tadReportEntryA.mergedTargetCount != tadReportEntryB.mergedTargetCount
                || tadReportEntryA.msksSmlrThnAprtrCnt != tadReportEntryB.msksSmlrThnAprtrCnt
                || tadReportEntryA.reportRejectedByCoaTargetCount != tadReportEntryB.reportRejectedByCoaTargetCount
                || tadReportEntryA.sigProcChainsCount != tadReportEntryB.sigProcChainsCount
                || tadReportEntryA.stellarPixelCount != tadReportEntryB.stellarPixelCount
                || tadReportEntryA.stellarTargetDefCnt != tadReportEntryB.stellarTargetDefCnt
                || tadReportEntryA.supermaskCount != tadReportEntryB.supermaskCount
                || tadReportEntryA.targetCount != tadReportEntryB.targetCount
                || tadReportEntryA.trailingBlackPixelCount != tadReportEntryB.trailingBlackPixelCount
                || tadReportEntryA.trailingBlackTargetDefCnt != tadReportEntryB.trailingBlackTargetDefCnt
                || tadReportEntryA.totalMaskCount != tadReportEntryB.totalMaskCount
                || tadReportEntryA.totalPixelCount != tadReportEntryB.totalPixelCount
                || tadReportEntryA.totalTargetDefCnt != tadReportEntryB.totalTargetDefCnt
                || tadReportEntryA.uniquePixelCount != tadReportEntryB.uniquePixelCount
                || tadReportEntryA.usedMaskCount != tadReportEntryB.usedMaskCount
                || tadReportEntryA.virtualSmearPixelCount != tadReportEntryB.virtualSmearPixelCount
                || tadReportEntryA.virtualSmearTargetDefCnt != tadReportEntryB.virtualSmearTargetDefCnt) {
                localDifferent = true;
            }

            if (localDifferent) {
                if (errorCount++ >= maxErrorsDisplayed) {
                    continue;
                }
                output.append(i)
                    .append("\t");
                if (tadReportEntryA != null) {
                    output.append(tadReportEntryA.averagePixelsPerTargetDef)
                        .append(" ")
                        .append(tadReportEntryA.cstmTrgsNoAptCnt)
                        .append(" ")
                        .append(tadReportEntryA.mergedTargetCount)
                        .append(" ")
                        .append(tadReportEntryA.reportRejectedByCoaTargetCount)
                        .append(" ")
                        .append(tadReportEntryA.supermaskCount)
                        .append(" ")
                        .append(tadReportEntryA.msksSmlrThnAprtrCnt)
                        .append(" ")
                        .append(tadReportEntryA.totalMaskCount)
                        .append(" ")
                        .append(tadReportEntryA.usedMaskCount)
                        .append(" ")
                        .append(tadReportEntryA.exclusiveLowerBound)
                        .append(" ")
                        .append(tadReportEntryA.inclusiveUpperBound)
                        .append(" ")
                        .append(tadReportEntryA.targetCount)
                        .append(" ")
                        .append(tadReportEntryA.sigProcChainsCount)
                        .append(" ")
                        .append(tadReportEntryA.backgroundPixelCount)
                        .append(" ")
                        .append(tadReportEntryA.backgroundTargetDefCnt)
                        .append(" ")
                        .append(tadReportEntryA.dynamicRangePixelCount)
                        .append(" ")
                        .append(tadReportEntryA.dynamicRangeTargetDefCnt)
                        .append(" ")
                        .append(tadReportEntryA.excessPixelCount)
                        .append(" ")
                        .append(tadReportEntryA.leadingBlackPixelCount)
                        .append(" ")
                        .append(tadReportEntryA.leadingBlackTargetDefCnt)
                        .append(" ")
                        .append(tadReportEntryA.maskedSmearPixelCount)
                        .append(" ")
                        .append(tadReportEntryA.maskedSmearTargetDefCnt)
                        .append(" ")
                        .append(tadReportEntryA.stellarPixelCount)
                        .append(" ")
                        .append(tadReportEntryA.stellarTargetDefCnt)
                        .append(" ")
                        .append(tadReportEntryA.totalPixelCount)
                        .append(" ")
                        .append(tadReportEntryA.totalTargetDefCnt)
                        .append(" ")
                        .append(tadReportEntryA.trailingBlackPixelCount)
                        .append(" ")
                        .append(tadReportEntryA.trailingBlackTargetDefCnt)
                        .append(" ")
                        .append(tadReportEntryA.uniquePixelCount)
                        .append(" ")
                        .append(tadReportEntryA.virtualSmearPixelCount)
                        .append(" ")
                        .append(tadReportEntryA.virtualSmearTargetDefCnt)
                        .append(" ")
                        .append(tadReportEntryA.labelCount)
                        .append(" ")
                        .append(tadReportEntryA.mapkey);
                } else {
                    output.append("NULL");
                }
                output.append("\n\t");
                if (tadReportEntryB != null) {
                    output.append(tadReportEntryB.averagePixelsPerTargetDef)
                        .append(" ")
                        .append(tadReportEntryB.cstmTrgsNoAptCnt)
                        .append(" ")
                        .append(tadReportEntryB.mergedTargetCount)
                        .append(" ")
                        .append(tadReportEntryB.reportRejectedByCoaTargetCount)
                        .append(" ")
                        .append(tadReportEntryB.supermaskCount)
                        .append(" ")
                        .append(tadReportEntryB.msksSmlrThnAprtrCnt)
                        .append(" ")
                        .append(tadReportEntryB.totalMaskCount)
                        .append(" ")
                        .append(tadReportEntryB.usedMaskCount)
                        .append(" ")
                        .append(tadReportEntryB.exclusiveLowerBound)
                        .append(" ")
                        .append(tadReportEntryB.inclusiveUpperBound)
                        .append(" ")
                        .append(tadReportEntryB.targetCount)
                        .append(" ")
                        .append(tadReportEntryB.sigProcChainsCount)
                        .append(" ")
                        .append(tadReportEntryB.backgroundPixelCount)
                        .append(" ")
                        .append(tadReportEntryB.backgroundTargetDefCnt)
                        .append(" ")
                        .append(tadReportEntryB.dynamicRangePixelCount)
                        .append(" ")
                        .append(tadReportEntryB.dynamicRangeTargetDefCnt)
                        .append(" ")
                        .append(tadReportEntryB.excessPixelCount)
                        .append(" ")
                        .append(tadReportEntryB.leadingBlackPixelCount)
                        .append(" ")
                        .append(tadReportEntryB.leadingBlackTargetDefCnt)
                        .append(" ")
                        .append(tadReportEntryB.maskedSmearPixelCount)
                        .append(" ")
                        .append(tadReportEntryB.maskedSmearTargetDefCnt)
                        .append(" ")
                        .append(tadReportEntryB.stellarPixelCount)
                        .append(" ")
                        .append(tadReportEntryB.stellarTargetDefCnt)
                        .append(" ")
                        .append(tadReportEntryB.totalPixelCount)
                        .append(" ")
                        .append(tadReportEntryB.totalTargetDefCnt)
                        .append(" ")
                        .append(tadReportEntryB.trailingBlackPixelCount)
                        .append(" ")
                        .append(tadReportEntryB.trailingBlackTargetDefCnt)
                        .append(" ")
                        .append(tadReportEntryB.uniquePixelCount)
                        .append(" ")
                        .append(tadReportEntryB.virtualSmearPixelCount)
                        .append(" ")
                        .append(tadReportEntryB.virtualSmearTargetDefCnt)
                        .append(" ")
                        .append(tadReportEntryB.labelCount)
                        .append(" ")
                        .append(tadReportEntryB.mapkey);
                } else {
                    output.append("NULL");
                }
                output.append("\n");
            }
        }

        errorCount += Math.abs(tadReportA.size() - tadReportB.size());
        displaySummary("Report", tadReportA.size(), errorCount, output,
            maxErrorsDisplayed);

        return errorCount > 0;
    }

    private boolean diffModOutReport(int maxErrorsDisplayed,
        List<TadModOutReportEntry> tadModOutReportA,
        List<TadModOutReportEntry> tadModOutReportB) {

        if (tadModOutReportA.size() != tadModOutReportB.size()) {
            log.error(String.format("The first mod/out report has %d rows "
                + "and the second mod/out report has %d rows",
                tadModOutReportA.size(), tadModOutReportB.size()));
        }

        StringBuffer output = new StringBuffer();
        output.append("\nReports differ");
        output.append("\nIndex\t"
            + "averagePixelsPerTargetDef, cstmTrgsNoAptCnt, "
            + "mergedTargetCount, reportRejectedByCoaTargetCount, "
            + "supermaskCount, msksSmlrThnAprtrCnt, totalMaskCount, "
            + "usedMaskCount, ccdModule, ccdOutput, "
            + "modOutRejectedByCoaTargetCount, exclusiveLowerBound, "
            + "inclusiveUpperBound, targetCount, sigProcChainsCount, "
            + "backgroundPixelCount, backgroundTargetDefCnt, "
            + "dynamicRangePixelCount, dynamicRangeTargetDefCnt, "
            + "excessPixelCount, leadingBlackPixelCount, "
            + "leadingBlackTargetDefCnt, maskedSmearPixelCount, "
            + "maskedSmearTargetDefCnt, stellarPixelCount, "
            + "stellarTargetDefCnt, totalPixelCount, totalTargetDefCnt, "
            + "trailingBlackPixelCount, trailingBlackTargetDefCnt, "
            + "uniquePixelCount, virtualSmearPixelCount, "
            + "virtualSmearTargetDefCnt, labelCount, mapkey\n");

        int errorCount = 0;
        int n = Math.min(tadModOutReportA.size(), tadModOutReportB.size());
        for (int i = 0; i < n; i++) {
            TadModOutReportEntry tadModOutReportEntryA = tadModOutReportA.get(i);
            TadModOutReportEntry tadModOutReportEntryB = tadModOutReportB.get(i);
            boolean localDifferent = false;
            if (tadModOutReportEntryA == null || tadModOutReportEntryB == null) {
                if (tadModOutReportEntryA != null
                    || tadModOutReportEntryB != null) {
                    localDifferent = true;
                }
            } else if (tadModOutReportEntryA.averagePixelsPerTargetDef != tadModOutReportEntryB.averagePixelsPerTargetDef
                || tadModOutReportEntryA.backgroundPixelCount != tadModOutReportEntryB.backgroundPixelCount
                || tadModOutReportEntryA.backgroundTargetDefCnt != tadModOutReportEntryB.backgroundTargetDefCnt
                || tadModOutReportEntryA.ccdModule != tadModOutReportEntryB.ccdModule
                || tadModOutReportEntryA.ccdOutput != tadModOutReportEntryB.ccdOutput
                || tadModOutReportEntryA.cstmTrgsNoAptCnt != tadModOutReportEntryB.cstmTrgsNoAptCnt
                || tadModOutReportEntryA.dynamicRangePixelCount != tadModOutReportEntryB.dynamicRangePixelCount
                || tadModOutReportEntryA.dynamicRangeTargetDefCnt != tadModOutReportEntryB.dynamicRangeTargetDefCnt
                || tadModOutReportEntryA.excessPixelCount != tadModOutReportEntryB.excessPixelCount
                || tadModOutReportEntryA.exclusiveLowerBound != tadModOutReportEntryB.exclusiveLowerBound
                || tadModOutReportEntryA.inclusiveUpperBound != tadModOutReportEntryB.inclusiveUpperBound
                || tadModOutReportEntryA.labelCount != tadModOutReportEntryB.labelCount
                || tadModOutReportEntryA.leadingBlackPixelCount != tadModOutReportEntryB.leadingBlackPixelCount
                || tadModOutReportEntryA.leadingBlackTargetDefCnt != tadModOutReportEntryB.leadingBlackTargetDefCnt
                || !objectsEqual(tadModOutReportEntryA.mapkey,
                    tadModOutReportEntryB.mapkey)
                || tadModOutReportEntryA.maskedSmearPixelCount != tadModOutReportEntryB.maskedSmearPixelCount
                || tadModOutReportEntryA.maskedSmearTargetDefCnt != tadModOutReportEntryB.maskedSmearTargetDefCnt
                || tadModOutReportEntryA.mergedTargetCount != tadModOutReportEntryB.mergedTargetCount
                || tadModOutReportEntryA.modOutRejectedByCoaTargetCount != tadModOutReportEntryB.modOutRejectedByCoaTargetCount
                || tadModOutReportEntryA.msksSmlrThnAprtrCnt != tadModOutReportEntryB.msksSmlrThnAprtrCnt
                || tadModOutReportEntryA.reportRejectedByCoaTargetCount != tadModOutReportEntryB.reportRejectedByCoaTargetCount
                || tadModOutReportEntryA.sigProcChainsCount != tadModOutReportEntryB.sigProcChainsCount
                || tadModOutReportEntryA.stellarPixelCount != tadModOutReportEntryB.stellarPixelCount
                || tadModOutReportEntryA.stellarTargetDefCnt != tadModOutReportEntryB.stellarTargetDefCnt
                || tadModOutReportEntryA.supermaskCount != tadModOutReportEntryB.supermaskCount
                || tadModOutReportEntryA.targetCount != tadModOutReportEntryB.targetCount
                || tadModOutReportEntryA.trailingBlackPixelCount != tadModOutReportEntryB.trailingBlackPixelCount
                || tadModOutReportEntryA.trailingBlackTargetDefCnt != tadModOutReportEntryB.trailingBlackTargetDefCnt
                || tadModOutReportEntryA.totalMaskCount != tadModOutReportEntryB.totalMaskCount
                || tadModOutReportEntryA.totalPixelCount != tadModOutReportEntryB.totalPixelCount
                || tadModOutReportEntryA.totalTargetDefCnt != tadModOutReportEntryB.totalTargetDefCnt
                || tadModOutReportEntryA.uniquePixelCount != tadModOutReportEntryB.uniquePixelCount
                || tadModOutReportEntryA.usedMaskCount != tadModOutReportEntryB.usedMaskCount
                || tadModOutReportEntryA.virtualSmearPixelCount != tadModOutReportEntryB.virtualSmearPixelCount
                || tadModOutReportEntryA.virtualSmearTargetDefCnt != tadModOutReportEntryB.virtualSmearTargetDefCnt) {
                localDifferent = true;
            }

            if (localDifferent) {
                if (errorCount++ >= maxErrorsDisplayed) {
                    continue;
                }
                output.append(i)
                    .append("\t");
                if (tadModOutReportEntryA != null) {
                    output.append(
                        tadModOutReportEntryA.averagePixelsPerTargetDef)
                        .append(" ")
                        .append(tadModOutReportEntryA.cstmTrgsNoAptCnt)
                        .append(" ")
                        .append(tadModOutReportEntryA.mergedTargetCount)
                        .append(" ")
                        .append(
                            tadModOutReportEntryA.reportRejectedByCoaTargetCount)
                        .append(" ")
                        .append(tadModOutReportEntryA.supermaskCount)
                        .append(" ")
                        .append(tadModOutReportEntryA.msksSmlrThnAprtrCnt)
                        .append(" ")
                        .append(tadModOutReportEntryA.totalMaskCount)
                        .append(" ")
                        .append(tadModOutReportEntryA.usedMaskCount)
                        .append(" ")
                        .append(tadModOutReportEntryA.ccdModule)
                        .append(" ")
                        .append(tadModOutReportEntryA.ccdOutput)
                        .append(" ")
                        .append(
                            tadModOutReportEntryA.modOutRejectedByCoaTargetCount)
                        .append(" ")
                        .append(tadModOutReportEntryA.exclusiveLowerBound)
                        .append(" ")
                        .append(tadModOutReportEntryA.inclusiveUpperBound)
                        .append(" ")
                        .append(tadModOutReportEntryA.targetCount)
                        .append(" ")
                        .append(tadModOutReportEntryA.sigProcChainsCount)
                        .append(" ")
                        .append(tadModOutReportEntryA.backgroundPixelCount)
                        .append(" ")
                        .append(tadModOutReportEntryA.backgroundTargetDefCnt)
                        .append(" ")
                        .append(tadModOutReportEntryA.dynamicRangePixelCount)
                        .append(" ")
                        .append(tadModOutReportEntryA.dynamicRangeTargetDefCnt)
                        .append(" ")
                        .append(tadModOutReportEntryA.excessPixelCount)
                        .append(" ")
                        .append(tadModOutReportEntryA.leadingBlackPixelCount)
                        .append(" ")
                        .append(tadModOutReportEntryA.leadingBlackTargetDefCnt)
                        .append(" ")
                        .append(tadModOutReportEntryA.maskedSmearPixelCount)
                        .append(" ")
                        .append(tadModOutReportEntryA.maskedSmearTargetDefCnt)
                        .append(" ")
                        .append(tadModOutReportEntryA.stellarPixelCount)
                        .append(" ")
                        .append(tadModOutReportEntryA.stellarTargetDefCnt)
                        .append(" ")
                        .append(tadModOutReportEntryA.totalPixelCount)
                        .append(" ")
                        .append(tadModOutReportEntryA.totalTargetDefCnt)
                        .append(" ")
                        .append(tadModOutReportEntryA.trailingBlackPixelCount)
                        .append(" ")
                        .append(tadModOutReportEntryA.trailingBlackTargetDefCnt)
                        .append(" ")
                        .append(tadModOutReportEntryA.uniquePixelCount)
                        .append(" ")
                        .append(tadModOutReportEntryA.virtualSmearPixelCount)
                        .append(" ")
                        .append(tadModOutReportEntryA.virtualSmearTargetDefCnt)
                        .append(" ")
                        .append(tadModOutReportEntryA.labelCount)
                        .append(" ")
                        .append(tadModOutReportEntryA.mapkey);
                } else {
                    output.append("NULL");
                }
                output.append("\n\t");
                if (tadModOutReportEntryB != null) {
                    output.append(
                        tadModOutReportEntryB.averagePixelsPerTargetDef)
                        .append(" ")
                        .append(tadModOutReportEntryB.cstmTrgsNoAptCnt)
                        .append(" ")
                        .append(tadModOutReportEntryB.mergedTargetCount)
                        .append(" ")
                        .append(
                            tadModOutReportEntryB.reportRejectedByCoaTargetCount)
                        .append(" ")
                        .append(tadModOutReportEntryB.supermaskCount)
                        .append(" ")
                        .append(tadModOutReportEntryB.msksSmlrThnAprtrCnt)
                        .append(" ")
                        .append(tadModOutReportEntryB.totalMaskCount)
                        .append(" ")
                        .append(tadModOutReportEntryB.usedMaskCount)
                        .append(" ")
                        .append(tadModOutReportEntryB.ccdModule)
                        .append(" ")
                        .append(tadModOutReportEntryB.ccdOutput)
                        .append(" ")
                        .append(
                            tadModOutReportEntryB.modOutRejectedByCoaTargetCount)
                        .append(" ")
                        .append(tadModOutReportEntryB.exclusiveLowerBound)
                        .append(" ")
                        .append(tadModOutReportEntryB.inclusiveUpperBound)
                        .append(" ")
                        .append(tadModOutReportEntryB.targetCount)
                        .append(" ")
                        .append(tadModOutReportEntryB.sigProcChainsCount)
                        .append(" ")
                        .append(tadModOutReportEntryB.backgroundPixelCount)
                        .append(" ")
                        .append(tadModOutReportEntryB.backgroundTargetDefCnt)
                        .append(" ")
                        .append(tadModOutReportEntryB.dynamicRangePixelCount)
                        .append(" ")
                        .append(tadModOutReportEntryB.dynamicRangeTargetDefCnt)
                        .append(" ")
                        .append(tadModOutReportEntryB.excessPixelCount)
                        .append(" ")
                        .append(tadModOutReportEntryB.leadingBlackPixelCount)
                        .append(" ")
                        .append(tadModOutReportEntryB.leadingBlackTargetDefCnt)
                        .append(" ")
                        .append(tadModOutReportEntryB.maskedSmearPixelCount)
                        .append(" ")
                        .append(tadModOutReportEntryB.maskedSmearTargetDefCnt)
                        .append(" ")
                        .append(tadModOutReportEntryB.stellarPixelCount)
                        .append(" ")
                        .append(tadModOutReportEntryB.stellarTargetDefCnt)
                        .append(" ")
                        .append(tadModOutReportEntryB.totalPixelCount)
                        .append(" ")
                        .append(tadModOutReportEntryB.totalTargetDefCnt)
                        .append(" ")
                        .append(tadModOutReportEntryB.trailingBlackPixelCount)
                        .append(" ")
                        .append(tadModOutReportEntryB.trailingBlackTargetDefCnt)
                        .append(" ")
                        .append(tadModOutReportEntryB.uniquePixelCount)
                        .append(" ")
                        .append(tadModOutReportEntryB.virtualSmearPixelCount)
                        .append(" ")
                        .append(tadModOutReportEntryB.virtualSmearTargetDefCnt)
                        .append(" ")
                        .append(tadModOutReportEntryB.labelCount)
                        .append(" ")
                        .append(tadModOutReportEntryB.mapkey);
                } else {
                    output.append("NULL");
                }
                output.append("\n");
            }
        }

        errorCount += Math.abs(tadModOutReportA.size()
            - tadModOutReportB.size());
        displaySummary("Mod/Out report", tadModOutReportA.size(), errorCount,
            output, maxErrorsDisplayed);

        return errorCount > 0;
    }

    private boolean diffAlerts(int maxErrorsDisplayed,
        List<TadReportAlertEntry> tadReportAlertsA,
        List<TadReportAlertEntry> tadReportAlertsB) {

        if (tadReportAlertsA.size() != tadReportAlertsB.size()) {
            log.error(String.format("The first report has %d alerts "
                + "and the second report has %d alerts",
                tadReportAlertsA.size(), tadReportAlertsB.size()));
        }

        StringBuffer output = new StringBuffer();
        output.append("\nAlerts differ");
        output.append("\nIndex\telement\n");

        int errorCount = 0;
        int n = Math.min(tadReportAlertsA.size(), tadReportAlertsB.size());
        for (int i = 0; i < n; i++) {
            TadReportAlertEntry tadReportAlertEntryA = tadReportAlertsA.get(i);
            TadReportAlertEntry tadReportAlertEntryB = tadReportAlertsB.get(i);
            boolean localDifferent = false;
            if (tadReportAlertEntryA == null || tadReportAlertEntryB == null) {
                if (tadReportAlertEntryA != null
                    || tadReportAlertEntryB != null) {
                    localDifferent = true;
                }
            } else if (!objectsEqual(tadReportAlertEntryA.element,
                tadReportAlertEntryB.element)) {
                localDifferent = true;
            }

            if (localDifferent) {
                if (errorCount++ >= maxErrorsDisplayed) {
                    continue;
                }
                output.append(i)
                    .append("\t");
                if (tadReportAlertEntryA != null) {
                    output.append(tadReportAlertEntryA.element)
                        .append("\t");
                } else {
                    output.append("NULL");
                }
                if (tadReportAlertEntryB != null) {
                    output.append(tadReportAlertEntryB.element);
                } else {
                    output.append("NULL");
                }
                output.append("\n");
            }
        }

        errorCount += Math.abs(tadReportAlertsA.size()
            - tadReportAlertsB.size());
        displaySummary("Alerts", tadReportAlertsA.size(), errorCount, output,
            maxErrorsDisplayed);

        return errorCount > 0;
    }

    private void displaySummary(String label, int rows, int errorCount,
        StringBuffer output, int maxErrorsDisplayed) {

        if (errorCount > 0) {
            if (errorCount >= maxErrorsDisplayed) {
                output.append("...\n");
            }
            output.append(String.format("%d error%s in %d values (%.2f%%)\n",
                errorCount, errorCount > 1 ? "s" : "", rows,
                (double) errorCount / rows * 100.0));
            log.error(output.toString());
        }

        log.info(String.format("%s: %s %d rows", label,
            errorCount > 0 ? "Processed" : "Validated", rows));
    }

    private boolean objectsEqual(Object objectA, Object objectB) {
        if (objectA == null && objectB != null || objectA != null
            && !objectA.equals(objectB)) {
            return false;
        }
        return true;
    }

    /**
     * Returns the last component of a path, or the entire component if there
     * aren't any path separators present.
     * <p>
     * It would be nice to use FileUtils.getBasename but its semantics are
     * wrong.
     * 
     * @param pathname the path
     * @return the last component, or {@code null} if {@code pathname} is
     * {@code null}
     */
    private static String basename(String pathname) {
        if (pathname == null) {
            return null;
        }
        int index = pathname.lastIndexOf(File.separatorChar);
        if (index == -1) {
            return pathname;
        }

        return pathname.substring(index + 1);
    }
}
