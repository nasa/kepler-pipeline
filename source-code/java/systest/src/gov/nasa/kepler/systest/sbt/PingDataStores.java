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

package gov.nasa.kepler.systest.sbt;

import gov.nasa.kepler.fs.FileStoreConstants;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.KeplerHibernateConfiguration;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.hibernate.Query;
import org.hibernate.Session;

/**
 * Ping the data stores (filestore, database)
 * to verify that they are up.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 * 
 */
public class PingDataStores extends AbstractSbt{
    static final Log log = LogFactory.getLog(PingDataStores.class);

    public PingDataStores() {
    }

    public PingResults ping(boolean requireDatabase, boolean requireFilestore){
                
        PingResults pingResults = new PingResults(requireDatabase, requireFilestore);

        if(requireDatabase){
            pingDatabase(pingResults);
        }

        if(requireFilestore){
            pingFilestore(pingResults);
        }
        
        return pingResults;
    }

    private void pingFilestore(PingResults pingResults){
        try {
            pingResults.setFsAvailable(true);
            Configuration config = ConfigurationServiceFactory.getInstance();
            pingResults.setFsUrl(config.getString(FileStoreConstants.FS_FSTP_URL));
            
            log.debug("Pinging filestore at: " + pingResults.getFsUrl());
            
            FileStoreClientFactory.getInstance().close();
            FileStoreClientFactory.getInstance().ping();
        } catch (Exception e) {
            pingResults.setFsAvailable(false);
            StringBuilder sb = new StringBuilder();
            sb.append(e.getMessage());
            Throwable cause = e.getCause();
            while(cause != null){
                sb.append(": " + cause.getMessage());
                cause = cause.getCause();
            }
            pingResults.setFsError(sb.toString());
        }
    }
    
    private void pingDatabase(PingResults pingResults){
        try {
            pingResults.setDbAvailable(true);
            Configuration config = ConfigurationServiceFactory.getInstance();
            pingResults.setDbUrl(config.getString(KeplerHibernateConfiguration.HIBERNATE_CONNECTION_URL_PROP));
            
            log.debug("Pinging database at: " + pingResults.getDbUrl());
            
            Session session = DatabaseServiceFactory.getInstance().getSession();
            session.clear();
            Query query = session.createSQLQuery("select count(*) from PI_MOD_NAME");
            query.list();
        } catch (Exception e) {
            pingResults.setDbAvailable(false);
            pingResults.setDbError(e.getMessage());
        }        
    }

    public boolean validateDatastore(boolean requiresDatabase, boolean requiresFilestore) {
        Level loggingLevel = Logger.getRootLogger().getLevel();
        Logger.getRootLogger().setLevel(Level.OFF);
        try {
            PingResults pingResults = ping(requiresDatabase, requiresFilestore);
            return pingResults.validate();
        } finally {
            Logger.getRootLogger().setLevel(loggingLevel);
        }
    }
}
