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

package gov.nasa.kepler.mc.fc;

import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fc.importer.ImporterGeometry;
import gov.nasa.kepler.fc.importer.ImporterPointing;
import gov.nasa.kepler.fc.importer.ImporterRollTime;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.FileLog;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.ReceiveLog;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;

import java.io.File;
import java.io.IOException;
import java.util.Date;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class TestsRaDec2PixModel {
    private static DdlInitializer ddlInitializer;
    private static DatabaseService dbService;
	private static FileStoreClient fsClient;
    
    @Before
    public void setUp() throws IOException {
        dbService = DatabaseServiceFactory.getInstance();
        fsClient = FileStoreClientFactory.getInstance();

        ddlInitializer = dbService.getDdlInitializer();
        ddlInitializer.initDB();
        
        try {
			dbService.beginTransaction();
            fsClient.beginLocalFsTransaction();
            
            new ImporterGeometry().rewriteHistory("TestsRaDec2PixModel geometry");
            new ImporterRollTime().rewriteHistory("TestsRaDec2PixModel roll time");
            new ImporterPointing().rewriteHistory("TestsRaDec2PixModel pointing");
            
            DispatcherType[] dispatcherTypes = { 
            		DispatcherType.LEAP_SECONDS,
					DispatcherType.PLANETARY_EPHEMERIS,
					DispatcherType.SPACECRAFT_EPHEMERIS };

            String[] filenames = {
            		"naif0009.tls",
            		"de405.bsp",
            		"spk_2009065045522_2009008233141_kplr.bsp"};
            
            String[] sourceDirectorys = {
                    SocEnvVars.getLocalDataDir() + "/moc/leap-seconds/latest/",
            		SocEnvVars.getLocalDataDir() + "/moc/planetary-ephemeris/latest/",
            		SocEnvVars.getLocalDataDir() + "/moc/spacecraft-ephemeris/latest/" };
            
            FsId[] fsIds = new FsId[3];
            ReceiveLog recieveLog = new ReceiveLog(new Date(), "test1", "test2");
            DispatchLog[] dispatchLogs = new DispatchLog[3];
            FileLog[] fileLogs = new FileLog[3];
            LogCrud logCrud = new LogCrud();
            logCrud.createReceiveLog(recieveLog);
            
            for (int ii = 0; ii < 3; ++ii) {
            	fsIds[ii] = DrFsIdFactory.getFile(dispatcherTypes[ii], filenames[ii]);
            	fsClient.writeBlob(fsIds[ii], 0, new File(sourceDirectorys[ii] + File.separator + filenames[ii]));
            	dispatchLogs[ii] = new DispatchLog(recieveLog, dispatcherTypes[ii]);
                fileLogs[ii] = new FileLog(dispatchLogs[ii], filenames[ii]);
            	logCrud.createDispatchLog(dispatchLogs[ii]);
            	logCrud.createFileLog(fileLogs[ii]);
            }
            
            fsClient.commitLocalFsTransaction();
            dbService.commitTransaction();
        } finally {   
        	fsClient.rollbackLocalFsTransactionIfActive();
        	dbService.rollbackTransactionIfActive();
        }
    }

    @After
    public void destroyDatabase() {
        dbService.closeCurrentSession();
        ddlInitializer.cleanDB();
    }
    
//    @Test
//    public void testOperationsWrapper() {
//        double mjdStart = 55000.0;
//        double mjdEnd = 56000.0;
//        
//        RaDec2PixOperations ops = new RaDec2PixOperations();
//        RaDec2PixModel model = ops.retrieveRaDec2PixModel(mjdStart, mjdEnd);
//        
//        boolean isGeometryContained = 
//            (model.getGeometryModel().getMjds())[0] <=  mjdStart &&
//            (model.getGeometryModel().getMjds())[model.getGeometryModel().size()-1] <= mjdEnd;
//        assertTrue(isGeometryContained);
//        
//        boolean isPointingBracketed = 
//            (model.getPointingModel().getMjds())[0] <=  mjdStart &&
//            (model.getPointingModel().getMjds())[model.getPointingModel().size()-1] >= mjdEnd;
//        assertTrue(isPointingBracketed);
//    }
    
    @Test
    public void testCall() {
        RaDec2PixOperations raDec2PixOperations = new RaDec2PixOperations();
        @SuppressWarnings("unused")
		RaDec2PixModel raDec2PixModel = raDec2PixOperations.retrieveRaDec2PixModel(55100, 55200);
        assertTrue(true);
    }
    
    @Test
    public void testDefaultConstructor() {
        @SuppressWarnings("unused")
		RaDec2PixModel model = (new RaDec2PixOperations()).retrieveRaDec2PixModel();
        assertTrue(true);
    }
    
    @Test
    public void testDefaultConstructor2() {
        RaDec2PixOperations ops = new RaDec2PixOperations();
        RaDec2PixModel model = ops.retrieveRaDec2PixModel();
        assertTrue(model.getMjdEnd() >= model.getMjdStart());
    }
    
}
