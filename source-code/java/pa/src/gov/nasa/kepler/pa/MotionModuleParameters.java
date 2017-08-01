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

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

public class MotionModuleParameters implements Parameters, Persistable {

    private int aicDecimationFactor;
    private boolean aicOrderSelectionEnabled;
    private int centroidBiasFitOrder;
    private int centroidBiasRemovalIterations;
    private int columnFitOrder;
    private int fitMaxOrder;

    /**
     * Minimum number of points required to create a valid motion polynomial.
     */
    private int fitMinPoints;

    private boolean k2PpaTargetRejectionEnabled;

    private int maxGappingIterations;
    private float robustWeightGappingThreshold;
    private int rowFitOrder;

    public int getAicDecimationFactor() {
        return aicDecimationFactor;
    }

    public void setAicDecimationFactor(int aicDecimationFactor) {
        this.aicDecimationFactor = aicDecimationFactor;
    }

    public boolean isAicOrderSelectionEnabled() {
        return aicOrderSelectionEnabled;
    }

    public void setAicOrderSelectionEnabled(
        final boolean aicOrderSelectionEnabled) {
        this.aicOrderSelectionEnabled = aicOrderSelectionEnabled;
    }

    public int getCentroidBiasFitOrder() {
        return centroidBiasFitOrder;
    }

    public void setCentroidBiasFitOrder(int centroidBiasFitOrder) {
        this.centroidBiasFitOrder = centroidBiasFitOrder;
    }

    public int getCentroidBiasRemovalIterations() {
        return centroidBiasRemovalIterations;
    }

    public void setCentroidBiasRemovalIterations(
        int centroidBiasRemovalIterations) {
        this.centroidBiasRemovalIterations = centroidBiasRemovalIterations;
    }

    public int getColumnFitOrder() {
        return columnFitOrder;
    }

    public void setColumnFitOrder(final int columnFitOrder) {
        this.columnFitOrder = columnFitOrder;
    }

    public int getFitMaxOrder() {
        return fitMaxOrder;
    }

    public void setFitMaxOrder(final int fitMaxOrder) {
        this.fitMaxOrder = fitMaxOrder;
    }

    public int getFitMinPoints() {
        return fitMinPoints;
    }

    public void setFitMinPoints(final int fitMinPoints) {
        this.fitMinPoints = fitMinPoints;
    }
    
    public boolean isK2PpaTargetRejectionEnabled() {
        return k2PpaTargetRejectionEnabled;
    }
    
    public void setK2PpaTargetRejectionEnabled(boolean k2PpaTargetRejectionDisabled) {
        this.k2PpaTargetRejectionEnabled = k2PpaTargetRejectionEnabled;
    }

    public int getMaxGappingIterations() {
        return maxGappingIterations;
    }

    public void setMaxGappingIterations(int maxGappingIterations) {
        this.maxGappingIterations = maxGappingIterations;
    }

    public float getRobustWeightGappingThreshold() {
        return robustWeightGappingThreshold;
    }

    public void setRobustWeightGappingThreshold(
        float robustWeightGappingThreshold) {
        this.robustWeightGappingThreshold = robustWeightGappingThreshold;
    }

    public int getRowFitOrder() {
        return rowFitOrder;
    }

    public void setRowFitOrder(final int rowFitOrder) {
        this.rowFitOrder = rowFitOrder;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }
}
