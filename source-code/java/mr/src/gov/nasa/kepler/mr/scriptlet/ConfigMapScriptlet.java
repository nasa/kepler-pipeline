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

package gov.nasa.kepler.mr.scriptlet;

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.hibernate.dr.ConfigMap;
import gov.nasa.kepler.hibernate.dr.ConfigMapCrud;
import gov.nasa.kepler.mr.MrTimeUtil;

import java.util.Date;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import net.sf.jasperreports.engine.JRDataSource;
import net.sf.jasperreports.engine.JRScriptletException;
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;

/**
 * This is the scriptlet class for the configuration map report.
 * 
 * @author Bill Wohler
 */
public class ConfigMapScriptlet extends BaseScriptlet {
    private static final Log log = LogFactory.getLog(ConfigMapScriptlet.class);

    public static final String REPORT_NAME_CONFIG_MAP = "config-map";
    public static final String REPORT_TITLE_CONFIG_MAP = "Spacecraft Configuration";

    private static ConfigMapCrud configMapCrud = new ConfigMapCrud();
    private ConfigMap configMap;

    @Override
    public void afterReportInit() throws JRScriptletException {
        super.afterReportInit();

        // Grab config map ID from parameters.
        expectIdParameter(true);
        if (getId() == INVALID_ID || getId() == UNINITIALIZED_ID) {
            return;
        }

        try {
            configMap = configMapCrud.retrieveConfigMap((int) getId());

            if (configMap == null) {
                String text = String.format(
                    "No spacecraft configuration found for ID %d.", getId());
                setErrorText(text);
                log.error(text);
                return;
            }
        } catch (HibernateException e) {
            String text = "Could not obtain spacecraft configuration with ID "
                + getId() + ": ";
            setErrorText(text + e + "\nCause: " + e.getCause());
            log.error(text, e);
            return;
        }
    }

    /**
     * Returns the timestamp of the selected config map. Returns an error string
     * if a config map has not yet been selected, or there was an error
     * accessing it.
     */
    public String getTimestamp() {
        if (configMap == null) {
            return "";
        }

        Date date = ModifiedJulianDate.mjdToDate(configMap.getMjd());
        return MrTimeUtil.dateFormatter()
            .format(date);
    }

    /**
     * Returns a {@link JRDataSource} which wraps all of the configuration map
     * elements.
     * 
     * @return a non-{@code null} data source.
     * @throws JRScriptletException if the data source could not be created.
     */
    public JRDataSource configMapDataSource() throws JRScriptletException {

        Set<KeyValuePair> configuration = new TreeSet<KeyValuePair>();
        if (configMap == null) {
            log.error("Should not be called if config map unavailable");
            return new JRBeanCollectionDataSource(configuration);
        }

        for (Map.Entry<String, String> entry : configMap.getMap()
            .entrySet()) {
            configuration.add(new KeyValuePair(entry.getKey(), entry.getValue()));
        }

        log.debug("Filling data source for " + configuration.size()
            + " config maps");

        return new JRBeanCollectionDataSource(configuration);
    }
}
