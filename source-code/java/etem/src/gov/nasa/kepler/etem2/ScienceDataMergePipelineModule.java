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

import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Pipeline module wrapper for {@link ScienceDataMerge} Unit of work is a
 * cadence range. Output is a file that contains ETEM2 SSR data for all
 * module/outputs, for all specified cadences.
 * 
 * @author tklaus
 * 
 */
public class ScienceDataMergePipelineModule extends PipelineModule {
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(ScienceDataMergePipelineModule.class);

    public static final String MODULE_NAME = "scienceDataMerge";

    private DataGenParameters dataGenParams;
    private TadParameters tadParameters;
    private PackerParameters packerParams;
    private DataGenDirManager dataGenDirManager;
    private PlannedSpacecraftConfigParameters scConfigParams;
    private CadenceType cadenceType;
    private int cadenceCount;
    private Etem2DitherParameters etem2DitherParams;

    public ScienceDataMergePipelineModule() {
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
        requiredParams.add(TadParameters.class);
        requiredParams.add(PackerParameters.class);
        requiredParams.add(PlannedSpacecraftConfigParameters.class);
        requiredParams.add(Etem2DitherParameters.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance, PipelineTask pipelineTask) {
        IntervalMetricKey key = null;
        try {
            key = IntervalMetric.start();

            setup(pipelineTask);

            Etem2OutputManager outputManager = new Etem2OutputManager(dataGenDirManager, pipelineTask.getId());

            if (etem2DitherParams.isDoDithering()) {
                int cadencesPerOffset = etem2DitherParams.getCadencesPerOffset();
                int numRuns = etem2DitherParams.numOffsets();
                for (int runNumber = 1; runNumber <= numRuns; runNumber++) {
                    int globalStartCadenceNumber = (runNumber - 1) * cadencesPerOffset;

                    outputManager.setRunNumber(runNumber);

                    log.info("doing the merge in the dithered case, cadencesPerOffset = " + cadencesPerOffset);

                    doMerge(outputManager.getOutputDir(), 0, cadencesPerOffset - 1, cadenceType, globalStartCadenceNumber);
                }
            } else { // no dithering
                log.info("doing the merge in the non-dithered case");
                doMerge(outputManager.getOutputDir(), 0, cadenceCount - 1, cadenceType, 0);
            }

        } catch (Exception e) {
            throw new PipelineException("Unable to run scienceDataMerge.  ", e);
        } finally {
            IntervalMetric.stop("etem2merge.exectime", key);
        }
    }

    private void doMerge(String sourceDirectory, int startCadence, int endCadence, CadenceType cadenceTypeToMerge,
        int mergeFilenameCadenceNumberOffset) {

        // always write the merge output to etem/merged, even in the dithered
        // case.
        File mergerOutputDir = new File(dataGenDirManager.getEtemDir(), "merged");

        log.info("Merging files in: " + sourceDirectory + " to " + mergerOutputDir);
        log.info("Start cadence = " + startCadence + ", End cadence = " + endCadence);

        switch (cadenceTypeToMerge) {
            case LONG:
                LongScienceDataMerge merger = new LongScienceDataMerge(new File(sourceDirectory), mergerOutputDir,
                    startCadence, endCadence, cadenceTypeToMerge.toString()
                        .toLowerCase(), mergeFilenameCadenceNumberOffset);
                try {
                    merger.doMerge();
                } catch (IOException e) {
                    throw new ModuleFatalProcessingException("failed to merge long cadence(cadenceCount = "
                        + cadenceCount + "), caught ", e);
                }
                break;
            case SHORT:
                ShortScienceDataMerge shortMerger = new ShortScienceDataMerge(new File(sourceDirectory),
                    mergerOutputDir, startCadence, endCadence, cadenceTypeToMerge.toString()
                        .toLowerCase(), mergeFilenameCadenceNumberOffset);
                try {
                    shortMerger.doMerge();
                } catch (IOException e) {
                    throw new ModuleFatalProcessingException("failed to merge short cadence(cadenceCount = "
                        + cadenceCount + "), caught ", e);
                }
                break;
        }
    }

    private void setup(PipelineTask pipelineTask) {
        dataGenParams = pipelineTask.getParameters(DataGenParameters.class);
        tadParameters = pipelineTask.getParameters(TadParameters.class);
        packerParams = pipelineTask.getParameters(PackerParameters.class);
        dataGenDirManager = new DataGenDirManager(dataGenParams, packerParams, tadParameters);
        etem2DitherParams = pipelineTask.getParameters(Etem2DitherParameters.class);

        scConfigParams = pipelineTask.getParameters(PlannedSpacecraftConfigParameters.class);

        String tlsName = tadParameters.getTargetListSetName();
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        TargetListSet tls = targetSelectionCrud.retrieveTargetListSet(tlsName);

        if (tls == null) {
            throw new ModuleFatalProcessingException("No target list set found for name = " + tlsName);
        }

        cadenceType = null;
        cadenceCount = 0;

        switch (tls.getType()) {
            case LONG_CADENCE:
                cadenceType = Cadence.CadenceType.LONG;
                cadenceCount = packerParams.getLongCadenceCount();
                break;
            case SHORT_CADENCE:
                cadenceType = Cadence.CadenceType.SHORT;
                cadenceCount = packerParams.getLongCadenceCount() * scConfigParams.getShortCadencesPerLongCadence();
                break;
            default:
                throw new IllegalStateException("Unexpected TargetTable.type = " + tls.getType());
        }
    }
}
