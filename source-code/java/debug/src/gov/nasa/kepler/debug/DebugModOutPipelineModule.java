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

package gov.nasa.kepler.debug;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.debug.DebugMetadata;
import gov.nasa.kepler.hibernate.debug.DebugMetadataCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.fs.DebugFsIdFactory;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.kepler.services.alert.AlertService;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class DebugModOutPipelineModule extends DebugPipelineModule {
    private static final Log log = LogFactory.getLog(DebugModOutPipelineModule.class);

    public static final String MODULE_NAME = "debug-modout";

    private DebugSimplePipelineParameters debugSimpleParams;

    private ModOutUowTask uow;

    private PipelineTask pipelineTask;

    public DebugModOutPipelineModule() {
    }

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
        
        List<Class<? extends Parameters>> requiredParams = new LinkedList<Class<? extends Parameters>>();
        requiredParams.add(DebugSimplePipelineParameters.class);
        
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance, PipelineTask pipelineTask) {

        this.pipelineTask = pipelineTask;
        uow = pipelineTask.uowTaskInstance();

        // Store something in the db so we can test rollbacks, deadlocks, etc.
        DebugMetadataCrud debugMetadataCrud = new DebugMetadataCrud(DatabaseServiceFactory.getInstance());
        debugMetadataCrud.create(new DebugMetadata(getModuleName(), pipelineTask));

        AlertService alertsService = AlertServiceFactory.getInstance();
        alertsService.generateAlert("debug-modout", pipelineTask.getId(), Severity.WARNING, "debug-modout was here");
        
        debugSimpleParams = (DebugSimplePipelineParameters) pipelineInstance.getPipelineParameters(DebugSimplePipelineParameters.class);
        int failChannel = debugSimpleParams.getFailChannel();

        if (failChannel != 0) {
            int currentChannel = FcConstants.getChannelNumber(uow.getCcdModule(), uow.getCcdOutput());

            if (currentChannel == failChannel) {
                throw new ModuleFatalProcessingException("Throwing exception because currentChannel == failChannel == "
                    + currentChannel);
            }
        }

        double failure = Math.random() * 100.0;
        if (failure < debugSimpleParams.getFailureProbability()) {
            throw new ModuleFatalProcessingException("Throwing exception because of failureProbability");
        }
        
        // read input timeseries
        if (debugSimpleParams.isIncludeFilestore()) {
            log.info("includeFilestore == true, reading "
                + debugSimpleParams.getNumTimeseries()
                + " timeseries from filestore");
            readFilestore(debugSimpleParams.getNumTimeseries());
        } else {
            log.info("includeFilestore == false, NOT reading from filestore");
        }

        sleep(debugSimpleParams);
        
        // store output timeseries
        if (debugSimpleParams.isIncludeFilestore()) {
            writeFilestore();
        } else {
            log.info("includeFilestore == false, NOT writing to filestore");
        }
    }
    
    private void readFilestore(int count) {
        
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();

        FsId[] fsIds = new FsId[count];

        for (int i = 0; i < count; i++) {
            fsIds[i] = DebugFsIdFactory.getDebugInputsId(i, uow.getCcdModule(), uow.getCcdOutput());
        }

        IntTimeSeries[] inputTimeSeries = fsClient.readTimeSeriesAsInt(fsIds, 0, debugSimpleParams.getTimeSeriesLength()-1);
        int[][] timeSeriesData = new int[count][];

        for (int i = 0; i < count; i++) {
            timeSeriesData[i] = inputTimeSeries[i].iseries();
        }
    }

    private void writeFilestore() {
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        int count = debugSimpleParams.getNumTimeseries();
        int[][] timeSeriesData = new int[count][debugSimpleParams.getTimeSeriesLength()];
        TimeSeries[] outputTimeSeries = new TimeSeries[count];

        log.info("includeFilestore == true, writing " + count + " timeseries to filestore");

        boolean[] gaps = new boolean[debugSimpleParams.getTimeSeriesLength()];
        Arrays.fill(gaps, false);

        for (int i = 0; i < count; i++) {
            FsId fsId = DebugFsIdFactory.getDebugOutputsId(i, uow.getCcdModule(), uow.getCcdOutput());
            outputTimeSeries[i] = new IntTimeSeries(fsId, timeSeriesData[i], 0,
                debugSimpleParams.getTimeSeriesLength(), gaps, pipelineTask.getId());
        }

        fsClient.writeTimeSeries(outputTimeSeries);
    }
    
}
