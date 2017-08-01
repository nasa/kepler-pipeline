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

package gov.nasa.kepler.mr.scriptlet;

import static gov.nasa.kepler.mr.scriptlet.TadCcdModuleOutputScriptlet.REPORT_NAME_TAD_MODULE;
import static gov.nasa.kepler.mr.servlet.ReportViewerServlet.PARAM_FORMAT;
import static gov.nasa.kepler.mr.servlet.ReportViewerServlet.REPORT_URI_BASE;
import gov.nasa.kepler.common.Iso8601Formatter;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.tad.BadPixelRateBin;
import gov.nasa.kepler.hibernate.tad.TadModOutReport;
import gov.nasa.kepler.hibernate.tad.TadReport;
import gov.nasa.kepler.hibernate.tad.TargetDefinitionAndPixelCounts;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mr.ParameterUtil;

import java.text.DateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import net.sf.jasperreports.engine.JRDataSource;
import net.sf.jasperreports.engine.JRScriptletException;
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;

/**
 * This is the scriptlet class for the TAD Summary report.
 * 
 * @author Bill Wohler
 */
public class TadScriptlet extends BaseScriptlet {

    private static final Log log = LogFactory.getLog(TadScriptlet.class);

    public static final String REPORT_NAME_TAD_SUMMARY = "tad-summary";
    public static final String REPORT_TITLE_TAD_SUMMARY = "Target and Aperture Definitions Processing Summary";

    private static final String PARAM_TARGET_LIST_SET = "targetListSet";
    private static final String NOMINAL_OPERATIONS = "All operations nominal.";
    private static final String TABLE_NOT_AVAILABLE = "Table not available.";

    private static TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();

    /** Target list set, extracted from HTTP parameter. */
    protected TargetListSet targetListSet;

    /** Name of associated target list set (short cadence only). */
    protected String associatedTargetListSetName;

    /** Target table from selected target list set. */
    protected TargetTable targetTable;

    /** Background table from selected target list set. */
    protected TargetTable backgroundTable;

    @Override
    public void afterReportInit() throws JRScriptletException {
        super.afterReportInit();

        // Grab target list set from parameters.
        String targetListSetString = getRequestParameter(PARAM_TARGET_LIST_SET,
            String.format(ParameterUtil.MISSING_PARAM_ERROR_TEXT,
                PARAM_TARGET_LIST_SET));
        log.debug("targetListSet=" + targetListSetString);
        if (targetListSetString == null) {
            return;
        }

        // Retrieve the target list set and extract target and background
        // tables.
        try {
            targetTable = null;
            backgroundTable = null;

            targetListSet = targetSelectionCrud.retrieveTargetListSet(targetListSetString);
            if (targetListSet == null) {
                String text = String.format(
                    "Target list set %s not in database.", targetListSetString);
                setErrorText(text);
                log.error(text);
                return;
            }

            targetTable = targetListSet.getTargetTable();
            if (targetTable == null || targetTable.getTadReport() == null) {
                String text = String.format(
                    "TAD target table report unavailable for %s.",
                    targetListSetString);
                setErrorText(text);
                log.error(text);
            }

            switch (targetListSet.getType()) {
                case LONG_CADENCE:
                    backgroundTable = targetListSet.getBackgroundTable();
                    break;
                case SHORT_CADENCE:
                    if (targetListSet.getAssociatedLcTls() != null) {
                        backgroundTable = targetListSet.getAssociatedLcTls()
                            .getBackgroundTable();
                        associatedTargetListSetName = targetListSet.getAssociatedLcTls()
                            .getName();
                    } else {
                        String text = String.format(
                            "Target list set associated with %s unavailable.",
                            targetListSetString);
                        setWarningText(text);
                        log.warn(text);
                    }
                    break;
                default:
                    break;
            }

            if (backgroundTable != null) {
                if (backgroundTable.getTadReport() == null) {
                    String text = String.format(
                        "TAD background table report unavailable for %s.",
                        targetListSetString);
                    setErrorText(text);
                    log.error(text);
                }
            } else if (targetListSet.getType() != TargetType.REFERENCE_PIXEL
                && getWarningText() == null) {
                String text = String.format(
                    "TAD background table unavailable for %s.",
                    targetListSetString);
                setWarningText(text);
                log.warn(text);
            }
        } catch (HibernateException e) {
            String text = "Could not obtain target list set "
                + targetListSetString + ": ";
            setErrorText(text + e + "\nCause: " + e.getCause());
            log.error(text, e);
            return;
        }
    }

    /**
     * Returns a {@link JRDataSource} which wraps the {@link TargetListSet}
     * information.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource targetListSetDataSource() throws JRScriptletException {
        log.debug("Filling data source for " + targetListSet);

        List<KeyValuePair> list = new ArrayList<KeyValuePair>();
        if (targetListSet == null) {
            log.error("Should not be called if target list set unavailable");
            return new JRBeanCollectionDataSource(list);
        }

        DateFormat dateFormat = Iso8601Formatter.dateFormatter();

        list.add(new KeyValuePair("Type", targetListSet.getType()
            .toString()));
        list.add(new KeyValuePair("State", targetListSet.getState()
            .toString()));
        list.add(new KeyValuePair("Start",
            dateFormat.format(targetListSet.getStart())));
        list.add(new KeyValuePair("End",
            dateFormat.format(targetListSet.getEnd())));

        return new JRBeanCollectionDataSource(list);
    }

    /**
     * Returns a {@link JRDataSource} which wraps the {@link TargetList}
     * information.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource targetListDataSource() throws JRScriptletException {
        log.debug("Filling target list data source for " + targetListSet);

        List<TargetListFacade> list = new ArrayList<TargetListFacade>();
        if (targetListSet == null) {
            log.error("Should not be called if target list set unavailable");
            return new JRBeanCollectionDataSource(list);
        }

        appendTargetLists(list, targetListSet.getTargetLists());

        return new JRBeanCollectionDataSource(list);
    }

    /**
     * Returns a {@link JRDataSource} which wraps the {@link TargetList}
     * information for excluded targets.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource excludedTargetListDataSource()
        throws JRScriptletException {
        log.debug("Filling excluded target list data source for "
            + targetListSet);

        List<TargetListFacade> list = new ArrayList<TargetListFacade>();
        if (targetListSet == null) {
            log.error("Should not be called if target list set unavailable");
            return new JRBeanCollectionDataSource(list);
        }

        appendTargetLists(list, targetListSet.getExcludedTargetLists());

        return new JRBeanCollectionDataSource(list);
    }

    /**
     * Creates {@code TargetListFacade}s for each target list and appends those
     * objects to the given list.
     * 
     * @param list the list of {@code TargetListFacade}s to fill
     * @param targetLists the list of {@code TargetList}s
     * @throws NullPointerException if list is {@code null}
     */
    private void appendTargetLists(List<TargetListFacade> list,
        List<TargetList> targetLists) {

        int targetCount = 0;
        for (TargetList targetList : targetLists) {
            TargetListFacade targetListData = targetListData(targetList);
            targetCount += targetListData.getTargetCountAsInt();
            list.add(targetListData);
        }

        // Only append totals if there are target lists to total.
        if (targetLists.size() > 0) {
            list.add(new TargetListFacade("Total Number of Targets",
                targetCount));
        }
    }

    /**
     * Returns a {@link TargetListFacade} which wraps the given
     * {@link TargetList}.
     * 
     * @return a non-{@code null} target list
     * @throws NullPointerException if {@code targetList} is {@code null}
     */
    private TargetListFacade targetListData(TargetList targetList) {
        int targetCount = targetCount(targetList);

        return new TargetListFacade(targetList, targetCount);
    }

    /**
     * Returns the target count of the given target list.
     * 
     * @param targetList a non-{@code null} target lists
     * @return the number of targets, or -1 if there was an error accessing the
     * count
     * @throws NullPointerException if {@code targetList} is {@code null}
     */
    private int targetCount(TargetList targetList) {
        try {
            return targetSelectionCrud.plannedTargetCount(targetList);
        } catch (HibernateException e) {
            log.error("Could not obtain number of targets in target list "
                + targetList.getName(), e);
        }

        return -1;
    }

    /**
     * Returns a {@link JRDataSource} which wraps the {@link TadReport} for the
     * current target table.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource targetTableDataSource() throws JRScriptletException {
        if (targetTable == null || targetTable.getTadReport() == null) {
            log.error("Should not be called if TAD report unavailable");
        }

        return dataSource(targetTable);
    }

    /**
     * Returns a {@link JRDataSource} which wraps the {@link TadReport} for the
     * current background target table.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource backgroundTableDataSource() throws JRScriptletException {
        // Short cadences don't have background tables, so not an error in
        // that case.

        return dataSource(backgroundTable);
    }

    /**
     * Returns a {@link JRDataSource} which wraps the {@link TadReport} for the
     * current target table.
     * 
     * @param targetTable the target table to display
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    private JRDataSource dataSource(TargetTable targetTable)
        throws JRScriptletException {

        log.debug("Filling data source for " + targetListSet);

        List<KeyValuePair> list = new ArrayList<KeyValuePair>();
        if (targetTable == null) {
            return new JRBeanCollectionDataSource(list);
        }

        TadReport tadReport = targetTable.getTadReport();
        if (tadReport == null) {
            return new JRBeanCollectionDataSource(list);
        }

        list.add(new KeyValuePair("Total Number of Unique Targets",
            String.format("%,d", tadReport.getMergedTargetCount())));
        list.add(new KeyValuePair("Number of Targets Rejected by COA",
            String.format("%,d", tadReport.getRejectedByCoaTargetCount())));

        for (BadPixelRateBin badPixelRateBin : tadReport.getBadPixelRateBins()) {
            if (badPixelRateBin.getInclusiveUpperBoundForBadPixelRate() <= 0.0) {
                list.add(new KeyValuePair(
                    "Number of Targets With No Bad Pixels", String.format(
                        "%,d", badPixelRateBin.getTargetCount())));
            } else {
                list.add(new KeyValuePair(
                    String.format(
                        "Number of Targets With Bad Pixels (%d%% - %d%%]",
                        (int) (badPixelRateBin.getExclusiveLowerBoundForBadPixelRate() * 100),
                        (int) (badPixelRateBin.getInclusiveUpperBoundForBadPixelRate() * 100)),
                    String.format("%,d", badPixelRateBin.getTargetCount())));
            }
        }

        list.add(new KeyValuePair(
            "Signal Processing Chains Without Target Definitions",
            String.format("%,d", tadReport.getMissingSignalProcessingChains()
                .size())));
        list.add(new KeyValuePair("Total Number of Used Target Aperture Masks",
            String.format("%,d", tadReport.getUsedMaskCount())));
        list.add(new KeyValuePair("Total Number of Target Aperture Masks",
            String.format("%,d", tadReport.getTotalMaskCount())));
        list.add(new KeyValuePair("Average Number of Pixels/Target Definition",
            String.format("%.3f", tadReport.getAveragePixelsPerTargetDef())));
        list.add(new KeyValuePair(
            "Total Number of Targets With No Aperture Mask", String.format(
                "%,d", tadReport.getCustomTargetsWithNoApertureCount())));
        list.add(new KeyValuePair(
            "Total Number of Targets With Aperture Mask Smaller Than Optimal Aperture",
            String.format("%,d",
                tadReport.getTargetsWithMasksSmallerThanOptimalApertureCount())));
        list.add(new KeyValuePair("Total Number of Aperture Supermasks",
            String.format("%,d", tadReport.getSupermaskCount())));

        String s = NO_DATA;
        if (targetTable.getExternalId() != ExportTable.INVALID_EXTERNAL_ID) {
            s = String.format("%,d", targetTable.getExternalId());
        }
        list.add(new KeyValuePair("Target Table ID", s));
        list.add(new KeyValuePair("Target Database ID", String.format("%,d",
            targetTable.getId())));
        s = NO_DATA;
        if (targetTable.getMaskTable()
            .getExternalId() != ExportTable.INVALID_EXTERNAL_ID) {
            s = String.format("%,d", targetTable.getMaskTable()
                .getExternalId());
        }
        list.add(new KeyValuePair("Aperture Table ID", s));
        list.add(new KeyValuePair("Aperture Database ID", String.format("%,d",
            targetTable.getMaskTable()
                .getId())));

        return new JRBeanCollectionDataSource(list);
    }

    /**
     * Returns a {@link JRDataSource} which wraps the target count portion of
     * the {@link TargetDefinitionAndPixelCounts} object for the current target
     * table.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource targetTableTargetCountDataSource()
        throws JRScriptletException {

        if (targetTable == null || targetTable.getTadReport() == null) {
            log.error("Should not be called if TAD report unavailable");
        }

        return targetCountDataSource(targetTable);
    }

    /**
     * Returns a {@link JRDataSource} which wraps the target count portion of
     * the {@link TargetDefinitionAndPixelCounts} object for the current
     * background target table.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource backgroundTableTargetCountDataSource()
        throws JRScriptletException {

        // Short cadences don't have background tables, so not an error in
        // that case.

        return targetCountDataSource(backgroundTable);
    }

    /**
     * Returns a {@link JRDataSource} which wraps the target count portion of
     * the {@link TargetDefinitionAndPixelCounts} object for the current target
     * table.
     * 
     * @param targetTable the target table to display
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    private JRDataSource targetCountDataSource(TargetTable targetTable)
        throws JRScriptletException {

        log.debug("Filling target count data source for " + targetListSet);

        List<KeyValuePair> list = new ArrayList<KeyValuePair>();
        if (targetTable == null || targetTable.getTadReport() == null) {
            return new JRBeanCollectionDataSource(list);
        }

        TargetDefinitionAndPixelCounts counts = getCounts(targetTable.getTadReport());
        if (counts == null) {
            return new JRBeanCollectionDataSource(list);
        }

        if (targetTable.getType() == TargetType.REFERENCE_PIXEL) {
            list.add(new KeyValuePair("Stellar Target Definitions",
                String.format("%,d", counts.getStellarTargetDefCount())));
            list.add(new KeyValuePair("Dynamic Range Target Definitions",
                String.format("%,d", counts.getDynamicRangeTargetDefCount())));
            list.add(new KeyValuePair("Background Target Definitions",
                String.format("%,d", counts.getBackgroundTargetDefCount())));
            list.add(new KeyValuePair("Leading Black Target Definitions",
                String.format("%,d", counts.getLeadingBlackTargetDefCount())));
            list.add(new KeyValuePair("Trailing Black Target Definitions",
                String.format("%,d", counts.getTrailingBlackTargetDefCount())));
            list.add(new KeyValuePair("Masked Smear Target Definitions",
                String.format("%,d", counts.getMaskedSmearTargetDefCount())));
            list.add(new KeyValuePair("Virtual Smear Target Definitions",
                String.format("%,d", counts.getVirtualSmearTargetDefCount())));
        }

        list.add(new KeyValuePair("Total Target Definitions", String.format(
            "%,d", counts.getTotalTargetDefCount())));

        return new JRBeanCollectionDataSource(list);
    }

    /**
     * Returns a {@link JRDataSource} which wraps the pixel count portion of the
     * {@link TargetDefinitionAndPixelCounts} object for the current target
     * table.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource targetTablePixelCountDataSource()
        throws JRScriptletException {

        if (targetTable == null || targetTable.getTadReport() == null) {
            log.error("Should not be called if TAD report unavailable");
        }

        return pixelCountDataSource(targetTable);
    }

    /**
     * Returns a {@link JRDataSource} which wraps the pixel count portion of the
     * {@link TargetDefinitionAndPixelCounts} object for the current background
     * target table.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource backgroundTablePixelCountDataSource()
        throws JRScriptletException {

        // Short cadences don't have background tables, so not an error in
        // that case.

        return pixelCountDataSource(backgroundTable);
    }

    /**
     * Returns a {@link JRDataSource} which wraps the pixel count portion of the
     * {@link TargetDefinitionAndPixelCounts} object for the current target
     * table.
     * 
     * @param targetTable the target table to display
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    private JRDataSource pixelCountDataSource(TargetTable targetTable)
        throws JRScriptletException {

        log.debug("Filling pixel count data source for " + targetListSet);

        List<KeyValuePair> list = new ArrayList<KeyValuePair>();
        if (targetTable == null || targetTable.getTadReport() == null) {
            return new JRBeanCollectionDataSource(list);
        }

        TargetDefinitionAndPixelCounts counts = getCounts(targetTable.getTadReport());
        if (counts == null) {
            return new JRBeanCollectionDataSource(list);
        }

        if (targetTable.getType() == TargetType.REFERENCE_PIXEL) {
            list.add(new KeyValuePair("Stellar Pixels", String.format("%,d",
                counts.getStellarPixelCount())));
            list.add(new KeyValuePair("Dynamic Range Pixels", String.format(
                "%,d", counts.getDynamicRangePixelCount())));
            list.add(new KeyValuePair("Background Pixels", String.format("%,d",
                counts.getBackgroundPixelCount())));
        }

        list.add(new KeyValuePair("Leading Black Pixels", String.format("%,d",
            counts.getLeadingBlackPixelCount())));
        list.add(new KeyValuePair("Trailing Black Pixels", String.format("%,d",
            counts.getTrailingBlackPixelCount())));
        list.add(new KeyValuePair("Masked Smear Pixels", String.format("%,d",
            counts.getMaskedSmearPixelCount())));
        list.add(new KeyValuePair("Virtual Smear Pixels", String.format("%,d",
            counts.getVirtualSmearPixelCount())));
        list.add(new KeyValuePair("Excess Pixels", String.format("%,d",
            counts.getExcessPixelCount())));
        list.add(new KeyValuePair("Total Unique Pixels", String.format("%,d",
            counts.getUniquePixelCount())));
        list.add(new KeyValuePair("Total Pixels", String.format("%,d",
            counts.getTotalPixelCount())));

        return new JRBeanCollectionDataSource(list);
    }

    /**
     * Returns a {@link JRDataSource} which wraps the label count portion of the
     * {@link TargetDefinitionAndPixelCounts} object for the current target
     * table.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource targetTableLabelCountDataSource()
        throws JRScriptletException {

        if (targetTable == null || targetTable.getTadReport() == null) {
            log.error("Should not be called if TAD report unavailable");
        }

        return labelCountDataSource(targetTable);
    }

    /**
     * Returns a {@link JRDataSource} which wraps the label count portion of the
     * {@link TargetDefinitionAndPixelCounts} object for the current background
     * target table.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource backgroundTableLabelCountDataSource()
        throws JRScriptletException {

        // Short cadences don't have background tables, so not an error in
        // that case.

        return labelCountDataSource(backgroundTable);
    }

    /**
     * Returns a {@link JRDataSource} which wraps the pixel count portion of the
     * {@link TargetDefinitionAndPixelCounts} object for the current target
     * table.
     * 
     * @param targetTable the target table to display
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    private JRDataSource labelCountDataSource(TargetTable targetTable)
        throws JRScriptletException {

        log.debug("Filling label count data source for " + targetListSet);

        List<KeyValuePair> list = new ArrayList<KeyValuePair>();
        if (targetTable == null || targetTable.getTadReport() == null
            || getCounts(targetTable.getTadReport()) == null) {
            return new JRBeanCollectionDataSource(list);
        }

        Map<String, Integer> labelCounts = getCounts(targetTable.getTadReport()).getLabelCounts();
        if (labelCounts == null) {
            return new JRBeanCollectionDataSource(list);
        }
        
        Set<String> labels = new TreeSet<String>();
        for (String label : labelCounts.keySet()) {
            labels.add(label);
        }
        
        for (String label : labels) {
            list.add(new KeyValuePair(label, String.format("%,d",
                labelCounts.get(label))));
        }

        return new JRBeanCollectionDataSource(list);
    }

    /**
     * Returns the {@link TargetDefinitionAndPixelCounts} object for the given
     * {@link TadReport}.
     * 
     * @param tadReport the {@link TadReport} that contains the
     * {@link TargetDefinitionAndPixelCounts} object
     * @return a {@link TargetDefinitionAndPixelCounts} object, or {@code null}
     * if unavailable
     */
    protected TargetDefinitionAndPixelCounts getCounts(TadReport tadReport) {
        return tadReport.getTargetDefinitionAndPixelCounts();
    }

    /**
     * Returns a numbered set of errors for the current target table. If there
     * aren't any errors, "All operations nominal" is returned.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource targetTableErrorsDataSource() {
        List<KeyValuePair> list = new ArrayList<KeyValuePair>();
        if (targetTable == null || targetTable.getTadReport() == null) {
            log.error("Should not be called if TAD report unavailable");
            return new JRBeanCollectionDataSource(list);
        }

        log.debug("Filling target table errors data source for "
            + targetListSet);
        appendListToKeyValuePairs(targetTable.getTadReport()
            .getErrors(), list, NOMINAL_OPERATIONS);

        return new JRBeanCollectionDataSource(list);
    }

    /**
     * Returns a numbered set of errors for the current background table. If
     * there aren't any errors, "All operations nominal" is returned.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource backgroundTableErrorsDataSource() {
        log.debug("Filling background table errors data source for "
            + targetListSet);

        List<KeyValuePair> list = new ArrayList<KeyValuePair>();

        if (backgroundTable == null) {
            list.add(new KeyValuePair(TABLE_NOT_AVAILABLE));
        } else if (backgroundTable.getTadReport() == null) {
            log.error("Should not be called if TAD report unavailable");
        } else {
            appendListToKeyValuePairs(backgroundTable.getTadReport()
                .getErrors(), list, NOMINAL_OPERATIONS);
        }

        return new JRBeanCollectionDataSource(list);
    }

    /**
     * Returns a numbered set of warnings for the current target table. If there
     * aren't any warnings, "All operations nominal" is returned.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource targetTableWarningsDataSource() {
        List<KeyValuePair> list = new ArrayList<KeyValuePair>();
        if (targetTable == null || targetTable.getTadReport() == null) {
            log.error("Should not be called if TAD report unavailable");
            return new JRBeanCollectionDataSource(list);
        }

        log.debug("Filling target table warnings data source for "
            + targetListSet);
        appendListToKeyValuePairs(targetTable.getTadReport()
            .getWarnings(), list, NOMINAL_OPERATIONS);

        return new JRBeanCollectionDataSource(list);
    }

    /**
     * Returns a numbered set of warnings for the current background table. If
     * there aren't any warnings, "All operations nominal" is returned.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource backgroundTableWarningsDataSource() {
        log.debug("Filling background table warnings data source for "
            + targetListSet);

        List<KeyValuePair> list = new ArrayList<KeyValuePair>();

        if (backgroundTable == null) {
            list.add(new KeyValuePair(TABLE_NOT_AVAILABLE));
        } else if (backgroundTable.getTadReport() == null) {
            log.error("Should not be called if TAD report unavailable");
        } else {
            appendListToKeyValuePairs(backgroundTable.getTadReport()
                .getWarnings(), list, NOMINAL_OPERATIONS);
        }

        return new JRBeanCollectionDataSource(list);
    }

    /**
     * Converts a list of strings into a list of key/value pairs (without the
     * key). The original strings are numbered. If there aren't any strings,
     * then the default parameter is used.
     * 
     * @param strings a list of strings. If {@code null} or empty, then
     * {@code defaultString} is used
     * @param list a non-{@code null} list of {@link KeyValuePair}s
     * @param defaultString
     * @throws NullPointerException if {@code list} is {@code null}
     */
    private void appendListToKeyValuePairs(List<String> strings,
        List<KeyValuePair> list, String defaultString) {

        if (strings == null || strings.size() == 0) {
            list.add(new KeyValuePair(defaultString));
        } else {
            int count = 1;
            for (String string : strings) {
                list.add(new KeyValuePair(String.format("%d. %s", count++,
                    string)));
            }
        }
    }

    /**
     * Returns a {@link JRDataSource} which summarizes the
     * {@code TadModOutReport} object in the the {@link TadReport} object for
     * the current target table.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource targetTableCcdModuleOutputSummaryDataSource() {
        if (targetTable == null || targetTable.getTadReport() == null) {
            log.error("Should not be called if TAD report unavailable");
        }

        return ccdModuleOutputSummaryDataSource(targetTable);
    }

    /**
     * Returns a {@link JRDataSource} which summarizes the
     * {@code TadModOutReport} object in the the {@link TadReport} object for
     * the current background target table.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource backgroundTableCcdModuleOutputSummaryDataSource() {
        // Short cadences don't have background tables, so not an error in
        // that case.

        return ccdModuleOutputSummaryDataSource(backgroundTable);
    }

    /**
     * Returns a {@link JRDataSource} which summarizes the
     * {@code TadModOutReport} object in the the {@link TadReport} object for
     * the given target table.
     * 
     * @param targetTable the target table to display
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    private JRDataSource ccdModuleOutputSummaryDataSource(
        TargetTable targetTable) {

        List<TadModOutReportFacade> list = new ArrayList<TadModOutReportFacade>();
        if (targetTable == null || targetTable.getTadReport() == null) {
            return new JRBeanCollectionDataSource(list);
        }

        log.debug("Filling CCD module/output summary data source for "
            + targetListSet);

        TadReport tadReport = targetTable.getTadReport();
        for (TadModOutReport tadModOutReport : tadReport.getModOutReports()) {
            list.add(new TadModOutReportFacade(tadModOutReport));
        }

        return new JRBeanCollectionDataSource(list);
    }

    /**
     * Returns the type of the target list set.
     */
    public TargetType getType() {
        return targetListSet.getType();
    }

    /**
     * Returns the name of the associated target list set.
     * 
     * @return the name of the associated target list set if the type of the
     * target list is {@link TargetType#SHORT_CADENCE}; otherwise, {@code null}
     * is returned
     */
    public String getAssociatedTargetListSetName() {
        return associatedTargetListSetName;
    }

    /**
     * Returns the pipeline instance ID.
     */
    public long getPipelineInstanceId() {
        return targetTable.getTadReport()
            .getPipelineTask()
            .getPipelineInstance()
            .getId();
    }

    /**
     * A value-added facade to the {@link TargetList} object. A
     * {@code targetCount} of less than 0 indicates an error retrieving the
     * number of targets and "Error: see log" is displayed in that column.
     * 
     * @author Bill Wohler
     */
    public static class TargetListFacade {
        private String name;
        private int targetCount;
        private String source = NO_DATA;

        public TargetListFacade(TargetList targetList, int targetCount) {
            name = targetList.getName();
            this.targetCount = targetCount;
            source = targetList.getSource();
        }

        public TargetListFacade(String label, int targetCount) {
            name = label;
            this.targetCount = targetCount;
        }

        public String getName() {
            return name;
        }

        public int getTargetCountAsInt() {
            return targetCount;
        }

        public String getTargetCount() {
            return targetCount >= 0 ? String.format("%,d", targetCount)
                : "Error: see log";
        }

        public String getSource() {
            return source;
        }
    }

    /**
     * A value-added facade to the {@link TadModOutReport} object.
     * 
     * @author Bill Wohler
     */
    public class TadModOutReportFacade {
        private TadModOutReport tadModOutReport;

        public TadModOutReportFacade(TadModOutReport tadModOutReport) {
            this.tadModOutReport = tadModOutReport;
        }

        public String getCcdModuleOutput() {
            return String.format("%02d/%d", tadModOutReport.getCcdModule(),
                tadModOutReport.getCcdOutput());
        }

        public String getCcdModuleOutputUrl() {
            String format = ((String[]) getGenerationParameters().get(
                PARAM_FORMAT))[0];
            String moduleOutputUrl = new StringBuilder().append(getServerUrl())
                .append(REPORT_URI_BASE)
                .append("/")
                .append(REPORT_NAME_TAD_MODULE)
                .append('?')
                .append(PARAM_TARGET_LIST_SET)
                .append('=')
                .append(targetListSet.getName())
                .append('&')
                .append(PARAM_MODULE_OUTPUT)
                .append('=')
                .append(getCcdModuleOutput())
                .append('&')
                .append(PARAM_FORMAT)
                .append('=')
                .append(format)
                .toString();

            return moduleOutputUrl;
        }

        public String getTotalTargetCount() {
            return String.format("%,d",
                tadModOutReport.getTargetDefinitionAndPixelCounts()
                    .getTotalTargetDefCount());
        }

        public String getRejectedByCoaTargetCount() {
            return String.format("%,d",
                tadModOutReport.getRejectedByCoaTargetCount());
        }

        public String getTotalPixelCount() {
            return String.format("%,7d",
                tadModOutReport.getTargetDefinitionAndPixelCounts()
                    .getTotalPixelCount());
        }
    }
}
