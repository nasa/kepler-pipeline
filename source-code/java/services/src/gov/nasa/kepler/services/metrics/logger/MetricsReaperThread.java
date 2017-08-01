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

package gov.nasa.kepler.services.metrics.logger;

import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.metrics.MetricsCrud;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class MetricsReaperThread extends Thread {
    private static final Log log = LogFactory.getLog(MetricsReaperThread.class);

    private static final String CHECK_INTERVAL_MINS_PROP = "pi.metrics.reaper.checkIntervalMins";
    private static final String MAX_ROWS_PROP = "pi.metrics.reaper.maxRows";

    private static final int DEFAULT_CHECK_INTERVAL_MINS = 5;
    private static final int DEFAULT_MAX_ROWS = 10000;
    
    int checkIntervalMillis;
    int maxRows;
    
    private long lastCheck = System.currentTimeMillis();

    public MetricsReaperThread() {
        super("MetricsReaperThread");
        setPriority(Thread.NORM_PRIORITY+1);
    }

    @Override
    public void run(){
        try{
            log.info("MetricsReaperThread: STARTED");
            
            Configuration config = ConfigurationServiceFactory.getInstance();
            checkIntervalMillis = config.getInt(CHECK_INTERVAL_MINS_PROP,
                DEFAULT_CHECK_INTERVAL_MINS) * 60 * 1000;
            maxRows = config.getInt(MAX_ROWS_PROP, DEFAULT_MAX_ROWS);
            
            log.info("MetricsReaperThread: maxRows = " + maxRows);
            log.info("MetricsReaperThread: checkIntervalMillis = " + checkIntervalMillis);
            
            while(true){
                long now = System.currentTimeMillis();
                if((now - lastCheck) > checkIntervalMillis){
                    
                    log.info("MetricsReaperThread: woke up to check rowCount");
                    
                    DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                    databaseService.beginTransaction();
                    
                    MetricsCrud crud = new MetricsCrud();
                    crud.deleteOldMetrics(maxRows);
                    
                    databaseService.commitTransaction();

                    lastCheck = now;

                    log.info("MetricsReaperThread: check complete");
                }
                
                Thread.sleep(1000);
            }
        }catch(Throwable t){
            log.fatal("MetricsReaperThread: caught: ", t);
            System.exit(-1);
        }
    }
}
