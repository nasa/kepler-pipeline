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

package gov.nasa.kepler.ui.proxy;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;

import java.util.Arrays;
import java.util.List;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.integration.junit4.JUnit4Mockery;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

/**
 * Tests the {@link TargetSelectionCrudProxy} class.
 * 
 * @author Bill Wohler
 */
@RunWith(JMock.class)
public class TargetSelectionCrudProxyTest {

    private DatabaseService databaseService;
    private TargetSelectionCrud targetSelectionCrud;
    private TargetSelectionCrudProxy targetSelectionCrudProxy;

    private final Mockery mockery = new JUnit4Mockery() {
        {
            setImposteriser(ClassImposteriser.INSTANCE);
        }
    };

    @Before
    public void setUp() {
        databaseService = mockery.mock(DatabaseService.class);
        ProxyTestHelper.createProxyAssertions(mockery, databaseService);
        targetSelectionCrud = mockery.mock(TargetSelectionCrud.class);
        targetSelectionCrudProxy = new TargetSelectionCrudProxy(databaseService);
        targetSelectionCrudProxy.setTargetSelectionCrud(targetSelectionCrud);
    }

    @Test
    public void provideCodeCoverageForDefaultConstructor() {
        ProxyTestHelper.dismissProxyAssertions(databaseService);
        new TargetSelectionCrudProxy();
    }

    @Test
    public void testCreateTargetList() {
        final TargetList targetList = new TargetList("foo");

        mockery.checking(new Expectations() {
            {
                one(targetSelectionCrud).create(targetList);
            }
        });

        targetSelectionCrudProxy.create(targetList);
    }

    @Test
    public void testRetrieveAllTargetLists() {
        final List<TargetList> targetLists = Arrays.asList(new TargetList[] { new TargetList(
            "foo") });

        mockery.checking(new Expectations() {
            {
                one(targetSelectionCrud).retrieveAllTargetLists();
                will(returnValue(targetLists));
            }
        });

        assertEquals(targetLists,
            targetSelectionCrudProxy.retrieveAllTargetLists());
    }

    @Test
    public void testDeleteTargetList() {
        final TargetList targetList = new TargetList("foo");

        mockery.checking(new Expectations() {
            {
                one(targetSelectionCrud).delete(targetList);
            }
        });

        targetSelectionCrudProxy.delete(targetList);
    }

    @Test
    public void testCreateCollectionOfPlannedTarget() {
        final List<PlannedTarget> plannedTargets = Arrays.asList(new PlannedTarget[] { new PlannedTarget(
            42, 42) });

        mockery.checking(new Expectations() {
            {
                one(targetSelectionCrud).create(plannedTargets);
            }
        });

        targetSelectionCrudProxy.create(plannedTargets);
    }

    @Test
    public void testRetrievePlannedTargets() {
        final TargetList targetList = new TargetList("foo");
        final List<PlannedTarget> plannedTargets = Arrays.asList(new PlannedTarget[] { new PlannedTarget(
            42, 42) });

        mockery.checking(new Expectations() {
            {
                one(targetSelectionCrud).retrievePlannedTargets(targetList);
                will(returnValue(plannedTargets));
            }
        });

        assertEquals(plannedTargets,
            targetSelectionCrudProxy.retrievePlannedTargets(targetList));
    }

    @Test
    public void testPlannedTargetCount() {
        final TargetList targetList = new TargetList("foo");
        final int count = 42;

        mockery.checking(new Expectations() {
            {
                one(targetSelectionCrud).plannedTargetCount(targetList);
                will(returnValue(count));
            }
        });

        assertEquals(count,
            targetSelectionCrudProxy.plannedTargetCount(targetList));
    }

    @Test
    public void testDeletePlannedTargets() {
        final TargetList targetList = new TargetList("foo");

        mockery.checking(new Expectations() {
            {
                one(targetSelectionCrud).deletePlannedTargets(targetList);
            }
        });

        targetSelectionCrudProxy.deletePlannedTargets(targetList);
    }

    @Test
    public void testCreateTargetListSet() {
        final TargetListSet targetListSet = new TargetListSet("foo");

        mockery.checking(new Expectations() {
            {
                one(targetSelectionCrud).create(targetListSet);
            }
        });

        targetSelectionCrudProxy.create(targetListSet);
    }

    @Test
    public void testRetrieveTargetListSets() {
        final List<TargetListSet> targetListSets = Arrays.asList(new TargetListSet[] { new TargetListSet(
            "foo") });
        final State lowState = State.UNLOCKED;
        final State highState = State.UPLINKED;

        mockery.checking(new Expectations() {
            {
                one(targetSelectionCrud).retrieveTargetListSets(lowState,
                    highState);
                will(returnValue(targetListSets));
            }
        });

        assertEquals(
            targetListSets,
            targetSelectionCrudProxy.retrieveTargetListSets(lowState, highState));
    }

    @Test
    public void testRetrieveAllTargetListSets() {
        final List<TargetListSet> targetListSets = Arrays.asList(new TargetListSet[] { new TargetListSet(
            "foo") });

        mockery.checking(new Expectations() {
            {
                one(targetSelectionCrud).retrieveAllTargetListSets();
                will(returnValue(targetListSets));
            }
        });

        assertEquals(targetListSets,
            targetSelectionCrudProxy.retrieveAllTargetListSets());
    }

    @Test
    public void testDeleteTargetListSet() {
        final TargetListSet targetListSet = new TargetListSet("foo");

        mockery.checking(new Expectations() {
            {
                one(targetSelectionCrud).delete(targetListSet);
            }
        });

        targetSelectionCrudProxy.delete(targetListSet);
    }
}
