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

package gov.nasa.kepler.pi.parameters;

import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Utility methods for {@link Parameters} classes
 * 
 * @author tklaus
 *
 */
public class ParametersUtils {
    private static final Log log = LogFactory.getLog(ParametersUtils.class);

    /** Singleton pattern, all methods are static */
    private ParametersUtils() {
    }

    /**
     * Populate the specified {@link Parameters} class with values from the
     * specified file.  The file is assumed to be in .properties format (see
     * {@link Properties}.load for format details.
     * 
     * @param file
     * @param parametersClass
     * @throws IOException 
     */
    public static Parameters importParameters(File file, Class<? extends Parameters> parametersClass) throws IOException{
        FileReader reader = new FileReader(file);
        Properties propsFile = new Properties();
        
        log.info("Importing " + parametersClass.getSimpleName() + " from: " + file.getName());
        
        propsFile.load(reader);

        reader.close();
        
        Map<String, String> propsMap = new HashMap<String, String>();
        Set<Object> keys = propsFile.keySet();
        for (Object key : keys) {
            Object value = propsFile.get(key);
            propsMap.put((String)key, (String)value);
        }

        BeanWrapper<Parameters> paramsBean = new BeanWrapper<Parameters>(parametersClass);
        paramsBean.setProps(propsMap);

        return paramsBean.getInstance();
    }
    
    public static void exportParameters(File file, Parameters parametersBean) throws IOException{
        BeanWrapper<Parameters> paramsBean = new BeanWrapper<Parameters>(parametersBean);

        Map<String, String> props = paramsBean.getProps();
        Properties propsFile = new Properties();
        
        for (String propName : props.keySet()) {
            String propValue = props.get(propName);
            if(propValue == null){
                // Hashtable (used by Properties) doesn't allow null values
                propValue = ""; 
            }
            propsFile.put(propName, propValue);
        }

        log.info("Exporting " + parametersBean.getClass().getSimpleName() + " to: " + file.getName());
        
        FileWriter propsFileWriter = new FileWriter(file);
        propsFile.store(propsFileWriter, "exported by ParametersUtils");
        propsFileWriter.close();
    }
}
