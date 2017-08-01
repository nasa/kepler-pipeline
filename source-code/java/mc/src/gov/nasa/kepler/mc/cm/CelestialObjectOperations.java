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

package gov.nasa.kepler.mc.cm;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Lists.newArrayListWithCapacity;
import static com.google.common.collect.Maps.newHashMap;
import static com.google.common.collect.Sets.newLinkedHashSet;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.cm.CelestialObjectCrud;
import gov.nasa.kepler.hibernate.cm.CustomTargetCrud;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.KicOverride;
import gov.nasa.kepler.hibernate.cm.KicOverrideModel;
import gov.nasa.kepler.hibernate.cm.SkyGroupCrud;
import gov.nasa.kepler.hibernate.cm.Kic.Field;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetriever;
import gov.nasa.kepler.mc.pi.ModelOperationsFactory;
import gov.nasa.kepler.pi.models.ModelOperations;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Contains operations related to {@link CelestialObject}s.
 * 
 * @author Miles Cote
 */
public class CelestialObjectOperations {

    private final List<CelestialObjectCrud> celestialObjectCruds;
    private final ModelOperations<KicOverrideModel> modelOperations;
    private final CelestialObjectUpdater celestialObjectUpdater;
    private final CelestialObjectParametersListFactory celestialObjectParametersListFactory;
    private final SkyGroupCrud skyGroupCrud;
    private final CelestialObjectMagnitudeFilter celestialObjectMagnitudeFilter;

    public CelestialObjectOperations(
        ModelMetadataRetriever modelMetadataRetriever,
        boolean excludeCustomTargets) {
        this(
            new ArrayList<CelestialObjectCrud>(),
            ModelOperationsFactory.getKicOverrideInstance(modelMetadataRetriever),
            new CelestialObjectUpdater(),
            new CelestialObjectParametersListFactory(), new KicCrud(),
            new CelestialObjectMagnitudeFilter());

        celestialObjectCruds.add(new KicCrud());
        if (!excludeCustomTargets) {
            celestialObjectCruds.add(new CustomTargetCrud());
        }
    }

    CelestialObjectOperations(
        List<CelestialObjectCrud> celestialObjectCruds,
        ModelOperations<KicOverrideModel> modelOperations,
        CelestialObjectUpdater celestialObjectUpdater,
        CelestialObjectParametersListFactory celestialObjectParametersListFactory,
        SkyGroupCrud skyGroupCrud,
        CelestialObjectMagnitudeFilter celestialObjectMagnitudeFilter) {
        this.celestialObjectCruds = celestialObjectCruds;
        this.modelOperations = modelOperations;
        this.celestialObjectUpdater = celestialObjectUpdater;
        this.celestialObjectParametersListFactory = celestialObjectParametersListFactory;
        this.skyGroupCrud = skyGroupCrud;
        this.celestialObjectMagnitudeFilter = celestialObjectMagnitudeFilter;
    }

    /**
     * @return {@link CelestialObject} or {@code null} if there is no
     * {@link CelestialObject} for the given input.
     */
    public CelestialObject retrieveCelestialObject(int keplerId) {
        List<CelestialObject> originalCelestialObjects = newArrayList();
        for (CelestialObjectCrud celestialObjectCrud : celestialObjectCruds) {
            originalCelestialObjects.addAll(celestialObjectCrud.retrieveForKeplerId(keplerId));
        }

        KicOverrideModel kicOverrideModel = modelOperations.retrieveModel();

        List<CelestialObject> updatedCelestialObjects = celestialObjectUpdater.update(
            originalCelestialObjects, kicOverrideModel);

        CelestialObject celestialObject = null;
        if (!updatedCelestialObjects.isEmpty()) {
            celestialObject = updatedCelestialObjects.get(0);
        }

        return celestialObject;
    }

    /**
     * 
     * @param ccdModule
     * @param ccdOutput
     * @param observingSeason
     * @return A non-null list of CelestialObject that have parameters that have
     * been updated with the kic overrides.
     */
    public List<CelestialObject> retrieveCelestialObjects(int ccdModule,
        int ccdOutput, int observingSeason) {
        int skyGroupId = skyGroupCrud.retrieveSkyGroupId(ccdModule, ccdOutput,
            observingSeason);

        return retrieveCelestialObjects(skyGroupId);
    }

    /**
     * 
     * @param skyGroupId
     * @return A non-null list of CelestialObject that have parameters that have
     * been updated with the kic overrides.
     */
    public List<CelestialObject> retrieveCelestialObjects(int skyGroupId) {
        List<CelestialObject> originalCelestialObjects = newArrayList();
        for (CelestialObjectCrud celestialObjectCrud : celestialObjectCruds) {
            originalCelestialObjects.addAll(celestialObjectCrud.retrieveForSkyGroupId(skyGroupId));
        }

        KicOverrideModel kicOverrideModel = modelOperations.retrieveModel();

        List<CelestialObject> updatedCelestialObjects = celestialObjectUpdater.update(
            originalCelestialObjects, kicOverrideModel);

        return updatedCelestialObjects;
    }

    public List<CelestialObject> retrieveCelestialObjects(int minKeplerId,
        int maxKeplerId) {
        List<CelestialObject> originalCelestialObjects = newArrayList();
        for (CelestialObjectCrud celestialObjectCrud : celestialObjectCruds) {
            originalCelestialObjects.addAll(celestialObjectCrud.retrieve(
                minKeplerId, maxKeplerId));
        }

        KicOverrideModel kicOverrideModel = modelOperations.retrieveModel();

        List<CelestialObject> updatedCelestialObjects = celestialObjectUpdater.update(
            originalCelestialObjects, kicOverrideModel);

        return updatedCelestialObjects;
    }

    public List<CelestialObject> retrieveCelestialObjects(
        List<Integer> keplerIds) {
        List<CelestialObject> originalCelestialObjects = newArrayList();
        for (int i = 0; i < keplerIds.size(); i++) {
            originalCelestialObjects.add(null);
        }

        for (CelestialObjectCrud celestialObjectCrud : celestialObjectCruds) {
            List<CelestialObject> retrievedCelestialObjects = celestialObjectCrud.retrieve(keplerIds);
            if (retrievedCelestialObjects.size() != keplerIds.size()) {
                throw new IllegalStateException(
                    "The input keplerIds and the retrievedCelestialObjects must have the same size.");
            }

            for (int i = 0; i < keplerIds.size(); i++) {
                CelestialObject celestialObject = retrievedCelestialObjects.get(i);
                if (celestialObject != null) {
                    originalCelestialObjects.set(i, celestialObject);
                }
            }
        }

        KicOverrideModel kicOverrideModel = modelOperations.retrieveModel();

        List<CelestialObject> updatedCelestialObjects = celestialObjectUpdater.update(
            originalCelestialObjects, kicOverrideModel);

        return updatedCelestialObjects;
    }

    public List<CelestialObject> retrieveCelestialObjects(int ccdModule,
        int ccdOutput, int observingSeason, float minKeplerMag,
        float maxKeplerMag) {
        Set<CelestialObject> originalCelestialObjects = newLinkedHashSet();

        int skyGroupId = skyGroupCrud.retrieveSkyGroupId(ccdModule, ccdOutput,
            observingSeason);

        for (CelestialObjectCrud celestialObjectCrud : celestialObjectCruds) {
            originalCelestialObjects.addAll(celestialObjectCrud.retrieve(
                skyGroupId, minKeplerMag, maxKeplerMag));
        }

        KicOverrideModel kicOverrideModel = modelOperations.retrieveModel();

        List<Integer> keplerIdsFromKom = getKeplerIds(kicOverrideModel,
            minKeplerMag, maxKeplerMag);
        for (CelestialObjectCrud celestialObjectCrud : celestialObjectCruds) {
            originalCelestialObjects.addAll(celestialObjectCrud.retrieve(keplerIdsFromKom));
        }

        List<CelestialObject> originalCelestialObjectsList = newArrayList(originalCelestialObjects);

        List<CelestialObject> updatedCelestialObjects = celestialObjectUpdater.update(
            originalCelestialObjectsList, kicOverrideModel);

        updatedCelestialObjects = celestialObjectMagnitudeFilter.filter(
            updatedCelestialObjects, minKeplerMag, maxKeplerMag, skyGroupId);

        return updatedCelestialObjects;
    }

    private List<Integer> getKeplerIds(KicOverrideModel kicOverrideModel,
        float minKeplerMag, float maxKeplerMag) {
        List<Integer> keplerIds = newArrayList();
        if (kicOverrideModel != null) {
            for (KicOverride kicOverride : kicOverrideModel.getKicOverrides()) {
                if (kicOverride.getField()
                    .equals(Field.KEPMAG)) {
                    double keplerMag = kicOverride.getValue();
                    if (keplerMag >= minKeplerMag && keplerMag <= maxKeplerMag) {
                        keplerIds.add(kicOverride.getKeplerId());
                    }
                }
            }
        }

        return keplerIds;
    }

    public Map<Integer, Integer> retrieveSkyGroupIdsForKeplerIds(
        List<Integer> keplerIds) {
        Map<Integer, Integer> keplerIdToSkyGroupId = newHashMap();
        for (CelestialObjectCrud celestialObjectCrud : celestialObjectCruds) {
            keplerIdToSkyGroupId.putAll(celestialObjectCrud.retrieveSkyGroupIdsForKeplerIds(keplerIds));
        }

        return keplerIdToSkyGroupId;
    }

    /**
     * {@link Deprecated} use the {@link CelestialObjectParameters} version
     * instead.
     */
    public static List<Integer> toKeplerIdListDeprecated(
        List<CelestialObject> celestialObjects) {
        List<Integer> keplerIds = newArrayListWithCapacity(celestialObjects.size());
        for (CelestialObject celestialObject : celestialObjects) {
            keplerIds.add(celestialObject.getKeplerId());
        }

        return keplerIds;
    }

    /**
     * @return {@link CelestialObjectParameters} or {@code null} if there are no
     * {@link CelestialObjectParameters} for the given input.
     */
    public CelestialObjectParameters retrieveCelestialObjectParameters(
        int keplerId) {
        List<CelestialObject> originalCelestialObjects = newArrayList();
        for (CelestialObjectCrud celestialObjectCrud : celestialObjectCruds) {
            originalCelestialObjects.addAll(celestialObjectCrud.retrieveForKeplerId(keplerId));
        }

        KicOverrideModel kicOverrideModel = modelOperations.retrieveModel();

        List<CelestialObject> updatedCelestialObjects = celestialObjectUpdater.update(
            originalCelestialObjects, kicOverrideModel);

        List<CelestialObjectParameters> celestialObjectParametersList = celestialObjectParametersListFactory.create(
            updatedCelestialObjects, kicOverrideModel);

        CelestialObjectParameters celestialObjectParameters = null;
        if (!celestialObjectParametersList.isEmpty()) {
            celestialObjectParameters = celestialObjectParametersList.get(0);
        }

        return celestialObjectParameters;
    }

    // This method is here to allow the jmock tests that expect a List to
    // succeed.
    public List<CelestialObjectParameters> retrieveCelestialObjectParameters(
        List<Integer> keplerIds) {
        return retrieveCelestialObjectParameters((Collection<Integer>) keplerIds);
    }

    public List<CelestialObjectParameters> retrieveCelestialObjectParameters(
        Collection<Integer> keplerIds) {
        List<CelestialObject> originalCelestialObjects = newArrayList();
        for (int i = 0; i < keplerIds.size(); i++) {
            originalCelestialObjects.add(null);
        }

        for (CelestialObjectCrud celestialObjectCrud : celestialObjectCruds) {
            List<CelestialObject> retrievedCelestialObjects = celestialObjectCrud.retrieve(keplerIds);
            if (retrievedCelestialObjects.size() != keplerIds.size()) {
                throw new IllegalStateException(
                    "The input keplerIds and the retrievedCelestialObjects must have the same size.");
            }

            for (int i = 0; i < keplerIds.size(); i++) {
                CelestialObject celestialObject = retrievedCelestialObjects.get(i);
                if (celestialObject != null) {
                    originalCelestialObjects.set(i, celestialObject);
                }
            }
        }

        KicOverrideModel kicOverrideModel = modelOperations.retrieveModel();

        List<CelestialObject> updatedCelestialObjects = celestialObjectUpdater.update(
            originalCelestialObjects, kicOverrideModel);

        List<CelestialObjectParameters> celestialObjectParametersList = celestialObjectParametersListFactory.create(
            updatedCelestialObjects, kicOverrideModel);

        return celestialObjectParametersList;
    }

    public List<CelestialObjectParameters> retrieveCelestialObjectParameters(
        int minKeplerId, int maxKeplerId) {
        List<CelestialObject> originalCelestialObjects = newArrayList();
        for (CelestialObjectCrud celestialObjectCrud : celestialObjectCruds) {
            originalCelestialObjects.addAll(celestialObjectCrud.retrieve(
                minKeplerId, maxKeplerId));
        }

        KicOverrideModel kicOverrideModel = modelOperations.retrieveModel();

        List<CelestialObject> updatedCelestialObjects = celestialObjectUpdater.update(
            originalCelestialObjects, kicOverrideModel);

        List<CelestialObjectParameters> celestialObjectParametersList = celestialObjectParametersListFactory.create(
            updatedCelestialObjects, kicOverrideModel);

        return celestialObjectParametersList;
    }

    public List<CelestialObjectParameters> retrieveCelestialObjectParameters(
        int ccdModule, int ccdOutput, int observingSeason) {
        int skyGroupId = skyGroupCrud.retrieveSkyGroupId(ccdModule, ccdOutput,
            observingSeason);

        return retrieveCelestialObjectParametersForSkyGroupId(skyGroupId);
    }

    public List<CelestialObjectParameters> retrieveCelestialObjectParameters(
        int ccdModule, int ccdOutput, int observingSeason, float minKeplerMag,
        float maxKeplerMag) {
        Set<CelestialObject> originalCelestialObjects = newLinkedHashSet();

        int skyGroupId = skyGroupCrud.retrieveSkyGroupId(ccdModule, ccdOutput,
            observingSeason);

        for (CelestialObjectCrud celestialObjectCrud : celestialObjectCruds) {
            originalCelestialObjects.addAll(celestialObjectCrud.retrieve(
                skyGroupId, minKeplerMag, maxKeplerMag));
        }

        KicOverrideModel kicOverrideModel = modelOperations.retrieveModel();

        List<Integer> keplerIdsFromKom = getKeplerIds(kicOverrideModel,
            minKeplerMag, maxKeplerMag);
        for (CelestialObjectCrud celestialObjectCrud : celestialObjectCruds) {
            originalCelestialObjects.addAll(celestialObjectCrud.retrieve(keplerIdsFromKom));
        }

        List<CelestialObject> originalCelestialObjectsList = newArrayList(originalCelestialObjects);

        List<CelestialObject> updatedCelestialObjects = celestialObjectUpdater.update(
            originalCelestialObjectsList, kicOverrideModel);

        updatedCelestialObjects = celestialObjectMagnitudeFilter.filter(
            updatedCelestialObjects, minKeplerMag, maxKeplerMag, skyGroupId);

        List<CelestialObjectParameters> celestialObjectParametersList = celestialObjectParametersListFactory.create(
            updatedCelestialObjects, kicOverrideModel);

        return celestialObjectParametersList;
    }

    public List<CelestialObjectParameters> retrieveCelestialObjectParameters(
        Integer keplerId, float boundedBoxWidth) {

        List<CelestialObjectParameters> celestialObjectParametersList = new ArrayList<CelestialObjectParameters>();
        CelestialObjectParameters celestialObjectParameters = retrieveCelestialObjectParameters(keplerId);
        celestialObjectParametersList.add(celestialObjectParameters);

        KicCrud kicCrud = new KicCrud();
        List<Integer> nearbyKeplerIds = new ArrayList<Integer>();
        nearbyKeplerIds.addAll(kicCrud.retrieveNearbyKeplerIds(
            celestialObjectParameters.getKeplerId(),
            celestialObjectParameters.getSkyGroupId(),
            celestialObjectParameters.getRa()
                .getValue(), celestialObjectParameters.getDec()
                .getValue(), boundedBoxWidth));

        celestialObjectParametersList.addAll(retrieveCelestialObjectParameters(nearbyKeplerIds));

        return celestialObjectParametersList;
    }

    public Map<Integer, List<CelestialObjectParameters>> retrieveCelestialObjectParameters(
        List<Integer> keplerIds, float boundedBoxWidth) {

        Map<Integer, List<CelestialObjectParameters>> celestialObjectParametersListByKeplerId = new HashMap<Integer, List<CelestialObjectParameters>>(
            keplerIds.size());
        List<CelestialObjectParameters> celestialObjectParametersList = retrieveCelestialObjectParameters(keplerIds);

        KicCrud kicCrud = new KicCrud();
        for (CelestialObjectParameters celestialObjectParameters : celestialObjectParametersList) {
            List<Integer> nearbyKeplerIds = kicCrud.retrieveNearbyKeplerIds(
                celestialObjectParameters.getKeplerId(),
                celestialObjectParameters.getSkyGroupId(),
                celestialObjectParameters.getRa()
                    .getValue(), celestialObjectParameters.getDec()
                    .getValue(), boundedBoxWidth);
            List<CelestialObjectParameters> celestialObjectParametersSubList = new ArrayList<CelestialObjectParameters>(nearbyKeplerIds.size() + 1);
            celestialObjectParametersSubList.add(celestialObjectParameters);
            celestialObjectParametersSubList.addAll(retrieveCelestialObjectParameters(nearbyKeplerIds, celestialObjectParameters.getSkyGroupId()));
            celestialObjectParametersListByKeplerId.put(
                celestialObjectParameters.getKeplerId(),
                celestialObjectParametersSubList);
        }

        return celestialObjectParametersListByKeplerId;
    }

    private List<CelestialObjectParameters> retrieveCelestialObjectParameters(
        List<Integer> keplerIds, int skyGroupId) {
        List<CelestialObjectParameters> parametersListForSkyGroupId = retrieveCelestialObjectParametersForSkyGroupId(skyGroupId);

        List<CelestialObjectParameters> parametersList = new ArrayList<CelestialObjectParameters>();
        for (CelestialObjectParameters parameters : parametersListForSkyGroupId) {
            if (keplerIds.contains(parameters.getKeplerId())) {
                parametersList.add(parameters);
            }
        }
        
        return parametersList;
    }

    public List<CelestialObjectParameters> retrieveCelestialObjectParametersForSkyGroupId(
        int skyGroupId) {
        List<CelestialObject> originalCelestialObjects = newArrayList();
        for (CelestialObjectCrud celestialObjectCrud : celestialObjectCruds) {
            originalCelestialObjects.addAll(celestialObjectCrud.retrieveForSkyGroupId(skyGroupId));
        }

        KicOverrideModel kicOverrideModel = modelOperations.retrieveModel();

        List<CelestialObject> updatedCelestialObjects = celestialObjectUpdater.update(
            originalCelestialObjects, kicOverrideModel);

        List<CelestialObjectParameters> celestialObjectParametersList = celestialObjectParametersListFactory.create(
            updatedCelestialObjects, kicOverrideModel);

        return celestialObjectParametersList;
    }

    public List<CelestialObjectParameters> retrieveCelestialObjectParametersForSkyGroupIdKeplerIdRange(
        int skyGroupId, int minKeplerId, int maxKeplerId) {
        List<CelestialObject> originalCelestialObjects = newArrayList();
        for (CelestialObjectCrud celestialObjectCrud : celestialObjectCruds) {
            originalCelestialObjects.addAll(celestialObjectCrud.retrieve(
                skyGroupId, minKeplerId, maxKeplerId));
        }

        KicOverrideModel kicOverrideModel = modelOperations.retrieveModel();

        List<CelestialObject> updatedCelestialObjects = celestialObjectUpdater.update(
            originalCelestialObjects, kicOverrideModel);

        List<CelestialObjectParameters> celestialObjectParametersList = celestialObjectParametersListFactory.create(
            updatedCelestialObjects, kicOverrideModel);

        return celestialObjectParametersList;
    }

    public static List<Integer> toKeplerIdList(
        List<CelestialObjectParameters> celestialObjectParametersList) {
        List<Integer> keplerIds = newArrayListWithCapacity(celestialObjectParametersList.size());
        for (CelestialObjectParameters celestialObjectParameters : celestialObjectParametersList) {
            keplerIds.add(celestialObjectParameters.getKeplerId());
        }

        return keplerIds;
    }

    public List<Integer> retrieveKeplerIdsForSkyGroupIdKeplerIdRange(
        int skyGroupId, int minKeplerId, int maxKeplerId) {
        List<Integer> keplerIds = newArrayList();
        for (CelestialObjectCrud celestialObjectCrud : celestialObjectCruds) {
            keplerIds.addAll(celestialObjectCrud.retrieveKeplerIds(skyGroupId,
                minKeplerId, maxKeplerId));
        }

        return keplerIds;
    }

}