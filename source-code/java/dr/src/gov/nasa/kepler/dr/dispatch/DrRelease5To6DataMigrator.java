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

package gov.nasa.kepler.dr.dispatch;

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.AncillaryLog;
import gov.nasa.kepler.hibernate.dr.AncillaryLogCrud;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.hibernate.dr.FileLog;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;

import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Query;

/**
 * This class migrates the dr portion of the database from release 5 data to
 * release 6 data. On the ops cluster, this should be run exactly once:
 * immediately after the ops database schema is migrated from release 5 to
 * release 6.
 * 
 * @author Miles Cote
 * 
 */
public class DrRelease5To6DataMigrator {

    private static final Log log = LogFactory.getLog(DrRelease5To6DataMigrator.class);

    public void migrateDispatchLogs() {
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        try {
            databaseService.beginTransaction();

            log.info("Setting dispatchLog.state and initializing totalFileCount to 0.");
            Query query = databaseService.getSession()
                .createSQLQuery(
                    "update DR_DISPATCH_LOG set total_file_count = 0");
            query.executeUpdate();
            query = databaseService.getSession()
                .createSQLQuery("update DR_DISPATCH_LOG set state = 0");
            query.executeUpdate();

            LogCrud logCrud = new LogCrud();
            List<DispatchLog> dispatchLogs = logCrud.retrieveAllDispatchLogs();
            for (DispatchLog dispatchLog : dispatchLogs) {
                dispatchLog.setTotalFileCount(0);
                dispatchLog.setState(dispatchLog.getReceiveLog()
                    .getState());
            }

            log.info("Counting fileLogs.");
            List<FileLog> fileLogs = logCrud.retrieveAllFileLogs();
            for (FileLog fileLog : fileLogs) {
                DispatchLog dispatchLog = fileLog.getDispatchLog();
                dispatchLog.setTotalFileCount(dispatchLog.getTotalFileCount() + 1);
            }
            databaseService.flush();
            databaseService.evictAll(fileLogs);

            log.info("Counting pixelLogs.");
            List<PixelLog> pixelLogs = logCrud.retrieveAllPixelLogs();
            for (PixelLog pixelLog : pixelLogs) {
                DispatchLog dispatchLog = pixelLog.getDispatchLog();
                dispatchLog.setTotalFileCount(dispatchLog.getTotalFileCount() + 1);
            }
            databaseService.flush();
            databaseService.evictAll(pixelLogs);

            log.info("Counting ancillaryLogs.");
            AncillaryLogCrud ancillaryLogCrud = new AncillaryLogCrud();
            List<AncillaryLog> ancillaryLogs = ancillaryLogCrud.retrieveAllAncillaryLogs();
            for (AncillaryLog ancillaryLog : ancillaryLogs) {
                DispatchLog dispatchLog = ancillaryLog.getDispatchLog();
                dispatchLog.setTotalFileCount(dispatchLog.getTotalFileCount() + 1);
            }
            databaseService.flush();
            databaseService.evictAll(ancillaryLogs);

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    public static void main(String[] args) {
        DrRelease5To6DataMigrator migrator = new DrRelease5To6DataMigrator();
        migrator.migrateDispatchLogs();
    }

}
