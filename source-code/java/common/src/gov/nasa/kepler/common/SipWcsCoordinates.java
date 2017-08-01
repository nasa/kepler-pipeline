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

package gov.nasa.kepler.common;

import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Arrays;
import java.util.List;

/**
 * See the article _The SIP Convention for Representing Distortion in FITS Image Headers_.
 * 
 * SIP == Simple Imaging Polynomial, this is an alternative way of representing
 * celestial WCS coordinates.
 * 
 * sipWcs.ra
 * sipWcs.dec
 * sipWcs.referenceCcdRow
 *  sipWcs.referenceCcdColumn
 *
 * sipWcs.rotationAndScale = 2x2 matrix
 * sipWcs.forwardPolynomial.a.order
 * sipWcs.forwardPolynomial.a.polynomial = array of struct of .keyword .value>
 * 
 * ditto for the B side
 *
 * sipWcs.inversePolynomial.a.order =
 * sipWcs.inversePolynomial.a.polynomial = array of struct of .keyword .value
 * 
 * 
 * @author Sean McCauliff
 *
 */
public final class SipWcsCoordinates implements Persistable {

    private double ra;
    private double dec;
    private double referenceCcdRow;
    private double referenceCcdColumn;
    private double[][] rotationAndScale;
    
    private PolynomialSet forwardPolynomial;
    private PolynomialSet inversePolynomial;
    
    private double maxDistortionA;
    private double maxDistortionB;
    
    
    /** For Persistable interface. */
    public SipWcsCoordinates() {}
    
    public SipWcsCoordinates(double ra, double dec,
                             double referenceCcdRow, double referenceCcdColumn,
                             double[][] rotationAndScale, 
                             PolynomialSet forward, PolynomialSet inverse,
                             double maxDistortionA, double maxDistortionB) {
        super();
        this.ra = ra;
        this.dec = dec;
        this.referenceCcdRow = referenceCcdRow;
        this.referenceCcdColumn = referenceCcdColumn;
        this.rotationAndScale = rotationAndScale;
        this.forwardPolynomial = forward;
        this.inversePolynomial = inverse;
        this.maxDistortionA = maxDistortionA;
        this.maxDistortionB = maxDistortionB;
    }
    
    
    public boolean isValid() {
        return rotationAndScale.length == 2 && rotationAndScale[0].length == 2;
    }
    
    public PolynomialSet forward() {
        return forwardPolynomial;
    }
    
    public PolynomialSet inverse() {
        return inversePolynomial;
    }
    
    /**
     * This is in whatever units the SIP keyword requires.
     * @return
     */
    public double ra() {
        return ra;
    }

    /**
     * This is in whatever units the SIP keyword requires.
     * @return
     */
    public double dec() {
        return dec;
    }

    public double referenceCcdRow() {
        return referenceCcdRow;
    }

    public double referenceCcdColumn() {
        return referenceCcdColumn;
    }


    public double maxDistortionA() {
        return maxDistortionA;
    }
    
    public double maxDistortionB() {
        return maxDistortionB;
    }
    
    
    /**
     * 
     * @return a 2x2 matrix
     */
    public double[][] rotationAndScale() {
        if (rotationAndScale.length != 2 || rotationAndScale[0].length != 2) {
            throw new IllegalStateException("Bad matrix dimensions for rotationAndScale.");
        }
        return rotationAndScale;
    }



    public static final class SipPolynomial implements Persistable {
        private int order;
        private List<PolynomialPart> polynomial;
        
        /** For Persistable interface */
        public SipPolynomial() {}
        
        public SipPolynomial(int order, List<PolynomialPart> polynomial) {
            super();
            this.order = order;
            this.polynomial = polynomial;
        }
        public int order() {
            return order;
        }

        public List<PolynomialPart> polynomial() {
            return polynomial;
        }

    }
    
    public static final class PolynomialPart implements Persistable {
        private String keyword;
        private double value;
        
        /** For Persistable interface */
        public PolynomialPart() {}
        
        public PolynomialPart(String keyword, double value) {
            super();
            this.keyword = keyword;
            this.value = value;
        }

        public String keyword() {
            return keyword;
        }

        public double value() {
            return value;
        }
    }
    
    public static final class PolynomialSet implements Persistable {
        private SipPolynomial a;
        private SipPolynomial b;
        
        /** For Persistable interface */
        public PolynomialSet() {}
        
        public PolynomialSet(SipPolynomial a, SipPolynomial b) {
            super();
            this.a = a;
            this.b = b;
        }
        
        public SipPolynomial a() {
            return a;
        }
        public SipPolynomial b() {
            return b;
        }

    }

    @Override
    public String toString() {
        final int maxLen = 3;
        StringBuilder builder = new StringBuilder();
        builder.append("SipWcsCoordinates [ra=")
                .append(ra)
                .append(", dec=")
                .append(dec)
                .append(", referenceCcdRow=")
                .append(referenceCcdRow)
                .append(", referenceCcdColumn=")
                .append(referenceCcdColumn)
                .append(", rotationAndScale=")
                .append(rotationAndScale != null ? Arrays.asList(
                        rotationAndScale).subList(0,
                        Math.min(rotationAndScale.length, maxLen)) : null)
                .append(", forwardPolynomial=").append(forwardPolynomial)
                .append(", inversePolynomial=").append(inversePolynomial)
                .append(", maxDistortionA=").append(maxDistortionA)
                .append(", maxDistortionB=").append(maxDistortionB).append("]");
        return builder.toString();
    }
    
    

}
