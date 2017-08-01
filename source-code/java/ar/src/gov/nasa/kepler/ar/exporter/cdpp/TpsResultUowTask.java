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

package gov.nasa.kepler.ar.exporter.cdpp;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;

/**
 * The unit of work for the CDPP exporter pipeline module.
 * 
 * @author Sean McCauliff
 *
 */
public class TpsResultUowTask extends UnitOfWorkTask {

    private int startKeplerId;
    private int endKeplerId;
    private long pipelineInstanceId;
    
    public TpsResultUowTask() {
        
    }
    
    @Override
    public String briefState() {
        StringBuilder bldr = new StringBuilder();
        bldr.append("keplerIds=[").append(startKeplerId).append(',')
            .append(endKeplerId).append(']');
        return bldr.toString();
    }
    

    public TpsResultUowTask(int startKeplerId, int endKeplerId,
        long pipelineInstanceId) {
        if (startKeplerId > endKeplerId) {
            throw new IllegalArgumentException("endKeplerId comes before startKeplerId");
        }
        if (pipelineInstanceId < 0) {
            throw new IllegalArgumentException("pipelineInstanceId must be greater than 0");
        }
        this.startKeplerId = startKeplerId;
        this.endKeplerId = endKeplerId;
        this.pipelineInstanceId = pipelineInstanceId;
    }
    
    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }

  

    public int getStartKeplerId() {
        return startKeplerId;
    }

    public void setStartKeplerId(int startKeplerId) {
        this.startKeplerId = startKeplerId;
    }

    /**
     * Inclusive
     */
    public int getEndKeplerId() {
        return endKeplerId;
    }

    public void setEndKeplerId(int endKeplerId) {
        this.endKeplerId = endKeplerId;
    }

    public long getPipelineInstanceId() {
        return pipelineInstanceId;
    }

    public void setPipelineInstanceId(long pipelineInstanceId) {
        this.pipelineInstanceId = pipelineInstanceId;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + endKeplerId;
        result = prime * result + (int) (pipelineInstanceId ^ (pipelineInstanceId >>> 32));
        result = prime * result + startKeplerId;
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null) return false;
        if (getClass() != obj.getClass()) return false;
        TpsResultUowTask other = (TpsResultUowTask) obj;
        if (endKeplerId != other.endKeplerId) return false;
        if (pipelineInstanceId != other.pipelineInstanceId) return false;
        if (startKeplerId != other.startKeplerId) return false;
        return true;
    }
    
    
    
}
