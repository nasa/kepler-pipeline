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

package gov.nasa.kepler.gar.hgn;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.utils.SerializationTest;
import gov.nasa.kepler.gar.CadencePixelValues;
import gov.nasa.kepler.gar.Histogram;
import gov.nasa.kepler.mc.gar.RequantTable;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

import org.junit.Test;

/**
 * Tests the {@link HgnInputs} and {@link HgnOutputs} classes.
 * 
 * @author Bill Wohler
 */
public class HgnSerializationTest extends SerializationTest {

    @Override
    @Test
    public void testInputs() throws IllegalAccessException {
        super.testInputs();
    }

    @Override
    @Test
    public void testOutputs() throws IllegalAccessException {
        super.testOutputs();
    }

    @Override
    protected Persistable createInputs() {
        return new HgnInputs();
    }

    @Override
    protected Persistable createOutputs() {
        return new HgnOutputs();
    }

    @Override
    protected Persistable populateInputs(Persistable inputs) {
        HgnInputs hgnInputs = (HgnInputs) inputs;

        int[] requantEntries = new int[FcConstants.REQUANT_TABLE_LENGTH];
        for (int i = 0; i < requantEntries.length; i++) {
            requantEntries[i] = i;
        }
        int[] meanBlackEntries = new int[FcConstants.MODULE_OUTPUTS];
        for (int i = 0; i < meanBlackEntries.length; i++) {
            meanBlackEntries[i] = i;
        }
        RequantTable requantTable = new RequantTable();
        requantTable.setRequantEntries(requantEntries);
        requantTable.setMeanBlackEntries(meanBlackEntries);

        List<CadencePixelValues> pixelValuesList = new ArrayList<CadencePixelValues>();
        pixelValuesList.add(createCadencePixelValues(1));
        pixelValuesList.add(createCadencePixelValues(2));
        pixelValuesList.add(createCadencePixelValues(3));

        HgnModuleParameters parameters = new HgnModuleParameters();
        parameters.setBaselineIntervals(new int[] { 2, 4, 8, 92 });

        hgnInputs.setCadencePixels(pixelValuesList);
        hgnInputs.setHgnModuleParameters(parameters);
        hgnInputs.setRequantTable(requantTable);

        return hgnInputs;
    }

    private CadencePixelValues createCadencePixelValues(int cadence) {

        CadencePixelValues cadencePixelValues = new CadencePixelValues();
        cadencePixelValues.setCadence(cadence);
        cadencePixelValues.setGapIndicators(new boolean[] { false, true, false });
        cadencePixelValues.setPixelValues(new int[] { 1, 2, 3 });

        return cadencePixelValues;
    }

    @Override
    protected Persistable populateOutputs(Persistable outputs) {
        HgnOutputs hgnOutputs = (HgnOutputs) outputs;

        List<Histogram> histograms = new ArrayList<Histogram>();
        histograms.add(createHistogram());
        hgnOutputs.setHistograms(histograms);

        return hgnOutputs;
    }

    private Histogram createHistogram() {
        Histogram histogram = new Histogram(0);
        histogram.setHistogram(new long[] { 1L, 2L, 3L });

        return histogram;
    }
}
