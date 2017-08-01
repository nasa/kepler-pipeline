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

package gov.nasa.kepler.debug;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

/**
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
public class DebugInputs implements Persistable {

    private DebugModuleParams moduleParameters;
    private FcConstants fcConstants = new FcConstants();
    private RaDec2PixModel raDec2PixModel;
    
    private String testString = "foobar";
    private String[] testStringArray = {"foo","bar"};
    private String[][] testStringArray2 = {{"one","two","three"},{"a","b"},{},{"1"}};
    
    // inputs to RaDec2Pix
    private boolean useOldRaDec2Pix = false;
    private double ra;
    private double dec;
    private double julianDate;
    
    private List<DebugElement> inputElements = new ArrayList<DebugElement>();
    
	public DebugInputs() {
        inputElements.add(new DebugElement());
        inputElements.add(new DebugElement());
        inputElements.add(new DebugElement());
	}

    /**
     * @return the dec
     */
    public double getDec() {
        return dec;
    }

    /**
     * @param dec the dec to set
     */
    public void setDec(double dec) {
        this.dec = dec;
    }

    /**
     * @return the ra
     */
    public double getRa() {
        return ra;
    }

    /**
     * @param ra the ra to set
     */
    public void setRa(double ra) {
        this.ra = ra;
    }

    /**
     * @return the julianDate
     */
    public double getJulianDate() {
        return julianDate;
    }

    /**
     * @param julianDate the julianDate to set
     */
    public void setJulianDate(double julianDate) {
        this.julianDate = julianDate;
    }

    /**
     * @return the moduleParameters
     */
    public DebugModuleParams getModuleParameters() {
        return moduleParameters;
    }

    /**
     * @param moduleParameters the moduleParameters to set
     */
    public void setModuleParameters(DebugModuleParams moduleParameters) {
        this.moduleParameters = moduleParameters;
    }

    /**
     * @return the raDec2PixModel
     */
    public RaDec2PixModel getRaDec2PixModel() {
        return raDec2PixModel;
    }

    /**
     * @param raDec2PixModel the raDec2PixModel to set
     */
    public void setRaDec2PixModel(RaDec2PixModel raDec2PixModel) {
        this.raDec2PixModel = raDec2PixModel;
    }

    public FcConstants getFcConstants() {
        return fcConstants;
    }

    public void setFcConstants(FcConstants fcConstants) {
        this.fcConstants = fcConstants;
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

    /**
     * @return the inputElements
     */
    public List<DebugElement> getInputElements() {
        return inputElements;
    }

    /**
     * @param inputElements the inputElements to set
     */
    public void setInputElements(List<DebugElement> inputElements) {
        this.inputElements = inputElements;
    }

    /**
     * @return the testString
     */
    public String getTestString() {
        return testString;
    }

    /**
     * @param testString the testString to set
     */
    public void setTestString(String testString) {
        this.testString = testString;
    }

    /**
     * @return the testStringArray
     */
    public String[] getTestStringArray() {
        return testStringArray;
    }

    /**
     * @param testStringArray the testStringArray to set
     */
    public void setTestStringArray(String[] testStringArray) {
        this.testStringArray = testStringArray;
    }

    /**
     * @return the testStringArray2
     */
    public String[][] getTestStringArray2() {
        return testStringArray2;
    }

    /**
     * @param testStringArray2 the testStringArray2 to set
     */
    public void setTestStringArray2(String[][] testStringArray2) {
        this.testStringArray2 = testStringArray2;
    }
}
