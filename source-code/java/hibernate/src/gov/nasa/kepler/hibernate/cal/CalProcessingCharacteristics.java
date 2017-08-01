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

package gov.nasa.kepler.hibernate.cal;

import javax.persistence.*;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.hibernate.pi.PipelineTask;

/**
 * Information about how cal processed some chunk of data.
 * 
 * @author Sean McCauliff
 *
 */
@Entity
@Table(name = "CAL_PROCESSING_CHAR")
public class CalProcessingCharacteristics {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "calpc")
    @SequenceGenerator(name = "calpc", sequenceName = "CAL_PC_SEQ")
    private long id; // required by Hibernate

    @Column(nullable = false)
    private int startCadence;
    @Column(nullable = false)
    private int endCadence;
    
    @Column(nullable = false)
    private CadenceType cadenceType;
    
    @Column(nullable = false)
    private int ccdModule;
    @Column(nullable = false)
    private int ccdOutput;
    
    @ManyToOne(fetch=FetchType.LAZY)
    private PipelineTask originator;
    
    @Column(nullable = false)
    private BlackAlgorithm blackAlgorithm = BlackAlgorithm.UNDEFINED;
    
    CalProcessingCharacteristics() {
        
    }

    public CalProcessingCharacteristics(int startCadence, int endCadence,
        CadenceType cadenceType,
        PipelineTask originator, BlackAlgorithm blackAlgorithm,
        int ccdModule, int ccdOutput) {
        super();
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.cadenceType = cadenceType;
        this.originator = originator;
        this.blackAlgorithm = blackAlgorithm;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
    }

    public long getId() {
        return id;
    }

    public int getStartCadence() {
        return startCadence;
    }

    public void setStartCadence(int startCadence) {
        this.startCadence = startCadence;
    }

    public int getEndCadence() {
        return endCadence;
    }

    public void setEndCadence(int endCadence) {
        this.endCadence = endCadence;
    }

    public PipelineTask getPipelineTask() {
        return originator;
    }

    public void setPipelineTask(PipelineTask originator) {
        this.originator = originator;
    }

    public BlackAlgorithm getBlackAlgorithm() {
        return blackAlgorithm;
    }

    public void setBlackAlgorithm(BlackAlgorithm blackAlgorithm) {
        this.blackAlgorithm = blackAlgorithm;
    }

    public int getCcdModule() {
        return ccdModule;
    }

    public void setCcdModule(int ccdModule) {
        this.ccdModule = ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public void setCcdOutput(int ccdOutput) {
        this.ccdOutput = ccdOutput;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + ((blackAlgorithm == null) ? 0 : blackAlgorithm.hashCode());
        result = prime * result
            + ((cadenceType == null) ? 0 : cadenceType.hashCode());
        result = prime * result + ccdModule;
        result = prime * result + ccdOutput;
        result = prime * result + endCadence;
        result = prime * result
            + ((originator == null) ? 0 : originator.hashCode());
        result = prime * result + startCadence;
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        CalProcessingCharacteristics other = (CalProcessingCharacteristics) obj;
        if (blackAlgorithm != other.blackAlgorithm)
            return false;
        if (cadenceType != other.cadenceType)
            return false;
        if (ccdModule != other.ccdModule)
            return false;
        if (ccdOutput != other.ccdOutput)
            return false;
        if (endCadence != other.endCadence)
            return false;
        if (originator == null) {
            if (other.originator != null)
                return false;
        } else if (!originator.equals(other.originator))
            return false;
        if (startCadence != other.startCadence)
            return false;
        return true;
    }

}
