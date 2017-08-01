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

package gov.nasa.kepler.tip;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ModifiedJulianDate;

public class UnitTestDescriptor {

    private static final long INSTANCE_ID = System.currentTimeMillis();
    private static final long TPS_PIPELINE_INSTANCE_ID = INSTANCE_ID - 10000;

    private static final int START_LC = 1439;
    private static final int END_LC = 1488;

    private CadenceType cadenceType = CadenceType.LONG;
    private boolean serializeInputs = false;
    private boolean serializeOutputs = false;
    private boolean validateInputs = false;
    private boolean validateOutputs = false;
    private int startCadence = START_LC;
    private int endCadence = END_LC;
    private long tpsPipelineInstanceId = TPS_PIPELINE_INSTANCE_ID;

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

    public void setEndCadence(final int endCadence) {
        this.endCadence = endCadence;
    }

    public boolean isSerializeInputs() {
        return serializeInputs;
    }

    public void setSerializeInputs(final boolean serializeInputs) {
        this.serializeInputs = serializeInputs;
    }

    public boolean isSerializeOutputs() {
        return serializeOutputs;
    }

    public void setSerializeOutputs(final boolean serializeOutputs) {
        this.serializeOutputs = serializeOutputs;
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

    public void setStartCadence(final int startCadence) {
        this.startCadence = startCadence;
    }

    public long getTpsPipelineInstanceId() {
        return tpsPipelineInstanceId;
    }

    public void setTpsPipelineInstanceId(long tpsPipelineInstanceId) {
        this.tpsPipelineInstanceId = tpsPipelineInstanceId;
    }

    public boolean isValidateInputs() {
        return validateInputs;
    }

    public void setValidateInputs(final boolean validateInputs) {
        this.validateInputs = validateInputs;
    }

    public boolean isValidateOutputs() {
        return validateOutputs;
    }

    public void setValidateOutputs(final boolean validateOutputs) {
        this.validateOutputs = validateOutputs;
    }
}
