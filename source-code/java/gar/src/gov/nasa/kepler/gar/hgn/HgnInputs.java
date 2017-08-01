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

package gov.nasa.kepler.gar.hgn;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.gar.CadencePixelValues;
import gov.nasa.kepler.mc.gar.RequantTable;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.List;

import org.apache.commons.lang.builder.ToStringBuilder;

public class HgnInputs implements Persistable {

    /**
     * Parameters set in the GUI.
     */
    private HgnModuleParameters hgnModuleParameters;

    /**
     * Focal plane characterization constants.
     */
    private FcConstants fcConstants = new FcConstants();

    /**
     * The CCD module. Only used to debug the bin file.
     */
    private int ccdModule;

    /**
     * The CCD output. Only used to debug the bin file.
     */
    private int ccdOutput;

    /**
     * The start cadence of this MATLAB invocation. Only used to debug the bin
     * file.
     */
    private int invocationCadenceStart;

    /**
     * The end cadence of this MATLAB invocation. Only used to debug the bin
     * file.
     */
    private int invocationCadenceEnd;

    /**
     * Marker for the first MATLAB invocation. Each subsequent MATLAB invocation
     * reads the previous state from a file. MATLAB is called
     * {@code ceil(startCadence - endCadence) / maxMatlabCadences)} times.
     */
    private boolean firstMatlabInvocation;

    /**
     * The requantization table.
     */
    private RequantTable requantTable;

    /**
     * List of {@link CadencePixelValues} objects. Each element contains the
     * cadence number and all of the raw pixel values for that cadence. Note
     * that raw pixel values are ints.
     */
    private List<CadencePixelValues> cadencePixels;

    private int debugFlag;

    public HgnModuleParameters getHgnModuleParameters() {
        return hgnModuleParameters;
    }

    public void setHgnModuleParameters(HgnModuleParameters hgnModuleParameters) {
        this.hgnModuleParameters = hgnModuleParameters;
    }

    public FcConstants getFcConstants() {
        return fcConstants;
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

    public int getInvocationCadenceStart() {
        return invocationCadenceStart;
    }

    public void setInvocationCadenceStart(int invocationCadenceStart) {
        this.invocationCadenceStart = invocationCadenceStart;
    }

    public int getInvocationCadenceEnd() {
        return invocationCadenceEnd;
    }

    public void setInvocationCadenceEnd(int invocationCadenceEnd) {
        this.invocationCadenceEnd = invocationCadenceEnd;
    }

    public boolean isFirstMatlabInvocation() {
        return firstMatlabInvocation;
    }

    public void setFirstMatlabInvocation(boolean firstMatlabInvocation) {
        this.firstMatlabInvocation = firstMatlabInvocation;
    }

    public RequantTable getRequantTable() {
        return requantTable;
    }

    public void setRequantTable(RequantTable requantTable) {
        this.requantTable = requantTable;
    }

    public List<CadencePixelValues> getCadencePixels() {
        return cadencePixels;
    }

    public void setCadencePixels(List<CadencePixelValues> cadencePixels) {
        this.cadencePixels = cadencePixels;
    }

    public int getDebugFlag() {
        return debugFlag;
    }

    public void setDebugFlag(int debugFlag) {
        this.debugFlag = debugFlag;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("ccdModule", ccdModule)
            .append("ccdOutput", ccdOutput)
            .append("startCadence", invocationCadenceStart)
            .append("endCadence", invocationCadenceEnd)
            .append("firstMatlabInvocation", firstMatlabInvocation)
            .append("requantTable", requantTable.toString())
            .append("cadencePixels count", cadencePixels.size())
            .toString();
    }
}
