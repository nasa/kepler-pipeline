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

import static com.google.common.collect.Maps.newHashMap;
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.pi.SkyGroupIdListsParameters;
import gov.nasa.kepler.hibernate.mc.ExternalTce;
import gov.nasa.kepler.hibernate.mc.ExternalTceModel;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.PlanetaryCandidatesChunkParameters;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.pi.models.ModelOperations;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.List;
import java.util.Map;

import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;

/**
 * 
 * @author Forrest Girouard
 */
public class ExternalTcesChunkUowTaskGeneratorTest extends JMockTest {

    private static final int SKY_GROUP_ID = 1;
    private static final int KEPLER_ID = 2;
    private static final int PLANET_NUMBER = 1;
    private static final float DURATION = 2.0F;
    private static final double EPOCH = 3.0;
    private static final float PERIOD = 4.0F;
    private static final float MAX_SES = 5.0F;
    private static final float MAX_MES = 6.0F;
    private static final int CHUNK_SIZE = 1;

    private PlanetaryCandidatesChunkUowTask planetaryCandidatesChunkUowTaskPrototype = new PlanetaryCandidatesChunkUowTask(
        0, KEPLER_ID, KEPLER_ID + 2);
    private List<PlanetaryCandidatesChunkUowTask> planetaryCandidatesChunkUowTaskPrototypes = ImmutableList.of(planetaryCandidatesChunkUowTaskPrototype);

    private PlanetaryCandidatesChunkUowTask planetaryCandidatesChunkUowTask1 = new PlanetaryCandidatesChunkUowTask(
        SKY_GROUP_ID, KEPLER_ID, KEPLER_ID);
    private PlanetaryCandidatesChunkUowTask planetaryCandidatesChunkUowTask2 = new PlanetaryCandidatesChunkUowTask(
        SKY_GROUP_ID + 1, KEPLER_ID + 1, KEPLER_ID + 2);
    private List<PlanetaryCandidatesChunkUowTask> planetaryCandidatesChunkUowTasks = ImmutableList.of(
        planetaryCandidatesChunkUowTask1, planetaryCandidatesChunkUowTask2);

    private PlanetaryCandidatesChunkUowTask planetaryCandidatesChunkUowTask3 = new PlanetaryCandidatesChunkUowTask(
        SKY_GROUP_ID + 1, KEPLER_ID + 1, KEPLER_ID + 1);
    private PlanetaryCandidatesChunkUowTask planetaryCandidatesChunkUowTask4 = new PlanetaryCandidatesChunkUowTask(
        SKY_GROUP_ID + 1, KEPLER_ID + 2, KEPLER_ID + 2);
    private List<PlanetaryCandidatesChunkUowTask> planetaryCandidatesChunkUowTasks2 = ImmutableList.of(
        planetaryCandidatesChunkUowTask1, planetaryCandidatesChunkUowTask3,
        planetaryCandidatesChunkUowTask4);

    private PlanetaryCandidatesChunkParameters planetaryCandidatesChunkParameters = mock(PlanetaryCandidatesChunkParameters.class);
    private SkyGroupIdListsParameters skyGroupIdListsParameters = mock(SkyGroupIdListsParameters.class);

    private Map<Class<? extends Parameters>, Parameters> parameters = newHashMap();

    private List<Integer> keplerIds = ImmutableList.of(KEPLER_ID,
        KEPLER_ID + 1, KEPLER_ID + 2);

    private Map<Integer, Integer> keplerIdToSkyGroupId = ImmutableMap.of(
        KEPLER_ID, SKY_GROUP_ID, KEPLER_ID + 1, SKY_GROUP_ID + 1,
        KEPLER_ID + 2, SKY_GROUP_ID + 1);

    private SkyGroupBinner skyGroupBinner = mock(SkyGroupBinner.class);
    private KeplerIdChunkBinner keplerIdChunkBinner = mock(KeplerIdChunkBinner.class);
    private CelestialObjectOperations celestialObjectOperations = mock(CelestialObjectOperations.class);

    ExternalTcesChunkUowTaskGenerator externalTcesChunkUowTaskGenerator = new ExternalTcesChunkUowTaskGenerator();

    @SuppressWarnings("unchecked")
    ModelOperations<ExternalTceModel> externalTceModelOperations = mock(ModelOperations.class);

    ExternalTce externalTce1 = new ExternalTce(KEPLER_ID, PLANET_NUMBER,
        DURATION, EPOCH, PERIOD, MAX_SES, MAX_MES);
    ExternalTce externalTce2 = new ExternalTce(KEPLER_ID, PLANET_NUMBER + 1,
        DURATION, EPOCH, PERIOD, MAX_SES, MAX_MES);
    ExternalTce externalTce3 = new ExternalTce(KEPLER_ID + 1, PLANET_NUMBER,
        DURATION, EPOCH, PERIOD, MAX_SES, MAX_MES);
    ExternalTce externalTce4 = new ExternalTce(KEPLER_ID + 2, PLANET_NUMBER,
        DURATION, EPOCH, PERIOD, MAX_SES, MAX_MES);
    List<ExternalTce> externalTcesList = ImmutableList.of(externalTce1,
        externalTce2, externalTce3, externalTce4);
    ExternalTceModel externalTceModel = new ExternalTceModel(
        ExternalTceModel.NULL_REVISION, externalTcesList);

    @Before
    public void setUp() {
        parameters.put(PlanetaryCandidatesChunkParameters.class,
            planetaryCandidatesChunkParameters);
        parameters.put(SkyGroupIdListsParameters.class,
            skyGroupIdListsParameters);

        externalTcesChunkUowTaskGenerator.setExternalTceModelOperations(externalTceModelOperations);
        externalTcesChunkUowTaskGenerator.setSkyGroupBinner(skyGroupBinner);
        externalTcesChunkUowTaskGenerator.setKeplerIdChunkBinner(keplerIdChunkBinner);
        externalTcesChunkUowTaskGenerator.setCelestialObjectOperations(celestialObjectOperations);
    }

    @Test
    public void testGenerateTasks() {
        allowing(externalTceModelOperations).retrieveModel();
        will(returnValue(externalTceModel));

        allowing(celestialObjectOperations).retrieveSkyGroupIdsForKeplerIds(
            keplerIds);
        will(returnValue(keplerIdToSkyGroupId));
        
        allowing(skyGroupIdListsParameters).included(1);
        will(returnValue(true));
        
        allowing(skyGroupIdListsParameters).included(2);
        will(returnValue(true));

        allowing(skyGroupBinner).subdivide(
            planetaryCandidatesChunkUowTaskPrototypes, keplerIds,
            keplerIdToSkyGroupId, skyGroupIdListsParameters);
        will(returnValue(planetaryCandidatesChunkUowTasks));

        allowing(planetaryCandidatesChunkParameters).getChunkSize();
        will(returnValue(CHUNK_SIZE));

        allowing(keplerIdChunkBinner).subdivide(
            planetaryCandidatesChunkUowTasks, CHUNK_SIZE, keplerIdToSkyGroupId);
        will(returnValue(planetaryCandidatesChunkUowTasks2));

        List<? extends UnitOfWorkTask> actualTasks = externalTcesChunkUowTaskGenerator.generateTasks(parameters);

        assertEquals(planetaryCandidatesChunkUowTasks2, actualTasks);
    }
}
