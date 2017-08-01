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

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.pi.SkyGroupIdListsParameters;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.TargetTableParameters;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

/**
 * 
 * @author Sean McCauliff
 * 
 */
@RunWith(JMock.class)
public class ObservedKeplerIdUowTaskGeneratorTest {

    private Mockery mockery;

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
    }

    @Test
    public void testObservedKeplerIdGenerator() {
        final int ttableDbId = 23424;
        final int CHUNK_SIZE = 128;
        final int NSKY_GROUP = 7;
        final int OBSERVING_SEASON = 8;
        final TargetTable ttable = new TargetTable(TargetType.LONG_CADENCE);
        ttable.testSetId(ttableDbId);
        ttable.setObservingSeason(OBSERVING_SEASON);

        final List<Integer> keplerIds = new ArrayList<Integer>();
        for (int i = 0; i <= CHUNK_SIZE * 2 * NSKY_GROUP; i++) {
            keplerIds.add(i + 1);
        }

        final TargetCrud targetCrud = mockery.mock(TargetCrud.class);
        mockery.checking(new Expectations() {
            {
                one(targetCrud).retrieveObservedKeplerIds(ttable);
                will(returnValue(keplerIds));
            }
        });

        final Map<Integer, Integer> keplerIdToSkyGroup = new HashMap<Integer, Integer>();
        for (Integer keplerId : keplerIds) {
            keplerIdToSkyGroup.put(keplerId, keplerId % NSKY_GROUP);
        }

        final List<SkyGroup> skyGroups = new ArrayList<SkyGroup>();
        for (int i = 0; i < NSKY_GROUP; i++) {
            SkyGroup skyGroup = new SkyGroup(i, i % 25, i % 4, OBSERVING_SEASON);
            skyGroups.add(skyGroup);
        }
        final KicCrud kicCrud = mockery.mock(KicCrud.class);
        final CelestialObjectOperations celestialObjectOperations = mockery.mock(CelestialObjectOperations.class);
        mockery.checking(new Expectations() {
            {
                atLeast(1).of(celestialObjectOperations)
                    .retrieveSkyGroupIdsForKeplerIds(keplerIds);
                will(returnValue(keplerIdToSkyGroup));
                one(kicCrud).retrieveAllSkyGroups();
                will(returnValue(skyGroups));
            }
        });

        ObservedKeplerIdUowTaskGenerator generator = new ObservedKeplerIdUowTaskGenerator() {
            @Override
            protected TargetTable targetTableForTargetTableId(long dbId) {
                if (dbId != ttableDbId) {
                    throw new IllegalArgumentException("Bad table id.");
                }
                return ttable;
            }
        };

        generator.setTargetCrud(targetCrud);
        generator.setKicCrud(kicCrud);
        generator.setCelestialObjectOperations(celestialObjectOperations);

        TargetTableParameters ttableParameters = new TargetTableParameters();
        ttableParameters.setTargetTableDbId(ttableDbId);
        ttableParameters.setChunkSize(CHUNK_SIZE);

        Map<Class<? extends Parameters>, Parameters> params = new HashMap<Class<? extends Parameters>, Parameters>();
        params.put(TargetTableParameters.class, ttableParameters);
        params.put(SkyGroupIdListsParameters.class,
            new SkyGroupIdListsParameters());

        @SuppressWarnings("unchecked")
        List<ObservedKeplerIdUowTask> tasks = (List<ObservedKeplerIdUowTask>) generator.generateTasks(params);
        assertEquals(3 * NSKY_GROUP, tasks.size());
    }

}
