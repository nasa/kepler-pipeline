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
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.cm.TargetSelectionOperations;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;

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
 * Tests the {@link TargetSelectionOperationsProxy} class.
 * 
 * @author Bill Wohler
 */
@RunWith(JMock.class)
public class TargetSelectionOperationsProxyTest {

    private DatabaseService databaseService;
    private TargetSelectionOperationsProxy targetSelectionOperationsProxy;
    private TargetSelectionOperations targetSelectionOperations;

    private final Mockery mockery = new JUnit4Mockery() {
        {
            setImposteriser(ClassImposteriser.INSTANCE);
        }
    };

    @Before
    public void setUp() {
        databaseService = mockery.mock(DatabaseService.class);
        ProxyTestHelper.createProxyAssertions(mockery, databaseService);
        targetSelectionOperations = mockery.mock(TargetSelectionOperations.class);
        targetSelectionOperationsProxy = new TargetSelectionOperationsProxy(
            databaseService);
        targetSelectionOperationsProxy.setTargetSelectionOperations(targetSelectionOperations);
    }

    @Test
    public void provideCodeCoverageForDefaultConstructor() {
        ProxyTestHelper.dismissProxyAssertions(databaseService);
        new TargetSelectionOperationsProxy();
    }

    @Test
    public void testUpdatePlannedTargets() {
        final TargetList targetList = new TargetList("foo");
        final List<PlannedTarget> plannedTargets = Arrays.asList(new PlannedTarget(
            42, 42));

        mockery.checking(new Expectations() {
            {
                one(targetSelectionOperations).updatePlannedTargets(targetList,
                    plannedTargets);
            }
        });

        // TODO KSOC-500: Verify returned values
        targetSelectionOperationsProxy.updatePlannedTargets(targetList,
            plannedTargets);
    }

    @Test
    public void testRetrieveAllVisibleKeplerSkyGroupIds() {
        final List<Object[]> visibleKeplerSkyGroupIds = Arrays.asList(new Object[][] {
            { 0, 0 }, { 1, 1 } });

        mockery.checking(new Expectations() {
            {
                one(targetSelectionOperations).retrieveAllVisibleKeplerSkyGroupIds();
                will(returnValue(visibleKeplerSkyGroupIds));
            }
        });

        assertEquals(
            visibleKeplerSkyGroupIds,
            targetSelectionOperationsProxy.retrieveAllVisibleKeplerSkyGroupIds());
    }

    @Test
    public void testExists() {
        final int keplerId = 0;

        mockery.checking(new Expectations() {
            {
                one(targetSelectionOperations).exists(keplerId);
                will(returnValue(true));
            }
        });

        assertTrue(targetSelectionOperationsProxy.exists(keplerId));
    }

    @Test
    public void testTargetToString() {
        final PlannedTarget plannedTarget = new PlannedTarget(0, 0);
        final String s = "";

        mockery.checking(new Expectations() {
            {
                one(targetSelectionOperations).targetToString(plannedTarget);
                will(returnValue(s));
            }
        });

        assertEquals(s,
            targetSelectionOperationsProxy.targetToString(plannedTarget));
    }

    @Test
    public void testSkyGroupIdForIntInt() {
        final int ccdModule = 0;
        final int ccdOutput = 0;
        final int skyGroupId = 0;

        mockery.checking(new Expectations() {
            {
                one(targetSelectionOperations).skyGroupIdFor(ccdModule,
                    ccdOutput);
                will(returnValue(skyGroupId));
            }
        });

        assertEquals(skyGroupId,
            targetSelectionOperationsProxy.skyGroupIdFor(ccdModule, ccdOutput));
    }

    @Test
    public void testSkyGroupIdForIntIntInt() {
        final int ccdModule = 0;
        final int ccdOutput = 0;
        final int season = 0;
        final int skyGroupId = 0;

        mockery.checking(new Expectations() {
            {
                one(targetSelectionOperations).skyGroupIdFor(ccdModule,
                    ccdOutput, season);
                will(returnValue(skyGroupId));
            }
        });

        assertEquals(skyGroupId, targetSelectionOperationsProxy.skyGroupIdFor(
            ccdModule, ccdOutput, season));
    }

    @Test
    public void testSkyGroupForInt() {
        final int skyGroupId = 0;
        final SkyGroup skyGroup = new SkyGroup(skyGroupId, 0, 0, 0);

        mockery.checking(new Expectations() {
            {
                one(targetSelectionOperations).skyGroupFor(skyGroupId);
                will(returnValue(skyGroup));
            }
        });

        assertEquals(skyGroup,
            targetSelectionOperationsProxy.skyGroupFor(skyGroupId));
    }

    @Test
    public void testSkyGroupForIntInt() {
        final int skyGroupId = 0;
        final int season = 0;
        final SkyGroup skyGroup = new SkyGroup(skyGroupId, 0, 0, season);

        mockery.checking(new Expectations() {
            {
                one(targetSelectionOperations).skyGroupFor(skyGroupId, season);
                will(returnValue(skyGroup));
            }
        });

        assertEquals(skyGroup,
            targetSelectionOperationsProxy.skyGroupFor(skyGroupId, season));
    }
}