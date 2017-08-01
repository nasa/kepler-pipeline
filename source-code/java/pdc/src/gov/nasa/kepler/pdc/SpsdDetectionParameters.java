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

package gov.nasa.kepler.pdc;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * 
 * @author Forrest Girouard
 */
public class SpsdDetectionParameters implements Parameters, Persistable {

    private float discontinuityRatioTolerance;
    private int endpointFitWindowWidth;
    private int excludeWindowHalfWidth;
    private float falsePositiveRateLimit;
    private boolean harmonicsRemovalEnabled;
    private int maxDetectionIterations;
    private boolean quickSpsdEnabled;
    private float transitSpsdMinmaxDiscriminator;
    private boolean useCentroids;
    private float validationSignificanceThreshold;

    public float getDiscontinuityRatioTolerance() {
        return discontinuityRatioTolerance;
    }

    public void setDiscontinuityRatioTolerance(float discontinuityRatioTolerance) {
        this.discontinuityRatioTolerance = discontinuityRatioTolerance;
    }

    public int getEndpointFitWindowWidth() {
        return endpointFitWindowWidth;
    }

    public void setEndpointFitWindowWidth(int endpointFitWindowWidth) {
        this.endpointFitWindowWidth = endpointFitWindowWidth;
    }

    public int getExcludeWindowHalfWidth() {
        return excludeWindowHalfWidth;
    }

    public void setExcludeWindowHalfWidth(int excludeWindowHalfWidth) {
        this.excludeWindowHalfWidth = excludeWindowHalfWidth;
    }

    public float getFalsePositiveRateLimit() {
        return falsePositiveRateLimit;
    }

    public void setFalsePositiveRateLimit(float falsePositiveRateLimit) {
        this.falsePositiveRateLimit = falsePositiveRateLimit;
    }

    public boolean isHarmonicsRemovalEnabled() {
        return harmonicsRemovalEnabled;
    }

    public void setHarmonicsRemovalEnabled(boolean harmonicsRemovalEnabled) {
        this.harmonicsRemovalEnabled = harmonicsRemovalEnabled;
    }

    public int getMaxDetectionIterations() {
        return maxDetectionIterations;
    }

    public void setMaxDetectionIterations(int maxDetectionIterations) {
        this.maxDetectionIterations = maxDetectionIterations;
    }

    public boolean isQuickSpsdEnabled() {
        return quickSpsdEnabled;
    }

    public void setQuickSpsdEnabled(boolean quickSpsdEnabled) {
        this.quickSpsdEnabled = quickSpsdEnabled;
    }

    public float getTransitSpsdMinmaxDiscriminator() {
        return transitSpsdMinmaxDiscriminator;
    }

    public void setTransitSpsdMinmaxDiscriminator(
        float transitSpsdMinmaxDiscriminator) {
        this.transitSpsdMinmaxDiscriminator = transitSpsdMinmaxDiscriminator;
    }

    public boolean isUseCentroids() {
        return useCentroids;
    }

    public void setUseCentroids(boolean useCentroids) {
        this.useCentroids = useCentroids;
    }

    public float getValidationSignificanceThreshold() {
        return validationSignificanceThreshold;
    }

    public void setValidationSignificanceThreshold(
        float validationSignificanceThreshold) {
        this.validationSignificanceThreshold = validationSignificanceThreshold;
    }
}
