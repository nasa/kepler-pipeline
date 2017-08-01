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

package gov.nasa.kepler.hibernate.cm;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.spiffy.common.collect.ListChunkIterator;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Criteria;
import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.criterion.Disjunction;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Restrictions;

/**
 * Data access operations for target selection objects.
 * 
 * @author Bill Wohler
 */
public class TargetSelectionCrud extends AbstractCrud implements
    TargetSelectionCrudInterface {

    private static final Log log = LogFactory.getLog(TargetSelectionCrud.class);

    /**
     * Creates a new {@link TargetSelectionCrud} object.
     */
    public TargetSelectionCrud() {
    }

    /**
     * Creates a new {@link TargetSelectionCrud} object with the specified
     * database service.
     * 
     * @param databaseService the {@link DatabaseService} to use for the
     * operations
     */
    public TargetSelectionCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    @Override
    public void create(TargetList targetList) {
        getSession().save(targetList);
    }

    @Override
    public TargetList retrieveTargetList(String name) {
        Query query = getSession().createQuery(
            "from TargetList where name = :name");
        query.setParameter("name", name);

        return uniqueResult(query);
    }

    @Override
    public List<TargetList> retrieveAllTargetLists() {
        Criteria query = getSession().createCriteria(TargetList.class);
        query.addOrder(Order.asc("name"));
        List<TargetList> targetLists = list(query);

        return targetLists;
    }

    @Override
    public List<Integer> retrieveKeplerIdsForTargetListName(
        List<String> targetListNames) {

        return retrieveKeplerIdsForTargetListName(targetListNames, 0,
            Integer.MAX_VALUE);
    }

    @Override
    public List<TargetList> retrieveTargetListsForUplinkedTargetTables() {
        String s = "select distinct t.targetLists from TargetListSet t "
            + " where t.targetTable.state =  :stateParam";
        Query query = getSession().createQuery(s);
        query.setParameter("stateParam", ExportTable.State.UPLINKED);

        List<TargetList> targetLists = list(query);
        return targetLists;
    }

    public List<Integer> retrieveKeplerIdsForTargetListNameMatlabFriendly(
        List<String> targetListNames, int skyGroupId) {

        int startKeplerId = 0;
        int endKeplerId = Integer.MAX_VALUE;

        if (targetListNames.size() == 0) {
            List<Integer> empty = Collections.emptyList();
            return empty;
        }
        StringBuilder queryString = new StringBuilder(128);
        queryString.append("select distinct keplerId from PlannedTarget pt\n"
            + "where keplerId >= :startKeplerId and\n"
            + " pt.skyGroupId = :skyGroupId and\n"
            + " keplerId <= :endKeplerId and\n"
            + " pt.targetList in\n"
            + "   (select elements(tlset.targetLists) from\n"
            + "       TargetListSet tlset where tlset.targetTable.state = :stateParam)\n"
            + " and targetList.name in (\n");

        for (int i = 0; i < targetListNames.size(); i++) {
            queryString.append(":tl")
                .append(i)
                .append(',');
        }
        queryString.setLength(queryString.length() - 1);
        queryString.append(")\n order by keplerId");

        Query query = getSession().createQuery(queryString.toString());
        query.setInteger("startKeplerId", startKeplerId);
        query.setInteger("endKeplerId", endKeplerId);
        query.setInteger("skyGroupId", skyGroupId);

        query.setParameter("stateParam", ExportTable.State.UPLINKED);

        for (int i = 0; i < targetListNames.size(); i++) {
            query.setString("tl" + i, targetListNames.get(i));
        }

        if (log.isDebugEnabled()) {
            log.debug(queryString);
        }
        List<Integer> keplerIds = list(query);

        return keplerIds;
    }

    @Override
    public List<Integer> retrieveKeplerIdsForTargetListName(
        List<String> targetListNames, int startKeplerId, int endKeplerId) {

        return retrieveKeplerIdsForTargetListName(targetListNames, -1, false,
            startKeplerId, endKeplerId);
    }

    @Override
    public List<Integer> retrieveKeplerIdsForTargetListName(
        List<String> targetListNames, int skyGroupId, int startKeplerId,
        int endKeplerId) {

        return retrieveKeplerIdsForTargetListName(targetListNames, skyGroupId,
            true, startKeplerId, endKeplerId);
    }

    /**
     * Returns the unique set of category names used by the specified
     * {@link TargetListSet}
     * 
     * @param targetListSetName
     * @return
     */
    public List<String> retrieveCategoriesForTargetListSet(
        String targetListSetName) {
        Query query = getSession().createSQLQuery(
            "select distinct(tl.category)"
                + " from CM_TARGET_LIST tl, CM_TLS_TL tlstl, CM_TARGET_LIST_SET tls"
                + " where tl.ID = tlstl.CM_TARGET_LIST_ID and tlstl.CM_TARGET_LIST_SET_ID = tls.id"
                + " and tls.NAME = :tlsName");

        query.setString("tlsName", targetListSetName);

        List<String> categories = list(query);

        return categories;
    }

    private List<Integer> retrieveKeplerIdsForTargetListName(
        List<String> targetListNames, int skyGroupId, boolean useSkyGroupId,
        int startKeplerId, int endKeplerId) {

        if (targetListNames.size() == 0) {
            List<Integer> empty = Collections.emptyList();
            return empty;
        }
        StringBuilder queryString = new StringBuilder(128);
        queryString.append("select distinct keplerId from PlannedTarget pt\n")
            .append("where keplerId >= :startKeplerId and\n")
            .append(" keplerId <= :endKeplerId and\n");
        if (useSkyGroupId) {
            queryString.append(" pt.skyGroupId = :skyGroupIdParam and\n");
        }
        queryString.append(" targetList.name in (\n");

        for (int i = 0; i < targetListNames.size(); i++) {
            queryString.append(":tl")
                .append(i)
                .append(',');
        }
        queryString.setLength(queryString.length() - 1);
        queryString.append(")\n order by keplerId");

        Query query = getSession().createQuery(queryString.toString());
        query.setInteger("startKeplerId", startKeplerId);
        query.setInteger("endKeplerId", endKeplerId);
        if (useSkyGroupId) {
            query.setInteger("skyGroupIdParam", skyGroupId);
        }

        for (int i = 0; i < targetListNames.size(); i++) {
            query.setString("tl" + i, targetListNames.get(i));
        }

        if (log.isDebugEnabled()) {
            log.debug(queryString);
        }
        List<Integer> keplerIds = list(query);

        return keplerIds;
    }

    @Override
    public int targetListCount() {
        Query query = getSession().createQuery(
            "select count(name) from TargetList");
        int count = ((Long) query.iterate()
            .next()).intValue();

        return count;
    }

    @Override
    public void delete(TargetList targetList) {
        deletePlannedTargets(targetList);
        getSession().delete(targetList);
    }

    @Override
    public void create(Collection<PlannedTarget> targets) {
        Session session = getSession();
        for (PlannedTarget target : targets) {
            // Force the save with evict because the bulk delete operation in
            // deletePlannedTargets will delete an object in the database but
            // Hibernate will be unaware of this. The effect is that a later
            // call to this create method will not push the object to the
            // database even though it might no longer be in the database,
            session.evict(target);
            session.save(target);
        }
    }

    @Override
    public List<PlannedTarget> retrievePlannedTargets(TargetList targetList) {
        Query query = getSession().createQuery(
            "from PlannedTarget where targetList = :targetList "
                + "order by keplerId");
        query.setParameter("targetList", targetList);
        List<PlannedTarget> targets = list(query);

        return targets;
    }

    public List<PlannedTarget> retrievePlannedTargets(TargetList targetList,
        int skyGroupId) {
        Query query = getSession().createQuery(
            "from PlannedTarget where targetList = :targetList "
                + "and skyGroupId = :skyGroupId " + "order by keplerId");
        query.setParameter("targetList", targetList);
        query.setParameter("skyGroupId", skyGroupId);
        List<PlannedTarget> targets = list(query);

        return targets;
    }

    /**
     * Retrieves a list of {@link PlannedTarget}s for each of the given Kepler
     * IDs. If a given Kepler ID is not present in any target list, then it will
     * not have an entry in the map.
     * 
     * @param keplerIds a non-{@code null} list of Kepler IDs
     * @return a non-{@code null} map of a Kepler ID to a list of
     * {@link PlannedTarget}s
     * @throws NullPointerException if {@code keplerIds} is {@code null}
     * @throws HibernateException if there were problems retrieving the
     * {@link PlannedTarget} objects
     */
    public Map<Integer, List<PlannedTarget>> retrievePlannedTargets(
        Set<Integer> keplerIds) {

        if (keplerIds.size() == 0) {
            return Collections.emptyMap();
        }

        Map<Integer, List<PlannedTarget>> plannedTargetsByKeplerId = new HashMap<Integer, List<PlannedTarget>>(
            keplerIds.size());

        ListChunkIterator<Integer> keplerIdIterator = new ListChunkIterator<Integer>(
            keplerIds.iterator(), MAX_EXPRESSIONS);

        while (keplerIdIterator.hasNext()) {
            addPlannedTargetsToMap(plannedTargetsByKeplerId,
                retrievePlannedTargetsIntern(keplerIdIterator.next()));
        }

        return plannedTargetsByKeplerId;
    }

    private List<PlannedTarget> retrievePlannedTargetsIntern(
        List<Integer> keplerIds) {

        Criteria query = createCriteria(PlannedTarget.class);
        query.add(Restrictions.in("keplerId", keplerIds));
        query.addOrder(Order.asc("keplerId"));

        List<PlannedTarget> plannedTargets = list(query);

        return plannedTargets;
    }

    private void addPlannedTargetsToMap(
        Map<Integer, List<PlannedTarget>> plannedTargetByKeplerId,
        List<PlannedTarget> plannedTargets) {

        for (PlannedTarget plannedTarget : plannedTargets) {
            int keplerId = plannedTarget.getKeplerId();
            List<PlannedTarget> targets = plannedTargetByKeplerId.get(keplerId);
            if (targets == null) {
                targets = new ArrayList<PlannedTarget>();
                plannedTargetByKeplerId.put(keplerId, targets);
            }
            targets.add(plannedTarget);
        }
    }

    /**
     * Retrieves all {@link PlannedTarget}s that match the input criteria.
     * 
     * This method assumes that labelsAndCategoriesAreSubstrings = false (i.e.
     * labels and categories are matched as exact names)
     * <p>
     * 
     * @param targetListSetName the {@link TargetListSet} name
     * @param labels the {@link List} of labels
     * @param categories the {@link List} of categories
     * @return {@link PlannedTarget}s
     */
    public List<PlannedTarget> retrievePlannedTargets(String targetListSetName,
        List<String> labels, List<String> categories) {
        return retrievePlannedTargets(targetListSetName, labels, categories,
            false);
    }

    /**
     * Retrieves all {@link PlannedTarget}s that match the input criteria.
     * 
     * @param targetListSetName the {@link TargetListSet} name
     * @param labels the {@link List} of labels
     * @param categories the {@link List} of categories
     * @param labelsAndCategoriesAreSubstrings indicates whether the inputs
     * should be matched as exact names or as substrings of labels/categories
     * @return {@link PlannedTarget}s
     */
    public List<PlannedTarget> retrievePlannedTargets(String targetListSetName,
        List<String> labels, List<String> categories,
        boolean labelsAndCategoriesAreSubstrings) {
        TargetListSet targetListSet = retrieveTargetListSet(targetListSetName);
        if (targetListSet == null) {
            throw new IllegalArgumentException(
                "The target list set name must exist in the database.\n  targetListSetName: "
                    + targetListSetName);
        }

        List<PlannedTarget> targets = new ArrayList<PlannedTarget>();

        if (labelsAndCategoriesAreSubstrings) {
            targets.addAll(retrievePlannedTargetsSubstringInputs("targetLists",
                targetListSetName, labels, categories));
            targets.addAll(retrievePlannedTargetsSubstringInputs(
                "excludedTargetLists", targetListSetName, labels, categories));
        } else {
            targets.addAll(retrievePlannedTargetsExactStringInputs(
                "targetLists", targetListSetName, labels, categories));
            targets.addAll(retrievePlannedTargetsExactStringInputs(
                "excludedTargetLists", targetListSetName, labels, categories));
        }

        return targets;
    }

    private List<PlannedTarget> retrievePlannedTargetsSubstringInputs(
        String tlsJoinTable, String targetListSetName, List<String> labels,
        List<String> categories) {
        Query query = getSession().createQuery(
            "from PlannedTarget pt, TargetListSet tls "
                + "inner join fetch pt.targetList tl "
                + "inner join fetch tls." + tlsJoinTable + " tlstl "
                + "inner join fetch pt.labels label "
                + "where tls.name = :targetListSetName " + "and tl = tlstl "
                + getLikeQueryString("label", labels)
                + getLikeQueryString("tl.category", categories)
                + " order by pt.keplerId");
        query.setParameter("targetListSetName", targetListSetName);
        List<Object[]> results = list(query);

        List<PlannedTarget> targets = new ArrayList<PlannedTarget>();
        for (Object[] result : results) {
            PlannedTarget plannedTarget = (PlannedTarget) result[0];
            if (!targets.contains(plannedTarget)) {
                targets.add(plannedTarget);
            }
        }

        return targets;
    }

    private String getLikeQueryString(String field, List<String> patterns) {
        StringBuilder likeQueryString = new StringBuilder();
        likeQueryString.append(" ");
        if (!patterns.isEmpty()) {
            likeQueryString.append("and (");
            for (String pattern : patterns) {
                likeQueryString.append(field)
                    .append(" like '%")
                    .append(pattern)
                    .append("%' or ");
            }
            // Trim the last " or "
            likeQueryString.setLength(likeQueryString.length() - 4);
            likeQueryString.append(") ");
        }

        return likeQueryString.toString();
    }

    private List<PlannedTarget> retrievePlannedTargetsExactStringInputs(
        String tlsJoinTable, String targetListSetName, List<String> labels,
        List<String> categories) {
        String labelsStringForQuery = " ";
        if (!labels.isEmpty()) {
            labelsStringForQuery = "and label in (:labels) ";
        }

        String categoriesStringForQuery = " ";
        if (!categories.isEmpty()) {
            categoriesStringForQuery = "and tl.category in (:categories) ";
        }

        Query query = getSession().createQuery(
            "from PlannedTarget pt, TargetListSet tls "
                + "inner join fetch pt.targetList tl "
                + "inner join fetch tls." + tlsJoinTable + " tlstl "
                + "inner join fetch pt.labels label "
                + "where tls.name = :targetListSetName " + "and tl = tlstl "
                + labelsStringForQuery + categoriesStringForQuery
                + " order by pt.keplerId");
        query.setParameter("targetListSetName", targetListSetName);
        if (!labels.isEmpty()) {
            query.setParameterList("labels", labels);
        }
        if (!categories.isEmpty()) {
            query.setParameterList("categories", categories);
        }
        List<Object[]> results = list(query);

        List<PlannedTarget> targets = new ArrayList<PlannedTarget>();
        for (Object[] result : results) {
            PlannedTarget plannedTarget = (PlannedTarget) result[0];
            if (!targets.contains(plannedTarget)) {
                targets.add(plannedTarget);
            }
        }

        return targets;
    }

    @Override
    public List<PlannedTarget> retrieveRejectedPlannedTargets(
        TargetListSet targetListSet) {

        Query query = getSession().createQuery(
            "from ObservedTarget where " + "targetTable = :targetTable and "
                + "rejected = true ");
        query.setParameter("targetTable", targetListSet.getTargetTable());
        List<ObservedTarget> rejectedObservedTargets = list(query);

        Set<Integer> rejectedKeplerIds = new HashSet<Integer>();
        for (ObservedTarget observedTarget : rejectedObservedTargets) {
            rejectedKeplerIds.add(observedTarget.getKeplerId());
        }

        List<PlannedTarget> rejectedPlannedTargets = new ArrayList<PlannedTarget>();
        for (TargetList targetList : targetListSet.getTargetLists()) {
            List<PlannedTarget> plannedTargets = retrievePlannedTargets(targetList);
            for (PlannedTarget plannedTarget : plannedTargets) {
                if (rejectedKeplerIds.contains(plannedTarget.getKeplerId())) {
                    rejectedPlannedTargets.add(plannedTarget);
                }
            }
        }

        return rejectedPlannedTargets;
    }

    @Override
    public int plannedTargetCount(TargetList targetList) {
        Query query = getSession().createQuery(
            "select count(id) from PlannedTarget where targetList = :targetList");
        query.setParameter("targetList", targetList);

        int count = ((Long) query.iterate()
            .next()).intValue();

        return count;
    }

    @Override
    public void deletePlannedTargets(TargetList targetList) {
        // Delete PlannedTarget's labels manually since bulk operations are not
        // currently aware of associations. Maybe this can be done with a
        // trigger like "cascade delete"?
        Query query = getSession().createSQLQuery(
            "delete from CM_PT_LABELS where PLANNED_TARGET_ID in "
                + "(select ID from CM_PLANNED_TARGET where TARGET_LIST_ID = :targetList)");
        query.setParameter("targetList", targetList);
        query.executeUpdate();

        // Ditto.
        // TODO need to delete from the aperture table.
        // query = dbService.getSession()
        // .createSQLQuery(
        // "delete from CM_PLANNED_TARGET_OFFSETS where CM_PLANNED_TARGET_ID in
        // "
        // + "(select ID from CM_PLANNED_TARGET where TARGET_LIST_ID =
        // :targetList)");
        // query.setParameter("targetList", targetList);
        // query.executeUpdate();

        query = getSession().createQuery(
            "delete from PlannedTarget where targetList = :targetList");
        query.setParameter("targetList", targetList);
        query.executeUpdate();
    }

    @Override
    public void create(TargetListSet targetListSet) {
        getSession().save(targetListSet);
    }

    @Override
    public TargetListSet retrieveTargetListSet(String name) {
        Query query = getSession().createQuery(
            "from TargetListSet where name = :name");
        query.setParameter("name", name);

        return uniqueResult(query);
    }

    @Override
    public TargetListSet retrieveTargetListSet(long id) {
        Query query = getSession().createQuery(
            "from TargetListSet where id = :id");
        query.setParameter("id", id);

        return uniqueResult(query);
    }

    @Override
    public List<TargetListSet> retrieveTargetListSets(State state) {
        return retrieveTargetListSets(state, state);
    }

    @Override
    public List<TargetListSet> retrieveTargetListSets(State lowState,
        State highState) {

        boolean addingStates = false;
        Disjunction disjunction = Restrictions.disjunction();
        for (State state : State.values()) {
            if (state == lowState) {
                addingStates = true;
            }
            if (addingStates) {
                disjunction.add(Restrictions.eq("state", state));
            }
            if (state == highState) {
                break;
            }
        }

        Criteria query = getSession().createCriteria(TargetListSet.class);
        query.add(disjunction);
        query.addOrder(Order.asc("name"));

        List<TargetListSet> targetListSets = list(query);

        return targetListSets;
    }

    @Override
    public List<TargetListSet> retrieveTargetListSets(MaskTable maskTable) {
        Query query = getSession().createQuery(
            "from TargetListSet as tls where tls.targetTable.maskTable = :maskTable");
        query.setParameter("maskTable", maskTable);

        List<TargetListSet> result = list(query);

        return result;
    }

    @Override
    public List<TargetListSet> retrieveTargetListSets(
        TargetListSet targetListSet) {
        Query query = getSession().createQuery(
            "from TargetListSet as tls where tls.associatedLcTls = :targetListSet");
        query.setParameter("targetListSet", targetListSet);

        List<TargetListSet> result = list(query);

        return result;
    }

    @Override
    public TargetListSet retrieveTargetListSetByTargetTable(
        TargetTable targetTable) {

        Query query = getSession().createQuery(
            "from TargetListSet where targetTable = :targetTable");
        query.setParameter("targetTable", targetTable);

        return uniqueResult(query);
    }

    @Override
    public List<TargetListSet> retrieveTargetListSets(Collection<String> names,
        TargetTable.TargetType targetType) {
        if (names.size() == 0) {
            return Collections.emptyList();
        }

        StringBuilder bldr = new StringBuilder("from TargetListSet tls where "
            + "tls.type = :targetType and tls.name in (");
        for (int i = 0; i < names.size(); i++) {
            bldr.append(":tlname" + i)
                .append(',');
        }
        bldr.setLength(bldr.length() - 1);
        bldr.append(')');

        Query query = getSession().createQuery(bldr.toString());
        query.setParameter("targetType", targetType);
        int i = 0;
        for (String name : names) {
            query.setParameter("tlname" + i, name);
            i++;
        }

        List<TargetListSet> rv = list(query);
        return rv;

    }

    public List<TargetListSet> retrieveReferencingTls(TargetList existingTl) {

        Query query = getSession().createSQLQuery(
            "select CM_TARGET_LIST_SET_ID from CM_TLS_TL where CM_TARGET_LIST_ID = :tlId");
        query.setParameter("tlId", existingTl.getId());

        List<Number> idList = list(query);

        List<TargetListSet> results = new LinkedList<TargetListSet>();

        for (Number id : idList) {
            results.add(retrieveTargetListSet(id.longValue()));
        }

        return results;
    }

    public List<TargetListSet> retrieveAllTargetListSetsActive() {
        List<TargetListSet> targetListSets = newArrayList();
        for (TargetListSet targetListSet : retrieveAllTargetListSets()) {
            if (targetListSet.getSupplementalTls() != null) {
                targetListSets.add(targetListSet);
            }
        }

        return targetListSets;
    }

    @Override
    public List<TargetListSet> retrieveAllTargetListSets() {
        Criteria query = getSession().createCriteria(TargetListSet.class);
        query.addOrder(Order.asc("name"));
        List<TargetListSet> targetListSets = list(query);

        return targetListSets;
    }

    @Override
    public int targetListSetCount() {
        Query query = getSession().createQuery(
            "select count(name) from TargetListSet");
        int count = ((Long) query.iterate()
            .next()).intValue();

        return count;
    }

    @Override
    public void delete(TargetListSet targetListSet) {
        getSession().delete(targetListSet);
    }
}
