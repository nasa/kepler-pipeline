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


package gov.nasa.kepler.fc.tds;

import gov.nasa.kepler.fc.FcUtilities;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.Tds;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Date;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * The TdsOperations class handles the JDO operations for the Tds class.
 * 
 * @author kester
 *
 */
public class TdsOperations {
	/**
	 * Logger for this class
	 */
	private static final Log log = LogFactory.getLog(TdsOperations.class);
	private static DatabaseService dbService;
	private static FcCrud fcCrud;
	
	public TdsOperations() throws PipelineException{
    	dbService = DatabaseServiceFactory.getInstance();
    	fcCrud = new FcCrud(dbService);
	}
	
	/**
	 * 
	 * @param tds The Tds object to persist.
	 * @throws FocalPlaneException 
	 * @throws PipelineException 
	 */
	public void persistTds(Tds tds) {
		if (log.isDebugEnabled()) {
			log.debug("persistTds(Tds) - start");
		}
		if ( ! FcUtilities.isAllowedModule(tds.getCcdModule()) ||
			 ! FcUtilities.isAllowedOutput(tds.getCcdOutput())   )
		{
			throw new FocalPlaneException( 
					"The inputs module or output are out of range."
			);         
		} 
		
       
        try{
        	dbService.beginTransaction();
        	fcCrud.create( tds );
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
        }    

		if (log.isDebugEnabled()) {
			log.debug("persistTds(Tds) - end");
		}
	}
	
	/**
	 * 
	 * @param module  The module to persist a tds value for.
	 * @param output  The output to persist a tds value for.
	 * @param tds    The tds value to persist.
	 * @param start   The start time of the tds value.
	 * @throws FocalPlaneException 
	 * @throws PipelineException 
	 */
	public void persistTds(int module, int output, Date start, double intercept, double slope) {
        if (log.isDebugEnabled()) {
            log.debug("persistTds(int, int, double, Date, Date) - start");
        }
        if (!FcUtilities.isAllowedModule(module) || !FcUtilities.isAllowedOutput(output)) {
            throw new FocalPlaneException("The inputs module or output are out of range.");
        }

        persistTds(new Tds(module, output, start, 1.0, 1.0));

        if (log.isDebugEnabled()) {
            log.debug("persistTds(int, int, double, Date, Date) - end");
        }
		
	}
	
	/**
	 * Retreives the tds information valid for the start Date of the input tds object.
	 * @param inGt The input tds object.  The start Date is used for the JDO lookup.
	 * @return A Tds object with the valid tds.
	 * @throws FocalPlaneException
	 */
	public Tds retreiveTds( Tds inGt ) {
		if (log.isDebugEnabled()) {
			log.debug("retreiveTds(Tds) - start");
		}

		Tds outGt = fcCrud.retrieve(inGt);
		
		if (log.isDebugEnabled()) {
			log.debug("retreiveTds(Tds) - end");
		}
        return outGt;
	}
}
