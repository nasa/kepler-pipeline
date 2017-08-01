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


import static gov.nasa.kepler.fs.FileStoreConstants.FS_DRIVER_NAME_PROPERTY;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.client.util.RAMFileStoreDriver;

import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Ignore;
import org.junit.Test;


/**
 * 
 * @author Sean McCauliff
 *
 */
public class RamTimeSeriesTest extends TimeSeriesCorrectnessTest {

    /**
     * @throws java.lang.Exception
     */
    @BeforeClass
    public static void setUpBeforeClass() throws Exception {
        TimeSeriesCorrectnessTest.setUpBeforeClass();
        config.setProperty(FS_DRIVER_NAME_PROPERTY, "ram");
    }

    @Override
    protected boolean runTransactionTests() {
        return false;
    }
    
    /**
     * @throws java.lang.Exception
     */
    @Before
    @Override
    public void setUp() throws Exception {
        super.setUp();
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    @Override
    public void tearDown() throws Exception {
        super.tearDown();
    }

    @Override
    protected FileStoreClient constructTimeSeriesClient() throws Exception {
        return (FileStoreClient) FileStoreClientInvocationHandler.newInstance(new RAMFileStoreDriver(config));
    }
    
    @Test
    @Override
    public void readNonExistant() {
        super.readNonExistant();
    }
    
    @Test
    @Override
    public void testReadTimeSeriesAsInt()  {
        super.testReadTimeSeriesAsInt();
    }

    @Test
    @Override
    public void testReadTimeSeriesAsFloat()  {
        super.testReadTimeSeriesAsFloat();
    }
    
    @Test
    @Override
    public void testReadTimeSeriesAsFloatMulti()  {
       super.testReadTimeSeriesAsFloatMulti();

    }
    
    @Test
    @Override
    public void testReadTimeSeriesAsIntMulti()  {
       super.testReadTimeSeriesAsIntMulti();
    }
    
    @Test
    @Override
    public void testGetIdsForSeries() {
        super.testGetIdsForSeries();
    }
    
    @Test
    @Override
    public void testgetIntervalsForId() {
        super.testGetIdsForSeries();
    }
    
    /**
     * <pre>
     *         n
     *         |
     *         V
     *    000000000000000dddddddddddddddddddddddddddddd
     *    
     * </pre>
     */
    @Test
    @Override
    public void testRangeNotStartAtZer0() {
        super.testRangeNotStartAtZer0();
    }

    /**
     * <pre>
     *           nnnnn
     *             |
     *             V
     * 0000000dddddddddd
     * </pre>
     */
    @Test
    @Override
    public void testWriteInMiddle() {
        super.testWriteInMiddle();
    }
   
    /**
     * <pre>
     *               nnnnnn
     *                 |
     *                 V
     *   00000000ddddXXXXX
     * </pre>
     */
    @Test
    @Override
    public void testWriteAtEnd() {
            super.testWriteAtEnd();
    }  
    
    /**
     * <pre>
     *               nnnnnnnnnnnnn
     *                     |
     *                     V
     *   0000dddddd00000000000000000ddddddd
     * </pre>
     */
    @Test
    @Override
    public void testWriteIntoHole() {
        super.testWriteIntoHole();

    }
    
    /**
     *  <pre>
     *         nnnnnnnnnnnnnnnnnnnnn
     *                   |
     *                   V
     *    ddddddd000000000000000dddddddddd
     *  </pre>
     */
    @Test
    @Override
    public void testMergeRanges() {
        super.testMergeRanges();
    }
    
    /**
     *    1111111111111111111111111111111111
     *        |
     *        V
     * 0: 000000000000000000000000000000000
     * 
     * 
     * 1:  222222222222222222222222222222222
     *        |
     *        V
     *    1111111111111111111111111111111111
     * 
     * N:
     *    ................NNNNNNNNNNNNNNNNNN
     *       |
     *       V
     *    1234567............
     *
     * @throws FileStoreException
     */
    @Test
    @Override
    public void testMergeMany() {
        super.testMergeMany();
    }
    
    /**
     * Single time series with gaps, instead of writing multiple times to generate
     * the gaps.
     * 
     * @throws FileStoreException
     */
    @Test
    @Override
    public void writeDataWithAbysses() {
        super.writeDataWithAbysses();
    }
    
    @Test
    @Override
    public void testWriteReadManySeries() throws Exception {
        super.testWriteReadManySeries();
    }
    
    @Test
    @Override
    public void readAllIntTimeSeries() throws Exception {
        super.readAllIntTimeSeries();
    }
    
    @Test
    @Override
    public void readAllFloatTimeSeries() throws Exception {
        super.readAllFloatTimeSeries();
    }
    
    @Ignore
    @Override
    public void testLargeCadenceNumbers() throws Exception {
        //This does nothing.
    }
    
    @Ignore
    @Override
    public void simpleTimeSeriesBatchTest() throws Exception {
        //This does nothing.
    }
    
    @Ignore
    @Override
    public void readMixedTimeSeriesBatchTest() throws Exception {
        //This does nothing.
    }
    
    @Ignore
    @Override
    public void readMultiBatchTest() throws Exception {
        //This does nothing.
    }
    
    @Ignore
    @Override
    public void explicitDelete() throws Exception {
        //This does nothing.
    }
    
    @Ignore
    @Override
    public void readNonExistentDoubleTimeSeries() throws Exception {
        //This does nothing.
    }
    
    @Ignore
    @Override
    public void simpleDoubleTimeSeries() throws Exception {
        //This does nothing
    }
    
    @Ignore
    @Override
    public void doubleTimeSeriesWithHoles() throws Exception {
        //This does nothing.
    }
    
    @Ignore
    @Override
    public void readTimeSeries() throws Exception {
        //This does nothing
    }

}
