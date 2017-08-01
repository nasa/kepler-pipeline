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

package gov.nasa.kepler.systest.sbt.data;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.common.AncillaryPipelineData;
import gov.nasa.kepler.common.pi.AncillaryEngineeringParameters;
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.mc.ancillary.AncillaryOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.util.List;

import org.junit.Test;

public class SbtAncillaryOperationsTest extends JMockTest {

    @Test
    public void testRetrieveAncillaryEngineering()
        throws IllegalAccessException {
        final int startCadence = 4;
        final int endCadence = 5;

        final double startMjd = 6.6;
        final double endMjd = 7.7;

        final String mnemonic = "mnemonic";
        final String interaction = "interaction";

        final String[] mnemonics = new String[] { mnemonic, mnemonic };

        final List<SbtParameterMapEntry> sbtParameterMapEntries = newArrayList();
        sbtParameterMapEntries.add(new SbtParameterMapEntry("mnemonics",
            mnemonic + "," + mnemonic));
        sbtParameterMapEntries.add(new SbtParameterMapEntry("modelOrders",
            "1,1"));
        sbtParameterMapEntries.add(new SbtParameterMapEntry(
            "quantizationLevels", "2.2,2.2"));
        sbtParameterMapEntries.add(new SbtParameterMapEntry(
            "intrinsicUncertainties", "3.3,3.3"));
        sbtParameterMapEntries.add(new SbtParameterMapEntry("interactions",
            interaction + "," + interaction));

        final List<SbtParameterMap> sbtParameterMaps = newArrayList();
        sbtParameterMaps.add(new SbtParameterMap(startCadence, endCadence,
            sbtParameterMapEntries));

        final List<SbtParameterGroup> sbtParameterGroups = newArrayList();
        sbtParameterGroups.add(new SbtParameterGroup(
            AncillaryEngineeringParameters.class.getSimpleName(),
            sbtParameterMaps));

        final AncillaryEngineeringData ancillaryEngineeringData = mock(AncillaryEngineeringData.class);

        final List<AncillaryEngineeringData> ancillaryEngineeringDataList = newArrayList();
        ancillaryEngineeringDataList.add(ancillaryEngineeringData);

        final MjdToCadence mjdToCadence = mock(MjdToCadence.class);
        final AncillaryOperations ancillaryOperations = mock(AncillaryOperations.class);

        allowing(mjdToCadence).cadenceToMjd(startCadence);
        will(returnValue(startMjd));

        allowing(mjdToCadence).cadenceToMjd(endCadence);
        will(returnValue(endMjd));

        allowing(ancillaryOperations).retrieveAncillaryEngineeringData(
            mnemonics, startMjd, endMjd);
        will(returnValue(ancillaryEngineeringDataList));

        SbtAncillaryOperations sbtAncillaryOperations = new SbtAncillaryOperations(
            ancillaryOperations);
        List<SbtAncillaryEngineeringGroup> sbtAncillaryEngineeringGroups = sbtAncillaryOperations.retrieveSbtAncillaryEngineeringGroups(
            sbtParameterGroups, mjdToCadence);

        AncillaryEngineeringParameters expectedAncillaryEngineeringParameters = new AncillaryEngineeringParameters(
            mnemonics, new String[] { interaction, interaction }, new int[] {
                1, 1 }, new float[] { 2.2F, 2.2F }, new float[] { 3.3F, 3.3F });

        List<SbtAncillaryEngineeringGroup> expectedSbtAncillaryEngineeringGroups = newArrayList();
        expectedSbtAncillaryEngineeringGroups.add(new SbtAncillaryEngineeringGroup(
            startCadence, endCadence, expectedAncillaryEngineeringParameters,
            ancillaryEngineeringDataList));

        ReflectionEquals reflectionEquals = new ReflectionEquals();
        reflectionEquals.assertEquals(expectedSbtAncillaryEngineeringGroups,
            sbtAncillaryEngineeringGroups);
    }

    @Test
    public void testRetrieveAncillaryPipeline() throws IllegalAccessException {
        final int startCadence = 4;
        final int endCadence = 5;

        final double startMjd = 6.6;
        final double endMjd = 7.7;

        final String mnemonic = "mnemonic";
        final String interaction = "interaction";

        final String[] mnemonics = new String[] { mnemonic, mnemonic };

        final List<SbtParameterMapEntry> sbtParameterMapEntries = newArrayList();
        sbtParameterMapEntries.add(new SbtParameterMapEntry("mnemonics",
            mnemonic + "," + mnemonic));
        sbtParameterMapEntries.add(new SbtParameterMapEntry("modelOrders",
            "1,1"));
        sbtParameterMapEntries.add(new SbtParameterMapEntry(
            "quantizationLevels", "2.2,2.2"));
        sbtParameterMapEntries.add(new SbtParameterMapEntry(
            "intrinsicUncertainties", "3.3,3.3"));
        sbtParameterMapEntries.add(new SbtParameterMapEntry("interactions",
            interaction + "," + interaction));

        final List<SbtParameterMap> sbtParameterMaps = newArrayList();
        sbtParameterMaps.add(new SbtParameterMap(startCadence, endCadence,
            sbtParameterMapEntries));

        final List<SbtParameterGroup> sbtParameterGroups = newArrayList();
        sbtParameterGroups.add(new SbtParameterGroup(
            AncillaryPipelineParameters.class.getSimpleName(), sbtParameterMaps));

        final AncillaryPipelineData ancillaryPipelineData = mock(AncillaryPipelineData.class);

        final List<AncillaryPipelineData> ancillaryPipelineDataList = newArrayList();
        ancillaryPipelineDataList.add(ancillaryPipelineData);

        final MjdToCadence mjdToCadence = mock(MjdToCadence.class);
        final AncillaryOperations ancillaryOperations = mock(AncillaryOperations.class);

        allowing(mjdToCadence).cadenceToMjd(startCadence);
        will(returnValue(startMjd));

        allowing(mjdToCadence).cadenceToMjd(endCadence);
        will(returnValue(endMjd));

        allowing(ancillaryOperations).retrieveAncillaryPipelineData(mnemonics,
            startMjd, endMjd);
        will(returnValue(ancillaryPipelineDataList));

        SbtAncillaryOperations sbtAncillaryOperations = new SbtAncillaryOperations(
            ancillaryOperations);
        List<SbtAncillaryPipelineGroup> sbtAncillaryPipelineGroups = sbtAncillaryOperations.retrieveSbtAncillaryPipelineGroups(
            sbtParameterGroups, mjdToCadence);

        AncillaryPipelineParameters expectedAncillaryPipelineParameters = new AncillaryPipelineParameters(
            mnemonics, new String[] { interaction, interaction }, new int[] {
                1, 1 });

        List<SbtAncillaryPipelineGroup> expectedSbtAncillaryPipelineGroups = newArrayList();
        expectedSbtAncillaryPipelineGroups.add(new SbtAncillaryPipelineGroup(
            startCadence, endCadence, expectedAncillaryPipelineParameters,
            ancillaryPipelineDataList));

        ReflectionEquals reflectionEquals = new ReflectionEquals();
        reflectionEquals.assertEquals(expectedSbtAncillaryPipelineGroups,
            sbtAncillaryPipelineGroups);
    }

}
