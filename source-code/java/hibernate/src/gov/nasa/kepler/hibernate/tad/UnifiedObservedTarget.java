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

package gov.nasa.kepler.hibernate.tad;

import gov.nasa.kepler.hibernate.pi.PipelineTask;

import java.util.Collection;
import java.util.Set;

import static com.google.common.base.Preconditions.checkNotNull;

/**
 * WARNING:  Do NOT use this class.
 * 
 * A wrapper like class for ObservedTarget.  This unifies information from
 * the supplemental version of the ObservedTarget and the initial version of
 * the ObservedTarget.  This is not a Hibernate entity.
 * 
 * @author Sean McCauliff
 *
 */
public class UnifiedObservedTarget extends ObservedTarget {

    
    private TargetTable originalTargetTable;
    private TargetTable suppTargetTable;
    private int clippedPixelCount = -1;
    private Aperture aperture;
    private Collection<TargetDefinition> targetDefinitions;
    private boolean wasDroppedBySupplementalTad;
    private double crowdingMetric;
    private double fluxFractionInAperture;
    private Set<String> labels;
    private PipelineTask pipelineTask;
    
    /**
     * This is here for testing.
     */
    UnifiedObservedTarget() {
        
    }
    
    /**
     * Initialize with the supplemental tad information, unless that does not
     * exist in which case this should be initalized with information from the
     * original tad run.
     * 
     * @param keplerId
     * @param fluxFractionInAperture
     * @param crowdingMetric
     * @param ccdModule
     * @param ccdOutput
     * @param originalTargetTable
     * @param suppTargetTable  This may be null.
     * @param aperture
     * @param targetDefinitions
     * @param labels
     */
    public UnifiedObservedTarget(
        int keplerId,
        double fluxFractionInAperture,
        double crowdingMetric,
        int ccdModule, int ccdOutput,
        TargetTable originalTargetTable,
        TargetTable suppTargetTable,
        Aperture aperture,
        Set<String> labels,
        boolean wasDroppedBySupplementalTad,
        PipelineTask pipelineTask) {
        
        super(originalTargetTable, ccdModule, ccdOutput, keplerId);

        checkNotNull(originalTargetTable, "originalTargetTable");
        
        checkNotNull(aperture, "aperture");
        
        checkNotNull(labels, "labels");

        checkNotNull(pipelineTask, "pipelineTask");
        
        this.wasDroppedBySupplementalTad = wasDroppedBySupplementalTad;
        this.originalTargetTable = originalTargetTable;
        this.suppTargetTable = suppTargetTable;
        this.aperture = aperture;
        
        this.fluxFractionInAperture  = fluxFractionInAperture;
        this.crowdingMetric = crowdingMetric;
        this.labels = labels;
        this.pipelineTask = pipelineTask;
    }
    
    public TargetTable originalTargetTable() {
        return originalTargetTable;
    }
    
    public TargetTable suppTargetTable() {
        return suppTargetTable;
    }

    
    @Override
    public Aperture getAperture() {
        return aperture;
    }
    
    @Override
    public void setAperture(Aperture newAperture) {
        this.aperture = newAperture;
    }
    
    @Override
    public int getClippedPixelCount() {
        return clippedPixelCount;
    }
    
    public void setClippedPixelCount(int newValue) {
        this.clippedPixelCount = newValue;
    }
    
    @Override
    public Collection<TargetDefinition> getTargetDefinitions() {
        return targetDefinitions;
    }
    
    @Override
    public void setTargetDefinitions(Collection<TargetDefinition> targetDefinitions) {
        if (targetDefinitions == null || targetDefinitions.isEmpty()) {
            throw new IllegalArgumentException("Missing target definitions.");
        }
        this.targetDefinitions = targetDefinitions;
    }
    
    public boolean wasDroppedBySupplementalTad() {
        return wasDroppedBySupplementalTad;
    }
    
    @Override
    public Set<String> getLabels() {
        return labels;
    }
    
    @Override
    public double getFluxFractionInAperture() {
        return fluxFractionInAperture;
    }
    
    @Override
    public double getCrowdingMetric() {
        return crowdingMetric;
    }
    
    /**
     * The task that is returned has getId() as the only valid method that can
     * be called on it.
     */
    @Override
    public PipelineTask getPipelineTask() {
        return pipelineTask;
    }
    

    /////////////////Unsupported methods ////////////////////
    // add setters.
    @Override
    public long getId() {
        throw new UnsupportedOperationException();
    }
    
    @Override
    public int getBadPixelCount() {
        throw new UnsupportedOperationException();
    }
    
    @Override
    public double getSignalToNoiseRatio() {
        throw new UnsupportedOperationException();
    }
    
    @Override
    public float getMagnitude() {
        throw new UnsupportedOperationException();
    }
    
    @Override
    public double getRa() {
        throw new UnsupportedOperationException();
    }
    
    @Override
    public double getDec() {
        throw new UnsupportedOperationException();
    }
    
    @Override
    public float getEffectiveTemp() {
        throw new UnsupportedOperationException();
    }
    
    @Override
    public int getAperturePixelCount() {
        throw new UnsupportedOperationException();
    }
    
    @Override
    public int getTargetDefsPixelCount() {
        throw new UnsupportedOperationException();
    }
    
    @Override
    public int getSaturatedRowCount() {
        throw new UnsupportedOperationException();
    }
    
    @Override
    public int getDistanceFromEdge() {
        throw new UnsupportedOperationException();
    }
    
    @Override
    public double getSkyCrowdingMetric() {
        throw new UnsupportedOperationException();
    }
    
    /**
     * Make sure we don't accidently invoke any unwanted behavior.
     */
    @Override
    protected ObservedTarget getObservedTarget() {
        throw new UnsupportedOperationException();
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = super.hashCode();
        result = prime * result
            + ((aperture == null) ? 0 : aperture.hashCode());
        result = prime * result + clippedPixelCount;
        long temp;
        temp = Double.doubleToLongBits(crowdingMetric);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(fluxFractionInAperture);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        result = prime * result + ((labels == null) ? 0 : labels.hashCode());
        result = prime
            * result
            + ((originalTargetTable == null) ? 0
                : originalTargetTable.hashCode());
        result = prime * result
            + ((suppTargetTable == null) ? 0 : suppTargetTable.hashCode());
        result = prime * result
            + ((targetDefinitions == null) ? 0 : targetDefinitions.hashCode());
        result = prime * result + (wasDroppedBySupplementalTad ? 1231 : 1237);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (!super.equals(obj))
            return false;
        if (getClass() != obj.getClass())
            return false;
        UnifiedObservedTarget other = (UnifiedObservedTarget) obj;
        if (aperture == null) {
            if (other.aperture != null)
                return false;
        } else if (!aperture.equals(other.aperture))
            return false;
        if (clippedPixelCount != other.clippedPixelCount)
            return false;
        if (Double.doubleToLongBits(crowdingMetric) != Double.doubleToLongBits(other.crowdingMetric))
            return false;
        if (Double.doubleToLongBits(fluxFractionInAperture) != Double.doubleToLongBits(other.fluxFractionInAperture))
            return false;
        if (labels == null) {
            if (other.labels != null)
                return false;
        } else if (!labels.equals(other.labels))
            return false;
        if (originalTargetTable == null) {
            if (other.originalTargetTable != null)
                return false;
        } else if (!originalTargetTable.equals(other.originalTargetTable))
            return false;
        if (suppTargetTable == null) {
            if (other.suppTargetTable != null)
                return false;
        } else if (!suppTargetTable.equals(other.suppTargetTable))
            return false;
        if (targetDefinitions == null) {
            if (other.targetDefinitions != null)
                return false;
        } else if (!targetDefinitions.equals(other.targetDefinitions))
            return false;
        if (wasDroppedBySupplementalTad != other.wasDroppedBySupplementalTad)
            return false;
        return true;
    }
    
    
}
