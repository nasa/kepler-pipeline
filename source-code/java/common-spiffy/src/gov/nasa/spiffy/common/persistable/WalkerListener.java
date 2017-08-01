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

package gov.nasa.spiffy.common.persistable;

import java.lang.reflect.Field;

/**
 * This interface defines the callbacks made by the ClassWalker class as it
 * parses a class hierarchy
 * 
 * Only Java primitives, java.lang.String, and classes that implement the
 * Persistable interface are supported as types. Also supported are arrays,
 * java.util.List and java.util.Map collections of these base types. Any other
 * types found will result in the unknownType callback being called (see below).
 * 
 * @author tklaus
 * 
 */
public interface WalkerListener {

    /**
     * Called when a new class is found in the hierarchy. This method will only
     * be called once for a given class, even if it occurs multiple times in the
     * hierarchy.
     * 
     * @param clazz
     * @throws Exception
     */
    public void classStart(Class<?> clazz) throws Exception;

    /**
     * Called for Persistable fields
     * 
     * @param name
     * @param classSimpleName
     * @param field
     * @throws Exception
     */
    public void classField(Field field) throws Exception;

    /**
     * Called for java.util.List collections or arrays of Persistable
     * 
     * @param name
     * @param classSimpleName
     * @param dimensions
     * @param field
     * @param clazz
     * @throws Exception
     */
    public void classArrayField(Field field, Class<?> elementClass, int dimensions) throws Exception;

    /**
     * Called after all fields in the current class have been reported (via the
     * various *Field callbacks) This method will only be called once for a
     * given class, even if it occurs multiple times in the hierarchy.
     * 
     * @param clazz
     * @throws Exception
     */
    public void classEnd(Class<?> clazz) throws Exception;

    /**
     * Called for primitive fields. This includes all Java primitives, plus
     * java.lang.String
     * 
     * @param name
     * @param classSimpleName
     * @param field
     * @param clazz
     * @throws Exception
     */
    public void primitiveField(String name, String classSimpleName, Field field, boolean preservePrecision) throws Exception;

    /**
     * Called for all primitive array fields. This includes all Java primitives,
     * plus java.lang.String
     * 
     * @param name
     * @param classSimpleName
     * @param dimensions
     * @param field
     * @throws Exception
     */
    public void primitiveArrayField(String name, String classSimpleName, int dimensions, Field field, boolean preservePrecision) throws Exception;

    /**
     * Called for all other field types not covered above
     * 
     * @param name
     * @param simpleClassName
     * @param canonicalClassName
     * @param clazz
     * @throws Exception
     */
    public void unknownType(Field field) throws Exception;
}
