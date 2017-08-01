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

import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLogResult;
import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.collect.ListChunkIterator;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import javax.persistence.NonUniqueResultException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.criterion.Projections;
import org.hibernate.criterion.Restrictions;

/**
 * Data access operations for target and aperture objects.
 * 
 * @author tklaus
 * @author Miles Cote
 * 
 */
public class TargetCrud extends AbstractCrud implements TargetCrudInterface {

    private static final Log log = LogFactory.getLog(TargetCrud.class);

    private PixelLogCrud pixelLogCrud;
    private TargetSelectionCrud targetSelectionCrud;
    private KicCrud kicCrud;

    public TargetCrud() {
    }

    public TargetCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    private PixelLogCrud getPixelLogCrud() {
        if (pixelLogCrud == null) {
            pixelLogCrud = new LogCrud(getDatabaseService());
        }
        return pixelLogCrud;
    }

    private TargetSelectionCrud getTargetSelectionCrud() {
        if (targetSelectionCrud == null) {
            targetSelectionCrud = new TargetSelectionCrud(getDatabaseService());
        }
        return targetSelectionCrud;
    }

    private KicCrud getKicCrud() {
        if (kicCrud == null) {
            kicCrud = new KicCrud(getDatabaseService());
        }
        return kicCrud;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#retrieveTargetTableLog
     * (gov.nasa.kepler.hibernate.tad.TargetTable.TargetType, int, int)
     */
    @Override
    public TargetTableLog retrieveTargetTableLog(TargetType targetTableType,
        int cadenceStart, int cadenceEnd) {
        IntervalMetricKey key = IntervalMetric.start();

        List<TargetTableLog> targetTableLogs = retrieveTargetTableLogs(
            targetTableType, cadenceStart, cadenceEnd);
        if (targetTableLogs.size() == 0) {
            // Same semantics as uniqueResult().
            return null;
        }
        if (targetTableLogs.size() > 1) {
            throw new NonUniqueResultException(
                "Expected 1 target table log, not " + targetTableLogs.size());
        }

        IntervalMetric.stop(getMetricName("retrieveTargetTableLog"), key);

        return targetTableLogs.get(0);
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#retrieveObservedKeplerIds
     * (gov.nasa.kepler.hibernate.tad.TargetTable)
     */
    @Override
    public List<Integer> retrieveObservedKeplerIds(TargetTable ttable) {
        IntervalMetricKey key = IntervalMetric.start();

        String queryString = " select distinct ot.keplerId from ObservedTarget as ot \n"
            + "  where ot.targetTable = :targetTableParam \n"
            + "   and ot.rejected = false " + "  order by ot.keplerId";
        Query q = getSession().createQuery(queryString);
        q.setParameter("targetTableParam", ttable);

        List<Integer> list = list(q);

        IntervalMetric.stop(getMetricName("retrieveObservedKeplerIds"), key);

        return list;
    }

    public List<Integer> retrieveObservedKeplerIds(TargetTable ttable,
        int ccdModule, int ccdOutput) {
        IntervalMetricKey key = IntervalMetric.start();

        String queryString = " select distinct ot.keplerId from ObservedTarget as ot \n"
            + "  where ot.targetTable = :targetTableParam \n"
            + "   and ot.rejected = false \n"
            + "   and ot.ccdModule = :ccdModuleParam and ot.ccdOutput = :ccdOutputParam \n"
            + "  order by ot.keplerId";
        Query q = getSession().createQuery(queryString);
        q.setParameter("targetTableParam", ttable);
        q.setParameter("ccdModuleParam", ccdModule);
        q.setParameter("ccdOutputParam", ccdOutput);

        List<Integer> list = list(q);

        IntervalMetric.stop(getMetricName("retrieveObservedKeplerIds"), key);

        return list;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#retrieveTargetTableLogs
     * (gov.nasa.kepler.hibernate.tad.TargetTable.TargetType, int, int)
     */
    @Override
    public List<TargetTableLog> retrieveTargetTableLogs(
        TargetType targetTableType, int cadenceStart, int cadenceEnd) {
        IntervalMetricKey key = IntervalMetric.start();

        // Retrieve cadence logs from DR
        List<PixelLogResult> results = getPixelLogCrud().retrieveTableIdsForCadenceRange(
            targetTableType, cadenceStart, cadenceEnd);

        // Package the results with TargetTables
        List<TargetTableLog> logs = new ArrayList<TargetTableLog>();
        for (PixelLogResult result : results) {
            // Use the revised target table, if one is available.
            TargetTable targetTable = retrieveRevisedTargetTable(
                result.getTableId(), targetTableType);

            // If there is no revised target table available, then fall back to the uplinked target table.
            if (targetTable == null) {
                targetTable = retrieveUplinkedTargetTable(
                    result.getTableId(), targetTableType);
            }
            
            logs.add(new TargetTableLog(targetTable, result.getCadenceStart(),
                result.getCadenceEnd()));
        }

        IntervalMetric.stop(getMetricName("retrieveTargetTableLogs"), key);

        return logs;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#retrieveTargetDefinitions
     * (gov.nasa.kepler.hibernate.tad.TargetTable, int, int)
     */
    @Override
    public List<TargetDefinition> retrieveTargetDefinitions(
        TargetTable targetTable, int ccdModule, int ccdOutput) {
        IntervalMetricKey key = IntervalMetric.start();

        Query query = getSession().createQuery(
            "from TargetDefinition where " + "targetTable = :targetTable and "
                + "ccdModule = :ccdModule and " + "ccdOutput = :ccdOutput "
                + "order by indexInModuleOutput asc");
        query.setParameter("targetTable", targetTable);
        query.setParameter("ccdModule", ccdModule);
        query.setParameter("ccdOutput", ccdOutput);

        List<TargetDefinition> list = list(query);

        IntervalMetric.stop(getMetricName("retrieveTargetDefinitions"), key);

        return list;
    }

    public List<TargetDefinition> retrieveTargetDefinitions(
        TargetTable targetTable) {
        IntervalMetricKey key = IntervalMetric.start();

        Query query = getSession().createQuery(
            "from TargetDefinition where " + "targetTable = :targetTable "
                + "order by ccdModule, ccdOutput, indexInModuleOutput asc");
        query.setParameter("targetTable", targetTable);

        List<TargetDefinition> list = list(query);

        IntervalMetric.stop(getMetricName("retrieveTargetDefinitions"), key);

        return list;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#createTargetTable(gov
     * .nasa.kepler.hibernate.tad.TargetTable)
     */
    @Override
    public void createTargetTable(TargetTable targetTable) {
        IntervalMetricKey key = IntervalMetric.start();

        getSession().save(targetTable);

        IntervalMetric.stop(getMetricName("createTargetTable"), key);
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#retrieveTargetTable
     * (long)
     */
    @Override
    public TargetTable retrieveTargetTable(long id) {
        IntervalMetricKey key = IntervalMetric.start();

        Query query = getSession().createQuery(
            "from TargetTable where " + "id = :id");
        query.setParameter("id", id);
        TargetTable uniqueResult = uniqueResult(query);

        IntervalMetric.stop(getMetricName("retrieveTargetTable"), key);

        return uniqueResult;
    }
    
    /**
     * Get target table by its external id and type.
     * 
     * @param targetType like BACKGROUND, non-null
     * @param externaId This is the id known to the spacecraft not the database
     * identifier.
     */
    public TargetTable retrieveTargetTable(TargetType targetType, int externalId) {
       String queryStr = 
           "from TargetTable ttable where ttable.externalId = :externalIdParam "  +
           " and ttable.state = :stateParam and ttable.type = :targetTypeParam";
       Query query = getSession().createQuery(queryStr);
       query.setParameter("externalIdParam", externalId);
       query.setParameter("targetTypeParam", targetType);
       query.setParameter("stateParam", State.UPLINKED);
       
       return uniqueResult(query);
    }

    @Override
    public TargetTable retrieveTargetTable(int externalId,
        TargetType type, ExportTable.State state) {
        IntervalMetricKey key = IntervalMetric.start();

        Query query = getSession().createQuery(
            "from TargetTable where " + "state = :state and "
                + "externalId = :externalId and " + "type = :type");
        query.setParameter("state", state);
        query.setParameter("externalId", externalId);
        query.setParameter("type", type);
        TargetTable uniqueResult = uniqueResult(query);

        IntervalMetric.stop(getMetricName("retrieveRevisedTargetTable"), key);

        return uniqueResult;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#retrieveTargetTables
     * (gov.nasa.kepler.hibernate.tad.TargetTable.TargetType)
     */
    @Override
    public List<TargetTable> retrieveTargetTables(TargetType type) {
        IntervalMetricKey key = IntervalMetric.start();

        Query query = getSession().createQuery(
            "from TargetTable where " + "type = :type");
        query.setParameter("type", type);

        List<TargetTable> list = list(query);

        IntervalMetric.stop(getMetricName("retrieveTargetTables"), key);

        return list;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#retrieveUplinkedTargetTable
     * (int, gov.nasa.kepler.hibernate.tad.TargetTable.TargetType)
     */
    @Override
    public TargetTable retrieveUplinkedTargetTable(int externalId,
        TargetType type) {
        IntervalMetricKey key = IntervalMetric.start();

        Query query = getSession().createQuery(
            "from TargetTable where " + "state = :state and "
                + "externalId = :externalId and " + "type = :type");
        query.setParameter("state", State.UPLINKED);
        query.setParameter("externalId", externalId);
        query.setParameter("type", type);
        TargetTable uniqueResult = uniqueResult(query);

        IntervalMetric.stop(getMetricName("retrieveUplinkedTargetTable"), key);

        return uniqueResult;
    }

    public TargetTable retrieveRevisedTargetTable(int externalId,
        TargetType type) {
        IntervalMetricKey key = IntervalMetric.start();

        Query query = getSession().createQuery(
            "from TargetTable where " + "state = :state and "
                + "externalId = :externalId and " + "type = :type");
        query.setParameter("state", State.REVISED);
        query.setParameter("externalId", externalId);
        query.setParameter("type", type);
        TargetTable uniqueResult = uniqueResult(query);

        IntervalMetric.stop(getMetricName("retrieveRevisedTargetTable"), key);

        return uniqueResult;
    }

    /*
     * (non-Javadoc)
     * 
     * @seegov.nasa.kepler.hibernate.tad.TargetCrudInterface#
     * retrieveUplinkedTargetTables(java.util.Date, java.util.Date)
     */
    @Override
    public List<TargetTable> retrieveUplinkedTargetTables(Date start, Date end) {
        IntervalMetricKey key = IntervalMetric.start();

        Query query = getSession().createQuery(
            "from TargetTable where " + "state = :state and "
                + "plannedStartTime >= :start and " + "plannedEndTime <= :end");
        query.setParameter("state", State.UPLINKED);
        query.setParameter("start", start);
        query.setParameter("end", end);

        List<TargetTable> list = list(query);

        IntervalMetric.stop(getMetricName("retrieveUplinkedTargetTables"), key);

        return list;
    }

    /*
     * (non-Javadoc)
     * 
     * @seegov.nasa.kepler.hibernate.tad.TargetCrudInterface#
     * retrieveUplinkedTargetTables
     * (gov.nasa.kepler.hibernate.tad.TargetTable.TargetType)
     */
    @Override
    public List<TargetTable> retrieveUplinkedTargetTables(TargetType type) {
        IntervalMetricKey key = IntervalMetric.start();

        String queryString = "from TargetTable where state = :state"
            + " and type = :type ";
        Query q = getSession().createQuery(queryString);
        q.setParameter("state", State.UPLINKED);
        q.setParameter("type", type);

        List<TargetTable> list = list(q);

        IntervalMetric.stop(getMetricName("retrieveUplinkedTargetTables"), key);

        return list;

    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#retrieveKtcInfo(java
     * .util.Date, java.util.Date)
     */
    @Override
    public List<KtcInfo> retrieveKtcInfo(Date startUtc, Date stopUtc) {
        IntervalMetricKey key = IntervalMetric.start();

        String queryString = "select new gov.nasa.kepler.hibernate.tad.KtcInfo("
            + "   target.keplerId, ttable.type,  ttable.plannedStartTime,"
            + "   ttable.plannedEndTime, target.id, ttable.externalId, ttable.id) "
            + "  from "
            + "     ObservedTarget as target "
            + "  inner join target.targetTable as ttable "
            + "    with ttable.plannedStartTime >= :paramStart and ttable.plannedEndTime <= :paramEnd "
            + "         and (ttable.type = :lcTypeParam or ttable.type = :scTypeParam) "
            + "         and ttable.state = :paramState where target.keplerId >= 0 "
            + "  order by target.keplerId, ttable.type,  ttable.externalId";

        Query query = getSession().createQuery(queryString.toString());
        query.setParameter("paramStart", startUtc);
        query.setParameter("paramEnd", stopUtc);
        query.setParameter("paramState", ExportTable.State.UPLINKED);
        query.setParameter("lcTypeParam", TargetType.LONG_CADENCE);
        query.setParameter("scTypeParam", TargetType.SHORT_CADENCE);
        List<KtcInfo> it = list(query);

        IntervalMetric.stop(getMetricName("retrieveKtcInfo"), key);

        return it;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#retrieveOrderedExternalIds
     * (gov.nasa.kepler.hibernate.tad.TargetTable.TargetType)
     */
    @Override
    public List<Integer> retrieveOrderedExternalIds(TargetType tableType) {
        IntervalMetricKey key = IntervalMetric.start();

        String queryString = "select  distinct(ttable.externalId) from TargetTable ttable "
            + " where ttable.type = :typeParam and ttable.state = :stateParam "
            + " order by ttable.externalId ";
        Query query = getSession().createQuery(queryString);
        query.setParameter("stateParam", ExportTable.State.UPLINKED);
        query.setParameter("typeParam", tableType);

        List<Integer> idList = list(query);

        IntervalMetric.stop(getMetricName("retrieveOrderedExternalIds"), key);

        return idList;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#retrieveCategoriesForTarget
     * (long, long)
     */
    @Override
    public List<String> retrieveCategoriesForTarget(long observedTargetId,
        long targetTableId) {
        IntervalMetricKey key = IntervalMetric.start();

        String queryString = "select distinct tl.category \n"
            + " from \n"
            + "   PlannedTarget as pt \n"
            + "       inner join pt.targetList as tl, \n"
            + "   TargetListSet as tls \n"
            + "        inner join tls.targetLists as tlsTargetLists\n"
            + "        inner join tls.targetTable as ttable with ttable.id = :targetTableIdParam, \n"
            + "   ObservedTarget as ot \n " + " where \n"
            + "   ot.id = :observedTargetIdParam \n"
            + "   and ot.keplerId = pt.keplerId \n"
            + "   and tl in tlsTargetLists\n"
            + "   and ot.targetTable = ttable " + " order by tl.category";

        Query query = getSession().createQuery(queryString);
        query.setParameter("targetTableIdParam", targetTableId);
        query.setParameter("observedTargetIdParam", observedTargetId);

        List<String> result = list(query);

        IntervalMetric.stop(getMetricName("retrieveCategoriesForTarget"), key);

        return result;
    }

    @Override
    public List<String> retrieveLabelsForObservedTarget(long observedTargetDbId) {
        IntervalMetricKey key = IntervalMetric.start();

        // This is an SQL query because there is no way to do this with Criteria
        // or HQL. Getting the ObservedTarget object and then the labels
        // eats up much CPU and memory.
        SQLQuery sqlQuery = getSession().createSQLQuery(
            "select distinct element " + "from tad_observed_target_labels "
                + "where tad_observed_target_id = " + observedTargetDbId
                + " order by element");

        List<String> rv = list(sqlQuery);

        IntervalMetric.stop(getMetricName("retrieveLabelsForObservedTarget"),
            key);

        return rv;

    }

    /*
     * (non-Javadoc)
     * 
     * @seegov.nasa.kepler.hibernate.tad.TargetCrudInterface#
     * retrieveCategoriesForTargetTable
     * (gov.nasa.kepler.hibernate.tad.TargetTable)
     */
    @Override
    public Map<Long, List<String>> retrieveCategoriesForTargetTable(
        TargetTable ttable) {
        IntervalMetricKey key = IntervalMetric.start();

        String queryString = "select distinct tl.category, ot.id \n"
            + " from \n" + "   PlannedTarget as pt \n"
            + "       inner join pt.targetList as tl, \n"
            + "   TargetListSet as tls \n"
            + "        inner join tls.targetLists as tlsTargetLists\n"
            + "        inner join tls.targetTable as ttable, \n"
            + "   ObservedTarget as ot where \n"
            + "   ot.keplerId = pt.keplerId \n"
            + "   and tl in tlsTargetLists\n"
            + "   and ot.targetTable = ttable \n"
            + "   and ttable = :ttableParam \n";
        Query q = createQuery(queryString);
        q.setParameter("ttableParam", ttable);

        Map<Long, List<String>> rv = new HashMap<Long, List<String>>();
        List<Object[]> queryResult = list(q);
        for (Object[] row : queryResult) {
            Long otId = (Long) row[1];
            List<String> categories = rv.get(otId);
            if (categories == null) {
                categories = new ArrayList<String>();
                rv.put(otId, categories);
            }
            categories.add((String) row[0]);
        }

        IntervalMetric.stop(getMetricName("retrieveCategoriesForTargetTable"),
            key);

        return rv;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#delete(gov.nasa.kepler
     * .hibernate.tad.TargetTable)
     */
    @Override
    public void delete(TargetTable targetTable) {
        IntervalMetricKey key = IntervalMetric.start();

        if (targetTable != null) {
            long targetTableId = targetTable.getId();

            Query query = getSession().createSQLQuery(
                "delete from TAD_OBS_TARGET_TARGET_DEFS where TAD_TARGET_DEFINITION_ID in (select ID from TAD_TARGET_DEFINITION where TAD_TARGET_TABLE_ID = "
                    + targetTableId + ")");
            query.executeUpdate();

            query = getSession().createSQLQuery(
                "delete from TAD_TARGET_DEFINITION where TAD_TARGET_TABLE_ID = "
                    + targetTableId);
            query.executeUpdate();

            query = getSession().createSQLQuery(
                "delete from TAD_OBSERVED_TARGET_LABELS where TAD_OBSERVED_TARGET_ID in (select ID from TAD_OBSERVED_TARGET where TAD_TARGET_TABLE_ID = "
                    + targetTableId + ")");
            query.executeUpdate();

            query = getSession().createSQLQuery(
                "delete from TAD_OBSERVED_TARGET where TAD_TARGET_TABLE_ID = "
                    + targetTableId);
            query.executeUpdate();

            query = getSession().createSQLQuery(
                "delete from TAD_APERTURE_OFFSETS where TAD_APERTURE_ID in (select ID from TAD_APERTURE where TAD_TARGET_TABLE_ID = "
                    + targetTableId + ")");
            query.executeUpdate();

            query = getSession().createSQLQuery(
                "delete from TAD_APERTURE where TAD_TARGET_TABLE_ID = "
                    + targetTableId);
            query.executeUpdate();

            query = getSession().createSQLQuery(
                "delete from TAD_IMAGE where TAD_TARGET_TABLE_ID = "
                    + targetTableId);
            query.executeUpdate();

            TadReport tadReport = targetTable.getTadReport();
            if (tadReport != null) {
                getSession().delete(tadReport);
            }

            getSession().delete(targetTable);
        }

        IntervalMetric.stop(getMetricName("delete"), key);
    }

    /*
     * (non-Javadoc)
     * 
     * @seegov.nasa.kepler.hibernate.tad.TargetCrudInterface#
     * retrieveMaxUplinkedExternalId
     * (gov.nasa.kepler.hibernate.tad.TargetTable.TargetType)
     */
    @Override
    public Set<Integer> retrieveUplinkedExternalIds(TargetType type) {
        IntervalMetricKey key = IntervalMetric.start();

        Criteria query = getSession().createCriteria(TargetTable.class);
        query.add(Restrictions.eq("state", State.UPLINKED));
        query.add(Restrictions.eq("type", type));
        query.setProjection(Projections.property("externalId"));

        List<Integer> list = list(query);
        Set<Integer> ids = new TreeSet<Integer>(list);

        IntervalMetric.stop(getMetricName("retrieveUplinkedExternalIds"), key);

        return ids;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#retrieveMaxExternalId
     * (gov.nasa.kepler.hibernate.tad.TargetTable.TargetType)
     */
    @Override
    public Set<Integer> retrieveExternalIdsInUse(TargetType type) {
        IntervalMetricKey key = IntervalMetric.start();

        Criteria query = getSession().createCriteria(TargetTable.class);
        query.add(Restrictions.eq("type", type));
        query.setProjection(Projections.property("externalId"));

        List<Integer> list = list(query);
        Set<Integer> ids = new TreeSet<Integer>(list);

        IntervalMetric.stop(getMetricName("retrieveExternalIdsInUse"), key);

        return ids;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#createMaskTable(gov
     * .nasa.kepler.hibernate.tad.MaskTable)
     */
    @Override
    public void createMaskTable(MaskTable maskTable) {
        IntervalMetricKey key = IntervalMetric.start();

        getSession().save(maskTable);

        IntervalMetric.stop(getMetricName("createMaskTable"), key);
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#retrieveMaskTable(long)
     */
    @Override
    public MaskTable retrieveMaskTable(long id) {
        IntervalMetricKey key = IntervalMetric.start();

        Query query = getSession().createQuery(
            "from MaskTable where " + "id = :id");
        query.setParameter("id", id);
        MaskTable uniqueResult = uniqueResult(query);

        IntervalMetric.stop(getMetricName("retrieveMaskTable"), key);

        return uniqueResult;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#retrieveUplinkedMaskTable
     * (int, gov.nasa.kepler.hibernate.tad.MaskTable.MaskType)
     */
    @Override
    public MaskTable retrieveUplinkedMaskTable(int externalId, MaskType type) {
        IntervalMetricKey key = IntervalMetric.start();

        Query query = getSession().createQuery(
            "from MaskTable where " + "state = :state and "
                + "externalId = :externalId and " + "type = :type");
        query.setParameter("state", State.UPLINKED);
        query.setParameter("externalId", externalId);
        query.setParameter("type", type);
        MaskTable uniqueResult = uniqueResult(query);

        IntervalMetric.stop(getMetricName("retrieveUplinkedMaskTable"), key);

        return uniqueResult;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#delete(gov.nasa.kepler
     * .hibernate.tad.MaskTable)
     */
    @Override
    public void delete(MaskTable maskTable) {
        IntervalMetricKey key = IntervalMetric.start();

        if (maskTable != null) {
            Query query = getSession().createSQLQuery(
                "delete from TAD_MASK_OFFSETS where TAD_MASK_ID in (select ID from TAD_MASK where TAD_MASK_TABLE_ID = "
                    + maskTable.getId() + ")");
            query.executeUpdate();

            query = getSession().createSQLQuery(
                "delete from TAD_MASK where TAD_MASK_TABLE_ID = "
                    + maskTable.getId());
            query.executeUpdate();

            getSession().delete(maskTable);
        }

        IntervalMetric.stop(getMetricName("delete"), key);
    }

    /*
     * (non-Javadoc)
     * 
     * @seegov.nasa.kepler.hibernate.tad.TargetCrudInterface#
     * retrieveMaxUplinkedExternalId
     * (gov.nasa.kepler.hibernate.tad.MaskTable.MaskType)
     */
    @Override
    public Set<Integer> retrieveUplinkedExternalIds(MaskType type) {
        IntervalMetricKey key = IntervalMetric.start();

        Criteria query = getSession().createCriteria(MaskTable.class);
        query.add(Restrictions.eq("state", State.UPLINKED));
        query.add(Restrictions.eq("type", type));
        query.setProjection(Projections.property("externalId"));

        List<Integer> list = list(query);
        Set<Integer> ids = new TreeSet<Integer>(list);

        IntervalMetric.stop(getMetricName("retrieveUplinkedExternalIds"), key);

        return ids;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#retrieveMaxExternalId
     * (gov.nasa.kepler.hibernate.tad.MaskTable.MaskType)
     */
    @Override
    public Set<Integer> retrieveExternalIdsInUse(MaskType type) {
        IntervalMetricKey key = IntervalMetric.start();

        Criteria query = getSession().createCriteria(MaskTable.class);
        query.add(Restrictions.eq("type", type));
        query.setProjection(Projections.property("externalId"));

        List<Integer> list = list(query);
        Set<Integer> ids = new TreeSet<Integer>(list);

        IntervalMetric.stop(getMetricName("retrieveExternalIdsInUse"), key);

        return ids;
    }

    /*
     * (non-Javadoc)
     * 
     * @seegov.nasa.kepler.hibernate.tad.TargetCrudInterface#
     * retrieveMaskTableForTargetTable
     * (gov.nasa.kepler.hibernate.tad.TargetTable,
     * gov.nasa.kepler.hibernate.tad.MaskTable.MaskType)
     */
    @Override
    public List<MaskTable> retrieveMaskTableForTargetTable(TargetTable ttable,
        MaskType mType) {
        IntervalMetricKey key = IntervalMetric.start();

        String pixelLogColumnName;
        switch (mType) {
            case TARGET:
                pixelLogColumnName = "targetApertureTableId";
                break;
            case BACKGROUND:
                pixelLogColumnName = "backApertureTableId";
                break;
            default:
                throw new IllegalStateException("Unknown mask type \"" + mType
                    + "\".");
        }

        List<Short> maskTableExternalIds = externalIdsFromPixelLog(ttable,
            pixelLogColumnName, getSession());

        if (maskTableExternalIds.isEmpty()) {
            return Collections.emptyList();
        }
        List<MaskTable> rv = new ArrayList<MaskTable>();
        for (short externalId : maskTableExternalIds) {
            rv.add(retrieveUplinkedMaskTable(externalId, mType));
        }

        IntervalMetric.stop(getMetricName("retrieveMaskTableForTargetTable"),
            key);

        return rv;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#createObservedTargets
     * (java.util.Collection)
     */
    @Override
    public void createObservedTargets(Collection<ObservedTarget> observedTargets) {
        IntervalMetricKey key = IntervalMetric.start();

        int targetCount = 0;
        for (ObservedTarget observedTarget : observedTargets) {
            if (targetCount % 10000 == 0) {
                log.info("Created " + targetCount + " ObservedTargets...");
            }

            getSession().save(observedTarget);

            targetCount++;
        }

        log.info("Completed creating " + targetCount + " ObservedTargets.");

        IntervalMetric.stop(getMetricName("createObservedTargets"), key);
    }

    public void createTargetDefinitions(
        Collection<TargetDefinition> targetDefinitions) {
        IntervalMetricKey key = IntervalMetric.start();

        int targetCount = 0;
        for (TargetDefinition targetDefinition : targetDefinitions) {
            if (targetCount % 10000 == 0) {
                log.info("Created " + targetCount + " TargetDefinitions...");
            }

            getSession().save(targetDefinition);

            targetCount++;
        }

        log.info("Completed creating " + targetCount + " TargetDefinitions.");

        IntervalMetric.stop(getMetricName("createTargetDefinitions"), key);
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#createObservedTarget
     * (gov.nasa.kepler.hibernate.tad.ObservedTarget)
     */
    @Override
    public void createObservedTarget(ObservedTarget observedTarget) {
        IntervalMetricKey key = IntervalMetric.start();

        getSession().save(observedTarget);

        IntervalMetric.stop(getMetricName("createObservedTarget"), key);
    }

    private List<ObservedTarget> retrieveObservedTargetsInternal(
        RetrieveObservedTargetsMethod retrieveObservedTargetsMethod,
        TargetTable targetTable, boolean includeNullApertures,
        boolean ignoreSupplemental) {
        List<ObservedTarget> origObservedTargets = retrieveObservedTargetsMethod.retrieve(targetTable);

        if (!ignoreSupplemental) {
            if (!origObservedTargets.isEmpty()) {
                TargetTable suppTargetTable = retrieveSuppTargetTableForOrigTargetTable(targetTable);
                if (suppTargetTable != null) {
                    List<ObservedTarget> suppObservedTargets = retrieveObservedTargetsMethod.retrieve(suppTargetTable);
                    if (!suppObservedTargets.isEmpty()) {
                        if (targetTable.getObservingSeason() != suppTargetTable.getObservingSeason()) {
                            throw new PipelineException(
                                "origTargetTable and suppTargetTable must have the same observing season.\n  origObservingSeason: "
                                    + targetTable.getObservingSeason()
                                    + "\n  suppObservingSeason: "
                                    + suppTargetTable.getObservingSeason());
                        }

                        Map<Integer, ObservedTarget> keplerIdToOrigObservedTarget = new HashMap<Integer, ObservedTarget>();
                        for (ObservedTarget origObservedTarget : origObservedTargets) {
                            keplerIdToOrigObservedTarget.put(
                                origObservedTarget.getKeplerId(),
                                origObservedTarget);
                        }

                        for (ObservedTarget suppObservedTarget : suppObservedTargets) {
                            ObservedTarget origObservedTarget = keplerIdToOrigObservedTarget.get(suppObservedTarget.getKeplerId());
                            if (origObservedTarget != null) {
                                origObservedTarget.setSupplementalObservedTarget(suppObservedTarget);
                            }
                        }
                    }
                }
            }
        }

        List<ObservedTarget> origObservedTargetsCopy = new ArrayList<ObservedTarget>();
        for (ObservedTarget observedTarget : origObservedTargets) {
            if (!includeNullApertures
                && observedTarget.getKeplerId() != TargetManagementConstants.INVALID_KEPLER_ID
                && !observedTarget.isRejected()
                && observedTarget.getAperture() == null) {
                // Do not add the target to the list to be returned.
            } else {
                origObservedTargetsCopy.add(observedTarget);
            }
        }

        return origObservedTargetsCopy;
    }

    /**
     * Get the supplemental target table generated for the supplemental tad run.
     * 
     * @param origTargetTable a non-null target table.
     * @return a supplemental target table for the specified target table else
     * this returns null if none exists.
     */
    public TargetTable retrieveSuppTargetTableForOrigTargetTable(
        TargetTable origTargetTable) {
        IntervalMetricKey key = IntervalMetric.start();

        TargetTable suppTargetTable = null;
        TargetListSet origTls = getTargetSelectionCrud().retrieveTargetListSetByTargetTable(
            origTargetTable);
        if (origTls != null) {
            TargetListSet suppTls = origTls.getSupplementalTls();
            if (suppTls != null) {
                suppTargetTable = suppTls.getTargetTable();
            }
        }

        IntervalMetric.stop(
            getMetricName("retrieveSuppTargetTableForOrigTargetTable"), key);

        return suppTargetTable;
    }

    /*
     * (non-Javadoc)
     * 
     * @seegov.nasa.kepler.hibernate.tad.TargetCrudInterface#
     * retrieveObservedTargetsPlusRejected
     * (gov.nasa.kepler.hibernate.tad.TargetTable)
     */
    @Override
    public List<ObservedTarget> retrieveObservedTargetsPlusRejected(
        TargetTable targetTable) {
        IntervalMetricKey key = IntervalMetric.start();

        List<ObservedTarget> observedTargets = retrieveObservedTargetsInternal(
            new RetrieveObservedTargetsPlusRejectedForTargetTable(),
            targetTable, false, false);

        IntervalMetric.stop(
            getMetricName("retrieveObservedTargetsPlusRejected"), key);

        return observedTargets;
    }

    /*
     * (non-Javadoc)
     * 
     * @seegov.nasa.kepler.hibernate.tad.TargetCrudInterface#
     * retrieveObservedTargetsPlusRejected
     * (gov.nasa.kepler.hibernate.tad.TargetTable, int, int)
     */
    @Override
    public List<ObservedTarget> retrieveObservedTargetsPlusRejected(
        TargetTable targetTable, int ccdModule, int ccdOutput) {
        IntervalMetricKey key = IntervalMetric.start();

        List<ObservedTarget> observedTargets = retrieveObservedTargetsPlusRejected(
            targetTable, ccdModule, ccdOutput, false);

        IntervalMetric.stop(
            getMetricName("retrieveObservedTargetsPlusRejected"), key);

        return observedTargets;
    }

    public List<ObservedTarget> retrieveObservedTargetsPlusRejected(
        TargetTable targetTable, int ccdModule, int ccdOutput,
        boolean includeNullApertures) {
        IntervalMetricKey key = IntervalMetric.start();

        List<ObservedTarget> observedTargets = retrieveObservedTargetsInternal(
            new RetrieveObservedTargetsPlusRejectedForTargetTableModOut(
                ccdModule, ccdOutput), targetTable, includeNullApertures, false);

        IntervalMetric.stop(
            getMetricName("retrieveObservedTargetsPlusRejected"), key);

        return observedTargets;
    }

    /**
     * WARNING: This method should only be used by CoaPipelineModule to perform
     * target rejection logic. All other code should use supplemental targets if
     * they are available.
     */
    public List<ObservedTarget> retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
        TargetTable targetTable, int ccdModule, int ccdOutput,
        boolean includeNullApertures) {
        IntervalMetricKey key = IntervalMetric.start();

        List<ObservedTarget> observedTargets = retrieveObservedTargetsInternal(
            new RetrieveObservedTargetsPlusRejectedForTargetTableModOut(
                ccdModule, ccdOutput), targetTable, includeNullApertures, true);

        IntervalMetric.stop(
            getMetricName("retrieveObservedTargetsPlusRejectedIgnoreSupplemental"),
            key);

        return observedTargets;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#retrieveObservedTargets
     * (gov.nasa.kepler.hibernate.tad.TargetTable)
     */
    @Override
    public List<ObservedTarget> retrieveObservedTargets(TargetTable targetTable) {
        IntervalMetricKey key = IntervalMetric.start();

        List<ObservedTarget> observedTargets = retrieveObservedTargets(
            targetTable, false);

        IntervalMetric.stop(getMetricName("retrieveObservedTargets"), key);

        return observedTargets;
    }

    public List<ObservedTarget> retrieveObservedTargets(
        TargetTable targetTable, boolean includeNullApertures) {
        IntervalMetricKey key = IntervalMetric.start();

        List<ObservedTarget> observedTargets = retrieveObservedTargetsInternal(
            new RetrieveObservedTargetsForTargetTable(), targetTable,
            includeNullApertures, false);

        IntervalMetric.stop(getMetricName("retrieveObservedTargets"), key);

        return observedTargets;
    }

    /*
     * (non-Javadoc)
     * 
     * @seegov.nasa.kepler.hibernate.tad.TargetCrudInterface#
     * retrieveLongCadenceTargetTable(gov.nasa.kepler.hibernate.tad.TargetTable)
     */
    @Override
    public List<TargetTable> retrieveLongCadenceTargetTable(TargetTable ttable) {
        IntervalMetricKey key = IntervalMetric.start();

        List<TargetTable> targetTables = retrieveXTargetTableForTargetTable(
            ttable, "lcTargetTableId", TargetTable.TargetType.LONG_CADENCE);

        IntervalMetric.stop(getMetricName("retrieveLongCadenceTargetTable"),
            key);

        return targetTables;
    }

    /*
     * (non-Javadoc)
     * 
     * @seegov.nasa.kepler.hibernate.tad.TargetCrudInterface#
     * retrieveShortCadenceTargetTable
     * (gov.nasa.kepler.hibernate.tad.TargetTable)
     */
    @Override
    public List<TargetTable> retrieveShortCadenceTargetTable(TargetTable ttable) {
        IntervalMetricKey key = IntervalMetric.start();

        List<TargetTable> targetTables = retrieveXTargetTableForTargetTable(
            ttable, "scTargetTableId", TargetTable.TargetType.SHORT_CADENCE);

        IntervalMetric.stop(getMetricName("retrieveShortCadenceTargetTable"),
            key);

        return targetTables;
    }

    /**
     * 
     * @see gov.nasa.kepler.hibernate.tad.TargetCrudInterface#
     * retrieveBackgroundTargetTable(gov.nasa.kepler.hibernate.tad.TargetTable)
     */
    @Override
    public List<TargetTable> retrieveBackgroundTargetTable(TargetTable ttable) {
        IntervalMetricKey key = IntervalMetric.start();

        List<TargetTable> targetTables = retrieveXTargetTableForTargetTable(
            ttable, "backTargetTableId", TargetTable.TargetType.BACKGROUND);

        IntervalMetric.stop(getMetricName("retrieveBackgroundTargetTable"), key);

        return targetTables;
    }

    /**
     * 
     * @param ttable The known table.
     * @param pixelLogFieldName The name of the pixel log field to query for the
     * desired table.
     * @param queryType The type of the desired table.
     * @return Zero or more tables of the type specified.
     */
    private List<TargetTable> retrieveXTargetTableForTargetTable(
        TargetTable ttable, String pixelLogFieldName,
        TargetTable.TargetType queryType) {

        List<Short> externalIds = externalIdsFromPixelLog(ttable,
            pixelLogFieldName, getSession());

        if (externalIds.isEmpty()) {
            return Collections.emptyList();
        }

        StringBuilder queryStr = new StringBuilder(
            "from TargetTable ttable where externalId in (");
        for (short xId : externalIds) {
            queryStr.append(xId)
                .append(',');
        }
        queryStr.setLength(queryStr.length() - 1);
        queryStr.append(')');
        queryStr.append(" and state = :paramState and type = :paramTargetType ");

        Query q = getSession().createQuery(queryStr.toString());
        q.setParameter("paramState", State.UPLINKED);
        q.setParameter("paramTargetType", queryType);
        List<TargetTable> rv = list(q);
        return rv;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#retrieveObservedTargets
     * (gov.nasa.kepler.hibernate.tad.TargetTable, int, int)
     */
    @Override
    public List<ObservedTarget> retrieveObservedTargets(
        TargetTable targetTable, int ccdModule, int ccdOutput) {
        IntervalMetricKey key = IntervalMetric.start();

        List<ObservedTarget> observedTargets = retrieveObservedTargets(
            targetTable, ccdModule, ccdOutput, false);

        IntervalMetric.stop(getMetricName("retrieveObservedTargets"), key);

        return observedTargets;
    }

    public List<ObservedTarget> retrieveObservedTargets(
        TargetTable targetTable, int ccdModule, int ccdOutput,
        boolean includeNullApertures) {
        IntervalMetricKey key = IntervalMetric.start();

        List<ObservedTarget> observedTargets = retrieveObservedTargetsInternal(
            new RetrieveObservedTargetsForTargetTableModOut(ccdModule,
                ccdOutput), targetTable, includeNullApertures, false);

        IntervalMetric.stop(getMetricName("retrieveObservedTargets"), key);

        return observedTargets;
    }

    public List<ObservedTarget> retrieveObservedTargets(
        TargetTable targetTable, List<Integer> keplerIds) {
        IntervalMetricKey key = IntervalMetric.start();

        if (keplerIds.size() == 0) {
            return Collections.emptyList();
        }

        Map<Integer, ObservedTarget> keplerIdToObservedTarget = new HashMap<Integer, ObservedTarget>(
            keplerIds.size());
        ListChunkIterator<Integer> keplerIdIterator = new ListChunkIterator<Integer>(
            keplerIds.iterator(), MAX_EXPRESSIONS);

        while (keplerIdIterator.hasNext()) {
            List<ObservedTarget> observedTargets = retrieveObservedTargetsInternal(
                new RetrieveObservedTargetsForTargetTableKeplerIds(
                    keplerIdIterator.next()), targetTable, false, false);

            for (ObservedTarget observedTarget : observedTargets) {
                keplerIdToObservedTarget.put(observedTarget.getKeplerId(),
                    observedTarget);
            }
        }

        List<ObservedTarget> observedTargets = new ArrayList<ObservedTarget>(
            keplerIds.size());
        for (Integer keplerId : keplerIds) {
            observedTargets.add(keplerIdToObservedTarget.get(keplerId));
        }

        IntervalMetric.stop(getMetricName("retrieveObservedTargets"), key);

        return observedTargets;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#createMasks(java.util
     * .Collection)
     */
    @Override
    public void createMasks(Collection<Mask> masks) {
        IntervalMetricKey key = IntervalMetric.start();

        for (Mask mask : masks) {
            getSession().save(mask);
        }

        IntervalMetric.stop(getMetricName("createMasks"), key);
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#createMask(gov.nasa
     * .kepler.hibernate.tad.Mask)
     */
    @Override
    public void createMask(Mask mask) {
        IntervalMetricKey key = IntervalMetric.start();

        getSession().save(mask);

        IntervalMetric.stop(getMetricName("createMask"), key);
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#retrieveMasks(gov.nasa
     * .kepler.hibernate.tad.MaskTable)
     */
    @Override
    public List<Mask> retrieveMasks(MaskTable maskTable) {
        IntervalMetricKey key = IntervalMetric.start();

        Query query = getSession().createQuery(
            "from Mask where " + "maskTable = :maskTable "
                + "order by indexInTable asc");
        query.setParameter("maskTable", maskTable);

        List<Mask> list = list(query);

        IntervalMetric.stop(getMetricName("retrieveMasks"), key);

        return list;
    }

    public void createImage(TargetTable targetTable, int ccdModule,
        int ccdOutput, PipelineTask pipelineTask, double[][] moduleOutputImage,
        int minRow, int maxRow, int minCol, int maxCol) {
        IntervalMetricKey key = IntervalMetric.start();

        Image image = new Image(targetTable, ccdModule, ccdOutput,
            pipelineTask, moduleOutputImage, minRow, maxRow, minCol, maxCol);

        getSession().save(image);

        IntervalMetric.stop(getMetricName("createImage"), key);
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#retrieveImage(gov.nasa
     * .kepler.hibernate.tad.TargetTable, int, int)
     */
    @Override
    public Image retrieveImage(TargetTable targetTable, int ccdModule,
        int ccdOutput) {
        IntervalMetricKey key = IntervalMetric.start();

        Image origImage = retrieveImageInternal(targetTable, ccdModule,
            ccdOutput);
        if (origImage != null) {
            TargetTable suppTargetTable = retrieveSuppTargetTableForOrigTargetTable(targetTable);
            if (suppTargetTable != null) {
                Image suppImage = retrieveImageInternal(suppTargetTable,
                    ccdModule, ccdOutput);
                origImage.setSupplementalImage(suppImage);
            }
        }

        IntervalMetric.stop(getMetricName("retrieveImage"), key);

        return origImage;
    }

    private Image retrieveImageInternal(TargetTable targetTable, int ccdModule,
        int ccdOutput) {
        Query query = getSession().createQuery(
            "from Image where " + "targetTable = :targetTable and "
                + "ccdModule = :ccdModule and " + "ccdOutput = :ccdOutput");
        query.setParameter("targetTable", targetTable);
        query.setParameter("ccdModule", ccdModule);
        query.setParameter("ccdOutput", ccdOutput);

        Image image = uniqueResult(query);
        return image;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.tad.TargetCrudInterface#deleteSupermasks(gov
     * .nasa.kepler.hibernate.tad.MaskTable)
     */
    @Override
    public void deleteSupermasks(MaskTable maskTable) {
        IntervalMetricKey key = IntervalMetric.start();

        if (maskTable != null) {
            Query query = getSession().createSQLQuery(
                "delete from TAD_MASK_OFFSETS where TAD_MASK_ID in (select ID from TAD_MASK where TAD_MASK_TABLE_ID = "
                    + maskTable.getId() + " and SUPERMASK = 1)");
            query.executeUpdate();

            query = getSession().createSQLQuery(
                "update TAD_TARGET_DEFINITION set TAD_MASK_ID = NULL where TAD_MASK_ID in (select ID from TAD_MASK where TAD_MASK_TABLE_ID = "
                    + maskTable.getId() + " and SUPERMASK = 1)");
            query.executeUpdate();

            query = getSession().createSQLQuery(
                "delete from TAD_MASK where TAD_MASK_TABLE_ID = "
                    + maskTable.getId() + " and SUPERMASK = 1");
            query.executeUpdate();
        }

        IntervalMetric.stop(getMetricName("deleteSupermasks"), key);
    }

    @Override
    public Map<Integer, TargetCrowdingInfo> retrieveCrowdingMetricInfo(
        List<TargetTable> ttables, int skyGroupId) {
        IntervalMetricKey key = IntervalMetric.start();

        Map<Integer, TargetCrowdingInfo> keplerIdToTargetCrowdingInfo = new HashMap<Integer, TargetCrowdingInfo>();
        for (int i = 0; i < ttables.size(); i++) {
            TargetTable targetTable = ttables.get(i);

            SkyGroup skyGroup = getKicCrud().retrieveSkyGroup(skyGroupId,
                targetTable.getObservingSeason());

            List<ObservedTarget> observedTargets = retrieveObservedTargets(
                targetTable, skyGroup.getCcdModule(), skyGroup.getCcdOutput());
            for (ObservedTarget observedTarget : observedTargets) {
                int keplerId = observedTarget.getKeplerId();

                TargetCrowdingInfo targetCrowdingInfo = keplerIdToTargetCrowdingInfo.get(keplerId);
                if (targetCrowdingInfo == null) {
                    targetCrowdingInfo = new TargetCrowdingInfo(keplerId,
                        new Double[ttables.size()],
                        new Integer[ttables.size()],
                        new Integer[ttables.size()]);
                    keplerIdToTargetCrowdingInfo.put(keplerId,
                        targetCrowdingInfo);
                }

                targetCrowdingInfo.getCrowdingMetric()[i] = observedTarget.getCrowdingMetric();
                targetCrowdingInfo.getCcdModule()[i] = observedTarget.getCcdModule();
                targetCrowdingInfo.getCcdOutput()[i] = observedTarget.getCcdOutput();
            }
        }

        IntervalMetric.stop(getMetricName("retrieveCrowdingMetricInfo"), key);

        return keplerIdToTargetCrowdingInfo;
    }

    public static List<Short> externalIdsFromPixelLog(TargetTable ttable,
        String idFieldName, Session session) {
        IntervalMetricKey key = IntervalMetric.start();

        StringBuilder bldr = new StringBuilder("select distinct " + idFieldName
            + " from PixelLog where ");

        switch (ttable.getType()) {
            case LONG_CADENCE:
                bldr.append("lcTargetTableId");
                break;
            case SHORT_CADENCE:
                bldr.append("scTargetTableId");
                break;
            case BACKGROUND:
                bldr.append("backTargetTableId");
                break;
            default:
                throw new IllegalStateException("Unsupported type "
                    + ttable.getType());
        }
        bldr.append(" = ")
            .append(ttable.getExternalId());
        @SuppressWarnings("unchecked")
        List<Short> externalIds = session.createQuery(bldr.toString())
            .list();

        IntervalMetric.stop(getMetricName("externalIdsFromPixelLog"), key);

        return externalIds;
    }

    private interface RetrieveObservedTargetsMethod {
        public List<ObservedTarget> retrieve(TargetTable targetTable);
    }

    private class RetrieveObservedTargetsPlusRejectedForTargetTable implements
        RetrieveObservedTargetsMethod {
        @Override
        public List<ObservedTarget> retrieve(TargetTable targetTable) {
            Query query = getSession().createQuery(
                "from ObservedTarget t " + "left join fetch t.aperture a "
                    + "left join fetch t.targetDefinitions td "
                    + "left join fetch td.mask m "
                    + "left join fetch m.maskTable " + "where "
                    + "t.targetTable = :targetTable "
                    + "order by t.ccdModule asc " + "order by t.ccdOutput asc "
                    + "order by t.id asc");
            query.setParameter("targetTable", targetTable);

            List<ObservedTarget> list = list(query);

            Set<Long> ids = new HashSet<Long>();
            List<ObservedTarget> returnList = new ArrayList<ObservedTarget>();
            for (ObservedTarget target : list) {
                long id = target.getId();
                if (!ids.contains(id)) {
                    ids.add(id);
                    returnList.add(target);
                }
            }

            return returnList;
        }
    }

    private class RetrieveObservedTargetsPlusRejectedForTargetTableModOut
        implements RetrieveObservedTargetsMethod {

        private final int ccdModule;
        private final int ccdOutput;

        public RetrieveObservedTargetsPlusRejectedForTargetTableModOut(
            int ccdModule, int ccdOutput) {
            this.ccdModule = ccdModule;
            this.ccdOutput = ccdOutput;
        }

        @Override
        public List<ObservedTarget> retrieve(TargetTable targetTable) {
            Query query = getSession().createQuery(
                "from ObservedTarget t " + "left join fetch t.aperture a "
                    + "left join fetch t.targetDefinitions td "
                    + "left join fetch td.mask m "
                    + "left join fetch m.maskTable " + "where "
                    + "t.targetTable = :targetTable and "
                    + "t.ccdModule = :ccdModule and "
                    + "t.ccdOutput = :ccdOutput " + "order by t.id asc");
            query.setParameter("targetTable", targetTable);
            query.setParameter("ccdModule", ccdModule);
            query.setParameter("ccdOutput", ccdOutput);

            List<ObservedTarget> list = list(query);

            Set<Long> ids = new HashSet<Long>();
            List<ObservedTarget> returnList = new ArrayList<ObservedTarget>();
            for (ObservedTarget target : list) {
                long id = target.getId();
                if (!ids.contains(id)) {
                    ids.add(id);
                    returnList.add(target);
                }
            }

            return returnList;
        }
    }

    private class RetrieveObservedTargetsForTargetTable implements
        RetrieveObservedTargetsMethod {
        @Override
        public List<ObservedTarget> retrieve(TargetTable targetTable) {
            Query query = getSession().createQuery(
                "from ObservedTarget t " + "left join fetch t.aperture a "
                    + "left join fetch t.targetDefinitions td "
                    + "left join fetch td.mask m "
                    + "left join fetch m.maskTable " + "where "
                    + "t.targetTable = :targetTable and "
                    + "t.rejected = false " + "order by t.ccdModule asc "
                    + "order by t.ccdOutput asc " + "order by t.id asc");
            query.setParameter("targetTable", targetTable);

            List<ObservedTarget> list = list(query);

            Set<Long> ids = new HashSet<Long>();
            List<ObservedTarget> returnList = new ArrayList<ObservedTarget>();
            for (ObservedTarget target : list) {
                long id = target.getId();
                if (!ids.contains(id)) {
                    ids.add(id);
                    returnList.add(target);
                }
            }

            return returnList;
        }
    }

    private class RetrieveObservedTargetsForTargetTableModOut implements
        RetrieveObservedTargetsMethod {

        private final int ccdModule;
        private final int ccdOutput;

        public RetrieveObservedTargetsForTargetTableModOut(int ccdModule,
            int ccdOutput) {
            this.ccdModule = ccdModule;
            this.ccdOutput = ccdOutput;
        }

        @Override
        public List<ObservedTarget> retrieve(TargetTable targetTable) {
            Query query = getSession().createQuery(
                "from ObservedTarget t " + "left join fetch t.aperture a "
                    + "left join fetch t.targetDefinitions td "
                    + "left join fetch td.mask m "
                    + "left join fetch m.maskTable " + "where "
                    + "t.targetTable = :targetTable and "
                    + "t.ccdModule = :ccdModule and "
                    + "t.ccdOutput = :ccdOutput and " + "t.rejected = false "
                    + "order by t.id asc");
            query.setParameter("targetTable", targetTable);
            query.setParameter("ccdModule", ccdModule);
            query.setParameter("ccdOutput", ccdOutput);

            List<ObservedTarget> list = list(query);

            Set<Long> ids = new HashSet<Long>();
            List<ObservedTarget> returnList = new ArrayList<ObservedTarget>();
            for (ObservedTarget target : list) {
                long id = target.getId();
                if (!ids.contains(id)) {
                    ids.add(id);
                    returnList.add(target);
                }
            }

            return returnList;
        }
    }

    private class RetrieveObservedTargetsForTargetTableKeplerIds implements
        RetrieveObservedTargetsMethod {

        private final List<Integer> keplerIds;

        public RetrieveObservedTargetsForTargetTableKeplerIds(
            List<Integer> keplerIds) {
            this.keplerIds = keplerIds;
        }

        @Override
        public List<ObservedTarget> retrieve(TargetTable targetTable) {
            Query query = getSession().createQuery(
                "from ObservedTarget t " + "left join fetch t.aperture a "
                    + "left join fetch t.targetDefinitions td "
                    + "left join fetch td.mask m "
                    + "left join fetch m.maskTable " + "where "
                    + "t.targetTable = :targetTable and "
                    + "t.keplerId in (:keplerIds) and " + "t.rejected = false "
                    + "order by t.id asc");
            query.setParameter("targetTable", targetTable);
            query.setParameterList("keplerIds", keplerIds);

            List<ObservedTarget> list = list(query);

            Set<Long> ids = new HashSet<Long>();
            List<ObservedTarget> returnList = new ArrayList<ObservedTarget>();
            for (ObservedTarget target : list) {
                long id = target.getId();
                if (!ids.contains(id)) {
                    ids.add(id);
                    returnList.add(target);
                }
            }

            return returnList;
        }
    }

    public void setPixelLogCrud(PixelLogCrud pixelLogCrud) {
        IntervalMetricKey key = IntervalMetric.start();

        this.pixelLogCrud = pixelLogCrud;

        IntervalMetric.stop(getMetricName("setPixelLogCrud"), key);
    }

    private static final String getMetricName(String methodName) {
        return "tad." + methodName + ".execTimeMillis";
    }

}
