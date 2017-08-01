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

package gov.nasa.kepler.hibernate.pdc;

import static com.google.common.base.Preconditions.checkNotNull;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.spiffy.common.collect.ListChunkIterator;

import java.util.Collection;
import java.util.List;

import org.hibernate.Query;

import com.google.common.collect.Lists;

/**
 * Create, read, update, and delete (CRUD) operations for PDC.
 * 
 * @author Forrest Girouard
 */
public class PdcCrud extends AbstractCrud {

    public PdcCrud() {
    }

    public void createCbvBlobMetadata(CbvBlobMetadata cbvBlobMetadata) {
        checkNotNull(cbvBlobMetadata, "cbvBlobMetadata cannot be null.");

        getSession().save(cbvBlobMetadata);
    }

    public void createPdcBlobMetadata(PdcBlobMetadata pdcBlobMetadata) {
        checkNotNull(pdcBlobMetadata, "pdcBlobMetadata cannot be null.");

        getSession().save(pdcBlobMetadata);
    }

    public void createPdcProcessingCharacteristics(
        PdcProcessingCharacteristics pdcProcessingCharacteristics) {
        checkNotNull(pdcProcessingCharacteristics,
            "pdcProcessingCharacteristics cannot be null");

        getSession().save(pdcProcessingCharacteristics);
    }

    public void createPdcProcessingCharacteristics(
        List<PdcProcessingCharacteristics> pdcProcessingCharacteristicsList) {
        checkNotNull(pdcProcessingCharacteristicsList,
            "pdcProcessingCharacteristicsList cannot be null");

        for (PdcProcessingCharacteristics pdcProcessingCharacteristics : pdcProcessingCharacteristicsList) {
            createPdcProcessingCharacteristics(pdcProcessingCharacteristics);
        }
    }

    public List<CbvBlobMetadata> retrieveCbvBlobMetadata(int ccdModule,
        int ccdOutput, CadenceType cadenceType, int startCadence, int endCadence) {

        Query query = getSession().createQuery(
            "from CbvBlobMetadata where " + "ccdModule = :ccdModule and "
                + "ccdOutput = :ccdOutput and "
                + "cadenceType = :cadenceType and "
                + "endCadence >= :startCadence and "
                + "startCadence <= :endCadence " + "order by startCadence asc");
        query.setParameter("ccdModule", ccdModule);
        query.setParameter("ccdOutput", ccdOutput);
        query.setParameter("cadenceType", cadenceType);
        query.setParameter("startCadence", startCadence);
        query.setParameter("endCadence", endCadence);

        List<CbvBlobMetadata> list = list(query);

        return list;
    }

    public List<PdcBlobMetadata> retrievePdcBlobMetadata(int ccdModule,
        int ccdOutput, CadenceType cadenceType, int startCadence, int endCadence) {

        Query query = getSession().createQuery(
            "from PdcBlobMetadata where " + "ccdModule = :ccdModule and "
                + "ccdOutput = :ccdOutput and "
                + "cadenceType = :cadenceType and "
                + "endCadence >= :startCadence and "
                + "startCadence <= :endCadence " + "order by startCadence asc");
        query.setParameter("ccdModule", ccdModule);
        query.setParameter("ccdOutput", ccdOutput);
        query.setParameter("cadenceType", cadenceType);
        query.setParameter("startCadence", startCadence);
        query.setParameter("endCadence", endCadence);

        List<PdcBlobMetadata> list = list(query);

        return list;
    }

    public List<PdcProcessingCharacteristics> retrievePdcProcessingCharacteristics(
        FluxType fluxType, CadenceType cadenceType, int keplerId,
        int startCadence, int endCadence) {

        Query query = getSession().createQuery(
            "from PdcProcessingCharacteristics where "
                + "fluxType = :fluxType and "
                + "cadenceType = :cadenceType and "
                + "keplerId = :keplerId and "
                + "endCadence >= :startCadence and "
                + "startCadence <= :endCadence " + "order by startCadence asc");
        query.setParameter("fluxType", fluxType);
        query.setParameter("cadenceType", cadenceType);
        query.setParameter("keplerId", keplerId);
        query.setParameter("startCadence", startCadence);
        query.setParameter("endCadence", endCadence);

        List<PdcProcessingCharacteristics> list = list(query);

        return list;
    }

    public List<PdcProcessingCharacteristics> retrievePdcProcessingCharacteristics(
        FluxType fluxType, CadenceType cadenceType,
        Collection<Integer> keplerIds, int startCadence, int endCadence) {

        List<PdcProcessingCharacteristics> allCharacteristics = Lists.newArrayListWithCapacity(keplerIds.size());
        ListChunkIterator<Integer> chunkIt = new ListChunkIterator<Integer>(
            keplerIds, 1000);
        for (List<Integer> keplerIdChunk : chunkIt) {
            Query query = getSession().createQuery(
                "from PdcProcessingCharacteristics where "
                    + "fluxType = :fluxType and "
                    + "cadenceType = :cadenceType and "
                    + "keplerId in (:keplerIds) and "
                    + "endCadence >= :startCadence and "
                    + "startCadence <= :endCadence "
                    + "order by pipelineTaskId asc");
            query.setParameter("fluxType", fluxType);
            query.setParameter("cadenceType", cadenceType);
            query.setParameterList("keplerIds", keplerIdChunk);
            query.setParameter("startCadence", startCadence);
            query.setParameter("endCadence", endCadence);

            List<PdcProcessingCharacteristics> list = list(query);
            allCharacteristics.addAll(list);
        }

        return allCharacteristics;
    }
}
