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

package gov.nasa.kepler.ar.exporter;

import java.util.List;

import com.google.common.collect.ImmutableList;

import gov.nasa.kepler.common.SipWcsCoordinates;
import gov.nasa.kepler.common.SipWcsCoordinates.SipPolynomial;
import gov.nasa.kepler.common.SipWcsCoordinates.PolynomialPart;
import gov.nasa.kepler.common.SipWcsCoordinates.PolynomialSet;

public class ExampleSipWcsCoordinates  {

    public static SipWcsCoordinates example() {
        List<PolynomialPart> forwardAParts = ImmutableList.of(new PolynomialPart("2_0", 17.1));
        List<PolynomialPart> forwardBParts = ImmutableList.of(new PolynomialPart("0_1", 18.2));
        
        PolynomialSet forwardPolynomials = 
            new PolynomialSet(new SipPolynomial(1, forwardAParts), new SipPolynomial(1, forwardBParts));
        
        List<PolynomialPart> inverseAParts = ImmutableList.of(new PolynomialPart("0_0", 19.3));
        List<PolynomialPart> inverseBParts = ImmutableList.of(new PolynomialPart("1_0", 20.4));
        
        PolynomialSet inversePolynomials =
            new PolynomialSet(new SipPolynomial(1, inverseAParts), new SipPolynomial(1, inverseBParts));
        
        SipWcsCoordinates sipWcs = 
            new SipWcsCoordinates(55.5, 66.6, 77.7, 88.8,
                                  new double[][] { { 1.0, 2.0} , {3.0, 4.0}},
                                  forwardPolynomials, inversePolynomials,
                                  10.1, 10.2);
        return sipWcs;
    }
}
