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

import gov.nasa.kepler.ar.exporter.ExporterParameters;
import gov.nasa.kepler.ar.exporter.ExporterPipelineUtils;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.*;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.pi.*;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.TargetTableParameters;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.*;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Reads the individual CBV fragments out of the file store server to create
 * the final CBV FITS file.
 * 
 * @author Sean McCauliff
 *
 */
public class CbvAssemblerPipelineModule extends PipelineModule {

    private static final Log log = LogFactory.getLog(CbvAssemblerPipelineModule.class);
    
    private static final String MODULE_NAME = "cbvassembler";
    
    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }
    
    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return SingleUowTask.class;
    }

    /**
     */
    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> rv = new ArrayList<Class<? extends Parameters>>();
        rv.add(TargetTableParameters.class);
        rv.add(ExporterParameters.class);
        return rv;
    }
    
    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) throws PipelineException {

        ExporterParameters exporterParams = pipelineTask.getParameters(ExporterParameters.class);
        TargetTableParameters ttableParams = pipelineTask.getParameters(TargetTableParameters.class);
        
        ExporterPipelineUtils utils = new ExporterPipelineUtils();
        TargetTable ttable = utils.targetTableForTargetTableId(ttableParams.getTargetTableDbId());
        File exportDirectory = new File(exporterParams.getNfsExportDirectory());
        utils.createOutputDirectory(exportDirectory);
        MjdToCadence mjdToCadence = 
            new MjdToCadence(CadenceType.LONG, new ModelMetadataRetrieverLatest());
        Pair<Integer, Integer> cadenceInterval = utils.calculateStartEndCadences(
            exporterParams.getStartCadence(), exporterParams.getEndCadence(),
            ttable, getLogCrud());
        
        TimestampSeries cadenceTimes =
            mjdToCadence.cadenceTimes(cadenceInterval.left, cadenceInterval.right);
        
        String defaultFileTimestamp = utils.defaultFileTimestamp(cadenceTimes);
        String fileTimestamp = exporterParams.selectTimestamp(-1, defaultFileTimestamp);

        
        CbvAssemblerSource assemblerSource = 
            createAssemblerSource(exporterParams, pipelineTask, exportDirectory,
                ttable.getObservingSeason(), fileTimestamp, ttable);
        
        CbvAssembler assembler = new CbvAssembler();
        try {
            assembler.assemble(assemblerSource);
        } catch (Exception e) {
            throw new PipelineException(e);
        }
    }

    private CbvAssemblerSource createAssemblerSource(
        final ExporterParameters exporterParameters,
        final PipelineTask pipelineTask,
        final File exportDirectory,
        final int season,
        final String fileTimestamp,
        TargetTable ttable) {

        double ttablePlannedStartTime = ModifiedJulianDate.dateToMjd(ttable.getPlannedStartTime());
        log.info("Target table planned start time " + ttablePlannedStartTime + " mjd.");
        final boolean isK2 = ttablePlannedStartTime >= FcConstants.KEPLER_END_OF_MISSION_MJD;
        
        final Date generatedAt = new Date();
        
        CbvAssemblerSource source = new CbvAssemblerSource() {
            
            @Override
            public int season() {
                return season;
            }
            
            @Override
            public int quarter() {
                return exporterParameters.getQuarter();
            }
            
            @Override
            public String programName() {
                return CbvAssemblerPipelineModule.class.getSimpleName();
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
            public FileStoreClient fileStoreClient() {
                return FileStoreClientFactory.getInstance();
            }
            
            @Override
            public String exportTimestamp() {
                return fileTimestamp;
            }
            
            @Override
            public File exportDirectory() {
               return exportDirectory;
            }
            
            @Override
            public int dataRelease() {
                return exporterParameters.getDataReleaseNumber();
            }
            
            @Override
            public CadenceType cadenceType() {
                return CadenceType.LONG;
            }
            
            @Override
            public boolean isK2() {
                return isK2;
            }

            @Override
            public int k2Campaign() {
                return exporterParameters.getK2Campaign();
            }
        };
        
        return source;
    }
    
    protected LogCrud getLogCrud() {
        return new LogCrud();
    }

}
