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

package gov.nasa.spiffy.common.jmx;


import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import javax.management.openmbean.CompositeData;
import javax.management.openmbean.CompositeType;
import javax.management.openmbean.OpenDataException;


/**
 * Generates needed meta-data from introspection.
 * @author Sean McCauliff
 *
 */
public abstract class AbstractCompositeData implements CompositeData {
    private final AutoCompositeType autoCompositeType;
    
    protected AbstractCompositeData() throws OpenDataException {
        this.autoCompositeType = AutoCompositeType.newAutoCompositeType(getClass());
    }
    
    @Override
    public boolean containsKey(String key) {
        return autoCompositeType.compositeType().containsKey(key);
    }

    @Override
    public boolean containsValue(Object value) {
        for (Method m : autoCompositeType.itemGetters().values()) {
            Object itemValue;
            try {
                itemValue = m.invoke(this, new Object[0]);
            } catch (IllegalArgumentException e) {
                //This should never happen since there no args.
                throw new IllegalStateException("while invoking getter", e);
            } catch (IllegalAccessException e) {
                //This should never happen since we checked for public before.
                throw new IllegalStateException("while invoking getter", e);
            } catch (InvocationTargetException e) {
                throw new IllegalStateException("while invoking getter", e);
            }
            
            if (itemValue == null && value == null) {
                return true;
            }
            if (itemValue == null && value != null) {
                continue;
            }
            if (itemValue != null && itemValue.equals(value)) {
                return true;
            }
        }
        
        return false;
    }

    @Override
    public Object get(String key) {
        Method m = autoCompositeType.itemGetters().get(key);
        if (m == null) {
            throw new IllegalArgumentException("Invalid item name \"" + 
                key + "\".");
        }
        
        try {
            return m.invoke(this, new Object[0]);
        } catch (IllegalArgumentException e) {
            //This should never happen since there no args.
            throw new IllegalStateException("while invoking getter", e);
        } catch (IllegalAccessException e) {
            //This should never happen since we checked for public before.
            throw new IllegalStateException("while invoking getter", e);
        } catch (InvocationTargetException e) {
            throw new IllegalStateException("while invoking getter", e);
        }
    }

    @Override
    public Object[] getAll(String[] keys) {
        Object[] rv = new Object[keys.length];
        for (int i=0; i < keys.length; i++) {
            rv[i] = get(keys[i]);
        }
        
        return rv;
    }

    @Override
    public CompositeType getCompositeType() {
        return autoCompositeType.compositeType();
    }

    @Override
    public Collection<?> values() {
        List<Object> rv = 
            new ArrayList<Object>(autoCompositeType.itemGetters().size());
        for (String itemName : autoCompositeType.itemGetters().keySet()) {
            rv.add(get(itemName));
        }
        return rv;
    }

   
}
