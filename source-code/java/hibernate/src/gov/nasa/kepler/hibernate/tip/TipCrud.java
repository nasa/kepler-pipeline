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

package gov.nasa.kepler.hibernate.tip;

import gov.nasa.kepler.hibernate.AbstractCrud;

import java.util.List;

import org.hibernate.Criteria;
import org.hibernate.HibernateException;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Restrictions;

/**
 * Create, read, update, and delete operations on the TIP classes.
 * 
 * @author Forrest Girouard
 */
public class TipCrud extends AbstractCrud {

    /**
     * Create a List of {@link TipBlobMetadata} instances in the database.
     * 
     * @param tipBlobMetadataList
     */
    public void createTipBlobMetadata(List<TipBlobMetadata> tipBlobMetadataList) {
        if (tipBlobMetadataList == null) {
            throw new NullPointerException("tipBlobMetadataList is null");
        }
        if (tipBlobMetadataList.isEmpty()) {
            throw new IllegalArgumentException("tipBlobMetadataList is empty");
        }
        for (TipBlobMetadata metadata : tipBlobMetadataList) {
            createTipBlobMetadata(metadata);
        }
    }

    /**
     * Create a {@link TipBlobMetadata} instance in the database.
     * 
     * @param tipBlobMetadata
     */
    public void createTipBlobMetadata(TipBlobMetadata tipBlobMetadata) {
        if (tipBlobMetadata == null) {
            throw new NullPointerException("tipBlobMetadata is null");
        }
        getSession().save(tipBlobMetadata);
    }

    /**
     * Retrieves all {@link TipBlobMetadata} for the given sky group.
     * 
     * @param skyGroupId the Sky Group ID
     * @return return a non-{@code null} list of {@link TipBlobMetadata}s sorted
     * by {@code createTime}
     * @throws HibernateException if there were problems accessing the database
     */
    public List<TipBlobMetadata> retrieveTipBlobMetadata(int skyGroupId) {

        Criteria query = getSession().createCriteria(TipBlobMetadata.class);
        query.add(Restrictions.eq("skyGroupId", skyGroupId));
        query.addOrder(Order.asc("createTime"));

        List<TipBlobMetadata> list = list(query);

        return list;
    }

    /**
     * Retrieves all {@link TipBlobMetadata} for the given sky group.
     * 
     * @param skyGroupId the Sky Group ID
     * @param createTime import time of blob
     * @return return a {@link TipBlobMetadata} for the given sky group and
     * import time
     * @throws HibernateException if there were problems accessing the database
     */
    public TipBlobMetadata retrieveTipBlobMetadata(int skyGroupId,
        long createTime) {

        Criteria query = getSession().createCriteria(TipBlobMetadata.class);
        query.add(Restrictions.eq("skyGroupId", skyGroupId));
        query.add(Restrictions.eq("createTime", createTime));

        TipBlobMetadata metadata = uniqueResult(query);

        return metadata;
    }
}
