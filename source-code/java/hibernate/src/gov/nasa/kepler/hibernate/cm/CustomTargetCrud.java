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

import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.spiffy.common.collect.ListChunkIterator;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Criteria;
import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Projections;
import org.hibernate.criterion.Restrictions;

/**
 * This is the CRUD class for {@link CustomTarget}s.
 * 
 * @author Miles Cote
 */
public class CustomTargetCrud extends AbstractCrud implements
    CelestialObjectCrud {

    private static final Log log = LogFactory.getLog(CustomTargetCrud.class);

    public CustomTargetCrud() {
        super(null);
    }

    public CustomTargetCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    public void create(CustomTarget customTarget) {
        getSession().save(customTarget);
    }

    public void create(Collection<CustomTarget> customTargets) {
        for (CustomTarget customTarget : customTargets) {
            getSession().save(customTarget);
        }
    }

    public CustomTarget retrieveCustomTarget(int keplerId) {
        Query query = getSession().createQuery(
            "from CustomTarget where " + "keplerId = :keplerId");
        query.setInteger("keplerId", keplerId);
        return uniqueResult(query);
    }

    public List<CustomTarget> retrieveCustomTargets(Collection<Integer> keplerIds) {
        if (keplerIds.size() == 0) {
            return Collections.emptyList();
        }

        Map<Integer, CustomTarget> customTargetByKeplerId = new HashMap<Integer, CustomTarget>(
            keplerIds.size());
        ListChunkIterator<Integer> keplerIdIterator = new ListChunkIterator<Integer>(
            keplerIds.iterator(), MAX_EXPRESSIONS);

        while (keplerIdIterator.hasNext()) {
            addCustomTargetsToMap(customTargetByKeplerId,
                retrieveCustomTargetsIntern(keplerIdIterator.next()));
        }

        List<CustomTarget> customTargets = new ArrayList<CustomTarget>(
            keplerIds.size());
        for (Integer keplerId : keplerIds) {
            customTargets.add(customTargetByKeplerId.get(keplerId));
        }

        return customTargets;
    }

    private List<CustomTarget> retrieveCustomTargetsIntern(
        List<Integer> keplerIds) {

        Criteria query = createCriteria(CustomTarget.class);
        query.add(Restrictions.in("keplerId", keplerIds));
        query.addOrder(Order.asc("keplerId"));

        List<CustomTarget> customTargets = list(query);

        return customTargets;
    }

    private void addCustomTargetsToMap(
        Map<Integer, CustomTarget> customTargetByKeplerId,
        List<CustomTarget> customTargets) {

        for (CustomTarget customTarget : customTargets) {
            customTargetByKeplerId.put(customTarget.getKeplerId(), customTarget);
        }
    }

    public int retrieveNextCustomTargetKeplerId() {
        // Not strictly necessary, but stay on the safe side.
        getSession().flush();

        Criteria query = getSession().createCriteria(CustomTarget.class);
        query.setProjection(Projections.max("keplerId"));
        Integer result = uniqueResult(query);

        int keplerId = TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START;
        if (result != null
            && result.intValue() >= TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START) {
            keplerId = result.intValue() + 1;
        }

        return keplerId;
    }

    /**
     * Retrieves Kepler IDs and their associated sky group IDs for all custom
     * targets on the focal plane. A list of arrays is returned. Each array
     * contains two {@link Object} objects (which are really {@link Integer}s)
     * that correspond to the Kepler ID and sky group ID respectively. This list
     * is sorted by ascending Kepler ID.
     * 
     * @return a non-{@code null} list of {@link Object} arrays
     * @throws HibernateException if there were problems accessing the database
     */
    public List<Object[]> retrieveAllVisibleKeplerSkyGroupIds() {
        Criteria query = getSession().createCriteria(CustomTarget.class);
        query.add(Restrictions.ne("skyGroupId", 0));
        query.addOrder(Order.asc("keplerId"));
        query.setProjection(Projections.projectionList()
            .add(Projections.property("keplerId"))
            .add(Projections.property("skyGroupId")));

        log.info("Retrieving custom target Kepler and sky group IDs");
        long start = System.currentTimeMillis();
        List<Object[]> ids = list(query);
        log.info("Query took " + (System.currentTimeMillis() - start) + " ms");

        return ids;
    }

    public boolean exists(int keplerId) {
        Query query = getSession().createQuery(
            "select count(keplerId) from CustomTarget where keplerId = :keplerId");
        query.setParameter("keplerId", keplerId);
        int count = ((Long) query.iterate()
            .next()).intValue();

        return count > 0;
    }

    /**
     * Gets the number of {@link CustomTarget} entries.
     * 
     * @return the number of {@link CustomTarget} entries
     * @throws HibernateException if there were problems retrieving the count of
     * {@link CustomTarget} objects
     */
    public int customTargetCount() {
        Query query = getSession().createQuery(
            "select count(keplerId) from CustomTarget");
        int count = ((Long) query.iterate()
            .next()).intValue();

        return count;
    }

    /**
     * Gets the number of {@link CustomTarget} entries that are on the focal
     * plane.
     * 
     * @return the number of {@link CustomTarget} entries that are on the focal
     * plane
     * @throws HibernateException if there were problems retrieving the count of
     * {@link CustomTarget} objects
     */
    public int visibleCustomTargetCount() {
        Query query = getSession().createQuery(
            "select count(keplerId) from CustomTarget where skyGroupId != 0");
        int count = ((Long) query.iterate()
            .next()).intValue();

        return count;
    }

    @Override
    public List<CelestialObject> retrieveForKeplerId(int keplerId) {
        CustomTarget customTarget = retrieveCustomTarget(keplerId);

        List<CelestialObject> celestialObjects = new ArrayList<CelestialObject>();
        if (customTarget != null) {
            celestialObjects.add(customTarget);
        }

        return celestialObjects;
    }

    @Override
    public List<CelestialObject> retrieveForSkyGroupId(int skyGroupId) {
        Query query = createQuery("from CustomTarget where skyGroupId = :skyGroupId order by keplerId");
        query.setParameter("skyGroupId", skyGroupId);

        List<CelestialObject> customTargets = list(query);

        return customTargets;
    }

    @Override
    public List<CelestialObject> retrieve(int minKeplerId, int maxKeplerId) {
        Query query = createQuery("from CustomTarget where keplerId >= :minKeplerId and keplerId <= :maxKeplerId "
            + "order by keplerId");
        query.setParameter("minKeplerId", minKeplerId);
        query.setParameter("maxKeplerId", maxKeplerId);

        List<CelestialObject> customTargets = list(query);

        return customTargets;
    }

    @Override
    public List<CelestialObject> retrieve(int skyGroupId, int minKeplerId,
        int maxKeplerId) {
        Query query = createQuery("from CustomTarget where skyGroupId = :skyGroupId and keplerId >= :minKeplerId and keplerId <= :maxKeplerId "
            + "order by keplerId");
        query.setParameter("skyGroupId", skyGroupId);
        query.setParameter("minKeplerId", minKeplerId);
        query.setParameter("maxKeplerId", maxKeplerId);

        List<CelestialObject> customTargets = list(query);

        return customTargets;
    }

    @Override
    public List<CelestialObject> retrieve(Collection<Integer> keplerIds) {
        return new ArrayList<CelestialObject>(retrieveCustomTargets(keplerIds));
    }

    /*
     * (non-Javadoc)
     * 
     * @see gov.nasa.kepler.hibernate.cm.CelestialObjectCrud#retrieve(int,
     * float, float) Note: CustomTargets in the database do not have magnitudes
     * stored with them. Therefore, the magnitude range cannot be used to query
     * the CustomTarget table.
     */
    @Override
    public List<CelestialObject> retrieve(int skyGroupId, float minKeplerMag,
        float maxKeplerMag) {
        return retrieveForSkyGroupId(skyGroupId);
    }

    @Override
    public Map<Integer, Integer> retrieveSkyGroupIdsForKeplerIds(
        List<Integer> keplerIds) {
        if (keplerIds.isEmpty()) {
            return Collections.emptyMap();
        }

        Map<Integer, Integer> skyGroupIdByKeplerId = new HashMap<Integer, Integer>();

        ListChunkIterator<Integer> keplerIdIterator = new ListChunkIterator<Integer>(
            keplerIds.iterator(), MAX_EXPRESSIONS);
        while (keplerIdIterator.hasNext()) {
            StringBuilder queryString = new StringBuilder(
                "select new gov.nasa.spiffy.common.collect.Pair(keplerId, skyGroupId) from CustomTarget "
                    + " where keplerId in (");
            for (int keplerId : keplerIdIterator.next()) {
                queryString.append(keplerId)
                    .append(',');
            }
            queryString.setLength(queryString.length() - 1);
            queryString.append(')');

            Query query = createQuery(queryString.toString());

            List<Pair<Integer, Integer>> keplerIdsSkyGroups = list(query);

            for (Pair<Integer, Integer> skyGroupIdKeplerId : keplerIdsSkyGroups) {
                skyGroupIdByKeplerId.put(skyGroupIdKeplerId.left,
                    skyGroupIdKeplerId.right);
            }
        }

        return skyGroupIdByKeplerId;
    }

    @Override
    public List<Integer> retrieveKeplerIds(int skyGroupId, int minKeplerId,
        int maxKeplerId) {
        Query query = createQuery("select keplerId from CustomTarget where skyGroupId = :skyGroupId and keplerId >= :minKeplerId and keplerId <= :maxKeplerId "
            + "order by keplerId");
        query.setParameter("skyGroupId", skyGroupId);
        query.setParameter("minKeplerId", minKeplerId);
        query.setParameter("maxKeplerId", maxKeplerId);

        List<Integer> keplerIds = list(query);

        return keplerIds;
    }

}
