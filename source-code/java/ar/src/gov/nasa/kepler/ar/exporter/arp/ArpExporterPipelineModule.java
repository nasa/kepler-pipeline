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

package gov.nasa.kepler.ar.exporter.arp;

import gov.nasa.kepler.ar.exporter.ExporterParameters;
import gov.nasa.kepler.ar.exporter.ExporterPipelineUtils;
import gov.nasa.kepler.ar.exporter.FrontEndPipelineMetadata;
import gov.nasa.kepler.ar.exporter.RollingBandUtils;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
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
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.kepler.mc.TargetTableParameters;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import nom.tam.fits.FitsException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.FlushMode;

/**
 * Pipeline module for exporting the artifact removal pixels (ARP).
 * 
 * @author Sean McCauliff
 *
 */
public final class ArpExporterPipelineModule extends PipelineModule {

    public static final String MODULE_NAME = "arpx";
    
    private static final Log log = LogFactory.getLog(ArpExporterPipelineModule.class);
    
    private TargetCrud targetCrud;
    private LogCrud logCrud;
    private MjdToCadence mjdToCadence;
    private KicCrud kicCrud;
    
    private PipelineInstance frontEndPipelineInstance;
    private FrontEndPipelineMetadata frontEndPipelineMetadata;
    private ConfigMapOperations configMapOps;
    private GainOperations gainOps;
    private SciencePixelOperations sciOps;
    private CompressionCrud compressionCrud;
    private ReadNoiseOperations readNoiseOps;
    private DataAnomalyOperations dataAnomalyOps;
    
    private RollingBandUtils rollingBandUtils;
    
    
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
        
        log.info("ARP exporter got unit of work for mod/out " +
            modOutUow.getCcdModule() + "/" +
            modOutUow.getCcdOutput() + ".");
        
        TargetTableParameters ttableParams = 
            pipelineTask.getParameters(TargetTableParameters.class);
        
        final TargetTable ttable = 
            getTargetCrud().retrieveTargetTable(ttableParams.getTargetTableDbId());
        
        log.info("Processing target table " + ttable.getExternalId() + " " + ttable.getType());
        
        CadenceType cadenceType = ttable.getType().toCadenceType();
   
        if (ttable.getType() != TargetType.LONG_CADENCE) {
            throw new IllegalStateException("ARP targets are only defined for" +
                    " long cadence target tables.  But target table " + ttable + 
                    " is a " + ttable.getType() + " type table.");
        }
        
        ExporterPipelineUtils utils = createExporterPipelineUtils();
        
        Pair<Integer, Integer> cadenceInterval = utils.calculateStartEndCadences(
            exporterParams.getStartCadence(), exporterParams.getEndCadence(),
            ttable, getLogCrud());
        
        final int startCadence = cadenceInterval.left;
        final int endCadence = cadenceInterval.right;
        
        frontEndPipelineInstance = getFrontEndPipelineMetadata().getPipelineInstance(
            cadenceType, startCadence, endCadence);
        
        final TimestampSeries cadenceTimes = 
            getMjdToCadence().cadenceTimes(startCadence, endCadence);

        final String defaultFileTimestamp = utils.defaultFileTimestamp(cadenceTimes);
        
        final int skyGroupId = getKicCrud().retrieveSkyGroupId(modOutUow.getCcdModule(), modOutUow.getCcdOutput(), ttable.getObservingSeason());
        
        final File outputDir = 
            utils.createOutputDirectory(new File(exporterParams.getNfsExportDirectory()));
        
        final Date generatedAt = new Date();
        
        ArpExporterSource arpExporterSource = 
            new DefaultArpExporterSource(getTargetCrud(), 
                getSciOps(ttable, modOutUow.getCcdModule(), modOutUow.getCcdOutput()), 
                cadenceTimes, getCompressionCrud(), ttable,
                getReadNoiseOps(), getGainOps(),
                getDataAnomalyOps(), getConfigMapOps()
            ) {
            
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
            public int quarter() {
                return exporterParams.getQuarter();
            }
            
            @Override
            public String programName() {
                return ArpExporterPipelineModule.class.getSimpleName();
            }
            
            @Override
            public long pipelineTaskId() {
                return pipelineTask.getId();
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
            public File exportDir() {
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
                return modOutUow.getCcdOutput();
            }
            
            @Override
            public int ccdModule() {
                return modOutUow.getCcdModule();
            }

            @Override
            public int k2Campaign() {
                return exporterParams.getK2Campaign();
            }

            @Override
            public int[] rollingBandPulseDurationsLc() {
                return getRollingBandUtils(ccdModule(), ccdOutput(), startCadence(), endCadence()).rollingBandPulseDurations();
            }
           
        };

        ArpExporter arpExporter = new ArpExporter();
        try {
            arpExporter.export(arpExporterSource);
        } catch (IOException e) {
            throw new PipelineException(e);
        } catch (FitsException e) {
            throw new PipelineException(e);
        }
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
    
    private ConfigMapOperations getConfigMapOps() {
        if (configMapOps == null) {
            configMapOps = new ConfigMapOperations();
        }
        return configMapOps;
    }
    
    private GainOperations getGainOps() {
        if (gainOps == null) {
            gainOps = new GainOperations();
        }
        return gainOps;
    }
    
    void setGainOps(GainOperations newGainOps) {
        this.gainOps = newGainOps;
    }
    
    private SciencePixelOperations getSciOps(TargetTable ttable, int ccdModule, int ccdOutput) {
        if (sciOps == null) {
            sciOps = new SciencePixelOperations(ttable, null, ccdModule, ccdOutput);
        }
        return sciOps;
    }
    
    private CompressionCrud getCompressionCrud() {
        if (compressionCrud == null) {
            compressionCrud = new CompressionCrud();
        }
        return compressionCrud;
    }
    
    private ReadNoiseOperations getReadNoiseOps() {
        if (readNoiseOps == null) {
            readNoiseOps = new ReadNoiseOperations();
        }
        return readNoiseOps;
    }
    
    private DataAnomalyOperations getDataAnomalyOps() {
        if (dataAnomalyOps == null) {
            dataAnomalyOps = 
                new DataAnomalyOperations(new ModelMetadataRetrieverPipelineInstance(frontEndPipelineInstance));
        }
        return dataAnomalyOps;
    }
    
    private MjdToCadence getMjdToCadence() {
        if (mjdToCadence == null) {
            mjdToCadence = new MjdToCadence(CadenceType.LONG, new ModelMetadataRetrieverPipelineInstance(frontEndPipelineInstance));
        }
        return mjdToCadence;
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
