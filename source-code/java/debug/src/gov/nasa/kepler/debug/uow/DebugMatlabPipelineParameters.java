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

package gov.nasa.kepler.debug.uow;

import org.apache.commons.lang.ArrayUtils;

import gov.nasa.spiffy.common.pi.Parameters;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
public class DebugMatlabPipelineParameters implements Parameters{

    private boolean callMatlab;
    private int numMatlabInvocations;
    private boolean useOldRaDec2Pix;
    
    private int sleepTimeJavaSecs;
    
    /** Generated task list will be capped at this size.  Zero means no cap */
    private int maxTaskCount;
    
    private int startCadence;
    private int endCadence;
    private int cadenceBinSize; // no cadence binning by default

    private boolean binByModuleOutput;
    private int[] channelIncludeArray = ArrayUtils.EMPTY_INT_ARRAY;
    private int[] channelExcludeArray = ArrayUtils.EMPTY_INT_ARRAY;

    /** These are just here as examples of the various types to exercise the
     * property editor in the PIG.  They don't affect the behavior of the 
     * debug module
     */
    private String observingSeason;
    private int targetTableId;
    private Integer[] intArray = ArrayUtils.EMPTY_INTEGER_OBJECT_ARRAY;

    public DebugMatlabPipelineParameters() {
    }

    /**
     * @return the callMatlab
     */
    public boolean isCallMatlab() {
        return callMatlab;
    }

    /**
     * @param callMatlab the callMatlab to set
     */
    public void setCallMatlab(boolean callMatlab) {
        this.callMatlab = callMatlab;
    }

    /**
     * @return the intArray
     */
    public Integer[] getIntArray() {
        return intArray;
    }

    /**
     * @param intArray the intArray to set
     */
    public void setIntArray(Integer[] intArray) {
        this.intArray = intArray;
    }

    /**
     * @return the observingSeason
     */
    public String getObservingSeason() {
        return observingSeason;
    }

    /**
     * @param observingSeason the observingSeason to set
     */
    public void setObservingSeason(String observingSeason) {
        this.observingSeason = observingSeason;
    }

    /**
     * @return the sleepTimeJavaSecs
     */
    public int getSleepTimeJavaSecs() {
        return sleepTimeJavaSecs;
    }

    /**
     * @param sleepTimeJavaSecs the sleepTimeJavaSecs to set
     */
    public void setSleepTimeJavaSecs(int sleepTimeJavaSecs) {
        this.sleepTimeJavaSecs = sleepTimeJavaSecs;
    }

    /**
     * @return the targetTableId
     */
    public int getTargetTableId() {
        return targetTableId;
    }

    /**
     * @param targetTableId the targetTableId to set
     */
    public void setTargetTableId(int targetTableId) {
        this.targetTableId = targetTableId;
    }

    /**
     * used by the PIG to display the name of the pipeline parameters type
     */
    public String toString() {
        return "Debug";
    }

    /**
     * @return the useOldRaDec2Pix
     */
    public boolean isUseOldRaDec2Pix() {
        return useOldRaDec2Pix;
    }

    /**
     * @param useOldRaDec2Pix the useOldRaDec2Pix to set
     */
    public void setUseOldRaDec2Pix(boolean useOldRaDec2Pix) {
        this.useOldRaDec2Pix = useOldRaDec2Pix;
    }

    public int getCadenceBinSize() {
        return cadenceBinSize;
    }

    public void setCadenceBinSize(int cadenceBinSize) {
        this.cadenceBinSize = cadenceBinSize;
    }

    public int[] getChannelExcludeArray() {
        return channelExcludeArray;
    }

    public void setChannelExcludeArray(int[] channelExcludeArray) {
        this.channelExcludeArray = channelExcludeArray;
    }

    public int[] getChannelIncludeArray() {
        return channelIncludeArray;
    }

    public void setChannelIncludeArray(int[] channelIncludeArray) {
        this.channelIncludeArray = channelIncludeArray;
    }

    public int getEndCadence() {
        return endCadence;
    }

    public void setEndCadence(int endCadence) {
        this.endCadence = endCadence;
    }

    public int getStartCadence() {
        return startCadence;
    }

    public void setStartCadence(int startCadence) {
        this.startCadence = startCadence;
    }

    public boolean isBinByModuleOutput() {
        return binByModuleOutput;
    }

    public void setBinByModuleOutput(boolean binByModuleOutput) {
        this.binByModuleOutput = binByModuleOutput;
    }

    public int getMaxTaskCount() {
        return maxTaskCount;
    }

    public void setMaxTaskCount(int maxTaskCount) {
        this.maxTaskCount = maxTaskCount;
    }

    /**
     * @return the numMatlabInvocations
     */
    public int getNumMatlabInvocations() {
        return numMatlabInvocations;
    }

    /**
     * @param numMatlabInvocations the numMatlabInvocations to set
     */
    public void setNumMatlabInvocations(int numMatlabInvocations) {
        this.numMatlabInvocations = numMatlabInvocations;
    }
}
