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

package gov.nasa.kepler.fc.psf;

import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.Psf;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * The PsfOperations class handles the JDO operations for the Psf class.
 * 
 * @author Kester Allen
 *
 */
public class PsfOperations {
	/**
	 * Logger for this class
	 */
	private static final Log log = LogFactory.getLog(PsfOperations.class);
	private static DatabaseService dbService;
	private static FcCrud fcCrud;

	/**
	 *
	 * @throws PipelineException 
	 *
	 */
	public PsfOperations() {
    	dbService = DatabaseServiceFactory.getInstance();
    	fcCrud = new FcCrud(dbService);
	}

//	public double getPsfByTargetId( long targetID, Date time) {
//	    try {
//	        Query query = pm.newQuery( Psf.class, Psf.queryString( targetID, time, EERadius ) );
//	        List theValues = (List) query.execute();
//	        if ( 0 == theValues.size() ) {
//	            return -1.0;
//	        }
//	        Psf out = (Psf) theValues.get( 0 );
//	        return out.getEEValue();
//	    }  catch( Throwable throwable ) {
//	        System.out.println( "Exception caught by Psf.getEEbyTargetID: " + throwable.getMessage() );
//	        throwable.printStackTrace();
//	        return -1.0;
//	    }
//	}
//	public double getEEbyRADec( RADec radec, long time, double EERadius ) {
//	    try {
//	        int closestTargetID = FakeCode.getClosestTargetID( radec );
//	        return getEEbyTargetID( closestTargetID, time, EERadius );
//	    }  catch( Throwable throwable ) {
//	        System.out.println( "Exception caught by Psf.getEEbyRADec: " + throwable.getMessage() );
//	        throwable.printStackTrace();
//	        return -1.0;
//	    }
//	}

	/**
	 * Persist a Psf object into the database.
	 *  
	 * @param inPsf Input Psf object to persist.
	 * @throws FocalPlaneException 
	 * @throws PipelineException 
	 */
	public void persistPsf( Psf inPsf ) {
		if (log.isDebugEnabled()) {
			log.debug("persistPsf(Psf) - start");
		}

		fcCrud.create(inPsf);
		
		if (log.isDebugEnabled()) {
			log.debug("persistPsf(Psf) - end");
		}
	}
	
	/**
     * Persist a Psf object into the database by specifying its parameters.
     * 
     * @param targetId
     * @param start
     * @param stop
     * @param coeffs
     * @param type
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public void persistPsf(long targetId, double start, double stop,
        List<Double> coeffs, String type) throws
        PipelineException {
        if (log.isDebugEnabled()) {
            log.debug("persistPsf(long, Date, Date, ArrayList, String) - start");
        }

        persistPsf(new Psf(targetId, start, stop, coeffs, type));

        if (log.isDebugEnabled()) {
            log.debug("persistPsf(long, Date, Date, ArrayList, String) - end");
        }
    }
	
	/**
	 * Retrieve a Psf object from the database.
	 * 
	 * @param psf
	 * @return
	 */
	public Psf retrievePsf(Psf psf) {
		Psf out = fcCrud.retrieve(psf);
		return out;
	}
	
	/**
	 * Retrieve all Psf objects from database
	 *  
	 * @return
	 */
	public List<Psf> retrieveAllPsf() {
		return fcCrud.retrieveAllPsf();
	}
	
//	public void setEEbyTargetID( int targetID, long time, LinkedList coeffs, String specType ) {
//	    try {
//	        Psf psfToSave = new Psf( targetID, time, coeffs, specType );
//	        FC_PersistenceManager.persistMe( pm, psfToSave );
//	    }  catch( Throwable throwable ) {
//	        System.out.println( "Exception caught by Psf.setFWHMbyTargetID: " + throwable.getMessage() );
//	        throwable.printStackTrace();
//	    }
//	}

}
