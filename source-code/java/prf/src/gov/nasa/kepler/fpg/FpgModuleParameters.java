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

package gov.nasa.kepler.fpg;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.Arrays;

/**
 * Parameters used to modify the FPG algorithms.
 * 
 * @author Sean McCauliff
 *
 */
@ProxyIgnoreStatics
public class FpgModuleParameters implements Persistable, Parameters {

	public static final int DEFAULT_REF_CADENCE = -1;

    private int debugLevel = 0;
	
	/** Approximate row values of the grid points to be
	 * used in the formation of constraint points on each mod/out.
	 */
	private double[] rowGridValues = new double[] {300, 700};

	/** Approximate row values of the grid points to be
	 * used in the formation of constraint points on each mod/out.
	 */
	private double[] columnGridValues = new double[] {100,700};

	private boolean fitPlateScaleFlag = true;
	
	/**
	 * Value to be used as the tolX in the convergence criteria for nlinfit.
	 */
	private double tolX = 1e-8;
	
	/**
	 * Value to be used as tolFcn in the convergence criteria for nlinfit.
	 */
	private double tolFun = 2e-2;
	
	/**
	 * Value to be used as tolSigma in the convergence criteria for nlinfit.
	 */
	private double tolSigma = 5e-1;
	
	/**
	 * When true robust fitting is used for nlinfit.
	 */
	private boolean doRobustFit = true;

	private boolean fitPointingRefCadence = true;
	
	/**
	 * when usePointingModel is true, FPG ignores the pointingRefCadence 
	 * values and uses the pointingModel which is part of the 
	 * raDec2PixModel; when usePointingModel is false, FPG 
	 * uses the values in pointingRefCadence
	 */
	private boolean usePointingModel = true;
	
	private int referenceCadence = DEFAULT_REF_CADENCE;
	
	/** Spacecraft pointing. */
	private double[] pointingRefCadence  = new double[] { -1.0, -1.0, -1.0};
	
	 /**
     * If this is non-negative then this will use the last geometry model
     * generated.
     */
    @ProxyIgnore
    private long useGeometryModelFromTaskId = -1;
    
    /**
     * When true ignore existing geometry models.
     */
    @ProxyIgnore
    private boolean bootstrapGeometryModel=false;
    
    /**
     *  The proportion of module/outputs which can be bad
     *  before rejecting the input data set.
     */
    private float maxBadDataCutoff = 0.1f;
    
    private boolean reportGenerationEnabled = true;
    
    public boolean isBootstrapGeometryModel() {
        return bootstrapGeometryModel;
    }
    
    public void setBootstrapGeometryModel(boolean newbs) {
        this.bootstrapGeometryModel = newbs;
    }
    
	public int getReferenceCadence() {
        return referenceCadence;
    }

    public void setReferenceCadence(int referenceCadence) {
        this.referenceCadence = referenceCadence;
    }

    public long getUseGeometryModelFromTaskId() {
        return useGeometryModelFromTaskId;
    }

    public void setUseGeometryModelFromTaskId(long useGeometryModelFromTaskId) {
        this.useGeometryModelFromTaskId = useGeometryModelFromTaskId;
    }

    public double getTolFun() {
        return tolFun;
    }

    public void setTolFun(double tolFun) {
        this.tolFun = tolFun;
    }

    public boolean isFitPointingRefCadence() {
        return fitPointingRefCadence;
    }

    public void setFitPointingRefCadence(boolean fitPointingRefCadence) {
        this.fitPointingRefCadence = fitPointingRefCadence;
    }

    public boolean isUsePointingModel() {
        return usePointingModel;
    }

    public void setUsePointingModel(boolean usePointingModel) {
        this.usePointingModel = usePointingModel;
    }

    public double[] getPointingRefCadence() {
        return pointingRefCadence;
    }

    public void setPointingRefCadence(double[] pointingRefCadence) {
        this.pointingRefCadence = pointingRefCadence;
    }

    public int getDebugLevel() {
		return debugLevel;
	}

	public void setDebugLevel(int debugLevel) {
		this.debugLevel = debugLevel;
	}

	public double[] getRowGridValues() {
		return rowGridValues;
	}

	public void setRowGridValues(double[] rowGridValues) {
		this.rowGridValues = rowGridValues;
	}

	public double[] getColumnGridValues() {
		return columnGridValues;
	}

	public void setColumnGridValues(double[] columnGridValues) {
		this.columnGridValues = columnGridValues;
	}

	public boolean isFitPlateScaleFlag() {
		return fitPlateScaleFlag;
	}

	public void setFitPlateScaleFlag(boolean fitPlateScaleFlag) {
		this.fitPlateScaleFlag = fitPlateScaleFlag;
	}

	public double getTolX() {
		return tolX;
	}

	public void setTolX(double tolX) {
		this.tolX = tolX;
	}

	public double getTolFcn() {
		return tolFun;
	}

	public void setTolFcn(double tolFcn) {
		this.tolFun = tolFcn;
	}

	public double getTolSigma() {
		return tolSigma;
	}

	public void setTolSigma(double tolSigma) {
		this.tolSigma = tolSigma;
	}

	public boolean isDoRobustFit() {
		return doRobustFit;
	}

	public void setDoRobustFit(boolean doRobustFit) {
		this.doRobustFit = doRobustFit;
	}

	public float getMaxBadDataCutoff() {
		return maxBadDataCutoff;
	}

	public void setMaxBadDataCutoff(float maxBadDataCutoff) {
		this.maxBadDataCutoff = maxBadDataCutoff;
	}

    public boolean isReportGenerationEnabled() {
        return reportGenerationEnabled;
    }

    public void setReportGenerationEnabled(boolean reportGenerationEnabled) {
        this.reportGenerationEnabled = reportGenerationEnabled;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + (bootstrapGeometryModel ? 1231 : 1237);
        result = prime * result + Arrays.hashCode(columnGridValues);
        result = prime * result + debugLevel;
        result = prime * result + (doRobustFit ? 1231 : 1237);
        result = prime * result + (fitPlateScaleFlag ? 1231 : 1237);
        result = prime * result + (fitPointingRefCadence ? 1231 : 1237);
        result = prime * result + Float.floatToIntBits(maxBadDataCutoff);
        result = prime * result + Arrays.hashCode(pointingRefCadence);
        result = prime * result + referenceCadence;
        result = prime * result + (reportGenerationEnabled ? 1231 : 1237);
        result = prime * result + Arrays.hashCode(rowGridValues);
        long temp;
        temp = Double.doubleToLongBits(tolFun);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(tolSigma);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(tolX);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        result = prime
            * result
            + (int) (useGeometryModelFromTaskId ^ (useGeometryModelFromTaskId >>> 32));
        result = prime * result + (usePointingModel ? 1231 : 1237);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        final FpgModuleParameters other = (FpgModuleParameters) obj;
        if (bootstrapGeometryModel != other.bootstrapGeometryModel)
            return false;
        if (!Arrays.equals(columnGridValues, other.columnGridValues))
            return false;
        if (debugLevel != other.debugLevel)
            return false;
        if (doRobustFit != other.doRobustFit)
            return false;
        if (fitPlateScaleFlag != other.fitPlateScaleFlag)
            return false;
        if (fitPointingRefCadence != other.fitPointingRefCadence)
            return false;
        if (Float.floatToIntBits(maxBadDataCutoff) != Float.floatToIntBits(other.maxBadDataCutoff))
            return false;
        if (!Arrays.equals(pointingRefCadence, other.pointingRefCadence))
            return false;
        if (referenceCadence != other.referenceCadence)
            return false;
        if (reportGenerationEnabled != other.reportGenerationEnabled)
            return false;
        if (!Arrays.equals(rowGridValues, other.rowGridValues))
            return false;
        if (Double.doubleToLongBits(tolFun) != Double.doubleToLongBits(other.tolFun))
            return false;
        if (Double.doubleToLongBits(tolSigma) != Double.doubleToLongBits(other.tolSigma))
            return false;
        if (Double.doubleToLongBits(tolX) != Double.doubleToLongBits(other.tolX))
            return false;
        if (useGeometryModelFromTaskId != other.useGeometryModelFromTaskId)
            return false;
        if (usePointingModel != other.usePointingModel)
            return false;
        return true;
    }

}
