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

package gov.nasa.kepler.ops.kid;

import gov.nasa.kepler.investigations.CollaboratorType;
import gov.nasa.kepler.investigations.InvestigationType;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Generates warnings for an {@link InvestigationType}.
 * 
 * @author Miles Cote
 * 
 */
public class InvestigationWarningsGenerator {

    static final String NAME_SEPARATOR = ",";
    static final String WARNING_SEPARATOR = "; ";

    @SuppressWarnings("deprecation")
    public String generate(InvestigationType investigationType) {
        StringBuilder warnings = new StringBuilder();

        Map<String, String> lastNameToFirstName = new LinkedHashMap<String, String>();
        Map<String, String> lastNameToEmail = new LinkedHashMap<String, String>();
        Map<String, String> emailToName = new LinkedHashMap<String, String>();
        for (CollaboratorType collaboratorType : investigationType.getCollaborators()
            .getCollaboratorArray()) {
            String fullName = collaboratorType.getName();
            String[] nameParts = fullName.split(NAME_SEPARATOR);

            String lastName = nameParts[0];

            String firstName = "";
            if (nameParts.length >= 2) {
                firstName = nameParts[1];
            }

            String previousFirstName = lastNameToFirstName.get(lastName);
            if (previousFirstName != null) {
                if (!previousFirstName.equals(firstName)) {
                    warnings.append("Collaborators should not have the same last name with different first names.  "
                        + lastName
                        + " has first names "
                        + previousFirstName
                        + " and " + firstName + WARNING_SEPARATOR);
                }
            }
            lastNameToFirstName.put(lastName, firstName);

            String email = collaboratorType.getEmail();

            String previousEmail = lastNameToEmail.get(lastName);
            if (previousEmail != null) {
                if (!previousEmail.equals(email)) {
                    warnings.append("Collaborators should not have the same last name with different email.  "
                        + lastName
                        + " has email "
                        + previousEmail
                        + " and "
                        + email + WARNING_SEPARATOR);
                }
            }
            lastNameToEmail.put(lastName, email);

            String previousName = emailToName.get(email);
            if (previousName != null) {
                if (!previousName.equals(fullName)) {
                    warnings.append("Collaborators should not have the same email with different full names.  "
                        + email
                        + " has full name "
                        + previousName
                        + " and "
                        + fullName + WARNING_SEPARATOR);
                }
            }
            emailToName.put(email, fullName);
        }

        return warnings.toString();
    }

}
