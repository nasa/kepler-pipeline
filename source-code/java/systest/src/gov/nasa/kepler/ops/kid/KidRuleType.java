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

import gov.nasa.kepler.ar.exporter.ktc.CompletedKtcEntry;
import gov.nasa.kepler.investigations.InvestigationType;
import gov.nasa.kepler.investigations.InvestigationTypeType;

import java.util.List;
import java.util.Map;

/**
 * Implements the type KID rule: <br>
 * Types should be assigned in priority order based on the
 * {@link InvestigationTypeType} enumerations in the investigations.xsd file. In
 * other words, of the types specified in the base investigations, assign the
 * earliest one found in the priority list.
 * 
 * @author Miles Cote
 * 
 */
public class KidRuleType implements KidRule {

    @Override
    public void apply(List<InvestigationType> kidInvestigations,
        Map<String, List<CompletedKtcEntry>> investigationIdToKtcEntries,
        Map<String, InvestigationType> baseInvestigationIdToBaseInvestigation) {
        for (InvestigationType kidInvestigation : kidInvestigations) {
            InvestigationTypeType.Enum type = null;

            for (int i = 1; i <= InvestigationTypeType.Enum.table.lastInt(); i++) {
                InvestigationTypeType.Enum typeForInt = InvestigationTypeType.Enum.forInt(i);

                String[] baseInvestigationIds = kidInvestigation.getId()
                    .split(INVESTIGATION_ID_SEPARATOR);
                for (String baseInvestigationId : baseInvestigationIds) {
                    InvestigationType baseInvestigation = baseInvestigationIdToBaseInvestigation.get(baseInvestigationId);
                    InvestigationTypeType.Enum baseInvestigationType = baseInvestigation.getType();

                    if (type == null
                        && typeForInt.equals(baseInvestigationType)) {
                        type = typeForInt;
                    }
                }
            }

            kidInvestigation.setType(type);
        }
    }

}
