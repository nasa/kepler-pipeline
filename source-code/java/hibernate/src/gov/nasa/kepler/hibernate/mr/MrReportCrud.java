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

package gov.nasa.kepler.hibernate.mr;

import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;

import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;
import org.hibernate.Query;

/**
 * CRUD methods for mission report data structures.
 * 
 * @author Bill Wohler
 */
public class MrReportCrud extends AbstractCrud {
    private static final Log log = LogFactory.getLog(MrReportCrud.class);

    /**
     * Creates a {@link MrReportCrud}.
     */
    public MrReportCrud() {
    }

    /**
     * Creates a {@link MrReportCrud} with the given database service.
     */
    public MrReportCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    /**
     * Persists the given {@link MrReport} object.
     */
    public void create(MrReport report) {
        getSession().save(report);
    }

    /**
     * Deletes the given report from the database.
     * 
     * @param report the report
     * @throws HibernateException if there were problems accessing the database
     */
    public void delete(MrReport report) {
        getSession().delete(report);
    }

    /**
     * Retrieves the names of all modules for which we have reports.
     * 
     * @return a non-{@code null} list of module names
     * @throws HibernateException if there were problems accessing the database
     */
    public List<String> retrieveModuleNames() {
        log.info("Retrieving module names");
        long start = System.currentTimeMillis();

        Query query = getSession().createQuery(
            "select distinct(moduleName.name) from MrReport "
                + "order by moduleName.name");
        List<String> names = list(query);

        log.info(String.format("Retrieved %d module names in %d ms",
            names.size(), System.currentTimeMillis() - start));

        return names;
    }

    /**
     * Retrieves all reports for the given module that were created between the
     * given dates.
     * 
     * @param moduleName the name of the module
     * @param startDate the starting date, inclusive
     * @param endDate the ending date, inclusive
     * @return a non-{@code null} list of reports
     * @throws HibernateException if there were problems accessing the database
     */
    public List<MrReport> retrieveReports(String moduleName, Date startDate,
        Date endDate) {

        log.info(String.format(
            "Retrieving reports for moduleName=%s between %s and %s",
            moduleName, startDate, endDate));
        long start = System.currentTimeMillis();

        String queryStr = " from MrReport where moduleName.name = :moduleName "
            + "and :startDate <= created " + "and :endDate >= created "
            + "order by pipelineInstance.id ASC, pipelineInstanceNode.id ASC, "
            + "pipelineTask.id ASC";

        Query query = getSession().createQuery(queryStr);
        query.setString("moduleName", moduleName);
        query.setDate("startDate", startDate);
        query.setDate("endDate", endDate);

        List<MrReport> reports = list(query);

        log.info(String.format("Retrieved %d reports in %d ms", reports.size(),
            System.currentTimeMillis() - start));

        return reports;
    }

    /**
     * Retrieves all reports for the given module that have the given pipeline
     * instance ID.
     * 
     * @param moduleName the name of the module
     * @param pipelineInstanceId the pipeline instance ID
     * @return a non-{@code null} list of reports
     * @throws HibernateException if there were problems accessing the database
     */
    public List<MrReport> retrieveReports(String moduleName,
        long pipelineInstanceId) {

        log.info(String.format(
            "Retrieving reports for moduleName=%s, pipelineInstanceId=%d",
            moduleName, pipelineInstanceId));
        long start = System.currentTimeMillis();

        String queryStr = " from MrReport where moduleName.name = :moduleName "
            + "and pipelineInstance.id = :pipelineInstanceId "
            + "order by pipelineTask.id ASC, identifier ASC";

        Query query = getSession().createQuery(queryStr);
        query.setString("moduleName", moduleName);
        query.setLong("pipelineInstanceId", pipelineInstanceId);

        List<MrReport> reports = list(query);

        log.info(String.format("Retrieved %d reports in %d ms", reports.size(),
            System.currentTimeMillis() - start));

        return reports;
    }

    /**
     * Retrieves all reports for the given module that have the given pipeline
     * instance ID and pipeline instance node ID.
     * 
     * @param moduleName the name of the module
     * @param pipelineInstanceId the pipeline instance ID
     * @param pipelineInstanceNodeId the pipeline instance node ID
     * @return a non-{@code null} list of reports
     * @throws HibernateException if there were problems accessing the database
     */
    public List<MrReport> retrieveReports(String moduleName,
        long pipelineInstanceId, long pipelineInstanceNodeId) {

        log.info(String.format(
            "Retrieving reports for moduleName=%s, pipelineInstanceId=%d, pipelineInstanceNodeId=%d",
            moduleName, pipelineInstanceId, pipelineInstanceNodeId));
        long start = System.currentTimeMillis();

        String queryStr = " from MrReport where moduleName.name = :moduleName "
            + "and pipelineInstance.id = :pipelineInstanceId "
            + "and pipelineInstanceNode.id = :pipelineInstanceNodeId "
            + "order by pipelineTask.id ASC, identifier ASC";

        Query query = getSession().createQuery(queryStr);
        query.setString("moduleName", moduleName);
        query.setLong("pipelineInstanceId", pipelineInstanceId);
        query.setLong("pipelineInstanceNodeId", pipelineInstanceNodeId);

        List<MrReport> reports = list(query);

        log.info(String.format("Retrieved %d reports in %d ms", reports.size(),
            System.currentTimeMillis() - start));

        return reports;
    }

    /**
     * Retrieves the report associated with the given task.
     * 
     * @param pipelineTaskId the pipeline task ID
     * @return an {@link MrReport} object, or {@code null} if there isn't a
     * report for the given task
     * @throws HibernateException if there were problems accessing the database
     */
    public MrReport retrieveReport(long pipelineTaskId) {
        return retrieveReport(pipelineTaskId, null);
    }

    /**
     * Retrieves the specified report.
     * 
     * @param pipelineTaskId the pipeline task ID
     * @param identifier the report's distinguishing identifier; may be
     * {@code null} or empty if the task has a single report
     * @return an {@link MrReport} object, or {@code null} if there isn't a
     * report for the given task
     * @throws HibernateException if there were problems accessing the database
     */
    public MrReport retrieveReport(long pipelineTaskId, String identifier) {
        log.info(String.format(
            "Retrieving report for pipelineTaskId=%d, identifier=%s",
            pipelineTaskId, identifier));
        long start = System.currentTimeMillis();

        String queryStr = " from MrReport where "
            + "pipelineTask.id = :pipelineTaskId ";
        if (identifier == null || identifier.length() == 0) {
            queryStr += "and identifier is null";
        } else {
            queryStr += "and identifier = :identifier";
        }

        Query query = getSession().createQuery(queryStr);
        query.setLong("pipelineTaskId", pipelineTaskId);
        if (identifier != null && identifier.length() > 0) {
            query.setString("identifier", identifier);
        }

        MrReport report = uniqueResult(query);

        log.info(String.format("Retrieved %sreport in %d ms",
            report == null ? "null " : "", +System.currentTimeMillis() - start));

        return report;
    }
}
