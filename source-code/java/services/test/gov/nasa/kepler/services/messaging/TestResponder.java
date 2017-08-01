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

import javax.naming.NamingException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.xml.DOMConfigurator;

public class TestResponder {
	/**
	 * Logger for this class
	 */
	private static final Log log = LogFactory.getLog(TestResponder.class);

	public TestResponder() {
	}

	private void listen(){
		log.debug("listen() - start");
		
		try {
			MessagingService ms = MessagingServiceFactory.getInstance();
			log.debug("listen() - initializing MS");
			ms.initialize();
			
			log.debug("listen() - waiting for message....");
			MessageContext requestContext = ms.receive("worker-admin");
			TestMessage request = (TestMessage) requestContext.getPipelineMessage();
			log.debug("listen() - got a request, content = " + request.getContent() );
			byte[] bytes = request.getByteContent();
			log.debug("listen() - got a request, content bytes len = " + bytes.length );
			log.debug("listen() - got a request, content bytes[10] = " + bytes[10] );
			
			TestMessage response = new TestMessage( "response to: " + request.getContent());

			log.debug("listen() - sending response");
			ms.respond( requestContext, response );
			ms.commitTransaction();
			
			log.info("response text = " + response.getContent() );
		} catch (PipelineException e) {
			log.error("listen()", e);
			
			e.printStackTrace();
		}
		
		
		log.debug("listen() - end");
	}

	/**
	 * @param args
	 * @throws ServiceException 
	 * @throws NamingException 
	 */
	public static void main(String[] args) throws NamingException {
		DOMConfigurator.configure(Filenames.ETC + Filenames.LOG4J_CONFIG);

		log.debug("main(String[]) - start");

		TestResponder r = new TestResponder();
		r.listen();

		log.debug("main(String[]) - end");
	}

}
