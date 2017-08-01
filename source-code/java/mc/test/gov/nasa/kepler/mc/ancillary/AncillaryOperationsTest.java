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

package gov.nasa.kepler.mc.ancillary;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.common.AncillaryPipelineData;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreTestInterface;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.TimeSeriesOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class AncillaryOperationsTest {

    private static final long PRODUCER_TASK_ID = -1;

    public static final String ANCILLARY_DIR = Filenames.BUILD_TMP
        + "/ancillary/";
    public static final int CCD_MODULE = 6;
    public static final int CCD_OUTPUT = 3;
    public static final int START_CADENCE = 0;
    public static final int END_CADENCE = 48;
    public static final TargetTable TARGET_TABLE = new TargetTable(
        TargetType.LONG_CADENCE);
    public static final int EXTERNAL_ID = 1;
    public static final String PIPELINE_ANC_MNEMONIC_PREFIX = "SOC_ANC_MNEMONIC";

    private AncillaryOperations ancillaryOperations;

    private List<String> engineeringMnemonics;
    private List<String> ancPipelineMnemonics;
    private List<String> pipelineMnemonics;
    private TimestampSeries cadenceTimes;
    private Map<String, Pair<FsId, FsId>> fsIdsByPipelineMnemonic;
    private Map<FsId, FloatTimeSeries> floatTimeSeriesByFsId;

    private List<AncillaryEngineeringData> ancillaryEngineeringDataList;
    private List<AncillaryPipelineData> ancillaryPipelineDataList;

    private Set<Long> producerTaskIds;

    @Before
    public void setUp() throws Exception {
        DefaultProperties.setPropsForUnitTest();
        TestUtils.setUpDatabase(DatabaseServiceFactory.getInstance());
        TARGET_TABLE.setExternalId(EXTERNAL_ID);
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(DatabaseServiceFactory.getInstance());
    }

    private static final Set<String> prepend(String prefix, Set<String> input) {

        Set<String> output = new HashSet<String>(input.size());
        for (String string : input) {
            output.add(prefix + string);
        }
        return output;
    }

    private void populateObjects() throws Exception {
        ancillaryOperations = new AncillaryOperations();

        engineeringMnemonics = new ArrayList<String>();
        engineeringMnemonics.add("mnemonic1");
        engineeringMnemonics.add("mnemonic2");
        engineeringMnemonics.add("mnemonic3");

        producerTaskIds = new HashSet<Long>();
        producerTaskIds.add(PRODUCER_TASK_ID);

        createAncillaryEngineeringDataList();
        createAncillaryPipelineMjdTimeSeries();

        ancPipelineMnemonics = new ArrayList<String>();
        for (int i = 1; i < 4; i++) {
            ancPipelineMnemonics.add(PIPELINE_ANC_MNEMONIC_PREFIX + i);
        }

        pipelineMnemonics = new ArrayList<String>();
        pipelineMnemonics.addAll(prepend("SOC_CAL_",
            CalFsIdFactory.getAncillaryPipelineDataMnemonics()));
        pipelineMnemonics.addAll(prepend("SOC_PA_",
            PaFsIdFactory.getAncillaryPipelineDataMnemonics()));

        createAncillaryPipelineTimeSeries();
    }

    private void createAncillaryEngineeringDataList() {
        ancillaryEngineeringDataList = new ArrayList<AncillaryEngineeringData>();
        for (int i = 1; i < 4; i++) {
            double[] array = new double[9];
            float[] floatArray = new float[9];
            for (int j = 0; j < array.length; j++) {
                array[j] = j;
                floatArray[j] = j;
            }

            AncillaryEngineeringData ancillaryEngineeringData = new AncillaryEngineeringData(
                "mnemonic" + i);
            ancillaryEngineeringData.setTimestamps(array);
            ancillaryEngineeringData.setValues(floatArray);
            ancillaryEngineeringDataList.add(ancillaryEngineeringData);
        }

        FileStoreClientFactory.getInstance().rollbackLocalFsTransactionIfActive();
        FileStoreClientFactory.getInstance()
            .beginLocalFsTransaction();
        ancillaryOperations.storeAncillaryEngineeringData(
            ancillaryEngineeringDataList, PRODUCER_TASK_ID);
        FileStoreClientFactory.getInstance()
            .commitLocalFsTransaction();
    }

    private void createAncillaryPipelineTimeSeries() {

        fsIdsByPipelineMnemonic = AncillaryOperations.getAncillaryMnemonicToTimeSeriesFsIds(
            pipelineMnemonics.toArray(new String[pipelineMnemonics.size()]),
            TARGET_TABLE, CCD_MODULE, CCD_OUTPUT);
        List<FsId> fsIds = new ArrayList<FsId>();
        for (Pair<FsId, FsId> mnemonicFsIds : fsIdsByPipelineMnemonic.values()) {
            fsIds.add(mnemonicFsIds.left);
            if (mnemonicFsIds.right != null) {
                fsIds.add(mnemonicFsIds.right);
            }
        }
        FloatTimeSeries[] floatTimeSeries = MockUtils.createFloatTimeSeries(
            START_CADENCE, END_CADENCE, PRODUCER_TASK_ID,
            fsIds.toArray(new FsId[fsIds.size()]));
        FileStoreClientFactory.getInstance().rollbackLocalFsTransactionIfActive();
        FileStoreClientFactory.getInstance()
            .beginLocalFsTransaction();
        FileStoreClientFactory.getInstance()
            .writeTimeSeries(floatTimeSeries);
        FileStoreClientFactory.getInstance()
            .commitLocalFsTransaction();
        floatTimeSeriesByFsId = TimeSeriesOperations.getFloatTimeSeriesByFsId(floatTimeSeries);

        int[] cadences = new int[END_CADENCE - START_CADENCE + 1];
        double[] midTimes = new double[cadences.length];
        for (int i = 0; i < cadences.length; i++) {
            cadences[i] = i;
            midTimes[i] = i;

        }
        cadenceTimes = new TimestampSeries(new double[0], midTimes,
            new double[0], new boolean[0], new boolean[0], cadences,
            new boolean[0], new boolean[0], new boolean[0], new boolean[0],
            new boolean[0], new boolean[0], new boolean[0], null);
    }

    private void createAncillaryPipelineMjdTimeSeries() {
        ancillaryPipelineDataList = new ArrayList<AncillaryPipelineData>();
        for (int i = 1; i < 4; i++) {
            double[] array = new double[9];
            float[] floatArray = new float[9];
            for (int j = 0; j < array.length; j++) {
                array[j] = j;
                floatArray[j] = j;
            }

            AncillaryPipelineData ancillaryPipelineData = new AncillaryPipelineData(
                PIPELINE_ANC_MNEMONIC_PREFIX + i);
            ancillaryPipelineData.setTimestamps(array);
            ancillaryPipelineData.setValues(floatArray);
            ancillaryPipelineData.setUncertainties(floatArray);
            ancillaryPipelineDataList.add(ancillaryPipelineData);
        }

        FileStoreClientFactory.getInstance().rollbackLocalFsTransactionIfActive();
        FileStoreClientFactory.getInstance()
            .beginLocalFsTransaction();
        ancillaryOperations.storeAncillaryPipelineData(
            ancillaryPipelineDataList, PRODUCER_TASK_ID);
        FileStoreClientFactory.getInstance()
            .commitLocalFsTransaction();
    }

    @Test(expected = IllegalArgumentException.class)
    public void testInvalidMnemonic() throws Exception {
        populateObjects();

        ancillaryOperations.retrieveAncillaryEngineeringData(new String[] {
            "FOO", "BAR" }, 0, 8);
    }

    @Test
    public void testRetrieveAncillaryEngineeringData() throws Exception {
        populateObjects();

        List<AncillaryEngineeringData> results = ancillaryOperations.retrieveAncillaryEngineeringData(
            engineeringMnemonics.toArray(new String[0]), 0, 8);
        ReflectionEquals reflectionEquals = new ReflectionEquals();
        reflectionEquals.assertEquals(ancillaryEngineeringDataList, results);

        assertEquals(new ArrayList<AncillaryEngineeringData>(),
            ancillaryOperations.retrieveAncillaryEngineeringData(
                new String[] {}, 0, 8));
        assertEquals(new ArrayList<AncillaryEngineeringData>(),
            ancillaryOperations.retrieveAncillaryEngineeringData(null, 0, 8));
    }

    @Test
    public void testRetrieveAncillaryPipelineMjdTimeSeries() throws Exception {
        populateObjects();

        List<AncillaryPipelineData> results = ancillaryOperations.retrieveAncillaryPipelineData(
            ancPipelineMnemonics.toArray(new String[0]), 0, 8);
        ReflectionEquals reflectionEquals = new ReflectionEquals();
        reflectionEquals.assertEquals(ancillaryPipelineDataList, results);

        assertEquals(new ArrayList<AncillaryPipelineData>(),
            ancillaryOperations.retrieveAncillaryPipelineData(null, 0, 8));
    }

    @Test
    public void testProducerTaskIds() throws Exception {
        populateObjects();

        ReflectionEquals reflectionEquals = new ReflectionEquals();

        ancillaryOperations.retrieveAncillaryEngineeringData(
            engineeringMnemonics.toArray(new String[0]), 0, 8);
        reflectionEquals.assertEquals(new HashSet<Long>(),
            ancillaryOperations.producerTaskIds());

        ancillaryOperations.retrieveAncillaryPipelineData(
            ancPipelineMnemonics.toArray(new String[0]), 0, 8);
        reflectionEquals.assertEquals(producerTaskIds,
            ancillaryOperations.producerTaskIds());

        ancillaryOperations.retrieveAncillaryPipelineData(
            pipelineMnemonics.toArray(new String[pipelineMnemonics.size()]),
            TARGET_TABLE, CCD_MODULE, CCD_OUTPUT, cadenceTimes);

        reflectionEquals.assertEquals(producerTaskIds,
            ancillaryOperations.producerTaskIds());
    }

    @Test
    public void testRetrieveAncillaryPipelineTimeSeries() throws Exception {
        populateObjects();

        List<AncillaryPipelineData> ancillaryPipelineData = ancillaryOperations.retrieveAncillaryPipelineData(
            pipelineMnemonics.toArray(new String[pipelineMnemonics.size()]),
            TARGET_TABLE, CCD_MODULE, CCD_OUTPUT, cadenceTimes);
        assertNotNull(ancillaryPipelineData);
        assertTrue(ancillaryPipelineData.size() > 0);
        assertEquals(pipelineMnemonics.size(), ancillaryPipelineData.size());

        ReflectionEquals reflectionEquals = new ReflectionEquals();

        for (AncillaryPipelineData data : ancillaryPipelineData) {
            String mnemonic = data.getMnemonic();
            assertTrue(pipelineMnemonics.contains(mnemonic));
            Pair<FsId, FsId> fsIds = fsIdsByPipelineMnemonic.get(mnemonic);
            assertTrue(Arrays.equals(floatTimeSeriesByFsId.get(fsIds.left)
                .fseries(), data.getValues()));
            if (fsIds.right != null) {
                assertTrue(Arrays.equals(floatTimeSeriesByFsId.get(fsIds.right)
                    .fseries(), data.getUncertainties()));
            }
            assertNotNull(data.getTimestamps());
        }
        reflectionEquals.assertEquals(producerTaskIds,
            ancillaryOperations.producerTaskIds());
    }

    @Test
    public void testThatAncillaryEngineeringDataMergesNonOverlappingRegions()
        throws Exception {
        populateObjects();

        // Store a bracketing mjd range that does not include new data for the
        // existing mjd range.
        FileStoreClientFactory.getInstance().rollbackLocalFsTransactionIfActive();
        FileStoreClientFactory.getInstance()
            .beginLocalFsTransaction();

        AncillaryEngineeringData ancillaryData = new AncillaryEngineeringData(
            engineeringMnemonics.get(0));
        ancillaryData.setTimestamps(new double[] { -100, 100 });
        ancillaryData.setValues(new float[] { -1000, -1000 });

        List<AncillaryEngineeringData> bracketingAncillaryDataList = new ArrayList<AncillaryEngineeringData>();
        bracketingAncillaryDataList.add(ancillaryData);

        ancillaryOperations.storeAncillaryEngineeringData(
            bracketingAncillaryDataList, PRODUCER_TASK_ID);

        FileStoreClientFactory.getInstance()
            .commitLocalFsTransaction();

        List<AncillaryEngineeringData> results = ancillaryOperations.retrieveAncillaryEngineeringData(
            engineeringMnemonics.toArray(new String[0]), 0, 8);
        ReflectionEquals reflectionEquals = new ReflectionEquals();
        reflectionEquals.assertEquals(ancillaryEngineeringDataList, results);
    }

    @Test
    public void testAncillaryEngineeringDataOutOfOrder() throws Exception {
        ancillaryOperations = new AncillaryOperations();

        String mnemonic = "mnemonic1";

        AncillaryEngineeringData unsortedAncillaryEngineeringData = new AncillaryEngineeringData(
            mnemonic);
        unsortedAncillaryEngineeringData.setTimestamps(new double[] { 4, 2, 3,
            1 });
        unsortedAncillaryEngineeringData.setValues(new float[] { 100, 200, 300,
            400 });

        ancillaryEngineeringDataList = new ArrayList<AncillaryEngineeringData>();
        ancillaryEngineeringDataList.add(unsortedAncillaryEngineeringData);

        FileStoreClientFactory.getInstance().rollbackLocalFsTransactionIfActive();
        FileStoreClientFactory.getInstance()
            .beginLocalFsTransaction();
        ancillaryOperations.storeAncillaryEngineeringData(
            ancillaryEngineeringDataList, PRODUCER_TASK_ID);
        FileStoreClientFactory.getInstance()
            .commitLocalFsTransaction();

        List<AncillaryEngineeringData> results = ancillaryOperations.retrieveAncillaryEngineeringData(
            new String[] { mnemonic }, 1, 4);

        assertTrue(Arrays.equals(new double[] { 1, 2, 3, 4 }, results.get(0)
            .getTimestamps()));
        assertTrue(Arrays.equals(new float[] { 400, 200, 300, 100 },
            results.get(0)
                .getValues()));
    }

    @Test
    public void testAncillaryEngineeringDuplicates() throws Exception {
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        ((FileStoreTestInterface) fsClient).cleanFileStore();

        ancillaryOperations = new AncillaryOperations();

        String mnemonic = "mnemonic1";

        AncillaryEngineeringData unsortedAncillaryEngineeringData = new AncillaryEngineeringData(
            mnemonic);
        unsortedAncillaryEngineeringData.setTimestamps(new double[] { 4, 2, 2,
            1 });
        unsortedAncillaryEngineeringData.setValues(new float[] { 100, 200, 200,
            400 });

        ancillaryEngineeringDataList = new ArrayList<AncillaryEngineeringData>();
        ancillaryEngineeringDataList.add(unsortedAncillaryEngineeringData);

        fsClient.rollbackLocalFsTransactionIfActive();
        fsClient.beginLocalFsTransaction();
        ancillaryOperations.storeAncillaryEngineeringData(
            ancillaryEngineeringDataList, PRODUCER_TASK_ID);
        fsClient.commitLocalFsTransaction();

        List<AncillaryEngineeringData> results = ancillaryOperations.retrieveAncillaryEngineeringData(
            new String[] { mnemonic }, 1, 4);

        assertTrue(Arrays.equals(new double[] { 1, 2, 4 }, results.get(0)
            .getTimestamps()));
        assertTrue(Arrays.equals(new float[] { 400, 200, 100 }, results.get(0)
            .getValues()));
    }

    @Test(expected = PipelineException.class)
    public void testAncillaryEngineeringDuplicatesWithDifferentValues()
        throws Exception {
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        ((FileStoreTestInterface) fsClient).cleanFileStore();

        ancillaryOperations = new AncillaryOperations();

        String mnemonic = "mnemonic1";

        AncillaryEngineeringData unsortedAncillaryEngineeringData = new AncillaryEngineeringData(
            mnemonic);
        unsortedAncillaryEngineeringData.setTimestamps(new double[] { 4, 2, 2,
            1 });
        unsortedAncillaryEngineeringData.setValues(new float[] { 100, 200, 300,
            400 });

        ancillaryEngineeringDataList = new ArrayList<AncillaryEngineeringData>();
        ancillaryEngineeringDataList.add(unsortedAncillaryEngineeringData);

        fsClient.rollbackLocalFsTransactionIfActive();
        fsClient.beginLocalFsTransaction();
        ancillaryOperations.storeAncillaryEngineeringData(
            ancillaryEngineeringDataList, PRODUCER_TASK_ID);
        fsClient.commitLocalFsTransaction();
    }

}
