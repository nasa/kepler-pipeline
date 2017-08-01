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

package gov.nasa.kepler.cal.io;

import gov.nasa.spiffy.common.persistable.Persistable;

/**
 * Some stuff cal matlab can pass back to us so we can
 * read in the output files in a separate pipeline session.
 * This duplicates some of the information available in the 
 * CalInputs structure for ease of implementation of the
 * matlab side.
 * 
 * @author Sean McCauliff
 *
 */
public class EmbeddedPipelineInfo implements Persistable{

    private int ccdModule;
    private int ccdOutput;
    private int startCadence;
    private int endCadence;
    private long pipelineTaskId;
    private int targetTableId;
    private int lcTargetTableId;
    private int bkgTargetTableId;
    private String cadenceTypeStr;
    private String ffiFileName;
    private double ffiMidTimeMjd;
    
    public EmbeddedPipelineInfo(int ccdModule, int ccdOutput, int startCadence,
        int endCadence, long pipelineTaskId,
        int targetTableId, int lcTargetTableId, int bkgTargetTableId,
        String cadenceTypeStr) {

        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.pipelineTaskId = pipelineTaskId;
        this.lcTargetTableId = lcTargetTableId;
        this.bkgTargetTableId = bkgTargetTableId;
        this.targetTableId = targetTableId;
        this.cadenceTypeStr = cadenceTypeStr;
        this.ffiFileName = "";
    }
    
    public EmbeddedPipelineInfo(int ccdModule, int ccdOutput, long pipelineTaskId,
        String ffiFileName, double ffiMidTimeMjd) {
        this.cadenceTypeStr = "FFI";
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.pipelineTaskId = pipelineTaskId;
        this.ffiFileName = ffiFileName;
        this.ffiMidTimeMjd = ffiMidTimeMjd;
    }
    
    
    /**
     * Required by Persistable
     */
    public EmbeddedPipelineInfo() {
        
    }

    public int ccdModule() {
        return ccdModule;
    }

    public int ccdOutput() {
        return ccdOutput;
    }

    public int startCadence() {
        return startCadence;
    }

    public int endCadence() {
        return endCadence;
    }

    public long pipelineTaskId() {
        return pipelineTaskId;
    }

    public int targetTableId() {
        return targetTableId;
    }

    public String cadenceTypeStr() {
        return cadenceTypeStr;
    }

    public String ffiFileName() {
        return ffiFileName;
    }
    
    public double ffiMidTimeMjd() {
        return ffiMidTimeMjd;
    }
    
    public int lcTargetTableId() {
        return lcTargetTableId;
    }
    
    public int bkgTargetTableId() {
        return bkgTargetTableId;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + bkgTargetTableId;
        result = prime * result
            + ((cadenceTypeStr == null) ? 0 : cadenceTypeStr.hashCode());
        result = prime * result + ccdModule;
        result = prime * result + ccdOutput;
        result = prime * result + endCadence;
        result = prime * result
            + ((ffiFileName == null) ? 0 : ffiFileName.hashCode());
        long temp;
        temp = Double.doubleToLongBits(ffiMidTimeMjd);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        result = prime * result + lcTargetTableId;
        result = prime * result
            + (int) (pipelineTaskId ^ (pipelineTaskId >>> 32));
        result = prime * result + startCadence;
        result = prime * result + targetTableId;
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
        EmbeddedPipelineInfo other = (EmbeddedPipelineInfo) obj;
        if (bkgTargetTableId != other.bkgTargetTableId)
            return false;
        if (cadenceTypeStr == null) {
            if (other.cadenceTypeStr != null)
                return false;
        } else if (!cadenceTypeStr.equals(other.cadenceTypeStr))
            return false;
        if (ccdModule != other.ccdModule)
            return false;
        if (ccdOutput != other.ccdOutput)
            return false;
        if (endCadence != other.endCadence)
            return false;
        if (ffiFileName == null) {
            if (other.ffiFileName != null)
                return false;
        } else if (!ffiFileName.equals(other.ffiFileName))
            return false;
        if (Double.doubleToLongBits(ffiMidTimeMjd) != Double.doubleToLongBits(other.ffiMidTimeMjd))
            return false;
        if (lcTargetTableId != other.lcTargetTableId)
            return false;
        if (pipelineTaskId != other.pipelineTaskId)
            return false;
        if (startCadence != other.startCadence)
            return false;
        if (targetTableId != other.targetTableId)
            return false;
        return true;
    }
    
    
}
