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
 * Useful if you want to implement the TargetBlob interface.
 * 
 * @author Forrest Girouard
 * 
 */
@Entity
@Table(name = "MC_TARGET_BLOBS")
@Inheritance(strategy = InheritanceType.SINGLE_TABLE)
public abstract class AbstractTargetBlob implements TargetBlob {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "mc")
    @SequenceGenerator(name = "mc", sequenceName = "MC_SEQ")
    // required by Hibernate
    private long id;

    private long createTime;

    private int keplerId;

    private String fileExtension;

    protected AbstractTargetBlob() {
    }

    protected AbstractTargetBlob(long createTime, int keplerId) {

        this.createTime = createTime;
        this.keplerId = keplerId;
    }

    protected AbstractTargetBlob(long createTime, int keplerId,
        String fileExtension) {

        this(createTime, keplerId);
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
            "createTime", createTime)
            .append("keplerId", keplerId);
        if (fileExtension != null) {
            builder.append("fileExtension", fileExtension);
        }
        return builder.toString();
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + keplerId;
        result = prime * result + (int) (createTime ^ createTime >>> 32);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof AbstractTargetBlob)) {
            return false;
        }
        AbstractTargetBlob other = (AbstractTargetBlob) obj;
        if (keplerId != other.keplerId) {
            return false;
        }
        if (createTime != other.createTime) {
            return false;
        }
        return true;
    }

    @Override
    public int getKeplerId() {
        return keplerId;
    }

    public void setKeplerId(int keplerId) {
        this.keplerId = keplerId;
    }

    public long getCreateTime() {
        return createTime;
    }

    public void setCreateTime(long createTime) {
        this.createTime = createTime;
    }

    @Override
    public long getCreationTime() {
        return createTime;
    }

    public String getFileExtension() {
        return fileExtension;
    }

    @Override
    public long getId() {
        return id;
    }

    /** Only use this to test this class. */
    public void testSetId(long id) {
        if (this.id != 0) {
            throw new IllegalStateException("Id is already set.");
        }
        this.id = id;
    }

}
