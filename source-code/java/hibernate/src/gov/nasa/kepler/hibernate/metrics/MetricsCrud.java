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

package gov.nasa.kepler.hibernate.metrics;

import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Query;
import org.hibernate.Session;

public class MetricsCrud extends AbstractCrud{
    private static final Log log = LogFactory.getLog(MetricsCrud.class);

    protected DatabaseService databaseService = null;

    public MetricsCrud() {
    }

    public MetricsCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    public void createMetricType(MetricType metricType) {
        getSession().save(metricType);
    }

    public void createMetricValue(MetricValue metricValue) {
        getSession().save(metricValue);
    }

    public List<MetricType> retrieveAllMetricTypes() {
        Session session = getSession();

        Query q = session.createQuery("from MetricType");

        List<MetricType> l = list(q);

        return l;
    }

    public List<MetricValue> retrieveAllMetricValuesForType(MetricType metricType, Date start, Date end) {
        Session session = getSession();

        Query q = session.createQuery("from MetricValue where metricType = :metricType and timestamp >= :start and timestamp <= :end order by timestamp asc");
        q.setEntity("metricType", metricType);
        q.setParameter("start", start);
        q.setParameter("end", end);

        List<MetricValue> l = list(q);

        log.debug("num matches = " + l.size());

        return l;
    }

    public Pair<Date, Date> getTimestampRange(MetricType metricType) {

        Session session = getSession();

        Query q = session.createQuery("select min(timestamp), max(timestamp) from MetricValue where metricType = :metricType");
        q.setEntity("metricType", metricType);

        Object[] results = uniqueResult(q);

        Date min = (Date) results[0];
        Date max = (Date) results[1];

        return Pair.of(min, max);
    }

    public int retrieveMetricValueRowCount() {
        Session session = getSession();

        Query q = session.createQuery("select count(*) from MetricValue");

        Number count = uniqueResult(q);

        return count.intValue();
    }
    
    public long retrieveMinimumId() {
        Session session = getSession();

        Query q = session.createQuery("select min(id) from MetricValue");

        Number minId = uniqueResult(q);

        return minId.longValue();
    }
    
    public int deleteOldMetrics(int maxRows){
        
        log.info("Preparing to delete old rows from PI_METRIC_VALUE.  maxRows = " + maxRows);
        
        Session session = getSession();
        int rowCount = 0;
        int numRowsOverLimit = 0;
        int numUpdated = 0;
        
        do{
            rowCount = retrieveMetricValueRowCount();
            numRowsOverLimit = rowCount - maxRows;

            log.info("rowCount = " + rowCount);
            
            if(numRowsOverLimit > 0){
                log.info("numRowsOverLimit = " + numRowsOverLimit);

                long minId = retrieveMinimumId();
                Query q = session.createQuery("delete from MetricValue where id <= :id");
                long idToDelete = minId + numRowsOverLimit;
                q.setParameter("id", idToDelete);
                int numUpdatedThisChunk = q.executeUpdate();
                
                log.info("deleted " + numUpdatedThisChunk + " rows (where id <= " + idToDelete + ")");
                
                numUpdated += numUpdatedThisChunk;
            }else{
                log.info("rowCount under the limit, no delete needed");
            }
        }while(numRowsOverLimit > 0);
        
        log.info("deleted a total of " + numUpdated + " rows.");

        return numUpdated;
    }
}
