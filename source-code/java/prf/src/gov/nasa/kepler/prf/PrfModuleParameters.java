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

package gov.nasa.kepler.prf;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.Arrays;

/**
 * Represents the complete set of available PRF module parameters.
 * <p>
 * Documentation for these fields can be found in the PRF SDD.
 * 
 * @author Sean McCauliff
 * @author Forrest Girouard
 * 
 */
public class PrfModuleParameters implements Parameters, Persistable {

    private static final int NMODOUT = 84;
    
    private static final float CONTOUR_DEFAULT = 1e-3F;
    private static final float CROWDING_THRESHOLD_DEFAULT = 0.5f;
    private static final float MAX_MAGNITUDE_DEFAULT = 13.0f;
    private static final float MIN_MAGNITUDE_DEFAULT = 12.0f;
    private static final int PIXEL_ARRAY_ROW_SIZE_DEFAULT = 11;
    private static final int PIXEL_ARRAY_COL_SIZE_DEFAULT = 11;
    private static final int[] BAD_FOCUS_PIXEL_ARRAY_INDICES = 
                               {2, 3, 10, 11, 30, 31, 54, 55};
    private static final int BAD_FOCUS_DEFAULT = 15;

    private int numPrfsPerChannel = 1;

    private double prfOverlap = 0.1;

    private int subPixelRowResolution = 6;

    private int subPixelColumnResolution = 6;

    private int[] pixelArrayRowSize = new int[NMODOUT];

    private int[] pixelArrayColumnSize = new int[NMODOUT];

    private int maximumPolyOrder = 8;
    
    private float[] minimumMagnitudePrf1 = new float[NMODOUT];
    private float[] minimumMagnitudePrf2 = new float[NMODOUT];
    private float[] minimumMagnitudePrf3 = new float[NMODOUT];
    private float[] minimumMagnitudePrf4 = new float[NMODOUT];
    private float[] minimumMagnitudePrf5 = new float[NMODOUT];

    private float[] maximumMagnitudePrf1 = new float[NMODOUT];
    private float[] maximumMagnitudePrf2 = new float[NMODOUT];
    private float[] maximumMagnitudePrf3 = new float[NMODOUT];
    private float[] maximumMagnitudePrf4 = new float[NMODOUT];
    private float[] maximumMagnitudePrf5 = new float[NMODOUT];

    
    private float[] crowdingThresholdPrf1 = new float[NMODOUT];
    private float[] crowdingThresholdPrf2 = new float[NMODOUT];
    private float[] crowdingThresholdPrf3 = new float[NMODOUT];
    private float[] crowdingThresholdPrf4 = new float[NMODOUT];
    private float[] crowdingThresholdPrf5 = new float[NMODOUT];
    
    private float[] contourCutoffPrf1 = new float[NMODOUT];
    private float[] contourCutoffPrf2 = new float[NMODOUT];
    private float[] contourCutoffPrf3 = new float[NMODOUT];
    private float[] contourCutoffPrf4 = new float[NMODOUT];
    private float[] contourCutoffPrf5 = new float[NMODOUT];

    private String prfPolynomialType = "not_scaled";

    private int[] rowLimit = new int[] { 21, 1044 };

    private int[] columnLimit = new int[] { 13, 1112 };

    private double regionMinSize = 0.3;

    private double regionStepSize = 0.05;

    private int minStars = 10;

    private int baseAttitudeIndex = 0;
    
    private float centroidChangeThreshold = 0.01f;
    
    private boolean reportEnable = false;

    private int debugLevel = 0;
    
    
    public PrfModuleParameters() {
        Arrays.fill(contourCutoffPrf1, CONTOUR_DEFAULT);
        Arrays.fill(contourCutoffPrf2, CONTOUR_DEFAULT);
        Arrays.fill(contourCutoffPrf3, CONTOUR_DEFAULT);
        Arrays.fill(contourCutoffPrf4, CONTOUR_DEFAULT);
        Arrays.fill(contourCutoffPrf5, CONTOUR_DEFAULT);
        
        Arrays.fill(crowdingThresholdPrf1, CROWDING_THRESHOLD_DEFAULT);
        Arrays.fill(crowdingThresholdPrf2, CROWDING_THRESHOLD_DEFAULT);
        Arrays.fill(crowdingThresholdPrf3, CROWDING_THRESHOLD_DEFAULT);
        Arrays.fill(crowdingThresholdPrf4, CROWDING_THRESHOLD_DEFAULT);
        Arrays.fill(crowdingThresholdPrf5, CROWDING_THRESHOLD_DEFAULT);

        Arrays.fill(maximumMagnitudePrf1, MAX_MAGNITUDE_DEFAULT);
        Arrays.fill(maximumMagnitudePrf2, MAX_MAGNITUDE_DEFAULT);
        Arrays.fill(maximumMagnitudePrf3, MAX_MAGNITUDE_DEFAULT);
        Arrays.fill(maximumMagnitudePrf4, MAX_MAGNITUDE_DEFAULT);
        Arrays.fill(maximumMagnitudePrf5, MAX_MAGNITUDE_DEFAULT);

        Arrays.fill(minimumMagnitudePrf1, MIN_MAGNITUDE_DEFAULT);
        Arrays.fill(minimumMagnitudePrf2, MIN_MAGNITUDE_DEFAULT);
        Arrays.fill(minimumMagnitudePrf3, MIN_MAGNITUDE_DEFAULT);
        Arrays.fill(minimumMagnitudePrf4, MIN_MAGNITUDE_DEFAULT);
        Arrays.fill(minimumMagnitudePrf5, MIN_MAGNITUDE_DEFAULT);

        Arrays.fill(pixelArrayColumnSize, PIXEL_ARRAY_COL_SIZE_DEFAULT);
        for (int i : BAD_FOCUS_PIXEL_ARRAY_INDICES) {
            pixelArrayColumnSize[i] = BAD_FOCUS_DEFAULT;
        }
        Arrays.fill(pixelArrayRowSize, PIXEL_ARRAY_ROW_SIZE_DEFAULT);
        for (int i : BAD_FOCUS_PIXEL_ARRAY_INDICES) {
            pixelArrayRowSize[i] = BAD_FOCUS_DEFAULT;
        }
        
    }
    
    public int getDebugLevel() {
        return debugLevel;
    }
    public void setDebugLevel(int debugLevel) {
        this.debugLevel = debugLevel;
    }
    public boolean isReportEnable() {
        return reportEnable;
    }
    public void setReportEnable(boolean reportEnabled) {
        this.reportEnable = reportEnabled;
    }
    public int getNumPrfsPerChannel() {
        return numPrfsPerChannel;
    }
    public void setNumPrfsPerChannel(int numPrfsPerChannel) {
        this.numPrfsPerChannel = numPrfsPerChannel;
    }
    public double getPrfOverlap() {
        return prfOverlap;
    }
    public void setPrfOverlap(double prfOverlap) {
        this.prfOverlap = prfOverlap;
    }
    public int getSubPixelRowResolution() {
        return subPixelRowResolution;
    }
    public void setSubPixelRowResolution(int subPixelRowResolution) {
        this.subPixelRowResolution = subPixelRowResolution;
    }
    public int getSubPixelColumnResolution() {
        return subPixelColumnResolution;
    }
    public void setSubPixelColumnResolution(int subPixelColumnResolution) {
        this.subPixelColumnResolution = subPixelColumnResolution;
    }
    public int[] getPixelArrayRowSize() {
        return pixelArrayRowSize;
    }
    public void setPixelArrayRowSize(int[] pixelArrayRowSize) {
        this.pixelArrayRowSize = pixelArrayRowSize;
    }
    public int[] getPixelArrayColumnSize() {
        return pixelArrayColumnSize;
    }
    public void setPixelArrayColumnSize(int[] pixelArrayColumnSize) {
        this.pixelArrayColumnSize = pixelArrayColumnSize;
    }
    public int getMaximumPolyOrder() {
        return maximumPolyOrder;
    }
    public void setMaximumPolyOrder(int maximumPolyOrder) {
        this.maximumPolyOrder = maximumPolyOrder;
    }
  
    public String getPrfPolynomialType() {
        return prfPolynomialType;
    }
    public void setPrfPolynomialType(String prfPolynomialType) {
        this.prfPolynomialType = prfPolynomialType;
    }
    public int[] getRowLimit() {
        return rowLimit;
    }
    public void setRowLimit(int[] rowLimit) {
        this.rowLimit = rowLimit;
    }
    public int[] getColumnLimit() {
        return columnLimit;
    }
    public void setColumnLimit(int[] columnLimit) {
        this.columnLimit = columnLimit;
    }
    public double getRegionMinSize() {
        return regionMinSize;
    }
    public void setRegionMinSize(double regionMinSize) {
        this.regionMinSize = regionMinSize;
    }
    public double getRegionStepSize() {
        return regionStepSize;
    }
    public void setRegionStepSize(double regionStepSize) {
        this.regionStepSize = regionStepSize;
    }
    public int getMinStars() {
        return minStars;
    }
    public void setMinStars(int minStars) {
        this.minStars = minStars;
    }
    
    
    public float[] getMinimumMagnitudePrf1() {
        return minimumMagnitudePrf1;
    }
    public void setMinimumMagnitudePrf1(float[] minimumMagnitudePrf1) {
        this.minimumMagnitudePrf1 = minimumMagnitudePrf1;
    }
    public float[] getMinimumMagnitudePrf2() {
        return minimumMagnitudePrf2;
    }
    public void setMinimumMagnitudePrf2(float[] minimumMagnitudePrf2) {
        this.minimumMagnitudePrf2 = minimumMagnitudePrf2;
    }
    public float[] getMinimumMagnitudePrf3() {
        return minimumMagnitudePrf3;
    }
    public void setMinimumMagnitudePrf3(float[] minimumMagnitudePrf3) {
        this.minimumMagnitudePrf3 = minimumMagnitudePrf3;
    }
    public float[] getMinimumMagnitudePrf4() {
        return minimumMagnitudePrf4;
    }
    public void setMinimumMagnitudePrf4(float[] minimumMagnitudePrf4) {
        this.minimumMagnitudePrf4 = minimumMagnitudePrf4;
    }
    public float[] getMinimumMagnitudePrf5() {
        return minimumMagnitudePrf5;
    }
    public void setMinimumMagnitudePrf5(float[] minimumMagnitudePrf5) {
        this.minimumMagnitudePrf5 = minimumMagnitudePrf5;
    }
    public float[] getMaximumMagnitudePrf1() {
        return maximumMagnitudePrf1;
    }
    public void setMaximumMagnitudePrf1(float[] maximumMagnitudePrf1) {
        this.maximumMagnitudePrf1 = maximumMagnitudePrf1;
    }
    public float[] getMaximumMagnitudePrf2() {
        return maximumMagnitudePrf2;
    }
    public void setMaximumMagnitudePrf2(float[] maximumMagnitudePrf2) {
        this.maximumMagnitudePrf2 = maximumMagnitudePrf2;
    }
    public float[] getMaximumMagnitudePrf3() {
        return maximumMagnitudePrf3;
    }
    public void setMaximumMagnitudePrf3(float[] maximumMagnitudePrf3) {
        this.maximumMagnitudePrf3 = maximumMagnitudePrf3;
    }
    public float[] getMaximumMagnitudePrf4() {
        return maximumMagnitudePrf4;
    }
    public void setMaximumMagnitudePrf4(float[] maximumMagnitudePrf4) {
        this.maximumMagnitudePrf4 = maximumMagnitudePrf4;
    }
    public float[] getMaximumMagnitudePrf5() {
        return maximumMagnitudePrf5;
    }
    public void setMaximumMagnitudePrf5(float[] maximumMagnitudePrf5) {
        this.maximumMagnitudePrf5 = maximumMagnitudePrf5;
    }
    public float[] getCrowdingThresholdPrf1() {
        return crowdingThresholdPrf1;
    }
    public void setCrowdingThresholdPrf1(float[] crowdingThresholdPrf1) {
        this.crowdingThresholdPrf1 = crowdingThresholdPrf1;
    }
    public float[] getCrowdingThresholdPrf2() {
        return crowdingThresholdPrf2;
    }
    public void setCrowdingThresholdPrf2(float[] crowdingThresholdPrf2) {
        this.crowdingThresholdPrf2 = crowdingThresholdPrf2;
    }
    public float[] getCrowdingThresholdPrf3() {
        return crowdingThresholdPrf3;
    }
    public void setCrowdingThresholdPrf3(float[] crowdingThresholdPrf3) {
        this.crowdingThresholdPrf3 = crowdingThresholdPrf3;
    }
    public float[] getCrowdingThresholdPrf4() {
        return crowdingThresholdPrf4;
    }
    public void setCrowdingThresholdPrf4(float[] crowdingThresholdPrf4) {
        this.crowdingThresholdPrf4 = crowdingThresholdPrf4;
    }
    public float[] getCrowdingThresholdPrf5() {
        return crowdingThresholdPrf5;
    }
    public void setCrowdingThresholdPrf5(float[] crowdingThresholdPrf5) {
        this.crowdingThresholdPrf5 = crowdingThresholdPrf5;
    }
    public float[] getContourCutoffPrf1() {
        return contourCutoffPrf1;
    }
    public void setContourCutoffPrf1(float[] contourCutoffPrf1) {
        this.contourCutoffPrf1 = contourCutoffPrf1;
    }
    public float[] getContourCutoffPrf2() {
        return contourCutoffPrf2;
    }
    public void setContourCutoffPrf2(float[] contourCutoffPrf2) {
        this.contourCutoffPrf2 = contourCutoffPrf2;
    }
    public float[] getContourCutoffPrf3() {
        return contourCutoffPrf3;
    }
    public void setContourCutoffPrf3(float[] contourCutoffPrf3) {
        this.contourCutoffPrf3 = contourCutoffPrf3;
    }
    public float[] getContourCutoffPrf4() {
        return contourCutoffPrf4;
    }
    public void setContourCutoffPrf4(float[] contourCutoffPrf4) {
        this.contourCutoffPrf4 = contourCutoffPrf4;
    }
    public float[] getContourCutoffPrf5() {
        return contourCutoffPrf5;
    }
    public void setContourCutoffPrf5(float[] contourCutoffPrf5) {
        this.contourCutoffPrf5 = contourCutoffPrf5;
    }
    public int getBaseAttitudeIndex() {
        return baseAttitudeIndex;
    }
    public void setBaseAttitudeIndex(int baseAttitudeIndex) {
        this.baseAttitudeIndex = baseAttitudeIndex;
    }
    public float getCentroidChangeThreshold() {
        return centroidChangeThreshold;
    }
    public void setCentroidChangeThreshold(float centroidChangeThreshold) {
        this.centroidChangeThreshold = centroidChangeThreshold;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + baseAttitudeIndex;
        result = prime * result + Float.floatToIntBits(centroidChangeThreshold);
        result = prime * result + Arrays.hashCode(columnLimit);
        result = prime * result + Arrays.hashCode(contourCutoffPrf1);
        result = prime * result + Arrays.hashCode(contourCutoffPrf2);
        result = prime * result + Arrays.hashCode(contourCutoffPrf3);
        result = prime * result + Arrays.hashCode(contourCutoffPrf4);
        result = prime * result + Arrays.hashCode(contourCutoffPrf5);
        result = prime * result + Arrays.hashCode(crowdingThresholdPrf1);
        result = prime * result + Arrays.hashCode(crowdingThresholdPrf2);
        result = prime * result + Arrays.hashCode(crowdingThresholdPrf3);
        result = prime * result + Arrays.hashCode(crowdingThresholdPrf4);
        result = prime * result + Arrays.hashCode(crowdingThresholdPrf5);
        result = prime * result + debugLevel;
        result = prime * result + Arrays.hashCode(maximumMagnitudePrf1);
        result = prime * result + Arrays.hashCode(maximumMagnitudePrf2);
        result = prime * result + Arrays.hashCode(maximumMagnitudePrf3);
        result = prime * result + Arrays.hashCode(maximumMagnitudePrf4);
        result = prime * result + Arrays.hashCode(maximumMagnitudePrf5);
        result = prime * result + maximumPolyOrder;
        result = prime * result + minStars;
        result = prime * result + Arrays.hashCode(minimumMagnitudePrf1);
        result = prime * result + Arrays.hashCode(minimumMagnitudePrf2);
        result = prime * result + Arrays.hashCode(minimumMagnitudePrf3);
        result = prime * result + Arrays.hashCode(minimumMagnitudePrf4);
        result = prime * result + Arrays.hashCode(minimumMagnitudePrf5);
        result = prime * result + numPrfsPerChannel;
        result = prime * result + Arrays.hashCode(pixelArrayColumnSize);
        result = prime * result + Arrays.hashCode(pixelArrayRowSize);
        long temp;
        temp = Double.doubleToLongBits(prfOverlap);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        result = prime * result
            + ((prfPolynomialType == null) ? 0 : prfPolynomialType.hashCode());
        temp = Double.doubleToLongBits(regionMinSize);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(regionStepSize);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        result = prime * result + (reportEnable ? 1231 : 1237);
        result = prime * result + Arrays.hashCode(rowLimit);
        result = prime * result + subPixelColumnResolution;
        result = prime * result + subPixelRowResolution;
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
        final PrfModuleParameters other = (PrfModuleParameters) obj;
        if (baseAttitudeIndex != other.baseAttitudeIndex)
            return false;
        if (Float.floatToIntBits(centroidChangeThreshold) != Float.floatToIntBits(other.centroidChangeThreshold))
            return false;
        if (!Arrays.equals(columnLimit, other.columnLimit))
            return false;
        if (!Arrays.equals(contourCutoffPrf1, other.contourCutoffPrf1))
            return false;
        if (!Arrays.equals(contourCutoffPrf2, other.contourCutoffPrf2))
            return false;
        if (!Arrays.equals(contourCutoffPrf3, other.contourCutoffPrf3))
            return false;
        if (!Arrays.equals(contourCutoffPrf4, other.contourCutoffPrf4))
            return false;
        if (!Arrays.equals(contourCutoffPrf5, other.contourCutoffPrf5))
            return false;
        if (!Arrays.equals(crowdingThresholdPrf1, other.crowdingThresholdPrf1))
            return false;
        if (!Arrays.equals(crowdingThresholdPrf2, other.crowdingThresholdPrf2))
            return false;
        if (!Arrays.equals(crowdingThresholdPrf3, other.crowdingThresholdPrf3))
            return false;
        if (!Arrays.equals(crowdingThresholdPrf4, other.crowdingThresholdPrf4))
            return false;
        if (!Arrays.equals(crowdingThresholdPrf5, other.crowdingThresholdPrf5))
            return false;
        if (debugLevel != other.debugLevel)
            return false;
        if (!Arrays.equals(maximumMagnitudePrf1, other.maximumMagnitudePrf1))
            return false;
        if (!Arrays.equals(maximumMagnitudePrf2, other.maximumMagnitudePrf2))
            return false;
        if (!Arrays.equals(maximumMagnitudePrf3, other.maximumMagnitudePrf3))
            return false;
        if (!Arrays.equals(maximumMagnitudePrf4, other.maximumMagnitudePrf4))
            return false;
        if (!Arrays.equals(maximumMagnitudePrf5, other.maximumMagnitudePrf5))
            return false;
        if (maximumPolyOrder != other.maximumPolyOrder)
            return false;
        if (minStars != other.minStars)
            return false;
        if (!Arrays.equals(minimumMagnitudePrf1, other.minimumMagnitudePrf1))
            return false;
        if (!Arrays.equals(minimumMagnitudePrf2, other.minimumMagnitudePrf2))
            return false;
        if (!Arrays.equals(minimumMagnitudePrf3, other.minimumMagnitudePrf3))
            return false;
        if (!Arrays.equals(minimumMagnitudePrf4, other.minimumMagnitudePrf4))
            return false;
        if (!Arrays.equals(minimumMagnitudePrf5, other.minimumMagnitudePrf5))
            return false;
        if (numPrfsPerChannel != other.numPrfsPerChannel)
            return false;
        if (!Arrays.equals(pixelArrayColumnSize, other.pixelArrayColumnSize))
            return false;
        if (!Arrays.equals(pixelArrayRowSize, other.pixelArrayRowSize))
            return false;
        if (Double.doubleToLongBits(prfOverlap) != Double.doubleToLongBits(other.prfOverlap))
            return false;
        if (prfPolynomialType == null) {
            if (other.prfPolynomialType != null)
                return false;
        } else if (!prfPolynomialType.equals(other.prfPolynomialType))
            return false;
        if (Double.doubleToLongBits(regionMinSize) != Double.doubleToLongBits(other.regionMinSize))
            return false;
        if (Double.doubleToLongBits(regionStepSize) != Double.doubleToLongBits(other.regionStepSize))
            return false;
        if (reportEnable != other.reportEnable)
            return false;
        if (!Arrays.equals(rowLimit, other.rowLimit))
            return false;
        if (subPixelColumnResolution != other.subPixelColumnResolution)
            return false;
        if (subPixelRowResolution != other.subPixelRowResolution)
            return false;
        return true;
    }

    /**
     * Constructs a <code>String</code> with all attributes
     * in name = value format.
     *
     * @return a <code>String</code> representation 
     * of this object.
     */
    public String toString()
    {
        final String TAB = "    ";
    
        StringBuilder retValue = new StringBuilder();
        
        retValue.append("PrfModuleParameters ( ")
            .append(super.toString()).append(TAB)
            .append("numPrfsPerChannel = ").append(this.numPrfsPerChannel).append(TAB)
            .append("prfOverlap = ").append(this.prfOverlap).append(TAB)
            .append("subPixelRowResolution = ").append(this.subPixelRowResolution).append(TAB)
            .append("subPixelColumnResolution = ").append(this.subPixelColumnResolution).append(TAB)
            .append("pixelArrayRowSize = ").append(this.pixelArrayRowSize).append(TAB)
            .append("pixelArrayColumnSize = ").append(this.pixelArrayColumnSize).append(TAB)
            .append("maximumPolyOrder = ").append(this.maximumPolyOrder).append(TAB)
            .append("minimumMagnitudePrf1 = ").append(this.minimumMagnitudePrf1).append(TAB)
            .append("minimumMagnitudePrf2 = ").append(this.minimumMagnitudePrf2).append(TAB)
            .append("minimumMagnitudePrf3 = ").append(this.minimumMagnitudePrf3).append(TAB)
            .append("minimumMagnitudePrf4 = ").append(this.minimumMagnitudePrf4).append(TAB)
            .append("minimumMagnitudePrf5 = ").append(this.minimumMagnitudePrf5).append(TAB)
            .append("maximumMagnitudePrf1 = ").append(this.maximumMagnitudePrf1).append(TAB)
            .append("maximumMagnitudePrf2 = ").append(this.maximumMagnitudePrf2).append(TAB)
            .append("maximumMagnitudePrf3 = ").append(this.maximumMagnitudePrf3).append(TAB)
            .append("maximumMagnitudePrf4 = ").append(this.maximumMagnitudePrf4).append(TAB)
            .append("maximumMagnitudePrf5 = ").append(this.maximumMagnitudePrf5).append(TAB)
            .append("crowdingThresholdPrf1 = ").append(this.crowdingThresholdPrf1).append(TAB)
            .append("crowdingThresholdPrf2 = ").append(this.crowdingThresholdPrf2).append(TAB)
            .append("crowdingThresholdPrf3 = ").append(this.crowdingThresholdPrf3).append(TAB)
            .append("crowdingThresholdPrf4 = ").append(this.crowdingThresholdPrf4).append(TAB)
            .append("crowdingThresholdPrf5 = ").append(this.crowdingThresholdPrf5).append(TAB)
            .append("contourCutoffPrf1 = ").append(this.contourCutoffPrf1).append(TAB)
            .append("contourCutoffPrf2 = ").append(this.contourCutoffPrf2).append(TAB)
            .append("contourCutoffPrf3 = ").append(this.contourCutoffPrf3).append(TAB)
            .append("contourCutoffPrf4 = ").append(this.contourCutoffPrf4).append(TAB)
            .append("contourCutoffPrf5 = ").append(this.contourCutoffPrf5).append(TAB)
            .append("prfPolynomialType = ").append(this.prfPolynomialType).append(TAB)
            .append("rowLimit = ").append(this.rowLimit).append(TAB)
            .append("columnLimit = ").append(this.columnLimit).append(TAB)
            .append("regionMinSize = ").append(this.regionMinSize).append(TAB)
            .append("regionStepSize = ").append(this.regionStepSize).append(TAB)
            .append("minStars = ").append(this.minStars).append(TAB)
            .append("baseAttitudeIndex = ").append(this.baseAttitudeIndex).append(TAB)
            .append("centroidChangeThreshold = ").append(this.centroidChangeThreshold).append(TAB)
            .append("reportEnable = ").append(this.reportEnable).append(TAB)
            .append("debugLevel = ").append(this.debugLevel).append(TAB)
            .append(" )");
        
        return retValue.toString();
    }
 
    

}
