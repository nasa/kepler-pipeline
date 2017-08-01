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

package gov.nasa.kepler.ui.ops.parameters;

import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.ui.common.ClasspathUtils;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

/**
 * Cache that holds {@link ClassWrapper<Parameters>} objects for all
 * implementations of the {@link Parameters} interface found on the 
 * classpath.
 * 
 * @author tklaus
 *
 */
public class ParametersClassCache {

    private static List<ClassWrapper<Parameters>> cache = new LinkedList<ClassWrapper<Parameters>>();
    private static boolean initialized = false;
    
    private ParametersClassCache() {
    }

    /**
     * Return a cached List of all classes that implement the {@link Parameters}
     * interface found on the classpath.
     * 
     * @return
     * @throws Exception 
     */
    public static synchronized List<ClassWrapper<Parameters>> getCache() throws Exception{
        
        if(!initialized){
            initializeCache();
        }
        
        return cache;
    }

    /**
     * Return a cached List of all classes that implement the {@link Parameters}
     * interface and are sub-classes for the specified filter class
     * found on the classpath.
     * 
     * @param filter
     * @return
     * @throws Exception 
     */
    public static synchronized List<ClassWrapper<Parameters>> getCache(Class<? extends Parameters> filter) throws Exception{
        
        if(!initialized){
            initializeCache();
        }
        
        List<ClassWrapper<Parameters>> filteredCache = new LinkedList<ClassWrapper<Parameters>>();
        
        for (ClassWrapper<Parameters> classWrapper : cache) {
            if(filter.isAssignableFrom(classWrapper.getClazz())){
                filteredCache.add(classWrapper);
            }
        }
        
        return filteredCache;
    }
    
    private static synchronized void initializeCache() throws Exception{
        cache = new LinkedList<ClassWrapper<Parameters>>();
        
        ClasspathUtils classpathUtils = new ClasspathUtils();
        Set<Class<? extends Parameters>> detectedClasses = classpathUtils.scanForInterfaceImpl(Parameters.class);

        for (Class<? extends Parameters> clazz : detectedClasses) {
            ClassWrapper<Parameters> wrapper = new ClassWrapper<Parameters>(clazz);
            cache.add(wrapper);
        }
        
        Collections.sort(cache);
    }
}
