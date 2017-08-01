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

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.ar.exporter.FileNameFormatter;
import gov.nasa.kepler.fs.api.StreamedBlobResult;
import gov.nasa.kepler.hibernate.mr.MrReport;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.CompletedDvPipelineInstanceSelectionParameters;
import gov.nasa.kepler.mc.CustomTargetParameters;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.mr.GenericReportOperations;
import gov.nasa.kepler.mc.uow.PlanetaryCandidatesChunkUowTask;
import gov.nasa.kepler.pi.module.ExternalProcessPipelineModule;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Pipeline to convert all the DV reports from LaTeX to PDF and copy them to a
 * specified export directory.
 * 
 * @author Forrest Girouard
 */
public class DvReportsPipelineModule extends ExternalProcessPipelineModule {

    private static final Log log = LogFactory.getLog(DvReportsPipelineModule.class);

    public static final String MODULE_NAME = "dvReports";

    private static final int TIMEOUT_SECS = 120;

    private static final Pattern SUMMARY_REPORT_NAME = Pattern.compile("(\\d{9})-(\\d{2})");

    // Variables set by pipeline infrastructure.
    private int skyGroupId;
    private int startKeplerId;
    private int endKeplerId;
    private File workingDir;

    private BlobOperations blobOperations = new BlobOperations();
    private DataAccountabilityTrailCrud daCrud = new DataAccountabilityTrailCrud();
    private CelestialObjectOperations celestialObjectOperations;
    private GenericReportOperations genericReportOperations = new GenericReportOperations();
    private PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud();

    private File dvReportsDirectory;
    private File dvReportSummariesDirectory;
    private boolean teamRemovalEnabled;
    private long pipelineInstanceId;
    private final Set<Long> producerTaskIds = new HashSet<Long>();
    private Date fileTime;

    private PipelineInstance pipelineInstance;
    private PipelineTask pipelineTask;
    
    private int failureCount = 0;

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return PlanetaryCandidatesChunkUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> requiredParameters = new ArrayList<Class<? extends Parameters>>();

        requiredParameters.add(DvReportsModuleParameters.class);
        requiredParameters.add(CompletedDvPipelineInstanceSelectionParameters.class);
        requiredParameters.add(CustomTargetParameters.class);

        return requiredParameters;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) throws PipelineException {

        this.pipelineInstance = pipelineInstance;
        this.pipelineTask = pipelineTask;
        initializeTask(pipelineInstance, pipelineTask);

        processTask();

        // Update the data accountability trail.
        daCrud.create(pipelineTask, producerTaskIds);
        
        if (this.failureCount > 0) {
            final String message = String.format("%d target" + 
                ((this.failureCount == 1) ? "" : "s") +
                " could not be exported", this.failureCount);
            throw new PipelineException(message);
        }
    }

    private void initializeTask(PipelineInstance incomingPipelineInstance,
        PipelineTask pipelineTask) {

        PlanetaryCandidatesChunkUowTask task = pipelineTask.uowTaskInstance();
        log.debug("uow=" + task);

        skyGroupId = task.getSkyGroupId();
        startKeplerId = task.getStartKeplerId();
        endKeplerId = task.getEndKeplerId();

        workingDir = allocateWorkingDir(pipelineTask);
        blobOperations.setOutputDir(workingDir);

        DvReportsModuleParameters dvReportsModuleParameters = pipelineTask.getParameters(DvReportsModuleParameters.class);
        dvReportsDirectory = new File(
            dvReportsModuleParameters.getDvReportsDirectory());
        log.info("dvReportsDirectory: " + dvReportsDirectory.getPath());
        dvReportsDirectory.mkdirs();
        dvReportSummariesDirectory = new File(
            dvReportsModuleParameters.getDvReportSummariesDirectory());
        log.info("dvReportSummariesDirectory: "
            + dvReportSummariesDirectory.getPath());
        dvReportSummariesDirectory.mkdirs();
        teamRemovalEnabled = dvReportsModuleParameters.isTeamRemovalEnabled();

        CompletedDvPipelineInstanceSelectionParameters instanceParameters = pipelineTask.getParameters(CompletedDvPipelineInstanceSelectionParameters.class);
        if (instanceParameters.getPipelineInstanceId() > 0) {
            pipelineInstanceId = instanceParameters.getPipelineInstanceId();
            pipelineInstance = pipelineInstanceCrud.retrieve(pipelineInstanceId);
        } else {
            pipelineInstance = incomingPipelineInstance;
            pipelineInstanceId = pipelineInstance.getId();
        }
        fileTime = incomingPipelineInstance.getStartProcessingTime();

        log.debug("skyGroupId: " + skyGroupId);
        log.debug("startKeplerId: " + startKeplerId);
        log.debug("endKeplerId: " + endKeplerId);
        log.debug("pipelineInstanceId: " + pipelineInstanceId);
        log.debug("workingDir: " + workingDir.getPath());
        log.debug("dvReportsDirectory: " + dvReportsDirectory.getParent());
        log.debug("fileTime: " + fileTime);
    }

    private void processTask() {

        Map<String, MrReport> mrReportByIdentifier = new HashMap<String, MrReport>();
        for (MrReport mrReport : genericReportOperations.retrieveReports("dv",
            pipelineInstanceId)) {
            mrReportByIdentifier.put(mrReport.getIdentifier(), mrReport);
        }

        Set<Integer> excludeKeplerIds = new HashSet<Integer>();
        for (CelestialObjectParameters celestialObjectParameters : getCelestialObjectOperations().retrieveCelestialObjectParameters(
            new ArrayList<Integer>(
                identifiersToKeplerIds(mrReportByIdentifier.keySet())))) {
            if (celestialObjectParameters.getSkyGroupId() != skyGroupId
                || celestialObjectParameters.getKeplerId() < startKeplerId
                || celestialObjectParameters.getKeplerId() > endKeplerId) {
                excludeKeplerIds.add(celestialObjectParameters.getKeplerId());
            }
        }

        for (String identifier : mrReportByIdentifier.keySet()) {
            try {
                MrReport mrReport = mrReportByIdentifier.get(identifier);
                Matcher matcher = SUMMARY_REPORT_NAME.matcher(identifier);
                if (matcher.matches()) {
                    int keplerId = Integer.valueOf(matcher.group(1));
                    if (!excludeKeplerIds.contains(keplerId)) {
                        int planetNumber = Integer.valueOf(matcher.group(2));
                        makeReportSummary(keplerId, planetNumber, mrReport);
                        producerTaskIds.add(mrReport.getPipelineTask()
                            .getId());
                    }
                } else {
                    int keplerId = Integer.valueOf(identifier);
                    if (!excludeKeplerIds.contains(keplerId)) {
                        makeReport(keplerId, mrReport);
                        producerTaskIds.add(mrReport.getPipelineTask()
                            .getId());
                    }
                }
            } catch (IOException ioe) {
                throw new PipelineException(String.format(
                    "error in exporting report for identifier %s", identifier),
                    ioe);
            }
        }
    }

    private Set<Integer> identifiersToKeplerIds(Set<String> identifiers) {

        Set<Integer> keplerIds = new HashSet<Integer>();
        for (String identifier : identifiers) {
            Matcher matcher = SUMMARY_REPORT_NAME.matcher(identifier);
            if (matcher.matches()) {
                int keplerId = Integer.valueOf(matcher.group(1));
                keplerIds.add(keplerId);
            } else {
                int keplerId = Integer.valueOf(identifier);
                keplerIds.add(keplerId);
            }
        }

        return keplerIds;
    }

    private void makeReportSummary(int keplerId, int planetNumber,
        MrReport mrReport) throws IOException {

        InputStream inputStream = null;
        try {
            String fname = new FileNameFormatter().dataValidationReportSummaryName(
                keplerId, planetNumber, fileTime);
            StreamedBlobResult blobResult = genericReportOperations.retrieveStreamedBlobResult(mrReport);
            inputStream = blobResult.stream();
            File dest = new File(dvReportSummariesDirectory, fname);
            FileUtils.copyInputStreamToFile(inputStream, dest);
            producerTaskIds.add(blobResult.originator());
            log.info("Extracted " + dest.getPath());
        } finally {
            FileUtil.close(inputStream);
        }
    }

    private void makeReport(Integer keplerId, MrReport mrReport)
        throws IOException {

        File execDir = new File(workingDir, mrReport.getFilename());

        if (!execDir.exists()) {
            log.info(String.format("Extracting archive %s",
                mrReport.getFilename()));
            StreamedBlobResult blobResult = genericReportOperations.retrieveStreamedBlobResult(mrReport);
            FileUtil.extractCompressedArchive(workingDir, blobResult.stream());
            producerTaskIds.add(blobResult.originator());
        }

        if (teamRemovalEnabled) {
            log.info("Removing team.");
            File teamFile = new File(execDir, "team.tex");
            teamFile.delete();
        }
        
        log.info(String.format("Running LaTeX on %s", mrReport.getFilename()));
        try {
            int status = executeExternalProcess(new File("/bin/sh"),
                newArrayList(new File(execDir, "mkreport").getPath()),
                TIMEOUT_SECS, execDir);
            if (status != 0) {
                final String message = String.format(
                    "mkreport failed on keplerId %d: status=%d", keplerId,
                    status);
                log.error(message);
                this.failureCount++;
                // No Exception: Allow the UoW to export reports for other
                // targets
            } else {
                File pdfFile = new File(execDir, mrReport.getFilename()
                    + ".pdf");
                if (!pdfFile.exists()) {
                    final String message = String.format(
                        "mkreport failed on keplerId %d: no .pdf generated",
                        keplerId);
                    log.error(message);
                    this.failureCount++;
                    // No Exception: Allow the UoW to export reports for other
                    // targets
                } else {
                    // The export PDF file was created
                    log.info("Generated " + pdfFile.getPath());
                    String fname = new FileNameFormatter().dataValidationReportName(
                        keplerId != null ? keplerId : 0, fileTime);
                    File dest = new File(dvReportsDirectory, fname);
                    FileUtil.copyFiles(pdfFile, dest);
                    log.info("Copied to " + dest.getPath());
                }
            }
        } catch (ModuleFatalProcessingException e) {
            final String message = String.format(
                "failed to execute external process mkreport on keplerId %d",
                keplerId);
            log.error(message);
            this.failureCount++;
            // Swallow the Exception: Allow the UoW to export reports for other
            // targets
        }

        log.info("Cleanup directory");
        FileUtil.removeAll(execDir);
    }

    public void setBlobOperations(BlobOperations blobOperations) {
        this.blobOperations = blobOperations;
    }

    public void setCelestialObjectOperations(
        CelestialObjectOperations celestialObjectOperations) {
        this.celestialObjectOperations = celestialObjectOperations;
    }

    private CelestialObjectOperations getCelestialObjectOperations() {
        if (celestialObjectOperations == null) {
            celestialObjectOperations = new CelestialObjectOperations(
                new ModelMetadataRetrieverPipelineInstance(pipelineInstance),
                !pipelineTask.getParameters(CustomTargetParameters.class)
                    .isProcessingEnabled());
        }

        return celestialObjectOperations;
    }

    public void setDaCrud(DataAccountabilityTrailCrud daCrud) {
        this.daCrud = daCrud;
    }

    public void setGenericReportOperations(
        GenericReportOperations genericReportOperations) {
        this.genericReportOperations = genericReportOperations;
    }

    public void setPipelineInstanceCrud(
        PipelineInstanceCrud pipelineInstanceCrud) {
        this.pipelineInstanceCrud = pipelineInstanceCrud;
    }
}
