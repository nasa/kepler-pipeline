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

package gov.nasa.kepler.hibernate.pdq;

import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.util.List;

import org.hibernate.Criteria;
import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.criterion.Restrictions;

/**
 * @author Forrest Girouard
 */
public class PdqCrud extends AbstractCrud {

    /**
     * Creates a {@link PdqCrud} object.
     */
    public PdqCrud() {
    }

    /**
     * Creates a new PdqCrud object with the specified persistence manager.
     * 
     * @param databaseService the DatabaseService to use for the operations.
     */
    public PdqCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    /**
     * Store a new AttitudeAdjustment instance or update an existing one.
     * 
     * @param attitudeAdjustment the AttitudeAdjustment object to store.
     */
    public void createAttitudeAdjustment(AttitudeAdjustment attitudeAdjustment) {

        if (attitudeAdjustment == null) {
            throw new NullPointerException("attitudeAdjustment is null");
        }
        getSession().save(attitudeAdjustment);
    }

    /**
     * Store a list of new AttitudeAdjustment instances or update existing ones.
     * 
     * @param attitudeAdjustments the list of AttitudeAdjustment objects to
     * store.
     */
    public void createAttitudeAdjustments(
        List<AttitudeAdjustment> attitudeAdjustments) {

        if (attitudeAdjustments == null) {
            throw new NullPointerException("attitudeAdjustments is null");
        }
        if (attitudeAdjustments.isEmpty()) {
            throw new IllegalArgumentException("attitudeAdjustments is empty");
        }
        for (AttitudeAdjustment attitudeAdjustment : attitudeAdjustments) {
            createAttitudeAdjustment(attitudeAdjustment);
        }
    }

    /**
     * Retrieve all attitude adjustments for the given parameters.
     * 
     * @param refPixelFileTime
     * @param endTime
     * @throws HibernateException if the query was unsuccessful.
     */
    public List<AttitudeAdjustment> retrieveAttitudeAdjustments(
        double startMjd, double endMjd) {

        if (startMjd > endMjd) {
            throw new IllegalArgumentException("start mjd is less than end mjd");
        }
        Query query = getSession().createQuery(
            "from AttitudeAdjustment aa "
                + "left join fetch aa.refPixelLog rpl where "
                + "rpl.mjd >= :startMjd and rpl.mjd <= :endMjd "
                + "order by rpl.mjd");
        query.setParameter("startMjd", startMjd);
        query.setParameter("endMjd", endMjd);

        List<AttitudeAdjustment> attitudeAdjustments = list(query);
        return attitudeAdjustments;
    }

    /**
     * Retrieve latest attitude adjustment.
     * 
     * @return the latest attitude adjustment, or <code>null</code> if there
     * aren't any attitude adjustments.
     * @throws HibernateException if the query was unsuccessful.
     */
    public AttitudeAdjustment retrieveLatestAttitudeAdjustment() {

        List<AttitudeAdjustment> attitudeAdjustments = retrieveLatestAttitudeAdjustments(1);
        if (attitudeAdjustments.size() == 0) {
            return null;
        }

        return attitudeAdjustments.get(0);
    }

    /**
     * Retrieve the latest attitude adjustments.
     * 
     * @param n a non-negative number of adjustments to retrieve. If this number
     * is 0, then all attitude adjustments are returned.
     * @return a list of the last <code>n</code> attitude adjustments; the list
     * may contain less then <code>n</code> objects or may even be empty if the
     * database contains less than <code>n</code> objects.
     * @throws IllegalArgumentExcpetion if <code>n</code> is less than 0.
     * @throws HibernateException if the query was unsuccessful.
     */
    public List<AttitudeAdjustment> retrieveLatestAttitudeAdjustments(int n) {

        if (n < 0) {
            throw new IllegalArgumentException("n can't be negative");
        }

        Query query = getSession().createQuery(
            "from AttitudeAdjustment aa "
                + "left join fetch aa.refPixelLog rpl "
                + "order by rpl.mjd desc");
        if (n > 0) {
            query.setMaxResults(n);
        }

        List<AttitudeAdjustment> attitudeAdjustments = list(query);
        return attitudeAdjustments;
    }

    /**
     * Deletes the given attitude adjustment.
     * 
     * @param attitudeAdjustment a {@link AttitudeAdjustment}.
     * @throws HibernateException if the query was unsuccessful.
     */
    public void delete(AttitudeAdjustment attitudeAdjustment) {

        if (attitudeAdjustment == null) {
            throw new NullPointerException("attitudeAdjustment is null");
        }
        getSession().delete(attitudeAdjustment);
    }

    /**
     * Store a new ModuleOutputMetricReport instance or update an existing one.
     * 
     * @param moduleOutputMetricReport the ModuleOutputMetricReport object to
     * store.
     */
    public void createModuleOutputMetricReport(
        ModuleOutputMetricReport moduleOutputMetricReport) {

        if (moduleOutputMetricReport == null) {
            throw new NullPointerException("moduleOutputMetricReport is null");
        }
        getSession().save(moduleOutputMetricReport);
    }

    /**
     * Store a list of new ModuleOutputMetricReport instances or update existing
     * ones.
     * 
     * @param moduleOutputMetricReports the list of ModuleOutputMetricReport
     * objects to store.
     */
    public void createModuleOutputMetricReports(
        List<ModuleOutputMetricReport> moduleOutputMetricReports) {

        if (moduleOutputMetricReports == null) {
            throw new NullPointerException("moduleOutputMetricReports is null");
        }
        if (moduleOutputMetricReports.isEmpty()) {
            throw new IllegalArgumentException(
                "moduleOutputMetricReports is empty");
        }
        for (ModuleOutputMetricReport report : moduleOutputMetricReports) {
            createModuleOutputMetricReport(report);
        }
    }

    /**
     * Deletes the given metric report.
     * 
     * @param moduleOutputMetricReport a {@link ModuleOutputMetricReport}.
     * @throws HibernateException if the query was unsuccessful.
     */
    public void delete(ModuleOutputMetricReport moduleOutputMetricReport) {

        if (moduleOutputMetricReport == null) {
            throw new NullPointerException("moduleOutputMetricReport is null");
        }
        getSession().delete(moduleOutputMetricReport);
    }

    public void deleteModuleOutputMetricReports(TargetTable targetTable) {

        List<ModuleOutputMetricReport> reports = retrieveModuleOutputMetricReports(targetTable);
        for (ModuleOutputMetricReport report : reports) {
            delete(report);
        }
    }

    /**
     * Retrieve the metric report of the given type for the given target table.
     * 
     * @param targetTable
     * @param type
     * @throws HibernateException if the query was unsuccessful.
     */
    public ModuleOutputMetricReport retrieveModuleOutputMetricReport(
        TargetTable targetTable, ModuleOutputMetricReport.MetricType type,
        int ccdModule, int ccdOutput) {

        if (targetTable == null) {
            throw new NullPointerException("targetTable is null");
        }
        if (targetTable.getType() != TargetType.REFERENCE_PIXEL) {
            throw new IllegalArgumentException(targetTable.getType()
                + ": invalid target table type");
        }
        Criteria query = getSession().createCriteria(
            ModuleOutputMetricReport.class);
        query.add(Restrictions.eq("targetTable", targetTable));
        query.add(Restrictions.eq("type", type));
        query.add(Restrictions.eq("ccdModule", ccdModule));
        query.add(Restrictions.eq("ccdOutput", ccdOutput));

        List<ModuleOutputMetricReport> reports = list(query);
        ModuleOutputMetricReport report = null;
        if (reports.size() > 1) {
            throw new IllegalStateException(targetTable
                + ": target table has more than one " + type
                + " metric for CCD module/output of " + ccdModule + "/"
                + ccdOutput + ".");
        } else if (reports.size() > 0) {
            report = reports.get(0);
        }
        return report;
    }

    /**
     * Retrieve all module output metrics for the target table.
     * 
     * @param targetTable
     * @throws HibernateException if the query was unsuccessful.
     */
    public List<ModuleOutputMetricReport> retrieveModuleOutputMetricReports(
        TargetTable targetTable) {

        if (targetTable == null) {
            throw new NullPointerException("targetTable is null");
        }
        if (targetTable.getType() != TargetType.REFERENCE_PIXEL) {
            throw new IllegalArgumentException(targetTable.getType()
                + ": invalid target table type");
        }
        Criteria query = getSession().createCriteria(
            ModuleOutputMetricReport.class);
        query.add(Restrictions.eq("targetTable", targetTable));

        List<ModuleOutputMetricReport> reports = list(query);
        return reports;
    }

    /**
     * Store a new FocalPlaneMetricReport instance or update an existing one.
     * 
     * @param moduleOutputMetricReport the ModuleOutputMetricReport object to
     * store.
     */
    public void createFocalPlaneMetricReport(
        FocalPlaneMetricReport focalPlaneMetricReport) {

        if (focalPlaneMetricReport == null) {
            throw new NullPointerException("focalPlaneMetricReport is null");
        }
        getSession().save(focalPlaneMetricReport);
    }

    /**
     * Store a list of new FocalPlaneMetricReport instances or update existing
     * ones.
     * 
     * @param focalPlaneMetricReports the list of FocalPlaneMetricReport objects
     * to store.
     */
    public void createFocalPlaneMetricReports(
        List<FocalPlaneMetricReport> focalPlaneMetricReports) {

        if (focalPlaneMetricReports == null) {
            throw new NullPointerException("focalPlaneMetricReports is null");
        }
        if (focalPlaneMetricReports.isEmpty()) {
            throw new IllegalArgumentException(
                "focalPlaneMetricReports is empty");
        }
        for (FocalPlaneMetricReport focalPlaneMetricReport : focalPlaneMetricReports) {
            createFocalPlaneMetricReport(focalPlaneMetricReport);
        }
    }

    /**
     * Deletes the given metric report.
     * 
     * @param focalPlaneMetricReport a {@link FocalPlaneMetricReport}.
     * @throws HibernateException if the query was unsuccessful.
     */
    public void delete(FocalPlaneMetricReport focalPlaneMetricReport) {

        if (focalPlaneMetricReport == null) {
            throw new NullPointerException("focalPlaneMetricReport is null");
        }
        getSession().delete(focalPlaneMetricReport);
    }

    public void deleteFocalPlaneMetricReports(TargetTable targetTable) {

        List<FocalPlaneMetricReport> reports = retrieveFocalPlaneMetricReports(targetTable);
        for (FocalPlaneMetricReport report : reports) {
            delete(report);
        }
    }

    /**
     * Retrieve the focal plane metric report of the given type for the given
     * target table.
     * 
     * @param targetTable
     * @param type
     * @throws HibernateException if the query was unsuccessful.
     */
    public FocalPlaneMetricReport retrieveFocalPlaneMetricReport(
        TargetTable targetTable, FocalPlaneMetricReport.MetricType type) {

        if (targetTable == null) {
            throw new NullPointerException("targetTable is null");
        }
        if (targetTable.getType() != TargetType.REFERENCE_PIXEL) {
            throw new IllegalArgumentException(targetTable.getType()
                + ": invalid target table type");
        }
        Criteria query = getSession().createCriteria(
            FocalPlaneMetricReport.class);
        query.add(Restrictions.eq("targetTable", targetTable));
        query.add(Restrictions.eq("type", type));

        List<FocalPlaneMetricReport> reports = list(query);
        FocalPlaneMetricReport report = null;
        if (reports.size() > 1) {
            throw new IllegalStateException(targetTable
                + ": target table has more than one " + type + " metric.");
        } else if (reports.size() > 0) {
            report = reports.get(0);
        }
        return report;
    }

    /**
     * Retrieve all focal plane metrics for the target table.
     * 
     * @param targetTable
     * @throws HibernateException if the query was unsuccessful.
     */
    public List<FocalPlaneMetricReport> retrieveFocalPlaneMetricReports(
        TargetTable targetTable) {

        if (targetTable == null) {
            throw new NullPointerException("targetTable is null");
        }
        if (targetTable.getType() != TargetType.REFERENCE_PIXEL) {
            throw new IllegalArgumentException(targetTable.getType()
                + ": invalid target table type");
        }
        Criteria query = getSession().createCriteria(
            FocalPlaneMetricReport.class);
        query.add(Restrictions.eq("targetTable", targetTable));

        List<FocalPlaneMetricReport> reports = list(query);
        return reports;
    }
}
