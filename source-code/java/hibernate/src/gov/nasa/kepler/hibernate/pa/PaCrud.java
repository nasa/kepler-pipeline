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

package gov.nasa.kepler.hibernate.pa;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.spiffy.common.collect.ListChunkIterator;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Restrictions;

/**
 * 
 * @author Forrest Girouard (fgirouard)
 * 
 */
public class PaCrud extends AbstractCrud implements PaBlobFactoryInterface {

    /**
     * For mock use only.
     */
    public PaCrud() {
        super(null);
    }

    /**
     * Creates a new PaCrud object with the specified database service.
     * 
     * @param databaseService the DatabaseService to use for the operations.
     */
    public PaCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    /**
     * Create a List of {@link BackgroundBlobMetadata} instances in the
     * database.
     * 
     * @param backgroundBlobMetadataList
     */
    public void createBackgroundBlobMetadata(
        List<BackgroundBlobMetadata> backgroundBlobMetadataList) {
        if (backgroundBlobMetadataList == null) {
            throw new NullPointerException("backgroundBlobMetadataList is null");
        }
        if (backgroundBlobMetadataList.isEmpty()) {
            throw new IllegalArgumentException(
                "backgroundBlobMetadataList is empty");
        }
        for (BackgroundBlobMetadata metadata : backgroundBlobMetadataList) {
            createBackgroundBlobMetadata(metadata);
        }
    }

    /**
     * Create a {@link BackgroundBlobMetadata} instance in the database.
     * 
     * @param backgroundBlobMetadata
     */
    public void createBackgroundBlobMetadata(
        BackgroundBlobMetadata backgroundBlobMetadata) {
        if (backgroundBlobMetadata == null) {
            throw new NullPointerException("backgroundBlobMetadata is null");
        }
        getSession().save(backgroundBlobMetadata);
    }

    /**
     * Delete a {@link BackgroundBlobMetadata} instance from the database.
     * 
     * @param backgroundBlobMetadata
     */
    public void delete(BackgroundBlobMetadata backgroundBlobMetadata) {
        if (backgroundBlobMetadata == null) {
            throw new NullPointerException("backgroundBlobMetadata is null");
        }
        getSession().delete(backgroundBlobMetadata);
    }

    /**
     * Retrieve metadata for all background coefficient blobs covered by the
     * specified cadence range for the specified module/output.
     * 
     */
    public List<BackgroundBlobMetadata> retrieveBackgroundBlobMetadata(
        int ccdModule, int ccdOutput, int startCadence, int endCadence) {

        if (startCadence > endCadence) {
            throw new IllegalArgumentException(
                "start cadence is greater than end cadence");
        }

        Criteria query = getSession().createCriteria(
            BackgroundBlobMetadata.class);
        query.add(Restrictions.eq("ccdModule", ccdModule));
        query.add(Restrictions.eq("ccdOutput", ccdOutput));
        query.add(Restrictions.ge("endCadence", startCadence));
        query.add(Restrictions.le("startCadence", endCadence));
        query.addOrder(Order.asc("startCadence"));
        List<BackgroundBlobMetadata> list = list(query);
        return list;
    }

    /**
     * Create a List of {@link MotionBlobMetadata} instances in the database.
     * 
     * @param motionBlobMetadataList
     */
    public void createMotionBlobMetadata(
        List<MotionBlobMetadata> motionBlobMetadataList) {
        if (motionBlobMetadataList == null) {
            throw new NullPointerException("motionBlobMetadataList is null");
        }
        if (motionBlobMetadataList.isEmpty()) {
            throw new IllegalArgumentException(
                "motionBlobMetadataList is empty");
        }
        for (MotionBlobMetadata metadata : motionBlobMetadataList) {
            createMotionBlobMetadata(metadata);
        }
    }

    /**
     * Create a {@link MotionBlobMetadata} instance in the database.
     * 
     * @param motionBlobMetadataList
     */
    public void createMotionBlobMetadata(MotionBlobMetadata motionBlobMetadata) {
        if (motionBlobMetadata == null) {
            throw new NullPointerException("motionBlobMetadata is null");
        }
        getSession().save(motionBlobMetadata);
    }

    /**
     * Create a {@link FfiMotionBlobMetadata} instance in the database.
     * 
     * @param motionBlobMetadataList
     */
    public void createFfiMotionBlobMetadata(
        FfiMotionBlobMetadata ffiMotionBlobMetadata) {
        if (ffiMotionBlobMetadata == null) {
            throw new NullPointerException("ffiMotionBlobMetadata is null");
        }
        getSession().save(ffiMotionBlobMetadata);
    }

    /**
     * Delete a {@link MotionBlobMetadata} instance from the database.
     * 
     * @param motionBlobMetadata
     */
    public void delete(MotionBlobMetadata motionBlobMetadata) {
        if (motionBlobMetadata == null) {
            throw new NullPointerException("motionBlobMetadata is null");
        }
        getSession().delete(motionBlobMetadata);
    }

    /**
     * Delete a {@link FfiMotionBlobMetadata} instance from the database.
     * 
     * @param motionBlobMetadata
     */
    public void delete(FfiMotionBlobMetadata ffiMotionBlobMetadata) {
        if (ffiMotionBlobMetadata == null) {
            throw new NullPointerException("ffiMotionBlobMetadata is null");
        }
        getSession().delete(ffiMotionBlobMetadata);
    }

    @Override
    public List<MotionBlobMetadata> retrieveMotionBlobMetadata(int ccdModule,
        int ccdOutput, int startCadence, int endCadence) {
        if (startCadence > endCadence) {
            throw new IllegalArgumentException(
                "start cadence is greater than end cadence");
        }

        Criteria query = getSession().createCriteria(MotionBlobMetadata.class);
        query.add(Restrictions.eq("ccdModule", ccdModule));
        query.add(Restrictions.eq("ccdOutput", ccdOutput));
        query.add(Restrictions.ge("endCadence", startCadence));
        query.add(Restrictions.le("startCadence", endCadence));
        query.addOrder(Order.asc("startCadence"));
        List<MotionBlobMetadata> list = list(query);
        return list;
    }

    @Override
    public List<FfiMotionBlobMetadata> retrieveFfiMotionBlobMetadata(
        int ccdModule, int ccdOutput, int startCadence, int endCadence) {
        if (startCadence > endCadence) {
            throw new IllegalArgumentException(
                "start cadence is greater than end cadence");
        }

        Criteria query = getSession().createCriteria(
            FfiMotionBlobMetadata.class);
        query.add(Restrictions.eq("ccdModule", ccdModule));
        query.add(Restrictions.eq("ccdOutput", ccdOutput));
        query.add(Restrictions.ge("endCadence", startCadence));
        query.add(Restrictions.le("startCadence", endCadence));
        query.addOrder(Order.asc("startCadence"));
        List<FfiMotionBlobMetadata> list = list(query);
        return list;
    }

    /**
     * Create a {@link UncertaintyBlobMetadata} instance in the database.
     * 
     * @param uncertaintyBlobMetadataList
     */
    public void createUncertaintyBlobMetadata(
        UncertaintyBlobMetadata uncertaintyBlobMetadata) {

        if (uncertaintyBlobMetadata == null) {
            throw new NullPointerException("uncertaintyBlobMetadata is null");
        }
        getSession().save(uncertaintyBlobMetadata);
    }

    /**
     * Delete a {@link UncertaintyBlobMetadata} instance from the database.
     * 
     * @param uncertaintyBlobMetadata
     */
    public void delete(UncertaintyBlobMetadata uncertaintyBlobMetadata) {

        if (uncertaintyBlobMetadata == null) {
            throw new NullPointerException("uncertaintyBlobMetadata is null");
        }
        getSession().delete(uncertaintyBlobMetadata);
    }

    /**
     * Retrieve metadata for all PA uncertainty blobs covered by the specified
     * cadence range for the specified module/output.
     * 
     */
    public List<UncertaintyBlobMetadata> retrieveUncertaintyBlobMetadata(
        int ccdModule, int ccdOutput, CadenceType cadenceType,
        int startCadence, int endCadence) {

        if (startCadence > endCadence) {
            throw new IllegalArgumentException(
                "start cadence is greater than end cadence");
        }

        Criteria query = getSession().createCriteria(
            UncertaintyBlobMetadata.class);
        query.add(Restrictions.eq("ccdModule", ccdModule));
        query.add(Restrictions.eq("ccdOutput", ccdOutput));
        query.add(Restrictions.eq("cadenceType", cadenceType));
        query.add(Restrictions.ge("endCadence", startCadence));
        query.add(Restrictions.le("startCadence", endCadence));
        query.addOrder(Order.asc("startCadence"));
        List<UncertaintyBlobMetadata> list = list(query);
        return list;
    }

    /**
     * Create a {@link TargetAperture} instance in the database.
     */
    public void createTargetAperture(TargetAperture targetAperture) {

        if (targetAperture == null) {
            throw new NullPointerException("targetAperture can't be null");
        }
        getSession().save(targetAperture);
    }

    /**
     * Create a {@link TargetAperture} instance in the database.
     */
    public void createTargetApertures(List<TargetAperture> targetApertures) {

        if (targetApertures == null) {
            throw new NullPointerException("targetApertures can't be null");
        }
        for (TargetAperture targetAperture : targetApertures) {
            getSession().save(targetAperture);
        }
    }

    /**
     * Delete a {@link TargetAperture} instance from the database.
     */
    public void deleteTargetAperture(TargetAperture targetAperture) {

        if (targetAperture == null) {
            throw new NullPointerException("targetAperture can't be null");
        }
        getSession().delete(targetAperture);
    }

    /**
     * Delete {@link TargetAperture} instances from the database.
     */
    public void deleteTargetApertures(List<TargetAperture> targetApertures) {

        if (targetApertures == null) {
            throw new NullPointerException("targetApertures can't be null");
        }
        for (TargetAperture targetAperture : targetApertures) {
            deleteTargetAperture(targetAperture);
        }
    }

    /**
     * Retrieve apertures for all PA targets covered by the specified cadence
     * range for the specified module/output and target table.
     * 
     */
    public List<TargetAperture> retrieveTargetApertures(
        TargetTable targetTable, int ccdModule, int ccdOutput) {

        Criteria query = getSession().createCriteria(TargetAperture.class);
        query.add(Restrictions.eq("targetTable", targetTable));
        query.add(Restrictions.eq("ccdModule", ccdModule));
        query.add(Restrictions.eq("ccdOutput", ccdOutput));

        List<TargetAperture> list = list(query);
        return list;
    }

    public List<TargetAperture> retrieveTargetApertures(
        PipelineTask pipelineTask) {
        Query query = getSession().createQuery(
            "from TargetAperture where " + "pipelineTask = :pipelineTask");
        query.setParameter("pipelineTask", pipelineTask);

        List<TargetAperture> list = list(query);

        return list;
    }

    /**
     * Retrieve apertures for given PA target covered by the specified cadence
     * range for the specified module/output and target table.
     * 
     */
    public List<TargetAperture> retrieveTargetApertures(
        TargetTable targetTable, int ccdModule, int ccdOutput,
        List<Integer> keplerIds) {

        ListChunkIterator<Integer> it = new ListChunkIterator<Integer>(
            keplerIds.iterator(), MAX_EXPRESSIONS);

        List<TargetAperture> rv = new ArrayList<TargetAperture>();
        while (it.hasNext()) {
            List<Integer> keplerIdChunk = it.next();
            Criteria query = getSession().createCriteria(TargetAperture.class);
            query.add(Restrictions.eq("targetTable", targetTable));
            query.add(Restrictions.eq("ccdModule", ccdModule));
            query.add(Restrictions.eq("ccdOutput", ccdOutput));
            query.add(Restrictions.in("keplerId", keplerIdChunk));

            List<TargetAperture> list = list(query);
            rv.addAll(list);
        }
        return rv;
    }
}
