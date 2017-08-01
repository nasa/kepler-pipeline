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

import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.Canonicalizable;
import gov.nasa.kepler.hibernate.Constraint;
import gov.nasa.kepler.hibernate.cm.Kic.Field;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.hibernate.fc.RollTime;
import gov.nasa.spiffy.common.collect.ListChunkIterator;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Criteria;
import org.hibernate.HibernateException;
import org.hibernate.NonUniqueResultException;
import org.hibernate.Query;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Projections;
import org.hibernate.criterion.Restrictions;

/**
 * KIC object data access operations.
 * <p>
 * The delete function is deliberately omitted.
 * 
 * @author Bill Wohler
 * @author Thomas Han
 */
public class KicCrud extends AbstractCrud implements CelestialObjectCrud,
    SkyGroupCrud {

    private static final Log log = LogFactory.getLog(KicCrud.class);

    public static final int INVALID_CCD_MODULE = -1;
    public static final int INVALID_CCD_OUTPUT = -1;
    public static final int INVALID_SEASON = -1;

    private static final double DEGREES_PER_ARCSEC = 1.0 / 3600.0;
    private static final double HOURS_PER_DEGREE = 1.0 / 15.0;
    
    private boolean kicCacheEnabled = true;

    /**
     * Creates a new {@link KicCrud} object whose read-only property is set to
     * {@code true}.
     */
    public KicCrud() {
        super(true);
    }

    /**
     * Creates a new {@link KicCrud} object.
     * 
     * @param readOnly whether objects returned by this class are read-only (not
     * dirty-checked)
     */
    public KicCrud(boolean readOnly) {
        super(readOnly);
    }

    /**
     * Creates a new {@link KicCrud} object with the specified database service
     * and whose read-only property is set to {@code true}.
     * 
     * @param dbService the {@link DatabaseService} to use for the operations
     */
    public KicCrud(DatabaseService dbService) {
        super(dbService, true);
    }

    /**
     * Creates a new {@link KicCrud} object with the specified database service.
     * 
     * @param dbService the {@link DatabaseService} to use for the operations
     * @param readOnly whether objects returned by this class are read-only (not
     * dirty-checked)
     */
    public KicCrud(DatabaseService dbService, boolean readOnly) {
        super(dbService, readOnly);
    }

    public static final String getKicVersion() {
        return "10.0";
    }

    /**
     * Stores a new {@link Kic}.
     * 
     * @param kic the {@link Kic} object to store
     * @throws HibernateException if there were problems persisting the
     * {@link Kic} object
     */
    public void create(Kic kic) {
        getSession().save(kic);
    }

    /**
     * Stores a collection of {@link Kic}s.
     * 
     * @param kics the {@link Kic} objects to store
     * @throws HibernateException if there were problems persisting the
     * {@link Kic} objects
     */
    public void create(Collection<Kic> kics) {
        for (Kic kic : kics) {
            getSession().save(kic);
        }
    }

    public void delete(Kic kic) {
        getSession().delete(kic);
    }

    /**
     * Retrieves the {@link Kic} object for the given Kepler ID.
     * 
     * @param keplerId the ID of the desired record
     * @return the {@link Kic} object for the given ID, or {@code null} if there
     * aren't any such {@link Kic}s
     * @throws NonUniqueResultException if the database query returned more than
     * 1 result
     * @throws HibernateException if there were problems retrieving the
     * {@link Kic} object
     */
    public Kic retrieveKic(int keplerId) {
        Query query = createQuery("from Kic where keplerId = :keplerId");
        query.setParameter("keplerId", keplerId);

        return uniqueResult(query);
    }

    /**
     * Retrieves {@link Kic}s for the given module/output and season. If you
     * already have a sky group ID, use the faster method
     * {@link #retrieveKics(int)} instead.
     * <p>
     * Used by TAD's compute-optimal-apertures to get all {@link Kic} entries on
     * a module/output for a season.
     * 
     * @param ccdModule the module (1-25)
     * @param ccdOutput the output (1-4)
     * @param observingSeason the observing season (0-3)
     * @return a non-{@code null} list of {@link Kic}s
     * @throws IllegalArgumentException if there there isn't a {@link SkyGroup}
     * in the database that matches the parameters
     * @throws NonUniqueResultException if the database query returned more than
     * 1 result
     * @throws HibernateException if there were problems retrieving the
     * {@link Kic} objects
     */
    public List<Kic> retrieveKics(int ccdModule, int ccdOutput,
        int observingSeason) {

        int skyGroupId = retrieveSkyGroupId(ccdModule, ccdOutput,
            observingSeason);

        return retrieveKics(skyGroupId);
    }

    /**
     * Retrieves {@link Kic}s for the given sky group. This method is preferred
     * over {@link #retrieveKics(int, int, int)}.
     * 
     * @param skyGroupId the id of the {@link SkyGroup}
     * @return a non-{@code null} list of {@link Kic}s ordered by Kepler ID
     * @throws NonUniqueResultException if the database query returned more than
     * 1 result
     * @throws HibernateException if there were problems retrieving the
     * {@link Kic} objects
     */
    public List<Kic> retrieveKics(int skyGroupId) {
        List<Kic> kics = null;
        if (kicCacheEnabled) {
            kics = KicCache.getKics(skyGroupId);
        } else {
            kics = retrieveKicsInternal(skyGroupId);
        }
        
        return kics;
    }
    
    List<Kic> retrieveKicsInternal(int skyGroupId) {
        Query query = createQuery("from Kic where skyGroupId = :skyGroupId order by keplerId");
        query.setParameter("skyGroupId", skyGroupId);

        log.info("Submitting query: " + query);
        long start = System.currentTimeMillis();
        List<Kic> kics = list(query);
        log.info("Query took " + (System.currentTimeMillis() - start) + " ms");

        return kics;
    }

    /**
     * Returns the minimum and maximum of the Kepler IDs in the KIC. This is
     * useful for subdividing the contents of the KIC as the unit of work
     * generators must do.
     * 
     * @return a {@link Pair} containing the minimum and maximum Kepler IDs
     * @throws HibernateException if there were problems retrieving the Kepler
     * IDs
     */
    public Pair<Integer, Integer> retrieveKeplerIdRange() {
        Query q = createQuery("select min(keplerId), max(keplerId) from Kic");
        Object[] result = uniqueResult(q);

        Integer min = (Integer) result[0];
        Integer max = (Integer) result[1];

        return Pair.of(min, max);
    }

    /**
     * Retrieves {@link Kic}s for the given keplerId range. Used by unit of work
     * generators that need to subdivide the contents of the KIC
     * 
     * @param minKeplerId the minimum Kepler ID
     * @param maxKeplerId the maximum Kepler ID
     * @return a non-{@code null} list of {@link Kic}s
     * @throws HibernateException if there were problems retrieving the
     * {@link Kic} objects
     */
    public List<Kic> retrieveKics(int minKeplerId, int maxKeplerId) {
        Query query = createQuery("from Kic where keplerId >= :minKeplerId and keplerId <= :maxKeplerId "
            + "order by keplerId");
        query.setParameter("minKeplerId", minKeplerId);
        query.setParameter("maxKeplerId", maxKeplerId);
        List<Kic> kics = list(query);

        return kics;
    }

    /**
     * Retrieves {@link Kic}s for the given skyGroupId and keplerId range.
     * 
     * @param skyGroupId the skyGroupId
     * @param minKeplerId the minimum Kepler ID
     * @param maxKeplerId the maximum Kepler ID
     * @return a non-{@code null} list of {@link Kic}s
     * @throws HibernateException if there were problems retrieving the
     * {@link Kic} objects
     */
    public List<Kic> retrieveKicsForSkyGroupIdKeplerIdRange(int skyGroupId,
        int minKeplerId, int maxKeplerId) {
        Query query = createQuery("from Kic where skyGroupId = :skyGroupId and keplerId >= :minKeplerId and keplerId <= :maxKeplerId "
            + "order by keplerId");
        query.setParameter("skyGroupId", skyGroupId);
        query.setParameter("minKeplerId", minKeplerId);
        query.setParameter("maxKeplerId", maxKeplerId);

        List<Kic> kics = list(query);

        return kics;
    }

    /**
     * Retrieves {@link Kic}s for the given Kepler IDs. If a given Kepler ID is
     * not present in the KIC or identifies a custom target, then a {@code null}
     * object will be returned in its corresponding place in the returned list.
     * 
     * @param keplerIds a collection of Kepler IDs
     * @return a non-{@code null} list of {@link Kic}s in the same order as the
     * parameters
     * @throws HibernateException if there were problems retrieving the
     * {@link Kic} objects
     */
    public List<Kic> retrieveKics(Collection<Integer> keplerIds) {
        if (keplerIds.size() == 0) {
            return Collections.emptyList();
        }

        Map<Integer, Kic> kicByKeplerId = new HashMap<Integer, Kic>(
            keplerIds.size());
        ListChunkIterator<Integer> keplerIdIterator = new ListChunkIterator<Integer>(
            keplerIds.iterator(), MAX_EXPRESSIONS);

        while (keplerIdIterator.hasNext()) {
            addKicsToMap(kicByKeplerId,
                retrieveKicsIntern(keplerIdIterator.next()));
        }

        List<Kic> kics = new ArrayList<Kic>(keplerIds.size());
        for (Integer keplerId : keplerIds) {
            kics.add(kicByKeplerId.get(keplerId));
        }

        return kics;
    }

    private List<Kic> retrieveKicsIntern(List<Integer> keplerIds) {
        Criteria query = createCriteria(Kic.class);
        query.add(Restrictions.in("keplerId", keplerIds));
        query.addOrder(Order.asc("keplerId"));

        List<Kic> kics = list(query);

        return kics;
    }

    private void addKicsToMap(Map<Integer, Kic> kicByKeplerId, List<Kic> kics) {
        for (Kic kic : kics) {
            kicByKeplerId.put(kic.getKeplerId(), kic);
        }
    }

    /**
     * Retrieves {@link Kic}s for the given keplerId range and keplerMag range.
     * Used by the sandbox tools.
     * 
     * @param minKeplerId the minimum Kepler ID
     * @param maxKeplerId the maximum Kepler ID
     * @param minKeplerMag the minimum Kepler magnitude, inclusive
     * @param maxKeplerMag the maximum Kepler magnitude, inclusive
     * @return a non-{@code null} list of {@link Kic}s
     * @throws HibernateException if there were problems retrieving the
     * {@link Kic} objects
     */
    public List<Kic> retrieveKics(int minKeplerId, int maxKeplerId,
        float minKeplerMag, float maxKeplerMag) {
        Query query = createQuery("from Kic where "
            + "keplerId >= :minKeplerId and keplerId <= :maxKeplerId "
            + "and keplerMag >= :minKeplerMag and keplerMag <= :maxKeplerMag "
            + "order by keplerId");
        query.setParameter("minKeplerId", minKeplerId);
        query.setParameter("maxKeplerId", maxKeplerId);
        query.setFloat("minKeplerMag", minKeplerMag);
        query.setFloat("maxKeplerMag", maxKeplerMag);

        log.info("Submitting query: " + query);
        long start = System.currentTimeMillis();
        List<Kic> kics = list(query);
        log.info("Query took " + (System.currentTimeMillis() - start) + " ms");

        return kics;
    }

    /**
     * Retrieves {@link Kic}s for the given module/output, season and Kepler
     * magnitude range. Used by retrieve_kic MATLAB wrapper.
     * 
     * @param ccdModule the module (1-25)
     * @param ccdOutput the output (1-4)
     * @param observingSeason the observing season (0-3)
     * @param minKeplerMag the minimum Kepler magnitude, inclusive
     * @param maxKeplerMag the maximum Kepler magnitude, inclusive
     * @return a non-{@code null} list of {@link Kic}s
     * @throws HibernateException if there were problems retrieving the
     * {@link Kic} objects
     */
    public List<Kic> retrieveKics(int ccdModule, int ccdOutput,
        int observingSeason, float minKeplerMag, float maxKeplerMag) {
        int skyGroupId = retrieveSkyGroupId(ccdModule, ccdOutput,
            observingSeason);

        return retrieveKics(skyGroupId, minKeplerMag, maxKeplerMag);
    }

    public List<Kic> retrieveKics(int skyGroupId, float minKeplerMag,
        float maxKeplerMag) {
        Query query = createQuery("from Kic where "
            + "keplerMag >= :minKeplerMag and keplerMag <= :maxKeplerMag "
            + "and skyGroupId = :skyGroupId order by keplerId");

        query.setFloat("minKeplerMag", minKeplerMag);
        query.setFloat("maxKeplerMag", maxKeplerMag);
        query.setInteger("skyGroupId", skyGroupId);

        log.info("Submitting query: " + query);
        long start = System.currentTimeMillis();
        List<Kic> kics = list(query);
        log.info("Query took " + (System.currentTimeMillis() - start) + " ms");

        return kics;
    }

    public List<Integer> retrieveNearbyKeplerIds(int keplerId, int skyGroupId,
        double ra, double dec, float boundedBoxWidth) {

        if (Double.isNaN(ra) || Double.isNaN(dec)) {
            return new ArrayList<Integer>();
        }
        if (log.isDebugEnabled()) {
            log.debug(String.format(
                "Query keplerId %d in skyGroupId %d for near by objects",
                keplerId, skyGroupId));
            log.debug(String.format(
                "in the bounded box whose width is %f centered at ra/dec %e/%e",
                boundedBoxWidth, ra, dec));
        }

        double hourOffset = boundedBoxWidth / 2 * HOURS_PER_DEGREE
            * DEGREES_PER_ARCSEC;
        // Adjusted to account for convergence of RA between the
        // equator and pole.
        hourOffset /= Math.cos(dec * Math.PI / 180);
        double degreeOffset = boundedBoxWidth / 2 * DEGREES_PER_ARCSEC;

        double minRa = ra - hourOffset;
        double maxRa = ra + hourOffset;
        double minDec = dec - degreeOffset;
        double maxDec = dec + degreeOffset;
        
        List<Kic> kics = null;
        if (kicCacheEnabled) {
            kics = KicCache.getKics(skyGroupId);
        } else {
            kics = retrieveKicsInternal(skyGroupId);
        }

        long start = System.currentTimeMillis();
        
        List<Integer> keplerIds = new ArrayList<Integer>();
        for (Kic kic : kics) {
            if (kic.getKeplerId() != keplerId &&
                kic.getRa() >= minRa && kic.getRa() <= maxRa &&
                kic.getDec() >= minDec && kic.getDec() <= maxDec) {
                keplerIds.add(kic.getKeplerId());
            }
        }
        
        Collections.sort(keplerIds);
        
        if (log.isDebugEnabled()) {
            log.debug(String.format(
                "Bounded box described by: minRa=%e; maxRa=%e; minDec=%e; maxDec=%e",
                minRa, maxRa, minDec, maxDec));
        }

        log.info("Determining nearby keplerIds took " + (System.currentTimeMillis() - start) + " ms");

        if (log.isDebugEnabled()) {
            log.debug(String.format("%d near by objeccts", keplerIds.size()));
        }

        return keplerIds;
    }

    /**
     * Retrieves {@link Kic} objects for the given list of constraints. See
     * {@link #retrieveKics(List, Canonicalizable, SortDirection, int, int, int, int)}
     * for additional documentation.
     * 
     * @param constraints a list of {@link Constraint} objects
     * @param orderColumn if {@code rowCount} is greater than 0, then this is
     * the column to sort before limiting the number of rows
     * @param sortDirection the direction to sort by ("ASC" or "DESC") if
     * {@code rowCount} is greater than 0
     * @param rowCount limit output to this number of rows if greater than 0.
     * Otherwise, the query returns all rows. In any case, the query may be
     * limited to the number of rows that can be read into memory
     * @throws HibernateException if the database query failed
     * @throws NullPointerException if {@code constraints} is {@code null}
     * @throws IllegalArgumentException if {@code constraints} is empty or
     * contains unexpected types in the {@code columnName} field
     */
    public List<Kic> retrieveKics(List<Constraint> constraints,
        Canonicalizable orderColumn, SortDirection sortDirection, int rowCount) {

        return retrieveKics(constraints, orderColumn, sortDirection,
            INVALID_CCD_MODULE, INVALID_CCD_OUTPUT, INVALID_SEASON, rowCount);
    }

    /**
     * Retrieves {@link Kic} objects for the given list of constraints.
     * <p>
     * This method expects {@link Constraint#getColumnName()} to return either a
     * {@link Field} object or a {@link CharacteristicType} object. In the
     * former case, the constraint is turned into a query such as
     * {@code CM_KIC.KMAG > 12}. In the latter case, the constraint is turned
     * into a query such as
     * {@code CM_CHAR.TYPE = getColumnName().canonicalize() AND
     * CM_CHAR.VALUE getOperator() getValue()}.
     * 
     * @param constraints a list of {@link Constraint} objects
     * @param orderColumn if {@code rowCount} is greater than 0, then this is
     * the column to sort before limiting the number of rows
     * @param sortDirection the direction to sort by ("ASC" or "DESC")
     * @param ccdModule the CCD module, or {@link #INVALID_CCD_MODULE} for all
     * CCD modules
     * @param ccdOutput the CCD output, or {@link #INVALID_CCD_OUTPUT} for all
     * CCD outputs
     * @param observingSeason the observing season, or {@link #INVALID_SEASON}
     * for all seasons. This parameter is ignored if {@code ccdModule} and
     * {@code ccdOutput} are {@link #INVALID_CCD_MODULE} and
     * {@link #INVALID_CCD_OUTPUT} respectively
     * @param rowCount limit output to this number of rows if greater than 0.
     * Otherwise, the query returns all rows. In any case, the query may be
     * limited to the number of rows that can be read into memory
     * @throws HibernateException if the database query failed
     * @throws NullPointerException if {@code constraints} is {@code null}
     * @throws IllegalArgumentException if {@code constraints} is empty or
     * contains unexpected types in the {@code columnName} field
     */
    public List<Kic> retrieveKics(List<Constraint> constraints,
        Canonicalizable orderColumn, SortDirection sortDirection,
        int ccdModule, int ccdOutput, int observingSeason, int rowCount) {

        String s = toHql(constraints, orderColumn, sortDirection, ccdModule,
            ccdOutput, observingSeason);
        log.info("Submitting query: " + s);
        Query query = createQuery(s);
        query.setMaxResults(rowCount == 0 ? Integer.MAX_VALUE : rowCount);

        long start = System.currentTimeMillis();
        List<Kic> results = list(query);
        log.info("Query took " + (System.currentTimeMillis() - start) + " ms");

        return results;
    }

    /**
     * Creates an HQL string from the given constraints.
     * 
     * @param constraints a list of constraints
     * @param orderColumn if {@code rowCount} is greater than 0, then this is
     * the column to sort before limiting the number of rows
     * @param sortDirection the direction to sort by ("ASC" or "DESC")
     * @param ccdModule the CCD module, or {@link #INVALID_CCD_MODULE} for all
     * sky groups
     * @param ccdOutput the CCD output, or {@link #INVALID_CCD_OUTPUT} for all
     * sky groups
     * @param observingSeason the observing season, or {@link #INVALID_SEASON}
     * for all sky groups
     * @return an HQL string that represents those constraints
     * @throws NullPointerException if {@code constraints} is {@code null}
     * @throws IllegalArgumentException if {@code constraints} is empty or
     * contains unexpected types in the {@code columnName} field
     */
    private String toHql(List<Constraint> constraints,
        Canonicalizable orderColumn, SortDirection sortDirection,
        int ccdModule, int ccdOutput, int observingSeason) {

        if (constraints == null) {
            throw new NullPointerException("constraints can't be null");
        } else if (constraints.size() == 0) {
            throw new IllegalArgumentException("constraints can't be empty");
        }

        final String KIC_ALIAS = "kic";
        final String QUERY_FORMAT = "select %s from Kic as %s%s where %s";
        final String SORT_FORMAT = "%s order by %s %s";
        final String CM_CHAR_XP_FORMAT = ", Characteristic as c%s";
        final String CM_CHAR_CONSTRAINT_FORMAT = "%s "
            + "kic.keplerId = c%s.keplerId "
            + "and c%s.type = %s and c%s.value %s %s";
        final String CM_CHAR_ORDER = "c%s.value";

        // Build the query. As we do so put any characteristics into a set which
        // will be used to create (the minimum number of) cross products on the
        // characteristics table.
        Set<Canonicalizable> characteristics = new HashSet<Canonicalizable>();
        StringBuffer whereClause = new StringBuffer();
        for (Constraint constraint : constraints) {
            whereClause.append(" ");
            Canonicalizable columnName = constraint.getColumnName();
            if (columnName instanceof Kic.Field) {
                whereClause.append(constraint.toCanonicalString(KIC_ALIAS));
            } else if (columnName instanceof CharacteristicType) {
                whereClause.append(String.format(CM_CHAR_CONSTRAINT_FORMAT,
                    constraint.getConjunction(), columnName.canonicalize(null),
                    columnName.canonicalize(null),
                    columnName.canonicalize(null),
                    columnName.canonicalize(null), constraint.getOperator(),
                    constraint.getValue()));
                characteristics.add(columnName);
            } else {
                throw new IllegalArgumentException("Constraint "
                    + constraint.toString()
                    + " has an unexpected columnName type "
                    + columnName.getClass()
                        .getSimpleName()
                    + "; expected Kic.Columns or CharacteristicType");
            }
        }

        // Limit query to a given sky group if module/output/season given.
        if (observingSeason != INVALID_SEASON
            && ccdModule != INVALID_CCD_MODULE
            && ccdOutput != INVALID_CCD_OUTPUT) {
            if (whereClause.length() > 0) {
                whereClause.append(" and ");
            }
            whereClause.append("kic.skyGroupId = (");
            whereClause.append("select skyGroupId from SkyGroup where ");
            whereClause.append("ccdModule = ")
                .append(ccdModule);
            whereClause.append(" and ccdOutput = ")
                .append(ccdOutput);
            whereClause.append(" and observingSeason = ")
                .append(observingSeason);
            whereClause.append(")");
        }

        // Create the cross products.
        if (orderColumn instanceof CharacteristicType) {
            characteristics.add(orderColumn);
        }
        StringBuilder crossProducts = new StringBuilder();
        for (Canonicalizable characteristic : characteristics) {
            crossProducts.append(String.format(CM_CHAR_XP_FORMAT,
                characteristic.canonicalize(null)));
        }

        // Put it all together.
        String coreQuery = String.format(QUERY_FORMAT, KIC_ALIAS, KIC_ALIAS,
            crossProducts, whereClause);

        // Optionally sort the output.
        if (orderColumn != null && sortDirection != null) {
            String orderColumnString;
            if (orderColumn instanceof Kic.Field) {
                orderColumnString = orderColumn.canonicalize(KIC_ALIAS);
            } else if (orderColumn instanceof CharacteristicType) {
                orderColumnString = String.format(CM_CHAR_ORDER,
                    orderColumn.canonicalize(null));
            } else {
                throw new IllegalArgumentException("Ordering "
                    + orderColumn.toString() + " has an unexpected type "
                    + orderColumn.getClass()
                        .getSimpleName()
                    + "; expected Kic.Columns or CharacteristicType");
            }
            return String.format(SORT_FORMAT, coreQuery, orderColumnString,
                sortDirection.dbString());
        }
        return coreQuery;
    }

    /**
     * Retrieves all {@link Kic} objects.
     * 
     * @return a non-{@code null} list of all {@link Kic} objects
     */
    public List<Kic> retrieveAllKics() {
        Criteria query = createCriteria(Kic.class);
        // query.addOrder(Order.asc("keplerId"));
        List<Kic> kics = list(query);

        return kics;
    }

    /**
     * Retrieves Kepler IDs and their associated sky group IDs for all KIC
     * objects on the focal plane. A list of arrays is returned. Each array
     * contains two {@link Object} objects (which are really {@link Integer}s)
     * that correspond to the Kepler ID and sky group ID respectively. This list
     * is sorted by ascending Kepler ID.
     * <p>
     * N.B. This returns an object that is approximately 500 MB in size.
     * 
     * @return a non-{@code null} list of {@link Object} arrays
     * @throws HibernateException if there were problems accessing the database
     */
    public List<Object[]> retrieveAllVisibleKeplerSkyGroupIds() {
        Criteria query = createCriteria(Kic.class);
        query.add(Restrictions.ne("skyGroupId", 0));
        query.addOrder(Order.asc("keplerId"));
        query.setProjection(Projections.projectionList()
            .add(Projections.property("keplerId"))
            .add(Projections.property("skyGroupId")));

        log.info("Retrieving KIC Kepler and sky group IDs");
        long start = System.currentTimeMillis();
        List<Object[]> ids = list(query);
        log.info("Query took " + (System.currentTimeMillis() - start) + " ms");

        return ids;
    }

    /**
     * Returns {@code true} if the given Kepler ID exists.
     * 
     * @return {@code true} if the given Kepler ID exists; otherwise,
     * {@code false}
     * @throws HibernateException if there were problems checking for the
     * existence of the given Kepler ID
     */
    public boolean exists(int keplerId) {
        Query query = createQuery("select count(keplerId) from Kic where keplerId = :keplerId");
        query.setParameter("keplerId", keplerId);
        int count = ((Long) query.iterate()
            .next()).intValue();

        return count > 0;
    }

    /**
     * Gets the number of {@link Kic} entries.
     * 
     * @return the number of {@link Kic} entries
     * @throws HibernateException if there were problems retrieving the count of
     * {@link Kic} objects
     */
    public int kicCount() {
        Query query = createQuery("select count(keplerId) from Kic");
        int count = ((Long) query.iterate()
            .next()).intValue();

        return count;
    }

    /**
     * Gets the number of {@link Kic} entries that are on the focal plane.
     * 
     * @return the number of {@link Kic} entries that are on the focal plane
     * @throws HibernateException if there were problems retrieving the count of
     * {@link Kic} objects
     */
    public int visibleKicCount() {
        Query query = createQuery("select count(keplerId) from Kic where skyGroupId != 0");
        int count = ((Long) query.iterate()
            .next()).intValue();

        return count;
    }

    /**
     * Stores a new {@link SkyGroup}.
     * 
     * @param skyGroup the {@link SkyGroup} object to store
     * @throws HibernateException if there were problems persisting the
     * {@link SkyGroup} object
     */
    public void create(SkyGroup skyGroup) {
        getSession().save(skyGroup);
    }

    /**
     * Retrieves the sky group ID for the given module/output and season.
     * 
     * @param ccdModule the module (1-25)
     * @param ccdOutput the output (1-4)
     * @param observingSeason the observing season (0-3)
     * @return the sky group ID for the given module/output and season
     * @throws NonUniqueResultException if the database query returned more than
     * 1 result
     * @throws IllegalArgumentException if there there isn't a {@link SkyGroup}
     * in the database that matches the parameters
     * @throws HibernateException if there were problems retrieving the
     * {@link SkyGroup} object
     */
    @Override
    public int retrieveSkyGroupId(int ccdModule, int ccdOutput,
        int observingSeason) {

        Query query = createQuery("select skyGroupId from SkyGroup where ccdModule = :ccdModule "
            + "and ccdOutput = :ccdOutput "
            + "and observingSeason = :observingSeason");
        query.setParameter("ccdModule", ccdModule);
        query.setParameter("ccdOutput", ccdOutput);
        query.setParameter("observingSeason", observingSeason);
        Integer skyGroupId = uniqueResult(query);
        if (skyGroupId == null) {
            throw new IllegalArgumentException("No sky group for ccdModule="
                + ccdModule + ", ccdOutput=" + ccdOutput + ", observingSeason="
                + observingSeason);
        }

        return skyGroupId;
    }

    /**
     * Retrieves the desired {@link SkyGroup} object.
     * 
     * @param skyGroupId the id of the {@link SkyGroup}
     * @param observingSeason the observing season (0-3)
     * @return the {@link SkyGroup} object for the given ID and season, or
     * {@code null} if there aren't any such {@link SkyGroup}s
     * @throws NonUniqueResultException if the database query returned more than
     * 1 result
     * @throws HibernateException if there were problems retrieving the
     * {@link SkyGroup} object
     */
    public SkyGroup retrieveSkyGroup(int skyGroupId, int observingSeason) {
        Query query = createQuery("from SkyGroup where "
            + "skyGroupId = :skyGroupId and "
            + "observingSeason = :observingSeason");
        query.setInteger("skyGroupId", skyGroupId);
        query.setInteger("observingSeason", observingSeason);

        return uniqueResult(query);
    }

    /**
     * Retrieves the desired {@link SkyGroup} object.
     * 
     * @param keplerId the Kepler ID that identifies the returned
     * {@link SkyGroup}
     * @param mjd the desired date
     * @return the {@link SkyGroup} object for the given Kepler ID and date, or
     * {@code null} if there aren't any such {@link SkyGroup}s
     * @throws NonUniqueResultException if the database query returned more than
     * 1 result
     * @throws HibernateException if there were problems retrieving the
     * {@link SkyGroup} object
     */
    public SkyGroup retrieveSkyGroupByKeplerId(int keplerId, double mjd) {
        Kic kic = retrieveKic(keplerId);

        return retrieveSkyGroup(kic.getSkyGroupId(), mjd);
    }

    /**
     * Retrieves the desired {@link SkyGroup} object.
     * 
     * @param skyGroupId the sky group ID that identifies the returned
     * {@link SkyGroup}
     * @param mjd the desired date
     * @return the {@link SkyGroup} object for the given sky group ID and date,
     * or {@code null} if there aren't any such {@link SkyGroup}s
     * @throws NonUniqueResultException if the database query returned more than
     * 1 result
     * @throws HibernateException if there were problems retrieving the
     * {@link SkyGroup} object
     */
    public SkyGroup retrieveSkyGroup(int skyGroupId, double mjd) {

        FcCrud fcCrud = new FcCrud();
        History history = fcCrud.retrieveHistory(HistoryModelName.ROLLTIME);
        if (history == null) {
            return null;
        }
        RollTime rollTime = fcCrud.retrieveRollTime(mjd, history);

        return retrieveSkyGroup(skyGroupId, rollTime.getSeason());
    }

    @Override
    public Map<Integer, Integer> retrieveSkyGroupIdsForKeplerIds(
        List<Integer> keplerIds) {

        if (keplerIds.isEmpty()) {
            return Collections.emptyMap();
        }

        log.info("Submitting query for " + keplerIds.size() + " kepler IDs");
        long start = System.currentTimeMillis();

        Map<Integer, Integer> skyGroupIdByKeplerId = new HashMap<Integer, Integer>();
        ListChunkIterator<Integer> keplerIdIterator = new ListChunkIterator<Integer>(
            keplerIds.iterator(), MAX_EXPRESSIONS);

        while (keplerIdIterator.hasNext()) {
            addSkyGroupIdsKeplerIdsToMap(skyGroupIdByKeplerId,
                retrieveSkyGroupIdsForKeplerIdsIntern(keplerIdIterator.next()));
        }

        log.info("Query took " + (System.currentTimeMillis() - start) + " ms");

        return skyGroupIdByKeplerId;
    }

    private List<Pair<Integer, Integer>> retrieveSkyGroupIdsForKeplerIdsIntern(
        List<Integer> keplerIds) {

        StringBuilder queryString = new StringBuilder(
            "select new gov.nasa.spiffy.common.collect.Pair(keplerId, skyGroupId) from Kic "
                + " where keplerId in (");
        for (int keplerId : keplerIds) {
            queryString.append(keplerId)
                .append(',');
        }
        queryString.setLength(queryString.length() - 1);
        queryString.append(')');

        Query query = createQuery(queryString.toString());
        List<Pair<Integer, Integer>> keplerIdsSkyGroups = list(query);

        return keplerIdsSkyGroups;
    }

    private void addSkyGroupIdsKeplerIdsToMap(
        Map<Integer, Integer> skyGroupIdByKeplerId,
        List<Pair<Integer, Integer>> skyGroupIdsKeplerIds) {

        for (Pair<Integer, Integer> skyGroupIdKeplerId : skyGroupIdsKeplerIds) {
            skyGroupIdByKeplerId.put(skyGroupIdKeplerId.left,
                skyGroupIdKeplerId.right);
        }
    }

    /**
     * Retrieves all {@link SkyGroup} objects.
     * 
     * @return a non-{@code null} list of all {@link SkyGroup} objects
     * @throws HibernateException if there were problems retrieving the
     * {@link SkyGroup} objects
     */
    public List<SkyGroup> retrieveAllSkyGroups() {
        Criteria query = createCriteria(SkyGroup.class);
        query.addOrder(Order.asc("skyGroupId"));
        List<SkyGroup> skyGroups = list(query);

        return skyGroups;
    }

    /**
     * Deletes all {@link SkyGroup}s. This method is typically used just before
     * seeding the table in the database.
     * 
     * @throws HibernateException if there were problems removing the
     * {@link SkyGroup} objects
     */
    public void deleteAllSkyGroups() {
        Query query = createQuery("delete SkyGroup");
        query.executeUpdate();
    }

    /**
     * Stores a new {@link CatKey} object.
     * 
     * @param catKey the {@link CatKey} object to store
     * @throws HibernateException if there were problems persisting the
     * {@link CatKey} object
     */
    public void create(CatKey catKey) {
        getSession().save(catKey);
    }

    /**
     * Retrieves the {@link CatKey} object for the given ID.
     * 
     * @param id the ID of the desired record
     * @return the {@link CatKey} object for the given ID, or {@code null} if
     * there aren't any such {@link CatKey}s
     * @throws NonUniqueResultException if the database query returned more than
     * 1 result
     * @throws HibernateException if there were problems retrieving the
     * {@link CatKey} objects
     */
    public CatKey retrieveCatKey(int id) {
        Query query = createQuery("from CatKey where id = :id");
        query.setParameter("id", id);

        return uniqueResult(query);
    }

    /**
     * Retrieves all {@link CatKey} objects.
     * 
     * @return a non-{@code null} list of all {@link CatKey} objects
     */
    public List<CatKey> retrieveAllCatKeys() {
        Criteria query = createCriteria(CatKey.class);
        query.addOrder(Order.asc("id"));
        List<CatKey> catKeys = list(query);

        return catKeys;
    }

    /**
     * Gets the number of {@link CatKey} entries.
     * 
     * @return the number of {@link CatKey} entries
     * @throws HibernateException if there were problems retrieving the count of
     * {@link CatKey} objects
     */
    public int catKeyCount() {
        Query query = createQuery("select count(id) from CatKey");
        int count = ((Long) query.iterate()
            .next()).intValue();

        return count;
    }

    /**
     * Stores a new {@link ScpKey} object.
     * 
     * @param scpKey the {@link ScpKey} object to store
     * @throws HibernateException if there were problems persisting the
     * {@link ScpKey} object
     */
    public void create(ScpKey scpKey) {
        getSession().save(scpKey);
    }

    /**
     * Retrieves the {@link ScpKey} object for the given ID.
     * 
     * @param id the ID of the desired record
     * @return the {@link ScpKey} object for the given ID
     * @throws NonUniqueResultException if the database query returned more than
     * 1 result
     * @throws HibernateException if there were problems retrieving the
     * {@link ScpKey} objects
     */
    public ScpKey retrieveScpKey(int id) {
        Query query = createQuery("from ScpKey where id = :id");
        query.setParameter("id", id);

        return uniqueResult(query);
    }

    /**
     * Retrieves all {@link ScpKey} objects.
     * 
     * @return a non-{@code null} list of all {@link ScpKey} objects
     */
    public List<ScpKey> retrieveAllScpKeys() {
        Criteria query = createCriteria(ScpKey.class);
        query.addOrder(Order.asc("id"));
        List<ScpKey> scpKeys = list(query);

        return scpKeys;
    }

    /**
     * Gets the number of {@link ScpKey} entries.
     * 
     * @return the number of {@link ScpKey} entries
     * @throws HibernateException if there were problems retrieving the count of
     * {@link ScpKey} objects
     */
    public int scpKeyCount() {
        Query query = createQuery("select count(id) from ScpKey");
        int count = ((Long) query.iterate()
            .next()).intValue();

        return count;
    }

    @Override
    public List<CelestialObject> retrieveForKeplerId(int keplerId) {
        Kic kic = retrieveKic(keplerId);

        List<CelestialObject> celestialObjects = new ArrayList<CelestialObject>();
        if (kic != null) {
            celestialObjects.add(kic);
        }

        return celestialObjects;
    }

    @Override
    public List<CelestialObject> retrieveForSkyGroupId(int skyGroupId) {
        return new ArrayList<CelestialObject>(retrieveKics(skyGroupId));
    }

    @Override
    public List<CelestialObject> retrieve(int minKeplerId, int maxKeplerId) {
        return new ArrayList<CelestialObject>(retrieveKics(minKeplerId,
            maxKeplerId));
    }

    @Override
    public List<CelestialObject> retrieve(int skyGroupId, int minKeplerId,
        int maxKeplerId) {
        return new ArrayList<CelestialObject>(
            retrieveKicsForSkyGroupIdKeplerIdRange(skyGroupId, minKeplerId,
                maxKeplerId));
    }

    @Override
    public List<CelestialObject> retrieve(Collection<Integer> keplerIds) {
        return new ArrayList<CelestialObject>(retrieveKics(keplerIds));
    }

    @Override
    public List<CelestialObject> retrieve(int skyGroupId, float minKeplerMag,
        float maxKeplerMag) {
        return new ArrayList<CelestialObject>(retrieveKics(skyGroupId,
            minKeplerMag, maxKeplerMag));
    }

    @Override
    public List<Integer> retrieveKeplerIds(int skyGroupId, int minKeplerId,
        int maxKeplerId) {
        Query query = createQuery("select keplerId from Kic where skyGroupId = :skyGroupId and keplerId >= :minKeplerId and keplerId <= :maxKeplerId "
            + "order by keplerId");
        query.setParameter("skyGroupId", skyGroupId);
        query.setParameter("minKeplerId", minKeplerId);
        query.setParameter("maxKeplerId", maxKeplerId);

        List<Integer> keplerIds = list(query);

        return keplerIds;
    }

    public void setKicCacheEnabled(boolean kicCacheEnabled) {
        this.kicCacheEnabled = kicCacheEnabled;
    }
}
