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

package gov.nasa.kepler.hibernate.cm;

import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.pi.ModelCrud;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.hibernate.Query;

/**
 * Contains {@link KicOverrideModel} data access operations.
 * 
 * @author Miles Cote
 * 
 */
public class KicOverrideModelCrud extends AbstractCrud implements
    ModelCrud<KicOverrideModel> {

    public KicOverrideModelCrud() {
        this(null);
    }

    public KicOverrideModelCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    @Override
    public String getType() {
        return "KIC_OVERRIDE";
    }

    @Override
    public void create(KicOverrideModel model) {
        List<KicOverride> kicOverrides = create(model.getKicOverrides());

        KicOverrideModel kicOverrideModelToCreate = new KicOverrideModel(
            model.getRevision(), kicOverrides);
        getSession().save(kicOverrideModelToCreate);
    }

    /**
     * Creates the {@link KicOverride}s in the database. If a
     * {@link KicOverride} already exists in the database, then it is not
     * re-created.
     * 
     * @param kicOverrides
     * @return new {@link List} of {@link KicOverride}s which should be used in
     * place of the input {@link List} {@link KicOverride}s.
     */
    private List<KicOverride> create(List<KicOverride> kicOverrides) {
        Map<KicOverride, KicOverride> kicOverrideKeyToKicOverrideValue = new HashMap<KicOverride, KicOverride>();
        for (KicOverride kicOverride : retrieveAllKicOverrides()) {
            kicOverrideKeyToKicOverrideValue.put(kicOverride, kicOverride);
        }

        List<KicOverride> kicOverridesToReturn = new ArrayList<KicOverride>();
        for (KicOverride kicOverride : kicOverrides) {
            KicOverride kicOverrideValue = kicOverrideKeyToKicOverrideValue.get(kicOverride);
            if (kicOverrideValue == null) {
                kicOverrideValue = kicOverride;
                kicOverrideKeyToKicOverrideValue.put(kicOverride, kicOverride);
                getSession().save(kicOverride);
            }

            kicOverridesToReturn.add(kicOverrideValue);
        }

        return kicOverridesToReturn;
    }

    private List<KicOverride> retrieveAllKicOverrides() {
        Query query = getSession().createQuery("from KicOverride");

        List<KicOverride> list = list(query);

        return list;
    }

    @Override
    public KicOverrideModel retrieve(int revision) {
        KicOverrideModel model = KicOverrideModelCache.getKicOverrideModel(revision);
        return model;
    }
    
    KicOverrideModel retrieveInternal(int revision) {
        Query q = getSession().createQuery(
            "from KicOverrideModel where " + "revision = :revision ");
        q.setParameter("revision", revision);

        KicOverrideModel model = uniqueResult(q);

        return model;
    }

    @Override
    public void delete(KicOverrideModel model) {
        getSession().delete(model);
    }

}
