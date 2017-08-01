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

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * Holds the results of an aggregate query from {@link PipelineInstanceCrud.instanceState}
 * 
 * @author tklaus
 *
 */
public class PipelineInstanceAggregateState {

    private Long numTasks;
    private Long numSubmittedTasks;
    private Long numCompletedTasks;
    private Long numFailedTasks;
    
    public PipelineInstanceAggregateState(Long numTasks, Long numSubmittedTasks, Long numCompletedTasks,
        Long numFailedTasks) {
        this.numTasks = numTasks;
        this.numSubmittedTasks = numSubmittedTasks;
        this.numCompletedTasks = numCompletedTasks;
        this.numFailedTasks = numFailedTasks;
    }

    public Long getNumTasks() {
        return numTasks;
    }

    public void setNumTasks(Long numTasks) {
        this.numTasks = numTasks;
    }

    public Long getNumCompletedTasks() {
        return numCompletedTasks;
    }

    public void setNumCompletedTasks(Long numCompletedTasks) {
        this.numCompletedTasks = numCompletedTasks;
    }

    public Long getNumFailedTasks() {
        return numFailedTasks;
    }

    public void setNumFailedTasks(Long numFailedTasks) {
        this.numFailedTasks = numFailedTasks;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }

    public Long getNumSubmittedTasks() {
        return numSubmittedTasks;
    }

    public void setNumSubmittedTasks(Long numSubmittedTasks) {
        this.numSubmittedTasks = numSubmittedTasks;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + ((numCompletedTasks == null) ? 0 : numCompletedTasks.hashCode());
        result = prime * result
            + ((numFailedTasks == null) ? 0 : numFailedTasks.hashCode());
        result = prime * result
            + ((numSubmittedTasks == null) ? 0 : numSubmittedTasks.hashCode());
        result = prime * result
            + ((numTasks == null) ? 0 : numTasks.hashCode());
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
        final PipelineInstanceAggregateState other = (PipelineInstanceAggregateState) obj;
        if (numCompletedTasks == null) {
            if (other.numCompletedTasks != null)
                return false;
        } else if (!numCompletedTasks.equals(other.numCompletedTasks))
            return false;
        if (numFailedTasks == null) {
            if (other.numFailedTasks != null)
                return false;
        } else if (!numFailedTasks.equals(other.numFailedTasks))
            return false;
        if (numSubmittedTasks == null) {
            if (other.numSubmittedTasks != null)
                return false;
        } else if (!numSubmittedTasks.equals(other.numSubmittedTasks))
            return false;
        if (numTasks == null) {
            if (other.numTasks != null)
                return false;
        } else if (!numTasks.equals(other.numTasks))
            return false;
        return true;
    }
}
