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

package gov.nasa.kepler.ar.exporter.cal;

import static gov.nasa.kepler.common.FitsConstants.*;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.ar.cli.CalibratedPixelExportCli;
import gov.nasa.kepler.ar.exporter.cal.CalibratedPixelExporter.CadenceOption;
import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.FitsDiff;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreTestInterface;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.dr.ReceiveLog;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.hibernate.pi.PipelineDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNodeCrud;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.pi.TestUowTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.services.AlertLogCrud;
import gov.nasa.kepler.hibernate.services.User;
import gov.nasa.kepler.hibernate.services.UserCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.lang.TestSystemProvider;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;

import nom.tam.fits.BinaryTableHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;
import nom.tam.fits.HeaderCard;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 * 
 */
public class CalibratedPixelExporterTest {

    private static final Log log = LogFactory.getLog(CalibratedPixelExporterTest.class);

    private static final String TESTDATA = "testdata";
    private static final String DEFAULT_TESTDATA_DIR = Filenames.BUILD_TEST
        + "/" + TESTDATA;
    private static final String[] CADENCE_DATE_STR = new String[] {
        "2009001003000", "2009001003001" };

    private static final String[] TARGET_PIXEL_NAME;

    private static final String[] SC_TARGET_PIXEL_NAME;
    private static final String[] BACKGROUND_PIXEL_NAME;
    private static final String[] COLLATERAL_PIXEL_NAME;
    private static final String[] SC_COLLATERAL_PIXEL_NAME;

    private static final String TARGET_PMRF = "kplr2222333000000_lcm.fits";
    private static final String BACKGROUND_PMRF = "kplr2222333000000_bgm.fits";
    private static final String COLLATERAL_PMRF = "kplr2222333000000_lcc.fits";
    private static final String SC_TARGET_PMRF = "kplr2222333000000_scm.fits";
    private static final String SC_COLLATERAL_PMRF = "kplr2222333000000_scc.fits";

    private static final String LC_PROCESSING_HISTORY_NAME = "kplr"
        + CADENCE_DATE_STR[0] + "_lcs-history.txt";
    private static final String SC_PROCESSING_HISTORY_NAME = "kplr"
        + CADENCE_DATE_STR[0] + "_scs-set-history.txt";

    private static final Set<String> pixelFileNames;

    static {
        TARGET_PIXEL_NAME = new String[CADENCE_DATE_STR.length];
        SC_TARGET_PIXEL_NAME = new String[CADENCE_DATE_STR.length];
        BACKGROUND_PIXEL_NAME = new String[CADENCE_DATE_STR.length];
        COLLATERAL_PIXEL_NAME = new String[CADENCE_DATE_STR.length];
        SC_COLLATERAL_PIXEL_NAME = new String[CADENCE_DATE_STR.length];

        Set<String> pixelFileNamesMod = new HashSet<String>();

        for (int i = 0; i < CADENCE_DATE_STR.length; i++) {
            String cadenceDateStr = CADENCE_DATE_STR[i];
            TARGET_PIXEL_NAME[i] = "kplr" + cadenceDateStr + "_lcs-targ.fits";
            BACKGROUND_PIXEL_NAME[i] = "kplr" + cadenceDateStr
                + "_lcs-bkg.fits";
            SC_TARGET_PIXEL_NAME[i] = "kplr" + cadenceDateStr
                + "_scs-targ.fits";
            COLLATERAL_PIXEL_NAME[i] = "kplr" + cadenceDateStr
                + "_lcs-col.fits";
            SC_COLLATERAL_PIXEL_NAME[i] = "kplr" + cadenceDateStr
                + "_scs-col.fits";
            pixelFileNamesMod.add(TARGET_PIXEL_NAME[i]);
            pixelFileNamesMod.add(BACKGROUND_PIXEL_NAME[i]);
            pixelFileNamesMod.add(SC_TARGET_PIXEL_NAME[i]);
            pixelFileNamesMod.add(COLLATERAL_PIXEL_NAME[i]);
            pixelFileNamesMod.add(SC_COLLATERAL_PIXEL_NAME[i]);
        }

        pixelFileNames = Collections.unmodifiableSet(pixelFileNamesMod);

    }

    private static final int CADENCE_START = 1;
    private static final int CADENCE_END = 2;
    private static final int SC_CADENCE_START = CADENCE_START * 30;
    private static final int SC_CADENCE_END = SC_CADENCE_START + 1;

    private static final String SOFTWARE_REVISION = "45678";

    private Map<Integer, Long> cadenceNoToTaskId = new HashMap<Integer, Long>();

    private DispatchLog dispatchLog;

    private FileStoreClient fileStore;

    private File testDataDir;

    private File testOut;


    private enum FileType {
        PIXEL_HEADER, PMRF
    }

    /**
     * Uncompresses the test data.
     * 
     * @throws Exception
     */
    private void uncompress() throws Exception {
        File dataFile = new File(TESTDATA, "pixeldata.tar.bz2");
        if (!dataFile.exists()) {
            log.warn("File \"" + dataFile
                + "\" does not exist assuming it has been uncompressed.");
            return;
        }

        Runtime rt = Runtime.getRuntime();
        Process p = rt.exec("tar -xjf " + dataFile + " -C " + testDataDir);
        int exitValue = p.waitFor();
        p.getOutputStream().close();
        p.getInputStream().close();
        p.getErrorStream().close();

        if (exitValue != 0) {
            throw new IllegalStateException("Unable to uncompress file \""
                + dataFile + "\".");
        }

    }

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        Configuration configuration = ConfigurationServiceFactory.getInstance();

        testOut = new File(Filenames.BUILD_TEST
            + "/CalibratedPixelExporter.test");
        if (testOut.exists()) {
            FileUtils.forceDelete(testOut);
        }
        FileUtils.forceMkdir(testOut);

        String testDataDirStr = configuration.getString("testdatadir",
            DEFAULT_TESTDATA_DIR);
        testDataDir = new File(testDataDirStr);
        if (testDataDir.exists()) {
            FileUtil.removeAll(testDataDir);
        }
        FileUtils.forceMkdir(testDataDir);

        uncompress();

        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        DatabaseServiceFactory.getInstance(false).getDdlInitializer().initDB();

        for (int cadenceNo = CADENCE_START; cadenceNo <= CADENCE_END; cadenceNo++) {
            createAccountability(cadenceNo);
        }

        // It just so happens for this test the short cadence numbers and the
        // long
        // cadence numbers will not overlap.
        for (int cadenceNo = SC_CADENCE_START; cadenceNo <= SC_CADENCE_END; cadenceNo++) {
            createAccountability(cadenceNo);
        }

        TransactionService xService = TransactionServiceFactory.getInstance();
        xService.beginTransaction(true, false, true);
        boolean ok = false;
        try {

            ReceiveLog receiveLog = new ReceiveLog(new Date(), "b0gus",
                "bogussdnm.xml");
            receiveLog.setLastTimestamp(CADENCE_DATE_STR[CADENCE_DATE_STR.length - 1]);

            DispatchLog dispatchLog = new DispatchLog(receiveLog,
                DispatcherType.LONG_CADENCE_PIXEL);

            LogCrud logCrud = new LogCrud(dbService);
            logCrud.createReceiveLog(receiveLog);
            logCrud.createDispatchLog(dispatchLog);

            fileStore = FileStoreClientFactory.getInstance();

            for (String pixelHeaderName : pixelFileNames) {
                storeFile(new File(testDataDir, pixelHeaderName),
                    FileType.PIXEL_HEADER);
            }

            storeFile(new File(testDataDir, TARGET_PMRF), FileType.PMRF);
            storeFile(new File(testDataDir, BACKGROUND_PMRF), FileType.PMRF);
            storeFile(new File(testDataDir, COLLATERAL_PMRF), FileType.PMRF);
            storeFile(new File(testDataDir, SC_TARGET_PMRF), FileType.PMRF);
            storeFile(new File(testDataDir, SC_COLLATERAL_PMRF), FileType.PMRF);
            storeProcessingHistory(LC_PROCESSING_HISTORY_NAME);
            storeProcessingHistory(SC_PROCESSING_HISTORY_NAME);

            for (int cadenceNo = CADENCE_START; cadenceNo <= CADENCE_END; cadenceNo++) {
                int fileIndex = cadenceNo - CADENCE_START;
                logCrud.createPixelLog(makeCadenceLog(
                    TARGET_PIXEL_NAME[fileIndex], false, cadenceNo,
                    DataSetType.Target));
                logCrud.createPixelLog(makeCadenceLog(
                    BACKGROUND_PIXEL_NAME[fileIndex], false, cadenceNo,
                    DataSetType.Background));
                logCrud.createPixelLog(makeCadenceLog(
                    COLLATERAL_PIXEL_NAME[fileIndex], false, cadenceNo,
                    DataSetType.Collateral));
            }

            for (int cadenceNo = SC_CADENCE_START; cadenceNo <= SC_CADENCE_END; cadenceNo++) {
                int fileIndex = cadenceNo - SC_CADENCE_START;
                logCrud.createPixelLog(makeCadenceLog(
                    SC_TARGET_PIXEL_NAME[fileIndex], true, cadenceNo,
                    DataSetType.Target));
                logCrud.createPixelLog(makeCadenceLog(
                    SC_COLLATERAL_PIXEL_NAME[fileIndex], true, cadenceNo,
                    DataSetType.Collateral));
            }

            storeTimeSeries(dbService);

            ok = true;
        } finally {
            if (ok) {
                xService.commitTransaction();
            } else {
                xService.rollbackTransaction();
            }
        }

    }

    private void createAccountability(int cadenceNo) {
        DatabaseService dbService = DatabaseServiceFactory.getInstance(false);
        dbService.beginTransaction();
        PipelineTaskCrud taskCrud = new PipelineTaskCrud(dbService);
        PipelineDefinitionCrud defCrud = new PipelineDefinitionCrud(dbService);

        PipelineDefinition pipeDef = new PipelineDefinition("CalExportTest"
            + cadenceNo);

        UserCrud userCrud = new UserCrud(dbService);
        User user = userCrud.retrieveUser("sean");
        if (user == null) {
            user = new User("sean", "sean", "sean", "smccauliff@arc.nasa.gov",
                "408-373-4565");
            userCrud.createUser(user);
        }

        //AuditInfo auditInfo = new AuditInfo(user, new Date());

        PipelineModuleDefinition pipelineModuleDefinition = new PipelineModuleDefinition(
            "ModuleDef" + cadenceNo);
        PipelineModuleDefinitionCrud modDefCrud = new PipelineModuleDefinitionCrud(
            dbService);
        modDefCrud.create(pipelineModuleDefinition);

        PipelineDefinitionNode pipeNodeDef = new PipelineDefinitionNode(
            pipelineModuleDefinition.getName());

        pipeDef.getRootNodes().add(pipeNodeDef);

        defCrud.create(pipeDef);

        PipelineInstance pipelineInstance = new PipelineInstance(pipeDef);
        PipelineInstanceCrud instCrud = new PipelineInstanceCrud(dbService);
        instCrud.create(pipelineInstance);

        PipelineInstanceNode pipelineInstanceNode = new PipelineInstanceNode(
            pipelineInstance, pipeNodeDef, pipelineModuleDefinition);
        PipelineInstanceNodeCrud instNodeCrud = new PipelineInstanceNodeCrud(
            dbService);
        instNodeCrud.create(pipelineInstanceNode);

        dbService.flush();

        PipelineTask task = new PipelineTask(pipelineInstance, pipeNodeDef,
            pipelineInstanceNode);
        task.setSoftwareRevision(SOFTWARE_REVISION);
        task.setEndProcessingTime(new Date());
        task.setUowTask(new BeanWrapper<UnitOfWorkTask>(new TestUowTask()));

        taskCrud.create(task);
        dbService.flush();
        dbService.commitTransaction();

        cadenceNoToTaskId.put(cadenceNo, task.getId());

    }

    private void storeProcessingHistory(String fileName) throws Exception {
        File historyFile = new File(this.testDataDir, fileName);
        DataInputStream din = new DataInputStream(new BufferedInputStream(
            new FileInputStream(historyFile)));
        byte[] buf = new byte[(int) historyFile.length()];
        din.readFully(buf);
        din.close();

        FsId fsid = DrFsIdFactory.getFile(DispatcherType.HISTORY, fileName);
        fileStore.writeBlob(fsid, /* task id */0, buf);

    }

    private PixelLog makeCadenceLog(String fileName, boolean shortCadence,
        int cadenceNo, DataSetType dataSetType) {

        double cadenceMultiplier = (shortCadence) ? 1.0 / 30.0 : 1.0;
        int cadenceType = (shortCadence) ? Cadence.CADENCE_SHORT
            : Cadence.CADENCE_LONG;

        PixelLog cadenceLog = new PixelLog(dispatchLog, cadenceNo, cadenceType,
            fileName, "DATASETNAME", cadenceMultiplier * cadenceNo,
            cadenceMultiplier * (cadenceNo + 1), (short) 3, // lcTargetTableId
            (short) 4, // scTargetTableId
            (short) 2, // backTargetTableId
            (short) 5, // targetApertureTableId
            (short) 1, // backgroundApertureTableId
            (short) 0); // compressionTableId
        cadenceLog.setDataSetType(dataSetType);

        return cadenceLog;
    }

    private void storeTimeSeries(DatabaseService dbService) throws Exception {
        File targetPmrfFile = new File(testDataDir, TARGET_PMRF);
        storeVisiblePixels(TargetType.LONG_CADENCE, targetPmrfFile, 23,
            CADENCE_START, CADENCE_END);

        File shortCadenceTargetPmrfFile = new File(testDataDir, SC_TARGET_PMRF);

        storeVisiblePixels(TargetType.SHORT_CADENCE,
            shortCadenceTargetPmrfFile, 23, SC_CADENCE_START, SC_CADENCE_END);

        File backgroundPmrfFile = new File(testDataDir, BACKGROUND_PMRF);

        storeVisiblePixels(TargetType.BACKGROUND, backgroundPmrfFile, 42,
            CADENCE_START, CADENCE_END);

        File collateralPmrfFile = new File(testDataDir, COLLATERAL_PMRF);
        storeCollateralPixels(collateralPmrfFile, Cadence.CADENCE_LONG,
            CADENCE_START, CADENCE_END);

        File shortCadenceCollateralPmrfFile = new File(testDataDir,
            SC_COLLATERAL_PMRF);
        storeCollateralPixels(shortCadenceCollateralPmrfFile,
            Cadence.CADENCE_SHORT, SC_CADENCE_START, SC_CADENCE_END);

        MjdToCadence longCadence = new MjdToCadence(
            Cadence.CadenceType.LONG, new ModelMetadataRetrieverLatest());
        MjdToCadence shortCadence = new MjdToCadence(
            Cadence.CadenceType.SHORT, new ModelMetadataRetrieverLatest());

        storeVisibleCosmicRays(TargetType.LONG_CADENCE, targetPmrfFile,
            CADENCE_START, CADENCE_END, longCadence);

        storeVisibleCosmicRays(TargetType.SHORT_CADENCE,
            shortCadenceTargetPmrfFile, SC_CADENCE_START, SC_CADENCE_END,
            shortCadence);

        storeVisibleCosmicRays(TargetType.BACKGROUND, backgroundPmrfFile,
            CADENCE_START, CADENCE_END, longCadence);

        storeCollateralCosmicRays(collateralPmrfFile, Cadence.CADENCE_LONG,
            CADENCE_START, CADENCE_END, longCadence);

        storeCollateralCosmicRays(shortCadenceCollateralPmrfFile,
            Cadence.CADENCE_SHORT, SC_CADENCE_START, SC_CADENCE_END,
            shortCadence);

    }

    private void storeVisibleCosmicRays(TargetType targetTableType,
        File pmrfFile, int cadenceStart, int cadenceEnd,
        MjdToCadence mjdToCadence) throws FitsException, IOException {

        Fits pmrf = new Fits(pmrfFile);
        int cadenceLen = cadenceEnd - cadenceStart + 1;
        double[] mjd = new double[cadenceLen];
        float[] rays = new float[cadenceLen];
        Arrays.fill(rays, 1.0f);
        long[] originators = new long[cadenceLen];

        for (int cadenceNo = cadenceStart; cadenceNo <= cadenceEnd; cadenceNo++) {
            int arrayIndex = cadenceNo - cadenceStart;
            mjd[arrayIndex] = mjdToCadence.cadenceToMjd(cadenceNo);
            originators[arrayIndex] = cadenceNoToTaskId.get(cadenceNo);
        }

        pmrf.readHDU();
        List<FloatMjdTimeSeries> allSeries = new ArrayList<FloatMjdTimeSeries>();
        for (int module : FcConstants.modulesList) {
            for (int output : FcConstants.outputsList) {
                BinaryTableHDU pmrfTable = (BinaryTableHDU) pmrf.readHDU();
                short[] rows = (short[]) pmrfTable.getColumn(0);
                short[] cols = (short[]) pmrfTable.getColumn(1);

                for (int i = 0; i < rows.length; i++) {
                    FsId crFsId = PaFsIdFactory.getCosmicRaySeriesFsId(
                        targetTableType, module, output, rows[i], cols[i]);
                    FloatMjdTimeSeries raySeries = new FloatMjdTimeSeries(
                        crFsId, 0.0, Double.MAX_VALUE, mjd, rays, originators,
                        true);
                    allSeries.add(raySeries);
                }
            }
        }

        fileStore.writeMjdTimeSeries(allSeries.toArray(new FloatMjdTimeSeries[0]));
    }

    private void storeVisiblePixels(TargetType targetTableType, File pmrfFile,
        int pixelValue, int cadenceStart, int cadenceEnd) throws Exception {

        int cadenceLen = cadenceEnd - cadenceStart + 1;
        int[] origValue = new int[cadenceLen];
        Arrays.fill(origValue, pixelValue);
        float[] calValue = new float[cadenceLen];
        Arrays.fill(calValue, pixelValue);
        float[] uncertValue = new float[cadenceLen];
        fillRandom(10, uncertValue);
        Fits pmrf = new Fits(pmrfFile);

        List<SimpleInterval> valid = Arrays.asList(new SimpleInterval[] { new SimpleInterval(
            cadenceStart, cadenceEnd) });

        List<TaggedInterval> origin = new ArrayList<TaggedInterval>();
        for (int cadenceNo = cadenceStart; cadenceNo <= cadenceEnd; cadenceNo++) {
            origin.add(new TaggedInterval(cadenceNo, cadenceNo,
                cadenceNoToTaskId.get(cadenceNo)));
        }

        pmrf.readHDU();
        for (int module : FcConstants.modulesList) {
            for (int output : FcConstants.outputsList) {
                BinaryTableHDU pmrfTable = (BinaryTableHDU) pmrf.readHDU();
                short[] rows = (short[]) pmrfTable.getColumn(0);
                short[] cols = (short[]) pmrfTable.getColumn(1);
                for (int i = 0; i < rows.length; i++) {
                    FsId original = DrFsIdFactory.getSciencePixelTimeSeries(
                        DrFsIdFactory.TimeSeriesType.ORIG, targetTableType,
                        module, output, rows[i], cols[i]);
                    
                    FsId calibrated = CalFsIdFactory.getTimeSeriesFsId(
                        CalFsIdFactory.PixelTimeSeriesType.SOC_CAL, targetTableType,
                        module, output, rows[i], cols[i]);
                    FsId uncert = CalFsIdFactory.getTimeSeriesFsId(
                    		CalFsIdFactory.PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES,
                    		targetTableType, module, output, rows[i], cols[i]);

                    IntTimeSeries ots = new IntTimeSeries(original, origValue,
                        cadenceStart, cadenceEnd, valid, origin);
                    FloatTimeSeries calts = new FloatTimeSeries(calibrated,
                        calValue, cadenceStart, cadenceEnd, valid, origin);
                    FloatTimeSeries umm = new FloatTimeSeries(uncert, uncertValue,
                    		cadenceStart, cadenceEnd, valid, origin);

                    fileStore.writeTimeSeries(new TimeSeries[] { ots, calts, umm });

                }
            }
        }
    }
    
    private void fillRandom(int init, float[] values) {
    	Random r = new Random(init);
    	for (int i=0; i < values.length; i++) {
    		values[i] = r.nextFloat();
    	}
	}


    private void storeCollateralCosmicRays(File pmrfFile, int cadenceTypeInt,
        int cadenceStart, int cadenceEnd, MjdToCadence mjdToCadence)
        throws FitsException, IOException {

        Fits pmrf = new Fits(pmrfFile);

        int cadenceLen = cadenceEnd - cadenceStart + 1;
        Cadence.CadenceType cadenceType = Cadence.CadenceType.valueOf(cadenceTypeInt);
        long[] originators = new long[cadenceLen];
        float[] rays = new float[cadenceLen];
        Arrays.fill(rays, 1.0f);
        double[] mjd = new double[cadenceLen];
        for (int cadenceNo = cadenceStart; cadenceNo <= cadenceEnd; cadenceNo++) {
            int arrayIndex = cadenceNo - cadenceStart;
            mjd[arrayIndex] = mjdToCadence.cadenceToMjd(cadenceNo);
            originators[arrayIndex] = cadenceNoToTaskId.get(cadenceNo);
        }

        List<FloatMjdTimeSeries> allRays = new ArrayList<FloatMjdTimeSeries>();

        pmrf.readHDU();
        for (int module : FcConstants.modulesList) {
            for (int output : FcConstants.outputsList) {
                BinaryTableHDU pmrfTable = (BinaryTableHDU) pmrf.readHDU();
                byte[] colType = (byte[]) pmrfTable.getColumn(0);
                short[] offset = (short[]) pmrfTable.getColumn(1);

                for (int i = 0; i < colType.length; i++) {
                    CollateralType collateralType = CollateralType.valueOf(colType[i]);
                    FsId rayId = CalFsIdFactory.getCosmicRaySeriesFsId(
                        collateralType, cadenceType, module, output, offset[i]);
                    FloatMjdTimeSeries raySeries = new FloatMjdTimeSeries(
                        rayId, 0.0, Double.MAX_VALUE, mjd, rays, originators,
                        true);
                    allRays.add(raySeries);
                }
            }
        }

        fileStore.writeMjdTimeSeries(allRays.toArray(new FloatMjdTimeSeries[0]));

    }

    private void storeCollateralPixels(File pmrfFile, int cadenceTypeInt,
        int cadenceStart, int cadenceEnd) throws Exception {

        Fits pmrf = new Fits(pmrfFile);

        int cadenceLen = cadenceEnd - cadenceStart + 1;
        int[] origValue = new int[cadenceLen];
        Arrays.fill(origValue, 5);

        float[] calValue = new float[cadenceLen];
        Arrays.fill(calValue, 4.0f);
        pmrf.readHDU();
        
        float[] uncertValue = new float[cadenceLen];
        fillRandom(10, uncertValue);
        
        Cadence.CadenceType cadenceType = Cadence.CadenceType.valueOf(cadenceTypeInt);

        List<SimpleInterval> valid = Arrays.asList(new SimpleInterval[] { new SimpleInterval(
            cadenceStart, cadenceEnd) });

        List<TaggedInterval> origin = new ArrayList<TaggedInterval>();
        for (int cadenceNo = cadenceStart; cadenceNo <= cadenceEnd; cadenceNo++) {
            origin.add(new TaggedInterval(cadenceNo, cadenceNo,
                cadenceNoToTaskId.get(cadenceNo)));
        }

        for (int module : FcConstants.modulesList) {
            for (int output : FcConstants.outputsList) {
                BinaryTableHDU pmrfTable = (BinaryTableHDU) pmrf.readHDU();
                byte[] colType = (byte[]) pmrfTable.getColumn(0);
                short[] offset = (short[]) pmrfTable.getColumn(1);

                for (int i = 0; i < colType.length; i++) {

                    DrFsIdFactory.TimeSeriesType timeSeriesType = DrFsIdFactory.TimeSeriesType.ORIG;
                    CollateralType collateralType = CollateralType.valueOf(colType[i]);

                    FsId orig = DrFsIdFactory.getCollateralPixelTimeSeries(
                        timeSeriesType, cadenceType, collateralType, module,
                        output, offset[i]);
                    
                    FsId cal = CalFsIdFactory.getCalibratedCollateralFsId(collateralType,
                        CalFsIdFactory.PixelTimeSeriesType.SOC_CAL, cadenceType, 
                        module, output, offset[i]);
                    
                    FsId uncert = CalFsIdFactory.getCalibratedCollateralFsId(collateralType,
                    		CalFsIdFactory.PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES,
                    		cadenceType, module, output, offset[i]);

                    IntTimeSeries origt = new IntTimeSeries(orig, origValue,
                        cadenceStart, cadenceEnd, valid, origin);

                    FloatTimeSeries calt = new FloatTimeSeries(cal, calValue, 
                        cadenceStart, cadenceEnd, valid, origin);
                    
                    FloatTimeSeries uncertt = new FloatTimeSeries(uncert, 
                    		uncertValue, cadenceStart, cadenceEnd, valid, origin);
                    
                    fileStore.writeTimeSeries(new TimeSeries[] { origt , calt, uncertt});
                }
            }
        }

    }

    private void storeFile(File f, FileType fileType) throws Exception {
        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        BufferedInputStream bin = new BufferedInputStream(
            new FileInputStream(f));
        long size = f.length();
        byte[] buf = new byte[1024 * 4];
        while (size != 0) {
            int nread = bin.read(buf);
            if (nread <= 0)
                break;
            size -= nread;
            bout.write(buf, 0, nread);
        }
        if (bout.size() != f.length()) {
            throw new IllegalStateException("Was not able to read file \"" + f
                + "\" completely.");
        }

        FsId id = null;
        switch (fileType) {
            case PIXEL_HEADER:
                id = DrFsIdFactory.getPixelFitsHeaderFile(f.getName());
                break;
            case PMRF:
                id = DrFsIdFactory.getPmrfFile(f.getName());
                break;
        }
        fileStore.writeBlob(id, /* taskId */0, bout.toByteArray());
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        if (fileStore != null) {
            ((FileStoreTestInterface) fileStore).cleanFileStore();
        }
        DatabaseServiceFactory.getInstance(false).closeCurrentSession();
        DatabaseServiceFactory.getInstance(false).getDdlInitializer().cleanDB();
        FileUtil.cleanDir(testOut);
    }

    @Test
    public void calibratedPixelCliTest() throws Exception {

        TestSystemProvider system = new TestSystemProvider(testOut);
        CalibratedPixelExportCli cli = new CalibratedPixelExportCli(system);

        String outputDir = "-o " + testOut;
        String begin = "-b " + CADENCE_START;
        String end = "-e " + CADENCE_END;
        String nthreads = "-t 1";
        String chunkSize = "-c 2000";
        cli.execute(new String[] { outputDir, begin, end, nthreads, chunkSize });

        validateOutput();
        assertEquals(0, system.returnCode());

    }
    
    @Test
    public void calibratedPixelCliShortCadenceOnly() throws Exception {
        calibratedPixelSingleCadenceType(true);
    }
    
    @Test
    public void calibratedPixelCliLongCadenceOnly() throws Exception {
        calibratedPixelSingleCadenceType(false);
    }
    
    
    private void calibratedPixelSingleCadenceType(boolean isShortCadence) throws Exception {
        TestSystemProvider system = new TestSystemProvider(testOut);
        CalibratedPixelExportCli cli = new CalibratedPixelExportCli(system);
         
        String outputDir = "-o " + testOut;
        String begin = "-b " + CADENCE_START;
        String end = "-e " + CADENCE_END;
        String nthreads = "-t 1";
        String chunkSize = "-c 2000";
        String shortCadenceOnly =  (isShortCadence) ? "-s" : "-l";
        cli.execute(new String[] { outputDir, begin, end, nthreads, chunkSize, shortCadenceOnly });
        
        assertEquals(0, system.returnCode());
        
        
        for (String fname : pixelFileNames) {
            File testFile = new File(testOut, fname);
            File srcFile = new File(testDataDir, fname);
            
            if (!(isNameShortCadence(fname) ^ isShortCadence)) {
                String difference  = diff(testFile, srcFile);
                assertEquals("Files \"" + testFile + "\" and  \"" + srcFile
                    + "\" differ.\n" + difference, null, difference);
            } else {
                assertFalse("LC files should not existing when exporting SC.", testFile.exists());
            }
        }
        
        File testSCProcessingHistoryFile = new File(testOut,
            SC_PROCESSING_HISTORY_NAME);
        File testLCProcessingHistoryFile = new File(testOut, LC_PROCESSING_HISTORY_NAME);
        
        if (isShortCadence) {
            assertFalse("Processing history file must not exist when exporting opposite cadence.", 
                testLCProcessingHistoryFile.exists());

            assertTrue(checkProcessingHistory(testSCProcessingHistoryFile, true));
        } else {
            assertFalse("Processing history file must not exist when exporting opposite cadence.", 
                testSCProcessingHistoryFile.exists());

            assertTrue(checkProcessingHistory(testLCProcessingHistoryFile, false));
        }
    }

    @Test
    public void testCalibratedPixelExporterNoCli() throws Exception {
        TransactionService xService = TransactionServiceFactory.getInstance();
        xService.beginTransaction();
        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        DataAccountabilityTrailCrud acctCrud = new DataAccountabilityTrailCrud(
            dbService);
        PipelineTaskCrud taskCrud = new PipelineTaskCrud(dbService);

        CalibratedPixelExporter exporter = new CalibratedPixelExporter(
            fileStore, acctCrud, taskCrud, new AlertLogCrud(),
            new FcCrud());
        exporter.export(CADENCE_START, CADENCE_END, testOut, CadenceOption.ALL);

        xService.commitTransaction();

        validateOutput();
    }

    private boolean isNameShortCadence(String fname) {
        return fname.contains("scs");
    }
    
    /**
     * @throws Exception
     */
    private void validateOutput() throws Exception {
        for (String fname : pixelFileNames) {
            File testFile = new File(testOut, fname);
            File srcFile = new File(testDataDir, fname);
            String difference = diff(testFile, srcFile);
            assertEquals("Files \"" + testFile + "\" and  \"" + srcFile
                + "\" differ.\n" + difference, null, difference);
        }

        File testLCProcessingHistFile = new File(testOut,
            LC_PROCESSING_HISTORY_NAME);
        File testSCProcessingHistFile = new File(testOut,
            SC_PROCESSING_HISTORY_NAME);

        assertTrue(checkProcessingHistory(testLCProcessingHistFile, false));
        assertTrue(checkProcessingHistory(testSCProcessingHistFile, true));
    }

    private boolean checkProcessingHistory(File historyFile,
        boolean shortCadence) throws Exception {
        
        StringBuilder bldr = new StringBuilder();
        BufferedInputStream bin = new BufferedInputStream(new FileInputStream(
            historyFile));
        FileUtil.readAll(bldr, bin);
        bin.close();
        String fileStr = bldr.toString();

        int cadenceOne = (shortCadence) ? 30 : 1;
        int cadenceTwo = (shortCadence) ? 31 : 2;
        int taskIdOne = (shortCadence) ? 3 : 1;
        int taskIdTwo = (shortCadence) ? 4 : 2;
        String historyFmt = 
            "TaskId: %d Module Software Revision: %s ModuleDef%d  UoW: null";
        String expectOne = String.format(historyFmt, taskIdOne, SOFTWARE_REVISION, cadenceOne);
        String expectTwo = String.format(historyFmt, taskIdTwo, SOFTWARE_REVISION, cadenceTwo);
        
        return fileStr.contains(expectOne) || fileStr.contains(expectTwo);

    }

    /**
     * 
     * @param f1
     * @return non-null if files differ.
     */
    private String diff(final File f1, final File f2) throws Exception {
        // ORIGN keyword may differ
        FitsDiff fitsDiff = new FitsDiff() {
            @Override
            protected String diffHeaderCard(HeaderCard card1, HeaderCard card2) {
                String keyword = card1.getKey();
                if (keyword.equals(ORIGIN_KW)) {
                    return null;
                }
                if (f1.getName().indexOf("scs") != -1) {
                    //These should have been fixed up for short cadence.
                    if (keyword.equals(LCTRGDEF_KW)) {
                        int lcTargetTable1 = Integer.parseInt(card1.getValue());
                        if (lcTargetTable1 != 3) {
                            return "Test: expected long cadence target table 3";
                        }
                        return null;
                    }
                    if (keyword.equals(BKTRGDEF_KW)) {
                        int bkgTargetTable1 = Integer.parseInt(card1.getValue());
                        if (bkgTargetTable1 != 2) {
                            return "Test: expected background target table 2";
                        }
                        return null;
                    }
                    if (keyword.equals(BKG_APER_KW)) {
                        int bkgApertureTable1 = Integer.parseInt(card1.getValue());
                        if (bkgApertureTable1 != 1) {
                            return "Test: expected background aperture table 1";
                        }
                        return null;
                    }
                }
                return super.diffHeaderCard(card1, card2);
            }
            
            @Override
            protected boolean isDiffOk(String keyword) {
                return keyword.equals("COMMENT");
            }
        };

        List<String> differences = new ArrayList<String>();
        boolean isDiff = fitsDiff.diff(f1, f2, differences);
        if (!isDiff) {
            return null;
        }
        StringBuilder bldr = new StringBuilder();
        for (String s : differences) {
            bldr.append(s).append("\n");
        }

        return bldr.toString();
    }
}
