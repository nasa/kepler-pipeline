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

import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TransactionNotExistException;
import gov.nasa.kepler.fs.transport.ServerSideException;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Map;

import javax.transaction.xa.XAException;


/**
 * Utility methods for dealting with java reflection as used by the code
 * generator and generated classes.
 * 
 * @author Sean McCauliff
 *
 */
public class Utils {

    static String packageName(String fullName) {
        int lastDot = fullName.lastIndexOf('.');
        if (lastDot == -1) {
            return fullName;
        }
        return fullName.substring(0, lastDot);
    }

    static String className(String fullName) {
        int lastDot = fullName.lastIndexOf('.');
        if (lastDot == -1) {
            return fullName;
        }
        return fullName.substring(lastDot + 1, fullName.length());
    }

    /**
     * How deep the specified class is in it's inheritance tree.
     *
     */
    static int classDepth(Class<?> c) {
        int depth=0;
        for (Class<?> superClass = c.getSuperclass(); 
        superClass != null;
        superClass = superClass.getSuperclass(), depth++) {}

        return depth;
    }

    /**
     * Sort classes based on their depth in the inheritance tree so that more
     * derived classes appear before less derived classes.
     */
    static void sortOnInheritanceDepth(Class<?>[] classes) {
        final Map<Class<?>, Integer> depthMap = new HashMap<Class<?>, Integer>();
        for (Class<?> c : classes) {
            depthMap.put(c, classDepth(c));
        }

        Arrays.sort(classes, new Comparator<Class<?>>() {

            public int compare(Class<?> o1, Class<?> o2) {
                return depthMap.get(o2) - depthMap.get(o1);
            }

        });

    }
    
    public static void rethrowXAException(ServerSideException sse) throws XAException {
        XAException original = (XAException) sse.getCause();
        XAException newXAException = new XAException(original.getMessage());
        //Let's assign like it's 1969
        newXAException.errorCode = original.errorCode;
        newXAException.initCause(original);
        throw newXAException;
    }
    
    public static void throwExceptionFromServer(Throwable sse) {
        if (sse instanceof OutOfMemoryError) {
            throw (OutOfMemoryError) sse;
        }
        if (sse.getCause() == null) {
            if (sse instanceof RuntimeException) {
                throw (RuntimeException) sse;
            }
            throw new FileStoreException("server side excepiton", sse);
        }
        
        Throwable cause = sse.getCause();
        if (cause instanceof TransactionNotExistException) {
            TransactionNotExistException tnee = (TransactionNotExistException) cause;
            throw new TransactionNotExistException(tnee.xid(), tnee.getMessage(), tnee);
        }
        
        if (cause instanceof RuntimeException) {
            //constructor containing FsId
            try {
                Method offendingIdMethod = cause.getClass().getMethod("id");
                FsId offendingId = (FsId) offendingIdMethod.invoke(cause);
                
                Constructor<? extends RuntimeException> withFsId = 
                    (Constructor<? extends RuntimeException>) 
                    cause.getClass().getConstructor(String.class, FsId.class, Throwable.class);
                throw withFsId.newInstance(cause.getMessage(), offendingId, cause);
                
            //Before you go changing the following to "catch (Exception e)"
            //consider that the preceding line throws an exception that you do
            //not want caught by the next set of catch blocks.
            } catch (InvocationTargetException ignored) {
            } catch (NoSuchMethodException ignored) {
            } catch (SecurityException ignored) {
            } catch (IllegalAccessException ignored) {
            } catch (InstantiationException e) {
            }
            

            try {
                Constructor<? extends RuntimeException> originalExceptionConstructor = 
                    (Constructor<? extends RuntimeException>) cause.getClass().getConstructor(String.class, Throwable.class);
                throw originalExceptionConstructor.newInstance(cause.getMessage(), cause);
              //Before you go changing the following to "catch (Exception e)"
                //consider that the preceding line throws an exception that you do
                //not want caught by the next set of catch blocks.
            } catch (InvocationTargetException ignored) {
            } catch (NoSuchMethodException ignored) {
            } catch (SecurityException ignored) {
            } catch (InstantiationException ignored) {
            } catch (IllegalAccessException ignored) {
            }
        }
        
        throw new FileStoreException(cause.getMessage(), sse);
    }
}
