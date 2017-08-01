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

package gov.nasa.kepler.ar.exporter.background;

import gnu.trove.TLongHashSet;
import gnu.trove.TLongIterator;
import gov.nasa.kepler.ar.archive.*;
import gov.nasa.kepler.ar.exporter.*;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.SipWcsCoordinates;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.kepler.mc.TargetTableParameters;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
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

import com.google.common.collect.ImmutableSortedSet;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;

/**
 * The background pixel exporter pipeline interface.
 * 
 * @author Sean McCauliff
 *
 */
public class BackgroundPixelExporterPipelineModule extends MatlabPipelineModule {

    public static final String MODULE_NAME = "bkgx";
    
    private static final Log log = LogFactory.getLog(BackgroundPixelExporterPipelineModule.class);
    
    private TargetCrud targetCrud;
    private MjdToCadence mjdToCadence;
    private DataAnomalyOperations dataAnomalyOps;
    private ConfigMapOperations configMapOps;
    private CompressionCrud compressionCrud;
    private GainOperations gainOps;
    private ReadNoiseOperations readNoiseOps;
    private DataAccountabilityTrailCrud daTrailCrud;
    private RaDec2PixOperations raDec2PixOps;
    private LogCrud logCrud;
    private BlobOperations blobOps;
    private KicCrud kicCrud;
    
    private PipelineInstance frontEndPipelineInstance;
    private FrontEndPipelineMetadata frontEndPipelineMetadata;
    
    private RollingBandUtils rollingBandUtils;

    private ArchiveMatlabProcess archive;
    
    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }
    
    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return ModOutUowTask.class;
    }
    
    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> rv = Lists.newArrayList();
        rv.add(ExporterParameters.class);
        rv.add(TargetTableParameters.class);
        rv.add(SipWcsParameters.class);
        return rv;
    }
    
    @Override
    public void processTask(PipelineInstance pipelineInstance,
        final PipelineTask pipelineTask) throws PipelineException {
        
        DatabaseServiceFactory.getInstance().getSession().setFlushMode(FlushMode.COMMIT);
        
        final Date generatedAt = new Date();
        
        final ModOutUowTask modOutUow = pipelineTask.uowTaskInstance();
        
        log.info("Got unit of work for mod/out " +
            modOutUow.getCcdModule() + "/" +
            modOutUow.getCcdOutput() + ".");
        
        final ExporterParameters exporterParams = 
            pipelineTask.getParameters(ExporterParameters.class);
        
        final SipWcsParameters sipWcsParameters = 
            pipelineTask.getParameters(SipWcsParameters.class);

        TargetTableParameters ttableParams = 
            pipelineTask.getParameters(TargetTableParameters.class);
        
        archive = new ArchiveMatlabProcess(exporterParams.isIgnoreZeroCrossingsForReferenceCadence());
        
        ExporterPipelineUtils utils = createExporterPipelineUtils();
        
        final TargetTable ttable = 
            getTargetCrud().retrieveTargetTable(ttableParams.getTargetTableDbId());
        
        if (ttable.getType() != TargetTable.TargetType.BACKGROUND) {
            throw new IllegalArgumentException("Need background target table, but got : " + ttable + ".");
        }
        
        Pair<Integer, Integer> cadenceInterval = utils.calculateStartEndCadences(
            exporterParams.getStartCadence(), exporterParams.getEndCadence(),
            ttable, getLogCrud());
        
        final int startCadence = cadenceInterval.left;
        final int endCadence = cadenceInterval.right;
        
        frontEndPipelineInstance = getFrontEndPipelineMetadata()
        .getPipelineInstance(CadenceType.LONG, startCadence, endCadence);
        
        final TimestampSeries cadenceTimes = 
            getMjdToCadence().cadenceTimes(startCadence, endCadence);
        
        final File outputDir = 
            utils.createOutputDirectory(new File(exporterParams.getNfsExportDirectory()));
        
        final String defaultFileTimestamp = utils.defaultFileTimestamp(cadenceTimes);
        
        frontEndPipelineInstance = getFrontEndPipelineMetadata().getPipelineInstance(
            CadenceType.LONG, startCadence, endCadence);
        
        final TLongHashSet allOriginators = new TLongHashSet();
        final ArchiveMatlabProcessSource archiveMatlabProcessSource = 
            new ArchiveMatlabProcessSource() {
                
                @Override
                public int startCadence() {
                    return startCadence;
                }
                
                @Override
                public RaDec2PixOperations raDec2PixOps() {
                    return getRaDec2PixOps();
                }
                
                @Override
                public TimestampSeries longCadenceTimes() {
                    return cadenceTimes;
                }
                
                @Override
                public LogCrud logCrud() {
                    return getLogCrud();
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
                    return modOutUow.getCcdOutput();
                }
                
                @Override
                public int ccdModule() {
                    return modOutUow.getCcdModule();
                }
                
                @Override
                public CadenceType cadenceType() {
                    return CadenceType.LONG;
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
                    allOriginators.add(pipelineTaskId);
                }
            };
        SciencePixelOperations sciOps = 
            getSciencePixelOperations(ttable, modOutUow.getCcdModule(), modOutUow.getCcdOutput());
        
        DefaultBackgroundPixelSource bkgSource = 
            new DefaultBackgroundPixelSource(sciOps, ttable, getDataAnomalyOps(),
                getConfigMapOps(), getReadNoiseOps(), getGainOps(),
                getCompressionCrud(), getKicCrud(), cadenceTimes) {
            
            @Override
            public int startCadence() {
                return startCadence;
            }
            
            @Override
            public int quarter() {
                return exporterParams.getQuarter();
            }
            
            @Override
            public long pipelineTaskId() {
                return pipelineTask.getId();
            }
            
            @Override
            public Map<Pixel, BarycentricCorrection> perPixelBarycentricCorrection(
                int barycentricCorrectionCadence, Collection<Pixel> pixels) {

                return calculateBarycentricCorrection(archiveMatlabProcessSource,
                    pixels, barycentricCorrectionCadence, pipelineTask);
            }
            
            @Override
            public MjdToCadence mjdToCadence() {
                return getMjdToCadence();
            }
            
            @Override
            public Date generatedAt() {
                return generatedAt;
            }
            
            @Override
            public String fileTimestamp() {
                return exporterParams.selectTimestamp(ccdModule(), defaultFileTimestamp);
            }
            
            @Override
            public FileStoreClient fileStoreClient() {
                return getFileStoreClient();
            }
            
            @Override
            public File exportDir() {
                return outputDir;
            }
            
            @Override
            public int endCadence() {
                return endCadence;
            }
            
            @Override
            public Map<Pixel, TargetDva> dvaMotionCorrections(Map<Pixel, BarycentricCorrection> perPixelBc, int referenceCadence) {
                return perPixelDvaMotion(archiveMatlabProcessSource,
                    pipelineTask, perPixelBc, referenceCadence);
            }
            
            @Override
            public int dataReleaseNumber() {
                return exporterParams.getDataReleaseNumber();
            }
            
            @Override
            public int ccdOutput() {
                return modOutUow.getCcdOutput();
            }
            
            @Override
            public int ccdModule() {
                return modOutUow.getCcdModule();
            }
            
            @Override
            public BackgroundPolynomial backgroundPolynomial() {
                try {
                    return unpackBackgroundPolynomial(archiveMatlabProcessSource, pipelineTask);
                } catch (IOException ioe) {
                    throw new IllegalStateException(ioe);
                }
            }

            @Override
            public TimestampSeries cadenceTimes() {
                return cadenceTimes;
            }
            
            @Override
            public SipWcsCoordinates sipWcsCoordinates(int referenceCadence) {
                return 
                BackgroundPixelExporterPipelineModule.this.
                sipWcsCoordinates(archiveMatlabProcessSource, pipelineTask,
                                         referenceCadence, sipWcsParameters);
            }

            @Override
            public int k2Campaign() {
                return exporterParams.getK2Campaign();
            }

            @Override
            public int[] rollingBandPulseDurationsLc() {
                return getRollingBandUtils(ccdModule(), ccdOutput(), startCadence(), endCadence()).rollingBandPulseDurations();
            }

            @Override
            public boolean ignoreZeroCrossingsForReferenceCadence() {
                return exporterParams.isIgnoreZeroCrossingsForReferenceCadence();
            }
        };
        
        try {
            BackgroundPixelExporter exporter =  new BackgroundPixelExporter();
            TLongHashSet exportOriginators = exporter.export(bkgSource);
            allOriginators.addAll(exportOriginators.toArray());
        } catch (IOException ioe) {
            throw new PipelineException(ioe);
        } catch (FitsException fitse) {
            throw new PipelineException(fitse);
        }
        
        
        Set<Long> javaOriginatorTaskIds = new HashSet<Long>( allOriginators.size() << 1);
        TLongIterator lit = allOriginators.iterator();
        while (lit.hasNext()) {
            javaOriginatorTaskIds.add(lit.next());
        }

        log.info("Originators list "
            + StringUtils.join(javaOriginatorTaskIds.iterator(), ','));

        getDaTrailCrud().create(pipelineTask, javaOriginatorTaskIds);
    }
    
    
    private SipWcsCoordinates sipWcsCoordinates(ArchiveMatlabProcessSource source,
        PipelineTask pipelineTask, int referenceCadence, SipWcsParameters sipWcsParameters) {
 
        PipelineProcessExecutor<ArchiveInputs, ArchiveOutputs> executor = executor(pipelineTask);
        return archive.sipWcsCoordinates(source, executor, false, referenceCadence,
                                  sipWcsParameters.getColStep(),
                                  sipWcsParameters.getRowStep());
    }
    
    private BackgroundPolynomial unpackBackgroundPolynomial(
        ArchiveMatlabProcessSource source,
        PipelineTask pipelineTask) throws IOException {


        PipelineProcessExecutor<ArchiveInputs, ArchiveOutputs> executor = executor(pipelineTask);
        return archive.convertBackgroundPolynomial(source, executor);
    }
    
    private
    Map<Pixel, BarycentricCorrection> calculateBarycentricCorrection(
        ArchiveMatlabProcessSource source, Collection<Pixel> backgroundPixels, 
        final int referenceCadence, PipelineTask task) {

        List<BarycentricCorrectionTarget> pixelsAsTargets = 
            Lists.newArrayListWithCapacity(backgroundPixels.size());
        
        for (final Pixel px : backgroundPixels) {
            BarycentricCorrectionTarget bct = 
                new BarycentricCorrectionTarget() {
                    
                    @Override
                    public Pair<Double, Double> rowColumnCentroid(Map<FsId, TimeSeries> ignored, boolean ignoreZeroCrossings) {
                        return Pair.of((double) px.getRow(), (double) px.getColumn());
                    }
                    
                    @Override
                    public int longReferenceCadence(Map<FsId, TimeSeries> allTimeSeries, boolean ignoreZeroCrossings) {
                        return referenceCadence;
                    }
                    
                    @Override
                    public int keplerId() {
                        return generateId(px);
                    }

                    @Override
                    public double ra() {
                        return Double.NaN;
                    }

                    @Override
                    public double dec() {
                        return Double.NaN;
                    }
                    
                    @Override
                    public boolean isCustomTarget() {
                        return true;
                    }
                };
            pixelsAsTargets.add(bct);
        }

        ArchiveOutputs archiveOutputs = archive.calculateBarycentricCorrections(
            source, executor(task), pixelsAsTargets, null);
        
        Map<Integer, BarycentricCorrection> correctionsById = 
            archiveOutputs.barycentricCorrectionToMap();
        
//        log.info("Barycentric corrections...");
//        for (Map.Entry<Integer, BarycentricCorrection> entry : correctionsById.entrySet()) {
//            int row = entry.getKey() >> 11;
//            int col = entry.getKey() & 0x7ff;
//            log.info("\t(" + row + "," + col + ") -> " + entry.getValue());
//        }
        Map<Pixel, BarycentricCorrection> perPixelCorrections = 
            Maps.newHashMapWithExpectedSize(correctionsById.size());
        for (Pixel px : backgroundPixels) {
            BarycentricCorrection bcCorrection = correctionsById.get(generateId(px));
            if (bcCorrection == null) {
                throw new IllegalStateException("Missing barycentric correction for pixel " + px + ".");
            }
            perPixelCorrections.put(px, bcCorrection);
        }
        
        return perPixelCorrections;
    }
    
    private Map<Pixel, TargetDva> perPixelDvaMotion(
        ArchiveMatlabProcessSource archiveMatlabProcessSource,
        PipelineTask pipelineTask,
        Map<Pixel, BarycentricCorrection> perPixelBc,
        final int referenceCadence) {
        
        List<DvaTargetSource> asDvaTargetSource = Lists.newArrayListWithCapacity(perPixelBc.size());
        
        for (Map.Entry<Pixel, BarycentricCorrection> pixelAndCorrection : perPixelBc.entrySet()) {
            final Pixel px = pixelAndCorrection.getKey();
            final BarycentricCorrection bcCorrection = pixelAndCorrection.getValue();
            
            DvaTargetSource target = new DvaTargetSource() {
                
                @Override
                public Pair<Double, Double> rowColumnCentroid(Map<FsId, TimeSeries> allTimeSeries, boolean ignoreZeroCrosssings) {
                    return Pair.of((double) px.getRow(), (double) px.getColumn());
                }
                
                @Override
                public int longReferenceCadence(Map<FsId, TimeSeries> allTimeSeries, boolean ignoreZeroCrossings) {
                    return referenceCadence;
                }
                
                @Override
                public int keplerId() {
                    return generateId(px);
                }
                
                @Override
                public double ra() {
                    return bcCorrection.getRaDecimalHours();
                }
                
                @Override
                public double dec() {
                    return bcCorrection.getDecDecimalDegrees();
                }
                
                @Override
                public SortedSet<Pixel> aperturePixels() {
                    return ImmutableSortedSet.of(px);
                }
                
                @Override
                public boolean isCustomTarget() {
                    return true;
                }
            };
            
            asDvaTargetSource.add(target);
        }
 
        ArchiveOutputs archiveOutputs = archive.calculateDva(
            archiveMatlabProcessSource, executor(pipelineTask), asDvaTargetSource, null);
        
        Map<Integer, TargetDva> byId = archiveOutputs.targetsDva();
        Map<Pixel, TargetDva> byPixel = Maps.newHashMapWithExpectedSize(byId.size());
        for (Pixel px : perPixelBc.keySet()) {
            TargetDva targetDva = byId.get(generateId(px));
            byPixel.put(px, targetDva);
        }
        
        return byPixel;
    }

    
    /**Generate an id that encodes the pixel
     * coordinate.  This is only used for map keys.
     */
    private static int generateId(Pixel px) {
        return (px.getRow() << 11) | (px.getColumn());
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
    protected ExporterPipelineUtils createExporterPipelineUtils() {
        return new ExporterPipelineUtils();
    }

    private TargetCrud getTargetCrud() {
        if (targetCrud == null) {
            targetCrud = new TargetCrud();
        }
        return targetCrud;
    }

    private MjdToCadence getMjdToCadence() {
        if (mjdToCadence == null) {
            mjdToCadence = new MjdToCadence(CadenceType.LONG, new ModelMetadataRetrieverPipelineInstance(frontEndPipelineInstance));
        }
        return mjdToCadence;
    }

    private DataAnomalyOperations getDataAnomalyOps() {
        if (dataAnomalyOps == null) {
            dataAnomalyOps = new DataAnomalyOperations(new ModelMetadataRetrieverPipelineInstance(frontEndPipelineInstance));
        }
        return dataAnomalyOps;
    }

    private ConfigMapOperations getConfigMapOps() {
        if (configMapOps == null) {
            configMapOps = new ConfigMapOperations();
        }
        return configMapOps;
    }

    private CompressionCrud getCompressionCrud() {
        if (compressionCrud == null) {
            compressionCrud = new CompressionCrud();
        }
        return compressionCrud;
    }

    private GainOperations getGainOps() {
        if (gainOps == null) {
            gainOps = new GainOperations();
        }
        return gainOps;
    }

    private ReadNoiseOperations getReadNoiseOps() {
        if (readNoiseOps == null) {
            readNoiseOps = new ReadNoiseOperations();
        }
        return readNoiseOps;
    }

    private DataAccountabilityTrailCrud getDaTrailCrud() {
        if (daTrailCrud == null) {
            daTrailCrud = new DataAccountabilityTrailCrud();
        }
        return daTrailCrud;
    }

    private RaDec2PixOperations getRaDec2PixOps() {
        if (raDec2PixOps == null) {
            raDec2PixOps = new RaDec2PixOperations();
        }
        return raDec2PixOps;
    }


    private LogCrud getLogCrud() {
        if (logCrud == null) {
            logCrud = new LogCrud();
        }
        return logCrud;
    }

    private FrontEndPipelineMetadata getFrontEndPipelineMetadata() {
        if (frontEndPipelineMetadata == null) {
            frontEndPipelineMetadata = new FrontEndPipelineMetadata();
        }
        return frontEndPipelineMetadata;
    }

    void setFrontEndPipelineMetadata(
        FrontEndPipelineMetadata frontEndPipelineMetadata) {
        this.frontEndPipelineMetadata = frontEndPipelineMetadata;
    }
   
    
    private BlobOperations getBlobOperations(PipelineTask pipelineTask) {
        if (blobOps == null) {
            blobOps = new BlobOperations(allocateWorkingDir(pipelineTask));
        }
        return blobOps;
    }
    
    protected FileStoreClient getFileStoreClient() {
        return FileStoreClientFactory.getInstance();
    }
    
    protected SciencePixelOperations getSciencePixelOperations(TargetTable ttable, int ccdModule, int ccdOutput) {
        return new SciencePixelOperations(null, ttable, ccdModule, ccdOutput);
    }
    
    private KicCrud getKicCrud() {
        if (kicCrud == null) {
            kicCrud = new KicCrud();
        }
        return kicCrud;
    }
    
    void setKicCrud(KicCrud kicCrud) {
        this.kicCrud = kicCrud;
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
