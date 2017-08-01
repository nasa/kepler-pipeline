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
import gov.nasa.kepler.hibernate.cm.CustomTarget;
import gov.nasa.kepler.hibernate.cm.CustomTargetCrud;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.Offset;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;

/**
 * Generally useful target selection operations.
 * 
 * @author Bill Wohler
 */
public class TargetSelectionOperations {

    private static final Log log = LogFactory.getLog(TargetSelectionOperations.class);

    /**
     * A string that indicates that this is a new target and that an ID should
     * be assigned to it.
     */
    public static final String NEW_CUSTOM_TARGET_ID_STRING = "NEW";

    /**
     * A boolean property that controls whether a NEW custom target is allowed
     * or not (default: {@code true}). The property is named
     * {@code allowNewCustomTargets}.
     */
    public static final String ALLOW_NEW_CUSTOM_TARGETS_PROPERTY = "cm.allowNewCustomTargets";

    private static final int TARGET_FIELD_COUNT = 6;
    private static final Pattern APERTURE_PATTERN = Pattern.compile(";?(-?[\\d]+),(-?[\\d]+)");

    /**
     * Kepler ID to sky group ID map cache.
     */
    private static final Map<Integer, Integer> skyGroupIdByKeplerId = new HashMap<Integer, Integer>();

    private final KicCrud kicCrud;
    private final CustomTargetCrud customTargetCrud;
    private final TargetSelectionCrud targetSelectionCrud;

    private Map<Integer, Integer> skyGroupIdMap;
    private Map<Integer, SkyGroup> skyGroupMap;

    // Reuse StringBuffer to improve targetToString performance.
    private StringBuilder s = new StringBuilder();

    private boolean allowNewCustomTargets = ConfigurationServiceFactory.getInstance()
        .getBoolean(ALLOW_NEW_CUSTOM_TARGETS_PROPERTY, true);

    public TargetSelectionOperations() {
        kicCrud = new KicCrud();
        customTargetCrud = new CustomTargetCrud();
        targetSelectionCrud = new TargetSelectionCrud();
    }

    public TargetSelectionOperations(DatabaseService databaseService) {
        kicCrud = new KicCrud(databaseService);
        customTargetCrud = new CustomTargetCrud(databaseService);
        targetSelectionCrud = new TargetSelectionCrud(databaseService);
    }

    /**
     * Updates the planned targets in the given target list.
     * 
     * @param targetList the non-{@code null} target list
     * @param plannedTargets the non-{@code null} list of planned targets to add
     * to the given target list
     * @throws NullPointerException if either argument is {@code null}
     * @throws HibernateException if there were problems accessing the database
     */
    public void updatePlannedTargets(TargetList targetList,
        List<PlannedTarget> plannedTargets) {

        if (targetList == null) {
            throw new NullPointerException("targetList can't be null");
        }
        if (plannedTargets == null) {
            throw new NullPointerException("plannedTargets can't be null");
        }

        // The alternative, to save the previous list of targets to
        // compare what should be added and deleted, is too memory
        // intensive. So just delete all targets in the database and
        // then save the local ones.
        log.info("Deleting existing targets");
        long start = System.currentTimeMillis();
        targetSelectionCrud.deletePlannedTargets(targetList);
        log.info(String.format("Deleted existing targets in %d ms",
            System.currentTimeMillis() - start));

        // Now save/update the targets themselves.
        log.info("Saving targets");
        start = System.currentTimeMillis();
        targetSelectionCrud.create(plannedTargets);
        log.info(String.format("Saved targets in %d ms",
            System.currentTimeMillis() - start));
    }

    /**
     * Adds missing sky group IDs to planned targets, and creates custom target
     * IDs as needed.
     * <p>
     * If a planned target for a custom target is missing aperture information,
     * then the aperture information is retrieved from the last planned target
     * in the database that shares its ID. If the aperture information can't be
     * found, an {@link IllegalStateException} is thrown. If the planned target
     * for a custom target contains aperture information, it is acceptable to be
     * different from another planned target for the same custom target that is
     * already is in the database.
     * 
     * @param targetList a non-{@code null} target list
     * @param plannedTargets a non-{@code null} list of planned targets
     * @param skipMissingKeplerIds if {@code true}, do not throw an error if a
     * given ID is not in the database; instead, do not add the target to the
     * returned list
     * @throws IllegalStateException if planned targets for a given custom
     * target in any target list has different sky group or aperture information
     * @throws NullPointerException if either {@code targetList} or
     * {@code plannedTargets} are {@code null}
     */
    public List<PlannedTarget> validatePlannedTargets(TargetList targetList,
        List<PlannedTarget> plannedTargets, boolean skipMissingKeplerIds) {

        if (targetList == null) {
            throw new NullPointerException("targetList can't be null");
        }
        if (plannedTargets == null) {
            throw new NullPointerException("plannedTargets can't be null");
        }

        updateSkyGroupIdCache(plannedTargets);
        Map<Integer, CustomTarget> customTargetByKeplerId = retrieveCustomTargetMap(plannedTargets);
        Map<Integer, List<PlannedTarget>> plannedTargetsByKeplerId = targetSelectionCrud.retrievePlannedTargets(customTargetByKeplerId.keySet());

        int nextCustomTargetKeplerId = customTargetCrud.retrieveNextCustomTargetKeplerId();
        List<PlannedTarget> validPlannedTargets = new ArrayList<PlannedTarget>();

        for (PlannedTarget plannedTarget : plannedTargets) {
            int keplerId = plannedTarget.getKeplerId();

            if (TargetManagementConstants.isCatalogTarget(keplerId)) {
                if (kicValid(plannedTarget, skyGroupIdByKeplerId.get(keplerId),
                    skipMissingKeplerIds)) {
                    validPlannedTargets.add(plannedTarget);
                }
                continue;
            }

            CustomTarget customTarget = customTargetByKeplerId.get(keplerId);
            if (customTarget == null) {
                if (keplerId == TargetManagementConstants.INVALID_KEPLER_ID) {
                    if (allowNewCustomTargets) {
                        keplerId = nextCustomTargetKeplerId++;
                        plannedTarget.setKeplerId(keplerId);
                    } else {
                        throw new IllegalStateException(
                            String.format(
                                "Can't create custom target for %s because %s property is false",
                                plannedTarget,
                                ALLOW_NEW_CUSTOM_TARGETS_PROPERTY));
                    }
                } else {
                    nextCustomTargetKeplerId = Math.max(
                        nextCustomTargetKeplerId, keplerId + 1);
                }
                if (plannedTarget.getSkyGroupId() == TargetManagementConstants.INVALID_SKY_GROUP_ID) {
                    throw new IllegalStateException(String.format(
                        "Sky group ID required for Kepler ID %d "
                            + "since that target has not yet been imported",
                        plannedTarget.getKeplerId()));
                }

                customTarget = new CustomTarget(keplerId,
                    plannedTarget.getSkyGroupId());
                customTargetCrud.create(customTarget);
            }

            verifyCustomTargetInPlannedTargets(plannedTarget, customTarget,
                plannedTargetsByKeplerId.get(keplerId), targetList);
            verifyApertureInPlannedTargets(plannedTarget,
                plannedTargetsByKeplerId.get(keplerId), targetList);

            validPlannedTargets.add(plannedTarget);
        }

        return validPlannedTargets;
    }

    private void updateSkyGroupIdCache(List<PlannedTarget> plannedTargets) {

        // Get list of Kepler IDs in planned targets that aren't already in
        // cache.
        List<Integer> keplerIds = new ArrayList<Integer>();
        for (PlannedTarget plannedTarget : plannedTargets) {
            if (TargetManagementConstants.isCatalogTarget(plannedTarget.getKeplerId())
                && skyGroupIdByKeplerId.get(plannedTarget.getKeplerId()) == null) {
                keplerIds.add(plannedTarget.getKeplerId());
            }
        }

        // Nothing to add to cache. Avoid synchronized block.
        if (keplerIds.size() == 0) {
            return;
        }

        // Retrieve the new Kepler IDs and merge them into cache.
        Map<Integer, Integer> newSkyGroupIdByKeplerId = kicCrud.retrieveSkyGroupIdsForKeplerIds(keplerIds);
        synchronized (skyGroupIdByKeplerId) {
            for (Entry<Integer, Integer> entry : newSkyGroupIdByKeplerId.entrySet()) {
                skyGroupIdByKeplerId.put(entry.getKey(), entry.getValue());
            }
        }
    }

    private Map<Integer, CustomTarget> retrieveCustomTargetMap(
        List<PlannedTarget> plannedTargets) {

        // Create a list of custom target IDs.
        List<Integer> keplerIds = new ArrayList<Integer>();
        for (PlannedTarget plannedTarget : plannedTargets) {
            if (TargetManagementConstants.isCustomTarget(plannedTarget.getKeplerId())) {
                keplerIds.add(plannedTarget.getKeplerId());
            }
        }

        // Look them up.
        List<CustomTarget> existingCustomTargets = customTargetCrud.retrieveCustomTargets(keplerIds);

        // Stash them in a map.
        Map<Integer, CustomTarget> customTargetByKeplerId = new HashMap<Integer, CustomTarget>(
            existingCustomTargets.size());
        for (CustomTarget customTarget : existingCustomTargets) {
            if (customTarget != null) {
                customTargetByKeplerId.put(customTarget.getKeplerId(),
                    customTarget);
            }
        }

        return customTargetByKeplerId;
    }

    private boolean kicValid(PlannedTarget plannedTarget, Integer skyGroupId,
        boolean skipMissingKeplerIds) {

        if (skyGroupId == null) {
            if (skipMissingKeplerIds) {
                log.debug("Skipping kepler ID " + plannedTarget.getKeplerId());
                return false;
            }
            throw new IllegalArgumentException(String.format(
                "Could not find Kepler ID %d in database",
                plannedTarget.getKeplerId()));

        } else if (skyGroupId == 0) {
            // Does not contribute to errorCount.
            log.warn(String.format("Sky group for Kepler ID %d is 0",
                plannedTarget.getKeplerId()));
        }

        if (plannedTarget.getSkyGroupId() != skyGroupId) {
            plannedTarget.setSkyGroupId(skyGroupId);
        }

        return true;
    }

    private void verifyCustomTargetInPlannedTargets(
        PlannedTarget plannedTarget, CustomTarget customTarget,
        List<PlannedTarget> plannedTargets, TargetList targetList) {

        if (plannedTarget.getKeplerId() == TargetManagementConstants.INVALID_KEPLER_ID) {
            plannedTarget.setKeplerId(customTarget.getKeplerId());
        }
        if (plannedTarget.getSkyGroupId() == TargetManagementConstants.INVALID_SKY_GROUP_ID) {
            plannedTarget.setSkyGroupId(customTarget.getSkyGroupId());
        }

        if (plannedTargets == null) {
            return;
        }

        for (PlannedTarget target : plannedTargets) {
            if (target.getTargetList()
                .equals(targetList)) {
                continue;
            }
            if (plannedTarget.getSkyGroupId() != target.getSkyGroupId()) {
                throw new IllegalStateException(String.format(
                    "Sky group ID %d for Kepler ID %d does not match "
                        + "this target's sky group ID %d in target list %s",
                    plannedTarget.getSkyGroupId(), plannedTarget.getKeplerId(),
                    target.getSkyGroupId(), target.getTargetList()
                        .getName()));
            }
        }
    }

    private void verifyApertureInPlannedTargets(PlannedTarget plannedTarget,
        List<PlannedTarget> plannedTargets, TargetList targetList) {

        if (plannedTargets == null) {
            if (plannedTarget.getAperture() == null) {
                throw new IllegalStateException(String.format(
                    "Aperture required for Kepler ID %d "
                        + "since that target has not yet been imported",
                    plannedTarget.getKeplerId()));
            }
            return;
        }

        PlannedTarget referenceTarget = null;
        for (PlannedTarget target : plannedTargets) {
            if (target.getTargetList()
                .equals(targetList)) {
                continue;
            }
            if (referenceTarget == null
                || target.getId() > referenceTarget.getId()) {
                referenceTarget = target;
            }
        }

        if (referenceTarget != null) {
            if (plannedTarget.getAperture() == null) {
                plannedTarget.setAperture(new Aperture(
                    referenceTarget.getAperture()));
            }
        } else {
            if (plannedTarget.getAperture() == null) {
                throw new IllegalStateException(String.format(
                    "Aperture required for Kepler ID %d since that target has "
                        + "not yet been imported in another target list",
                    plannedTarget.getKeplerId()));
            }
        }
    }

    /**
     * Merges the given planned target into the given map. The Kepler ID from
     * the planned target is not used as the key; rather, the given Kepler ID is
     * used. This is useful to keep new custom targets from hashing to the same
     * index. If the key maps to an existing planned target, the apertures are
     * compared for equality and the labels are merged. Otherwise, the given
     * planned target is added to the map.
     * 
     * @param targetByKeplerId map of planned targets by Kepler ID
     * @param keplerId the key
     * @param plannedTarget the planned target to merge into the map
     * @throws NullPointerException if {@code targetByKeplerId} or
     * {@code plannedTarget} are {@code null}
     * @throws IllegalStateException if the given planned target has a different
     * aperture from the corresponding target in the map
     */
    public static void merge(Map<Integer, PlannedTarget> targetByKeplerId,
        int keplerId, PlannedTarget plannedTarget) {

        if (targetByKeplerId == null) {
            throw new NullPointerException("targetByKeplerId can't be null");
        }
        if (plannedTarget == null) {
            throw new NullPointerException("plannedTarget can't be null");
        }

        PlannedTarget target = targetByKeplerId.get(keplerId);
        if (target == null) {
            targetByKeplerId.put(keplerId, plannedTarget);
        } else {
            if (target.getAperture() == null) {
                target.setAperture(plannedTarget.getAperture());
            } else if (plannedTarget.getAperture() != null
                && !plannedTarget.getAperture()
                    .equals(target.getAperture())) {
                throw new IllegalStateException(String.format(
                    "Custom target %d has two different apertures", keplerId));
            }
            target.getLabels()
                .addAll(plannedTarget.getLabels());
        }
    }

    /**
     * Retrieves Kepler IDs and their associated sky group IDs for all objects
     * on the focal plane. A list of arrays is returned. Each array contains two
     * {@link Object} objects (which are really {@link Integer}s) that
     * correspond to the Kepler ID and sky group ID respectively. This list is
     * sorted by ascending Kepler ID.
     * <p>
     * N.B. This returns an object that is approximately 500 MB in size.
     * 
     * @return a non-{@code null} list of {@link Object} arrays
     * @throws HibernateException if there were problems accessing the database
     */
    public List<Object[]> retrieveAllVisibleKeplerSkyGroupIds() {

        // An ArrayList suffices here because the retrieve methods return their
        // IDs in sorted order and the custom target IDs are guaranteed to be
        // larger than all of the IDs in the KIC.
        log.info("Counting Kepler IDs...");
        int count = kicCrud.visibleKicCount()
            + customTargetCrud.visibleCustomTargetCount();
        log.info("Counting Kepler IDs...done (" + count + ")");
        List<Object[]> keplerSkyGroupIds = new ArrayList<Object[]>(count);

        List<Object[]> ids = kicCrud.retrieveAllVisibleKeplerSkyGroupIds();
        keplerSkyGroupIds.addAll(ids);
        ids = customTargetCrud.retrieveAllVisibleKeplerSkyGroupIds();
        keplerSkyGroupIds.addAll(ids);

        return keplerSkyGroupIds;
    }

    /**
     * Returns {@code true} if the given Kepler ID exists.
     * 
     * @return {@code true} if the given Kepler ID exists; otherwise,
     * {@code false}
     * @throws HibernateException if there were problems accessing the database
     */
    public boolean exists(int keplerId) {
        if (!TargetManagementConstants.isCustomTarget(keplerId)) {
            return kicCrud.exists(keplerId);
        }
        return customTargetCrud.exists(keplerId);
    }

    public static PlannedTarget stringToTarget(String s) {
        if (s == null) {
            throw new NullPointerException("s can't be null");
        }

        // Check that we have the correct number of delimiters.
        int delimiterCount = 0;
        for (int i = s.length() - 1; i >= 0; i--) {
            if (s.charAt(i) == Kic.SCP_DELIMITER_CHAR) {
                delimiterCount++;
            }
        }
        if (delimiterCount + 1 < TARGET_FIELD_COUNT) {
            throw new IllegalArgumentException(
                "Not enough fields in record: \n" + s);
        }

        // Note that split discards trailing empty fields.
        String[] fields = s.split("\\" + Kic.SCP_DELIMITER);

        // Identification (keplerId, skyGroupId).
        String keplerIdString = parseString(fields, 0);
        if (keplerIdString == null) {
            throw new IllegalArgumentException("No keplerId in record: \n" + s);
        }
        int keplerId = keplerIdString.equals(NEW_CUSTOM_TARGET_ID_STRING) ? TargetManagementConstants.INVALID_KEPLER_ID
            : Integer.parseInt(keplerIdString);
        int skyGroupId = parseInt(fields, 1);

        if (keplerId == TargetManagementConstants.INVALID_KEPLER_ID
            && skyGroupId < 0) {
            throw new IllegalArgumentException(
                "New target requires sky group ID in record: \n" + s);
        } else if (keplerId >= 0
            && !TargetManagementConstants.isCustomTarget(keplerId)
            && skyGroupId >= 0) {
            throw new IllegalArgumentException(
                "Sky group ID prohibited in KIC target in record: \n" + s);
        }

        PlannedTarget target = new PlannedTarget(keplerId, skyGroupId);

        // Labels.
        String labelString = parseString(fields, 2);
        if (labelString != null) {
            String[] labels = labelString.split("\\"
                + PlannedTarget.PAIR_DELIMITER);
            target.setLabels(new LinkedHashSet<String>(Arrays.asList(labels)));
        }

        // Aperture.
        int row = parseInt(fields, 3);
        int column = parseInt(fields, 4);
        String offsetString = parseString(fields, 5);

        // If any of the aperture's fields are present, then all must be
        // present.
        if ((row >= 0 || column >= 0 || offsetString != null)
            && (row < 0 || column < 0 || offsetString == null)) {
            throw new IllegalArgumentException("Invalid aperture in record: \n"
                + s);
        }

        // New custom targets require apertures, whereas KIC targets prohibit
        // apertures.
        if (keplerId == TargetManagementConstants.INVALID_KEPLER_ID && row < 0) {
            throw new IllegalArgumentException(
                "Custom target requires aperture in record: \n" + s);
        } else if (keplerId >= 0
            && !TargetManagementConstants.isCustomTarget(keplerId) && row >= 0) {
            throw new IllegalArgumentException(
                "Aperture prohibited in KIC target in record: \n" + s);
        }

        if (row >= 0) {
            // Reference pixel must be on the CCD.
            if (row >= FcConstants.CCD_ROWS
                || column >= FcConstants.CCD_COLUMNS) {
                throw new IllegalArgumentException(
                    "Reference pixel off CCD in record: \n" + s);
            }

            Aperture aperture = new Aperture(true, row, column, parseOffsets(
                row, column, offsetString));
            target.setAperture(aperture);
        }

        return target;
    }

    private static int parseInt(String[] fields, int n) {
        return fields.length > n && fields[n].length() > 0 ? Integer.parseInt(fields[n])
            : -1;
    }

    private static String parseString(String[] fields, int n) {
        return fields.length > n && fields[n].length() > 0 ? fields[n] : null;
    }

    private static List<Offset> parseOffsets(int referenceRow,
        int referenceColumn, String s) {

        // We expect the number of offsets to be the number semicolons plus 1.
        int expectedOffsetCount = 1;
        for (int i = s.indexOf(';', 0); i >= 0; i = s.indexOf(';', i + 1)) {
            expectedOffsetCount++;
        }

        Matcher m = APERTURE_PATTERN.matcher(s);
        List<Offset> offsets = new ArrayList<Offset>();
        while (m.find()) {
            int row = Integer.parseInt(m.group(1));
            int column = Integer.parseInt(m.group(2));

            // Absolute pixel must be on the CCD.
            int absoluteRow = referenceRow + row;
            int absoluteColumn = referenceColumn + column;
            if (absoluteRow < 0 || absoluteRow >= FcConstants.CCD_ROWS
                || absoluteColumn < 0
                || absoluteColumn >= FcConstants.CCD_COLUMNS) {
                throw new IllegalArgumentException(
                    "Pixel off CCD in record: \n" + s);
            }

            offsets.add(new Offset(row, column));
        }

        if (offsets.size() != expectedOffsetCount) {
            throw new IllegalArgumentException(
                "Offset format not row,col[;row,col;...] in record: \n" + s);
        }

        return offsets;
    }

    /**
     * Turn a {@link PlannedTarget} into a string suitable for export. The
     * operation {@code targetToString(stringToTarget(s))} should give {@code s}
     * .
     * 
     * @param target the target for which a string representation is needed
     * @return the string
     * @see #stringToTarget(String)
     */
    public String targetToString(PlannedTarget target) {
        s.setLength(0);

        // Start with PlannedTarget.toString.
        s.append(target.toString());

        // Change keplerId value of -1 to NEW.
        int keplerId = target.getKeplerId();
        if (keplerId == TargetManagementConstants.INVALID_KEPLER_ID) {
            s.replace(0, s.indexOf(Kic.SCP_DELIMITER),
                NEW_CUSTOM_TARGET_ID_STRING);
        }

        return s.toString();
    }

    /**
     * Returns the sky group ID for the given module/output at
     * {@link SkyGroup#DEFAULT_SEASON}. This method caches The {@link SkyGroup}
     * table for quick access so this object should be kept around when
     * possible.
     * 
     * @param ccdModule the module
     * @param ccdOutput the output
     * @return a sky group ID
     * @throws IllegalArgumentException if there there isn't a {@link SkyGroup}
     * in the database that matches the parameters
     */
    public int skyGroupIdFor(int ccdModule, int ccdOutput) {
        return skyGroupIdFor(ccdModule, ccdOutput, SkyGroup.DEFAULT_SEASON);
    }

    /**
     * Returns the sky group ID for the given module/output in the given season.
     * This method caches The {@link SkyGroup} table for quick access so this
     * object should be kept around when possible.
     * 
     * @param ccdModule the module
     * @param ccdOutput the output
     * @param season the season
     * @return a sky group ID
     * @throws IllegalArgumentException if there there isn't a {@link SkyGroup}
     * in the database that matches the parameters
     */
    public int skyGroupIdFor(int ccdModule, int ccdOutput, int season) {
        if (skyGroupIdMap == null) {
            createSkyGroupMap();
        }
        Integer skyGroupId = skyGroupIdMap.get(generateModuleOutputSeasonKey(
            ccdModule, ccdOutput, season));

        if (skyGroupId == null) {
            throw new IllegalArgumentException("No sky group for CCD module "
                + ccdModule + ", output " + ccdOutput
                + ", and observing season " + season);
        }

        return skyGroupId;
    }

    /**
     * Returns the sky group for the given ID at {@link SkyGroup#DEFAULT_SEASON}
     * . This method caches The {@link SkyGroup} table for quick access so this
     * object should be kept around when possible.
     * 
     * @param skyGroupId the sky group ID
     * @return a sky group, or null if the table is empty, or an invalid sky
     * group ID is given
     * @throws IllegalArgumentException if there there isn't a {@link SkyGroup}
     * in the database that matches the parameters
     */
    public SkyGroup skyGroupFor(int skyGroupId) {
        return skyGroupFor(skyGroupId, SkyGroup.DEFAULT_SEASON);
    }

    /**
     * Returns the sky group for the given ID in the given season. This method
     * caches The {@link SkyGroup} table for quick access so this object should
     * be kept around when possible.
     * 
     * @param skyGroupId the sky group ID
     * @param season the season
     * @return a sky group
     * @throws IllegalArgumentException if there there isn't a {@link SkyGroup}
     * in the database that matches the parameters
     */
    public SkyGroup skyGroupFor(int skyGroupId, int season) {
        if (skyGroupIdMap == null) {
            createSkyGroupMap();
        }

        SkyGroup skyGroup = skyGroupMap.get(generateIdSeasonKey(skyGroupId,
            season));

        if (skyGroup == null) {
            throw new IllegalArgumentException("No sky group for sky group ID "
                + skyGroupId + " and observing season " + season);
        }

        return skyGroup;
    }

    private void createSkyGroupMap() {
        skyGroupIdMap = new HashMap<Integer, Integer>();
        skyGroupMap = new HashMap<Integer, SkyGroup>();
        for (SkyGroup skyGroup : kicCrud.retrieveAllSkyGroups()) {
            int key = generateModuleOutputSeasonKey(skyGroup.getCcdModule(),
                skyGroup.getCcdOutput(), skyGroup.getObservingSeason());
            skyGroupIdMap.put(key, skyGroup.getSkyGroupId());
            key = generateIdSeasonKey(skyGroup.getSkyGroupId(),
                skyGroup.getObservingSeason());
            skyGroupMap.put(key, skyGroup);
        }
    }

    private int generateModuleOutputSeasonKey(int ccdModule, int ccdOutput,
        int season) {

        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + ccdModule;
        result = PRIME * result + ccdOutput;
        result = PRIME * result + season;

        return result;
    }

    private int generateIdSeasonKey(int skyGroupId, int season) {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + skyGroupId;
        result = PRIME * result + season;

        return result;
    }
}
