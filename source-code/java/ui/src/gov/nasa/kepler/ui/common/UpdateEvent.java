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

package gov.nasa.kepler.ui.common;

import org.bushe.swing.event.EventBus;

/**
 * A fairly general event that is used on the {@link EventBus}.
 * 
 * @param <T> the type of object that this event contains.
 * @author Bill Wohler
 */
public class UpdateEvent<T> {

    public enum Function {
        /** The object(s) should be added. */
        ADD,
        /** The object(s) should be added or updated. */
        ADD_OR_UPDATE,
        /**
         * The object is a list, and the second object should be inserted after
         * the first object. If the first object is <code>null</code>, then the
         * second objected should be inserted at the beginning of the list.
         */
        INSERT,
        /** The object(s) should be updated. */
        UPDATE,
        /** The object(s) should deleted. */
        DELETE,
        /** The object(s) have been selected. */
        SELECT,
        /** The object(s) in the view should be refreshed. */
        REFRESH,
    }

    private Function function;
    private T object;

    /**
     * Creates an {@link UpdateEvent}.
     * 
     * @param function one of the values from the {@link Function} enum.
     * @param object the object that the function should operate upon.
     */
    public UpdateEvent(Function function, T object) {
        this.function = function;
        this.object = object;
    }

    /**
     * Returns this event's function.
     * 
     * @return one of the values from the {@link Function} enum.
     */
    public Function getFunction() {
        return function;
    }

    /**
     * Returns this event's object.
     * 
     * @return the object that the function should operate upon.
     */
    public T get() {
        return object;
    }

    @Override
    public String toString() {
        return "function=" + function + ", object=" + object;
    }
}
