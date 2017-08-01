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

package gov.nasa.kepler.dr.kicextension;

import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.KicTest;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

/**
 * @author Miles Cote
 * 
 */
public class KicExtensionStorerRetrieverTest {

    private KicExtension kicExtension1 = TestKicExtensions.create(KicExtension.MIN_KIC_EXSTENSION_KEPLER_ID);
    private KicExtension kicExtension2 = TestKicExtensions.create(KicExtension.MIN_KIC_EXSTENSION_KEPLER_ID + 1);

    private KicCrud kicCrud = new KicCrud();

    private KicExtensionStorer kicExtensionStorer = new KicExtensionStorer(
        kicCrud);
    private KicExtensionRetriever kicExtensionRetriever = new KicExtensionRetriever(
        kicCrud);

    @BeforeClass
    public static void setUpBeforeClass() {
        DefaultProperties.setPropsForUnitTest();
    }

    @Before
    public void setUp() throws Exception {
        TestUtils.setUpDatabase(DatabaseServiceFactory.getInstance());
    }

    @Test
    public void testStoreRetrieve() throws Exception {
        DatabaseServiceFactory.getInstance()
            .beginTransaction();
        kicCrud.create(KicTest.buildKic(
            KicExtension.MAX_ORIGINAL_KIC_KEPLER_ID, 0));
        kicExtensionStorer.store(kicExtension1);
        DatabaseServiceFactory.getInstance()
            .commitTransaction();

        DatabaseServiceFactory.getInstance()
            .closeCurrentSession();

        KicExtension actualKicExtension = kicExtensionRetriever.retrieve();

        new ReflectionEquals().assertEquals(kicExtension1, actualKicExtension);
    }

    @Test
    public void testStoreStoreRetrieve() throws Exception {
        testStoreRetrieve();

        DatabaseServiceFactory.getInstance()
            .beginTransaction();
        kicExtensionStorer.store(kicExtension2);
        DatabaseServiceFactory.getInstance()
            .commitTransaction();

        DatabaseServiceFactory.getInstance()
            .closeCurrentSession();

        KicExtension actualKicExtension = kicExtensionRetriever.retrieve();

        new ReflectionEquals().assertEquals(kicExtension2, actualKicExtension);
    }

}
