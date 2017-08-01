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
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.cm.CelestialObjectCrud;
import gov.nasa.kepler.hibernate.cm.CustomTarget;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.Kic.Field;
import gov.nasa.kepler.hibernate.cm.KicOverride;
import gov.nasa.kepler.hibernate.cm.KicOverrideModel;
import gov.nasa.kepler.hibernate.cm.SkyGroupCrud;
import gov.nasa.kepler.pi.models.ModelOperations;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.util.List;
import java.util.Map;

import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;

/**
 * @author Miles Cote
 * 
 */
public class CelestialObjectOperationsTest extends JMockTest {

    private static final int KEPLER_ID = 1;
    private static final int CCD_MODULE = 2;
    private static final int CCD_OUTPUT = 3;
    private static final int SEASON = 4;
    private static final int SKY_GROUP_ID = 5;
    private static final int MIN_KEPLER_ID = 6;
    private static final int MAX_KEPLER_ID = 7;
    private static final float MIN_MAGNITUDE = 8.8F;
    private static final float MAX_MAGNITUDE = 9.9F;

    private List<Integer> keplerIds = ImmutableList.of(KEPLER_ID);

    private interface RetrieveCelestialObjectsMethod {
        public List<CelestialObject> retrieve(
            CelestialObjectOperations celestialObjectOperations);
    }

    private interface RetrieveCelestialObjectParametersListMethod {
        public List<CelestialObjectParameters> retrieve(
            CelestialObjectOperations celestialObjectOperations);
    }

    @Test
    public void testRetrieveCelestialObjectsForKeplerId() {
        RetrieveCelestialObjectsMethod retrieveCelestialObjectsMethod = new RetrieveCelestialObjectsMethod() {
            @Override
            public List<CelestialObject> retrieve(
                CelestialObjectOperations celestialObjectOperations) {
                CelestialObject celestialObject = celestialObjectOperations.retrieveCelestialObject(KEPLER_ID);

                List<CelestialObject> celestialObjects = ImmutableList.of(celestialObject);

                return celestialObjects;
            }
        };

        testRetrieveCelestialObjectInternal(retrieveCelestialObjectsMethod);
    }

    @Test
    public void testRetrieveCelestialObjectsForModuleOutputSeason() {
        RetrieveCelestialObjectsMethod retrieveCelestialObjectsMethod = new RetrieveCelestialObjectsMethod() {
            @Override
            public List<CelestialObject> retrieve(
                CelestialObjectOperations celestialObjectOperations) {
                return celestialObjectOperations.retrieveCelestialObjects(
                    CCD_MODULE, CCD_OUTPUT, SEASON);
            }
        };

        testRetrieveCelestialObjectInternal(retrieveCelestialObjectsMethod);
    }

    @Test
    public void testRetrieveCelestialObjectsForSkyGroupId() {
        RetrieveCelestialObjectsMethod retrieveCelestialObjectsMethod = new RetrieveCelestialObjectsMethod() {
            @Override
            public List<CelestialObject> retrieve(
                CelestialObjectOperations celestialObjectOperations) {
                return celestialObjectOperations.retrieveCelestialObjects(SKY_GROUP_ID);
            }
        };

        testRetrieveCelestialObjectInternal(retrieveCelestialObjectsMethod);
    }

    @Test
    public void testRetrieveCelestialObjectsForMinMaxKeplerId() {
        RetrieveCelestialObjectsMethod retrieveCelestialObjectsMethod = new RetrieveCelestialObjectsMethod() {
            @Override
            public List<CelestialObject> retrieve(
                CelestialObjectOperations celestialObjectOperations) {
                return celestialObjectOperations.retrieveCelestialObjects(
                    MIN_KEPLER_ID, MAX_KEPLER_ID);
            }
        };

        testRetrieveCelestialObjectInternal(retrieveCelestialObjectsMethod);
    }

    @Test
    public void testRetrieveCelestialObjectsForKeplerIds() {
        RetrieveCelestialObjectsMethod retrieveCelestialObjectsMethod = new RetrieveCelestialObjectsMethod() {
            @Override
            public List<CelestialObject> retrieve(
                CelestialObjectOperations celestialObjectOperations) {
                return celestialObjectOperations.retrieveCelestialObjects(keplerIds);
            }
        };

        testRetrieveCelestialObjectInternal(retrieveCelestialObjectsMethod);
    }

    @Test
    public void testRetrieveCelestialObjectsForKeplerIdsWithMultipleCruds() {
        int keplerId1 = 111;
        int keplerId2 = 222;

        List<Integer> keplerIds = ImmutableList.of(keplerId1, keplerId2);

        CelestialObject celestialObject1 = mock(CelestialObject.class,
            "celestialObject1");
        CelestialObject celestialObject2 = mock(CelestialObject.class,
            "celestialObject2");

        List<CelestialObject> celestialObjectsFromCrud1 = newArrayList(null,
            celestialObject2);

        List<CelestialObject> celestialObjectsFromCrud2 = newArrayList(
            celestialObject1, null);

        List<CelestialObject> celestialObjectsCombinedList = ImmutableList.of(
            celestialObject1, celestialObject2);

        KicOverrideModel kicOverrideModel = mock(KicOverrideModel.class);

        CelestialObjectCrud celestialObjectCrud1 = mock(
            CelestialObjectCrud.class, "celestialObjectCrud1");
        CelestialObjectCrud celestialObjectCrud2 = mock(
            CelestialObjectCrud.class, "celestialObjectCrud2");

        List<CelestialObjectCrud> celestialObjectCruds = ImmutableList.of(
            celestialObjectCrud1, celestialObjectCrud2);

        @SuppressWarnings("unchecked")
        ModelOperations<KicOverrideModel> modelOperations = mock(ModelOperations.class);
        CelestialObjectUpdater celestialObjectUpdater = mock(CelestialObjectUpdater.class);
        CelestialObjectParametersListFactory celestialObjectParametersListFactory = mock(CelestialObjectParametersListFactory.class);
        SkyGroupCrud skyGroupCrud = mock(SkyGroupCrud.class);
        CelestialObjectMagnitudeFilter celestialObjectMagnitudeFilter = mock(CelestialObjectMagnitudeFilter.class);

        allowing(celestialObjectCrud1).retrieve(keplerIds);
        will(returnValue(celestialObjectsFromCrud1));

        allowing(celestialObjectCrud2).retrieve(keplerIds);
        will(returnValue(celestialObjectsFromCrud2));

        allowing(modelOperations).retrieveModel();
        will(returnValue(kicOverrideModel));

        allowing(celestialObjectUpdater).update(celestialObjectsCombinedList,
            kicOverrideModel);
        will(returnValue(celestialObjectsCombinedList));

        allowing(celestialObjectUpdater).update(celestialObjectsCombinedList,
            kicOverrideModel);
        will(returnValue(celestialObjectsCombinedList));

        allowing(skyGroupCrud).retrieveSkyGroupId(CCD_MODULE, CCD_OUTPUT,
            SEASON);
        will(returnValue(SKY_GROUP_ID));

        CelestialObjectOperations celestialObjectOperations = new CelestialObjectOperations(
            celestialObjectCruds, modelOperations, celestialObjectUpdater,
            celestialObjectParametersListFactory, skyGroupCrud,
            celestialObjectMagnitudeFilter);
        List<CelestialObject> actualCelestialObjects = celestialObjectOperations.retrieveCelestialObjects(keplerIds);

        List<CelestialObject> expectedCelestialObjects = ImmutableList.of(
            celestialObject1, celestialObject2);

        assertEquals(expectedCelestialObjects, actualCelestialObjects);
    }

    @Test
    public void testRetrieveCelestialObjectsForModuleOutputSeasonMinMaxMagnitude() {
        RetrieveCelestialObjectsMethod retrieveCelestialObjectsMethod = new RetrieveCelestialObjectsMethod() {
            @Override
            public List<CelestialObject> retrieve(
                CelestialObjectOperations celestialObjectOperations) {
                return celestialObjectOperations.retrieveCelestialObjects(
                    CCD_MODULE, CCD_OUTPUT, SEASON, MIN_MAGNITUDE,
                    MAX_MAGNITUDE);
            }
        };

        testRetrieveCelestialObjectInternal(retrieveCelestialObjectsMethod);
    }

    private void testRetrieveCelestialObjectInternal(
        RetrieveCelestialObjectsMethod retrieveCelestialObjectsMethod) {
        CelestialObject celestialObject = mock(CelestialObject.class);

        List<CelestialObject> celestialObjects = ImmutableList.of(celestialObject);

        KicOverride kicOverride = mock(KicOverride.class);

        List<KicOverride> kicOverrides = ImmutableList.of(kicOverride);

        KicOverrideModel kicOverrideModel = mock(KicOverrideModel.class);

        CelestialObjectCrud celestialObjectCrud = mock(CelestialObjectCrud.class);

        List<CelestialObjectCrud> celestialObjectCruds = ImmutableList.of(celestialObjectCrud);

        @SuppressWarnings("unchecked")
        ModelOperations<KicOverrideModel> modelOperations = mock(ModelOperations.class);
        CelestialObjectUpdater celestialObjectUpdater = mock(CelestialObjectUpdater.class);
        CelestialObjectParametersListFactory celestialObjectParametersListFactory = mock(CelestialObjectParametersListFactory.class);
        SkyGroupCrud skyGroupCrud = mock(SkyGroupCrud.class);
        CelestialObjectMagnitudeFilter celestialObjectMagnitudeFilter = mock(CelestialObjectMagnitudeFilter.class);

        allowing(celestialObjectCrud).retrieveForKeplerId(KEPLER_ID);
        will(returnValue(celestialObjects));

        allowing(celestialObjectCrud).retrieveForSkyGroupId(SKY_GROUP_ID);
        will(returnValue(celestialObjects));

        allowing(celestialObjectCrud).retrieve(MIN_KEPLER_ID, MAX_KEPLER_ID);
        will(returnValue(celestialObjects));

        allowing(celestialObjectCrud).retrieve(keplerIds);
        will(returnValue(celestialObjects));

        allowing(modelOperations).retrieveModel();
        will(returnValue(kicOverrideModel));

        allowing(celestialObjectUpdater).update(celestialObjects,
            kicOverrideModel);
        will(returnValue(celestialObjects));

        allowing(celestialObjectUpdater).update(celestialObjects,
            kicOverrideModel);
        will(returnValue(celestialObjects));

        allowing(skyGroupCrud).retrieveSkyGroupId(CCD_MODULE, CCD_OUTPUT,
            SEASON);
        will(returnValue(SKY_GROUP_ID));

        allowing(celestialObjectCrud).retrieve(SKY_GROUP_ID, MIN_MAGNITUDE,
            MAX_MAGNITUDE);
        will(returnValue(celestialObjects));

        allowing(celestialObjectMagnitudeFilter).filter(celestialObjects,
            MIN_MAGNITUDE, MAX_MAGNITUDE, SKY_GROUP_ID);
        will(returnValue(celestialObjects));

        allowing(kicOverrideModel).getKicOverrides();
        will(returnValue(kicOverrides));

        allowing(kicOverride).getField();
        will(returnValue(Field.KEPMAG));

        allowing(kicOverride).getValue();
        will(returnValue((double) MIN_MAGNITUDE));

        allowing(kicOverride).getKeplerId();
        will(returnValue(KEPLER_ID));

        CelestialObjectOperations celestialObjectOperations = new CelestialObjectOperations(
            celestialObjectCruds, modelOperations, celestialObjectUpdater,
            celestialObjectParametersListFactory, skyGroupCrud,
            celestialObjectMagnitudeFilter);
        List<CelestialObject> actualCelestialObjects = retrieveCelestialObjectsMethod.retrieve(celestialObjectOperations);

        assertEquals(celestialObjects, actualCelestialObjects);
    }

    @Test
    public void testRetrieveSkyGroupIdsForKeplerIds() {
        CelestialObjectCrud celestialObjectCrud = mock(CelestialObjectCrud.class);

        List<CelestialObjectCrud> celestialObjectCruds = ImmutableList.of(celestialObjectCrud);

        @SuppressWarnings("unchecked")
        ModelOperations<KicOverrideModel> modelOperations = mock(ModelOperations.class);
        CelestialObjectUpdater celestialObjectUpdater = mock(CelestialObjectUpdater.class);
        CelestialObjectParametersListFactory celestialObjectParametersListFactory = mock(CelestialObjectParametersListFactory.class);
        SkyGroupCrud skyGroupCrud = mock(SkyGroupCrud.class);
        CelestialObjectMagnitudeFilter celestialObjectMagnitudeFilter = mock(CelestialObjectMagnitudeFilter.class);

        Map<Integer, Integer> crudKeplerIdToSkyGroupId = ImmutableMap.of(
            KEPLER_ID, SKY_GROUP_ID);

        allowing(celestialObjectCrud).retrieveSkyGroupIdsForKeplerIds(keplerIds);
        will(returnValue(crudKeplerIdToSkyGroupId));

        CelestialObjectOperations celestialObjectOperations = new CelestialObjectOperations(
            celestialObjectCruds, modelOperations, celestialObjectUpdater,
            celestialObjectParametersListFactory, skyGroupCrud,
            celestialObjectMagnitudeFilter);
        Map<Integer, Integer> actualKeplerIdToSkyGroupId = celestialObjectOperations.retrieveSkyGroupIdsForKeplerIds(keplerIds);

        Map<Integer, Integer> expectedKeplerIdToSkyGroupId = ImmutableMap.of(
            KEPLER_ID, SKY_GROUP_ID);

        assertEquals(expectedKeplerIdToSkyGroupId, actualKeplerIdToSkyGroupId);
    }

    @Test
    public void testRetrieveCelestialObjectParametersListForKeplerId() {
        RetrieveCelestialObjectParametersListMethod retrieveCelestialObjectParametersListMethod = new RetrieveCelestialObjectParametersListMethod() {
            @Override
            public List<CelestialObjectParameters> retrieve(
                CelestialObjectOperations celestialObjectOperations) {
                CelestialObjectParameters celestialObjectParameters = celestialObjectOperations.retrieveCelestialObjectParameters(KEPLER_ID);

                List<CelestialObjectParameters> celestialObjectParametersList = ImmutableList.of(celestialObjectParameters);

                return celestialObjectParametersList;
            }
        };

        testRetrieveCelestialObjectParametersListInternal(retrieveCelestialObjectParametersListMethod);
    }

    @Test
    public void testRetrieveCelestialObjectParametersListForKeplerIds() {
        RetrieveCelestialObjectParametersListMethod retrieveCelestialObjectParametersListMethod = new RetrieveCelestialObjectParametersListMethod() {
            @Override
            public List<CelestialObjectParameters> retrieve(
                CelestialObjectOperations celestialObjectOperations) {
                return celestialObjectOperations.retrieveCelestialObjectParameters(keplerIds);
            }
        };

        testRetrieveCelestialObjectParametersListInternal(retrieveCelestialObjectParametersListMethod);
    }

    @Test
    public void testRetrieveCelestialObjectParametersListForMinMaxKeplerId() {
        RetrieveCelestialObjectParametersListMethod retrieveCelestialObjectParametersListMethod = new RetrieveCelestialObjectParametersListMethod() {
            @Override
            public List<CelestialObjectParameters> retrieve(
                CelestialObjectOperations celestialObjectOperations) {
                return celestialObjectOperations.retrieveCelestialObjectParameters(
                    MIN_KEPLER_ID, MAX_KEPLER_ID);
            }
        };

        testRetrieveCelestialObjectParametersListInternal(retrieveCelestialObjectParametersListMethod);
    }

    @Test
    public void testRetrieveCelestialObjectParametersListForSkyGroupId() {
        RetrieveCelestialObjectParametersListMethod retrieveCelestialObjectParametersListMethod = new RetrieveCelestialObjectParametersListMethod() {
            @Override
            public List<CelestialObjectParameters> retrieve(
                CelestialObjectOperations celestialObjectOperations) {
                return celestialObjectOperations.retrieveCelestialObjectParametersForSkyGroupId(SKY_GROUP_ID);
            }
        };

        testRetrieveCelestialObjectParametersListInternal(retrieveCelestialObjectParametersListMethod);
    }

    @Test
    public void testRetrieveCelestialObjectParametersListForSkyGroupIdKeplerIdRange() {
        RetrieveCelestialObjectParametersListMethod retrieveCelestialObjectParametersListMethod = new RetrieveCelestialObjectParametersListMethod() {
            @Override
            public List<CelestialObjectParameters> retrieve(
                CelestialObjectOperations celestialObjectOperations) {
                return celestialObjectOperations.retrieveCelestialObjectParametersForSkyGroupIdKeplerIdRange(
                    SKY_GROUP_ID, MIN_KEPLER_ID, MAX_KEPLER_ID);
            }
        };

        testRetrieveCelestialObjectParametersListInternal(retrieveCelestialObjectParametersListMethod);
    }

    @Test
    public void testRetrieveCelestialObjectParametersForModuleOutputSeason() {
        RetrieveCelestialObjectParametersListMethod retrieveCelestialObjectParmetersListMethod = new RetrieveCelestialObjectParametersListMethod() {
            @Override
            public List<CelestialObjectParameters> retrieve(
                CelestialObjectOperations celestialObjectOperations) {
                return celestialObjectOperations.retrieveCelestialObjectParameters(
                    CCD_MODULE, CCD_OUTPUT, SEASON);
            }
        };

        testRetrieveCelestialObjectParametersListInternal(retrieveCelestialObjectParmetersListMethod);
    }

    @Test
    public void testRetrieveCelestialObjectParametersForModuleOutputSeasonMinMaxMagnitude() {
        RetrieveCelestialObjectParametersListMethod retrieveCelestialObjectParmetersListMethod = new RetrieveCelestialObjectParametersListMethod() {
            @Override
            public List<CelestialObjectParameters> retrieve(
                CelestialObjectOperations celestialObjectOperations) {
                return celestialObjectOperations.retrieveCelestialObjectParameters(
                    CCD_MODULE, CCD_OUTPUT, SEASON, MIN_MAGNITUDE,
                    MAX_MAGNITUDE);
            }
        };

        testRetrieveCelestialObjectParametersListInternal(retrieveCelestialObjectParmetersListMethod);
    }

    private void testRetrieveCelestialObjectParametersListInternal(
        RetrieveCelestialObjectParametersListMethod retrieveCelestialObjectParametersListMethod) {
        CelestialObjectParameters celestialObjectParameters = mock(CelestialObjectParameters.class);
        List<CelestialObjectParameters> celestialObjectParametersList = ImmutableList.of(celestialObjectParameters);

        CelestialObject celestialObject = mock(CelestialObject.class);

        List<CelestialObject> celestialObjects = ImmutableList.of(celestialObject);

        KicOverride kicOverride = mock(KicOverride.class);

        List<KicOverride> kicOverrides = ImmutableList.of(kicOverride);

        KicOverrideModel kicOverrideModel = mock(KicOverrideModel.class);

        CelestialObjectCrud celestialObjectCrud = mock(CelestialObjectCrud.class);

        List<CelestialObjectCrud> celestialObjectCruds = ImmutableList.of(celestialObjectCrud);

        @SuppressWarnings("unchecked")
        ModelOperations<KicOverrideModel> modelOperations = mock(ModelOperations.class);
        CelestialObjectUpdater celestialObjectUpdater = mock(CelestialObjectUpdater.class);
        CelestialObjectParametersListFactory celestialObjectParametersListFactory = mock(CelestialObjectParametersListFactory.class);
        SkyGroupCrud skyGroupCrud = mock(SkyGroupCrud.class);
        CelestialObjectMagnitudeFilter celestialObjectMagnitudeFilter = mock(CelestialObjectMagnitudeFilter.class);

        allowing(celestialObjectParametersListFactory).create(
            celestialObjects, kicOverrideModel);
        will(returnValue(celestialObjectParametersList));

        allowing(celestialObjectCrud).retrieveForKeplerId(KEPLER_ID);
        will(returnValue(celestialObjects));

        allowing(celestialObjectCrud).retrieveForSkyGroupId(SKY_GROUP_ID);
        will(returnValue(celestialObjects));

        allowing(celestialObjectCrud).retrieve(SKY_GROUP_ID, MIN_KEPLER_ID,
            MAX_KEPLER_ID);
        will(returnValue(celestialObjects));

        allowing(celestialObjectCrud).retrieve(MIN_KEPLER_ID, MAX_KEPLER_ID);
        will(returnValue(celestialObjects));

        allowing(celestialObjectCrud).retrieve(keplerIds);
        will(returnValue(celestialObjects));

        allowing(modelOperations).retrieveModel();
        will(returnValue(kicOverrideModel));

        allowing(celestialObjectUpdater).update(celestialObjects,
            kicOverrideModel);
        will(returnValue(celestialObjects));

        allowing(celestialObjectUpdater).update(celestialObjects,
            kicOverrideModel);
        will(returnValue(celestialObjects));

        allowing(skyGroupCrud).retrieveSkyGroupId(CCD_MODULE, CCD_OUTPUT,
            SEASON);
        will(returnValue(SKY_GROUP_ID));

        allowing(celestialObjectCrud).retrieve(SKY_GROUP_ID, MIN_MAGNITUDE,
            MAX_MAGNITUDE);
        will(returnValue(celestialObjects));

        allowing(celestialObjectMagnitudeFilter).filter(celestialObjects,
            MIN_MAGNITUDE, MAX_MAGNITUDE, SKY_GROUP_ID);
        will(returnValue(celestialObjects));

        allowing(kicOverrideModel).getKicOverrides();
        will(returnValue(kicOverrides));

        allowing(kicOverride).getField();
        will(returnValue(Field.KEPMAG));

        allowing(kicOverride).getValue();
        will(returnValue((double) MIN_MAGNITUDE));

        allowing(kicOverride).getKeplerId();
        will(returnValue(KEPLER_ID));

        CelestialObjectOperations celestialObjectOperations = new CelestialObjectOperations(
            celestialObjectCruds, modelOperations, celestialObjectUpdater,
            celestialObjectParametersListFactory, skyGroupCrud,
            celestialObjectMagnitudeFilter);
        List<CelestialObjectParameters> actualCelestialObjectParametersList = retrieveCelestialObjectParametersListMethod.retrieve(celestialObjectOperations);

        assertEquals(celestialObjectParametersList,
            actualCelestialObjectParametersList);
    }

    @Test
    public void testToKeplerIdListDeprecated() {
        List<CelestialObject> celestialObjects = ImmutableList.of(
            new Kic.Builder(43, 0.0, 0.0).build(),
            new CustomTarget(
                TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START + 1, 0),
            new CustomTarget(
                TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START, 0),
            new Kic.Builder(42, 0.0, 0.0).build());

        List<Integer> keplerIds = CelestialObjectOperations.toKeplerIdListDeprecated(celestialObjects);
        assertEquals(4, keplerIds.size());
        assertEquals(43, keplerIds.get(0)
            .intValue());
        assertEquals(
            TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START + 1,
            keplerIds.get(1)
                .intValue());
        assertEquals(TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START,
            keplerIds.get(2)
                .intValue());
        assertEquals(42, keplerIds.get(3)
            .intValue());
    }

    @Test
    public void testToKeplerIdList() {
        int keplerId = 1;
        List<Integer> keplerIds = ImmutableList.of(keplerId);

        CelestialObjectParameters celestialObjectParameters = mock(CelestialObjectParameters.class);
        List<CelestialObjectParameters> celestialObjectParametersList = ImmutableList.of(celestialObjectParameters);

        allowing(celestialObjectParameters).getKeplerId();
        will(returnValue(keplerId));

        List<Integer> actualKeplerIds = CelestialObjectOperations.toKeplerIdList(celestialObjectParametersList);

        assertEquals(keplerIds, actualKeplerIds);
    }

}
