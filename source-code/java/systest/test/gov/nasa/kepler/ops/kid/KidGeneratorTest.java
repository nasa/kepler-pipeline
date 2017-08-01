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
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Map;

import org.apache.xmlbeans.XmlException;
import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;

/**
 * @author Miles Cote
 * 
 */
public class KidGeneratorTest extends JMockTest {

    @Test
    public void testGenerate() throws IOException, XmlException {
        String investigationId = "investigationId";

        File ktcFile = mock(File.class, "ktcFile");
        File baseInvestigationsFile = mock(File.class, "baseInvestigationsFile");
        File kidFile = mock(File.class, "kidFile");
        File reportFile = mock(File.class, "reportFile");

        CompletedKtcEntry ktcEntry = mock(CompletedKtcEntry.class);
        List<CompletedKtcEntry> ktcEntries = ImmutableList.of(ktcEntry);

        InvestigationType kidInvestigationType = mock(InvestigationType.class,
            "kidInvestigationType");
        List<InvestigationType> kidInvestigationTypes = ImmutableList.of(kidInvestigationType);

        InvestigationType baseInvestigationType = mock(InvestigationType.class,
            "baseInvestigationType");
        List<InvestigationType> baseInvestigationTypes = ImmutableList.of(baseInvestigationType);

        KtcReader ktcReader = mock(KtcReader.class);
        InvestigationTypeListFactory investigationTypeListFactory = mock(InvestigationTypeListFactory.class);
        InvestigationsReader investigationsReader = mock(InvestigationsReader.class);
        InvestigationsWriter investigationsWriter = mock(InvestigationsWriter.class);
        InvestigationsReportWriter investigationsReportWriter = mock(InvestigationsReportWriter.class);

        KidRule kidRule = mock(KidRule.class);
        List<KidRule> kidRules = ImmutableList.of(kidRule);

        Map<String, List<CompletedKtcEntry>> investigationIdToKtcEntries = ImmutableMap.of(investigationId, ktcEntries);

        Map<String, InvestigationType> baseInvestigationIdToBaseInvestigation = ImmutableMap.of(investigationId, baseInvestigationType);

        allowing(ktcReader).read(ktcFile);
        will(returnValue(ktcEntries));

        allowing(investigationTypeListFactory).create(ktcEntries,
            baseInvestigationTypes);
        will(returnValue(kidInvestigationTypes));

        allowing(investigationsReader).read(baseInvestigationsFile);
        will(returnValue(baseInvestigationTypes));

        allowing(investigationsWriter).write(kidInvestigationTypes);
        will(returnValue(kidFile));

        allowing(investigationsReportWriter).write(kidInvestigationTypes);
        will(returnValue(reportFile));

        oneOf(kidRule).apply(kidInvestigationTypes,
            investigationIdToKtcEntries, baseInvestigationIdToBaseInvestigation);

        allowing(ktcEntry).getInvestigation();
        will(returnValue(investigationId));

        allowing(baseInvestigationType).getId();
        will(returnValue(investigationId));

        KidGenerator kidGenerator = new KidGenerator(ktcReader,
            investigationTypeListFactory, investigationsReader,
            investigationsWriter, investigationsReportWriter, kidRules);
        Pair<File, File> actualKidFileReportFile = kidGenerator.generateKidFileReportFilePair(
            ktcFile, baseInvestigationsFile);

        Pair<File, File> expectedKidFileReportFile = Pair.of(kidFile,
            reportFile);

        assertEquals(expectedKidFileReportFile, actualKidFileReportFile);
    }

}
