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
import gov.nasa.kepler.hibernate.PlanetaryCandidatesFilter;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.mc.ExternalTce;
import gov.nasa.kepler.hibernate.mc.ExternalTceModel;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTaskGenerator;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.hibernate.tps.TpsDbResult;
import gov.nasa.kepler.mc.PlanetaryCandidatesChunkParameters;
import gov.nasa.kepler.mc.PlanetaryCandidatesFilterImpl;
import gov.nasa.kepler.mc.PlanetaryCandidatesFilterParameters;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.dv.DvModuleParameters;
import gov.nasa.kepler.mc.pi.ModelOperationsFactory;
import gov.nasa.kepler.pi.models.ModelOperations;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

/**
 * This is the {@link UnitOfWorkTaskGenerator} for the DV {@link PipelineModule}
 * . This class will retrieve {@link TpsDbResult} objects that are candidates,
 * subdivide by {@link SkyGroup}, and then subdivide by
 * {@link PlanetaryCandidatesChunkParameters} chunk size.
 * 
 * @author Miles Cote
 * @author tklaus
 * 
 */
public class PlanetaryCandidatesChunkUowTaskGenerator implements
    UnitOfWorkTaskGenerator {

    private static final Log log = LogFactory.getLog(PlanetaryCandidatesChunkUowTaskGenerator.class);

    private TpsCrud tpsCrud = new TpsCrud();
    private SkyGroupBinner skyGroupBinner = new SkyGroupBinner();
    private KeplerIdChunkBinner keplerIdChunkBinner = new KeplerIdChunkBinner();
    private CelestialObjectOperations celestialObjectOperations = new CelestialObjectOperations(
        new ModelMetadataRetrieverLatest(), false);
    private ModelOperations<ExternalTceModel> externalTceModelOperations;

    public PlanetaryCandidatesChunkUowTaskGenerator() {
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return PlanetaryCandidatesChunkUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameterClasses() {
        List<Class<? extends Parameters>> requiredParams = new ArrayList<Class<? extends Parameters>>();
        requiredParams.add(PlanetaryCandidatesChunkParameters.class);
        requiredParams.add(PlanetaryCandidatesFilterParameters.class);
        requiredParams.add(SkyGroupIdListsParameters.class);
        requiredParams.add(DvModuleParameters.class);
        return requiredParams;
    }

    @Override
    public List<? extends UnitOfWorkTask> generateTasks(
        Map<Class<? extends Parameters>, Parameters> parameters) {
        PlanetaryCandidatesChunkParameters planetaryCandidatesChunkParameters = (PlanetaryCandidatesChunkParameters) parameters.get(PlanetaryCandidatesChunkParameters.class);
        PlanetaryCandidatesFilterParameters planetaryCandidatesFilterParameters = (PlanetaryCandidatesFilterParameters) parameters.get(PlanetaryCandidatesFilterParameters.class);
        SkyGroupIdListsParameters skyGroupIdListsParameters = (SkyGroupIdListsParameters) parameters.get(SkyGroupIdListsParameters.class);

        PlanetaryCandidatesFilter planetaryCandidatesFilter = new PlanetaryCandidatesFilterImpl(
            planetaryCandidatesFilterParameters);

        List<KeplerIdChunkUowTask> tasks = new ArrayList<KeplerIdChunkUowTask>();

        Set<Integer> tceKeplerIds;
        if (((DvModuleParameters) parameters.get(DvModuleParameters.class)).isExternalTcesEnabled()) {
            tceKeplerIds = retrieveExternalTces(planetaryCandidatesFilter);
        } else {
            tceKeplerIds = retrieveTpsResults(planetaryCandidatesFilter);
        }

        if (tceKeplerIds.isEmpty()) {
            return tasks;
        }


        int minKeplerId = Integer.MAX_VALUE;
        int maxKeplerId = Integer.MIN_VALUE;
        for (int keplerId : tceKeplerIds) {
            if (keplerId < minKeplerId) {
                minKeplerId = keplerId;
            }
            if (keplerId > maxKeplerId) {
                maxKeplerId = keplerId;
            }
        }

        //Probably should have made more of these use Collection<T> rather than List<T>
        List<Integer> tceKeplerIdsList = Lists.newArrayListWithCapacity(tceKeplerIds.size());
        for (Integer keplerId : tceKeplerIds) {
            tceKeplerIdsList.add(keplerId);
        }
        final Map<Integer, Integer> keplerIdToSkyGroupMap = 
            celestialObjectOperations.retrieveSkyGroupIdsForKeplerIds(tceKeplerIdsList);

        KeplerIdChunkUowTask prototypeTask = new PlanetaryCandidatesChunkUowTask(
            0, minKeplerId, maxKeplerId);

        tasks.add(prototypeTask);

        tasks = skyGroupBinner.subdivide(tasks, tceKeplerIdsList,
            keplerIdToSkyGroupMap, skyGroupIdListsParameters);

        int chunkSize = planetaryCandidatesChunkParameters.getChunkSize();

        tasks = keplerIdChunkBinner.subdivide(tasks, chunkSize,
            keplerIdToSkyGroupMap);

        return tasks;
    }

    private Set<Integer> retrieveTpsResults(
        PlanetaryCandidatesFilter planetaryCandidatesFilter) {

        log.info("Retrieving TPS results");

        // Get the list of Kepler IDs in the specified range.
        List<TpsDbResult> tpsDbResults = tpsCrud.retrieveLatestTpsResults(planetaryCandidatesFilter);
        if (tpsDbResults == null || tpsDbResults.isEmpty()) {
            throw new IllegalStateException("No TPS results available.");
        }

        Set<Integer> keplerIds = new HashSet<Integer>(tpsDbResults.size() * 2);
        for (TpsDbResult tpsDbResult : tpsDbResults) {
            keplerIds.add(tpsDbResult.getKeplerId());
        }
        return keplerIds;
    }

    private Set<Integer> retrieveExternalTces(
        PlanetaryCandidatesFilter planetaryCandidatesFilter) {

        log.info("Retrieving external TCEs");

        Set<Integer> tcesByKeplerId = Sets.newHashSet();

        // Get all the TCEs in the model independent of sky group and specified
        // kepler id range.
        ExternalTceModel externalTceModel = getExternalTceModelOperations().retrieveModel();
        for (ExternalTce externalTce : externalTceModel.getExternalTces()) {
            if (!planetaryCandidatesFilter.included(externalTce.getKeplerId())) {
                // Skip external TCEs that are explicitly excluded.
                continue;
            }
            tcesByKeplerId.add(externalTce.getKeplerId());
        }

        return tcesByKeplerId;
    }

    public void setCelestialObjectOperations(
        CelestialObjectOperations celestialObjectOperations) {
        this.celestialObjectOperations = celestialObjectOperations;
    }

    /**
     * This method is only needed for testing.
     */
    void setExternalTceModelOperations(
        ModelOperations<ExternalTceModel> externalTceModelOperations) {
        this.externalTceModelOperations = externalTceModelOperations;
    }

    private ModelOperations<ExternalTceModel> getExternalTceModelOperations() {
        if (externalTceModelOperations == null) {
            externalTceModelOperations = ModelOperationsFactory.getExternalTceInstance(new ModelMetadataRetrieverLatest());
        }

        return externalTceModelOperations;
    }

    void setTpsCrud(TpsCrud tpsCrud) {
        this.tpsCrud = tpsCrud;
    }

    public void setSkyGroupBinner(SkyGroupBinner skyGroupBinner) {
        this.skyGroupBinner = skyGroupBinner;
    }

    public void setKeplerIdChunkBinner(KeplerIdChunkBinner keplerIdChunkBinner) {
        this.keplerIdChunkBinner = keplerIdChunkBinner;
    }

    @Override
    public String toString() {
        return "PlanetaryCandidatesChunk";
    }

}
