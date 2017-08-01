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
import gov.nasa.kepler.investigations.ObservationEventType;
import gov.nasa.kepler.investigations.ObservationEventTypeType;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.PriorityQueue;

/**
 * Implements the start time KID rule: <br>
 * start: if any component base investigation has an actual start time, then set
 * this to the earliest component base investigation actual start time from the
 * KTC. Otherwise, set this to the earliest component planned start time for any
 * component base investigation from the KTC.
 * 
 * @author Miles Cote
 * 
 */
public class KidRuleEnd implements KidRule {

    @Override
    public void apply(List<InvestigationType> kidInvestigations,
        Map<String, List<CompletedKtcEntry>> investigationIdToKtcEntries,
        Map<String, InvestigationType> baseInvestigationIdToBaseInvestigation) {
        for (InvestigationType kidInvestigationType : kidInvestigations) {
            String[] baseInvestigationIds = kidInvestigationType.getId()
                .split(INVESTIGATION_ID_SEPARATOR);

            List<CompletedKtcEntry> ktcEntries = new ArrayList<CompletedKtcEntry>();
            if (baseInvestigationIds.length == 1) {
                for (Entry<String, List<CompletedKtcEntry>> entry : investigationIdToKtcEntries.entrySet()) {
                    if (entry.getKey()
                        .contains(baseInvestigationIds[0])) {
                        ktcEntries.addAll(entry.getValue());
                    }
                }
            } else {
                ktcEntries.addAll(investigationIdToKtcEntries.get(kidInvestigationType.getId()));
            }

            if (ktcEntries.isEmpty()) {
                throw new IllegalStateException(
                    "There must be at least one KTC entry for each KID investigation.\n  kidInvestigationWithNoKtcEntry: "
                        + kidInvestigationType.getId());
            }

            Comparator<ObservationEventType> comparator = new Comparator<ObservationEventType>() {
                @Override
                public int compare(ObservationEventType o1,
                    ObservationEventType o2) {
                    if (o1.getMjd() > o2.getMjd()) {
                        return -1;
                    } else if (o1.getMjd() < o2.getMjd()) {
                        return 1;
                    } else {
                        if (o1.getType()
                            .intValue() < o2.getType()
                            .intValue()) {
                            return -1;
                        } else if (o1.getType()
                            .intValue() > o2.getType()
                            .intValue()) {
                            return 1;
                        } else {
                            return 0;
                        }
                    }
                }
            };

            PriorityQueue<ObservationEventType> priorityQueue = new PriorityQueue<ObservationEventType>(
                ktcEntries.size(), comparator);
            for (CompletedKtcEntry ktcEntry : ktcEntries) {
                ObservationEventType eventTypePlanned = ObservationEventType.Factory.newInstance();
                eventTypePlanned.setMjd(ktcEntry.getPlanStop());
                eventTypePlanned.setType(ObservationEventTypeType.PLANNED);
                priorityQueue.add(eventTypePlanned);

                if (ktcEntry.getActualStop() != null) {
                    ObservationEventType eventTypeActual = ObservationEventType.Factory.newInstance();
                    eventTypeActual.setMjd(ktcEntry.getActualStop());
                    eventTypeActual.setType(ObservationEventTypeType.ACTUAL);
                    priorityQueue.add(eventTypeActual);
                }
            }

            kidInvestigationType.setEnd(priorityQueue.peek());
        }
    }

}
