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

package gov.nasa.kepler.etem2;

import gov.nasa.spiffy.common.pi.Parameters;

public class Etem2DitherParameters implements Parameters {

    /**
     * Controls whether dithering is enabled. When enabled, ETEM Java will be
     * called in a loop by Etem2PipelineModule, once for each offset
     */
    private boolean doDithering = false;

    /**
     * Starting cadence number (used by Etem2Fits)
     */
    private int startCadenceNumber = 1;

    /**
     * Number of cadences generated for each offset. Normally this is 2, one
     * with MOTION=false, and one with MOTION=true
     */
    private int cadencesPerOffset = 2;

    /**
     * RA offsets, one for each ETEM run. All three of the offsets arrays must
     * be the same length
     */
    private double[] raOffsets = { 0, -0.000415332, -0.000122864 };

    /**
     * Dec offsets, one for each ETEM run. All three of the offsets arrays must
     * be the same length
     */
    private double[] decOffsets = { 0, -0.000557708, -0.000203062 };

    /**
     * Roll offsets, one for each ETEM run. All three of the offsets arrays must
     * be the same length
     */
    private double[] phiOffsets = { 0.0, 0.0, 0.0 };

    /**
     * Used by {@link ModOutRunNumberUowTaskGenerator} to break up the UOW 
     * by chunks of ETEM runs.  Zero means no binning 
     */
    private int binSize = 0;

    public Etem2DitherParameters() {
    }

    public int computeCadenceCount() {
        return cadencesPerOffset * numOffsets();
    }

    /**
     * Return the number of offsets and verify that all three of the offsets
     * arrays are the same length
     * 
     * @return
     */
    public int numOffsets() {
        if (raOffsets.length != decOffsets.length
            || raOffsets.length != phiOffsets.length) {
            throw new IllegalStateException(
                "Configuration error: Offset arrays are not all the same length: raOffsets("
                    + raOffsets.length + "), decOffsets(" + decOffsets.length
                    + "), phiOffsets(" + phiOffsets.length + ")");
        }

        return raOffsets.length;
    }

    public boolean isDoDithering() {
        return doDithering;
    }

    public void setDoDithering(boolean doDithering) {
        this.doDithering = doDithering;
    }

    public int getCadencesPerOffset() {
        return cadencesPerOffset;
    }

    public void setCadencesPerOffset(int cadencesPerOffset) {
        this.cadencesPerOffset = cadencesPerOffset;
    }

    public double[] getRaOffsets() {
        return raOffsets;
    }

    public void setRaOffsets(double[] raOffsets) {
        this.raOffsets = raOffsets;
    }

    public double[] getDecOffsets() {
        return decOffsets;
    }

    public void setDecOffsets(double[] decOffsets) {
        this.decOffsets = decOffsets;
    }

    public double[] getPhiOffsets() {
        return phiOffsets;
    }

    public void setPhiOffsets(double[] phiOffsets) {
        this.phiOffsets = phiOffsets;
    }

    public int getStartCadenceNumber() {
        return startCadenceNumber;
    }

    public void setStartCadenceNumber(int startCadenceNumber) {
        this.startCadenceNumber = startCadenceNumber;
    }

    /**
     * @return the binSize
     */
    public int getBinSize() {
        return binSize;
    }

    /**
     * @param binSize the binSize to set
     */
    public void setBinSize(int binSize) {
        this.binSize = binSize;
    }
}
