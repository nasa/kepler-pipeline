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

import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;

/**
 * Maintains a list of {@link ModelMetadata} objects for
 * data accountability purposes.
 * {@link PipelineInstance} contains a reference to 
 * the specific version of the model registry that was 
 * in force at the time the instance was launched.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
@Entity
@Table(name = "PI_MODEL_REGISTRY")
public class ModelRegistry {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "PI_MODREG_SEQ")
    private long id;

    @ManyToMany(fetch=FetchType.EAGER)
    @JoinTable(name = "PI_MODREG_MODEL")
    @Cascade({CascadeType.SAVE_UPDATE})
    private Map<ModelType,ModelMetadata> models = new HashMap<ModelType,ModelMetadata>();

    private int version = 0;
    private boolean locked = false;
    private Date lockTime;
    
    public ModelRegistry() {
    }

    /**
     * Copy constructor
     */
    public ModelRegistry(ModelRegistry other) {
        this.models = new HashMap<ModelType,ModelMetadata>(other.models);
        
        this.version = 0;
        this.locked = false;
    }
    
    public ModelRegistry newVersion() throws PipelineException{
        if(!locked){
            throw new PipelineException("Can't version an unlocked instance");
        }
        
        ModelRegistry copy = new ModelRegistry(this);
        copy.version = this.version + 1;
        
        return copy;
    }
    
    public void lock() {
        locked = true;
        lockTime = new Date();
    }

    public Date getLockTime() {
        return lockTime;
    }    
    
    public int getVersion() {
        return version;
    }

    public boolean isLocked() {
        return locked;
    }
    
    public long getId() {
        return id;
    }

    public Map<ModelType, ModelMetadata> getModels() {
        return models;
    }
   
    /**
     * Convenience method to return {@link ModelMetadata} for
     * the specified model type.
     * 
     * @param modelType
     * @return
     */
    public ModelMetadata getMetadataForType(String modelType){
        return models.get(new ModelType(modelType));
    }
    
    // for test use ONLY
    void setVersion(int version){
        this.version = version;
    }
}
