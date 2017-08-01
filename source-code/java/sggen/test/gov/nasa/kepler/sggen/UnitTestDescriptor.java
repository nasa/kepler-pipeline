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

package gov.nasa.kepler.sggen;

/**
 * Descriptor used to control the unit tests.
 * 
 * @author Bill Wohler
 */
public class UnitTestDescriptor {

    // CadenceRangeParameters
    private int startCadence = 1439;
    private int endCadence = 1488;

    // PlanetaryCandidatesChunkUowTask
    private int startKeplerId = 10000000;
    private int endKeplerId = startKeplerId + 100;
    private int skyGroupId = 13;

    // Unit test control
    private boolean serializeInputs = false;
    private boolean serializeOutputs = false;
    private boolean validateInputs = false;
    private boolean validateOutputs = false;

    public int getCadenceCount() {
        return endCadence - startCadence + 1;
    }

    public int getStartCadence() {
        return startCadence;
    }

    public void setStartCadence(int startCadence) {
        this.startCadence = startCadence;
    }

    public int getEndCadence() {
        return endCadence;
    }

    public void setEndCadence(int endCadence) {
        this.endCadence = endCadence;
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

    public int getSkyGroupId() {
        return skyGroupId;
    }

    public void setSkyGroupId(int skyGroupId) {
        this.skyGroupId = skyGroupId;
    }

    public boolean isSerializeInputs() {
        return serializeInputs;
    }

    public void setSerializeInputs(boolean serializeInputs) {
        this.serializeInputs = serializeInputs;
    }

    public boolean isSerializeOutputs() {
        return serializeOutputs;
    }

    public void setSerializeOutputs(boolean serializeOutputs) {
        this.serializeOutputs = serializeOutputs;
    }

    public boolean isValidateInputs() {
        return validateInputs;
    }

    public void setValidateInputs(boolean validateInputs) {
        this.validateInputs = validateInputs;
    }

    public boolean isValidateOutputs() {
        return validateOutputs;
    }

    public void setValidateOutputs(boolean validateOutputs) {
        this.validateOutputs = validateOutputs;
    }
}
