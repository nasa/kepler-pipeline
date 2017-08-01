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
import gov.nasa.kepler.mc.CompoundIndicesTimeSeries;
import gov.nasa.kepler.mc.CorrectedFluxTimeSeries;
import gov.nasa.kepler.mc.SimpleIndicesTimeSeries;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.util.Arrays;
import java.util.List;

import org.junit.Test;

public class IndexingSchemeConverterToOneBasedTest {

    @Test
    public void testConvert() throws IllegalAccessException {
        int[] originalIndicesArray = new int[] { 1, 2, 3 };
        SbtData inputSbtData = createSbtData(originalIndicesArray);

        IndexingSchemeConverterToOneBased indicesConverterToOneBased = new IndexingSchemeConverterToOneBased();
        indicesConverterToOneBased.convert(inputSbtData);

        int[] expectedIndicesArray = new int[] { 2, 3, 4 };
        SbtData expectedSbtData = createSbtData(expectedIndicesArray);

        ReflectionEquals reflectionEquals = new ReflectionEquals();
        reflectionEquals.assertEquals(expectedSbtData, inputSbtData);
    }

    private SbtData createSbtData(int[] indices) {
        SimpleIndicesTimeSeries cosmicRayEventsTimeSeries = new SimpleIndicesTimeSeries();
        cosmicRayEventsTimeSeries.setIndices(Arrays.copyOf(indices,
            indices.length));

        CorrectedFluxTimeSeries correctedFluxTimeSeries = new CorrectedFluxTimeSeries();
        correctedFluxTimeSeries.setFilledIndices(Arrays.copyOf(indices,
            indices.length));

        CompoundIndicesTimeSeries outliersTimeSeries = new CompoundIndicesTimeSeries();
        outliersTimeSeries.setIndices(Arrays.copyOf(indices, indices.length));

        CorrectedFluxTimeSeries harmonicFreeCorrectedFluxTimeSeries = new CorrectedFluxTimeSeries();
        harmonicFreeCorrectedFluxTimeSeries.setFilledIndices(Arrays.copyOf(
            indices, indices.length));

        CompoundIndicesTimeSeries harmonicFreeOutliersTimeSeries = new CompoundIndicesTimeSeries();
        harmonicFreeOutliersTimeSeries.setIndices(Arrays.copyOf(indices,
            indices.length));

        SbtBlobSeries blobSeries = new SbtBlobSeries();
        blobSeries.setBlobIndices(Arrays.copyOf(indices, indices.length));

        List<SbtBlobSeries> blobSeriesList = newArrayList();
        blobSeriesList.add(blobSeries);

        SbtModOut sbtModOut = new SbtModOut();
        sbtModOut.setBlobGroups(blobSeriesList);
        sbtModOut.setArgabrighteningIndices(Arrays.copyOf(indices,
            indices.length));

        SbtTargetTable sbtTargetTable = new SbtTargetTable();
        sbtTargetTable.getModOuts()
            .add(sbtModOut);

        SbtCorrectedFluxAndOutliersTimeSeries sbtCorrectedFluxTimeSeries = new SbtCorrectedFluxAndOutliersTimeSeries();
        sbtCorrectedFluxTimeSeries.setTimeSeries(correctedFluxTimeSeries);
        sbtCorrectedFluxTimeSeries.setOutliers(outliersTimeSeries);

        SbtFluxGroup sbtFluxGroup = new SbtFluxGroup();
        sbtFluxGroup.getCorrectedFluxTimeSeriesList()
            .add(sbtCorrectedFluxTimeSeries);
        sbtFluxGroup.setDiscontinuityIndices(Arrays.copyOf(indices,
            indices.length));

        SbtPixel sbtPixel = new SbtPixel();
        sbtPixel.setCosmicRayEvents(cosmicRayEventsTimeSeries);

        SbtAperture sbtAperture = new SbtAperture();
        sbtAperture.getPixels()
            .add(sbtPixel);

        SbtTarget sbtTarget = new SbtTarget();
        sbtTarget.getFluxGroups()
            .add(sbtFluxGroup);
        sbtTarget.getTargetTables()
            .add(sbtAperture);

        SbtData sbtData = new SbtData();
        sbtData.getTargetTables()
            .add(sbtTargetTable);
        sbtData.getTargets()
            .add(sbtTarget);

        return sbtData;
    }

}
