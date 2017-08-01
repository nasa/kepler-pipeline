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

import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;

import java.util.LinkedList;
import java.util.List;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.criterion.Order;

import com.google.common.collect.ImmutableList;

public class ConfigMapCrud extends AbstractCrud {

    public ConfigMapCrud() {
    }

    public ConfigMapCrud(DatabaseService dbs) {
        super(dbs);
    }

    public void createConfigMap(ConfigMap configMap) {
        getSession().save(configMap);
    }

    public List<ConfigMap> retrieveConfigMaps(List<Integer> scConfigIds) {
        if (scConfigIds.size() == 0) {
            return ImmutableList.of();
        }

        StringBuilder bldr = new StringBuilder();
        bldr.append("from ConfigMap where scConfigId in (");
        for (int id : scConfigIds) {
            bldr.append(id)
                .append(',');
        }
        bldr.setLength(bldr.length() - 1);
        bldr.append(')');
        bldr.append(" order by scConfigId ");

        Query q = getSession().createQuery(bldr.toString());
        return list(q);
    }

    public ConfigMap retrieveConfigMap(int scConfigId) {
        Query query = getSession().createQuery(
            "from ConfigMap where " + "scConfigId = :scConfigId");
        query.setParameter("scConfigId", scConfigId);

        return uniqueResult(query);
    }

    public List<ConfigMap> retrieveAllConfigMaps() {
        Criteria query = getSession().createCriteria(ConfigMap.class);
        query.addOrder(Order.desc("scConfigId"));
        List<ConfigMap> results = list(query);

        return results;
    }

    public ConfigMap retrieveConfigMap(double mjd) {
        Query query = getSession().createQuery(
            "from ConfigMap where " + "mjd <= :mjd " + "order by mjd desc");
        query.setParameter("mjd", mjd);

        List<ConfigMap> list = list(query);

        return list.get(0);
    }

    public List<ConfigMap> retrieveConfigMaps(double startMjd, double endMjd) {
        List<ConfigMap> configMaps = new LinkedList<ConfigMap>();

        Query query = getSession().createQuery(
            "from ConfigMap where " + "mjd <= :mjd " + "order by mjd desc");
        query.setParameter("mjd", endMjd);

        List<ConfigMap> results = list(query);

        for (ConfigMap configMap : results) {
            // Always return at least one config map.
            configMaps.add(0, configMap);

            if (configMap.getMjd() <= startMjd) {
                break;
            }
        }

        return configMaps;
    }
}
