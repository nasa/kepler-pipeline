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

package gov.nasa.kepler.pi.metrics.report;

import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNodeCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.List;
import java.util.Map;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;

/**
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class PerformanceReport {
    private static final Log log = LogFactory.getLog(PerformanceReport.class);
    
    private static String INSTANCE_ID_OPT = "id";
    private static String TASK_FILES_OPT = "taskdir";
    private static String NODE_IDS_OPT = "nodes";
    private static String FORCE_OPT = "force";
    
    private long instanceId;
    private File taskFilesDir;
    private Pair<Integer, Integer> nodes;
    
    public PerformanceReport(long instanceId, File taskFilesDir, Pair<Integer,Integer> nodes) {
        this.instanceId = instanceId;
        this.taskFilesDir = taskFilesDir;
        this.nodes = nodes;
    }

    private void generateReport() throws Exception {
        log.info("Generating performance report");
        
        PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud();
        PipelineInstanceNodeCrud pipelineInstanceNodeCrud = new PipelineInstanceNodeCrud();
        PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();
        
        PipelineInstance instance = pipelineInstanceCrud.retrieve(instanceId);
        
        if(instance == null){
            System.err.println("No instance found with ID = " + instanceId);
            System.exit(-1);
        }

        File outputFile = null;
        String name = "perf-report-" + instanceId + ".pdf";
        
        if(taskFilesDir != null){
            outputFile = new File(taskFilesDir, name);
        }else{
            outputFile = new File(name);
        }

        log.info("Writing report to: " + outputFile);

        PdfRenderer pdfRenderer = new PdfRenderer(outputFile, false);
        
        List<PipelineInstanceNode> instanceNodes = pipelineInstanceNodeCrud.retrieveAll(instance);
        List<PipelineInstanceNode> nodesToProcess = null;
        String nodesIncluded;
        
        if(nodes == null){
            nodesIncluded = "All";
            nodesToProcess = instanceNodes;
        }else{
            nodesIncluded = nodes.toString();
            nodesToProcess = selectNodes(instanceNodes);
        }
        
        pdfRenderer.printText("Nodes included in report: " + nodesIncluded, PdfRenderer.h1Font);
        pdfRenderer.println();

        InstanceReport instanceReport = new InstanceReport(pdfRenderer);
        instanceReport.generateReport(instance, nodesToProcess);

        if(nodesToProcess.isEmpty()){
            System.err.println("No instance nodes found for instance = " + instanceId);
            System.exit(-1);
        }else{
            pdfRenderer.newPage();

            for (PipelineInstanceNode node : nodesToProcess) {
                List<PipelineTask> nodeTasks = pipelineTaskCrud.retrieveAll(node);
                generateNodeReport(pdfRenderer, node, nodeTasks);
            }
        }
        
        pdfRenderer.newPage();

        AppendixReport appendixReport = new AppendixReport(pdfRenderer);
        appendixReport.generateReport(instance, nodesToProcess);
        
        pdfRenderer.close();

        log.info("DONE Generating performance report");
    }

    private List<PipelineInstanceNode> selectNodes(List<PipelineInstanceNode> instanceNodes) {
        int startNode = nodes.left;
        int endNode = nodes.right;
        
        if(startNode < 0 || startNode > (instanceNodes.size() - 1) 
            || endNode < 0 || endNode > (instanceNodes.size() - 1) 
            || startNode > endNode){
            throw new PipelineException("Invalid node range: " + nodes);
        }
        
        log.info("processing nodes " + startNode + " to " + endNode);
        
        return instanceNodes.subList(startNode, endNode + 1);
    }

    private void generateNodeReport(PdfRenderer pdfRenderer, PipelineInstanceNode node, List<PipelineTask> tasks) throws Exception {
        String moduleName = node.getPipelineModuleDefinition().getName().getName();
                
        NodeReport nodeReport = new NodeReport(pdfRenderer);
        nodeReport.generateReport(node, tasks);
        
        pdfRenderer.newPage();
                
        if(taskFilesDir != null){
            // generate matlab report
            MatlabReport matlabReport = new MatlabReport(pdfRenderer, taskFilesDir, moduleName);
            matlabReport.generateReport();        
        }else{
            pdfRenderer.printText("No per-process statistics available: Task files directory not specified", PdfRenderer.h1Font);
        }

        pdfRenderer.newPage();

        log.info("category report");
        
        List<String> orderedCategoryNames = nodeReport.getOrderedCategoryNames();
        Map<String, DescriptiveStatistics> categoryStats = nodeReport.getCategoryStats();
        Map<String, TopNList> topTen = nodeReport.getCategoryTopTen();
        
        for (String category : orderedCategoryNames) {
            log.info("processing category: " + category);

            boolean isTime = nodeReport.categoryIsTime(category);
            CategoryReport categoryReport = new CategoryReport(category, pdfRenderer, isTime);
            categoryReport.generateReport(moduleName, categoryStats.get(category), topTen.get(category));
        }
    }

    private static void usageAndExit(String msg, Options options) {
        System.err.println(msg);
        HelpFormatter formatter = new HelpFormatter();
        formatter.printHelp("perf-report", options);
        System.exit(-1);
    }
    
    private static Pair<Integer,Integer> parseNodesArg(String nodesArg, Options options) {
        String[] parts = nodesArg.split(":");
        
        if(parts.length != 2){
            usageAndExit("Node indices must be specified in START:END format. You entered: " + nodesArg, options);
        }
        
        int startNodeIndex = -1;
        int endNodeIndex = -1;
        
        try {
            startNodeIndex = Integer.parseInt(parts[0]);
        } catch (NumberFormatException e) {
            usageAndExit("Invalid start node index: " + parts[0], options);
        }
        
        try {
            endNodeIndex = Integer.parseInt(parts[1]);
        } catch (NumberFormatException e) {
            usageAndExit("Invalid end node index: " + parts[1], options);
        }
        
        return Pair.of(startNodeIndex, endNodeIndex);
    }   

    public static void main(String[] args) throws Exception {
        Options options = new Options();
        options.addOption(INSTANCE_ID_OPT, true, "Pipeline instance ID");
        options.addOption(TASK_FILES_OPT, true, "Top-level task file for instance");
        options.addOption(NODE_IDS_OPT, true, "Start and end node indices in START:END format. Default is all nodes");
        options.addOption(FORCE_OPT, false, "Force generation of report without specifying task file directory. " +
        		"If the task dir is not specified, CPU and memory stats will not be included in report");
        
        CommandLineParser parser = new GnuParser();
        CommandLine cmdLine = null;
        try {
            cmdLine = parser.parse(options, args);
        } catch (ParseException e) {
            usageAndExit("Illegal argument: " + e.getMessage(), options);
        }

        String instanceIdArg = cmdLine.getOptionValue(INSTANCE_ID_OPT);

        long instanceId = -1;
        try {
            instanceId = Long.parseLong(instanceIdArg);
        } catch (NumberFormatException e) {
            usageAndExit("Invalid instanceId: " + instanceIdArg, options);
        }

        String taskDirArg = cmdLine.getOptionValue(TASK_FILES_OPT);

        if(taskDirArg == null && !cmdLine.hasOption(FORCE_OPT)){
            usageAndExit("Task file dir not specified.  " +
            		"If the task dir is not specified, CPU and memory stats will not be included in report. " +
            		"To force generation of the report without CPU & memory stats, use the -force option." + 
            		instanceIdArg, options);
        }

        Pair<Integer, Integer> nodes = null;
        if(cmdLine.hasOption(NODE_IDS_OPT)){
            String nodesArg = cmdLine.getOptionValue(NODE_IDS_OPT);
            nodes = parseNodesArg(nodesArg, options);
        }
        
        File taskDir = null;
        if(taskDirArg != null){
            taskDir = new File(taskDirArg);
        }
        PerformanceReport report = new PerformanceReport(instanceId, taskDir, nodes);
        report.generateReport();
    }
}
