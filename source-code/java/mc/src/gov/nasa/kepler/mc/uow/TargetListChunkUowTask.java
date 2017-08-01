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

package gov.nasa.kepler.mc.uow;

import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;


/**
 * This describes an interval of Kepler Ids that are to be worked on in a list
 * of Kepler Ids in the specified target list which sorted in ascending order.
 * @author Sean McCauliff
 *
 */
public class TargetListChunkUowTask extends KeplerIdChunkUowTask {

    /** The sky group of all the Kepler Ids in this task. */
    private int skyGroupId;
    
    /** Inclusive. */
    private int startKeplerId;
    /** Inclusive. */
    private int endKeplerId;
    
    @Override
    public String briefState() {
        StringBuilder bldr = new StringBuilder();
        bldr.append("[").append(startKeplerId).append(',')
            .append(endKeplerId).append("]sg").append(skyGroupId);
        
        return bldr.toString();
    }
    
    public TargetListChunkUowTask() {
    }

    /**
     * 
     * @param startKeplerId inclusive
     * @param endKeplerId inclusive
     */
    
    public TargetListChunkUowTask(int skyGroupId, int startKeplerId, int endKeplerId) {

        this.skyGroupId = skyGroupId;
        this.startKeplerId = startKeplerId;
        this.endKeplerId = endKeplerId;
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
     * Inclusive.
     */
    public int getEndKeplerId() {
        return endKeplerId;
    }

    public void setEndKeplerId(int endKeplerId) {
        this.endKeplerId = endKeplerId;
    }

    @Override
    public int getSkyGroupId() {
        return skyGroupId;
    }

    private TargetListChunkUowTask makeCopy(TargetListChunkUowTask self) {
        if (self != this) {
            throw new IllegalStateException("self != this");
        }
        return new 
        TargetListChunkUowTask(skyGroupId, startKeplerId, endKeplerId);
    }
    @SuppressWarnings("unchecked")
    @Override
    public <T extends SkyGroupBinnable> T makeCopy(T self) {
        return (T) makeCopy((TargetListChunkUowTask) self);
    }

    @Override
    public void setSkyGroupId(int skyGroupId) {
        this.skyGroupId = skyGroupId;
    }

    @SuppressWarnings("unchecked")
    @Override
    public <T extends KeplerIdChunkBinnable> T makeCopy(T self) {
        return (T) makeCopy((TargetListChunkUowTask) self);
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + endKeplerId;
        result = prime * result + skyGroupId;
        result = prime * result + startKeplerId;
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
        TargetListChunkUowTask other = (TargetListChunkUowTask) obj;
        if (endKeplerId != other.endKeplerId)
            return false;
        if (skyGroupId != other.skyGroupId)
            return false;
        if (startKeplerId != other.startKeplerId)
            return false;
        return true;
    }
    
    
}
