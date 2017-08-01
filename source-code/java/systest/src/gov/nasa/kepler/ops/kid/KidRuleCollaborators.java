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
import gov.nasa.kepler.investigations.CollaboratorListType;
import gov.nasa.kepler.investigations.CollaboratorType;
import gov.nasa.kepler.investigations.InvestigationType;
import gov.nasa.kepler.investigations.LeaderType;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Implements the collaborators KID rule: <br>
 * The collaborator list should be a concatenation of the collaborators listed
 * in each of the base investigations. The leader of of the joint investigation
 * should not be added, but the leaders of any other investigation used to make
 * this joint investigation should be added to the collaborator list. The leader
 * of of the joint investigation should be removed from the collaborator list.
 * The new collaborators list should only have one instance of each name.
 * 
 * @author Miles Cote
 * 
 */
public class KidRuleCollaborators implements KidRule {

    @Override
    public void apply(List<InvestigationType> kidInvestigations,
        Map<String, List<CompletedKtcEntry>> investigationIdToKtcEntries,
        Map<String, InvestigationType> baseInvestigationIdToBaseInvestigation) {
        for (InvestigationType kidInvestigation : kidInvestigations) {
            Set<Pair<String, String>> nameEmailPairs = new LinkedHashSet<Pair<String, String>>();

            String[] baseInvestigationIds = kidInvestigation.getId()
                .split(INVESTIGATION_ID_SEPARATOR);
            if (baseInvestigationIds.length == 1) {
                InvestigationType baseInvestigation = baseInvestigationIdToBaseInvestigation.get(baseInvestigationIds[0]);

                @SuppressWarnings("deprecation")
                CollaboratorType[] collaboratorArray = baseInvestigation.getCollaborators()
                    .getCollaboratorArray();
                for (CollaboratorType collaboratorType : collaboratorArray) {
                    nameEmailPairs.add(Pair.of(collaboratorType.getName(),
                        collaboratorType.getEmail()));
                }
            } else {
                for (String baseInvestigationId : baseInvestigationIds) {
                    InvestigationType baseInvestigation = baseInvestigationIdToBaseInvestigation.get(baseInvestigationId);

                    LeaderType leader = baseInvestigation.getLeader();
                    nameEmailPairs.add(Pair.of(leader.getName(),
                        leader.getEmail()));

                    @SuppressWarnings("deprecation")
                    CollaboratorType[] collaboratorArray = baseInvestigation.getCollaborators()
                        .getCollaboratorArray();
                    for (CollaboratorType collaboratorType : collaboratorArray) {
                        nameEmailPairs.add(Pair.of(collaboratorType.getName(),
                            collaboratorType.getEmail()));
                    }
                }

                LeaderType jointLeader = kidInvestigation.getLeader();
                nameEmailPairs.remove(Pair.of(jointLeader.getName(),
                    jointLeader.getEmail()));
            }

            List<CollaboratorType> collaborators = new ArrayList<CollaboratorType>();
            for (Pair<String, String> nameEmailPair : nameEmailPairs) {
                CollaboratorType collaboratorType = CollaboratorType.Factory.newInstance();
                collaboratorType.setName(nameEmailPair.left);
                collaboratorType.setEmail(nameEmailPair.right);
                collaborators.add(collaboratorType);
            }

            CollaboratorListType collaboratorListType = CollaboratorListType.Factory.newInstance();
            collaboratorListType.setCollaboratorArray(collaborators.toArray(new CollaboratorType[0]));

            kidInvestigation.setCollaborators(collaboratorListType);
        }
    }

}
