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

package gov.nasa.kepler.systest;

import gov.nasa.kepler.common.pi.PlannedPhotometerConfigParameters;
import gov.nasa.kepler.etem2.DataGenDirManager;
import gov.nasa.kepler.etem2.DataGenParameters;
import gov.nasa.kepler.etem2.PackerParameters;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.DataRepoParameters;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.List;

public class TestCopierNotifierPipelineModule extends PipelineModule {

    public static final String MODULE_NAME = "testCopierNotifier";

    protected DataRepoParameters dataRepoParams;

    protected TadParameters tadParameters;

    protected IncomingFileCopierRequester requester;

    protected PlannedPhotometerConfigParameters photometerConfigParams;

    private TestCopierNotifierParameters testCopierNotifierParameters;

    private DataGenParameters dataGenParams;

    private PackerParameters packerParams;

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
        requiredParams.add(DataRepoParameters.class);
        requiredParams.add(PlannedPhotometerConfigParameters.class);
        requiredParams.add(TestCopierNotifierParameters.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {

        try {
            testCopierNotifierParameters = pipelineTask.getParameters(TestCopierNotifierParameters.class);
            dataGenParams = pipelineTask.getParameters(DataGenParameters.class);
            tadParameters = pipelineTask.getParameters(TadParameters.class);
            packerParams = pipelineTask.getParameters(PackerParameters.class);

            dataRepoParams = pipelineTask.getParameters(DataRepoParameters.class);

            photometerConfigParams = pipelineTask.getParameters(PlannedPhotometerConfigParameters.class);

            requester = new IncomingFileCopierRequester();

            copyFiles();
        } catch (Exception e) {
            throw new ModuleFatalProcessingException("Unable to notify ", e);
        }
    }

    protected void copyFiles() throws InterruptedException {
        String tlsName = tadParameters.getTargetListSetName();
        if (tlsName == null || tlsName.isEmpty()) {
            // In the ffi case, the tls name is empty, so just copy ffis from
            // the data-repo.
            copyFilesForLcProcessing();
        } else {
            TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
            TargetListSet tls = targetSelectionCrud.retrieveTargetListSet(tlsName);
            TargetType targetType = tls.getType();

            switch (targetType) {
                case LONG_CADENCE:
                    copyFilesForLcProcessing();
                    break;
                case SHORT_CADENCE:
                    copyFilesForScProcessing();
                    break;
                case REFERENCE_PIXEL:
                    // The rp files are under the etem/long directory, so the
                    // tadParameters have to be the long tadParameters.
                    tadParameters = new TadParameters(tls.getAssociatedLcTls()
                        .getName(), null);
                    copyFilesForLcProcessing();
                    break;
                default:
                    throw new IllegalArgumentException(
                        "Unexpected targetType: " + targetType);
            }
        }
    }

    private void copyFilesForLcProcessing() throws InterruptedException {

        if (testCopierNotifierParameters.isConfigMapEnabled()) {
            requester.requestCopyAndWaitForNmCompletion(getDataGenDirManager().getConfigMapExportDir());
        }

        if (testCopierNotifierParameters.isGapReportEnabled()) {
            requester.requestCopyAndWaitForNmCompletion(dataRepoParams.getGapReportPath());
        }

        if (testCopierNotifierParameters.isAncillaryEnabled()) {
            requester.requestCopyAndWaitForNmCompletion(dataRepoParams.getAncillaryPath());
        }

        if (testCopierNotifierParameters.isCrctEnabled()) {
            requester.requestCopyAndWaitForNmCompletion(dataRepoParams.getCrctPath());
        }

        if (testCopierNotifierParameters.isFfiEnabled()) {
            requester.requestCopyAndWaitForNmCompletion(dataRepoParams.getFfiPath());
        }

        if (testCopierNotifierParameters.isHistogramEnabled()) {
            requester.requestCopyAndWaitForNmCompletion(dataRepoParams.getHistogramPath());
        }

        if (testCopierNotifierParameters.isHistoryEnabled()) {
            requester.requestCopyAndWaitForNmCompletion(dataRepoParams.getHistoryPath());
        }

        if (testCopierNotifierParameters.isPmrfEnabled()) {
            requester.requestCopyAndWaitForNmCompletion(getDataGenDirManager().getPmrfDir(
                photometerConfigParams));
        }

        if (testCopierNotifierParameters.isCadenceFitsEnabled()) {
            requester.requestCopyAndWaitForNmCompletion(getDataGenDirManager().getCadenceFitsDir());
        }

        if (testCopierNotifierParameters.isRpEnabled()) {
            requester.requestCopyAndWaitForNmCompletion(getDataGenDirManager().getRpDir()
                + "/contact0");
        }
    }

    private void copyFilesForScProcessing() throws InterruptedException {
        if (testCopierNotifierParameters.isPmrfEnabled()) {
            requester.requestCopyAndWaitForNmCompletion(getDataGenDirManager().getPmrfDir(
                photometerConfigParams));
        }

        if (testCopierNotifierParameters.isCadenceFitsEnabled()) {
            requester.requestCopyAndWaitForNmCompletion(getDataGenDirManager().getCadenceFitsDir());
        }
    }

    private DataGenDirManager getDataGenDirManager() {
        return new DataGenDirManager(dataGenParams, packerParams, tadParameters);
    }

}
