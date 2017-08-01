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

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class TestServerListenerThread extends Thread {
	/**
	 * Logger for this class
	 */
	private static final Log log = LogFactory.getLog(TestServerListenerThread.class);

	private MessagingService messagingService = null;
	private String name = null;
	private String destName = null;
	
	/**
	 * @param messagingService
	 * @param name
	 * @param destName
	 */
	public TestServerListenerThread(MessagingService messagingService, String name, String destName) {
		this.messagingService = messagingService;
		this.name = name;
		this.destName = destName;
	}

	@Override
    public void run(){
		log.debug(name + ":run() - start");

		try{
			while(true){
				log.debug( name + ":listen() - waiting for message....");
				MessageContext requestContext = messagingService.receive( destName );
				TestMessage request = (TestMessage) requestContext.getPipelineMessage();
				log.debug(name + ":listen() - got a request, content = " + request.getContent() );
				byte[] bytes = request.getByteContent();
				log.debug(name + ":listen() - got a request, content bytes len = " + bytes.length );
				log.debug(name + ":listen() - got a request, content bytes[10] = " + bytes[10] );
				
				TestMessage response = new TestMessage( "response to: " + request.getContent());

				log.debug(name + ":listen() - sending response");
				messagingService.respond( requestContext, response );
				messagingService.commitTransaction();
				
				log.info(name + ":response text = " + response.getContent() );
			}

		}catch( Exception e ){
			log.error(name + ":caught e ", e );
		}
		log.debug("run() - end");
	}
}
