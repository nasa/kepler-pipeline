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

package gov.nasa.kepler.hibernate.dv;

import gnu.trove.TIntArrayList;
import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.spiffy.common.collect.ListChunkIterator;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Criteria;
import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Restrictions;

import static gov.nasa.kepler.hibernate.dv.DvCrud.KeplerIdQueryType.*;

/**
 * Create, read, update, and delete operations on the DV classes.
 * 
 * @author Bill Wohler
 */
public class DvCrud extends AbstractCrud {

    private static final Log log = LogFactory.getLog(DvCrud.class);

    public enum KeplerIdQueryType {
        /**
         * indicates query should be from "startKeplerId" to "endKeplerId"
         * inclusive.
         */
        KeplerIdInterval,
        /** Indicates query should accept a list of kepler id integers. */
        KeplerIdList;
    }

    /**
     * Creates a new {@link DvCrud} object.
     */
    public DvCrud() {
    }

    /**
     * Creates a new {@link DvCrud} object with the specified database service.
     * 
     * @param dbService the {@link DatabaseService} to use for the operations
     */
    public DvCrud(DatabaseService dbService) {
        super(dbService);
    }

    /**
     * Stores a new {@link DvPlanetResults}.
     * 
     * @param planetResults the {@link DvPlanetResults} object to store
     * @throws HibernateException if there were problems accessing the database
     */
    public void create(DvPlanetResults planetResults) {
        getSession().save(planetResults);
    }

    /**
     * Stores the given collection of {@link DvPlanetResults}.
     * 
     * @param planetResultsCollection the {@link DvPlanetResults} objects to
     * create
     * @throws HibernateException if there were problems accessing the database
     * @throws NullPointerException if {@code planetResultsCollection} is
     * {@code null}
     */
    public void createPlanetResultsCollection(
        Collection<DvPlanetResults> planetResultsCollection) {

        for (DvPlanetResults planetResults : planetResultsCollection) {
            create(planetResults);
        }
    }

    /**
     * Stores a new {@link DvLimbDarkeningModel}.
     * 
     * @param limbDarkeningModel the {@link DvLimbDarkeningModel} object to
     * store
     * @throws HibernateException if there were problems accessing the database
     */
    public void create(DvLimbDarkeningModel limbDarkeningModel) {
        getSession().save(limbDarkeningModel);
    }

    /**
     * Stores the given collection of {@link DvLimbDarkeningModel}.
     * 
     * @param limbDarkeningModelCollection the {@link DvLimbDarkeningModel}
     * objects to create
     * @throws HibernateException if there were problems accessing the database
     * @throws NullPointerException if {@code limbDarkeningModelCollection} is
     * {@code null}
     */
    public void createLimbDarkeningModelsCollection(
        List<DvLimbDarkeningModel> limbDarkeningModelCollection) {

        for (DvLimbDarkeningModel limbDarkeningModel : limbDarkeningModelCollection) {
            create(limbDarkeningModel);
        }
    }

    /**
     * Stores a new {@link DvTargetResults}.
     * 
     * @param dvTargetResults the {@link DvTargetResults} object to store
     * @throws HibernateException if there were problems accessing the database
     */
    public void create(DvTargetResults dvTargetResults) {
        getSession().save(dvTargetResults);
    }

    /**
     * Stores the given collection of {@link DvTargetResults}.
     * 
     * @param targetResultsCollection the {@link DvTargetResults} objects to
     * create
     * @throws HibernateException if there were problems accessing the database
     * @throws NullPointerException if {@code targetResultsCollection} is
     * {@code null}
     */
    public void createTargetResultsCollection(
        List<DvTargetResults> targetResultsCollection) {

        for (DvTargetResults dvTargetResults : targetResultsCollection) {
            create(dvTargetResults);
        }
    }

    /**
     * Retrieves all {@link DvPlanetResults}.
     * 
     * @return return a non-{@code null} list of {@link DvPlanetResults}s sorted
     * by {@code keplerId} and then by {@code planetNumber}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvPlanetResults> retrieveAllPlanetResults() {
        Criteria query = createCriteria(DvPlanetResults.class);
        query.addOrder(Order.asc("keplerId"));
        query.addOrder(Order.asc("planetNumber"));

        List<DvPlanetResults> planetResults = list(query);

        return planetResults;
    }

    /**
     * Retrieves all {@link DvPlanetResults} for the given target.
     * 
     * @param keplerId the target ID
     * @return return a non-{@code null} list of {@link DvPlanetResults}s sorted
     * by {@code planetNumber}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvPlanetResults> retrieveAllPlanetResults(int keplerId) {
        Criteria query = createCriteria(DvPlanetResults.class);
        query.add(Restrictions.eq("keplerId", keplerId));
        query.addOrder(Order.asc("planetNumber"));

        List<DvPlanetResults> planetResults = list(query);

        return planetResults;
    }

    /**
     * Retrieves all {@link DvPlanetResults} for the given pipeline.
     * 
     * @param pipelineInstanceId a completed pipeline instance ID
     * @return return a non-{@code null} list of {@link DvPlanetResults}s sorted
     * by {@code keplerId} and then by {@code planetNumber}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvPlanetResults> retrievePlanetResultsByPipelineInstanceId(
        long pipelineInstanceId) {

        return retrievePlanetResultsByPipelineInstanceId(pipelineInstanceId,
            Integer.MIN_VALUE, Integer.MAX_VALUE);
    }

    /**
     * Retrieves the {@link DvPlanetResults} for the given pipeline and list of
     * kepler ids.
     * 
     * @param pipelineInstanceId a completed pipeline instance ID
     * @param keplerIds list of kepler ids of length 0 to 1000.
     * @return return a non-{@code null} list of {@link DvPlanetResults}s sorted
     * by {@code keplerId} and then by {@code planetNumber}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvPlanetResults> retrievePlanetResultsByPipelineInstanceId(
        long pipelineInstanceId, List<Integer> keplerIds) {

        Query query = createQuery(generateQueryStringPlanetResultsByPipelineInstanceId(
            "", "order by planets.keplerId, planets.planetNumber", KeplerIdList));
        query.setLong("pipelineInstanceIdParam", pipelineInstanceId);
        query.setParameterList("keplerIds", keplerIds);

        List<DvPlanetResults> planetResults = list(query);

        return planetResults;

    }

    /**
     * Retrieves {@link DvPlanetResults} by pipeline instance ID.
     * 
     * @param pipelineInstanceId a completed pipeline instance ID
     * @param minKeplerId inclusive
     * @param maxKeplerId inclusive
     * @return a non-{@code null} list of {@link DvPlanetResults}s sorted by
     * {@code keplerId} and then by {@code planetNumber}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvPlanetResults> retrievePlanetResultsByPipelineInstanceId(
        long pipelineInstanceId, int minKeplerId, int maxKeplerId) {

        Query query = createQuery(generateQueryStringPlanetResultsByPipelineInstanceId(
            "", "order by planets.keplerId, planets.planetNumber",
            KeplerIdInterval));
        query.setLong("pipelineInstanceIdParam", pipelineInstanceId);
        query.setInteger("minKeplerId", minKeplerId);
        query.setInteger("maxKeplerId", maxKeplerId);

        List<DvPlanetResults> planetResults = list(query);

        return planetResults;
    }

    /**
     * Retrieves the latest {@link DvPlanetResults} that were generated by DV
     * pipelines in the COMPLETED, STOPPED, or ERRORS_STALLED state at or before
     * the specified pipeline instance.
     * 
     * @param maxPipelineInstanceId inclusive
     * @return return a non-{@code null} list of {@link DvPlanetResults}s sorted
     * by {@code keplerId} and then by {@code planetNumber}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvPlanetResults> retrieveLatestCompletedOrErredPlanetResultsBeforePipelineInstance(
        long maxPipelineInstanceId) {

        return retrieveLatestCompletedOrErredPlanetResultsBeforePipelineInstance(
            maxPipelineInstanceId, Integer.MIN_VALUE, Integer.MAX_VALUE);
    }

    /**
     * Retrieves the most up to date {@link DvPlanetResults} that were generated
     * by DV pipelines in the COMPLETED, STOPPED or ERRORS_STALLED state at or
     * before the specified pipeline instance.
     * 
     * @param maxPipelineInstanceId inclusive
     * @param minKeplerId inclusive
     * @param maxKeplerId inclusive
     * @return return a non-{@code null} list of {@link DvPlanetResults}s sorted
     * by {@code keplerId} and then by {@code planetNumber}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvPlanetResults> retrieveLatestCompletedOrErredPlanetResultsBeforePipelineInstance(
        long maxPipelineInstanceId, int minKeplerId, int maxKeplerId) {

        Query query = createQuery(generateQueryStringForPlanetResultsBeforePipelineInstance(
            "", "order by planet1.keplerId, planet1.planetNumber"));
        query.setParameter("maxInstanceId", maxPipelineInstanceId);
        query.setParameter("minKeplerId", minKeplerId);
        query.setParameter("maxKeplerId", maxKeplerId);

        List<DvPlanetResults> planetResults = list(query);

        return planetResults;
    }

    /**
     * Retrieves the most up to date {@link DvPlanetResults} that were generated
     * by the most recent DV pipeline in the COMPLETED, STOPPED or
     * ERRORS_STALLED state.
     * 
     * @param keplerIds
     * @return return a non-{@code null} list of {@link DvPlanetResults}s sorted
     * by {@code keplerId} and then by {@code planetNumber}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvPlanetResults> retrieveLatestPlanetResults(
        List<Integer> keplerIds) {

        List<DvPlanetResults> planetResults = new LinkedList<DvPlanetResults>();
        ListChunkIterator<Integer> keplerIdIterator = new ListChunkIterator<Integer>(
            keplerIds.iterator(), MAX_EXPRESSIONS);

        while (keplerIdIterator.hasNext()) {
            List<Integer> keplerIdsThisChunk = keplerIdIterator.next();
            StringBuilder inClause = new StringBuilder();

            for (int keplerId : keplerIdsThisChunk) {
                inClause.append(keplerId)
                    .append(',');
            }
            inClause.setLength(inClause.length() - 1);

            Query query = createQuery(generateQueryStringForPlanetResultsBeforePipelineInstance(inClause.toString()));
            query.setParameter("maxInstanceId", Long.MAX_VALUE);

            List<DvPlanetResults> chunkResults = list(query);
            planetResults.addAll(chunkResults);
        }

        return planetResults;
    }

    /**
     * Retrieves the {@link DvPlanetResults} for the given Kepler IDs that were
     * generated by the specified DV pipeline in the COMPLETED, STOPPED or
     * ERRORS_STALLED state.
     * 
     * @param pipelineInstanceId the particular pipeline run
     * @param keplerIds
     * @return return a non-{@code null} list of {@link DvPlanetResults}s
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvPlanetResults> retrievePlanetResultsByPipelineInstanceIdKeplerIds(
        long pipelineInstanceId, List<Integer> keplerIds) {

        List<DvPlanetResults> planetResults = new LinkedList<DvPlanetResults>();
        ListChunkIterator<Integer> keplerIdIterator = new ListChunkIterator<Integer>(
            keplerIds.iterator(), MAX_EXPRESSIONS);

        while (keplerIdIterator.hasNext()) {
            List<Integer> keplerIdsThisChunk = keplerIdIterator.next();
            StringBuilder inClause = new StringBuilder();

            for (int keplerId : keplerIdsThisChunk) {
                inClause.append(keplerId)
                    .append(',');
            }
            inClause.setLength(inClause.length() - 1);

            Query query = createQuery(generateQueryStringPlanetResultsByPipelineInstanceIdKeplerIds(inClause.toString()));
            query.setLong("pipelineInstanceIdParam", pipelineInstanceId);

            List<DvPlanetResults> chunkResults = list(query);
            planetResults.addAll(chunkResults);
        }

        return planetResults;
    }

    /**
     * Retrieves Kepler IDs which have planet results that were generated by a
     * particular run of the DV pipeline.
     * 
     * @param pipelineInstanceId the particular pipeline run
     * @return a non-{@code null} list of distinct Kepler IDs in ascending order
     */
    public List<Integer> retrievePlanetResultsKeplerIdsByPipelineInstanceId(
        long pipelineInstanceId) {

        Query query = createQuery(generateQueryStringPlanetResultsByPipelineInstanceId(
            "select distinct planets.keplerId ", " order by planets.keplerId",
            KeplerIdInterval));
        query.setLong("pipelineInstanceIdParam", pipelineInstanceId);
        query.setInteger("minKeplerId", Integer.MIN_VALUE);
        query.setInteger("maxKeplerId", Integer.MAX_VALUE);

        List<Integer> keplerIds = list(query);

        return keplerIds;
    }

    /**
     * Retrieves Kepler IDs which have planet results that were generated by the
     * specified DV pipeline or a previous pipeline run.
     * 
     * @param maxPipelineInstanceId inclusive
     * @return a non-{@code null} list of distinct Kepler IDs in ascending order
     */
    public List<Integer> retrievePlanetResultsKeplerIdsBeforePipelineInstance(
        long maxPipelineInstanceId) {

        Query query = createQuery(generateQueryStringForPlanetResultsBeforePipelineInstance(
            "select distinct planet1.keplerId ", "order by planet1.keplerId"));
        query.setParameter("minKeplerId", Integer.MIN_VALUE);
        query.setParameter("maxKeplerId", Integer.MAX_VALUE);
        query.setParameter("maxInstanceId", maxPipelineInstanceId);

        List<Integer> keplerIds = list(query);

        return keplerIds;
    }

    /**
     * Retrieves {@link DvPlanetSummary}s that were generated by a particular
     * run of the DV pipeline.
     * 
     * @param pipelineInstanceId the particular pipeline run
     * @param minKeplerId inclusive
     * @param maxKeplerId inclusive
     * @return a non-{@code null} list of {@link DvPlanetSummary} objects in
     * ascending order
     */
    public List<DvPlanetSummary> retrievePlanetSummaryByPipelineInstanceId(
        long pipelineInstanceId, int minKeplerId, int maxKeplerId) {

        Query query = createQuery(generateQueryStringPlanetResultsByPipelineInstanceId(
            "select planets.startCadence, planets.endCadence, planets.keplerId, "
                + "planets.planetNumber, planets.pipelineTask.pipelineInstance.id, pipelineTask.id ",
            " order by planets.keplerId, planets.planetNumber",
            KeplerIdInterval));
        query.setLong("pipelineInstanceIdParam", pipelineInstanceId);
        query.setInteger("maxKeplerId", maxKeplerId);
        query.setInteger("minKeplerId", minKeplerId);

        return returnSummary(query);
    }

    /**
     * Retrieves {@link DvPlanetSummary}s that were generated by the specified
     * DV pipeline or a previous pipeline run.
     * 
     * @param maxPipelineInstanceId the particular pipeline run
     * @param minKeplerId inclusive
     * @param maxKeplerId inclusive
     * @return a non-{@code null} list of {@link DvPlanetSummary} objects in
     * ascending order
     */
    public List<DvPlanetSummary> retrievePlanetSummaryBeforePipelineInstance(
        long maxPipelineInstanceId, int minKeplerId, int maxKeplerId) {

        Query query = createQuery(generateQueryStringForPlanetResultsBeforePipelineInstance(
            "select planet1.startCadence, planet1.endCadence, planet1.keplerId, "
                + "planet1.planetNumber, planet1.pipelineTask.pipelineInstance.id, pipelineTask.id ",
            "order by planet1.keplerId, planet1.planetNumber"));
        query.setParameter("minKeplerId", minKeplerId);
        query.setParameter("maxKeplerId", maxKeplerId);
        query.setParameter("maxInstanceId", maxPipelineInstanceId);

        return returnSummary(query);
    }

    private static String generateQueryStringPlanetResultsByPipelineInstanceId(
        String selectPart, String orderBy, KeplerIdQueryType keplerIdQueryType) {

        StringBuilder queryString = new StringBuilder(256);
        queryString.append(selectPart)
            .append("\n")
            .append("from DvPlanetResults planets where ");
        switch (keplerIdQueryType) {
            case KeplerIdInterval:
                queryString.append("planets.keplerId >= :minKeplerId ")
                    .append("and planets.keplerId <= :maxKeplerId ");
                break;
            case KeplerIdList:
                queryString.append(" planets.keplerId in (:keplerIds)");
                break;
            default:
                throw new IllegalStateException("Unknown KeplerIdQueryType "
                    + keplerIdQueryType);
        }

        queryString.append("and planets.pipelineTask.state in (")
            .append(PipelineTask.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineTask.State.PARTIAL.ordinal())
            .append(")")
            .append(
                " and planets.pipelineTask.pipelineInstance.id = :pipelineInstanceIdParam ")
            .append("and planets.pipelineTask.pipelineInstance.state in (")
            .append(PipelineInstance.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.STOPPED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.ERRORS_STALLED.ordinal())
            .append(")\n")
            .append(orderBy);

        return queryString.toString();
    }

    private static String generateQueryStringPlanetResultsByPipelineInstanceIdKeplerIds(
        String inClause) {

        StringBuilder queryString = new StringBuilder();
        queryString.append("from DvPlanetResults planets where ")
            .append("planets.keplerId in (")
            .append(inClause)
            .append(") ")
            .append("and planets.pipelineTask.state in (")
            .append(PipelineTask.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineTask.State.PARTIAL.ordinal())
            .append(")")
            .append(
                " and planets.pipelineTask.pipelineInstance.id = :pipelineInstanceIdParam ")
            .append("and planets.pipelineTask.pipelineInstance.state in (")
            .append(PipelineInstance.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.STOPPED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.ERRORS_STALLED.ordinal())
            .append(")\n");

        return queryString.toString();
    }

    private static String generateQueryStringForPlanetResultsBeforePipelineInstance(
        String selectPart, String orderBy) {

        StringBuilder queryString = new StringBuilder();
        queryString.append(selectPart)
            .append("\n")
            .append("from DvPlanetResults planet1 where ")
            .append("planet1.keplerId >= :minKeplerId ")
            .append("and planet1.keplerId <= :maxKeplerId ")
            .append("and planet1.pipelineTask.state in (")
            .append(PipelineTask.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineTask.State.PARTIAL.ordinal())
            .append(")")
            .append(" and planet1.pipelineTask.pipelineInstance.id in ")
            .append("(select max(planet2.pipelineTask.pipelineInstance.id) ")
            .append("from DvPlanetResults planet2 where ")
            .append("planet2.pipelineTask.pipelineInstance.state in (")
            .append(PipelineInstance.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.ERRORS_STALLED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.STOPPED.ordinal())
            .append(")")
            .append(" and planet2.keplerId = planet1.keplerId ")
            .append(
                "and planet2.pipelineTask.pipelineInstance.id <= :maxInstanceId) ")
            .append("\n")
            .append(orderBy);

        return queryString.toString();
    }

    private static String generateQueryStringForPlanetResultsBeforePipelineInstance(
        String inClause) {

        StringBuilder queryString = new StringBuilder();
        queryString.append("from DvPlanetResults planet1 where ")
            .append("planet1.keplerId in (")
            .append(inClause)
            .append(") ")
            .append("and planet1.pipelineTask.state in (")
            .append(PipelineTask.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineTask.State.PARTIAL.ordinal())
            .append(") and planet1.pipelineTask.pipelineInstance.id in ")
            .append("(select max(planet2.pipelineTask.pipelineInstance.id) ")
            .append("from DvPlanetResults planet2 where ")
            .append("planet2.pipelineTask.pipelineInstance.state in (")
            .append(PipelineInstance.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.ERRORS_STALLED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.STOPPED.ordinal())
            .append(")")
            .append(" and planet2.keplerId = planet1.keplerId ")
            .append(
                "and planet2.pipelineTask.pipelineInstance.id <= :maxInstanceId) ")
            .append("\n")
            .append("order by planet1.keplerId, planet1.planetNumber");

        return queryString.toString();
    }

    private static List<DvPlanetSummary> returnSummary(Query query) {
        @SuppressWarnings("unchecked")
        final List<Object[]> queryResults = query.list();

        final List<DvPlanetSummary> planetSummaries = new ArrayList<DvPlanetSummary>();
        final TIntArrayList planetNumbers = new TIntArrayList();
        int previousKeplerId = -1;
        long previousPipelineInstanceId = -1L;
        int previousStartCadence = -1;
        int previousEndCadence = -1;
        long previousPipelineTaskId = -1;
        for (Object[] row : queryResults) {
            final int startCadence = ((Integer) row[0]).intValue();
            final int endCadence = ((Integer) row[1]).intValue();
            final int keplerId = ((Integer) row[2]).intValue();
            final int planetNumber = ((Integer) row[3]).intValue();
            final long pipelineInstanceId = ((Long) row[4]).longValue();
            final long pipelineTaskId = ((Long) row[5]).longValue();
            if (previousKeplerId != keplerId) {
                if (previousKeplerId != -1) {
                    planetSummaries.add(new DvPlanetSummary(
                        previousStartCadence, previousEndCadence,
                        planetNumbers.toNativeArray(), previousKeplerId,
                        previousPipelineInstanceId, pipelineTaskId));
                }
                previousKeplerId = keplerId;
                previousPipelineInstanceId = pipelineInstanceId;
                previousStartCadence = startCadence;
                previousEndCadence = endCadence;
                previousPipelineTaskId = pipelineTaskId;
                planetNumbers.clear();
            }
            if (previousPipelineInstanceId != pipelineInstanceId) {
                throw new IllegalStateException(
                    "Current pipeline task id does " + "not equal previous.");
            }
            planetNumbers.add(planetNumber);
        }
        if (previousKeplerId != -1) {
            planetSummaries.add(new DvPlanetSummary(previousStartCadence,
                previousEndCadence, planetNumbers.toNativeArray(),
                previousKeplerId, previousPipelineInstanceId,
                previousPipelineTaskId));
        }

        return planetSummaries;
    }

    /**
     * Retrieves all {@link DvTargetResults}.
     * 
     * @return return a non-{@code null} list of {@link DvTargetResults} sorted
     * by {@code keplerId}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvTargetResults> retrieveAllTargetResults() {
        Criteria query = createCriteria(DvTargetResults.class);
        query.addOrder(Order.asc("keplerId"));

        List<DvTargetResults> targetResults = list(query);

        return targetResults;
    }

    /**
     * Retrieves all {@link DvTargetResults} for the given target.
     * 
     * @param keplerId the target ID
     * @return return a non-{@code null} list of {@link DvTargetResults} sorted
     * by {@code targetTableId}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvTargetResults> retrieveAllTargetResults(int keplerId) {
        Criteria query = createCriteria(DvTargetResults.class);
        query.add(Restrictions.eq("keplerId", keplerId));

        List<DvTargetResults> targetResults = list(query);

        return targetResults;
    }

    /**
     * Retrieves all {@link DvTargetResults} for the given pipeline.
     * 
     * @param pipelineInstanceId a completed pipeline instance ID
     * @return return a non-{@code null} list of {@link DvTargetResults} sorted
     * by {@code keplerId}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvTargetResults> retrieveTargetResultsByPipelineInstanceId(
        long pipelineInstanceId) {

        return retrieveTargetResultsByPipelineInstanceId(pipelineInstanceId,
            Integer.MIN_VALUE, Integer.MAX_VALUE);
    }

    /**
     * Retrieves {@link DvTargetResults} by pipeline instance ID.
     * 
     * @param pipelineInstanceId a completed pipeline instance ID
     * @param minKeplerId inclusive
     * @param maxKeplerId inclusive
     * @return a non-{@code null} list of {@link DvTargetResults} sorted by
     * {@code keplerId}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvTargetResults> retrieveTargetResultsByPipelineInstanceId(
        long pipelineInstanceId, int minKeplerId, int maxKeplerId) {

        Query query = createQuery(generateQueryStringTargetResultsByPipelineInstanceId(
            "", "order by results.keplerId", KeplerIdInterval));
        query.setLong("pipelineInstanceIdParam", pipelineInstanceId);
        query.setInteger("minKeplerId", minKeplerId);
        query.setInteger("maxKeplerId", maxKeplerId);

        List<DvTargetResults> targetResults = list(query);

        return targetResults;
    }

    public List<DvTargetResults> retrieveTargetResultsByPipelineInstanceId(
        long pipelineInstanceId, List<Integer> keplerIds) {

        Query query = createQuery(generateQueryStringTargetResultsByPipelineInstanceId(
            "", "order by results.keplerId", KeplerIdList));
        query.setLong("pipelineInstanceIdParam", pipelineInstanceId);
        query.setParameterList("keplerIds", keplerIds);

        List<DvTargetResults> targetResults = list(query);

        return targetResults;
    }

    /**
     * Retrieves the latest {@link DvTargetResults} that were generated by DV
     * pipelines in the COMPLETED, STOPPED, or ERRORS_STALLED state at or before
     * the specified pipeline instance.
     * 
     * @param maxPipelineInstanceId inclusive
     * @return return a non-{@code null} list of {@link DvTargetResults} sorted
     * by {@code keplerId}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvTargetResults> retrieveLatestCompletedOrErredTargetResultsBeforePipelineInstance(
        long maxPipelineInstanceId) {

        return retrieveLatestCompletedOrErredTargetResultsBeforePipelineInstance(
            maxPipelineInstanceId, Integer.MIN_VALUE, Integer.MAX_VALUE);
    }

    /**
     * Retrieves the most up to date {@link DvTargetResults} that were generated
     * by DV pipelines in the COMPLETED, STOPPED or ERRORS_STALLED state at or
     * before the specified pipeline instance.
     * 
     * @param maxPipelineInstanceId inclusive
     * @param minKeplerId inclusive
     * @param maxKeplerId inclusive
     * @return return a non-{@code null} list of {@link DvTargetResults} sorted
     * by {@code keplerId}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvTargetResults> retrieveLatestCompletedOrErredTargetResultsBeforePipelineInstance(
        long maxPipelineInstanceId, int minKeplerId, int maxKeplerId) {

        Query query = createQuery(generateQueryStringForTargetResultsBeforePipelineInstance(
            "", "order by results1.keplerId"));
        query.setParameter("maxInstanceId", maxPipelineInstanceId);
        query.setParameter("minKeplerId", minKeplerId);
        query.setParameter("maxKeplerId", maxKeplerId);

        List<DvTargetResults> targetResults = list(query);

        return targetResults;
    }

    /**
     * Retrieves the most up to date {@link DvTargetResults} that were generated
     * by the most recent DV pipeline in the COMPLETED, STOPPED or
     * ERRORS_STALLED state.
     * 
     * @param keplerIds
     * @return return a non-{@code null} list of {@link DvTargetResults} sorted
     * by {@code keplerId}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvTargetResults> retrieveLatestTargetResults(
        List<Integer> keplerIds) {

        List<DvTargetResults> targetResults = new LinkedList<DvTargetResults>();
        ListChunkIterator<Integer> keplerIdIterator = new ListChunkIterator<Integer>(
            keplerIds.iterator(), MAX_EXPRESSIONS);

        while (keplerIdIterator.hasNext()) {
            List<Integer> keplerIdsThisChunk = keplerIdIterator.next();
            StringBuilder inClause = new StringBuilder();

            for (int keplerId : keplerIdsThisChunk) {
                inClause.append(keplerId)
                    .append(',');
            }
            inClause.setLength(inClause.length() - 1);

            Query query = createQuery(generateQueryStringForTargetResultsBeforePipelineInstance(inClause.toString()));
            query.setParameter("maxInstanceId", Long.MAX_VALUE);

            List<DvTargetResults> chunkResults = list(query);
            targetResults.addAll(chunkResults);
        }

        return targetResults;
    }

    /**
     * Retrieves Kepler IDs which have target results that were generated by a
     * particular run of the DV pipeline.
     * 
     * @param pipelineInstanceId the particular pipeline run
     * @return a non-{@code null} list of distinct Kepler IDs in ascending order
     */
    public List<Integer> retrieveTargetResultsKeplerIdsByPipelineInstanceId(
        long pipelineInstanceId) {

        Query query = createQuery(generateQueryStringTargetResultsByPipelineInstanceId(
            "select distinct results.keplerId ", " order by results.keplerId",
            KeplerIdInterval));
        query.setLong("pipelineInstanceIdParam", pipelineInstanceId);
        query.setInteger("minKeplerId", Integer.MIN_VALUE);
        query.setInteger("maxKeplerId", Integer.MAX_VALUE);

        List<Integer> keplerIds = list(query);

        return keplerIds;
    }

    /**
     * Retrieves Kepler IDs which have target results that were generated by the
     * specified DV pipeline or a previous pipeline run.
     * 
     * @param maxPipelineInstanceId inclusive
     * @return a non-{@code null} list of distinct Kepler IDs in ascending order
     */
    public List<Integer> retrieveTargetResultsKeplerIdsBeforePipelineInstance(
        long maxPipelineInstanceId) {

        Query query = createQuery(generateQueryStringForTargetResultsBeforePipelineInstance(
            "select distinct results1.keplerId ", "order by results1.keplerId"));
        query.setParameter("minKeplerId", Integer.MIN_VALUE);
        query.setParameter("maxKeplerId", Integer.MAX_VALUE);
        query.setParameter("maxInstanceId", maxPipelineInstanceId);

        List<Integer> keplerIds = list(query);

        return keplerIds;
    }

    /**
     * 
     * @param selectPart Specify the fields retrieved else this can be empty,
     * but must be non-null.
     * @param orderBy The order by part. This can be empty, but must be
     * non-null.
     * @param keplerIdQueryType When query type is KeplerIdInterval this
     * generates a HQL query with the parameters "minKeplerId" and "maxKeplerId"
     * when the query type is KeplerIdList then this generates a query with the
     * parameter "keplerIds". "keplerIds" should be set to a list of
     * java.lang.Integer.
     * @return A valid query string.
     */
    private static String generateQueryStringTargetResultsByPipelineInstanceId(
        String selectPart, String orderBy, KeplerIdQueryType keplerIdQueryType) {

        StringBuilder queryString = new StringBuilder(128);
        queryString.append(selectPart)
            .append("\n")
            .append("from DvTargetResults results where ");
        switch (keplerIdQueryType) {
            case KeplerIdInterval:
                queryString.append("results.keplerId >= :minKeplerId ")
                    .append("and results.keplerId <= :maxKeplerId ");
                break;
            case KeplerIdList:
                queryString.append("results.keplerId in (:keplerIds) ");
                break;
            default:
                throw new IllegalStateException("Invalid query type: "
                    + keplerIdQueryType);
        }
        queryString.append("and results.pipelineTask.state in (")
            .append(PipelineTask.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineTask.State.PARTIAL.ordinal())
            .append(")")
            .append(
                " and results.pipelineTask.pipelineInstance.id = :pipelineInstanceIdParam ")
            .append("and results.pipelineTask.pipelineInstance.state in (")
            .append(PipelineInstance.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.STOPPED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.ERRORS_STALLED.ordinal())
            .append(")\n")
            .append(orderBy);

        return queryString.toString();
    }

    /**
     * 
     * @param selectPart Specify the fields retrieved else this can be empty,
     * but must be non-null.
     * @param orderBy The order by part. This can be empty, but must be
     * non-null.
     * @param keplerIdQueryType When query type is KeplerIdInterval this
     * generates a HQL query with the parameters "minKeplerId" and "maxKeplerId"
     * when the query type is KeplerIdList then this generates a query with the
     * parameter "keplerIds". "keplerIds" should be set to a list of
     * java.lang.Integer.
     * @return A valid query string.
     */
    private static String generateQueryStringForTargetResultsBeforePipelineInstance(
        String selectPart, String orderBy) {

        StringBuilder queryString = new StringBuilder();
        queryString.append(selectPart)
            .append("\n")
            .append("from DvTargetResults results1 where ")
            .append("results1.keplerId >= :minKeplerId ")
            .append("and results1.keplerId <= :maxKeplerId ")
            .append("and results1.pipelineTask.state in (")
            .append(PipelineTask.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineTask.State.PARTIAL.ordinal())
            .append(")")
            .append(" and results1.pipelineTask.pipelineInstance.id in ")
            .append("(select max(results2.pipelineTask.pipelineInstance.id) ")
            .append("from DvTargetResults results2 where ")
            .append("results2.pipelineTask.pipelineInstance.state in (")
            .append(PipelineInstance.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.ERRORS_STALLED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.STOPPED.ordinal())
            .append(")")
            .append(" and results2.keplerId = results1.keplerId ")
            .append(
                "and results2.pipelineTask.pipelineInstance.id <= :maxInstanceId) ")
            .append("\n")
            .append(orderBy);

        return queryString.toString();
    }

    private static String generateQueryStringForTargetResultsBeforePipelineInstance(
        String inClause) {

        StringBuilder queryString = new StringBuilder();
        queryString.append("from DvTargetResults results1 where ")
            .append("results1.keplerId in (")
            .append(inClause)
            .append(") ")
            .append("and results1.pipelineTask.state in (")
            .append(PipelineTask.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineTask.State.PARTIAL.ordinal())
            .append(")")
            .append(" and results1.pipelineTask.pipelineInstance.id in ")
            .append("(select max(results2.pipelineTask.pipelineInstance.id) ")
            .append("from DvTargetResults results2 where ")
            .append("results2.pipelineTask.pipelineInstance.state in (")
            .append(PipelineInstance.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.ERRORS_STALLED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.STOPPED.ordinal())
            .append(")")
            .append(" and results2.keplerId = results1.keplerId ")
            .append(
                "and results2.pipelineTask.pipelineInstance.id <= :maxInstanceId) ")
            .append("\n")
            .append("order by results1.keplerId");

        return queryString.toString();
    }

    /**
     * Retrieves all {@link DvLimbDarkeningModel}.
     * 
     * @return return a non-{@code null} list of {@link DvLimbDarkeningModel}s
     * sorted by {@code keplerId} and then by {@code targetTableId}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvLimbDarkeningModel> retrieveAllLimbDarkeningModels() {
        Criteria query = createCriteria(DvLimbDarkeningModel.class);
        query.addOrder(Order.asc("keplerId"));
        query.addOrder(Order.asc("targetTableId"));

        List<DvLimbDarkeningModel> limbDarkeningModels = list(query);

        return limbDarkeningModels;
    }

    /**
     * Retrieves all {@link DvLimbDarkeningModel} for the given target.
     * 
     * @param keplerId the target ID
     * @return return a non-{@code null} list of {@link DvLimbDarkeningModel}s
     * sorted by {@code targetTableId}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvLimbDarkeningModel> retrieveAllLimbDarkeningModels(
        int keplerId) {
        Criteria query = createCriteria(DvLimbDarkeningModel.class);
        query.add(Restrictions.eq("keplerId", keplerId));
        query.addOrder(Order.asc("targetTableId"));

        List<DvLimbDarkeningModel> limbDarkeningModels = list(query);

        return limbDarkeningModels;
    }

    /**
     * Retrieves all {@link DvLimbDarkeningModel} for the given pipeline.
     * 
     * @param pipelineInstanceId a completed pipeline instance ID
     * @return return a non-{@code null} list of {@link DvLimbDarkeningModel}s
     * sorted by {@code keplerId} and then by {@code targetTableId}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvLimbDarkeningModel> retrieveLimbDarkeningModelsByPipelineInstanceId(
        long pipelineInstanceId) {

        return retrieveLimbDarkeningModelsByPipelineInstanceId(
            pipelineInstanceId, Integer.MIN_VALUE, Integer.MAX_VALUE);
    }

    /**
     * Retrieves {@link DvLimbDarkeningModel} by pipeline instance ID.
     * 
     * @param pipelineInstanceId a completed pipeline instance ID
     * @param minKeplerId inclusive
     * @param maxKeplerId inclusive
     * @return a non-{@code null} list of {@link DvLimbDarkeningModel}s sorted
     * by {@code keplerId} and then by {@code targetTableId}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvLimbDarkeningModel> retrieveLimbDarkeningModelsByPipelineInstanceId(
        long pipelineInstanceId, int minKeplerId, int maxKeplerId) {

        Query query = createQuery(generateQueryStringLimbDarkeningModelsByPipelineInstanceId(
            "", "order by models.keplerId, models.targetTableId"));
        query.setLong("pipelineInstanceIdParam", pipelineInstanceId);
        query.setInteger("minKeplerId", minKeplerId);
        query.setInteger("maxKeplerId", maxKeplerId);

        List<DvLimbDarkeningModel> limbDarkeningModels = list(query);

        return limbDarkeningModels;
    }

    /**
     * Retrieves the latest {@link DvLimbDarkeningModel}s that were generated by
     * DV pipelines in the COMPLETED, STOPPED, or ERRORS_STALLED state at or
     * before the specified pipeline instance.
     * 
     * @param maxPipelineInstanceId inclusive
     * @return return a non-{@code null} list of {@link DvLimbDarkeningModel}s
     * sorted by {@code keplerId} and then by {@code targetTableId}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvLimbDarkeningModel> retrieveLatestCompletedOrErredLimbDarkeningModelsBeforePipelineInstance(
        long maxPipelineInstanceId) {

        return retrieveLatestCompletedOrErredLimbDarkeningModelsBeforePipelineInstance(
            maxPipelineInstanceId, Integer.MIN_VALUE, Integer.MAX_VALUE);
    }

    /**
     * Retrieves the most up to date {@link DvLimbDarkeningModel} that were
     * generated by DV pipelines in the COMPLETED, STOPPED or ERRORS_STALLED
     * state at or before the specified pipeline instance.
     * 
     * @param maxPipelineInstanceId inclusive
     * @param minKeplerId inclusive
     * @param maxKeplerId inclusive
     * @return return a non-{@code null} list of {@link DvLimbDarkeningModel}s
     * sorted by {@code keplerId} and then by {@code targetTableId}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvLimbDarkeningModel> retrieveLatestCompletedOrErredLimbDarkeningModelsBeforePipelineInstance(
        long maxPipelineInstanceId, int minKeplerId, int maxKeplerId) {

        Query query = createQuery(generateQueryStringForLimbDarkeningModelsBeforePipelineInstance(
            "", "order by model1.keplerId, model1.targetTableId"));
        query.setParameter("maxInstanceId", maxPipelineInstanceId);
        query.setParameter("minKeplerId", minKeplerId);
        query.setParameter("maxKeplerId", maxKeplerId);

        List<DvLimbDarkeningModel> limbDarkeningModels = list(query);

        return limbDarkeningModels;
    }

    /**
     * Retrieves the most up to date {@link DvLimbDarkeningModel} that were
     * generated by the most recent DV pipeline in the COMPLETED, STOPPED or
     * ERRORS_STALLED state.
     * 
     * @param keplerIds
     * @return return a non-{@code null} list of {@link DvLimbDarkeningModel}s
     * sorted by {@code keplerId} and then by {@code targetTableId}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<DvLimbDarkeningModel> retrieveLatestLimbDarkeningModels(
        List<Integer> keplerIds) {

        List<DvLimbDarkeningModel> limbDarkeningModels = new LinkedList<DvLimbDarkeningModel>();
        ListChunkIterator<Integer> keplerIdIterator = new ListChunkIterator<Integer>(
            keplerIds.iterator(), MAX_EXPRESSIONS);

        while (keplerIdIterator.hasNext()) {
            List<Integer> keplerIdsThisChunk = keplerIdIterator.next();
            StringBuilder inClause = new StringBuilder();

            for (int keplerId : keplerIdsThisChunk) {
                inClause.append(keplerId)
                    .append(',');
            }
            inClause.setLength(inClause.length() - 1);

            Query query = createQuery(generateQueryStringForLimbDarkeningModelsBeforePipelineInstance(inClause.toString()));
            query.setParameter("maxInstanceId", Long.MAX_VALUE);

            List<DvLimbDarkeningModel> chunkResults = list(query);
            limbDarkeningModels.addAll(chunkResults);
        }

        return limbDarkeningModels;
    }

    /**
     * Retrieves Kepler IDs which have limb darkening models that were generated
     * by a particular run of the DV pipeline.
     * 
     * @param pipelineInstanceId the particular pipeline run
     * @return a non-{@code null} list of distinct Kepler IDs in ascending order
     */
    public List<Integer> retrieveLimbDarkeningModelsKeplerIdsByPipelineInstanceId(
        long pipelineInstanceId) {

        Query query = createQuery(generateQueryStringLimbDarkeningModelsByPipelineInstanceId(
            "select distinct models.keplerId ", " order by models.keplerId"));
        query.setLong("pipelineInstanceIdParam", pipelineInstanceId);
        query.setInteger("minKeplerId", Integer.MIN_VALUE);
        query.setInteger("maxKeplerId", Integer.MAX_VALUE);

        List<Integer> keplerIds = list(query);

        return keplerIds;
    }

    /**
     * Retrieves Kepler IDs which limb darkening models that were generated by
     * the specified DV pipeline or a previous pipeline run.
     * 
     * @param maxPipelineInstanceId inclusive
     * @return a non-{@code null} list of distinct Kepler IDs in ascending order
     */
    public List<Integer> retrieveLimbDarkeningModelsKeplerIdsBeforePipelineInstance(
        long maxPipelineInstanceId) {

        Query query = createQuery(generateQueryStringForLimbDarkeningModelsBeforePipelineInstance(
            "select distinct model1.keplerId ", "order by model1.keplerId"));
        query.setParameter("minKeplerId", Integer.MIN_VALUE);
        query.setParameter("maxKeplerId", Integer.MAX_VALUE);
        query.setParameter("maxInstanceId", maxPipelineInstanceId);

        List<Integer> keplerIds = list(query);

        return keplerIds;
    }

    private static String generateQueryStringLimbDarkeningModelsByPipelineInstanceId(
        String selectPart, String orderBy) {

        StringBuilder queryString = new StringBuilder();
        queryString.append(selectPart)
            .append("\n")
            .append("from DvLimbDarkeningModel models where ")
            .append("models.keplerId >= :minKeplerId ")
            .append("and models.keplerId <= :maxKeplerId ")
            .append("and models.pipelineTask.state in (")
            .append(PipelineTask.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineTask.State.PARTIAL.ordinal())
            .append(")")
            .append(
                " and models.pipelineTask.pipelineInstance.id = :pipelineInstanceIdParam ")
            .append("and models.pipelineTask.pipelineInstance.state in (")
            .append(PipelineInstance.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.STOPPED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.ERRORS_STALLED.ordinal())
            .append(")\n")
            .append(orderBy);

        return queryString.toString();
    }

    private static String generateQueryStringForLimbDarkeningModelsBeforePipelineInstance(
        String selectPart, String orderBy) {

        StringBuilder queryString = new StringBuilder();
        queryString.append(selectPart)
            .append("\n")
            .append("from DvLimbDarkeningModel model1 where ")
            .append("model1.keplerId >= :minKeplerId ")
            .append("and model1.keplerId <= :maxKeplerId ")
            .append("and model1.pipelineTask.state in (")
            .append(PipelineTask.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineTask.State.PARTIAL.ordinal())
            .append(")")
            .append(" and model1.pipelineTask.pipelineInstance.id in ")
            .append("(select max(model2.pipelineTask.pipelineInstance.id) ")
            .append("from DvLimbDarkeningModel model2 where ")
            .append("model2.pipelineTask.pipelineInstance.state in (")
            .append(PipelineInstance.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.ERRORS_STALLED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.STOPPED.ordinal())
            .append(")")
            .append(" and model2.keplerId = model1.keplerId ")
            .append(
                "and model2.pipelineTask.pipelineInstance.id <= :maxInstanceId) ")
            .append("\n")
            .append(orderBy);

        return queryString.toString();
    }

    private static String generateQueryStringForLimbDarkeningModelsBeforePipelineInstance(
        String inClause) {

        StringBuilder queryString = new StringBuilder();
        queryString.append("from DvLimbDarkeningModel model1 where ")
            .append("model1.keplerId in (")
            .append(inClause)
            .append(") ")
            .append("and model1.pipelineTask.state in (")
            .append(PipelineTask.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineTask.State.PARTIAL.ordinal())
            .append(")")
            .append(" and model1.pipelineTask.pipelineInstance.id in ")
            .append("(select max(model2.pipelineTask.pipelineInstance.id) ")
            .append("from DvLimbDarkeningModel model2 where ")
            .append("model2.pipelineTask.pipelineInstance.state in (")
            .append(PipelineInstance.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.ERRORS_STALLED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.STOPPED.ordinal())
            .append(")")
            .append(" and model2.keplerId = model1.keplerId ")
            .append(
                "and model2.pipelineTask.pipelineInstance.id <= :maxInstanceId) ")
            .append("\n")
            .append("order by model1.keplerId, model1.targetTableId");

        return queryString.toString();
    }

    /**
     * Deletes the given {@link DvPlanetResults}.
     * 
     * @param planetResults the {@link DvPlanetResults} object to delete
     * @throws HibernateException if there were problems accessing the database
     */
    public void delete(DvPlanetResults planetResults) {
        getSession().delete(planetResults);
    }

    /**
     * Deletes the given collection of {@link DvPlanetResults}.
     * 
     * @param planetResultsCollection the {@link DvPlanetResults} objects to
     * delete
     * @throws HibernateException if there were problems accessing the database
     * @throws NullPointerException if {@code planetResultsCollection} is
     * {@code null}
     */
    public void deletePlanetResultsCollection(
        Collection<DvPlanetResults> planetResultsCollection) {

        for (DvPlanetResults planetResults : planetResultsCollection) {
            delete(planetResults);
        }
    }

    /**
     * Deletes the given {@link DvLimbDarkeningModel}.
     * 
     * @param limbDarkeningModel the {@link DvLimbDarkeningModel} object to
     * delete
     * @throws HibernateException if there were problems accessing the database
     */
    public void delete(DvLimbDarkeningModel limbDarkeningModel) {
        getSession().delete(limbDarkeningModel);
    }

    /**
     * Deletes the given collection of {@link DvLimbDarkeningModel}.
     * 
     * @param limbDarkeningModelCollection the {@link DvLimbDarkeningModel}
     * objects to delete
     * @throws HibernateException if there were problems accessing the database
     * @throws NullPointerException if {@code limbDarkeningModelCollection} is
     * {@code null}
     */
    public void deleteLimbDarkeningModelCollection(
        Collection<DvLimbDarkeningModel> limbDarkeningModelCollection) {

        for (DvLimbDarkeningModel limbDarkeningModel : limbDarkeningModelCollection) {
            delete(limbDarkeningModel);
        }
    }

    /**
     * Deletes the given {@link DvTargetResults}.
     * 
     * @param targetResults the {@link DvTargetResults} object to delete
     * @throws HibernateException if there were problems accessing the database
     */
    public void delete(DvTargetResults targetResults) {
        getSession().delete(targetResults);
    }

    /**
     * Deletes the given collection of {@link DvTargetResults}.
     * 
     * @param targetResultsCollection the {@link DvTargetResults} objects to
     * delete
     * @throws HibernateException if there were problems accessing the database
     * @throws NullPointerException if {@code targetResultsCollection} is
     * {@code null}
     */
    public void deleteTargetResultsCollection(
        Collection<DvTargetResults> targetResultsCollection) {

        for (DvTargetResults targetResults : targetResultsCollection) {
            delete(targetResults);
        }
    }

    /**
     * Create a List of {@link UkirtImageBlobMetadata} instances in the
     * database.
     * 
     * @param UkirtImageBlobMetadataList
     */
    public void createUkirtImageBlobMetadata(
        List<UkirtImageBlobMetadata> ukirtImageBlobMetadataList) {
        if (ukirtImageBlobMetadataList == null) {
            throw new NullPointerException("ukirtImageBlobMetadataList is null");
        }
        if (ukirtImageBlobMetadataList.isEmpty()) {
            throw new IllegalArgumentException(
                "ukirtImageBlobMetadataList is empty");
        }
        for (UkirtImageBlobMetadata metadata : ukirtImageBlobMetadataList) {
            createUkirtImageBlobMetadata(metadata);
        }
    }

    /**
     * Create a {@link UkirtImageBlobMetadata} instance in the database.
     * 
     * @param backgroundBlobMetadata
     */
    public void createUkirtImageBlobMetadata(
        UkirtImageBlobMetadata ukirtImageBlobMetadata) {
        if (ukirtImageBlobMetadata == null) {
            throw new NullPointerException("ukirtImageBlobMetadata is null");
        }
        getSession().save(ukirtImageBlobMetadata);
    }

    /**
     * Retrieves all {@link UkirtImageBlobMetadata} for the given target.
     * 
     * @param keplerId the target ID
     * @return return a non-{@code null} list of {@link UkirtImageBlobMetadata}s
     * sorted by {@code createTime}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<UkirtImageBlobMetadata> retrieveUkirtImageBlobMetadata(
        int keplerId) {

        Criteria query = getSession().createCriteria(
            UkirtImageBlobMetadata.class);
        query.add(Restrictions.eq("keplerId", keplerId));
        query.addOrder(Order.asc("createTime"));

        List<UkirtImageBlobMetadata> list = list(query);

        return list;
    }

    public List<Integer> retrieveKeplerIdsForUkirtImages(
        List<String> targetListNames, int skyGroupId, int startKeplerId,
        int endKeplerId) {

        if (targetListNames.size() == 0) {
            List<Integer> empty = Collections.emptyList();
            return empty;
        }
        StringBuilder queryString = new StringBuilder(128);
        queryString.append("select distinct um.keplerId from")
            .append(" UkirtImageBlobMetadata um, PlannedTarget pt\n")
            .append("where um.keplerId >= :startKeplerId and\n")
            .append(" um.keplerId <= :endKeplerId and\n")
            .append(" um.keplerId = pt.keplerId and\n")
            .append(" pt.skyGroupId = :skyGroupIdParam and\n")
            .append(" pt.targetList.name in (\n");

        for (int i = 0; i < targetListNames.size(); i++) {
            queryString.append(":tl")
                .append(i)
                .append(',');
        }
        queryString.setLength(queryString.length() - 1);
        queryString.append(")\n order by um.keplerId");

        Query query = getSession().createQuery(queryString.toString());
        query.setInteger("startKeplerId", startKeplerId);
        query.setInteger("endKeplerId", endKeplerId);
        query.setInteger("skyGroupIdParam", skyGroupId);

        for (int i = 0; i < targetListNames.size(); i++) {
            query.setString("tl" + i, targetListNames.get(i));
        }

        if (log.isDebugEnabled()) {
            log.debug(queryString);
        }
        List<Integer> keplerIds = list(query);

        return keplerIds;
    }

    public void create(DvTransitModelDescriptions transitModelDescriptions) {
        getSession().save(transitModelDescriptions);
    }

    public void createTransitModelDescriptionsCollection(
        Collection<DvTransitModelDescriptions> transitModelDescriptions) {
        for (DvTransitModelDescriptions transitModelDescription : transitModelDescriptions) {
            create(transitModelDescription);
        }
    }

    public void delete(DvTransitModelDescriptions transitModelDescriptions) {
        getSession().delete(transitModelDescriptions);
    }

    public List<DvTransitModelDescriptions> retrieveTransitModelDescriptions(
        long pipelineInstanceId) {

        Query query = createQuery(generateQueryStringTransitModelDescriptionsByPipelineInstanceId(
            "", " order by pipelineTask.id"));
        query.setLong("pipelineInstanceIdParam", pipelineInstanceId);

        List<DvTransitModelDescriptions> transitModelDescriptions = list(query);

        String transitNameModelDescription = null;
        String transitParameterModelDescription = null;
        for (DvTransitModelDescriptions transitModelDescription : transitModelDescriptions) {
            if (transitNameModelDescription == null) {
                transitNameModelDescription = transitModelDescription.getNameModelDescription();
                transitParameterModelDescription = transitModelDescription.getParameterModelDescription();
            } else if (!transitNameModelDescription.equals(transitModelDescription.getNameModelDescription())
                || !transitParameterModelDescription.equals(transitModelDescription.getParameterModelDescription())) {
                throw new IllegalStateException(
                    "Transit model descriptions must be the same for all tasks in a pipeline.");
            }
        }

        return transitModelDescriptions;
    }

    public DvTransitModelDescriptions retrieveTransitModelDescriptions(
        PipelineTask pipelineTask) {

        Query query = createQuery("from DvTransitModelDescriptions where "
            + "pipelineTask.id = :pipelineTaskId");
        query.setLong("pipelineTaskId", pipelineTask.getId());

        DvTransitModelDescriptions transitModelDescriptions = uniqueResult(query);

        return transitModelDescriptions;
    }

    public List<DvTransitModelDescriptions> retrieveLatestCompletedOrErredTransitModelDescriptionsBeforePipelineInstance(
        long maxPipelineInstanceId) {

        Query query = createQuery(generateQueryStringForTransitModelDescriptionsBeforePipelineInstance(
            "", "order by description1.pipelineTask.id"));
        query.setParameter("maxInstanceId", maxPipelineInstanceId);

        List<DvTransitModelDescriptions> transitModelDescriptions = list(query);

        return transitModelDescriptions;
    }

    private static String generateQueryStringTransitModelDescriptionsByPipelineInstanceId(
        String selectPart, String orderBy) {

        StringBuilder queryString = new StringBuilder();
        queryString.append(selectPart)
            .append("\n")
            .append("from DvTransitModelDescriptions where ")
            .append(" pipelineTask.state in (")
            .append(PipelineTask.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineTask.State.PARTIAL.ordinal())
            .append(")")
            .append(
                " and pipelineTask.pipelineInstance.id = :pipelineInstanceIdParam ")
            .append("and pipelineTask.pipelineInstance.state in (")
            .append(PipelineInstance.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.STOPPED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.ERRORS_STALLED.ordinal())
            .append(")\n")
            .append(orderBy);

        return queryString.toString();
    }

    private static String generateQueryStringForTransitModelDescriptionsBeforePipelineInstance(
        String selectPart, String orderBy) {

        StringBuilder queryString = new StringBuilder();
        queryString.append(selectPart)
            .append("\n")
            .append("from DvTransitModelDescriptions description1 where ")
            .append("description1.pipelineTask.state in (")
            .append(PipelineTask.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineTask.State.PARTIAL.ordinal())
            .append(")")
            .append(" and description1.pipelineTask.pipelineInstance.id in ")
            .append(
                "(select max(description2.pipelineTask.pipelineInstance.id) ")
            .append("from DvTransitModelDescriptions description2 where ")
            .append("description2.pipelineTask.pipelineInstance.state in (")
            .append(PipelineInstance.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.ERRORS_STALLED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.STOPPED.ordinal())
            .append(")")
            .append(
                " and description2.pipelineTask.pipelineInstance.id <= :maxInstanceId) ")
            .append("\n")
            .append(orderBy);

        return queryString.toString();
    }

    public void create(DvExternalTceModelDescription externalTceModelDescription) {
        getSession().save(externalTceModelDescription);
    }

    public void createExternalTceModelDescriptionCollection(
        Collection<DvExternalTceModelDescription> externalTceModelDescriptions) {
        for (DvExternalTceModelDescription externalTceModelDescription : externalTceModelDescriptions) {
            create(externalTceModelDescription);
        }
    }

    public void delete(DvExternalTceModelDescription externalTceModelDescription) {
        getSession().delete(externalTceModelDescription);
    }

    public List<DvExternalTceModelDescription> retrieveExternalTceModelDescription(
        long pipelineInstanceId) {

        Query query = createQuery(generateQueryStringExternalTceModelDescriptionsByPipelineInstanceId(
            "", " order by pipelineTask.id"));
        query.setLong("pipelineInstanceIdParam", pipelineInstanceId);

        List<DvExternalTceModelDescription> externalTceModelDescriptions = list(query);

        String modelDescription = null;
        for (DvExternalTceModelDescription externalTceModelDescription : externalTceModelDescriptions) {
            if (modelDescription == null) {
                modelDescription = externalTceModelDescription.getModelDescription();
            } else if (!modelDescription.equals(externalTceModelDescription.getModelDescription())) {
                throw new IllegalStateException(
                    "External TCE model descriptions must be the same for all tasks in a pipeline.");
            }
        }

        return externalTceModelDescriptions;
    }

    public DvExternalTceModelDescription retrieveExternalTceModelDescription(
        PipelineTask pipelineTask) {

        Query query = createQuery("from DvExternalTceModelDescription where "
            + "pipelineTask.id = :pipelineTaskId");
        query.setLong("pipelineTaskId", pipelineTask.getId());

        DvExternalTceModelDescription externalTceModelDescription = uniqueResult(query);

        return externalTceModelDescription;
    }

    public List<DvExternalTceModelDescription> retrieveLatestCompletedOrErredExternalTceModelDescriptionBeforePipelineInstance(
        long maxPipelineInstanceId) {

        Query query = createQuery(generateQueryStringForExternalTceModelDescriptionsBeforePipelineInstance(
            "", "order by description1.pipelineTask.id"));
        query.setParameter("maxInstanceId", maxPipelineInstanceId);

        List<DvExternalTceModelDescription> externalTceModelDescriptions = list(query);

        return externalTceModelDescriptions;
    }

    private static String generateQueryStringExternalTceModelDescriptionsByPipelineInstanceId(
        String selectPart, String orderBy) {

        StringBuilder queryString = new StringBuilder();
        queryString.append(selectPart)
            .append("\n")
            .append("from DvExternalTceModelDescription where ")
            .append(" pipelineTask.state in (")
            .append(PipelineTask.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineTask.State.PARTIAL.ordinal())
            .append(")")
            .append(
                " and pipelineTask.pipelineInstance.id = :pipelineInstanceIdParam ")
            .append("and pipelineTask.pipelineInstance.state in (")
            .append(PipelineInstance.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.STOPPED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.ERRORS_STALLED.ordinal())
            .append(")\n")
            .append(orderBy);

        return queryString.toString();
    }

    private static String generateQueryStringForExternalTceModelDescriptionsBeforePipelineInstance(
        String selectPart, String orderBy) {

        StringBuilder queryString = new StringBuilder();
        queryString.append(selectPart)
            .append("\n")
            .append("from DvExternalTceModelDescription description1 where ")
            .append("description1.pipelineTask.state in (")
            .append(PipelineTask.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineTask.State.PARTIAL.ordinal())
            .append(")")
            .append(" and description1.pipelineTask.pipelineInstance.id in ")
            .append(
                "(select max(description2.pipelineTask.pipelineInstance.id) ")
            .append("from DvExternalTceModelDescription description2 where ")
            .append("description2.pipelineTask.pipelineInstance.state in (")
            .append(PipelineInstance.State.COMPLETED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.ERRORS_STALLED.ordinal())
            .append(", ")
            .append(PipelineInstance.State.STOPPED.ordinal())
            .append(")")
            .append(
                " and description2.pipelineTask.pipelineInstance.id <= :maxInstanceId) ")
            .append("\n")
            .append(orderBy);

        return queryString.toString();
    }

    public static final class DvPlanetSummary {
        public final int[] planetNumbers;
        public final int keplerId;
        public final long pipelineInstanceId;
        public final int startCadence;
        public final int endCadence;
        public final long pipelineTaskId;

        public DvPlanetSummary(int startCadence, int endCadence,
            int[] planetNumbers, int keplerId, long pipelineInstanceId,
            long pipelineTaskId) {

            this.planetNumbers = planetNumbers;
            this.keplerId = keplerId;
            this.pipelineInstanceId = pipelineInstanceId;
            this.startCadence = startCadence;
            this.endCadence = endCadence;
            this.pipelineTaskId = pipelineTaskId;
        }
    }
}
