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
import static gov.nasa.kepler.mr.servlet.ReportViewerServlet.PARAM_GENERATION_DATE_UTC;
import static gov.nasa.kepler.mr.servlet.ReportViewerServlet.PARAM_GENERATION_DATE_UTC_URL;
import static gov.nasa.kepler.mr.servlet.ReportViewerServlet.PARAM_IGNORE_PAGINATION;
import static gov.nasa.kepler.mr.servlet.ReportViewerServlet.PARAM_REPORT_URL;
import static gov.nasa.kepler.mr.servlet.ReportViewerServlet.PARAM_SERVER_URL;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.StringTokenizer;

import net.sf.jasperreports.engine.JREmptyDataSource;
import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JasperExportManager;
import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperPrintManager;
import net.sf.jasperreports.engine.JasperRunManager;

public class JasperReportGenerator {

    private static final String TASK_FILL = "fill";
    private static final String TASK_PRINT = "print";
    private static final String TASK_PDF = "pdf";
    private static final String TASK_HTML = "html";
    private static final String TASK_RUN = "run";

    public static void main(String[] args) {
        String fileName = null;
        String taskName = null;

        if (args.length == 0) {
            usage();
        }

        for (String arg : args) {
            if (arg.startsWith("-T")) {
                taskName = arg.substring(2);
                if (taskName.isEmpty()) {
                    usage();
                }
            }
            if (arg.startsWith("-F")) {
                fileName = arg.substring(2);
                if (fileName.isEmpty()) {
                    usage();
                }
            }
        }

        try {
            new JasperReportGenerator().generate(taskName, fileName);
        } catch (JRException e) {
            e.printStackTrace();
            System.exit(1);
        } catch (UnsupportedOperationException e) {
            usage();
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }

        System.exit(0);
    }

    private static void usage() {
        System.out.println("JasperReportGenerator usage:");
        System.out.println("\tjava JasperReportGenerator -Ttask -Ffile");
        System.out.println("\tTasks : fill | pdf | html | run");
        System.exit(1);
    }

    private void generate(String taskName, String fileName) throws JRException {
        long start = System.currentTimeMillis();
        if (taskName.equals(TASK_FILL)) {
            fill(fileName);
            System.err.println("Filling time : "
                + (System.currentTimeMillis() - start));
        } else if (taskName.equals(TASK_PRINT)) {
            print(fileName);
            System.err.println("Printing time : "
                + (System.currentTimeMillis() - start));
        } else if (taskName.equals(TASK_PDF)) {
            exportPdf(fileName);
            System.err.println("PDF creation time : "
                + (System.currentTimeMillis() - start));
        } else if (taskName.equals(TASK_HTML)) {
            exportHtml(fileName);
            System.err.println("HTML creation time : "
                + (System.currentTimeMillis() - start));
        } else if (taskName.equals(TASK_RUN)) {
            runPdf(fileName);
            System.err.println("PDF running time : "
                + (System.currentTimeMillis() - start));
        } else {
            throw new UnsupportedOperationException();
        }
    }

    public void runPdf(String fileName) throws JRException {
        JasperRunManager.runReportToPdfFile(fileName, null,
            new JREmptyDataSource());
    }

    public void exportHtml(String fileName) throws JRException {
        JasperExportManager.exportReportToHtmlFile(fileName);
    }

    public void exportPdf(String fileName) throws JRException {
        JasperExportManager.exportReportToPdfFile(fileName);
    }

    public void print(String fileName) throws JRException {
        JasperPrintManager.printReport(fileName, true);
    }

    public void fill(String fileName) throws JRException {

        Map<String, Object> reportParameters = new HashMap<String, Object>();
        Map<String, Object> generationParameters = new HashMap<String, Object>();
        parseParams(generationParameters);

        reportParameters.put(GENERATION_PARAMETERS_KEY, generationParameters);

        reportParameters.put("SUBREPORT_DIR", "build/compiled-report/");

        // Set the report generation date.
        Date date = new Date();
        String urlDate = MrTimeUtil.urlDateFormatter()
            .format(date);
        reportParameters.put(PARAM_GENERATION_DATE_UTC,
            MrTimeUtil.dateFormatter()
                .format(date));
        reportParameters.put(PARAM_GENERATION_DATE_UTC_URL, urlDate);

        // Set the server's base URL in the report parameters.
        String serverUrl = "http://localhost:8000";
        reportParameters.put(PARAM_SERVER_URL, serverUrl);

        String reportUrl = serverUrl + "/" + fileName;

        // Build the remainder of the report URL and set it.
        StringBuilder reportUrlStringBuilder = new StringBuilder();
        reportUrlStringBuilder.append(reportUrl)
            .append('?');
        boolean firstParam = true;
        for (Object element : generationParameters.keySet()) {
            String key = (String) element;
            if (firstParam) {
                firstParam = false;
            } else {
                reportUrlStringBuilder.append('&');
            }
            reportUrlStringBuilder.append(key)
                .append('=')
                .append(((String[]) generationParameters.get(key))[0]);
        }
        reportParameters.put(PARAM_REPORT_URL,
            reportUrlStringBuilder.toString());

        String[] param = (String[]) generationParameters.get("format");
        if (param != null && param.length > 0) {
            String format = param[0];
            if (format.equals("html")) {
                reportParameters.put(PARAM_IGNORE_PAGINATION,
                    Boolean.valueOf(true));
            }
        }

        JasperFillManager.fillReportToFile(fileName, reportParameters,
            new JREmptyDataSource());
    }

    public void parseParams(Map<String, Object> generationParameters) {
        String params = System.getProperty("params");
        if (params != null) {
            StringTokenizer st = new StringTokenizer(params, "&", false);
            while (st.hasMoreTokens()) {
                String param = st.nextToken();
                if (param == null || param.length() < 3) {
                    continue;
                }
                int index = param.indexOf('=');
                if (index != -1 && index > 0 && index < param.length() - 1) {
                    generationParameters.put(
                        param.substring(0, index),
                        new String[] { param.substring(index + 1,
                            param.length()) });
                    System.out.println("PARAM: " + param.substring(0, index)
                        + "=" + param.substring(index + 1, param.length()));
                }
            }
        }
    }

}
