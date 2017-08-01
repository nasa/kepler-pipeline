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

package gov.nasa.kepler.etem2;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.spiffy.common.persistable.Persistable;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
public class Etem2Inputs implements Persistable{

    private int ccdModule;
    private int ccdOutput;
    private int numCadences;
    private String cadenceType;
    private String startDate; 
    private String outputDir;
    private String targetListSetName;
    private String refPixTargetListSetName;
    private int refPixelCadenceInterval;
    private int refPixelCadenceOffset;
    private int requantExternalId;
    private PlannedSpacecraftConfigParameters plannedConfigMap;
    private String etemInputsFile = "ETEM_inputs_example";
    private double raOffset = 0.0;
    private double decOffset = 0.0;
    private double phiOffset = 0.0;
    private boolean enableAstrophysics;
    private String previousQuarterRunDir;
    private FcConstants fcConstants = new FcConstants();
    
    public Etem2Inputs() {
    }

    /**
     * @return the cadenceType
     */
    public String getCadenceType() {
        return cadenceType;
    }

    /**
     * @param cadenceType the cadenceType to set
     */
    public void setCadenceType(String cadenceType) {
        this.cadenceType = cadenceType;
    }

    /**
     * @return the ccdModule
     */
    public int getCcdModule() {
        return ccdModule;
    }

    /**
     * @param ccdModule the ccdModule to set
     */
    public void setCcdModule(int ccdModule) {
        this.ccdModule = ccdModule;
    }

    /**
     * @return the ccdOutput
     */
    public int getCcdOutput() {
        return ccdOutput;
    }

    /**
     * @param ccdOutput the ccdOutput to set
     */
    public void setCcdOutput(int ccdOutput) {
        this.ccdOutput = ccdOutput;
    }

    /**
     * @return the outputDir
     */
    public String getOutputDir() {
        return outputDir;
    }

    /**
     * @param outputDir the outputDir to set
     */
    public void setOutputDir(String outputDir) {
        this.outputDir = outputDir;
    }

    /**
     * @return the startDate
     */
    public String getStartDate() {
        return startDate;
    }

    /**
     * @param startDate the startDate to set
     */
    public void setStartDate(String startDate) {
        this.startDate = startDate;
    }

    /**
     * @return the targetListSetName
     */
    public String getTargetListSetName() {
        return targetListSetName;
    }

    /**
     * @param targetListSetName the targetListSetName to set
     */
    public void setTargetListSetName(String targetListSetName) {
        this.targetListSetName = targetListSetName;
    }

    public String getRefPixTargetListSetName() {
        return refPixTargetListSetName;
    }

    public void setRefPixTargetListSetName(String refPixTargetListSetName) {
        this.refPixTargetListSetName = refPixTargetListSetName;
    }

    /**
     * @return the numCadences
     */
    public int getNumCadences() {
        return numCadences;
    }

    /**
     * @param numCadences the numCadences to set
     */
    public void setNumCadences(int numCadences) {
        this.numCadences = numCadences;
    }

    /**
     * @return the requantExternalId
     */
    public int getRequantExternalId() {
        return requantExternalId;
    }

    /**
     * @param requantExternalId the requantExternalId to set
     */
    public void setRequantExternalId(int requantExternalId) {
        this.requantExternalId = requantExternalId;
    }

    /**
     * @return the etemInputsFile
     */
    public String getEtemInputsFile() {
        return etemInputsFile;
    }

    /**
     * @param etemInputsFile the etemInputsFile to set
     */
    public void setEtemInputsFile(String etemInputsFile) {
        this.etemInputsFile = etemInputsFile;
    }

    /**
     * @return the refPixelCadenceInterval
     */
    public int getRefPixelCadenceInterval() {
        return refPixelCadenceInterval;
    }

    /**
     * @param refPixelCadenceInterval the refPixelCadenceInterval to set
     */
    public void setRefPixelCadenceInterval(int refPixelCadenceInterval) {
        this.refPixelCadenceInterval = refPixelCadenceInterval;
    }

    /**
     * @return the refPixelCadenceOffset
     */
    public int getRefPixelCadenceOffset() {
        return refPixelCadenceOffset;
    }

    /**
     * @param refPixelCadenceOffset the refPixelCadenceOffset to set
     */
    public void setRefPixelCadenceOffset(int refPixelCadenceOffset) {
        this.refPixelCadenceOffset = refPixelCadenceOffset;
    }

    public double getRaOffset() {
        return raOffset;
    }

    public void setRaOffset(double raOffset) {
        this.raOffset = raOffset;
    }

    public double getDecOffset() {
        return decOffset;
    }

    public void setDecOffset(double decOffset) {
        this.decOffset = decOffset;
    }

    public double getPhiOffset() {
        return phiOffset;
    }

    public void setPhiOffset(double phiOffset) {
        this.phiOffset = phiOffset;
    }

    public boolean isEnableAstrophysics() {
        return enableAstrophysics;
    }

    public void setEnableAstrophysics(boolean enableAstrophysics) {
        this.enableAstrophysics = enableAstrophysics;
    }

    /**
     * @return the plannedConfigMap
     */
    public PlannedSpacecraftConfigParameters getPlannedConfigMap() {
        return plannedConfigMap;
    }

    /**
     * @param plannedConfigMap the plannedConfigMap to set
     */
    public void setPlannedConfigMap(PlannedSpacecraftConfigParameters configMap) {
        this.plannedConfigMap = configMap;
    }

    /**
     * @return the previousQuarterRunDir
     */
    public String getPreviousQuarterRunDir() {
        return previousQuarterRunDir;
    }

    /**
     * @param previousQuarterRunDir the previousQuarterRunDir to set
     */
    public void setPreviousQuarterRunDir(String previousQuarterRunDir) {
        this.previousQuarterRunDir = previousQuarterRunDir;
    }

    /**
     * @return the fcConstants
     */
    public FcConstants getFcConstants() {
        return fcConstants;
    }

    /**
     * @param fcConstants the fcConstants to set
     */
    public void setFcConstants(FcConstants fcConstants) {
        this.fcConstants = fcConstants;
    }
    
}
