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

package gov.nasa.kepler.gar.requant;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * Requantization module parameters.
 * 
 * @author Bill Wohler
 */
public class RequantModuleParameters implements Persistable, Parameters {

    private float guardBandHigh;
    private float quantizationFraction;
    private float expectedSmearMaxBlackCorrectedPerReadInAdu;
    private float expectedSmearMinBlackCorrectedPerReadInAdu;
    private boolean rssOutOriginalQuantizationNoiseFlag;
    private float inflationFactorForBufferZone;
    private float twoDBlackTrimPercentage;
    private float trimPercentageForBlackResiduals;
    private int debugFlag;

    public RequantModuleParameters() {
    }

    public float getGuardBandHigh() {
        return guardBandHigh;
    }

    public void setGuardBandHigh(float guardBandHigh) {
        this.guardBandHigh = guardBandHigh;
    }

    public float getQuantizationFraction() {
        return quantizationFraction;
    }

    public void setQuantizationFraction(float quantizationFraction) {
        this.quantizationFraction = quantizationFraction;
    }

    public float getExpectedSmearMaxBlackCorrectedPerReadInAdu() {
        return expectedSmearMaxBlackCorrectedPerReadInAdu;
    }

    public void setExpectedSmearMaxBlackCorrectedPerReadInAdu(
        float expectedSmearMaxBlackCorrectedPerReadInAdu) {
        this.expectedSmearMaxBlackCorrectedPerReadInAdu = expectedSmearMaxBlackCorrectedPerReadInAdu;
    }

    public float getExpectedSmearMinBlackCorrectedPerReadInAdu() {
        return expectedSmearMinBlackCorrectedPerReadInAdu;
    }

    public void setExpectedSmearMinBlackCorrectedPerReadInAdu(
        float expectedSmearMinBlackCorrectedPerReadInAdu) {
        this.expectedSmearMinBlackCorrectedPerReadInAdu = expectedSmearMinBlackCorrectedPerReadInAdu;
    }

    public boolean isRssOutOriginalQuantizationNoiseFlag() {
        return rssOutOriginalQuantizationNoiseFlag;
    }

    public void setRssOutOriginalQuantizationNoiseFlag(
        boolean rssOutOriginalQuantizationNoiseFlag) {
        this.rssOutOriginalQuantizationNoiseFlag = rssOutOriginalQuantizationNoiseFlag;
    }

    public float getInflationFactorForBufferZone() {
        return inflationFactorForBufferZone;
    }

    public void setInflationFactorForBufferZone(
        float inflationFactorForBufferZone) {
        this.inflationFactorForBufferZone = inflationFactorForBufferZone;
    }

    public void setTwoDBlackTrimPercentage(float twoDBlackTrimPercentage) {
        this.twoDBlackTrimPercentage = twoDBlackTrimPercentage;
    }

    public float getTwoDBlackTrimPercentage() {
        return twoDBlackTrimPercentage;
    }

    public float getTrimPercentageForBlackResiduals() {
        return trimPercentageForBlackResiduals;
    }

    public void setTrimPercentageForBlackResiduals(
        float trimPercentageForBlackResiduals) {
        this.trimPercentageForBlackResiduals = trimPercentageForBlackResiduals;
    }

    public int getDebugFlag() {
        return debugFlag;
    }

    public void setDebugFlag(int debugFlag) {
        this.debugFlag = debugFlag;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }
}
