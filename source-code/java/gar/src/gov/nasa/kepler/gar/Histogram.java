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

package gov.nasa.kepler.gar;

import gov.nasa.spiffy.common.persistable.Persistable;

public class Histogram implements Persistable {

    private int baselineInterval;

    private float uncompressedBaselineOverheadRate;
    private float theoreticalCompressionRate;
    private float totalStorageRate;

    private long[] histogram;

    /**
     * For use by MATLAB controller.
     */
    public Histogram() {
    }

    /**
     * Creates a {@link Histogram} for the given baseline interval.
     * 
     * @param baselineInterval the baseline interval.
     */
    public Histogram(int baselineInterval) {
        this.baselineInterval = baselineInterval;
    }

    public int getBaselineInterval() {
        return baselineInterval;
    }

    public void setBaselineInterval(int baselineInterval) {
        this.baselineInterval = baselineInterval;
    }

    public long[] getHistogram() {
        return histogram;
    }

    public void setHistogram(long[] histogram) {
        this.histogram = histogram;
    }

    public float getTheoreticalCompressionRate() {
        return theoreticalCompressionRate;
    }

    public void setTheoreticalCompressionRate(float theoreticalCompressionRate) {
        this.theoreticalCompressionRate = theoreticalCompressionRate;
    }

    public float getTotalStorageRate() {
        return totalStorageRate;
    }

    public void setTotalStorageRate(float totalStorageRate) {
        this.totalStorageRate = totalStorageRate;
    }

    public float getUncompressedBaselineOverheadRate() {
        return uncompressedBaselineOverheadRate;
    }

    public void setUncompressedBaselineOverheadRate(
        float uncompressedBaselineOverheadRate) {
        this.uncompressedBaselineOverheadRate = uncompressedBaselineOverheadRate;
    }

}
