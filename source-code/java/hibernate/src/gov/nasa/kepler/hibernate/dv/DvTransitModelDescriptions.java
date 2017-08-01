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

package gov.nasa.kepler.hibernate.dv;

import gov.nasa.kepler.hibernate.pi.PipelineTask;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.ManyToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;

@Entity
@Table(name = "DV_TRANSIT_MODEL_DESCS")
@XmlType
public class DvTransitModelDescriptions {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "DV_TRANSIT_MODEL_DESCS_SEQ")
    @Column(nullable = false)
    private long id;

    @XmlAttribute
    private String nameModelDescription = "";

    @XmlAttribute
    private String parameterModelDescription = "";

    @ManyToOne(fetch = FetchType.LAZY)
    @XmlAttribute(name = "pipelineTaskId", required = true)
    @XmlJavaTypeAdapter(PipelineTaskXmlAdapter.class)
    private PipelineTask pipelineTask;

    public DvTransitModelDescriptions() {
    }

    public DvTransitModelDescriptions(PipelineTask pipelineTask,
        String transitNameModelDescription,
        String transitParameterModelDescription) {
        this.pipelineTask = pipelineTask;
        this.nameModelDescription = transitNameModelDescription;
        this.parameterModelDescription = transitParameterModelDescription;
    }

    public long getId() {
        return id;
    }

    public String getNameModelDescription() {
        return nameModelDescription;
    }

    public String getParameterModelDescription() {
        return parameterModelDescription;
    }

    public PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime
            * result
            + ((nameModelDescription == null) ? 0
                : nameModelDescription.hashCode());
        result = prime
            * result
            + ((parameterModelDescription == null) ? 0
                : parameterModelDescription.hashCode());
        result = prime * result
            + ((pipelineTask == null) ? 0 : pipelineTask.hashCode());
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
        if (!(obj instanceof DvTransitModelDescriptions)) {
            return false;
        }
        DvTransitModelDescriptions other = (DvTransitModelDescriptions) obj;
        if (nameModelDescription == null) {
            if (other.nameModelDescription != null) {
                return false;
            }
        } else if (!nameModelDescription.equals(other.nameModelDescription)) {
            return false;
        }
        if (parameterModelDescription == null) {
            if (other.parameterModelDescription != null) {
                return false;
            }
        } else if (!parameterModelDescription.equals(other.parameterModelDescription)) {
            return false;
        }
        if (pipelineTask == null) {
            if (other.pipelineTask != null) {
                return false;
            }
        } else if (!pipelineTask.equals(other.pipelineTask)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "DvTransitModelDescriptions [nameModelDescription="
            + nameModelDescription + ", parameterModelDescription="
            + parameterModelDescription + ", pipelineTask=" + pipelineTask
            + "]";
    }
}
