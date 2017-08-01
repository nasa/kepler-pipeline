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

package gov.nasa.kepler.hibernate.mc;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.intervals.CadenceBlob;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Inheritance;
import javax.persistence.InheritanceType;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * Useful if you want to implement the CadenceBlob interface.
 * 
 * @author Sean McCauliff
 * 
 */
@Entity
@Table(name = "MC_CADENCE_BLOBS")
@Inheritance(strategy = InheritanceType.SINGLE_TABLE)
public abstract class AbstractCadenceBlob implements CadenceBlob {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "mc")
    @SequenceGenerator(name = "mc", sequenceName = "MC_SEQ")
    // required by Hibernate
    private long id;

    private long pipelineTaskId;

    private int startCadence;
    private int endCadence;

    @Column(nullable = false)
    private CadenceType cadenceType;

    private String fileExtension;

    protected AbstractCadenceBlob() {
    }

    protected AbstractCadenceBlob(long pipelineTaskId, int startCadence,
        int endCadence, CadenceType cadenceType) {

        if (endCadence < startCadence) {
            throw new IllegalArgumentException("endCadence(" + endCadence
                + ") occurs before startCadence(" + startCadence + ")");
        }

        this.pipelineTaskId = pipelineTaskId;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.cadenceType = cadenceType;
    }

    protected AbstractCadenceBlob(long pipelineTaskId, int startCadence,
        int endCadence, CadenceType cadenceType, String fileExtension) {

        this(pipelineTaskId, startCadence, endCadence, cadenceType);
        this.fileExtension = fileExtension;
        if (fileExtension != null && fileExtension.length() > 0) {
            if (!fileExtension.startsWith(".")) {
                this.fileExtension = "." + fileExtension;
            } else {
                this.fileExtension = fileExtension;
            }
        }
    }

    @Override
    public String toString() {
        ToStringBuilder builder = new ToStringBuilder(this).append(
            "pipelineTaskId", pipelineTaskId)
            .append("startCadence", startCadence)
            .append("endCadence", endCadence)
            .append("cadenceType", cadenceType);
        if (fileExtension != null) {
            builder.append("fileExtension", fileExtension);
        }
        return builder.toString();
    }

    @Override
    public boolean equals(Object o) {
        if (o == null) {
            return false;
        }

        if (!(o instanceof AbstractCadenceBlob)) {
            return false;
        }

        AbstractCadenceBlob other = (AbstractCadenceBlob) o;

        if (other.cadenceType != this.cadenceType) {
            return false;
        }
        if (other.startCadence != this.startCadence) {
            return false;
        }
        if (other.endCadence != this.endCadence) {
            return false;
        }
        if (other.pipelineTaskId != this.pipelineTaskId) {
            return false;
        }

        return true;

    }

    @Override
    public int hashCode() {

        int code = cadenceType.ordinal();
        code = code ^ startCadence;
        code = code ^ Integer.rotateLeft(endCadence, 16);
        code = code ^ (int) (pipelineTaskId >>> 32);
        code = code ^ (int) (pipelineTaskId & 0x0000000000FFFFFFFF);
        return code;

    }

    public CadenceType getCadenceType() {
        return cadenceType;
    }

    public void setCadenceType(CadenceType cadenceType) {
        this.cadenceType = cadenceType;
    }

    public long getPipelineTaskId() {
        return pipelineTaskId;
    }

    public void setPipelineTaskId(long pipelineTaskId) {
        this.pipelineTaskId = pipelineTaskId;
    }

    @Override
    public long getCreationTime() {
        return pipelineTaskId;
    }

    @Override
    public int getEndCadence() {
        return endCadence;
    }

    public String getFileExtension() {
        return fileExtension;
    }

    @Override
    public long getId() {
        return id;
    }

    @Override
    public int getStartCadence() {
        return startCadence;
    }
    
    /** Only use this to test this class. */
    public void testSetId(long id) {
        if (this.id != 0) {
            throw new IllegalStateException("Id is already set.");
        }
        this.id = id;
    }

}
