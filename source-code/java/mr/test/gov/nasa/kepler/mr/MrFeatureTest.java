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

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;

import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.util.Arrays;
import java.util.List;

import javax.security.auth.login.FailedLoginException;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.JUnitCore;
import org.xml.sax.SAXException;

import com.meterware.httpunit.ClientProperties;
import com.meterware.httpunit.FrameSelector;
import com.meterware.httpunit.GetMethodWebRequest;
import com.meterware.httpunit.HttpInternalErrorException;
import com.meterware.httpunit.HttpUnitOptions;
import com.meterware.httpunit.PostMethodWebRequest;
import com.meterware.httpunit.WebConversation;
import com.meterware.httpunit.WebForm;
import com.meterware.httpunit.WebForm.Scriptable;
import com.meterware.httpunit.WebLink;
import com.meterware.httpunit.WebRequest;
import com.meterware.httpunit.WebResponse;

/**
 * This class tests the MR webapp features via HTTP against an already built,
 * deployed, and started MR runtime.
 * 
 * @author jbrittain
 */
public class MrFeatureTest {

    protected static final Log log = LogFactory.getLog(MrFeatureTest.class);

    private static final String SLASH = "/";
    private static final String CONFIG_KEY_URL_BASE = "mr.url.base";
    private static final String SO_HOME = "so.html";

    private static Configuration config;
    private static String baseUrl = "";

    @BeforeClass
    public static void setUp() {
        config = ConfigurationServiceFactory.getInstance();
        baseUrl = config.getString(CONFIG_KEY_URL_BASE);
    }

    @Test
    public void testLogin() throws MalformedURLException, IOException,
        SAXException, FailedLoginException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(false);
        ClientProperties props = conversation.getClientProperties();

        // Make a request without being logged in. We should end up on
        // the login page.
        WebRequest request = new GetMethodWebRequest(baseUrl + SLASH);
        WebResponse response = conversation.getResponse(request);

        // Verify that the form contains the fields we expect.
        WebForm forms[] = response.getForms();
        assertEquals(1, forms.length);
        assertEquals(3, forms[0].getParameterNames().length);
        List<String> inputFields = Arrays.asList(forms[0].getParameterNames());
        assertTrue("login form did not contain the accountname field",
            inputFields.contains("accountname"));
        assertTrue("login form did not contain the password field",
            inputFields.contains("password"));
        assertTrue("login form did not contain the submit field",
            inputFields.contains("submit"));

        // Log in by submitting the login form via POST.
        props.setAutoRedirect(false);
        login(conversation, "sotest", "test");
    }

    /**
     * Verifies that submitting the login form without entering a username nor a
     * password takes the user back to the login page again.
     * 
     * @throws SAXException
     */
    @Test
    public void testFailureLogin() throws SAXException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(false);
        ClientProperties props = conversation.getClientProperties();
        props.setAutoRedirect(false);

        // Just click "Log In" with a blank username and blank password.
        try {
            login(conversation, "", "");
        } catch (FailedLoginException e) {
            // This is what we expect.
        }
    }

    @Test
    public void testViewSoHome() throws MalformedURLException, IOException,
        SAXException, FailedLoginException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(false);
        ClientProperties props = conversation.getClientProperties();

        // Log in as sotest.
        props.setAutoRedirect(false);
        login(conversation, "sotest", "test");

        // Make a request to view the SO home page.
        WebRequest request = new GetMethodWebRequest(baseUrl + SLASH + SO_HOME);
        WebResponse response = conversation.getResponse(request);
        int responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }
    }

    @Test
    public void testFailureViewSoHome() throws MalformedURLException,
        IOException, SAXException, FailedLoginException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(false);
        ClientProperties props = conversation.getClientProperties();

        // Log in as fowgtest.
        props.setAutoRedirect(false);
        login(conversation, "fowgtest", "test");

        // Make a request to view the SO home page.
        WebRequest request = new GetMethodWebRequest(baseUrl + SLASH + SO_HOME);
        WebResponse response = conversation.getResponse(request);
        int responseCode = response.getResponseCode();
        if (responseCode != 302) {
            fail("response code was " + responseCode + " -- we expected 302.");
        }
    }

    @Test
    public void testReportTreePermissions() throws MalformedURLException,
        IOException, SAXException, FailedLoginException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(true);
        ClientProperties props = conversation.getClientProperties();

        // Log in as sotest.
        props.setAutoRedirect(false);
        login(conversation, "sotest", "test");

        // Make a request to view the reportal's tree.html page.
        WebRequest request = new GetMethodWebRequest(baseUrl
            + "/reportal/index.html");
        WebResponse response = conversation.getResponse(request);
        int responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Get the tree iframe.
        String[] frameNames = response.getFrameNames();
        assertTrue("tree iframe was missing", frameNames.length > 0);
        response = conversation.getFrameContents("tree-iframe");
        assertNotNull("could not find the tree iframe", response);

        // Verify that the pipeline-processing report is listed in the tree,
        // since the sotest user has permission to view it.
        int index = response.getText()
            .indexOf("pipeline-processing");
        assertTrue("the pipeline-processing report did not appear in the tree",
            index != -1);

        // Verify that a nonexistent report name does not appear in the
        // response.
        index = response.getText()
            .indexOf("nonexistent-report-name");
        assertTrue("a nonexistent report name is unexpectedly in the tree",
            index == -1);

        // Find the report link.
        WebLink reportLink = response.getLinkWith("pipeline-processing");
        assertNotNull("the report link was not found in the tree", reportLink);

        // Click the report tree node link.
        response = reportLink.click();
        responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        WebResponse topFrame = conversation.getFrameContents(FrameSelector.TOP_FRAME);
        WebForm[] forms = topFrame.getForms();
        assertTrue("there was no parameters page for the report",
            forms.length > 0);

        // Submit the parameters page form.
        response = forms[0].submit();
        responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Verify that the report iframe is in the response.
        index = response.getText()
            .indexOf("report-iframe");
        assertTrue("report iframe does not appear in response", index != -1);

        // Get the report iframe.
        frameNames = response.getFrameNames();
        assertTrue("report iframe was missing", frameNames.length > 0);
        response = conversation.getFrameContents("report-iframe");
        assertNotNull("could not find the report iframe", response);
    }

    @Test
    public void testFailureReportTreePermissions()
        throws MalformedURLException, IOException, SAXException,
        FailedLoginException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(true);
        ClientProperties props = conversation.getClientProperties();

        // Log in as fowgtest.
        props.setAutoRedirect(false);
        login(conversation, "fowgtest", "test");

        // Make a request to view the reportal's tree.html page.
        WebRequest request = new GetMethodWebRequest(baseUrl
            + "/reportal/index.html");
        WebResponse response = conversation.getResponse(request);
        int responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Get the tree iframe.
        String[] frameNames = response.getFrameNames();
        assertTrue("tree iframe was missing", frameNames.length > 0);
        response = conversation.getFrameContents("tree-iframe");
        assertNotNull("could not find the tree iframe", response);

        // Verify that the pipeline-processing report is not listed in the
        // tree, since the fowgtest user has no permission to view it.
        int index = response.getText()
            .indexOf("pipeline-processing");
        assertTrue("the pipeline-processing report appeared in the tree",
            index == -1);
    }

    @Test
    public void testFileSharingTreePermissions() throws MalformedURLException,
        IOException, SAXException, FailedLoginException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(true);
        ClientProperties props = conversation.getClientProperties();

        // Log in as fowgtest.
        props.setAutoRedirect(false);
        login(conversation, "fowgtest", "test");

        // Request the file sharing index page.
        WebRequest request = new GetMethodWebRequest(baseUrl
            + "/share/index.html?path=files");
        WebResponse response = conversation.getResponse(request);
        int responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Get the tree iframe.
        String[] frameNames = response.getFrameNames();
        assertTrue("tree iframe was missing", frameNames.length > 0);
        response = conversation.getFrameContents("tree-iframe");
        assertNotNull("could not find the tree iframe", response);

        // Verify that the FOWG file share directory appears in the
        // tree, since the fowgtest user has permission to view it.
        int index = response.getText()
            .indexOf("FOWG");
        assertTrue("the FOWG file share dir did not appear in the tree",
            index != -1);
    }

    @Test
    public void testFailureFileSharingTreePermissions()
        throws MalformedURLException, IOException, SAXException,
        FailedLoginException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(true);
        ClientProperties props = conversation.getClientProperties();

        // Log in as fowgtest.
        props.setAutoRedirect(false);
        login(conversation, "fowgtest", "test");

        // Request the file sharing index page.
        WebRequest request = new GetMethodWebRequest(baseUrl
            + "/share/index.html?path=files");
        WebResponse response = conversation.getResponse(request);
        int responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Get the tree iframe.
        String[] frameNames = response.getFrameNames();
        assertTrue("tree iframe was missing", frameNames.length > 0);
        response = conversation.getFrameContents("tree-iframe");
        assertNotNull("could not find the tree iframe", response);

        // Verify that the SO file share directory does not appear in the
        // tree, since the fowgtest user does not have permission to view it.
        int index = response.getText()
            .indexOf("SO");
        assertTrue("the SO file share dir appeared in the tree", index == -1);

        // Enter a URL to attempt to go there anyway.
        request = new GetMethodWebRequest(baseUrl
            + "/share/index.html?path=files/SO");
        response = conversation.getResponse(request);
        responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Get the tree iframe.
        response = conversation.getFrameContents("tree-iframe");
        assertNotNull("could not find the tree iframe", response);

        // Verify that the SO file share directory does not appear in the
        // tree, since the fowgtest user does not have permission to view it.
        index = response.getText()
            .indexOf("new Node( \"SO\"");
        assertTrue("the SO file share dir appeared in the tree", index == -1);
    }

    @Test
    public void testFileSharingAdd() throws MalformedURLException, IOException,
        SAXException, FailedLoginException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(true);
        ClientProperties props = conversation.getClientProperties();

        // Log in as sotest.
        props.setAutoRedirect(false);
        login(conversation, "sotest", "test");

        // Request the file sharing index page.
        WebRequest request = new GetMethodWebRequest(baseUrl
            + "/share/index.html?path=files/SO");
        WebResponse response = conversation.getResponse(request);
        int responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Try adding a test file.
        addTestFile(conversation, "files/SO");

        // Get the top frame.
        response = conversation.getFrameContents("_top");
        assertNotNull("could not find the top frame", response);

        // Now try adding a directory..
        // Find the Add button link.
        WebLink addButton = response.getLinkWithImageText("Add New");
        assertNotNull("the Add New button/link was not found", addButton);

        // Click the Add button.
        response = addButton.click();
        responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Look for the add form.
        WebForm[] forms = response.getForms();
        assertTrue("there was no add form on the add page", forms.length > 0);
        WebForm wizard = forms[1]; // The 0th form is the tree form.
        assertNotNull("add form was null", wizard);

        // Add a new directory.
        String destinationPath = "files/SO/"
            + File.createTempFile("test-add-", "")
                .getName();
        wizard.setParameter("destinationPath", destinationPath);
        log.info("Adding directory " + destinationPath);
        props.setAutoRedirect(true);
        response = wizard.submit();
        props.setAutoRedirect(false);
        responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Look for the destination path in the response.
        int index = response.getText()
            .indexOf(destinationPath);
        assertTrue("the added dir's path was not found in the response",
            index != -1);

        // See if it's listed in the tree.
        WebResponse treeIframe = conversation.getFrameContents("tree-iframe");
        index = treeIframe.getText()
            .indexOf(destinationPath + "\"");
        assertTrue("new dir " + destinationPath
            + " submitted, but not found in the tree", index != -1);
    }

    @Test
    public void testFileSharingCopy() throws MalformedURLException,
        IOException, SAXException, FailedLoginException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(true);
        ClientProperties props = conversation.getClientProperties();

        // Log in as sotest.
        props.setAutoRedirect(false);
        login(conversation, "sotest", "test");

        // Request the file sharing index page.
        WebRequest request = new GetMethodWebRequest(baseUrl
            + "/share/index.html?path=files/SO");
        WebResponse response = conversation.getResponse(request);
        int responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Try adding a test file.
        String testFile = addTestFile(conversation, "files/SO");

        // Get the top frame.
        response = conversation.getFrameContents("_top");
        assertNotNull("could not find the top frame", response);

        // Find the Copy button link.
        WebLink copyButton = response.getLinkWithImageText("Copy selected page or directory");
        assertNotNull("the Copy button/link was not found", copyButton);

        // Click the Copy button.
        response = copyButton.click();
        responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Look for the copy form.
        WebForm[] forms = response.getForms();
        assertTrue("there was no copy form on the copy page", forms.length > 0);
        WebForm wizard = forms[1]; // The 0th form is the tree form.
        assertNotNull("copy form was null", wizard);

        // Copy the test file.
        log.info("Copying file " + testFile);
        props.setAutoRedirect(true);
        String destinationPath = wizard.getParameterValue("destinationPath");
        Scriptable formObject = wizard.getScriptableObject();
        formObject.setAction("/share/copypage-finish.html");
        response = wizard.submit();
        props.setAutoRedirect(false);
        responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Look for the copy successful message in the response.
        int index = response.getText()
            .indexOf("COPY SUCCESSFUL");
        assertTrue("the 'copy successful' message was not found", index != -1);

        // Look for the destination path in the response.
        String destinationName = new File(destinationPath).getName();
        index = response.getText()
            .indexOf(destinationName);
        assertTrue("the copied page's path was not found in the response",
            index != -1);

        // See if it's listed in the tree.
        WebResponse treeIframe = response.getSubframeContents("tree-iframe");
        index = treeIframe.getText()
            .indexOf(destinationName);
        assertTrue("test file " + testFile
            + " copy submitted, but destination file " + destinationName
            + " was not found in the tree", index != -1);
    }

    @Test
    public void testFileSharingMove() throws FailedLoginException,
        SAXException, MalformedURLException, IOException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(true);
        ClientProperties props = conversation.getClientProperties();

        // Log in as sotest.
        props.setAutoRedirect(false);
        login(conversation, "sotest", "test");

        // Request the file sharing index page.
        WebRequest request = new GetMethodWebRequest(baseUrl
            + "/share/index.html?path=files/SO");
        WebResponse response = conversation.getResponse(request);
        int responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Try adding a test file.
        String testFile = addTestFile(conversation, "files/SO");

        // Get the top frame.
        response = conversation.getFrameContents("_top");
        assertNotNull("could not find the top frame", response);

        // Find the Copy button link.
        WebLink moveButton = response.getLinkWithImageText("Move / Rename selected page or directory");
        assertNotNull("the Move button/link was not found", moveButton);

        // Click the Move button.
        response = moveButton.click();
        responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Look for the move form.
        WebForm[] forms = response.getForms();
        assertTrue("there was no move form on the move page", forms.length > 0);
        WebForm wizard = forms[1]; // The 0th form is the tree form.
        assertNotNull("move form was null", wizard);

        // Move the test file.
        String destinationPath = "files/SO/"
            + File.createTempFile("test-move-", ".html")
                .getName();
        log.info("Moving file " + testFile + " to " + destinationPath);
        wizard.setParameter("sourcePath", testFile);
        wizard.setParameter("destinationPath", destinationPath);
        Scriptable formObject = wizard.getScriptableObject();
        formObject.setAction("/share/movepage-finish.html");
        response = wizard.submit();
        responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Look for the move successful message in the response.
        int index = response.getText()
            .indexOf("MOVE SUCCESSFUL");
        assertTrue("the 'move successful' message was not found", index != -1);

        // Look for the destination path in the response.
        String destinationName = new File(destinationPath).getName();
        index = response.getText()
            .indexOf(destinationName);
        assertTrue("the moved page's name was not found in the response",
            index != -1);

        // See if the destination file is listed in the tree.
        WebResponse treeIframe = response.getSubframeContents("tree-iframe");
        index = treeIframe.getText()
            .indexOf(destinationName);
        assertTrue("test file " + testFile
            + " move submitted, but destination file " + destinationName
            + " was not found in the tree", index != -1);

        // Make sure that the source name does not appear in the tree anymore.
        String testName = new File(testFile).getName();
        index = treeIframe.getText()
            .indexOf(testName);
        assertTrue("test file " + testFile
            + " move submitted, but source file name " + testName
            + " was still found in the tree", index == -1);
    }

    @Test
    public void testFileSharingDelete() throws FailedLoginException,
        SAXException, MalformedURLException, IOException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(true);
        ClientProperties props = conversation.getClientProperties();

        // Log in as sotest.
        props.setAutoRedirect(false);
        login(conversation, "sotest", "test");

        // Request the file sharing index page.
        WebRequest request = new GetMethodWebRequest(baseUrl
            + "/share/index.html?path=files/SO");
        WebResponse response = conversation.getResponse(request);
        int responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Try adding a test file.
        String testFile = addTestFile(conversation, "files/SO");

        // Get the top frame.
        response = conversation.getFrameContents("_top");
        assertNotNull("could not find the top frame", response);

        // Find the Delete button link.
        WebLink deleteButton = response.getLinkWithImageText("Delete selected page or directory");
        assertNotNull("the Delete button/link was not found", deleteButton);

        // Click the Delete button.
        response = deleteButton.click();
        responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Look for the move form.
        WebForm[] forms = response.getForms();
        assertTrue("there was no delete form on the delete page",
            forms.length > 0);
        WebForm wizard = forms[1]; // The 0th form is the tree form.
        assertNotNull("delete form was null", wizard);

        // Delete the test file.
        log.info("Deleting file " + testFile);
        Scriptable formObject = wizard.getScriptableObject();
        formObject.setAction("/share/deletepage-finish.html");
        response = wizard.submit();
        responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Look for the delete successful message in the response.
        int index = response.getText()
            .indexOf("DELETE SUCCESSFUL");
        assertTrue("the 'delete successful' message was not found", index != -1);

        // See if it's listed in the tree.
        WebResponse treeIframe = response.getSubframeContents("tree-iframe");
        index = treeIframe.getText()
            .indexOf(new File(testFile).getName());
        assertTrue("test file " + testFile
            + " delete submitted, but the file was still found in the tree",
            index == -1);
    }

    @Test
    public void testFileSharingUpload() throws MalformedURLException,
        IOException, SAXException, FailedLoginException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(true);
        ClientProperties props = conversation.getClientProperties();

        // Log in as sotest.
        props.setAutoRedirect(false);
        login(conversation, "sotest", "test");

        // Upload a test file where all users should be able to view it.
        String uploadFilename = File.createTempFile("test-upload-", ".html")
            .getName();
        WebResponse response = uploadFile("files/" + uploadFilename,
            conversation);

        // See if it's listed in the tree.
        WebResponse treeIframe = response.getSubframeContents("tree-iframe");

        int index = treeIframe.getText()
            .indexOf(uploadFilename);
        assertTrue("upload " + uploadFilename
            + " submitted, but not found in the tree", index != -1);

        // Try to view the uploaded file.
        WebLink uploadedFileNode = treeIframe.getLinkWith(uploadFilename);
        response = uploadedFileNode.click();
        int responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }
    }

    @Test
    public void testFileSharingUploadViewPermFailure()
        throws MalformedURLException, IOException, SAXException,
        FailedLoginException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(true);
        ClientProperties props = conversation.getClientProperties();

        // Log in as sotest.
        props.setAutoRedirect(false);
        login(conversation, "sotest", "test");

        // Upload a test file where only SO users should be able to view it.
        String uploadPathName = "files/SO/"
            + File.createTempFile("test-upload-", ".html")
                .getName();
        WebResponse response = uploadFile(uploadPathName, conversation);

        // See if it's listed in the tree.
        WebResponse treeIframe = response.getSubframeContents("tree-iframe");

        WebLink soNode = treeIframe.getLinkWith("SO");
        response = soNode.click();
        int responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        treeIframe = response.getSubframeContents("tree-iframe");
        int index = treeIframe.getText()
            .indexOf(uploadPathName);
        assertTrue("upload " + uploadPathName
            + " submitted, but not found in the tree", index != -1);

        // Log in as moctest.
        login(conversation, "moctest", "test");

        // Try to view the uploaded SO file via its URL (should fail).
        log.info("Requesting file " + baseUrl + SLASH + uploadPathName
            + " as moctest.");
        WebRequest request = new GetMethodWebRequest(baseUrl + SLASH
            + uploadPathName);
        response = conversation.getResponse(request);
        responseCode = response.getResponseCode();
        if (responseCode != 302) {
            fail("response code was " + responseCode + " (success = 302)");
        }
        String redirectUrl = response.getHeaderField("Location");
        if (!redirectUrl.endsWith("/auth/login.html")) {
            fail("got a redirect to " + redirectUrl
                + " when it should be a redirect to the login page");
        }
    }

    @Test
    public void testFileSharingViewPermissionFailure()
        throws MalformedURLException, IOException, SAXException,
        FailedLoginException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(true);
        ClientProperties props = conversation.getClientProperties();

        // Log in as sotest.
        props.setAutoRedirect(false);
        login(conversation, "sotest", "test");

        // Request the file sharing index page.
        WebRequest request = new GetMethodWebRequest(baseUrl
            + "/share/index.html?path=files/SO");
        WebResponse response = conversation.getResponse(request);
        int responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Try adding a test file.
        String testFile = addTestFile(conversation, "files/SO");

        // Log in as moctest.
        login(conversation, "moctest", "test");

        // Try to request the test file by its absolute URL.
        log.info("Requesting file " + baseUrl + SLASH + testFile
            + " as moctest.");
        request = new GetMethodWebRequest(baseUrl + SLASH + testFile);
        response = conversation.getResponse(request);
        responseCode = response.getResponseCode();
        if (responseCode != 302) {
            fail("response code was " + responseCode + " (success = 302)");
        }
        String redirectUrl = response.getHeaderField("Location");
        if (!redirectUrl.endsWith("/auth/login.html")) {
            fail("got a redirect to " + redirectUrl
                + " when it should be a redirect to the login page");
        }
    }

    @Test(expected = HttpInternalErrorException.class)
    public void testFileSharingAddFileFailure() throws MalformedURLException,
        IOException, SAXException, FailedLoginException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(true);
        ClientProperties props = conversation.getClientProperties();

        // Log in as moctest.
        props.setAutoRedirect(false);
        login(conversation, "moctest", "test");

        // Request the file sharing index page.
        WebRequest request = new GetMethodWebRequest(baseUrl
            + "/share/index.html?path=files");
        WebResponse response = conversation.getResponse(request);
        int responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Try adding a test file in the SO dir (should fail).
        addTestFile(conversation, "files/SO");
    }

    @Test(expected = HttpInternalErrorException.class)
    public void testFileSharingCopyFileSourceFailure()
        throws MalformedURLException, IOException, SAXException,
        FailedLoginException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(true);
        ClientProperties props = conversation.getClientProperties();

        // Log in as sotest.
        props.setAutoRedirect(false);
        login(conversation, "sotest", "test");

        // Request the file sharing index page.
        WebRequest request = new GetMethodWebRequest(baseUrl
            + "/share/index.html?path=files");
        WebResponse response = conversation.getResponse(request);
        int responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Add a test file in the SO dir.
        String testFile = addTestFile(conversation, "files/SO");

        // Log in as moctest.
        login(conversation, "moctest", "test");

        // Try copying the test file from the SO dir (should fail).
        request = new PostMethodWebRequest(baseUrl
            + "/share/copypage-finish.html");
        request.setParameter("sourcePath", testFile);
        request.setParameter("destinationPath",
            File.createTempFile("test-copy-", ".html")
                .getName());
        props.setAutoRedirect(true);
        conversation.getResponse(request);
    }

    @Test(expected = HttpInternalErrorException.class)
    public void testFileSharingCopyFileDestFailure()
        throws MalformedURLException, IOException, SAXException,
        FailedLoginException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(true);
        ClientProperties props = conversation.getClientProperties();

        // Log in as moctest.
        props.setAutoRedirect(false);
        login(conversation, "moctest", "test");

        // Request the file sharing index page.
        WebRequest request = new GetMethodWebRequest(baseUrl
            + "/share/index.html?path=files");
        WebResponse response = conversation.getResponse(request);
        int responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Try adding a test file in the SO dir (should fail).
        String testFile = addTestFile(conversation, "files/MOC");

        // Try copying the test file to the SO dir (should fail).
        request = new PostMethodWebRequest(baseUrl
            + "/share/copypage-finish.html");
        request.setParameter("sourcePath", testFile);
        request.setParameter("destinationPath", "files/SO/"
            + File.createTempFile("test-copy-", ".html")
                .getName());
        props.setAutoRedirect(true);
        conversation.getResponse(request);
    }

    @Test
    public void testFileSharingRecursiveCopy() throws MalformedURLException,
        IOException, SAXException, FailedLoginException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(true);
        ClientProperties props = conversation.getClientProperties();

        // Log in as sotest.
        props.setAutoRedirect(false);
        login(conversation, "sotest", "test");

        // Request the file sharing index page.
        WebRequest request = new GetMethodWebRequest(baseUrl
            + "/share/index.html?path=files");
        WebResponse response = conversation.getResponse(request);
        int responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Add a test dir.
        String testDirName = "files/"
            + File.createTempFile("test-copy-", "-dir")
                .getName();

        // Find the Add button link.
        WebLink addButton = response.getLinkWithImageText("Add New");
        assertNotNull("the Add New button/link was not found", addButton);

        // Click the Add button.
        response = addButton.click();
        responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Look for the add form.
        WebForm[] forms = response.getForms();
        assertTrue("there was no add form on the add page", forms.length > 0);
        WebForm wizard = forms[1]; // The 0th form is the tree form.
        assertNotNull("add form was null", wizard);

        // Add the new dir.
        wizard.setParameter("destinationPath", testDirName);
        log.info("Adding dir " + testDirName);
        props.setAutoRedirect(true);
        response = wizard.submit();
        props.setAutoRedirect(false);
        responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Add a test file.
        String testFile = addTestFile(conversation, testDirName);

        // Copy the directory with the file in it.
        // Get the top frame.
        response = conversation.getFrameContents("_top");
        assertNotNull("could not find the top frame", response);

        // Try copying the dir.
        request = new PostMethodWebRequest(baseUrl
            + "/share/copypage-finish.html");
        request.setParameter("sourcePath", testDirName);
        String destDirName = File.createTempFile("test-copy-", "-dir")
            .getName();
        request.setParameter("destinationPath", "files/" + destDirName);
        props.setAutoRedirect(true);
        log.info("Copying dir " + testDirName + " to files/" + destDirName);
        response = conversation.getResponse(request);

        // Look for the copy successful message in the response.
        int index = response.getText()
            .indexOf("COPY SUCCESSFUL");
        assertTrue("the 'copy successful' message was not found", index != -1);

        // Look for the destination path in the response.
        index = response.getText()
            .indexOf(destDirName);
        assertTrue("the dest dir's path was not found in the response",
            index != -1);

        // See if it's listed in the tree.
        // Find the destination dir tree node link and open it.
        WebResponse treeIframe = conversation.getFrameContents("tree-iframe");
        WebLink dirTreeNodeLink = treeIframe.getLinkWith(destDirName);
        assertNotNull("the dir tree node link for " + destDirName
            + " was not found in the tree", dirTreeNodeLink);

        // Click the report tree node link.
        response = dirTreeNodeLink.click();
        responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        treeIframe = conversation.getFrameContents("tree-iframe");
        index = treeIframe.getText()
            .indexOf(destDirName + "\"");
        assertTrue("new dir " + destDirName
            + " submitted, but not found in the tree", index != -1);

        // Make sure that the file that is inside it is also listed.
        index = testFile.lastIndexOf("/");
        String testFileMinusDir = testFile.substring(index + 1);
        log.info("Looking for " + destDirName + SLASH + testFileMinusDir);
        index = treeIframe.getText()
            .indexOf(destDirName + SLASH + testFileMinusDir + "\"");
        assertTrue("new dir " + destDirName + " is in the tree but its file "
            + testFileMinusDir + " isn't", index != -1);
    }

    @Test(expected = HttpInternalErrorException.class)
    public void testFileSharingMoveFileSourceFailure()
        throws MalformedURLException, IOException, SAXException,
        FailedLoginException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(true);
        ClientProperties props = conversation.getClientProperties();

        // Log in as sotest.
        props.setAutoRedirect(false);
        login(conversation, "sotest", "test");

        // Request the file sharing index page.
        WebRequest request = new GetMethodWebRequest(baseUrl
            + "/share/index.html?path=files");
        WebResponse response = conversation.getResponse(request);
        int responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Add a test file in the SO dir.
        String testFile = addTestFile(conversation, "files/SO");

        // Log in as moctest.
        login(conversation, "moctest", "test");

        // Try moving the test file from the SO dir (should fail).
        request = new PostMethodWebRequest(baseUrl
            + "/share/movepage-finish.html");
        request.setParameter("sourcePath", testFile);
        request.setParameter("destinationPath",
            File.createTempFile("test-move-", ".html")
                .getName());
        request.setParameter("oe-action", "Page.movePage");
        props.setAutoRedirect(true);
        conversation.getResponse(request);
    }

    @Test(expected = HttpInternalErrorException.class)
    public void testFileSharingMoveFileDestFailure()
        throws MalformedURLException, IOException, SAXException,
        FailedLoginException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(true);
        ClientProperties props = conversation.getClientProperties();

        // Log in as moctest.
        props.setAutoRedirect(false);
        login(conversation, "moctest", "test");

        // Request the file sharing index page.
        WebRequest request = new GetMethodWebRequest(baseUrl
            + "/share/index.html?path=files");
        WebResponse response = conversation.getResponse(request);
        int responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Try adding a test file in the SO dir (should fail).
        String testFile = addTestFile(conversation, "files/MOC");

        // Try moving the test file to the SO dir (should fail).
        request = new PostMethodWebRequest(baseUrl
            + "/share/movepage-finish.html");
        request.setParameter("sourcePath", testFile);
        String destinationPath = "files/SO/"
            + File.createTempFile("test-move-", ".html")
                .getName();
        request.setParameter("destinationPath", destinationPath);
        request.setParameter("oe-action", "Page.movePage");
        props.setAutoRedirect(true);
        response = conversation.getResponse(request);
        responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }
    }

    @Test(expected = HttpInternalErrorException.class)
    public void testFileSharingDeleteFilePermFailure()
        throws MalformedURLException, IOException, SAXException,
        FailedLoginException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(true);
        ClientProperties props = conversation.getClientProperties();

        // Log in as sotest.
        props.setAutoRedirect(false);
        login(conversation, "sotest", "test");

        // Request the file sharing index page.
        WebRequest request = new GetMethodWebRequest(baseUrl
            + "/share/index.html?path=files");
        WebResponse response = conversation.getResponse(request);
        int responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Add a test file in the SO dir.
        String testFile = addTestFile(conversation, "files/SO");

        // Log in as moctest.
        login(conversation, "moctest", "test");

        // Try deleting the test file from the SO dir (should fail).
        request = new PostMethodWebRequest(baseUrl
            + "/share/deletepage-finish.html");
        request.setParameter("delete", testFile);
        request.setParameter("oe-action", "Page.deletePage");
        props.setAutoRedirect(true);
        conversation.getResponse(request);
    }

    @Test(expected = HttpInternalErrorException.class)
    public void testFileSharingUploadPermFailure()
        throws MalformedURLException, IOException, SAXException,
        FailedLoginException {

        // Initialize the web client.
        WebConversation conversation = new WebConversation();
        HttpUnitOptions.setScriptingEnabled(true);
        ClientProperties props = conversation.getClientProperties();

        // Log in as mmotest.
        props.setAutoRedirect(false);
        login(conversation, "mmotest", "test");

        // Try to upload a test file to the SO directory.
        String uploadPathName = "files/SO/"
            + File.createTempFile("test-upload-", ".html")
                .getName();
        uploadFile(uploadPathName, conversation);
    }

    /**
     * This method performs the work of logging in a user via the web.
     * 
     * @param conversation
     * @param username
     * @param password
     * @return the response with the user is logged in.
     * @throws FailedLoginException
     * @throws SAXException
     */
    protected WebResponse login(WebConversation conversation, String username,
        String password) throws FailedLoginException, SAXException {

        WebRequest request = new PostMethodWebRequest(baseUrl
            + "/auth/login.html");
        request.setParameter("accountname", username);
        request.setParameter("password", password);
        request.setParameter("submit", "Log In");
        WebResponse response;
        try {
            response = conversation.getResponse(request);
            int responseCode = response.getResponseCode();
            if (responseCode != 302) {
                throw new FailedLoginException("login response code "
                    + responseCode + " (success = 302)");
            }
            log.debug("Returned cookie count: "
                + response.getNewCookieNames().length);
        } catch (IOException e) {
            throw new FailedLoginException(e.toString());
        }
        log.info("Logged in as user " + username + ".");

        return response;
    }

    public String addTestFile(WebConversation conversation, String dirPath)
        throws SAXException, IOException {

        ClientProperties props = conversation.getClientProperties();

        // Get the tree iframe.
        WebResponse response = conversation.getFrameContents("_top");
        assertNotNull("could not find the top frame", response);

        // Find the Add button link.
        WebLink addButton = response.getLinkWithImageText("Add New");
        assertNotNull("the Add New button/link was not found", addButton);

        // Click the Add button.
        response = addButton.click();
        int responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Look for the add form.
        WebForm[] forms = response.getForms();
        assertTrue("there was no add form on the add page", forms.length > 0);
        WebForm wizard = forms[1]; // The 0th form is the tree form.
        assertNotNull("add form was null", wizard);

        // Add a new (mostly empty) file.
        String destinationPath = dirPath + SLASH
            + File.createTempFile("test-", ".html")
                .getName();
        wizard.setParameter("destinationPath", destinationPath);
        log.info("Adding file " + destinationPath);
        props.setAutoRedirect(true);
        response = wizard.submit();
        props.setAutoRedirect(false);
        responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Look for the destination path in the response.
        int index = response.getText()
            .indexOf(destinationPath);
        assertTrue("the added page's path was not found in the response",
            index != -1);

        // See if it's listed in the tree.
        WebResponse treeIframe = conversation.getFrameContents("tree-iframe");
        index = treeIframe.getText()
            .indexOf(destinationPath);
        assertTrue("new file " + destinationPath
            + " submitted, but not found in the tree", index != -1);

        return destinationPath;
    }

    public WebResponse uploadFile(String path, WebConversation conversation)
        throws MalformedURLException, IOException, SAXException {

        // Request the file sharing index page.
        WebRequest request = new GetMethodWebRequest(baseUrl
            + "/share/index.html?path=files");
        WebResponse response = conversation.getResponse(request);
        int responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Get the top frame.
        response = conversation.getFrameContents("_top");
        assertNotNull("could not find the top frame", response);

        // Find the Upload button link.
        WebLink uploadButton = response.getLinkWithImageText("Upload File");
        assertNotNull("the upload button/link was not found", uploadButton);

        // Click the Upload button.
        response = uploadButton.click();
        responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Look for the upload form.
        WebForm[] forms = response.getForms();
        assertTrue("there was no upload form on the upload page",
            forms.length > 0);
        WebForm wizard = forms[1]; // The 0th form is the tree form.
        assertNotNull("file upload form was null", wizard);

        // Upload the file.
        wizard.setParameter("file",
            new File("webroot/index.html").getAbsoluteFile());
        String uploadPathName = path;
        wizard.setParameter("path", uploadPathName);
        log.info("Uploading " + uploadPathName);
        response = wizard.submit();
        responseCode = response.getResponseCode();
        if (responseCode != 200) {
            if (responseCode == 302) {
                fail("got a redirect to "
                    + response.getHeaderFields("Location")[0]);
            } else {
                fail("response code was " + responseCode + " (success = 200)");
            }
        }

        // Look for the upload successful message in the response.
        int index = response.getText()
            .indexOf("Upload Successful");
        assertTrue("the 'upload successful' message was not found", index != -1);

        return response;
    }

    public static void main(String[] args) throws Exception {
        JUnitCore.main(MrFeatureTest.class.getName());
    }
}
