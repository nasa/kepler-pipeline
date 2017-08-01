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

package gov.nasa.kepler.systest.validation.dv;

import static com.google.common.base.Preconditions.checkNotNull;
import gov.nasa.kepler.ar.exporter.dv.DvResultsExporter;
import gov.nasa.kepler.common.UsageException;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.dv.io.DvBinaryDiscriminationResults;
import gov.nasa.kepler.dv.io.DvBootstrapHistogram;
import gov.nasa.kepler.dv.io.DvCentroidMotionResults;
import gov.nasa.kepler.dv.io.DvCentroidResults;
import gov.nasa.kepler.dv.io.DvDifferenceImageMotionResults;
import gov.nasa.kepler.dv.io.DvDifferenceImagePixelData;
import gov.nasa.kepler.dv.io.DvDifferenceImageResults;
import gov.nasa.kepler.dv.io.DvDoubleQuantity;
import gov.nasa.kepler.dv.io.DvDoubleQuantityWithProvenance;
import gov.nasa.kepler.dv.io.DvGhostDiagnosticResults;
import gov.nasa.kepler.dv.io.DvLimbDarkeningModel;
import gov.nasa.kepler.dv.io.DvModelParameter;
import gov.nasa.kepler.dv.io.DvMqCentroidOffsets;
import gov.nasa.kepler.dv.io.DvMqImageCentroid;
import gov.nasa.kepler.dv.io.DvPixelCorrelationMotionResults;
import gov.nasa.kepler.dv.io.DvPixelCorrelationResults;
import gov.nasa.kepler.dv.io.DvPixelStatistic;
import gov.nasa.kepler.dv.io.DvPlanetCandidate;
import gov.nasa.kepler.dv.io.DvPlanetModelFit;
import gov.nasa.kepler.dv.io.DvPlanetResults;
import gov.nasa.kepler.dv.io.DvPlanetStatistic;
import gov.nasa.kepler.dv.io.DvQualityMetric;
import gov.nasa.kepler.dv.io.DvQuantity;
import gov.nasa.kepler.dv.io.DvQuantityWithProvenance;
import gov.nasa.kepler.dv.io.DvStatistic;
import gov.nasa.kepler.dv.io.DvTargetResults;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.dv.DvExternalTceModelDescription;
import gov.nasa.kepler.hibernate.dv.DvPlanetModelFit.PlanetModelFitType;
import gov.nasa.kepler.hibernate.dv.DvResultsSequence;
import gov.nasa.kepler.hibernate.dv.DvSummaryOverlapMetric;
import gov.nasa.kepler.hibernate.dv.DvSummaryQualityMetric;
import gov.nasa.kepler.hibernate.dv.DvWeakSecondary;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.mc.tps.WeakSecondary;
import gov.nasa.kepler.systest.validation.FitsValidationOptions;
import gov.nasa.kepler.systest.validation.FitsValidationOptions.Command;
import gov.nasa.kepler.systest.validation.ValidationException;
import gov.nasa.kepler.systest.validation.ValidationUtils;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.io.FileFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.XMLConstants;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;
import javax.xml.bind.ValidationEvent;
import javax.xml.bind.ValidationEventHandler;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import nom.tam.fits.FitsException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.xml.sax.SAXException;

import com.google.common.primitives.Floats;
import com.google.common.primitives.Ints;

/**
 * Validates exported DV time series, XML file, and PDF report.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class DvValidator {

    private static final Log log = LogFactory.getLog(DvValidator.class);

    private FitsValidationOptions options;
    private File fitsDirectory;
    private File xmlDirectory;
    private File tasksRootDirectory;

    public DvValidator(FitsValidationOptions options) {
        if (options == null) {
            throw new NullPointerException("options can't be null");
        }

        this.options = options;
        validateOptions();
    }

    private void validateOptions() {
        if (options.getCommand() != Command.VALIDATE_DV) {
            throw new IllegalStateException("Unexpected command "
                + options.getCommand()
                    .getName());
        }
        if (options.getDvId() == -1) {
            throw new UsageException("DV pipeline instance ID not set");
        }

        if (options.getDvFitsDirectory() == null) {
            throw new UsageException("DV FITS directory not set");
        }
        fitsDirectory = new File(options.getDvFitsDirectory());
        if (!ValidationUtils.directoryReadable(fitsDirectory,
            "DV FITS directory")) {
            throw new UsageException("Can't read DV FITS directory "
                + fitsDirectory);
        }
        if (options.getDvXmlDirectory() == null) {
            throw new UsageException("DV XML directory not set");
        }
        xmlDirectory = new File(options.getDvXmlDirectory());
        if (!ValidationUtils.directoryReadable(xmlDirectory, "DV XML directory")) {
            throw new UsageException("Can't read DV XML directory "
                + xmlDirectory);
        }

        if (options.getTasksRootDirectory() == null) {
            throw new UsageException("Tasks root directory not set");
        }
        tasksRootDirectory = new File(options.getTasksRootDirectory());
        if (!ValidationUtils.directoryReadable(tasksRootDirectory,
            "tasks root directory")) {
            throw new UsageException("Can't read tasks root directory "
                + tasksRootDirectory);
        }

        if (options.getMaxErrorsDisplayed() < 0) {
            throw new UsageException("Max errors displayed can't be negative");
        }
    }

    public void validate() throws FitsException, IOException, JAXBException,
        SAXException, ValidationException {

        boolean failed = false;

        if (!validateTimeSeries()) {
            failed = true;
        }
        if (!validateXml()) {
            failed = true;
        }

        if (failed) {
            throw new ValidationException("Task and FITS files differ; see log");
        }
    }

    private boolean validateTimeSeries() throws FitsException, IOException {

        Map<Integer, Map<FsId, SimpleFloatTimeSeries>> simpleTimeSeriesByKeplerId = new HashMap<Integer, Map<FsId, SimpleFloatTimeSeries>>();
        Map<Integer, Map<FsId, CompoundFloatTimeSeries>> compoundTimeSeriesByKeplerId = new HashMap<Integer, Map<FsId, CompoundFloatTimeSeries>>();

        DvExtractor dvExtractor = new DvExtractor(options.getDvId(),
            tasksRootDirectory);
        dvExtractor.extractTimeSeries(simpleTimeSeriesByKeplerId,
            compoundTimeSeriesByKeplerId);

        FitsDvExtractor fitsFluxExtractor = new FitsDvExtractor(fitsDirectory);

        boolean failed = false;

        for (int keplerId : simpleTimeSeriesByKeplerId.keySet()) {
            Map<FsId, SimpleFloatTimeSeries> fitsSimpleTimeSeries = new HashMap<FsId, SimpleFloatTimeSeries>();
            Map<FsId, CompoundFloatTimeSeries> fitsCompoundTimeSeries = new HashMap<FsId, CompoundFloatTimeSeries>();
            fitsFluxExtractor.extractTimeSeries(keplerId, fitsSimpleTimeSeries,
                fitsCompoundTimeSeries);
            Map<FsId, SimpleFloatTimeSeries> taskSimpleTimeSeriesByFsId = simpleTimeSeriesByKeplerId.get(keplerId);
            Map<FsId, CompoundFloatTimeSeries> taskCompoundTimeSeriesByFsId = compoundTimeSeriesByKeplerId.get(keplerId);

            for (FsId fsId : fitsSimpleTimeSeries.keySet()) {
                if (processSimpleTimeSeries(taskSimpleTimeSeriesByFsId,
                    fitsSimpleTimeSeries, keplerId, fsId)) {
                    failed = true;
                }
            }
            for (FsId fsId : fitsCompoundTimeSeries.keySet()) {
                if (processCompoundTimeSeries(taskCompoundTimeSeriesByFsId,
                    fitsCompoundTimeSeries, keplerId, fsId)) {
                    failed = true;
                }
            }
        }
        log.info(String.format("%s time series for %d targets",
            failed ? "Processed" : "Validated",
            simpleTimeSeriesByKeplerId.size()));

        return !failed;
    }

    private boolean processSimpleTimeSeries(
        Map<FsId, SimpleFloatTimeSeries> taskTimeSeriesByFsId,
        Map<FsId, SimpleFloatTimeSeries> fitsTimeSeriesByFsId, int keplerId,
        FsId fsId) {

        SimpleFloatTimeSeries taskTimeSeries = taskTimeSeriesByFsId.get(fsId);
        if (taskTimeSeries == null) {
            log.warn(String.format(
                "No simple time series with fsid %s in task files for Kepler ID %d",
                fsId, keplerId));
            return false;
        }
        SimpleFloatTimeSeries fitsTimeSeries = fitsTimeSeriesByFsId.get(fsId);
        if (fitsTimeSeries == null) {
            log.error(String.format(
                "No simple time series with fsid %s in fits files for Kepler ID %d",
                fsId, keplerId));
            return true;
        }
        if (taskTimeSeries.getValues().length != fitsTimeSeries.getValues().length) {
            log.warn(String.format("Time series with fsid %s for Kepler ID %d "
                + "has %d values in task file and %d values in FITS file",
                fsId, keplerId, taskTimeSeries.getValues().length,
                fitsTimeSeries.getValues().length));
        }

        return !diffSimpleTimeSeries(fsId, keplerId, taskTimeSeries,
            fitsTimeSeries);
    }

    private boolean processCompoundTimeSeries(
        Map<FsId, CompoundFloatTimeSeries> taskTimeSeriesByFsId,
        Map<FsId, CompoundFloatTimeSeries> fitsTimeSeriesByFsId, int keplerId,
        FsId fsId) {

        CompoundFloatTimeSeries taskTimeSeries = taskTimeSeriesByFsId.get(fsId);
        if (taskTimeSeries == null) {
            log.warn(String.format(
                "No compound time series with fsid %s in task files for Kepler ID %d",
                fsId, keplerId));
            return false;
        }
        CompoundFloatTimeSeries fitsTimeSeries = fitsTimeSeriesByFsId.get(fsId);
        if (fitsTimeSeries == null) {
            log.error(String.format(
                "No compound time series with fsid %s in fits files for Kepler ID %d",
                fsId, keplerId));
            return true;
        }
        if (taskTimeSeries.getValues().length != fitsTimeSeries.getValues().length) {
            log.warn(String.format("Time series with fsid %s for Kepler ID %d "
                + "has %d values in task file and %d values in FITS file",
                fsId, keplerId, taskTimeSeries.getValues().length,
                fitsTimeSeries.getValues().length));
        }

        return !ValidationUtils.diffCompoundTimeSeries(
            options.getMaxErrorsDisplayed(), fsId.toString(), keplerId,
            taskTimeSeries, fitsTimeSeries);
    }

    private boolean diffSimpleTimeSeries(FsId fsId, int keplerId,
        SimpleFloatTimeSeries taskTimeSeries,
        SimpleFloatTimeSeries fitsTimeSeries) {

        boolean equals = true;
        StringBuffer output = new StringBuffer();
        output.append(String.format(
            "\nTime series with fsid %s for Kepler ID %d differ", fsId,
            keplerId));
        output.append("\nIndex\tTask file (value, gap)\tFITS file (value, gap)\n");

        int errorCount = 0;
        int n = Math.min(taskTimeSeries.getValues().length,
            fitsTimeSeries.getValues().length);
        for (int i = 0; i < n; i++) {

            float valueA = taskTimeSeries.getValues()[i];
            float valueB = fitsTimeSeries.getValues()[i];
            boolean gapIndicatorA = taskTimeSeries.getGapIndicators()[i];
            boolean gapIndicatorB = fitsTimeSeries.getGapIndicators()[i];

            if (gapIndicatorA != gapIndicatorB || !gapIndicatorA
                && valueA != valueB) {

                equals = false;
                if (errorCount++ >= options.getMaxErrorsDisplayed()) {
                    continue;
                }

                output.append(i)
                    .append("\t");
                output.append(valueA)
                    .append(" ")
                    .append(gapIndicatorA)
                    .append("\t");
                output.append(valueB)
                    .append(" ")
                    .append(gapIndicatorB)
                    .append("\n");
            }
        }

        if (!equals) {
            if (errorCount >= options.getMaxErrorsDisplayed()) {
                output.append("...\n");
            }
            output.append(String.format("%d error%s in %d values (%.2f%%)\n",
                errorCount, errorCount > 1 ? "s" : "", n, (double) errorCount
                    / n * 100.0));
            log.error(output.toString());
        }

        return equals;
    }

    private boolean validateXml() throws JAXBException, SAXException {

        DvExtractor dvExtractor = new DvExtractor(options.getDvId(),
            tasksRootDirectory);

        XmlResults xmlResults = extractXml();

        boolean targetResultsFailed = false;
        Map<Integer, Pair<PipelineTask, DvTargetResults>> taskTargetResultsByKeplerId = dvExtractor.extractTargetResults();
        if (taskTargetResultsByKeplerId.keySet()
            .size() != xmlResults.getXmlTargetResultsByKeplerId()
            .keySet()
            .size()) {
            log.warn(String.format(
                "Target results has %d entries in task file "
                    + "and %d elements in XML file",
                taskTargetResultsByKeplerId.keySet()
                    .size(), xmlResults.getXmlTargetResultsByKeplerId()
                    .keySet()
                    .size()));
        }

        for (Integer keplerId : xmlResults.getXmlTargetResultsByKeplerId()
            .keySet()) {
            gov.nasa.kepler.hibernate.dv.DvTargetResults taskTargetResults = convertTargetResults(taskTargetResultsByKeplerId.get(keplerId));
            if (taskTargetResults == null) {
                log.warn(String.format("No task file for Kepler ID %d ",
                    keplerId));
            } else if (!taskTargetResults.equals(xmlResults.getXmlTargetResultsByKeplerId()
                .get(keplerId))) {
                log.error(String.format(
                    "Target results for Kepler ID %d differ", keplerId));
                gov.nasa.kepler.hibernate.dv.DvTargetResults fitsTargetResults = xmlResults.getXmlTargetResultsByKeplerId()
                    .get(keplerId);
                log.debug(String.format(
                    "taskTargetResults [%s] != fitsTargetResults [%s]",
                    taskTargetResults, fitsTargetResults));
                targetResultsFailed = true;
            }
        }

        log.info(String.format("%s XML results for %d targets",
            targetResultsFailed ? "Processed" : "Validated",
            xmlResults.getXmlTargetResultsByKeplerId()
                .keySet()
                .size()));

        boolean planetResultsFailed = false;
        Map<Pair<Integer, Integer>, Pair<PipelineTask, DvPlanetResults>> taskPlanetResultsByKeplerIdAndPlanetNumber = dvExtractor.extractPlanetResults();
        if (taskPlanetResultsByKeplerIdAndPlanetNumber.keySet()
            .size() != xmlResults.getXmlPlanetResultsByKeplerIdAndPlanetNumber()
            .keySet()
            .size()) {
            log.warn(String.format(
                "Planet results has %d entries in task file "
                    + "and %d elements in XML file",
                taskPlanetResultsByKeplerIdAndPlanetNumber.keySet()
                    .size(),
                xmlResults.getXmlPlanetResultsByKeplerIdAndPlanetNumber()
                    .keySet()
                    .size()));
        }

        for (Pair<Integer, Integer> planetId : xmlResults.getXmlPlanetResultsByKeplerIdAndPlanetNumber()
            .keySet()) {
            gov.nasa.kepler.hibernate.dv.DvPlanetResults taskPlanetResults = convertPlanetResults(taskPlanetResultsByKeplerIdAndPlanetNumber.get(planetId));
            if (taskPlanetResults == null) {
                log.warn(String.format(
                    "No task file for Kepler ID %d, planet number %d ",
                    planetId.left, planetId.right));
            } else if (!taskPlanetResults.equals(xmlResults.getXmlPlanetResultsByKeplerIdAndPlanetNumber()
                .get(planetId))) {
                log.error(String.format(
                    "Planet results for Kepler ID %d, planet number %d differ",
                    planetId.left, planetId.right));
                gov.nasa.kepler.hibernate.dv.DvPlanetResults fitsPlanetResults = xmlResults.getXmlPlanetResultsByKeplerIdAndPlanetNumber()
                    .get(planetId);
                log.debug(String.format(
                    "taskPlanetResults [%s] != fitsPlanetResults [%s]",
                    taskPlanetResults, fitsPlanetResults));
                planetResultsFailed = true;
            }
        }

        log.info(String.format("%s XML results for %d planets",
            planetResultsFailed ? "Processed" : "Validated",
            xmlResults.getXmlPlanetResultsByKeplerIdAndPlanetNumber()
                .keySet()
                .size()));

        boolean limbDarkeningModelsFailed = false;
        Map<Pair<Integer, Integer>, Pair<PipelineTask, DvLimbDarkeningModel>> taskLimbDarkeningModelByKeplerIdAndTargetTableId = dvExtractor.extractLimbDarkeningModels();
        if (taskLimbDarkeningModelByKeplerIdAndTargetTableId.keySet()
            .size() != xmlResults.getXmlLimbDarkeningModelByKeplerIdAndTargetTableId()
            .keySet()
            .size()) {
            log.warn(String.format(
                "Limb darkening models has %d entries in task file "
                    + "and %d elements in XML file",
                taskLimbDarkeningModelByKeplerIdAndTargetTableId.keySet()
                    .size(),
                xmlResults.getXmlLimbDarkeningModelByKeplerIdAndTargetTableId()
                    .keySet()
                    .size()));
        }

        for (Pair<Integer, Integer> modelId : xmlResults.getXmlLimbDarkeningModelByKeplerIdAndTargetTableId()
            .keySet()) {
            gov.nasa.kepler.hibernate.dv.DvLimbDarkeningModel limbDarkeningModel = convertLimbDarkeningModel(taskLimbDarkeningModelByKeplerIdAndTargetTableId.get(modelId));
            if (limbDarkeningModel == null) {
                log.warn(String.format(
                    "No task file for Kepler ID %d, target table id %d ",
                    modelId.left, modelId.right));
            } else if (!limbDarkeningModel.equals(xmlResults.getXmlLimbDarkeningModelByKeplerIdAndTargetTableId()
                .get(modelId))) {
                log.error(String.format(
                    "Planet results for Kepler ID %d, target table id %d differ",
                    modelId.left, modelId.right));
                limbDarkeningModelsFailed = true;
            }
        }

        log.info(String.format("%s XML results for %d limb darkening models",
            limbDarkeningModelsFailed ? "Processed" : "Validated",
            xmlResults.getXmlLimbDarkeningModelByKeplerIdAndTargetTableId()
                .keySet()
                .size()));

        boolean modelDescriptionsFailed = false;
        gov.nasa.kepler.hibernate.dv.DvExternalTceModelDescription xmlExternalTceModelDescription = xmlResults.getExternalTceModelDescription();
        List<String> extractExternalTceModelDescriptions = dvExtractor.extractExternalTceModelDescriptions();
        for (String modelDescription : extractExternalTceModelDescriptions) {
            if (!xmlExternalTceModelDescription.getModelDescription()
                .equals(modelDescription)) {
                log.error(String.format(
                    "External TCE model descriptions differ, task was \"%s\""
                        + " but XML was \"%s\"", modelDescription,
                    xmlExternalTceModelDescription));
                modelDescriptionsFailed = true;
            }
        }

        log.info(String.format(
            "%s XML results for %d external TCE model description",
            modelDescriptionsFailed ? "Processed" : "Validated",
            extractExternalTceModelDescriptions.size()));

        boolean transitNameModelDescriptionsFailed = false;
        gov.nasa.kepler.hibernate.dv.DvTransitModelDescriptions xmlTransitNameModelDescriptions = xmlResults.getTransitModelDescriptions();
        List<String> extractTransitNameModelDescriptions = dvExtractor.extractTransitNameModelDescription();
        for (String modelDescription : extractTransitNameModelDescriptions) {
            if (!xmlTransitNameModelDescriptions.getNameModelDescription()
                .equals(modelDescription)) {
                log.error(String.format(
                    "Transit name model descriptions differ, task was \"%s\""
                        + " but XML was \"%s\"", modelDescription,
                    xmlTransitNameModelDescriptions));
                transitNameModelDescriptionsFailed = true;
            }
        }

        log.info(String.format(
            "%s XML results for %d transit name model description",
            transitNameModelDescriptionsFailed ? "Processed" : "Validated",
            extractTransitNameModelDescriptions.size()));

        boolean transitParameterModelDescriptionsFailed = false;
        gov.nasa.kepler.hibernate.dv.DvTransitModelDescriptions xmlTransitParameterModelDescriptions = xmlResults.getTransitModelDescriptions();
        List<String> extractTransitParameterModelDescriptions = dvExtractor.extractTransitParameterModelDescription();
        for (String modelDescription : extractTransitParameterModelDescriptions) {
            if (!xmlTransitParameterModelDescriptions.getParameterModelDescription()
                .equals(modelDescription)) {
                log.error(String.format(
                    "Transit parameter model descriptions differ, task was \"%s\""
                        + " but XML was \"%s\"", modelDescription,
                    xmlTransitParameterModelDescriptions));
                transitParameterModelDescriptionsFailed = true;
            }
        }

        log.info(String.format(
            "%s XML results for %d transit parameter model description",
            transitParameterModelDescriptionsFailed ? "Processed" : "Validated",
            extractTransitParameterModelDescriptions.size()));

        return !(targetResultsFailed || planetResultsFailed
            || limbDarkeningModelsFailed || modelDescriptionsFailed
            || transitNameModelDescriptionsFailed || transitParameterModelDescriptionsFailed);
    }

    private gov.nasa.kepler.hibernate.dv.DvTargetResults convertTargetResults(
        Pair<PipelineTask, DvTargetResults> pipelineTaskAndTargetResults) {

        if (pipelineTaskAndTargetResults == null) {
            return null;
        }

        PipelineTask pipelineTask = pipelineTaskAndTargetResults.left;
        DvTargetResults dvTargetResults = pipelineTaskAndTargetResults.right;
        CadenceRangeParameters cadenceRangeParameters = pipelineTask.getParameters(CadenceRangeParameters.class);

        gov.nasa.kepler.hibernate.dv.DvTargetResults targetResults = new gov.nasa.kepler.hibernate.dv.DvTargetResults.Builder(
            getFluxType(pipelineTask),
            cadenceRangeParameters.getStartCadence(),
            cadenceRangeParameters.getEndCadence(),
            dvTargetResults.getKeplerId(), pipelineTask).planetCandidateCount(
            dvTargetResults.getPlanetResults()
                .size())
            .quartersObserved(dvTargetResults.getQuartersObserved())
            .effectiveTemp(
                convertDvQuantityWithProvenance(dvTargetResults.getEffectiveTemp()))
            .log10Metallicity(
                convertDvQuantityWithProvenance(dvTargetResults.getLog10Metallicity()))
            .log10SurfaceGravity(
                convertDvQuantityWithProvenance(dvTargetResults.getLog10SurfaceGravity()))
            .radius(
                convertDvQuantityWithProvenance(dvTargetResults.getRadius()))
            .decDegrees(
                convertDvDoubleQuantityWithProvenance(dvTargetResults.getDecDegrees()))
            .keplerMag(
                convertDvQuantityWithProvenance(dvTargetResults.getKeplerMag()))
            .raHours(
                convertDvDoubleQuantityWithProvenance(dvTargetResults.getRaHours()))
            .koiId(dvTargetResults.getKoiId())
            .keplerName(dvTargetResults.getKeplerName())
            .matchedKoiIds(Arrays.asList(dvTargetResults.getMatchedKoiIds()))
            .unmatchedKoiIds(
                Arrays.asList(dvTargetResults.getUnmatchedKoiIds()))
            .build();

        return targetResults;
    }

    private gov.nasa.kepler.hibernate.dv.DvQuantityWithProvenance convertDvQuantityWithProvenance(
        DvQuantityWithProvenance dvQuantityWithProvenance) {

        return new gov.nasa.kepler.hibernate.dv.DvQuantityWithProvenance(
            dvQuantityWithProvenance.getValue(),
            dvQuantityWithProvenance.getUncertainty(),
            dvQuantityWithProvenance.getProvenance());
    }

    private gov.nasa.kepler.hibernate.dv.DvDoubleQuantityWithProvenance convertDvDoubleQuantityWithProvenance(
        DvDoubleQuantityWithProvenance dvDoubleQuantityWithProvenance) {

        return new gov.nasa.kepler.hibernate.dv.DvDoubleQuantityWithProvenance(
            dvDoubleQuantityWithProvenance.getValue(),
            dvDoubleQuantityWithProvenance.getUncertainty(),
            dvDoubleQuantityWithProvenance.getProvenance());
    }

    private gov.nasa.kepler.hibernate.dv.DvPlanetResults convertPlanetResults(
        Pair<PipelineTask, DvPlanetResults> pipelineTaskAndPlanetResults) {

        if (pipelineTaskAndPlanetResults == null) {
            return null;
        }

        PipelineTask pipelineTask = pipelineTaskAndPlanetResults.left;
        DvPlanetResults dvPlanetResults = pipelineTaskAndPlanetResults.right;
        CadenceRangeParameters cadenceRangeParameters = pipelineTask.getParameters(CadenceRangeParameters.class);

        gov.nasa.kepler.hibernate.dv.DvPlanetResults planetResults = new gov.nasa.kepler.hibernate.dv.DvPlanetResults.Builder(
            cadenceRangeParameters.getStartCadence(),
            cadenceRangeParameters.getEndCadence(),
            dvPlanetResults.getKeplerId(), dvPlanetResults.getPlanetNumber(),
            pipelineTask).allTransitsFit(
            convertPlanetModelFit(PlanetModelFitType.ALL,
                dvPlanetResults.getAllTransitsFit(), pipelineTask))
            .binaryDiscriminationResults(
                convertBinaryDiscriminationResults(dvPlanetResults.getBinaryDiscriminationResults()))
            .centroidResults(
                convertCentroidResults(dvPlanetResults.getCentroidResults()))
            .detrendFilterLength(dvPlanetResults.getDetrendFilterLength())
            .differenceImageResults(
                convertDifferenceImageResults(dvPlanetResults.getDifferenceImageResults()))
            .evenTransitsFit(
                convertPlanetModelFit(PlanetModelFitType.EVEN,
                    dvPlanetResults.getEvenTransitsFit(), pipelineTask))
            .ghostDiagnosticResults(
                convertGhostDiagnosticResults(dvPlanetResults.getGhostDiagnosticResults()))
            .fluxType(FluxType.SAP)
            .keplerName(dvPlanetResults.getKeplerName())
            .koiCorrelation(dvPlanetResults.getKoiCorrelation())
            .koiId(dvPlanetResults.getKoiId())
            .oddTransitsFit(
                convertPlanetModelFit(PlanetModelFitType.ODD,
                    dvPlanetResults.getOddTransitsFit(), pipelineTask))
            .pixelCorrelationResults(
                convertPixelCorrelationResults(dvPlanetResults.getPixelCorrelationResults()))
            .planetCandidate(
                convertPlanetCandidate(dvPlanetResults.getPlanetCandidate(),
                    pipelineTask))
            .reducedParameterFits(
                convertReducedParameterFits(
                    dvPlanetResults.getReducedParameterFits(), pipelineTask))
            .imageArtifactResults(
                convertImageArtifactResults(dvPlanetResults.getImageArtifactResults()))
            .secondaryEventResults(
                convertSecondaryEventResults(dvPlanetResults.getSecondaryEventResults()))
            .trapezoidalFit(
                convertPlanetModelFit(PlanetModelFitType.TRAPEZOIDAL,
                    dvPlanetResults.getTrapezoidalFit(), pipelineTask))
            .build();

        return planetResults;
    }

    private gov.nasa.kepler.hibernate.dv.DvPlanetModelFit convertPlanetModelFit(
        PlanetModelFitType type, DvPlanetModelFit planetModelFit,
        PipelineTask pipelineTask) {

        gov.nasa.kepler.hibernate.dv.DvPlanetModelFit convertedPlanetModelFit = new gov.nasa.kepler.hibernate.dv.DvPlanetModelFit.Builder(
            planetModelFit.getKeplerId(), planetModelFit.getPlanetNumber(),
            pipelineTask).fullConvergence(planetModelFit.isFullConvergence())
            .limbDarkeningModelName(planetModelFit.getLimbDarkeningModelName())
            .modelChiSquare(planetModelFit.getModelChiSquare())
            .modelDegreesOfFreedom(planetModelFit.getModelDegreesOfFreedom())
            .modelFitSnr(planetModelFit.getModelFitSnr())
            .modelParameterCovariance(
                convertFloatArray(planetModelFit.getModelParameterCovariance()))
            .modelParameters(
                convertModelParameters(planetModelFit.getModelParameters()))
            .transitModelName(planetModelFit.getTransitModelName())
            .type(type)
            .build();
        return convertedPlanetModelFit;
    }

    private List<gov.nasa.kepler.hibernate.dv.DvModelParameter> convertModelParameters(
        List<DvModelParameter> modelParameters) {

        List<gov.nasa.kepler.hibernate.dv.DvModelParameter> convertedModelParameters = new ArrayList<gov.nasa.kepler.hibernate.dv.DvModelParameter>(
            modelParameters.size());

        for (DvModelParameter modelParameter : modelParameters) {
            convertedModelParameters.add(new gov.nasa.kepler.hibernate.dv.DvModelParameter(
                modelParameter.getName(), modelParameter.getValue(),
                modelParameter.getUncertainty(), modelParameter.isFitted()));
        }

        return convertedModelParameters;
    }

    private gov.nasa.kepler.hibernate.dv.DvBinaryDiscriminationResults convertBinaryDiscriminationResults(
        DvBinaryDiscriminationResults binaryDiscriminationResults) {

        gov.nasa.kepler.hibernate.dv.DvBinaryDiscriminationResults convertedBinaryDiscriminationResults = new gov.nasa.kepler.hibernate.dv.DvBinaryDiscriminationResults(
            convertPlanetStatistic(binaryDiscriminationResults.getShorterPeriodComparisonStatistic()),
            convertPlanetStatistic(binaryDiscriminationResults.getLongerPeriodComparisonStatistic()),
            convertStatistic(binaryDiscriminationResults.getOddEvenTransitEpochComparisonStatistic()),
            convertStatistic(binaryDiscriminationResults.getOddEvenTransitDepthComparisonStatistic()),
            convertStatistic(binaryDiscriminationResults.getSingleTransitDepthComparisonStatistic()),
            convertStatistic(binaryDiscriminationResults.getSingleTransitDurationComparisonStatistic()),
            convertStatistic(binaryDiscriminationResults.getSingleTransitEpochComparisonStatistic()));
        return convertedBinaryDiscriminationResults;
    }

    private gov.nasa.kepler.hibernate.dv.DvPlanetStatistic convertPlanetStatistic(
        DvPlanetStatistic planetStatistic) {

        gov.nasa.kepler.hibernate.dv.DvPlanetStatistic convertedPlanetStatistic = new gov.nasa.kepler.hibernate.dv.DvPlanetStatistic(
            planetStatistic.getPlanetNumber(), planetStatistic.getValue(),
            planetStatistic.getSignificance());

        return convertedPlanetStatistic;
    }

    private gov.nasa.kepler.hibernate.dv.DvStatistic convertStatistic(
        DvStatistic statistic) {

        gov.nasa.kepler.hibernate.dv.DvStatistic convertedStatistic = new gov.nasa.kepler.hibernate.dv.DvStatistic(
            statistic.getValue(), statistic.getSignificance());

        return convertedStatistic;
    }

    private gov.nasa.kepler.hibernate.dv.DvCentroidResults convertCentroidResults(
        DvCentroidResults centroidResults) {

        gov.nasa.kepler.hibernate.dv.DvCentroidResults convertedCentroidResults = new gov.nasa.kepler.hibernate.dv.DvCentroidResults(
            convertCentroidMotionResults(centroidResults.getFluxWeightedMotionResults()),
            convertCentroidMotionResults(centroidResults.getPrfMotionResults()),
            convertDifferenceImageMotionResults(centroidResults.getDifferenceImageMotionResults()),
            convertPixelCorrelationMotionResults(centroidResults.getPixelCorrelationMotionResults()));

        return convertedCentroidResults;
    }

    private gov.nasa.kepler.hibernate.dv.DvCentroidMotionResults convertCentroidMotionResults(
        DvCentroidMotionResults centroidMotionResults) {

        gov.nasa.kepler.hibernate.dv.DvCentroidMotionResults convertedCentroidMotionResults = new gov.nasa.kepler.hibernate.dv.DvCentroidMotionResults(
            convertDoubleQuantity(centroidMotionResults.getSourceRaHours()),
            convertDoubleQuantity(centroidMotionResults.getSourceDecDegrees()),
            convertDoubleQuantity(centroidMotionResults.getOutOfTransitCentroidRaHours()),
            convertDoubleQuantity(centroidMotionResults.getOutOfTransitCentroidDecDegrees()),
            convertQuantity(centroidMotionResults.getSourceRaOffset()),
            convertQuantity(centroidMotionResults.getSourceDecOffset()),
            convertQuantity(centroidMotionResults.getSourceOffsetArcSec()),
            convertQuantity(centroidMotionResults.getPeakRaOffset()),
            convertQuantity(centroidMotionResults.getPeakDecOffset()),
            convertQuantity(centroidMotionResults.getPeakOffsetArcSec()),
            convertStatistic(centroidMotionResults.getMotionDetectionStatistic()));

        return convertedCentroidMotionResults;
    }

    private gov.nasa.kepler.hibernate.dv.DvDifferenceImageMotionResults convertDifferenceImageMotionResults(
        DvDifferenceImageMotionResults motionResults) {

        gov.nasa.kepler.hibernate.dv.DvDifferenceImageMotionResults convertedMotionResults = new gov.nasa.kepler.hibernate.dv.DvDifferenceImageMotionResults(
            convertMqCentroidOffsets(motionResults.getMqControlCentroidOffsets()),
            convertMqCentroidOffsets(motionResults.getMqKicCentroidOffsets()),
            convertMqImageCentroid(motionResults.getMqControlImageCentroid()),
            convertMqImageCentroid(motionResults.getMqDifferenceImageCentroid()),
            convertSummaryQualityMetric(motionResults.getSummaryQualityMetric()),
            convertSummaryOverlapMetric(motionResults.getSummaryOverlapMetric()));

        return convertedMotionResults;
    }

    private gov.nasa.kepler.hibernate.dv.DvGhostDiagnosticResults convertGhostDiagnosticResults(
        DvGhostDiagnosticResults ghostDiagnosticResults) {

        gov.nasa.kepler.hibernate.dv.DvGhostDiagnosticResults convertedGhostDiagnosticResults = new gov.nasa.kepler.hibernate.dv.DvGhostDiagnosticResults(
            convertStatistic(ghostDiagnosticResults.getCoreApertureCorrelationStatistic()),
            convertStatistic(ghostDiagnosticResults.getHaloApertureCorrelationStatistic()));

        return convertedGhostDiagnosticResults;
    }

    private gov.nasa.kepler.hibernate.dv.DvPixelCorrelationMotionResults convertPixelCorrelationMotionResults(
        DvPixelCorrelationMotionResults motionResults) {

        gov.nasa.kepler.hibernate.dv.DvPixelCorrelationMotionResults convertedMotionResults = new gov.nasa.kepler.hibernate.dv.DvPixelCorrelationMotionResults(
            convertMqCentroidOffsets(motionResults.getMqControlCentroidOffsets()),
            convertMqCentroidOffsets(motionResults.getMqKicCentroidOffsets()),
            convertMqImageCentroid(motionResults.getMqControlImageCentroid()),
            convertMqImageCentroid(motionResults.getMqCorrelationImageCentroid()));

        return convertedMotionResults;
    }

    private gov.nasa.kepler.hibernate.dv.DvMqCentroidOffsets convertMqCentroidOffsets(
        DvMqCentroidOffsets mqCentroidOffsets) {

        gov.nasa.kepler.hibernate.dv.DvMqCentroidOffsets convertedMqCentroidOffsets = new gov.nasa.kepler.hibernate.dv.DvMqCentroidOffsets(
            convertQuantity(mqCentroidOffsets.getMeanDecOffset()),
            convertQuantity(mqCentroidOffsets.getMeanRaOffset()),
            convertQuantity(mqCentroidOffsets.getMeanSkyOffset()),
            convertQuantity(mqCentroidOffsets.getSingleFitDecOffset()),
            convertQuantity(mqCentroidOffsets.getSingleFitRaOffset()),
            convertQuantity(mqCentroidOffsets.getSingleFitSkyOffset()));

        return convertedMqCentroidOffsets;
    }

    private gov.nasa.kepler.hibernate.dv.DvMqImageCentroid convertMqImageCentroid(
        DvMqImageCentroid mqImageCentroid) {

        gov.nasa.kepler.hibernate.dv.DvMqImageCentroid convertedMqImageCentroid = new gov.nasa.kepler.hibernate.dv.DvMqImageCentroid(
            convertDoubleQuantity(mqImageCentroid.getDecDegrees()),
            convertDoubleQuantity(mqImageCentroid.getRaHours()));

        return convertedMqImageCentroid;
    }

    private DvSummaryQualityMetric convertSummaryQualityMetric(
        gov.nasa.kepler.dv.io.DvSummaryQualityMetric summaryQualityMetric) {

        return new DvSummaryQualityMetric(
            summaryQualityMetric.getFractionOfGoodMetrics(),
            summaryQualityMetric.getNumberOfAttempts(),
            summaryQualityMetric.getNumberOfGoodMetrics(),
            summaryQualityMetric.getNumberOfMetrics(),
            summaryQualityMetric.getQualityThreshold());
    }

    private DvSummaryOverlapMetric convertSummaryOverlapMetric(
        gov.nasa.kepler.dv.io.DvSummaryOverlapMetric summaryOverlapMetric) {

        return new DvSummaryOverlapMetric(summaryOverlapMetric.getImageCount(),
            summaryOverlapMetric.getImageCountNoOverlap(),
            summaryOverlapMetric.getImageCountFractionNoOverlap());
    }

    private gov.nasa.kepler.hibernate.dv.DvDoubleQuantity convertDoubleQuantity(
        DvDoubleQuantity doubleQuantity) {

        gov.nasa.kepler.hibernate.dv.DvDoubleQuantity convertedDoubleQuantity = new gov.nasa.kepler.hibernate.dv.DvDoubleQuantity(
            doubleQuantity.getValue(), doubleQuantity.getUncertainty());

        return convertedDoubleQuantity;
    }

    private gov.nasa.kepler.hibernate.dv.DvQuantity convertQuantity(
        DvQuantity quantity) {

        gov.nasa.kepler.hibernate.dv.DvQuantity convertedQuantity = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            quantity.getValue(), quantity.getUncertainty());

        return convertedQuantity;
    }

    private List<gov.nasa.kepler.hibernate.dv.DvDifferenceImageResults> convertDifferenceImageResults(
        List<DvDifferenceImageResults> differenceImageResultsList) {

        List<gov.nasa.kepler.hibernate.dv.DvDifferenceImageResults> convertedDifferenceImageResultsList = new ArrayList<gov.nasa.kepler.hibernate.dv.DvDifferenceImageResults>(
            differenceImageResultsList.size());
        for (DvDifferenceImageResults differenceImageResults : differenceImageResultsList) {
            convertedDifferenceImageResultsList.add(new gov.nasa.kepler.hibernate.dv.DvDifferenceImageResults.Builder(
                differenceImageResults.getTargetTableId()).ccdModule(
                differenceImageResults.getCcdModule())
                .ccdOutput(differenceImageResults.getCcdOutput())
                .startCadence(differenceImageResults.getStartCadence())
                .endCadence(differenceImageResults.getEndCadence())
                .quarter(differenceImageResults.getQuarter())
                .controlCentroidOffsets(
                    createCentroidOffsets(differenceImageResults.getControlCentroidOffsets()))
                .controlImageCentroid(
                    createImageCentroid(differenceImageResults.getControlImageCentroid()))
                .differenceImageCentroid(
                    createImageCentroid(differenceImageResults.getDifferenceImageCentroid()))
                .kicCentroidOffsets(
                    createCentroidOffsets(differenceImageResults.getKicCentroidOffsets()))
                .kicReferenceCentroid(
                    createImageCentroid(differenceImageResults.getKicReferenceCentroid()))
                .numberOfTransits(differenceImageResults.getNumberOfTransits())
                .numberOfCadencesInTransit(
                    differenceImageResults.getNumberOfCadencesInTransit())
                .numberOfCadenceGapsInTransit(
                    differenceImageResults.getNumberOfCadenceGapsInTransit())
                .numberOfCadencesOutOfTransit(
                    differenceImageResults.getNumberOfCadencesOutOfTransit())
                .numberOfCadenceGapsOutOfTransit(
                    differenceImageResults.getNumberOfCadenceGapsOutOfTransit())
                .overlappedTransits(
                    differenceImageResults.isOverlappedTransits())
                .differenceImagePixelData(
                    convertDifferenceImagePixelData(differenceImageResults.getDifferenceImagePixelData()))
                .qualityMetric(
                    convertQualityMetric(differenceImageResults.getQualityMetric()))
                .build());
        }

        return convertedDifferenceImageResultsList;
    }

    private gov.nasa.kepler.hibernate.dv.DvCentroidOffsets createCentroidOffsets(
        gov.nasa.kepler.dv.io.DvCentroidOffsets srcCentroidOffsets) {

        gov.nasa.kepler.hibernate.dv.DvQuantity columnOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            srcCentroidOffsets.getColumnOffset()
                .getValue(), srcCentroidOffsets.getColumnOffset()
                .getUncertainty());
        gov.nasa.kepler.hibernate.dv.DvQuantity decOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            srcCentroidOffsets.getDecOffset()
                .getValue(), srcCentroidOffsets.getDecOffset()
                .getUncertainty());
        gov.nasa.kepler.hibernate.dv.DvQuantity focalPlaneOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            srcCentroidOffsets.getFocalPlaneOffset()
                .getValue(), srcCentroidOffsets.getFocalPlaneOffset()
                .getUncertainty());
        gov.nasa.kepler.hibernate.dv.DvQuantity raOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            srcCentroidOffsets.getRaOffset()
                .getValue(), srcCentroidOffsets.getRaOffset()
                .getUncertainty());
        gov.nasa.kepler.hibernate.dv.DvQuantity rowOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            srcCentroidOffsets.getRowOffset()
                .getValue(), srcCentroidOffsets.getRowOffset()
                .getUncertainty());
        gov.nasa.kepler.hibernate.dv.DvQuantity skyOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            srcCentroidOffsets.getSkyOffset()
                .getValue(), srcCentroidOffsets.getSkyOffset()
                .getUncertainty());
        gov.nasa.kepler.hibernate.dv.DvCentroidOffsets centroidOffsets = new gov.nasa.kepler.hibernate.dv.DvCentroidOffsets(
            columnOffset, decOffset, focalPlaneOffset, raOffset, rowOffset,
            skyOffset);

        return centroidOffsets;
    }

    private gov.nasa.kepler.hibernate.dv.DvImageCentroid createImageCentroid(
        gov.nasa.kepler.dv.io.DvImageCentroid srcImageCentroid) {

        gov.nasa.kepler.hibernate.dv.DvQuantity column = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            srcImageCentroid.getColumn()
                .getValue(), srcImageCentroid.getColumn()
                .getUncertainty());
        gov.nasa.kepler.hibernate.dv.DvDoubleQuantity decDegrees = new gov.nasa.kepler.hibernate.dv.DvDoubleQuantity(
            srcImageCentroid.getDecDegrees()
                .getValue(), srcImageCentroid.getDecDegrees()
                .getUncertainty());
        gov.nasa.kepler.hibernate.dv.DvDoubleQuantity raHours = new gov.nasa.kepler.hibernate.dv.DvDoubleQuantity(
            srcImageCentroid.getRaHours()
                .getValue(), srcImageCentroid.getRaHours()
                .getUncertainty());
        gov.nasa.kepler.hibernate.dv.DvQuantity row = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            srcImageCentroid.getRow()
                .getValue(), srcImageCentroid.getRow()
                .getUncertainty());
        gov.nasa.kepler.hibernate.dv.DvImageCentroid imageCentroid = new gov.nasa.kepler.hibernate.dv.DvImageCentroid(
            column, decDegrees, raHours, row);

        return imageCentroid;
    }

    private List<gov.nasa.kepler.hibernate.dv.DvDifferenceImagePixelData> convertDifferenceImagePixelData(
        List<DvDifferenceImagePixelData> differenceImagePixelDataList) {

        List<gov.nasa.kepler.hibernate.dv.DvDifferenceImagePixelData> convertedDifferenceImagePixelDataList = new ArrayList<gov.nasa.kepler.hibernate.dv.DvDifferenceImagePixelData>(
            differenceImagePixelDataList.size());
        for (DvDifferenceImagePixelData differenceImagePixelData : differenceImagePixelDataList) {
            convertedDifferenceImagePixelDataList.add(new gov.nasa.kepler.hibernate.dv.DvDifferenceImagePixelData(
                differenceImagePixelData.getCcdRow(),
                differenceImagePixelData.getCcdColumn(),
                convertQuantity(differenceImagePixelData.getMeanFluxInTransit()),
                convertQuantity(differenceImagePixelData.getMeanFluxOutOfTransit()),
                convertQuantity(differenceImagePixelData.getMeanFluxDifference()),
                convertQuantity(differenceImagePixelData.getMeanFluxForTargetTable())));
        }

        return convertedDifferenceImagePixelDataList;
    }

    private gov.nasa.kepler.hibernate.dv.DvQualityMetric convertQualityMetric(
        DvQualityMetric qualityMetric) {

        return new gov.nasa.kepler.hibernate.dv.DvQualityMetric(
            qualityMetric.isAttempted(), qualityMetric.isValid(),
            qualityMetric.getValue());
    }

    private List<gov.nasa.kepler.hibernate.dv.DvPixelCorrelationResults> convertPixelCorrelationResults(
        List<DvPixelCorrelationResults> pixelCorrelationResultsList) {

        List<gov.nasa.kepler.hibernate.dv.DvPixelCorrelationResults> convertedPixelCorrelationResultsList = new ArrayList<gov.nasa.kepler.hibernate.dv.DvPixelCorrelationResults>(
            pixelCorrelationResultsList.size());
        for (DvPixelCorrelationResults pixelCorrelationResults : pixelCorrelationResultsList) {
            convertedPixelCorrelationResultsList.add(new gov.nasa.kepler.hibernate.dv.DvPixelCorrelationResults.Builder(
                pixelCorrelationResults.getTargetTableId()).ccdModule(
                pixelCorrelationResults.getCcdModule())
                .ccdOutput(pixelCorrelationResults.getCcdOutput())
                .endCadence(pixelCorrelationResults.getEndCadence())
                .quarter(pixelCorrelationResults.getQuarter())
                .startCadence(pixelCorrelationResults.getStartCadence())
                .controlCentroidOffsets(
                    createCentroidOffsets(pixelCorrelationResults.getControlCentroidOffsets()))
                .controlImageCentroid(
                    createImageCentroid(pixelCorrelationResults.getControlImageCentroid()))
                .correlationImageCentroid(
                    createImageCentroid(pixelCorrelationResults.getCorrelationImageCentroid()))
                .kicCentroidOffsets(
                    createCentroidOffsets(pixelCorrelationResults.getKicCentroidOffsets()))
                .kicReferenceCentroid(
                    createImageCentroid(pixelCorrelationResults.getKicReferenceCentroid()))
                .pixelCorrelationStatistics(
                    convertPixelCorrelationStatistics(pixelCorrelationResults.getPixelCorrelationStatistics()))
                .build());
        }

        return convertedPixelCorrelationResultsList;
    }

    private List<gov.nasa.kepler.hibernate.dv.DvPixelStatistic> convertPixelCorrelationStatistics(
        List<DvPixelStatistic> pixelCorrelationStatistics) {

        List<gov.nasa.kepler.hibernate.dv.DvPixelStatistic> convertedPixelCorrelationStatistics = new ArrayList<gov.nasa.kepler.hibernate.dv.DvPixelStatistic>(
            pixelCorrelationStatistics.size());
        for (DvPixelStatistic pixelCorrelationStatistic : pixelCorrelationStatistics) {
            convertedPixelCorrelationStatistics.add(new gov.nasa.kepler.hibernate.dv.DvPixelStatistic(
                pixelCorrelationStatistic.getCcdRow(),
                pixelCorrelationStatistic.getCcdColumn(),
                pixelCorrelationStatistic.getValue(),
                pixelCorrelationStatistic.getSignificance()));
        }

        return convertedPixelCorrelationStatistics;
    }

    private gov.nasa.kepler.hibernate.dv.DvPlanetCandidate convertPlanetCandidate(
        DvPlanetCandidate planetCandidate, PipelineTask pipelineTask) {

        checkNotNull(planetCandidate, "planetCandidate can't be null");

        gov.nasa.kepler.hibernate.dv.DvPlanetCandidate convertedPlanetCandidate = new gov.nasa.kepler.hibernate.dv.DvPlanetCandidate.Builder(
            planetCandidate.getKeplerId(), pipelineTask).bootstrapHistogram(
            convertBootstrapHistogram(planetCandidate.getBootstrapHistogram()))
            .bootstrapMesMean(planetCandidate.getBoostrapMesMean())
            .bootstrapMesStd(planetCandidate.getBootstrapMesStd())
            .bootstrapThresholdForDesiredPfa(
                planetCandidate.getBootstrapThresholdForDesiredPfa())
            .chiSquare1(planetCandidate.getChiSquare1())
            .chiSquare2(planetCandidate.getChiSquare2())
            .chiSquareDof1(planetCandidate.getChiSquareDof1())
            .chiSquareDof2(planetCandidate.getChiSquareDof2())
            .chiSquareGof(planetCandidate.getChiSquareGof())
            .chiSquareGofDof(planetCandidate.getChiSquareGofDof())
            .epochMjd(planetCandidate.getEpochMjd())
            .expectedTransitCount(planetCandidate.getExpectedTransitCount())
            .maxSesInMes(planetCandidate.getMaxSesInMes())
            .maxMultipleEventSigma(planetCandidate.getMaxMultipleEventSigma())
            .maxSingleEventSigma(planetCandidate.getMaxSingleEventSigma())
            .modelChiSquare2(planetCandidate.getModelChiSquare2())
            .modelChiSquareDof2(planetCandidate.getModelChiSquareDof2())
            .modelChiSquareGof(planetCandidate.getModelChiSquareGof())
            .modelChiSquareGofDof(planetCandidate.getModelChiSquareGofDof())
            .observedTransitCount(planetCandidate.getObservedTransitCount())
            .orbitalPeriod(planetCandidate.getOrbitalPeriod())
            .planetNumber(planetCandidate.getPlanetNumber())
            .robustStatistic(planetCandidate.getRobustStatistic())
            .significance(planetCandidate.getSignificance())
            .statisticRatioBelowThreshold(
                planetCandidate.isStatisticRatioBelowThreshold())
            .suspectedEclipsingBinary(
                planetCandidate.isSuspectedEclipsingBinary())
            .thresholdForDesiredPfa(planetCandidate.getThresholdForDesiredPfa())
            .trialTransitPulseDuration(
                planetCandidate.getTrialTransitPulseDuration())
            .weakSecondary(
                convertWeakSecondary(planetCandidate.getWeakSecondary()))
            .build();

        return convertedPlanetCandidate;
    }

    private DvWeakSecondary convertWeakSecondary(WeakSecondary weakSecondary) {

        return new DvWeakSecondary(weakSecondary.maxMesPhaseInDays(),
            weakSecondary.maxMes(), weakSecondary.minMesPhaseInDays(),
            weakSecondary.minMes(), weakSecondary.mesMad(),
            weakSecondary.depthPpm(), weakSecondary.depthUncert(),
            weakSecondary.medianMes(), weakSecondary.nValidPhases(),
            weakSecondary.robustStatistic());
    }

    private gov.nasa.kepler.hibernate.dv.DvBootstrapHistogram convertBootstrapHistogram(
        DvBootstrapHistogram bootstrapHistogram) {

        gov.nasa.kepler.hibernate.dv.DvBootstrapHistogram convertedBootstrapHistogram = new gov.nasa.kepler.hibernate.dv.DvBootstrapHistogram(
            convertFloatArray(bootstrapHistogram.getStatistics()),
            convertFloatArray(bootstrapHistogram.getProbabilities()),
            bootstrapHistogram.getFinalSkipCount());

        return convertedBootstrapHistogram;
    }

    private List<Float> convertFloatArray(float[] floats) {

        List<Float> convertedStatistics = new ArrayList<Float>(floats.length);

        for (float value : floats) {
            convertedStatistics.add(value);
        }

        return convertedStatistics;
    }

    private List<gov.nasa.kepler.hibernate.dv.DvPlanetModelFit> convertReducedParameterFits(
        List<DvPlanetModelFit> reducedParameterFits, PipelineTask pipelineTask) {

        List<gov.nasa.kepler.hibernate.dv.DvPlanetModelFit> convertedReducedParameterFits = new ArrayList<gov.nasa.kepler.hibernate.dv.DvPlanetModelFit>(
            reducedParameterFits.size());

        for (DvPlanetModelFit planetModelFit : reducedParameterFits) {
            convertedReducedParameterFits.add(convertPlanetModelFit(
                PlanetModelFitType.REDUCED_PARAMETER, planetModelFit,
                pipelineTask));
        }

        return convertedReducedParameterFits;
    }

    private gov.nasa.kepler.hibernate.dv.DvLimbDarkeningModel convertLimbDarkeningModel(
        Pair<PipelineTask, DvLimbDarkeningModel> pair) {

        PipelineTask pipelineTask = pair.left;
        DvLimbDarkeningModel model = pair.right;

        FluxType fluxType = getFluxType(pipelineTask);

        return new gov.nasa.kepler.hibernate.dv.DvLimbDarkeningModel.Builder(
            model.getTargetTableId(), fluxType, model.getKeplerId(),
            pipelineTask).ccdModule(model.getCcdModule())
            .ccdOutput(model.getCcdOutput())
            .startCadence(model.getStartCadence())
            .endCadence(model.getEndCadence())
            .quarter(model.getQuarter())
            .modelName(model.getModelName())
            .coefficient1(model.getCoefficient1())
            .coefficient2(model.getCoefficient2())
            .coefficient3(model.getCoefficient3())
            .coefficient4(model.getCoefficient4())
            .build();
    }

    private gov.nasa.kepler.hibernate.dv.DvImageArtifactResults convertImageArtifactResults(
        gov.nasa.kepler.dv.io.DvImageArtifactResults srcImageArtifactResults) {

        return new gov.nasa.kepler.hibernate.dv.DvImageArtifactResults(
            convertRollingBandContaminationHistogram(srcImageArtifactResults.getRollingBandContaminationHistogram()));
    }

    /** 
     * Factory method to return a new Hibernate Rolling Band Contamination Histogram
     * from a corresponding DV object.
     */
    private gov.nasa.kepler.hibernate.dv.DvRollingBandContaminationHistogram convertRollingBandContaminationHistogram(
        gov.nasa.kepler.dv.io.DvRollingBandContaminationHistogram srcRollingBandContaminationHistogram) {

        return new gov.nasa.kepler.hibernate.dv.DvRollingBandContaminationHistogram(
            srcRollingBandContaminationHistogram.getTestPulseDurationLc(),
            Floats.asList(srcRollingBandContaminationHistogram.getSeverityLevels()),
            Ints.asList(srcRollingBandContaminationHistogram.getTransitCounts()),
            Floats.asList(srcRollingBandContaminationHistogram.getTransitFractions()));
    }

    private gov.nasa.kepler.hibernate.dv.DvSecondaryEventResults convertSecondaryEventResults(
        gov.nasa.kepler.dv.io.DvSecondaryEventResults secondaryEventResults) {

        return new gov.nasa.kepler.hibernate.dv.DvSecondaryEventResults(
            convertPlanetParameters(secondaryEventResults.getPlanetParameters()),
            convertComparisonTests(secondaryEventResults.getComparisonTests()));
    }

    private gov.nasa.kepler.hibernate.dv.DvPlanetParameters convertPlanetParameters(
        gov.nasa.kepler.dv.io.DvPlanetParameters planetParameters) {

        return new gov.nasa.kepler.hibernate.dv.DvPlanetParameters(
            convertQuantity(planetParameters.getGeometricAlbedo()),
            convertQuantity(planetParameters.getPlanetEffectiveTemp()));
    }

    private gov.nasa.kepler.hibernate.dv.DvComparisonTests convertComparisonTests(
        gov.nasa.kepler.dv.io.DvComparisonTests comparisonTests) {

        return new gov.nasa.kepler.hibernate.dv.DvComparisonTests(
            convertStatistic(comparisonTests.getAlbedoComparisonStatistic()),
            convertStatistic(comparisonTests.getTempComparisonStatistic()));
    }

    private FluxType getFluxType(PipelineTask pipelineTask) {

        FluxTypeParameters fluxTypeParameters = pipelineTask.getParameters(FluxTypeParameters.class);

        return FluxTypeParameters.FluxType.valueOf(fluxTypeParameters.getFluxType());
    }

    private XmlResults extractXml() throws JAXBException, SAXException,
        javax.xml.bind.ValidationException {

        File[] files = xmlDirectory.listFiles(new XmlFilter());
        if (files.length != 1) {
            throw new IllegalStateException(xmlDirectory.getPath()
                + ": expected a single XML file, but found " + files.length);
        }

        final StringBuilder unmarshallerErrors = new StringBuilder();
        Unmarshaller unmarshaller = JAXBContext.newInstance(
            DvResultsSequence.class)
            .createUnmarshaller();
        Schema dvXmlSchema = SchemaFactory.newInstance(
            XMLConstants.W3C_XML_SCHEMA_NS_URI)
            .newSchema(
                DvValidator.class.getResource(DvResultsExporter.DV_ICD_XSD));
        unmarshaller.setSchema(dvXmlSchema);
        unmarshaller.setEventHandler(new ValidationEventHandler() {
            @Override
            public boolean handleEvent(ValidationEvent event) {
                unmarshallerErrors.append(event)
                    .append('\n');
                return true;
            }
        });

        DvResultsSequence dvResultsSequence;
        try {
            dvResultsSequence = (DvResultsSequence) unmarshaller.unmarshal(files[0]);
        } catch (javax.xml.bind.ValidationException e) {
            log.error(unmarshallerErrors);
            throw e;
        }

        XmlResults xmlResults = new XmlResults();

        for (gov.nasa.kepler.hibernate.dv.DvTargetResults targetResults : dvResultsSequence.getTargetResults()) {
            xmlResults.getXmlTargetResultsByKeplerId()
                .put(targetResults.getKeplerId(), targetResults);
        }

        for (gov.nasa.kepler.hibernate.dv.DvPlanetResults planetResults : dvResultsSequence.getPlanetResults()) {
            xmlResults.getXmlPlanetResultsByKeplerIdAndPlanetNumber()
                .put(
                    Pair.of(planetResults.getKeplerId(),
                        planetResults.getPlanetNumber()), planetResults);
        }

        for (gov.nasa.kepler.hibernate.dv.DvLimbDarkeningModel limbDarkeningModel : dvResultsSequence.getLimbDarkeningModels()) {
            xmlResults.getXmlLimbDarkeningModelByKeplerIdAndTargetTableId()
                .put(
                    Pair.of(limbDarkeningModel.getKeplerId(),
                        limbDarkeningModel.getTargetTableId()),
                    limbDarkeningModel);
        }

        xmlResults.setExternalTceModelDescription(dvResultsSequence.getExternalTceModelDescription());
        xmlResults.setTransitModelDescriptions(dvResultsSequence.getTransitModelDescriptions());

        return xmlResults;
    }

    private static class XmlFilter implements FileFilter {
        @Override
        public boolean accept(File path) {
            if (path.getName()
                .endsWith(".xml")) {
                return true;
            }
            return false;
        }
    }

    private static class XmlResults {
        private Map<Integer, gov.nasa.kepler.hibernate.dv.DvTargetResults> xmlTargetResultsByKeplerId = new HashMap<Integer, gov.nasa.kepler.hibernate.dv.DvTargetResults>();
        private Map<Pair<Integer, Integer>, gov.nasa.kepler.hibernate.dv.DvPlanetResults> xmlPlanetResultsByKeplerIdAndPlanetNumber = new HashMap<Pair<Integer, Integer>, gov.nasa.kepler.hibernate.dv.DvPlanetResults>();
        private Map<Pair<Integer, Integer>, gov.nasa.kepler.hibernate.dv.DvLimbDarkeningModel> xmlLimbDarkeningModelByKeplerIdAndTargetTableId = new HashMap<Pair<Integer, Integer>, gov.nasa.kepler.hibernate.dv.DvLimbDarkeningModel>();
        private gov.nasa.kepler.hibernate.dv.DvExternalTceModelDescription externalTceModelDescription = new gov.nasa.kepler.hibernate.dv.DvExternalTceModelDescription();
        private gov.nasa.kepler.hibernate.dv.DvTransitModelDescriptions transitModelDescriptions = new gov.nasa.kepler.hibernate.dv.DvTransitModelDescriptions();

        public DvExternalTceModelDescription getExternalTceModelDescription() {
            return externalTceModelDescription;
        }

        public void setExternalTceModelDescription(
            DvExternalTceModelDescription externalTceModelDescription) {
            this.externalTceModelDescription = externalTceModelDescription;
        }

        public gov.nasa.kepler.hibernate.dv.DvTransitModelDescriptions getTransitModelDescriptions() {
            return transitModelDescriptions;
        }

        public void setTransitModelDescriptions(
            gov.nasa.kepler.hibernate.dv.DvTransitModelDescriptions transitModelDescriptions) {
            this.transitModelDescriptions = transitModelDescriptions;
        }

        public Map<Integer, gov.nasa.kepler.hibernate.dv.DvTargetResults> getXmlTargetResultsByKeplerId() {
            return xmlTargetResultsByKeplerId;
        }

        public Map<Pair<Integer, Integer>, gov.nasa.kepler.hibernate.dv.DvPlanetResults> getXmlPlanetResultsByKeplerIdAndPlanetNumber() {
            return xmlPlanetResultsByKeplerIdAndPlanetNumber;
        }

        public Map<Pair<Integer, Integer>, gov.nasa.kepler.hibernate.dv.DvLimbDarkeningModel> getXmlLimbDarkeningModelByKeplerIdAndTargetTableId() {
            return xmlLimbDarkeningModelByKeplerIdAndTargetTableId;
        }
    }
}
