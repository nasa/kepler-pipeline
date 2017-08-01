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
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.investigations.CollaboratorListType;
import gov.nasa.kepler.investigations.CollaboratorType;
import gov.nasa.kepler.investigations.InvestigationType;
import gov.nasa.kepler.investigations.InvestigationTypeType;
import gov.nasa.kepler.investigations.LeaderType;
import gov.nasa.kepler.investigations.ObservationEventType;
import gov.nasa.kepler.investigations.ObservationEventTypeType;

import java.io.File;
import java.io.IOException;
import java.util.List;

import org.apache.xmlbeans.XmlException;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class InvestigationsReaderWriterTest {

    @Test
    public void testReadWrite() throws IOException, XmlException {
        String id = "id";
        String title = "title";
        InvestigationTypeType.Enum investigationTypeType = InvestigationTypeType.GO;
        String abstractString = "abstractString";
        String name = "name";
        String email = "email@nasa.gov";
        double mjdStart = 1.1;
        double mjdEnd = 2.2;

        LeaderType leaderType = LeaderType.Factory.newInstance();
        leaderType.setName(name);
        leaderType.setEmail(email);

        CollaboratorType collaboratorType = CollaboratorType.Factory.newInstance();
        collaboratorType.setName(name);
        collaboratorType.setEmail(email);

        List<CollaboratorType> collaboratorTypes = ImmutableList.of(collaboratorType);

        CollaboratorListType collaboratorListType = CollaboratorListType.Factory.newInstance();
        collaboratorListType.setCollaboratorArray(collaboratorTypes.toArray(new CollaboratorType[0]));

        ObservationEventTypeType.Enum observationEventTypeTypeStart = ObservationEventTypeType.PLANNED;

        ObservationEventType observationEventTypeStart = ObservationEventType.Factory.newInstance();
        observationEventTypeStart.setMjd(mjdStart);
        observationEventTypeStart.setType(observationEventTypeTypeStart);

        ObservationEventTypeType.Enum observationEventTypeTypeEnd = ObservationEventTypeType.ACTUAL;

        ObservationEventType observationEventTypeEnd = ObservationEventType.Factory.newInstance();
        observationEventTypeEnd.setMjd(mjdEnd);
        observationEventTypeEnd.setType(observationEventTypeTypeEnd);

        InvestigationType investigationType = InvestigationType.Factory.newInstance();
        investigationType.setId(id);
        investigationType.setTitle(title);
        investigationType.setType(investigationTypeType);
        investigationType.setAbstract(abstractString);
        investigationType.setLeader(leaderType);
        investigationType.setCollaborators(collaboratorListType);
        investigationType.setStart(observationEventTypeStart);
        investigationType.setEnd(observationEventTypeEnd);

        List<InvestigationType> investigations = ImmutableList.of(investigationType);

        InvestigationsWriter investigationsWriter = new InvestigationsWriter(
            true);
        File file = investigationsWriter.write(investigations);

        InvestigationsReader investigationsReader = new InvestigationsReader();
        List<InvestigationType> actualInvestigations = investigationsReader.read(file);

        assertEquals(investigations.toString(), actualInvestigations.toString());

        boolean deleted = file.delete();
        if (!deleted) {
            throw new IllegalStateException("File was not deleted.");
        }
        assertTrue(!file.exists());
    }

}
