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

package gov.nasa.kepler.prf;

import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.persistable.BinaryPersistableInputStream;
import gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.*;


/**
 * Overrides the
 * {@link #executeAlgorithm(PipelineModuleDefinition, Persistable, Persistable)}
 * method and does not call the actual science algorithm.
 * 
 * @author Forrest Girouard (fgirouard)
 * 
 */
public class PrfPipelineModuleNullScience extends PrfPipelineModule {

    private final AbstractPrfPipelineModuleTest moduleTest;
    private boolean processTaskInternal;

    public PrfPipelineModuleNullScience(
        AbstractPrfPipelineModuleTest moduleTest, boolean processTaskInternal) {
        this.moduleTest = moduleTest;
        this.processTaskInternal = processTaskInternal;
    }

    public PrfPipelineModuleNullScience(AbstractPrfPipelineModuleTest moduleTest) {
        this(moduleTest, true);
    }

    @Override
    protected void processTask(TargetTableLog targetTableLog) {
        if (processTaskInternal) {
            super.processTask(targetTableLog);
        }
    }

    /**
     * Primarily copies the inputs to the outputs only creating data for fields
     * that are not present in the inputs.
     */
    @Override
    protected void executeAlgorithm(PipelineTask pipelineTask,
        Persistable inputs, Persistable outputs) {
        PrfInputs prfInputs = (PrfInputs) inputs;
        PrfOutputs prfOutputs = (PrfOutputs) outputs;
        try {
            File testFile = new File(getMatlabWorkingDir(), "test.ser");
            DataOutputStream dout = 
                new DataOutputStream(new BufferedOutputStream(new FileOutputStream(testFile)));
            
            BinaryPersistableOutputStream bpout = 
                new BinaryPersistableOutputStream(dout);
            bpout.save(prfInputs);
            dout.close();
            
            DataInputStream din = 
                new DataInputStream(new BufferedInputStream(new FileInputStream(testFile)));
            
            BinaryPersistableInputStream pin = new BinaryPersistableInputStream(din);
            PrfInputs inputCopy = new PrfInputs();
            pin.load(inputCopy);
            din.close();

            ReflectionEquals reflectionEquals = new ReflectionEquals();
            reflectionEquals.assertEquals(prfInputs, inputCopy);
            
            moduleTest.validate(prfInputs);
            moduleTest.createOutputs(prfInputs, prfOutputs);
            moduleTest.validate(prfOutputs);
        } catch (Exception ioe) {
            throw new PipelineException(ioe);
        }
    }
}
