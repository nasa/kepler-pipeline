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

import static gov.nasa.kepler.common.MimeType.GIF;
import static gov.nasa.kepler.common.MimeType.HTML;
import static gov.nasa.kepler.common.MimeType.PDF;
import static gov.nasa.kepler.common.MimeType.PNG;
import static gov.nasa.kepler.common.MimeType.TAR;
import static gov.nasa.kepler.common.MimeType.XML;
import gov.nasa.kepler.common.MimeType;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.mr.MrTimeUtil;
import gov.nasa.kepler.mr.users.pi.Permissions;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.Connection;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JasperExportManager;
import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperPrint;
import net.sf.jasperreports.engine.query.JRHibernateQueryExecuterFactory;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Session;

import com.openedit.users.User;

@SuppressWarnings("serial")
public class ReportViewerServlet extends HttpServlet {

    protected static final Log log = LogFactory.getLog(ReportViewerServlet.class);

    public static final String REPORT_URI_BASE = "/reportal/view";
    public static final String GENERATION_PARAMETERS_KEY = "MR_PARAMETERS";
    public static final String PARAM_FORMAT = "format";
    public static final String PARAM_PATH = "path";
    public static final String PARAM_SUBMIT = "submit";
    public static final String PARAM_GENERATION_DATE_UTC = "GENERATION_DATE_UTC";
    public static final String PARAM_GENERATION_DATE_UTC_URL = "GENERATION_DATE_UTC_URL";
    public static final String PARAM_SERVER_URL = "SERVER_URL";
    public static final String PARAM_REPORT_URL = "REPORT_URL";
    public static final String PARAM_DB_CONNECTION = "DB_CONNECTION";
    public static final String PARAM_IGNORE_PAGINATION = "IS_IGNORE_PAGINATION";
    public static final String SESSION_ATTRIBUTE_USER = "user";

    private static final String HTML_FORMAT = "html";
    private static final String PDF_FORMAT = "pdf";
    private static final String DOT_JASPER = ".jasper";
    private static final String PAGE_LOGIN = "auth/login.html";
    private static final String PAGE_NO_PERMISSION = "/reportal/no-permission.html";
    private static final String WEBAPP_COMPILED_DIR = "compiled-report";
    private static final String IMAGE_DIR = ".html_files";
    private static final String TEXT = "text";
    private static final String CONTENT_DISPOSITION = "Content-Disposition";
    private static final String CONTENT_DISPOSITION_FILENAME = "attachment; filename=";
    private static final String CHARSET = "UTF-8";
    private static final int DEFAULT_RESPONSE_BUFFER_SIZE = 8 * 1024;
    private static final int MAX_RESPONSE_BUFFER_SIZE = 1024 * 1024;

    private ServletContext context;

    @Override
    public void init() throws ServletException {
        log.debug("initialized");
        context = getServletContext();
        clearOrphanedTmpDirectories(new File(
            context.getRealPath(ReportViewerServlet.REPORT_URI_BASE)));
    }

    /**
     * Clears orphaned temporary directories. The servlet saves reports and
     * images in directories in /reportal/view named after the session ID. After
     * the session expires (30 minutes) or the server is brought down gracefully
     * (C-c and kill -TERM counts as graceful), these directories are
     * automatically removed by the {@link ReportListener}. In the rare case
     * where the server or computer crashes, outstanding sessions will not have
     * their directories cleared, so clear directory just in case on start-up to
     * avoid having to add a special operations procedure.
     * <p>
     * The given directory itself and regular files within it are not removed,
     * only directories that are contained within it.
     * 
     * @param dir the base temporary directory
     */
    private void clearOrphanedTmpDirectories(File dir) {
        if (!dir.exists()) {
            return;
        }

        for (File file : dir.listFiles()) {
            if (file.isDirectory()) {
                log.info("Removing " + file.getAbsolutePath());
                try {
                    FileUtils.deleteDirectory(file);
                } catch (IOException e) {
                    log.error("Failed to remove " + file.getAbsolutePath()
                        + ": " + e.getMessage(), e);
                }
            }
        }
    }

    // A report file URI looks like:
    // /reportal/view/proto?format=html&...
    // And, if it's HTML_FORMAT, images will be served like:
    // /reportal/view/proto.html_files/px
    // /reportal/view/proto.html_files/img_0_0_5

    // A generic report file URI looks like:
    // /reportal/view/generic-report?task=...
    @Override
    protected void doGet(HttpServletRequest request,
        HttpServletResponse response) throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session == null) {
            response.sendRedirect(PAGE_LOGIN);
            return;
        }

        String reportName = getReportName(request);
        if (reportName == null) {
            // getReportName already logged error.
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        // Make sure the user has permission to view this report.
        User user = (User) session.getAttribute(SESSION_ATTRIBUTE_USER);
        if (user == null
            || !(user.hasPermission(Permissions.PERM_MR_PREFIX + reportName) || user.hasPermission(Permissions.ADMINISTRATION))) {
            // Show them the "you do not have permission for this report" page.
            getServletContext().getRequestDispatcher(PAGE_NO_PERMISSION)
                .include(request, response);
            return;
        }

        String imageName = getImageName(request);
        if (imageName != null) {
            // Serve image.
            File imageFile = new File(context.getRealPath(REPORT_URI_BASE)
                + "/" + request.getSession()
                    .getId(), imageName);
            serveFile(imageFile, response);
        } else {
            log.info("Generating " + reportName + " report for "
                + user.getUserName() + "@" + request.getRemoteHost() + "...");
            long startTime = System.currentTimeMillis();

            if (reportName.equals(GenericReport.REPORT_NAME_GENERIC_REPORT)) {
                createGenericReport(request, response);
            } else {
                createJasperReport(request, response, reportName);
            }

            log.info("Generating " + reportName + " report for "
                + user.getUserName() + "@" + request.getRemoteHost()
                + "...done (" + (System.currentTimeMillis() - startTime)
                + " ms)");
        }
    }

    @SuppressWarnings("unchecked")
    private void createGenericReport(HttpServletRequest request,
        HttpServletResponse response) throws IOException {

        Report report = null;
        try {
            report = new GenericReport(request.getParameterMap());
        } catch (Exception e) {
            displayError(
                response,
                request.getPathInfo() + "?genericReportIdentifier="
                    + request.getParameter("genericReportIdentifier"), e);
            return;
        }

        if (report.getContentType()
            .equals(TAR.getContentType())) {
            try {
                report = new LaTeXReport(new File(
                    context.getRealPath(REPORT_URI_BASE), request.getSession()
                        .getId()), report);
            } catch (Exception e) {
                displayError(response,
                    request.getPathInfo() + "?genericReportIdentifier="
                        + request.getParameter("genericReportIdentifier"), e);
                return;
            }
        }

        try {
            // Stream out the generated report.
            serveStream(report.getInputStream(), report.getFilename(),
                report.getContentType(), report.getSize(), response);
        } finally {
            report.dispose();
        }
    }

    private void createJasperReport(HttpServletRequest request,
        HttpServletResponse response, String reportName) throws IOException {

        log.info("Creating a Jasper report");

        // Generate report on disk.
        String contextDir = context.getRealPath("/");
        String format = getFormat(request);
        String uriDotExt = REPORT_URI_BASE
            + File.separator
            + request.getSession()
                .getId()
            + File.separator
            + reportName
            + (format.equals(PDF_FORMAT) ? PDF.getFileExtension()
                : HTML.getFileExtension());
        File reportFile = new File(contextDir, uriDotExt);
        generateReport(request, response, reportFile, reportName, new Date());

        // Stream out the generated report.
        serveFile(reportFile, response);

    }

    private void generateReport(HttpServletRequest request,
        HttpServletResponse response, File reportFile, String reportName,
        Date generationDate) {

        String destinationFilename = reportFile.getAbsolutePath();
        try {
            Map<String, Object> generationParameters = new HashMap<String, Object>();
            @SuppressWarnings("unchecked")
            Map<? extends String, ? extends Object> parameterMap = request.getParameterMap();
            generationParameters.putAll(parameterMap);
            JasperPrint filledReport = fillAndExportReport(reportName,
                generationParameters, destinationFilename, request,
                generationDate);

            // Render/export the report.
            if (getFormat(request).equals(PDF_FORMAT)) {
                JasperExportManager.exportReportToPdfFile(filledReport,
                    destinationFilename);
            } else {
                JasperExportManager.exportReportToHtmlFile(filledReport,
                    destinationFilename);
            }
        } catch (Exception e) {
            displayError(response, destinationFilename, e);
        }
    }

    private JasperPrint fillAndExportReport(String name,
        Map<String, Object> generationParameters, String destinationFilename,
        HttpServletRequest request, Date generationDate) throws JRException {

        String contextDir = context.getRealPath("/");
        if (!contextDir.endsWith("/")) {
            contextDir = contextDir + "/";
        }

        // Make sure the destination directory exists.
        if (!new File(destinationFilename).getParentFile()
            .mkdirs()) {
            ; // Ignore since mkdirs returns false if the directory exists.
        }

        Map<Object, Object> reportParameters = new HashMap<Object, Object>();
        reportParameters.put(GENERATION_PARAMETERS_KEY, generationParameters);

        // Set the report generation date.
        reportParameters.put(PARAM_GENERATION_DATE_UTC,
            MrTimeUtil.dateFormatter()
                .format(generationDate));
        reportParameters.put(PARAM_GENERATION_DATE_UTC_URL,
            MrTimeUtil.urlDateFormatter()
                .format(generationDate));

        // Set the server's base URL in the report parameters.
        String serverUrl = new StringBuilder().append("http://")
            .append(request.getServerName())
            .toString();
        if (request.getServerPort() != 80) {
            serverUrl = new StringBuilder().append(serverUrl)
                .append(":")
                .append(request.getServerPort())
                .toString();
        }
        serverUrl = serverUrl + request.getContextPath();
        reportParameters.put(PARAM_SERVER_URL, serverUrl);

        String format = getFormat(request);

        // Set the report URL -- the URL including query string to re-generate.
        String reportUrl = new StringBuilder().append(serverUrl)
            .append(REPORT_URI_BASE)
            .append("/")
            .append(name)
            .append(".")
            .append(format)
            .toString();

        if (format.equals(HTML_FORMAT)) {
            reportParameters.put(PARAM_IGNORE_PAGINATION, Boolean.TRUE);
        }
        reportParameters.put(PARAM_REPORT_URL, reportUrl);

        // Give the JasperReports engine a database Connection and a Session.
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        Connection connection = databaseService.getConnection();
        Session session = databaseService.getSession();
        reportParameters.put(
            JRHibernateQueryExecuterFactory.PARAMETER_HIBERNATE_SESSION,
            session);

        // Fill the report.
        JasperPrint filledReport = JasperFillManager.fillReport(contextDir
            + WEBAPP_COMPILED_DIR + "/" + name + DOT_JASPER, reportParameters,
            connection);

        return filledReport;
    }

    private void serveFile(File file, HttpServletResponse response)
        throws IOException {

        InputStream istream = new FileInputStream(file);

        try {
            serveStream(istream, file.getName(),
                contentTypeFromExtension(file), file.length(), response);
        } catch (IOException e) {
            throw e;
        } finally {
            istream.close();
        }
    }

    private void serveStream(InputStream istream, String filename,
        String contentType, long length, HttpServletResponse response)
        throws IOException {

        log.info(String.format("Serving %s (%s, %d bytes)", filename,
            contentType, length));

        // Set the appropriate output headers.
        response.setContentType(contentType);
        response.setContentLength((int) length);
        if (contentType.equals(PDF.getContentType())) {
            response.setHeader(CONTENT_DISPOSITION,
                CONTENT_DISPOSITION_FILENAME + filename);
        }

        // Calculate and set buffer size.
        int bufferSize = bufferSizeFromContentType(contentType, length);
        try {
            log.info(String.format("Response bufferSize: old=%d, new=%d",
                response.getBufferSize(), bufferSize));
            response.setBufferSize(bufferSize);
        } catch (IllegalStateException e) {
            // Do nothing.
        }

        // Try to retrieve the servlet output stream.
        ServletOutputStream ostream = null;
        PrintWriter writer = null;
        try {
            ostream = response.getOutputStream();
        } catch (IllegalStateException e) {
            // If it fails, we try to get a Writer instead if we're
            // trying to serve a text file.
            if (contentType.startsWith(TEXT)
                || contentType.endsWith(XML.getContentType())) {
                writer = response.getWriter();
            } else {
                throw e;
            }
        }

        // Copy the file stream to the client.
        byte buffer[] = new byte[bufferSize];
        int len = buffer.length;
        while (true) {
            len = istream.read(buffer);
            if (len == -1) {
                break;
            }
            if (ostream != null) {
                ostream.write(buffer, 0, len);
            } else if (writer != null) {
                writer.write(new String(buffer, CHARSET));
            } else {
                // Should never happen.
                throw new IOException("No writers available");
            }
        }
    }

    private String getReportName(HttpServletRequest request) {
        String pathInfo = request.getPathInfo();
        log.info("pathInfo=" + pathInfo);
        if (pathInfo == null) {
            log.warn("Did not receive path info");
            return null;
        }

        // Strip off .html_files/px.
        int imageDir = pathInfo.indexOf(IMAGE_DIR);
        if (imageDir != -1) {
            pathInfo = pathInfo.substring(0, imageDir);
        }

        // Assume first char is a slash.
        int firstSlash = pathInfo.indexOf("/");
        if (firstSlash != 0) {
            log.warn("URL \"" + pathInfo + "\" did not start with a /");
            return null;
        }

        // Strip off leading / to yield report's name.
        String reportName = pathInfo.substring(firstSlash + 1);
        if (reportName.length() == 0) {
            log.warn("URL \"" + pathInfo + "\" yielded an empty report name");
            return null;
        }

        return reportName;
    }

    private String getImageName(HttpServletRequest request) {

        // Error checking already performed in getReportName.
        // Can now assume URL begins with a /.
        String pathInfo = request.getPathInfo();

        int imageIndex = pathInfo.indexOf(IMAGE_DIR);
        if (imageIndex == -1) {
            return null;
        }

        // Strip off leading / to yield image directory's name.
        String imageName = pathInfo.substring(1);
        if (imageName.length() == 0) {
            log.warn("URL \"" + pathInfo
                + "\" yielded an empty image directory name");
            return null;
        }

        return imageName;
    }

    private String getFormat(HttpServletRequest request) {
        String format = request.getParameter(PARAM_FORMAT);
        if (format == null) {
            format = HTML_FORMAT;
        }

        return format;
    }

    private String contentTypeFromExtension(File file) {
        String filename = file.getAbsolutePath();
        int index = filename.lastIndexOf('.');
        if (index > -1) {
            String fileExtension = filename.substring(index, filename.length());
            MimeType mimeType = MimeType.valueOfFileExtension(fileExtension);
            if (mimeType != MimeType.OCTET_STREAM) {
                return mimeType.getContentType();
            }
            if (filename.contains(IMAGE_DIR)) {
                return PNG.getContentType();
            }
        }
        return HTML.getContentType();
    }

    /**
     * Returns an appropriate buffer size based upon the content type. For
     * PDF_FORMAT files and images which can't be shown incrementally to the
     * user, return the smaller of the length of the file or
     * {@link #MAX_RESPONSE_BUFFER_SIZE}. Otherwise, return the server default
     * of 8 kB (see {@link #DEFAULT_RESPONSE_BUFFER_SIZE}) to increase perceived
     * performance.
     * 
     * @param contentType the content type of the response
     * @param length the length of the response
     * @return an appropriate buffer size
     */
    private int bufferSizeFromContentType(String contentType, long length) {
        if (contentType.equals(GIF.getContentType())
            || contentType.equals(PDF.getContentType())
            || contentType.equals(PNG.getContentType())) {

            // Cast is safe, since value is no larger than
            // MAX_RESPONSE_BUFFER_SIZE.
            return length > MAX_RESPONSE_BUFFER_SIZE ? MAX_RESPONSE_BUFFER_SIZE
                : (int) length;
        }

        return DEFAULT_RESPONSE_BUFFER_SIZE;
    }

    private void displayError(HttpServletResponse response,
        String destinationFilename, Exception e) {

        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        e.printStackTrace(printWriter);
        printWriter.flush();
        String exceptionStack = stringWriter.toString();
        log.error("Exception while generating report " + destinationFilename);
        log.error(exceptionStack);
        PrintWriter out;
        try {
            out = response.getWriter();
            out.write("Error: \n");
            out.write(exceptionStack + "\n");
        } catch (IOException e1) {
            log.error(e1);
        }
        printWriter.close();

        Throwable t = e.getCause();
        if (t != null) {
            stringWriter = new StringWriter();
            printWriter = new PrintWriter(stringWriter);
            t.printStackTrace(printWriter);
            printWriter.flush();
            String throwableStack = stringWriter.toString();
            log.error(throwableStack);
            try {
                out = response.getWriter();
                out.write(throwableStack);
            } catch (IOException e1) {
                log.error(e1);
            }
        }
        try {
            out = response.getWriter();
            out.write('\n');
        } catch (IOException e1) {
            log.error(e1);
        }
    }
}
