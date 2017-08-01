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
 * Common bootstrap parameters.
 * 
 * @author Forrest Girouard
 */
public class BootstrapModuleParameters implements Persistable, Parameters {

    private boolean autoSkipCountEnabled;
    private int binsBelowSearchTransitThreshold;
    private boolean convolutionMethodEnabled;
    private boolean deemphasizeQuartersWithoutTransits;
    private float histogramBinWidth;
    private float maxAllowedMes;
    private int maxAllowedTransitCount;
    private long maxIterations;
    private int maxNumberBins;
    private int skipCount;
    private int upperLimitFactor;
    private boolean useTceTrialPulseOnly;
    private float sesZeroCrossingWidthDays;
    private float sesZeroCrossingDensityFactor;
    private int nSesPeaksToRemove;
    private float sesPeakRemovalThreshold;
    private float sesPeakRemovalFloor;
    private int bootstrapResolutionFactor;

    public boolean isAutoSkipCountEnabled() {
        return autoSkipCountEnabled;
    }

    public void setAutoSkipCountEnabled(boolean autoSkipCountEnabled) {
        this.autoSkipCountEnabled = autoSkipCountEnabled;
    }

    public int getBinsBelowSearchTransitThreshold() {
        return binsBelowSearchTransitThreshold;
    }

    public void setBinsBelowSearchTransitThreshold(
        int binsBelowSearchTransitThreshold) {
        this.binsBelowSearchTransitThreshold = binsBelowSearchTransitThreshold;
    }

    public boolean isConvolutionMethodEnabled() {
        return convolutionMethodEnabled;
    }

    public void setConvolutionMethodEnabled(boolean convolutionMethodEnabled) {
        this.convolutionMethodEnabled = convolutionMethodEnabled;
    }

    public boolean isDeemphasizeQuartersWithoutTransits() {
        return deemphasizeQuartersWithoutTransits;
    }

    public void setDeemphasizeQuartersWithoutTransits(
        boolean deemphasizeQuartersWithoutTransits) {
        this.deemphasizeQuartersWithoutTransits = deemphasizeQuartersWithoutTransits;
    }

    public float getHistogramBinWidth() {
        return histogramBinWidth;
    }

    public void setHistogramBinWidth(float histogramBinWidth) {
        this.histogramBinWidth = histogramBinWidth;
    }

    public float getMaxAllowedMes() {
        return maxAllowedMes;
    }

    public void setMaxAllowedMes(float maxAllowedMes) {
        this.maxAllowedMes = maxAllowedMes;
    }

    public int getMaxAllowedTransitCount() {
        return maxAllowedTransitCount;
    }

    public void setMaxAllowedTransitCount(int maxAllowedTransitCount) {
        this.maxAllowedTransitCount = maxAllowedTransitCount;
    }

    public long getMaxIterations() {
        return maxIterations;
    }

    public void setMaxIterations(long maxIterations) {
        this.maxIterations = maxIterations;
    }

    public int getMaxNumberBins() {
        return maxNumberBins;
    }

    public void setMaxNumberBins(int maxNumberBins) {
        this.maxNumberBins = maxNumberBins;
    }

    public int getSkipCount() {
        return skipCount;
    }

    public void setSkipCount(int skipCount) {
        this.skipCount = skipCount;
    }

    public int getUpperLimitFactor() {
        return upperLimitFactor;
    }

    public void setUpperLimitFactor(int upperLimitFactor) {
        this.upperLimitFactor = upperLimitFactor;
    }

    public boolean isUseTceTrialPulseOnly() {
        return useTceTrialPulseOnly;
    }

    public void setUseTceTrialPulseOnly(boolean useTceTrialPulseOnly) {
        this.useTceTrialPulseOnly = useTceTrialPulseOnly;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + (autoSkipCountEnabled ? 1231 : 1237);
        result = prime * result + binsBelowSearchTransitThreshold;
        result = prime * result + bootstrapResolutionFactor;
        result = prime * result + Float.floatToIntBits(histogramBinWidth);
        result = prime * result + (int) (maxIterations ^ (maxIterations >>> 32));
        result = prime * result + maxNumberBins;
        result = prime * result + nSesPeaksToRemove;
        result = prime * result + Float.floatToIntBits(sesPeakRemovalFloor);
        result = prime * result + Float.floatToIntBits(sesPeakRemovalThreshold);
        result = prime * result + Float.floatToIntBits(sesZeroCrossingDensityFactor);
        result = prime * result + Float.floatToIntBits(sesZeroCrossingWidthDays);
        result = prime * result + skipCount;
        result = prime * result + upperLimitFactor;
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
        BootstrapModuleParameters other = (BootstrapModuleParameters) obj;
        if (autoSkipCountEnabled != other.autoSkipCountEnabled) {
            return false;
        }
        if (binsBelowSearchTransitThreshold != other.binsBelowSearchTransitThreshold) {
            return false;
        }
        if (bootstrapResolutionFactor != other.bootstrapResolutionFactor) {
            return false;
        }
        if (Float.floatToIntBits(histogramBinWidth) != Float.floatToIntBits(other.histogramBinWidth)) {
            return false;
        }
        if (maxIterations != other.maxIterations) {
            return false;
        }
        if (maxNumberBins != other.maxNumberBins) {
            return false;
        }
        if (nSesPeaksToRemove != other.nSesPeaksToRemove) {
            return false;
        }
        if (Float.floatToIntBits(sesPeakRemovalFloor) != Float.floatToIntBits(other.sesPeakRemovalFloor)) {
            return false;
        }
        if (Float.floatToIntBits(sesPeakRemovalThreshold) != Float.floatToIntBits(other.sesPeakRemovalThreshold)) {
            return false;
        }
        if (Float.floatToIntBits(sesZeroCrossingDensityFactor) != Float.floatToIntBits(other.sesZeroCrossingDensityFactor)) {
            return false;
        }
        if (Float.floatToIntBits(sesZeroCrossingWidthDays) != Float.floatToIntBits(other.sesZeroCrossingWidthDays)) {
            return false;
        }
        if (skipCount != other.skipCount) {
            return false;
        }
        if (upperLimitFactor != other.upperLimitFactor) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }

    public float getSesZeroCrossingWidthDays() {
        return sesZeroCrossingWidthDays;
    }

    public void setSesZeroCrossingWidthDays(float sesZeroCrossingWidthDays) {
        this.sesZeroCrossingWidthDays = sesZeroCrossingWidthDays;
    }

    public float getSesZeroCrossingDensityFactor() {
        return sesZeroCrossingDensityFactor;
    }

    public void setSesZeroCrossingDensityFactor(float sesZeroCrossingDensityFactor) {
        this.sesZeroCrossingDensityFactor = sesZeroCrossingDensityFactor;
    }

    public int getnSesPeaksToRemove() {
        return nSesPeaksToRemove;
    }

    public void setnSesPeaksToRemove(int nSesPeaksToRemove) {
        this.nSesPeaksToRemove = nSesPeaksToRemove;
    }

    public float getSesPeakRemovalThreshold() {
        return sesPeakRemovalThreshold;
    }

    public void setSesPeakRemovalThreshold(float sesPeakRemovalThreshold) {
        this.sesPeakRemovalThreshold = sesPeakRemovalThreshold;
    }

    public float getSesPeakRemovalFloor() {
        return sesPeakRemovalFloor;
    }

    public void setSesPeakRemovalFloor(float sesPeakRemovalFloor) {
        this.sesPeakRemovalFloor = sesPeakRemovalFloor;
    }

    public int getBootstrapResolutionFactor() {
        return bootstrapResolutionFactor;
    }

    public void setBootstrapResolutionFactor(int bootstrapResolutionFactor) {
        this.bootstrapResolutionFactor = bootstrapResolutionFactor;
    }
}
