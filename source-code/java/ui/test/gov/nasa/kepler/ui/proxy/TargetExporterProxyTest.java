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
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.tad.xml.TargetExporter;

import java.io.File;
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
 * Tests the {@link TargetExporterProxy} class.
 * 
 * @author Bill Wohler
 */
@RunWith(JMock.class)
public class TargetExporterProxyTest {

    private DatabaseService databaseService;
    private TargetExporter targetExporter;
    private TargetExporterProxy targetExporterProxy;

    private final Mockery mockery = new JUnit4Mockery() {
        {
            setImposteriser(ClassImposteriser.INSTANCE);
        }
    };

    @Before
    public void setUp() {
        databaseService = mockery.mock(DatabaseService.class);
        ProxyTestHelper.createProxyAssertions(mockery, databaseService);
        targetExporter = mockery.mock(TargetExporter.class);
        targetExporterProxy = new TargetExporterProxy(databaseService);
        targetExporterProxy.setTargetExporter(targetExporter);
    }

    @Test
    public void provideCodeCoverageForDefaultConstructor() {
        ProxyTestHelper.dismissProxyAssertions(databaseService);
        new TargetExporterProxy();
    }

    @Test
    public void testExport() {
        final List<File> files = Arrays.asList(new File[] { new File("foo") });

        final TargetTable lcTargetTable = new TargetTable(
            TargetType.LONG_CADENCE);
        final TargetTable bgTargetTable = new TargetTable(TargetType.BACKGROUND);
        final MaskTable targetMaskTable = new MaskTable(MaskType.TARGET);
        final MaskTable bgMaskTable = new MaskTable(MaskType.BACKGROUND);
        final TargetTable rpTargetTable = new TargetTable(
            TargetType.REFERENCE_PIXEL);
        final TargetTable sc1TargetTable = new TargetTable(
            TargetType.SHORT_CADENCE);
        final TargetTable sc2TargetTable = new TargetTable(
            TargetType.SHORT_CADENCE);
        final TargetTable sc3TargetTable = new TargetTable(
            TargetType.SHORT_CADENCE);
        final String path = "bar";

        mockery.checking(new Expectations() {
            {
                one(targetExporter).export(lcTargetTable, bgTargetTable,
                    targetMaskTable, bgMaskTable, rpTargetTable,
                    sc1TargetTable, sc2TargetTable, sc3TargetTable, path);
                will(returnValue(files));
            }
        });

        assertEquals(files, targetExporterProxy.export(lcTargetTable,
            bgTargetTable, targetMaskTable, bgMaskTable, rpTargetTable,
            sc1TargetTable, sc2TargetTable, sc3TargetTable, path));
    }

}
