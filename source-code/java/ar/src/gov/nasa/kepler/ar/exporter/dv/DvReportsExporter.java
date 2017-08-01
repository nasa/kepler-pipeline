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

package gov.nasa.kepler.ar.exporter.dv;

import gov.nasa.kepler.ar.exporter.FileNameFormatter;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.hibernate.mr.MrReport;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.mc.mr.GenericReportOperations;
import gov.nasa.spiffy.common.concurrent.MiniWork;
import gov.nasa.spiffy.common.concurrent.MiniWorkFactory;
import gov.nasa.spiffy.common.concurrent.MiniWorkPool;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.File;
import java.io.IOException;
import java.util.Date;
import java.util.List;
import java.util.SortedSet;
import java.util.TreeSet;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Exports all the DV results from the same pipeline instance.
 * 
 * @author Sean McCauliff
 *
 */
public class DvReportsExporter {

    private static final Log log = LogFactory.getLog(DvReportsExporter.class);
    
    private final GenericReportOperations reportOps;
    private final PipelineInstanceCrud pipelineInstanceCrud;
    private final File outputDir;
    private final FileStoreClient fsClient;
    
    public DvReportsExporter(GenericReportOperations reportOps,
        PipelineInstanceCrud pipelineInstanceCrud, 
        File outputDir, FileStoreClient fsClient) throws IOException {

        this.outputDir = outputDir;
        this.reportOps = reportOps;
        this.pipelineInstanceCrud = pipelineInstanceCrud;
        this.fsClient = fsClient;
        
        if (!outputDir.exists()) {
            FileUtil.mkdirs(outputDir);
        }
        if (!outputDir.canWrite()) {
            throw new IllegalArgumentException("Output directory \"" + 
                outputDir + "\" exists, but is not writable.");
        }
    }

    
    public void exportInstances(long pipelineInstanceId) throws InterruptedException, IOException {
        PipelineInstance pipelineInstance = pipelineInstanceCrud.retrieve(pipelineInstanceId);
        Date endProcessingTime = pipelineInstance.getStartProcessingTime();
        SortedSet<Long> idSet = new TreeSet<Long>();
        idSet.add(pipelineInstanceId);
        export(idSet, new SingleTime(endProcessingTime));
    }
    
    private void export(SortedSet<Long> pipelineInstanceIds, DvFileTimeFactory fileTimeFactory) throws InterruptedException, IOException {
        
        for (long pipelineInstanceId : pipelineInstanceIds) {
            log.info("Exporting DV reports for pipeline instance ID " + pipelineInstanceId);
            final Date fileTime = fileTimeFactory.timestampFor(pipelineInstanceId);
            List<MrReport> reports = reportOps.retrieveReports("dv", pipelineInstanceId);
            MiniWorkFactory<MrReport> workerFactory = new MiniWorkFactory<MrReport>() {

                @Override
                public MiniWork<MrReport> createMiniWork() {
                    return new ReportExporterWorker(fsClient, outputDir, reportOps, fileTime);
                }
            };
            
            MiniWorkPool<MrReport> workerPool = 
                new MiniWorkPool<MrReport>("dvreports",reports, workerFactory);
            workerPool.performAllWork();
        }
        log.info("Completed exporting DV reports.");
    }
    
    private final static class ReportExporterWorker extends MiniWork<MrReport> {

        private final Date fileTime;
        private final GenericReportOperations reportOps;
        private final FileStoreClient fsClient;
        private final File outputDir;
        private boolean disassocaited = false;
        private final FileNameFormatter fnameFormatter = new FileNameFormatter();
        
        public ReportExporterWorker(FileStoreClient fsClient, File outputDir, 
            GenericReportOperations reportOps, Date fileTime) {
            this.fsClient = fsClient;
            this.outputDir = outputDir;
            this.reportOps = reportOps;
            if (fileTime == null) {
                throw new NullPointerException("fileTime must not be null");
            }
            this.fileTime = fileTime;
        }
        
        @Override
        protected void doIt(MrReport report) throws Throwable {
            if (!disassocaited) {
                fsClient.disassociateThread();
                disassocaited = true;
            }
            int reportKeplerId = Integer.parseInt(report.getIdentifier());
            String fname = fnameFormatter.dataValidationReportName(reportKeplerId, fileTime);
            File outputFile = new File(outputDir, fname);
            reportOps.retrieveBlobResult(report, outputFile);
        }
    }

}
