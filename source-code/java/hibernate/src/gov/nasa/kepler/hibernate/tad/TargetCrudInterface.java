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

package gov.nasa.kepler.hibernate.tad;

import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.*;

import javax.persistence.NonUniqueResultException;

import org.hibernate.HibernateException;

/**
 * 
 * @author Sean McCauliff
 * @author Todd Klaus
 * @author Forrest Girouard
 *
 */
public interface TargetCrudInterface {

    /**
     * Returns a single {@link TargetTableLog} that falls within the given
     * cadence range.
     * 
     * @param targetTableType the target table type.
     * @param startCadence the beginning cadence.
     * @param endCadence the end cadence.
     * @return a single {@link TargetTableLog}, or {@code null} if there
     * weren't any {@link TargetTableLog}s that fell within the given cadence
     * range.
     * @throws NonUniqueResultException if there were multiple
     * {@link TargetTableLog}s within the given cadence range.
     * @throws HibernateException if there were problems accessing the database.
     * @throws PipelineException if there were other errors in the query, but
     * not related to the database access itself.
     */
    TargetTableLog retrieveTargetTableLog(TargetType targetTableType,
        int cadenceStart, int cadenceEnd);

    /**
     * @param should be a target table which is not up
     * @return All the keplerIds of non-rejected targets
     */
    List<Integer> retrieveObservedKeplerIds(TargetTable ttable);

    List<TargetTableLog> retrieveTargetTableLogs(TargetType targetTableType,
        int cadenceStart, int cadenceEnd);

    List<TargetDefinition> retrieveTargetDefinitions(TargetTable targetTable,
        int ccdModule, int ccdOutput);

    void createTargetTable(TargetTable targetTable);

    TargetTable retrieveTargetTable(long id);

    List<TargetTable> retrieveTargetTables(TargetType type);

    TargetTable retrieveUplinkedTargetTable(int externalId, TargetType type);

    TargetTable retrieveTargetTable(int externalId, TargetType type, ExportTable.State state);

    List<TargetTable> retrieveUplinkedTargetTables(Date start, Date end);

    List<TargetTable> retrieveUplinkedTargetTables(TargetType type);

    /**
     * 
     * @param startUtc TargetTable.plannedStartTime >= startUtc
     * @param stopUtc TargetTable.plannedEndTime <= endUtc
     * @return This returns an Iterator instead of something else so we can
     * reduce memory consumption.
     */
    List<KtcInfo> retrieveKtcInfo(Date startUtc, Date stopUtc);

    /**
     * 
     * @param tableType the table type to use when querying the table.
     * @return A list of uplinked target tables ordered by target table external
     * id.
     */
    List<Integer> retrieveOrderedExternalIds(TargetType tableType);

    /**
     * 
     * @param observedTargetId This is the internal database id for an observed
     * target.
     * @param targetTableId This is the internal database id for a target table.
     * @return A distinct list of categories from all the TargetLists mentioning
     * an observed target with the same Kepler ID as the observed target in
     * ascending sorted order.
     */
    List<String> retrieveCategoriesForTarget(long observedTargetId,
        long targetTableId);

    /**
     * Get all the categories for all the targets in the target table.
     * @param ttable
     * @return
     */

    Map<Long, List<String>> retrieveCategoriesForTargetTable(TargetTable ttable);

    /**
     * 
     * @param targetTable
     */

    void delete(TargetTable targetTable);

    Set<Integer> retrieveUplinkedExternalIds(TargetType type);

    Set<Integer> retrieveExternalIdsInUse(TargetType type);

    void createMaskTable(MaskTable maskTable);

    MaskTable retrieveMaskTable(long id);

    MaskTable retrieveUplinkedMaskTable(int externalId, MaskType type);

    void delete(MaskTable maskTable);

    Set<Integer> retrieveUplinkedExternalIds(MaskType type);

    Set<Integer> retrieveExternalIdsInUse(MaskType type);

    List<MaskTable> retrieveMaskTableForTargetTable(TargetTable ttable,
        MaskType mType);

    void createObservedTargets(Collection<ObservedTarget> observedTargets);

    void createObservedTarget(ObservedTarget observedTarget);

    List<ObservedTarget> retrieveObservedTargetsPlusRejected(
        TargetTable targetTable);

    List<ObservedTarget> retrieveObservedTargetsPlusRejected(
        TargetTable targetTable, int ccdModule, int ccdOutput);

    List<ObservedTarget> retrieveObservedTargets(TargetTable targetTable);

    /**
     * Retrieve the target tables associated with this specified PixelLog.
     * @param ttable 
     * @return
     */
    List<TargetTable> retrieveLongCadenceTargetTable(TargetTable ttable);

    /**
     * Retrieve the target tables associated with this specified target table.
     * For example find the short cadence target tables that where in effect
     * during the time the specified long cadence target table was in effect.
     * Or the other way around.
     * 
     * @param ttable 
     * @return
     */
    List<TargetTable> retrieveShortCadenceTargetTable(TargetTable ttable);

    /**
     * Gets the background target table associated with the specified target table.
     * @param ttable some target table
     * @return 
     */
    List<TargetTable> retrieveBackgroundTargetTable(TargetTable ttable);

    List<ObservedTarget> retrieveObservedTargets(TargetTable targetTable,
        int ccdModule, int ccdOutput);

    void createMasks(Collection<Mask> masks);

    void createMask(Mask mask);

    List<Mask> retrieveMasks(MaskTable maskTable);

    Image retrieveImage(TargetTable targetTable, int ccdModule, int ccdOutput);

    void deleteSupermasks(MaskTable maskTable);

    /**
     *
     * @param ttables The target tables have targets with interesting crowding
     * metrics.
     * @return  A map of (keplerId) -> (crowdingMetric_table0, ... crowdingMetric_tableN)
     * If a crowding metric does not exist for a target table and keplerId then
     * that position is null.  Where target tables have incresing ids.
     */
    public Map<Integer, TargetCrowdingInfo> retrieveCrowdingMetricInfo(
        List<TargetTable> ttables, int skyGroupId);

    List<String> retrieveLabelsForObservedTarget(long observedTargetDbId);

}