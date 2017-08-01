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

package gov.nasa.kepler.hibernate.tps;

import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.common.pi.TpsType;
import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.PlanetaryCandidatesFilter;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.spiffy.common.collect.ListChunkIterator;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Query;

/**
 * CRUD for Tps objects.
 * 
 * @author Sean McCauliff
 * 
 */
public class TpsCrud extends AbstractCrud {
    private static final Log log = LogFactory.getLog(TpsCrud.class);

    public void create(AbstractTpsDbResult tpsResult) {
        getSession().save(tpsResult);
    }

    public void delete(AbstractTpsDbResult tpsResult) {
        getSession().delete(tpsResult);
    }


    public List<TpsLiteDbResult> retrieveTpsLiteResult(
        Collection<Integer> keplerIds) {
        return retrieveTpsXResult(keplerIds, TpsLiteDbResult.class);
    }

    public List<TpsDbResult> retrieveTpsResult(Collection<Integer> keplerIds) {
        return retrieveTpsXResult(keplerIds, TpsDbResult.class);
    }

    public List<TpsDbResult> retrieveTpsResults() {
        Query q = getSession().createQuery("from TpsDbResult");
        return list(q);
    }

    public List<TpsDbResult> retrieveTpsResultByPipelineInstanceId(
           int startKeplerId, int endKeplerId, long pipelineInstanceId) {
       
        List<TpsDbResult> rv = 
            retrieveByPipelineTaskId("", startKeplerId,
                                    endKeplerId, pipelineInstanceId, TpsDbResult.class);
        return rv;
    }
    
    public List<TpsDbResult> retrieveTpsResultByPipelineInstanceIdSkyGroupId(
        int startKeplerId, int endKeplerId, long pipelineInstanceId,
        int skyGroupId) {
        
        String queryStr = 
            " select tps from TpsDbResult as tps, Kic as kic\n" +
            " where\n" +
            "  kic.keplerId = tps.keplerId\n" +
            "  and tps.originator.pipelineInstance.id = :paramPipelineInstanceId\n" +
            "  and tps.keplerId >= :paramStartKeplerId\n" +
            "  and tps.keplerId <= :paramEndKeplerId\n" +
            "  and kic.skyGroupId = :skyGroupId\n" +
            " order by tps.keplerId, tps.trialTransitPulseInHours";
        
            Query q = getSession().createQuery(queryStr);
            q.setParameter("paramPipelineInstanceId", pipelineInstanceId);
            q.setParameter("paramStartKeplerId", startKeplerId);
            q.setParameter("paramEndKeplerId", endKeplerId);
            q.setParameter("skyGroupId", skyGroupId);
            
        return list(q);
    }
    
    public List<TpsLiteDbResult> retrieveTpsLiteResultByPipelineInstanceId(
        int startKeplerId, int endKeplerId, long pipelineInstanceId) {
        
        List<TpsLiteDbResult> rv = 
            retrieveByPipelineTaskId("", startKeplerId,
                                    endKeplerId, pipelineInstanceId, TpsLiteDbResult.class);
        return rv;
    }
    
    public List<Integer> retrieveTpsResultKeplerIdsByPipelineInstanceId(
        int startKeplerId, int endKeplerId, long pipelineInstanceId) {
        
        List<Integer> rv = 
            retrieveByPipelineTaskId("select distinct tps.keplerId", startKeplerId,
                                    endKeplerId, pipelineInstanceId, TpsDbResult.class);
        return rv;
    }
    
    
    public List<Integer> retrieveTpsLiteResultKeplerIdsByPipelineInstanceId(
        int startKeplerId, int endKeplerId, long pipelineInstanceId) {
        
        List<Integer> rv = 
            retrieveByPipelineTaskId("select distinct tps.keplerId", startKeplerId,
                                    endKeplerId, pipelineInstanceId, TpsLiteDbResult.class);
        return rv;
    }
    
    private <E> List<E> retrieveByPipelineTaskId(String projection,
        int startKeplerId, int endKeplerId, long pipelineInstanceId, Class<? extends AbstractTpsDbResult> resultType) {
        String queryStr = projection + " from " + resultType.getSimpleName() + " tps where " +
        " tps.originator.pipelineInstance.id = :paramPipelineInstanceId " +
        " and tps.keplerId >= :paramStartKeplerId " +
        " and tps.keplerId <= :paramEndKeplerId " +
        " order by keplerId ";
    
        Query q = getSession().createQuery(queryStr);
        q.setParameter("paramPipelineInstanceId", pipelineInstanceId);
        q.setParameter("paramStartKeplerId", startKeplerId);
        q.setParameter("paramEndKeplerId", endKeplerId);
        
        return list(q);
    }
    
    
    /**
     * @param startKeplerId
     * @param endKeplerId inclusive.
     * @return A non-null list of full tps results for the specified Kepler ids.
     */
    public List<TpsDbResult> retrieveTpsResult(int startKeplerId,
        int endKeplerId) {
        String queryStr = " from TpsDbResult where keplerId >= :paramStartKeplerId and keplerId <= :paramEndKeplerId";

        Query q = getSession().createQuery(queryStr);
        q.setInteger("paramStartKeplerId", startKeplerId);
        q.setInteger("paramEndKeplerId", endKeplerId);

        List<TpsDbResult> rv = list(q);
        return rv;
    }

    /**
     * @return The list of kepler ids with full tps results regardless of their
     * status as planetary candidates. These are distinct and sorted.
     */
    public List<Integer> retrieveKeplerIds() {
        Query q = getSession().createQuery(
            "select distinct keplerId from TpsDbResult order by keplerId");
        List<Integer> rv = list(q);
        return rv;
    }

    public List<TpsDbResult> retrieveLatestTpsResults(
        PlanetaryCandidatesFilter filter) {
        List<Integer> keplerIds = new ArrayList<Integer>();
        keplerIds.add(TargetManagementConstants.INVALID_KEPLER_ID);

        return retrieveLatestTpsResultsInternal(
            "and t.keplerId not in (:keplerIds) ", keplerIds, filter);
    }

    public List<TpsDbResult> retrieveLatestTpsResults(List<Integer> keplerIds,
        PlanetaryCandidatesFilter filter) {
        return retrieveLatestTpsResultsInternal(
            "and t.keplerId in (:keplerIds) ", keplerIds, filter);
    }
    
    public List<TpsDbResult> retrieveTpsResultByKeplerIdsPipelineInstanceId(
        List<Integer> keplerIds, long instanceId) {

        ListChunkIterator<Integer> keplerIdIterator = new ListChunkIterator<Integer>(
            keplerIds.iterator(), MAX_EXPRESSIONS);
        
        List<TpsDbResult> tpsResults = new ArrayList<TpsDbResult>();
        while (keplerIdIterator.hasNext()) {
            List<Integer> nextKeplerIds = keplerIdIterator.next();

            Query query = getSession().createQuery(
                "select t from TpsDbResult t, PipelineTask p where "
                    + "p.id = t.originator.id and "
                    + "p.pipelineInstance.id = :instanceId "
                    + "and t.keplerId in (:keplerIds) ");
            query.setParameter("instanceId", instanceId);
            query.setParameterList("keplerIds", nextKeplerIds);

            List<TpsDbResult> queryResults = list(query);
            tpsResults.addAll(queryResults);
        }

        return tpsResults;
    }

    private List<TpsDbResult> retrieveLatestTpsResultsInternal(
        String keplerIdsStringForQuery, List<Integer> keplerIds,
        PlanetaryCandidatesFilter filter) {
        Query query = getSession().createQuery(
            "select max(p.pipelineInstance.id) from TpsDbResult t, PipelineTask p where "
                + "p.id = t.originator.id");
        Long instanceId = uniqueResult(query);

        log.info("Latest TPS pipeline instance id: " + instanceId);
        
        ListChunkIterator<Integer> keplerIdIterator = new ListChunkIterator<Integer>(
            keplerIds.iterator(), MAX_EXPRESSIONS);

        // Select the TpsDbResults from the latest run where isPlanetACandidate
        // = true.
        List<TpsDbResult> tpsResults = new ArrayList<TpsDbResult>();
        while (keplerIdIterator.hasNext()) {
            List<Integer> nextKeplerIds = keplerIdIterator.next();

            query = getSession().createQuery(
                "select t from TpsDbResult t, PipelineTask p where "
                    + "p.id = t.originator.id and "
                    + "p.pipelineInstance.id = :instanceId "
                    + "and t.isPlanetACandidate = true "
                    + keplerIdsStringForQuery);
            query.setParameter("instanceId", instanceId);
            query.setParameterList("keplerIds", nextKeplerIds);

            List<TpsDbResult> queryResults = list(query);
            tpsResults.addAll(queryResults);
        }

        /* For a given target, we need to select out the pulse duration from the set 
         * for which isPlanetACandidate=true and orbital period > 0 that has the highest 
         * MES out of the subset of all those with MES/SES above threshold 
         */

        // For each keplerId, select the valid TpsDbResult with the largest
        // maxMultipleEventStatistic.
        Map<Integer, TpsDbResult> tpsResultByKeplerId = new TreeMap<Integer, TpsDbResult>();
        for (TpsDbResult tpsResult : tpsResults) {
            if (filter != null && !filter.included(tpsResult.getKeplerId())) {
                continue;
            }

            if (!tpsResult.isPlanetACandidate()) {
                continue;
            }
            
            if (tpsResult.getMaxMultipleEventStatistic() == null) {
                continue;
            }

            // we have a valid TCE for consideration, let's see if it's better
            // than the one we already have
            
            TpsDbResult existingTpsResult = 
                    tpsResultByKeplerId.get(tpsResult.getKeplerId());

            if (existingTpsResult == null ||
                tpsResult.getMaxMultipleEventStatistic() > existingTpsResult.getMaxMultipleEventStatistic()) {
                tpsResultByKeplerId.put(tpsResult.getKeplerId(), tpsResult);
            }

        }
        return new ArrayList<TpsDbResult>(tpsResultByKeplerId.values());
    }

    private <T extends AbstractTpsDbResult> List<T> retrieveTpsXResult(
        Collection<Integer> keplerIds, Class<T> resultClass) {
    
        StringBuilder bldr = new StringBuilder();
        bldr.append(" from ")
            .append(resultClass.getName())
            .append(" where keplerId in (:chunk)");

        final Query query = createQuery(bldr.toString());
        
        QueryFactory<Integer, T> queryFactory = new QueryFactory<Integer, T>() {
            @Override
            public Query produceQuery(List<Integer> nextChunk) {
                query.setParameterList("chunk", nextChunk);
                return query;
            }
        };

        List<T> results = aggregateResults(keplerIds, queryFactory);
        return results;
    }
    
    public List<TpsDbResult> retrieveTpsResultsForSbt(
        List<Integer> keplerIds) {
        
        return retrieveAllLatestTpsXResults(keplerIds, TpsDbResult.class);
    }
    
    public List<TpsLiteDbResult> retrieveAllLatestTpsLiteResults(
        List<Integer> keplerIds) {
        
        return retrieveAllLatestTpsXResults(keplerIds, TpsLiteDbResult.class);
    }
    
    private <T extends AbstractTpsDbResult> List<T> retrieveAllLatestTpsXResults(
        List<Integer> keplerIds, Class<T> resultClass) {
        Query query = getSession().createQuery(
            "select max(p.pipelineInstance.id) from "
                + resultClass.getName()
                + " t, PipelineTask p where "
                + "p.id = t.originator.id");
        Long instanceId = uniqueResult(query);

        ListChunkIterator<Integer> keplerIdIterator = new ListChunkIterator<Integer>(
            keplerIds.iterator(), MAX_EXPRESSIONS);

        // Select the TpsDbResults from the latest run.
        List<T> tpsResults = new ArrayList<T>();
        while (keplerIdIterator.hasNext()) {
            List<Integer> nextKeplerIds = keplerIdIterator.next();

            query = getSession().createQuery(
                "select t from "
                    + resultClass.getName()
                    + " t, PipelineTask p where "
                    + "p.id = t.originator.id and "
                    + "p.pipelineInstance.id = :instanceId "
                    + "and t.keplerId in (:keplerIds) "
                    + "order by t.trialTransitPulseInHours asc ");
            query.setParameter("instanceId", instanceId);
            query.setParameterList("keplerIds", nextKeplerIds);

            List<T> queryResults = list(query);
            tpsResults.addAll(queryResults);
        }

        return tpsResults;
    }
    
    /**
     * Gets the pipeline instance of the most recent TPS run of the specified type to complete.
     * 
     */
    public PipelineInstance retrieveLatestTpsRun(TpsType tpsType) {
        // TODO: call tpsTypeToClassSimpleName()
        String tpsResultStr;
        switch (tpsType) {
            case TPS_FULL: tpsResultStr = TpsDbResult.class.getSimpleName(); break;
            case TPS_LITE: tpsResultStr = TpsLiteDbResult.class.getSimpleName(); break;
            default:
                throw new IllegalStateException("Unknown tps type \"" + tpsType + "\".");
        }
        
        String queryStr = "select max(tps.originator.pipelineInstance.id) from " + 
            tpsResultStr + " tps where tps.originator.state = :taskState";
        Query query = getSession().createQuery(queryStr);
        query.setParameter("taskState", PipelineTask.State.COMPLETED);
        Long pipelineTaskId = (Long) query.uniqueResult();
        if (pipelineTaskId == null) {
            throw new IllegalStateException("Expected that at least one TPS result would exist in the database.");
        }
        PipelineInstance pipelineInstance = (PipelineInstance) getSession().get(PipelineInstance.class, pipelineTaskId);
        return pipelineInstance;
    }
    
    /**
     * Map the TypeType enumeration value onto the simple name of the class
     * that it specifies.
     * @param tpsType designates "full" or "lite" TPS
     * @return the simple name of the corresponding class
     */
    private String tpsTypeToClassSimpleName(TpsType tpsType) {
        String result;
        switch (tpsType) {
            case TPS_FULL: result = TpsDbResult.class.getSimpleName(); break;
            case TPS_LITE: result = TpsLiteDbResult.class.getSimpleName(); break;
            default:
                throw new IllegalStateException("Unknown tps type \"" + tpsType + "\".");
        }
        return result;
    }

    /**
     * @return the PipelineInstance of the most recent completed TPS run of the
     * specified type and which contains the specified cadence range.
     * @param tpsType specifies "full" or "lite" TPS
     * @param startCadence the PipelineInstance's start cadence must be no greater than this
     * @param endCadence the PipelineInstance's end cadence must be no less than this
     */
    public PipelineInstance retrieveLatestTpsRunForCadenceRange(TpsType tpsType,
            int startCadence, int endCadence) {
        final String tpsResultStr = tpsTypeToClassSimpleName(tpsType);
        // Partially specify the query as a String
        final String queryStr = 
            "SELECT MAX(tps.originator.pipelineInstance.id)"
            + " FROM " + tpsResultStr + " AS tps"
            + " WHERE tps.originator.state = :taskState"
            + " AND tps.startCadence <= :startCadence"
            + " AND tps.endCadence >= :endCadence";
        // Convert the query String into a query object
        final Query query = getSession().createQuery(queryStr);
        // Complete the query
        query.setParameter("taskState", PipelineTask.State.COMPLETED);
        query.setParameter("startCadence", startCadence);
        query.setParameter("endCadence", endCadence);
        // Execute the query
        final Long pipelineInstanceId = (Long)query.uniqueResult();
        if (pipelineInstanceId == null) {
            throw new IllegalStateException("Expected that at least one TPS result would exist in the database.");
        }
        // Map the PipelineInstance ID onto the PipelineInstance object
        final PipelineInstance pipelineInstance =
            (PipelineInstance) getSession().get(PipelineInstance.class, pipelineInstanceId);
        return pipelineInstance;
    }
}
