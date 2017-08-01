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

package gov.nasa.kepler.mr.servlet;

import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.mr.ParameterUtil;
import gov.nasa.kepler.mr.users.pi.PipelineUser;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.util.ArrayList;

import javax.servlet.http.HttpSession;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.BeforeClass;
import org.junit.Test;
import org.xml.sax.SAXException;

import com.meterware.httpunit.ClientProperties;
import com.meterware.httpunit.GetMethodWebRequest;
import com.meterware.httpunit.HttpNotFoundException;
import com.meterware.httpunit.WebRequest;
import com.meterware.servletunit.ServletRunner;
import com.meterware.servletunit.ServletUnitClient;
import com.openedit.users.User;

/**
 * This class tests the ReportViewerServlet without needing to deploy a full
 * runtime environment. It uses ServletUnit (a subset of HttpUnit) that includes
 * a unit testing friendly servlet container implementation. No HTTP is
 * involved, but requests can be made to a servlet, and responses are generated.
 * This class creates minimalistic webapp root in build/test that contains only
 * the few files and dirs that are necessary for testing.
 * 
 * @author jbrittain
 */
public class ReportViewerServletTest {

    protected static final Log logger = LogFactory.getLog(ReportViewerServletTest.class);

    private static final String EMPTY_STRING = "";
    private static final String COMPILED_REPORT_DIR = "compiled-report";
    private static final String BASE_URL = "http://localhost:8080/reportal/view";
    private static final String BUILD_DIR = "build";
    private static final String TEST_DIR = BUILD_DIR + File.separator + "test";
    private static final String REPORT_DIR = TEST_DIR + File.separator
        + "reportal" + File.separator + "view";
    private static final String TEST_RESOURCES_DIR = "test" + File.separator
        + "resources";

    private static ServletRunner servletRunner;

    @BeforeClass
    public static void setUp() throws IOException {
        File webInfDir = new File(TEST_DIR, "WEB-INF");
        FileUtil.mkdirs(webInfDir);
        File webXmlFile = new File(TEST_RESOURCES_DIR,
            "report-viewer-servlet-web.xml");
        File destWebXmlFile = new File(webInfDir, "web.xml");
        try {
            FileUtils.copyDirectory(new File(BUILD_DIR, COMPILED_REPORT_DIR),
                new File(TEST_DIR, COMPILED_REPORT_DIR));
            FileUtils.copyFile(webXmlFile, destWebXmlFile);
            servletRunner = new ServletRunner(destWebXmlFile, EMPTY_STRING);
        } catch (IOException e) {
            throw new PipelineException(e);
        } catch (SAXException e) {
            throw new PipelineException(e);
        }
    }

    @Test
    public void testHtmlReportGeneration() throws MalformedURLException,
        IOException, SAXException {

        ServletUnitClient client = startServlet("html", "blank");

        // Request an image from the HTML report's image directory.
        WebRequest webRequest = new GetMethodWebRequest(BASE_URL
            + "/blank.html_files/px");
        try {
            client.getResponse(webRequest);
        } catch (HttpNotFoundException e) {
            String message = e.getMessage();
            if (!message.startsWith("Error on HTTP request: 404 No servlet mapping defined")) {
                throw e;
            }
        }

        // Verification.
        File reportBase = validate(client, "blank.html");
        File reportImagesDir = new File(reportBase, "blank.html_files");
        assertTrue("Generator ran but the report's images dir is missing",
            reportImagesDir.exists());
        File pxImageFile = new File(reportBase, "blank.html_files/px");
        assertTrue("Generator ran but the px image file is missing",
            pxImageFile.exists());
    }

    @Test
    public void testPdfReportGeneration() throws MalformedURLException,
        IOException, SAXException {

        ServletUnitClient client = startServlet("pdf", "blank");
        validate(client, "blank.pdf");
    }

    // Since we can't mock the database and filestore with HttpUnit, this test
    // would require that the database and filestore be populated appropriately.
    // @Test
    public void testGenericReportGeneration() throws MalformedURLException,
        IOException, SAXException {

        ServletUnitClient client = startServlet("pdf", "generic-report");
        validate(client, "generic-report.pdf");
    }

    private ServletUnitClient startServlet(String format, String reportName)
        throws IOException, MalformedURLException, SAXException {

        ServletUnitClient client = servletRunner.newClient();
        ClientProperties clientProperties = client.getClientProperties();
        clientProperties.setAcceptCookies(true);

        gov.nasa.kepler.hibernate.services.User piUser = new gov.nasa.kepler.hibernate.services.User(
            "testusername", "testpw", EMPTY_STRING, EMPTY_STRING, EMPTY_STRING);
        User user = new PipelineUser(piUser);
        ArrayList<String> privs = new ArrayList<String>();
        privs.add("mr." + reportName);
        piUser.setPrivileges(privs);
        HttpSession session = client.getSession(true);
        session.setAttribute(ReportViewerServlet.SESSION_ATTRIBUTE_USER, user);

        WebRequest webRequest = new GetMethodWebRequest(BASE_URL + "/"
            + reportName);
        webRequest.setParameter("format", format);
        webRequest.setParameter(ParameterUtil.PARAM_GENERIC_REPORT_IDENTIFIER,
            "42 dv");
        try {
            // Clear the report directory.
            File reportDir = new File(REPORT_DIR);
            FileUtils.deleteDirectory(reportDir);
            FileUtil.mkdirs(reportDir);

            client.getResponse(webRequest);

        } catch (HttpNotFoundException e) {
            // This is the exception we want -- the servlet tries to stream the
            // report file to the browser, and cannot find the resource because
            // the fake servlet container does not actually map static webapp
            // resources.
            String message = e.getMessage();
            if (!message.startsWith("Error on HTTP request: 404 No servlet mapping defined")) {
                throw e;
            }
        }

        // Request the file after it is already generated.
        webRequest = new GetMethodWebRequest(BASE_URL + "/" + reportName + "."
            + format);
        try {
            client.getResponse(webRequest);

        } catch (HttpNotFoundException e) {
            String message = e.getMessage();
            if (!message.startsWith("Error on HTTP request: 404 No servlet mapping defined")) {
                throw e;
            }
        }

        return client;
    }

    private File validate(ServletUnitClient client, String reportName) {
        File reportBase = new File(REPORT_DIR, client.getSession(false)
            .getId());
        File reportFile = new File(reportBase, reportName);
        assertTrue("Generator ran but the main report file is missing",
            reportFile.exists());

        return reportBase;
    }
}
