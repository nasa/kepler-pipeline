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

package gov.nasa.kepler.pdq;

import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;

import java.util.Collection;

import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * A PDQ stellar target, contains all the information necessary for PDQ to
 * process this stellar target.
 * 
 * @author Forrest Girouard
 * 
 */
public class PdqStellarTarget extends PdqTarget {

    /**
     * The Kepler ID for this target (directly from the KIC).
     */
    private int keplerId;

    /**
     * The right ascension for this target in hours (directly from the KIC).
     */
    private double raHours;

    /**
     * The declination of this target in degrees (directly from the KIC).
     */
    private double decDegrees;

    /**
     * The magnitude of this target (directly from the KIC)
     */
    private float keplerMag;

    /**
     * The fraction of the flux in the optimal aperture (from TAD).
     */
    private double fluxFractionInAperture;

    public PdqStellarTarget() {
        super();
    }

    PdqStellarTarget(final int ccdModule, final int ccdOutput,
        final ObservedTarget target,
        final Collection<TargetDefinition> targetDefs,
        final CelestialObjectParameters celestialObjectParameters) {
        super(ccdModule, ccdOutput, target, targetDefs);
        this.keplerId = target.getKeplerId();
        this.fluxFractionInAperture = target.getFluxFractionInAperture();

        if (celestialObjectParameters != null) {
            this.decDegrees = celestialObjectParameters.getDec()
                .getValue();
            this.raHours = celestialObjectParameters.getRa()
                .getValue();
            this.keplerMag = (float) celestialObjectParameters.getKeplerMag()
                .getValue();
        }
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = super.hashCode();
        long temp;
        temp = Double.doubleToLongBits(decDegrees);
        result = PRIME * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(fluxFractionInAperture);
        result = PRIME * result + (int) (temp ^ (temp >>> 32));
        result = PRIME * result + keplerId;
        result = PRIME * result + Float.floatToIntBits(keplerMag);
        temp = Double.doubleToLongBits(raHours);
        result = PRIME * result + (int) (temp ^ (temp >>> 32));
        return result;
    }

    @Override
    public boolean equals(final Object obj) {
        if (this == obj) {
            return true;
        }
        if (!super.equals(obj)) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final PdqStellarTarget other = (PdqStellarTarget) obj;
        if (Double.doubleToLongBits(decDegrees) != Double.doubleToLongBits(other.decDegrees)) {
            return false;
        }
        if (Double.doubleToLongBits(fluxFractionInAperture) != Double.doubleToLongBits(other.fluxFractionInAperture)) {
            return false;
        }
        if (keplerId != other.keplerId) {
            return false;
        }
        if (Float.floatToIntBits(keplerMag) != Float.floatToIntBits(other.keplerMag)) {
            return false;
        }
        if (Double.doubleToLongBits(raHours) != Double.doubleToLongBits(other.raHours)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("raHours", raHours)
            .append("decDegrees", decDegrees)
            .append("keplerId", keplerId)
            .append("keplerMag", keplerMag)
            .append("fluxFractionInAperture", fluxFractionInAperture)
            .appendSuper(super.toString())
            .toString();
    }

    public double getDecDegrees() {
        return decDegrees;
    }

    public void setDecDegrees(final double decDegrees) {
        this.decDegrees = decDegrees;
    }

    public double getFluxFractionInAperture() {
        return fluxFractionInAperture;
    }

    public void setFluxFractionInAperture(final double fluxFractionInAperture) {
        this.fluxFractionInAperture = fluxFractionInAperture;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public void setKeplerId(final int keplerId) {
        this.keplerId = keplerId;
    }

    public float getKeplerMag() {
        return keplerMag;
    }

    public void setKeplerMag(final float keplerMag) {
        this.keplerMag = keplerMag;
    }

    public double getRaHours() {
        return raHours;
    }

    public void setRaHours(final double raHours) {
        this.raHours = raHours;
    }

}
