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

package gov.nasa.kepler.dv.io;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * Module parameters used to configure the trapezoidal model fit.
 * 
 * @author Bill Wohler
 */
public class TrapezoidalFitParameters implements Persistable, Parameters {
    private float defaultSmoothingParameter;
    private int filterCircularShift;
    private int gapThreshold;
    private int medianFilterLength;
    private float snrThreshold;
    private float transitFitRegion;
    private int transitSamplesPerCadence;

    public float getDefaultSmoothingParameter() {
        return defaultSmoothingParameter;
    }

    public void setDefaultSmoothingParameter(float defaultSmoothingParameter) {
        this.defaultSmoothingParameter = defaultSmoothingParameter;
    }

    public int getFilterCircularShift() {
        return filterCircularShift;
    }

    public void setFilterCircularShift(int filterCircularShift) {
        this.filterCircularShift = filterCircularShift;
    }

    public int getGapThreshold() {
        return gapThreshold;
    }

    public void setGapThreshold(int gapThreshold) {
        this.gapThreshold = gapThreshold;
    }

    public int getMedianFilterLength() {
        return medianFilterLength;
    }

    public void setMedianFilterLength(int medianFilterLength) {
        this.medianFilterLength = medianFilterLength;
    }

    public float getSnrThreshold() {
        return snrThreshold;
    }

    public void setSnrThreshold(float snrThreshold) {
        this.snrThreshold = snrThreshold;
    }

    public float getTransitFitRegion() {
        return transitFitRegion;
    }

    public void setTransitFitRegion(float transitFitRegion) {
        this.transitFitRegion = transitFitRegion;
    }

    public int getTransitSamplesPerCadence() {
        return transitSamplesPerCadence;
    }

    public void setTransitSamplesPerCadence(int transitSamplesPerCadence) {
        this.transitSamplesPerCadence = transitSamplesPerCadence;
    }
}
