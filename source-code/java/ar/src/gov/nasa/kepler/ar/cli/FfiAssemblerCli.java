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

package gov.nasa.kepler.ar.cli;

import gov.nasa.kepler.ar.archive.ArchiveInputs;
import gov.nasa.kepler.ar.archive.ArchiveOutputs;
import gov.nasa.kepler.ar.archive.PipelineProcessExecutor;
import gov.nasa.kepler.ar.exporter.SipWcsParameters;
import gov.nasa.kepler.ar.exporter.ffi.FfiFragmentGenerator;
import gov.nasa.kepler.ar.exporter.ffi.FfiFragmentGeneratorModuleParameters;
import gov.nasa.kepler.ar.exporter.ffi.FfiFragmentGeneratorPipelineModule;
import gov.nasa.kepler.ar.exporter.ffi.FfiFragmentGeneratorSource;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.CalFfiModuleParameters;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.kepler.pi.module.MatlabMcrExecutable;
import gov.nasa.kepler.pi.module.io.MatlabBinFileUtils;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

/**
 * Runs the FFI assembler pipeline module from the command line.  This does not
 * store any results in the file store or database.
 * 
 * @author Sean McCauliff
 *
 */
public class FfiAssemblerCli implements PipelineProcessExecutor<ArchiveInputs, ArchiveOutputs> {

    private int exeSequenceNumber = 0;
    private final String ffiTimestamp;
    private final int ccdModule;
    private final int ccdOutput;
    
    
    
    public FfiAssemblerCli(String ffiTimestamp, int ccdModule, int ccdOutput) {
        super();
        this.ffiTimestamp = ffiTimestamp;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
    }


    private void exportFfiFragment() {
        FfiFragmentGeneratorPipelineModule ffiFragmentGeneratorPipelineModule = 
            new FfiFragmentGeneratorPipelineModule() {
            
            @Override
            protected void executeAlgorithm(PipelineTask pipelineTask,
                Persistable inputs, Persistable outputs) {
                exec((ArchiveOutputs) outputs, (ArchiveInputs) inputs);
            }
            
            @Override
            protected FfiFragmentGenerator ffiFragmentGenerator() {
                return new FfiFragmentGenerator() {
                    protected OutputStream fileStoreOutputStream(
                        FfiFragmentGeneratorSource source, FsId calId) throws IOException {
                        File outputFile  = new File(calId.name());
                        FileOutputStream fout = new FileOutputStream(outputFile);
                        return fout;
                    }
                };
            }
            
            @Override
            protected File allocateWorkingDir(PipelineTask pipelineTask) {
                return new File(".");
            }
        };
        
        
        final CalFfiModuleParameters calFfiModuleParameters = 
            new CalFfiModuleParameters(ffiTimestamp);
        final FfiFragmentGeneratorModuleParameters ffiFragmentGeneratorModuleParameters = 
            new FfiFragmentGeneratorModuleParameters();
        ffiFragmentGeneratorModuleParameters.setUseMotionPolynomials(true);
        final SipWcsParameters sipWcsParameters = new SipWcsParameters();
        sipWcsParameters.setRowStep(20);
        sipWcsParameters.setColStep(20);
        
        final UnitOfWorkTask modOutUowTask = new ModOutUowTask(ccdModule, ccdOutput);
        
        PipelineTask pipelineTask = new PipelineTask() {
            @SuppressWarnings("unchecked")
            @Override
            public <T extends Parameters> T getParameters(Class<T> parametersClass) {
                if (parametersClass == CalFfiModuleParameters.class) {
                    return (T) calFfiModuleParameters;
                } else if (parametersClass == FfiFragmentGeneratorModuleParameters.class) {
                    return (T) ffiFragmentGeneratorModuleParameters;
                } else if (parametersClass == SipWcsParameters.class) {
                    return (T) sipWcsParameters;
                } else {
                    throw new IllegalArgumentException(parametersClass.getSimpleName());
                }
            }
            
            @SuppressWarnings("unchecked")
            @Override
            public <T extends UnitOfWorkTask> T uowTaskInstance() {
                return (T) modOutUowTask;
            }
        };
        
        
        TransactionServiceFactory.getInstance().beginTransaction(true, false, true);
        try {
            ffiFragmentGeneratorPipelineModule.processTask(null, pipelineTask);
        } finally {
            TransactionServiceFactory.getInstance().rollbackTransactionIfActive();
        }
    }
    
    
    /**
     * This implementation might be replaced with something that the pipeline
     * already uses.
     */
    @Override
    public void exec(ArchiveOutputs aout, ArchiveInputs ain) {
        try {
            File taskWorkingDir = new File(".");
            String exeName = "ar";

            exeSequenceNumber++;

            MatlabBinFileUtils.clearStaleErrorState(taskWorkingDir, exeName,
                exeSequenceNumber);
            MatlabBinFileUtils.serializeInputsFile(ain, taskWorkingDir,
                exeName, exeSequenceNumber);

            MatlabMcrExecutable matlabExe = new MatlabMcrExecutable("ar",
                taskWorkingDir, 3000);
            matlabExe.execAlgorithm(exeSequenceNumber);

            MatlabBinFileUtils.deserializeOutputsFile(aout, taskWorkingDir,
                exeName, exeSequenceNumber);
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }
    
    public static void main(String[] argv) {
        String ffiTimestamp = "2014110010101";
        int ccdModule = 2;
        int ccdOutput = 1;
        
        FfiAssemblerCli assemblerCli = new FfiAssemblerCli(ffiTimestamp, ccdModule, ccdOutput);
        assemblerCli.exportFfiFragment();
    }

    
}
