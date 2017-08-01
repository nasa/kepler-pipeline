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

package gov.nasa.kepler.mc.configmap;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.ConfigMapEntry;
import gov.nasa.kepler.hibernate.dr.ConfigMapCrud;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.RclcPixelLogCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

/**
 * 
 * @author Forrest Girouard
 * 
 */
public class ConfigMapOperations {

    private ConfigMapCrud configMapCrud;

    public ConfigMapOperations() {
        configMapCrud = new ConfigMapCrud();
    }

    public ConfigMap retrieveConfigMap(int scConfigId) {
        gov.nasa.kepler.hibernate.dr.ConfigMap map = configMapCrud.retrieveConfigMap(scConfigId);
        ConfigMap configMap = new ConfigMap(map.getScConfigId(), map.getMjd());
        for (Map.Entry<String, String> entry : map.getMap().entrySet()) {
            configMap.add(new ConfigMapEntry(entry.getKey(), entry.getValue()));
        }
        return configMap;
    }

    public List<ConfigMap> retrieveConfigMaps(double startMjd, double endMjd) {

        List<gov.nasa.kepler.hibernate.dr.ConfigMap> hibernateConfigMaps = 
            configMapCrud.retrieveConfigMaps(startMjd, endMjd);
        
        return hibernateConfigMapsToPersistableConfigMaps(hibernateConfigMaps);
    }

    public List<ConfigMap> retrieveConfigMapsUsingPixelLog(double startMjd,
        double endMjd) {

        return retrieveConfigMapsUsingPixelLog(new LogCrud(), null, startMjd,
            endMjd);
    }

    public List<ConfigMap> retrieveConfigMapsUsingRcLcPixelLog(double startMjd,
        double endMjd) {

        return retrieveConfigMapsUsingPixelLog(new RclcPixelLogCrud(),
            CadenceType.LONG, startMjd, endMjd);
    }
    
    public List<ConfigMap> retrieveAllConfigMaps(CadenceType cadenceType,
        double startMjd, double endMjd) {

        List<Integer> allList = retrieveAllConfigMapIds(cadenceType, startMjd,
            endMjd);
        
        List<gov.nasa.kepler.hibernate.dr.ConfigMap> hibernateConfigMaps = 
            configMapCrud.retrieveConfigMaps(allList);

        return hibernateConfigMapsToPersistableConfigMaps(hibernateConfigMaps);
    }
    
    public List<ConfigMap> retrieveConfigMaps(TargetTable ttable) {
        List<Integer> configMapIdList = new LogCrud().retrieveConfigMapIds(ttable.getType(), ttable.getExternalId());
        List<gov.nasa.kepler.hibernate.dr.ConfigMap> hibernateConfigMaps = 
            configMapCrud.retrieveConfigMaps(configMapIdList);
        return hibernateConfigMapsToPersistableConfigMaps(hibernateConfigMaps);
    }

    private List<ConfigMap> retrieveConfigMapsUsingPixelLog(LogCrud logCrud,
        CadenceType cadenceType, double startMjd, double endMjd) {
        List<Integer> ids = logCrud.retrieveConfigMapIds(cadenceType, startMjd,
            endMjd);
        List<gov.nasa.kepler.hibernate.dr.ConfigMap> hibernateConfigMaps = 
            configMapCrud.retrieveConfigMaps(ids);
    
        return hibernateConfigMapsToPersistableConfigMaps(hibernateConfigMaps);
    }

    private List<Integer> retrieveAllConfigMapIds(CadenceType cadenceType,
        double startMjd, double endMjd) {
        List<Integer> allList = new ArrayList<Integer>();
        
        Set<Integer> allSet = new TreeSet<Integer>();
        List<Integer> ids = new LogCrud().retrieveConfigMapIds(cadenceType,
            startMjd, endMjd);
        allSet.addAll(ids);
        if (cadenceType == CadenceType.LONG) {
            ids = new RclcPixelLogCrud().retrieveConfigMapIds(cadenceType,
                startMjd, endMjd);
            allSet.addAll(ids);
        }
        for (Integer id : allSet) {
            allList.add(id);
        }
        
        return allList;
    }

    private List<ConfigMap> hibernateConfigMapsToPersistableConfigMaps(
        List<gov.nasa.kepler.hibernate.dr.ConfigMap> hibernateConfigMaps) {
        List<ConfigMap> configMaps = new ArrayList<ConfigMap>();
        if (hibernateConfigMaps != null && hibernateConfigMaps.size() > 0) {
            for (gov.nasa.kepler.hibernate.dr.ConfigMap map : hibernateConfigMaps) {
                ConfigMap configMap = new ConfigMap(map.getScConfigId(),
                    map.getMjd());
                for (Map.Entry<String, String> entry : map.getMap().entrySet()) {
                    configMap.add(new ConfigMapEntry(entry.getKey(),
                        entry.getValue()));
                }
                configMaps.add(configMap);
            }
        }
        return configMaps;
    }

}
