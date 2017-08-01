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

package gov.nasa.kepler.hibernate.pi;

import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.ManyToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

/**
 * Entity used to track revisions of models used in the system for data
 * accountability purposes. This metadata is updated by the model importers.
 * 
 * The metadata contains only the name and revision of the model (as Strings).
 * It does not contain a reference to the model itself, so there is no
 * dependency on model entities or code.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 */
@Entity
@Table(name = "PI_MODEL_METADATA")
public class ModelMetadata {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "PI_MODEL_METADATA_SEQ")
    private long id;

    /**
     * A String identifying the model type (like 'GEOMETRY' or
     * 'SPACECRAFT_EPHEMERIS')
     */
    @ManyToOne(fetch = FetchType.EAGER)
    private ModelType modelType;

    /**
     * A description of the revision, usually provided by the operator when the
     * update is imported.
     */
    private String modelDescription;

    /** A String that uniquely identifies the revision, such as an SVN peg URL */
    private String modelRevision;

    /** The timestamp when the revision was imported */
    private Date importTime;

    /**
     * The timestamp when this revision was locked (referenced by a
     * PipelineInstance)
     */
    private Date lockTime;

    /**
     * Set to true when this revision is referenced by a
     * {@link PipelineInstance}. Subsequent updates result in a new row in this
     * table
     */
    private boolean locked = false;

    public ModelMetadata() {
    }

    public ModelMetadata(ModelType modelType, String modelDescription,
        String modelRevision, Date importTime) {
        this.modelType = modelType;
        this.modelDescription = modelDescription;
        this.modelRevision = modelRevision;
        this.importTime = importTime;
    }

    public void lock() {
        locked = true;
        lockTime = new Date();
    }

    public ModelType getModelType() {
        return modelType;
    }

    public void setModelType(ModelType modelType) {
        this.modelType = modelType;
    }

    public String getModelDescription() {
        return modelDescription;
    }

    public void setModelDescription(String modelDescription) {
        this.modelDescription = modelDescription;
    }

    public String getModelRevision() {
        return modelRevision;
    }

    public void setModelRevision(String modelRevision) {
        this.modelRevision = modelRevision;
    }

    public Date getImportTime() {
        return importTime;
    }

    public void setImportTime(Date importTime) {
        this.importTime = importTime;
    }

    public boolean isLocked() {
        return locked;
    }

    public void setLocked(boolean locked) {
        this.locked = locked;
    }

    public long getId() {
        return id;
    }

    public Date getLockTime() {
        return lockTime;
    }

    @Override
    public String toString() {
        return "ModelMetadata [modelType=" + modelType + ", modelDescription="
            + modelDescription + ", modelRevision=" + modelRevision
            + ", importTime=" + importTime + ", lockTime=" + lockTime
            + ", locked=" + locked + "]";
    }

}
