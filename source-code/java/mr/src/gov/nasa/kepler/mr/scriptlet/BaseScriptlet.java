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
import static gov.nasa.kepler.mr.servlet.ReportViewerServlet.PARAM_PATH;
import static gov.nasa.kepler.mr.servlet.ReportViewerServlet.PARAM_SUBMIT;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.HibernateConstants;
import gov.nasa.kepler.mr.MrTimeUtil;
import gov.nasa.kepler.mr.ParameterUtil;
import gov.nasa.kepler.mr.servlet.ReportViewerServlet;

import java.text.DateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import net.sf.jasperreports.engine.JRDefaultScriptlet;
import net.sf.jasperreports.engine.JRRenderable;
import net.sf.jasperreports.engine.JRScriptletException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This is MR's base scriptlet class that other scriptlet classes should
 * subclass. When overridding {@link #afterReportInit()}, you must call
 * {@code super.afterReportInit()}.
 * 
 * @author Bill Wohler
 * @author jbrittain
 */
public class BaseScriptlet extends JRDefaultScriptlet {

    protected static final Log log = LogFactory.getLog(BaseScriptlet.class);

    public static final String CHART_MAP_KEY = "CHART_MAP";
    public static final String JASPER_PARAMETERS_MAP_KEY = "REPORT_PARAMETERS_MAP";

    public static final int UNINITIALIZED_CADENCE = ParameterUtil.UNINITIALIZED_CADENCE;
    public static final int INVALID_CADENCE = ParameterUtil.INVALID_CADENCE;

    public static final String PARAM_MODULE_OUTPUT = ParameterUtil.PARAM_MODULE_OUTPUT;
    public static final int UNINITIALIZED_CCD_MODULE_OUTPUT = ParameterUtil.UNINITIALIZED_CCD_MODULE_OUTPUT;
    public static final int INVALID_CCD_MODULE_OUTPUT = ParameterUtil.INVALID_CCD_MODULE_OUTPUT;

    public static final String PARAM_ID = ParameterUtil.PARAM_ID;
    public static final long UNINITIALIZED_ID = ParameterUtil.UNINITIALIZED_ID;
    public static final long INVALID_ID = ParameterUtil.INVALID_ID;

    /**
     * String to use if a field has no data. Fields should never be left blank.
     */
    public static final String NO_DATA = ParameterUtil.NO_DATA;

    /**
     * String to use if a field represents all data. Fields should never be left
     * blank.
     */
    public static final String ALL_DATA = "ALL";

    /**
     * Character to use if the content of a field is the same as in the row
     * above it. Fields should never be left blank.
     */
    public static final String DITTO = "\"";

    private DateFormat dateFormatter = MrTimeUtil.dateFormatter();

    private ParameterUtil parameterUtil = new ParameterUtil();
    private Map<String, JRRenderable> chartMap;
    private String serverUrl;

    /**
     * Performs report initialization. Subclasses MUST call
     * {@code super.afterReportInit()} in order to:
     * <ul>
     * <li>Initialize the various fields provided by this class.
     * <li>Close the database session to avoid pulling stale data out of the
     * cache.
     * </ul>
     */
    @SuppressWarnings("unchecked")
    @Override
    public void afterReportInit() throws JRScriptletException {

        setReportParameters((Map<String, Object>) getParameterValue(JASPER_PARAMETERS_MAP_KEY));

        // Get the serverUrl so that hyperlinks can work inside reports.
        setServerUrl((String) parameterUtil.getReportParameters()
            .get(ReportViewerServlet.PARAM_SERVER_URL));

        // Create the chart map containing all charts for the report unless
        // we're here while initializing a subDataset, in which case
        // generationParameters will be null. Why is that?
        if (getGenerationParameters() != null) {
            setChartMap(new HashMap<String, JRRenderable>());
            getGenerationParameters().put(CHART_MAP_KEY, chartMap);
        }

        // Ensure that queries don't return stale data.
        DatabaseServiceFactory.getInstance()
            .closeCurrentSession();
    }

    protected DateFormat getDateFormatter() {
        return dateFormatter;
    }

    protected Map<String, JRRenderable> getChartMap() {
        return chartMap;
    }

    protected void setChartMap(Map<String, JRRenderable> chartMap) {
        this.chartMap = chartMap;
    }

    /** Returns a single value for the given parameter. */
    protected String getRequestParameter(String paramName, String errorText) {
        return parameterUtil.getRequestParameter(paramName, errorText);
    }

    /** Returns an array of values for the given parameter. */
    protected String[] getRequestParameters(String paramName, String errorText) {
        return parameterUtil.getRequestParameters(paramName, errorText);
    }

    protected void setRequestParameter(String paramName, String value) {
        parameterUtil.setRequestParameter(paramName, value);
    }

    public String printParams() {
        StringBuilder parameterString = new StringBuilder();
        for (Object element : getGenerationParameters().keySet()) {
            String key = (String) element;
            Object valueObject = getGenerationParameters().get(key);
            if (valueObject instanceof String[]) {
                for (String value : (String[]) valueObject) {
                    if (key.equals(PARAM_PATH) || key.equals(PARAM_SUBMIT)
                        || key.equals(PARAM_FORMAT)) {
                        continue;
                    }
                    parameterString.append(key)
                        .append(" = ")
                        .append(value)
                        .append("\n");
                }
            } else {
                if (key.equals(CHART_MAP_KEY)) {
                    continue;
                }
                parameterString.append(key)
                    .append(" = ")
                    .append(getGenerationParameters().get(key))
                    .append("\n");
            }
        }

        return parameterString.toString();
    }

    /**
     * Parses the {@code time} request parameter.
     * 
     * @see ParameterUtil#expectTimeParameter()
     */
    protected void expectTimeParameter() {
        parameterUtil.expectTimeParameter();
    }

    /**
     * Parses the {@code startTime} and {@code endTime} request parameters.
     * 
     * @see ParameterUtil#expectStartEndTimeParameters()
     */
    protected void expectStartEndTimeParameters() {
        parameterUtil.expectStartEndTimeParameters();
    }

    /**
     * Parses the {@code startCadence}, {@code endCadence}, and
     * {@code cadenceType} request parameters.
     * 
     * @see ParameterUtil#expectCadenceParameters()
     */
    protected void expectCadenceParameters() {
        parameterUtil.expectCadenceParameters();
    }

    /**
     * Parses the {@code moduleOutput} request parameter.
     * 
     * @see ParameterUtil#expectModuleOutputParameter()
     */
    protected void expectModuleOutputParameter() {
        parameterUtil.expectModuleOutputParameter();
    }

    /**
     * Parses the {@code id} request parameter.
     * 
     * @see ParameterUtil#expectIdParameter(boolean)
     */
    protected void expectIdParameter(boolean required) {
        parameterUtil.expectIdParameter(required);
    }
    
    /**
     * Parses the {@code sortby} request parameter.
     * 
     * @see ParameterUtil#expectSortByParameter()
     */
    protected void expectSortByParameter() {
        parameterUtil.expectSortByParameter();
    }
    
    /**
     * Parses the {@code sortorder} request parameter.
     * 
     * @see ParameterUtil#expectSortOrderParameter()
     */
    protected void expectSortOrderParameter() {
        parameterUtil.expectSortOrderParameter();
    }

    /**
     * Returns the time specified in the {@code time} request parameter.
     * 
     * @see ParameterUtil#getTime()
     */
    public Date getTime() {
        return parameterUtil.getTime();
    }

    /**
     * Returns the starting time specified in the {@code startTime} request
     * parameter.
     * 
     * @see ParameterUtil#getStartTime()
     */
    public Date getStartTime() {
        return parameterUtil.getStartTime();
    }

    /**
     * Returns the ending time specified in the {@code endTime} request
     * parameter.
     * 
     * @see ParameterUtil#getEndTime()
     */
    public Date getEndTime() {
        return parameterUtil.getEndTime();
    }

    /**
     * Returns the starting cadence specified in the {@code startCadence}
     * request parameter.
     * 
     * @see ParameterUtil#getStartCadence()
     */
    public int getStartCadence() {
        return parameterUtil.getStartCadence();
    }

    /**
     * Returns the ending cadence specified in the {@code endCadence} request
     * parameter.
     * 
     * @see ParameterUtil#getEndCadence()
     */
    public int getEndCadence() {
        return parameterUtil.getEndCadence();
    }

    /**
     * Returns the type of cadence specified in the {@code cadenceType} request
     * parameter.
     * 
     * @see ParameterUtil#getCadenceType()
     */
    public CadenceType getCadenceType() {
        return parameterUtil.getCadenceType();
    }

    /**
     * Returns the CCD module specified in the {@code moduleOutput} request
     * parameter.
     * 
     * @see ParameterUtil#getCcdModule()
     */
    public int getCcdModule() {
        return parameterUtil.getCcdModule();
    }

    /**
     * Returns the CCD output specified in the {@code moduleOutput} request
     * parameter.
     * 
     * @see ParameterUtil#getCcdOutput()
     */
    public int getCcdOutput() {
        return parameterUtil.getCcdOutput();
    }

    /**
     * Returns the ID specified in the {@code id} request parameter.
     * 
     * @see ParameterUtil#getId()
     */
    public long getId() {
        return parameterUtil.getId();
    }

    /**
     * Returns the field to sort by specified in the {@code sortby} request parameter.
     * 
     * @see ParameterUtil#getId()
     */
    public String getSortBy() {
        return parameterUtil.getSortBy();
    }

    /**
     * Returns the field to sort by specified in the {@code sortorder} request parameter.
     * 
     * @see ParameterUtil#getId()
     */
    public Boolean getSortAscending() {
        return parameterUtil.getSortAscending();
    }

    /**
     * Returns the URL of the database in use.
     */
    public String getDatabaseUrl() {
        return ConfigurationServiceFactory.getInstance()
            .getString(HibernateConstants.HIBERNATE_URL_PROP);
    }

    /**
     * Returns the name of the database user.
     */
    public String getDatabaseUser() {
        return ConfigurationServiceFactory.getInstance()
            .getString(HibernateConstants.HIBERNATE_USERNAME_PROP);
    }

    protected Map<String, Object> getGenerationParameters() {
        return parameterUtil.getGenerationParameters();
    }

    protected void setGenerationParameters(
        Map<String, Object> generationParameters) {
        parameterUtil.setGenerationParameters(generationParameters);
    }

    protected Map<String, Object> getReportParameters() {
        return parameterUtil.getReportParameters();
    }

    protected void setReportParameters(Map<String, Object> reportParameters) {
        parameterUtil.setReportParameters(reportParameters);
    }

    protected String getServerUrl() {
        return serverUrl;
    }

    protected void setServerUrl(String serverUrl) {
        this.serverUrl = serverUrl;
    }

    protected void setWarningText(String text) {
        parameterUtil.setWarningText(text);
    }

    public String getWarningText() {
        return parameterUtil.getWarningText();
    }

    protected void setErrorText(String text) {
        parameterUtil.setErrorText(text);
    }

    public String getErrorText() {
        return parameterUtil.getErrorText();
    }
}
