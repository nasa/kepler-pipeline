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

package gov.nasa.kepler.tad.peer;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * Used to pass data to and from MATLAB.
 * 
 * @author Miles Cote
 */
public class AmtModuleParameters implements Persistable, Parameters {

    private int maxMasks;
    private int maxPixelsInMask;
    private int maxMaskRows;
    private int maxMaskCols;
    private int centerRow;
    private int centerCol;
    private float minEccentricity;
    private float maxEccentricity;
    private float stepEccentricity;
    private float stepInclination;
    private int useOptimalApertureInputs;
    private int maxPixelsInSmallMask;
    private String maskTableCopySourceTargetListSetName = "";
    private String maskTableImportSourceFileName = "";

    public AmtModuleParameters() {
    }

    public int getCenterCol() {
        return centerCol;
    }

    public void setCenterCol(int centerCol) {
        this.centerCol = centerCol;
    }

    public int getCenterRow() {
        return centerRow;
    }

    public void setCenterRow(int centerRow) {
        this.centerRow = centerRow;
    }

    public float getMaxEccentricity() {
        return maxEccentricity;
    }

    public void setMaxEccentricity(float maxEccentricity) {
        this.maxEccentricity = maxEccentricity;
    }

    public int getMaxMaskCols() {
        return maxMaskCols;
    }

    public void setMaxMaskCols(int maxMaskCols) {
        this.maxMaskCols = maxMaskCols;
    }

    public int getMaxMaskRows() {
        return maxMaskRows;
    }

    public void setMaxMaskRows(int maxMaskRows) {
        this.maxMaskRows = maxMaskRows;
    }

    public int getMaxMasks() {
        return maxMasks;
    }

    public void setMaxMasks(int maxMasks) {
        this.maxMasks = maxMasks;
    }

    public int getMaxPixelsInMask() {
        return maxPixelsInMask;
    }

    public void setMaxPixelsInMask(int maxPixelsInMask) {
        this.maxPixelsInMask = maxPixelsInMask;
    }

    public float getMinEccentricity() {
        return minEccentricity;
    }

    public void setMinEccentricity(float minEccentricity) {
        this.minEccentricity = minEccentricity;
    }

    public float getStepEccentricity() {
        return stepEccentricity;
    }

    public void setStepEccentricity(float stepEccentricity) {
        this.stepEccentricity = stepEccentricity;
    }

    public float getStepInclination() {
        return stepInclination;
    }

    public void setStepInclination(float stepInclination) {
        this.stepInclination = stepInclination;
    }

    public int getUseOptimalApertureInputs() {
        return useOptimalApertureInputs;
    }

    public void setUseOptimalApertureInputs(int useOptimalApertureInputs) {
        this.useOptimalApertureInputs = useOptimalApertureInputs;
    }

    public String getMaskTableCopySourceTargetListSetName() {
        return maskTableCopySourceTargetListSetName;
    }

    public void setMaskTableCopySourceTargetListSetName(
        String maskTableCopySourceTargetListSetName) {
        this.maskTableCopySourceTargetListSetName = maskTableCopySourceTargetListSetName;
    }

    public String getMaskTableImportSourceFileName() {
        return maskTableImportSourceFileName;
    }

    public void setMaskTableImportSourceFileName(
        String maskTableImportSourceFileName) {
        this.maskTableImportSourceFileName = maskTableImportSourceFileName;
    }

    public int getMaxPixelsInSmallMask() {
        return maxPixelsInSmallMask;
    }

    public void setMaxPixelsInSmallMask(int maxPixelsInSmallMask) {
        this.maxPixelsInSmallMask = maxPixelsInSmallMask;
    }

}
