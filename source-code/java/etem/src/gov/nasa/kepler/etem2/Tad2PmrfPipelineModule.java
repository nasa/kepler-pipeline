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

import gov.nasa.kepler.common.MatlabDateFormatter;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.pi.PlannedPhotometerConfigParameters;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.dr.NmGenerator;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.DataRepoParameters;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.List;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 */
public class Tad2PmrfPipelineModule extends PipelineModule {

    public static final String MODULE_NAME = "Tad2Pmrf";

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
        requiredParams.add(PlannedPhotometerConfigParameters.class);
        requiredParams.add(DataRepoParameters.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {

        try {
            DataGenParameters dataGenParams = pipelineTask.getParameters(DataGenParameters.class);
            TadParameters tadParameters = pipelineTask.getParameters(TadParameters.class);
            PackerParameters packerParams = pipelineTask.getParameters(PackerParameters.class);
            DataGenDirManager dataGenDirManager = new DataGenDirManager(
                dataGenParams, packerParams, tadParameters);

            PlannedSpacecraftConfigParameters spacecraftConfigParams = pipelineTask.getParameters(PlannedSpacecraftConfigParameters.class);
            PlannedPhotometerConfigParameters photometerConfigParams = pipelineTask.getParameters(PlannedPhotometerConfigParameters.class);
            DataRepoParameters dataRepoParams = pipelineTask.getParameters(DataRepoParameters.class);

            String tlsName = tadParameters.getTargetListSetName();
            TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
            TargetListSet tls = targetSelectionCrud.retrieveTargetListSet(tlsName);

            int scConfigId = spacecraftConfigParams.getScConfigId();
            int compressionId = photometerConfigParams.getCompressionExternalId();

            if (tls == null) {
                throw new ModuleFatalProcessingException(
                    "No target list set found for name = " + tlsName);
            }

            String pmrfDir = dataGenDirManager.getPmrfDir(photometerConfigParams);
            double startMjd = ModifiedJulianDate.dateToMjd(MatlabDateFormatter.dateFormatter()
                .parse(packerParams.getStartDate()));

            double secondsPerShortCadence = spacecraftConfigParams.getSecondsPerShortCadence();
            int shortCadencesPerLong = spacecraftConfigParams.getShortCadencesPerLongCadence();

            int badId = photometerConfigParams.getBadExternalId();
            int bgpId = photometerConfigParams.getBgpExternalId();
            int tadId = photometerConfigParams.getTadExternalId();
            int lctId = photometerConfigParams.getLctExternalId();
            int sctId = photometerConfigParams.getSctExternalId();
            int rptId = photometerConfigParams.getRptExternalId();

            // Clean output dir.
            FileUtil.cleanDir(pmrfDir);

            // Create files.
            switch (tls.getType()) {
                case SHORT_CADENCE:
                    Tad2PmrfShort tad2PmrfShort = new Tad2PmrfShort(tlsName,
                        pmrfDir, startMjd, scConfigId,
                        dataRepoParams.getMasterFitsPath(),
                        secondsPerShortCadence, shortCadencesPerLong,
                        compressionId, badId, bgpId, tadId, lctId, sctId, rptId);
                    tad2PmrfShort.export();
                    break;

                case LONG_CADENCE:
                    Tad2PmrfLong tad2PmrfLong = new Tad2PmrfLong(tlsName,
                        pmrfDir, startMjd, scConfigId,
                        dataRepoParams.getMasterFitsPath(),
                        secondsPerShortCadence, shortCadencesPerLong,
                        compressionId, badId, bgpId, tadId, lctId, sctId, rptId);
                    tad2PmrfLong.export();
                    break;

                default:
                    throw new IllegalStateException(
                        "Unexpected TargetTable.type = " + tls.getType());
            }

            // Generate nm.
            NmGenerator.generateNotificationMessage(pmrfDir, "tara");

        } catch (Exception e) {
            throw new PipelineException("Unable to process task.", e);
        }
    }

}
