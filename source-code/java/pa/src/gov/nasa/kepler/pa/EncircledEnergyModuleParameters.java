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

package gov.nasa.kepler.pa;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

public class EncircledEnergyModuleParameters implements Parameters, Persistable {

    /**
     * Flux fraction for encircled energy metric.
     */
    private float fluxFraction;

    /**
     * Encircled energy polynomial order.
     */
    private int polyOrder;

    /**
     * Target label to identify encircled energy targets.
     */
    private String targetLabel = "";

    /**
     * Maximum number of encircled energy targets.
     */
    private int maxTargets;

    /**
     * Maximum number of encircled energy pixels.
     */
    private int maxPixels;

    /**
     * Seed radious for encircled energy.
     */
    private float seedRadius;

    /**
     * Maximum encircled energy polynomial order.
     */
    private int maxPolyOrder;

    /**
     * AIC fluxFraction for encircled energy.
     */
    private float aicFraction;

    /**
     * Encircled energy target polynomial order.
     */
    private int targetPolyOrder;

    /**
     * Radius in pixels over which to normalize data. Zero invokes dynamic
     * normalization.
     */
    private float maxRadius;

    /**
     * True enables plots during metric calculation.
     */
    private boolean plotsEnabled;

    /**
     * Robust weight threshold below which outliers are rejected during pixel
     * data normalization.
     */
    private float robustThreshold;

    /**
     * True sets cadence gap for metric if robust fit iteration limit is
     * exceeded during pixel data normalization.
     */
    private boolean robustLimitEnabled;

    public EncircledEnergyModuleParameters() {
    }

    public float getAicFraction() {
        return aicFraction;
    }

    public void setAicFraction(final float aicFraction) {
        this.aicFraction = aicFraction;
    }

    public float getFluxFraction() {
        return fluxFraction;
    }

    public void setFluxFraction(final float fluxFraction) {
        this.fluxFraction = fluxFraction;
    }

    public int getMaxPixels() {
        return maxPixels;
    }

    public void setMaxPixels(final int maxPixels) {
        this.maxPixels = maxPixels;
    }

    public int getMaxPolyOrder() {
        return maxPolyOrder;
    }

    public void setMaxPolyOrder(final int maxPolyOrder) {
        this.maxPolyOrder = maxPolyOrder;
    }

    public float getMaxRadius() {
        return maxRadius;
    }

    public void setMaxRadius(final float maxRadius) {
        this.maxRadius = maxRadius;
    }

    public int getMaxTargets() {
        return maxTargets;
    }

    public void setMaxTargets(final int maxTargets) {
        this.maxTargets = maxTargets;
    }

    public boolean isPlotsEnabled() {
        return plotsEnabled;
    }

    public void setPlotsEnabled(final boolean plotsEnabled) {
        this.plotsEnabled = plotsEnabled;
    }

    public int getPolyOrder() {
        return polyOrder;
    }

    public void setPolyOrder(final int polyOrder) {
        this.polyOrder = polyOrder;
    }

    public boolean isRobustLimitEnabled() {
        return robustLimitEnabled;
    }

    public void setRobustLimitEnabled(final boolean robustLimitEnabled) {
        this.robustLimitEnabled = robustLimitEnabled;
    }

    public float getRobustThreshold() {
        return robustThreshold;
    }

    public void setRobustThreshold(final float robustThreshold) {
        this.robustThreshold = robustThreshold;
    }

    public float getSeedRadius() {
        return seedRadius;
    }

    public void setSeedRadius(final float seedRadius) {
        this.seedRadius = seedRadius;
    }

    public String getTargetLabel() {
        return targetLabel;
    }

    public void setTargetLabel(final String targetLabel) {
        this.targetLabel = targetLabel;
    }

    public int getTargetPolyOrder() {
        return targetPolyOrder;
    }

    public void setTargetPolyOrder(final int targetPolyOrder) {
        this.targetPolyOrder = targetPolyOrder;
    }

}
