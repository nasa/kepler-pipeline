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

package gov.nasa.kepler.etem2;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.PlannedPhotometerConfigParameters;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Pipeline module wrapper for {@link DataSetPacker} Unit of work is a cadence
 * range. Output is a file that contains CCSDS packets for all specified
 * cadences.
 * 
 * @author tklaus
 * 
 */
public class DataSetPackerPipelineModule extends PipelineModule {

    public static final String MODULE_NAME = "dataSetPacker";

    private static final Log log = LogFactory.getLog(DataSetPackerPipelineModule.class);

    // private double SECS_PER_VTC_FRACTIONAL_COUNT = 4.096 / 1000.0;

    public DataSetPackerPipelineModule() {
    }

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return SingleUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> requiredParams = new ArrayList<Class<? extends Parameters>>();
        requiredParams.add(DataGenParameters.class);
        requiredParams.add(PackerParameters.class);
        requiredParams.add(PlannedSpacecraftConfigParameters.class);
        requiredParams.add(PlannedPhotometerConfigParameters.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        IntervalMetricKey key = null;

        try {
            key = IntervalMetric.start();

            DataGenParameters dataGenParams = pipelineTask.getParameters(DataGenParameters.class);
            PackerParameters packerParams = pipelineTask.getParameters(PackerParameters.class);
            DataGenDirManager dataGenDirManager = new DataGenDirManager(
                dataGenParams, packerParams);

            PlannedSpacecraftConfigParameters scConfigParams = pipelineTask.getParameters(PlannedSpacecraftConfigParameters.class);

            File outDirFile = new File(dataGenDirManager.getPacketizedDir(),
                "ccsds");

            // make sure output dir exists
            outDirFile.mkdirs();

            DataGenTimeOperations dataGenTimeOperations = new DataGenTimeOperations();
            int startCadence = dataGenTimeOperations.getCadence(dataGenParams,
                scConfigParams, CadenceType.LONG, packerParams.getStartDate());
            int endCadence = startCadence + packerParams.getLongCadenceCount()
                - 1;

            startCadence = 0;
            endCadence = packerParams.getLongCadenceCount() - 1;

            log.info("startCadence = " + startCadence);
            log.info("endCadence = " + endCadence);

            DataSetPacker dataSetPacker = new DataSetPacker();

            PlannedSpacecraftConfigParameters spacecraftConfigParams = pipelineTask.getParameters(PlannedSpacecraftConfigParameters.class);
            PlannedPhotometerConfigParameters photometerConfigParams = pipelineTask.getParameters(PlannedPhotometerConfigParameters.class);

            /*
             * Photometer config ID is 8 bytes consisting of: 0 flags 1 long
             * cadence target table id 2 short cadence target table id 3
             * background target table id 4 background aperture table id 5
             * science aperture table id 6 reference pixel target table id 7
             * compression table id
             */
            long photometerConfigId = photometerConfigParams.getPhotometerConfigId();

            // public void run(
            // String babbleFlags,
            // String inputDirPath,
            // String outputDirPath,
            // String prevRunOutputDirPath,
            //
            // int numShortCadencesPerLongCadence,
            //
            // int numLongCadencesPerBaseline,
            // int startingLongCadenceFileNumber,
            // int numLongCadenceFilesToProcess,
            //
            // String filenameHuffmanTable,
            //
            // long photometerID,
            // long vtcStart,
            // long vtcIncrement

            StringBuilder flags = new StringBuilder("");
            // TODO if using multiple uow, only do this for the last uow:
            if (packerParams.isIncludeFfi()) {
                /* This UOW is the last cadence bin, so we include FFIs */
                log.info("Making CCSDSs for FFI data");
                // indludeFfi
                flags.append("F");
                // ffiOnly
                flags.append("f");
            }

            if (packerParams.isGenDmcFiles()) {
                log.info("Generating DMC-format files");
                flags.append("p");
            }

            DataGenTimeOperations vtcOperations = new DataGenTimeOperations();
            double vtcStartSeconds = vtcOperations.getVtcStartSeconds(packerParams.getStartDate());

            dataSetPacker.run(flags.toString(),
                dataGenDirManager.getDataSetDir(),
                outDirFile.getAbsolutePath(),
                dataGenDirManager.getPreviousPacketizedDir(), spacecraftConfigParams.getShortCadencesPerLongCadence(), spacecraftConfigParams.getLongCadencesPerBaseline(),
                startCadence, packerParams.getLongCadenceCount(),
                photometerConfigParams.getCompressionExternalId(),
                photometerConfigId, vtcStartSeconds,
                spacecraftConfigParams.getSecondsPerShortCadence());
        } catch (Exception e) {
            throw new ModuleFatalProcessingException(
                "failed to run dataSetPacker.  ", e);
        } finally {
            IntervalMetric.stop("datasetpacker.exectime", key);
        }
    }
}
