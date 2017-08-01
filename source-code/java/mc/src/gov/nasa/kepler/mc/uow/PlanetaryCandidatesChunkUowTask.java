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

import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;

/**
 * This class is the {@link UnitOfWorkTask} for the DV {@link PipelineModule}.
 * 
 * @author Miles Cote
 * 
 */
public class PlanetaryCandidatesChunkUowTask extends KeplerIdChunkUowTask {

    private int skyGroupId;

    private int startKeplerId;
    private int endKeplerId;

    public PlanetaryCandidatesChunkUowTask() {
    }

    public PlanetaryCandidatesChunkUowTask(int skyGroupId, int startKeplerId,
        int endKeplerId) {
        this.skyGroupId = skyGroupId;
        this.startKeplerId = startKeplerId;
        this.endKeplerId = endKeplerId;
    }

    public PlanetaryCandidatesChunkUowTask makeCopy(PlanetaryCandidatesChunkUowTask self) {
        if (this != self) {
            throw new IllegalStateException("this != self");
        }
        return new PlanetaryCandidatesChunkUowTask(skyGroupId, startKeplerId, endKeplerId);
    }

    @Override
    public String briefState() {
        return "[skyGroupId=" + skyGroupId + "][keplerIdRange=" + startKeplerId
            + "," + endKeplerId + "]";
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
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        PlanetaryCandidatesChunkUowTask other = (PlanetaryCandidatesChunkUowTask) obj;
        if (endKeplerId != other.endKeplerId) {
            return false;
        }
        if (skyGroupId != other.skyGroupId) {
            return false;
        }
        if (startKeplerId != other.startKeplerId) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return briefState();
    }

    @Override
    public int getSkyGroupId() {
        return skyGroupId;
    }

    @Override
    public void setSkyGroupId(int skyGroupId) {
        this.skyGroupId = skyGroupId;
    }

    @Override
    public int getStartKeplerId() {
        return startKeplerId;
    }

    @Override
    public void setStartKeplerId(int startKeplerId) {
        this.startKeplerId = startKeplerId;
    }

    @Override
    public int getEndKeplerId() {
        return endKeplerId;
    }

    @Override
    public void setEndKeplerId(int endKeplerId) {
        this.endKeplerId = endKeplerId;
    }

    @SuppressWarnings("unchecked")
    @Override
    public <T extends SkyGroupBinnable> T makeCopy(T self) {
        return (T) makeCopy((PlanetaryCandidatesChunkUowTask) self);
    }

    @SuppressWarnings("unchecked")
    @Override
    public <T extends KeplerIdChunkBinnable> T makeCopy(T self) {
        return (T) makeCopy((PlanetaryCandidatesChunkUowTask) self);
    }

}
