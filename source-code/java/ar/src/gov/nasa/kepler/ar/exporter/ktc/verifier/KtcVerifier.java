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

package gov.nasa.kepler.ar.exporter.ktc.verifier;

import gnu.trove.TIntObjectHashMap;
import gnu.trove.TIntObjectProcedure;
import gov.nasa.kepler.ar.exporter.FileNameFormatter;
import gov.nasa.kepler.ar.exporter.ktc.InvestigationBase;
import gov.nasa.kepler.ar.xmlbean.ExpectedTargetListXB;
import gov.nasa.kepler.ar.xmlbean.ExpectedTargetTableInformationXB;
import gov.nasa.kepler.ar.xmlbean.KtcVerifierInfoDocument;
import gov.nasa.kepler.cm.TargetListImporter;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.intervals.DoubleIntervalSet;
import gov.nasa.kepler.common.intervals.SimpleDoubleInterval;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.regex.Pattern;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xmlbeans.XmlException;
import org.apache.xmlbeans.XmlOptions;

/**
 * Check that all the planetary kepler ids are in the KTC and have the planetary
 * category in the category list.
 * 
 * Every entry has an investigation ID assigned to it. Check times: min actual
 * start max actual start min actual end max actual end min expected start max
 * expected start min expected end max expected end
 * 
 * @author Sean McCauliff
 * 
 */
public class KtcVerifier {

    private static final Log log = LogFactory.getLog(KtcVerifier.class);
    private static final double SHORT_CADENCE_COMES_BEFORE_LONG_CADENCE_DAYS = .00001;
    private static final double DAYS_BETWEEN_TARGET_TABLES = 5.0;
    /**
     * This is the maximum difference in days tolerated. For various reasons
     * like the database storing more precision or it starting at the end of the
     * day rather than the beinning or the database having local time and we are
     * having UTC it never matches exactly.
     */
    private static final double PLANNED_TIME_SLOP = 1.0;

    private boolean minMaxDatesOK = false;
    private boolean investigationIdOK = false;
    private boolean shortCadenceOK = false;
    private boolean planetaryTargetsOK = false;

    private final List<ParsedKtcEntry> ktcEntries;

    private final File dataRepoDir;

    private final ExpectedTargetTableInformationXB[] expectedTtableInfoArray;

    public KtcVerifier(File ktcFile, File dataRepoDir,
        File expectedTargetTableInfoFile) throws IOException, XmlException {

        XmlOptions xmlOptions = new XmlOptions();
        xmlOptions.setLoadLineNumbers();
        List<String> xmlErrors = new ArrayList<String>();
        xmlOptions.setErrorListener(xmlErrors);
        if (xmlErrors.size() != 0) {
            log.error(StringUtils.join(xmlErrors.iterator(), "\n"));
            throw new IllegalStateException("XML exception.");
        }
        KtcVerifierInfoDocument xmlDoc = KtcVerifierInfoDocument.Factory.parse(expectedTargetTableInfoFile);
        xmlDoc.validate(xmlOptions);
        if (xmlErrors.size() != 0) {
            log.error(StringUtils.join(xmlErrors.iterator(), "\n"));
            throw new IllegalStateException("XML exception.");
        }

        expectedTtableInfoArray = xmlDoc.getKtcVerifierInfo()
            .getExpectedTargetTableInfoArray();

        FileNameFormatter fFormatter = new FileNameFormatter();
        fFormatter.parseKtcName(ktcFile.getName());

        this.dataRepoDir = dataRepoDir;

        if (!dataRepoDir.isDirectory() || !dataRepoDir.canRead()) {
            throw new IllegalArgumentException("Bad dataRepo directory \""
                + dataRepoDir + "\".");
        }
        List<ParsedKtcEntry> ktcEntries = new ArrayList<ParsedKtcEntry>();
        BufferedReader breader = null;
        try {
            breader = new BufferedReader(new FileReader(ktcFile));
            for (String line = breader.readLine(); line != null; line = breader.readLine()) {
                if (line.startsWith("#")) {
                    continue;
                }
                ktcEntries.add(ParsedKtcEntry.valueOf(line));
            }
        } finally {
            FileUtil.close(breader);
        }
        this.ktcEntries = Collections.unmodifiableList(ktcEntries);
        log.info("Parsed " + ktcEntries.size() + " KTC entries from \""
            + ktcFile + "\".");
    }

    public void verify(Date startUtc, Date endUtc, File dataRepoDir)
        throws IOException {
        verifyMinMaxDates(startUtc, endUtc);
        investigationIdVerify();
        everyShortCadenceHasALongCadence();
        verifyTargetLists(startUtc, endUtc);

        if (minMaxDatesOK && investigationIdOK && planetaryTargetsOK
            && shortCadenceOK) {
            log.info("All tests passed.");
        } else {
            log.error("One or more tests failed.  Check log for more info.");
        }
    }

    private void everyShortCadenceHasALongCadence() {
        TIntObjectHashMap<List<ParsedKtcEntry>> keplerIdToKtcEntries = new TIntObjectHashMap<List<ParsedKtcEntry>>();

        List<ParsedKtcEntry> shortCadenceEntries = new ArrayList<ParsedKtcEntry>();
        for (ParsedKtcEntry entry : ktcEntries) {
            List<ParsedKtcEntry> entryList = keplerIdToKtcEntries.get(entry.keplerId);
            if (entryList == null) {
                entryList = new ArrayList<ParsedKtcEntry>();
                keplerIdToKtcEntries.put(entry.keplerId, entryList);
            }
            entryList.add(entry);
            if (entry.cadenceType == CadenceType.SHORT) {
                shortCadenceEntries.add(entry);
            }
        }

        boolean verificationOK = true;

        for (ParsedKtcEntry shortCadenceEntry : shortCadenceEntries) {
            List<ParsedKtcEntry> allEntries = keplerIdToKtcEntries.get(shortCadenceEntry.keplerId);
            if (allEntries == null || allEntries.size() == 0) {
                verificationOK = false;
                log.info("Short cadence KTC entry missing companion long"
                    + " cadence entry " + shortCadenceEntry);
                continue;
            }

            if (shortCadenceEntry.actualStartMjd() != null) {
                // Allow a break of up to and including two days.
                DoubleIntervalSet<SimpleDoubleInterval> longCadenceActuals = new DoubleIntervalSet<SimpleDoubleInterval>(
                    DAYS_BETWEEN_TARGET_TABLES);
                for (ParsedKtcEntry lcEntry : allEntries) {
                    if (lcEntry.cadenceType == CadenceType.SHORT) {
                        continue; // NOT LC
                    }
                    if (lcEntry.actualStartMjd() == null) {
                        continue;
                    }

                    longCadenceActuals.mergeInterval(new SimpleDoubleInterval(
                        lcEntry.actualStartMjd(), lcEntry.actualEndMjd()));
                }

                List<SimpleDoubleInterval> spannedLongCadence = longCadenceActuals.spannedIntervals(
                    new SimpleDoubleInterval(shortCadenceEntry.actualStartMjd,
                        shortCadenceEntry.actualEndMjd), true);
                boolean foundCompanionLC = true;
                if (spannedLongCadence.size() == 1) {
                    SimpleDoubleInterval lcInterval = spannedLongCadence.get(0);
                    if (lcInterval.start()
                        - SHORT_CADENCE_COMES_BEFORE_LONG_CADENCE_DAYS > shortCadenceEntry.actualStartMjd
                        || lcInterval.end() < shortCadenceEntry.actualEndMjd) {
                        foundCompanionLC = false;
                    }
                } else {
                    foundCompanionLC = false;
                }

                if (!foundCompanionLC) {
                    verificationOK = false;
                    log.info("Short cadence KTC entry missing companion long "
                        + "cadence entry " + shortCadenceEntry);
                }
            }

        }

        if (verificationOK) {
            log.info("Short cadence has long cadence OK");
        } else {
            log.info("Short cadence has long cadence FAILED.");
        }
        shortCadenceOK = verificationOK;
    }

    private void verifyMinMaxDates(Date startUtc, Date endUtc) {

        List<ExpectedTargetTableInformationAdapter> expectedList = new ArrayList<ExpectedTargetTableInformationAdapter>();
        for (ExpectedTargetTableInformationXB expected : expectedTargetTables(
            startUtc, endUtc)) {
            expectedList.add(new ExpectedTargetTableInformationAdapter(expected));
        }
        double ktcCliStartMjd = ModifiedJulianDate.dateToMjd(startUtc);
        double ktcCliEndMjd = ModifiedJulianDate.dateToMjd(endUtc);

        MinMaxTimes minMaxTimes = MinMaxTimes.create(ktcEntries);
        MinMaxTimes expectedMinMaxTimes = MinMaxTimes.create(expectedList);

        log.debug("Times found\n" + minMaxTimes);
        log.debug("Expected times\n" + expectedMinMaxTimes);

        boolean foundError = false;
        if (minMaxTimes.minPlannedStart() < ktcCliStartMjd) {
            log.error("Minimum expected start date "
                + minMaxTimes.minPlannedStart()
                + " mjd in KTC comes before command line start date "
                + ktcCliStartMjd + " mjd.");
            foundError = true;
        }
        if (minMaxTimes.maxPlannedEnd() > ktcCliEndMjd) {
            log.error("Maximum expected end date "
                + minMaxTimes.maxPlannedEnd()
                + " mjd comes after the command line end date " + ktcCliEndMjd
                + " mjd.");
            foundError = true;
        }

        if (minMaxTimes.minPlannedStart() > minMaxTimes.maxPlannedEnd()) {
            log.error("Minimum expected start comes before max expected end.");
            foundError = true;
        }
        if (minMaxTimes.minActualStart() > minMaxTimes.maxActualEnd()) {
            log.error("Minimum actual start comes after max actual end.\n  minActualStart: "
                + minMaxTimes.minActualStart()
                + "\n  maxActualEnd: "
                + minMaxTimes.maxActualEnd());
            foundError = true;
        }

        String minMaxDiff = MinMaxTimes.diff(expectedMinMaxTimes, "expected",
            minMaxTimes, "KTC", PLANNED_TIME_SLOP);
        if (minMaxDiff.length() > 0) {
            log.info("Expected min/max times do not match actual.\n"
                + minMaxDiff);
            foundError = true;
        }

        if (foundError) {
            log.info("Min/max timestamps FAILED.");
        } else {
            log.info("Min/max timestamps OK.");
        }
        minMaxDatesOK = !foundError;

    }

    private List<ExpectedTargetTableInformationXB> expectedTargetTables(
        Date startUtc, Date endUtc) {
        List<ExpectedTargetTableInformationXB> expected = new ArrayList<ExpectedTargetTableInformationXB>();
        for (ExpectedTargetTableInformationXB xinfo : expectedTtableInfoArray) {
            Date plannedStart = xinfo.getPlannedStart()
                .getTime();
            Date plannedEnd = xinfo.getPlannedEnd()
                .getTime();

            if ((plannedStart.equals(startUtc) || plannedStart.after(startUtc))
                && (plannedEnd.equals(endUtc) || plannedEnd.before(endUtc))) {
                expected.add(xinfo);
            }
        }

        return expected;
    }

    public void investigationIdVerify() {
        Pattern goPattern = Pattern.compile("GO\\d+");
        boolean foundError = false;
        for (ParsedKtcEntry e : ktcEntries) {
            if (e.investigationId == null || e.investigationId.length() == 0) {
                log.error("KTC entry \"" + e
                    + "\" does not have an investigation ID.");
                foundError = true;
                continue;
            }
            String[] idParts = e.investigationId.split("_");
            for (String part : idParts) {
                try {
                    InvestigationBase base = InvestigationBase.valueOf(part);
                    if (base == InvestigationBase.GO) {
                        log.error("Bad investigation " + base);
                        foundError = true;
                    }
                } catch (IllegalArgumentException x) {
                    if (!goPattern.matcher(part)
                        .matches()) {
                        log.error("Bad investigation \"" + part + "\".");
                        foundError = true;
                    }
                }
            }
        }

        if (foundError) {
            log.info("Investigation ids FAILED.");
        } else {
            log.info("Investigation ids OK.");
        }
        investigationIdOK = !foundError;

    }

    private void verifyTargetLists(Date startUtc, Date endUtc)
        throws IOException {
        TIntObjectHashMap<Set<String>> keplerIdsToCategories = new TIntObjectHashMap<Set<String>>();
        for (ExpectedTargetTableInformationXB expectedTtableInfo : expectedTargetTables(
            startUtc, endUtc)) {
            List<File> targetListFiles = new ArrayList<File>();
            for (ExpectedTargetListXB expectedTargetList : expectedTtableInfo.getTargetListArray()) {
                targetListFiles.add(new File(this.dataRepoDir + "/"
                    + expectedTargetList.getFileName()));
            }
            loadTargetLists(targetListFiles, keplerIdsToCategories);
        }

        // Check that every kepler id exists in the KTC and has the correct
        // categories
        final TIntObjectHashMap<Set<String>> keplerIdToKtcCategories = new TIntObjectHashMap<Set<String>>();
        for (ParsedKtcEntry ktcEntry : this.ktcEntries) {
            Set<String> ktcCategoriesForKeplerId = keplerIdToKtcCategories.get(ktcEntry.keplerId);
            if (ktcCategoriesForKeplerId == null) {
                ktcCategoriesForKeplerId = new HashSet<String>();
                keplerIdToKtcCategories.put(ktcEntry.keplerId,
                    ktcCategoriesForKeplerId);
            }
            ktcCategoriesForKeplerId.addAll(ktcEntry.categories);
        }

        final AtomicBoolean notFound = new AtomicBoolean();
        keplerIdsToCategories.forEachEntry(new TIntObjectProcedure<Set<String>>() {

            @Override
            public boolean execute(int keplerId, Set<String> categories) {
                Set<String> ktcCategories = keplerIdToKtcCategories.get(keplerId);
                if (ktcCategories == null) {
                    log.info(keplerId + " is not present in the KTC.");
                    notFound.set(true);
                    return true;
                }
                // I still don't know why there is not a isSubset method.
                for (String expectedCategory : categories) {
                    if (!ktcCategories.contains(expectedCategory)) {
                        notFound.set(true);
                        log.info(keplerId + " is missing category \""
                            + expectedCategory + "\".");
                    }
                }
                return true;
            }
        });

        String okString = (notFound.get()) ? "FAILED" : "OK";
        log.info("Verify target lists " + okString + ".");
        this.planetaryTargetsOK = !notFound.get();
    }

    private void loadTargetLists(List<File> listsToLoad,
        TIntObjectHashMap<Set<String>> keplerIdsToCategories)
        throws IOException {

        for (File targetListFile : listsToLoad) {
            loadList(targetListFile, keplerIdsToCategories);
        }
    }

    private void loadList(File targetListFile,
        TIntObjectHashMap<Set<String>> keplerIdsToCategories)
        throws IOException {
        
        TargetListImporter targetListImporter = new TargetListImporter();
        Set<Integer> keplerIds = targetListImporter.keplerIdsFromFile(targetListFile.getAbsolutePath());
        String targetCategory = targetListImporter.getCategory();
        if (targetCategory == null) {
            throw new IllegalStateException("Bad target list file \""
                + targetListFile + "\": missing target category.");
        }
        for (Integer keplerId : keplerIds) {
            Set<String> categorySet = keplerIdsToCategories.get(keplerId);
            if (categorySet == null) {
                categorySet = new HashSet<String>();
                keplerIdsToCategories.put(keplerId, categorySet);
            }
            categorySet.add(targetCategory);
        }
    }

}
