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

import static gov.nasa.kepler.mr.ParameterUtil.MISSING_PARAM_ERROR_TEXT;
import static gov.nasa.kepler.mr.ParameterUtil.PARAM_MODULE_OUTPUT;
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.mr.ParameterUtil;

import java.util.HashMap;
import java.util.LinkedHashMap;

import org.junit.Test;

public class BaseScriptletTest {

    private BaseScriptlet createScriptlet() {
        BaseScriptlet scriptlet = new BaseScriptlet();
        scriptlet.setReportParameters(new HashMap<String, Object>());
        scriptlet.setGenerationParameters(new LinkedHashMap<String, Object>());

        return scriptlet;
    }

    @Test
    public void testGetRequestParameter() {
        BaseScriptlet scriptlet = createScriptlet();
        assertEquals(null, scriptlet.getRequestParameter("foo", "error"));
        assertEquals("Error: error", scriptlet.getErrorText());

        scriptlet.setErrorText(null);
        scriptlet.getGenerationParameters()
            .put("foo", new String[] { "bar" });
        assertEquals("bar", scriptlet.getRequestParameter("foo", "error"));
        assertEquals(null, scriptlet.getErrorText());
    }

    @Test
    public void testPrintParams() {
        // Print no parameters.
        BaseScriptlet scriptlet = createScriptlet();
        assertEquals("", scriptlet.printParams());

        // Print a single parameter.
        scriptlet.getGenerationParameters()
            .put("foo", "foo");
        assertEquals("foo = foo\n", scriptlet.printParams());

        // Print a collection of parameters.
        scriptlet.getGenerationParameters()
            .put("bar", new String[] { "bar" });
        scriptlet.getGenerationParameters()
            .put("baz", new String[] { "foo", "bar", "baz" });
        assertEquals("foo = foo\nbar = bar\nbaz = foo\nbaz = bar\nbaz = baz\n",
            scriptlet.printParams());

    }

    @Test
    public void testCcdModuleOutput() {
        BaseScriptlet scriptlet = createScriptlet();
        assertEquals(ParameterUtil.UNINITIALIZED_CCD_MODULE_OUTPUT,
            scriptlet.getCcdModule());
        assertEquals(ParameterUtil.UNINITIALIZED_CCD_MODULE_OUTPUT,
            scriptlet.getCcdOutput());

        // No module/output.
        scriptlet.expectModuleOutputParameter();
        assertEquals(ParameterUtil.INVALID_CCD_MODULE_OUTPUT,
            scriptlet.getCcdModule());
        assertEquals(ParameterUtil.INVALID_CCD_MODULE_OUTPUT,
            scriptlet.getCcdOutput());
        assertEquals(
            "Error: "
                + String.format(MISSING_PARAM_ERROR_TEXT, PARAM_MODULE_OUTPUT),
            scriptlet.getErrorText());
        scriptlet.setErrorText(null);

        // Invalid string.
        scriptlet.getGenerationParameters()
            .put(BaseScriptlet.PARAM_MODULE_OUTPUT, new String[] { "lskdfj" });
        scriptlet.expectModuleOutputParameter();
        assertEquals(ParameterUtil.INVALID_CCD_MODULE_OUTPUT,
            scriptlet.getCcdModule());
        assertEquals(ParameterUtil.INVALID_CCD_MODULE_OUTPUT,
            scriptlet.getCcdOutput());
        assertEquals("Error: Malformed moduleOutput string: lskdfj",
            scriptlet.getErrorText());
        scriptlet.setErrorText(null);

        // Valid string, bad module/output.
        scriptlet.getGenerationParameters()
            .put(BaseScriptlet.PARAM_MODULE_OUTPUT, new String[] { "42/42" });
        scriptlet.expectModuleOutputParameter();
        assertEquals(ParameterUtil.INVALID_CCD_MODULE_OUTPUT,
            scriptlet.getCcdModule());
        assertEquals(ParameterUtil.INVALID_CCD_MODULE_OUTPUT,
            scriptlet.getCcdOutput());
        assertEquals("Error: Invalid module: 42\nError: Invalid output: 42",
            scriptlet.getErrorText());
        scriptlet.setErrorText(null);

        // Good module/output.
        scriptlet.getGenerationParameters()
            .put(BaseScriptlet.PARAM_MODULE_OUTPUT, new String[] { "4/2" });
        scriptlet.expectModuleOutputParameter();
        assertEquals(4, scriptlet.getCcdModule());
        assertEquals(2, scriptlet.getCcdOutput());
        assertEquals(null, scriptlet.getErrorText());
    }

    @Test
    public void testWarningText() {
        BaseScriptlet scriptlet = createScriptlet();
        assertEquals(null, scriptlet.getWarningText());
        scriptlet.setWarningText("foo");
        assertEquals("Warning: foo", scriptlet.getWarningText());
    }

    @Test
    public void testErrorText() {
        BaseScriptlet scriptlet = createScriptlet();
        assertEquals(null, scriptlet.getErrorText());
        scriptlet.setErrorText("foo");
        assertEquals("Error: foo", scriptlet.getErrorText());
    }
}
