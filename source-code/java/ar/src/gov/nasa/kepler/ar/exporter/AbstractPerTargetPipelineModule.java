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

package gov.nasa.kepler.ar.exporter;

import gnu.trove.TLongHashSet;
import gnu.trove.TLongIterator;
import gov.nasa.kepler.ar.archive.*;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.TpsType;
import gov.nasa.kepler.common.pi.TpsTypeParameters;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.UnifiedObservedTargetCrud;
import gov.nasa.kepler.hibernate.tps.AbstractTpsDbResult;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.uow.ObservedKeplerIdUowTask;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.*;

import nom.tam.fits.FitsException;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.FlushMode;

import com.google.common.collect.ImmutableList;

/**
 * A base class for per target exporters.
 * 
 * @author Sean McCauliff
 * 
 */
public abstract class AbstractPerTargetPipelineModule extends
    MatlabPipelineModule {

    private static final Log log = LogFactory.getLog(AbstractPerTargetPipelineModule.class);

    private TargetCrud targetCrud;
    private MjdToCadence mjdToCadence;
    private MjdToCadence lcMjdToCadence;
    private LogCrud logCrud;
    private CelestialObjectOperations celestialObjectOperations;
    private DataAnomalyOperations dataAnomalyOperations;
    private ConfigMapOperations configMapOps;
    private CompressionCrud compressionCrud;
    private GainOperations gainOps;
    private ReadNoiseOperations readNoiseOps;
    private DataAccountabilityTrailCrud daTrailCrud;
    private RaDec2PixOperations raDec2PixOps;
    private FrontEndPipelineMetadata frontEndPipelineMetadata;
    private TpsCrud tpsCrud;
    private PipelineInstanceCrud pipelineInstanceCrud;

    private PipelineInstance frontEndPipelineInstance;

    private boolean dataStoreReadOnly = false;
    private UnifiedObservedTargetCrud unifiedTargetCrud;
    
    private RollingBandUtils rollingBandUtils;
    
    private ArchiveMatlabProcess archive;
    
    protected AbstractPerTargetPipelineModule() {
    }
    /**
     * If you wanted to unfinal this then you need to change this base class.
     */
    @Override
    public final Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return ObservedKeplerIdUowTask.class;
    }
    
    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        return new ImmutableList.Builder<Class<? extends Parameters>>()
        .add(TpsTypeParameters.class)
        .add(ExporterParameters.class)
        .add(TargetLabelFilterParameters.class)
        .build();
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        final PipelineTask pipelineTask) throws PipelineException {
        
        DatabaseServiceFactory.getInstance().getSession().setFlushMode(FlushMode.COMMIT);
        final ObservedKeplerIdUowTask uow = pipelineTask.uowTaskInstance();

        log.info(getModuleName() + " exporter pipeline module unit of work.");
        log.info(uow.toString());
        
        final ExporterParameters exporterParams = pipelineTask.getParameters(ExporterParameters.class);
        final BasePerTargetExporterParameters baseParams = baseParameters(pipelineTask);

        archive = new ArchiveMatlabProcess(exporterParams.isIgnoreZeroCrossingsForReferenceCadence());
        
        ExporterPipelineUtils utils = createExporterPipelineUtils();
        final File outputDir = 
            utils.createOutputDirectory(new File(exporterParams.getNfsExportDirectory()));

        log.info("Getting target table with database id " + uow.getTargetTableDbId() + ".");
        final TargetTable ttable = utils.targetTableForTargetTableId(uow.getTargetTableDbId());
        
        log.info("Processing target table " + ttable.getExternalId() + " " + ttable.getType());

        final long tpsPipelineInstanceId = baseParams.getTpsPipelineInstanceId();
        final TpsType tpsType = pipelineTask.getParameters(TpsTypeParameters.class).toTpsTypeEnumValue();

        Pair<Integer, Integer> cadenceInterval = utils.calculateStartEndCadences(
            exporterParams.getStartCadence(), exporterParams.getEndCadence(),
            ttable, getLogCrud());
        final CadenceType cadenceType = ttable.getType().toCadenceType();
        final TargetTable lcTargetTable = (cadenceType == CadenceType.LONG) ? 
            ttable : getTargetCrud().retrieveLongCadenceTargetTable(ttable).get(0);
        
        final int startCadence = cadenceInterval.left;
        final int endCadence = cadenceInterval.right;

        if (exporterParams.getFrontEndPipelineInstance() 
            == ExporterParameters.AUTOMATIC_FRONT_END_PIPELINE_INSTANCE) {
            frontEndPipelineInstance = getFrontEndPipelineMetadata().getPipelineInstance(
                cadenceType, startCadence, endCadence);
        } else {
            frontEndPipelineInstance = getPipelineInstanceCrud().retrieve(exporterParams.getFrontEndPipelineInstance());
        }

        log.info("Exporting for " + cadenceType + " [" + startCadence + "," + endCadence + "]");

        log.info("Getting cadence times.");
        final TimestampSeries cadenceTimes = getMjdToCadence(cadenceType).cadenceTimes(
            startCadence, endCadence);
        final TimestampSeries longCadenceTimes = (cadenceType == CadenceType.LONG) ? cadenceTimes
            : longCadenceTimes(startCadence, endCadence);

        String defaultFileTimestamp = utils.defaultFileTimestamp(cadenceTimes);
        String fileTimestamp = exporterParams.selectTimestamp(uow.getCcdModule(), defaultFileTimestamp);
        
        final TLongHashSet backgroundOriginators = new TLongHashSet();
        final ArchiveMatlabProcessSource archiveMatlabProcessSource = new ArchiveMatlabProcessSource() {

            @Override
            public int startCadence() {
                return startCadence;
            }

            @Override
            public int endCadence() {
                return endCadence;
            }

            @Override
            public ConfigMapOperations configMapOps() {
                return getConfigMapOps();
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
            public CadenceType cadenceType() {
                return cadenceType;
            }

            @Override
            public TimestampSeries cadenceTimes() {
                return cadenceTimes;
            }

            @Override
            public BlobOperations blobOps() {
                return getBlobOperations(pipelineTask);
            }

            @Override
            public void addOriginator(long pipelineTaskId) {
                backgroundOriginators.add(pipelineTaskId);
            }

            @Override
            public LogCrud logCrud() {
                return getLogCrud();
            }

            @Override
            public RaDec2PixOperations raDec2PixOps() {
                return getRaDec2PixOps();
            }

            @Override
            public TimestampSeries longCadenceTimes() {
                return longCadenceTimes;
            }
        };

        TLongHashSet originators;
        try {
            originators = exportFiles(pipelineTask, uow,
                archiveMatlabProcessSource, ttable, lcTargetTable, 
                cadenceType, startCadence,
                endCadence, cadenceTimes, longCadenceTimes, outputDir,
                tpsType, tpsPipelineInstanceId, fileTimestamp);
        } catch (FitsException e) {
            throw new PipelineException(e);
        } catch (IOException e) {
            throw new PipelineException(e);
        }

        originators.addAll(backgroundOriginators.toArray());

        Set<Long> javaOriginatorTaskIds = new HashSet<Long>(
            originators.size() << 1);
        originators.addAll(backgroundOriginators.toArray());
        TLongIterator lit = originators.iterator();
        while (lit.hasNext()) {
            javaOriginatorTaskIds.add(lit.next());
        }

        log.info("Originators list "
            + StringUtils.join(javaOriginatorTaskIds.iterator(), ','));

        if (!dataStoreReadOnly) {
            getDaTrailCrud().create(pipelineTask, javaOriginatorTaskIds);
        }
    }

    protected abstract TLongHashSet exportFiles(PipelineTask pipelineTask,
        ObservedKeplerIdUowTask uow, ArchiveMatlabProcessSource matlabSource,
        TargetTable ttable, TargetTable lcTargetTable, 
        CadenceType cadenceType, int startCadence,
        int endCadence, TimestampSeries cadenceTimes,
        TimestampSeries longCadenceTimes,
        File outputDir, TpsType tpsType, long tpsPipelineInstanceId,
        String fileTimestamp)
        throws FitsException, IOException;
    
    protected abstract BasePerTargetExporterParameters baseParameters(PipelineTask task);

    private  TimestampSeries longCadenceTimes(int shortCadenceStart,
        int shortCadenceEnd) {
        Pair<Integer, Integer> lcTimes = getLogCrud().shortCadenceToLongCadence(
            shortCadenceStart, shortCadenceEnd);
        return getLcMjdToCadence().cadenceTimes(lcTimes.left, lcTimes.right);
    }

    protected final Map<Pixel, BackgroundPixelValue> calculateBackgroundFlux(
        final Set<Pixel> pixels, ArchiveMatlabProcessSource source,
        PipelineTask task) {

        ArchiveOutputs archiveOutputs = archive.calculateBackground(source,
            executor(task), pixels);
        return archiveOutputs.backgroundToMap();
    }

    protected final <T extends DvaTargetSource> Map<Integer, TargetWcs> calculateWcsCoordinates(
        Collection<T> targets, ArchiveMatlabProcessSource source,
        Map<FsId, TimeSeries> allTimeSeries, PipelineTask task) {

        ArchiveOutputs archiveOutputs = archive.calculateWcs(source,
            executor(task), targets, allTimeSeries);
        return archiveOutputs.targetsWcs();
    }

    protected final <T extends DvaTargetSource> Map<Integer, BarycentricCorrection> calculateBarycentricCorrection(
        Collection<T> customTargets, ArchiveMatlabProcessSource source,
        Map<FsId, TimeSeries> allTimeSeries, PipelineTask task) {

        ArchiveOutputs archiveOutputs = archive.calculateBarycentricCorrections(
            source, executor(task), customTargets, allTimeSeries);
        return archiveOutputs.barycentricCorrectionToMap();
    }

    protected final <T extends DvaTargetSource> Map<Integer, TargetDva> calculateDvaMotion(
        Collection<T> targets, ArchiveMatlabProcessSource source,
        Map<FsId, TimeSeries> allTimeSeries, PipelineTask task) {

        ArchiveOutputs archiveOutputs = archive.calculateDva(source,
            executor(task), targets, allTimeSeries);
        return archiveOutputs.targetsDva();
    }

    protected PipelineProcessExecutor<ArchiveInputs, ArchiveOutputs> executor(
        final PipelineTask pipelineTask) {
        return new PipelineProcessExecutor<ArchiveInputs, ArchiveOutputs>() {

            @Override
            public void exec(ArchiveOutputs outputs, ArchiveInputs inputs) {
                executeAlgorithm(pipelineTask, inputs, outputs);
            }

        };
    }

    protected final List<? extends AbstractTpsDbResult> retrieveTpsResults(CadenceType cadenceType, TpsType tpsType, long tpsPipelineInstanceId, int startKeplerId, int endKeplerId) {
        if (cadenceType == CadenceType.SHORT) {
            return Collections.emptyList();
        }
        
        switch (tpsType) {
            case TPS_FULL:
                return getTpsCrud().retrieveTpsResultByPipelineInstanceId(startKeplerId, endKeplerId, tpsPipelineInstanceId);
            case TPS_LITE:
                return getTpsCrud().retrieveTpsLiteResultByPipelineInstanceId(startKeplerId, endKeplerId, tpsPipelineInstanceId);
            default:
                throw new IllegalStateException("Bad tps type \"" + tpsType + "\".");
        }
    }
    
    protected TpsCrud getTpsCrud() {
        if (tpsCrud == null) {
            tpsCrud = new TpsCrud();
        }
        return tpsCrud;
    }
    
    public void setTpsCrud(TpsCrud tpsCrud) {
        this.tpsCrud = tpsCrud;
    }
    
    protected DataAccountabilityTrailCrud getDaTrailCrud() {
        if (daTrailCrud == null) {
            daTrailCrud = new DataAccountabilityTrailCrud();
        }
        return daTrailCrud;
    }

    public void setDaTrailCrud(DataAccountabilityTrailCrud daTrailCrud) {
        this.daTrailCrud = daTrailCrud;
    }

    protected GainOperations getGainOps() {
        if (gainOps == null) {
            gainOps = new GainOperations();
        }
        return gainOps;
    }

    public void setGainOperations(GainOperations gainOps) {
        this.gainOps = gainOps;
    }

    protected ReadNoiseOperations getReadNoiseOperations() {
        if (readNoiseOps == null) {
            readNoiseOps = new ReadNoiseOperations();
        }
        return readNoiseOps;
    }

    public void setReadNoiseOperations(ReadNoiseOperations readNoiseOps) {
        this.readNoiseOps = readNoiseOps;
    }

    protected CompressionCrud getCompressionCrud() {
        if (compressionCrud == null) {
            compressionCrud = new CompressionCrud();
        }
        return compressionCrud;
    }

    public void setCompressionCrud(CompressionCrud compressionCrud) {
        this.compressionCrud = compressionCrud;
    }

    protected ConfigMapOperations getConfigMapOps() {
        if (configMapOps == null) {
            configMapOps = new ConfigMapOperations();
        }
        return configMapOps;
    }

    public void setConfigMapOps(ConfigMapOperations configMapOps) {
        this.configMapOps = configMapOps;
    }

    protected DataAnomalyOperations getDataAnomalyOperations() {
        if (dataAnomalyOperations == null) {
            dataAnomalyOperations = new DataAnomalyOperations(new ModelMetadataRetrieverPipelineInstance(frontEndPipelineInstance));
        }
        return dataAnomalyOperations;
    }

    public void setDataAnomalyOperations(DataAnomalyOperations dataAnomalyOperations) {
        this.dataAnomalyOperations = dataAnomalyOperations;
    }

    protected MjdToCadence getMjdToCadence(CadenceType cadenceType) {
        if (mjdToCadence == null) {
            mjdToCadence = new MjdToCadence(cadenceType, new ModelMetadataRetrieverPipelineInstance(frontEndPipelineInstance));
        }
        return mjdToCadence;
    }

    protected MjdToCadence getLcMjdToCadence() {
        if (lcMjdToCadence == null) {
            lcMjdToCadence = new MjdToCadence(CadenceType.LONG, new ModelMetadataRetrieverPipelineInstance(frontEndPipelineInstance));
        }
        return lcMjdToCadence;
    }

    public void setMjdToCadence(MjdToCadence mjdToCadence) {
        this.mjdToCadence = mjdToCadence;
    }

    protected LogCrud getLogCrud() {
        if (logCrud == null) {
            logCrud = new LogCrud();
        }
        return logCrud;
    }

    public void setLogCrud(LogCrud logCrud) {
        this.logCrud = logCrud;
    }

    protected CelestialObjectOperations getCelestialObjectOperations() {
        if (celestialObjectOperations == null) {
            celestialObjectOperations = new CelestialObjectOperations(
                new ModelMetadataRetrieverPipelineInstance(
                    frontEndPipelineInstance), false);
        }
        return celestialObjectOperations;
    }

    public void setCelestialObjectOperations(
        CelestialObjectOperations celestialObjectOperations) {
        this.celestialObjectOperations = celestialObjectOperations;
    }

    protected TargetCrud getTargetCrud() {
        if (targetCrud == null) {
            targetCrud = new TargetCrud();
        }
        return targetCrud;
    }

    public void setTargetCrud(TargetCrud targetCrud) {
        this.targetCrud = targetCrud;
    }

    protected RaDec2PixOperations getRaDec2PixOps() {
        if (raDec2PixOps == null) {
            raDec2PixOps = new RaDec2PixOperations();
        }
        return raDec2PixOps;
    }

    public void setRaDec2PixOperations(RaDec2PixOperations raDec2PixOps) {
        this.raDec2PixOps = raDec2PixOps;
    }

    protected FrontEndPipelineMetadata getFrontEndPipelineMetadata() {
        if (frontEndPipelineMetadata == null) {
            frontEndPipelineMetadata = new FrontEndPipelineMetadata();
        }
        return frontEndPipelineMetadata;
    }

    public void setFrontEndPipelineMetadata(
        FrontEndPipelineMetadata frontEndPipelineMetadata) {
        this.frontEndPipelineMetadata = frontEndPipelineMetadata;
    }

    protected BlobOperations getBlobOperations(PipelineTask pipelineTask) {
        return new BlobOperations(getMatlabWorkingDir(pipelineTask));
    }

    protected File getMatlabWorkingDir(PipelineTask pipelineTask) {
        return allocateWorkingDir(pipelineTask);
    }

    protected ExporterPipelineUtils createExporterPipelineUtils() {
        return new ExporterPipelineUtils();
    }

    public void setDatastoreReadOnly(boolean newState) {
        this.dataStoreReadOnly = newState;
    }
    
    protected UnifiedObservedTargetCrud getUnifiedObservedTargetCrud() {
        if (unifiedTargetCrud == null) {
            unifiedTargetCrud = new UnifiedObservedTargetCrud();
        }
        return unifiedTargetCrud;
    }
    
    public void setPipelineInstanceCrud(PipelineInstanceCrud crud) {
        pipelineInstanceCrud = crud;
    }
    
    protected PipelineInstanceCrud getPipelineInstanceCrud() {
        if (pipelineInstanceCrud == null) {
            pipelineInstanceCrud = new PipelineInstanceCrud();
        }
        return pipelineInstanceCrud;
    }
    
    public void setRollingBandUtils(RollingBandUtils crud) {
        rollingBandUtils = crud;
    }
    
    protected RollingBandUtils getRollingBandUtils(int ccdModule, int ccdOutput, int startCadence, int endCadence) {
        if (rollingBandUtils == null) {
            rollingBandUtils = new RollingBandUtils(ccdModule, ccdOutput, startCadence, endCadence);
        }
        return rollingBandUtils;
    }
}
