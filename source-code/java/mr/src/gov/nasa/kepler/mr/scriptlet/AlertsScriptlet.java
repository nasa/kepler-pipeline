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

import gov.nasa.kepler.hibernate.services.Alert;
import gov.nasa.kepler.hibernate.services.AlertLog;
import gov.nasa.kepler.hibernate.services.AlertLogCrud;
import gov.nasa.kepler.mr.ParameterUtil;
import gov.nasa.kepler.mr.webui.AlertsUtil;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import net.sf.jasperreports.engine.JRDataSource;
import net.sf.jasperreports.engine.JRScriptletException;
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;

/**
 * This is the scriptlet class for the Alerts report.
 * 
 * @author Bill Wohler
 */
public class AlertsScriptlet extends BaseScriptlet {

    private static final Log log = LogFactory.getLog(AlertsScriptlet.class);

    public static final String REPORT_NAME_ALERTS = "alerts";
    public static final String REPORT_TITLE_ALERTS = "Alerts";

    private static final String PARAM_COMPONENTS = "components";
    private static final String PARAM_SEVERITIES = "severities";

    private static AlertLogCrud alertLogCrud = new AlertLogCrud();

    private List<String> severities;
    private List<AlertLog> alertLogs;

    @Override
    public void afterReportInit() throws JRScriptletException {
        super.afterReportInit();

        // Initialize start and end times.
        expectStartEndTimeParameters();
        if (getStartTime() == null || getEndTime() == null) {
            return;
        }

        // Grab components from parameters.
        String components[] = getRequestParameters(PARAM_COMPONENTS,
            String.format(ParameterUtil.MISSING_PARAM_ERROR_TEXT,
                PARAM_COMPONENTS));
        if (components == null) {
            return;
        }
        if (log.isDebugEnabled()) {
            if (components.length > 0) {
                log.debug("components[" + components.length + "]="
                    + components[0] + ", ...");
            } else {
                log.debug("components[" + components.length + "]");
            }
        }

        // Grab severity from parameters.
        String[] severities = getRequestParameters(PARAM_SEVERITIES,
            String.format(ParameterUtil.MISSING_PARAM_ERROR_TEXT,
                PARAM_SEVERITIES));
        if (severities == null) {
            return;
        }
        if (log.isDebugEnabled()) {
            if (severities.length > 0) {
                log.debug("severity[" + severities.length + "]="
                    + severities[0] + ", ...");
            } else {
                log.debug("severity[" + severities.length + "]");
            }
        }
        this.severities = Arrays.asList(severities);

        try {
            alertLogs = alertLogCrud.retrieve(getStartTime(), getEndTime(),
                components, severities);

            if (alertLogs.size() == 0) {
                String text = String.format(
                    "No alerts received from %s to %s.",
                    getDateFormatter().format(getStartTime()),
                    getDateFormatter().format(getEndTime()));
                setErrorText(text);
                log.error(text);
            }
        } catch (HibernateException e) {
            String text = "Could not obtain alerts from "
                + getDateFormatter().format(getStartTime()) + " to "
                + getDateFormatter().format(getEndTime()) + ": ";
            setErrorText(text + e + "\nCause: " + e.getCause());
            log.error(text, e);
            return;
        }
    }

    /**
     * Returns a {@link JRDataSource} which wraps all of the {@link AlertLog}s
     * for the current time range.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource alertsDataSource() throws JRScriptletException {

        log.debug("Filling data source for chosen severities");

        List<SeverityFacade> list = new ArrayList<SeverityFacade>();
        if (alertLogs == null) {
            log.error("Should not be called if alerts unavailable");
            return new JRBeanCollectionDataSource(list);
        }

        for (String severity : AlertsUtil.sortSeveritiesBySeverity(severities)) {
            list.add(new SeverityFacade(severity));
        }

        return new JRBeanCollectionDataSource(list);
    }

    /**
     * Returns a {@link JRDataSource} which wraps all of the {@link AlertLog}s
     * for the current time range at the given severity.
     * 
     * @param severity the severity of the alerts which should be included
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource alertsDataSource(String severity)
        throws JRScriptletException {

        log.debug("Filling data source for all alerts");

        List<AlertFacade> list = new ArrayList<AlertFacade>();
        if (alertLogs == null) {
            log.error("Should not be called if alerts unavailable");
            return new JRBeanCollectionDataSource(list);
        }

        for (AlertLog alertLog : alertLogs) {
            if (alertLog.getAlertData()
                .getSeverity()
                .equalsIgnoreCase(severity)) {
                list.add(new AlertFacade(alertLog.getAlertData()));
            }
        }

        return new JRBeanCollectionDataSource(list);
    }

    /**
     * A value-added facade to the given severity string.
     * 
     * @author Bill Wohler
     */
    public static class SeverityFacade {
        private String severity;

        public SeverityFacade(String severity) {
            this.severity = severity;
        }

        public String getSeverity() {
            return severity;
        }
    }

    /**
     * A value-added facade to the {@link Alert} object.
     * 
     * @author Bill Wohler
     */
    public class AlertFacade {
        private Alert alert;

        public AlertFacade(Alert alert) {
            this.alert = alert;
        }

        public String getTime() {
            return getDateFormatter().format(alert.getTimestamp());
        }

        public String getSource() {
            return alert.getSourceComponent();
        }

        public long getTaskId() {
            return alert.getSourceTaskId();
        }

        public String getMessage() {
            return alert.getMessage();
        }
    }
}
