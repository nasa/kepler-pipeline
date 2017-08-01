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

package gov.nasa.kepler.hibernate.dr;

import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.collect.Pair;


import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.SQLException;
import java.util.Collection;
import java.util.Date;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Criteria;
import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.SQLQuery;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Projections;
import org.hibernate.criterion.Restrictions;

/**
 * CRUD API's for the ReceiveLog, PixelLog, and CadencePixelLog classes
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 */
public class LogCrud extends AbstractCrud implements PixelLogCrud, PixelLogRetriever {
    private static final Log log = LogFactory.getLog(LogCrud.class);

    /**
     * Creates a new {@link LogCrud} object.
     */
    public LogCrud() {
    }

    /**
     * Creates a {@link LogCrud}.
     * 
     * @param dbs the database service for this object.
     */
    public LogCrud(DatabaseService dbs) {
        super(dbs);
    }

    /**
     * Gets the list of distinct spacecraft config map ids for the given time
     * interval, inclusive.
     * 
     * @return a non-null list distinct of ids.
     */
    public List<Integer> retrieveConfigMapIds(double mjdStart, double mjdEnd) {
        return retrieveConfigMapIds(null, mjdStart, mjdEnd);
    }
    
    public List<Integer> retrieveConfigMapIds(CadenceType cadenceType,
        double mjdStart, double mjdEnd) {
        String queryStr = "select distinct spacecraftConfigId from "
            + getPixelLogClassName()
            + " where mjdStartTime >= :startTime and mjdEndTime <= :endTime"
            + (cadenceType == null ? "" : " and cadenceType = :cadenceType")
            + " order by spacecraftConfigId ";

        Query q = createQuery(queryStr);
        q.setDouble("startTime", mjdStart);
        q.setDouble("endTime", mjdEnd);
        if (cadenceType != null) {
            q.setParameter("cadenceType", cadenceType.intValue());
        }

        List<Integer> rv = list(q);
        
        return rv;
    }

    /**
     * Get all the target table ids for a specific target table.
     * 
     * @param targetType
     * @param ttableId
     * @return
     */
    public List<Integer> retrieveConfigMapIds(TargetTable.TargetType targetType, int ttableId) {
        Pair<String, CadenceType> targetTypeInfo = targetTypeFields(targetType);
        
        String fieldName = targetTypeInfo.left;
        
        String queryStr = "select distinct spacecraftConfigId from "
            + getPixelLogClassName() +
            " where " + fieldName + " = :ttableId ";
        Query q = createQuery(queryStr);
        q.setInteger("ttableId", ttableId);
        List<Integer> rv = list(q);
        return rv;
    }
    
    /**
     * Persist a new ReceiveLog instance
     */
    public void createReceiveLog(ReceiveLog receiveLog) {
        getSession().save(receiveLog);
    }

    public List<ReceiveLog> retrieveAllReceiveLogs() {
        Query query = getSession().createQuery("from ReceiveLog");

        List<ReceiveLog> logs = list(query);

        return logs;
    }

    /**
     * Retrieve a ReceiveLog instance for the specified id
     */
    public ReceiveLog retrieveReceiveLog(long id) {
        return (ReceiveLog) getSession().get(ReceiveLog.class, id);
    }

    /**
     * Retrieves {@link ReceiveLog} instances that occurred during the given
     * time period, inclusive.
     * 
     * @param start the beginning of the period.
     * @param end the end of the period.
     * @throws HibernateException if there were problems retrieving the logs.
     */
    public List<ReceiveLog> retrieveReceiveLogs(Date start, Date end) {
        Criteria query = getSession().createCriteria(ReceiveLog.class);
        query.add(Restrictions.ge("socIngestTime", start));
        query.add(Restrictions.le("socIngestTime", end));
        query.addOrder(Order.asc("socIngestTime"));

        List<ReceiveLog> receiveLogs = list(query);

        return receiveLogs;
    }

    /**
     * Retrieves {@link ReceiveLog} instances that occurred during the given
     * time period, inclusive. Filter the instances by the given {@code states}
     * and {@code types} parameters and order the results using the given
     * {@code sortBy} and {@sortAscending} parameters.
     * 
     * @param start the beginning of the period.
     * @param end the end of the period.
     * @param sortBy the field (column) by which to sort the results.
     * @param sortAscending the sort order.
     * @param states the state filter.
     * @param types the notification message type filter.
     * @throws HibernateException if there were problems retrieving the logs.
     */
    public List<ReceiveLog> retrieveReceiveLogs(Date start, Date end,
        String sortBy, Collection<ReceiveLog.State> states,
        Collection<String> types, boolean sortAscending) {

        Criteria query = getSession().createCriteria(ReceiveLog.class);
        query.add(Restrictions.ge("socIngestTime", start));
        query.add(Restrictions.le("socIngestTime", end));
        if (states != null && states.size() > 0) {
            query.add(Restrictions.in("state", states));
        }
        if (types != null && types.size() > 0) {
            query.add(Restrictions.in("messageType", types));
        }
        if (sortAscending) {
            query.addOrder(Order.asc(sortBy));
        } else {
            query.addOrder(Order.desc(sortBy));
        }

        List<ReceiveLog> receiveLogs = list(query);

        return receiveLogs;
    }

    /**
     * Retrieves the notification message types of all receive logs in the
     * database.
     * 
     * @return a non-{@code null} list of matching message types
     * @throws NullPointerException if any of the arguments were {@code null}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<String> retrieveMessageTypes() {
        Criteria query = getSession().createCriteria(ReceiveLog.class);
        query.setProjection((Projections.distinct(Projections.property("messageType"))));
        query.addOrder(Order.asc("messageType"));
        List<String> types = list(query);

        return types;
    }

    /**
     * Persist a new {@link DispatchLog} instance
     */
    public void createDispatchLog(DispatchLog dispatchLog) {
        getSession().save(dispatchLog);
    }

    /**
     * Retrieve a {@link DispatchLog} instance for the specified id
     */
    public DispatchLog retrieveDispatchLog(long id) {
        return (DispatchLog) getSession().get(DispatchLog.class, id);
    }

    /**
     * Retrieve all {@link DispatchLog}s
     * 
     * @return
     */
    public List<DispatchLog> retrieveAllDispatchLogs() {
        Query query = getSession().createQuery("from DispatchLog");

        List<DispatchLog> logs = list(query);

        return logs;
    }

    /**
     * Retrieve the {@link DispatchLog}s associated with the given
     * {@link ReceiveLog}.
     */
    public List<DispatchLog> retrieveDispatchLogs(ReceiveLog receiveLog) {
        Query query = getSession().createQuery(
            "from DispatchLog d where receiveLog = :receiveLog "
                + "order by dispatcherType asc");
        query.setEntity("receiveLog", receiveLog);

        List<DispatchLog> dispatchLogs = list(query);

        return dispatchLogs;
    }

    /**
     * Persist a new {@link FileLog} instance
     */
    public void createFileLog(FileLog genericFileLog) {
        getSession().save(genericFileLog);
    }

    public FileLog createFileLog(DispatchLog dispatchLog, String filename) {
        FileLog fileLog = new FileLog(dispatchLog, filename);
        getSession().save(fileLog);

        return fileLog;
    }

    /**
     * Retrieve a {@link FileLog} instance for the specified id
     */
    public FileLog retrieveFileLog(long id) {
        return (FileLog) getSession().get(FileLog.class, id);
    }

    /**
     * Retrieves the latest log of a given type from the database.
     * 
     * @param dispatcherType required to be a Dispatcher.getName()
     */
    public FileLog retrieveLatestFileLog(DispatcherType dispatcherType) {
        Query query = getSession().createQuery(
            "from FileLog gfl " + "left join fetch gfl.dispatchLog dl "
                + "left join fetch dl.receiveLog rl " + "where "
                + "dl.dispatcherType = :dispatcherType "
                + "order by rl.socIngestTime desc");
        query.setMaxResults(1);
        query.setParameter("dispatcherType", dispatcherType);

        return uniqueResult(query);
    }

    public List<FileLog> retrieveAllFileLogs(DispatcherType dispatcherType) {
        Query query = getSession().createQuery(
            "from FileLog gfl " + "left join fetch gfl.dispatchLog dl "
                + "left join fetch dl.receiveLog rl " + "where "
                + "dl.dispatcherType = :dispatcherType "
                + "order by rl.socIngestTime desc");
        query.setParameter("dispatcherType", dispatcherType);

        List<FileLog> list = list(query);
        return list;
    }

    public List<FileLog> retrieveAllFileLogs() {
        Query query = getSession().createQuery(
            "from FileLog gfl " + "left join fetch gfl.dispatchLog dl "
                + "left join fetch dl.receiveLog rl "
                + "order by rl.socIngestTime desc");

        List<FileLog> list = list(query);
        return list;
    }

    /**
     * Retrieve {@link FileLog}s using a file name search criteria.
     * 
     * @param filenamePart is part of a file name to use as a search criteria.
     * (e.g. "_ffi-orig.fits")
     * @return
     */
    public List<FileLog> retrieveFileLogsWhereFilenameContains(
        String filenamePart) {
        filenamePart = "%" + filenamePart + "%";

        Query query = getSession().createQuery(
            "from FileLog gfl " + "where " + "gfl.filename like :filenamePart "
                + "order by gfl.filename asc");
        query.setParameter("filenamePart", filenamePart);

        List<FileLog> list = list(query);
        return list;
    }

    /**
     * Returns the number of {@link FileLog}s associated with the given
     * {@link DispatchLog}.
     * 
     * @throws HibernateException if there were problems retrieving the count of
     * file logs.
     */
    public int fileLogCount(DispatchLog dispatchLog) {
        Query query = getSession().createQuery(
            "select count(*) from FileLog f where f.dispatchLog = :dispatchLog");
        query.setEntity("dispatchLog", dispatchLog);
        int count = ((Long) query.iterate()
            .next()).intValue();

        return count;
    }

    /**
     * Persist a new PixelLog instance
     */
    public void createPixelLog(PixelLog pixelLog) {
        getSession().save(getPixelLogInstance(pixelLog));
    }

    /**
     * Retrieve a PixelLog instance for the specified id
     */
    public PixelLog retrievePixelLog(long id) {
        return (PixelLog) getSession().get(PixelLog.class, id);
    }

    public List<PixelLog> retrievePixelLog(int cadenceType,
        DataSetType dataSetType, int startCadence, int endCadence) {

        if (startCadence > endCadence) {
            throw new IllegalArgumentException("startCadence " + startCadence
                + " must come before or at the same time " + "as endCadence "
                + endCadence);
        }

        String dataSetTypeClause = "";

        if (dataSetType != null) {
            dataSetTypeClause = "pl.dataSetType = :dataSetType and ";
        }

        String queryString = "from " + getPixelLogClassName()
            + " pl where pl.cadenceType = :cadenceType and "
            + dataSetTypeClause + "pl.cadenceNumber >= :startCadence and "
            + "pl.cadenceNumber <= :endCadence order by pl.cadenceNumber";

        Query q = getSession().createQuery(queryString);
        q.setParameter("cadenceType", cadenceType);
        if (dataSetType != null) {
            q.setParameter("dataSetType", dataSetType);
        }
        q.setParameter("startCadence", startCadence);
        q.setParameter("endCadence", endCadence);

        return getPixelLogs(q);
    }

    public List<PixelLog> retrievePixelLog(int cadenceType, int startCadence,
        int endCadence) {

        return retrievePixelLog(cadenceType, null, startCadence, endCadence);
    }

    /**
     * Retrieves Pixel logs for the overlapping time interval. A PixelLog is
     * considered within the interval specified by [mjdStart, mjdEnd] if the
     * PixelLog's start is greater than or equal to mjdStart and the PixelLogs'
     * end is less than or equal to mjdEnd. So partial overlaps are discarded.
     * 
     * @return An empty list if nothing is found.
     */
    public List<PixelLog> retrievePixelLog(int cadenceType,
        DataSetType dataSetType, double mjdStart, double mjdEnd) {

        if (mjdEnd < mjdStart) {
            throw new IllegalArgumentException("mjdStart " + mjdStart
                + " must come before or at the same time as mjdEnd " + mjdEnd);
        }

        String dataSetTypeClause = "";

        if (dataSetType != null) {
            dataSetTypeClause = "pl.dataSetType = :dataSetType and ";
        }

        String queryString = " from " + getPixelLogClassName()
            + " pl where pl.cadenceType = :cadenceTypeParam and "
            + dataSetTypeClause + "pl.mjdStartTime >= :mjdStartTimeParam "
            + "and pl.mjdEndTime <= :mjdEndTimeParam order by pl.mjdStartTime";

        Query q = getSession().createQuery(queryString);
        q.setParameter("cadenceTypeParam", cadenceType);
        if (dataSetType != null) {
            q.setParameter("dataSetType", dataSetType);
        }
        q.setParameter("mjdStartTimeParam", mjdStart);
        q.setParameter("mjdEndTimeParam", mjdEnd);

        return getPixelLogs(q);
    }

    /**
     * Retrieves Pixel logs for the overlapping time interval. A PixelLog is
     * considered within the interval specified by [mjdStart, mjdEnd] if the
     * PixelLog's start is greater than or equal to mjdStart and the PixelLogs'
     * end is less than or equal to mjdEnd. So partial overlaps are discarded.
     * 
     * @return An empty list if nothing is found.
     */
    public List<PixelLog> retrievePixelLog(int cadenceType, double mjdStart,
        double mjdEnd) {

        return retrievePixelLog(cadenceType, null, mjdStart, mjdEnd);
    }

    /**
     * Retrieves the pixel log for the specified point in time by searching for
     * mjd mid point times.
     */
    public List<PixelLog> retrievePixelLog(int cadenceType, double mjdMidTime) {
        String queryString = "from PixelLog pl where pl.cadenceType = :cadenceType "
            + " and pl.mjdMidTime = :mjdMidParam ";

        Query q = getSession().createQuery(queryString);
        q.setParameter("cadenceType", cadenceType);
        q.setParameter("mjdMidParam", mjdMidTime);

        List<PixelLog> list = list(q);
        return list;
    }

    /**
     * Returns the cadence range from the {@link PixelLog} table for the
     * specified {@link DispatchLog}
     * 
     * @param dispatchLog
     * @return
     */
    public Pair<Integer, Integer> cadenceRangeForDispatchLog(
        DispatchLog dispatchLog) {
        String queryString = "select new gov.nasa.spiffy.common.collect.Pair("
            + " min(cadenceNumber), max(cadenceNumber)) from PixelLog where"
            + " dispatchLog = :dispatchLog";

        Query q = getSession().createQuery(queryString);
        q.setEntity("dispatchLog", dispatchLog);

        Pair<Integer, Integer> result = uniqueResult(q);
        if (result.left == null || result.right == null) {
            return null;
        }
        return result;
    }

    /**
     * Finds the short cadence interval for the specified long cadence interval.
     * A short cadence is considered in the interval if its startMjd is in the
     * start/end mjd interval of the specified long cadence interval.
     * 
     * @param longStart Inclusive
     * @param longEnd Inclusive
     * @return null If data is not available for the specified range else
     * returns the [start, end] short cadence numbers
     */
    public Pair<Integer, Integer> longCadenceToShortCadence(int longStart,
        int longEnd) {
        if (longStart > longEnd) {
            throw new IllegalArgumentException("longStart " + longStart
                + " must come before or at the same time as longEnd " + longEnd);
        }

        String queryString = "select new gov.nasa.spiffy.common.collect.Pair(\n"
            + " min(spl.cadenceNumber), max(spl.cadenceNumber)) from PixelLog spl where \n"
            + " spl.cadenceType = :shortCadenceType and \n"
            + " spl.mjdMidTime > (select min(lpl.mjdStartTime) from PixelLog lpl \n"
            + "    where lpl.cadenceNumber >= :longCadenceStart and "
            + "    lpl.cadenceNumber <= :longCadenceEnd and lpl.cadenceType = :longCadenceType) \n"
            + " and spl.mjdMidTime <= (select max(lpl.mjdEndTime) from PixelLog lpl \n"
            + "    where lpl.cadenceNumber >= :longCadenceStart and "
            + "    lpl.cadenceNumber <= :longCadenceEnd and lpl.cadenceType = :longCadenceType) \n";

        Query q = getSession().createQuery(queryString);
        q.setInteger("shortCadenceType", Cadence.CADENCE_SHORT);
        q.setInteger("longCadenceType", Cadence.CADENCE_LONG);
        q.setInteger("longCadenceStart", longStart);
        q.setInteger("longCadenceEnd", longEnd);

        Pair<Integer, Integer> result = uniqueResult(q);
        if (result.left == null || result.right == null) {
            return null;
        }
        return result;
    }

    /**
     * Finds the long cadence interval for the specified short cadence interval.
     * A long cadence is considered in the interval if its startMjd is in the
     * start/end mjd interval of the specified short cadence interval.
     * 
     * @return null If data is not available for the specified range else
     * returns the [start, end] long cadence numbers
     */
    public Pair<Integer, Integer> shortCadenceToLongCadence(int shortStart,
        int shortEnd) {
        if (shortStart > shortEnd) {
            throw new IllegalArgumentException("shortStart " + shortStart
                + " must come before or at the same time as shortEnd "
                + shortEnd);
        }

        String queryString = "select new gov.nasa.spiffy.common.collect.Pair(\n"
            + " min(lpl.cadenceNumber), max(lpl.cadenceNumber)) from PixelLog lpl where \n"
            + " lpl.cadenceType = :longCadenceType and \n"
            + " lpl.mjdEndTime > (select min(spl.mjdStartTime) from PixelLog spl \n"
            + "    where spl.cadenceNumber >= :shortCadenceStart and "
            + "    spl.cadenceNumber <= :shortCadenceEnd and spl.cadenceType = :shortCadenceType) \n"
            + " and lpl.mjdStartTime < (select max(spl.mjdEndTime) from PixelLog spl \n"
            + "    where spl.cadenceNumber >= :shortCadenceStart and "
            + "    spl.cadenceNumber <= :shortCadenceEnd and spl.cadenceType = :shortCadenceType) \n";

        Query q = getSession().createQuery(queryString);
        q.setInteger("shortCadenceType", Cadence.CADENCE_SHORT);
        q.setInteger("longCadenceType", Cadence.CADENCE_LONG);
        q.setInteger("shortCadenceStart", shortStart);
        q.setInteger("shortCadenceEnd", shortEnd);

        Pair<Integer, Integer> result = uniqueResult(q);
        if (result.left == null || result.right == null) {
            return null;
        }
        return result;
    }

    /**
     * Given some cadence find a cadence that has a valid pixel log closest to
     * that cadence.  You need to use if you have been given a cadence number
     * that does not have a pixel log associated, but a valid cadence number is still
     * required somewhere else for processing.
     * @param cadence
     * @return A pair of cadence numbers the first number is closest lower
     * numbered cadence the second is the closest higher numbered cadence.
     */
    public Pair<Integer, Integer> retrieveClosestCadenceToCadence(int cadence, CadenceType cadenceType) {
        String minQuery = "select max(pl.cadenceNumber) from PixelLog pl " + 
            " where pl.cadenceType = :cadenceTypeParam " +
            "   and pl.cadenceNumber < :cadenceNumberParam ";
        Query q = getSession().createQuery(minQuery);
        q.setInteger("cadenceTypeParam", cadenceType.intValue());
        q.setInteger("cadenceNumberParam", cadence);
        
        Integer minCadence = uniqueResult(q);
        
        String maxQuery = "select min(pl.cadenceNumber) from PixelLog pl " +
            " where pl.cadenceType = :cadenceTypeParam " +
            " and pl.cadenceNumber > :cadenceNumberParam";
        q = getSession().createQuery(maxQuery);
        q.setInteger("cadenceTypeParam", cadenceType.intValue());
        q.setInteger("cadenceNumberParam", cadence);
        Integer maxCadence = uniqueResult(q);
        return Pair.of(minCadence, maxCadence);
    }
    
    /**
     * Retrieves all pixel logs
     */
    public List<PixelLog> retrieveAllPixelLogs() {
        String queryString = "from PixelLog";

        Query q = getSession().createQuery(queryString);

        List<PixelLog> list = list(q);
        return list;
    }

    /**
     * Returns the number of {@link PixelLog}s associated with the given
     * {@link DispatchLog}.
     * 
     * @throws HibernateException if there were problems retrieving the count of
     * pixel logs.
     */
    public int pixelLogCount(DispatchLog dispatchLog) {
        Query query = getSession().createQuery(
            "select count(*) from PixelLog f where f.dispatchLog = :dispatchLog");
        query.setEntity("dispatchLog", dispatchLog);
        int count = ((Long) query.iterate()
            .next()).intValue();

        return count;
    }

    /**
     * Retrieve the cadence number for a specified dataset name and cadence
     * type. Used by GapReportDispatcher if DMC can only provide dataset name
     * (they are still checking)
     */
    public Integer retrieveCadenceNumberForDatasetName(String datasetName,
        int cadenceType) {

        Query q = getSession().createQuery(
            "from PixelLog cl where cl.cadenceType = :cadenceType and cl.datasetName = :datasetName");
        q.setParameter("cadenceType", cadenceType);
        q.setParameter("datasetName", datasetName);
        q.setMaxResults(1);

        return uniqueResult(q);
    }

    /**
     * Used by TAD to get the table IDs for target tables in a cadence range.
     */
    public List<PixelLogResult> retrieveTableIdsForCadenceRange(
        TargetType targetTableType, int cadenceStart, int cadenceEnd) {
        LinkedList<PixelLogResult> results = new LinkedList<PixelLogResult>();

        Pair<String, CadenceType> targetTypeInfo = targetTypeFields(targetTableType);
        String tableIdColumn = targetTypeInfo.left;
        int cadenceType = targetTypeInfo.right.intValue();

        // first, get the list of distinct table ids for the specified cadence
        // range
        Query query = getSession().createQuery(
            "select distinct("
                + tableIdColumn
                + ") from "
                + getPixelLogClassName()
                + " "
                + "where cadenceNumber >= :cadenceStart and cadenceNumber <= :cadenceEnd and cadenceType = :cadenceType order by "
                + tableIdColumn);
        query.setParameter("cadenceStart", cadenceStart);
        query.setParameter("cadenceEnd", cadenceEnd);
        query.setParameter("cadenceType", cadenceType);
        List<Short> tableIdResults = list(query);

        Iterator<Short> tableIdResultsIter = tableIdResults.iterator();
        while (tableIdResultsIter.hasNext()) {
            short tableId = tableIdResultsIter.next();

            log.info("Found target table (" + targetTableType + "," + tableId + ").");

            // second, get the cadence ranges for each of those table ids
            Query innerQuery = getSession().createQuery(
                "select min(cadenceNumber), max(cadenceNumber) from "
                    + getPixelLogClassName() + " " + "where " + tableIdColumn
                    + " = :tableId and cadenceType = :cadenceType");
            innerQuery.setParameter("tableId", tableId);
            innerQuery.setParameter("cadenceType", cadenceType);

            List<Object[]> cadenceRangeResults = list(innerQuery);

            Object[] cadenceRanges = cadenceRangeResults.iterator()
                .next();

            Object cadenceStartForTableResult = cadenceRanges[0];
            Object cadenceEndForTableResult = cadenceRanges[1];
            int cadenceStartForTable = 0;
            int cadenceEndForTable = 0;

            cadenceStartForTable = ((Number) cadenceStartForTableResult).intValue();
            cadenceEndForTable = ((Number) cadenceEndForTableResult).intValue();

            results.add(new PixelLogResult(tableId, cadenceStartForTable,
                cadenceEndForTable));
        }

        log.info("Returning PixelLogResults: " + results);

        return results;
    }

    /**
     * Store a RefPixelLog
     */
    public void createRefPixelLog(RefPixelLog refPixelLog) {
        getSession().save(refPixelLog);
    }

    /**
     * Retrieve RefPixelLogs for the specified timestamp range
     */
    public List<RefPixelLog> retrieveRefPixelLog(long startTimestamp,
        long endTimestamp) {

        Query q = getSession().createQuery(
            "from RefPixelLog rl where rl.timestamp >= :startTimestamp and rl.timestamp <= :endTimestamp");
        q.setParameter("startTimestamp", startTimestamp);
        q.setParameter("endTimestamp", endTimestamp);

        List<RefPixelLog> list = list(q);
        return list;
    }

    /**
     * Retrieve a RefPixelLog for the specified timestamp
     */
    public RefPixelLog retrieveRefPixelLog(long timestamp) {
        Query q = getSession().createQuery(
            "from RefPixelLog rl where rl.timestamp = :timestamp");
        q.setParameter("timestamp", timestamp);

        return uniqueResult(q);
    }

    /**
     * Retrieve all RefPixelLogs
     */
    public List<RefPixelLog> retrieveAllRefPixelLog() {
        Query q = getSession().createQuery(
            "from RefPixelLog rpl order by rpl.timestamp asc");

        List<RefPixelLog> list = list(q);
        return list;
    }

    public List<RefPixelLog> retrieveAllRefPixelLogForTargetTable(
        int targetTableId) {

        Query q = getSession().createQuery(
            "from RefPixelLog rl where rl.targetTableId = :targetTableId order by rl.timestamp asc");
        q.setParameter("targetTableId", targetTableId);

        List<RefPixelLog> result = list(q);

        return result;
    }

    /**
     * Search the pixel logs for the (start, end) times for the given target
     * table.
     * 
     * @param targetTableId The external target table id. This must be a target
     * target table.
     * @param targetType The kind of target table to query for. Reference pixels
     * excluded.
     * @return (mjd start, mjd end) in days
     */
    public Pair<Double, Double> retrieveActualObservationTimeForTargetTable(
        int targetTableId, TargetTable.TargetType targetType) {

        return retrieveActualTableTimes(targetTableId, targetType, true);
    }

    private Pair<String, CadenceType> targetTypeFields(TargetType targetType) {
        String typeFieldName = null;
        CadenceType cadenceType = null;
        
        switch (targetType) {
            case LONG_CADENCE:
                typeFieldName = "lcTargetTableId";
                cadenceType = CadenceType.LONG;
                break;
            case SHORT_CADENCE:
                typeFieldName = "scTargetTableId";
                cadenceType = CadenceType.SHORT;
                break;
            case BACKGROUND:
                typeFieldName = "backTargetTableId";
                cadenceType = CadenceType.LONG;
                break;
            default:
                throw new IllegalStateException("Unhandled enumerated element " + targetType);
        }
        return Pair.of(typeFieldName, cadenceType);
    }
    
    private <T> Pair<T, T> retrieveActualTableTimes(int targetTableId,
        TargetTable.TargetType targetType, boolean mjdOrCadence) {


        Pair<String, CadenceType> targetTypeInfo = targetTypeFields(targetType);
        String typeFieldName = targetTypeInfo.left;
        CadenceType cadenceType = targetTypeInfo.right;
        DataSetType dataSetType = DataSetType.Target;

        String minMaxQuery = (mjdOrCadence) ? "min(plog.mjdStartTime), max(plog.mjdEndTime)"
            : "min(plog.cadenceNumber), max(plog.cadenceNumber)";
        String queryString = "select new gov.nasa.spiffy.common.collect.Pair("
            + minMaxQuery + ") " + " from PixelLog plog " + " where plog."
            + typeFieldName + " = :tableIdParam " + " and plog.cadenceType = "
            + cadenceType.intValue() + " and plog.dataSetType = :dataSetType ";

        Query query = getSession().createQuery(queryString);
        query.setShort("tableIdParam", (short) targetTableId);
        query.setParameter("dataSetType", dataSetType);
        return uniqueResult(query);
    }

    /**
     * Search the pixel logs for the (start, end) times for the given target
     * table.
     * 
     * @param targetTableId The external target table id.
     * @param targetType The kind of target table to query for. Reference pixels
     * excluded.
     * @return (cadence start, cadence end)
     */
    public Pair<Integer, Integer> retrieveActualCadenceTimeForTargetTable(
        int targetTableId, TargetTable.TargetType targetType) {

        return retrieveActualTableTimes(targetTableId, targetType, false);
    }

    public void deletePixelLog(DataSetType dataSetType, int cadenceType,
        int cadenceNumber) {
        Query query = getSession().createQuery(
            "delete " + getPixelLogClassName() + " where "
                + "dataSetType = :dataSetType and "
                + "cadenceType = :cadenceType and "
                + "cadenceNumber = :cadenceNumber");
        query.setParameter("dataSetType", dataSetType);
        query.setParameter("cadenceType", cadenceType);
        query.setParameter("cadenceNumber", cadenceNumber);
        query.executeUpdate();
    }

    /**
     * Get the first and last start cadences from the pixel log.
     * 
     * @return null if no pixel logs exist else this returns a pair(start,stop)
     */
    public Pair<Integer, Integer> retrieveFirstAndLastCadences(int cadenceType) {
        String queryString = "select new gov.nasa.spiffy.common.collect.Pair("
            + "min(cadenceNumber), max(cadenceNumber) "
            + " ) from PixelLog where cadenceType = :paramCadenceType ";
        Query q = getSession().createQuery(queryString);
        q.setInteger("paramCadenceType", cadenceType);

        Pair<Integer, Integer> rv = uniqueResult(q);
        return rv;
    }

    /**
     * Get the cadence number closest to the specified MJD.
     * 
     * @return a cadence number
     */
    public int retrieveCadenceClosestToMjd(int cadenceType, double mjd) {
        // I don't seem able to do this using the hibernate query language.
        // Since a) it does not support queries involving the results of
        // numerical expressions like (a - b) as something ... sort by something
        // and b) once you go SQL you need to deal with database specific
        // problems like limit not being in select statements in Oracle

        String oracleQueryString = "select * from (\n"
            + "  select pl.cadence_number, abs(pl.MJD_MID_TIME - :mjdParam) as timeDiff\n"
            + "    from DR_PIXEL_LOG pl where pl.CADENCE_TYPE = :cadenceTypeParam      \n"
            + "    order by timeDiff                                           \n"
            + ") where rownum = 1";

        String ansiSqlQueryString = " select pl.cadence_number, abs(pl.MJD_MID_TIME - :mjdParam) as timeDiff\n"
            + "    from DR_PIXEL_LOG pl where pl.CADENCE_TYPE = :cadenceTypeParam     \n"
            + "    order by timeDiff limit 1";

        Connection conn = getSession().connection();
        try {
            DatabaseMetaData dbMetadata = conn.getMetaData();
            String dbProductName = dbMetadata.getDatabaseProductName();
            log.info("dbProductName : " + dbProductName);
            boolean isOracle = dbProductName.toLowerCase()
                .contains("oracle");
            SQLQuery sqlQuery = getSession().createSQLQuery(
                isOracle ? oracleQueryString : ansiSqlQueryString);
            sqlQuery.setDouble("mjdParam", mjd);
            sqlQuery.setInteger("cadenceTypeParam", cadenceType);
            Object[] uniqueResult = uniqueResult(sqlQuery);
            Object cadenceObject = uniqueResult[0];
            if (cadenceObject instanceof Integer) {
                return (Integer) cadenceObject;
            } else {
                //Oracle driver may return BigDecimal.
                BigDecimal bigDecimal = (BigDecimal) cadenceObject;
                if (bigDecimal.abs().compareTo(BigDecimal.valueOf(Integer.MAX_VALUE)) > 0) {
                    throw new IllegalStateException("Integer overflow from return value (" + bigDecimal + ")");
                }
                return bigDecimal.intValue();
            }
        } catch (SQLException sqle) {
            throw new IllegalStateException(sqle);
        } finally {
            try {
                conn.close();
            } catch (SQLException e) {
                log.warn(e);
            }
        }
    }

    protected Object getPixelLogInstance(PixelLog pixelLog) {
        return pixelLog;
    }

    protected String getPixelLogClassName() {
        return PixelLog.class.getSimpleName();
    }

    protected List<PixelLog> getPixelLogs(Query q) {
        List<PixelLog> list = list(q);

        return list;
    }

}
