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

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.services.metrics.logger.MetricsLogger;
import gov.nasa.spiffy.common.metrics.ValueMetric;
import junit.framework.TestCase;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.xml.DOMConfigurator;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

public class ProcessStatusLoggerTest extends TestCase {
    private static final String METRIC_NAME = "test.valuemetric.name";
    private static final Log log = LogFactory.getLog(ProcessStatusLoggerTest.class);

	public static void main(String[] args) {
		DOMConfigurator.configure("config/log4j.xml");
		junit.textui.TestRunner.run(ProcessStatusLoggerTest.class);
	}

	private void deleteAll( Session session ){
		Transaction tx=session.getTransaction();
		
		try{
		    tx.begin();

			// delete all MetricValue
            Query q = session.createQuery("delete from MetricValue");
			q.executeUpdate();
            
			tx.commit();
		}finally{
		    if (tx.isActive()){
		        tx.rollback();
		    }
		}	
	}
	
	/*
	 * Test method for 'gov.nasa.kepler.pipeline.ui.metrilyzer.ProcessStatusLogger.storeMetric(PersistenceManager, String, long, Metric)'
	 */
	public void testStoreMetric() throws Exception {
		
		MetricsLogger logger = new MetricsLogger();
		DatabaseService ds = DatabaseServiceFactory.getInstance();
		Session session = ds.getSession();
		
		log.debug("deleting...");
		deleteAll( session );
		
		logger.loadTypes();
		
		// batch 1
		for (int i = 0; i < 10; i++) {
			log.debug("batch 1, sample " + i );
			ValueMetric.addValue(METRIC_NAME, 10);
			ds.beginTransaction();
			//logger.storeMetric("process", System.currentTimeMillis(), metric );
			ds.commitTransaction();
			Thread.sleep(1000);
		}

		log.debug("repeating for 10...");
		for (int i = 0; i < 10; i++) {
			log.debug("quiet time, sample " + i );
			ds.beginTransaction();
			//logger.storeMetric("process", System.currentTimeMillis(), metric );
			ds.commitTransaction();
			Thread.sleep(1000);
		}

		// batch 2
		for (int i = 0; i < 10; i++) {
			log.debug("batch 2, sample " + i );
            ValueMetric.addValue(METRIC_NAME, 100);
			ds.beginTransaction();
			//logger.storeMetric("process", System.currentTimeMillis(), metric );
			ds.commitTransaction();
			Thread.sleep(1000);
		}
	}
}
