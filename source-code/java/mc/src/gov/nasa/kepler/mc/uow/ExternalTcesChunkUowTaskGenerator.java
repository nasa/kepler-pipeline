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

import gov.nasa.kepler.common.pi.SkyGroupIdListsParameters;
import gov.nasa.kepler.hibernate.mc.ExternalTce;
import gov.nasa.kepler.hibernate.mc.ExternalTceModel;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTaskGenerator;
import gov.nasa.kepler.mc.ExternalTcesChunkParameters;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.pi.ModelOperationsFactory;
import gov.nasa.kepler.pi.models.ModelOperations;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ExternalTcesChunkUowTaskGenerator implements
    UnitOfWorkTaskGenerator {
    
    public ExternalTcesChunkUowTaskGenerator() {
    }
    
    ModelOperations<ExternalTceModel> externalTceModelOperations;
    private SkyGroupBinner skyGroupBinner = new SkyGroupBinner();
    private KeplerIdChunkBinner keplerIdChunkBinner = new KeplerIdChunkBinner();
    private CelestialObjectOperations celestialObjectOperations = new CelestialObjectOperations(
        new ModelMetadataRetrieverLatest(), false);

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return PlanetaryCandidatesChunkUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameterClasses() {
        List<Class<? extends Parameters>> requiredParams = new ArrayList<Class<? extends Parameters>>();
        requiredParams.add(ExternalTcesChunkParameters.class);
        requiredParams.add(SkyGroupIdListsParameters.class);
        
        return requiredParams;
    }

    @Override
    public List<? extends UnitOfWorkTask> generateTasks(
        Map<Class<? extends Parameters>, Parameters> parameters) {
        
        ExternalTcesChunkParameters externalTcesChunkParameters = (ExternalTcesChunkParameters) parameters.get(ExternalTcesChunkParameters.class);
        SkyGroupIdListsParameters skyGroupIdListsParameters = (SkyGroupIdListsParameters) parameters.get(SkyGroupIdListsParameters.class);

        List<KeplerIdChunkUowTask> tasks = new ArrayList<KeplerIdChunkUowTask>();
        ModelOperations<ExternalTceModel> modelOperations = getExternalTceModelOperations();
        ExternalTceModel externalTceModel = modelOperations.retrieveModel();

        Map<Integer, List<ExternalTce>> parsedModel = ExternalTceModel.parseModel(externalTceModel);
        List<Integer> keplerIds = new ArrayList<Integer>(parsedModel.keySet());

        if (keplerIds.isEmpty()) {
            return tasks;
        }
        
        int minKeplerId = Integer.MAX_VALUE;
        int maxKeplerId = Integer.MIN_VALUE;
        for (int keplerId : keplerIds) {
            if (keplerId < minKeplerId) {
                minKeplerId = keplerId;
            }
            if (keplerId > maxKeplerId) {
                maxKeplerId = keplerId;
            }
        }

        Map<Integer, Integer> keplerIdToSkyGroupMap = 
                celestialObjectOperations.retrieveSkyGroupIdsForKeplerIds(keplerIds);

        KeplerIdChunkUowTask prototypeTask =
                new PlanetaryCandidatesChunkUowTask(0, minKeplerId, maxKeplerId);

        tasks.add(prototypeTask);

        tasks = skyGroupBinner.subdivide(tasks, keplerIds,
            keplerIdToSkyGroupMap, skyGroupIdListsParameters);

        int chunkSize = externalTcesChunkParameters.getChunkSize();

        tasks = keplerIdChunkBinner.subdivide(tasks, chunkSize,
            keplerIdToSkyGroupMap);

        return tasks;
    }

    public void setCelestialObjectOperations(
        CelestialObjectOperations celestialObjectOperations) {
        this.celestialObjectOperations = celestialObjectOperations;
    }

    private ModelOperations<ExternalTceModel> getExternalTceModelOperations() {
        if (externalTceModelOperations == null) {
            externalTceModelOperations = ModelOperationsFactory.getExternalTceInstance(new ModelMetadataRetrieverLatest());
        }

        return externalTceModelOperations;
    }

    void setExternalTceModelOperations(
        ModelOperations<ExternalTceModel> externalTceModelOperations) {
        this.externalTceModelOperations = externalTceModelOperations;
    }

    public void setSkyGroupBinner(SkyGroupBinner skyGroupBinner) {
        this.skyGroupBinner = skyGroupBinner;
    }

    public void setKeplerIdChunkBinner(KeplerIdChunkBinner keplerIdChunkBinner) {
        this.keplerIdChunkBinner = keplerIdChunkBinner;
    }

    public String toString() {
        return "ExternalTcesChunk";
    }
    
    public static void main(String[] args) {
        ExternalTcesChunkUowTaskGenerator generator = new ExternalTcesChunkUowTaskGenerator();
        Map<Class<? extends Parameters>, Parameters> parameters = new HashMap<Class<? extends Parameters>, Parameters>();
        parameters.put(ExternalTcesChunkParameters.class, new ExternalTcesChunkParameters());
        SkyGroupIdListsParameters skyGroupIdLists = new SkyGroupIdListsParameters();
        skyGroupIdLists.setSkyGroupIdIncludeArray(new int[] { 67 });
        parameters.put(SkyGroupIdListsParameters.class, new SkyGroupIdListsParameters());
        
        List<? extends UnitOfWorkTask> tasks = generator.generateTasks(parameters);
        System.out.println("tasks.size() = " + tasks.size());
    }

}
