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

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Extracts database tables associated with a given target list set.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class CmTadExtractor {

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(CmTadExtractor.class);

    private enum TableIdIndex {
        /** Matches tls.ID in query. */
        TARGET_LIST_SET(0),

        /** Matches tt.ID in query. */
        TARGET_TABLE(1),

        /** Matches tt.TAD_MASK_TABLE_ID in query. */
        MASK_TABLE(2),

        /** Matches tt.TAD_TAD_REPORT_ID in query. */
        TAD_REPORT(3);

        private final int index;

        private TableIdIndex(int index) {
            this.index = index;
        }

        public int getIndex() {
            return index;
        }
    }

    private static final String TARGET_TABLE_ID_QUERY_FORMAT = "select "
        + "tls.ID as TARGET_LIST_SET_ID, tt.ID as TARGET_TABLE_ID, tt.TAD_MASK_TABLE_ID, tt.TAD_TAD_REPORT_ID "
        + "from CM_TARGET_LIST_SET tls, CM_TLS_TT ct, TAD_TARGET_TABLE tt "
        + "where tls.NAME='%s' and ct.CM_TARGET_LIST_SET_ID = tls.id and ct.TAD_TARGET_TABLE_ID = tt.ID";

    private static final String BACKGROUND_TABLE_ID_QUERY_FORMAT = "select "
        + "tls.ID as TARGET_LIST_SET_ID, bt.ID as TARGET_TABLE_ID, bt.TAD_MASK_TABLE_ID, bt.TAD_TAD_REPORT_ID "
        + "from CM_TARGET_LIST_SET tls, CM_TLS_BT ct, TAD_TARGET_TABLE bt "
        + "where tls.NAME='%s' and ct.CM_TARGET_LIST_SET_ID = tls.id and ct.TAD_TARGET_TABLE_ID = bt.ID";

    private DbExtractor extractor;
    private String targetListSetName;

    private List<Long> targetTableIds;
    private List<Long> backgroundTableIds;

    public CmTadExtractor(String uri) {
        String[] uriParts = uri.split("\\?");
        if (uriParts.length != 2) {
            throw new UsageException("Missing target list set name");
        }
        extractor = new DbExtractor(uriParts[0]);
        targetListSetName = uriParts[1];
    }

    public String getTargetListSetName() {
        return targetListSetName;
    }

    public List<PlannedTargetEntry> extractIncludedPlannedTargets() {
        List<PlannedTargetEntry> plannedTargetEntries = new ArrayList<PlannedTargetEntry>();

        extractor.process(new PlannedTargetVisitor(
            PlannedTargetEntry.PLANNED_TARGET_QUERY_FORMAT, "CM_TLS_TL",
            getTargetTableIds().get(TableIdIndex.TARGET_LIST_SET.getIndex()),
            plannedTargetEntries));

        return plannedTargetEntries;
    }

    public List<PlannedTargetEntry> extractExcludedPlannedTargets() {
        List<PlannedTargetEntry> plannedTargetEntries = new ArrayList<PlannedTargetEntry>();

        extractor.process(new PlannedTargetVisitor(
            PlannedTargetEntry.PLANNED_TARGET_QUERY_FORMAT, "CM_TLS_ETL",
            getTargetTableIds().get(TableIdIndex.TARGET_LIST_SET.getIndex()),
            plannedTargetEntries));

        return plannedTargetEntries;
    }

    public List<CustomPlannedTargetEntry> extractCustomPlannedTargets() {
        List<CustomPlannedTargetEntry> customPlannedTargetEntries = new ArrayList<CustomPlannedTargetEntry>();

        extractor.process(new CustomPlannedTargetVisitor(
            CustomPlannedTargetEntry.CUSTOM_PLANNED_TARGET_QUERY_FORMAT,
            getTargetTableIds().get(TableIdIndex.TARGET_LIST_SET.getIndex()),
            customPlannedTargetEntries));

        return customPlannedTargetEntries;
    }

    public List<TargetTableEntry> extractTargetTable() {
        List<TargetTableEntry> targetTableEntries = new ArrayList<TargetTableEntry>();

        extractor.process(new TargetTableVisitor(
            TargetTableEntry.TARGET_QUERY_FORMAT, getTargetTableIds().get(
                TableIdIndex.TARGET_TABLE.getIndex()), targetTableEntries));
        extractor.process(new TargetTableVisitor(
            TargetTableEntry.TARGET_QUERY_FORMAT, getBackgroundTableIds().get(
                TableIdIndex.TARGET_TABLE.getIndex()), targetTableEntries));

        return targetTableEntries;
    }

    public List<MaskTableEntry> extractMaskTable() {
        List<MaskTableEntry> maskTableEntries = new ArrayList<MaskTableEntry>();

        extractor.process(new MaskTableVisitor(
            MaskTableEntry.MASK_QUERY_FORMAT, getTargetTableIds().get(
                TableIdIndex.MASK_TABLE.getIndex()), maskTableEntries));
        extractor.process(new MaskTableVisitor(
            MaskTableEntry.MASK_QUERY_FORMAT, getBackgroundTableIds().get(
                TableIdIndex.MASK_TABLE.getIndex()), maskTableEntries));

        return maskTableEntries;
    }

    public List<ObservedTargetEntry> extractObservedTargets() {
        List<ObservedTargetEntry> observedTargetEntries = new ArrayList<ObservedTargetEntry>();

        extractor.process(new ObservedTargetVisitor(
            ObservedTargetEntry.OBSERVED_TARGET_QUERY_FORMAT,
            getTargetTableIds().get(TableIdIndex.TARGET_TABLE.getIndex()),
            observedTargetEntries));
        extractor.process(new ObservedTargetVisitor(
            ObservedTargetEntry.OBSERVED_TARGET_QUERY_FORMAT,
            getBackgroundTableIds().get(TableIdIndex.TARGET_TABLE.getIndex()),
            observedTargetEntries));

        return observedTargetEntries;
    }

    public List<TargetDefinitionValidationEntry> extractTargetDefinitionValidationEntries() {
        List<TargetDefinitionValidationEntry> targetDefinitionValidationEntries = new ArrayList<TargetDefinitionValidationEntry>();

        extractor.process(new TargetDefinitionValidationVisitor(
            TargetDefinitionValidationEntry.TARGET_DEFINITION_VALIDATION_QUERY_FORMAT,
            getTargetTableIds().get(TableIdIndex.TARGET_TABLE.getIndex()),
            targetDefinitionValidationEntries));
        extractor.process(new TargetDefinitionValidationVisitor(
            TargetDefinitionValidationEntry.TARGET_DEFINITION_VALIDATION_QUERY_FORMAT,
            getBackgroundTableIds().get(TableIdIndex.TARGET_TABLE.getIndex()),
            targetDefinitionValidationEntries));

        return targetDefinitionValidationEntries;
    }

    public List<TadReportEntry> extractTadReport() {
        List<TadReportEntry> tadReportEntries = new ArrayList<TadReportEntry>();

        extractor.process(new TadReportVisitor(
            TadReportEntry.REPORT_QUERY_FORMAT, getTargetTableIds().get(
                TableIdIndex.TAD_REPORT.getIndex()), tadReportEntries));
        extractor.process(new TadReportVisitor(
            TadReportEntry.REPORT_QUERY_FORMAT, getBackgroundTableIds().get(
                TableIdIndex.TAD_REPORT.getIndex()), tadReportEntries));

        return tadReportEntries;
    }

    public List<TadModOutReportEntry> extractTadModOutReport() {
        List<TadModOutReportEntry> tadModOutReportEntries = new ArrayList<TadModOutReportEntry>();

        extractor.process(new TadModOutReportVisitor(
            TadModOutReportEntry.REPORT_QUERY_FORMAT, getTargetTableIds().get(
                TableIdIndex.TAD_REPORT.getIndex()), tadModOutReportEntries));
        extractor.process(new TadModOutReportVisitor(
            TadModOutReportEntry.REPORT_QUERY_FORMAT,
            getBackgroundTableIds().get(TableIdIndex.TAD_REPORT.getIndex()),
            tadModOutReportEntries));

        return tadModOutReportEntries;
    }

    public List<TadReportAlertEntry> extractTadReportAlerts() {
        List<TadReportAlertEntry> tadReportAlertEntries = new ArrayList<TadReportAlertEntry>();

        extractor.process(new TadReportAlertsVisitor(
            TadReportAlertEntry.WARNING_QUERY_FORMAT, getTargetTableIds().get(
                TableIdIndex.TAD_REPORT.getIndex()), tadReportAlertEntries));
        extractor.process(new TadReportAlertsVisitor(
            TadReportAlertEntry.WARNING_QUERY_FORMAT,
            getBackgroundTableIds().get(TableIdIndex.TAD_REPORT.getIndex()),
            tadReportAlertEntries));

        extractor.process(new TadReportAlertsVisitor(
            TadReportAlertEntry.ERROR_QUERY_FORMAT, getTargetTableIds().get(
                TableIdIndex.TAD_REPORT.getIndex()), tadReportAlertEntries));
        extractor.process(new TadReportAlertsVisitor(
            TadReportAlertEntry.ERROR_QUERY_FORMAT,
            getBackgroundTableIds().get(TableIdIndex.TAD_REPORT.getIndex()),
            tadReportAlertEntries));

        return tadReportAlertEntries;
    }

    private List<Long> getTargetTableIds() {
        if (targetTableIds == null) {
            targetTableIds = new ArrayList<Long>();
            extractor.process(new TableIdVisitor(TARGET_TABLE_ID_QUERY_FORMAT,
                targetListSetName, targetTableIds));
            if (targetTableIds.size() != TableIdIndex.values().length) {
                throw new IllegalStateException(String.format(
                    "Expected %d table IDs, not %d",
                    TableIdIndex.values().length, targetTableIds.size()));
            }
        }

        return targetTableIds;
    }

    private List<Long> getBackgroundTableIds() {
        if (backgroundTableIds == null) {
            backgroundTableIds = new ArrayList<Long>();
            extractor.process(new TableIdVisitor(
                BACKGROUND_TABLE_ID_QUERY_FORMAT, targetListSetName,
                backgroundTableIds));
            if (backgroundTableIds.size() != TableIdIndex.values().length) {
                throw new IllegalStateException(String.format(
                    "Expected %d table IDs, not %d",
                    TableIdIndex.values().length, backgroundTableIds.size()));
            }
        }

        return backgroundTableIds;
    }

    public static class PlannedTargetEntry {
        public static final String PLANNED_TARGET_QUERY_FORMAT = "select "
            + "tl.CATEGORY, tl.LAST_MODIFIED, tl.NAME, tl.SOURCE, tl.SOURCE_TYPE, "
            + "pt.KEPLER_ID, pt.SKY_GROUP_ID, "
            + "pl.ELEMENT as LABEL "
            + "from CM_TARGET_LIST_SET tls, %s sl, CM_TARGET_LIST tl, CM_PLANNED_TARGET pt, CM_PT_LABELS pl "
            + "where tls.ID = %d and sl.CM_TARGET_LIST_SET_ID = tls.ID and tl.ID = sl.CM_TARGET_LIST_ID "
            + "and pt.TARGET_LIST_ID = tl.ID and pl.PLANNED_TARGET_ID = pt.ID "
            + "order by pt.KEPLER_ID, tl.CATEGORY, pl.ELEMENT";

        public String category;
        public Date lastModified;
        public String name;
        public String source;
        public int sourceType;
        public int keplerId;
        public int skyGroupId;
        public String label;
    }

    public static class CustomPlannedTargetEntry {
        public static final String CUSTOM_PLANNED_TARGET_QUERY_FORMAT = "select "
            + "tl.CATEGORY, tl.LAST_MODIFIED, tl.NAME, tl.SOURCE, tl.SOURCE_TYPE, "
            + "pt.KEPLER_ID, pt.SKY_GROUP_ID, "
            + "ta.REFERENCE_COLUMN, ta.REFERENCE_ROW, ta.USER_DEFINED, "
            + "ao.COLUMN_OFFSET, ao.ROW_OFFSET, "
            + "pl.ELEMENT as LABEL "
            + "from CM_TARGET_LIST_SET tls, CM_TLS_TL sl, CM_TARGET_LIST tl, CM_PLANNED_TARGET pt, "
            + "CM_PT_APERTURE pa, TAD_APERTURE ta, TAD_APERTURE_OFFSETS ao, CM_PT_LABELS pl "
            + "where tls.ID = %d and sl.CM_TARGET_LIST_SET_ID = tls.ID and tl.ID = sl.CM_TARGET_LIST_ID "
            + "and pt.TARGET_LIST_ID = tl.ID and pt.KEPLER_ID >= 100000000 "
            + "and pa.PLANNED_TARGET_ID = pt.ID and ta.ID = pa.TAD_APERTURE_ID "
            + "and ao.TAD_APERTURE_ID = ta.ID and pl.PLANNED_TARGET_ID = pt.ID "
            + "order by pt.KEPLER_ID, tl.CATEGORY, pl.ELEMENT, ao.ROW_OFFSET, ao.COLUMN_OFFSET";

        public String category;
        public Date lastModified;
        public String name;
        public String source;
        public int sourceType;
        public int keplerId;
        public int skyGroupId;
        public int referenceColumn;
        public int referenceRow;
        public boolean userDefined;
        public int columnOffset;
        public int rowOffset;
        public String label;
    }

    public static class TargetTableEntry {

        public static final String TARGET_QUERY_FORMAT = "select tt.FILE_NAME, "
            + "tt.PLANNED_START_TIME, tt.PLANNED_END_TIME, tt.OBSERVING_SEASON, tt.TYPE, "
            + "td.CCD_MODULE, td.CCD_OUTPUT, td.EXCESS_PIXELS, td.INDEX_IN_MODULE_OUTPUT, td.KEPLER_ID, "
            + "td.REFERENCE_ROW, td.REFERENCE_COLUMN, td.STATUS, tm.INDEX_IN_TABLE "
            + "from TAD_TARGET_TABLE tt, TAD_TARGET_DEFINITION td, TAD_MASK tm "
            + "where tt.id=%d and td.TAD_TARGET_TABLE_ID=tt.id and td.TAD_MASK_ID=tm.ID "
            + "order by td.CCD_MODULE, td.CCD_OUTPUT, td.KEPLER_ID, "
            + "td.INDEX_IN_MODULE_OUTPUT, td.REFERENCE_ROW, td.REFERENCE_COLUMN";

        public String fileName;
        public Date plannedStartTime;
        public Date plannedEndTime;
        public int observingSeason;
        public int type;
        public int ccdModule;
        public int ccdOutput;
        public int excessPixels;
        public int indexInModuleOutput;
        public int keplerId;
        public int referenceRow;
        public int referenceColumn;
        public int status;
        public int indexInTable;
    }

    public static class MaskTableEntry {

        public static final String MASK_QUERY_FORMAT = "select "
            + "mt.FILE_NAME, mt.PLANNED_START_TIME, mt.PLANNED_END_TIME, "
            + "mt.TYPE, m.INDEX_IN_TABLE, m.SUPERMASK, m.USED, "
            + "mo.COLUMN_OFFSET, mo.ROW_OFFSET "
            + "from TAD_MASK_TABLE mt, TAD_MASK m, TAD_MASK_OFFSETS mo "
            + "where m.TAD_MASK_TABLE_ID = mt.id and mo.TAD_MASK_ID = m.id and mt.id=%d "
            + "order by m.INDEX_IN_TABLE, mo.ROW_OFFSET, mo.COLUMN_OFFSET";

        public String fileName;
        public Date plannedStartTime;
        public Date plannedEndTime;
        public int type;
        public int indexInTable;
        public boolean supermask;
        public boolean used;
        public int columnOffset;
        public int rowOffset;
    }

    public static class ObservedTargetEntry {
        public static final String OBSERVED_TARGET_QUERY_FORMAT = "select "
            + "ot.APERTURE_PIXEL_COUNT, ot.BAD_PIXEL_COUNT, ot.CCD_MODULE, ot.CCD_OUTPUT, ot.CROWDING_METRIC, "
            + "ot.DISTANCE_FROM_EDGE, ot.FLUX_FRACTION_IN_APERTURE, ot.KEPLER_ID, ot.MAGNITUDE, ot.REJECTED, "
            + "ot.SIGNAL_TO_NOISE_RATIO, ot.SKY_CROWDING_METRIC, ot.TARGET_DEFS_PIXEL_COUNT, "
            + "ot.SATURATED_ROW_COUNT, ta.REFERENCE_COLUMN, ta.REFERENCE_ROW, ta.USER_DEFINED, "
            + "ao.COLUMN_OFFSET, ao.ROW_OFFSET, tl.ELEMENT as LABEL "
            + "from TAD_OBSERVED_TARGET ot, TAD_APERTURE ta, TAD_APERTURE_OFFSETS ao, TAD_OBSERVED_TARGET_LABELS tl "
            + "where ot.TAD_TARGET_TABLE_ID = %d and ot.TAD_APERTURE_ID = ta.ID and ao.TAD_APERTURE_ID = ta.ID and tl.TAD_OBSERVED_TARGET_ID = ot.ID "
            + "order by ot.KEPLER_ID, tl.ELEMENT, ao.ROW_OFFSET, ao.COLUMN_OFFSET";

        public int aperturePixelCount;
        public int badPixelCount;
        public int ccdModule;
        public int ccdOutput;
        public double crowdingMetric;
        public int distanceFromEdge;
        public double fluxFractionInAperture;
        public int keplerId;
        public float magnitude;
        public boolean rejected;
        public double signalToNoiseRatio;
        public double skyCrowdingMetric;
        public int targetDefsPixelCount;
        public int saturatedRowCount;
        public int referenceColumn;
        public int referenceRow;
        public boolean userDefined;
        public int columnOffset;
        public int rowOffset;
        public String label;
    }

    public static class TargetDefinitionValidationEntry {
        public static final String TARGET_DEFINITION_VALIDATION_QUERY_FORMAT = "select count(*) "
            + "from TAD_TARGET_DEFINITION td, TAD_OBSERVED_TARGET ot, TAD_OBS_TARGET_TARGET_DEFS ottd "
            + "where td.TAD_TARGET_TABLE_ID=%d "
            + "and ottd.TAD_OBSERVED_TARGET_ID = ot.id and ottd.TAD_TARGET_DEFINITION_ID = td.id "
            + "and ot.KEPLER_ID != td.KEPLER_ID";

        public int observedTargetKeplerIdMismatchCount;
    }

    public static class TadReportEntry {
        public static final String REPORT_QUERY_FORMAT = "select "
            + "r.AVERAGE_PIXELS_PER_TARGET_DEF, r.CSTM_TRGS_NO_APT_CNT, "
            + "r.MERGED_TARGET_COUNT, "
            + "r.REJECTED_BY_COA_TARGET_COUNT as REPORT_REJECTED_BY_COA, "
            + "r.SUPERMASK_COUNT, r.MSKS_SMLR_THN_APRTR_CNT, r.TOTAL_MASK_COUNT, "
            + "r.USED_MASK_COUNT, "
            + "rbp.EXCLUSIVE_LOWER_BOUND, rbp.INCLUSIVE_UPPER_BOUND, rbp.TARGET_COUNT, "
            + "rc.ELEMENT as SIG_PROC_CHAINS_ELEMENT, "
            + "rtpc.BACKGROUND_PIXEL_COUNT, rtpc.BACKGROUND_TARGET_DEF_CNT, "
            + "rtpc.DYNAMIC_RANGE_PIXEL_COUNT, "
            + "rtpc.DYNAMIC_RANGE_TARGET_DEF_CNT, rtpc.EXCESS_PIXEL_COUNT, "
            + "rtpc.LEADING_BLACK_PIXEL_COUNT, "
            + "rtpc.LEADING_BLACK_TARGET_DEF_CNT, rtpc.MASKED_SMEAR_PIXEL_COUNT, "
            + "rtpc.MASKED_SMEAR_TARGET_DEF_CNT, rtpc.STELLAR_PIXEL_COUNT, "
            + "rtpc.STELLAR_TARGET_DEF_CNT, rtpc.TOTAL_PIXEL_COUNT, "
            + "rtpc.TOTAL_TARGET_DEF_CNT, rtpc.TRAILING_BLACK_PIXEL_COUNT, "
            + "rtpc.TRAILING_BLACK_TARGET_DEF_CNT, rtpc.UNIQUE_PIXEL_COUNT, "
            + "rtpc.VIRTUAL_SMEAR_PIXEL_COUNT, "
            + "rtpc.VIRTUAL_SMEAR_TARGET_DEF_CNT, "
            + "rl.ELEMENT as LABEL_ELEMENT, rl.MAPKEY "
            + "from TAD_REP_BAD_PIX_RATES rbp, TAD_TARG_AND_PIX_COUNTS rtpc, TAD_TPC_LABEL_COUNTS rl, "
            + "TAD_TAD_REPORT r left outer join TAD_REP_MSSG_SIG_PROC_CHAINS rc on rc.TAD_TAD_REPORT_ID = r.ID "
            + "where r.ID = %d and rbp.TAD_TAD_REPORT_ID = r.ID "
            + "and rtpc.ID = r.TAD_TARG_AND_PIX_COUNTS_ID and "
            + "rl.TAD_TARG_AND_PIX_COUNTS_ID = rtpc.ID";

        public float averagePixelsPerTargetDef;
        public int cstmTrgsNoAptCnt;
        public int mergedTargetCount;
        public int reportRejectedByCoaTargetCount;
        public int supermaskCount;
        public int msksSmlrThnAprtrCnt;
        public int totalMaskCount;
        public int usedMaskCount;
        public float exclusiveLowerBound;
        public float inclusiveUpperBound;
        public int targetCount;
        public int sigProcChainsCount;
        public int backgroundPixelCount;
        public int backgroundTargetDefCnt;
        public int dynamicRangePixelCount;
        public int dynamicRangeTargetDefCnt;
        public int excessPixelCount;
        public int leadingBlackPixelCount;
        public int leadingBlackTargetDefCnt;
        public int maskedSmearPixelCount;
        public int maskedSmearTargetDefCnt;
        public int stellarPixelCount;
        public int stellarTargetDefCnt;
        public int totalPixelCount;
        public int totalTargetDefCnt;
        public int trailingBlackPixelCount;
        public int trailingBlackTargetDefCnt;
        public int uniquePixelCount;
        public int virtualSmearPixelCount;
        public int virtualSmearTargetDefCnt;
        public int labelCount;
        public String mapkey;
    }

    public static class TadModOutReportEntry {
        public static final String REPORT_QUERY_FORMAT = "select "
            + "r.AVERAGE_PIXELS_PER_TARGET_DEF, r.CSTM_TRGS_NO_APT_CNT, "
            + "r.MERGED_TARGET_COUNT, "
            + "r.REJECTED_BY_COA_TARGET_COUNT as REPORT_REJECTED_BY_COA, "
            + "r.SUPERMASK_COUNT, r.MSKS_SMLR_THN_APRTR_CNT, r.TOTAL_MASK_COUNT, "
            + "r.USED_MASK_COUNT, "
            + "rmo.CCD_MODULE, rmo.CCD_OUTPUT, "
            + "rmo.REJECTED_BY_COA_TARGET_COUNT as MOD_OUT_REJECTED_BY_COA, "
            + "rbp.EXCLUSIVE_LOWER_BOUND, rbp.INCLUSIVE_UPPER_BOUND, rbp.TARGET_COUNT, "
            + "rc.ELEMENT as SIG_PROC_CHAINS_ELEMENT, "
            + "rtpc.BACKGROUND_PIXEL_COUNT, rtpc.BACKGROUND_TARGET_DEF_CNT, "
            + "rtpc.DYNAMIC_RANGE_PIXEL_COUNT, "
            + "rtpc.DYNAMIC_RANGE_TARGET_DEF_CNT, rtpc.EXCESS_PIXEL_COUNT, "
            + "rtpc.LEADING_BLACK_PIXEL_COUNT, "
            + "rtpc.LEADING_BLACK_TARGET_DEF_CNT, rtpc.MASKED_SMEAR_PIXEL_COUNT, "
            + "rtpc.MASKED_SMEAR_TARGET_DEF_CNT, rtpc.STELLAR_PIXEL_COUNT, "
            + "rtpc.STELLAR_TARGET_DEF_CNT, rtpc.TOTAL_PIXEL_COUNT, "
            + "rtpc.TOTAL_TARGET_DEF_CNT, rtpc.TRAILING_BLACK_PIXEL_COUNT, "
            + "rtpc.TRAILING_BLACK_TARGET_DEF_CNT, rtpc.UNIQUE_PIXEL_COUNT, "
            + "rtpc.VIRTUAL_SMEAR_PIXEL_COUNT, "
            + "rtpc.VIRTUAL_SMEAR_TARGET_DEF_CNT, "
            + "rl.ELEMENT as LABEL_ELEMENT, rl.MAPKEY "
            + "from TAD_TAD_MOD_OUT_REPORT rmo, TAD_TAD_REP_TMOR tmor, "
            + "TAD_REP_BAD_PIX_RATES rbp, TAD_TARG_AND_PIX_COUNTS rtpc, TAD_TPC_LABEL_COUNTS rl, "
            + "TAD_TAD_REPORT r left outer join TAD_REP_MSSG_SIG_PROC_CHAINS rc on rc.TAD_TAD_REPORT_ID = r.ID "
            + "where r.ID = %d and tmor.TAD_TAD_REPORT_ID = r.ID  and rmo.ID = tmor.TAD_TAD_MOD_OUT_REPORT_ID "
            + "and rbp.TAD_TAD_REPORT_ID = r.ID and rtpc.ID = r.TAD_TARG_AND_PIX_COUNTS_ID "
            + "and rl.TAD_TARG_AND_PIX_COUNTS_ID = rtpc.ID "
            + "order by rmo.CCD_MODULE, rmo.CCD_OUTPUT, rl.MAPKEY, "
            + "rbp.EXCLUSIVE_LOWER_BOUND, rbp.INCLUSIVE_UPPER_BOUND, rbp.TARGET_COUNT";

        public float averagePixelsPerTargetDef;
        public int cstmTrgsNoAptCnt;
        public int mergedTargetCount;
        public int reportRejectedByCoaTargetCount;
        public int supermaskCount;
        public int msksSmlrThnAprtrCnt;
        public int totalMaskCount;
        public int usedMaskCount;
        public int ccdModule;
        public int ccdOutput;
        public int modOutRejectedByCoaTargetCount;
        public float exclusiveLowerBound;
        public float inclusiveUpperBound;
        public int targetCount;
        public int sigProcChainsCount;
        public int backgroundPixelCount;
        public int backgroundTargetDefCnt;
        public int dynamicRangePixelCount;
        public int dynamicRangeTargetDefCnt;
        public int excessPixelCount;
        public int leadingBlackPixelCount;
        public int leadingBlackTargetDefCnt;
        public int maskedSmearPixelCount;
        public int maskedSmearTargetDefCnt;
        public int stellarPixelCount;
        public int stellarTargetDefCnt;
        public int totalPixelCount;
        public int totalTargetDefCnt;
        public int trailingBlackPixelCount;
        public int trailingBlackTargetDefCnt;
        public int uniquePixelCount;
        public int virtualSmearPixelCount;
        public int virtualSmearTargetDefCnt;
        public int labelCount;
        public String mapkey;
    }

    public static class TadReportAlertEntry {
        public static final String WARNING_QUERY_FORMAT = "select rw.ELEMENT "
            + "from TAD_TAD_REPORT_WARNINGS rw "
            + "where rw.TAD_TAD_REPORT_ID = %d";
        public static final String ERROR_QUERY_FORMAT = "select re.ELEMENT "
            + "from TAD_TAD_REPORT_ERRORS re "
            + "where re.TAD_TAD_REPORT_ID = %d";

        public String element;
    }

    private static class TableIdVisitor implements DbVisitor {

        private final String queryFormat;
        private final String targetListSetName;
        private final List<Long> tableIds;

        public TableIdVisitor(String queryFormat, String targetListSetName,
            List<Long> targetTableIds) {
            this.queryFormat = queryFormat;
            this.targetListSetName = targetListSetName;
            tableIds = targetTableIds;
        }

        @Override
        public String getQuery() {
            return String.format(queryFormat, targetListSetName);
        }

        @Override
        public void visit(ResultSet resultSet) throws SQLException {
            tableIds.add(resultSet.getLong("TARGET_LIST_SET_ID"));
            tableIds.add(resultSet.getLong("TARGET_TABLE_ID"));
            tableIds.add(resultSet.getLong("TAD_MASK_TABLE_ID"));
            tableIds.add(resultSet.getLong("TAD_TAD_REPORT_ID"));
        }
    }

    private static class PlannedTargetVisitor implements DbVisitor {

        private final String queryFormat;
        private final String targetListJoinTable;
        private final Long targetListSetId;
        private final List<PlannedTargetEntry> plannedTargetEntries;

        public PlannedTargetVisitor(String queryFormat,
            String targetListJoinTable, long targetListSetId,
            List<PlannedTargetEntry> plannedTargetEntries) {
            this.queryFormat = queryFormat;
            this.targetListJoinTable = targetListJoinTable;
            this.targetListSetId = targetListSetId;
            this.plannedTargetEntries = plannedTargetEntries;
        }

        @Override
        public String getQuery() {
            return String.format(queryFormat, targetListJoinTable,
                targetListSetId);
        }

        @Override
        public void visit(ResultSet resultSet) throws SQLException {
            PlannedTargetEntry plannedTargetEntry = new PlannedTargetEntry();
            plannedTargetEntry.category = resultSet.getString("CATEGORY");
            plannedTargetEntry.lastModified = resultSet.getDate("LAST_MODIFIED");
            plannedTargetEntry.name = resultSet.getString("NAME");
            plannedTargetEntry.source = resultSet.getString("SOURCE");
            plannedTargetEntry.sourceType = resultSet.getInt("SOURCE_TYPE");
            plannedTargetEntry.keplerId = resultSet.getInt("KEPLER_ID");
            plannedTargetEntry.skyGroupId = resultSet.getInt("SKY_GROUP_ID");
            plannedTargetEntry.label = resultSet.getString("LABEL");
            plannedTargetEntries.add(plannedTargetEntry);
        }
    }

    private static class CustomPlannedTargetVisitor implements DbVisitor {

        private final String queryFormat;
        private final Long targetListSetId;
        private final List<CustomPlannedTargetEntry> customPlannedTargetEntries;

        public CustomPlannedTargetVisitor(String queryFormat,
            long targetListSetId,
            List<CustomPlannedTargetEntry> customPlannedTargetEntries) {
            this.queryFormat = queryFormat;
            this.targetListSetId = targetListSetId;
            this.customPlannedTargetEntries = customPlannedTargetEntries;
        }

        @Override
        public String getQuery() {
            return String.format(queryFormat, targetListSetId);
        }

        @Override
        public void visit(ResultSet resultSet) throws SQLException {
            CustomPlannedTargetEntry customPlannedTargetEntry = new CustomPlannedTargetEntry();
            customPlannedTargetEntry.category = resultSet.getString("CATEGORY");
            customPlannedTargetEntry.lastModified = resultSet.getDate("LAST_MODIFIED");
            customPlannedTargetEntry.name = resultSet.getString("NAME");
            customPlannedTargetEntry.source = resultSet.getString("SOURCE");
            customPlannedTargetEntry.sourceType = resultSet.getInt("SOURCE_TYPE");
            customPlannedTargetEntry.keplerId = resultSet.getInt("KEPLER_ID");
            customPlannedTargetEntry.skyGroupId = resultSet.getInt("SKY_GROUP_ID");
            customPlannedTargetEntry.referenceColumn = resultSet.getInt("REFERENCE_COLUMN");
            customPlannedTargetEntry.referenceRow = resultSet.getInt("REFERENCE_ROW");
            customPlannedTargetEntry.userDefined = resultSet.getBoolean("USER_DEFINED");
            customPlannedTargetEntry.columnOffset = resultSet.getInt("COLUMN_OFFSET");
            customPlannedTargetEntry.rowOffset = resultSet.getInt("ROW_OFFSET");
            customPlannedTargetEntry.label = resultSet.getString("LABEL");
            customPlannedTargetEntries.add(customPlannedTargetEntry);
        }
    }

    private static class TargetTableVisitor implements DbVisitor {

        private final String queryFormat;
        private final Long targetTableId;
        private final List<TargetTableEntry> targetTableEntries;

        public TargetTableVisitor(String queryFormat, long targetTableId,
            List<TargetTableEntry> targetTableEntries) {
            this.queryFormat = queryFormat;
            this.targetTableId = targetTableId;
            this.targetTableEntries = targetTableEntries;
        }

        @Override
        public String getQuery() {
            return String.format(queryFormat, targetTableId);
        }

        @Override
        public void visit(ResultSet resultSet) throws SQLException {
            TargetTableEntry targetTableEntry = new TargetTableEntry();
            targetTableEntry.fileName = resultSet.getString("FILE_NAME");
            targetTableEntry.plannedStartTime = resultSet.getDate("PLANNED_START_TIME");
            targetTableEntry.plannedEndTime = resultSet.getDate("PLANNED_END_TIME");
            targetTableEntry.observingSeason = resultSet.getInt("OBSERVING_SEASON");
            targetTableEntry.type = resultSet.getInt("TYPE");
            targetTableEntry.ccdModule = resultSet.getInt("CCD_MODULE");
            targetTableEntry.ccdOutput = resultSet.getInt("CCD_OUTPUT");
            targetTableEntry.excessPixels = resultSet.getInt("EXCESS_PIXELS");
            targetTableEntry.indexInModuleOutput = resultSet.getInt("INDEX_IN_MODULE_OUTPUT");
            targetTableEntry.keplerId = resultSet.getInt("KEPLER_ID");
            targetTableEntry.referenceRow = resultSet.getInt("REFERENCE_ROW");
            targetTableEntry.referenceColumn = resultSet.getInt("REFERENCE_COLUMN");
            targetTableEntry.status = resultSet.getInt("STATUS");
            targetTableEntry.indexInTable = resultSet.getInt("INDEX_IN_TABLE");
            targetTableEntries.add(targetTableEntry);
        }
    }

    private static class MaskTableVisitor implements DbVisitor {

        private final String queryFormat;
        private final Long maskTableId;
        private final List<MaskTableEntry> maskTableEntries;

        public MaskTableVisitor(String queryFormat, long maskTableId,
            List<MaskTableEntry> maskTableEntries) {
            this.queryFormat = queryFormat;
            this.maskTableId = maskTableId;
            this.maskTableEntries = maskTableEntries;
        }

        @Override
        public String getQuery() {
            return String.format(queryFormat, maskTableId);
        }

        @Override
        public void visit(ResultSet resultSet) throws SQLException {
            MaskTableEntry maskTableEntry = new MaskTableEntry();
            maskTableEntry.fileName = resultSet.getString("FILE_NAME");
            maskTableEntry.plannedStartTime = resultSet.getDate("PLANNED_START_TIME");
            maskTableEntry.plannedEndTime = resultSet.getDate("PLANNED_END_TIME");
            maskTableEntry.type = resultSet.getInt("TYPE");
            maskTableEntry.indexInTable = resultSet.getInt("INDEX_IN_TABLE");
            maskTableEntry.supermask = resultSet.getBoolean("SUPERMASK");
            maskTableEntry.used = resultSet.getBoolean("USED");
            maskTableEntry.columnOffset = resultSet.getInt("COLUMN_OFFSET");
            maskTableEntry.rowOffset = resultSet.getInt("ROW_OFFSET");
            maskTableEntries.add(maskTableEntry);
        }
    }

    private static class ObservedTargetVisitor implements DbVisitor {

        private final String queryFormat;
        private final Long targetTableId;
        private final List<ObservedTargetEntry> observedTargetEntries;

        public ObservedTargetVisitor(String queryFormat, long targetTableId,
            List<ObservedTargetEntry> observedTargetEntries) {
            this.queryFormat = queryFormat;
            this.targetTableId = targetTableId;
            this.observedTargetEntries = observedTargetEntries;
        }

        @Override
        public String getQuery() {
            return String.format(queryFormat, targetTableId);
        }

        @Override
        public void visit(ResultSet resultSet) throws SQLException {
            ObservedTargetEntry observedTargetEntry = new ObservedTargetEntry();
            observedTargetEntry.aperturePixelCount = resultSet.getInt("APERTURE_PIXEL_COUNT");
            observedTargetEntry.badPixelCount = resultSet.getInt("BAD_PIXEL_COUNT");
            observedTargetEntry.ccdModule = resultSet.getInt("CCD_MODULE");
            observedTargetEntry.ccdOutput = resultSet.getInt("CCD_OUTPUT");
            observedTargetEntry.crowdingMetric = resultSet.getDouble("CROWDING_METRIC");
            observedTargetEntry.distanceFromEdge = resultSet.getInt("DISTANCE_FROM_EDGE");
            observedTargetEntry.fluxFractionInAperture = resultSet.getDouble("FLUX_FRACTION_IN_APERTURE");
            observedTargetEntry.keplerId = resultSet.getInt("KEPLER_ID");
            observedTargetEntry.magnitude = resultSet.getFloat("MAGNITUDE");
            observedTargetEntry.rejected = resultSet.getBoolean("REJECTED");
            observedTargetEntry.signalToNoiseRatio = resultSet.getDouble("SIGNAL_TO_NOISE_RATIO");
            observedTargetEntry.skyCrowdingMetric = resultSet.getDouble("SKY_CROWDING_METRIC");
            observedTargetEntry.targetDefsPixelCount = resultSet.getInt("TARGET_DEFS_PIXEL_COUNT");
            observedTargetEntry.saturatedRowCount = resultSet.getInt("SATURATED_ROW_COUNT");
            observedTargetEntry.referenceColumn = resultSet.getInt("REFERENCE_COLUMN");
            observedTargetEntry.referenceRow = resultSet.getInt("REFERENCE_ROW");
            observedTargetEntry.userDefined = resultSet.getBoolean("USER_DEFINED");
            observedTargetEntry.columnOffset = resultSet.getInt("COLUMN_OFFSET");
            observedTargetEntry.rowOffset = resultSet.getInt("ROW_OFFSET");
            observedTargetEntry.label = resultSet.getString("LABEL");
            observedTargetEntries.add(observedTargetEntry);
        }
    }

    private static class TargetDefinitionValidationVisitor implements DbVisitor {

        private final String queryFormat;
        private final Long targetTableId;
        private final List<TargetDefinitionValidationEntry> targetDefinitionValidationEntries;

        public TargetDefinitionValidationVisitor(
            String queryFormat,
            long targetTableId,
            List<TargetDefinitionValidationEntry> targetDefinitionValidationEntries) {
            this.queryFormat = queryFormat;
            this.targetTableId = targetTableId;
            this.targetDefinitionValidationEntries = targetDefinitionValidationEntries;
        }

        @Override
        public String getQuery() {
            return String.format(queryFormat, targetTableId);
        }

        @Override
        public void visit(ResultSet resultSet) throws SQLException {
            TargetDefinitionValidationEntry targetDefinitionValidationEntry = new TargetDefinitionValidationEntry();
            targetDefinitionValidationEntry.observedTargetKeplerIdMismatchCount = resultSet.getInt(1);
            targetDefinitionValidationEntries.add(targetDefinitionValidationEntry);
        }
    }

    private static class TadReportVisitor implements DbVisitor {

        private final String queryFormat;
        private final Long tadReportId;
        private final List<TadReportEntry> tadReportEntries;

        public TadReportVisitor(String queryFormat, long tadReportId,
            List<TadReportEntry> tadReportEntries) {
            this.queryFormat = queryFormat;
            this.tadReportId = tadReportId;
            this.tadReportEntries = tadReportEntries;
        }

        @Override
        public String getQuery() {
            return String.format(queryFormat, tadReportId);
        }

        @Override
        public void visit(ResultSet resultSet) throws SQLException {
            TadReportEntry tadReportEntry = new TadReportEntry();

            tadReportEntry.averagePixelsPerTargetDef = resultSet.getInt("AVERAGE_PIXELS_PER_TARGET_DEF");
            tadReportEntry.cstmTrgsNoAptCnt = resultSet.getInt("CSTM_TRGS_NO_APT_CNT");
            tadReportEntry.mergedTargetCount = resultSet.getInt("MERGED_TARGET_COUNT");
            tadReportEntry.reportRejectedByCoaTargetCount = resultSet.getInt("REPORT_REJECTED_BY_COA");
            tadReportEntry.supermaskCount = resultSet.getInt("SUPERMASK_COUNT");
            tadReportEntry.msksSmlrThnAprtrCnt = resultSet.getInt("MSKS_SMLR_THN_APRTR_CNT");
            tadReportEntry.totalMaskCount = resultSet.getInt("TOTAL_MASK_COUNT");
            tadReportEntry.usedMaskCount = resultSet.getInt("USED_MASK_COUNT");
            tadReportEntry.exclusiveLowerBound = resultSet.getFloat("EXCLUSIVE_LOWER_BOUND");
            tadReportEntry.inclusiveUpperBound = resultSet.getFloat("INCLUSIVE_UPPER_BOUND");
            tadReportEntry.targetCount = resultSet.getInt("TARGET_COUNT");
            tadReportEntry.sigProcChainsCount = resultSet.getInt("SIG_PROC_CHAINS_ELEMENT");
            tadReportEntry.backgroundPixelCount = resultSet.getInt("BACKGROUND_PIXEL_COUNT");
            tadReportEntry.backgroundTargetDefCnt = resultSet.getInt("BACKGROUND_TARGET_DEF_CNT");
            tadReportEntry.dynamicRangePixelCount = resultSet.getInt("DYNAMIC_RANGE_PIXEL_COUNT");
            tadReportEntry.dynamicRangeTargetDefCnt = resultSet.getInt("DYNAMIC_RANGE_TARGET_DEF_CNT");
            tadReportEntry.excessPixelCount = resultSet.getInt("EXCESS_PIXEL_COUNT");
            tadReportEntry.leadingBlackPixelCount = resultSet.getInt("LEADING_BLACK_PIXEL_COUNT");
            tadReportEntry.leadingBlackTargetDefCnt = resultSet.getInt("LEADING_BLACK_TARGET_DEF_CNT");
            tadReportEntry.maskedSmearPixelCount = resultSet.getInt("MASKED_SMEAR_PIXEL_COUNT");
            tadReportEntry.maskedSmearTargetDefCnt = resultSet.getInt("MASKED_SMEAR_TARGET_DEF_CNT");
            tadReportEntry.stellarPixelCount = resultSet.getInt("STELLAR_PIXEL_COUNT");
            tadReportEntry.stellarTargetDefCnt = resultSet.getInt("STELLAR_TARGET_DEF_CNT");
            tadReportEntry.totalPixelCount = resultSet.getInt("TOTAL_PIXEL_COUNT");
            tadReportEntry.totalTargetDefCnt = resultSet.getInt("TOTAL_TARGET_DEF_CNT");
            tadReportEntry.trailingBlackPixelCount = resultSet.getInt("TRAILING_BLACK_PIXEL_COUNT");
            tadReportEntry.trailingBlackTargetDefCnt = resultSet.getInt("TRAILING_BLACK_TARGET_DEF_CNT");
            tadReportEntry.uniquePixelCount = resultSet.getInt("UNIQUE_PIXEL_COUNT");
            tadReportEntry.virtualSmearPixelCount = resultSet.getInt("VIRTUAL_SMEAR_PIXEL_COUNT");
            tadReportEntry.virtualSmearTargetDefCnt = resultSet.getInt("VIRTUAL_SMEAR_TARGET_DEF_CNT");
            tadReportEntry.labelCount = resultSet.getInt("LABEL_ELEMENT");
            tadReportEntry.mapkey = resultSet.getString("MAPKEY");
            tadReportEntries.add(tadReportEntry);
        }
    }

    private static class TadModOutReportVisitor implements DbVisitor {

        private final String queryFormat;
        private final Long tadReportId;
        private final List<TadModOutReportEntry> tadModOutReportEntries;

        public TadModOutReportVisitor(String queryFormat, long tadReportId,
            List<TadModOutReportEntry> tadModOutReportEntries) {
            this.queryFormat = queryFormat;
            this.tadReportId = tadReportId;
            this.tadModOutReportEntries = tadModOutReportEntries;
        }

        @Override
        public String getQuery() {
            return String.format(queryFormat, tadReportId);
        }

        @Override
        public void visit(ResultSet resultSet) throws SQLException {
            TadModOutReportEntry tadModOutReportEntry = new TadModOutReportEntry();

            tadModOutReportEntry.averagePixelsPerTargetDef = resultSet.getInt("AVERAGE_PIXELS_PER_TARGET_DEF");
            tadModOutReportEntry.cstmTrgsNoAptCnt = resultSet.getInt("CSTM_TRGS_NO_APT_CNT");
            tadModOutReportEntry.mergedTargetCount = resultSet.getInt("MERGED_TARGET_COUNT");
            tadModOutReportEntry.reportRejectedByCoaTargetCount = resultSet.getInt("REPORT_REJECTED_BY_COA");
            tadModOutReportEntry.supermaskCount = resultSet.getInt("SUPERMASK_COUNT");
            tadModOutReportEntry.msksSmlrThnAprtrCnt = resultSet.getInt("MSKS_SMLR_THN_APRTR_CNT");
            tadModOutReportEntry.totalMaskCount = resultSet.getInt("TOTAL_MASK_COUNT");
            tadModOutReportEntry.usedMaskCount = resultSet.getInt("USED_MASK_COUNT");
            tadModOutReportEntry.ccdModule = resultSet.getInt("CCD_MODULE");
            tadModOutReportEntry.ccdOutput = resultSet.getInt("CCD_OUTPUT");
            tadModOutReportEntry.modOutRejectedByCoaTargetCount = resultSet.getInt("MOD_OUT_REJECTED_BY_COA");
            tadModOutReportEntry.exclusiveLowerBound = resultSet.getFloat("EXCLUSIVE_LOWER_BOUND");
            tadModOutReportEntry.inclusiveUpperBound = resultSet.getFloat("INCLUSIVE_UPPER_BOUND");
            tadModOutReportEntry.targetCount = resultSet.getInt("TARGET_COUNT");
            tadModOutReportEntry.sigProcChainsCount = resultSet.getInt("SIG_PROC_CHAINS_ELEMENT");
            tadModOutReportEntry.backgroundPixelCount = resultSet.getInt("BACKGROUND_PIXEL_COUNT");
            tadModOutReportEntry.backgroundTargetDefCnt = resultSet.getInt("BACKGROUND_TARGET_DEF_CNT");
            tadModOutReportEntry.dynamicRangePixelCount = resultSet.getInt("DYNAMIC_RANGE_PIXEL_COUNT");
            tadModOutReportEntry.dynamicRangeTargetDefCnt = resultSet.getInt("DYNAMIC_RANGE_TARGET_DEF_CNT");
            tadModOutReportEntry.excessPixelCount = resultSet.getInt("EXCESS_PIXEL_COUNT");
            tadModOutReportEntry.leadingBlackPixelCount = resultSet.getInt("LEADING_BLACK_PIXEL_COUNT");
            tadModOutReportEntry.leadingBlackTargetDefCnt = resultSet.getInt("LEADING_BLACK_TARGET_DEF_CNT");
            tadModOutReportEntry.maskedSmearPixelCount = resultSet.getInt("MASKED_SMEAR_PIXEL_COUNT");
            tadModOutReportEntry.maskedSmearTargetDefCnt = resultSet.getInt("MASKED_SMEAR_TARGET_DEF_CNT");
            tadModOutReportEntry.stellarPixelCount = resultSet.getInt("STELLAR_PIXEL_COUNT");
            tadModOutReportEntry.stellarTargetDefCnt = resultSet.getInt("STELLAR_TARGET_DEF_CNT");
            tadModOutReportEntry.totalPixelCount = resultSet.getInt("TOTAL_PIXEL_COUNT");
            tadModOutReportEntry.totalTargetDefCnt = resultSet.getInt("TOTAL_TARGET_DEF_CNT");
            tadModOutReportEntry.trailingBlackPixelCount = resultSet.getInt("TRAILING_BLACK_PIXEL_COUNT");
            tadModOutReportEntry.trailingBlackTargetDefCnt = resultSet.getInt("TRAILING_BLACK_TARGET_DEF_CNT");
            tadModOutReportEntry.uniquePixelCount = resultSet.getInt("UNIQUE_PIXEL_COUNT");
            tadModOutReportEntry.virtualSmearPixelCount = resultSet.getInt("VIRTUAL_SMEAR_PIXEL_COUNT");
            tadModOutReportEntry.virtualSmearTargetDefCnt = resultSet.getInt("VIRTUAL_SMEAR_TARGET_DEF_CNT");
            tadModOutReportEntry.labelCount = resultSet.getInt("LABEL_ELEMENT");
            tadModOutReportEntry.mapkey = resultSet.getString("MAPKEY");
            tadModOutReportEntries.add(tadModOutReportEntry);
        }
    }

    private static class TadReportAlertsVisitor implements DbVisitor {

        private final String queryFormat;
        private final Long tadReportId;
        private final List<TadReportAlertEntry> tadReportAlertEntries;

        public TadReportAlertsVisitor(String queryFormat, long tadReportId,
            List<TadReportAlertEntry> tadReportAlertEntries) {
            this.queryFormat = queryFormat;
            this.tadReportId = tadReportId;
            this.tadReportAlertEntries = tadReportAlertEntries;
        }

        @Override
        public String getQuery() {
            return String.format(queryFormat, tadReportId);
        }

        @Override
        public void visit(ResultSet resultSet) throws SQLException {
            TadReportAlertEntry tadReportAlertEntry = new TadReportAlertEntry();

            tadReportAlertEntry.element = resultSet.getString("ELEMENT");
            tadReportAlertEntries.add(tadReportAlertEntry);
        }
    }
}
