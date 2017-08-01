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

package gov.nasa.kepler.ar.exporter.cal;

import gnu.trove.TLongHashSet;
import gnu.trove.TLongIterator;
import gov.nasa.kepler.ar.exporter.Iso8601Formatter;
import gov.nasa.kepler.common.AsciiCleanWriter;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fs.api.BlobResult;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.services.Alert;
import gov.nasa.kepler.hibernate.services.AlertLog;
import gov.nasa.kepler.hibernate.services.AlertLogCrud;
import gov.nasa.kepler.mc.dr.DrConstants;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.pi.dacct.DataAccountabilityReport;
import gov.nasa.kepler.pi.dacct.DetailedPipelineTaskRenderer;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.*;
import java.util.*;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author Sean McCauliff
 * 
 */
class ProcessingHistoryFile {

    private static final Log log = LogFactory.getLog(ProcessingHistoryFile.class);
    private final Iso8601Formatter processingHistoryDate = new Iso8601Formatter();

    private final String processingHistoryFileName;
    private final TLongHashSet historyTaskIds = new TLongHashSet();
    private final DataAccountabilityTrailCrud acctCrud;
    private final PipelineTaskCrud taskCrud;
    private final AlertLogCrud alertLogCrud;
    private final FcCrud fcCrud;

    ProcessingHistoryFile(String processingHistoryFileName,
        DataAccountabilityTrailCrud acctCrud, PipelineTaskCrud taskCrud,
        AlertLogCrud alertLogCrud,
        FcCrud fcCrud) {
        this.processingHistoryFileName = processingHistoryFileName;
        this.taskCrud = taskCrud;
        this.acctCrud = acctCrud;
        this.alertLogCrud = alertLogCrud;
        this.fcCrud = fcCrud;
    }

    synchronized void addTaskId(long originator) {
        historyTaskIds.add(originator);
    }
    
    TLongHashSet testTaskIds() {
        return historyTaskIds;
    }

    private String alerts(Collection<Long> javaUtilSetTaskIds) {
        
        List<AlertLog> sortedAlertLogs = 
            new ArrayList<AlertLog>(alertLogCrud.retrieveByPipelineTaskIds(javaUtilSetTaskIds));
        Collections.sort(sortedAlertLogs, new Comparator<AlertLog>() {
            @Override
            public int compare(AlertLog o1, AlertLog o2) {
                long diff = o1.getAlertData().getSourceTaskId() - 
                    o2.getAlertData().getSourceTaskId();
                if (diff < 0) {
                    return -1;
                } else if (diff > 0) {
                    return 1;
                }
                
                return o1.getAlertData().getTimestamp().compareTo(o2.getAlertData().getTimestamp());
            }
        });
        
        StringBuilder bldr = new StringBuilder(1024);
        for (AlertLog alertLog : sortedAlertLogs) {
            bldr.append(format(alertLog.getAlertData()));
            bldr.append('\n');
        }
        return bldr.toString();
    }
    
    private String format(Alert alert) {
        String timestamp = processingHistoryDate.format(alert.getTimestamp());
        return String.format("%s - %s - task id: %d / worker: %s - %s ",
            timestamp, alert.getSeverity(), alert.getSourceTaskId(),
            alert.getProcessHost(), alert.getMessage());
    }
    
    private String fcModelsHistory(Collection<Long> taskIds) {
        Pair<Date, Date> historyStartEnd = pipelineTaskStartEndTimes(taskIds);
        if (historyStartEnd == null) {
            return "";
        }
        
        List<History> histories = 
            fcCrud.retrieveActiveHistory(historyStartEnd.left, historyStartEnd.right);
        
        Collections.sort(histories, new Comparator<History>() {
            @Override
            public int compare(History h1, History h2) {
                int diff = Double.compare(h1.getIngestTime(), h2.getIngestTime());
                if (diff != 0) {
                    return diff;
                }
                return h1.getModelType().name().compareTo(h2.getModelType().name());
            }
            
        });
        
        StringBuilder bldr = new StringBuilder(1024);
        for (History h : histories) {
            bldr.append(format(h));
            bldr.append('\n');
        }
        return bldr.toString();
    }
    
    /**
     * 
     * @param taskIds  A non-null Collection.
     * @return  This may return null if taskIds is empty or the data was not
     * produced by any pipeline tasks.
     */
    private Pair<Date, Date> pipelineTaskStartEndTimes(Collection<Long> taskIds) {
        Date minDate = null;
        Date maxDate = null;
        
        for (long taskId : taskIds) {
            if (taskId == DrConstants.DATA_RECEIPT_ORIGIN_ID) {
                continue;
            }
            
            PipelineTask pipelineTask = taskCrud.retrieve(taskId);
            Date taskStartTime = pipelineTask.getStartProcessingTime();
            if (minDate == null) {
                minDate = taskStartTime;
            } else {
                minDate = min(minDate, taskStartTime);
            }
            
            if (maxDate == null) {
                maxDate = taskStartTime;
            } else {
                maxDate = max(maxDate, taskStartTime);
            }
        }
        
        if (minDate == null || maxDate == null) {
            return null;
        }
        return Pair.of(minDate, maxDate);
    }
    
    private Date max(Date a, Date b) {
        int diff = a.compareTo(b);
        if (diff > 0) {
            return a;
        }
        return b;
    }
    
    private Date min(Date a, Date b) {
        int diff = a.compareTo(b);
        if (diff < 0) {
            return a;
        }
        return b;
    }
    
    private String format(History fcHistory) {
        String ingestDateStr = 
            processingHistoryDate.format(ModifiedJulianDate.mjdToDate(fcHistory.getIngestTime()));
        return String.format("%s - %s - %s", ingestDateStr, 
            fcHistory.getModelType().toString(), fcHistory.getDescription());
    }
    
    synchronized void write(FileStoreClient fileStore,
        File destinationDirectory, String exportParameters) throws IOException {

        Set<Long> javaUtilSet = new HashSet<Long>();
        TLongIterator it = historyTaskIds.iterator();
        while (it.hasNext()) {
            javaUtilSet.add(it.next());
        }

        // Calculate report.
        DataAccountabilityReport report = new DataAccountabilityReport(
            javaUtilSet, acctCrud, taskCrud, new HistoryTaskRenderer());
        String reportStr = report.produceReport();

        // Export history files.

        FsId phfId = DrFsIdFactory.getFile(DispatcherType.HISTORY,
            processingHistoryFileName);

        File historyFile = new File(destinationDirectory,
            processingHistoryFileName);
        boolean writeHeader = !historyFile.exists();

        DataOutputStream dout = new DataOutputStream(new BufferedOutputStream(
            new FileOutputStream(historyFile, true)));

        if (writeHeader) {
            if (fileStore.blobExists(phfId)) {
                BlobResult phfBlob = fileStore.readBlob(phfId);
                dout.write(phfBlob.data());
            } else {
                log.warn("Processing history file \""
                    + processingHistoryFileName + "\" not found.");
            }
        }

        Writer historyWriter = null;
        try {
            historyWriter = new AsciiCleanWriter(new OutputStreamWriter(dout, "US-ASCII"));
            historyWriter.append("\n");
            historyWriter.append("Kepler SOC Data Accountability Trail\n");
            historyWriter.append(reportStr);
            historyWriter.append("Alerts generated by pipeline modules\n");
            historyWriter.append(alerts(javaUtilSet));
            historyWriter.append("Focal Plane Characterization Models");
            historyWriter.append(fcModelsHistory(javaUtilSet));
            historyWriter.append(processingHistoryDate.format(new Date()));
            historyWriter.append(exportParameters);
            historyWriter.append(" Archived at Kepler SOC.\n");
            historyWriter.flush();
        } finally {
            FileUtil.close(historyWriter);
        }
    }

    @Override
    public int hashCode() {
        return processingHistoryFileName.hashCode();
    }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof ProcessingHistoryFile)) {
            return false;
        }

        ProcessingHistoryFile other = (ProcessingHistoryFile) o;
        return processingHistoryFileName.equals(other.processingHistoryFileName);
    }

    @Override
    public String toString() {
        return processingHistoryFileName;
    }

    private class HistoryTaskRenderer extends DetailedPipelineTaskRenderer {
        @Override
        public String renderTask(PipelineTask pipelineTask) {
            String dateStr = processingHistoryDate.format(pipelineTask.getEndProcessingTime());
            return dateStr + " " + super.renderTask(pipelineTask);
        }
    }
}
