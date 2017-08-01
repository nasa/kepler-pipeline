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
 * This class contains parameters associated with ancillary engineering data
 * (i.e. from the spacecraft). These parameters are to be set by the pipeline
 * operator, who gets the values from the Science Office. All but one of the
 * arrays, {@code interactions}, are parallel arrays that have the same number
 * of elements.
 * 
 * @author Miles Cote
 * 
 */
public class AncillaryEngineeringParameters implements Persistable, Parameters {

    private String[] mnemonics = ArrayUtils.EMPTY_STRING_ARRAY;
    private int[] modelOrders = ArrayUtils.EMPTY_INT_ARRAY;
    private float[] quantizationLevels = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] intrinsicUncertainties = ArrayUtils.EMPTY_FLOAT_ARRAY;

    /**
     * Each element of the array is a {@code String} whose value is a pair of
     * pipe-separated mnemonics. Note that this array is not necessarily the
     * same length as the other array fields.
     */
    private String[] interactions = ArrayUtils.EMPTY_STRING_ARRAY;

    public AncillaryEngineeringParameters() {
    }

    public AncillaryEngineeringParameters(String[] mnemonics,
        String[] interactions, int[] modelOrders, float[] quantizationLevels,
        float[] intrinsicUncertainties) {
        this.mnemonics = mnemonics;
        this.interactions = interactions;
        this.modelOrders = modelOrders;
        this.quantizationLevels = quantizationLevels;
        this.intrinsicUncertainties = intrinsicUncertainties;
    }

    public String[] getInteractions() {
        return interactions;
    }

    public void setInteractions(String[] interactions) {
        if (interactions.length == 1 && interactions[0] == null) {
            interactions = new String[0];
        }
        this.interactions = interactions;
    }

    public float[] getIntrinsicUncertainties() {
        return intrinsicUncertainties;
    }

    public void setIntrinsicUncertainties(float[] intrinsicUncertainties) {
        this.intrinsicUncertainties = intrinsicUncertainties;
    }

    public String[] getMnemonics() {
        return mnemonics;
    }

    public void setMnemonics(String[] mnemonics) {
        if (mnemonics.length == 1 && mnemonics[0] == null) {
            mnemonics = new String[0];
        }
        this.mnemonics = mnemonics;
    }

    public int[] getModelOrders() {
        return modelOrders;
    }

    public void setModelOrders(int[] modelOrders) {
        this.modelOrders = modelOrders;
    }

    public float[] getQuantizationLevels() {
        return quantizationLevels;
    }

    public void setQuantizationLevels(float[] quantizationLevels) {
        this.quantizationLevels = quantizationLevels;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Arrays.hashCode(interactions);
        result = prime * result + Arrays.hashCode(intrinsicUncertainties);
        result = prime * result + Arrays.hashCode(mnemonics);
        result = prime * result + Arrays.hashCode(modelOrders);
        result = prime * result + Arrays.hashCode(quantizationLevels);
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
        if (!(obj instanceof AncillaryEngineeringParameters)) {
            return false;
        }
        final AncillaryEngineeringParameters other = (AncillaryEngineeringParameters) obj;
        if (!Arrays.equals(interactions, other.interactions)) {
            return false;
        }
        if (!Arrays.equals(intrinsicUncertainties, other.intrinsicUncertainties)) {
            return false;
        }
        if (!Arrays.equals(mnemonics, other.mnemonics)) {
            return false;
        }
        if (!Arrays.equals(modelOrders, other.modelOrders)) {
            return false;
        }
        if (!Arrays.equals(quantizationLevels, other.quantizationLevels)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }

}