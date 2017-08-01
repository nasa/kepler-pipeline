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

package gov.nasa.kepler.fc.scatteredlight;

import gov.nasa.kepler.fc.FcUtilities;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.ScatteredLight;
import gov.nasa.spiffy.common.pi.PipelineException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * The ScatteredLightOperations class handles the JDO operations for the ScatteredLightclass.
 * 
 * @author Kester Allen
 *
 */
public class ScatteredLightOperations {
	/**
	 * Logger for this class
	 */
	private static final Log log = LogFactory.getLog(ScatteredLightOperations.class);
	private static DatabaseService dbService;
	private static FcCrud fcCrud;

	/**
	 * @throws PipelineException 
	 *
	 */
	public ScatteredLightOperations() {
    	dbService = DatabaseServiceFactory.getInstance();
    	fcCrud = new FcCrud(dbService);
	}

	/**
	 * Persist a ScatteredLight object.
	 * 
	 * @param inSl
	 * @throws Exception 
	 */
	public void persistScatteredLight(ScatteredLight inSl) throws Exception {
		if (log.isDebugEnabled()) {
			log.debug("persistScatteredLight(ScatteredLight) - start");
		}

		if ( ! FcUtilities.isAllowedModule( inSl.getCcdModule() ) ||
		 	 ! FcUtilities.isAllowedOutput( inSl.getCcdOutput() )   )
		{
			throw new FocalPlaneException( 
					"The inputs module or output are out of range."
			);         
		} 
//		FocalPlaneGeometry.pm.makePersistent( inSl );
		fcCrud.create(inSl);
		if (log.isDebugEnabled()) {
			log.debug("persistScatteredLight(ScatteredLight) - end");
		}
	}
	
	/**
	 * Retrevieve a ScatteredLight object from the database using the input ScatteredLight object.
	 * @param inSl
	 * @return
	 */
	public ScatteredLight retrieveScatteredLight( ScatteredLight inSl ) {
		if (log.isDebugEnabled()) {
			log.debug("retreieveScatteredLight(ScatteredLight) - start");
		}

		return fcCrud.retrieve(inSl);
//    	String queryString = inSl.queryStringBefore(); 
//    	Query query = FocalPlaneGeometry.pm.newQuery( queryString );
//    	
//		query.declareImports("import java.util.Date" );
//		query.declareParameters( "Date parameterizedValue" );
//		List slList = (List) query.execute( inSl.getStart() );
//
//		if (log.isDebugEnabled()) {
//			log.debug("retreieveScatteredLight(ScatteredLight) - end");
//		}
//		return (ScatteredLight) slList.get( 0 );
	}

}
