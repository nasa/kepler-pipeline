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

package gov.nasa.kepler.mc.dr;

import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.dr.RclcPixelBlobMetadata;
import gov.nasa.kepler.hibernate.dr.RclcPixelBlobMetadataCrud;
import gov.nasa.kepler.hibernate.dr.RclcPixelBlobMetadataFactory;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.util.Arrays;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Miles Cote
 * 
 */
public class RclcPixelTimeSeriesOperationsTest extends JMockTest {

    private static final int CCD_MODULE = 2;
    private static final int CCD_OUTPUT = 1;
    private static final int START_CADENCE = 3;
    private static final int END_CADENCE = 4;
    private static final int MODULE_ID = 5;
    private static final int[] ISERIES = new int[] { 6, 7 };
    private static final long PIPELINE_TASK_ID = DrConstants.DATA_RECEIPT_ORIGIN_ID;

    private static final DataSetType DATA_SET_TYPE = DataSetType.Target;
    private static final boolean OVERWRITE = false;

    private FsId id = DrFsIdFactory.getRclcPixelBlobFsId(DATA_SET_TYPE,
        CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE - START_CADENCE + 1);
    private FsId[] ids = new FsId[] { id };
    private boolean[] gaps = new boolean[] { false, false };
    private IntTimeSeries intTimeSeries = new IntTimeSeries(id, ISERIES,
        START_CADENCE, END_CADENCE, gaps, MODULE_ID);
    private IntTimeSeries[] intTimeSeriesArray = new IntTimeSeries[] { intTimeSeries };
    private RclcPixelBlobMetadata rclcPixelBlobMetadata = new RclcPixelBlobMetadata(
        PIPELINE_TASK_ID, CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);

    private RclcPixelBlobMetadataCrud rclcPixelBlobMetadataCrud = mock(RclcPixelBlobMetadataCrud.class);
    private RclcPixelBlobMetadataFactory rclcPixelBlobMetadataFactory = mock(RclcPixelBlobMetadataFactory.class);

    private RclcPixelTimeSeriesOperations rclcPixelTimeSeriesOperations = new RclcPixelTimeSeriesOperations(
        DATA_SET_TYPE, CCD_MODULE, CCD_OUTPUT, rclcPixelBlobMetadataCrud,
        rclcPixelBlobMetadataFactory);

    @Before
    public void setUp() throws Exception {
        DefaultProperties.setPropsForUnitTest();
        TestUtils.setUpDatabase(DatabaseServiceFactory.getInstance());

        FileStoreClientFactory.getInstance()
            .rollbackLocalFsTransactionIfActive();
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(DatabaseServiceFactory.getInstance());
    }

    @Test
    public void testWriteRead() {
        setAllowances();

        allowing(rclcPixelBlobMetadataCrud).createRclcPixelBlobMetadata(
            rclcPixelBlobMetadata);

        FileStoreClientFactory.getInstance()
            .beginLocalFsTransaction();
        rclcPixelTimeSeriesOperations.write(intTimeSeriesArray, OVERWRITE);
        FileStoreClientFactory.getInstance()
            .commitLocalFsTransaction();

        IntTimeSeries[] actualIntTimeSeriesArray = rclcPixelTimeSeriesOperations.readTimeSeriesAsInt(
            ids, START_CADENCE, END_CADENCE);

        assertTrue(Arrays.equals(intTimeSeriesArray, actualIntTimeSeriesArray));
    }

    private void setAllowances() {
        allowing(rclcPixelBlobMetadataFactory).create(PIPELINE_TASK_ID,
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
        will(returnValue(rclcPixelBlobMetadata));

        allowing(rclcPixelBlobMetadataCrud).retrieveLatestRclcPixelBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
        will(returnValue(Arrays.asList(rclcPixelBlobMetadata)));
    }

}
