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

package gov.nasa.kepler.systest;

public class EtemScienceInjectedKeplerId {

    public enum EtemScienceInjectionType {
        SOHO_BASED_STELLAR_VARIABILITY("SOHO-based stellar variability"),
        TRANSITING_EARTH("Transiting Earths"),
        TRANSITING_JUPITER("Transiting Jupiters"),
        ECLIPSING_BINARY_STAR("Eclipsing Binary Stars");

        private String etemStringId;

        private EtemScienceInjectionType(String etemStringId) {
            this.etemStringId = etemStringId;
        }

        public String getEtemStringId() {
            return etemStringId;
        }

        public static EtemScienceInjectionType valueOfEtemStringId(
            String etemStringId) {
            if (etemStringId.equals(SOHO_BASED_STELLAR_VARIABILITY.getEtemStringId())) {
                return SOHO_BASED_STELLAR_VARIABILITY;
            }
            if (etemStringId.equals(TRANSITING_EARTH.getEtemStringId())) {
                return TRANSITING_EARTH;
            }
            if (etemStringId.equals(TRANSITING_JUPITER.getEtemStringId())) {
                return TRANSITING_JUPITER;
            }
            if (etemStringId.equals(ECLIPSING_BINARY_STAR.getEtemStringId())) {
                return ECLIPSING_BINARY_STAR;
            }
            throw new IllegalArgumentException("Invalid etemStringId \""
                + etemStringId + "\".");
        }
    }

    private int keplerId;
    private EtemScienceInjectionType etemScienceInjectionType;

    public EtemScienceInjectedKeplerId(int keplerId,
        EtemScienceInjectionType etemScienceInjectionType) {
        this.keplerId = keplerId;
        this.etemScienceInjectionType = etemScienceInjectionType;
    }

    @Override
    public String toString() {
        StringBuilder builder = new StringBuilder();
        builder.append("[")
            .append(keplerId)
            .append(",")
            .append(etemScienceInjectionType)
            .append("]");

        return builder.toString();
    }

    public int getKeplerId() {
        return keplerId;
    }

    public EtemScienceInjectionType getEtemScienceInjectionType() {
        return etemScienceInjectionType;
    }

}
