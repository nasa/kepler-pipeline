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


/**
 * The start and end points for a set of keplerIds which have been targets at
 * some point during the mission.
 * 
 * @author Sean McCauliff
 * 
 */
public class ObservedKeplerIdUowTask extends KeplerIdChunkUowTask {

    private int startKeplerId;
    private int endKeplerId;
    private long targetTableDbId;
    private int ccdModule;
    private int ccdOutput;
    private int skyGroupId;

    
    public ObservedKeplerIdUowTask() {

    }

    /**
     * @param startKeplerId
     * @param endKeplerId
     * @param targetTableDbId
     */
    public ObservedKeplerIdUowTask(int startKeplerId, int endKeplerId,
        long targetTableDbId, int ccdModule, int ccdOutput, int skyGroupId) {

        this.startKeplerId = startKeplerId;
        this.endKeplerId = endKeplerId;
        this.targetTableDbId = targetTableDbId;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.skyGroupId = skyGroupId;
    }
    
    @Override
    public String briefState() {
        StringBuilder bldr = new StringBuilder();
        bldr.append(targetTableDbId).append('+').append('[').append(startKeplerId)
        .append(',').append(endKeplerId).append("](").append(ccdModule)
        .append(ccdOutput).append(')');
        return bldr.toString();
    }

    public int getStartKeplerId() {
        return startKeplerId;
    }

    public void setStartKeplerId(int startKeplerId) {
        this.startKeplerId = startKeplerId;
    }

    public int getEndKeplerId() {
        return endKeplerId;
    }

    public void setEndKeplerId(int endKeplerId) {
        this.endKeplerId = endKeplerId;
    }

    public long getTargetTableDbId() {
        return targetTableDbId;
    }

    public void setTargetTableDbId(long targetTableDbId) {
        this.targetTableDbId = targetTableDbId;
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
    public int getSkyGroupId() {
        return skyGroupId;
    }

    @Override
    public <T extends SkyGroupBinnable> T makeCopy(T selfUntyped) {
        if (selfUntyped != this) {
            throw new IllegalArgumentException("self != this");
        }
        
        ObservedKeplerIdUowTask self = (ObservedKeplerIdUowTask) selfUntyped;
        @SuppressWarnings("unchecked")
        T rv = (T)new ObservedKeplerIdUowTask(self.startKeplerId, 
            self.endKeplerId, self.targetTableDbId, self.ccdModule, self.ccdOutput, self.skyGroupId);
        return rv;
    }

    @Override
    public void setSkyGroupId(int skyGroupId) {
        this.skyGroupId = skyGroupId;
    }

    @Override
    public <T extends KeplerIdChunkBinnable> T makeCopy(T selfUntyped) {
        if (selfUntyped != this) {
            throw new IllegalArgumentException("self != this");
        }
        
        ObservedKeplerIdUowTask self = (ObservedKeplerIdUowTask) selfUntyped;
        @SuppressWarnings("unchecked")
        T rv = (T)new ObservedKeplerIdUowTask(self.startKeplerId, 
            self.endKeplerId, self.targetTableDbId, self.ccdModule, self.ccdOutput, self.skyGroupId);
        return rv;
    }

    @Override
    public String toString() {
        StringBuilder builder = new StringBuilder();
        builder.append("ObservedKeplerIdUowTask [ccdModule=")
            .append(ccdModule)
            .append(", ccdOutput=")
            .append(ccdOutput)
            .append(", endKeplerId=")
            .append(endKeplerId)
            .append(", skyGroupId=")
            .append(skyGroupId)
            .append(", startKeplerId=")
            .append(startKeplerId)
            .append(", targetTableDbId=")
            .append(targetTableDbId)
            .append("]");
        return builder.toString();
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ccdModule;
        result = prime * result + ccdOutput;
        result = prime * result + endKeplerId;
        result = prime * result + skyGroupId;
        result = prime * result + startKeplerId;
        result = prime * result
            + (int) (targetTableDbId ^ (targetTableDbId >>> 32));
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (!(obj instanceof ObservedKeplerIdUowTask))
            return false;
        ObservedKeplerIdUowTask other = (ObservedKeplerIdUowTask) obj;
        if (ccdModule != other.ccdModule)
            return false;
        if (ccdOutput != other.ccdOutput)
            return false;
        if (endKeplerId != other.endKeplerId)
            return false;
        if (skyGroupId != other.skyGroupId)
            return false;
        if (startKeplerId != other.startKeplerId)
            return false;
        if (targetTableDbId != other.targetTableDbId)
            return false;
        return true;
    }
    
    


}
