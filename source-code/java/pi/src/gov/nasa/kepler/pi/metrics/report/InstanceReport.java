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
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributeCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTaskMetrics;
import gov.nasa.kepler.pi.common.InstancesDisplayModel;
import gov.nasa.kepler.pi.common.TaskSummaryDisplayModel;
import gov.nasa.kepler.pi.common.TasksStates;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.spiffy.common.lang.StringUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;

import com.itextpdf.text.pdf.PdfPTable;

public class InstanceReport extends Report {
    private static final Log log = LogFactory.getLog(InstanceReport.class);

    public InstanceReport(PdfRenderer pdfRenderer) {
        super(pdfRenderer);
    }

    public void generateReport(PipelineInstance instance, List<PipelineInstanceNode> nodes) throws Exception{
        PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();

        String instanceName = instance.getId() + ":" + instance.getName();

        pdfRenderer.printText("Performance Report for " + instanceName, PdfRenderer.titleFont);

        pdfRenderer.println();
        pdfRenderer.println();
        pdfRenderer.println();
        
        pdfRenderer.printText("Pipeline Instance Summary", PdfRenderer.h1Font);
        
        pdfRenderer.println();

        PdfPTable timeTable = new PdfPTable(3);
        timeTable.setWidthPercentage(100);
        
        addCell(timeTable, "Start", true);
        addCell(timeTable, "End", true);
        addCell(timeTable, "Total", true);
        
        addCell(timeTable, dateToDateString(instance.getStartProcessingTime()), false);
        addCell(timeTable, dateToDateString(instance.getEndProcessingTime()), false);
        String elapsedTime = StringUtils.elapsedTime(instance.getStartProcessingTime(),
            instance.getEndProcessingTime());
        addCell(timeTable, elapsedTime, false);

        pdfRenderer.add(timeTable);
        
        pdfRenderer.println();
        
        // Instance Summary
        InstancesDisplayModel instancesDisplayModel = new InstancesDisplayModel(instance);
        printDisplayModel("", instancesDisplayModel);
        
        pdfRenderer.println();
        
        // Task Summary
        List<PipelineTask> tasks = new ArrayList<PipelineTask>();
        
        for (PipelineInstanceNode node : nodes) {
            List<PipelineTask> nodeTasks = pipelineTaskCrud.retrieveAll(node);
            tasks.addAll(nodeTasks);
        }

        PipelineTaskAttributeCrud attrCrud = new PipelineTaskAttributeCrud();
        Map<Long, PipelineTaskAttributes> taskAttrs = attrCrud.retrieveByInstanceId(instance.getId());

        TaskSummaryDisplayModel tasksDisplayModel = new TaskSummaryDisplayModel(new TasksStates(tasks, taskAttrs));
        printDisplayModel("Pipeline Task Summary", tasksDisplayModel);

        pdfRenderer.println();
        
        pdfRenderer.printText("File Sizes and Transfer Rates", PdfRenderer.h1Font);
        pdfRenderer.println();
        
        generateTransferStats(instance, nodes);
    }
    
    private String dateToDateString(java.util.Date date){
        if(date.getTime() == 0){
            return "--";
        }else{
            return date.toString();
        }
    }
    
    private void generateTransferStats(PipelineInstance instance, List<PipelineInstanceNode> nodes) throws Exception{
        PdfPTable transfersTable = new PdfPTable(4);
        
        transfersTable.setWidthPercentage(100);
        
        addCell(transfersTable, "Node", true);
        addCell(transfersTable, "Transfer Type", true);
        addCell(transfersTable, "Size", true);
        addCell(transfersTable, "Transfer Rate", true);

        for (PipelineInstanceNode node : nodes) {
            transfersForNode(transfersTable, node, "Inputs (SOC->Pleiades)",
                MatlabPipelineModule.TF_INPUTS_SIZE_CATEGORY,
                MatlabPipelineModule.SEND_INPUTS_CATEGORY);
            
            
            transfersForNode(transfersTable, node, "Outputs (Pleiades->SOC)",
                MatlabPipelineModule.TF_PFE_OUTPUTS_SIZE_CATEGORY,
                MatlabPipelineModule.RECEIVE_OUTPUTS_CATEGORY);

            
            transfersForNode(transfersTable, node, "Archive (SOC->NFS)",
                MatlabPipelineModule.TF_ARCHIVE_SIZE_CATEGORY,
                MatlabPipelineModule.COPY_TASK_FILES_CATEGORY);
        }
        pdfRenderer.add(transfersTable);
    }

    private void transfersForNode(PdfPTable transfersTable, PipelineInstanceNode node, String label, String sizeCategory, String timeCategory){
        BytesFormat bytesFormatter = new BytesFormat();
        BytesPerSecondFormat rateFormatter = new BytesPerSecondFormat();

        PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();

        DescriptiveStatistics sizeStats = new DescriptiveStatistics();
        DescriptiveStatistics timeStats = new DescriptiveStatistics();

        List<PipelineTask> tasks = pipelineTaskCrud.retrieveAll(node);
        
        for (PipelineTask task : tasks) {
            List<PipelineTaskMetrics> taskMetrics = task.getSummaryMetrics();
            
            for (PipelineTaskMetrics taskMetric : taskMetrics) {
                if(taskMetric.getCategory().equals(sizeCategory)){
                    sizeStats.addValue(taskMetric.getValue());
                } else if(taskMetric.getCategory().equals(timeCategory)){
                    timeStats.addValue(taskMetric.getValue());
                }
            }
        }

        double bytesForNode = sizeStats.getSum();
        double millisForNode = timeStats.getSum();

        double bytesPerSecondForNode = bytesForNode / (millisForNode / 1000);

        log.info("bytesForNode = " + bytesForNode);
        log.info("millisForNode = " + millisForNode);
        log.info("bytesPerSecondForNode = " + bytesPerSecondForNode);
        
        addCell(transfersTable, node.getPipelineDefinitionNode().getModuleName().getName());
        addCell(transfersTable, label);
        addCell(transfersTable, bytesFormatter.format(bytesForNode));
        addCell(transfersTable, rateFormatter.format(bytesPerSecondForNode));
    }
}
