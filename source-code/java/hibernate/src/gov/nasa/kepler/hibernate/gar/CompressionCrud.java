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

package gov.nasa.kepler.hibernate.gar;

import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Criteria;
import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Projections;
import org.hibernate.criterion.Restrictions;

/**
 * Compression tables database operations. The tables manipulated by this class
 * include {@link Histogram}, {@link HistogramGroup}, {@link RequantTable}, and
 * {@link HuffmanTable}.
 * 
 * @author Bill Wohler
 */
public class CompressionCrud extends AbstractCrud {

    private static Log log = LogFactory.getLog(CompressionCrud.class);

    /**
     * Creates a {@link CompressionCrud}.
     */
    public CompressionCrud() {
    }

    /**
     * Creates a {@link CompressionCrud}.
     * 
     * @param databaseService the database service
     */
    public CompressionCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    public void createHuffmanTable(HuffmanTable table) {
        getSession().save(table);
    }

    public List<HuffmanTable> retrieveAllHuffmanTables() {
        Criteria query = getSession().createCriteria(HuffmanTable.class);
        query.addOrder(Order.desc("plannedStartTime"));
        query.addOrder(Order.desc("externalId"));
        query.addOrder(Order.desc("id"));
        List<HuffmanTable> list = list(query);
        return list;
    }

    public List<HuffmanTableDescriptor> retrieveAllHuffmanTableDescriptors() {
        // Use a left outer join with PipelineTask so that we get the Huffman
        // table even when pipelineTask is null. Note that we use 0L instead of
        // the constant HuffmanTableDescriptor.INVALID_ID since the string
        // representation of the constant does not contain the L and therefore
        // fails to match the constructor.
        String s = "select new gov.nasa.kepler.hibernate.gar.HuffmanTableDescriptor("
            + "h.id, "
            + "case when t is null then 0L else t.pipelineInstance.id end, "
            + "case when t is null then 0L else t.id end, "
            + "h.plannedStartTime, h.state, h.externalId, "
            + "h.effectiveCompressionRate, h.theoreticalCompressionRate)\n"
            + "from HuffmanTable h "
            + "left join h.pipelineTask t "
            + "order by h.plannedStartTime desc, h.externalId desc, h.id desc";
        Query query = getSession().createQuery(s);
        List<HuffmanTableDescriptor> list = list(query);

        return list;
    }

    public HuffmanTable retrieveHuffmanTable(long id) {
        Query query = getSession().createQuery(
            "from HuffmanTable where " + "id = :id");
        query.setParameter("id", id);
        return uniqueResult(query);
    }

    public List<HuffmanTable> retrieveHuffmanTable(TargetTable targetTable) {
        List<Short> compressionTableExternalIds = TargetCrud.externalIdsFromPixelLog(
            targetTable, "compressionTableId", getSession());
        List<HuffmanTable> huffmanTables = new ArrayList<HuffmanTable>();
        for (short externalId : compressionTableExternalIds) {
            huffmanTables.add(retrieveUplinkedHuffmanTable(externalId));
        }

        return huffmanTables;
    }

    public HuffmanTable retrieveUplinkedHuffmanTable(int externalId) {
        Query query = getSession().createQuery(
            "from HuffmanTable where " + "state = :state and "
                + "externalId = :externalId");
        query.setParameter("state", State.UPLINKED);
        query.setParameter("externalId", externalId);
        return uniqueResult(query);
    }

    public int[] retrieveUplinkedHuffmanValues(int externalId) {
        HuffmanTable table = retrieveUplinkedHuffmanTable(externalId);

        List<HuffmanEntry> entries = table.getEntries();
        int[] huffmanValues = new int[entries.size()];
        int i = 0;
        for (HuffmanEntry entry : entries) {
            huffmanValues[i++] = entry.getValue();
        }

        return huffmanValues;
    }

    public String[] retrieveUplinkedHuffmanBitstrings(int externalId) {
        HuffmanTable table = retrieveUplinkedHuffmanTable(externalId);

        List<HuffmanEntry> entries = table.getEntries();
        String[] huffmanBitstrings = new String[entries.size()];
        int i = 0;
        for (HuffmanEntry entry : entries) {
            huffmanBitstrings[i++] = entry.getBitstring();
        }

        return huffmanBitstrings;
    }

    /**
     * 
     * @param mjdStart The cadence start time
     * @param mjdEnd The cadence end time, inclusive
     * @return A list of zero or more HuffmanTables ordered by externalId
     */
    public List<HuffmanTable> retrieveHuffmanTables(double mjdStart,
        double mjdEnd) {
        String qString = "from HuffmanTable ht where state = :state and ht.externalId in (\n"
            + " select pl.compressionTableId from PixelLog pl where \n"
            + "    pl.mjdMidTime >= :start and pl.mjdMidTime <= :end "
            + ") order by ht.externalId";

        Query q = getSession().createQuery(qString);
        q.setParameter("state", State.UPLINKED);
        q.setDouble("start", mjdStart);
        q.setDouble("end", mjdEnd);

        List<HuffmanTable> rv = list(q);
        return rv;
    }

    public void createRequantTable(RequantTable table) {
        getSession().save(table);
    }

    public List<RequantTable> retrieveAllRequantTables() {
        Criteria query = getSession().createCriteria(RequantTable.class);
        query.addOrder(Order.desc("plannedStartTime"));
        query.addOrder(Order.desc("externalId"));
        query.addOrder(Order.desc("id"));
        List<RequantTable> list = list(query);
        return list;
    }

    public List<RequantTableDescriptor> retrieveAllRequantTableDescriptors() {
        // Use a left outer join with PipelineTask so that we get the requant
        // table even when pipelineTask is null. Note that we use 0L instead of
        // the constant RequantTableDescriptor.INVALID_ID since the string
        // representation of the constant does not contain the L and therefore
        // fails to match the constructor.
        String s = "select new gov.nasa.kepler.hibernate.gar.RequantTableDescriptor("
            + "r.id, "
            + "case when t is null then 0L else t.pipelineInstance.id end, "
            + "case when t is null then 0L else t.id end, "
            + "r.plannedStartTime, r.state, r.externalId)\n"
            + "from RequantTable r "
            + "left join r.pipelineTask t "
            + "order by r.plannedStartTime desc, r.externalId desc, r.id desc";
        Query query = getSession().createQuery(s);
        List<RequantTableDescriptor> list = list(query);

        return list;
    }

    public RequantTable retrieveRequantTable(long id) {
        Query query = getSession().createQuery(
            "from RequantTable where " + "id = :id");
        query.setParameter("id", id);
        return uniqueResult(query);
    }

    public List<RequantTable> retrieveRequantTable(TargetTable targetTable) {
        List<Short> requantTableExternalIds = TargetCrud.externalIdsFromPixelLog(
            targetTable, "compressionTableId", getSession());
        List<RequantTable> requantTables = new ArrayList<RequantTable>();
        for (short externalId : requantTableExternalIds) {
            requantTables.add(retrieveUplinkedRequantTable(externalId));
        }

        return requantTables;
    }

    public RequantTable retrieveUplinkedRequantTable(int externalId) {
        Query query = getSession().createQuery(
            "from RequantTable where " + "state = :state and "
                + "externalId = :externalId");
        query.setParameter("state", State.UPLINKED);
        query.setParameter("externalId", externalId);
        return uniqueResult(query);
    }

    /**
     * 
     * @param mjdStart Start time of this cadence
     * @param mjdEnd End time (inclusive) of the cadence
     * @return RequantTables (zero or more) sorted by external id
     */
    public List<RequantTable> retrieveRequantTables(double mjdStart,
        double mjdEnd) {
        String qString = "from RequantTable rt where state = :state and rt.externalId in ( \n"
            + "select pl.compressionTableId from PixelLog pl\n"
            + "      where pl.mjdMidTime >= :start and pl.mjdMidTime <= :end\n "
            + ") order by rt.externalId";

        Query q = getSession().createQuery(qString);
        q.setParameter("state", State.UPLINKED);
        q.setDouble("start", mjdStart);
        q.setDouble("end", mjdEnd);

        List<RequantTable> rv = list(q);
        return rv;
    }

    /**
     * Stores an {@link Histogram} object.
     * 
     * @param histogram the {@link Histogram} object to store
     * @throws HibernateException if there were problems persisting the
     * {@link Histogram} object
     */
    public void create(Histogram histogram) {
        getSession().save(histogram);
    }

    /**
     * Stores an {@link HistogramGroup} object.
     * 
     * @param histogramGroup the {@link HistogramGroup} object to store
     * @throws HibernateException if there were problems persisting the
     * {@link HistogramGroup} object
     */
    public void create(HistogramGroup histogramGroup) {
        getSession().save(histogramGroup);
    }

    /**
     * Retrieves all {@link HistogramGroup}s in the database.
     * 
     * @return a non-{@code null} list of {@link HistogramGroup}s
     * @throws HibernateException if there were problems accessing the database
     */
    public List<HistogramGroup> retrieveAllHistogramGroups() {
        Criteria query = getSession().createCriteria(HistogramGroup.class);

        List<HistogramGroup> result = list(query);

        return result;
    }

    /**
     * Retrieves the {@link HistogramGroup}s for the given
     * {@link PipelineInstance}.
     * 
     * @param pipelineInstance the pipeline instance
     * @return a non-{@code null} list of {@link HistogramGroup}s
     * @throws HibernateException if there were problems accessing the database
     */
    public List<HistogramGroup> retrieveHistogramGroups(
        PipelineInstance pipelineInstance) {

        Criteria query = getSession().createCriteria(HistogramGroup.class);
        query.add(Restrictions.eq("pipelineInstance", pipelineInstance));

        List<HistogramGroup> result = list(query);

        return result;
    }

    /**
     * Retrieves the {@link HistogramGroup} for the given
     * {@link PipelineInstance} that represents the entire focal plane.
     * 
     * @param pipelineInstanceId the pipeline instance
     * @return a {@link HistogramGroup} or {@code null} if there weren't any
     * @throws HibernateException if there were problems accessing the database
     */
    public HistogramGroup retrieveHistogramGroupForEntireFocalPlane(
        long pipelineInstanceId) {

        Criteria query = getSession().createCriteria(HistogramGroup.class);
        query.add(Restrictions.eq("pipelineInstance.id", pipelineInstanceId));
        query.add(Restrictions.eq("ccdModule", HistogramGroup.CCD_MOD_OUT_ALL));
        query.add(Restrictions.eq("ccdOutput", HistogramGroup.CCD_MOD_OUT_ALL));

        HistogramGroup result = uniqueResult(query);

        return result;
    }

    /**
     * Retrieves the pipeline instance ID of the {@link HistogramGroup} with the
     * largest ID. If no {@link HistogramGroup}s are found, then -1 is returned.
     */
    public long retrievePipelineInstanceIdForLatestHistogramGroupForEntireFocalPlane() {
        Criteria query = getSession().createCriteria(HistogramGroup.class);
        query.add(Restrictions.eq("ccdModule", HistogramGroup.CCD_MOD_OUT_ALL));
        query.add(Restrictions.eq("ccdOutput", HistogramGroup.CCD_MOD_OUT_ALL));
        query.addOrder(Order.desc("id"));
        query.setMaxResults(1);
        HistogramGroup histogramGroup = uniqueResult(query);

        if (histogramGroup == null) {
            return -1L;
        }

        return histogramGroup.getPipelineInstance()
            .getId();
    }

    /**
     * Deletes the given histogram from the database.
     * 
     * @param histogram the {@link Histogram} object to delete
     */
    public void delete(Histogram histogram) {
        getSession().delete(histogram);
    }

    /**
     * Deletes the given histogram group from the database.
     * 
     * @param histogramGroup the {@link HistogramGroup} object to delete
     */
    public void delete(HistogramGroup histogramGroup) {
        getSession().delete(histogramGroup);
    }

    public Set<Integer> retrieveUplinkedExternalIds() {
        Criteria query = getSession().createCriteria(HuffmanTable.class);
        query.add(Restrictions.eq("state", State.UPLINKED));
        query.setProjection(Projections.property("externalId"));

        Set<Integer> huffmanIds = new TreeSet<Integer>(
            this.<Integer> list(query));

        query = getSession().createCriteria(RequantTable.class);
        query.add(Restrictions.eq("state", State.UPLINKED));
        query.setProjection(Projections.property("externalId"));

        Set<Integer> requantIds = new TreeSet<Integer>(
            this.<Integer> list(query));

        if (!huffmanIds.equals(requantIds)) {
            log.warn(String.format(
                "Uplinked table IDs for Huffman tables and requant tables are not the same (Huffman: %s; requant: %s)",
                huffmanIds, requantIds));
            log.warn("Using uplinked table IDs for Huffman tables");
        }

        return huffmanIds;
    }

    public Set<Integer> retrieveExternalIdsInUse() {
        Criteria query = getSession().createCriteria(HuffmanTable.class);
        query.add(Restrictions.ne("externalId", ExportTable.INVALID_EXTERNAL_ID));
        query.setProjection(Projections.property("externalId"));

        Set<Integer> huffmanIds = new TreeSet<Integer>(
            this.<Integer> list(query));

        query = getSession().createCriteria(RequantTable.class);
        query.add(Restrictions.ne("externalId", ExportTable.INVALID_EXTERNAL_ID));
        query.setProjection(Projections.property("externalId"));

        Set<Integer> requantIds = new TreeSet<Integer>(
            this.<Integer> list(query));

        if (!huffmanIds.equals(requantIds)) {
            log.warn(String.format(
                "Uplinked table IDs for Huffman tables and requant tables are not the same (Huffman: %s; requant: %s)",
                huffmanIds, requantIds));
            log.warn("Using uplinked table IDs for Huffman tables");
        }

        return huffmanIds;
    }

    /**
     * Returns the time interval where the given compression tables are valid.
     */
    public Pair<Double, Double> retrieveStartEndTimes(int externalId) {
        String qString = "select new gov.nasa.spiffy.common.collect.Pair(min(pl.mjdMidTime),max(pl.mjdMidTime))\n"
            + " from PixelLog pl where pl.compressionTableId = :tableId";

        Query q = getSession().createQuery(qString);
        q.setShort("tableId", (short) externalId);

        Pair<Double, Double> rv = uniqueResult(q);

        return rv;
    }
}
