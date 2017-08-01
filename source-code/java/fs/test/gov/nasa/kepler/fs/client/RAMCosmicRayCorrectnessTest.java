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

package gov.nasa.kepler.fs.client;


import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.client.util.RAMFileStoreDriver;

import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Ignore;
import org.junit.Test;

/**
 * Tests the RAM file store implementation CosmicRaySeries functionality.
 * @author Sean McCauliff
 *
 */
public class RAMCosmicRayCorrectnessTest extends MjdTimeSeriesCorrectnessTest{

    /**
     * @throws java.lang.Exception
     */
    @BeforeClass
    public static void setUpBeforeClass() throws Exception {
    }

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        super.setUp();
    }

    protected FileStoreClient createFileStoreClient() throws Exception {
        return new RAMFileStoreDriver(null);
    }
    
    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        super.tearDown();
    }
    
    @Test
    @Override
    public void appendToMjdTimeSeries() throws Exception {
        super.appendToMjdTimeSeries();
    }
    
    @Test
    @Override
    public void insertIntoMjdTimeSeries() throws Exception {
        super.insertIntoMjdTimeSeries();
    }
    
    @Test
    @Override
    public void overwriteMjdTimeSeries() throws Exception {
        super.overwriteMjdTimeSeries();
    }
    
    @Test
    @Override
    public void readNonExistantMjdTimeSeries() throws Exception {
        super.readNonExistantMjdTimeSeries();
    }
    
    @Test
    @Override
    public void prefixMjdTimeSeries() throws Exception {
        super.prefixMjdTimeSeries();
    }
    
    @Test
    @Override
    public void testListMjdTimeSeries() throws Exception {
        super.testListMjdTimeSeries();
    }
    
    @Test
    @Override
    public void testReadAllMjdTimeSeries() throws Exception {
        super.testReadAllMjdTimeSeries();
    }
    
    @Test
    @Override
    public void testSimpleMjdTimeSeries() throws Exception {
        super.testSimpleMjdTimeSeries();
    }
    
    @Ignore
    @Override
    public void simpleReadMjdTimeSeries() throws Exception {
        //This does nothing.
    }

}
