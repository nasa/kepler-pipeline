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

package gov.nasa.kepler.ar.exporter.collateral;

import gov.nasa.kepler.ar.exporter.BlackAlgorithmUtils;
import gov.nasa.kepler.ar.exporter.ExporterParameters;
import gov.nasa.kepler.ar.exporter.ExporterPipelineUtils;
import gov.nasa.kepler.ar.exporter.FrontEndPipelineMetadata;
import gov.nasa.kepler.ar.exporter.ParametersUsedInCalibration;
import gov.nasa.kepler.ar.exporter.RollingBandUtils;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.KeplerSocVersion;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cal.BlackAlgorithm;
import gov.nasa.kepler.hibernate.cal.CalCrud;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.TargetTableParameters;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.pmrf.CollateralPmrfTable;
import gov.nasa.kepler.mc.pmrf.CollateralPmrfTable.Duplication;
import gov.nasa.kepler.mc.pmrf.PmrfOperations;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.*;

import nom.tam.fits.FitsException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.FlushMode;

/**
 * Runs the collateral pixel exporter.
 * 
 * @author Sean McCauliff
 *
 */
public final class CollateralPixelExporterPipelineModule extends PipelineModule {
    
    private static final Log log = LogFactory.getLog(CollateralPixelExporterPipelineModule.class);
    
    public static final String MODULE_NAME = "collateralx";

    private TargetCrud targetCrud;
    private LogCrud logCrud;
    private MjdToCadence mjdToCadence;
    private KicCrud kicCrud;
    private FileStoreClient fsClient;
    
    private PipelineInstance frontEndPipelineInstance;
    private FrontEndPipelineMetadata frontEndPipelineMetadata;
    private PmrfOperations pmrfOps;
    private ConfigMapOperations configMapOps;
    private ParametersUsedInCalibration calibration;
    private RollingBandUtils rollingBandUtils;

    private CalCrud calCrud;

    
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
        List<Class<? extends Parameters>> rv = new ArrayList<Class<? extends Parameters>>();
        rv.add(ExporterParameters.class);
        rv.add(TargetTableParameters.class);
        return rv;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        final PipelineTask pipelineTask) throws PipelineException {
        
        DatabaseServiceFactory.getInstance().getSession().setFlushMode(FlushMode.COMMIT);
        
        final ModOutUowTask modOutUow = pipelineTask.uowTaskInstance();
        
        final ExporterParameters exporterParams = 
            pipelineTask.getParameters(ExporterParameters.class);
        
        log.info("Got unit of work for mod/out " +
            modOutUow.getCcdModule() + "/" +
            modOutUow.getCcdOutput() + ".");
        
        TargetTableParameters ttableParams = 
            pipelineTask.getParameters(TargetTableParameters.class);
        
        final TargetTable ttable = 
            getTargetCrud().retrieveTargetTable(ttableParams.getTargetTableDbId());
        
        log.info("Processing target table " + ttable.getExternalId() + " " + ttable.getType());
        
        final CadenceType cadenceType = ttable.getType().toCadenceType();
   
        ExporterPipelineUtils utils = createExporterPipelineUtils();
        
        Pair<Integer, Integer> cadenceInterval = utils.calculateStartEndCadences(
            exporterParams.getStartCadence(), exporterParams.getEndCadence(),
            ttable, getLogCrud());
        
        
        final int startCadence = cadenceInterval.left;
        final int endCadence = cadenceInterval.right;
        
        frontEndPipelineInstance = getFrontEndPipelineMetadata().getPipelineInstance(
            cadenceType, startCadence, endCadence);
        
        final TimestampSeries cadenceTimes = 
            getMjdToCadence(cadenceType).cadenceTimes(startCadence, endCadence);

        final int skyGroupId = getKicCrud().retrieveSkyGroupId(modOutUow.getCcdModule(), modOutUow.getCcdOutput(), ttable.getObservingSeason());
        
        final File outputDir = 
            utils.createOutputDirectory(new File(exporterParams.getNfsExportDirectory()));
        
        
        final String defaultFileTimestamp = utils.defaultFileTimestamp(cadenceTimes);
        
        final Date generatedAt = new Date();
        
        //TODO:  merge this with DefaultCollateralPixelExporterSource
        CollateralPixelExporterSource exporterSource = 
            new CollateralPixelExporterSource() {
                
                @Override
                public double startMidMjd() {
                    return cadenceTimes.startTimestamps[0];
                }
                
                @Override
                public int startCadence() {
                    return startCadence;
                }
                
                @Override
                public int skyGroup() {
                    return skyGroupId;
                }
                
                @Override
                public int season() {
                    return ttable.getObservingSeason();
                }
                
                @Override
                public double readNoseE() {
                    return getParametersUsedInCalibration(ttable, startMidMjd(), endMidMjd(), ccdModule(), ccdOutput()).readNoiseE();
                }
                
                @Override
                public int quarter() {
                    return exporterParams.getQuarter();
                }
                
                @Override
                public CollateralPmrfTable prmfTable() {
                    return getPmrfOps().getCollateralPmrfTable(cadenceType,
                        ttable.getExternalId(), modOutUow.getCcdModule(), modOutUow.getCcdOutput());
                }
                
                @Override
                public long pipelineTaskId() {
                    return pipelineTask.getId();
                }
                
                @Override
                public MjdToCadence mjdToCadence() {
                    return mjdToCadence;
                }
                
                @Override
                public int meanBlack() {
                    return getParametersUsedInCalibration(ttable, startMidMjd(), endMidMjd(), ccdModule(), ccdOutput()).meanBlackValue();
                }
                
                @Override
                public double gainE() {
                    return getParametersUsedInCalibration(ttable, startMidMjd(), endMidMjd(), ccdModule(), ccdOutput()).gainE();
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
                public double endMidMjd() {
                    return cadenceTimes.endTimestamps[cadenceTimes.endTimestamps.length - 1];
                }
                
                @Override
                public int endCadence() {
                    return endCadence;
                }
                
                @Override
                public String defaultFileTimestamp() {
                    return exporterParams.selectTimestamp(ccdModule(), defaultFileTimestamp);
                }
                
                @Override
                public int dataRelease() {
                    return exporterParams.getDataReleaseNumber();
                }
                
                @Override
                public Collection<ConfigMap> configMaps() {
                    return getConfigMapOps().retrieveConfigMaps(startMidMjd(), endMidMjd());
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
                    return cadenceType;
                }
                
                @Override
                public Date generatedAt() {
                    return generatedAt;
                }

                @Override
                public String subversionRevision() {
                    return KeplerSocVersion.getRevision();
                }

                @Override
                public String subversionUrl() {
                    return KeplerSocVersion.getUrl();
                }

                @Override
                public double startStartMjd() {
                    return cadenceTimes.startTimestamps[0];
                }

                @Override
                public double endEndMjd() {
                    return cadenceTimes.endTimestamps[cadenceTimes.endTimestamps.length - 1];
                }

                @Override
                public int k2Campaign() {
                    return exporterParams.getK2Campaign();
                }

                @Override
                public int targetTableId() {
                    return ttable.getExternalId();
                }

                @Override
                public RollingBandUtils rollingBandUtils() {
                    switch (cadenceType) {
                        case LONG:
                            return getRollingBandUtils(ccdModule(), ccdOutput(), startCadence, endCadence);
                        case SHORT:
                            return getRollingBandUtils(0, 0, 0, 0); //empty
                        default:
                            throw new IllegalStateException("Unhandled cadenceType " + cadenceType);
                    }
                }

                @Override
                public BlackAlgorithm blackAlgorithm() {
                    return BlackAlgorithmUtils.blackAlgorithm(getCalCrud(), ccdModule(), ccdOutput(), startCadence(), endCadence(), cadenceType());
                }
            };
            
        CollateralPixelExporter exporter = new CollateralPixelExporter();
        try {
            exporter.export(exporterSource);
        } catch (FitsException e) {
            throw new PipelineException(e);
        } catch (IOException e) {
            throw new PipelineException(e);
        }
        
        //TODO:  Data accountability tracing.
    }
    
    protected ExporterPipelineUtils createExporterPipelineUtils() {
        return new ExporterPipelineUtils();
    }
    
    private LogCrud getLogCrud() {
        if (logCrud == null) {
            logCrud = new LogCrud();
        }
        return logCrud;
    }
    
    void setLogCrud(LogCrud newCrud) {
        this.logCrud = newCrud;
    }
    
    private TargetCrud getTargetCrud() {
        if (targetCrud == null) {
            targetCrud = new TargetCrud();
        }
        return targetCrud;
    }
    

    private MjdToCadence getMjdToCadence(CadenceType cadenceType) {
        if (mjdToCadence == null) {
            mjdToCadence = new MjdToCadence(cadenceType, 
                new ModelMetadataRetrieverPipelineInstance(frontEndPipelineInstance));
        }
        return mjdToCadence;
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
    
    private KicCrud getKicCrud() {
        if (kicCrud == null) {
            kicCrud = new KicCrud();
        }
        return kicCrud;
    }
    
    void setKicCrid(KicCrud kicCrud) {
        this.kicCrud = kicCrud;
    }
    
    private FileStoreClient getFileStoreClient() {
        if (fsClient == null) {
            fsClient = FileStoreClientFactory.getInstance();
        }
        return fsClient;
    }
    
    void setFileStoreClient(FileStoreClient fsClient) {
        this.fsClient = fsClient;
    }
    
    private PmrfOperations getPmrfOps() {
        if (this.pmrfOps == null) {
            pmrfOps = new PmrfOperations(Duplication.NOT_ALLOWED);
        }
        return pmrfOps;
    }
    
    private ConfigMapOperations getConfigMapOps() {
        if (configMapOps == null) {
            configMapOps = new ConfigMapOperations();
        }
        return configMapOps;
    }
    
    private ParametersUsedInCalibration getParametersUsedInCalibration(
        TargetTable ttable, double startMjd, double endMjd, int ccdModule, int ccdOutput) {
        if (calibration == null) {
            calibration = 
                new ParametersUsedInCalibration(new ReadNoiseOperations(),
                    new GainOperations(), 
                    ttable,
                    new CompressionCrud(), startMjd, endMjd, ccdModule, ccdOutput);
        }
        return calibration;
    }
    
    void setRollingBandUtils(RollingBandUtils rollingBandUtils) {
        this.rollingBandUtils = rollingBandUtils;
    }
    
    private RollingBandUtils getRollingBandUtils(int ccdModule, int ccdOutput, int startCadence, int endCadence) {
        if (rollingBandUtils == null) {
            rollingBandUtils = new RollingBandUtils(ccdModule, ccdOutput, startCadence, endCadence);
        }
        return rollingBandUtils;
    }
    
    private CalCrud getCalCrud() {
        if (calCrud == null) {
            calCrud = new CalCrud();
        }
        return calCrud;
    }
    
    void setCalCrud(CalCrud calCrud) {
        this.calCrud = calCrud;
    }
}
