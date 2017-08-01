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

import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;

/**
 * Pipeline module wrapper for {@link VcduPacker} Unit of work is a cadence
 * range.
 * 
 * @author tklaus
 * 
 */
public class VcduPackerPipelineModule extends PipelineModule {

    public static final String MODULE_NAME = "vcduPacker";

    private DataGenParameters dataGenParams;

    private PlannedSpacecraftConfigParameters scConfigParams;

    public VcduPackerPipelineModule() {
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
        requiredParams.add(TransmissionParameters.class);
        requiredParams.add(PlannedSpacecraftConfigParameters.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        IntervalMetricKey key = null;

        try {
            key = IntervalMetric.start();

            dataGenParams = pipelineTask.getParameters(DataGenParameters.class);
            TransmissionParameters transmissionParams = pipelineTask.getParameters(TransmissionParameters.class);
            DataGenDirManager dataGenDirManager = new DataGenDirManager(
                dataGenParams, transmissionParams);

            scConfigParams = pipelineTask.getParameters(PlannedSpacecraftConfigParameters.class);

            File outDirFile = new File(dataGenDirManager.getVcduDir());
            outDirFile.mkdirs();

            String prevRunOutDir = null;
            String previousTransmissionDir = dataGenDirManager.getPreviousTransmissionDir();
            if (transmissionParams.isUsePrevRunDir()
                && previousTransmissionDir != null) {
                prevRunOutDir = previousTransmissionDir + "/vcdu";
            }

            String inputSpecs = transmissionParams.getInputSpecs();

            VcduPacker vcduPacker = null;
            if (inputSpecs != null) {
                // There should be inputSpecs.
                vcduPacker = new VcduPacker(dataGenParams.getDataGenOutputPath(),
                    inputSpecs, prevRunOutDir, outDirFile.getAbsolutePath(),
                    transmissionParams.getVirtualChannelNumber());
            } else {
                // Backup plan.
                vcduPacker = new VcduPacker(
                    dataGenDirManager.getCcsdsFilenames(), prevRunOutDir,
                    outDirFile.getAbsolutePath(),
                    transmissionParams.getVirtualChannelNumber(),
                    scConfigParams.getSecondsPerShortCadence(),
                    scConfigParams.getShortCadencesPerLongCadence(),
                    getVtcRanges(transmissionParams.getDateRanges())
                /*
                 * -1, // "any" VTC, along with... "any", // "any" cadence type
                 * means we start at the very first CCSDS packet -1, // "any"
                 * VTC, along with... "any" // "any" cadence type means we end
                 * at the very last CCSDS packet
                 */
                );
            }

            vcduPacker.makeVcdus();

        } catch (Exception e) {
            throw new ModuleFatalProcessingException(
                "failed to run dataSetPacker, caught ", e);
        } finally {
            IntervalMetric.stop("etem2.vcduPacker.exectime", key);
        }
    }

    @SuppressWarnings("unchecked")
    private Pair<Double, Double>[] getVtcRanges(String dateRanges)
        throws ParseException {
        List<Pair<String, String>> pairDateRanges = new ArrayList<Pair<String, String>>();
        for (String dateRange : dateRanges.split(",")) {
            String[] split = dateRange.split("to");
            String startDate = split[0];
            String endDate = split[1];
            pairDateRanges.add(Pair.of(startDate, endDate));
        }

        DataGenTimeOperations dataGenTimeOperations = new DataGenTimeOperations();
        List<Pair<Double, Double>> vtcRanges = new ArrayList<Pair<Double, Double>>();
        for (Pair<String, String> pairDateRange : pairDateRanges) {
            // String startDate =
            // dataGenTimeOperations.getMatlabDate(dataGenParams,
            // scConfigParams, CadenceType.LONG, cadenceRange.left);
            // double vtcStart =
            // dataGenTimeOperations.getVtcStartSeconds(pairDateRange.left);
            double vtcStart = getVtc(dataGenTimeOperations, pairDateRange.left);
            // String endDate =
            // dataGenTimeOperations.getMatlabDate(dataGenParams,
            // scConfigParams, CadenceType.LONG, cadenceRange.right);
            // double vtcEnd =
            // dataGenTimeOperations.getVtcStartSeconds(pairDateRange.right);
            double vtcEnd = getVtc(dataGenTimeOperations, pairDateRange.right);
            vtcRanges.add(Pair.of(vtcStart, vtcEnd));
        }

        return vtcRanges.toArray(new Pair[0]);
    }

    private double getVtc(DataGenTimeOperations dataGenTimeOperations, String s)
        throws ParseException {
        if (-1 != s.toLowerCase()
            .indexOf("any")) {
            return -1;
        } else {
            return dataGenTimeOperations.getVtcStartSeconds(s);
        }
    }
}
