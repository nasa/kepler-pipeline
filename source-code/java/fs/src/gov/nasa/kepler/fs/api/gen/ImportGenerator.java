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

package gov.nasa.kepler.fs.api.gen;

import java.util.Comparator;
import java.util.Set;
import java.util.TreeSet;

/**
 * Given a set of classes generate the import statements that are needed by
 * a Java source file.
 * 
 * @author Sean McCauliff
 *
 */
class ImportGenerator {

    private Set<Class<?>> importClasses = new TreeSet<Class<?>>(new ClassNameComparator());
    
    ImportGenerator() {
        
    }
    
    
    void addClass(Class<?> c) {
        if (c == null) {
            return;
        }
        if (c.isArray()) {
            importClasses.add(c.getComponentType());           
        } else {
            importClasses.add(c);
        }

    }
    
    void addClass(Class<?>[] c) {
        if (c == null) {
            return;
        }
        for (Class<?> blah : c) { 
            addClass(blah);
        }
    }
    
    /**
     * @param filter Don't generate import statements for the specified package.
     * @return The current import list or the empty string if there are none.
     */
    String imports(Package filter) {
    	
    	Set<String> packageNames = new TreeSet<String>();

        for (Class<?> c : importClasses) {
            if (c.getPackage() == null) {
                continue;
            }
            if (c.getPackage().getName().equals("java.lang")) {
                continue;
            }
            if (c.getPackage() == filter) {
                continue;
            }
            
            packageNames.add(c.getPackage().getName());

        }
        
        StringBuilder bldr = new StringBuilder();
        for (String packageName : packageNames) {
	        bldr.append("import ").append(packageName).append(".*;");
	        bldr.append('\n');
        }
        return bldr.toString();
    }
    
    private static class ClassNameComparator implements Comparator<Class<?>> {

        public int compare(Class<?> o1, Class<?> o2) {
            return o1.getName().compareTo(o2.getName());
        }
        
    }
}
