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
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.spiffy.common.collect.ListChunkIterator;

import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Criteria;
import org.hibernate.HibernateException;
import org.hibernate.NonUniqueResultException;
import org.hibernate.Query;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Restrictions;

/**
 * {@link Characteristic} and {@link CharacteristicType} object data access
 * operations.
 * 
 * @author Bill Wohler
 */
public class CharacteristicCrud extends AbstractCrud {
    private static final Log log = LogFactory.getLog(CharacteristicCrud.class);

    private Map<String, CharacteristicType> characteristicTypeMap;

    /**
     * Creates a new {@link CharacteristicCrud} object.
     */
    public CharacteristicCrud() {
    }

    /**
     * Creates a new {@link CharacteristicCrud} object with the specified
     * database service.
     * 
     * @param databaseService the {@link DatabaseService} to use for the
     * operations
     */
    public CharacteristicCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    /**
     * Stores a new {@link Characteristic} or update an existing one.
     * 
     * @param characteristic the {@link Characteristic} object to store
     * @throws HibernateException if there were problems saving the
     * characteristic
     */
    public void create(Characteristic characteristic) {
        getSession().save(characteristic);
    }

    /**
     * Retrieves the characteristics for the given Kepler ID and
     * {@link CharacteristicType}.
     * 
     * @param keplerId the Kepler ID for which the characteristics are desired
     * @param type the {@link CharacteristicType} of the characteristic
     * @return the most recent characteristic for the given Kepler ID and
     * {@link CharacteristicType}, or {@code null} if such a characteristic is
     * missing
     * @throws NonUniqueResultException if the database query returned more than
     * 1 result
     * @throws HibernateException if there were problems retrieving the
     * characteristic
     */
    public Characteristic retrieveCharacteristic(int keplerId,
        CharacteristicType type) {

        Criteria query = getSession().createCriteria(Characteristic.class);
        query.add(Restrictions.eq("keplerId", keplerId));
        query.add(Restrictions.eq("type", type));
        query.addOrder(Order.desc("id"));
        query.setMaxResults(1);
        Characteristic characteristic = uniqueResult(query);

        return characteristic;
    }

    /**
     * Retrieves the characteristics for the given Kepler ID. There may be
     * multiple values returned for a particular type. The last one in the list
     * is the most recent.
     * 
     * @param keplerId the Kepler ID for which the characteristics are desired
     * @return a non-{@code null} list of characteristics
     * @throws HibernateException if there were problems retrieving the
     * characteristics
     */
    public List<Characteristic> retrieveCharacteristics(int keplerId) {
        Criteria query = getSession().createCriteria(Characteristic.class);
        query.add(Restrictions.eq("keplerId", keplerId));
        query.addOrder(Order.asc("id"));

        List<Characteristic> results = list(query);

        return results;
    }

    /**
     * Retrieves the characteristics for the given Kepler ID and builds a map
     * with the most recent results.
     * 
     * @param keplerId the Kepler ID for which the characteristics are desired
     * @return a non-{@code null} map of characteristics
     * @throws HibernateException if there were problems retrieving the
     * characteristics
     */
    public Map<CharacteristicType, Double> retrieveCharacteristicMap(
        int keplerId) {

        List<Characteristic> characteristics = retrieveCharacteristics(keplerId);
        Map<CharacteristicType, Double> characteristicMap = new HashMap<CharacteristicType, Double>();

        for (Characteristic characteristic : characteristics) {
            characteristicMap.put(characteristic.getType(),
                Double.valueOf(characteristic.getValue()));
        }

        return characteristicMap;
    }

    /**
     * Retrieves the characteristics for all of the Kepler IDs with the given
     * sky group ID and builds a map with the most recent results.
     * 
     * @param skyGroupId the sky group ID for which the characteristics are
     * desired
     * @return a non-{@code null} map of characteristic maps
     * @throws HibernateException if there were problems retrieving the
     * characteristics
     */
    public Map<Integer, Map<CharacteristicType, Double>> retrieveCharacteristicMaps(
        int skyGroupId) {

        Query query = createQuery("select c.keplerId, c.type, c.value "
            + "from Characteristic c, Kic k "
            + "where k.skyGroupId = :skyGroupId and c.keplerId = k.keplerId "
            + "order by c.id");
        query.setInteger("skyGroupId", skyGroupId);

        log.info("Submitting query: " + query);
        long start = System.currentTimeMillis();
        List<Object[]> list = list(query);
        log.info("Query took " + (System.currentTimeMillis() - start) + " ms");

        Map<Integer, Map<CharacteristicType, Double>> characteristicMaps = new HashMap<Integer, Map<CharacteristicType, Double>>();

        for (Object[] characteristic : list) {
            Integer keplerId = (Integer) characteristic[0];
            CharacteristicType characteristicType = (CharacteristicType) characteristic[1];
            Double value = (Double) characteristic[2];

            Map<CharacteristicType, Double> characteristicMap = characteristicMaps.get(keplerId);
            if (characteristicMap == null) {
                characteristicMap = new HashMap<CharacteristicType, Double>();
                characteristicMaps.put(keplerId, characteristicMap);
            }
            characteristicMap.put(characteristicType, Double.valueOf(value));
        }

        return characteristicMaps;
    }

    /**
     * Retrieves the characteristics for all of the Kepler IDs with the given
     * sky group ID and builds a map with the most recent results.
     * <p>
     * This method differs from {@link #retrieveCharacteristicMaps(int)} in that
     * the secondary map's key is the ID of the characteristics type instead of
     * the type itself.
     * 
     * @param skyGroupId the sky group ID for which the characteristics are
     * desired
     * @return a non-{@code null} map of characteristic maps
     * @throws HibernateException if there were problems retrieving the
     * characteristics
     */
    public Map<Integer, Map<Long, Double>> retrieveCharacteristicMapsMatlabFriendly(
        int skyGroupId) {

        Query query = createQuery("select c.keplerId, c.type.id, c.value "
            + "from Characteristic c, Kic k "
            + "where k.skyGroupId = :skyGroupId and c.keplerId = k.keplerId");
        query.setInteger("skyGroupId", skyGroupId);

        log.info("Submitting query: " + query);
        long start = System.currentTimeMillis();
        List<Object[]> list = list(query);
        log.info("Query took " + (System.currentTimeMillis() - start) + " ms");

        Map<Integer, Map<Long, Double>> characteristicMaps = new HashMap<Integer, Map<Long, Double>>();

        for (Object[] characteristic : list) {
            Integer keplerId = (Integer) characteristic[0];
            Long characteristicTypeId = (Long) characteristic[1];
            Double value = (Double) characteristic[2];

            Map<Long, Double> characteristicMap = characteristicMaps.get(keplerId);
            if (characteristicMap == null) {
                characteristicMap = new HashMap<Long, Double>();
                characteristicMaps.put(keplerId, characteristicMap);
            }
            characteristicMap.put(characteristicTypeId, Double.valueOf(value));
        }

        return characteristicMaps;
    }

    /**
     * Retrieves the characteristics for all of the given Kepler IDs and builds
     * a map with the most recent results.
     * 
     * @param keplerIds a list of Kepler IDs
     * @return a non-{@code null} map of characteristic maps
     * @throws HibernateException if there were problems retrieving the
     * characteristics
     */
    public Map<Integer, Map<CharacteristicType, Double>> retrieveCharacteristicMaps(
        Collection<Integer> keplerIds) {

        Map<Integer, Map<CharacteristicType, Double>> characteristicMaps = new HashMap<Integer, Map<CharacteristicType, Double>>();
        ListChunkIterator<Integer> keplerIdIterator = new ListChunkIterator<Integer>(
            keplerIds.iterator(), MAX_EXPRESSIONS);

        while (keplerIdIterator.hasNext()) {
            characteristicMaps.putAll(retrieveCharacteristicMapsIntern(keplerIdIterator.next()));
        }

        return characteristicMaps;
    }

    private Map<Integer, Map<CharacteristicType, Double>> retrieveCharacteristicMapsIntern(
        List<Integer> keplerIds) {

        StringBuilder queryString = new StringBuilder(
            "from Characteristic where keplerId in (");
        for (int keplerId : keplerIds) {
            queryString.append(keplerId)
                .append(',');
        }
        queryString.setLength(queryString.length() - 1); // trim last comma
        queryString.append(") order by id");

        Query query = createQuery(queryString.toString());

        log.info("Submitting Characteristic query for " + keplerIds.size()
            + " kepler IDs");
        long start = System.currentTimeMillis();
        List<Characteristic> characteristics = list(query);
        log.info(String.format("Query took %d ms", System.currentTimeMillis()
            - start));

        Map<Integer, Map<CharacteristicType, Double>> characteristicMaps = new HashMap<Integer, Map<CharacteristicType, Double>>();

        for (Characteristic characteristic : characteristics) {
            Map<CharacteristicType, Double> characteristicMap = characteristicMaps.get(characteristic.getKeplerId());
            if (characteristicMap == null) {
                characteristicMap = new HashMap<CharacteristicType, Double>();
                characteristicMaps.put(characteristic.getKeplerId(),
                    characteristicMap);
            }
            characteristicMap.put(characteristic.getType(),
                Double.valueOf(characteristic.getValue()));
        }

        return characteristicMaps;
    }

    /**
     * Retrieves all {@link Characteristic}s for a {@link CharacteristicType}
     * and a {@code skyGroupId}.
     * 
     * @param type the {@link CharacteristicType}
     * @param skyGroupId the sky group ID
     * @return all {@link Characteristic}s for a {@link CharacteristicType} and
     * a skyGroupId
     */
    public List<Characteristic> retrieveCharacteristics(
        CharacteristicType type, int skyGroupId) {
        Query query = createQuery("select c from Kic k, Characteristic c where "
            + "c.type = :type and "
            + "k.skyGroupId = :skyGroupId and "
            + "k.keplerId = c.keplerId");
        query.setParameter("type", type)
            .setParameter("skyGroupId", skyGroupId);

        List<Characteristic> characteristics = list(query);

        return characteristics;
    }

    /**
     * Retrieves all {@link Characteristic}s for a {@link CharacteristicType}
     * and a {@code skyGroupId} and a quarter.
     */
    public List<Characteristic> retrieveCharacteristics(
        CharacteristicType type, int skyGroupId, Integer quarter) {
        String quarterClause;
        if (quarter != null) {
            quarterClause = "c.quarter = :quarter and ";
        } else {
            quarterClause = "c.quarter is null and ";
        }

        Query query = createQuery("select c from Kic k, Characteristic c where "
            + "c.type = :type and "
            + quarterClause
            + "k.skyGroupId = :skyGroupId and " + "k.keplerId = c.keplerId");
        query.setParameter("type", type)
            .setParameter("skyGroupId", skyGroupId);

        if (quarter != null) {
            query.setParameter("quarter", quarter);
        }
        
        List<Characteristic> characteristics = list(query);

        return characteristics;
    }

    /**
     * Deletes all {@link Characteristic}s for the {@link CharacteristicType}.
     * 
     * @param type the {@link CharacteristicType} for which to delete
     * {@link Characteristic}s
     */
    public void deleteCharacteristics(CharacteristicType type) {
        Query query = getSession().createQuery(
            "delete from Characteristic where type = :type");
        query.setParameter("type", type);
        query.executeUpdate();
    }

    /**
     * Deletes all {@link Characteristic}s for a given quarter.
     */
    public void deleteCharacteristics(Integer quarter) {
        Query query = getSession().createQuery(
            "delete from Characteristic where quarter = :quarter");
        query.setParameter("quarter", quarter);
        query.executeUpdate();
    }

    /**
     * Deletes all {@link Characteristic}s for the {@link CharacteristicType}
     * and skyGroupId.
     * 
     * @param type the {@link CharacteristicType} for which to delete
     * {@link Characteristic}s
     * @param skyGroupId the skyGroupId for which to delete
     * {@link Characteristic}s
     */
    public void deleteCharacteristics(CharacteristicType type, int skyGroupId) {

        List<Characteristic> characteristics = retrieveCharacteristics(type,
            skyGroupId);
        ListChunkIterator<Characteristic> characteristicIterator = new ListChunkIterator<Characteristic>(
            characteristics.iterator(), MAX_EXPRESSIONS);

        while (characteristicIterator.hasNext()) {
            deleteCharacteristicsIntern(characteristicIterator.next());
        }
    }

    private void deleteCharacteristicsIntern(
        List<Characteristic> characteristics) {

        StringBuilder commaSeparatedString = new StringBuilder();
        for (Characteristic characteristic : characteristics) {
            commaSeparatedString.append(characteristic.getId())
                .append(",");
        }
        // Trim last comma.
        commaSeparatedString.setLength(commaSeparatedString.length() - 1);

        Query query = createQuery("delete from Characteristic c where c.id in ("
            + commaSeparatedString + ")");
        query.executeUpdate();
    }

    /**
     * Returns the number of entries in the {@link Characteristic}s table.
     * 
     * @return the number of entries in the {@link Characteristic}s table
     * @throws HibernateException if there were problems retrieving the count of
     * characteristics
     */
    public int characteristicCount() {
        Query query = getSession().createQuery(
            "select count(*) from Characteristic");
        int count = ((Long) query.iterate()
            .next()).intValue();

        return count;
    }

    /**
     * Stores a new {@link CharacteristicType} or update an existing one.
     * 
     * @param characteristicType the {@link CharacteristicType} object to store
     * @throws HibernateException if there were problems saving the
     * characteristic type
     */
    public void create(CharacteristicType characteristicType) {
        getSession().save(characteristicType);
    }

    /**
     * Retrieves the characteristic type for the given name.
     * 
     * @param name the name of the characteristic type
     * @return a {@link CharacteristicType} object, or null if there isn't a
     * type of that name
     * @throws NonUniqueResultException if the database query returned more than
     * 1 result
     * @throws HibernateException if there were problems retrieving the
     * characteristic type
     */
    public CharacteristicType retrieveCharacteristicType(String name) {
        Query query = getSession().createQuery(
            "from CharacteristicType where name = :name");
        query.setParameter("name", name);

        return uniqueResult(query);
    }

    /**
     * Retrieves all of the characteristic types.
     * 
     * @return a non-null list of {@link CharacteristicType} objects
     * @throws HibernateException if there were problems retrieving the
     * characteristic types
     */
    public Collection<CharacteristicType> retrieveAllCharacteristicTypes() {
        Query query = getSession().createQuery("from CharacteristicType");
        Collection<CharacteristicType> types = list(query);

        return types;
    }

    /**
     * Retrieves the characteristic type for the given name. This differs from
     * {@link #retrieveCharacteristicType(String)} in that it caches all types
     * for later use. Because of this cache, it won't see types that were added
     * after this method was first called.
     * 
     * @param name the name of the characteristic type
     * @return a {@link CharacteristicType} object, or null if there isn't a
     * type of that name
     * @throws HibernateException if there were problems retrieving the
     * characteristic type
     */
    public CharacteristicType getCharacteristicType(String name) {
        if (characteristicTypeMap == null) {
            Collection<CharacteristicType> characteristicTypes = retrieveAllCharacteristicTypes();
            characteristicTypeMap = new HashMap<String, CharacteristicType>();
            for (CharacteristicType characteristicType : characteristicTypes) {
                characteristicTypeMap.put(characteristicType.getName(),
                    characteristicType);
            }
        }

        return characteristicTypeMap.get(name);
    }

    /**
     * Deletes all {@link Characteristic}s for the {@link CharacteristicType}
     * and then deletes the {@link CharacteristicType}.
     * 
     * @param type the {@link CharacteristicType} to delete
     */
    public void delete(CharacteristicType type) {
        deleteCharacteristics(type);
        getSession().delete(type);
    }

    /**
     * Deletes the {@link Characteristic}.
     * 
     * @param characteristic the {@link Characteristic} to delete
     */
    public void delete(Characteristic characteristic) {
        getSession().delete(characteristic);
    }

    /**
     * Retrieves {@link Characteristic}s for a keplerId and quarter.
     */
    public List<Characteristic> retrieveCharacteristics(int keplerId,
        int quarter) {
        Criteria query = getSession().createCriteria(Characteristic.class);
        query.add(Restrictions.eq("keplerId", keplerId));
        query.add(Restrictions.eq("quarter", quarter));
        query.addOrder(Order.asc("id"));

        List<Characteristic> results = list(query);

        return results;
    }
}
