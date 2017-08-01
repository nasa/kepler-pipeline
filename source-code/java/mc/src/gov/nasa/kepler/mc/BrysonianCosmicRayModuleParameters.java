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

package gov.nasa.kepler.mc;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * All the cosmic ray specific configuration information for PA.
 * 
 * @author Forrest Girouard (fgirouard)
 * 
 */
public class BrysonianCosmicRayModuleParameters implements Parameters, Persistable {

    /**
     * Order of polynomial used to estimate local second derivative for
     * partition by curvature.
     */
    private int curvaturePartitionOrder = 3;

    /**
     * Smallest region or negative curvature to consider for creating a
     * partition.
     */
    private int curvaturePartitionSmallestRegion = 5;

    /**
     * Threshold for partition by curvature, where a partition is created if the
     * local second derivative (curvature) is smaller than threhold * local
     * median.
     */
    private float curvaturePartitionThreshold = 20;

    /**
     * Half-window of data used to estimate local second derivative for
     * partition by curvature.
     */
    private int curvaturePartitionWindow = 5;

    /**
     * Polynomial order to use for gap filling.
     */
    private int dataGapFillOrder = 5;

    /**
     * Half-window size for detrending.
     */
    private int detrendWindow = 40;

    /**
     * Order of polynomial used in detrending when the window is large.
     */
    private int largeWindowDetrendOrder = 3;

    /**
     * Number of iterations to use in computing local standard deviation.
     */
    private int localSdIterations = 3;

    /**
     * Half-window size used in computing local standard deviation.
     */
    private int localSdWindow = 100;

    /**
     * Order of regression against motion for pixel series detrending.
     */
    private int motionDetrendOrder = 3;

    /**
     * Test threshold for reconstructed time series.
     */
    private float reconstructionThreshold = (float) 1e-6;

    /**
     * Amount to multiply the standard deviation for when any pixel in the
     * aperture is in saturation. The effect of this multiplier is threshold ->
     * threshold*(saturationThresholdMultiplier + 1).
     */
    private float saturationThresholdMultiplier = (float) 1.5;

    /**
     * Saturation value for pixels - when a pixel value exceeds this threhold it
     * is to be considered near saturation and cosmic rays are not removed.
     */
    private float saturationValueThreshold = (float) 3.7e8;

    /**
     * Order of polynomial used in detrending when the window is small.
     */
    private int smallWindowDetrendOrder = 7;

    /**
     * Threshold for the identification of cosmic rays as positive outliers, as
     * multiple of local standard deviation.
     */
    private float threshold = (float) 3.5;

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }

    public int getCurvaturePartitionOrder() {
        return curvaturePartitionOrder;
    }

    public void setCurvaturePartitionOrder(int curvaturePartitionOrder) {
        this.curvaturePartitionOrder = curvaturePartitionOrder;
    }

    public int getCurvaturePartitionSmallestRegion() {
        return curvaturePartitionSmallestRegion;
    }

    public void setCurvaturePartitionSmallestRegion(
        int curvaturePartitionSmallestRegion) {
        this.curvaturePartitionSmallestRegion = curvaturePartitionSmallestRegion;
    }

    public float getCurvaturePartitionThreshold() {
        return curvaturePartitionThreshold;
    }

    public void setCurvaturePartitionThreshold(float curvaturePartitionThreshold) {
        this.curvaturePartitionThreshold = curvaturePartitionThreshold;
    }

    public int getCurvaturePartitionWindow() {
        return curvaturePartitionWindow;
    }

    public void setCurvaturePartitionWindow(int curvaturePartitionWindow) {
        this.curvaturePartitionWindow = curvaturePartitionWindow;
    }

    public int getDataGapFillOrder() {
        return dataGapFillOrder;
    }

    public void setDataGapFillOrder(int dataGapFillOrder) {
        this.dataGapFillOrder = dataGapFillOrder;
    }

    public int getDetrendWindow() {
        return detrendWindow;
    }

    public void setDetrendWindow(int detrendWindow) {
        this.detrendWindow = detrendWindow;
    }

    public int getLargeWindowDetrendOrder() {
        return largeWindowDetrendOrder;
    }

    public void setLargeWindowDetrendOrder(int largeWindowDetrendOrder) {
        this.largeWindowDetrendOrder = largeWindowDetrendOrder;
    }

    public int getLocalSdIterations() {
        return localSdIterations;
    }

    public void setLocalSdIterations(int localSdIterations) {
        this.localSdIterations = localSdIterations;
    }

    public int getLocalSdWindow() {
        return localSdWindow;
    }

    public void setLocalSdWindow(int localSdWindow) {
        this.localSdWindow = localSdWindow;
    }

    public int getMotionDetrendOrder() {
        return motionDetrendOrder;
    }

    public void setMotionDetrendOrder(int motionDetrendOrder) {
        this.motionDetrendOrder = motionDetrendOrder;
    }

    public float getReconstructionThreshold() {
        return reconstructionThreshold;
    }

    public void setReconstructionThreshold(float reconstructionThreshold) {
        this.reconstructionThreshold = reconstructionThreshold;
    }

    public float getSaturationThresholdMultiplier() {
        return saturationThresholdMultiplier;
    }

    public void setSaturationThresholdMultiplier(
        float saturationThresholdMultiplier) {
        this.saturationThresholdMultiplier = saturationThresholdMultiplier;
    }

    public float getSaturationValueThreshold() {
        return saturationValueThreshold;
    }

    public void setSaturationValueThreshold(float saturationValueThreshold) {
        this.saturationValueThreshold = saturationValueThreshold;
    }

    public int getSmallWindowDetrendOrder() {
        return smallWindowDetrendOrder;
    }

    public void setSmallWindowDetrendOrder(int smallWindowDetrendOrder) {
        this.smallWindowDetrendOrder = smallWindowDetrendOrder;
    }

    public float getThreshold() {
        return threshold;
    }

    public void setThreshold(float threshold) {
        this.threshold = threshold;
    }

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + curvaturePartitionOrder;
		result = prime * result + curvaturePartitionSmallestRegion;
		result = prime * result
				+ Float.floatToIntBits(curvaturePartitionThreshold);
		result = prime * result + curvaturePartitionWindow;
		result = prime * result + dataGapFillOrder;
		result = prime * result + detrendWindow;
		result = prime * result + largeWindowDetrendOrder;
		result = prime * result + localSdIterations;
		result = prime * result + localSdWindow;
		result = prime * result + motionDetrendOrder;
		result = prime * result + Float.floatToIntBits(reconstructionThreshold);
		result = prime * result
				+ Float.floatToIntBits(saturationThresholdMultiplier);
		result = prime * result
				+ Float.floatToIntBits(saturationValueThreshold);
		result = prime * result + smallWindowDetrendOrder;
		result = prime * result + Float.floatToIntBits(threshold);
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj) {
			return true;
		}
		if (obj == null) {
			return false;
		}
		if (getClass() != obj.getClass()) {
			return false;
		}
		BrysonianCosmicRayModuleParameters other = (BrysonianCosmicRayModuleParameters) obj;
		if (curvaturePartitionOrder != other.curvaturePartitionOrder) {
			return false;
		}
		if (curvaturePartitionSmallestRegion != other.curvaturePartitionSmallestRegion) {
			return false;
		}
		if (Float.floatToIntBits(curvaturePartitionThreshold) != Float
				.floatToIntBits(other.curvaturePartitionThreshold)) {
			return false;
		}
		if (curvaturePartitionWindow != other.curvaturePartitionWindow) {
			return false;
		}
		if (dataGapFillOrder != other.dataGapFillOrder) {
			return false;
		}
		if (detrendWindow != other.detrendWindow) {
			return false;
		}
		if (largeWindowDetrendOrder != other.largeWindowDetrendOrder) {
			return false;
		}
		if (localSdIterations != other.localSdIterations) {
			return false;
		}
		if (localSdWindow != other.localSdWindow) {
			return false;
		}
		if (motionDetrendOrder != other.motionDetrendOrder) {
			return false;
		}
		if (Float.floatToIntBits(reconstructionThreshold) != Float
				.floatToIntBits(other.reconstructionThreshold)) {
			return false;
		}
		if (Float.floatToIntBits(saturationThresholdMultiplier) != Float
				.floatToIntBits(other.saturationThresholdMultiplier)) {
			return false;
		}
		if (Float.floatToIntBits(saturationValueThreshold) != Float
				.floatToIntBits(other.saturationValueThreshold)) {
			return false;
		}
		if (smallWindowDetrendOrder != other.smallWindowDetrendOrder) {
			return false;
		}
		if (Float.floatToIntBits(threshold) != Float
				.floatToIntBits(other.threshold)) {
			return false;
		}
		return true;
	}
    
    
}
