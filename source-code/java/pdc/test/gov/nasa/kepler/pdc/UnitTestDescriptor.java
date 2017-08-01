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

package gov.nasa.kepler.pdc;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ModifiedJulianDate;

/**
 * Descriptor used to control the unit tests.
 * 
 * @author Forrest Girouard
 */
public class UnitTestDescriptor {

    private static final int START_LC = 1439;
    private static final int END_LC = 1488;

    // ModOutCadenceUowTask
    private int startCadence = START_LC;
    private int endCadence = END_LC;

    // Parameters
    private CadenceType cadenceType = CadenceType.LONG;

    // Unit test control
    private boolean generateAlerts = false;
    private boolean serializeInputs = false;
    private boolean serializeOutputs = false;
    private boolean validateInputs = false;
    private boolean validateOutputs = false;
    private boolean mapEnabled = false;
    private boolean pseudoTargetListEnabled = false;
    private boolean[] useBasisVectorsFromBlob = new boolean[] { false };

    public CadenceType getCadenceType() {
        return cadenceType;
    }

    public void setCadenceType(final CadenceType cadenceType) {
        if (getCadenceType() != cadenceType) {
            if (cadenceType == CadenceType.SHORT) {
                int longCadences = endCadence - startCadence + 1;
                startCadence *= ModifiedJulianDate.SHORT_CADENCES_PER_LONG;
                endCadence = startCadence + longCadences
                    * ModifiedJulianDate.SHORT_CADENCES_PER_LONG - 1;
            } else {
                int shortCadences = endCadence - startCadence + 1;
                startCadence /= ModifiedJulianDate.SHORT_CADENCES_PER_LONG;
                endCadence = startCadence + shortCadences
                    / ModifiedJulianDate.SHORT_CADENCES_PER_LONG - 1;
            }
            this.cadenceType = cadenceType;
        }
    }

    public int getStartCadence() {
        return startCadence;
    }

    public int getStartCadence(final CadenceType cadenceType) {
        int cadence = startCadence;
        if (this.cadenceType != cadenceType) {
            if (cadenceType == CadenceType.LONG) {
                cadence /= ModifiedJulianDate.SHORT_CADENCES_PER_LONG;
            } else {
                cadence *= ModifiedJulianDate.SHORT_CADENCES_PER_LONG;
            }
        }
        return cadence;
    }

    public void setStartCadence(int startCadence) {
        this.startCadence = startCadence;
    }

    public int getEndCadence() {
        return endCadence;
    }

    public int getEndCadence(final CadenceType cadenceType) {
        int cadence = endCadence;
        if (this.cadenceType != cadenceType) {
            if (cadenceType == CadenceType.LONG) {
                cadence = (endCadence + 1)
                    / ModifiedJulianDate.SHORT_CADENCES_PER_LONG - 1;
            } else {
                cadence = (endCadence + 1)
                    * ModifiedJulianDate.SHORT_CADENCES_PER_LONG - 1;
            }
        }
        return cadence;
    }

    public void setEndCadence(int endCadence) {
        this.endCadence = endCadence;
    }

    public boolean isGenerateAlerts() {
        return generateAlerts;
    }

    public void setGenerateAlerts(boolean generateAlerts) {
        this.generateAlerts = generateAlerts;
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

    public boolean isMapEnabled() {
        return mapEnabled;
    }

    public void setMapEnabled(boolean mapEnabled) {
        this.mapEnabled = mapEnabled;
    }

    public boolean isPseudoTargetListEnabled() {
        return pseudoTargetListEnabled;
    }

    public void setPseudoTargetListEnabled(boolean pseudoTargetListEnabled) {
        this.pseudoTargetListEnabled = pseudoTargetListEnabled;
    }

    public void setUseBasisVectorsFromBlob(boolean[] useBasisVectorsFromBlob) {
        this.useBasisVectorsFromBlob = useBasisVectorsFromBlob;
    }

    public boolean[] getUseBasisVectorsFromBlob() {
        return useBasisVectorsFromBlob;
    }
}
