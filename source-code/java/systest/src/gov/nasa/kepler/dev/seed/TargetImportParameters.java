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

package gov.nasa.kepler.dev.seed;

import gov.nasa.kepler.mc.DataRepoParameters;
import gov.nasa.kepler.pa.MotionModuleParameters;
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * Relative paths to the target-related notification messages. All paths are
 * relative to the data-repo root (defined in {@link DataRepoParameters}).
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 */
public class TargetImportParameters implements Parameters {

    private String tlnmPath;
    private String tlsnmPath;
    private String mtnmPath;
    private String charTablePath;
    private int maxTargetsPerTargetList;
    private String pseudoTargetListPath;

    /**
     * The fraction of maxTargetsPerTargetList required for
     * {@link MotionModuleParameters}.fitMinPoints.
     */
    private float fitMinPointsFraction = 0.5F;

    /**
     * These will always be included (if they are in the target list),
     * regardless of the maxTargetsPerTargetList value.
     */
    private int[] forceIncludedKeplerIdArray = new int[0];

    /**
     * These will always be excluded regardless of the maxTargetsPerTargetList
     * value.
     */
    private int[] forceExcludedKeplerIdArray = new int[0];

    public TargetImportParameters() {
    }

    /**
     * @return the tlnmPath
     */
    public String getTlnmPath() {
        return tlnmPath;
    }

    /**
     * @param tlnmPath the tlnmPath to set
     */
    public void setTlnmPath(String tlnmPath) {
        this.tlnmPath = tlnmPath;
    }

    /**
     * @return the maxTargetsPerTargetList
     */
    public int getMaxTargetsPerTargetList() {
        return maxTargetsPerTargetList;
    }

    /**
     * @param maxTargetsPerTargetList the maxTargetsPerTargetList to set
     */
    public void setMaxTargetsPerTargetList(int maxTargetsPerTargetList) {
        this.maxTargetsPerTargetList = maxTargetsPerTargetList;
    }

    /**
     * @return the mtnmPath
     */
    public String getMtnmPath() {
        return mtnmPath;
    }

    /**
     * @param mtnmPath the mtnmPath to set
     */
    public void setMtnmPath(String mtnmPath) {
        this.mtnmPath = mtnmPath;
    }

    /**
     * @return the tlsnmPath
     */
    public String getTlsnmPath() {
        return tlsnmPath;
    }

    /**
     * @param tlsnmPath the tlsnmPath to set
     */
    public void setTlsnmPath(String tlsnmPath) {
        this.tlsnmPath = tlsnmPath;
    }

    public int[] getForceIncludedKeplerIdArray() {
        return forceIncludedKeplerIdArray;
    }

    public void setForceIncludedKeplerIdArray(int[] includeKeplerIdArray) {
        forceIncludedKeplerIdArray = includeKeplerIdArray;
    }

    public int[] getForceExcludedKeplerIdArray() {
        return forceExcludedKeplerIdArray;
    }

    public void setForceExcludedKeplerIdArray(int[] excludeKeplerIdArray) {
        forceExcludedKeplerIdArray = excludeKeplerIdArray;
    }

    public float getFitMinPointsFraction() {
        return fitMinPointsFraction;
    }

    public void setFitMinPointsFraction(float fitMinPointsFraction) {
        this.fitMinPointsFraction = fitMinPointsFraction;
    }

    public String getCharTablePath() {
        return charTablePath;
    }

    public void setCharTablePath(String charTablePath) {
        this.charTablePath = charTablePath;
    }

    public String getPseudoTargetListPath() {
        return pseudoTargetListPath;
    }

    public void setPseudoTargetListPath(String pseudoTargetListPath) {
        this.pseudoTargetListPath = pseudoTargetListPath;
    }

}
