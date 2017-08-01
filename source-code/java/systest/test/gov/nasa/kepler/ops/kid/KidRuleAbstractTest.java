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

import java.util.List;
import java.util.Map;

import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;

/**
 * @author Miles Cote
 * 
 */
public class KidRuleAbstractTest {

    @Test
    public void testApplyForBaseInvestigation() {
        String investigationId = "investigationId";
        String abstractString = "abstract";

        InvestigationType kidInvestigation = InvestigationType.Factory.newInstance();
        kidInvestigation.setId(investigationId);

        List<InvestigationType> kidInvestigations = ImmutableList.of(kidInvestigation);

        Map<String, List<CompletedKtcEntry>> investigationIdToKtcEntries = null;

        InvestigationType baseInvestigation = InvestigationType.Factory.newInstance();
        baseInvestigation.setId(investigationId);
        baseInvestigation.setAbstract(abstractString);

        Map<String, InvestigationType> baseInvestigationIdToBaseInvestigation = ImmutableMap.of(
            investigationId, baseInvestigation);

        KidRuleAbstract kidRuleAbstract = new KidRuleAbstract();
        kidRuleAbstract.apply(kidInvestigations, investigationIdToKtcEntries,
            baseInvestigationIdToBaseInvestigation);

        InvestigationType expectedKidInvestigation = InvestigationType.Factory.newInstance();
        expectedKidInvestigation.setId(investigationId);
        expectedKidInvestigation.setAbstract(abstractString);

        List<InvestigationType> expectedKidInvestigations = ImmutableList.of(expectedKidInvestigation);

        assertEquals(expectedKidInvestigations.toString(),
            kidInvestigations.toString());
    }

    @Test
    public void testApplyForSharedInvestigation() {
        String investigationId = "investigationId";
        String investigationId_investigationId = "investigationId_investigationId";
        String abstractString = "abstract";

        InvestigationType kidInvestigation = InvestigationType.Factory.newInstance();
        kidInvestigation.setId(investigationId_investigationId);

        List<InvestigationType> kidInvestigations = ImmutableList.of(kidInvestigation);

        Map<String, List<CompletedKtcEntry>> investigationIdToKtcEntries = null;

        InvestigationType baseInvestigation = InvestigationType.Factory.newInstance();
        baseInvestigation.setId(investigationId);
        baseInvestigation.setAbstract(abstractString);

        Map<String, InvestigationType> baseInvestigationIdToBaseInvestigation = ImmutableMap.of(
            investigationId, baseInvestigation);

        KidRuleAbstract kidRuleAbstract = new KidRuleAbstract();
        kidRuleAbstract.apply(kidInvestigations, investigationIdToKtcEntries,
            baseInvestigationIdToBaseInvestigation);

        InvestigationType expectedKidInvestigation = InvestigationType.Factory.newInstance();
        expectedKidInvestigation.setId(investigationId_investigationId);
        expectedKidInvestigation.setAbstract("");

        List<InvestigationType> expectedKidInvestigations = ImmutableList.of(expectedKidInvestigation);

        assertEquals(expectedKidInvestigations.toString(),
            kidInvestigations.toString());
    }

}
