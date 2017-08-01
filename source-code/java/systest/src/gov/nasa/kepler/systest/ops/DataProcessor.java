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

package gov.nasa.kepler.systest.ops;

import static gov.nasa.kepler.hibernate.pi.PipelineInstance.State.COMPLETED;
import gov.nasa.kepler.common.Iso8601Formatter;
import gov.nasa.kepler.common.UsageException;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance.State;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNodeCrud;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.spiffy.common.collect.Pair;

import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Data processing report generator.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class DataProcessor {

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(DataProcessor.class);

    private static final String TBD = "TBD";

    private ReportGenerationOptions options;

    private PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud();
    private PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();

    public DataProcessor(ReportGenerationOptions options) {
        if (options == null) {
            throw new NullPointerException("options can't be null");
        }

        this.options = options;
        validateOptions();
    }

    private void validateOptions() {
        switch (options.getCommand()) {
            case DATA_PROCESSING_REPORT:
                // Nothing special.
                break;
            case DATA_PROCESSING_SUMMARY:
                if (options.getDataName() == null) {
                    throw new UsageException("Data name not set");
                }
                break;
            default:
                throw new IllegalStateException("Unexpected command "
                    + options.getCommand()
                        .getName());
        }

        if (options.getClusterName() == null) {
            throw new UsageException("Cluster name not set");
        }
        if (options.getJiraTicket() == null) {
            throw new UsageException("Jira ticket not set");
        }
        if (options.getPipelineInstanceIds() == null
            || options.getPipelineInstanceIds()
                .isEmpty()) {
            throw new UsageException("Pipeline instance ID(s) not set");
        }
    }

    public void generateReport() {

        List<PipelineInstance> pipelineInstances = retrievePipelineInstances();
        TextRenderer textRenderer = options.getTextRenderer();

        textRenderer.renderTableBegin("border=\"0\" cellspacing=\"0\"",
            "padding-right: 1em; vertical-align: top");

        textRenderer.renderTableRow("Pipeline:",
            getPipelineName(pipelineInstances));
        textRenderer.renderTableRow("JIRA Ticket:", options.getJiraTicket());
        textRenderer.renderTableRow("Date:", Iso8601Formatter.dateFormatter()
            .format(getLatestEndDate(pipelineInstances)));
        textRenderer.renderTableRow("Pipeline Instance ID:",
            getPipelineInstanceInfo(pipelineInstances));
        textRenderer.renderTableRow("Software:",
            retrieveSoftwareRevisions(pipelineInstances));
        if (options.getReleaseToSt() != null) {
            textRenderer.renderTableRow("Released to ST:",
                options.getReleaseToSt());
        }
        if (options.getReleaseToPublic() != null) {
            textRenderer.renderTableRow("Released to Public:",
                options.getReleaseToPublic());
        }
        textRenderer.renderTableRow("Available in:", options.getClusterName());

        for (Pair<String, String> field : options.getFields()) {
            textRenderer.renderTableRow(field.left + ":", field.right);
        }

        textRenderer.renderTableEnd();
    }

    private List<PipelineInstance> retrievePipelineInstances() {

        List<PipelineInstance> pipelineInstances = new ArrayList<PipelineInstance>();

        for (long pipelineInstanceId : options.getPipelineInstanceIds()) {
            PipelineInstance pipelineInstance = pipelineInstanceCrud.retrieve(pipelineInstanceId);
            if (pipelineInstance == null) {
                throw new IllegalArgumentException(String.format(
                    "Pipeline instance ID %d not found", pipelineInstanceId));
            }
            pipelineInstances.add(pipelineInstance);
        }

        return pipelineInstances;
    }

    private String getPipelineName(List<PipelineInstance> pipelineInstances) {

        String pipelineName = null;
        for (PipelineInstance pipelineInstance : pipelineInstances) {
            String name = pipelineInstance.getPipelineDefinition()
                .getName()
                .toString();
            if (pipelineName == null) {
                pipelineName = name;
            } else {
                if (!pipelineName.equals(name)) {
                    throw new IllegalArgumentException(
                        String.format(
                            "Pipeline name %s for instance ID %d inconsistent with previous name of %s",
                            name, pipelineInstance.getId(), pipelineName));
                }
            }
        }

        return pipelineName;
    }

    private Date getLatestEndDate(List<PipelineInstance> pipelineInstances) {

        Date latestEndDate = null;
        for (PipelineInstance pipelineInstance : pipelineInstances) {
            Date date = pipelineInstance.getEndProcessingTime();
            if (latestEndDate == null || date.after(latestEndDate)) {
                latestEndDate = date;
            }
        }

        return latestEndDate;
    }

    private String getPipelineInstanceInfo(
        List<PipelineInstance> pipelineInstances) {

        StringBuilder pipelineInstanceInfo = new StringBuilder();

        for (PipelineInstance pipelineInstance : pipelineInstances) {
            if (pipelineInstanceInfo.length() > 0) {
                pipelineInstanceInfo.append(", ");
            }

            pipelineInstanceInfo.append(pipelineInstance.getId())
                .append(" (")
                .append(retrieveModuleInfo(pipelineInstance))
                .append(")");
        }

        return pipelineInstanceInfo.toString();
    }

    private String retrieveModuleInfo(PipelineInstance pipelineInstance) {
        return retrieveModuleInfo(pipelineInstance, false);
    }

    private String retrieveModuleInfo(PipelineInstance pipelineInstance,
        boolean brief) {

        List<PipelineInstanceNode> pipelineNodes = new PipelineInstanceNodeCrud().retrieveAll(pipelineInstance);
        StringBuilder completedModules = new StringBuilder();

        boolean complete = true;
        for (PipelineInstanceNode node : pipelineNodes) {
            PipelineModuleDefinition module = node.getPipelineModuleDefinition();
            if (completedModules.length() > 0) {
                completedModules.append("+");
            }
            completedModules.append(module.getName()
                .toString()
                .toUpperCase());
            if (node.state() != COMPLETED) {
                complete = false;
                if (!brief) {
                    completedModules.append("[")
                        .append(node.state()
                            .toString())
                        .append("]");
                }
            }
        }

        return complete && brief ? null : completedModules.toString();
    }

    private String retrieveSoftwareRevisions(
        List<PipelineInstance> pipelineInstances) {

        // Build map of software revisions to the modules that were run with
        // that revision.
        Map<String, List<String>> moduleNamesBySoftwareRevision = new TreeMap<String, List<String>>();
        for (PipelineInstance pipelineInstance : pipelineInstances) {
            List<PipelineInstanceNode> pipelineNodes = new PipelineInstanceNodeCrud().retrieveAll(pipelineInstance);
            for (PipelineInstanceNode node : pipelineNodes) {
                if (node.state() != State.COMPLETED) {
                    continue;
                }
                PipelineModuleDefinition module = node.getPipelineModuleDefinition();
                String moduleName = module.getName()
                    .toString()
                    .toUpperCase();
                for (String softwareRevision : pipelineTaskCrud.distinctSoftwareRevisions(node)) {
                    addModuleName(moduleNamesBySoftwareRevision,
                        softwareRevision, moduleName);
                }
            }
        }

        // Display software revisions. Show the modules as a prefix, unless
        // there is only one revision in which case it is assumed that the
        // revision was used for all of the modules.
        // Separate multiple software revisions with a newline and a two space
        // indent.
        boolean addNewlinesAndModules = moduleNamesBySoftwareRevision.size() > 1;
        String lineSeparator = System.getProperty("line.separator") + "  ";
        StringBuilder softwareRevisions = new StringBuilder();

        for (String softwareRevision : moduleNamesBySoftwareRevision.keySet()) {
            if (addNewlinesAndModules) {
                softwareRevisions.append(lineSeparator);
                boolean addPlus = false;
                for (String module : moduleNamesBySoftwareRevision.get(softwareRevision)) {
                    if (addPlus) {
                        softwareRevisions.append("+");
                    }
                    softwareRevisions.append(module);
                    addPlus = true;
                }
                softwareRevisions.append(": ");
            }
            softwareRevisions.append(softwareRevision);
        }

        return softwareRevisions.toString();
    }

    private void addModuleName(
        Map<String, List<String>> moduleNameBySoftwareRevision,
        String softwareRevision, String moduleName) {

        List<String> moduleNames = moduleNameBySoftwareRevision.get(softwareRevision);
        if (moduleNames == null) {
            moduleNames = new ArrayList<String>();
            moduleNameBySoftwareRevision.put(softwareRevision, moduleNames);
        }
        moduleNames.add(moduleName);
    }

    public void generateSummary() {
        DateFormat dateFormatter = Iso8601Formatter.dateFormatter();

        List<PipelineInstance> pipelineInstances = retrievePipelineInstances();
        String pipelineName = getPipelineName(pipelineInstances);
        String pipelineDate = dateFormatter.format(getLatestEndDate(pipelineInstances));
        String stDate = extractOption(options.getReleaseToSt());
        String publicDate = extractOption(options.getReleaseToPublic());

        // Q0 LC Quarterly 4/28/10 KSOP-435 SPQ Sept 2009 6/15/10
        options.getTextRenderer()
            .renderTableRow(options.getDataName(), pipelineName, pipelineDate,
                options.getJiraTicket(), options.getClusterName(), stDate,
                publicDate, retrieveSoftwareVersions(pipelineInstances));
    }

    String retrieveSoftwareVersions(List<PipelineInstance> pipelineInstances) {

        Set<String> softwareVersionSet = new TreeSet<String>();

        for (PipelineInstance pipelineInstance : pipelineInstances) {
            for (String softwareRevision : pipelineTaskCrud.distinctSoftwareRevisions(pipelineInstance)) {

                if (!addMatch(
                    softwareVersionSet,
                    "svn\\+ssh://host[^/]*/path/to/code/([\\d.]+)@[\\d]+",
                    softwareRevision)
                    && !addMatch(
                        softwareVersionSet,
                        "svn\\+ssh://host[^/]*/path/to/code/([\\d.]+)@[\\d]+",
                        softwareRevision)
                    && !addMatch(
                        softwareVersionSet,
                        "svn\\+ssh://host[^/]*/path/to/code/([^@]+)@[\\d]+",
                        softwareRevision)
                    && !addMatch(softwareVersionSet,
                        "svn\\+ssh://host[^/]*/path/to/code@[\\d]+",
                        softwareRevision)) {
                    throw new IllegalStateException(
                        String.format(
                            "Unexpected software revision %s for pipeline instance %d",
                            softwareRevision, pipelineInstance.getId()));
                }
            }
        }

        StringBuilder softwareVersions = new StringBuilder();
        for (String softwareVersion : softwareVersionSet) {
            if (softwareVersions.length() > 0) {
                softwareVersions.append(", ");
            }
            softwareVersions.append(softwareVersion);
        }

        return softwareVersions.toString();
    }

    private boolean addMatch(Set<String> matches, String regexp, String input) {

        Pattern pattern = Pattern.compile(regexp);
        Matcher matcher = pattern.matcher(input);
        if (matcher.matches()) {
            matches.add(matcher.group(1));
            return true;
        }

        return false;
    }

    private String extractOption(String option) {
        return option != null ? option : TBD;
    }

    void setPipelineInstanceCrud(PipelineInstanceCrud pipelineInstanceCrud) {
        this.pipelineInstanceCrud = pipelineInstanceCrud;
    }

    void setPipelineTaskCrud(PipelineTaskCrud pipelineTaskCrud) {
        this.pipelineTaskCrud = pipelineTaskCrud;
    }
}
