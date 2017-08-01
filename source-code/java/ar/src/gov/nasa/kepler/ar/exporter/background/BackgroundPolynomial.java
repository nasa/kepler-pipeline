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

package gov.nasa.kepler.ar.exporter.background;


import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;

/**
 * This represents the contents of a background polynomial blob.
 * 
 * @author Sean McCauliff
 *
 */
public class BackgroundPolynomial implements Persistable {

    // These should all be the same for all cadences which this background polynomal covers.
    private double ccdRowScale;
    private double ccdColScale;
    private double ccdRowOffset;
    private double ccdColOffset;
    private double ccdRowOrigin;
    private double ccdColOrigin;
    
    /**
     * One polynomial per cadence.
     */
    private Polynomial[] polynomials;
  
    @ProxyIgnore
    private int nCoeff = Integer.MIN_VALUE;
    
    
    public BackgroundPolynomial() {
        
    }
    
    
    public BackgroundPolynomial(double ccdRowScale, double ccdColScale,
        double ccdRowOffset, double ccdColOffset, double ccdRowOrigin,
        double ccdColOrigin, Polynomial[] polynomials) {

        this.ccdRowScale = ccdRowScale;
        this.ccdColScale = ccdColScale;
        this.ccdRowOffset = ccdRowOffset;
        this.ccdColOffset = ccdColOffset;
        this.ccdRowOrigin = ccdRowOrigin;
        this.ccdColOrigin = ccdColOrigin;
        this.polynomials = polynomials;
    }
    


    public static final class Polynomial implements Persistable {
        private double[] coeffs;
        private double[] covarianceCoeffs;
        private boolean gap;
        private int cadence;
        
        public Polynomial() {
            
        }
        
        
        public Polynomial(double[] coeffs, double[] covarianceCoeffs, boolean gap) {
            this.coeffs = coeffs;
            this.covarianceCoeffs = covarianceCoeffs;
            this.gap = gap;
        }


        /**
         * 
         * @return non-null.  If isGap() is true then the values are undefined.
         */
        public double[] coeffs() {
            return coeffs;
        }
        
        /**
         * 
         * @return non-null.  If isGap() is true then the values are undefined.
         * This is a linearlized version of a 2d array of coefficients.
         */
        public double[] covarianceCoeffs() {
            return covarianceCoeffs;
        }
        
        public boolean isGap() {
            return gap;
        }
        
        public int cadence() {
            return cadence;
        }
        
    }
    
    public int nCoefficients() {
        if (nCoeff != Integer.MIN_VALUE) {
            return nCoeff;
        }
        for (Polynomial poly : polynomials) {
            if (poly.gap) {
                continue;
            }
            if (nCoeff == Integer.MIN_VALUE) {
                nCoeff = poly.coeffs.length;
            } else if (nCoeff != poly.coeffs.length) {
                throw new IllegalStateException("Varying number of background polynomial coefficients.");
            }
        }
        return nCoeff;
    }
    
    public double ccdRowScale() {
        return ccdRowScale;
    }
    
    public double ccdColScale() {
        return ccdColScale;
    }
    
    public double ccdRowOffset() {
        return ccdRowOffset;
    }
    
    public double ccdRowOrigin() {
        return ccdRowOrigin;
    }
    
    public double ccdColOffset() {
        return ccdColOffset;
    }
    
    public double ccdColOrigin() {
        return ccdColOrigin;
    }
    
    public Polynomial[] polynomials() {
        return polynomials;
    }
    
    public Integer[] fitsDimensions() {
        return new Integer[] { nCoefficients()};
    }
    
    public Integer[] fitsCovarianceDimensions() {
        return new Integer[] { nCoefficients() , nCoefficients() };
    }
}
