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

import static com.google.common.collect.Maps.newHashMap;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTaskGenerator;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.List;
import java.util.Map;

public class ModOutCadenceUowTaskGeneratorDebugger {

    private static final String CONFIG_PATH = "/path/to/lab.properties";

    public static void main(String[] args) throws Exception {
        setUp();
        
        int[] channelIncludeArray = {};
        int[] channelExcludeArray = {};
        int[] deadChannelArray = { 5, 6, 7, 8 };
        int[] cadenceOfDeathArray = { 12935, 12935, 12935, 12935 };
        String cadenceType = CadenceType.LONG.getName();
        int startCadence = 1105; // q1 start cadence
        int endCadence = 43621; // q10 end cadence
        int numberOfBins = 1;
        int minimumBinSize = 820;
        boolean binByTargetTable = true;
        String[] excludeCadences = { "11891:11913", "34226:34236" }; 

        ModuleOutputListsParameters moduleOutputListsParameters = new ModuleOutputListsParameters();
        moduleOutputListsParameters.setChannelIncludeArray(channelIncludeArray);
        moduleOutputListsParameters.setChannelExcludeArray(channelExcludeArray);
        moduleOutputListsParameters.setDeadChannelArray(deadChannelArray);
        moduleOutputListsParameters.setCadenceOfDeathArray(cadenceOfDeathArray);

        CadenceTypePipelineParameters cadenceTypePipelineParameters = new CadenceTypePipelineParameters();
        cadenceTypePipelineParameters.setCadenceType(cadenceType);

        CadenceRangeParameters cadenceRangeParameters = new CadenceRangeParameters();
        cadenceRangeParameters.setStartCadence(startCadence);
        cadenceRangeParameters.setEndCadence(endCadence);
        cadenceRangeParameters.setNumberOfBins(numberOfBins);
        cadenceRangeParameters.setMinimumBinSize(minimumBinSize);
        cadenceRangeParameters.setBinByTargetTable(binByTargetTable);
        cadenceRangeParameters.setExcludeCadences(excludeCadences);

        Map<Class<? extends Parameters>, Parameters> parameters = newHashMap();
        parameters.put(ModuleOutputListsParameters.class,
            moduleOutputListsParameters);
        parameters.put(CadenceTypePipelineParameters.class,
            cadenceTypePipelineParameters);
        parameters.put(CadenceRangeParameters.class, cadenceRangeParameters);

        ModOutCadenceUowTaskGenerator modOutCadenceUowTaskGenerator = new ModOutCadenceUowTaskGenerator();
        @SuppressWarnings("unchecked")
        List<ModOutCadenceUowTask> tasks = (List<ModOutCadenceUowTask>) modOutCadenceUowTaskGenerator.generateTasks(parameters);

        for (ModOutCadenceUowTask task : tasks) {
            System.out.println(task + "\tcadenceCount: "
                + (task.getEndCadence() - task.getStartCadence() + 1));
        }
    }

    private static void setUp() {
        System.setProperty(
            ConfigurationServiceFactory.CONFIG_SERVICE_PROPERTIES_PATH_PROP,
            CONFIG_PATH);
    }

}
