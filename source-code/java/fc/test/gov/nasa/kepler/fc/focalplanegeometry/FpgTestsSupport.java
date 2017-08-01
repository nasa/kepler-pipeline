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

package gov.nasa.kepler.fc.focalplanegeometry;

import gov.nasa.kepler.hibernate.fc.Geometry;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class FpgTestsSupport {

    public static final Log log = LogFactory.getLog(FpgTestsSupport.class);
    
	public static double startJulianDate = 2453736.0;
	public static double endJulianDate   = 2466154.0;
	
    public static Geometry getFpgToPersist(double startTime) {
        Geometry gm = new Geometry(startTime, data.clone());
        return gm;
    }
    
	public static double data[] = {
        5.71881,   2.84513, 180.14080,
        5.71881,   2.84513,   0.14080,
        5.71893,   0.00000, 180.00000,
        5.71893,   0.00000,   0.00000,
        5.71881,  -2.84513, 179.85920,
        5.71881,  -2.84513,  -0.14080,
        2.85934,   5.71174,  90.14400,
        2.85934,   5.71174, 270.14400,
        2.85942,   2.85586, 180.07160,
        2.85942,   2.85586,   0.07160,
        2.85945,   0.00000, 180.00000,
        2.85945,   0.00000,   0.00000,
        2.85942,  -2.85587, 269.92900,
        2.85942,  -2.85587,  89.92900,
        2.85934,  -5.71174, 269.85600,
        2.85934,  -5.71174,  89.85600,
        0.00000,   5.71893,  90.00000,
        0.00000,   5.71893, 270.00000,
        0.00000,   2.85945,  90.00000,
        0.00000,   2.85945, 270.00000,
        0.00000,   0.00000,  90.00000,
        0.00000,   0.00000, 270.00000,
        0.00000,  -2.85945, 270.00000,
        0.00000,  -2.85945,  90.00000,
        0.00000,  -5.71893, 270.00000,
        0.00000,  -5.71893,  90.00000,
       -2.85934,   5.71174,  89.85600,
       -2.85934,   5.71174, 269.85600,
       -2.85942,   2.85587,  89.92900,
       -2.85942,   2.85587, 269.92900,
       -2.85945,   0.00000,   0.00000,
       -2.85945,   0.00000, 180.00000,
       -2.85942,  -2.85586,   0.07160,
       -2.85942,  -2.85586, 180.07160,
       -2.85934,  -5.71174, 270.14400,
       -2.85934,  -5.71174,  90.14400,
       -5.71881,   2.84513,  -0.14080,
       -5.71881,   2.84513, 179.85920,
       -5.71893,   0.00000,   0.00000,
       -5.71893,   0.00000, 180.00000,
       -5.71881,  -2.84513,   0.14080,
       -5.71881,  -2.84513, 180.14080,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0,
         0.00000, 38.884, 0.0
	};
    
    public static boolean dataIsGood(double array1[], double array2[]) {
        boolean isMatch = array1.length == array2.length;
        for (int ii = 0; ii < array1.length; ++ii) {
            isMatch = isMatch && (array1[ii] == array2[ii]);
            if (array1[ii] != array2[ii]) {
                log.debug(array1[ii] + " != " + array2[ii]);
            }
        }
        return isMatch;
    }

    public static boolean dataIsGood(double arrayIn[]) {
        return dataIsGood(arrayIn, data);
    }
}
