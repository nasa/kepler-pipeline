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

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import nom.tam.fits.FitsException;
import gnu.trove.TLongHashSet;
import gov.nasa.kepler.ar.archive.ArchiveMatlabProcessSource;
import gov.nasa.kepler.ar.archive.BarycentricCorrection;
import gov.nasa.kepler.ar.archive.DvaTargetSource;
import gov.nasa.kepler.ar.archive.TargetWcs;
import gov.nasa.kepler.ar.exporter.AbstractPerTargetPipelineModule;
import gov.nasa.kepler.ar.exporter.BasePerTargetExporterParameters;
import gov.nasa.kepler.ar.exporter.ExporterParameters;
import gov.nasa.kepler.ar.exporter.TargetLabelFilterParameters;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.TpsType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.uow.ObservedKeplerIdUowTask;
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * Export K2 target pixel files.
 * 
 * @author Sean McCauliff
 *
 */
public class K2ExporterPipelineModule extends AbstractPerTargetPipelineModule {

    private static final Log log = LogFactory.getLog(K2ExporterPipelineModule.class);

    /**
     * @param matlabSource this value is ignored.
     * @param tpsType this value is ignored.
     */
    @Override
    protected TLongHashSet exportFiles(final PipelineTask pipelineTask,
        final ObservedKeplerIdUowTask uow,
        final ArchiveMatlabProcessSource matlabSource,
        final TargetTable ttable, final TargetTable lcTargetTable,
        final CadenceType cadenceType,
        final int startCadence, final int endCadence,
        final TimestampSeries cadenceTimes,
        final TimestampSeries longCadenceTimes,
        final File outputDir, TpsType tpsType,
        long tpsPipelineInstanceId, final String fileTimestamp)
            throws FitsException, IOException {

        
        K2Exporter k2Exporter = new K2Exporter();

        final TargetPixelExporterParameters parameters = 
            pipelineTask.getParameters(TargetPixelExporterParameters.class);
        final ExporterParameters exporterParams = pipelineTask.getParameters(ExporterParameters.class);
        final TargetLabelFilterParameters targetLabelFilterParams = pipelineTask.getParameters(TargetLabelFilterParameters.class);
        final Date generatedAt = new Date();
        
        log.info("Pipeline module, started exporting.");
        TLongHashSet originators = k2Exporter.exportPixelsForTargets(new DefaultK2ExporterSource(getDataAnomalyOperations(), getConfigMapOps(), getTargetCrud(),
            getCompressionCrud(), getGainOps(),
            getReadNoiseOperations(), ttable, getLogCrud(),
            getCelestialObjectOperations(),
            uow.getStartKeplerId(), uow.getEndKeplerId(),
            getUnifiedObservedTargetCrud(),
            exporterParams.getK2Campaign()) {
            
            @Override
            public TimestampSeries longCadenceTimes() {
                return longCadenceTimes;
            }
            
            @Override
            public int compressionThresholdInPixels() {
                return parameters.getCompressionThresholdInPixels();
            }
            
            @Override
            public TimestampSeries cadenceTimes() {
                return cadenceTimes;
            }
            
            @Override
            public <T extends DvaTargetSource> Map<Integer, TargetWcs> wcsCoordinates(
                Collection<T> targets, Map<FsId, TimeSeries> allTimeSeries) {

            	return calculateWcsCoordinates(targets,
                        matlabSource, allTimeSeries, pipelineTask);
            }
            
            @Override
            public <T extends DvaTargetSource> Map<Integer, BarycentricCorrection> barycentricCorrection(
                Collection<T> targets, Map<FsId, TimeSeries> allTimeSeries) {

                return calculateBarycentricCorrection(targets,
                    matlabSource, allTimeSeries, pipelineTask);
            }
            
            
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
                return getModuleName();
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
            public TimestampSeries longCadenceTimestampSeries() {
                return longCadenceTimes;
            }
            
            @Override
            public MjdToCadence longCadenceMjdToCadence() {
                return getLcMjdToCadence();
            }
            
            @Override
            public int longCadenceExternalTargetTableId() {
                return lcTargetTable.getExternalId();
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
            public File exportDirectory() {
                return outputDir;
            }
            
            @Override
            public Set<String> excludeTargetsWithLabel() {
                return targetLabelFilterParams.labelsAsSet();
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
        });
        return originators;
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
    protected BasePerTargetExporterParameters baseParameters(PipelineTask task) {
        return task.getParameters(TargetPixelExporterParameters.class);
    }


    @Override
    public String getModuleName() {
        return "K2TargetPixelExporter";
    }

}
