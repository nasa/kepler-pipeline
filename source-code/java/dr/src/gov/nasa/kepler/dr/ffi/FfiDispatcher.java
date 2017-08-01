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

package gov.nasa.kepler.dr.ffi;

import static gov.nasa.kepler.common.FitsConstants.SCCONFID_KW;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.FfiType;
import gov.nasa.kepler.common.FitsUtils;
import gov.nasa.kepler.common.pi.CalFfiModuleParameters;
import gov.nasa.kepler.dr.dispatch.DispatchException;
import gov.nasa.kepler.dr.dispatch.Dispatcher;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapper;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapperFactory;
import gov.nasa.kepler.dr.dispatch.Launchable;
import gov.nasa.kepler.dr.dispatch.NotificationMessageHandler;
import gov.nasa.kepler.dr.dispatch.PipelineLauncher;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.hibernate.dr.FfiLog;
import gov.nasa.kepler.hibernate.dr.FfiLogCrud;
import gov.nasa.kepler.hibernate.dr.FileLog;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetCrud;
import gov.nasa.kepler.hibernate.pi.ParameterSetName;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.Header;
import nom.tam.fits.ImageHDU;

/**
 * This dispatcher processes and stores FFI's.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 */
public class FfiDispatcher implements Dispatcher, Launchable {

    private FfiLogCrud ffiLogCrud;

    private String timestamp;

    public FfiDispatcher() {
        try {
            ffiLogCrud = new FfiLogCrud(DatabaseServiceFactory.getInstance());
        } catch (PipelineException e) {
            throw new DispatchException("Initilialization failure", e);
        }
    }

    @Override
    public void dispatch(Set<String> filenames, String sourceDirectory,
        DispatchLog dispatchLog, DispatcherWrapper dispatcherWrapper) {
        List<String> timestampsToLaunch = new ArrayList<String>();

        for (String filename : filenames) {
            try {
                FileLog fileLog = dispatcherWrapper.storeFile(filename);

                // Read the file to check basic formatting.
                Fits fits = new Fits(new FileInputStream(sourceDirectory
                    + File.separator + filename));

                BasicHDU primaryHdu = fits.getHDU(0);
                Header primaryHeader = primaryHdu.getHeader();

                int scConfigId = FitsUtils.getHeaderIntValueChecked(
                    primaryHeader, SCCONFID_KW);

                // Check that the file contains 84 image extensions of size
                // 1132x1070.
                for (int i = 1; i <= FcConstants.MODULE_OUTPUTS; i++) {
                    BasicHDU hdu = fits.getHDU(i);
                    if (hdu instanceof ImageHDU) {
                        ImageHDU imageHdu = (ImageHDU) hdu;
                        long size = imageHdu.getData()
                            .getSize();
                        if (size
                            / (FcConstants.CCD_ROWS * FcConstants.CCD_COLUMNS * 4) != 1) {
                            throw new DispatchException(
                                "FFIs must contain image HDUs of size 1132*1070*4.  actual size = "
                                    + size);
                        }
                    } else {
                        throw new DispatchException(
                            "FFIs must contain image HDUs.  HDU[" + i
                                + "] is of type " + hdu.getClass());
                    }
                }

                // Store metadata.
                ffiLogCrud.createFfiLog(new FfiLog(fileLog, scConfigId));

                // Store single-channel ffi fits blobs.
                Pair<String, String> filenameTimestampSuffixPair = NotificationMessageHandler.getFilenameTimestampSuffixPair(filename);
                timestamp = filenameTimestampSuffixPair.left;
                String suffix = filenameTimestampSuffixPair.right;
                if (suffix.contains(DispatcherWrapperFactory.FFI_ORIGINAL)) {
                    FileStoreClient fsClient = FileStoreClientFactory.getInstance();
                    for (int i = 1; i <= FcConstants.MODULE_OUTPUTS; i++) {
                        BasicHDU hdu = fits.getHDU(i);

                        ByteArrayOutputStream os = new ByteArrayOutputStream();

                        Fits singleChannelFits = new Fits();
                        singleChannelFits.addHDU(primaryHdu);
                        singleChannelFits.addHDU(hdu);
                        singleChannelFits.write(new DataOutputStream(os));

                        FsId fsId = DrFsIdFactory.getSingleChannelFfiFile(
                            timestamp, FfiType.ORIG,
                            FcConstants.getModuleOutput(i).left,
                            FcConstants.getModuleOutput(i).right);

                        fsClient.writeBlob(fsId,
                            DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID,
                            os.toByteArray());

                        os.close();
                    }

                    timestampsToLaunch.add(timestamp);
                }
            } catch (Throwable e) {
                dispatcherWrapper.throwExceptionForFile(filename, e);
            }
        }

        if (timestampsToLaunch.size() == 1) {
            // Launch the pipeline. The pipeline will actually only
            // launch if the dispatcher trigger is enabled.
            timestamp = timestampsToLaunch.get(0);
            new PipelineLauncher().launchIfEnabled(this, dispatchLog);
        } else {
            // Log an alert.
            AlertServiceFactory.getInstance()
                .generateAlert(
                    getClass().getName(),
                    "No pipeline will be launched.  In order for a pipeline to launch, "
                        + getClass().getSimpleName()
                        + " expects to find exactly one "
                        + DispatcherWrapperFactory.FFI_ORIGINAL
                        + " file in the sfnm.\n  "
                        + DispatcherWrapperFactory.FFI_ORIGINAL + "FileCount: "
                        + timestampsToLaunch.size());
        }
    }

    @Override
    public void augmentPipelineParameters(TriggerDefinition triggerDefinition) {
        Map<ClassWrapper<Parameters>, ParameterSetName> pipelineParameterSetNames = triggerDefinition.getPipelineParameterSetNames();

        ParameterSetName calFfiParameterSetName = pipelineParameterSetNames.get(new ClassWrapper<Parameters>(
            CalFfiModuleParameters.class));

        ParameterSetCrud parameterSetCrud = new ParameterSetCrud();
        ParameterSet paramSet = parameterSetCrud.retrieveLatestVersionForName(calFfiParameterSetName);
        CalFfiModuleParameters calFfiModuleParameters = paramSet.parametersInstance();
        calFfiModuleParameters.setFileTimeStamp(timestamp);

        PipelineOperations pipelineOperations = new PipelineOperations();
        pipelineOperations.updateParameterSet(calFfiParameterSetName,
            calFfiModuleParameters, false);
    }

}
