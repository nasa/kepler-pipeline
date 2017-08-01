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

package gov.nasa.kepler.dv;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertSame;
import gov.nasa.kepler.dv.io.DvInputs;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import org.junit.Test;

/**
 * Tests the {@link DvInputsTest} class.
 * 
 * @author Bill Wohler
 */
public class DvInputsTest {

    private static final Integer ZERO = 0;

    // Ensure that the copy function copies all fields.
    @Test
    public void testCopy() throws IllegalArgumentException,
        IllegalAccessException {

        DvInputs dvInputsOriginal = new DvInputs();
        DvInputs dvInputsCopy = DvInputs.copy(dvInputsOriginal,
            new ArrayList<Integer>());
        Map<String, Object> originalValueByField = createValueByFieldMap(dvInputsOriginal);
        Map<String, Object> copiedValueByField = createValueByFieldMap(dvInputsCopy);

        for (String field : originalValueByField.keySet()) {
            if (field.equals("targetStruct") || field.equals("kics")
                || field.equals("kicsByKeplerId")) {
                // All will be empty lists.
                assertEquals("for field " + field,
                    originalValueByField.get(field),
                    copiedValueByField.get(field));

            } else if (field.equals("serialVersionUID")) {
                // Ignore.
            } else {
                assertSame("for field " + field,
                    originalValueByField.get(field),
                    copiedValueByField.get(field));
            }
        }
    }

    private Map<String, Object> createValueByFieldMap(Object object)
        throws IllegalArgumentException, IllegalAccessException {

        Map<String, Object> valueByField = new HashMap<String, Object>();
        for (Field field : object.getClass()
            .getDeclaredFields()) {
            field.setAccessible(true);
            Object value;
            if (field.getType()
                .equals(Boolean.TYPE)) {
                value = Boolean.valueOf((Boolean) field.get(object));
            } else if (field.getType()
                .equals(Integer.TYPE) || field.getType()
                .equals(Float.TYPE)) {
                value = ZERO;
            } else {
                value = field.get(object);
            }
            valueByField.put(field.getName(), value);
        }

        return valueByField;
    }
}
