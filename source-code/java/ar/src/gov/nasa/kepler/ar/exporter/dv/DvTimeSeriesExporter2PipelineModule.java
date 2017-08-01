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

import gnu.trove.TLongHashSet;
import gnu.trove.TLongIterator;
import gov.nasa.kepler.ar.exporter.ExporterParameters;
import gov.nasa.kepler.ar.exporter.ExporterPipelineUtils;
import gov.nasa.kepler.ar.exporter.FrontEndPipelineMetadata;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dv.DvCrud;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.uow.PlanetaryCandidatesChunkUowTask;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

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
public class DvTimeSeriesExporter2PipelineModule extends PipelineModule {

    private static final Log log = LogFactory.getLog(DvTimeSeriesExporter2PipelineModule.class);

    private static final String MODULE_NAME = "dvtimeseries2";
    
    
    private TargetCrud targetCrud;
    private MjdToCadence mjdToCadence;
    private LogCrud logCrud;
    private CelestialObjectOperations celestialObjectOperations;
    private DataAnomalyOperations dataAnomalyOperations;
    private ConfigMapOperations configMapOps;
    private DataAccountabilityTrailCrud daTrailCrud;
    private TpsCrud tpsCrud;
    private PipelineInstance frontEndPipelineInstance;
    private PipelineInstanceCrud pipelineInstanceCrud;

    private boolean dataStoreReadOnly = false;

    private DvCrud dvCrud;

    private FrontEndPipelineMetadata frontEndPipelineMetadata;
    
    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }
    
    @Override
    public final Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return PlanetaryCandidatesChunkUowTask.class;
    }
    
    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        return new ImmutableList.Builder<Class<? extends Parameters>>()
        .add(ExporterParameters.class)
        .add(DvExporterPipelineModuleParameters.class)
        .build();
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        final PipelineTask pipelineTask) throws PipelineException {
        
        DatabaseServiceFactory.getInstance().getSession().setFlushMode(FlushMode.COMMIT);
        PlanetaryCandidatesChunkUowTask uow = pipelineTask.uowTaskInstance();

        log.info(getModuleName() + " exporter pipeline module unit of work.");
        log.info(uow.toString());
        
        final ExporterParameters exporterParams = 
            pipelineTask.getParameters(ExporterParameters.class);
        
        DvExporterPipelineModuleParameters dvExporterParameters = 
            pipelineTask.getParameters(DvExporterPipelineModuleParameters.class);

        ExporterPipelineUtils utils = createExporterPipelineUtils();
        final File outputDir = 
            utils.createOutputDirectory(new File(exporterParams.getNfsExportDirectory()));

        if (exporterParams.getStartCadence() == 0 || exporterParams.getEndCadence() == 0) {
            throw new PipelineException("You must specify the start and end parameters.");
        }  
        final int startCadence = exporterParams.getStartCadence();
        final int endCadence = exporterParams.getEndCadence();
        log.info("Exporting for long cadence [" + startCadence + "," + endCadence + "]");
        
        if (exporterParams.getFrontEndPipelineInstance() 
            == ExporterParameters.AUTOMATIC_FRONT_END_PIPELINE_INSTANCE) {
            frontEndPipelineInstance = getFrontEndPipelineMetadata().getPipelineInstance(
                CadenceType.LONG, startCadence, endCadence);
        } else {
            frontEndPipelineInstance = getPipelineInstanceCrud().retrieve(exporterParams.getFrontEndPipelineInstance());
        }
        
      
        log.info("Getting cadence times.");
        //TODO:  this could probably be moved into the data source object.
        final TimestampSeries cadenceTimes = 
            getMjdToCadence(CadenceType.LONG).cadenceTimes( startCadence, endCadence);
        log.info("Done getting cadence times.");

        final Date generatedAt = new Date();
        
        DvExporterSource exporterSource = new DefaultDvExporterSource(uow.getSkyGroupId(),
            getTargetCrud(),
            uow.getStartKeplerId(),
            uow.getEndKeplerId(),
            getLogCrud(),
            getDataAnomalyOperations(),
            getConfigMapOps(),
            getCelestialObjectOperations(),
            getTpsCrud(),
            dvExporterParameters.getTpsPipelineInstanceId(),
            FileStoreClientFactory.getInstance(),
            dvExporterParameters.getDvPipelineInstanceId(),
            getDvCrud()
            ) {
            
            @Override
            public TimestampSeries timestampSeries() {
                return cadenceTimes;
            }
            
            @Override
            public int startCadence() {
                return startCadence;
            }
            
            @Override
            public String programName() {
                return DvTimeSeriesExporter2PipelineModule.class.getSimpleName();
            }
            
            @Override
            public long pipelineTaskId() {
                return pipelineTask.getId();
            }
            
            @Override
            public Date generatedAt() {
                return generatedAt;
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
            public MjdToCadence mjdToCadence() {
                return getMjdToCadence(CadenceType.LONG);
            }
        };

        
        DvTimeSeriesExporter2 dvExporter = new DvTimeSeriesExporter2();
        TLongHashSet originators = null;
        try {
            originators = dvExporter.exportDv(exporterSource);
        } catch (FitsException e) {
            throw new PipelineException(e);
        } catch (IOException e) {
            throw new PipelineException(e);
        }

        Set<Long> javaOriginatorTaskIds = new HashSet<Long>(originators.size());
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

    
    private DvCrud getDvCrud() {
        if (dvCrud == null) {
            dvCrud = new DvCrud();
        }
        return dvCrud;
    }
    
    void setDvCrud(DvCrud dvCrud) {
        this.dvCrud = dvCrud;
    }

    private TpsCrud getTpsCrud() {
        if (tpsCrud == null) {
            tpsCrud = new TpsCrud();
        }
        return tpsCrud;
    }
    
    void setTpsCrud(TpsCrud tpsCrud) {
        this.tpsCrud = tpsCrud;
    }
    
    private DataAccountabilityTrailCrud getDaTrailCrud() {
        if (daTrailCrud == null) {
            daTrailCrud = new DataAccountabilityTrailCrud();
        }
        return daTrailCrud;
    }

    void setDaTrailCrud(DataAccountabilityTrailCrud daTrailCrud) {
        this.daTrailCrud = daTrailCrud;
    }

    private ConfigMapOperations getConfigMapOps() {
        if (configMapOps == null) {
            configMapOps = new ConfigMapOperations();
        }
        return configMapOps;
    }

    void setConfigMapOps(ConfigMapOperations configMapOps) {
        this.configMapOps = configMapOps;
    }

    private DataAnomalyOperations getDataAnomalyOperations() {
        if (dataAnomalyOperations == null) {
            dataAnomalyOperations = new DataAnomalyOperations(new ModelMetadataRetrieverPipelineInstance(frontEndPipelineInstance));
        }
        return dataAnomalyOperations;
    }

    void setDataAnomalyOperations(DataAnomalyOperations dataAnomalyOperations) {
        this.dataAnomalyOperations = dataAnomalyOperations;
    }

    private MjdToCadence getMjdToCadence(CadenceType cadenceType) {
        if (mjdToCadence == null) {
            mjdToCadence = new MjdToCadence(cadenceType, new ModelMetadataRetrieverPipelineInstance(frontEndPipelineInstance));
        }
        return mjdToCadence;
    }

    void setMjdToCadence(MjdToCadence mjdToCadence) {
        this.mjdToCadence = mjdToCadence;
    }

    private LogCrud getLogCrud() {
        if (logCrud == null) {
            logCrud = new LogCrud();
        }
        return logCrud;
    }

    void setLogCrud(LogCrud logCrud) {
        this.logCrud = logCrud;
    }

    private CelestialObjectOperations getCelestialObjectOperations() {
        if (celestialObjectOperations == null) {
            celestialObjectOperations = new CelestialObjectOperations(
                new ModelMetadataRetrieverPipelineInstance(
                    frontEndPipelineInstance), false);
        }
        return celestialObjectOperations;
    }

    void setCelestialObjectOperations(
        CelestialObjectOperations celestialObjectOperations) {
        this.celestialObjectOperations = celestialObjectOperations;
    }

    private TargetCrud getTargetCrud() {
        if (targetCrud == null) {
            targetCrud = new TargetCrud();
        }
        return targetCrud;
    }

    void setTargetCrud(TargetCrud targetCrud) {
        this.targetCrud = targetCrud;
    }

    private ExporterPipelineUtils createExporterPipelineUtils() {
        return new ExporterPipelineUtils();
    }

    void setDatastoreReadOnly(boolean newState) {
        this.dataStoreReadOnly = newState;
    }
    
    void setPipelineInstanceCrud(PipelineInstanceCrud crud) {
        pipelineInstanceCrud = crud;
    }
    
    private PipelineInstanceCrud getPipelineInstanceCrud() {
        if (pipelineInstanceCrud == null) {
            pipelineInstanceCrud = new PipelineInstanceCrud();
        }
        return pipelineInstanceCrud;
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
    
}
