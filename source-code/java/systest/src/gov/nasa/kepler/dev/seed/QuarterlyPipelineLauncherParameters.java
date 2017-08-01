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

package gov.nasa.kepler.dev.seed;

import gov.nasa.kepler.common.EnumList;
import gov.nasa.kepler.hibernate.pi.PipelineDefinition;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.ArrayUtils;

/**
 * Defines how quarterly {@link PipelineDefinition}s are launched.
 * 
 * @author Miles Cote
 * 
 */
public class QuarterlyPipelineLauncherParameters implements Parameters {

    public static enum Field {
        QUARTERS(new QuarterlyPipelineDescriptorSubdividerQuarters()),
        DATA_TYPES(new QuarterlyPipelineDescriptorSubdividerDataTypes()),
        ACTIVITIES(new QuarterlyPipelineDescriptorSubdividerActivities());

        private final QuarterlyPipelineDescriptorSubdivider quarterlyPipelineDescriptorSubdivider;

        private Field(
            QuarterlyPipelineDescriptorSubdivider quarterlyPipelineDescriptorSubdivider) {
            this.quarterlyPipelineDescriptorSubdivider = quarterlyPipelineDescriptorSubdivider;
        }

        public QuarterlyPipelineDescriptorSubdivider getQuarterlyPipelineDescriptorSubdivider() {
            return quarterlyPipelineDescriptorSubdivider;
        }
    }

    /**
     * Array of {@link QuarterlyPipelineDescriptor.Quarter}s.
     */
    private String[] quarters = ArrayUtils.EMPTY_STRING_ARRAY;

    /**
     * Array of {@link QuarterlyPipelineDescriptor.DataType}s;
     */
    private String[] dataTypes = ArrayUtils.EMPTY_STRING_ARRAY;

    /**
     * Array of {@link QuarterlyPipelineDescriptor.Activity}s;
     */
    private String[] activities = ArrayUtils.EMPTY_STRING_ARRAY;

    /**
     * Array of {@link Field}s defining the outer-to-inner wrapping order for
     * determining pipeline launching order.
     */
    private String[] wrappingOrder = ArrayUtils.EMPTY_STRING_ARRAY;

    public List<QuarterlyPipelineDescriptor> toQuarterlyPipelineDescriptors() {
        List<QuarterlyPipelineDescriptor> descriptors = new ArrayList<QuarterlyPipelineDescriptor>();
        descriptors.add(new QuarterlyPipelineDescriptor());

        for (Field field : EnumList.valueOf(Field.class, wrappingOrder)) {
            descriptors = field.getQuarterlyPipelineDescriptorSubdivider()
                .subdivide(descriptors, this);
        }

        return descriptors;
    }

    public QuarterlyPipelineLauncherParameters() {
    }

    public String[] getQuarters() {
        return quarters;
    }

    public void setQuarters(String[] quarters) {
        this.quarters = quarters;
    }

    public String[] getDataTypes() {
        return dataTypes;
    }

    public void setDataTypes(String[] dataTypes) {
        this.dataTypes = dataTypes;
    }

    public String[] getActivities() {
        return activities;
    }

    public void setActivities(String[] activities) {
        this.activities = activities;
    }

    public String[] getWrappingOrder() {
        return wrappingOrder;
    }

    public void setWrappingOrder(String[] wrappingOrder) {
        this.wrappingOrder = wrappingOrder;
    }

}
