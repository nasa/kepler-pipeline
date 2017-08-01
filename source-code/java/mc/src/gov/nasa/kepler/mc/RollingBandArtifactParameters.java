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

import org.apache.commons.lang.ArrayUtils;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

public class RollingBandArtifactParameters implements Parameters, Persistable {
     
    private int cleaningScale;
    private float meanSigmaThreshold;
    private int numberOfFlagVariables;
    private float pixelNoiseThresholdAduPerRead;
    private float pixelBiasThresholdAduPerRead;
    private float robustWeightThreshold;
    private float[] severityQuantiles = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private int[] testPulseDurations = ArrayUtils.EMPTY_INT_ARRAY;
    private float transitDepthSigmaThreshold;
    
    public int getCleaningScale() {
        return cleaningScale;
    }
    
    public void setCleaningScale(int cleaningScale) {
        this.cleaningScale = cleaningScale;
    }
    
    public float getMeanSigmaThreshold() {
        return meanSigmaThreshold;
    }
    
    public void setMeanSigmaThreshold(float meanSigmaThreshold) {
        this.meanSigmaThreshold = meanSigmaThreshold;
    }
    
    public int getNumberOfFlagVariables() {
        return numberOfFlagVariables;
    }
    
    public void setNumberOfFlagVariables(int numberOfFlagVariables) {
        this.numberOfFlagVariables = numberOfFlagVariables;
    }
    
    public float getPixelNoiseThresholdAduPerRead() {
        return pixelNoiseThresholdAduPerRead;
    }
    
    public void setPixelNoiseThresholdAduPerRead(float pixelNoiseThresholdAduPerRead) {
        this.pixelNoiseThresholdAduPerRead = pixelNoiseThresholdAduPerRead;
    }
    
    public float getPixelBiasThresholdAduPerRead() {
        return pixelBiasThresholdAduPerRead;
    }
    
    public void setPixelBiasThresholdAduPerRead(float pixelBiasThresholdAduPerRead) {
        this.pixelBiasThresholdAduPerRead = pixelBiasThresholdAduPerRead;
    }
    
    public float getRobustWeightThreshold() {
        return robustWeightThreshold;
    }
    
    public void setRobustWeightThreshold(float robustWeightThreshold) {
        this.robustWeightThreshold = robustWeightThreshold;
    }
    
    public float[] getSeverityQuantiles() {
        return severityQuantiles;
    }
    
    public void setSeverityQuantiles(float[] severityQuantiles) {
        this.severityQuantiles = severityQuantiles;
    }

    public int[] getTestPulseDurations() {
        return testPulseDurations;
    }

    public void setTestPulseDurations(int[] testPulseDurations) {
        this.testPulseDurations = testPulseDurations;
    }
    
    public float getTransitDepthSigmaThreshold() {
        return transitDepthSigmaThreshold;
    }
    
    public void setTransitDepthSigmaThreshold(float transitDepthSigmaThreshold) {
        this.transitDepthSigmaThreshold = transitDepthSigmaThreshold;
    }
}
