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

import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.ReceiveLog;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.mr.ParameterUtil;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import net.sf.jasperreports.engine.JRDataSource;
import net.sf.jasperreports.engine.JRScriptletException;
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource;

import org.apache.commons.lang.time.DurationFormatUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;

/**
 * This is the scriptlet class for the Data Receipt Summary report.
 * 
 * @author Bill Wohler
 */
public class DrScriptlet extends BaseScriptlet {

    private static final Log log = LogFactory.getLog(DrScriptlet.class);

    public static final String REPORT_NAME_DR_SUMMARY = "dr-summary";
    public static final String REPORT_TITLE_DR_SUMMARY = "Data Receipt";

    private static final String PARAM_TYPE = "types";
    private static final String PARAM_STATE = "states";

    private static LogCrud logCrud = new LogCrud();

    private List<ReceiveLog> receiveLogs;

    @Override
    public void afterReportInit() throws JRScriptletException {
        super.afterReportInit();

        expectStartEndTimeParameters();
        expectSortByParameter();
        expectSortOrderParameter();
        if (getStartTime() == null || getEndTime() == null
            || getSortBy() == null || getSortAscending() == null) {
            return;
        }

        // Grab state and type from parameters.
        String stateStrings[] = getRequestParameters(PARAM_STATE,
            String.format(ParameterUtil.MISSING_PARAM_ERROR_TEXT, PARAM_STATE));
        String typeStrings[] = getRequestParameters(PARAM_TYPE, String.format(
            ParameterUtil.MISSING_PARAM_ERROR_TEXT, PARAM_TYPE));

        if (stateStrings == null || typeStrings == null) {
            log.debug("stateStrings=" + stateStrings);
            log.debug("types=" + typeStrings);
            return;
        }
        if (log.isDebugEnabled()) {
            if (stateStrings.length > 0) {
                log.debug("states[" + stateStrings.length + "]="
                    + stateStrings[0] + ", ...");
            } else {
                log.debug("states[" + stateStrings.length + "]");
            }
            if (typeStrings.length > 0) {
                log.debug("types[" + typeStrings.length + "]=" + typeStrings[0]
                    + ", ...");
            } else {
                log.debug("types[" + typeStrings.length + "]");
            }
        }

        Set<String> types = new HashSet<String>();
        Collection<String> allMessageTypes = getAllMessageTypes();
        if (allMessageTypes != null
            && typeStrings.length != allMessageTypes.size()) {
            for (String typeString : typeStrings) {
                types.add(typeString.toUpperCase());
                types.add(typeString.toLowerCase());
            }
        }

        Set<ReceiveLog.State> states = new HashSet<ReceiveLog.State>();
        if (stateStrings.length != ReceiveLog.State.values().length) {
            states = convertToEnum(stateStrings);
        }

        log.debug("states size: " + states.size());
        log.debug("types size: " + types.size());

        try {
            receiveLogs = logCrud.retrieveReceiveLogs(getStartTime(),
                getEndTime(), getSortBy(), states, types,
                getSortAscending() != null ? getSortAscending().booleanValue()
                    : true);

            if (receiveLogs.size() == 0) {
                String text = String.format(
                    "No notification messages received from %s to %s.",
                    getDateFormatter().format(getStartTime()),
                    getDateFormatter().format(getEndTime()));
                setErrorText(text);
                log.error(text);
            }
        } catch (HibernateException e) {
            String text = "Could not obtain notification messages from "
                + getDateFormatter().format(getStartTime()) + " to "
                + getDateFormatter().format(getEndTime()) + ": ";
            setErrorText(text + e + "\nCause: " + e.getCause());
            log.error(text, e);
            return;
        }
    }

    /**
     * Returns a {@link JRDataSource} which wraps all of the {@link ReceiveLog}s
     * for the current time range.
     * 
     * @return a non-{@code null} data source.
     * @throws JRScriptletException if the data source could not be created.
     */
    public JRDataSource receiveLogsDataSource() throws JRScriptletException {

        log.debug("Filling data source for all receive logs");

        List<ReceiveLogFacade> list = new ArrayList<ReceiveLogFacade>();
        if (receiveLogs == null) {
            log.error("Should not be called if notification messages unavailable");
            return new JRBeanCollectionDataSource(list);
        }

        for (ReceiveLog receiveLog : receiveLogs) {
            list.add(new ReceiveLogFacade(receiveLog));
        }

        return new JRBeanCollectionDataSource(list);
    }

    /**
     * Returns a {@link JRDataSource} which wraps the {@link ReceiveLog} with
     * the given ID.
     * 
     * @return a non-{@code null} data source.
     * @throws JRScriptletException if the data source could not be created.
     */
    public JRDataSource receiveLogDataSource(long id)
        throws JRScriptletException {

        log.debug("Filling data source for receive log ID " + id);

        List<KeyValuePair> list = new ArrayList<KeyValuePair>();
        if (receiveLogs == null) {
            log.error("Should not be called if receive logs unavailable");
            return new JRBeanCollectionDataSource(list);
        }

        for (ReceiveLog receiveLog : receiveLogs) {
            if (receiveLog.getId() == id) {
                return receiveLogDataSource(receiveLog);
            }
        }

        log.error("Could not identify receive log for ID " + id);
        return new JRBeanCollectionDataSource(list);
    }

    /**
     * Returns a {@link JRDataSource} which wraps the given {@link ReceiveLog}.
     * 
     * @return a non-{@code null} data source.
     * @throws JRScriptletException if the data source could not be created.
     */
    public JRDataSource receiveLogDataSource(ReceiveLog receiveLog)
        throws JRScriptletException {

        List<DispatchLogFacade> list = new ArrayList<DispatchLogFacade>();
        if (receiveLog == null) {
            log.error("pipelineInstance is null");
            return new JRBeanCollectionDataSource(list);
        }

        log.debug("Filling data source for receiveLog " + receiveLog.getId()
            + " (" + receiveLog.getMessageFileName() + ")");

        // Retrieve dispatchers for receive log.
        List<DispatchLog> dispatchLogs = logCrud.retrieveDispatchLogs(receiveLog);

        // For each dispatcher, display dispatcher name, type, pipeline instance
        // name and type, and number of files. If there is more than one
        // pipeline instance, do not display dispatch name and type for
        // subsequent instances.
        for (DispatchLog dispatchLog : dispatchLogs) {
            boolean displayTotal = false;
            long totalTime = 0;

            list.add(new DispatchLogFacade(dispatchLog));
            long duration = duration(dispatchLog.getStartProcessingTime(),
                dispatchLog.getEndProcessingTime());
            if (duration > 0) {
                totalTime += duration;
            }

            for (PipelineInstance pipelineInstance : dispatchLog.getPipelineInstances()) {
                list.add(new DispatchLogFacade(pipelineInstance));
                duration = duration(pipelineInstance.getStartProcessingTime(),
                    pipelineInstance.getEndProcessingTime());
                if (duration > 0) {
                    totalTime += duration;
                }
                displayTotal = true;
            }

            // Display total if there were any pipelines.
            if (displayTotal) {
                list.add(new DispatchLogFacade(totalTime));
            }
        }

        return new JRBeanCollectionDataSource(list);
    }

    private long duration(Date start, Date end) {
        if (start == null) {
            return -1;
        }

        // Assume we're still running and display elapsed time so far.
        Date theEnd = end;
        if (theEnd == null) {
            theEnd = new Date();
        }

        long duration = theEnd.getTime() - start.getTime();

        if (log.isDebugEnabled()) {
            log.debug("start=" + start.getTime() + ", end=" + theEnd.getTime()
                + ", duration=" + duration);
        }

        return duration;
    }

    private Set<ReceiveLog.State> convertToEnum(String[] stateStrings) {

        Set<ReceiveLog.State> states = new HashSet<ReceiveLog.State>();
        if (stateStrings != null) {
            for (String stateString : stateStrings) {
                states.add(ReceiveLog.State.valueOf(stateString));
            }
        }
        return states;
    }

    private Collection<String> getAllMessageTypes() {

        Set<String> types = new TreeSet<String>();

        List<String> typeStrings = null;
        try {
            typeStrings = new LogCrud().retrieveMessageTypes();
        } catch (Exception e) {
            return types;
        }

        if (typeStrings.size() == 0) {
            return types;
        }

        for (String typeString : typeStrings) {
            types.add(typeString.toUpperCase());
        }

        return types;
    }

    /**
     * A value-added facade to the {@link ReceiveLog} object.
     * 
     * @author Bill Wohler
     */
    public class ReceiveLogFacade {
        private ReceiveLog receiveLog;
        private long duration = -1;

        public ReceiveLogFacade(ReceiveLog receiveLog) {
            this.receiveLog = receiveLog;
        }

        public String getMessageFileName() {
            return receiveLog.getMessageFileName();
        }

        public String getMessageType() {
            return receiveLog.getMessageType();
        }

        public ReceiveLog getReceiveLog() {
            return receiveLog;
        }

        public String getSocIngestTime() {
            return getDateFormatter().format(receiveLog.getSocIngestTime());
        }

        public String getState() {
            return receiveLog.getState()
                .toString();
        }

        public String getTime() {
            if (duration < 0) {
                duration = duration();
                if (duration < 0) {
                    return NO_DATA;
                }
            }

            return DurationFormatUtils.formatDuration(duration, "H:mm");
        }

        private long duration() {
            Date start = receiveLog.getStartProcessingTime();
            Date end = receiveLog.getEndProcessingTime();

            long duration = DrScriptlet.this.duration(start, end);

            return duration;
        }
    }

    /**
     * A value-added facade to the {@link DispatchLog} object.
     * 
     * @author Bill Wohler
     */
    public class DispatchLogFacade {
        private DispatchLog dispatchLog;
        private PipelineInstance pipelineInstance;
        private String state;
        private long duration = -1;

        public DispatchLogFacade(DispatchLog dispatchLog) {
            this.dispatchLog = dispatchLog;
            state = dispatchLog.getState()
                .toString();
        }

        public DispatchLogFacade(PipelineInstance pipelineInstance) {
            this.pipelineInstance = pipelineInstance;
            state = pipelineInstance.getState()
                .toString();
        }

        public DispatchLogFacade(long duration) {
            this.duration = duration;
        }

        public String getDispatcherType() {
            return dispatchLog != null ? dispatchLog.getDispatcherType()
                .getName() : pipelineInstance != null ? DITTO : "Total";
        }

        public String getFileCount() {
            if (dispatchLog == null) {
                return NO_DATA;
            }

            return Integer.toString(dispatchLog.getTotalFileCount());
        }

        public String getPipelineInstanceName() {
            return pipelineInstance != null ? pipelineInstance.getPipelineDefinition()
                .getName()
                .toString()
                : NO_DATA;
        }

        public String getState() {
            return state != null ? state : NO_DATA;
        }

        public String getTime() {
            if (duration < 0) {
                duration = duration();
                if (duration < 0) {
                    return NO_DATA;
                }
            }

            return DurationFormatUtils.formatDuration(duration, "H:mm");
        }

        private long duration() {
            Date start;
            Date end;
            if (pipelineInstance != null) {
                start = pipelineInstance.getStartProcessingTime();
                end = pipelineInstance.getEndProcessingTime();
            } else {
                start = dispatchLog.getStartProcessingTime();
                end = dispatchLog.getEndProcessingTime();
            }

            long duration = DrScriptlet.this.duration(start, end);

            return duration;
        }
    }
}
