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
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.gar.HuffmanTable;
import gov.nasa.kepler.hibernate.gar.HuffmanTableDescriptor;
import gov.nasa.kepler.hibernate.gar.RequantTable;
import gov.nasa.kepler.hibernate.gar.RequantTableDescriptor;

import java.util.Arrays;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.integration.junit4.JUnit4Mockery;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

/**
 * Tests the {@link CompressionCrudProxy} class.
 * 
 * @author Bill Wohler
 */
@RunWith(JMock.class)
public class CompressionCrudProxyTest {

    private DatabaseService databaseService;
    private CompressionCrud compressionCrud;
    private CompressionCrudProxy compressionCrudProxy;

    private final Mockery mockery = new JUnit4Mockery() {
        {
            setImposteriser(ClassImposteriser.INSTANCE);
        }
    };

    @Before
    public void setUp() {
        databaseService = mockery.mock(DatabaseService.class);
        ProxyTestHelper.createProxyAssertions(mockery, databaseService);
        compressionCrud = mockery.mock(CompressionCrud.class);
        compressionCrudProxy = new CompressionCrudProxy(databaseService);
        compressionCrudProxy.setCompressionCrud(compressionCrud);
    }

    @Test
    public void provideCodeCoverageForDefaultConstructor() {
        ProxyTestHelper.dismissProxyAssertions(databaseService);
        new CompressionCrudProxy();
    }

    @Test
    public void testCreateHuffmanTable() {
        final HuffmanTable table = new HuffmanTable();

        mockery.checking(new Expectations() {
            {
                one(compressionCrud).createHuffmanTable(table);
            }
        });

        compressionCrudProxy.createHuffmanTable(table);
    }

    @Test
    public void testRetrieveHuffmanTable() {
        final long id = 42;
        final HuffmanTable table = new HuffmanTable();

        mockery.checking(new Expectations() {
            {
                one(compressionCrud).retrieveHuffmanTable(id);
                will(returnValue(table));
            }
        });

        assertEquals(table, compressionCrudProxy.retrieveHuffmanTable(id));
    }

    @Test
    public void testRetrieveAllHuffmanTableDescriptors() {
        final List<HuffmanTableDescriptor> descriptors = Arrays.asList(new HuffmanTableDescriptor[] { new HuffmanTableDescriptor(
            42, 42, 42, (Date) null, State.LOCKED, 42, 42.0F, 42.0F) });

        mockery.checking(new Expectations() {
            {
                one(compressionCrud).retrieveAllHuffmanTableDescriptors();
                will(returnValue(descriptors));
            }
        });

        assertEquals(descriptors,
            compressionCrudProxy.retrieveAllHuffmanTableDescriptors());
    }

    @Test
    public void testCreateRequantTable() {
        final RequantTable table = new RequantTable();

        mockery.checking(new Expectations() {
            {
                one(compressionCrud).createRequantTable(table);
            }
        });

        compressionCrudProxy.createRequantTable(table);
    }

    @Test
    public void testRetrieveRequantTable() {
        final long id = 42;
        final RequantTable table = new RequantTable();

        mockery.checking(new Expectations() {
            {
                one(compressionCrud).retrieveRequantTable(id);
                will(returnValue(table));
            }
        });

        assertEquals(table, compressionCrudProxy.retrieveRequantTable(id));
    }

    @Test
    public void testRetrieveAllRequantTableDescriptors() {
        final List<RequantTableDescriptor> descriptors = Arrays.asList(new RequantTableDescriptor[] { new RequantTableDescriptor(
            42, 42, 42, (Date) null, State.LOCKED, 42) });

        mockery.checking(new Expectations() {
            {
                one(compressionCrud).retrieveAllRequantTableDescriptors();
                will(returnValue(descriptors));
            }
        });

        assertEquals(descriptors,
            compressionCrudProxy.retrieveAllRequantTableDescriptors());
    }

    @Test
    public void testRetrieveUplinkedExternalIds() {
        final Set<Integer> ids = new HashSet<Integer>(
            Arrays.asList(new Integer[] { 42 }));

        mockery.checking(new Expectations() {
            {
                one(compressionCrud).retrieveUplinkedExternalIds();
                will(returnValue(ids));
            }
        });

        assertEquals(ids, compressionCrudProxy.retrieveUplinkedExternalIds());
    }

    @Test
    public void testRetrieveExternalIdsInUse() {
        final Set<Integer> ids = new HashSet<Integer>(
            Arrays.asList(new Integer[] { 42 }));

        mockery.checking(new Expectations() {
            {
                one(compressionCrud).retrieveExternalIdsInUse();
                will(returnValue(ids));
            }
        });

        assertEquals(ids, compressionCrudProxy.retrieveExternalIdsInUse());
    }
}
