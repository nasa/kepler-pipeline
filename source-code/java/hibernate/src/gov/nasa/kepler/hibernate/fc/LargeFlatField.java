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

package gov.nasa.kepler.hibernate.fc;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.annotations.CollectionOfElements;
import org.hibernate.annotations.IndexColumn;

@Entity
@Table(name = "FC_LARGEFLAT")
public class LargeFlatField {
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(LargeFlatField.class);
    
    @Id
    @GeneratedValue(strategy=GenerationType.AUTO, generator="sg")
    @SequenceGenerator(name="sg", sequenceName="FC_LARGE_FLAT_SEQ")
    private long id;
    
    private int ccdModule;
    private int ccdOutput;
    private double startTime;
 
    private int polynomialOrder;
    private String type;
    
    private int xIndex;
    private double offsetX;
    private double scaleX;
    private double originX;
    
    private int yIndex;
    private double offsetY;
    private double scaleY;
    private double originY;

    @CollectionOfElements
    @JoinTable(name="FC_LARGEFLAT_COEFFS")
    @IndexColumn(name="IDX_T")
    private List<Double> polynomialCoefficients;
    
    @CollectionOfElements
    @JoinTable(name="FC_LARGEFLAT_COVARCOEFFS")
    @IndexColumn(name="IDX_B")
    private List<Double> covarianceCoefficients;

    // For Hibernate:
    LargeFlatField() {
        ;
    }
    
    
    /**
     * @param ccdModule
     * @param ccdOutput
     * @param startTime
     * @param polynomialOrder
     * @param type
     * @param index
     * @param offsetX
     * @param scaleX
     * @param originX
     * @param index2
     * @param offsetY
     * @param scaleY
     * @param originY
     * @param history
     * @param polynomialCoefficients
     * @param covarianceCoefficients
     */
    public LargeFlatField(int ccdModule, int ccdOutput, double startTime,
        int polynomialOrder, String type, int index, double offsetX,
        double scaleX, double originX, int index2, double offsetY,
        double scaleY, double originY, double[] topCoeffs,
        double[] bottomCoeffs) 
    {
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.startTime = startTime;
        this.polynomialOrder = polynomialOrder;
        this.type = type;
        this.xIndex = index;
        this.offsetX = offsetX;
        this.scaleX = scaleX;
        this.originX = originX;
        this.yIndex = index2;
        this.offsetY = offsetY;
        this.scaleY = scaleY;
        this.originY = originY;
        
        this.polynomialCoefficients = new ArrayList<Double>();
        for (int ii = 0; ii < topCoeffs.length; ++ii) {
            this.polynomialCoefficients.add(topCoeffs[ii]);
        }

        this.covarianceCoefficients = new ArrayList<Double>();
        for (int ii = 0; ii < bottomCoeffs.length; ++ii) {
            this.covarianceCoefficients.add(bottomCoeffs[ii]);
        }
    }

//    public LargeFlatField() {
//        double[] initTopCoeffs = { 1.0 };
//        double[] initBottomCoeffs = { 1.0 };
//        
//        ccdModule = 0;
//        ccdOutput = 0;
//        startTime = 0.0;
//        
//        polynomialCoefficients = new ArrayList<Double>(initTopCoeffs.length);
//        covarianceCoefficients = new ArrayList<Double>(initBottomCoeffs.length);
//        for (double val : initTopCoeffs) {
//            this.polynomialCoefficients.add(val);
//        }
//        for (double val : initBottomCoeffs) {
//            this.covarianceCoefficients.add(val);
//        }
//    }
//    
//    public LargeFlatField(int module, int output, double startTime) {
//        this();
//        this.ccdModule = module;
//        this.ccdOutput = output;
//        this.startTime  = startTime;
//    }
//    
//    public LargeFlatField(int module, int output, double[] topCoeffs, double[] bottomCoeffs, double startTime) {
//        this(module, output, startTime);
//        
//        if(topCoeffs != null){
//            this.polynomialCoefficients = new ArrayList<Double>(topCoeffs.length);
//            for (double val : topCoeffs) {
//                this.polynomialCoefficients.add(val);
//            }
//        }
//        
//        if(bottomCoeffs != null){
//            this.covarianceCoefficients = new ArrayList<Double>(bottomCoeffs.length);
//            for (double val : bottomCoeffs) {
//                this.covarianceCoefficients.add(val);
//            }
//        }
//    }

    
    public int getCcdModule() {
        return this.ccdModule;
    }

    public void setCcdModule(int ccdModule) {
        this.ccdModule = ccdModule;
    }

    public int getCcdOutput() {
        return this.ccdOutput;
    }

    public void setCcdOutput(int ccdOutput) {
        this.ccdOutput = ccdOutput;
    }

    public double getStartTime() {
        return this.startTime;
    }

    public void setStartTime(double startTime) {
        this.startTime = startTime;
    }

    public int getPolynomialOrder() {
        return this.polynomialOrder;
    }

    public void setPolynomialOrder(int polynomialOrder) {
        this.polynomialOrder = polynomialOrder;
    }

    public String getType() {
        return this.type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int getXIndex() {
        return this.xIndex;
    }

    public void setXIndex(int index) {
        this.xIndex = index;
    }

    public double getOffsetX() {
        return this.offsetX;
    }

    public void setOffsetX(double offsetX) {
        this.offsetX = offsetX;
    }

    public double getScaleX() {
        return this.scaleX;
    }

    public void setScaleX(double scaleX) {
        this.scaleX = scaleX;
    }

    public double getOriginX() {
        return this.originX;
    }

    public void setOriginX(double originX) {
        this.originX = originX;
    }

    public int getYIndex() {
        return this.yIndex;
    }

    public void setYIndex(int index) {
        this.yIndex = index;
    }

    public double getOffsetY() {
        return this.offsetY;
    }

    public void setOffsetY(double offsetY) {
        this.offsetY = offsetY;
    }

    public double getScaleY() {
        return this.scaleY;
    }

    public void setScaleY(double scaleY) {
        this.scaleY = scaleY;
    }

    public double getOriginY() {
        return this.originY;
    }

    public void setOriginY(double originY) {
        this.originY = originY;
    }

    public List<Double> getPolynomialCoefficients() {
        return this.polynomialCoefficients;
    }
    
    public double[] getPolynomialCoefficientsArray() {
        double[] coeffArr = new double[polynomialCoefficients.size()];
        for (int ii = 0; ii < polynomialCoefficients.size(); ++ii) {
            coeffArr[ii] = polynomialCoefficients.get(ii);
        }
        return coeffArr;
    }

    public void setPolynomialCoefficients(List<Double> topCoeffs) {
        this.polynomialCoefficients = topCoeffs;
    }

    public List<Double> getCovarianceCoefficients() {
        return this.covarianceCoefficients;
    }
    
    public double[] getCovarianceCoefficientsArray() {
        double[] covarArr = new double[covarianceCoefficients.size()];
        for (int ii = 0; ii < covarianceCoefficients.size(); ++ii) {
            covarArr[ii] = covarianceCoefficients.get(ii);
        }
        return covarArr;
    }

    public void setCovarianceCoefficients(List<Double> bottomCoeffs) {
        this.covarianceCoefficients = bottomCoeffs;
    }

    /**
     *
     *  This is handled in the matlab side now
     * 
     * @param row
     * @param column
     * @return
     */
    public double getFlat(int row, int column) {
        return 1.0;
    }

    public String queryString() {
		return getCcdModule() + " == module " + " && " + getCcdOutput() + " == output ";
    }

	public String queryStringBefore() {
		return "select from gov.nasa.kepler.hibernate.fc.LargeFlatField " + "where start < parameterizedValue";
    }

    public String queryDistinctTimes() {
        return "select distinct starttime from gov.nasa.kepler.hibernate.fc.LargeFlatField "
                + "where start > parameterizedValueStart and stop < parameterizedValueStop";
    }
	
	public String toString() {
	    return startTime + " " + ccdModule + " " + ccdOutput + "\n" + polynomialCoefficients.toString() + "\n" + covarianceCoefficients.toString();
	}
}
