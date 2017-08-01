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

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.ar.exporter.ktc.CompletedKtcEntry;
import gov.nasa.kepler.investigations.InvestigationType;
import gov.nasa.kepler.investigations.LeaderType;

import java.util.List;
import java.util.Map;
import java.util.Properties;

import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;

/**
 * @author Miles Cote
 * 
 */
public class KidRuleLeaderTest {

    @Test
    public void testApplyForBaseInvestigation() {
        String investigationId = "investigationId";
        String leader = "leader";
        String email = "email";

        InvestigationType kidInvestigation = InvestigationType.Factory.newInstance();
        kidInvestigation.setId(investigationId);

        List<InvestigationType> kidInvestigations = ImmutableList.of(kidInvestigation);

        Map<String, List<CompletedKtcEntry>> investigationIdToKtcEntries = null;

        LeaderType leaderType = LeaderType.Factory.newInstance();
        leaderType.setName(leader);
        leaderType.setEmail(email);

        InvestigationType baseInvestigation = InvestigationType.Factory.newInstance();
        baseInvestigation.setId(investigationId);
        baseInvestigation.setLeader(leaderType);

        Map<String, InvestigationType> baseInvestigationIdToBaseInvestigation = ImmutableMap.of(
            investigationId, baseInvestigation);

        KidRuleLeader kidRuleLeader = new KidRuleLeader(new Properties());
        kidRuleLeader.apply(kidInvestigations, investigationIdToKtcEntries,
            baseInvestigationIdToBaseInvestigation);

        InvestigationType expectedKidInvestigation = InvestigationType.Factory.newInstance();
        expectedKidInvestigation.setId(investigationId);
        expectedKidInvestigation.setLeader(leaderType);

        List<InvestigationType> expectedKidInvestigations = ImmutableList.of(expectedKidInvestigation);

        assertEquals(expectedKidInvestigations.toString(),
            kidInvestigations.toString());
    }

    @Test
    public void testApplyForSharedEXEX1() {
        testApplyForShared("EX" + KidRule.INVESTIGATION_ID_SEPARATOR + "EX1",
            KidRuleLeader.EX_LEADER_NAME_PROP_NAME,
            KidRuleLeader.EX_LEADER_EMAIL_PROP_NAME);
    }

    @Test
    public void testApplyForSharedEXSTK1() {
        testApplyForShared("EX" + KidRule.INVESTIGATION_ID_SEPARATOR + "STK1",
            KidRuleLeader.EX_LEADER_NAME_PROP_NAME,
            KidRuleLeader.EX_LEADER_EMAIL_PROP_NAME);
    }

    @Test
    public void testApplyForSharedEXGO1() {
        testApplyForShared("EX" + KidRule.INVESTIGATION_ID_SEPARATOR + "GO1",
            KidRuleLeader.EX_LEADER_NAME_PROP_NAME,
            KidRuleLeader.EX_LEADER_EMAIL_PROP_NAME);
    }

    @Test
    public void testApplyForSharedSTKSTK1() {
        testApplyForShared("STK" + KidRule.INVESTIGATION_ID_SEPARATOR + "STK1",
            KidRuleLeader.STK_LEADER_NAME_PROP_NAME,
            KidRuleLeader.STK_LEADER_EMAIL_PROP_NAME);
    }

    @Test
    public void testApplyForSharedSTKGO1() {
        testApplyForShared("STK" + KidRule.INVESTIGATION_ID_SEPARATOR + "GO1",
            KidRuleLeader.SO_LEADER_NAME_PROP_NAME,
            KidRuleLeader.SO_LEADER_EMAIL_PROP_NAME);
    }

    @Test
    public void testApplyForSharedGOGO1() {
        testApplyForShared("GO" + KidRule.INVESTIGATION_ID_SEPARATOR + "GO1",
            KidRuleLeader.GO_LEADER_NAME_PROP_NAME,
            KidRuleLeader.GO_LEADER_EMAIL_PROP_NAME);
    }

    private void testApplyForShared(String investigationId,
        String expectedName, String expectedEmail) {
        InvestigationType kidInvestigation = InvestigationType.Factory.newInstance();
        kidInvestigation.setId(investigationId);

        List<InvestigationType> kidInvestigations = ImmutableList.of(kidInvestigation);

        Map<String, List<CompletedKtcEntry>> investigationIdToKtcEntries = null;

        Map<String, InvestigationType> baseInvestigationIdToBaseInvestigation = null;

        Properties properties = new Properties();
        properties.put(KidRuleLeader.EX_LEADER_NAME_PROP_NAME,
            KidRuleLeader.EX_LEADER_NAME_PROP_NAME);
        properties.put(KidRuleLeader.EX_LEADER_EMAIL_PROP_NAME,
            KidRuleLeader.EX_LEADER_EMAIL_PROP_NAME);
        properties.put(KidRuleLeader.STK_LEADER_NAME_PROP_NAME,
            KidRuleLeader.STK_LEADER_NAME_PROP_NAME);
        properties.put(KidRuleLeader.STK_LEADER_EMAIL_PROP_NAME,
            KidRuleLeader.STK_LEADER_EMAIL_PROP_NAME);
        properties.put(KidRuleLeader.GO_LEADER_NAME_PROP_NAME,
            KidRuleLeader.GO_LEADER_NAME_PROP_NAME);
        properties.put(KidRuleLeader.GO_LEADER_EMAIL_PROP_NAME,
            KidRuleLeader.GO_LEADER_EMAIL_PROP_NAME);
        properties.put(KidRuleLeader.SO_LEADER_NAME_PROP_NAME,
            KidRuleLeader.SO_LEADER_NAME_PROP_NAME);
        properties.put(KidRuleLeader.SO_LEADER_EMAIL_PROP_NAME,
            KidRuleLeader.SO_LEADER_EMAIL_PROP_NAME);

        KidRuleLeader kidRuleLeader = new KidRuleLeader(properties);
        kidRuleLeader.apply(kidInvestigations, investigationIdToKtcEntries,
            baseInvestigationIdToBaseInvestigation);

        LeaderType leaderType = LeaderType.Factory.newInstance();
        leaderType.setName(expectedName);
        leaderType.setEmail(expectedEmail);

        InvestigationType expectedKidInvestigation = InvestigationType.Factory.newInstance();
        expectedKidInvestigation.setId(investigationId);
        expectedKidInvestigation.setLeader(leaderType);

        List<InvestigationType> expectedKidInvestigations = ImmutableList.of(expectedKidInvestigation);

        assertEquals(expectedKidInvestigations.toString(),
            kidInvestigations.toString());
    }

}
