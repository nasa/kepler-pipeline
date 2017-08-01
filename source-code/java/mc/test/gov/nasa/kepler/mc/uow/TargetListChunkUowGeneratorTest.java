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
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;
import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.TargetListParameters;
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
 * @author Sean McCauliff
 * 
 */
@RunWith(JMock.class)
public class TargetListChunkUowGeneratorTest {

    private DatabaseService databaseService;
    private DdlInitializer ddlInitializer;

    private Mockery mockery;

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        databaseService = DatabaseServiceFactory.getInstance();
        ddlInitializer = databaseService.getDdlInitializer();
        ddlInitializer.initDB();

        mockery = new Mockery() {{
                setImposteriser(ClassImposteriser.INSTANCE);
            }
        };
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        if (databaseService != null) {
            databaseService.closeCurrentSession();
            ddlInitializer.cleanDB();
        }
    }

    @Test
    public void chunkTargetListTest() {
        databaseService.beginTransaction();

        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        TargetList targetList = new TargetList("test-list");
        targetList.setCategory("test-category");
        targetSelectionCrud.create(targetList);
        TargetList excludeList = new TargetList("exclude");
        excludeList.setCategory("test-exclude-category");
        targetSelectionCrud.create(excludeList);

        TargetTable ttable = new TargetTable(
            TargetTable.TargetType.LONG_CADENCE);
        ttable.setState(ExportTable.State.UPLINKED);

        TargetCrud targetCrud = new TargetCrud();
        targetCrud.createTargetTable(ttable);

        TargetListSet tlSet = new TargetListSet("tl-set");
        tlSet.getTargetLists().add(targetList);
        tlSet.getTargetLists().add(excludeList);
        tlSet.setTargetTable(ttable);
        tlSet.setState(ExportTable.State.UPLINKED);

        targetSelectionCrud.create(tlSet);

        List<PlannedTarget> targets = new ArrayList<PlannedTarget>();
        final List<Integer> expectedKeplerIds = new ArrayList<Integer>();
        final Map<Integer, Integer> keplerIdToSkyGroupMap = new HashMap<Integer, Integer>();
        for (int i = 0; i < 10; i++) {
            PlannedTarget pt = new PlannedTarget(i, 0);
            pt.setTargetList(targetList);
            targets.add(pt);
            expectedKeplerIds.add(i);
            keplerIdToSkyGroupMap.put(i, i % 2);
        }
        
        PlannedTarget excludeMe = new PlannedTarget(expectedKeplerIds.size() + 1, 0);
        excludeMe.setTargetList(excludeList);
        targets.add(excludeMe);

        final CelestialObjectOperations celestialObjectOperations = mockery.mock(CelestialObjectOperations.class);
        mockery.checking(new Expectations() {{
                exactly(2).of(celestialObjectOperations)
                    .retrieveSkyGroupIdsForKeplerIds(expectedKeplerIds);
                will(returnValue(keplerIdToSkyGroupMap));
            }
        });

        targetSelectionCrud.create(targets);

        databaseService.flush();
        databaseService.commitTransaction();

        TargetListChunkUowGenerator uowGenerator = new TargetListChunkUowGenerator();
        SkyGroupBinner skyGroupBinner = new SkyGroupBinner(
            celestialObjectOperations);
        uowGenerator.setSkyGroupBinner(skyGroupBinner);
        KeplerIdChunkBinner keplerIdChunkBinner = new KeplerIdChunkBinner(
            celestialObjectOperations);
        uowGenerator.setKeplerIdChunkBinner(keplerIdChunkBinner);
        TargetListParameters parameters = new TargetListParameters();
        parameters.setChunkSize(3);
        parameters.setTargetListNames(new String[] { "test-list" });
        parameters.setExcludeTargetListNames(new String[] { excludeList.getName()});

        Map<Class<? extends Parameters>, Parameters> parameterMap = new HashMap<Class<? extends Parameters>, Parameters>();
        parameterMap.put(TargetListParameters.class, parameters);
        parameterMap.put(SkyGroupIdListsParameters.class,
            new SkyGroupIdListsParameters());
        List<? extends UnitOfWorkTask> genericTasks = uowGenerator.generateTasks(parameterMap);

        List<TargetListChunkUowTask> tasks = new ArrayList<TargetListChunkUowTask>();
        for (UnitOfWorkTask generic : genericTasks) {
            tasks.add((TargetListChunkUowTask) generic);
        }

        assertEquals(4, tasks.size());
        assertEquals(0, tasks.get(0).getStartKeplerId());
        assertEquals(4, tasks.get(0).getEndKeplerId());
        assertEquals(6, tasks.get(1).getStartKeplerId());
        assertEquals(8, tasks.get(1).getEndKeplerId());
        assertEquals(1, tasks.get(2).getStartKeplerId());
        assertEquals(5, tasks.get(2).getEndKeplerId());
        assertEquals(7, tasks.get(3).getStartKeplerId());
        assertEquals(9, tasks.get(3).getEndKeplerId());
    }

}
