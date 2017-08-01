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

package gov.nasa.kepler.ppa.pag;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.uow.CadenceUowTask;
import gov.nasa.kepler.ppa.AbstractPpaPipelineModule;
import gov.nasa.kepler.ppa.pmd.PmdReport;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * PPA:PAG pipeline module.
 * 
 * @author Bill Wohler
 */
public class PagPipelineModule extends AbstractPpaPipelineModule {

    private static final Log log = LogFactory.getLog(PagPipelineModule.class);

    public static final String MODULE_NAME = "pag";

    /**
     * Maximum number of reports in an array. Typically, the number of reports
     * in an array is bound to the number of targets for that particular
     * category. For example, for 2D black and LDE undershoot, there are about 4
     * or 5 targets for each on a module/output. This constant was chosen to be
     * generous, in case someone decides that a report is needed for every
     * target on a module/output. It is safe to say that there won't be more
     * targets on a module/output than the total number of targets (170,000).
     * This number is only used to detect an infinite loop earlier than
     * {@code Integer.MAX_VALUE} and before running out of memory.
     */
    private static final int MAX_REPORT_ARRAY_LENGTH = 170000;

    public PagPipelineModule() {
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
    public void initializeTask() {
        CadenceUowTask task = pipelineTask.uowTaskInstance();

        log.info("uow=" + task);

        startCadence = task.getStartCadence();
        endCadence = task.getEndCadence();
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> requiredParameters = new ArrayList<Class<? extends Parameters>>();
        requiredParameters.add(PagModuleParameters.class);

        return requiredParameters;
    }

    @Override
    protected Persistable createInputs() {
        setInputs(new PagInputs());
        return getInputs();
    }

    @Override
    protected void retrieveInputs(Persistable inputs, TargetTable targetTable) {
        PagInputs pagInputs = (PagInputs) inputs;

        TimestampSeries cadenceTimes = retrieveCadenceTimes();
        double startMjd = cadenceTimes.startMjd();
        double endMjd = cadenceTimes.endMjd();

        pagInputs.setPagModuleParameters(getPagModuleParameters());
        pagInputs.setSpacecraftConfigMaps(retrieveConfigMaps(startMjd, endMjd));
        pagInputs.setCadenceTimes(cadenceTimes);
        pagInputs.setInputTsData(retrieveInputTsData());
        pagInputs.setReports(retrieveReports());
    }

    private PagModuleParameters getPagModuleParameters() {
        return pipelineTask.getParameters(PagModuleParameters.class);
    }

    private List<PagInputTsData> retrieveInputTsData() {

        // Gather fsids.
        List<FsId> intFsIds = new ArrayList<FsId>();
        List<FsId> floatFsIds = new ArrayList<FsId>();
        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                intFsIds.addAll(PagInputTsData.getIntFsIds(ccdModule, ccdOutput));
                floatFsIds.addAll(PagInputTsData.getFloatFsIds(ccdModule,
                    ccdOutput));
            }
        }

        // Retrieve time series.
        Map<FsId, IntTimeSeries> intTimeSeriesByFsId = retrieveIntTimeSeries(intFsIds);
        Map<FsId, FloatTimeSeries> floatTimeSeriesByFsId = retrieveFloatTimeSeries(floatFsIds);

        // Create PagInputTsData objects.
        List<PagInputTsData> inputTsData = new ArrayList<PagInputTsData>();
        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                if (PagInputTsData.containsTimeSeries(ccdModule, ccdOutput,
                    intTimeSeriesByFsId, floatTimeSeriesByFsId)) {
                    PagInputTsData inputTsDataElement = new PagInputTsData(
                        ccdModule, ccdOutput);
                    inputTsDataElement.setTimeSeries(intTimeSeriesByFsId,
                        floatTimeSeriesByFsId);
                    inputTsData.add(inputTsDataElement);
                }
            }
        }

        return inputTsData;
    }

    private List<PagInputReport> retrieveReports() {
        List<gov.nasa.kepler.hibernate.ppa.PmdMetricReport> pmdMetricReports = getPpaCrud().retrievePmdMetricReports(
            pipelineInstance);
        addReportsToDataAccountability(pmdMetricReports);

        // Create a map to aid in the conversion of the Hibernate reports to the
        // persistable reports.
        Map<PmdMetricReportKey, gov.nasa.kepler.hibernate.ppa.PmdMetricReport> reportMap = new HashMap<PmdMetricReportKey, gov.nasa.kepler.hibernate.ppa.PmdMetricReport>(
            pmdMetricReports.size());
        for (gov.nasa.kepler.hibernate.ppa.PmdMetricReport pmdMetricReport : pmdMetricReports) {
            PmdMetricReportKey key = new PmdMetricReportKey(pmdMetricReport);

            // If a key is already in the map, it means that we have an array of
            // the particular type of report. In that case, increment the index
            // and try again.
            while (reportMap.containsKey(key)) {
                int index = key.getIndex() + 1;
                if (index >= MAX_REPORT_ARRAY_LENGTH) {
                    throw new ModuleFatalProcessingException(String.format(
                        "Too many reports in array (%d+)", index));
                }
                key = new PmdMetricReportKey(pmdMetricReport, index);
            }
            reportMap.put(key, pmdMetricReport);
        }

        // Create reports.
        List<PagInputReport> reports = new ArrayList<PagInputReport>();
        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                if (PmdReport.containsReport(reportMap, ccdModule, ccdOutput)) {
                    reports.add(new PagInputReport(reportMap, ccdModule,
                        ccdOutput));
                }
            }
        }

        return reports;
    }

    @Override
    protected Persistable createOutputs() {
        setOutputs(new PagOutputs());
        return getOutputs();
    }

    @Override
    protected void storeOutputs(Persistable outputs, TargetTable targetTable) {
        PagOutputs pagOutputs = (PagOutputs) outputs;
        storeTsData(pagOutputs.getOutputTsData());
        storeReport(pagOutputs.getReport(), targetTable);
        storeMissionReport(pagOutputs.getReportFilename());

        generateAlerts(pagOutputs.getReport()
            .alerts());

        updateDataAccountability();
    }

    private void generateAlerts(Map<List<String>, List<ModuleAlert>> alerts) {
        for (Entry<List<String>, List<ModuleAlert>> type : alerts.entrySet()) {
            generateAlerts(type.getKey()
                .toString(), type.getValue());
        }
    }

    private void storeTsData(PagOutputTsData outputTsData) {
        log.info("Preparing to write time series");
        List<FloatTimeSeries> timeSeries = outputTsData.toTimeSeries(
            startCadence, endCadence, pipelineTask.getId());

        log.info(String.format("Writing %d time series from %d to %d...",
            timeSeries.size(), startCadence, endCadence));
        FileStoreClientFactory.getInstance()
            .writeTimeSeries(timeSeries.toArray(new FloatTimeSeries[0]));
        log.info(String.format("Writing %d time series from %d to %d...done",
            timeSeries.size(), startCadence, endCadence));
    }

    private void storeReport(PagReport report, TargetTable targetTable) {
        List<gov.nasa.kepler.hibernate.ppa.PmdMetricReport> reports = report.createReports(
            pipelineTask, targetTable, startCadence, endCadence);

        log.info(String.format("Saving %d reports", reports.size()));
        getPpaCrud().createMetricReports(reports);
    }
}
