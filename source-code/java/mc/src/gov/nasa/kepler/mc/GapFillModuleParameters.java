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
 * 
 * @author Forrest Girouard
 * 
 */
public class GapFillModuleParameters implements Parameters, Persistable {

    // SOC PDC2.9: inputs: minimum long data gap size is maxArOrderLimit * MaxCorrelationWindowXFactor.
    private float madXFactor;
    private float maxGiantTransitDurationInHours;
    private int maxDetrendPolyOrder;
    private int maxArOrderLimit;
    private int maxCorrelationWindowXFactor;
    private boolean gapFillModeIsAddBackPredictionError;
    private String waveletFamily = "";
    private int waveletFilterLength;
    private float giantTransitPolyFitChunkLengthInHours;
    private boolean removeEclipsingBinariesOnList;
    private float arAutoCorrelationThreshold;

    @Override
    public String toString() {
        return new ReflectionToStringBuilder(this).toString();
    }

    public boolean isRemoveEclipsingBinariesOnList() {
        return removeEclipsingBinariesOnList;
    }
    
    public boolean isGapFillModeIsAddBackPredictionError() {
        return gapFillModeIsAddBackPredictionError;
    }

    public float getMadXFactor() {
        return madXFactor;
    }

    public int getMaxArOrderLimit() {
        return maxArOrderLimit;
    }

    public int getMaxCorrelationWindowXFactor() {
        return maxCorrelationWindowXFactor;
    }

    public int getMaxDetrendPolyOrder() {
        return maxDetrendPolyOrder;
    }

    public float getMaxGiantTransitDurationInHours() {
        return maxGiantTransitDurationInHours;
    }

    public void setGapFillModeIsAddBackPredictionError(
        boolean gapFillModeIsAddBackPredictionError) {
        this.gapFillModeIsAddBackPredictionError = gapFillModeIsAddBackPredictionError;
    }

    public void setMadXFactor(float madXFactor) {
        this.madXFactor = madXFactor;
    }

    public void setMaxArOrderLimit(int maxArOrderLimit) {
        this.maxArOrderLimit = maxArOrderLimit;
    }

    public void setMaxCorrelationWindowXFactor(int maxCorrelationWindowXFactor) {
        this.maxCorrelationWindowXFactor = maxCorrelationWindowXFactor;
    }

    public void setMaxDetrendPolyOrder(int maxDetrendPolyOrder) {
        this.maxDetrendPolyOrder = maxDetrendPolyOrder;
    }

    public void setMaxGiantTransitDurationInHours(
        float maxGiantTransitDurationInHours) {
        this.maxGiantTransitDurationInHours = maxGiantTransitDurationInHours;
    }

    public String getWaveletFamily() {
        return waveletFamily;
    }

    public void setWaveletFamily(String waveletFamily) {
        this.waveletFamily = waveletFamily;
    }

    public int getWaveletFilterLength() {
        return waveletFilterLength;
    }

    public void setWaveletFilterLength(int filterLength) {
        this.waveletFilterLength = filterLength;
    }

    public float getGiantTransitPolyFitChunkLengthInHours() {
        return giantTransitPolyFitChunkLengthInHours;
    }

    public void setGiantTransitPolyFitChunkLengthInHours(
        float giantTransitPolyFitChunkLengthInHours) {
        this.giantTransitPolyFitChunkLengthInHours = giantTransitPolyFitChunkLengthInHours;
    }
    
    public void setRemoveEclipsingBinariesOnList(boolean newValue) {
        removeEclipsingBinariesOnList = newValue;
    }

    public float getArAutoCorrelationThreshold() {
        return arAutoCorrelationThreshold;
    }

    public void setArAutoCorrelationThreshold(float arAutoCorrelationThreshold) {
        this.arAutoCorrelationThreshold = arAutoCorrelationThreshold;
    }

}
