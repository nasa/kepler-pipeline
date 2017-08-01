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

package gov.nasa.kepler.fc.vignettingobscuration;

import gov.nasa.kepler.fc.FcUtilities;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.Obscuration;
import gov.nasa.kepler.hibernate.fc.Vignetting;
import gov.nasa.spiffy.common.pi.PipelineException;

/**
 * The VignettingObscurationOperations class handles the JDO operations for the
 * VignettingObscuration.
 * 
 * @author Kester Allen
 * 
 */
public class VignettingObscurationOperations {
    private static DatabaseService dbService;
    private static FcCrud fcCrud;

    public VignettingObscurationOperations() {
        dbService = DatabaseServiceFactory.getInstance();
        fcCrud = new FcCrud(dbService);
    }

    /**
     * Persist a Vignetting object
     * 
     * @param vin
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public void persistVignetting(Vignetting vin) throws
        PipelineException {
        if (!FcUtilities.isAllowedModule(vin.getCcdModule())
            || !FcUtilities.isAllowedOutput(vin.getCcdOutput())) {
            throw new FocalPlaneException(
                "The inputs module or output are out of range.");
        }
        // FocalPlaneGeometry.pm.makePersistent( vin );
        fcCrud.create(vin);
    }

    /**
     * Persist a Obscuration object
     * 
     * @param obs
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public void persistObscuration(Obscuration obs) throws
        PipelineException {
        if (!FcUtilities.isAllowedModule(obs.getCcdModule())
            || !FcUtilities.isAllowedOutput(obs.getCcdOutput())) {
            throw new FocalPlaneException(
                "The inputs module or output are out of range.");
        }
        // FocalPlaneGeometry.pm.makePersistent( obs );
        fcCrud.create(obs);
    }

    /**
     * Retrieve a Vignetting object based on the input object.
     * 
     * @param inVin
     * @return
     */
    public Vignetting retrieveVignetting(Vignetting inVin) {
        // String queryString = inVin.queryString();
        // Query query = FocalPlaneGeometry.pm.newQuery( queryString );
        //    	
        // query.declareImports("import java.util.Date" );
        // query.declareParameters( "Date parameterizedValue" );
        // List vinList = (List) query.execute( inVin.getStart() );
        //		
        // return (Vignetting) vinList.get(0);
        return fcCrud.retrieve(inVin);
    }

    /**
     * Retrieve a Obscuration object based on the input object.
     * 
     * @param inObs
     * @return
     */
    public Obscuration retrieveObscuration(Obscuration inObs) {
        // String queryString = inObs.queryString();
        // Query query = FocalPlaneGeometry.pm.newQuery( queryString );
        //    	
        // query.declareImports("import java.util.Date" );
        // query.declareParameters( "Date parameterizedValue" );
        // List obsList = (List) query.execute( inObs.getStart() );
        //		
        // return (Obscuration) obsList.get(0);
        return fcCrud.retrieve(inObs);
    }

    /**
     * Retreive the combined effect of the Vignetting and Obscuration at the
     * input time.
     * 
     * @param time
     * @return
     */
    public double retrieveVignettingObscurationValue(double mjd) {
        Vignetting vin = fcCrud.retrieve(new Vignetting(mjd));
        Obscuration obs = fcCrud.retrieve(new Obscuration(mjd));

        double valVin = vin.getVignettingValue();
        double valObs = obs.getObscurationValue();
        return valVin * valObs;
    }

    //
    // /**
    // * By pixel location:
    // *
    // * @param pix
    // * @param centerFOV
    // * @return
    // */
    // public double retrieveVignettingObscuration( Pixel pix, Date time ) {
    //    	
    // return( Vignetting.getVignetting( pix, time ) *
    // Obscuration.getObscuration( pix, time ) );
    // }
    //    
    // public static double getVignettingObscuration( Pixel pix, double ra,
    // double dec ) {
    // return getVignettingObscuration( pix, new RADec( ra, dec ) );
    // }
    //    
    // public static double getVignettingObscuration( int module, int output,
    // double row, double column, double ra, double dec ) {
    // Pixel pix = new Pixel( module, output, row, column );
    // return getVignettingObscuration( pix, ra, dec );
    // }
    //    
    // public static double getVignettingObscuration( Pixel pix ) {
    // return getVignettingObscuration( pix, FcConstants.nominalCtrFOV );
    // }
    //    
    //    
    // /**
    // * By distance from the FOV center:
    // *
    // * @param arcsecFromCenter
    // * @param radec
    // * @return
    // */
    // public static double getVignettingObscuration( double arcsecFromCenter,
    // RADec radec ) {
    // double radiansFromCenter = arcsecFromCenter * FcConstants.arcsec2rad;
    //        
    // radec.setDec( radec.getDec() + radiansFromCenter );
    // Pixel pix = FocalPlaneGeometry.getPixelByCoordinate( radec );
    // radec.setDec( radec.getDec() - radiansFromCenter );
    //        
    // return getVignettingObscuration( pix );
    // }
    //    
    // public static double getVignettingObscuration( double arcsecFromCenter,
    // double ra, double dec ) {
    // RADec radec = new RADec( ra, dec );
    // return getVignettingObscuration( arcsecFromCenter, radec );
    // }
    //    
    //    
    //    
    //
    // public static double getObscuration( Pixel pix, RADec centerFOV ) {
    //        Obscuration obscuration = new Obscuration( pix );
    //        Query query = pm.newQuery( obscuration.getClass(), query_string( pix ) );
    //        List zodiBack = (List) query.execute();
    //        
    //        System.out.println( "size is " + zodiBack.size() );
    //
    //        Obscuration ob = (Obscuration) zodiBack.get( 0 );
    //        return ob.getValue();
    //    }
    //    
    //    public static double getObscuration( Pixel pix ) {
    //        return getObscuration( pix, FcConstants.nominalCtrFOV );
    //    }

}
