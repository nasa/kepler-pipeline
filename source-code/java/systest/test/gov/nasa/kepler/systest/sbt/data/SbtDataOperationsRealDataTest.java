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

package gov.nasa.kepler.systest.sbt.data;

import static com.google.common.collect.Sets.newHashSet;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.BlobSeriesType;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.io.PrintStream;
import java.util.List;
import java.util.Set;

import javax.activation.DataHandler;
import javax.activation.FileDataSource;
import javax.mail.Address;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.Multipart;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;

import junit.framework.JUnit4TestAdapter;
import junit.textui.TestRunner;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

public class SbtDataOperationsRealDataTest {

    private static final Log log = LogFactory.getLog(SbtDataOperationsRealDataTest.class);

    private static final String CONFIG_PATH = "/path/to/test.properties";

    @Before
    public void setUp() {
        System.setProperty(
            ConfigurationServiceFactory.CONFIG_SERVICE_PROPERTIES_PATH_PROP,
            CONFIG_PATH);
    }

    @Test
    public void testSbtDataForHatP7b() {
        SbtData sbtData = retrieveAllLongCadenceSbtData(10666592);

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        parameters.setConfirmedPlanet(true);
        assertEquals("", sbtData.toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataForHatP11() {
        SbtData sbtData = retrieveAllLongCadenceSbtData(10748390);

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        parameters.setConfirmedPlanet(true);
        assertEquals("", sbtData.toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataForTres2() {
        SbtData sbtData = retrieveAllLongCadenceSbtData(11446443);

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        parameters.setConfirmedPlanet(true);
        assertEquals("", sbtData.toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataForKepler4b() {
        SbtData sbtData = retrieveAllLongCadenceSbtData(11853905);

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        parameters.setConfirmedPlanet(true);
        assertEquals("", sbtData.toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataForKepler5b() {
        SbtData sbtData = retrieveAllLongCadenceSbtData(8191672);

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        parameters.setConfirmedPlanet(true);
        assertEquals("", sbtData.toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataForKepler6b() {
        SbtData sbtData = retrieveAllLongCadenceSbtData(9110357);

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        parameters.setConfirmedPlanet(true);
        assertEquals("", sbtData.toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataForKepler7b() {
        SbtData sbtData = retrieveAllLongCadenceSbtData(5780885);

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        parameters.setConfirmedPlanet(true);
        assertEquals("", sbtData.toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataForKepler8b() {
        SbtData sbtData = retrieveAllLongCadenceSbtData(6922244);

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        parameters.setConfirmedPlanet(true);
        assertEquals("", sbtData.toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataForKepler9b() {
        SbtData sbtData = retrieveAllLongCadenceSbtData(3323887);

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        parameters.setConfirmedPlanet(true);
        assertEquals("", sbtData.toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataForKepler10b() {
        SbtData sbtData = retrieveAllLongCadenceSbtData(11904151);

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        parameters.setConfirmedPlanet(true);
        assertEquals("", sbtData.toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataForKepler11b() {
        SbtData sbtData = retrieveAllLongCadenceSbtData(6541920);

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        parameters.setConfirmedPlanet(true);
        assertEquals("", sbtData.toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataForRandomKeplerIdsOnTheFov() {
        for (int runNumber = 0; runNumber < 10; runNumber++) {
            CadenceType cadenceType = CadenceType.LONG;

            TargetCrud targetCrud = new TargetCrud();
            List<TargetTableLog> targetTableLogs = targetCrud.retrieveTargetTableLogs(
                TargetType.valueOf(cadenceType), 0, 100000);
            int targetTableLogIndex = (int) (Math.random() * targetTableLogs.size());
            TargetTableLog targetTableLog = targetTableLogs.get(targetTableLogIndex);

            int channelNumber = (int) (Math.random() * FcConstants.MODULE_OUTPUTS) + 1;
            Pair<Integer, Integer> moduleOutput = FcConstants.getModuleOutput(channelNumber);

            List<TargetDefinition> targetDefs = targetCrud.retrieveTargetDefinitions(
                targetTableLog.getTargetTable(), moduleOutput.left,
                moduleOutput.right);
            int targetDefIndex = (int) (Math.random() * targetDefs.size());
            TargetDefinition targetDef = targetDefs.get(targetDefIndex);
            int keplerId = targetDef.getKeplerId();

            StringBuilder methodCall = new StringBuilder();
            methodCall.append("retrieveAllLongCadenceSbtData(")
                .append(keplerId)
                .append(");");

            try {
                log.info("Executing: " + methodCall);
                SbtData sbtData = retrieveAllLongCadenceSbtData(keplerId);

                ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
                parameters.setCustomTarget(TargetManagementConstants.isCustomTarget(keplerId));
                Assert.assertEquals("Results for testing: " + methodCall, "",
                    sbtData.toMissingDataString(parameters));
            } catch (Throwable e) {
                throw new IllegalArgumentException("Unable to execute: "
                    + methodCall, e);
            }
        }
    }

    @Test(expected = IllegalArgumentException.class)
    public void testSbtDataForNegativeKeplerId() {
        retrieveAllLongCadenceSbtData(-2);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testSbtDataForKeplerIdOffOfFov() {
        retrieveAllLongCadenceSbtData(299);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testSbtDataForNegativeStartCadence() {
        retrieveSbtData(10666592, CadenceType.LONG, -1, 3000,
            new PixelCoordinateSystemConverterToZeroBased());
    }

    @Test(expected = IllegalArgumentException.class)
    public void testSbtDataForEndCadenceBeforeStartCadence() {
        retrieveSbtData(10666592, CadenceType.LONG, 4000, 3000,
            new PixelCoordinateSystemConverterToZeroBased());
    }

    @Test(expected = IllegalArgumentException.class)
    public void testSbtDataForMissingStartCadence() {
        retrieveSbtData(10666592, CadenceType.LONG, 1, 3000,
            new PixelCoordinateSystemConverterToZeroBased());
    }

    @Test(expected = IllegalArgumentException.class)
    public void testSbtDataForMissingEndCadence() {
        retrieveSbtData(10666592, CadenceType.LONG, 3000, 100000,
            new PixelCoordinateSystemConverterToZeroBased());
    }

    @Test
    public void testSbtDataWithNoTpsResults() {
        SbtData sbtData = retrieveAllLongCadenceSbtData(5545104);

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        assertEquals("", sbtData.toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataWithNoDvResults() {
        SbtData sbtData = retrieveAllLongCadenceSbtData(1161432);

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        assertEquals("", sbtData.toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataForCustomTarget() {
        SbtData sbtData = retrieveAllLongCadenceSbtData(100000892);

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        parameters.setCustomTarget(true);
        assertEquals("", sbtData.toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataForShortCadence() {
        SbtData sbtData = retrieveSbtData(9143749, CadenceType.SHORT, 345880,
            345980, new PixelCoordinateSystemConverterToOneBased());

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        parameters.setShortCadence(true);
        assertEquals("", sbtData.toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataWithSkippedQuarter() {
        SbtData sbtData = retrieveAllLongCadenceSbtData(3440230);

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        assertEquals("", sbtData.toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataWithNoTargetTable() {
        SbtData sbtData = retrieveAllLongCadenceSbtData(11962664);

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        assertTrue(!sbtData.toMissingDataString(parameters)
            .isEmpty());
    }

    @Test
    public void testSbtDataWithBadPixels() {
        SbtData sbtData = retrieveSbtData(7255398, CadenceType.LONG, 3095,
            3105, new PixelCoordinateSystemConverterToZeroBased());

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        assertEquals("", new SbtList(sbtData.getTargets()
            .get(0)
            .getTargetTables()
            .get(0)
            .getPixels()
            .get(0)
            .getBadPixelIntervals()).toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataWithCalTargetMetricTimeSeries() {
        SbtData sbtData = retrieveSbtData(100001048, CadenceType.LONG, 1245,
            1255, new PixelCoordinateSystemConverterToZeroBased());

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        parameters.setCustomTarget(true);
        assertEquals("", new SbtGapIndicators(sbtData.getTargets()
            .get(0)
            .getTargetTables()
            .get(0)
            .getCalMetricTimeSeriesList()
            .get(1)
            .getTimeSeries()
            .getGapIndicators()).toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataWithDataAnomalyFlags() {
        SbtData sbtData = retrieveSbtData(9143749, CadenceType.LONG, 7591,
            7601, new PixelCoordinateSystemConverterToOneBased());

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        assertEquals(
            "",
            new SbtDataAnomalyFlags(sbtData.getCadenceTimes().dataAnomalyFlags).toMissingDataString(parameters));
        assertEquals(
            "",
            new SbtDataAnomalyFlags(sbtData.getTargetTables()
                .get(0)
                .getCadenceTimes().dataAnomalyFlags).toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataWithCalCosmicRayMetricTimeSeries() {
        SbtData sbtData = retrieveSbtData(4768677, CadenceType.SHORT, 98404,
            98414, new PixelCoordinateSystemConverterToOneBased());

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        assertEquals("", new SbtGapIndicators(sbtData.getTargetTables()
            .get(0)
            .getModOuts()
            .get(0)
            .getCalCosmicRayMetricTimeSeriesLists()
            .get(0)
            .getTimeSeriesList()
            .get(0)
            .getTimeSeries()
            .getGapIndicators()).toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataWithPaCosmicRayMetricTimeSeries() {
        SbtData sbtData = retrieveSbtData(9143749, CadenceType.LONG, 7404,
            7414, new PixelCoordinateSystemConverterToOneBased());

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        assertEquals("", new SbtGapIndicators(sbtData.getTargetTables()
            .get(0)
            .getModOuts()
            .get(0)
            .getPaCosmicRayMetricTimeSeriesLists()
            .get(0)
            .getTimeSeriesList()
            .get(0)
            .getTimeSeries()
            .getGapIndicators()).toMissingDataString(parameters));

    }

    @Test
    public void testSbtDataWithSingleEventStatistics() {
        SbtData sbtData = retrieveSbtData(8120608, CadenceType.LONG, 7475,
            7485, new PixelCoordinateSystemConverterToZeroBased());

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        assertEquals("", new SbtList(sbtData.getTargets()
            .get(0)
            .getFluxGroups()
            .get(0)
            .getDvResults()
            .getSingleEventStatistics()
            .get(0)
            .getTimeSeriesList()).toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataWithAncillaryData() {
        SbtData sbtData = retrieveSbtData(9143749, CadenceType.LONG, 7591,
            7601, new PixelCoordinateSystemConverterToOneBased());

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        assertEquals(
            "",
            new SbtList(
                SbtDataContainerListFactory.getInstance(sbtData.getAncillaryData()
                    .get(2)
                    .getAncillaryEngineeringGroups()
                    .get(0)
                    .getAncillaryEngineeringDataStruct()
                    .get(0)
                    .getValues())).toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataWithBootstrapHistogram() {
        SbtData sbtData = retrieveSbtData(10801794, CadenceType.LONG, 7591,
            7601, new PixelCoordinateSystemConverterToOneBased());

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        assertEquals("", sbtData.getTargets()
            .get(0)
            .getFluxGroups()
            .get(0)
            .getDvResults()
            .getPlanetResults()
            .get(0)
            .getPlanetCandidate()
            .getBootstrapHistogram()
            .toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataWithCorrectedFluxOutliers() {
        SbtData sbtData = retrieveSbtData(9143749, CadenceType.LONG, 3752,
            3762, new PixelCoordinateSystemConverterToOneBased());

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        assertEquals(
            "",
            new SbtList(
                SbtDataContainerListFactory.getInstance(sbtData.getTargets()
                    .get(0)
                    .getFluxGroups()
                    .get(0)
                    .getCorrectedFluxTimeSeriesList()
                    .get(0)
                    .getOutliers()
                    .getIndices())).toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataWithDiscontinuityIndices() {
        SbtData sbtData = retrieveSbtData(10220756, CadenceType.LONG, 928, 938,
            new PixelCoordinateSystemConverterToOneBased());

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        assertEquals(
            "",
            new SbtList(
                SbtDataContainerListFactory.getInstance(sbtData.getTargets()
                    .get(0)
                    .getFluxGroups()
                    .get(0)
                    .getDiscontinuityIndices())).toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataWithArgabrighteningIndices() {
        SbtData sbtData = retrieveSbtData(7697396, CadenceType.LONG, 7591,
            7601, new PixelCoordinateSystemConverterToOneBased());

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        assertEquals(
            "",
            new SbtList(
                SbtDataContainerListFactory.getInstance(sbtData.getTargetTables()
                    .get(0)
                    .getModOuts()
                    .get(0)
                    .getArgabrighteningIndices())).toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataWithPipelineMetadata() {
        SbtData sbtData = retrieveSbtData(7697396, CadenceType.LONG, 7591,
            7601, new PixelCoordinateSystemConverterToOneBased());

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        assertEquals("", new SbtList(sbtData.getPipelineMetadata()
            .get(1)
            .getParameterGroups()
            .get(0)
            .getParameterMaps()
            .get(0)
            .getEntries()).toMissingDataString(parameters));
        assertEquals("", new SbtList(sbtData.getPipelineMetadata()
            .get(1)
            .getPipelineInstances()
            .get(0)
            .getPipelineTasks()
            .get(0)
            .getAlerts()).toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataDoesNotHaveSingleTransitFits() {
        // As of release 6.1, the singleTransitFits database table is empty. If
        // that ever changes, then this test should fail. At that point, this
        // test can assert the opposite (i.e. that singleTransitFits is *not*
        // empty).
        SbtData sbtData = retrieveAllLongCadenceSbtData(10666592);

        assertEquals(0, sbtData.getTargets()
            .get(0)
            .getFluxGroups()
            .get(0)
            .getDvResults()
            .getPlanetResults()
            .get(0)
            .getSingleTransitFits()
            .size());
    }

    @Test
    public void testSbtDataWithPixelCosmicRayEvent() {
        SbtData sbtData = retrieveSbtData(3230050, CadenceType.LONG, 3768,
            3778, new PixelCoordinateSystemConverterToOneBased());

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        assertEquals(
            "",
            new SbtList(
                SbtDataContainerListFactory.getInstance(sbtData.getTargets()
                    .get(0)
                    .getTargetTables()
                    .get(0)
                    .getPixels()
                    .get(0)
                    .getCosmicRayEvents()
                    .getIndices())).toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataWithPmdCdppTimeSeries() {
        SbtData sbtData = retrieveSbtData(3230050, CadenceType.LONG, 3768,
            3778, new PixelCoordinateSystemConverterToOneBased());

        ToMissingDataStringParameters parameters = new ToMissingDataStringParameters();
        assertEquals("", new SbtList(sbtData.getTargetTables()
            .get(0)
            .getModOuts()
            .get(0)
            .getPmdCdppTimeSeriesLists()).toMissingDataString(parameters));
    }

    @Test
    public void testSbtDataWithRetrieveBackgroundBlobsOnly() {
        List<Integer> keplerIds = ImmutableList.of(1296779);

        List<PipelineProduct> pipelineProductIncludeList = ImmutableList.of(PipelineProduct.BACKGROUND_BLOBS);

        List<PipelineProduct> pipelineProductExcludeList = ImmutableList.of();

        SbtDataOperations sbtOperations = new SbtDataOperations();
        SbtData sbtData = sbtOperations.retrieveSbtData(keplerIds,
            CadenceType.LONG, 16373, 21006,
            new PixelCoordinateSystemConverterToOneBased(),
            new PipelineProductLists(pipelineProductIncludeList,
                pipelineProductExcludeList));

        assertEquals(BlobSeriesType.BACKGROUND.toString(),
            sbtData.getTargetTables()
                .get(0)
                .getModOuts()
                .get(0)
                .getBlobGroups()
                .get(0)
                .getBlobType());
    }

    private SbtData retrieveAllLongCadenceSbtData(int keplerId) {
        CadenceType cadenceType = CadenceType.LONG;

        TargetCrud targetCrud = new TargetCrud();
        List<TargetTableLog> targetTableLogs = targetCrud.retrieveTargetTableLogs(
            TargetType.valueOf(cadenceType), 0, 100000);

        // processedTargetTableIds are targetTables that have been processed by
        // pa, and therefore have argabrightening indices.
        Set<FsId> fsIds = FileStoreClientFactory.getInstance()
            .queryPaths("TimeSeries@/pa/targets/Argabrightening/long/*");
        Set<Integer> processedTargetTableIds = newHashSet();
        for (FsId fsId : fsIds) {
            String[] strings = fsId.toString()
                .split("/");
            for (String string : strings) {
                try {
                    int value = Integer.parseInt(string);
                    processedTargetTableIds.add(value);
                } catch (NumberFormatException e) {
                    // If the string is not parseable, then it is not a tableId.
                }
            }
        }

        int startCadence = -1;
        int endCadence = -1;
        for (TargetTableLog targetTableLog : targetTableLogs) {
            if (processedTargetTableIds.contains(targetTableLog.getTargetTable()
                .getExternalId())) {
                if (startCadence == -1) {
                    startCadence = targetTableLog.getCadenceStart();
                }

                endCadence = targetTableLog.getCadenceEnd();
            }
        }

        return retrieveSbtData(keplerId, cadenceType, startCadence, endCadence,
            new PixelCoordinateSystemConverterToZeroBased());
    }

    private SbtData retrieveSbtData(int keplerId, CadenceType cadenceType,
        int startCadence, int endCadence,
        PixelCoordinateSystemConverter pixelCoordinateSystemConverter) {
        List<Integer> keplerIds = ImmutableList.of(keplerId);

        SbtDataOperations sbtOperations = new SbtDataOperations();
        SbtData sbtData = sbtOperations.retrieveSbtData(keplerIds, cadenceType,
            startCadence, endCadence, pixelCoordinateSystemConverter,
            new PipelineProductLists());

        return sbtData;
    }

    public static void main(String[] args) throws Exception {
        File file = new File(
            SbtDataOperationsRealDataTest.class.getSimpleName() + "Results.txt");

        TestRunner testRunner = new TestRunner(new PrintStream(file));
        testRunner.doRun(new JUnit4TestAdapter(
            SbtDataOperationsRealDataTest.class));

        mailReport(file);

        file.delete();
        Assert.assertTrue(!file.exists());
    }

    private static void mailReport(File file) throws Exception {
        // Create a mail session
        java.util.Properties props = new java.util.Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        Session session = Session.getDefaultInstance(props,
            new Authenticator() {
                @Override
                public PasswordAuthentication getPasswordAuthentication() {
                    String username = "user@gmail.com";
                    String password = "password";
                    return new PasswordAuthentication(username, password);
                }
            });

        // Construct the message
        Message msg = new MimeMessage(session);
        msg.setFrom(new InternetAddress("user@gmail.com"));
        Address[] addresses = new Address[] { new InternetAddress(
            "user@nasa.gov") };
        msg.addRecipients(Message.RecipientType.TO, addresses);
        msg.setSubject(file.getName());

        // Part one is text.
        MimeBodyPart part1 = new MimeBodyPart();
        part1.setText("See attached.");

        // Part two is attachment.
        MimeBodyPart part2 = new MimeBodyPart();
        part2.setDataHandler(new DataHandler(new FileDataSource(file)));
        part2.setFileName(file.getName());

        Multipart multipart = new MimeMultipart();
        multipart.addBodyPart(part1);
        multipart.addBodyPart(part2);

        msg.setContent(multipart);

        // Send the message
        Transport.send(msg);
    }

}
