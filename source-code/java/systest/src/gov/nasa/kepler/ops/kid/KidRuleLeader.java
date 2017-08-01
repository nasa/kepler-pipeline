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
import gov.nasa.kepler.investigations.LeaderType;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.List;
import java.util.Map;
import java.util.Properties;

/**
 * Implements the leader KID rule: <br>
 * - If the investigation is a base investigation, copy the leader from the base
 * investigation file.<br>
 * - If the investigation is a shared investigation, please work down the
 * following set of prioritized rules.<br>
 * a. If one of the component investigations = EX, the leader should be set
 * equal to the EX leader<br>
 * b. If all of the component investigations = STK* (e.g. either STKL or STKS),
 * the leader should be set equal to the STKS leader<br>
 * c. If all of the component investigations = GO*, the leader should be set
 * equal to GO_leader name (specified in one of the input files)<br>
 * d. If none of the above rules are relevant, the leader should be set equal to
 * SO_leader name (specified in one of the input files)<br>
 * 
 * @author Miles Cote
 * 
 */
public class KidRuleLeader implements KidRule {

    static final String EX_LEADER_NAME_PROP_NAME = "exLeaderName";
    static final String EX_LEADER_EMAIL_PROP_NAME = "exLeaderEmail";
    static final String STK_LEADER_NAME_PROP_NAME = "stkLeaderName";
    static final String STK_LEADER_EMAIL_PROP_NAME = "stkLeaderEmail";
    static final String GO_LEADER_NAME_PROP_NAME = "goLeaderName";
    static final String GO_LEADER_EMAIL_PROP_NAME = "goLeaderEmail";
    static final String SO_LEADER_NAME_PROP_NAME = "soLeaderName";
    static final String SO_LEADER_EMAIL_PROP_NAME = "soLeaderEmail";

    private static final String EX = "EX";
    private static final String STK = "STK";
    private static final String GO = "GO";

    private final Properties properties;

    public KidRuleLeader(Properties properties) {
        this.properties = properties;
    }

    @Override
    public void apply(List<InvestigationType> kidInvestigations,
        Map<String, List<CompletedKtcEntry>> investigationIdToKtcEntries,
        Map<String, InvestigationType> baseInvestigationIdToBaseInvestigation) {
        for (InvestigationType kidInvestigation : kidInvestigations) {
            Pair<String, String> nameEmailPair = null;
            if (!kidInvestigation.getId()
                .contains(INVESTIGATION_ID_SEPARATOR)) {
                InvestigationType baseInvestigation = baseInvestigationIdToBaseInvestigation.get(kidInvestigation.getId());
                nameEmailPair = Pair.of(baseInvestigation.getLeader()
                    .getName(), baseInvestigation.getLeader()
                    .getEmail());
            } else {
                boolean foundEx = false;
                boolean allStk = true;
                boolean allGo = true;

                String[] baseInvestigationIds = kidInvestigation.getId()
                    .split(INVESTIGATION_ID_SEPARATOR);
                for (String baseInvestigationId : baseInvestigationIds) {
                    foundEx |= baseInvestigationId.startsWith(EX);
                    allStk &= baseInvestigationId.startsWith(STK);
                    allGo &= baseInvestigationId.startsWith(GO);
                }

                if (foundEx) {
                    nameEmailPair = Pair.of(
                        properties.getProperty(EX_LEADER_NAME_PROP_NAME),
                        properties.getProperty(EX_LEADER_EMAIL_PROP_NAME));
                } else if (allStk) {
                    nameEmailPair = Pair.of(
                        properties.getProperty(STK_LEADER_NAME_PROP_NAME),
                        properties.getProperty(STK_LEADER_EMAIL_PROP_NAME));
                } else if (allGo) {
                    nameEmailPair = Pair.of(
                        properties.getProperty(GO_LEADER_NAME_PROP_NAME),
                        properties.getProperty(GO_LEADER_EMAIL_PROP_NAME));
                } else {
                    nameEmailPair = Pair.of(
                        properties.getProperty(SO_LEADER_NAME_PROP_NAME),
                        properties.getProperty(SO_LEADER_EMAIL_PROP_NAME));
                }
            }

            LeaderType leaderType = LeaderType.Factory.newInstance();
            leaderType.setName(nameEmailPair.left);
            leaderType.setEmail(nameEmailPair.right);

            kidInvestigation.setLeader(leaderType);
        }
    }

}
