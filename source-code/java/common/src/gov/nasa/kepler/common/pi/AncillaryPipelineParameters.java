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

package gov.nasa.kepler.common.pi;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.Arrays;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * This class contains parameters associated with ancillary pipeline data (i.e.
 * produced by another pipeline module). These parameters are to be set by the
 * pipeline operator, who gets the values from the Science Office. All but one
 * of the arrays, {@code interactions}, are parallel arrays that have the same
 * number of elements.
 * 
 * @author Miles Cote
 * 
 */
public class AncillaryPipelineParameters implements Persistable, Parameters {

    /**
     * Ancillary pipeline mnemonics. The value of this field must be the same
     * length as the {@code modeOrders} field.
     */
    private String[] mnemonics = ArrayUtils.EMPTY_STRING_ARRAY;

    /**
     * Data model order in design matrix. The value of this field must be the
     * same length as the {@code mnemonics} field.
     */
    private int[] modelOrders = ArrayUtils.EMPTY_INT_ARRAY;

    /**
     * Each element of the array is a {@code String} whose value is a pair of
     * pipe-separated mnemonics. Note that this array is not necessarily the
     * same length as the other array fields.
     */
    private String[] interactions = ArrayUtils.EMPTY_STRING_ARRAY;

    public AncillaryPipelineParameters() {
    }

    public AncillaryPipelineParameters(String[] mnemonics,
        String[] interactions, int[] modelOrders) {
        this.mnemonics = mnemonics;
        this.modelOrders = modelOrders;
        this.interactions = interactions;
    }

    public String[] getInteractions() {
        return interactions;
    }

    public void setInteractions(String[] interactions) {
        this.interactions = interactions;
    }

    public String[] getMnemonics() {
        return mnemonics;
    }

    public void setMnemonics(String[] mnemonics) {
        this.mnemonics = mnemonics;
    }

    public int[] getModelOrders() {
        return modelOrders;
    }

    public void setModelOrders(int[] modelOrders) {
        this.modelOrders = modelOrders;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Arrays.hashCode(interactions);
        result = prime * result + Arrays.hashCode(mnemonics);
        result = prime * result + Arrays.hashCode(modelOrders);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof AncillaryPipelineParameters)) {
            return false;
        }
        final AncillaryPipelineParameters other = (AncillaryPipelineParameters) obj;
        if (!Arrays.equals(interactions, other.interactions)) {
            return false;
        }
        if (!Arrays.equals(mnemonics, other.mnemonics)) {
            return false;
        }
        if (!Arrays.equals(modelOrders, other.modelOrders)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }

}