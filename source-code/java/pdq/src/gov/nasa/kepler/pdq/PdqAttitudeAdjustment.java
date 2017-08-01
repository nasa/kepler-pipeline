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

import gov.nasa.kepler.hibernate.dr.RefPixelLog;
import gov.nasa.kepler.hibernate.pdq.AttitudeAdjustment;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.spiffy.common.persistable.OracleDouble;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Arrays;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * Contains the representation of an attitude adjustment returned by the science
 * algorithm.
 * 
 * @author fgirouard
 * 
 */
public final class PdqAttitudeAdjustment implements Persistable {

    /**
     * The attitude adjustment specified as a delta quaternion.
     */
    @OracleDouble
    private double[] quaternion = new double[4];

    public PdqAttitudeAdjustment() {
    }

    public AttitudeAdjustment createAttitudeAdjustment(
        final PipelineTask pipelineTask, final RefPixelLog refPixelLog) {
        return new AttitudeAdjustment(pipelineTask, refPixelLog,
            quaternion[AttitudeAdjustment.QUATERNION_X],
            quaternion[AttitudeAdjustment.QUATERNION_Y],
            quaternion[AttitudeAdjustment.QUATERNION_Z],
            quaternion[AttitudeAdjustment.QUATERNION_W]);
    }

    public double[] getQuaternion() {
        return Arrays.copyOf(quaternion, quaternion.length);
    }

    public double getX() {
        return quaternion[AttitudeAdjustment.QUATERNION_X];
    }

    public double getY() {
        return quaternion[AttitudeAdjustment.QUATERNION_Y];
    }

    public double getZ() {
        return quaternion[AttitudeAdjustment.QUATERNION_Z];
    }

    public double getW() {
        return quaternion[AttitudeAdjustment.QUATERNION_W];
    }

    public void setQuaternion(final double[] quaternion) {
        this.quaternion = Arrays.copyOf(quaternion, quaternion.length);
    }

    public void setX(final double x) {
        this.quaternion[AttitudeAdjustment.QUATERNION_X] = x;
    }

    public void setY(final double y) {
        this.quaternion[AttitudeAdjustment.QUATERNION_Y] = y;
    }

    public void setZ(final double z) {
        this.quaternion[AttitudeAdjustment.QUATERNION_Z] = z;
    }

    public void setW(final double w) {
        this.quaternion[AttitudeAdjustment.QUATERNION_W] = w;
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + Arrays.hashCode(quaternion);
        return result;
    }

    @Override
    public boolean equals(final Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof PdqAttitudeAdjustment)) {
            return false;
        }
        final PdqAttitudeAdjustment other = (PdqAttitudeAdjustment) obj;
        if (!Arrays.equals(quaternion, other.quaternion)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }
}
