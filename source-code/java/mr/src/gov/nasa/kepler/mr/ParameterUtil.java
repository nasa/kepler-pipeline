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

package gov.nasa.kepler.mr;

import static gov.nasa.kepler.mr.servlet.ReportViewerServlet.GENERATION_PARAMETERS_KEY;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.Iso8601Formatter;

import java.text.DateFormat;
import java.text.ParseException;
import java.util.Date;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Parse request parameters.
 * 
 * @author Bill Wohler
 */
public class ParameterUtil {
    private static final Log log = LogFactory.getLog(ParameterUtil.class);

    public static final String NO_DATA = "-";

    public static final String PARAM_TIME = "time";
    public static final String PARAM_START_TIME = "startTime";
    public static final String PARAM_END_TIME = "endTime";

    public static final String PARAM_START_CADENCE = "startCadence";
    public static final String PARAM_END_CADENCE = "endCadence";
    public static final String PARAM_CADENCE_TYPE = "cadenceType";
    public static final int UNINITIALIZED_CADENCE = -2;
    public static final int INVALID_CADENCE = -1;

    public static final String PARAM_MODULE_OUTPUT = "moduleOutput";
    public static final int INVALID_CCD_MODULE_OUTPUT = -1;
    public static final int UNINITIALIZED_CCD_MODULE_OUTPUT = -2;

    public static final String PARAM_ID = "id";
    public static final long INVALID_ID = -1;
    public static final long UNINITIALIZED_ID = -2;

    public static final String PARAM_GENERIC_REPORT_IDENTIFIER = "genericReportIdentifier";
    public static final long INVALID_PIPELINE_TASK_ID = -1;
    public static final long UNINITIALIZED_PIPELINE_TASK_ID = -2;

    public static final String MISSING_PARAM_ERROR_TEXT = "Did not receive the %s report parameter.";

    public static final String PARAM_SORT_BY = "sortBy";
    public static final String INVALID_SORT_BY = null;
    public static final String PARAM_SORT_ORDER = "sortOrder";
    public static final Boolean INVALID_SORT_ORDER = null;

    /**
     * This is the default cadence number if one isn't entered by the user.
     * It'll cover the short cadences for about 2000 years.
     */
    static final int NICE_ROUND_INCONCEIVABLY_LARGE_CADENCE_NUMBER = 1000000000;

    private Date time;
    private Date startTime;
    private Date endTime;

    private int startCadence = UNINITIALIZED_CADENCE;
    private int endCadence = UNINITIALIZED_CADENCE;
    private CadenceType cadenceType;

    private int ccdModule = UNINITIALIZED_CCD_MODULE_OUTPUT;
    private int ccdOutput = UNINITIALIZED_CCD_MODULE_OUTPUT;

    private long id = UNINITIALIZED_ID;

    private long pipelineTaskId = UNINITIALIZED_PIPELINE_TASK_ID;
    private String identifier;

    private String sortBy;
    private Boolean sortAscending;

    private DateFormat relaxedDateTimeFormatter = Iso8601Formatter.relaxedDateTimeFormatter();
    private DateFormat dateFormatter = MrTimeUtil.dateFormatter();

    private Map<String, Object> reportParameters;
    private Map<String, Object> generationParameters;

    private String warningText;
    private String errorText;

    public ParameterUtil() {
    }

    public ParameterUtil(Map<String, Object> reportParameters) {
        setReportParameters(reportParameters);
    }

    public Map<String, Object> getReportParameters() {
        return reportParameters;
    }

    @SuppressWarnings("unchecked")
    public final void setReportParameters(Map<String, Object> reportParameters) {
        this.reportParameters = reportParameters;

        if (reportParameters != null) {
            setGenerationParameters((Map<String, Object>) reportParameters.get(GENERATION_PARAMETERS_KEY));
        }
    }

    public Map<String, Object> getGenerationParameters() {
        return generationParameters;
    }

    public final void setGenerationParameters(
        Map<String, Object> generationParameters) {
        this.generationParameters = generationParameters;
    }

    /** Returns a single value for the given parameter. */
    public String getRequestParameter(String paramName, String errorText) {
        String[] values = getRequestParameters(paramName, errorText);
        if (values == null) {
            return null;
        }

        return values[0];
    }

    public void setRequestParameter(String paramName, String value) {
        setRequestParameters(paramName, new String[] { value != null ? value
            : "" });
    }

    /** Returns an array of values for the given parameter. */
    public String[] getRequestParameters(String paramName, String errorText) {
        // Default is scriptlet context, but fall back to reportParameters in
        // servlet context.
        Map<String, Object> parameters = generationParameters != null ? generationParameters
            : reportParameters;
        if (parameters == null) {
            return null;
        }

        String[] valueArray = (String[]) parameters.get(paramName);
        if (errorText != null && (valueArray == null || valueArray.length == 0)) {
            if (getErrorText() == null) {
                setErrorText(errorText);
            }
            log.error(errorText);
            return null;
        }

        return valueArray;
    }

    /**
     * For internal use and testing only.
     */
    void setRequestParameters(String paramName, String[] value) {
        // Default is scriptlet context, but fall back to reportParameters in
        // servlet context.
        Map<String, Object> parameters = generationParameters != null ? generationParameters
            : reportParameters;
        if (parameters == null || value == null) {
            return;
        }

        parameters.put(paramName, value);
    }

    /**
     * Initializes the {@code time} field from its request parameter. If the
     * {@code time} parameter is empty, the field is initialized to the time
     * now. When this method completes, either the field is initialized, or it
     * is set to {@code null}, the error is logged, and the error text is set
     * appropriately. This can happen if the parameter is either missing, or its
     * content cannot be parsed.
     */
    public void expectTimeParameter() {
        parseTime(getRequestParameter(PARAM_TIME, String.format(
            MISSING_PARAM_ERROR_TEXT, PARAM_TIME)));
    }

    /**
     * Initializes the {@code time} field from the given string. If the string
     * is empty, the field is initialized to the time now. When this method
     * completes, either the field is initialized, or it is set to {@code null},
     * the error is logged, and the error text is set appropriately. This can
     * happen if the argument is either {@code null}, or its content cannot be
     * parsed.
     */
    private void parseTime(String timeString) {
        // Assume the worst.
        time = null;

        log.debug("time=" + timeString);
        if (timeString == null) {
            return;
        }

        // Parse the time. If timeString is empty, use now. Since we push the
        // date back into the request parameters which subreports will see, we
        // use the relaxed formatter if we don't see a T, and the normal
        // formatter if we do. See
        // Iso8601Formatter.RELAXED_DATE_TIME_FORMAT_STRING.
        try {
            time = timeString.trim()
                .length() == 0 ? new Date()
                : timeString.indexOf('T') < 0 ? relaxedDateTimeFormatter.parse(timeString)
                    : dateFormatter.parse(timeString);
            setRequestParameter(PARAM_TIME, dateFormatter.format(time));
        } catch (ParseException e) {
            if (getErrorText() == null) {
                setErrorText(e.getMessage());
            }
            log.error(e.getMessage(), e);
            return;
        }
    }

    /**
     * Initializes the {@code startTime} and {@code endTime} fields from their
     * respective request parameters. If the {@code startTime} parameter is
     * empty, the field is initialized to the beginning of time; if the {@code
     * endTime} parameter is empty, the field is initialized to the time now.
     * When this method completes, either the fields are initialized, or they
     * are set to {@code null}, the error is logged, and the error text is set
     * appropriately. This can happen if the arguments are either {@code null},
     * or their content cannot be parsed.
     */
    public void expectStartEndTimeParameters() {
        parseStartEndTime(getRequestParameter(PARAM_START_TIME, String.format(
            MISSING_PARAM_ERROR_TEXT, PARAM_START_TIME)), getRequestParameter(
            PARAM_END_TIME, String.format(MISSING_PARAM_ERROR_TEXT,
                PARAM_END_TIME)));
    }

    /**
     * Initializes the {@code startTime} and {@code endTime} fields from the
     * respective arguments. If the {@code startTime} argument is empty, the
     * field is initialized to the beginning of time; if the {@code endTime}
     * argument is empty, the field is initialized to the time now. When this
     * method completes, either the fields are initialized, or they are set to
     * {@code null}, the error is logged, and the error text is set
     * appropriately. This can happen if the parameters are either missing, or
     * their content cannot be parsed.
     */
    public void parseStartEndTime(String startTimeString, String endTimeString) {
        // Assume the worst.
        startTime = null;
        endTime = null;

        log.debug("startTime=" + startTimeString);
        if (startTimeString == null) {
            return;
        }
        log.debug("endTime=" + endTimeString);
        if (endTimeString == null) {
            return;
        }

        // Parse the times. If startTimeString is empty, use the beginning of
        // time; if endTimeString is empty, use now. Since we push the date back
        // into the request parameters which subreports will see, we use the
        // relaxed formatter if we don't see a T, and the normal formatter if we
        // do. See Iso8601Formatter.RELAXED_DATE_TIME_FORMAT_STRING.
        try {
            startTime = startTimeString.trim()
                .length() == 0 ? new Date(0)
                : startTimeString.indexOf('T') < 0 ? relaxedDateTimeFormatter.parse(startTimeString)
                    : dateFormatter.parse(startTimeString);
            setRequestParameter(PARAM_START_TIME,
                dateFormatter.format(startTime));
        } catch (ParseException e) {
            String text = "Malformed " + PARAM_START_TIME + " string: "
                + startTimeString;
            if (getErrorText() == null) {
                setErrorText(text);
            }
            log.error(text, e);
        }

        try {
            endTime = endTimeString.trim()
                .length() == 0 ? new Date()
                : endTimeString.indexOf('T') < 0 ? relaxedDateTimeFormatter.parse(endTimeString)
                    : dateFormatter.parse(endTimeString);
            setRequestParameter(PARAM_END_TIME, dateFormatter.format(endTime));
        } catch (ParseException e) {
            String text = "Malformed " + PARAM_END_TIME + " string: "
                + endTimeString;
            if (getErrorText() == null) {
                setErrorText(text);
            }
            log.error(text, e);
        }

        if (getErrorText() != null) {
            startTime = null;
            endTime = null;
        }
    }

    /**
     * Initializes the {@code startCadence}, {@code endCadence}, and {@code
     * cadenceType} fields from their respective request parameters. If the
     * {@code startCadence} parameter is empty, the field is initialized to 0;
     * if the {@code endCadence} parameter is empty, the field is initialized to
     * a large value. When this method completes, either the fields are
     * initialized, or {@code startCadence} and {@code endCadence} are set to
     * {@link #INVALID_CADENCE} and {@link #cadenceType} is set to {@code null},
     * the error is logged, and the error text is set appropriately. This can
     * happen if the parameters are either missing, or their content cannot be
     * parsed.
     */
    public void expectCadenceParameters() {
        parseCadence(getRequestParameter(PARAM_START_CADENCE, String.format(
            MISSING_PARAM_ERROR_TEXT, PARAM_START_CADENCE)),
            getRequestParameter(PARAM_END_CADENCE, String.format(
                MISSING_PARAM_ERROR_TEXT, PARAM_END_CADENCE)),
            getRequestParameter(PARAM_CADENCE_TYPE, String.format(
                MISSING_PARAM_ERROR_TEXT, PARAM_CADENCE_TYPE)));
    }

    /**
     * Initializes the {@code startCadence}, {@code endCadence}, and {@code
     * cadenceType} fields from their respective arguments. If the {@code
     * startCadence} argument is empty, the field is initialized to 0; if the
     * {@code endCadence} argument is empty, the field is initialized to a large
     * value. When this method completes, either the fields are initialized, or
     * {@code startCadence} and {@code endCadence} are set to
     * {@link #INVALID_CADENCE} and {@code cadenceType} is set to {@code null},
     * the error is logged, and the error text is set appropriately. This can
     * happen if the arguments are either {@code null}, or their content cannot
     * be parsed.
     */
    private void parseCadence(String startCadenceString,
        String endCadenceString, String cadenceTypeString) {

        // Assume the worst.
        startCadence = INVALID_CADENCE;
        endCadence = INVALID_CADENCE;
        cadenceType = null;

        log.debug("startCadence=" + startCadenceString);
        if (startCadenceString == null) {
            return;
        }
        log.debug("endCadence=" + endCadenceString);
        if (endCadenceString == null) {
            return;
        }
        log.debug("cadenceType=" + cadenceTypeString);
        if (cadenceTypeString == null) {
            return;
        }

        // Parse the cadences. If startCadenceString is empty, use 0; if
        // endCadenceString is empty, use a large value.
        try {
            startCadence = startCadenceString.trim()
                .length() == 0 ? 0 : Integer.parseInt(startCadenceString);
            setRequestParameter(PARAM_START_CADENCE,
                Integer.toString(startCadence));
        } catch (NumberFormatException e) {
            String text = "Malformed " + PARAM_START_CADENCE + " string: "
                + startCadenceString;
            if (getErrorText() == null) {
                setErrorText(text);
            }
            log.error(text, e);
        }

        try {
            endCadence = endCadenceString.trim()
                .length() == 0 ? NICE_ROUND_INCONCEIVABLY_LARGE_CADENCE_NUMBER
                : Integer.parseInt(endCadenceString);
            setRequestParameter(PARAM_END_CADENCE, Integer.toString(endCadence));
        } catch (NumberFormatException e) {
            String text = "Malformed " + PARAM_END_CADENCE + " string: "
                + endCadenceString;
            if (getErrorText() == null) {
                setErrorText(text);
            }
            log.error(text, e);
        }

        try {
            cadenceType = CadenceType.valueOf(cadenceTypeString.trim());
        } catch (IllegalArgumentException e) {
            String text = "Malformed " + PARAM_CADENCE_TYPE + " string: "
                + cadenceTypeString;
            if (getErrorText() == null) {
                setErrorText(text);
            }
            log.error(text, e);
        }

        if (startCadence > endCadence) {
            String text = "Ending cadence " + endCadence
                + " must be less than or equal to starting cadence "
                + startCadence;
            if (getErrorText() == null) {
                setErrorText(text);
            }
            log.error(text);
        }
        if (getErrorText() != null) {
            startCadence = INVALID_CADENCE;
            endCadence = INVALID_CADENCE;
            cadenceType = null;
        }
    }

    /**
     * Initializes the {@code ccdModule} and {@code ccdOutput} fields from the
     * {@code moduleOutput} request parameter. When this method completes,
     * either the fields are initialized, or they are set to
     * {@link #INVALID_CCD_MODULE_OUTPUT}, the error is logged, and the error
     * text is set appropriately.
     */
    public void expectModuleOutputParameter() {
        parseModuleOutput(getRequestParameter(PARAM_MODULE_OUTPUT,
            String.format(MISSING_PARAM_ERROR_TEXT, PARAM_MODULE_OUTPUT)));
    }

    /**
     * Initializes the {@code ccdModule} and {@code ccdOutput} fields from the
     * {@code moduleOutputString} argument. When this method completes, either
     * the fields are initialized, or they are set to
     * {@link #INVALID_CCD_MODULE_OUTPUT}, the error is logged, and the error
     * text is set appropriately.
     */
    private void parseModuleOutput(String moduleOutputString) {
        // Assume the worst.
        ccdModule = INVALID_CCD_MODULE_OUTPUT;
        ccdOutput = INVALID_CCD_MODULE_OUTPUT;

        if (moduleOutputString == null) {
            return;
        }

        // Parse out the module and the output.
        try {
            int index = moduleOutputString.indexOf('/');
            if (index == -1 || index == 0
                || index == moduleOutputString.length() - 1) {
                String text = "Malformed " + PARAM_MODULE_OUTPUT + " string: "
                    + moduleOutputString;
                if (getErrorText() == null) {
                    setErrorText(text);
                }
                log.error(text);
                return;
            }
            ccdModule = Integer.parseInt(moduleOutputString.substring(0, index));
            ccdOutput = Integer.parseInt(moduleOutputString.substring(
                index + 1, moduleOutputString.length()));
        } catch (NumberFormatException e) {
            String text = "Malformed " + PARAM_MODULE_OUTPUT + " string: "
                + moduleOutputString;
            if (getErrorText() == null) {
                setErrorText(text);
            }
            log.error(text);
            ccdModule = INVALID_CCD_MODULE_OUTPUT;
            ccdOutput = INVALID_CCD_MODULE_OUTPUT;
            return;
        }

        // Validate.
        String text = null;
        if (!FcConstants.validCcdModule(ccdModule)) {
            String s = "Invalid module: " + ccdModule;
            log.error(s);
            text = s;
        }
        if (!FcConstants.validCcdOutput(ccdOutput)) {
            String s = "Invalid output: " + ccdOutput;
            log.error(s);
            text = text == null ? s : text + "\nError: " + s;
        }
        if (text != null) {
            if (getErrorText() == null) {
                setErrorText(text);
            }
            ccdModule = INVALID_CCD_MODULE_OUTPUT;
            ccdOutput = INVALID_CCD_MODULE_OUTPUT;
        }
    }

    /**
     * Initializes the {@code id} field from its request parameter. When this
     * method completes, either the field is initialized, or it is set to
     * {@link #INVALID_ID}, the error is logged, and the error text is set
     * appropriately. This can happen if the parameter is either missing, or its
     * content cannot be parsed.
     * <p>
     * However, if the {@code required} parameter is {@code false}, then the
     * field is either initialized as above or set to {@link #UNINITIALIZED_ID}
     * if it is missing (without logging errors).
     */
    public void expectIdParameter(boolean required) {
        parseId(required,
            getRequestParameter(PARAM_ID, required ? String.format(
                MISSING_PARAM_ERROR_TEXT, PARAM_ID) : null));
    }

    /**
     * Initializes the {@code id} field from the given argument. When this
     * method completes, either the field is initialized, or it is set to
     * {@link #INVALID_ID}, the error is logged, and the error text is set
     * appropriately. This can happen if the argument is either {@code null}, or
     * its content cannot be parsed.
     * <p>
     * However, if the {@code required} parameter is {@code false}, then the
     * field is either initialized as above or set to {@link #UNINITIALIZED_ID}
     * if it is {@code null} (without logging errors).
     */
    private void parseId(boolean required, String idString) {
        // Assume the worst (almost).
        id = required ? INVALID_ID : UNINITIALIZED_ID;

        log.debug("id=" + idString);
        if (idString == null) {
            return;
        }

        // Assume the worst.
        id = INVALID_ID;

        // Parse the ID.
        try {
            id = Long.parseLong(idString);
            setRequestParameter(PARAM_ID, Long.toString(id));
        } catch (NumberFormatException e) {
            String text = "Malformed " + PARAM_ID + " string: " + idString;
            if (getErrorText() == null) {
                setErrorText(text);
            }
            log.error(text, e);
            return;
        }
    }

    /**
     * Initializes the {@code pipelineTaskId} and {@code identifier} fields from
     * the {@code genericReportIdentifier} request parameter. When this method
     * completes, either the fields are initialized, or they are set to
     * {@link #INVALID_PIPELINE_TASK_ID} and {@code null} respectively, the
     * error is logged, and the error text is set appropriately.
     */
    public void expectGenericReportIdentifierParameter() {
        parseGenericReportIdentifier(getRequestParameter(
            PARAM_GENERIC_REPORT_IDENTIFIER, String.format(
                MISSING_PARAM_ERROR_TEXT, PARAM_GENERIC_REPORT_IDENTIFIER)));
    }

    /**
     * Initializes the {@code pipelineTaskId} and {@code identifier} fields from
     * the {@code genericReportIdentifierString} argument. When this method
     * completes, either the fields are initialized, or they are set to
     * {@link #INVALID_PIPELINE_TASK_ID} and {@code null} respectively, the
     * error is logged, and the error text is set appropriately.
     */
    private void parseGenericReportIdentifier(
        String genericReportIdentifierString) {

        // Assume the worst.
        pipelineTaskId = INVALID_PIPELINE_TASK_ID;
        identifier = null;

        if (genericReportIdentifierString == null) {
            return;
        }

        // Parse out the pipeline task ID and identifier.
        try {
            Pattern p = Pattern.compile("^\\s*(\\d+)\\s*?(.+?)?\\s*(\\([^(]+\\))?\\s*$");
            Matcher m = p.matcher(genericReportIdentifierString);
            if (!m.matches()) {
                String text = "Malformed " + PARAM_GENERIC_REPORT_IDENTIFIER
                    + " string: " + genericReportIdentifierString;
                if (getErrorText() == null) {
                    setErrorText(text);
                }
                log.error(text);
                return;
            }

            pipelineTaskId = Integer.parseInt(m.group(1));
            identifier = m.group(2);
            if (identifier != null) {
                identifier = identifier.trim();
                if (identifier.equals("") || identifier.equals(NO_DATA)) {
                    identifier = null;
                }
            }
        } catch (NumberFormatException e) {
            String text = "Malformed " + PARAM_GENERIC_REPORT_IDENTIFIER
                + " string: " + genericReportIdentifierString;
            if (getErrorText() == null) {
                setErrorText(text);
            }
            log.error(text);
            return;
        }
    }

    /**
     * Initializes the {@code sortBy} field from the {@code sortBy} request
     * parameter. When this method completes, either the field is initialized,
     * or it is set to {@link #INVALID_SORT_BY}, the error is logged, and the
     * error text is set appropriately.
     */
    public void expectSortByParameter() {
        parseSortBy(getRequestParameter(PARAM_SORT_BY, String.format(
            MISSING_PARAM_ERROR_TEXT, PARAM_SORT_BY)));
    }

    /**
     * Initializes the {@code sortBy} field from the given argument. When this
     * method completes, either the field is initialized, or it is set to
     * {@link #INVALID_SORT_BY}, the error is logged, and the error text is set
     * appropriately. This can happen if the argument is either {@code null}, or
     * its content cannot be parsed.
     */
    private void parseSortBy(String sortByString) {

        log.debug("sortBy=" + sortByString);
        if (sortByString == null) {
            sortBy = INVALID_SORT_BY;
            String text = "Missing " + PARAM_SORT_BY + " request parameter";
            if (getErrorText() == null) {
                setErrorText(text);
            }
            log.error(text);
            return;
        }

        // Parse the sort by parameter.
        try {
            int sortByValue = Integer.parseInt(sortByString);
            switch (sortByValue) {
                case 1:
                    sortBy = "socIngestTime";
                    break;
                case 2:
                    sortBy = "messageFileName";
                    break;
                case 3:
                    sortBy = "messageType";
                    break;
                default:
                    sortBy = INVALID_SORT_BY;
                    String text = "Invalid " + PARAM_SORT_BY + " string: "
                        + sortByString;
                    if (getErrorText() == null) {
                        setErrorText(text);
                    }
                    log.error(text);
                    break;
            }
        } catch (NumberFormatException e) {
            String text = "Malformed " + PARAM_SORT_BY + " string: "
                + sortByString;
            if (getErrorText() == null) {
                setErrorText(text);
            }
            log.error(text, e);
            return;
        }
    }

    /**
     * Initializes the {@code sortAscending} field from the {@code sortOrder}
     * request parameter. When this method completes, either the field is
     * initialized, or it is set to {@link #INVALID_SORT_ORDER}, the error is
     * logged, and the error text is set appropriately.
     */
    public void expectSortOrderParameter() {
        parseSortOrder(getRequestParameter(PARAM_SORT_ORDER, String.format(
            MISSING_PARAM_ERROR_TEXT, PARAM_SORT_ORDER)));
    }

    /**
     * Initializes the {@code sortAscending} field from the given argument. When
     * this method completes, either the field is initialized, or it is set to
     * {@link #INVALID_SORT_ORDER}, the error is logged, and the error text is
     * set appropriately. This can happen if the argument is either {@code null}
     * , or its content cannot be parsed.
     */
    private void parseSortOrder(String sortOrderString) {

        log.debug("sortOrder=" + sortOrderString);
        if (sortOrderString == null) {
            sortAscending = INVALID_SORT_ORDER;
            String text = "Missing " + PARAM_SORT_ORDER + " request parameter";
            if (getErrorText() == null) {
                setErrorText(text);
            }
            log.error(text);
            return;
        }

        // Parse the sort order parameter.
        try {
            int sortOrderValue = Integer.parseInt(sortOrderString);
            switch (sortOrderValue) {
                case 1:
                    sortAscending = Boolean.TRUE;
                    break;
                case 2:
                    sortAscending = Boolean.FALSE;
                    break;
                default:
                    sortAscending = INVALID_SORT_ORDER;
                    String text = "Invalid " + PARAM_SORT_ORDER + " string: "
                        + sortOrderString;
                    if (getErrorText() == null) {
                        setErrorText(text);
                    }
                    log.error(text);
                    break;
            }
        } catch (NumberFormatException e) {
            String text = "Malformed " + PARAM_SORT_ORDER + " string: "
                + sortOrderString;
            if (getErrorText() == null) {
                setErrorText(text);
            }
            log.error(text, e);
            return;
        }
    }

    /**
     * Returns the time specified in the {@code time} request parameter.
     * 
     * @return the time, or {@code null} if {@link #expectTimeParameter()} has
     * not been called or if the parameter was invalid or expected and missing.
     */
    public Date getTime() {
        return time;
    }

    /**
     * Returns the starting time specified in the {@code startTime} request
     * parameter.
     * 
     * @return the starting time, or {@code null} if
     * {@link #expectStartEndTimeParameters()} has not been called or if the
     * parameter was invalid or expected and missing.
     */
    public Date getStartTime() {
        return startTime;
    }

    /**
     * Returns the ending time specified in the {@code endTime} request
     * parameter.
     * 
     * @return the ending time, or {@code null} if
     * {@link #expectStartEndTimeParameters()} has not been called or if the
     * parameter was invalid or expected and missing.
     */
    public Date getEndTime() {
        return endTime;
    }

    /**
     * Returns the starting cadence specified in the {@code startCadence}
     * request parameter.
     * 
     * @return the starting cadence, or {@code UNINITIALIZED_CADENCE} if
     * {@link #expectCadenceParameters()} has not been called or
     * {@link #INVALID_CADENCE} if the parameter was invalid or expected and
     * missing.
     */
    public int getStartCadence() {
        return startCadence;
    }

    /**
     * Returns the ending cadence specified in the {@code endCadence} request
     * parameter.
     * 
     * @return the ending cadence, or {@code UNINITIALIZED_CADENCE} if
     * {@link #expectCadenceParameters()} has not been called or
     * {@link #INVALID_CADENCE} if the parameter was invalid or expected and
     * missing.
     */
    public int getEndCadence() {
        return endCadence;
    }

    /**
     * Returns the type of cadence specified in the {@code cadenceType} request
     * parameter.
     * 
     * @return the cadence type, or {@code null} if
     * {@link #expectCadenceParameters()} has not been called or if the
     * parameter was invalid or expected and missing.
     */
    public CadenceType getCadenceType() {
        return cadenceType;
    }

    /**
     * Returns the CCD module specified in the {@code moduleOutput} request
     * parameter.
     * 
     * @return the CCD module, or {@link #UNINITIALIZED_CCD_MODULE_OUTPUT} if
     * {@link #expectModuleOutputParameter()} has not been called (not
     * necessarily an error for summary pages), or
     * {@link #INVALID_CCD_MODULE_OUTPUT} if the parameter was invalid or
     * expected and missing.
     */
    public int getCcdModule() {
        return ccdModule;
    }

    /**
     * Returns the CCD output specified in the {@code moduleOutput} request
     * parameter.
     * 
     * @return the CCD output, or {@link #UNINITIALIZED_CCD_MODULE_OUTPUT} if
     * {@link #expectModuleOutputParameter()} has not been called (not
     * necessarily an error for summary pages), or
     * {@link #INVALID_CCD_MODULE_OUTPUT} if the parameter was invalid or
     * expected and missing.
     */
    public int getCcdOutput() {
        return ccdOutput;
    }

    /**
     * Returns the ID specified in the {@code id} request parameter.
     * 
     * @return the ID, or {@link #UNINITIALIZED_ID} if
     * {@link #expectIdParameter(boolean)} has not been called (not necessarily
     * an error for summary pages), or {@link #INVALID_ID} if the parameter was
     * invalid or expected and missing.
     */
    public long getId() {
        return id;
    }

    /**
     * Returns the pipeline task ID specified in the {@code
     * genericReportIdentifier} request parameter.
     * 
     * @return the ID, or {@link #UNINITIALIZED_PIPELINE_TASK_ID} if
     * {@link #expectGenericReportIdentifierParameter(boolean)} has not been
     * called, or {@link #INVALID_PIPELINE_TASK_ID} if the parameter was invalid
     * or expected and missing.
     */
    public long getPipelineTaskId() {
        return pipelineTaskId;
    }

    /**
     * Returns the field to sort by specified in the {@code sortBy} request
     * parameter.
     * 
     * @return the sort field, or {@link #INVALID_SORT_BY} if the parameter was
     * invalid or expected and missing.
     */
    public String getSortBy() {
        return sortBy;
    }

    /**
     * Returns the direction to sort by specified in the {@code sortOrder}
     * request parameter.
     * 
     * @return the ID, or {@link #INVALID_SORT_ORDER} if the parameter was
     * invalid or expected and missing.
     */
    public Boolean getSortAscending() {
        return sortAscending;
    }

    /**
     * Returns the identifier specified in the {@code genericReportIdentifier}
     * request parameter.
     * 
     * @return the identifier, which may be {@code null} if the parameter did
     * not provide one
     */
    public String getIdentifier() {
        return identifier;
    }

    public void setWarningText(String text) {
        warningText = text == null ? null : "Warning: " + text;
    }

    public String getWarningText() {
        return warningText;
    }

    public void setErrorText(String text) {
        errorText = text == null ? null : "Error: " + text;
    }

    public String getErrorText() {
        return errorText;
    }
}
