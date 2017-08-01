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

import static gov.nasa.kepler.common.FitsConstants.*;
import gov.nasa.kepler.common.FfiType;
import gov.nasa.kepler.common.MatlabDateFormatter;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.pi.CalFfiModuleParameters;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.etem2.DataGenParameters;
import gov.nasa.kepler.etem2.PackerParameters;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.StreamedBlobResult;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.util.ArrayList;
import java.util.List;

import nom.tam.fits.Fits;
import nom.tam.fits.Header;
import nom.tam.util.BufferedDataInputStream;

/**
 * This {@link PipelineModule} primes the ffi that is an input for calFfi. This
 * class is only used for testing calFfi.
 * 
 * @author Miles Cote
 * 
 */
public class SystestCalFfiSetupPipelineModule extends PipelineModule {

    public static final String MODULE_NAME = "calFfiSetup";

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
        List<Class<? extends Parameters>> requiredParams = new ArrayList<Class<? extends Parameters>>();
        requiredParams.add(DataGenParameters.class);
        requiredParams.add(PackerParameters.class);
        requiredParams.add(PlannedSpacecraftConfigParameters.class);
        requiredParams.add(CalFfiModuleParameters.class);

        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        try {
            PackerParameters packerParams = pipelineTask.getParameters(PackerParameters.class);
            PlannedSpacecraftConfigParameters spacecraftConfigParams = pipelineTask.getParameters(PlannedSpacecraftConfigParameters.class);
            CalFfiModuleParameters calFfiModuleParameters = pipelineTask.getParameters(CalFfiModuleParameters.class);

            ModOutUowTask task = pipelineTask.uowTaskInstance();
            int ccdModule = task.getCcdModule();
            int ccdOutput = task.getCcdOutput();

            FsId fsId = DrFsIdFactory.getSingleChannelFfiFile(
                calFfiModuleParameters.getFileTimeStamp(), FfiType.ORIG,
                ccdModule, ccdOutput);

            FileStoreClient fsClient = FileStoreClientFactory.getInstance();
            StreamedBlobResult blobResult = fsClient.readBlobAsStream(fsId);

            // Modify fits headers.
            BufferedDataInputStream bin = new BufferedDataInputStream(
                blobResult.stream());
            Fits fits = new Fits(bin);
            fits.read();
            for (int i = 0; i < fits.getNumberOfHDUs(); i++) {
                Header header = fits.getHDU(i)
                    .getHeader();

                if (header.containsKey(SCCONFID_KW)) {
                    header.addValue(
                        SCCONFID_KW,
                        spacecraftConfigParams.getScConfigId(), "");
                }

                double startMjd = ModifiedJulianDate.dateToMjd(MatlabDateFormatter.dateFormatter()
                    .parse(packerParams.getStartDate()));
                if (header.containsKey(STARTIME_KW)) {
                    header.addValue(STARTIME_KW,
                        startMjd, "");
                }

                if (header.containsKey(END_TIME_KW)) {
                    double secondsPerLongCadence = spacecraftConfigParams.getSecondsPerShortCadence()
                        * spacecraftConfigParams.getShortCadencesPerLongCadence();
                    double daysPerLongCadence = secondsPerLongCadence / 86400;

                    header.addValue(END_TIME_KW,
                        startMjd + daysPerLongCadence, "");
                }
            }

            blobResult.stream()
                .close();

            // Write fits back to filestore.
            ByteArrayOutputStream os = new ByteArrayOutputStream();

            fits.write(new DataOutputStream(os));

            fsClient.writeBlob(fsId, pipelineTask.getId(), os.toByteArray());

            os.close();

        } catch (Exception e) {
            throw new PipelineException("Unable to setup ffi.", e);
        }
    }
}
