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

package gov.nasa.kepler.pi.module;

import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.PipelineException;

/**
 * Convenience class for modules that follow the standard pattern of a single MATLAB invocation.  
 * Subclasses don't have to override processTask(), instead they implement createInputs(), 
 * retrieveInputs(), storeOutputs(), etc.
 * 
 * @author tklaus
 * 
 */
public abstract class StandardMatlabPipelineModule extends MatlabPipelineModule {
    
    protected PipelineInstance pipelineInstance;
    protected PipelineTask pipelineTask;
    
    /**
     * Basic implementation of processTask() that assumes that the corresponding
     * MATLAB algorithm will be executed once per UOW.  For pipeline modules
     * that fit this pattern, sub-classes only need to implement the I/O methods
     * (createInputs(), retrieveInputs(), createOutputs(), storeOutputs())
     * 
     * Note that this method is final.  Pipeline modules that desire other behavior
     * should subclass {@link MatlabPipelineModule} or {@link PipelineModule}
     * directly.
     * 
     * @param taskId
     * @param unitOfWork
     * @param parameters
     * @throws PipelineException
     */
    @Override
    public final void processTask(PipelineInstance pipelineInstance, PipelineTask pipelineTask) {
        this.pipelineInstance = pipelineInstance;
        this.pipelineTask = pipelineTask;
        
        validate();
        
        Persistable inputs = createInputs();

        retrieveInputs(inputs);
        
        Persistable outputs = createOutputs();

        executeAlgorithm(pipelineTask, inputs, outputs);

        storeOutputs(outputs);
    }

    /**
     * Empty method stub that sub-classes can override to validate pipeline
     * parameters or the UOW prior to processing
     */
    protected void validate() throws PipelineException{
    }

    /**
     * Method to create the module-specific input object tree 
     * Sub-classes should override this method and simply return a new
     * instance of the module-specific input class
     *
     * @return
     * @throws PipelineException
     */
    protected abstract Persistable createInputs() throws PipelineException;

    /**
     * Method to retrieve the inputs for this module/UOW
     * Sub-classes should override this method and populate the object 
     * with data from the filestore and/or database.
     * 
     * It is not necessary to populate fields that represent module parameters,
     * these are filled in by StandardMatlabPipelineModule.processTask() using the ModuleParamConverter
     *    
     * @return
     * @throws PipelineException
     */
    protected abstract void retrieveInputs(Persistable inputs) throws PipelineException;

    /**
     * Factory method to construct the module-specific output object
     * Sub-classes should override this method and simply return a new
     * instance of the module-specific output class (it is not necessary
     * to initialize nested objects, this is done when the output data is
     * de-serialized)
     * 
     * @return
     * @throws PipelineException 
     */
    protected abstract Persistable createOutputs() throws PipelineException;

    /**
     * Method to store the outputs to the data store
     * Sub-classes should override this method and store all outputs
     * to the data store.
     * Make sure all outputs are associated with the pipeline task id (pipelineTask.getId())
     * 
     * @param outputs
     * @throws PipelineException
     */
    protected abstract void storeOutputs(Persistable outputs) throws PipelineException;
}
