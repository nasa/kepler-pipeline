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

package gov.nasa.kepler.services.messaging;

import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Properties;

import junit.framework.TestCase;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.xml.DOMConfigurator;

public class TestClient extends TestCase {
	private static final Log log = LogFactory.getLog(TestClient.class);

	public void testRequest(){
		log.debug("testRequest() - start");

		try {
			Properties sysProps = System.getProperties();
			
			/*
			 * config for cluster=OpenJMS, embedded=AMQ
			 */
//			// cluster broker - OpenJMS
//			sysProps.setProperty("jms.url", "tcp://host:port/");
//			
//			// embedded broker - ActiveMQ
//			sysProps.setProperty("jms.url.server", "tcp://host:port/");
//			sysProps.setProperty("jms.implClassName.server", "gov.nasa.kepler.services.messaging.ActiveMQMessagingServiceImpl");
			
			/*
			 * config for cluster=AMQ, embedded=OpenJMS
			 */
			// cluster broker -
//			sysProps.setProperty("jms.url", "tcp://host:port/");
//			sysProps.setProperty("jms.implClassName", "gov.nasa.kepler.services.messaging.ActiveMQMessagingServiceImpl");
			
			// embedded broker -
//			sysProps.setProperty("jms.url.server", "tcp://host:port");
//			sysProps.setProperty("jms.url.server", "tcp://host:port");
//			sysProps.setProperty("jms.implClassName.server", "gov.nasa.kepler.services.messaging.ActiveMQMessagingServiceImpl");

			/*
			 * SonicMQ
			 */
			sysProps.setProperty("jms.url.server", "tcp://host:port");
			sysProps.setProperty("jms.implClassName.server", "gov.nasa.kepler.services.messaging.SonicMQMessagingServiceImpl");
			
			MessagingService serverMS = MessagingServiceFactory.getInstance();
//			MessagingService clusterMS = MessagingServiceFactory.getInstance();

			log.debug("testRequest() - initializing server MS");
			serverMS.initialize();

//			log.debug("testRequest() - initializing cluster MS");
//			clusterMS.initialize();
			
			while(true){
				long start = System.currentTimeMillis();
//				sendRequest(serverMS, "server", "dynamicQueues/fs");
				sendRequest(serverMS, "server", "SampleQ1");
				log.info("time = " + (System.currentTimeMillis() - start));
			}
			
//			try {
//				Thread.sleep(5000);
//			} catch (InterruptedException e) {
//				// TODO Auto-generated catch block
//				e.printStackTrace();
//			}
			
//			sendRequest(clusterMS, "cluster", "dynamicTopics/worker-admin");

		} catch (PipelineException e) {
			log.error("listen()", e);
			
			e.printStackTrace();
		}
		
		
		log.debug("testRequest() - end");
		System.exit(0);
	}

	private void sendRequest(MessagingService ms, String name, String destName ) {
		TestMessage request = new TestMessage("request");
		byte[] bytes = new byte[ 42 ];
		bytes[ 10 ] = 42;
		request.setByteContent( bytes );
		
		log.debug(name +":testRequest() - sending request");
		MessageContext responseContext = ms.request(destName, request, 5000 );
		
		TestMessage response = (TestMessage) responseContext.getPipelineMessage();
		log.debug(name +":testRequest() - got a response, content = " + response.getContent() );
	}
	
	public static void main(String[] args) {
		log.debug("main(String[]) - start");

		DOMConfigurator.configure(Filenames.ETC + Filenames.LOG4J_CONFIG);

		log.debug("main(String[]) - start");

		junit.textui.TestRunner.run(TestClient.class);

		log.debug("main(String[]) - end");
	}


}
