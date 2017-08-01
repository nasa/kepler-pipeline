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

import static gov.nasa.kepler.mr.servlet.ReportViewerServlet.PARAM_FORMAT;
import static gov.nasa.kepler.mr.servlet.ReportViewerServlet.REPORT_URI_BASE;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNodeCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask.State;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.mr.ParameterUtil;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import net.sf.jasperreports.engine.JRDataSource;
import net.sf.jasperreports.engine.JRScriptletException;
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource;

import org.apache.commons.lang.time.DurationFormatUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;

/**
 * This is the scriptlet class for the Pipeline Processing report.
 * 
 * @author Bill Wohler
 */
public class PipelineScriptlet extends BaseScriptlet {

    private static final Log log = LogFactory.getLog(PipelineScriptlet.class);

    public static final String REPORT_NAME_PI_PROCESSING = "pipeline-processing";
    public static final String REPORT_TITLE_PI_PROCESSING = "Pipeline Processing";
    public static final String REPORT_NAME_PI_INSTANCE_DETAIL = "pipeline-instance-detail";

    private static final String DURATION_FORMAT = "H:mm:ss";

    private static final String PARAM_TYPE = "type";
    private static final String PARAM_STATE = "state";

    private static PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud();
    private static PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();

    private List<PipelineInstance> pipelineInstances;
    private PipelineInstance pipelineInstance;

    @Override
    public void afterReportInit() throws JRScriptletException {
        super.afterReportInit();

        // If we get an id parameter, that's all we need for a detailed report.
        expectIdParameter(false);
        if (getId() == INVALID_ID) {
            return;
        } else if (getId() != UNINITIALIZED_ID) {
            try {
                pipelineInstance = pipelineInstanceCrud.retrieve(getId());
            } catch (HibernateException e) {
                String text = "Could not obtain pipeline instance for id="
                    + getId() + ": ";
                setErrorText(text + e + "\nCause: " + e.getCause());
                log.error(text, e);
            }
            return;
        }

        // Otherwise, get everything for the summary.
        expectStartEndTimeParameters();
        if (getStartTime() == null || getEndTime() == null) {
            return;
        }

        // Grab state and type from parameters.
        String stateStrings[] = getRequestParameters(PARAM_STATE,
            String.format(ParameterUtil.MISSING_PARAM_ERROR_TEXT, PARAM_STATE));
        String types[] = getRequestParameters(PARAM_TYPE,
            String.format(ParameterUtil.MISSING_PARAM_ERROR_TEXT, PARAM_TYPE));
        if (stateStrings == null || types == null) {
            return;
        }
        if (log.isDebugEnabled()) {
            if (stateStrings.length > 0) {
                log.debug("states[" + stateStrings.length + "]="
                    + stateStrings[0] + ", ...");
            } else {
                log.debug("states[" + stateStrings.length + "]");
            }
            if (types.length > 0) {
                log.debug("types[" + types.length + "]=" + types[0] + ", ...");
            } else {
                log.debug("types[" + types.length + "]");
            }
        }
        PipelineInstance.State[] states = new PipelineInstance.State[stateStrings.length];
        for (int i = 0; i < stateStrings.length; i++) {
            states[i] = PipelineInstance.State.valueOf(stateStrings[i]);
        }

        try {
            pipelineInstances = pipelineInstanceCrud.retrieve(getStartTime(),
                getEndTime(), states, types);

            if (pipelineInstances.size() == 0) {
                String text = String.format(
                    "There weren't any pipeline instances in the range %s to %s.",
                    getDateFormatter().format(getStartTime()),
                    getDateFormatter().format(getEndTime()));
                setErrorText(text);
                log.error(text);
            }
        } catch (HibernateException e) {
            String text = "Could not obtain pipeline instances from "
                + getDateFormatter().format(getStartTime()) + " to "
                + getDateFormatter().format(getEndTime()) + ": ";
            setErrorText(text + e + "\nCause: " + e.getCause());
            log.error(text, e);
            return;
        }
    }

    /**
     * Returns a {@link JRDataSource} which wraps all of the
     * {@link PipelineInstance}s for the current time range.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource pipelineInstancesDataSource()
        throws JRScriptletException {

        log.debug("Filling data source for all pipeline instances");

        List<PipelineInstanceFacade> list = new ArrayList<PipelineInstanceFacade>();
        if (pipelineInstances == null) {
            log.error("Should not be called if pipeline instances unavailable");
            return new JRBeanCollectionDataSource(list);
        }

        for (PipelineInstance pipelineInstance : pipelineInstances) {
            list.add(new PipelineInstanceFacade(pipelineInstance));
        }

        return new JRBeanCollectionDataSource(list);
    }

    /**
     * Returns a {@link JRDataSource} which wraps the current
     * {@link PipelineInstance}.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource pipelineInstanceDataSource()
        throws JRScriptletException {

        List<KeyValuePair> list = new ArrayList<KeyValuePair>();
        if (pipelineInstance == null) {
            log.error("Should not be called if pipeline instance unavailable");
            return new JRBeanCollectionDataSource(list);
        }

        log.debug("Filling data source for pipeline instance "
            + pipelineInstance.getName() + "/" + pipelineInstance.getId());

        list.add(new KeyValuePair("Start", getDateFormatter().format(
            pipelineInstance.getStartProcessingTime())));

        if (pipelineInstance.getEndProcessingTime()
            .getTime() > 0) {
            list.add(new KeyValuePair("End", getDateFormatter().format(
                pipelineInstance.getEndProcessingTime())));
            list.add(new KeyValuePair("Duration",
                DurationFormatUtils.formatDuration(
                    pipelineInstance.getEndProcessingTime()
                        .getTime() - pipelineInstance.getStartProcessingTime()
                        .getTime(), DURATION_FORMAT)));
        } else {
            list.add(new KeyValuePair("End", NO_DATA));
            list.add(new KeyValuePair("Elapsed",
                DurationFormatUtils.formatDuration(System.currentTimeMillis()
                    - pipelineInstance.getStartProcessingTime()
                        .getTime(), DURATION_FORMAT)));
        }
        list.add(new KeyValuePair("State", pipelineInstance.getState()
            .toString()));

        Map<State, Integer> taskCounts = pipelineTaskCrud.taskCountByState(pipelineInstance);

        list.add(new KeyValuePair("Total Number of Tasks", totalTaskCount(
            taskCounts).toString()));

        list.add(new KeyValuePair("Number of Initialized Tasks", taskCount(
            taskCounts, State.INITIALIZED).toString()));
        list.add(new KeyValuePair("Number of Submitted Tasks", taskCount(
            taskCounts, State.SUBMITTED).toString()));
        list.add(new KeyValuePair("Number of Running Tasks", taskCount(
            taskCounts, State.PROCESSING).toString()));
        list.add(new KeyValuePair("Number of Failed Tasks", taskCount(
            taskCounts, State.ERROR).toString()));
        list.add(new KeyValuePair("Number of Completed Tasks", taskCount(
            taskCounts, State.COMPLETED).toString()));
        list.add(new KeyValuePair("Number of Partially Completed Tasks",
            taskCount(taskCounts, State.PARTIAL).toString()));

        list.add(new KeyValuePair("Trigger Name",
            pipelineInstance.getTriggerName()));

        return new JRBeanCollectionDataSource(list);
    }

    private Integer totalTaskCount(Map<State, Integer> taskCounts) {
        int total = 0;
        for (Integer count : taskCounts.values()) {
            total += count;
        }

        return total;
    }

    private Integer taskCount(Map<State, Integer> taskCounts, State state) {
        if (state == null) {
            throw new NullPointerException("state can't be null");
        }
        Integer taskCount = taskCounts.get(state);
        if (taskCount == null) {
            throw new IllegalStateException("No data for state " + state);
        }

        return taskCount;
    }

    /**
     * Returns a {@link JRDataSource} which wraps the parameter sets for the
     * chosen {@link PipelineInstance}.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource pipelineParameterSetsDataSource()
        throws JRScriptletException {

        List<ParameterSetFacade> list = new ArrayList<ParameterSetFacade>();
        if (pipelineInstance == null) {
            log.error("Should not be called if pipeline instance unavailable");
            return new JRBeanCollectionDataSource(list);
        }

        log.debug("Filling data source for pipeline parameter sets associated with "
            + pipelineInstance.getName());

        return parameterSetsDataSource(pipelineInstance.getPipelineParameterSets());
    }

    /**
     * Returns a {@link JRDataSource} which wraps the parameter sets found in
     * the given map.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource parameterSetsDataSource(
        Map<ClassWrapper<Parameters>, ParameterSet> parameterSets)
        throws JRScriptletException {

        log.debug("Filling data source for parameter sets");

        List<ParameterSetFacade> list = new ArrayList<ParameterSetFacade>();
        if (parameterSets == null) {
            log.error("parameterSets is null");
            return new JRBeanCollectionDataSource(list);
        }

        for (Map.Entry<ClassWrapper<Parameters>, ParameterSet> entry : parameterSets.entrySet()) {
            list.add(new ParameterSetFacade(entry.getKey(), entry.getValue()));
        }

        return new JRBeanCollectionDataSource(list);
    }

    /**
     * Returns a {@link JRDataSource} which wraps the parameters for the given
     * {@link ParameterSet}.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource parametersDataSource(ParameterSet parameterSet)
        throws JRScriptletException {

        List<KeyValuePair> list = new ArrayList<KeyValuePair>();
        if (parameterSet == null) {
            log.error("parameterSet is null");
            return new JRBeanCollectionDataSource(list);
        }

        log.debug("Filling data source for parameter set"
            + parameterSet.getName());

        Map<String, String> props = parameterSet.getParameters()
            .getProps();
        for (Map.Entry<String, String> prop : props.entrySet()) {
            list.add(new KeyValuePair(prop.getKey(), prop.getValue()));
        }

        return new JRBeanCollectionDataSource(list);
    }

    /**
     * Returns a {@link JRDataSource} which wraps the module parameter sets for
     * the chosen {@link PipelineInstance}.
     * 
     * @return a non-{@code null} data source
     * @throws JRScriptletException if the data source could not be created
     */
    public JRDataSource pipelineModulesDataSource() throws JRScriptletException {
        List<PipelineInstanceNodeFacade> list = new ArrayList<PipelineInstanceNodeFacade>();
        if (pipelineInstance == null) {
            log.error("Should not be called if pipeline instance unavailable");
            return new JRBeanCollectionDataSource(list);
        }

        log.debug("Filling data source for pipeline module parameters associated with "
            + pipelineInstance.getName());

        PipelineInstanceNodeCrud pipelineInstanceNodeCrud = new PipelineInstanceNodeCrud();
        List<PipelineInstanceNode> pipelineInstanceNodes = pipelineInstanceNodeCrud.retrieveAll(pipelineInstance);
        for (PipelineInstanceNode pipelineInstanceNode : pipelineInstanceNodes) {
            list.add(new PipelineInstanceNodeFacade(pipelineInstanceNode));
        }

        return new JRBeanCollectionDataSource(list);
    }

    public String getName() {
        return pipelineInstance.getName() != null ? pipelineInstance.getName()
            : NO_DATA;
    }

    public String getType() {
        if (pipelineInstance.getPipelineDefinition() != null
            && pipelineInstance.getPipelineDefinition()
                .getName()
                .toString() != null) {
            return pipelineInstance.getPipelineDefinition()
                .getName()
                .toString();
        }

        return NO_DATA;
    }

    /**
     * A value-added facade to the {@link PipelineInstance} object.
     * 
     * @author Bill Wohler
     */
    public class PipelineInstanceFacade {
        private PipelineInstance pipelineInstance;

        public PipelineInstanceFacade(PipelineInstance pipelineInstance) {
            this.pipelineInstance = pipelineInstance;
        }

        public long getId() {
            return pipelineInstance.getId();
        }

        public String getUrl() {
            String format = ((String[]) getGenerationParameters().get(
                PARAM_FORMAT))[0];

            String pipelineInstanceUrl = new StringBuilder().append(
                getServerUrl())
                .append(REPORT_URI_BASE)
                .append("/")
                .append(REPORT_NAME_PI_INSTANCE_DETAIL)
                .append('?')
                .append(PARAM_ID)
                .append('=')
                .append(getId())
                .append('&')
                .append(PARAM_FORMAT)
                .append('=')
                .append(format)
                .toString();

            return pipelineInstanceUrl;
        }

        public String getName() {
            return pipelineInstance.getName() != null ? pipelineInstance.getName()
                : NO_DATA;
        }

        public String getType() {
            if (pipelineInstance.getPipelineDefinition() != null
                && pipelineInstance.getPipelineDefinition()
                    .getName() != null) {
                return pipelineInstance.getPipelineDefinition()
                    .getName()
                    .toString();
            }

            return NO_DATA;
        }

        public String getStartProcessingTime() {
            return getDateFormatter().format(
                pipelineInstance.getStartProcessingTime());
        }

        public String getState() {
            return pipelineInstance.getState()
                .toString();
        }
    }

    /**
     * A value-added facade to the {@link ParameterSet} object.
     * 
     * @author Bill Wohler
     */
    public static class ParameterSetFacade {
        private ClassWrapper<Parameters> clazz;
        private ParameterSet parameterSet;

        public ParameterSetFacade(ClassWrapper<Parameters> clazz,
            ParameterSet parameterSet) {
            this.clazz = clazz;
            this.parameterSet = parameterSet;
        }

        public String getType() {
            return clazz.toString();
        }

        public ParameterSet getParameterSet() {
            return parameterSet;
        }
    }

    /**
     * A value-added facade to the pipeline modules and their
     * {@link ParameterSet}s.
     * 
     * @author Bill Wohler
     */
    public static class PipelineInstanceNodeFacade {
        private PipelineInstanceNode pipelineInstanceNode;

        public PipelineInstanceNodeFacade(
            PipelineInstanceNode pipelineInstanceNode) {
            this.pipelineInstanceNode = pipelineInstanceNode;
        }

        public String getName() {
            if (pipelineInstanceNode.getPipelineModuleDefinition() != null
                && pipelineInstanceNode.getPipelineModuleDefinition()
                    .getName() != null
                && pipelineInstanceNode.getPipelineModuleDefinition()
                    .getName()
                    .getName() != null) {
                return pipelineInstanceNode.getPipelineModuleDefinition()
                    .getName()
                    .getName();
            }

            return NO_DATA;
        }

        public Map<ClassWrapper<Parameters>, ParameterSet> getParameterSets() {
            return pipelineInstanceNode.getModuleParameterSets();
        }
    }

    /**
     * Facade used test private methods.
     * 
     * @author Bill Wohler
     */
    class TestFacade {
        public Integer totalTaskCount(Map<State, Integer> taskCounts) {
            return PipelineScriptlet.this.totalTaskCount(taskCounts);
        }

        public Integer taskCount(Map<State, Integer> taskCounts, State state) {
            return PipelineScriptlet.this.taskCount(taskCounts, state);
        }
    }
}
