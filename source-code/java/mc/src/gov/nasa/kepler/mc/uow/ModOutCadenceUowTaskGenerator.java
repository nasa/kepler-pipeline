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

package gov.nasa.kepler.mc.uow;

import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTaskGenerator;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * {@link UnitOfWorkTaskGenerator} for the {@link ModOutCadenceUowTask}. Uses
 * {@link CadenceBinner} and {@link ModOutBinner}. Subdivides by cadence range
 * first, and module/output second.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * @author Miles Cote
 * 
 */
public class ModOutCadenceUowTaskGenerator implements UnitOfWorkTaskGenerator {

    private final ModOutUowTaskGenerator modOutUowTaskGenerator;
    private final CadenceUowTaskGenerator cadenceUowTaskGenerator;

    public ModOutCadenceUowTaskGenerator() {
        this.modOutUowTaskGenerator = new ModOutUowTaskGenerator();
        this.cadenceUowTaskGenerator = new CadenceUowTaskGenerator();
    }

    public ModOutCadenceUowTaskGenerator(
        ModOutUowTaskGenerator modOutUowTaskGenerator,
        CadenceUowTaskGenerator cadenceUowTaskGenerator) {
        this.modOutUowTaskGenerator = modOutUowTaskGenerator;
        this.cadenceUowTaskGenerator = cadenceUowTaskGenerator;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return ModOutCadenceUowTask.class;
    }

    public List<Class<? extends Parameters>> requiredParameterClasses() {
        List<Class<? extends Parameters>> list = new ArrayList<Class<? extends Parameters>>();
        list.addAll(modOutUowTaskGenerator.requiredParameterClasses());
        list.addAll(cadenceUowTaskGenerator.requiredParameterClasses());
        return list;
    }

    @Override
    public List<? extends UnitOfWorkTask> generateTasks(
        Map<Class<? extends Parameters>, Parameters> parameters) {
        List<ModOutCadenceUowTask> tasks = new ArrayList<ModOutCadenceUowTask>();
        tasks.add(new ModOutCadenceUowTask());

        List<ModOutCadenceUowTask> generatedTasks = modOutUowTaskGenerator.generateTasks(
            parameters,
            cadenceUowTaskGenerator.generateTasks(parameters, tasks));

        ModuleOutputListsParameters moduleOutputLists = (ModuleOutputListsParameters) parameters.get(ModuleOutputListsParameters.class);
        generatedTasks = new DeadChannelTrimmer().trim(generatedTasks,
            moduleOutputLists.toDeadChannelCadencePairs());

        return generatedTasks;
    }

    public String toString() {
        return modOutUowTaskGenerator.toString()
            + cadenceUowTaskGenerator.toString();
    }

}
