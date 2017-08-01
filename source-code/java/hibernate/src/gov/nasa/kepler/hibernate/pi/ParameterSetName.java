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

import gov.nasa.spiffy.common.pi.Parameters;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * {@link TriggerDefinition} and {@link TriggerDefinitionNode} use 
 * {@link ParameterSetName} to refer to the {@link ParameterSet}s that are used by 
 * those definitions ({@link Parameters} or {@link Parameters}).
 * 
 * This is a 'soft reference' because there may be several instances of the 
 * {@link ParameterSet} with the name in the {@link ParameterSetName} 
 * (one for each version).  An association to a specific version (usually latest version)
 * is only made when a pipeline instance is launched (the {@link PipelineInstance} and 
 * {@link PipelineInstanceNode} contain hard references to the {@link ParameterSet}s).
 * 
 * This class is used instead of just using {@link String} in order to support
 * referential integrity in the database (both the {@link TriggerDefinition} 
 * and the {@link ParameterSet} refer to the same {@link ParameterSetName} row)
 * 
 * Note that in order to support rename capability, foreign key references to this entity 
 * need to be updated in ParameterSetCrud.rename().
 *  
 * @author tklaus
 *
 */
@Entity
@Table(name = "PI_PS_NAME")
public class ParameterSetName {

    public static String DELIMITER = ":";
    
    @Id
    private String name;
    
    /**
     * For Hibernate use only
     */
    ParameterSetName() {
    }

    /**
     * Constructors are package-level access because they should only be created by
     * {@link ParameterSet}
     * 
     * @param name
     */
    ParameterSetName(String name) {
        if(name.contains(DELIMITER)){
            throw new IllegalArgumentException("name must not contain '" + DELIMITER + "'");
        }
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        if(name.contains(DELIMITER)){
            throw new IllegalArgumentException("name must not contain '" + DELIMITER + "'");
        }
        this.name = name;
    }

    @Override
    public String toString() {
        return name;
    }
}
