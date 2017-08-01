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
import gov.nasa.kepler.cm.TargetListImporter;
import gov.nasa.kepler.cm.TargetListImporter.ProgressHandler;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;

import java.io.IOException;
import java.text.ParseException;
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
 * Tests the {@link TargetListImporterProxy} class.
 * 
 * @author Bill Wohler
 */
@RunWith(JMock.class)
public class TargetListImporterProxyTest {

    private DatabaseService databaseService;
    private TargetListImporter targetListImporter;
    private TargetListImporterProxy targetListImporterProxy;

    private final Mockery mockery = new JUnit4Mockery() {
        {
            setImposteriser(ClassImposteriser.INSTANCE);
        }
    };

    @Before
    public void setUp() {
        databaseService = mockery.mock(DatabaseService.class);
        ProxyTestHelper.createProxyAssertions(mockery, databaseService);
        targetListImporter = mockery.mock(TargetListImporter.class);
        targetListImporterProxy = new TargetListImporterProxy(databaseService,
            new TargetList("targetList"));
        targetListImporterProxy.setTargetListImporter(targetListImporter);
    }

    @Test
    public void provideCodeCoverageForDefaultConstructor() {
        ProxyTestHelper.dismissProxyAssertions(databaseService);
        new TargetListImporterProxy();
        new TargetListImporterProxy(new TargetList("targetList"));
    }

    @Test
    public void testSetProgressHandler() {
        ProxyTestHelper.dismissProxyAssertions(databaseService);

        final ProgressHandler progressHandler = new ProgressHandler() {
            @Override
            public void setProgress(float progress) {
            }
        };

        mockery.checking(new Expectations() {
            {
                one(targetListImporter).setProgressHandler(progressHandler);
            }
        });

        targetListImporterProxy.setProgressHandler(progressHandler);
    }

    @Test
    public void testGetCategory() {
        ProxyTestHelper.dismissProxyAssertions(databaseService);

        final String category = "category";

        mockery.checking(new Expectations() {
            {
                one(targetListImporter).getCategory();
                will(returnValue(category));
            }
        });

        assertEquals(category, targetListImporterProxy.getCategory());
    }

    @Test
    public void testExport() throws IOException, ParseException {
        final List<PlannedTarget> plannedTargets = Arrays.asList(new PlannedTarget[] { new PlannedTarget(
            42, 42) });

        final String targetListFile = "targetListFile";
        mockery.checking(new Expectations() {
            {
                one(targetListImporter).ingestTargetFile(targetListFile);
                will(returnValue(plannedTargets));
            }
        });

        assertEquals(plannedTargets,
            targetListImporterProxy.ingestTargetFile(targetListFile));
    }
}
