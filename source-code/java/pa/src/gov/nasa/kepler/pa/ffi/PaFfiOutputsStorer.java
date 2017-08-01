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

package gov.nasa.kepler.pa.ffi;

import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.pa.FfiMotionBlobMetadata;
import gov.nasa.kepler.hibernate.pa.PaCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.mc.MatlabCallState;
import gov.nasa.kepler.mc.MatlabCallStateStream;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.pa.PaOutputs;
import gov.nasa.kepler.pa.PaPipelineModule;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.kepler.services.alert.AlertServiceFactory;

import java.io.File;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Stores {@link PaOutputs}
 * 
 * @author Forrest Girouard
 * @author Miles Cote
 * 
 */
public class PaFfiOutputsStorer {

    /**
     * Logger for this class
     */
    private static final Log log = LogFactory.getLog(PaFfiOutputsStorer.class);

    public static final String MODULE_NAME = "pa";

    private PipelineTask pipelineTask;
    private PipelineInstance pipelineInstance;
    private int ccdModule;
    private int ccdOutput;

    private PaCrud paCrud = new PaCrud();
    private MatlabCallStateStream matlabCallStateStream = new MatlabCallStateStream();

    private MatlabCallState matlabCallState;

    private File matlabWorkingDir;

    public PaFfiOutputsStorer(PipelineTask pipelineTask, int ccdModule,
        int ccdOutput) {
        this.pipelineTask = pipelineTask;
        pipelineInstance = pipelineTask.getPipelineInstance();
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
    }

    private String getModuleName() {
        return MODULE_NAME;
    }

    public void storeOutputs(File matlabWorkingDir, PaOutputs paOutputs) {
        this.matlabWorkingDir = matlabWorkingDir;

        matlabCallState = matlabCallStateStream.read(matlabWorkingDir);

        PaPipelineModule.ProcessingState state = PaPipelineModule.ProcessingState.valueOf(paOutputs.getProcessingState());
        log.info("[" + getModuleName() + "]Processing state: " + state);

        if (matlabCallState.isLastCall()) {

            log.info("[" + getModuleName() + "]persist motion blob.");
            log.debug("[" + getModuleName() + "]motion blob filename: "
                + paOutputs.getMotionBlobFileName());
            if (paOutputs.getMotionBlobFileName() == null
                || paOutputs.getMotionBlobFileName()
                    .length() == 0) {
                throw new IllegalStateException(
                    "Expected motion blob file name but none given.");
            }
            storeFfiMotionBlob(paOutputs);
        }

        if (paOutputs.getAlerts()
            .size() > 0) {
            for (ModuleAlert alert : paOutputs.getAlerts()) {
                AlertServiceFactory.getInstance()
                    .generateAlert(MODULE_NAME, pipelineTask.getId(),
                        Severity.valueOf(alert.getSeverity()),
                        alert.getMessage() + ": time=" + alert.getTime());
            }
        }
    }

    private void storeFfiMotionBlob(final PaOutputs paOutputs) {

        String blobFileName = paOutputs.getMotionBlobFileName();
        FfiMotionBlobMetadata ffiMotionBlobMetadata = new FfiMotionBlobMetadata(
            pipelineTask.getId(), ccdModule, ccdOutput,
            paOutputs.getStartCadence(), paOutputs.getEndCadence(),
            FilenameUtils.getExtension(blobFileName));
        paCrud.createFfiMotionBlobMetadata(ffiMotionBlobMetadata);

        FileStoreClientFactory.getInstance()
            .writeBlob(BlobOperations.getFsId(ffiMotionBlobMetadata),
                pipelineTask.getId(), new File(matlabWorkingDir, blobFileName));
    }

    /**
     * Only used for testing.
     */
    protected void setMatlabWorkingDir(final File matlabWorkingDir) {
        this.matlabWorkingDir = matlabWorkingDir;
    }

    /**
     * Sets this module's PA CRUD. This method isn't used by the module
     * interface, but by tests.
     * 
     * @param paCrud the PA CRUD.
     */
    protected void setPaCrud(final PaCrud paCrud) {
        this.paCrud = paCrud;
    }

    /**
     * Only used for testing.
     */
    protected PipelineInstance getPipelineInstance() {
        return pipelineInstance;
    }

    /**
     * Sets this module's pipeline instance. This is only used internally and by
     * unit tests that aren't calling
     * {@link #processTask(PipelineInstance, PipelineTask)}.
     * 
     * @param pipelineInstance the non-{@code null} pipeline instance.
     * @throws NullPointerException if {@code pipelineInstance} is {@code null}.
     */
    protected void setPipelineInstance(final PipelineInstance pipelineInstance) {

        if (pipelineInstance == null) {
            throw new NullPointerException("pipelineInstance can't be null");
        }

        this.pipelineInstance = pipelineInstance;
        if (pipelineTask != null) {
            pipelineTask.setPipelineInstance(pipelineInstance);
        }
    }

    /**
     * Only used for testing.
     */
    protected PipelineTask getPipelineTask() {
        return pipelineTask;
    }
}
