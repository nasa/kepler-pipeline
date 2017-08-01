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

package gov.nasa.kepler.fc;

import gov.nasa.kepler.hibernate.fc.Linearity;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.List;

import org.apache.commons.lang.ArrayUtils;

public class LinearityModel implements Persistable {
	private double[] mjds = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private double[][] constants = new double[0][];
    private double[][] uncertainties = new double[0][];
    private double[] offsetXs = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private double[] scaleXs = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private double[] originXs = ArrayUtils.EMPTY_DOUBLE_ARRAY; 
    private String[] types = ArrayUtils.EMPTY_STRING_ARRAY;
    private int[] xIndices = ArrayUtils.EMPTY_INT_ARRAY;
    private int[] maxDomains = ArrayUtils.EMPTY_INT_ARRAY;
    private FcModelMetadata fcModelMetadata = new FcModelMetadata();
    
    /**
     * Required by {@link Persistable}.
     */
    public LinearityModel() {
    }
    
    /**
     * 
     * @param mjds
     * @param constants
     */
    public LinearityModel(double[] mjds, double[][] constants) {
		this.mjds = mjds;
		this.constants = constants;
	}
    
    /**
     * 
     * @param mjds
     * @param constants
     * @param uncertainties
     */
    public LinearityModel(double[] mjds, double[][] constants, double[][] uncertainties) {
        this.mjds = mjds;
        this.constants = constants;
        this.uncertainties = uncertainties;
    }
    
    /**
     * 
     * @param mjds
     * @param constants
     * @param uncertainties
     * @param offsetXs
     * @param scaleXs
     * @param originXs
     */
    public LinearityModel(double[] mjds, double[][] constants,
        double[][] uncertainties, double[] offsetXs, double[] scaleXs,
        double[] originXs) 
    {
        this(mjds, constants, uncertainties);
        this.offsetXs = offsetXs;
        this.scaleXs = scaleXs;
        this.originXs = originXs;
    }
    
    public LinearityModel(double[] mjds, 
        double[][] constants, double[][] uncertainties, 
        double[] offsetXs, double[] scaleXs, double[] originXs,
        String[] types, int[] xIndices, int[] maxDomains) 
    {
        this(mjds, constants, uncertainties, offsetXs, scaleXs, offsetXs);        
        this.types = types;
        this.xIndices = xIndices;
        this.originXs = originXs;
        this.maxDomains = maxDomains;
    }
    
    public LinearityModel(List<Linearity> lins) {
        mjds = new double[lins.size()];
        constants = new double[lins.size()][];
        uncertainties = new double[lins.size()][];
        offsetXs = new double[lins.size()];
        scaleXs = new double[lins.size()];
        originXs = new double[lins.size()]; 
        types    = new String[lins.size()];
        xIndices    = new int[lins.size()];
        maxDomains  = new int[lins.size()];
        
        for (int ii = 0; ii < lins.size(); ++ii) {
            mjds[ii] = lins.get(ii).getStartMjd();
            offsetXs[ii] = lins.get(ii).getOffsetX();
            scaleXs[ii]  = lins.get(ii).getScaleX();
            originXs[ii] = lins.get(ii).getOriginX();
            types[ii]    = lins.get(ii).getType();
            xIndices[ii] = lins.get(ii).getXIndex();
            maxDomains[ii] = lins.get(ii).getMaxDomain();
                  
            constants[ii] = lins.get(ii).getCoefficients();
            uncertainties[ii] = lins.get(ii).getUncertainties();
        }
    }
    
    /**
     * 
     * @return
     */
    public double[] getMjds() {
		return mjds;
	}
    
    /**
     * 
     * @param mjds
     */
	public void setMjds(double[] mjds) {
		this.mjds = mjds;
	}
	
	/**
	 * 
	 * @return
	 */
	public double[][] getConstants() {
		return constants;
	}
	
	/**
	 * 
	 * @param constants
	 */
	public void setConstants(double[][] constants) {
		this.constants = constants;
	}

    public double[][] getUncertainties() {
        return this.uncertainties;
    }

    public void setUncertainties(double[][] uncertainties) {
        this.uncertainties = uncertainties;
    }

    public double[] getOffsetXs() {
        return this.offsetXs;
    }

    public void setOffsetXs(double[] offsetXs) {
        this.offsetXs = offsetXs;
    }

    public double[] getScaleXs() {
        return this.scaleXs;
    }

    public void setScaleXs(double[] scaleXs) {
        this.scaleXs = scaleXs;
    }

    public double[] getOriginXs() {
        return this.originXs;
    }

    public void setOriginXs(double[] originXs) {
        this.originXs = originXs;
    }

    public String[] getTypes() {
        return this.types;
    }

    public void setTypes(String[] types) {
        this.types = types;
    }

    public int[] getXIndices() {
        return this.xIndices;
    }

    public void setXIndices(int[] indexs) {
        this.xIndices = indexs;
    }

    public int[] getMaxDomains() {
        return this.maxDomains;
    }

    public void setMaxDomains(int[] maxDomains) {
        this.maxDomains = maxDomains;
    }

    public void setFcModelMetadata(FcModelMetadata fcModelMetadata) {
        this.fcModelMetadata = fcModelMetadata;
    }

    public FcModelMetadata getFcModelMetadata() {
        return fcModelMetadata;
    }
}
