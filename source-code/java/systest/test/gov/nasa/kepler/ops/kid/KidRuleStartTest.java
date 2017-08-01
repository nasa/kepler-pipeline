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
import gov.nasa.kepler.investigations.ObservationEventType;
import gov.nasa.kepler.investigations.ObservationEventTypeType;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.util.List;
import java.util.Map;

import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;

/**
 * @author Miles Cote
 * 
 */
public class KidRuleStartTest extends JMockTest {

    @Test
    public void testApplyWithPlannedStartEarlier() {
        testApply(1.1, 2.2, 2.2, ObservationEventTypeType.ACTUAL,
            "investigationId", "investigationId");
    }

    @Test
    public void testApplyWithActualStartEarlier() {
        testApply(2.2, 1.1, 1.1, ObservationEventTypeType.ACTUAL,
            "investigationId", "investigationId");
    }

    @Test
    public void testApplyWithNullActualStart() {
        testApply(1.1, null, 1.1, ObservationEventTypeType.PLANNED,
            "investigationId", "investigationId");
    }

    @Test
    public void testApplyWhereInvestigationDoesNotExistInKtcAndIsBaseInvestigation() {
        testApply(2.2, 1.1, 1.1, ObservationEventTypeType.ACTUAL,
            "investigationId_investigationId", "investigationId");
    }

    private void testApply(double plannedMjd, Double actualMjd,
        double expectedMjd, ObservationEventTypeType.Enum expectedType,
        String ktcInvestigationId, String kidInvestigationId) {
        InvestigationType kidInvestigation = InvestigationType.Factory.newInstance();
        kidInvestigation.setId(kidInvestigationId);

        List<InvestigationType> kidInvestigations = ImmutableList.of(kidInvestigation);

        CompletedKtcEntry ktcEntry = mock(CompletedKtcEntry.class);

        List<CompletedKtcEntry> ktcEntries = ImmutableList.of(ktcEntry);

        Map<String, List<CompletedKtcEntry>> investigationIdToKtcEntries = ImmutableMap.of(ktcInvestigationId, ktcEntries);

        Map<String, InvestigationType> baseInvestigationIdToBaseInvestigation = null;

        allowing(ktcEntry).getInvestigation();
        will(returnValue(ktcInvestigationId));

        allowing(ktcEntry).getPlanStart();
        will(returnValue(plannedMjd));

        allowing(ktcEntry).getActualStart();
        will(returnValue(actualMjd));

        KidRuleStart kidRuleStart = new KidRuleStart();
        kidRuleStart.apply(kidInvestigations, investigationIdToKtcEntries,
            baseInvestigationIdToBaseInvestigation);

        ObservationEventType expectedObservationEventType = ObservationEventType.Factory.newInstance();
        expectedObservationEventType.setMjd(expectedMjd);
        expectedObservationEventType.setType(expectedType);

        InvestigationType expectedKidInvestigation = InvestigationType.Factory.newInstance();
        expectedKidInvestigation.setId(kidInvestigationId);
        expectedKidInvestigation.setStart(expectedObservationEventType);

        List<InvestigationType> expectedKidInvestigations = ImmutableList.of(expectedKidInvestigation);

        assertEquals(expectedKidInvestigations.toString(),
            kidInvestigations.toString());
    }

}
