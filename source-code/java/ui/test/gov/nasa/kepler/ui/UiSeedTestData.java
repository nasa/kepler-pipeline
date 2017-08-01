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

package gov.nasa.kepler.ui;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.Iso8601Formatter;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.hibernate.cm.Characteristic;
import gov.nasa.kepler.hibernate.cm.CharacteristicCrud;
import gov.nasa.kepler.hibernate.cm.CharacteristicType;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetList.SourceType;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.RefPixelLog;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.gar.HuffmanEntry;
import gov.nasa.kepler.hibernate.gar.HuffmanTable;
import gov.nasa.kepler.hibernate.gar.MeanBlackEntry;
import gov.nasa.kepler.hibernate.gar.RequantEntry;
import gov.nasa.kepler.hibernate.gar.RequantTable;
import gov.nasa.kepler.hibernate.pdq.AttitudeAdjustment;
import gov.nasa.kepler.hibernate.pdq.PdqCrud;
import gov.nasa.kepler.hibernate.pdq.PdqSeed;
import gov.nasa.kepler.hibernate.pi.PipelineDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.services.UserCrud;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.TadReport;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.services.security.TestSecuritySeedData;

import java.text.DateFormat;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Seeds the database with data that is useful for UI development. If you're
 * adding a UI component and want to seed the data with your own data, append a
 * new {@code seedFoo} method to the end and call it from
 * {@code initializeTestDb}.
 * 
 * @author Bill Wohler
 */
public class UiSeedTestData {
    private static final int BATCH_SIZE = 20;
    private static final long MILLIS_PER_HOUR = 60 * 60 * 1000;
    private static final long MILLIS_PER_DAY = 24 * MILLIS_PER_HOUR;

    private static final Log log = LogFactory.getLog(UiSeedTestData.class);
    private int targetCount = 1;
    private int externalId = 1;
    private DateFormat format = Iso8601Formatter.dateFormatter();

    public static void main(String[] args) {
        DatabaseService dbService = null;
        try {
            log.info("Initializing database");
            dbService = DatabaseServiceFactory.getInstance();
            dbService.beginTransaction();
            new UiSeedTestData().loadSeedDb();
            log.info("Committing transactions");
            dbService.commitTransaction();
        } catch (Exception e) {
            log.info("Initialization failed", e);
        } finally {
            if (dbService != null) {
                dbService.rollbackTransactionIfActive();
                dbService.closeCurrentSession();
            }
        }
        log.info("Done");
    }

    /**
     * Seed database with some data.
     */
    public void loadSeedDb() {
        log.info("Loading database for KSOC use");

        seedTargetSelection();
        seedPdq();
        seedHuffman();
        seedRequant();
        seedSecurity();
    }

    /**
     * Seeds the {@link Kic}, {@link TargetList}s, and {@link TargetListSet}s.
     */
    private void seedTargetSelection() {
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        TargetCrud targetCrud = new TargetCrud();
        CharacteristicCrud characteristicCrud = new CharacteristicCrud();
        KicCrud kicCrud = new KicCrud();

        // Clear existing data.
        for (TargetList targetList : targetSelectionCrud.retrieveAllTargetLists()) {
            targetSelectionCrud.delete(targetList);
        }
        for (TargetListSet targetListSet : targetSelectionCrud.retrieveAllTargetListSets()) {
            targetSelectionCrud.delete(targetListSet);
            TargetTable targetTable = targetListSet.getTargetTable();
            if (targetTable != null) {
                targetCrud.delete(targetTable.getMaskTable());
                targetCrud.delete(targetTable);
            }
            targetTable = targetListSet.getBackgroundTable();
            if (targetTable != null) {
                targetCrud.delete(targetTable.getMaskTable());
                targetCrud.delete(targetTable);
            }
        }
        DatabaseServiceFactory.getInstance()
            .flush();

        // Add data.
        String[] targetListNames = { "Planet Detection Targets", "GO Targets",
            "Photometry Data Quality" };
        Map<String, TargetList> targetLists = new HashMap<String, TargetList>();

        for (String name : targetListNames) {
            TargetList targetList = createTargetList(name);
            targetLists.put(name, targetList);
            targetSelectionCrud.create(targetList);
            targetSelectionCrud.create(createTargets(kicCrud, targetList));
        }

        MaskTable lcMaskTable = new MaskTable(MaskType.TARGET);
        targetCrud.createMaskTable(lcMaskTable);

        targetSelectionCrud.create(createTargetListSet(targetCrud,
            "2009 Q1-Long Cadence", State.UPLINKED,
            targetLists.get("Planet Detection Targets"), lcMaskTable));
        targetSelectionCrud.create(createTargetListSet(targetCrud,
            "2009 Q1-Reference Pixel", State.UPLINKED,
            targetLists.get("Photometry Data Quality"), lcMaskTable));
        targetSelectionCrud.create(createTargetListSet(targetCrud,
            "2009 Q1 M1-Short Cadence", State.UPLINKED,
            targetLists.get("GO Targets"), lcMaskTable));
        targetSelectionCrud.create(createTargetListSet(targetCrud,
            "2009 Q1 M2-Short Cadence", State.UPLINKED,
            targetLists.get("GO Targets"), lcMaskTable));
        targetSelectionCrud.create(createTargetListSet(targetCrud,
            "2009 Q1 M3-Short Cadence", State.UPLINKED,
            targetLists.get("GO Targets"), lcMaskTable));

        lcMaskTable = new MaskTable(MaskType.TARGET);
        targetCrud.createMaskTable(lcMaskTable);

        targetSelectionCrud.create(createTargetListSet(targetCrud,
            "2009 Q2-Long Cadence", State.TAD_COMPLETED,
            targetLists.get("Planet Detection Targets"), lcMaskTable));
        targetSelectionCrud.create(createTargetListSet(targetCrud,
            "2009 Q2-Reference Pixel", State.TAD_COMPLETED,
            targetLists.get("Photometry Data Quality"), lcMaskTable));
        targetSelectionCrud.create(createTargetListSet(targetCrud,
            "2009 Q2 M1-Short Cadence", State.TAD_COMPLETED,
            targetLists.get("GO Targets"), lcMaskTable));
        targetSelectionCrud.create(createTargetListSet(targetCrud,
            "2009 Q2 M2-Short Cadence", State.TAD_COMPLETED,
            targetLists.get("GO Targets"), lcMaskTable));
        targetSelectionCrud.create(createTargetListSet(targetCrud,
            "2009 Q2 M3-Short Cadence", State.TAD_COMPLETED,
            targetLists.get("GO Targets"), lcMaskTable));

        String[] characteristicNames = new String[] { "EffectiveTemperature",
            "CrowdingMetric" };
        for (String name : characteristicNames) {
            if (characteristicCrud.retrieveCharacteristicType(name) == null) {
                characteristicCrud.create(createCharacteristicType(name));
            }
            CharacteristicType type = characteristicCrud.retrieveCharacteristicType(name);
            for (int i = 1; i < 4; i++) {
                List<Characteristic> characteristics = characteristicCrud.retrieveCharacteristics(i);
                boolean found = false;
                for (Characteristic characteristic : characteristics) {
                    if (characteristic.getType()
                        .equals(type)) {
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    characteristicCrud.create(createCharacteristic(i, type, i));
                }
            }
        }
    }

    /**
     * Returns a target list set with the given name.
     */
    private TargetListSet createTargetListSet(TargetCrud targetCrud,
        String name, State state, TargetList targetList, MaskTable maskTable) {

        TargetListSet targetListSet = new TargetListSet(name);
        targetListSet.getTargetLists()
            .add(targetList);

        // The target table creation uses the dates from the target list set, so
        // this stanza must appear before the target tables are created.
        try {
            targetListSet.setStart(format.parse("2008-12-16"));
            targetListSet.setEnd(format.parse("2009-03-17"));
        } catch (ParseException e) {
            e.printStackTrace();
        }

        if (name.endsWith("Long Cadence")) {
            targetListSet.setType(TargetType.LONG_CADENCE);
            targetListSet.setTargetTable(createTargetTable(targetCrud,
                targetListSet, TargetType.LONG_CADENCE, state, maskTable));
            targetListSet.setBackgroundTable(createTargetTable(targetCrud,
                targetListSet, TargetType.BACKGROUND, state, null));
        } else if (name.endsWith("Short Cadence")) {
            targetListSet.setType(TargetType.SHORT_CADENCE);
            targetListSet.setTargetTable(createTargetTable(targetCrud,
                targetListSet, TargetType.SHORT_CADENCE, state, maskTable));
        } else if (name.endsWith("Reference Pixel")) {
            targetListSet.setType(TargetType.REFERENCE_PIXEL);
            targetListSet.setTargetTable(createTargetTable(targetCrud,
                targetListSet, TargetType.REFERENCE_PIXEL, state, maskTable));
        }

        // This stanza must appear after target table assigned since the
        // assignment will fail if the state is UPLINKED.
        State initialState = state;
        if (initialState == null) {
            State states[] = State.values();
            initialState = states[(int) Math.round(Math.random()
                * (states.length - 1))];
        }
        targetListSet.setState(initialState);

        return targetListSet;
    }

    /**
     * Returns a {@link TargetTable} for the given {@link TargetListSet} of the
     * given type in the given state with the given mask (which will be created
     * if {@code null}).
     */
    @SuppressWarnings("serial")
    private TargetTable createTargetTable(TargetCrud targetCrud,
        TargetListSet targetListSet, TargetType type, State state,
        MaskTable defaultMaskTable) {

        TargetTable targetTable = new TargetTable(type);
        targetTable.setExternalId(state == State.UPLINKED ? externalId++
            : ExportTable.INVALID_EXTERNAL_ID);
        targetTable.setState(state);
        targetTable.setPlannedStartTime(targetListSet.getStart());
        targetTable.setPlannedEndTime(targetListSet.getEnd());

        MaskTable maskTable = defaultMaskTable;
        if (maskTable == null) {
            maskTable = new MaskTable(MaskType.BACKGROUND);
            targetCrud.createMaskTable(maskTable);
        }
        maskTable.setPlannedStartTime(targetListSet.getStart());
        maskTable.setPlannedEndTime(targetListSet.getEnd());
        maskTable.setExternalId(state == State.UPLINKED ? externalId++
            : ExportTable.INVALID_EXTERNAL_ID);
        maskTable.setState(state);
        targetTable.setMaskTable(maskTable);

        if (state.tadCompleted()) {

            TadReport tadReport = new TadReport();
            tadReport.setMergedTargetCount(170000);
            tadReport.setRejectedByCoaTargetCount(35335);
            tadReport.setTotalMaskCount(1022);
            tadReport.setSupermaskCount(5);
            tadReport.setAveragePixelsPerTargetDef(31.123456789F);
            tadReport.setCustomTargetsWithNoApertureCount(0);
            tadReport.setTargetsWithMasksSmallerThanOptimalApertureCount(5);
            tadReport.setErrors(new ArrayList<String>() {
                {
                    add("Error 1");
                    add("Error 2");
                }
            });
            tadReport.setWarnings(new ArrayList<String>() {
                {
                    add("Warning 1");
                    add("Warning 2");
                }
            });
            tadReport.setPipelineTask(createPipelineTask(targetListSet.getName()
                + " (" + type.toString() + "," + state.toString() + ")"));
            targetTable.setTadReport(tadReport);
        }

        targetCrud.createTargetTable(targetTable);

        return targetTable;
    }

    /**
     * Returns a target list with the given name.
     */
    private TargetList createTargetList(String name) {
        TargetList targetList = new TargetList(name);
        targetList.setCategory(name);
        targetList.setSourceType(SourceType.QUERY);
        targetList.setSource("KMAG > 12 and KMAG < 18");

        return targetList;
    }

    /**
     * Returns the next batch of targets, creating {@link Kic} objects if
     * necessary.
     */
    private List<PlannedTarget> createTargets(KicCrud kicCrud,
        TargetList targetList) {
        List<PlannedTarget> targets = new ArrayList<PlannedTarget>();

        for (int n = targetCount + BATCH_SIZE; targetCount < n; targetCount++) {
            Kic kic = kicCrud.retrieveKic(targetCount);
            int skyGroupId = targetCount % BATCH_SIZE;
            if (kic == null) {
                kic = new Kic.Builder(targetCount, targetCount, targetCount).skyGroupId(
                    skyGroupId)
                    .build();
                kicCrud.create(kic);
            }

            targets.add(new PlannedTarget(targetCount, skyGroupId, targetList));
        }

        return targets;
    }

    /**
     * Returns a characteristic type with the given name.
     */
    private CharacteristicType createCharacteristicType(String name) {
        CharacteristicType type = new CharacteristicType(name, "%f");
        return type;
    }

    /**
     * Returns a characteristic with the given type and value.
     */
    private Characteristic createCharacteristic(int keplerId,
        CharacteristicType type, double value) {

        return new Characteristic(keplerId, type, value);
    }

    /**
     * Seeds the {@link AttitudeAdjustment}s.
     */
    private void seedPdq() {
        PdqCrud pdqCrud = new PdqCrud();
        LogCrud logCrud = new LogCrud();

        // Check for existing data.
        if (pdqCrud.retrieveLatestAttitudeAdjustments(0)
            .size() > 0) {
            log.info("Attitude adjustment tables already seeded");
            return;
        }

        double mjd = ModifiedJulianDate.dateToMjd(new Date());

        // Add data.
        pdqCrud.createAttitudeAdjustment(createAttitudeAdjustment(logCrud, mjd,
            123.45689F));
        pdqCrud.createAttitudeAdjustment(createAttitudeAdjustment(logCrud,
            mjd++, .12345689F));
        pdqCrud.createAttitudeAdjustment(createAttitudeAdjustment(logCrud,
            mjd++, .012345689F));
        pdqCrud.createAttitudeAdjustment(createAttitudeAdjustment(logCrud,
            mjd++, .0012345689F));
        pdqCrud.createAttitudeAdjustment(createAttitudeAdjustment(logCrud,
            mjd++, .00012345689F));
        pdqCrud.createAttitudeAdjustment(createAttitudeAdjustment(logCrud,
            mjd++, .000012345689F));
        pdqCrud.createAttitudeAdjustment(createAttitudeAdjustment(logCrud,
            mjd++, .0000012345689F));
        pdqCrud.createAttitudeAdjustment(createAttitudeAdjustment(logCrud,
            mjd++, .00000012345689F));
        pdqCrud.createAttitudeAdjustment(createAttitudeAdjustment(logCrud,
            mjd++, .000000012345689F));
        pdqCrud.createAttitudeAdjustment(createAttitudeAdjustment(logCrud,
            mjd++, .0000000012345689F));
    }

    /**
     * Returns an {@link AttitudeAdjustment}. See
     * {@link PdqSeed#createAttitudeAdjustment(double)} for description of the
     * arguments.
     */
    private AttitudeAdjustment createAttitudeAdjustment(LogCrud logCrud,
        double seed1, float seed2) {

        RefPixelLog refPixelLog = new RefPixelLog();
        refPixelLog.setMjd(seed1);
        logCrud.createRefPixelLog(refPixelLog);
        AttitudeAdjustment attitudeAdjustment = PdqSeed.createAttitudeAdjustment(seed2);
        attitudeAdjustment.setPipelineTask(createPipelineTask(String.format(
            "PDQ Pipeline %.3e", seed2)));
        attitudeAdjustment.setRefPixelLog(refPixelLog);

        return attitudeAdjustment;
    }

    /**
     * Creates (and stores) a {@link PipelineTask}.
     */
    private PipelineTask createPipelineTask(String name) {
        PipelineInstance pipelineInstance = createPipelineInstance(name);

        PipelineTask pipelineTask = new PipelineTask();
        pipelineTask.setPipelineInstance(pipelineInstance);
        new PipelineTaskCrud().create(pipelineTask);

        return pipelineTask;
    }

    /**
     * Creates (and stores) a {@link PipelineDefinition}.
     */
    private PipelineInstance createPipelineInstance(String name) {
        PipelineDefinition pipelineDefinition = new PipelineDefinition(name);
        new PipelineDefinitionCrud().create(pipelineDefinition);

        PipelineInstance pipelineInstance = new PipelineInstance(
            pipelineDefinition);
        new PipelineInstanceCrud().create(pipelineInstance);

        return pipelineInstance;
    }

    /**
     * Seeds the {@link HuffmanTable}s.
     */
    private void seedHuffman() {
        CompressionCrud compressionCrud = new CompressionCrud();

        // Check for existing data.
        if (compressionCrud.retrieveUplinkedHuffmanTable(1) != null) {
            log.info("Huffman tables already seeded");
            return;
        }

        // Add data.
        List<HuffmanEntry> entries = createHuffmanEntries();

        long timeNow = System.currentTimeMillis();

        HuffmanTable huffmanTable = new HuffmanTable();
        PipelineTask pipelineTask = createPipelineTask("Huffman Pipeline 1");
        huffmanTable.setPipelineTask(pipelineTask);
        huffmanTable.setExternalId(1);
        huffmanTable.setEntries(entries);
        huffmanTable.setState(State.UPLINKED);
        huffmanTable.setPlannedStartTime(new Date(timeNow - 30 * MILLIS_PER_DAY));
        huffmanTable.setPlannedEndTime(new Date(timeNow - 29 * MILLIS_PER_DAY));
        huffmanTable.setTheoreticalCompressionRate(1.0F);
        huffmanTable.setEffectiveCompressionRate(2.3F);
        compressionCrud.createHuffmanTable(huffmanTable);

        huffmanTable = new HuffmanTable();
        huffmanTable.setPipelineTask(createPipelineTask("Huffman Pipeline 2"));
        huffmanTable.setExternalId(2);
        huffmanTable.setTheoreticalCompressionRate(1.0F);
        huffmanTable.setEffectiveCompressionRate(2.4F);
        compressionCrud.createHuffmanTable(huffmanTable);
    }

    /**
     * Returns a list of {@code HuffmanEntry}s.
     */
    private List<HuffmanEntry> createHuffmanEntries() {
        int huffmanEntryCount = 131071;
        List<HuffmanEntry> entries = new ArrayList<HuffmanEntry>(
            huffmanEntryCount);

        for (int i = 0; i < huffmanEntryCount; i++) {
            entries.add(new HuffmanEntry("000000", 42L));
        }

        return entries;
    }

    /**
     * Seeds the {@link RequantTable}s.
     */
    private void seedRequant() {
        CompressionCrud compressionCrud = new CompressionCrud();

        // Check for existing data.
        if (compressionCrud.retrieveUplinkedRequantTable(1) != null) {
            log.info("Requant tables already seeded");
            return;
        }

        // Add data.
        List<RequantEntry> requantEntries = createRequantEntries();
        List<MeanBlackEntry> meanBlackEntries = createMeanBlackEntries();

        long timeNow = System.currentTimeMillis();

        RequantTable requantTable = new RequantTable();
        requantTable.setPipelineTask(createPipelineTask("Requant Pipeline 1"));
        requantTable.setExternalId(1);
        requantTable.setRequantEntries(requantEntries);
        requantTable.setMeanBlackEntries(meanBlackEntries);
        requantTable.setState(State.UPLINKED);
        requantTable.setPlannedStartTime(new Date(timeNow - 30 * MILLIS_PER_DAY));
        requantTable.setPlannedEndTime(new Date(timeNow - 29 * MILLIS_PER_DAY));
        compressionCrud.createRequantTable(requantTable);

        requantTable = new RequantTable();
        requantTable.setPipelineTask(createPipelineTask("Requant Pipeline 2"));
        requantTable.setExternalId(2);
        compressionCrud.createRequantTable(requantTable);
    }

    /**
     * Returns a list of {@code RequantEntry}s.
     */
    private List<RequantEntry> createRequantEntries() {
        List<RequantEntry> entries = new ArrayList<RequantEntry>(
            FcConstants.REQUANT_TABLE_LENGTH);

        for (int i = 0; i < FcConstants.REQUANT_TABLE_LENGTH; i++) {
            entries.add(new RequantEntry(i));
        }

        return entries;
    }

    /**
     * Returns a list of {@code MeanBlackEntry}s.
     */
    private List<MeanBlackEntry> createMeanBlackEntries() {
        List<MeanBlackEntry> entries = new ArrayList<MeanBlackEntry>(
            FcConstants.MODULE_OUTPUTS);

        for (int i = 0; i < FcConstants.MODULE_OUTPUTS; i++) {
            entries.add(new MeanBlackEntry(i));
        }

        return entries;
    }

    private void seedSecurity() {
        TestSecuritySeedData testSecuritySeedData = new TestSecuritySeedData();
        UserCrud userCrud = new UserCrud();
        if (userCrud.retrieveUser("admin") == null) {
            testSecuritySeedData.loadSeedData();
        } else {
            log.info("Security tables already seeded");
        }
    }
}
