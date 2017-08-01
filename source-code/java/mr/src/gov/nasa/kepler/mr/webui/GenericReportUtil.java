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

package gov.nasa.kepler.mr.webui;

import gov.nasa.kepler.hibernate.mr.MrReport;
import gov.nasa.kepler.hibernate.mr.MrReportCrud;
import gov.nasa.kepler.mr.ParameterUtil;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Provides methods for locating a generic report.
 * 
 * @author Bill Wohler
 */
public class GenericReportUtil extends AbstractUtil {

    private static final Log log = LogFactory.getLog(AbstractUtil.class);

    /**
     * Returns a group of HTML options containing valid module names.
     * 
     * @return a non-{@code null} string containing HTML options or an error
     * message if the modules names could not be found
     */
    public String moduleNames() {
        log.info("Retrieving module names");
        dbPrepare();

        List<String> names = null;
        try {
            names = new MrReportCrud().retrieveModuleNames();
        } catch (Exception e) {
            return displayError("Could not obtain module names: ", e);
        }

        if (names.size() == 0) {
            String errorText = "No reports have been created.";
            return displayError(errorText);
        }

        StringBuilder options = new StringBuilder();
        boolean firstItem = true;
        for (String name : names) {
            options.append("<option value=\"")
                .append(name)
                .append('\"')
                .append(firstItem ? " selected" : "")
                .append(">")
                .append(name)
                .append("</option>\r");
            firstItem = false;
        }

        return options.toString();
    }

    /**
     * Returns a group of HTML options representing nodes for the given module
     * name between the given times, inclusive.
     * <p>
     * The node is a string that looks like "cal 1 1". The three components are
     * the module name, the pipeline instance ID, and the pipeline instance node
     * ID.
     * 
     * @param moduleName the selected module name
     * @param startTime the starting time, inclusive
     * @param endTime the ending time, inclusive
     * @return a non-{@code null} string containing HTML options or an error
     * message if the associated nodes could not be found
     */
    public String nodes(String moduleName, String startTime, String endTime) {
        log.info("Retrieving nodes: moduleName=" + moduleName + ", startTime="
            + startTime + ", endTime" + endTime);
        dbPrepare();

        List<String> nodes = new ArrayList<String>();
        try {
            ParameterUtil parameterUtil = new ParameterUtil();
            parameterUtil.parseStartEndTime(startTime, endTime);
            List<MrReport> reports = new MrReportCrud().retrieveReports(
                moduleName, parameterUtil.getStartTime(),
                parameterUtil.getEndTime());

            // The query above returns all reports sorted by instance, node, and
            // task. However, at the moment we're only interested in the
            // distinct instances and nodes. The condition below avoids printing
            // the same instances and nodes over and over.
            long lastInstanceId = -1;
            long lastNodeId = -1;
            for (MrReport report : reports) {
                if (report.getPipelineInstance()
                    .getId() != lastInstanceId
                    || report.getPipelineInstanceNode()
                        .getId() != lastNodeId) {
                    nodes.add(String.format("%-20s %7d %7d", moduleName,
                        report.getPipelineInstance()
                            .getId(), report.getPipelineInstanceNode()
                            .getId()));
                    lastInstanceId = report.getPipelineInstance()
                        .getId();
                    lastNodeId = report.getPipelineInstanceNode()
                        .getId();
                }
            }
        } catch (Exception e) {
            return displayError("Could not obtain node names: ", e);
        }

        if (nodes.size() == 0) {
            String errorText = "No reports have been created.";
            return displayError(errorText);
        }

        StringBuilder options = new StringBuilder();
        boolean firstItem = true;
        for (String name : nodes) {
            options.append("<option value=\"")
                .append(name)
                .append('\"')
                .append(firstItem ? " selected" : "")
                .append(">")
                .append(toNbsp(name))
                .append("</option>\r");
            firstItem = false;
        }

        return options.toString();
    }

    /**
     * Returns a group of HTML options representing generic report identifiers
     * for the given node. The node is a string that looks like "cal 1 1". The
     * three components are the module name, the pipeline instance ID, and the
     * pipeline instance node ID.
     * <p>
     * The generic report identifier is a string that looks like
     * "1 12345678 (0-1440 [16/1])". The first number is the pipeline instance
     * ID, the second field, which may include spaces, is the generic report
     * identifier, and the text in parenthesis is a string representation of the
     * task's unit of work.
     * 
     * @param node the selected node
     * @return a non-{@code null} string containing HTML options or an error
     * message if the associated task or report could not be found
     */
    public String genericReportIdentifiers(String node) {
        log.info("Retrieving generic report identifiers: node=" + node);
        dbPrepare();

        List<String> tasks = new ArrayList<String>();
        try {
            // Parse node.
            String[] args = node.trim()
                .split(" +");
            if (args.length != 3) {
                throw new IllegalArgumentException("\"" + node + "\" has "
                    + args.length + " fields; expected 3");
            }
            String module = args[0];
            long pipelineInstanceId = Integer.parseInt(args[1]);
            long pipelineInstanceNodeId = Integer.parseInt(args[2]);

            // Look up tasks.
            List<MrReport> reports = new MrReportCrud().retrieveReports(module,
                pipelineInstanceId, pipelineInstanceNodeId);

            // 0 0-1440 [16/1]
            for (MrReport report : reports) {
                StringBuffer uow = new StringBuffer();
                uow.append("(")
                    .append(report.getPipelineTask()
                        .uowTaskInstance()
                        .briefState())
                    .append(")");
                tasks.add(String.format("%7d %10s %20s",
                    report.getPipelineTask()
                        .getId(),
                    report.getIdentifier() != null ? report.getIdentifier()
                        : NO_DATA, uow.toString()));
            }
        } catch (Exception e) {
            return displayError(
                "Could not obtain generic report identifiers: ", e);
        }

        if (tasks.size() == 0) {
            String errorText = "No reports have been created.";
            return displayError(errorText);
        }

        StringBuilder options = new StringBuilder();
        boolean firstOption = true;
        for (String task : tasks) {
            options.append("<option value=\"")
                .append(task)
                .append('\"')
                .append(firstOption ? " selected" : "")
                .append(">")
                .append(toNbsp(task))
                .append("</option>\r");
            firstOption = false;
        }

        return options.toString();
    }
}
