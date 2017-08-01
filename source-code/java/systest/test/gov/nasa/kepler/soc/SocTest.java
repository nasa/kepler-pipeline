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

package gov.nasa.kepler.soc;

import static com.google.common.collect.Lists.newArrayList;
import static gov.nasa.kepler.mc.file.FileAssert.assertEquals;
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.common.FitsDiff;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.fs.api.FileStoreTestInterface;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.List;

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class SocTest {

    private String importDirectoryRoot = SocEnvVars.getLocalTestDataDir()
        + "/dr/";
    private String importDirectoryQ6 = importDirectoryRoot + "q6";
    private String exportDirectory = Filenames.BUILD_TMP;

    @BeforeClass
    public static void setUpBeforeClass() {
        DefaultProperties.setPropsForUnitTest();
    }

    @Before
    public void setUp() throws Exception {
        TestUtils.setUpDatabase(DatabaseServiceFactory.getInstance());
        ((FileStoreTestInterface) FileStoreClientFactory.getInstance()).cleanFileStore();
    }

    @Test
    public void testImportExportPixels() throws Exception {
        testImportExportRequant("kplr2011269071154-206_rq.xml", "206");

        testImportExportMasks("kplr2011269071153-206_tad.xml", "206", "tad");
        testImportExportMasks("kplr2011269071153-206_bad.xml", "206", "bad");

        testImportExportTargets("kplr2011269071153-206_lct.xml", "206", "lct",
            "206", "tad");
        testImportExportTargets("kplr2011269071153-206_sct.xml", "206", "sct",
            "206", "tad");
        testImportExportTargets("kplr2011269071153-206_rpt.xml", "206", "rpt",
            "206", "tad");
        testImportExportTargets("kplr2011269071153-206_bgp.xml", "206", "bgp",
            "206", "bad");

        testImportExportPmrf("kplr2006265000000-206-206_lcm.fits", "206",
            "LONG_CADENCE_TARGET");
        testImportExportPmrf("kplr2006265000000-206-206_lcc.fits", "206",
            "LONG_CADENCE_COLLATERAL");
        testImportExportPmrf("kplr2006265000000-206-206_bgm.fits", "206",
            "BACKGROUND");
        testImportExportPmrf("kplr2006265000000-206-206_scm.fits", "206",
            "SHORT_CADENCE_TARGET");
        testImportExportPmrf("kplr2006265000000-206-206_scc.fits", "206",
            "SHORT_CADENCE_COLLATERAL");

        testImportExportPixels("kplr2010175123346_lcs-targ.fits", "LONG",
            "Target", "20579");
        testImportExportPixels("kplr2010175123346_lcs-col.fits", "LONG",
            "Collateral", "20579");
        testImportExportPixels("kplr2010175123346_lcs-bkg.fits", "LONG",
            "Background", "20579");
        testImportExportPixels("kplr2010175120519_scs-targ.fits", "SHORT",
            "Target", "617370");
        testImportExportPixels("kplr2010175120519_scs-col.fits", "SHORT",
            "Collateral", "617370");
    }

    @Test
    public void testImportExportRclcPixels() throws Exception {
        testImportExportRequant("kplr2010054165357-202_rq.xml", "202");

        testImportExportMasks("kplr2009009144314-007_tad.xml", "7", "tad");
        testImportExportMasks("kplr2009009144314-007_bad.xml", "7", "bad");

        testImportExportTargets("kplr2009009144314-007_lct.xml", "7", "lct",
            "7", "tad");
        testImportExportTargets("kplr2009009144314-007_bgp.xml", "7", "bgp",
            "7", "bad");

        testImportExportPmrf("kplr2009009144314-007-007_lcm.fits", "7",
            "LONG_CADENCE_TARGET");
        testImportExportPmrf("kplr2009009144314-000-000_lcc.fits", "7",
            "LONG_CADENCE_COLLATERAL");
        testImportExportPmrf("kplr2009009144314-007-007_bgm.fits", "7",
            "BACKGROUND");

        testImportExportRclcPixels("kplr2010203185452_lcs-targ.fits", "LONG",
            "Target", "22431");
        testImportExportRclcPixels("kplr2010203185452_lcs-col.fits", "LONG",
            "Collateral", "22431");
        testImportExportRclcPixels("kplr2010203185452_lcs-bkg.fits", "LONG",
            "Background", "22431");
    }

    private void testImportExportRequant(String fileName, String externalId) {
        Soc.importRequant(importDirectoryQ6, fileName);

        Soc.exportRequant(externalId, exportDirectory, fileName);

        assertEquals(new File(importDirectoryQ6, fileName), new File(
            exportDirectory, fileName));
    }

    private void testImportExportMasks(String fileName, String externalId,
        String maskType) {
        Soc.importMasks(importDirectoryQ6, fileName);

        Soc.exportMasks(externalId, maskType, exportDirectory, fileName);

        assertEquals(new File(importDirectoryQ6, fileName), new File(
            exportDirectory, fileName));
    }

    private void testImportExportTargets(String fileName,
        String targetExternalId, String targetType, String maskExternalId,
        String maskType) {
        Soc.importTargets(importDirectoryQ6, fileName, maskExternalId, maskType);

        Soc.exportTargets(targetExternalId, targetType, exportDirectory,
            fileName);

        assertEquals(new File(importDirectoryQ6, fileName), new File(
            exportDirectory, fileName));
    }

    private void testImportExportPmrf(String fileName, String externalId,
        String pmrfType) throws Exception {
        Soc.importPmrf(importDirectoryQ6, fileName);

        Soc.exportPmrf(externalId, pmrfType, exportDirectory, fileName);

        List<String> diffs = newArrayList();
        new FitsDiff().diff(new File(importDirectoryQ6, fileName), new File(
            exportDirectory, fileName), diffs);

        List<String> expectedDiffs = ImmutableList.of();
        assertEquals(expectedDiffs, diffs);
    }

    private void testImportExportPixels(String fileName, String cadenceType,
        String dataSetType, String cadenceNumber) throws Exception {
        Soc.importPixels(importDirectoryQ6, fileName);

        Soc.exportPixels(exportDirectory, fileName, cadenceType, dataSetType,
            cadenceNumber);

        List<String> diffs = newArrayList();
        new FitsDiff().diff(new File(importDirectoryQ6, fileName), new File(
            exportDirectory, fileName), diffs);

        List<String> expectedDiffs = ImmutableList.of();
        assertEquals(expectedDiffs, diffs);
    }

    private void testImportExportRclcPixels(String fileName,
        String cadenceType, String dataSetType, String cadenceNumber)
        throws Exception {
        Soc.importRclcPixels(importDirectoryQ6, fileName);

        Soc.exportRclcPixels(exportDirectory, fileName, cadenceType,
            dataSetType, cadenceNumber);

        List<String> diffs = newArrayList();
        new FitsDiff().diff(new File(importDirectoryQ6, fileName), new File(
            exportDirectory, fileName), diffs);

        List<String> expectedDiffs = ImmutableList.of();
        assertEquals(expectedDiffs, diffs);
    }

    @Test
    public void testImportExportGapReport() throws Exception {
        testImportExportGapReport("kplr2009198201500_lcs-gaps.xml", "LONG",
            "7300");
        testImportExportGapReport("kplr2009350211500_scs-gaps.xml", "SHORT",
            "87600");
        testImportExportGapReport("kplr2010138001500_lcs-gaps.xml", "LONG",
            "21900");
        testImportExportGapReport("kplr2010290021500_scs-gaps.xml", "SHORT",
            "175200");
        testImportExportGapReport("kplr2011077031500_lcs-gaps.xml", "LONG",
            "36500");
        testImportExportGapReport("kplr2011077034500_lcs-gaps.xml", "LONG",
            "36501");
        testImportExportGapReport("kplr2011077041500_lcs-gaps.xml", "LONG",
            "36502");
        testImportExportGapReport("kplr2011077044500_lcs-gaps.xml", "LONG",
            "36503");
        testImportExportGapReport("kplr2011077051500_lcs-gaps.xml", "LONG",
            "36504");
        testImportExportGapReport("kplr2011229061500_scs-gaps.xml", "SHORT",
            "262800");
        testImportExportGapReport("kplr2012016071500_lcs-gaps.xml", "LONG",
            "51100");
        testImportExportGapReport("kplr2012168101500_scs-gaps.xml", "SHORT",
            "350400");
        testImportExportGapReport("kplr2012320111500_lcs-gaps.xml", "LONG",
            "65700");
        testImportExportGapReport("kplr2013106131500_scs-gaps.xml", "SHORT",
            "438000");
        testImportExportGapReport("kplr2013106132000_scs-gaps.xml", "SHORT",
            "438001");
        testImportExportGapReport("kplr2013106132500_scs-gaps.xml", "SHORT",
            "438002");
        testImportExportGapReport("kplr2013106133000_scs-gaps.xml", "SHORT",
            "438003");
        testImportExportGapReport("kplr2013106133500_scs-gaps.xml", "SHORT",
            "438004");
        testImportExportGapReport("kplr2013258161500_lcs-gaps.xml", "LONG",
            "80300");
        testImportExportGapReport("kplr2014045171500_scs-gaps.xml", "SHORT",
            "525600");
        testImportExportGapReport("kplr2014197201500_lcs-gaps.xml", "LONG",
            "94900");
        testImportExportGapReport("kplr2014349211500_scs-gaps.xml", "SHORT",
            "613200");
        testImportExportGapReport("kplr2015137001500_lcs-gaps.xml", "LONG",
            "109500");
        testImportExportGapReport("kplr2015137004500_lcs-gaps.xml", "LONG",
            "109501");
        testImportExportGapReport("kplr2015137011500_lcs-gaps.xml", "LONG",
            "109502");
        testImportExportGapReport("kplr2015137014500_lcs-gaps.xml", "LONG",
            "109503");
        testImportExportGapReport("kplr2015137021500_lcs-gaps.xml", "LONG",
            "109504");
        testImportExportGapReport("kplr2015289021500_scs-gaps.xml", "SHORT",
            "700800");
        testImportExportGapReport("kplr2016076031500_lcs-gaps.xml", "LONG",
            "124100");
        testImportExportGapReport("kplr2016228061500_scs-gaps.xml", "SHORT",
            "788400");
        testImportExportGapReport("kplr2017014071500_lcs-gaps.xml", "LONG",
            "138700");
        testImportExportGapReport("kplr2017166101500_scs-gaps.xml", "SHORT",
            "876000");
        testImportExportGapReport("kplr2017166102000_scs-gaps.xml", "SHORT",
            "876001");
        testImportExportGapReport("kplr2017166102500_scs-gaps.xml", "SHORT",
            "876002");
        testImportExportGapReport("kplr2017166103000_scs-gaps.xml", "SHORT",
            "876003");
        testImportExportGapReport("kplr2017166103500_scs-gaps.xml", "SHORT",
            "876004");
        testImportExportGapReport("kplr2017318111500_lcs-gaps.xml", "LONG",
            "153300");
        testImportExportGapReport("kplr2018105131500_scs-gaps.xml", "SHORT",
            "963600");
        testImportExportGapReport("kplr2018257161500_lcs-gaps.xml", "LONG",
            "167900");
        testImportExportGapReport("kplr2019044171500_scs-gaps.xml", "SHORT",
            "1051200");
    }

    private void testImportExportGapReport(String fileName, String cadenceType,
        String cadenceNumber) {
        String importDirectory = importDirectoryRoot + "gap-report";

        Soc.importGapReport(importDirectory, fileName);

        Soc.exportGapReport(cadenceType, cadenceNumber, exportDirectory,
            fileName);

        assertEquals(new File(importDirectory, fileName), new File(
            exportDirectory, fileName));
    }

    @Test
    public void testImportExportConfigMap() throws Exception {
        testImportExportConfigMap("kplr2008324080001a_map.xml", "0");
    }

    private void testImportExportConfigMap(String fileName, String scConfigId) {
        String importDirectory = importDirectoryRoot + "config-map";

        Soc.importConfigMap(importDirectory, fileName);

        Soc.exportConfigMap(scConfigId, exportDirectory, fileName);

        assertEquals(new File(importDirectory, fileName), new File(
            exportDirectory, fileName));
    }

    @Test
    public void testImportExportCrct() throws Exception {
        testImportExportCrct("kplr2008347160000_lcs-crct.fits");
    }

    private void testImportExportCrct(String fileName) throws Exception {
        String importDirectory = importDirectoryRoot + "crct";

        Soc.importCrct(importDirectory, fileName);

        Soc.exportCrct(exportDirectory, fileName);

        List<String> diffs = newArrayList();
        new FitsDiff().diff(new File(importDirectory, fileName), new File(
            exportDirectory, fileName), diffs);

        List<String> expectedDiffs = ImmutableList.of();
        assertEquals(expectedDiffs, diffs);
    }

    @Test
    public void testImportExportParameterLibrary() throws Exception {
        testImportExportParameterLibrary("parameter-library.xml");
    }

    private void testImportExportParameterLibrary(String fileName)
        throws Exception {
        String importDirectory = SocEnvVars.getLocalDataDir()
            + "/flight/so/pipeline_parameters/soc";
        Soc.importParameterLibrary(importDirectory, fileName);

        String fileNameForFirstExport = fileName + ".1";
        Soc.exportParameterLibrary(exportDirectory, fileNameForFirstExport);
        removeMetadata(exportDirectory, fileNameForFirstExport);

        Soc.importParameterLibrary(exportDirectory, fileNameForFirstExport);

        String fileNameForSecondExport = fileName + ".2";
        Soc.exportParameterLibrary(exportDirectory, fileNameForSecondExport);
        removeMetadata(exportDirectory, fileNameForSecondExport);

        assertEquals(new File(exportDirectory, fileNameForFirstExport),
            new File(exportDirectory, fileNameForSecondExport));
    }

    private void removeMetadata(String exportDirectory, String fileName)
        throws Exception {
        File file = new File(exportDirectory, fileName);
        File newFile = new File(exportDirectory, fileName + ".new");

        BufferedReader reader = new BufferedReader(new FileReader(file));
        BufferedWriter writer = new BufferedWriter(new FileWriter(newFile));

        reader.readLine();
        writer.write("<par:parameter-library release=\"\" svn-url=\"\" svn-revision=\"\" build-date=\"\" "
            + "database-url=\"\" database-user=\"\" xmlns:par=\"http://kepler.nasa.gov/pi/parameters\">\n");

        for (String line = reader.readLine(); line != null; line = reader.readLine()) {
            writer.write(line + "\n");
        }

        reader.close();
        writer.close();

        newFile.renameTo(file);
    }

}
