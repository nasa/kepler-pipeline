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

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Pipeline module wrapper for {@link FfiMerge} Unit of work is a single task.
 * Output is one file per module
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class FfiMergePipelineModule extends PipelineModule {

    public static final String MODULE_NAME = "ffiMerge";

    /**
     * 
     */
    public FfiMergePipelineModule() {
    }

    /*
     * (non-Javadoc)
     * 
     * @see gov.nasa.kepler.hibernate.pi.PipelineModule#unitOfWorkTaskType()
     */
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
        return requiredParams;
    }

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    /*
     * (non-Javadoc)
     * 
     * @see gov.nasa.kepler.hibernate.pi.PipelineModule#processTask(gov.nasa.kepler.hibernate.pi.PipelineInstance,
     * gov.nasa.kepler.hibernate.pi.PipelineTask)
     */
    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        IntervalMetricKey key = null;
        try {
            key = IntervalMetric.start();

            DataGenParameters dataGenParams = pipelineTask.getParameters(DataGenParameters.class);
            TadParameters tadParameters = pipelineTask.getParameters(TadParameters.class);
            PackerParameters packerParams = pipelineTask.getParameters(PackerParameters.class);
            DataGenDirManager dataGenDirManager = new DataGenDirManager(
                dataGenParams, packerParams, tadParameters);

            String tlsName = tadParameters.getTargetListSetName();
            TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
            TargetListSet tls = targetSelectionCrud.retrieveTargetListSet(tlsName);

            if (tls == null) {
                throw new ModuleFatalProcessingException(
                    "No target list set found for name = " + tlsName);
            }

            String cadenceType = null;
            switch (tls.getType()) {
                case SHORT_CADENCE:
                    cadenceType = Cadence.CadenceType.SHORT.toString()
                        .toLowerCase();
                    break;

                case LONG_CADENCE:
                    cadenceType = Cadence.CadenceType.LONG.toString()
                        .toLowerCase();
                    break;

                default:
                    throw new IllegalStateException(
                        "Unexpected TargetTable.type = " + tls.getType());
            }

            String outputDir = dataGenDirManager.getEtemDir();

            File mergerOutputDir = new File(outputDir, "merged");

            FfiMerge merger = new FfiMerge(new File(outputDir),
                mergerOutputDir, cadenceType);

            try {
                merger.doMerge();
            } catch (IOException e) {
                throw new ModuleFatalProcessingException(
                    "failed to merge FFIs, caught ", e);
            }
        } finally {
            IntervalMetric.stop("etem2ffimerge.exectime", key);
        }
    }
}
