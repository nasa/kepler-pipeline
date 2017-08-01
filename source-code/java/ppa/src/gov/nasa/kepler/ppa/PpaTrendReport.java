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

package gov.nasa.kepler.ppa;

import gov.nasa.kepler.hibernate.ppa.TrendReport;
import gov.nasa.spiffy.common.persistable.Persistable;

/**
 * Trend report for a single metric.
 * <p>
 * Note that the accessors drop the "trend" that are present in the field names
 * (for the convenience of the MATLAB programmer) to avoid repeating ourselves
 * in Java.
 * 
 * @author Bill Wohler
 */
public class PpaTrendReport implements Persistable {

    private boolean trendValid;
    private float trendFitTime;
    private float trendOffset;
    private float trendSlope;
    private float horizonTime;

    /**
     * Creates a {@link PpaTrendReport}.
     */
    public PpaTrendReport() {
    }

    /**
     * Creates a {@link PpaTrendReport} with the given {@link TrendReport}.
     */
    public PpaTrendReport(TrendReport trendReport) {
        setValid(trendReport.isValid());
        setFitTime(trendReport.getFitTime());
        setOffset(trendReport.getOffset());
        setSlope(trendReport.getSlope());
        setHorizonTime(trendReport.getHorizonTime());
    }

    public TrendReport createReport() {
        return new TrendReport(trendValid, trendFitTime, trendOffset,
            trendSlope, horizonTime);
    }

    public boolean isValid() {
        return trendValid;
    }

    public void setValid(boolean valid) {
        trendValid = valid;
    }

    public float getFitTime() {
        return trendFitTime;
    }

    public void setFitTime(float fitTime) {
        trendFitTime = fitTime;
    }

    public float getOffset() {
        return trendOffset;
    }

    public void setOffset(float offset) {
        trendOffset = offset;
    }

    public float getSlope() {
        return trendSlope;
    }

    public void setSlope(float slope) {
        trendSlope = slope;
    }

    public float getHorizonTime() {
        return horizonTime;
    }

    public void setHorizonTime(float horizonTime) {
        this.horizonTime = horizonTime;
    }
}
