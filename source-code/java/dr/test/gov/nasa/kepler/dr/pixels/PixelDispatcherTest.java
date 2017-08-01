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

package gov.nasa.kepler.dr.pixels;

import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.common.FilenameConstants;
import gov.nasa.kepler.dr.dispatch.DispatchException;
import gov.nasa.kepler.dr.dispatch.DispatcherAbstractTest;
import gov.nasa.kepler.dr.dispatch.NotificationMessageHandler;
import gov.nasa.kepler.dr.dispatch.PipelineLauncher;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreTestInterface;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.dr.ReceiveLog;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.services.AlertLog;
import gov.nasa.kepler.hibernate.services.AlertLogCrud;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.fs.DrFsIdFactory.TimeSeriesType;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import junit.framework.Assert;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class PixelDispatcherTest extends DispatcherAbstractTest {

    private static final CollateralType COLLATERAL_TYPE = CollateralType.MASKED_SMEAR;
    private static final int TARGET_RAW_PIXEL_VALUE = 42;
    private static final int BACKGROUND_RAW_PIXEL_VALUE = 43;
    private static final int COLLATERAL_RAW_PIXEL_VALUE = 44;
    private static final int CADENCE_END = 0;
    private static final int CADENCE_START = 0;
    private static final int KEPLER_ID = 1;
    private static final int CCD_OUTPUT = 1;
    private static final int CCD_MODULE = 2;
    private static final int VISIBLE_OFFSET_COLUMN = 500;
    private static final int VISIBLE_OFFSET_ROW = 500;
    private static final int COLLATERAL_OFFSET_COLUMN = 12;
    private static final int COLLATERAL_OFFSET_ROW = 12;
    private static final String SC_TLS_NAME = "scTls2";
    private static final String BG_TLS_NAME = "bgTls2";
    private static final String LC_TLS_NAME = "lcTls2";
    private static final int EXTERNAL_ID = 1;

    private DatabaseService databaseService;
    private FileStoreClient fsClient;
    private LogCrud logCrud;
    private NotificationMessageHandler handler;
    private ReceiveLog receiveLog;
    private ReflectionEquals reflectionEquals;
    private TargetCrud targetCrud;
    private TargetSelectionCrud targetSelectionCrud;

    @Before
    public void setUp() throws Exception {
        FileUtil.cleanDir(FilenameConstants.ACTIVEMQ_DATA);

        DefaultProperties.setPropsForUnitTest();
        TestUtils.setUpDatabase(DatabaseServiceFactory.getInstance());
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(DatabaseServiceFactory.getInstance());
    }

    protected void populateObjects() throws IOException {
        databaseService = DatabaseServiceFactory.getInstance();
        fsClient = FileStoreClientFactory.getInstance();
        logCrud = new LogCrud(databaseService);
        alertLogCrud = new AlertLogCrud(databaseService);

        ((FileStoreTestInterface) fsClient).cleanFileStore();

        databaseService.beginTransaction();
        receiveLog = new ReceiveLog(new Date(), null, null);
        logCrud.createReceiveLog(receiveLog);
        databaseService.commitTransaction();

        handler = new NotificationMessageHandler();
        handler.setReceiveLog(receiveLog);

        reflectionEquals = new ReflectionEquals();
        reflectionEquals.excludeField(".*\\.tadReport");

        seedTad();

        receivePmrfs();
    }

    public void seedTad() {
        databaseService = DatabaseServiceFactory.getInstance();
        targetCrud = new TargetCrud(databaseService);
        targetSelectionCrud = new TargetSelectionCrud(databaseService);

        TargetListSet lcTls = seedTargetListSet(LC_TLS_NAME,
            TargetType.LONG_CADENCE, MaskType.TARGET);
        TargetListSet bgTls = seedTargetListSet(BG_TLS_NAME,
            TargetType.BACKGROUND, MaskType.BACKGROUND);
        TargetListSet scTls = seedTargetListSet(SC_TLS_NAME,
            TargetType.SHORT_CADENCE, MaskType.TARGET);

        // Reassign background table to the lcTls.
        databaseService.beginTransaction();
        lcTls.setBackgroundTable(bgTls.getTargetTable());
        databaseService.commitTransaction();

        // Reassign mask table and make one table not uplinked.
        databaseService.beginTransaction();
        scTls.getTargetTable()
            .getMaskTable()
            .setState(State.LOCKED);
        scTls.getTargetTable()
            .setMaskTable(lcTls.getTargetTable()
                .getMaskTable());
        databaseService.commitTransaction();
    }

    private TargetListSet seedTargetListSet(String name, TargetType targetType,
        MaskType maskType) {
        MaskTable maskTable = new MaskTable(maskType);
        maskTable.setState(State.UPLINKED);
        maskTable.setExternalId(EXTERNAL_ID);

        ArrayList<Offset> offsets = new ArrayList<Offset>();
        offsets.add(new Offset(VISIBLE_OFFSET_ROW, VISIBLE_OFFSET_COLUMN));

        ArrayList<Mask> masks = new ArrayList<Mask>();
        Mask mask = new Mask(maskTable, offsets);
        masks.add(mask);

        TargetListSet targetListSet = new TargetListSet(name);

        TargetTable targetTable = new TargetTable(targetType);
        targetTable.setState(State.UPLINKED);
        targetTable.setExternalId(EXTERNAL_ID);
        targetTable.setMaskTable(maskTable);

        targetListSet.setTargetTable(targetTable);

        ArrayList<ObservedTarget> observedTargets = new ArrayList<ObservedTarget>();
        ObservedTarget observedTarget = new ObservedTarget(targetTable,
            CCD_MODULE, CCD_OUTPUT, KEPLER_ID);
        observedTargets.add(observedTarget);

        ArrayList<TargetDefinition> targetDefs = new ArrayList<TargetDefinition>();
        TargetDefinition targetDef = new TargetDefinition(observedTarget);
        targetDef.setMask(mask);
        targetDefs.add(targetDef);

        observedTarget.getTargetDefinitions()
            .add(targetDef);

        // Store objects.
        databaseService.beginTransaction();
        targetCrud.createMaskTable(maskTable);
        targetCrud.createMasks(masks);
        targetCrud.createTargetTable(targetTable);
        targetSelectionCrud.create(targetListSet);
        targetCrud.createObservedTargets(observedTargets);
        databaseService.commitTransaction();

        return targetListSet;
    }

    private void receivePmrfs() {
        // PmrfDispatcher pmrfDispatcher = null;
        //
        // pmrfDispatcher = new LongCadenceTargetPmrfDispatcher(SOURCE_DIR,
        // handler);
        // dispatchPmrf(pmrfDispatcher, LCM_FILENAME);
        //
        // pmrfDispatcher = new LongCadenceCollateralPmrfDispatcher(SOURCE_DIR,
        // handler);
        // dispatchPmrf(pmrfDispatcher, LCC_FILENAME);
        //
        // pmrfDispatcher = new BackgroundPmrfDispatcher(SOURCE_DIR, handler);
        // dispatchPmrf(pmrfDispatcher, BGM_FILENAME);
        //
        // pmrfDispatcher = new ShortCadenceTargetPmrfDispatcher(SOURCE_DIR,
        // handler);
        // dispatchPmrf(pmrfDispatcher, SCM_FILENAME);
        //
        // pmrfDispatcher = new ShortCadenceCollateralPmrfDispatcher(SOURCE_DIR,
        // handler);
        // dispatchPmrf(pmrfDispatcher, SCC_FILENAME);
    }

    // private void dispatchPmrf(PmrfDispatcher dispatcher, String filename) {
    // // Dispatch.
    // databaseService.beginTransaction();
    // fsClient.beginLocalFsTransaction();
    //
    // // dispatcher.addFileName(filename);
    // // dispatcher.dispatch();
    //
    // fsClient.commitLocalFsTransaction();
    // databaseService.commitTransaction();
    // }

    @Test
    public void testLongCadenceDispatch() throws Exception {
        populateObjects();

        // dispatcher = new LongCadencePixelDispatcher(SOURCE_DIR, handler);

        mockPipelineLauncher = mock(PipelineLauncher.class);

        // oneOf(mockPipelineLauncher).launch(dispatcher);

        // Dispatch.
        fsClient.beginLocalFsTransaction();

        // dispatcher.addFileName(LCS_TARG_FILENAME);
        // dispatcher.addFileName(LCS_COL_FILENAME);
        // dispatcher.addFileName(LCS_BKG_FILENAME);
        // dispatcher.dispatch();

        fsClient.commitLocalFsTransaction();

        // Check targ.
        checkDatabaseAndFilestore(TargetType.LONG_CADENCE, VISIBLE_OFFSET_ROW,
            VISIBLE_OFFSET_COLUMN, TARGET_RAW_PIXEL_VALUE,
            Cadence.CADENCE_LONG, false);

        // Check col.
        checkDatabaseAndFilestore(TargetType.LONG_CADENCE,
            COLLATERAL_OFFSET_ROW, COLLATERAL_OFFSET_COLUMN,
            COLLATERAL_RAW_PIXEL_VALUE, Cadence.CADENCE_LONG, true);

        // Check bkg.
        checkDatabaseAndFilestore(TargetType.BACKGROUND, VISIBLE_OFFSET_ROW,
            VISIBLE_OFFSET_COLUMN, BACKGROUND_RAW_PIXEL_VALUE,
            Cadence.CADENCE_LONG, false);

        // Check alerts.
        List<AlertLog> alertLogs = alertLogCrud.retrieve(new Date(0),
            new Date());
        Assert.assertEquals(0, alertLogs.size());
    }

    private void checkDatabaseAndFilestore(TargetType targetType,
        int offsetRow, int offsetColumn, int pixelValue, int cadenceType,
        boolean isCollateral) {
        FsId fsId = null;

        if (isCollateral) {
            fsId = DrFsIdFactory.getCollateralPixelTimeSeries(
                TimeSeriesType.ORIG, CadenceType.valueOf(cadenceType),
                COLLATERAL_TYPE, CCD_MODULE, CCD_OUTPUT, offsetRow);
        } else {
            fsId = DrFsIdFactory.getSciencePixelTimeSeries(TimeSeriesType.ORIG,
                targetType, CCD_MODULE, CCD_OUTPUT, offsetRow, offsetColumn);
        }

        FsId[] fsIds = { fsId };
        IntTimeSeries[] seriesArray = fsClient.readTimeSeriesAsInt(fsIds,
            CADENCE_START, CADENCE_END);
        Assert.assertEquals(1, seriesArray.length);

        IntTimeSeries series = seriesArray[0];
        Assert.assertEquals(1, series.cadenceLength());

        int[] iseries = series.iseries();
        Assert.assertEquals(1, iseries.length);
        Assert.assertEquals(pixelValue, iseries[0]);

        List<PixelLog> pixelLogs = logCrud.retrievePixelLog(cadenceType, -100,
            100);
        Assert.assertEquals(EXTERNAL_ID, pixelLogs.get(0)
            .getLcTargetTableId());
    }

    @Test
    public void testShortCadenceDispatch() throws Exception {
        populateObjects();

        // dispatcher = new ShortCadencePixelDispatcher(SOURCE_DIR, handler);

        mockPipelineLauncher = mock(PipelineLauncher.class);

        // oneOf(mockPipelineLauncher).launch(dispatcher);

        // Dispatch.
        fsClient.beginLocalFsTransaction();

        // dispatcher.addFileName(SCS_TARG_FILENAME);
        // dispatcher.addFileName(SCS_COL_FILENAME);
        // dispatcher.dispatch();

        fsClient.commitLocalFsTransaction();

        // Check targ.
        checkDatabaseAndFilestore(TargetType.SHORT_CADENCE, VISIBLE_OFFSET_ROW,
            VISIBLE_OFFSET_COLUMN, TARGET_RAW_PIXEL_VALUE,
            Cadence.CADENCE_SHORT, false);

        // Check col.
        checkDatabaseAndFilestore(TargetType.SHORT_CADENCE,
            COLLATERAL_OFFSET_ROW, COLLATERAL_OFFSET_COLUMN,
            COLLATERAL_RAW_PIXEL_VALUE, Cadence.CADENCE_SHORT, true);

        // Check alerts.
        List<AlertLog> alertLogs = alertLogCrud.retrieve(new Date(0),
            new Date());
        Assert.assertEquals(0, alertLogs.size());
    }

    @Test(expected = DispatchException.class)
    public void attemptToDispatchNullFile() throws Exception {
        populateObjects();

        // dispatcher = new LongCadencePixelDispatcher(SOURCE_DIR, handler);
        //
        // dispatcher.addFileName(null);
        // dispatcher.dispatch();
    }

}
