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

package gov.nasa.kepler.ppa.pad;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.ppa.PadMetricReport.ReportType;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.uow.CadenceUowTask;
import gov.nasa.kepler.ppa.AbstractPpaPipelineModule;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class PadPipelineModule extends AbstractPpaPipelineModule {

    private static final Log log = LogFactory.getLog(PadPipelineModule.class);

    public static final String MODULE_NAME = "pad";

    public PadPipelineModule() {
    }

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return CadenceUowTask.class;
    }

    @Override
    protected Persistable createInputs() {
        setInputs(new PadInputs());
        return getInputs();
    }

    @Override
    protected Persistable createOutputs() {
        setOutputs(new PadOutputs());
        return getOutputs();
    }

    @Override
    public void initializeTask() {
        CadenceUowTask task = pipelineTask.uowTaskInstance();

        log.info("instance node uow = " + task);

        startCadence = task.getStartCadence();
        endCadence = task.getEndCadence();
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> requiredParameters = new ArrayList<Class<? extends Parameters>>();
        requiredParameters.add(PadModuleParameters.class);

        return requiredParameters;
    }

    @Override
    protected void retrieveInputs(Persistable inputs, TargetTable targetTable) {

        log.info("start");

        PadInputs padInputs = (PadInputs) inputs;

        TimestampSeries cadenceTimes = retrieveCadenceTimes();
        double startMjd = cadenceTimes.startMjd();
        double endMjd = cadenceTimes.endMjd();
        padInputs.setPadModuleParameters(getPadModuleParameters());
        padInputs.setCadenceTimes(cadenceTimes);
        padInputs.setSpacecraftConfigMaps(retrieveConfigMaps(startMjd, endMjd));
        padInputs.setRaDec2PixModel(retrieveRaDec2PixModel(startMjd, endMjd));
        padInputs.setMotionBlobs(retrieveAllMotionBlobs(startCadence,
            endCadence));
    }

    private PadModuleParameters getPadModuleParameters() {
        return pipelineTask.getParameters(PadModuleParameters.class);
    }

    private BlobFileSeries[] retrieveAllMotionBlobs(int startCadence,
        int endCadence) {
        BlobFileSeries[] blobSeries = new BlobFileSeries[FcConstants.MODULE_OUTPUTS];
        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                blobSeries[FcConstants.getChannelNumber(ccdModule, ccdOutput) - 1] = retrieveMotionBlobs(
                    ccdModule, ccdOutput);
            }
        }
        return blobSeries;
    }

    @Override
    protected void storeOutputs(Persistable outputs, TargetTable targetTable) {

        PadOutputs padOutputs = (PadOutputs) outputs;

        // store attitude double time series
        log.info("write all double time series to database");
        padOutputs.getAttitudeSolution()
            .writeDoubleTimeSeries(getDoubleDbTimeSeriesCrud(), startCadence,
                endCadence, pipelineTask.getId());

        // store attitude float time series
        log.info("write all float time series to file store");
        padOutputs.getAttitudeSolution()
            .writeFloatTimeSeries(FileStoreClientFactory.getInstance(),
                startCadence, endCadence, pipelineTask.getId());

        // store attitude reports
        if (padOutputs.getReport()
            .getDeltaRa() != null) {
            log.info("persist Ra report to database");
            getPpaCrud().createMetricReport(
                padOutputs.getReport()
                    .getDeltaRa()
                    .createReport(ReportType.DELTA_RA, pipelineTask,
                        targetTable, startCadence, endCadence));
        }
        if (padOutputs.getReport()
            .getDeltaDec() != null) {
            log.info("persist Dec report to database");
            getPpaCrud().createMetricReport(
                padOutputs.getReport()
                    .getDeltaDec()
                    .createReport(ReportType.DELTA_DEC, pipelineTask,
                        targetTable, startCadence, endCadence));
        }
        if (padOutputs.getReport()
            .getDeltaRoll() != null) {
            log.info("persist Roll report to database");
            getPpaCrud().createMetricReport(
                padOutputs.getReport()
                    .getDeltaRoll()
                    .createReport(ReportType.DELTA_ROLL, pipelineTask,
                        targetTable, startCadence, endCadence));
        }

        storeMissionReport(padOutputs.getReportFilename());

        generateAlerts(ReportType.DELTA_RA.toString(), padOutputs.getReport()
            .getDeltaRa()
            .getAlerts());
        generateAlerts(ReportType.DELTA_DEC.toString(), padOutputs.getReport()
            .getDeltaDec()
            .getAlerts());
        generateAlerts(ReportType.DELTA_ROLL.toString(), padOutputs.getReport()
            .getDeltaRoll()
            .getAlerts());

        updateDataAccountability();
    }
}
