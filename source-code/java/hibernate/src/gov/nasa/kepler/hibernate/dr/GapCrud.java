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

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Query;

/**
 * Data gap access database operations. The tables manipulated by this class
 * include {@link GapCadence}, {@link GapChannel}, {@link GapTarget},
 * {@link GapPixel}, and {@link GapCollateralPixel}.
 * 
 * @author Bill Wohler
 * @author Todd Klaus tklaus@arc.nasa.gov
 */
public class GapCrud extends AbstractCrud {

    /**
     * Creates a {@link GapCrud}.
     */
    public GapCrud() {
    }

    /**
     * Creates a {@link GapCrud}.
     * 
     * @param dbs the database service.
     */
    public GapCrud(DatabaseService dbs) {
        super(dbs);
    }

    /**
     * Stores or updates a {@link GapCadence} object.
     * 
     * @param gapCadence the {@link GapCadence} object.
     * @throws HibernateException if there were problems with the database
     * transaction.
     */
    public void create(GapCadence gapCadence) {
        getSession().save(gapCadence);
    }

    /**
     * Stores or updates a {@link GapChannel} object.
     * 
     * @param gapChannel the {@link GapChannel} object.
     * @throws HibernateException if there were problems with the database
     * transaction.
     */
    public void create(GapChannel gapChannel) {
        getSession().save(gapChannel);
    }

    /**
     * Stores or updates a {@link GapTarget} object.
     * 
     * @param gapTarget the {@link GapTarget} object.
     * @throws HibernateException if there were problems with the database
     * transaction.
     */
    public void create(GapTarget gapTarget) {
        getSession().save(gapTarget);
    }

    /**
     * Stores or updates a {@link GapPixel} object.
     * 
     * @param gapPixel the {@link GapPixel} object.
     * @throws HibernateException if there were problems with the database
     * transaction.
     */
    public void create(GapPixel gapPixel) {
        getSession().save(gapPixel);
    }

    /**
     * Stores or updates a {@link GapCollateralPixel} object.
     * 
     * @param gapCollateralPixel the {@link GapCollateralPixel} object.
     * @throws HibernateException if there were problems with the database
     * transaction.
     */
    public void create(GapCollateralPixel gapCollateralPixel) {
        getSession().save(gapCollateralPixel);
    }

    /**
     * Retrieves {@link GapCadence}s for the specified cadence range.
     * 
     * @param cadenceType the cadence type.
     * @param startCadence the starting cadence number.
     * @param endCadence the ending cadence number.
     * @return a non-{@code null} list of {@link GapCadence} objects.
     * @throws HibernateException if there were problems with the database
     * transaction.
     */
    public List<GapCadence> retrieveGapCadence(CadenceType cadenceType,
        int startCadence, int endCadence) {

        Query query = getSession().createQuery(
            "from GapCadence where " + "cadenceType = :cadenceType "
                + "and cadenceNumber >= :startCadence "
                + "and cadenceNumber <= :endCadence "
                + "order by cadenceNumber asc");
        query.setParameter("cadenceType", cadenceType);
        query.setInteger("startCadence", startCadence);
        query.setInteger("endCadence", endCadence);

        List<GapCadence> list = list(query);

        return list;
    }

    /**
     * Retrieves {@link GapChannel}s for the specified cadence range and
     * module/output.
     * 
     * @param cadenceType the cadence type.
     * @param startCadence the starting cadence number.
     * @param endCadence the ending cadence number.
     * @param ccdModule the CCD module.
     * @param ccdOutput the CCD output.
     * @return a non-{@code null} list of {@link GapChannel} objects.
     * @throws HibernateException if there were problems with the database
     * transaction.
     */
    public List<GapChannel> retrieveGapChannel(CadenceType cadenceType,
        int startCadence, int endCadence, int ccdModule, int ccdOutput) {

        Query query = getSession().createQuery(
            "from GapChannel where " + "cadenceType = :cadenceType "
                + "and cadenceNumber >= :startCadence "
                + "and cadenceNumber <= :endCadence "
                + "and ccdModule = :ccdModule " + "and ccdOutput = :ccdOutput "
                + "order by cadenceNumber asc, " + "ccdModule asc, "
                + "ccdOutput asc");
        query.setParameter("cadenceType", cadenceType);
        query.setInteger("startCadence", startCadence);
        query.setInteger("endCadence", endCadence);
        query.setInteger("ccdModule", ccdModule);
        query.setInteger("ccdOutput", ccdOutput);

        List<GapChannel> list = list(query);

        return list;
    }

    /**
     * Retrieves {@link GapChannel}s for the specified cadence range.
     * 
     * @param cadenceType the cadence type.
     * @param startCadence the starting cadence number.
     * @param endCadence the ending cadence number.
     * @return a non-{@code null} list of {@link GapChannel} objects.
     * @throws HibernateException if there were problems with the database
     * transaction.
     */
    public List<GapChannel> retrieveGapChannel(CadenceType cadenceType,
        int startCadence, int endCadence) {

        Query query = getSession().createQuery(
            "from GapChannel where " + "cadenceType = :cadenceType "
                + "and cadenceNumber >= :startCadence "
                + "and cadenceNumber <= :endCadence "
                + "order by cadenceNumber asc, " + "ccdModule asc, "
                + "ccdOutput asc");
        query.setParameter("cadenceType", cadenceType);
        query.setInteger("startCadence", startCadence);
        query.setInteger("endCadence", endCadence);

        List<GapChannel> list = list(query);

        return list;
    }

    /**
     * Retrieves {@link GapTarget}s for the specified cadence range,
     * module/output, and target index.
     * 
     * @param cadenceType the cadence type.
     * @param targetTableType the target table type.
     * @param startCadence the starting cadence number.
     * @param endCadence the ending cadence number.
     * @param ccdModule the CCD module.
     * @param ccdOutput the CCD output.
     * @param targetIndex the target index.
     * @return a non-{@code null} list of {@link GapTarget} objects.
     * @throws HibernateException if there were problems with the database
     * transaction.
     */
    public List<GapTarget> retrieveGapTarget(CadenceType cadenceType,
        TargetType targetTableType, int startCadence, int endCadence,
        int ccdModule, int ccdOutput, int targetIndex) {

        Query query = getSession().createQuery(
            "from GapTarget where " + "cadenceType = :cadenceType "
                + "and targetTableType = :targetTableType "
                + "and cadenceNumber >= :startCadence "
                + "and cadenceNumber <= :endCadence "
                + "and ccdModule = :ccdModule " + "and ccdOutput = :ccdOutput "
                + "and targetIndex = :targetIndex "
                + "order by cadenceNumber asc, " + "ccdModule asc, "
                + "ccdOutput asc, " + "targetIndex asc");
        query.setParameter("cadenceType", cadenceType);
        query.setParameter("targetTableType", targetTableType);
        query.setInteger("startCadence", startCadence);
        query.setInteger("endCadence", endCadence);
        query.setInteger("ccdModule", ccdModule);
        query.setInteger("ccdOutput", ccdOutput);
        query.setInteger("targetIndex", targetIndex);

        List<GapTarget> list = list(query);

        return list;
    }

    /**
     * Retrieves {@link GapTarget}s for the specified cadence range, and
     * module/output.
     * 
     * @param cadenceType the cadence type.
     * @param targetTableType the target table type.
     * @param startCadence the starting cadence number.
     * @param endCadence the ending cadence number.
     * @param ccdModule the CCD module.
     * @param ccdOutput the CCD output.
     * @return a non-{@code null} list of {@link GapTarget} objects.
     * @throws HibernateException if there were problems with the database
     */
    public List<GapTarget> retrieveGapTarget(CadenceType cadenceType,
        TargetType targetTableType, int startCadence, int endCadence,
        int ccdModule, int ccdOutput) {

        Query query = getSession().createQuery(
            "from GapTarget where " + "cadenceType = :cadenceType "
                + "and targetTableType = :targetTableType "
                + "and cadenceNumber >= :startCadence "
                + "and cadenceNumber <= :endCadence "
                + "and ccdModule = :ccdModule " + "and ccdOutput = :ccdOutput "
                + "order by cadenceNumber asc, " + "ccdModule asc, "
                + "ccdOutput asc, " + "targetIndex asc");
        query.setParameter("cadenceType", cadenceType);
        query.setParameter("targetTableType", targetTableType);
        query.setInteger("startCadence", startCadence);
        query.setInteger("endCadence", endCadence);
        query.setInteger("ccdModule", ccdModule);
        query.setInteger("ccdOutput", ccdOutput);

        List<GapTarget> list = list(query);

        return list;
    }

    /**
     * Retrieves {@link GapTarget}s for the specified cadence range.
     * 
     * @param cadenceType the cadence type.
     * @param targetTableType the target table type.
     * @param startCadence the starting cadence number.
     * @param endCadence the ending cadence number.
     * @return a non-{@code null} list of {@link GapTarget} objects.
     * @throws HibernateException if there were problems with the database
     * transaction.
     */
    public List<GapTarget> retrieveGapTarget(CadenceType cadenceType,
        TargetType targetTableType, int startCadence, int endCadence) {

        Query query = getSession().createQuery(
            "from GapTarget where " + "cadenceType = :cadenceType "
                + "and targetTableType = :targetTableType "
                + "and cadenceNumber >= :startCadence "
                + "and cadenceNumber <= :endCadence "
                + "order by cadenceNumber asc, " + "ccdModule asc, "
                + "ccdOutput asc, " + "targetIndex asc");
        query.setParameter("cadenceType", cadenceType);
        query.setParameter("targetTableType", targetTableType);
        query.setInteger("startCadence", startCadence);
        query.setInteger("endCadence", endCadence);

        List<GapTarget> list = list(query);

        return list;
    }

    /**
     * Retrieves {@link GapPixel}s for the specified cadence range,
     * module/output, target index, and row/column.
     * 
     * @param cadenceType the cadence type.
     * @param targetTableType the target table type.
     * @param startCadence the starting cadence number.
     * @param endCadence the ending cadence number.
     * @param ccdModule the CCD module.
     * @param ccdOutput the CCD output.
     * @param targetIndex the target index.
     * @param ccdRow the pixel's row.
     * @param ccdColumn the pixel's column.
     * @return a non-{@code null} list of {@link GapPixel} objects.
     * @throws HibernateException if there were problems with the database
     * transaction.
     */
    public List<GapPixel> retrieveGapPixel(CadenceType cadenceType,
        TargetType targetTableType, int startCadence, int endCadence,
        int ccdModule, int ccdOutput, int targetIndex, int ccdRow, int ccdColumn) {

        Query query = getSession().createQuery(
            "from GapPixel where " + "cadenceType = :cadenceType "
                + "and targetTableType = :targetTableType "
                + "and cadenceNumber >= :startCadence "
                + "and cadenceNumber <= :endCadence "
                + "and ccdModule = :ccdModule " + "and ccdOutput = :ccdOutput "
                + "and targetIndex = :targetIndex " + "and ccdRow = :ccdRow "
                + "and ccdColumn = :ccdColumn "
                + "order by cadenceNumber asc, " + "ccdModule asc, "
                + "ccdOutput asc, " + "targetIndex asc, " + "ccdRow asc, "
                + "ccdColumn asc");
        query.setParameter("cadenceType", cadenceType);
        query.setParameter("targetTableType", targetTableType);
        query.setInteger("startCadence", startCadence);
        query.setInteger("endCadence", endCadence);
        query.setInteger("ccdModule", ccdModule);
        query.setInteger("ccdOutput", ccdOutput);
        query.setInteger("targetIndex", targetIndex);
        query.setInteger("ccdRow", ccdRow);
        query.setInteger("ccdColumn", ccdColumn);

        List<GapPixel> list = list(query);

        return list;
    }

    /**
     * Retrieves {@link GapPixel}s for the specified cadence range,
     * module/output, and target index.
     * 
     * @param cadenceType the cadence type.
     * @param targetTableType the target table type.
     * @param startCadence the starting cadence number.
     * @param endCadence the ending cadence number.
     * @param ccdModule the CCD module.
     * @param ccdOutput the CCD output.
     * @param targetIndex the target index.
     * @return a non-{@code null} list of {@link GapPixel} objects.
     * @throws HibernateException if there were problems with the database
     * transaction.
     */
    public List<GapPixel> retrieveGapPixel(CadenceType cadenceType,
        TargetType targetTableType, int startCadence, int endCadence,
        int ccdModule, int ccdOutput, int targetIndex) {

        Query query = getSession().createQuery(
            "from GapPixel where " + "cadenceType = :cadenceType "
                + "and targetTableType = :targetTableType "
                + "and cadenceNumber >= :startCadence "
                + "and cadenceNumber <= :endCadence "
                + "and ccdModule = :ccdModule " + "and ccdOutput = :ccdOutput "
                + "and targetIndex = :targetIndex "
                + "order by cadenceNumber asc, " + "ccdModule asc, "
                + "ccdOutput asc, " + "targetIndex asc, " + "ccdRow asc, "
                + "ccdColumn asc");
        query.setParameter("cadenceType", cadenceType);
        query.setParameter("targetTableType", targetTableType);
        query.setInteger("startCadence", startCadence);
        query.setInteger("endCadence", endCadence);
        query.setInteger("ccdModule", ccdModule);
        query.setInteger("ccdOutput", ccdOutput);
        query.setInteger("targetIndex", targetIndex);

        List<GapPixel> list = list(query);

        return list;
    }

    /**
     * Retrieves {@link GapPixel}s for the specified cadence range and
     * module/output.
     * 
     * @param cadenceType the cadence type.
     * @param targetTableType the target table type.
     * @param startCadence the starting cadence number.
     * @param endCadence the ending cadence number.
     * @param ccdModule the CCD module.
     * @param ccdOutput the CCD output.
     * @return a non-{@code null} list of {@link GapPixel} objects.
     * @throws HibernateException if there were problems with the database
     * transaction.
     */
    public List<GapPixel> retrieveGapPixel(CadenceType cadenceType,
        TargetType targetTableType, int startCadence, int endCadence,
        int ccdModule, int ccdOutput) {

        Query query = getSession().createQuery(
            "from GapPixel where " + "cadenceType = :cadenceType "
                + "and targetTableType = :targetTableType "
                + "and cadenceNumber >= :startCadence "
                + "and cadenceNumber <= :endCadence "
                + "and ccdModule = :ccdModule " + "and ccdOutput = :ccdOutput "
                + "order by cadenceNumber asc, " + "ccdModule asc, "
                + "ccdOutput asc, " + "targetIndex asc, " + "ccdRow asc, "
                + "ccdColumn asc");
        query.setParameter("cadenceType", cadenceType);
        query.setParameter("targetTableType", targetTableType);
        query.setInteger("startCadence", startCadence);
        query.setInteger("endCadence", endCadence);
        query.setInteger("ccdModule", ccdModule);
        query.setInteger("ccdOutput", ccdOutput);

        List<GapPixel> list = list(query);

        return list;
    }

    /**
     * Retrieves {@link GapPixel}s for the specified cadence range.
     * 
     * @param cadenceType the cadence type.
     * @param targetTableType the target table type.
     * @param startCadence the starting cadence number.
     * @param endCadence the ending cadence number.
     * @return a non-{@code null} list of {@link GapPixel} objects.
     * @throws HibernateException if there were problems with the database
     * transaction.
     */
    public List<GapPixel> retrieveGapPixel(CadenceType cadenceType,
        TargetType targetTableType, int startCadence, int endCadence) {

        Query query = getSession().createQuery(
            "from GapPixel where " + "cadenceType = :cadenceType "
                + "and targetTableType = :targetTableType "
                + "and cadenceNumber >= :startCadence "
                + "and cadenceNumber <= :endCadence "
                + "order by cadenceNumber asc, " + "ccdModule asc, "
                + "ccdOutput asc, " + "targetIndex asc, " + "ccdRow asc, "
                + "ccdColumn asc");
        query.setParameter("cadenceType", cadenceType);
        query.setParameter("targetTableType", targetTableType);
        query.setInteger("startCadence", startCadence);
        query.setInteger("endCadence", endCadence);

        List<GapPixel> list = list(query);

        return list;
    }

    /**
     * Retrieves {@link GapCollateralPixel}s for the specified cadence range,
     * module/output, target index, and row/column.
     * 
     * @param cadenceType the cadence type.
     * @param startCadence the starting cadence number.
     * @param endCadence the ending cadence number.
     * @param ccdModule the CCD module.
     * @param ccdOutput the CCD output.
     * @param ccdRowOrColumn the row or column of the collateral data.
     * @return a non-{@code null} list of {@link GapCollateralPixel} objects.
     * @throws HibernateException if there were problems with the database
     * transaction.
     */
    public List<GapCollateralPixel> retrieveGapCollateralPixel(
        CadenceType cadenceType, int startCadence, int endCadence,
        int ccdModule, int ccdOutput, int ccdRowOrColumn) {

        Query query = getSession().createQuery(
            "from GapCollateralPixel where " + "cadenceType = :cadenceType "
                + "and cadenceNumber >= :startCadence "
                + "and cadenceNumber <= :endCadence "
                + "and ccdModule = :ccdModule " + "and ccdOutput = :ccdOutput "
                + "and ccdRowOrColumn = :ccdRowOrColumn "
                + "order by cadenceNumber asc, " + "ccdModule asc, "
                + "ccdOutput asc, " + "pixelType asc, " + "ccdRowOrColumn asc");
        query.setParameter("cadenceType", cadenceType);
        query.setInteger("startCadence", startCadence);
        query.setInteger("endCadence", endCadence);
        query.setInteger("ccdModule", ccdModule);
        query.setInteger("ccdOutput", ccdOutput);
        query.setInteger("ccdRowOrColumn", ccdRowOrColumn);

        List<GapCollateralPixel> list = list(query);

        return list;
    }

    /**
     * Retrieves {@link GapCollateralPixel}s for the specified cadence range and
     * module/output.
     * 
     * @param cadenceType the cadence type.
     * @param startCadence the starting cadence number.
     * @param endCadence the ending cadence number.
     * @param ccdModule the CCD module.
     * @param ccdOutput the CCD output.
     * @return a non-{@code null} list of {@link GapCollateralPixel} objects.
     * @throws HibernateException if there were problems with the database
     * transaction.
     */
    public List<GapCollateralPixel> retrieveGapCollateralPixel(
        CadenceType cadenceType, int startCadence, int endCadence,
        int ccdModule, int ccdOutput) {

        Query query = getSession().createQuery(
            "from GapCollateralPixel where " + "cadenceType = :cadenceType "
                + "and cadenceNumber >= :startCadence "
                + "and cadenceNumber <= :endCadence "
                + "and ccdModule = :ccdModule " + "and ccdOutput = :ccdOutput "
                + "order by cadenceNumber asc, " + "ccdModule asc, "
                + "ccdOutput asc, " + "pixelType asc, " + "ccdRowOrColumn asc");
        query.setParameter("cadenceType", cadenceType);
        query.setInteger("startCadence", startCadence);
        query.setInteger("endCadence", endCadence);
        query.setInteger("ccdModule", ccdModule);
        query.setInteger("ccdOutput", ccdOutput);

        List<GapCollateralPixel> list = list(query);

        return list;
    }

    /**
     * Retrieves {@link GapCollateralPixel}s for the specified cadence range.
     * 
     * @param cadenceType the cadence type.
     * @param startCadence the starting cadence number.
     * @param endCadence the ending cadence number.
     * @return a non-{@code null} list of {@link GapCollateralPixel} objects.
     * @throws HibernateException if there were problems with the database
     * transaction.
     */
    public List<GapCollateralPixel> retrieveGapCollateralPixel(
        CadenceType cadenceType, int startCadence, int endCadence) {

        Query query = getSession().createQuery(
            "from GapCollateralPixel where " + "cadenceType = :cadenceType "
                + "and cadenceNumber >= :startCadence "
                + "and cadenceNumber <= :endCadence "
                + "order by cadenceNumber asc, " + "ccdModule asc, "
                + "ccdOutput asc, " + "pixelType asc, " + "ccdRowOrColumn asc");
        query.setParameter("cadenceType", cadenceType);
        query.setInteger("startCadence", startCadence);
        query.setInteger("endCadence", endCadence);

        List<GapCollateralPixel> list = list(query);

        return list;
    }
}
