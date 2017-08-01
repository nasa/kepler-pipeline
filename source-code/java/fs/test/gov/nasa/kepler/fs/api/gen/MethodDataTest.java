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

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fs.api.FileStoreClient;

import java.io.File;
import java.lang.reflect.Method;
import java.util.List;

import org.junit.Test;

/**
 * @author Sean McCauliff
 *
 */
public class MethodDataTest {

    @Test
    public void printMethodSignatures() throws Exception  {
        Method[] methods = FileStoreClient.class.getMethods();
        for (Method m : methods) {
            MethodData mdata = new MethodData(m);
            System.out.println(mdata.signature());
        }
    }
    
    @Test
    public void compareToSignature() throws Exception {
        Method method = 
            String.class.getDeclaredMethod("compareTo", new Class[] { Object.class});
        MethodData mdata = new MethodData(method);
        assertEquals("public volatile int compareTo(Object object1)", mdata.signature());
    }
    
    @Test
    public void getBytesSignature() throws Exception {
        Method method =
            String.class.getDeclaredMethod("getBytes", new Class[] {String.class});
        MethodData mdata = new MethodData(method);
        assertEquals("public byte[] getBytes(String string1) throws UnsupportedEncodingException", mdata.signature());
    }
    
    @Test
    public void returnTypeDependencies() throws Exception {
     
        
        Method stringStuffMethod = 
            TestInterface.class.getDeclaredMethod("stringStuff", new Class<?>[] {});
        MethodData stringStuffMdata = new MethodData(stringStuffMethod);
        Class<?>[] depends = stringStuffMdata.methodReturnTypeDependences();
        assertTrue("Return type dependencies broken.", find(depends, List.class));
        assertTrue("Return type dependencies broken.", find(depends, String.class));
        
        
        Method getFilesMethod = 
            TestInterface.class.getDeclaredMethod("getFiles", new Class<?>[] {});
        MethodData getFilesMdata = new MethodData(getFilesMethod);
        depends = getFilesMdata.methodReturnTypeDependences();
        assertTrue("Return type dependencies broken.", find(depends, List.class));
        assertTrue("Return type dependencies broken.", find(depends, File.class));
        
        Method floatStuffMethod = 
            TestInterface.class.getDeclaredMethod("floatStuff", new Class<?>[] {});
        MethodData floatStuffMdata = new MethodData(floatStuffMethod);
        depends = floatStuffMdata.methodReturnTypeDependences();
        assertTrue("Return type dependencies broken.", find(depends, Float.class));
    }
    
    private boolean find(Class<?>[] a, Class<?> query) {
        for (Class<?> c : a) {
            if (c == query) {
                return true;
            }
        }
        return false;
    }
    
    private static interface TestInterface {
        List<File> getFiles();
        List<String>[] stringStuff();
        Float[] floatStuff();
    }
    
}
