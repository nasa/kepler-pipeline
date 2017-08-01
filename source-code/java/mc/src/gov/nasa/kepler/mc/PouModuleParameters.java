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

package gov.nasa.kepler.mc;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * Propagation of uncertainty parameters.
 * 
 * @author Forrest Girouard
 */
public class PouModuleParameters implements Parameters, Persistable {

    /**
     * True iff propagation of uncertainties is enabled.
     */
    private boolean pouEnabled;

    /**
     * True iff compression of uncertainties is enabled.
     */
    private boolean compressionEnabled;

    private int numErrorPropVars;
    private int maxSvdOrder;
    private int pixelChunkSize;
    private int cadenceChunkSize;
    private int maxBackgroundCadenceChunkSize;
    private int interpDecimation;
    private String interpMethod = "";

    public PouModuleParameters() {
    }

    public boolean isPouEnabled() {
        return pouEnabled;
    }

    public void setPouEnabled(boolean pouEnabled) {
        this.pouEnabled = pouEnabled;
    }

    public boolean isCompressionEnabled() {
        return compressionEnabled;
    }

    public void setCompressionEnabled(boolean compressionEnabled) {
        this.compressionEnabled = compressionEnabled;
    }

    public int getNumErrorPropVars() {
        return numErrorPropVars;
    }

    public void setNumErrorPropVars(int numErrorPropVars) {
        this.numErrorPropVars = numErrorPropVars;
    }

    public int getMaxSvdOrder() {
        return maxSvdOrder;
    }

    public void setMaxSvdOrder(int maxSvdOrder) {
        this.maxSvdOrder = maxSvdOrder;
    }

    public int getPixelChunkSize() {
        return pixelChunkSize;
    }

    public void setPixelChunkSize(int pixelChunkSize) {
        this.pixelChunkSize = pixelChunkSize;
    }

    public int getCadenceChunkSize() {
        return cadenceChunkSize;
    }

    public void setCadenceChunkSize(int cadenceChunkSize) {
        this.cadenceChunkSize = cadenceChunkSize;
    }

    public int getMaxBackgroundCadenceChunkSize() {
        return maxBackgroundCadenceChunkSize;
    }

    public void setMaxBackgroundCadenceChunkSize(int maxBackgroundCadenceChunkSize) {
        this.maxBackgroundCadenceChunkSize = maxBackgroundCadenceChunkSize;
    }

    public int getInterpDecimation() {
        return interpDecimation;
    }

    public void setInterpDecimation(int interpDecimation) {
        this.interpDecimation = interpDecimation;
    }

    public String getInterpMethod() {
        return interpMethod;
    }

    public void setInterpMethod(String interpMethod) {
        this.interpMethod = interpMethod;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + cadenceChunkSize;
        result = prime * result + (compressionEnabled ? 1231 : 1237);
        result = prime * result + interpDecimation;
        result = prime * result
            + (interpMethod == null ? 0 : interpMethod.hashCode());
        result = prime * result + maxBackgroundCadenceChunkSize;
        result = prime * result + maxSvdOrder;
        result = prime * result + numErrorPropVars;
        result = prime * result + pixelChunkSize;
        result = prime * result + (pouEnabled ? 1231 : 1237);
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
        PouModuleParameters other = (PouModuleParameters) obj;
        if (cadenceChunkSize != other.cadenceChunkSize) {
            return false;
        }
        if (compressionEnabled != other.compressionEnabled) {
            return false;
        }
        if (interpDecimation != other.interpDecimation) {
            return false;
        }
        if (interpMethod == null) {
            if (other.interpMethod != null) {
                return false;
            }
        } else if (!interpMethod.equals(other.interpMethod)) {
            return false;
        }
        if (maxBackgroundCadenceChunkSize != other.maxBackgroundCadenceChunkSize) {
            return false;
        }
        if (maxSvdOrder != other.maxSvdOrder) {
            return false;
        }
        if (numErrorPropVars != other.numErrorPropVars) {
            return false;
        }
        if (pixelChunkSize != other.pixelChunkSize) {
            return false;
        }
        if (pouEnabled != other.pouEnabled) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }
}
