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

package gov.nasa.kepler.ar.exporter.cbv;

import gov.nasa.kepler.ar.archive.*;
import gov.nasa.kepler.ar.exporter.ExporterParameters;
import gov.nasa.kepler.ar.exporter.ExporterPipelineUtils;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.pi.*;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.TargetTableParameters;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.*;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author Sean McCauliff
 *
 */
public class CbvFragmentGeneratorPipelineModule extends MatlabPipelineModule  {

    private static final Log log = LogFactory.getLog(CbvFragmentGeneratorPipelineModule.class);
    
    private static final String MODULE_NAME = "cbvfragment";
    
    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return ModOutUowTask.class;
    }
    
    /**
     * We don't actually use all the members of ExporterParamerters here, but since the
     * next stage of the pipeline needs them we might as well just reuse this
     * parameters object to make everything consistent.
     */
    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> rv = new ArrayList<Class<? extends Parameters>>();
        rv.add(TargetTableParameters.class);
        rv.add(ExporterParameters.class);
        rv.add(CbvFragmentGeneratorParameters.class);
        return rv;
    }
    
    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) throws PipelineException {

        ModOutUowTask uow = pipelineTask.uowTaskInstance();
        int ccdModule = uow.getCcdModule();
        int ccdOutput = uow.getCcdOutput();
        
        ExporterParameters exporterParameters = pipelineTask.getParameters(ExporterParameters.class);
        TargetTableParameters ttableParameters = pipelineTask.getParameters(TargetTableParameters.class);
        final CbvFragmentGeneratorParameters cbvParameters = pipelineTask.getParameters(CbvFragmentGeneratorParameters.class);
        
        
        ExporterPipelineUtils utils = new ExporterPipelineUtils();
        log.info("Getting target table with database id " + ttableParameters.getTargetTableDbId() + ".");
        final TargetTable ttable = utils.targetTableForTargetTableId(ttableParameters.getTargetTableDbId());
        
        
        Pair<Integer, Integer> cadenceInterval = 
            utils.calculateStartEndCadences(exporterParameters.getStartCadence(),
            exporterParameters.getEndCadence(), ttable, 
            getLogCrud());
        
        
        //Actually we don't care about which quality flags were used during CBV
        //generation since we don't export any quality information in the 
        //CBV file.
        MjdToCadence mjdToCadence = new MjdToCadence(CadenceType.LONG, new ModelMetadataRetrieverLatest());
        TimestampSeries cadenceTimes = 
            mjdToCadence.cadenceTimes(cadenceInterval.left, cadenceInterval.right);
        log.info("Generating CBV fragment for module/output " + ccdModule + "/" + ccdOutput + ".");
        
        CbvModOutExporterSource exporterSource = 
            createExporterSource(cbvParameters.isUseFakeMjds(), 
                cadenceInterval.left, cadenceInterval.right, cadenceTimes,
                ccdModule, ccdOutput, pipelineTask, exporterParameters.getQuarter());
        CbvModOutExporter fragmentGenerator = new CbvModOutExporter();
        try {
            fragmentGenerator.export(exporterSource);
        } catch (Exception e) {
            throw new PipelineException(e);
        }
        //At this point the mod/out fragment should reside in the file store.
    }
    
    private CbvModOutExporterSource createExporterSource(
        final boolean useFakeMjds,
        final int startCadence, final int endCadence,
        final TimestampSeries cadenceTimes,
        final int ccdModule, final int ccdOutput,
        final PipelineTask pipelineTask,
        final int quarter) {

        final Date generatedAt = new Date();
        CbvModOutExporterSource source = new CbvModOutExporterSource() {

            
            @Override
            public double startMjd() {
                return cadenceTimes.midTimestamps[0];
            }
            
            @Override
            public int startCadence() {
                return startCadence;
            }
            
            @Override
            public int quarter() {
                return quarter;
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
            public FileStoreClient fsClient() {
                return FileStoreClientFactory.getInstance();
            }
            
            @Override
            public double endMjd() {
                return cadenceTimes.midTimestamps[cadenceTimes.midTimestamps.length - 1];
            }
            
            @Override
            public int endCadence() {
                return endCadence;
            }
            
            @Override
            public int ccdOutput() {
                return ccdOutput;
            }
            
            @Override
            public int ccdModule() {
                return ccdModule;
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
            public CotrendingBasisVectors basisVectors() {
                return retrieveCbvs(startCadence, endCadence,
                    cadenceTimes, ccdModule, ccdOutput,
                    pipelineTask);
            }

            @Override
            public PipelineTaskCrud pipelineTaskCrud() {
                return new PipelineTaskCrud();
            }

            @Override
            public boolean useFakeMjds() {
                return useFakeMjds;
            }
        };
        
        return source;
    }

    /**
     * 
     * @param startCadence
     * @param endCadence
     * @param cadenceTimes
     * @param ccdModule
     * @param ccdOutput
     * @param pipelineTask
     * @return May return null if basis vectors do not exist.
     */
    private CotrendingBasisVectors retrieveCbvs(
        final int startCadence, final int endCadence,
        final TimestampSeries cadenceTimes,
        final int ccdModule, final int ccdOutput,
        final PipelineTask pipelineTask) {
        
        ArchiveMatlabProcessSource source = new ArchiveMatlabProcessSource() {
            
            @Override
            public int startCadence() {
                return startCadence;
            }
            
            @Override
            public RaDec2PixOperations raDec2PixOps() {
                throw new UnsupportedOperationException();
            }
            
            @Override
            public TimestampSeries longCadenceTimes() {
                return cadenceTimes;
            }
            
            @Override
            public LogCrud logCrud() {
                throw new UnsupportedOperationException();
            }
            
            @Override
            public int endCadence() {
                return endCadence;
            }
            
            @Override
            public ConfigMapOperations configMapOps() {
                throw new UnsupportedOperationException();
            }
            
            @Override
            public int ccdOutput() {
                return ccdOutput;
            }
            
            @Override
            public int ccdModule() {
                return ccdModule;
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
                return getBlobOps(pipelineTask);
            }
            
            @Override
            public void addOriginator(long pipelineTaskId) {
                //This does nothing.
            }
        };
        
        PipelineProcessExecutor<ArchiveInputs, ArchiveOutputs> executor = 
            new PipelineProcessExecutor<ArchiveInputs, ArchiveOutputs>() {
                
                @Override
                public void exec(ArchiveOutputs outputs, ArchiveInputs inputs) {
                    executeAlgorithm(pipelineTask, inputs, outputs);
                }
            };
            
        ArchiveMatlabProcess archiveMatlabProcess = new ArchiveMatlabProcess(false);
        CotrendingBasisVectors basisVectors = 
            archiveMatlabProcess.convertCotrendingBasisVectorBlob(source, executor);
        return basisVectors;
        
    }
    

    protected BlobOperations getBlobOps(PipelineTask pipelineTask) {
        return new BlobOperations(getMatlabWorkingDir(pipelineTask));
    }

    protected File getMatlabWorkingDir(PipelineTask pipelineTask) {
        return allocateWorkingDir(pipelineTask);
    }
    
    protected LogCrud getLogCrud() {
        return new LogCrud();
    }
}
