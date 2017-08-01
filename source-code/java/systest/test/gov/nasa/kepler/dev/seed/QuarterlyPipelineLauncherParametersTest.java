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

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.dev.seed.QuarterlyPipelineDescriptor.Activity;
import gov.nasa.kepler.dev.seed.QuarterlyPipelineDescriptor.DataType;
import gov.nasa.kepler.dev.seed.QuarterlyPipelineDescriptor.Quarter;

import java.util.List;

import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class QuarterlyPipelineLauncherParametersTest {

    @Test
    public void testGetQuarterlyPipelineDescriptorsByQuartersDataTypesActivities() {
        QuarterlyPipelineLauncherParameters parameters = new QuarterlyPipelineLauncherParameters();
        parameters.setQuarters(new String[] { "Q0", "Q1" });
        parameters.setDataTypes(new String[] { "LC", "SC" });
        parameters.setActivities(new String[] { "INGEST", "DATAGEN" });
        parameters.setWrappingOrder(new String[] { "QUARTERS", "DATA_TYPES",
            "ACTIVITIES" });
        List<QuarterlyPipelineDescriptor> actualDescriptors = parameters.toQuarterlyPipelineDescriptors();

        List<QuarterlyPipelineDescriptor> expectedDescriptors = ImmutableList.of(
            new QuarterlyPipelineDescriptor(Quarter.Q0, DataType.LC,
                Activity.INGEST), new QuarterlyPipelineDescriptor(Quarter.Q0,
                DataType.LC, Activity.DATAGEN),
            new QuarterlyPipelineDescriptor(Quarter.Q0, DataType.SC,
                Activity.INGEST), new QuarterlyPipelineDescriptor(Quarter.Q0,
                DataType.SC, Activity.DATAGEN),
            new QuarterlyPipelineDescriptor(Quarter.Q1, DataType.LC,
                Activity.INGEST), new QuarterlyPipelineDescriptor(Quarter.Q1,
                DataType.LC, Activity.DATAGEN),
            new QuarterlyPipelineDescriptor(Quarter.Q1, DataType.SC,
                Activity.INGEST), new QuarterlyPipelineDescriptor(Quarter.Q1,
                DataType.SC, Activity.DATAGEN));

        assertEquals(expectedDescriptors, actualDescriptors);
    }

    @Test
    public void testGetQuarterlyPipelineDescriptorsByDataTypesActivitiesQuarters() {
        QuarterlyPipelineLauncherParameters parameters = new QuarterlyPipelineLauncherParameters();
        parameters.setQuarters(new String[] { "Q0", "Q1" });
        parameters.setDataTypes(new String[] { "LC", "SC" });
        parameters.setActivities(new String[] { "INGEST", "DATAGEN" });
        parameters.setWrappingOrder(new String[] { "DATA_TYPES", "ACTIVITIES",
            "QUARTERS" });
        List<QuarterlyPipelineDescriptor> actualDescriptors = parameters.toQuarterlyPipelineDescriptors();

        List<QuarterlyPipelineDescriptor> expectedDescriptors = ImmutableList.of(
            new QuarterlyPipelineDescriptor(Quarter.Q0, DataType.LC,
                Activity.INGEST), new QuarterlyPipelineDescriptor(Quarter.Q1,
                DataType.LC, Activity.INGEST), new QuarterlyPipelineDescriptor(
                Quarter.Q0, DataType.LC, Activity.DATAGEN),
            new QuarterlyPipelineDescriptor(Quarter.Q1, DataType.LC,
                Activity.DATAGEN), new QuarterlyPipelineDescriptor(Quarter.Q0,
                DataType.SC, Activity.INGEST), new QuarterlyPipelineDescriptor(
                Quarter.Q1, DataType.SC, Activity.INGEST),
            new QuarterlyPipelineDescriptor(Quarter.Q0, DataType.SC,
                Activity.DATAGEN), new QuarterlyPipelineDescriptor(Quarter.Q1,
                DataType.SC, Activity.DATAGEN));

        assertEquals(expectedDescriptors, actualDescriptors);
    }

}
