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

package gov.nasa.kepler.ar.cli;

import java.util.NoSuchElementException;

import gov.nasa.kepler.ar.exporter.ExporterParameters;
import gov.nasa.kepler.ar.exporter.dv.DvTimeSeriesExporter2PipelineModule;
import gov.nasa.kepler.ar.exporter.dv.DvExporterPipelineModuleParameters;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.uow.PlanetaryCandidatesChunkUowTask;
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * Run the dv time series exporter outside of the pipeline.
 * 
 * @author Sean McCauliff
 *
 */
public class DvTimeSeriesExportCli {

    private static final long NINE_TWO_DV_INSTANCE_ID = 9794;
    private static final long NINE_TWO_TPS_INSTANCE_ID = 9774;
    
    private final DvTimeSeriesExporter2PipelineModule exporterPipelineModule;
    
    
    DvTimeSeriesExportCli() {
        exporterPipelineModule = new DvTimeSeriesExporter2PipelineModule();
        
    }
    
    void export(int startCadence, int endCadence,
        int skyGroupId,
        int startKeplerId, int endKeplerId,
        long dvPipelineInstanceId,
        long tpsPipelineInstanceId) {
        
        final ExporterParameters exporterParam = new ExporterParameters();
        exporterParam.setDataReleaseNumber(-99);
        exporterParam.setStartCadence(startCadence);
        exporterParam.setEndCadence(endCadence);
        exporterParam.setFrontEndPipelineInstance(3);
        exporterParam.setIgnoreZeroCrossingsForReferenceCadence(false);
        exporterParam.setK2Campaign(-1);
        exporterParam.setNfsExportDirectory("/path/to/all-dv-time-series");
        exporterParam.setQuarter(-1);
        
        final DvExporterPipelineModuleParameters dvExporterParam = new DvExporterPipelineModuleParameters();
        dvExporterParam.setDvPipelineInstanceId(dvPipelineInstanceId);
        dvExporterParam.setTpsPipelineInstanceId(tpsPipelineInstanceId);
        
        PipelineTask pipelineTask = new PipelineTask() {
            @SuppressWarnings("unchecked")
            @Override
            public <T extends Parameters> T getParameters(Class<T> parametersClass) {
                if (parametersClass == ExporterParameters.class) {
                    return (T) exporterParam;
                } else if (parametersClass == DvExporterPipelineModuleParameters.class) {
                    return (T) dvExporterParam;
                }
                throw new NoSuchElementException();
            }
        };
        pipelineTask.setId(-888);
        
        
        
        PlanetaryCandidatesChunkUowTask uow = new PlanetaryCandidatesChunkUowTask();
        uow.setSkyGroupId(skyGroupId);
        uow.setStartKeplerId(startKeplerId);
        uow.setEndKeplerId(endKeplerId);
        
        pipelineTask.setUowTask(new BeanWrapper<UnitOfWorkTask>(uow));
        
        exporterPipelineModule.processTask(null, pipelineTask);
        
        
    }
    
    public static void main(String[] argv) throws Exception {
        DvTimeSeriesExportCli exporter = new DvTimeSeriesExportCli();
        
// for some module 3 targets.
//        int startKeplerId = 10851035;
//        int endKeplerId = 10910878;
//      int skyGroupId = 5; //this has module 3 in rotation
        int skyGroupId = 47;
        // 1105,72531]
        int startCadence = 1105; //start of Q1
        int endCadence = 72531; // This seems to be the end of some of the processing runs.

        int startKeplerId = 6028860;
        int endKeplerId = 7187184;
        
        long miniRunTps = 10475;
        long miniRunDv = 10476;
        
      //  for (int skyGroupId=1; skyGroupId <= 84; skyGroupId++) {
            try {
                DatabaseServiceFactory.getInstance().beginTransaction();
                exporter.export(startCadence, endCadence, skyGroupId, startKeplerId, endKeplerId,
                    miniRunDv, miniRunTps);
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                DatabaseServiceFactory.getInstance().rollbackTransactionIfActive();
            }
       // }
    }
    
    /*
     * For some module 3 targets.
     * 
     * Kepler ids that match:
     * 
select distinct(tps.KEPLER_ID) from TPS_RESULT tps 
    inner join PI_PIPELINE_TASK ptask on ptask.id = tps.PI_PIPELINE_TASK_ID 
    inner join PI_PIPELINE_INSTANCE pinst on pinst.id = ptask.PI_PIPELINE_INSTANCE_ID 
    inner join CM_KIC kic on kic.KEPLER_ID = tps.KEPLER_ID 
    where pinst.id = 9774 and kic.sky_group_id = 5 and tps.IS_PLANETACANDIDATE = 1

select * from CM_SKY_GROUP where CCD_MODULE = 3
     * 
     * 10,851,035
10,910,878
11,020,521
11,021,188
11,021,252
11,074,514
11,074,541
11,074,835
11,075,124
11,075,279
11,075,429
11,075,737
11,076,176
11,076,276
11,076,279
11,076,400
11,127,641
11,129,258
11,129,738
11,181,260
11,182,260
11,182,608
11,182,840
11,183,259
11,183,539
11,234,677
11,235,323
11,235,536
11,236,035
11,236,244
11,236,745
11,237,410
11,287,726
11,288,051
11,288,072
11,288,492
11,288,505
11,288,686
11,288,772
11,289,905
11,290,515
11,340,713
11,341,164
11,341,314
11,342,032
11,342,416
11,342,573
11,342,880
11,393,217
11,393,634
11,394,027
11,395,310
11,395,392
11,395,587
11,395,936
11,445,913
11,446,254
11,446,443
11,446,961
11,497,958
11,497,977
11,498,128
11,498,764
11,499,192
11,499,228
11,499,263
11,499,757
11,551,652
11,551,692
11,602,449
11,602,794
11,654,113
11,654,267
11,705,004

     */

    
}
