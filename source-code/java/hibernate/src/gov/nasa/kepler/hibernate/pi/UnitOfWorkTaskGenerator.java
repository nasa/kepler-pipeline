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

package gov.nasa.kepler.hibernate.pi;

import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.List;
import java.util.Map;

/**
 * Interface implemented by all UnitOfWorkTaskGenerators. Used by the pipeline
 * execution logic to generate tasks for pipline nodes.
 * 
 * Implementing classes should conform to the JavaBeans specification.
 * 
 * This class and subclasses are NOT Hibernate Pojos, but this class is here
 * because it is used to parameterize {@link BeanWrapper<T>} in
 * {@link PipelineDefinitionNode}
 * 
 * @author tklaus
 * 
 */
public interface UnitOfWorkTaskGenerator {

    /**
     * Identifies the type of task produced by this generator. Used by the PIG
     * to validate that the task type matches what the pipeline module expects
     * in order to prevent misconfigurations.
     * 
     * @return
     */
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType();

    /**
     * Should return the {@link Parameters} classes required by this task
     * generator, or and empty list if no {@link Parameters} classes are required.
     * 
     * Used by the PIG to prevent misconfigurations.
     * 
     * @return
     */
    public List<Class<? extends Parameters>> requiredParameterClasses();

    /**
     * Generate the task objects for this unit of work.
     * 
     * @param parameters
     * @return
     * @throws PipelineException
     */
    public List<? extends UnitOfWorkTask> generateTasks(Map<Class<? extends Parameters>, Parameters> parameters);
    
    /**
     * Should return a short name of the task generator for display in the PIG
     * 
     * @return
     */
    public String toString();
}
