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

package gov.nasa.kepler.ar.exporter.tpixel;

import gnu.trove.TLongHashSet;
import gov.nasa.kepler.ar.archive.*;
import gov.nasa.kepler.ar.exporter.AbstractPerTargetPipelineModule;
import gov.nasa.kepler.ar.exporter.BasePerTargetExporterParameters;
import gov.nasa.kepler.ar.exporter.ExporterParameters;
import gov.nasa.kepler.ar.exporter.TargetLabelFilterParameters;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.TpsType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.cal.CalCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tps.AbstractTpsDbResult;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.uow.ObservedKeplerIdUowTask;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.io.IOException;
import java.util.*;

import nom.tam.fits.FitsException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Executes the target pixel exporter on a single unit of work.
 * 
 * @author Sean McCauliff
 * 
 */
public class TargetPixelExporterPipelineModule extends AbstractPerTargetPipelineModule {

    @SuppressWarnings("unused")
    private static Log log = LogFactory.getLog(TargetPixelExporterPipelineModule.class);

    public static final String MODULE_NAME = "tpixel";

    private CalCrud calCrud;
    
    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> rv = new ArrayList<Class<? extends Parameters>>();
        rv.addAll(super.requiredParameters());
        rv.add(TargetPixelExporterParameters.class);
        rv.add(ExporterParameters.class);
        return rv;
    }

    @Override
    protected TLongHashSet exportFiles(final PipelineTask pipelineTask,
        final ObservedKeplerIdUowTask uow,
        final ArchiveMatlabProcessSource matlabSource,
        final TargetTable ttable, final TargetTable lcTargetTable,
        final CadenceType cadenceType, final int startCadence, final int endCadence,
        final TimestampSeries cadenceTimes,
        final TimestampSeries longCadenceTimes, final File outputDir,
        final TpsType tpsType, final long tpsPipelineInstanceId,
        final String fileTimestamp)
        throws FitsException, IOException {

        TargetPixelExporter exporter = createTargetPixelExporter();

        final TargetPixelExporterParameters parameters = 
            pipelineTask.getParameters(TargetPixelExporterParameters.class);
        final ExporterParameters exporterParams = pipelineTask.getParameters(ExporterParameters.class);
        final TargetLabelFilterParameters targetLabelFilterParams = pipelineTask.getParameters(TargetLabelFilterParameters.class);
        final Date generatedAt = new Date();
        
        TLongHashSet originators = exporter.exportPixelsForTargets(new DefaultTargetPixelExporterSource(
            getDataAnomalyOperations(), getConfigMapOps(), getTargetCrud(),
            getCompressionCrud(), getGainOps(),
            getReadNoiseOperations(), ttable, getLogCrud(),
            getCelestialObjectOperations(),
            uow.getStartKeplerId(), uow.getEndKeplerId(),
            getUnifiedObservedTargetCrud(),
            exporterParams.getK2Campaign(),
            getCalCrud()) {

            @Override
            public TimestampSeries timestampSeries() {
                return cadenceTimes;
            }

            @Override
            public int startCadence() {
                return startCadence;
            }

            @Override
            public int quarter() {
                return exporterParams.getQuarter();
            }

            @Override
            public String programName() {
                return TargetPixelExporterPipelineModule.class.getSimpleName();
            }

            @Override
            public long pipelineTaskId() {
                return pipelineTask.getId();
            }

            @Override
            public MjdToCadence mjdToCadence() {
                return getMjdToCadence(cadenceType);
            }

            @Override
            public File exportDirectory() {
                return outputDir;
            }

            @Override
            public int endCadence() {
                return endCadence;
            }

            @Override
            public int dataReleaseNumber() {
                return exporterParams.getDataReleaseNumber();
            }

            @Override
            public int ccdOutput() {
                return uow.getCcdOutput();
            }

            @Override
            public int ccdModule() {
                return uow.getCcdModule();
            }

            @Override
            public Map<Pixel, BackgroundPixelValue> background(
                Set<Pixel> pixels) {

                if (parameters.isExportBackground()) {
                    return calculateBackgroundFlux(pixels,
                        matlabSource, pipelineTask);
                } else {
                    return super.background(pixels);
                }
            }

            @Override
            public <T extends DvaTargetSource> Map<Integer, BarycentricCorrection> barycentricCorrection(
                Collection<T> targets, Map<FsId, TimeSeries> allTimeSeries) {

                return calculateBarycentricCorrection(targets,
                    matlabSource, allTimeSeries, pipelineTask);
            }

            @Override
            public int compressionThresholdInPixels() {
                return parameters.getCompressionThresholdInPixels();
            }

            @Override
            public Set<String> excludeTargetsWithLabel() {
                return targetLabelFilterParams.labelsAsSet();
            }

            @Override
            public <T extends DvaTargetSource> Map<Integer, TargetDva> dvaMotion(
                Collection<T> targets, Map<FsId, TimeSeries> allTimeSeries) {

                return calculateDvaMotion(targets,
                    matlabSource, allTimeSeries, pipelineTask);
            }

            @Override
            public <T extends DvaTargetSource> Map<Integer, TargetWcs> wcsCoordinates(
                Collection<T> targets, Map<FsId, TimeSeries> allTimeSeries) {
                return calculateWcsCoordinates(targets,
                    matlabSource, allTimeSeries, pipelineTask);
            }
            
            @Override
            public List<? extends AbstractTpsDbResult>  tpsDbResults() {
                return retrieveTpsResults(cadenceType, tpsType, tpsPipelineInstanceId, 
                    uow.getStartKeplerId(), uow.getEndKeplerId());
            }

            @Override
            public TimestampSeries longCadenceTimestampSeries() {
                return longCadenceTimes;
            }

            @Override
            public int longCadenceExternalTargetTableId() {
                return lcTargetTable.getExternalId();
            }

            @Override
            public MjdToCadence longCadenceMjdToCadence() {
                return getLcMjdToCadence();
            }
            
            @Override
            public Date generatedAt() {
                return generatedAt;
            }

            @Override
            public String fileTimestamp() {
                return fileTimestamp;
            }

            @Override
            public TimestampSeries cadenceTimes() {
                return timestampSeries();
            }

            @Override
            public TimestampSeries longCadenceTimes() {
                return longCadenceTimes;
            }

        });

        return originators;
    }


    protected CalCrud getCalCrud() {
        if (calCrud == null) {
            calCrud = new CalCrud();
        }
        return calCrud;
    }

    void setCalCrud(CalCrud calCrud) {
        this.calCrud = calCrud;
    }
    
    protected TargetPixelExporter createTargetPixelExporter() {
        return new TargetPixelExporter();
    }

    @Override
    protected BasePerTargetExporterParameters baseParameters(PipelineTask task) {
        return task.getParameters(TargetPixelExporterParameters.class);
    }
    
}
