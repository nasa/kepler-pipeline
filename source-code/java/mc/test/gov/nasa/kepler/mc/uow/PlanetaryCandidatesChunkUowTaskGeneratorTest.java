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
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.hibernate.tps.TpsDbResult;
import gov.nasa.kepler.mc.PlanetFitModuleParameters;
import gov.nasa.kepler.mc.PlanetaryCandidatesChunkParameters;
import gov.nasa.kepler.mc.PlanetaryCandidatesFilterImpl;
import gov.nasa.kepler.mc.PlanetaryCandidatesFilterParameters;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.dv.DvModuleParameters;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.List;
import java.util.Map;

import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;

/**
 * @author Miles Cote
 * 
 */
public class PlanetaryCandidatesChunkUowTaskGeneratorTest extends JMockTest {

    private static final int SKY_GROUP_ID = 1;
    private static final int KEPLER_ID = 2;
    private static final int CHUNK_SIZE = 5;
    private static final Float CHI_SQUARE_1 = 1.0F;
    private static final Float CHI_SQUARE_2 = 2.0F;
    private static final Integer CHI_SQUARE_DOF_1 = 3;
    private static final Integer CHI_SQUARE_DOF_2 = 4;
    private static final Double TIME_OF_FIRST_TRANSIT_IN_MJD = 5.0;
    private static final Float MAX_MULTIPLE_EVENT_STATISTIC = 6.0F;
    private static final Float MAX_SES_IN_MES = 7.0F;
    private static final Float MAX_SINGLE_EVENT_STATISTIC = 8.0F;
    private static final Double DETECTED_ORBITAL_PERIOD_IN_DAYS = 9.0;
    private static final Float ROBUST_STATISTIC = 10.0F;
    private static final float TRIAL_TRANSIT_PULSE_IN_HOURS = 11.0F;

    private PlanetaryCandidatesChunkUowTask planetaryCandidatesChunkUowTaskPrototype = new PlanetaryCandidatesChunkUowTask(
        0, KEPLER_ID, KEPLER_ID);
    private List<PlanetaryCandidatesChunkUowTask> planetaryCandidatesChunkUowTaskPrototypes = ImmutableList.of(planetaryCandidatesChunkUowTaskPrototype);

    private PlanetaryCandidatesChunkUowTask planetaryCandidatesChunkUowTask = new PlanetaryCandidatesChunkUowTask(
        SKY_GROUP_ID, KEPLER_ID, KEPLER_ID);
    private List<PlanetaryCandidatesChunkUowTask> planetaryCandidatesChunkUowTasks = ImmutableList.of(planetaryCandidatesChunkUowTask);

    private PlanetaryCandidatesChunkParameters planetaryCandidatesChunkParameters = mock(PlanetaryCandidatesChunkParameters.class);
    private PlanetaryCandidatesFilterParameters planetaryCandidatesFilterParameters = mock(PlanetaryCandidatesFilterParameters.class);
    private PlanetFitModuleParameters planetFitModuleParameters = mock(PlanetFitModuleParameters.class);
    private SkyGroupIdListsParameters skyGroupIdListsParameters = mock(SkyGroupIdListsParameters.class);
    private DvModuleParameters dvModuleParameters = mock(DvModuleParameters.class);

    private Map<Class<? extends Parameters>, Parameters> parameters = newHashMap();

    private TpsDbResult tpsDbResult = mock(TpsDbResult.class);
    private List<TpsDbResult> tpsDbResults = ImmutableList.of(tpsDbResult);

    private List<Integer> keplerIds = ImmutableList.of(KEPLER_ID);

    private Map<Integer, Integer> keplerIdToSkyGroupId = ImmutableMap.of(
        KEPLER_ID, SKY_GROUP_ID);

    private TpsCrud tpsCrud = mock(TpsCrud.class);
    private SkyGroupBinner skyGroupBinner = mock(SkyGroupBinner.class);
    private KeplerIdChunkBinner keplerIdChunkBinner = mock(KeplerIdChunkBinner.class);
    private CelestialObjectOperations celestialObjectOperations = mock(CelestialObjectOperations.class);

    private PlanetaryCandidatesChunkUowTaskGenerator planetaryCandidatesChunkUowTaskGenerator = new PlanetaryCandidatesChunkUowTaskGenerator();

    @Before
    public void setUp() {
        parameters.put(PlanetaryCandidatesChunkParameters.class,
            planetaryCandidatesChunkParameters);
        parameters.put(PlanetaryCandidatesFilterParameters.class,
            planetaryCandidatesFilterParameters);
        parameters.put(PlanetFitModuleParameters.class,
            planetFitModuleParameters);
        parameters.put(SkyGroupIdListsParameters.class,
            skyGroupIdListsParameters);
        parameters.put(DvModuleParameters.class, 
            dvModuleParameters);

        planetaryCandidatesChunkUowTaskGenerator.setTpsCrud(tpsCrud);
        planetaryCandidatesChunkUowTaskGenerator.setSkyGroupBinner(skyGroupBinner);
        planetaryCandidatesChunkUowTaskGenerator.setKeplerIdChunkBinner(keplerIdChunkBinner);
        planetaryCandidatesChunkUowTaskGenerator.setCelestialObjectOperations(celestialObjectOperations);
    }

    @Test
    public void testGenerateTasks() {
        allowing(tpsCrud).retrieveLatestTpsResults(
            new PlanetaryCandidatesFilterImpl(planetaryCandidatesFilterParameters));
        will(returnValue(tpsDbResults));

        allowing(tpsDbResult).getKeplerId();
        will(returnValue(KEPLER_ID));
        allowing(tpsDbResult).getChiSquare1();
        will(returnValue(CHI_SQUARE_1));
        allowing(tpsDbResult).getChiSquare2();
        will(returnValue(CHI_SQUARE_2));
        allowing(tpsDbResult).getChiSquareDof1();
        will(returnValue(CHI_SQUARE_DOF_1));
        allowing(tpsDbResult).getChiSquareDof2();
        will(returnValue(CHI_SQUARE_DOF_2));
        allowing(tpsDbResult).timeOfFirstTransitInMjd();
        will(returnValue(TIME_OF_FIRST_TRANSIT_IN_MJD));
        allowing(tpsDbResult).getMaxMultipleEventStatistic();
        will(returnValue(MAX_MULTIPLE_EVENT_STATISTIC));
        allowing(tpsDbResult).getMaxSesInMes();
        will(returnValue(MAX_SES_IN_MES));
        allowing(tpsDbResult).getMaxSingleEventStatistic();
        will(returnValue(MAX_SINGLE_EVENT_STATISTIC));
        allowing(tpsDbResult).getDetectedOrbitalPeriodInDays();
        will(returnValue(DETECTED_ORBITAL_PERIOD_IN_DAYS));
        allowing(tpsDbResult).getRobustStatistic();
        will(returnValue(ROBUST_STATISTIC));
        allowing(tpsDbResult).getTrialTransitPulseInHours();
        will(returnValue(TRIAL_TRANSIT_PULSE_IN_HOURS));

        allowing(celestialObjectOperations).retrieveSkyGroupIdsForKeplerIds(
            keplerIds);
        will(returnValue(keplerIdToSkyGroupId));

        allowing(skyGroupBinner).subdivide(
            planetaryCandidatesChunkUowTaskPrototypes, keplerIds,
            keplerIdToSkyGroupId, skyGroupIdListsParameters);
        will(returnValue(planetaryCandidatesChunkUowTasks));

        allowing(planetaryCandidatesChunkParameters).getChunkSize();
        will(returnValue(CHUNK_SIZE));

        allowing(keplerIdChunkBinner).subdivide(
            planetaryCandidatesChunkUowTasks, CHUNK_SIZE, keplerIdToSkyGroupId);
        will(returnValue(planetaryCandidatesChunkUowTasks));
        
        allowing(dvModuleParameters).isExternalTcesEnabled();
        will(returnValue(false));

        List<? extends UnitOfWorkTask> actualTasks = planetaryCandidatesChunkUowTaskGenerator.generateTasks(parameters);

        assertEquals(planetaryCandidatesChunkUowTasks, actualTasks);
    }

}
