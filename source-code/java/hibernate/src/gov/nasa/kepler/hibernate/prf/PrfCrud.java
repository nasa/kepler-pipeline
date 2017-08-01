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

package gov.nasa.kepler.hibernate.prf;

import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.mc.AbstractCadenceBlob;

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
public class PrfCrud extends AbstractCrud {

    /**
     * For mock use only.
     */
    public PrfCrud() {
        super(null);
    }

    /**
     * Creates a new PrfCrud object with the specified database service.
     * 
     * @param databaseService the DatabaseService to use for the operations.
     */
    public PrfCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    public void create(PrfConvergence convergence) {
        getSession().save(convergence);
    }

    public boolean didLastPipelineConverge() {
        String qStr = " from PrfConvergence pc1 where "
            + "   pc1.task.pipelineInstanceNode in "
            + "  (select pitask.pipelineInstanceNode from PipelineTask pitask "
            + "    where pitask.id in "
            + "    (select max(pc2.task.id) from PrfConvergence pc2) ";

        Query q = getSession().createQuery(qStr);
        List<PrfConvergence> convergence = list(q);
        if (convergence.isEmpty()) {
            throw new IllegalStateException(
                "PrcConvergence instances not found.");
        }
        for (PrfConvergence pc : convergence) {
            if (!pc.isConverged()) {
                return false;
            }
        }
        return true;
    }

    public void create(AbstractCadenceBlob fpgPrfBlobMetaData) {
        if (!(fpgPrfBlobMetaData instanceof FpgGeometryBlobMetadata
            || fpgPrfBlobMetaData instanceof FpgImportBlobMetadata
            || fpgPrfBlobMetaData instanceof FpgResultsBlobMetadata || fpgPrfBlobMetaData instanceof PrfBlobMetadata)) {
            throw new IllegalArgumentException(
                "Not one of the prf/fpg blob classes.");
        }
        getSession().save(fpgPrfBlobMetaData);
    }

    public void create(FpgGeometryBlobMetadata geometryBlobMeta) {
        getSession().save(geometryBlobMeta);
    }

    public void deleteGeometryBlob(FpgGeometryBlobMetadata geometryBlobMeta) {
        getSession().delete(geometryBlobMeta);
    }

    public FpgGeometryBlobMetadata retrieveLastGeometryBlobMetadata() {
        String queryString = "from FpgGeometryBlobMetadata g1 where "
            + " g1.pipelineTaskId = ( select max(g2.pipelineTaskId) from FpgGeometryBlobMetadata g2)";
        Query q = getSession().createQuery(queryString);
        FpgGeometryBlobMetadata rv = uniqueResult(q);
        return rv;
    }

    public List<FpgGeometryBlobMetadata> retrieveGeometryBlobMetadata(
        int startCadence, int endCadence) {
        String queryString = "from FpgGeometryBlobMetadata where "
            + "endCadence >= :paramStartCadence and startCadence <= :paramEndCadence ";

        Query q = getSession().createQuery(queryString);
        q.setParameter("paramStartCadence", startCadence);
        q.setParameter("paramEndCadence", endCadence);

        List<FpgGeometryBlobMetadata> rv = list(q);
        return rv;
    }

    public FpgGeometryBlobMetadata retrieveGeometryBlobMetadata(
        long taskCreatorId) {
        return uniqueResult(getSession().createCriteria(
                FpgGeometryBlobMetadata.class)
                .add(Restrictions.eq("pipelineTaskId", taskCreatorId)));
    }

    public void create(FpgImportBlobMetadata importMeta) {
        getSession().save(importMeta);
    }

    public void create(FpgResultsBlobMetadata resultsMeta) {
        getSession().save(resultsMeta);
    }

    public FpgImportBlobMetadata retrieveImportBlobMetadata(long taskCreatorId) {
        return uniqueResult(getSession().createCriteria(
                FpgImportBlobMetadata.class)
                .add(Restrictions.eq("pipelineTaskId", taskCreatorId)));
    }

    public FpgResultsBlobMetadata retrieveResultsBlobMetadata(long taskCreatorId) {
        return uniqueResult(getSession().createCriteria(
                FpgResultsBlobMetadata.class)
                .add(Restrictions.eq("pipelineTaskId", taskCreatorId)));

    }

    /**
     * Create a List of {@link PrfBlobMetadata} instances in the database.
     * 
     * @param prfBlobMetadataList
     */
    public void createPrfBlobMetadata(List<PrfBlobMetadata> prfBlobMetadataList) {
        if (prfBlobMetadataList == null) {
            throw new NullPointerException("prfBlobMetadataList is null");
        }
        if (prfBlobMetadataList.isEmpty()) {
            throw new IllegalArgumentException("prfBlobMetadata is empty");
        }
        for (PrfBlobMetadata metadata : prfBlobMetadataList) {
            createPrfBlobMetadata(metadata);
        }
    }

    /**
     * Create a {@link PrfBlobMetadata} instance in the database.
     * 
     * @param prfBlobMetadata
     */
    public void createPrfBlobMetadata(PrfBlobMetadata prfBlobMetadata) {
        if (prfBlobMetadata == null) {
            throw new NullPointerException("prfBlobMetadata is null");
        }
        getSession().save(prfBlobMetadata);
    }

    /**
     * Delete a {@link PrfBlobMetadata} instance from the database.
     * 
     * @param prfBlobMetadata
     */
    public void delete(PrfBlobMetadata prfBlobMetadata) {
        if (prfBlobMetadata == null) {
            throw new NullPointerException("prfBlobMetadata is null");
        }
        getSession().delete(prfBlobMetadata);
    }

    /**
     * Retrieve metadata for all collection blobs covered by the specified
     * cadence range for the specified module/output.
     * 
     */
    public List<PrfBlobMetadata> retrievePrfBlobMetadata(int ccdModule,
        int ccdOutput, int startCadence, int endCadence) {

        if (startCadence > endCadence) {
            throw new IllegalArgumentException(
                "start cadence is greater than end cadence");
        }

        Criteria query = getSession().createCriteria(PrfBlobMetadata.class);
        query.add(Restrictions.eq("ccdModule", ccdModule));
        query.add(Restrictions.eq("ccdOutput", ccdOutput));
        query.add(Restrictions.ge("endCadence", startCadence));
        query.add(Restrictions.le("startCadence", endCadence));
        query.addOrder(Order.asc("startCadence"));
        List<PrfBlobMetadata> list = list(query);
        return list;
    }
}
