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

package gov.nasa.kepler.cm;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.hibernate.cm.Characteristic;
import gov.nasa.kepler.hibernate.cm.CharacteristicType;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.TreeSet;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.PosixParser;
import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * Generates test target management data.
 * <p>
 * The use of the default {@code --target-lists} argument generates two sets of
 * target lists and two sets of GO target lists.
 * <p>
 * The first target list set will contain a long cadence target list with
 * 163,000 targets (to ensure that LC + GO pixel count is small enough), three
 * short cadence lists with ~512 targets and a reference pixel target list with
 * 840 targets. The second set contains a long cadence target list with ~97,000
 * targets, three short cadence lists with ~512 targets which share half of
 * their targets with the previous short cadence lists, and a reference pixel
 * target list with 420 targets which is a subset of the first. An input file
 * with 168,040 long cadence targets and specified on the command line is
 * therefore necessary.
 * <p>
 * The two long cadence GO lists will intersect each other and be disjoint from
 * the other two sets. Each contains 2940 targets. In addition, the two GO sets
 * will contain three short cadence lists with 84 targets each which are all
 * disjoint from any other list.
 * <p>
 * The short cadence, reference pixel, and GO target lists are equally
 * distributed across the focal plane and sorted by magnitude.
 * <p>
 * The use of the {@code --characteristics} argument generates five
 * characteristic types (RANKING-1, RANKING-2, ...) and matching data files
 * consisting of 200,000 entries with random and unique Kepler IDs.
 * 
 * @author Bill Wohler
 */
public class GenerateTestData {

    private static final String CATEGORY_LABEL = "Category:";
    private static final String PLANETARY_CATEGORY = CATEGORY_LABEL
        + " Planetary\n";
    private static final String GO_CATEGORY = CATEGORY_LABEL + " GO\n";
    private static final String RP_CATEGORY = CATEGORY_LABEL
        + " Reference Pixel\n";

    private static final double BUCKET_SIZE_TOLERANCE = 0.66;
    private static final int LC1_TARGET_COUNT = 163000;
    private static final int LC2_TARGET_COUNT = 97000;
    private static final short LC_MIN_MAGNITUDE = 9;
    private static final short LC_MAX_MAGNITUDE = 18;
    private static final short GO_MIN_MAGNITUDE = LC_MIN_MAGNITUDE;
    private static final short GO_MAX_MAGNITUDE = LC_MAX_MAGNITUDE;

    // 24 is fudge factor to make up for light buckets.
    private static final int LC2_BUCKET_SIZE = LC2_TARGET_COUNT
        / FcConstants.MODULE_OUTPUTS + 24;

    private static final int GO_BUCKET_SIZE = 35;
    private static final int GO_SHARED_BUCKET_SIZE = 10;
    private static final int GO_TARGET_COUNT = GO_BUCKET_SIZE
        * FcConstants.MODULE_OUTPUTS;
    private static final int GO_SC_BUCKET_SIZE = 1;
    private static final int GO_TOTAL_TARGET_COUNT = (2 * GO_BUCKET_SIZE - GO_SHARED_BUCKET_SIZE)
        * FcConstants.MODULE_OUTPUTS;

    private static final int SC_BUCKET_SIZE = TargetManagementConstants.MAX_SHORT_CADENCE_TARGET_DEFS
        / FcConstants.MODULE_OUTPUTS - GO_SC_BUCKET_SIZE;
    private static final int SC_SHARED_BUCKET_SIZE = SC_BUCKET_SIZE / 2;
    private static final short SC_MIN_MAGNITUDE = 12;
    private static final short SC_MAX_MAGNITUDE = 18;
    private static final short GO_SC_MIN_MAGNITUDE = SC_MIN_MAGNITUDE;
    private static final short GO_SC_MAX_MAGNITUDE = SC_MAX_MAGNITUDE;

    private static final int RP1_BUCKET_SIZE = 6;
    private static final int RP2_BUCKET_SIZE = RP1_BUCKET_SIZE / 2;
    private static final int RP3_BUCKET_SIZE = 20;
    private static final short RP_MIN_MAGNITUDE = 10;
    private static final short RP_MAX_MAGNITUDE = 12;
    @SuppressWarnings("serial")
    private static final Set<String> REFERENCE_PIXEL_LABELS = new HashSet<String>() {
        {
            add("PDQ_STELLAR");
        }
    };

    private static final int INPUT_FILE_SIZE = LC1_TARGET_COUNT
        + GO_TOTAL_TARGET_COUNT;

    private static final boolean TOO_MANY_TARGET_DEFS = LC1_TARGET_COUNT
        + GO_TARGET_COUNT > TargetManagementConstants.MAX_LONG_CADENCE_TARGET_DEFS;

    private static final String COMMENT_CHAR = "#";

    private static final String LC1_FILENAME = "LongCadence-"
        + LC1_TARGET_COUNT / 1000 + "a.txt";
    private static final String LC2_FILENAME = "LongCadence-"
        + LC2_TARGET_COUNT / 1000 + "b.txt";
    private static final String SC1_FILENAME = "ShortCadence-" + SC_BUCKET_SIZE
        + "a1.txt";
    private static final String SC2_FILENAME = "ShortCadence-" + SC_BUCKET_SIZE
        + "a2.txt";
    private static final String SC3_FILENAME = "ShortCadence-" + SC_BUCKET_SIZE
        + "a3.txt";
    private static final String SC4_FILENAME = "ShortCadence-" + SC_BUCKET_SIZE
        + "b1.txt";
    private static final String SC5_FILENAME = "ShortCadence-" + SC_BUCKET_SIZE
        + "b2.txt";
    private static final String SC6_FILENAME = "ShortCadence-" + SC_BUCKET_SIZE
        + "b3.txt";
    private static final String RP1_FILENAME = "ReferencePixel-"
        + RP1_BUCKET_SIZE + "a.txt";
    private static final String RP2_FILENAME = "ReferencePixel-"
        + RP2_BUCKET_SIZE + "b.txt";
    private static final String RP3_FILENAME = "ReferencePixel-"
        + RP3_BUCKET_SIZE + ".txt";
    private static final String GO1_FILENAME = "GO-" + GO_BUCKET_SIZE + "a.txt";
    private static final String GO2_FILENAME = "GO-" + GO_BUCKET_SIZE + "b.txt";
    private static final String GO_SC1_FILENAME = "GO-" + GO_SC_BUCKET_SIZE
        + "a1.txt";
    private static final String GO_SC2_FILENAME = "GO-" + GO_SC_BUCKET_SIZE
        + "a2.txt";
    private static final String GO_SC3_FILENAME = "GO-" + GO_SC_BUCKET_SIZE
        + "a3.txt";
    private static final String GO_SC4_FILENAME = "GO-" + GO_SC_BUCKET_SIZE
        + "b1.txt";
    private static final String GO_SC5_FILENAME = "GO-" + GO_SC_BUCKET_SIZE
        + "b2.txt";
    private static final String GO_SC6_FILENAME = "GO-" + GO_SC_BUCKET_SIZE
        + "b3.txt";

    // Characteristics
    private static final String[] CHAR_TYPES = new String[] { "RANKING-1",
        "RANKING-2", "RANKING-3", "RANKING-4", "RANKING-5" };
    private static final String CHAR_TYPE_FORMAT = "%.0f";
    private static final String CHAR_TYPE_FILENAME = "t-rankings.mrg";
    private static final String CHAR_FILENAME = "r-%s.mrg";
    private static final int CHAR_COUNT = 200000;
    private static final int KIC_COUNT = 13000000;

    private Map<Integer, Set<TargetInfo>> lc1Targets = new HashMap<Integer, Set<TargetInfo>>();
    private Map<Integer, Set<TargetInfo>> lc2Targets = new HashMap<Integer, Set<TargetInfo>>();

    private KicCrud kicCrud;
    private TargetSelectionOperations targetSelectionOperations;

    public static void main(String[] args) {
        Options options = new Options();
        options.addOption("t", "target-lists", true,
            "Generates two sets of target lists and two sets of GO target lists");
        options.addOption("c", "characteristics", false,
            "Generates five characteristic types "
                + "and data files consisting of 200,000 rows each");

        // Parse command line.
        try {
            CommandLine cmds = new PosixParser().parse(options, args);
            GenerateTestData generateTestData = new GenerateTestData();
            if (cmds.hasOption("target-lists")) {
                generateTestData.createTargetLists(cmds.getOptionValue("target-lists"));
            } else if (cmds.hasOption("characteristics")) {
                generateTestData.createCharacteristics();
            } else {
                usage(options);
            }
        } catch (ParseException e) {
            System.out.println(e.getMessage());
            usage(options);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void usage(Options options) {
        HelpFormatter formatter = new HelpFormatter();
        formatter.printHelp("GenerateTestData [options]", options);
        System.exit(1);
    }

    private void createTargetLists(String inputFilename) throws IOException,
        FileNotFoundException {

        kicCrud = new KicCrud();
        targetSelectionOperations = new TargetSelectionOperations();

        // Sanity check.
        if (TOO_MANY_TARGET_DEFS) {
            System.err.printf(
                "\nInternal error: First long cadence count (%,d) plus GO target count (%,d)\n"
                    + "is greater than maximum targets allowed (%,d).\n"
                    + "Bailing since the results will break the pipeline.\n\n",
                LC1_TARGET_COUNT, GO_TARGET_COUNT,
                TargetManagementConstants.MAX_LONG_CADENCE_TARGET_DEFS);
            System.exit(1);
        }

        readLongCadenceFile(new File(inputFilename));

        System.out.print("\nWriting target lists...");
        selectGoTargets();
        generateTestData();
    }

    private void readLongCadenceFile(File file) throws IOException,
        PipelineException {

        System.out.println("Reading " + file.getCanonicalPath());

        DatabaseService dbInstance = DatabaseServiceFactory.getInstance();
        String categoryLabel = CATEGORY_LABEL.toLowerCase();
        BufferedReader lc = new BufferedReader(new FileReader(file));
        int targetCount = 0;
        for (String s = lc.readLine(); s != null; s = lc.readLine()) {
            if (s.startsWith(COMMENT_CHAR) || s.toLowerCase()
                .startsWith(categoryLabel)) {
                continue;
            }

            PlannedTarget target = TargetSelectionOperations.stringToTarget(s);
            Kic kic = kicCrud.retrieveKic(target.getKeplerId());
            dbInstance.evict(kic);

            Set<TargetInfo> targets = lc1Targets.get(kic.getSkyGroupId());
            if (targets == null) {
                targets = new TreeSet<TargetInfo>();
                lc1Targets.put(kic.getSkyGroupId(), targets);
            }
            targets.add(new TargetInfo(target, kic.getKeplerMag()));

            if (++targetCount % 1000 == 0) {
                System.out.println("Read " + targetCount + " targets");
            }
        }
        lc.close();

        if (targetCount != INPUT_FILE_SIZE) {
            System.err.printf(
                "\nInput file %s contains only %,d targets, %,d is required.\n"
                    + "Proceeding anyway, but results will be insufficient.\n\n",
                file.getName(), targetCount, INPUT_FILE_SIZE);
        }
    }

    private void selectGoTargets() throws IOException {
        Map<Integer, Set<TargetInfo>> go1Targets = new HashMap<Integer, Set<TargetInfo>>();
        Map<Integer, Set<TargetInfo>> go2Targets = new HashMap<Integer, Set<TargetInfo>>();

        BufferedWriter go1 = new BufferedWriter(new FileWriter(GO1_FILENAME));
        BufferedWriter go2 = new BufferedWriter(new FileWriter(GO2_FILENAME));

        go1.write(GO_CATEGORY);
        go2.write(GO_CATEGORY);

        for (Integer skyGroupId : lc1Targets.keySet()) {
            TreeSet<TargetInfo> targets = (TreeSet<TargetInfo>) lc1Targets.get(skyGroupId);

            // Add targets to the GO lists, removing them from the original list
            // as we do.
            for (TargetInfo targetInfo = targets.last();; targetInfo = targets.last()) {
                PlannedTarget plannedTarget = targetInfo.getPlannedTarget();
                if (needed(targetInfo, skyGroupId, go1Targets,
                    GO_SHARED_BUCKET_SIZE, GO_MIN_MAGNITUDE, GO_MAX_MAGNITUDE)
                    && needed(targetInfo, skyGroupId, go2Targets,
                        GO_SHARED_BUCKET_SIZE, GO_MIN_MAGNITUDE,
                        GO_MAX_MAGNITUDE)) {
                    writeTarget(plannedTarget, go1, go2);
                } else if (needed(targetInfo, skyGroupId, go1Targets,
                    GO_BUCKET_SIZE, GO_MIN_MAGNITUDE, GO_MAX_MAGNITUDE)) {
                    writeTarget(plannedTarget, go1);
                } else if (needed(targetInfo, skyGroupId, go2Targets,
                    GO_BUCKET_SIZE, GO_MIN_MAGNITUDE, GO_MAX_MAGNITUDE)) {
                    writeTarget(plannedTarget, go2);
                } else {
                    break;
                }

                targets.remove(targetInfo);
            }
        }

        go1.close();
        targetCheck(GO1_FILENAME, go1Targets, GO_BUCKET_SIZE);
        go2.close();
        targetCheck(GO2_FILENAME, go2Targets, GO_BUCKET_SIZE);
    }

    private void generateTestData() throws FileNotFoundException, IOException,
        PipelineException {

        Map<Integer, Set<TargetInfo>> sc1Targets = new HashMap<Integer, Set<TargetInfo>>();
        Map<Integer, Set<TargetInfo>> sc2Targets = new HashMap<Integer, Set<TargetInfo>>();
        Map<Integer, Set<TargetInfo>> sc3Targets = new HashMap<Integer, Set<TargetInfo>>();
        Map<Integer, Set<TargetInfo>> sc4Targets = new HashMap<Integer, Set<TargetInfo>>();
        Map<Integer, Set<TargetInfo>> sc5Targets = new HashMap<Integer, Set<TargetInfo>>();
        Map<Integer, Set<TargetInfo>> sc6Targets = new HashMap<Integer, Set<TargetInfo>>();
        Map<Integer, Set<TargetInfo>> rp1Targets = new HashMap<Integer, Set<TargetInfo>>();
        Map<Integer, Set<TargetInfo>> rp2Targets = new HashMap<Integer, Set<TargetInfo>>();
        Map<Integer, Set<TargetInfo>> rp3Targets = new HashMap<Integer, Set<TargetInfo>>();
        Map<Integer, Set<TargetInfo>> gosc1Targets = new HashMap<Integer, Set<TargetInfo>>();
        Map<Integer, Set<TargetInfo>> gosc2Targets = new HashMap<Integer, Set<TargetInfo>>();
        Map<Integer, Set<TargetInfo>> gosc3Targets = new HashMap<Integer, Set<TargetInfo>>();
        Map<Integer, Set<TargetInfo>> gosc4Targets = new HashMap<Integer, Set<TargetInfo>>();
        Map<Integer, Set<TargetInfo>> gosc5Targets = new HashMap<Integer, Set<TargetInfo>>();
        Map<Integer, Set<TargetInfo>> gosc6Targets = new HashMap<Integer, Set<TargetInfo>>();

        BufferedWriter lc1 = new BufferedWriter(new FileWriter(LC1_FILENAME));
        BufferedWriter lc2 = new BufferedWriter(new FileWriter(LC2_FILENAME));
        BufferedWriter sc1 = new BufferedWriter(new FileWriter(SC1_FILENAME));
        BufferedWriter sc2 = new BufferedWriter(new FileWriter(SC2_FILENAME));
        BufferedWriter sc3 = new BufferedWriter(new FileWriter(SC3_FILENAME));
        BufferedWriter sc4 = new BufferedWriter(new FileWriter(SC4_FILENAME));
        BufferedWriter sc5 = new BufferedWriter(new FileWriter(SC5_FILENAME));
        BufferedWriter sc6 = new BufferedWriter(new FileWriter(SC6_FILENAME));
        BufferedWriter rp1 = new BufferedWriter(new FileWriter(RP1_FILENAME));
        BufferedWriter rp2 = new BufferedWriter(new FileWriter(RP2_FILENAME));
        BufferedWriter rp3 = new BufferedWriter(new FileWriter(RP3_FILENAME));
        BufferedWriter gosc1 = new BufferedWriter(new FileWriter(
            GO_SC1_FILENAME));
        BufferedWriter gosc2 = new BufferedWriter(new FileWriter(
            GO_SC2_FILENAME));
        BufferedWriter gosc3 = new BufferedWriter(new FileWriter(
            GO_SC3_FILENAME));
        BufferedWriter gosc4 = new BufferedWriter(new FileWriter(
            GO_SC4_FILENAME));
        BufferedWriter gosc5 = new BufferedWriter(new FileWriter(
            GO_SC5_FILENAME));
        BufferedWriter gosc6 = new BufferedWriter(new FileWriter(
            GO_SC6_FILENAME));

        lc1.write(PLANETARY_CATEGORY);
        lc2.write(PLANETARY_CATEGORY);
        sc1.write(PLANETARY_CATEGORY);
        sc2.write(PLANETARY_CATEGORY);
        sc3.write(PLANETARY_CATEGORY);
        sc4.write(PLANETARY_CATEGORY);
        sc5.write(PLANETARY_CATEGORY);
        sc6.write(PLANETARY_CATEGORY);
        rp1.write(RP_CATEGORY);
        rp2.write(RP_CATEGORY);
        rp3.write(RP_CATEGORY);
        gosc1.write(GO_CATEGORY);
        gosc2.write(GO_CATEGORY);
        gosc3.write(GO_CATEGORY);
        gosc4.write(GO_CATEGORY);
        gosc5.write(GO_CATEGORY);
        gosc6.write(GO_CATEGORY);

        int lc2Count = 0;
        for (Integer skyGroupId : lc1Targets.keySet()) {
            for (TargetInfo targetInfo : lc1Targets.get(skyGroupId)) {
                PlannedTarget plannedTarget = targetInfo.getPlannedTarget();

                // The pattern here is to fill both of the related short cadence
                // lists (sc1 and sc4, for example) for a given shared amount,
                // then to add some targets to the first and some different
                // targets to the second. Then move on to the next pair of
                // associated short cadence lists (for example, sc2 and sc5).
                if (needed(targetInfo, skyGroupId, sc1Targets,
                    SC_SHARED_BUCKET_SIZE, SC_MIN_MAGNITUDE, SC_MAX_MAGNITUDE)
                    && needed(targetInfo, skyGroupId, sc4Targets,
                        SC_SHARED_BUCKET_SIZE, SC_MIN_MAGNITUDE,
                        SC_MAX_MAGNITUDE)) {
                    writeTarget(plannedTarget, sc1, sc4);
                } else if (needed(targetInfo, skyGroupId, sc1Targets,
                    SC_BUCKET_SIZE, SC_MIN_MAGNITUDE, SC_MAX_MAGNITUDE)) {
                    writeTarget(plannedTarget, sc1);
                } else if (needed(targetInfo, skyGroupId, sc4Targets,
                    SC_BUCKET_SIZE, SC_MIN_MAGNITUDE, SC_MAX_MAGNITUDE)) {
                    writeTarget(plannedTarget, sc4);
                } else if (needed(targetInfo, skyGroupId, sc2Targets,
                    SC_SHARED_BUCKET_SIZE, SC_MIN_MAGNITUDE, SC_MAX_MAGNITUDE)
                    && needed(targetInfo, skyGroupId, sc5Targets,
                        SC_SHARED_BUCKET_SIZE, SC_MIN_MAGNITUDE,
                        SC_MAX_MAGNITUDE)) {
                    writeTarget(plannedTarget, sc2, sc5);
                } else if (needed(targetInfo, skyGroupId, sc2Targets,
                    SC_BUCKET_SIZE, SC_MIN_MAGNITUDE, SC_MAX_MAGNITUDE)) {
                    writeTarget(plannedTarget, sc2);
                } else if (needed(targetInfo, skyGroupId, sc5Targets,
                    SC_BUCKET_SIZE, SC_MIN_MAGNITUDE, SC_MAX_MAGNITUDE)) {
                    writeTarget(plannedTarget, sc5);
                } else if (needed(targetInfo, skyGroupId, sc3Targets,
                    SC_SHARED_BUCKET_SIZE, SC_MIN_MAGNITUDE, SC_MAX_MAGNITUDE)
                    && needed(targetInfo, skyGroupId, sc6Targets,
                        SC_SHARED_BUCKET_SIZE, SC_MIN_MAGNITUDE,
                        SC_MAX_MAGNITUDE)) {
                    writeTarget(plannedTarget, sc3, sc6);
                } else if (needed(targetInfo, skyGroupId, sc3Targets,
                    SC_BUCKET_SIZE, SC_MIN_MAGNITUDE, SC_MAX_MAGNITUDE)) {
                    writeTarget(plannedTarget, sc3);
                } else if (needed(targetInfo, skyGroupId, sc6Targets,
                    SC_BUCKET_SIZE, SC_MIN_MAGNITUDE, SC_MAX_MAGNITUDE)) {
                    writeTarget(plannedTarget, sc6);
                } else if (needed(targetInfo, skyGroupId, gosc1Targets,
                    GO_SC_BUCKET_SIZE, GO_SC_MIN_MAGNITUDE, GO_SC_MAX_MAGNITUDE)) {
                    writeTarget(plannedTarget, gosc1);
                } else if (needed(targetInfo, skyGroupId, gosc2Targets,
                    GO_SC_BUCKET_SIZE, GO_SC_MIN_MAGNITUDE, GO_SC_MAX_MAGNITUDE)) {
                    writeTarget(plannedTarget, gosc2);
                } else if (needed(targetInfo, skyGroupId, gosc3Targets,
                    GO_SC_BUCKET_SIZE, GO_SC_MIN_MAGNITUDE, GO_SC_MAX_MAGNITUDE)) {
                    writeTarget(plannedTarget, gosc3);
                } else if (needed(targetInfo, skyGroupId, gosc4Targets,
                    GO_SC_BUCKET_SIZE, GO_SC_MIN_MAGNITUDE, GO_SC_MAX_MAGNITUDE)) {
                    writeTarget(plannedTarget, gosc4);
                } else if (needed(targetInfo, skyGroupId, gosc5Targets,
                    GO_SC_BUCKET_SIZE, GO_SC_MIN_MAGNITUDE, GO_SC_MAX_MAGNITUDE)) {
                    writeTarget(plannedTarget, gosc5);
                } else if (needed(targetInfo, skyGroupId, gosc6Targets,
                    GO_SC_BUCKET_SIZE, GO_SC_MIN_MAGNITUDE, GO_SC_MAX_MAGNITUDE)) {
                    writeTarget(plannedTarget, gosc6);
                }

                // Because the second reference pixel target list is a subset of
                // the first, fill both until the the second is full, and then
                // add the remaining targets to the first.
                if (needed(targetInfo, skyGroupId, rp1Targets, RP2_BUCKET_SIZE,
                    RP_MIN_MAGNITUDE, RP_MAX_MAGNITUDE)
                    && needed(targetInfo, skyGroupId, rp2Targets,
                        RP2_BUCKET_SIZE, RP_MIN_MAGNITUDE, RP_MAX_MAGNITUDE)) {
                    writeRpTarget(plannedTarget, rp1, rp2);
                } else if (needed(targetInfo, skyGroupId, rp1Targets,
                    RP1_BUCKET_SIZE, RP_MIN_MAGNITUDE, RP_MAX_MAGNITUDE)) {
                    writeRpTarget(plannedTarget, rp1);
                }
                if (needed(targetInfo, skyGroupId, rp3Targets, RP3_BUCKET_SIZE,
                    RP_MIN_MAGNITUDE, RP_MAX_MAGNITUDE)) {
                    writeRpTarget(plannedTarget, rp3);
                }

                // Limit down-selected long cadence targets.
                if (lc2Count < LC2_TARGET_COUNT
                    && needed(targetInfo, skyGroupId, lc2Targets,
                        LC2_BUCKET_SIZE, LC_MIN_MAGNITUDE, LC_MAX_MAGNITUDE)) {
                    writeTarget(plannedTarget, lc2);
                    lc2Count++;
                }

                // Write every long cadence target.
                writeTarget(plannedTarget, lc1);
            }
        }

        System.out.println("done");

        lc1.close();
        targetCheck(LC1_FILENAME, lc1Targets, (int) (LC1_TARGET_COUNT
            / FcConstants.MODULE_OUTPUTS * BUCKET_SIZE_TOLERANCE));
        lc2.close();
        targetCheck(LC2_FILENAME, lc2Targets, (int) (LC2_TARGET_COUNT
            / FcConstants.MODULE_OUTPUTS * BUCKET_SIZE_TOLERANCE));
        sc1.close();
        targetCheck(SC1_FILENAME, sc1Targets, SC_BUCKET_SIZE);
        sc2.close();
        targetCheck(SC2_FILENAME, sc2Targets, SC_BUCKET_SIZE);
        sc3.close();
        targetCheck(SC3_FILENAME, sc3Targets, SC_BUCKET_SIZE);
        sc4.close();
        targetCheck(SC4_FILENAME, sc4Targets, SC_BUCKET_SIZE);
        sc5.close();
        targetCheck(SC5_FILENAME, sc5Targets, SC_BUCKET_SIZE);
        sc6.close();
        targetCheck(SC6_FILENAME, sc6Targets, SC_BUCKET_SIZE);
        rp1.close();
        targetCheck(RP1_FILENAME, rp1Targets, RP1_BUCKET_SIZE);
        rp2.close();
        targetCheck(RP2_FILENAME, rp2Targets, RP2_BUCKET_SIZE);
        rp3.close();
        targetCheck(RP3_FILENAME, rp3Targets, RP3_BUCKET_SIZE);
        gosc1.close();
        targetCheck(GO_SC1_FILENAME, gosc1Targets, GO_SC_BUCKET_SIZE);
        gosc2.close();
        targetCheck(GO_SC2_FILENAME, gosc2Targets, GO_SC_BUCKET_SIZE);
        gosc3.close();
        targetCheck(GO_SC3_FILENAME, gosc3Targets, GO_SC_BUCKET_SIZE);
        gosc4.close();
        targetCheck(GO_SC4_FILENAME, gosc4Targets, GO_SC_BUCKET_SIZE);
        gosc5.close();
        targetCheck(GO_SC5_FILENAME, gosc5Targets, GO_SC_BUCKET_SIZE);
        gosc6.close();
        targetCheck(GO_SC6_FILENAME, gosc6Targets, GO_SC_BUCKET_SIZE);
    }

    private boolean needed(TargetInfo target, int skyGroupId,
        Map<Integer, Set<TargetInfo>> targets, int bucketSize,
        short minMagnitude, short maxMagnitude) {

        Set<TargetInfo> skyGroupTargets = targets.get(skyGroupId);
        if (skyGroupTargets == null) {
            skyGroupTargets = new TreeSet<TargetInfo>();
            targets.put(skyGroupId, skyGroupTargets);
        }
        assert minMagnitude < maxMagnitude;
        if (skyGroupTargets.size() < bucketSize
            && target.getKeplerMag() > minMagnitude
            && target.getKeplerMag() < maxMagnitude) {
            skyGroupTargets.add(target);
            return true;
        }

        return false;
    }

    private void writeRpTarget(PlannedTarget plannedTarget, Writer... files)
        throws IOException {

        PlannedTarget plannedTargetCopy = new PlannedTarget(plannedTarget);
        plannedTargetCopy.setLabels(REFERENCE_PIXEL_LABELS);
        writeTarget(plannedTargetCopy, files);
    }

    private void writeTarget(PlannedTarget plannedTarget, Writer... files)
        throws IOException {

        for (Writer file : files) {
            file.write(targetSelectionOperations.targetToString(plannedTarget));
            file.write("\n");
        }
    }

    private void targetCheck(String filename,
        Map<Integer, Set<TargetInfo>> targets, int bucketSize) {

        if (targets.get(0) != null) {
            System.out.println("Warning: " + targets.get(0)
                .size() + " targets in sky group 0");
        }

        StringBuilder s = new StringBuilder();
        int total = 0;
        for (int i = 1; i <= FcConstants.MODULE_OUTPUTS; i++) {
            Set<TargetInfo> skyGroupTargets = targets.get(i);
            int targetCount = skyGroupTargets != null ? skyGroupTargets.size()
                : 0;
            if (targetCount < bucketSize) {
                s.append(i + ": " + targetCount + " target");
                s.append(targetCount == 1 ? "" : "s");
                s.append("\n");
            }
            total += targetCount;
        }

        System.out.println("\n" + filename + " contains " + total + " target"
            + (total == 1 ? "." : "s."));
        String summary = "All sky groups have at least " + bucketSize
            + " target" + (bucketSize == 1 ? "" : "s");
        if (s.length() == 0) {
            System.out.println(summary + ".");
        } else {
            System.out.println(summary + ", except:");
            System.out.print(s.toString());
        }
    }

    private void createCharacteristics() throws IOException {
        Random random = new Random(42);
        Set<Integer> keplerIds = new HashSet<Integer>(CHAR_COUNT);
        BufferedWriter typeFile = new BufferedWriter(new FileWriter(
            CHAR_TYPE_FILENAME));

        for (String type : CHAR_TYPES) {
            // Write types.
            CharacteristicType charType = new CharacteristicType(type,
                CHAR_TYPE_FORMAT);
            typeFile.write(charType.format() + "\n");

            // Write characteristics.
            String filename = String.format(CHAR_FILENAME, type.toLowerCase());
            System.out.print("Writing " + filename + "...");
            BufferedWriter charFile = new BufferedWriter(new FileWriter(
                filename));
            keplerIds.clear();

            for (int i = 0; i < CHAR_COUNT; i++) {
                int keplerId = (int) (random.nextFloat() * KIC_COUNT);
                while (keplerIds.contains(keplerId)) {
                    keplerId = (int) (random.nextFloat() * KIC_COUNT);
                }
                keplerIds.add(keplerId);

                Characteristic characteristic = new Characteristic(keplerId,
                    charType, i);
                charFile.write(characteristic.toString() + "\n");
            }

            charFile.close();
            System.out.println("done");
        }

        typeFile.close();
    }

    private static class TargetInfo implements Comparable<TargetInfo> {
        private PlannedTarget plannedTarget;
        private Float keplerMag;

        public TargetInfo(PlannedTarget target, Float kepmag) {
            plannedTarget = target;
            keplerMag = kepmag;
        }

        @Override
        public int compareTo(TargetInfo o) {
            int diff = keplerMag.compareTo(o.getKeplerMag());

            return diff != 0 ? diff : plannedTarget.getKeplerId()
                - o.plannedTarget.getKeplerId();
        }

        public Float getKeplerMag() {
            return keplerMag;
        }

        public PlannedTarget getPlannedTarget() {
            return plannedTarget;
        }

        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime * result
                + (keplerMag == null ? 0 : keplerMag.hashCode());
            result = prime * result
                + (plannedTarget == null ? 0 : plannedTarget.hashCode());
            return result;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj) {
                return true;
            }
            if (obj == null) {
                return false;
            }
            if (!(obj instanceof TargetInfo)) {
                return false;
            }
            TargetInfo other = (TargetInfo) obj;
            if (keplerMag == null) {
                if (other.keplerMag != null) {
                    return false;
                }
            } else if (!keplerMag.equals(other.keplerMag)) {
                return false;
            }
            if (plannedTarget == null) {
                if (other.plannedTarget != null) {
                    return false;
                }
            } else if (!plannedTarget.equals(other.plannedTarget)) {
                return false;
            }
            return true;
        }

        @Override
        public String toString() {
            return new ToStringBuilder(this).append("keplerId",
                plannedTarget.getKeplerId())
                .append("mag", keplerMag)
                .toString();
        }
    }
}
