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

import static gov.nasa.kepler.mr.ParameterUtil.INVALID_CADENCE;
import static gov.nasa.kepler.mr.ParameterUtil.INVALID_CCD_MODULE_OUTPUT;
import static gov.nasa.kepler.mr.ParameterUtil.INVALID_ID;
import static gov.nasa.kepler.mr.ParameterUtil.INVALID_PIPELINE_TASK_ID;
import static gov.nasa.kepler.mr.ParameterUtil.MISSING_PARAM_ERROR_TEXT;
import static gov.nasa.kepler.mr.ParameterUtil.PARAM_CADENCE_TYPE;
import static gov.nasa.kepler.mr.ParameterUtil.PARAM_END_CADENCE;
import static gov.nasa.kepler.mr.ParameterUtil.PARAM_END_TIME;
import static gov.nasa.kepler.mr.ParameterUtil.PARAM_GENERIC_REPORT_IDENTIFIER;
import static gov.nasa.kepler.mr.ParameterUtil.PARAM_ID;
import static gov.nasa.kepler.mr.ParameterUtil.PARAM_MODULE_OUTPUT;
import static gov.nasa.kepler.mr.ParameterUtil.PARAM_START_CADENCE;
import static gov.nasa.kepler.mr.ParameterUtil.PARAM_START_TIME;
import static gov.nasa.kepler.mr.ParameterUtil.PARAM_TIME;
import static gov.nasa.kepler.mr.ParameterUtil.UNINITIALIZED_ID;
import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotSame;
import static org.junit.Assert.assertNull;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.Iso8601Formatter;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link ParameterUtil} class.
 * 
 * @author Bill Wohler
 */
public class ParameterUtilTest {

    private static final int START_CADENCE = 42;
    private static final int END_CADENCE = 84;
    private static final Date DATE = new Date();

    private ParameterUtil parameterUtil = new ParameterUtil();

    @Before
    public void setUp() {
        parameterUtil.setReportParameters(new HashMap<String, Object>());
        parameterUtil.setGenerationParameters(new HashMap<String, Object>());
    }

    @Test
    public void testReportParameters() {
        Map<String, Object> reportParameters = new HashMap<String, Object>();
        parameterUtil.setReportParameters(reportParameters);
        assertEquals(reportParameters, parameterUtil.getReportParameters());
        HashMap<String, Object> newReportParameters = new HashMap<String, Object>();
        newReportParameters.put("foo", "foo");
        parameterUtil.setReportParameters(newReportParameters);
        assertNotSame(reportParameters, newReportParameters);
        assertEquals(newReportParameters, parameterUtil.getReportParameters());

        // For code coverage only.
        new ParameterUtil(reportParameters);
    }

    @Test
    public void testGenerationParameters() {
        Map<String, Object> generationParameters = new HashMap<String, Object>();
        parameterUtil.setGenerationParameters(generationParameters);
        assertEquals(generationParameters,
            parameterUtil.getGenerationParameters());
        Map<String, Object> newGenerationParameters = new HashMap<String, Object>();
        newGenerationParameters.put("foo", "foo");
        parameterUtil.setGenerationParameters(newGenerationParameters);
        assertNotSame(generationParameters, newGenerationParameters);
        assertEquals(newGenerationParameters,
            parameterUtil.getGenerationParameters());
    }

    @Test
    public void testRequestParameter() {
        String requestParameter = "requestParameter";
        parameterUtil.setRequestParameter(requestParameter, requestParameter);
        assertEquals(requestParameter,
            parameterUtil.getRequestParameter(requestParameter, "error"));
        parameterUtil.setRequestParameter(requestParameter, "bar");
        assertNotSame(requestParameter,
            parameterUtil.getRequestParameter(requestParameter, "error"));
        parameterUtil.setRequestParameter("foo", "bar");
        assertEquals("bar", parameterUtil.getRequestParameter("foo", "error"));
        parameterUtil.setRequestParameter(requestParameter, null);
        assertEquals("",
            parameterUtil.getRequestParameter(requestParameter, "error"));
        parameterUtil.setRequestParameter(requestParameter, "");
        assertEquals("",
            parameterUtil.getRequestParameter(requestParameter, "error"));
    }

    @Test
    public void testRequestParameters() {
        String[] requestParameters = { "requestParameter1", "requestParameter2" };
        parameterUtil.setRequestParameters(requestParameters[0],
            requestParameters);
        assertArrayEquals(requestParameters,
            parameterUtil.getRequestParameters(requestParameters[0], "error"));
        String[] newRequestParameters = new String[] { "foo", "bar" };
        parameterUtil.setRequestParameters(requestParameters[0],
            newRequestParameters);
        assertNotSame(requestParameters,
            parameterUtil.getRequestParameters(requestParameters[0], "error"));
        assertArrayEquals(newRequestParameters,
            parameterUtil.getRequestParameters(requestParameters[0], "error"));
    }

    @Test
    public void testExpectTimeParameterNoParameter() {
        parameterUtil.expectTimeParameter();
        assertNull(parameterUtil.getTime());
        assertEquals(
            String.format("Error: " + MISSING_PARAM_ERROR_TEXT, PARAM_TIME),
            parameterUtil.getErrorText());
    }

    @Test
    public void testExpectTimeParameterEmptyParameter() {
        parameterUtil.setRequestParameter(PARAM_TIME, "");
        parameterUtil.expectTimeParameter();
        assertEquals(new Date().getTime(), parameterUtil.getTime()
            .getTime(), 2000);
        assertNull(parameterUtil.getErrorText());
    }

    @Test
    public void testExpectTimeParameterInvalidDate() {
        parameterUtil.setRequestParameter(PARAM_TIME, "foo");
        parameterUtil.expectTimeParameter();
        assertNull(parameterUtil.getTime());
        assertEquals("Error: Unparseable date: \"foo\"",
            parameterUtil.getErrorText());
    }

    @Test
    public void testExpectTimeParameterNormal() {
        parameterUtil.setRequestParameter(PARAM_TIME,
            Iso8601Formatter.dateTimeFormatter()
                .format(DATE));
        parameterUtil.expectTimeParameter();
        assertEquals(DATE.getTime(), parameterUtil.getTime()
            .getTime(), 2000);
        assertNull(parameterUtil.getErrorText());
    }

    @Test
    public void testExpectTimeParameterRelaxed() {
        parameterUtil.setRequestParameter(PARAM_TIME,
            Iso8601Formatter.relaxedDateTimeFormatter()
                .format(DATE));
        parameterUtil.expectTimeParameter();
        assertEquals(DATE.getTime(), parameterUtil.getTime()
            .getTime(), 2000);
        assertNull(parameterUtil.getErrorText());
    }

    @Test
    public void testExpectStartEndTimeParametersNoParameters1() {
        parameterUtil.expectStartEndTimeParameters();
        assertNull(parameterUtil.getStartTime());
        assertNull(parameterUtil.getEndTime());
        assertEquals(String.format("Error: " + MISSING_PARAM_ERROR_TEXT,
            PARAM_START_TIME), parameterUtil.getErrorText());
    }

    @Test
    public void testExpectStartEndTimeParametersNoParameters2() {
        parameterUtil.setRequestParameter(PARAM_START_TIME, "");
        parameterUtil.expectStartEndTimeParameters();
        assertNull(parameterUtil.getStartTime());
        assertNull(parameterUtil.getEndTime());
        assertEquals(
            String.format("Error: " + MISSING_PARAM_ERROR_TEXT, PARAM_END_TIME),
            parameterUtil.getErrorText());
    }

    @Test
    public void testExpectStartEndTimeParametersEmptyParameters() {
        parameterUtil.setRequestParameter(PARAM_START_TIME, "");
        parameterUtil.setRequestParameter(PARAM_END_TIME, "");
        parameterUtil.expectStartEndTimeParameters();
        assertEquals(new Date(0).getTime(), parameterUtil.getStartTime()
            .getTime(), 2000);
        assertEquals(DATE.getTime(), parameterUtil.getEndTime()
            .getTime(), 2000);
        assertNull(parameterUtil.getErrorText());
    }

    @Test
    public void testExpectStartEndTimeParametersInvalidStart() {
        parameterUtil.setRequestParameter(PARAM_START_TIME, "foo");
        parameterUtil.setRequestParameter(PARAM_END_TIME,
            Iso8601Formatter.relaxedDateTimeFormatter()
                .format(DATE));
        parameterUtil.expectStartEndTimeParameters();
        assertNull(parameterUtil.getStartTime());
        assertNull(parameterUtil.getEndTime());
        assertEquals("Error: Malformed " + PARAM_START_TIME + " string: foo",
            parameterUtil.getErrorText());
    }

    @Test
    public void testExpectStartEndTimeParametersInvalidEnd() {
        parameterUtil.setRequestParameter(PARAM_START_TIME,
            Iso8601Formatter.relaxedDateTimeFormatter()
                .format(DATE));
        parameterUtil.setRequestParameter(PARAM_END_TIME, "foo");
        parameterUtil.expectStartEndTimeParameters();
        assertNull(parameterUtil.getStartTime());
        assertNull(parameterUtil.getEndTime());
        assertEquals("Error: Malformed " + PARAM_END_TIME + " string: foo",
            parameterUtil.getErrorText());
    }

    @Test
    public void testExpectStartEndTimeParametersNormal() {
        parameterUtil.setRequestParameter(PARAM_START_TIME,
            Iso8601Formatter.dateTimeFormatter()
                .format(DATE));
        parameterUtil.setRequestParameter(PARAM_END_TIME,
            Iso8601Formatter.dateTimeFormatter()
                .format(DATE));
        parameterUtil.expectStartEndTimeParameters();
        assertEquals(DATE.getTime(), parameterUtil.getStartTime()
            .getTime(), 2000);
        assertEquals(DATE.getTime(), parameterUtil.getEndTime()
            .getTime(), 2000);
        assertNull(parameterUtil.getErrorText());
    }

    @Test
    public void testExpectStartEndTimeParametersRelaxed() {
        parameterUtil.setRequestParameter(PARAM_START_TIME,
            Iso8601Formatter.relaxedDateTimeFormatter()
                .format(DATE));
        parameterUtil.setRequestParameter(PARAM_END_TIME,
            Iso8601Formatter.relaxedDateTimeFormatter()
                .format(DATE));
        parameterUtil.expectStartEndTimeParameters();
        assertEquals(DATE.getTime(), parameterUtil.getStartTime()
            .getTime(), 2000);
        assertEquals(DATE.getTime(), parameterUtil.getEndTime()
            .getTime(), 2000);
        assertNull(parameterUtil.getErrorText());
    }

    @Test
    public void testExpectCadenceParametersNoParameters1() {
        parameterUtil.expectCadenceParameters();
        assertEquals(INVALID_CADENCE, parameterUtil.getStartCadence());
        assertEquals(INVALID_CADENCE, parameterUtil.getEndCadence());
        assertNull(parameterUtil.getCadenceType());
        assertEquals(String.format("Error: " + MISSING_PARAM_ERROR_TEXT,
            PARAM_START_CADENCE), parameterUtil.getErrorText());
    }

    @Test
    public void testExpectCadenceParametersNoParameters2() {
        parameterUtil.setRequestParameter(PARAM_START_CADENCE, "");
        parameterUtil.expectCadenceParameters();
        assertEquals(INVALID_CADENCE, parameterUtil.getStartCadence());
        assertEquals(INVALID_CADENCE, parameterUtil.getEndCadence());
        assertNull(parameterUtil.getCadenceType());
        assertEquals(String.format("Error: " + MISSING_PARAM_ERROR_TEXT,
            PARAM_END_CADENCE), parameterUtil.getErrorText());
    }

    @Test
    public void testExpectCadenceParametersNoParameters3() {
        parameterUtil.setRequestParameter(PARAM_START_CADENCE, "");
        parameterUtil.setRequestParameter(PARAM_END_CADENCE, "");
        parameterUtil.expectCadenceParameters();
        assertEquals(INVALID_CADENCE, parameterUtil.getStartCadence());
        assertEquals(INVALID_CADENCE, parameterUtil.getEndCadence());
        assertNull(parameterUtil.getCadenceType());
        assertEquals(String.format("Error: " + MISSING_PARAM_ERROR_TEXT,
            PARAM_CADENCE_TYPE), parameterUtil.getErrorText());
    }

    @Test
    public void testExpectCadenceParametersEmptyParameters() {
        parameterUtil.setRequestParameter(PARAM_START_CADENCE, "");
        parameterUtil.setRequestParameter(PARAM_END_CADENCE, "");
        parameterUtil.setRequestParameter(PARAM_CADENCE_TYPE, "");
        parameterUtil.expectCadenceParameters();
        assertEquals(INVALID_CADENCE, parameterUtil.getStartCadence());
        assertEquals(INVALID_CADENCE, parameterUtil.getEndCadence());
        assertNull(parameterUtil.getCadenceType());
        assertEquals("Error: Malformed " + PARAM_CADENCE_TYPE + " string: ",
            parameterUtil.getErrorText());
    }

    @Test
    public void testExpectCadenceParametersInvalidStartEndType() {
        parameterUtil.setRequestParameter(PARAM_START_CADENCE, "foo");
        parameterUtil.setRequestParameter(PARAM_END_CADENCE, "bar");
        parameterUtil.setRequestParameter(PARAM_CADENCE_TYPE, "baz");
        parameterUtil.expectCadenceParameters();
        assertEquals(INVALID_CADENCE, parameterUtil.getStartCadence());
        assertEquals(INVALID_CADENCE, parameterUtil.getEndCadence());
        assertNull(parameterUtil.getCadenceType());
        assertEquals(
            "Error: Malformed " + PARAM_START_CADENCE + " string: foo",
            parameterUtil.getErrorText());
    }

    @Test
    public void testExpectCadenceParametersInvalidStart() {
        parameterUtil.setRequestParameter(PARAM_START_CADENCE, "foo");
        parameterUtil.setRequestParameter(PARAM_END_CADENCE,
            Integer.toString(END_CADENCE));
        parameterUtil.setRequestParameter(PARAM_CADENCE_TYPE,
            CadenceType.LONG.toString());
        parameterUtil.expectCadenceParameters();
        assertEquals(INVALID_CADENCE, parameterUtil.getStartCadence());
        assertEquals(INVALID_CADENCE, parameterUtil.getEndCadence());
        assertNull(parameterUtil.getCadenceType());
        assertEquals(
            "Error: Malformed " + PARAM_START_CADENCE + " string: foo",
            parameterUtil.getErrorText());
    }

    @Test
    public void testExpectCadenceParametersInvalidEnd() {
        parameterUtil.setRequestParameter(PARAM_START_CADENCE,
            Integer.toString(START_CADENCE));
        parameterUtil.setRequestParameter(PARAM_END_CADENCE, "bar");
        parameterUtil.setRequestParameter(PARAM_CADENCE_TYPE,
            CadenceType.LONG.toString());
        parameterUtil.expectCadenceParameters();
        assertEquals(INVALID_CADENCE, parameterUtil.getStartCadence());
        assertEquals(INVALID_CADENCE, parameterUtil.getEndCadence());
        assertNull(parameterUtil.getCadenceType());
        assertEquals("Error: Malformed " + PARAM_END_CADENCE + " string: bar",
            parameterUtil.getErrorText());
    }

    @Test
    public void testExpectCadenceParametersInvalidType() {
        parameterUtil.setRequestParameter(PARAM_START_CADENCE,
            Integer.toString(START_CADENCE));
        parameterUtil.setRequestParameter(PARAM_END_CADENCE,
            Integer.toString(END_CADENCE));
        parameterUtil.setRequestParameter(PARAM_CADENCE_TYPE, "baz");
        parameterUtil.expectCadenceParameters();
        assertEquals(INVALID_CADENCE, parameterUtil.getStartCadence());
        assertEquals(INVALID_CADENCE, parameterUtil.getEndCadence());
        assertNull(parameterUtil.getCadenceType());
        assertEquals("Error: Malformed " + PARAM_CADENCE_TYPE + " string: baz",
            parameterUtil.getErrorText());
    }

    @Test
    public void testExpectCadenceParametersEndLessThanStart() {
        parameterUtil.setRequestParameter(PARAM_START_CADENCE,
            Integer.toString(END_CADENCE));
        parameterUtil.setRequestParameter(PARAM_END_CADENCE,
            Integer.toString(START_CADENCE));
        parameterUtil.setRequestParameter(PARAM_CADENCE_TYPE,
            CadenceType.LONG.toString());
        parameterUtil.expectCadenceParameters();
        assertEquals(INVALID_CADENCE, parameterUtil.getStartCadence());
        assertEquals(INVALID_CADENCE, parameterUtil.getEndCadence());
        assertNull(parameterUtil.getCadenceType());
        assertEquals("Error: Ending cadence " + START_CADENCE
            + " must be less than or equal to starting cadence " + END_CADENCE,
            parameterUtil.getErrorText());
    }

    @Test
    public void testExpectCadenceParametersEmptyButValidParameters() {
        parameterUtil.setRequestParameter(PARAM_START_CADENCE, "");
        parameterUtil.setRequestParameter(PARAM_END_CADENCE, "");
        parameterUtil.setRequestParameter(PARAM_CADENCE_TYPE,
            CadenceType.LONG.toString());
        parameterUtil.expectCadenceParameters();
        assertEquals(0, parameterUtil.getStartCadence());
        assertEquals(
            ParameterUtil.NICE_ROUND_INCONCEIVABLY_LARGE_CADENCE_NUMBER,
            parameterUtil.getEndCadence());
        assertEquals(CadenceType.LONG, parameterUtil.getCadenceType());
        assertNull(parameterUtil.getErrorText());
    }

    @Test
    public void testExpectCadenceParameters() {
        parameterUtil.setRequestParameter(PARAM_START_CADENCE,
            Integer.toString(START_CADENCE));
        parameterUtil.setRequestParameter(PARAM_END_CADENCE,
            Integer.toString(END_CADENCE));
        parameterUtil.setRequestParameter(PARAM_CADENCE_TYPE,
            CadenceType.LONG.toString());
        parameterUtil.expectCadenceParameters();
        assertEquals(START_CADENCE, parameterUtil.getStartCadence());
        assertEquals(END_CADENCE, parameterUtil.getEndCadence());
        assertEquals(CadenceType.LONG, parameterUtil.getCadenceType());
    }

    @Test
    public void testExpectModuleOutputParameterNoParameters() {
        parameterUtil.expectModuleOutputParameter();
        assertEquals(INVALID_CCD_MODULE_OUTPUT, parameterUtil.getCcdModule());
        assertEquals(INVALID_CCD_MODULE_OUTPUT, parameterUtil.getCcdOutput());
        assertEquals(String.format("Error: " + MISSING_PARAM_ERROR_TEXT,
            PARAM_MODULE_OUTPUT), parameterUtil.getErrorText());
    }

    @Test
    public void testExpectModuleOutputParameterEmptyParameter() {
        parameterUtil.setRequestParameter(PARAM_MODULE_OUTPUT, "");
        parameterUtil.expectModuleOutputParameter();
        assertEquals(INVALID_CCD_MODULE_OUTPUT, parameterUtil.getCcdModule());
        assertEquals(INVALID_CCD_MODULE_OUTPUT, parameterUtil.getCcdOutput());
        assertEquals("Error: Malformed " + PARAM_MODULE_OUTPUT + " string: ",
            parameterUtil.getErrorText());
    }

    @Test
    public void testExpectModuleOutputParameterInvalidString1() {
        parameterUtil.setRequestParameter(PARAM_MODULE_OUTPUT, "foo");
        parameterUtil.expectModuleOutputParameter();
        assertEquals(INVALID_CCD_MODULE_OUTPUT, parameterUtil.getCcdModule());
        assertEquals(INVALID_CCD_MODULE_OUTPUT, parameterUtil.getCcdOutput());
        assertEquals(
            "Error: Malformed " + PARAM_MODULE_OUTPUT + " string: foo",
            parameterUtil.getErrorText());
    }

    @Test
    public void testExpectModuleOutputParameterInvalidString2() {
        parameterUtil.setRequestParameter(PARAM_MODULE_OUTPUT, "foo/bar");
        parameterUtil.expectModuleOutputParameter();
        assertEquals(INVALID_CCD_MODULE_OUTPUT, parameterUtil.getCcdModule());
        assertEquals(INVALID_CCD_MODULE_OUTPUT, parameterUtil.getCcdOutput());
        assertEquals("Error: Malformed " + PARAM_MODULE_OUTPUT
            + " string: foo/bar", parameterUtil.getErrorText());
    }

    @Test
    public void testExpectModuleOutputParameterInvalidModuleOutput() {
        parameterUtil.setRequestParameter(PARAM_MODULE_OUTPUT, "1/5");
        parameterUtil.expectModuleOutputParameter();
        assertEquals(INVALID_CCD_MODULE_OUTPUT, parameterUtil.getCcdModule());
        assertEquals(INVALID_CCD_MODULE_OUTPUT, parameterUtil.getCcdOutput());
        assertEquals("Error: Invalid module: 1\nError: Invalid output: 5",
            parameterUtil.getErrorText());
    }

    @Test
    public void testExpectModuleOutputParameterInvalidModule() {
        parameterUtil.setRequestParameter(PARAM_MODULE_OUTPUT, "1/2");
        parameterUtil.expectModuleOutputParameter();
        assertEquals(INVALID_CCD_MODULE_OUTPUT, parameterUtil.getCcdModule());
        assertEquals(INVALID_CCD_MODULE_OUTPUT, parameterUtil.getCcdOutput());
        assertEquals("Error: Invalid module: 1", parameterUtil.getErrorText());
    }

    @Test
    public void testExpectModuleOutputParameterInvalidOutput() {
        parameterUtil.setRequestParameter(PARAM_MODULE_OUTPUT, "2/5");
        parameterUtil.expectModuleOutputParameter();
        assertEquals(INVALID_CCD_MODULE_OUTPUT, parameterUtil.getCcdModule());
        assertEquals(INVALID_CCD_MODULE_OUTPUT, parameterUtil.getCcdOutput());
        assertEquals("Error: Invalid output: 5", parameterUtil.getErrorText());
    }

    @Test
    public void testExpectModuleOutputParameter() {
        parameterUtil.setRequestParameter(PARAM_MODULE_OUTPUT, "2/1");
        parameterUtil.expectModuleOutputParameter();
        assertEquals(2, parameterUtil.getCcdModule());
        assertEquals(1, parameterUtil.getCcdOutput());
        assertNull(parameterUtil.getErrorText());
    }

    @Test
    public void testExpectIdParameterRequiredNoParameters() {
        parameterUtil.expectIdParameter(true);
        assertEquals(INVALID_ID, parameterUtil.getId());
        assertEquals(
            String.format("Error: " + MISSING_PARAM_ERROR_TEXT, PARAM_ID),
            parameterUtil.getErrorText());
    }

    @Test
    public void testExpectIdParameterRequiredEmptyParameter() {
        parameterUtil.setRequestParameter(PARAM_ID, "");
        parameterUtil.expectIdParameter(true);
        assertEquals(INVALID_ID, parameterUtil.getId());
        assertEquals("Error: Malformed " + PARAM_ID + " string: ",
            parameterUtil.getErrorText());
    }

    @Test
    public void testExpectIdParameterRequiredInvalidId() {
        parameterUtil.setRequestParameter(PARAM_ID, "foo");
        parameterUtil.expectIdParameter(true);
        assertEquals(INVALID_ID, parameterUtil.getId());
        assertEquals("Error: Malformed " + PARAM_ID + " string: foo",
            parameterUtil.getErrorText());
    }

    @Test
    public void testExpectIdParameterRequired() {
        parameterUtil.setRequestParameter(PARAM_ID, "42");
        parameterUtil.expectIdParameter(true);
        assertEquals(42, parameterUtil.getId());
        assertNull(parameterUtil.getErrorText());
    }

    @Test
    public void testExpectIdParameterNotRequiredNoParameters() {
        parameterUtil.expectIdParameter(false);
        assertEquals(UNINITIALIZED_ID, parameterUtil.getId());
        assertNull(parameterUtil.getErrorText());
    }

    @Test
    public void testExpectIdParameterNotRequiredEmptyParameter() {
        parameterUtil.setRequestParameter(PARAM_ID, "");
        parameterUtil.expectIdParameter(false);
        assertEquals(INVALID_ID, parameterUtil.getId());
        assertEquals("Error: Malformed " + PARAM_ID + " string: ",
            parameterUtil.getErrorText());
    }

    @Test
    public void testExpectIdParameterNotRequiredInvalidId() {
        parameterUtil.setRequestParameter(PARAM_ID, "foo");
        parameterUtil.expectIdParameter(false);
        assertEquals(INVALID_ID, parameterUtil.getId());
        assertEquals("Error: Malformed " + PARAM_ID + " string: foo",
            parameterUtil.getErrorText());
    }

    @Test
    public void testExpectIdParameterNotRequired() {
        parameterUtil.setRequestParameter(PARAM_ID, "42");
        parameterUtil.expectIdParameter(false);
        assertEquals(42, parameterUtil.getId());
        assertNull(parameterUtil.getErrorText());
    }

    @Test
    public void testExpectGenericReportIdentifierParameterNoParameters() {
        parameterUtil.expectGenericReportIdentifierParameter();
        assertEquals(INVALID_PIPELINE_TASK_ID,
            parameterUtil.getPipelineTaskId());
        assertNull(parameterUtil.getIdentifier());
        assertEquals(String.format("Error: " + MISSING_PARAM_ERROR_TEXT,
            PARAM_GENERIC_REPORT_IDENTIFIER), parameterUtil.getErrorText());
    }

    @Test
    public void testExpectGenericReportIdentifierParameterEmptyParameters() {
        parameterUtil.setRequestParameter(PARAM_GENERIC_REPORT_IDENTIFIER, "");
        parameterUtil.expectGenericReportIdentifierParameter();
        assertEquals(INVALID_PIPELINE_TASK_ID,
            parameterUtil.getPipelineTaskId());
        assertNull(parameterUtil.getIdentifier());
        assertEquals("Error: Malformed " + PARAM_GENERIC_REPORT_IDENTIFIER
            + " string: ", parameterUtil.getErrorText());
    }

    @Test
    public void testExpectGenericReportIdentifierParameterInvalidString() {
        parameterUtil.setRequestParameter(PARAM_GENERIC_REPORT_IDENTIFIER,
            "foo");
        parameterUtil.expectGenericReportIdentifierParameter();
        assertEquals(INVALID_PIPELINE_TASK_ID,
            parameterUtil.getPipelineTaskId());
        assertNull(parameterUtil.getIdentifier());
        assertEquals("Error: Malformed " + PARAM_GENERIC_REPORT_IDENTIFIER
            + " string: foo", parameterUtil.getErrorText());
    }

    @Test
    public void testExpectGenericReportIdentifierParameterInvalidPipeline() {
        parameterUtil.setRequestParameter(PARAM_GENERIC_REPORT_IDENTIFIER,
            "foo id (uow)");
        parameterUtil.expectGenericReportIdentifierParameter();
        assertEquals(INVALID_PIPELINE_TASK_ID,
            parameterUtil.getPipelineTaskId());
        assertNull(parameterUtil.getIdentifier());
        assertEquals("Error: Malformed " + PARAM_GENERIC_REPORT_IDENTIFIER
            + " string: foo id (uow)", parameterUtil.getErrorText());
    }

    @Test
    public void testExpectGenericReportIdentifierParameter() {
        parameterUtil.setRequestParameter(PARAM_GENERIC_REPORT_IDENTIFIER,
            "42 id (uow)");
        parameterUtil.expectGenericReportIdentifierParameter();
        assertEquals(42, parameterUtil.getPipelineTaskId());
        assertEquals("id", parameterUtil.getIdentifier());
        assertNull(parameterUtil.getErrorText());

        parameterUtil.setRequestParameter(PARAM_GENERIC_REPORT_IDENTIFIER,
            "42       id  id     (uow)");
        parameterUtil.expectGenericReportIdentifierParameter();
        assertEquals(42, parameterUtil.getPipelineTaskId());
        assertEquals("id  id", parameterUtil.getIdentifier());
        assertNull(parameterUtil.getErrorText());

        parameterUtil.setRequestParameter(PARAM_GENERIC_REPORT_IDENTIFIER,
            "42 12345678 (uow)");
        parameterUtil.expectGenericReportIdentifierParameter();
        assertEquals(42, parameterUtil.getPipelineTaskId());
        assertEquals("12345678", parameterUtil.getIdentifier());
        assertNull(parameterUtil.getErrorText());

        parameterUtil.setRequestParameter(PARAM_GENERIC_REPORT_IDENTIFIER,
            "  53          -            ([0,349])");
        parameterUtil.expectGenericReportIdentifierParameter();
        assertEquals(53, parameterUtil.getPipelineTaskId());
        assertNull(parameterUtil.getIdentifier());
        assertNull(parameterUtil.getErrorText());
    }

    @Test
    public void testExpectGenericReportIdentifierParameterNoUow() {
        parameterUtil.setRequestParameter(PARAM_GENERIC_REPORT_IDENTIFIER,
            "42 id");
        parameterUtil.expectGenericReportIdentifierParameter();
        assertEquals(42, parameterUtil.getPipelineTaskId());
        assertEquals("id", parameterUtil.getIdentifier());
        assertNull(parameterUtil.getErrorText());
    }

    @Test
    public void testExpectGenericReportIdentifierParameterNoIdentifier() {
        parameterUtil.setRequestParameter(PARAM_GENERIC_REPORT_IDENTIFIER,
            "42 (uow)");
        parameterUtil.expectGenericReportIdentifierParameter();
        assertEquals(42, parameterUtil.getPipelineTaskId());
        assertNull(parameterUtil.getIdentifier(), parameterUtil.getIdentifier());
        assertNull(parameterUtil.getErrorText());
    }

    @Test
    public void testExpectGenericReportIdentifierParameterNoUowNoIdentifier() {
        parameterUtil.setRequestParameter(PARAM_GENERIC_REPORT_IDENTIFIER, "42");
        parameterUtil.expectGenericReportIdentifierParameter();
        assertEquals(42, parameterUtil.getPipelineTaskId());
        assertNull(parameterUtil.getIdentifier());
        assertNull(parameterUtil.getErrorText());
    }

    @Test
    public void testExpectGenericReportIdentifierParameterParensInIdentifier() {
        parameterUtil.setRequestParameter(PARAM_GENERIC_REPORT_IDENTIFIER,
            "42 (id id) (uow uow)");
        parameterUtil.expectGenericReportIdentifierParameter();
        assertEquals(42, parameterUtil.getPipelineTaskId());
        assertEquals("(id id)", parameterUtil.getIdentifier());
        assertNull(parameterUtil.getErrorText());
    }

    @Test
    public void testSetWarningText() {
        assertNull(parameterUtil.getWarningText());
        parameterUtil.setWarningText("foo");
        assertEquals("Warning: foo", parameterUtil.getWarningText());
        parameterUtil.setWarningText(null);
        assertNull(parameterUtil.getWarningText());
    }

    @Test
    public void testSetErrorText() {
        assertNull(parameterUtil.getErrorText());
        parameterUtil.setErrorText("foo");
        assertEquals("Error: foo", parameterUtil.getErrorText());
        parameterUtil.setErrorText(null);
        assertNull(parameterUtil.getErrorText());
    }
}
