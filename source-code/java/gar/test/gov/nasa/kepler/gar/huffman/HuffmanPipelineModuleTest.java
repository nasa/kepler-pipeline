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

package gov.nasa.kepler.gar.huffman;

import static com.google.common.collect.Lists.newArrayList;
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.gar.AbstractGarPipelineModuleTest;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.Histogram;
import gov.nasa.kepler.hibernate.gar.HistogramGroup;
import gov.nasa.kepler.hibernate.gar.HuffmanEntry;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.List;

import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * Tests the {@link HuffmanPipelineModule}.
 * 
 * @author Bill Wohler
 */
public class HuffmanPipelineModuleTest extends AbstractGarPipelineModuleTest {

    private static final long[] HISTOGRAM = new long[] { 1L, 2L, 3L };
    private static final long PIPELINE_INSTANCE_ID = 42;
    private static final int BASELINE_INTERVAL = 48;

    private HuffmanPipelineModule pipelineModule;
    private PipelineTask pipelineTask;

    private CompressionCrud compressionCrud = mock(CompressionCrud.class);

    @Test
    public void testGetModuleName() {
        assertEquals("huffman", new HuffmanPipelineModule().getModuleName());
    }

    @Test
    public void taskType() {
        assertEquals(SingleUowTask.class,
            new HuffmanPipelineModule().unitOfWorkTaskType());
    }

    @Test
    public void testRequiredParameters() {
        assertEquals(ImmutableList.of(HuffmanModuleParameters.class),
            new HuffmanPipelineModule().requiredParameters());
    }

    private void populateObjects() {
        pipelineModule = new HuffmanPipelineModule();

        List<Parameters> moduleParameters = newArrayList();
        HuffmanModuleParameters huffmanModuleParameters = new HuffmanModuleParameters();
        huffmanModuleParameters.setHistogramPipelineInstanceId(PIPELINE_INSTANCE_ID);
        huffmanModuleParameters.setBaselineInterval(BASELINE_INTERVAL);
        moduleParameters.add(huffmanModuleParameters);
        pipelineTask = createPipelineTask(0, new SingleUowTask(), null,
            moduleParameters);
        pipelineModule.setPipelineTask(pipelineTask);
        pipelineModule.setCompressionCrud(compressionCrud);
    }

    @Test
    public void retrieveInputs() throws Exception {
        populateObjects();

        HuffmanInputs expectedHuffmanInputs = new HuffmanInputs();
        expectedHuffmanInputs.setHuffmanModuleParameters(pipelineTask.getParameters(HuffmanModuleParameters.class));
        expectedHuffmanInputs.setHistogram(createHistogram());

        HuffmanInputs actualHuffmanInputs = (HuffmanInputs) pipelineModule.createInputs();
        pipelineModule.retrieveInputs(actualHuffmanInputs);

        ReflectionEquals reflectionEquals = new ReflectionEquals();
        reflectionEquals.assertEquals(expectedHuffmanInputs,
            actualHuffmanInputs);
    }

    private long[] createHistogram() {
        PipelineInstance pipelineInstance = new PipelineInstance();
        pipelineInstance.setId(PIPELINE_INSTANCE_ID);
        final HistogramGroup histogramGroup = new HistogramGroup(
            pipelineInstance, new PipelineTask());

        List<Long> histogramValues = new ArrayList<Long>(HISTOGRAM.length);
        for (long histogramValue : HISTOGRAM) {
            histogramValues.add(histogramValue);
        }
        Histogram histogram = new Histogram(BASELINE_INTERVAL);
        histogram.setHistogram(histogramValues);
        List<Histogram> histograms = new ArrayList<Histogram>(1);
        histograms.add(histogram);
        histogramGroup.setHistograms(histograms);

        allowing(compressionCrud).retrieveHistogramGroupForEntireFocalPlane(
            PIPELINE_INSTANCE_ID);
        will(returnValue(histogramGroup));

        return HISTOGRAM;
    }

    @Test
    public void storeOutputs() throws Exception {
        // Call retrieveInputs instead of populateObjects in order to populate
        // HuffmanPipelineModule.histogram field.
        retrieveInputs();

        String[] huffmanCodeString = { "1", "10", "100" };
        int[] huffmanCodeLength = { 1, 2, 3 };
        int effectiveCompressionRate = 1;
        int theoreticalCompressionRate = 1;

        // Expected Huffman table.
        createHuffmanTable(huffmanCodeString, effectiveCompressionRate,
            theoreticalCompressionRate);

        // Basis for actual Huffman table.
        HuffmanOutputs outputs = (HuffmanOutputs) pipelineModule.createOutputs();
        outputs.setHuffmanCodeLengths(huffmanCodeLength);
        outputs.setHuffmanCodeStrings(huffmanCodeString);
        outputs.setEffectiveCompressionRate(effectiveCompressionRate);
        outputs.setTheoreticalCompressionRate(theoreticalCompressionRate);

        pipelineModule.storeOutputs(outputs);
    }

    private HuffmanTable createHuffmanTable(String[] huffmanCodeString,
        int effectiveCompressionRate, int theoreticalCompressionRate) {

        List<HuffmanEntry> entries = new ArrayList<HuffmanEntry>();
        for (int i = 0; i < HISTOGRAM.length; i++) {
            entries.add(new HuffmanEntry(huffmanCodeString[i], HISTOGRAM[i]));
        }

        final HuffmanTable huffmanTable = new HuffmanTable();
        huffmanTable.setPipelineTask(pipelineTask);
        huffmanTable.setEntries(entries);
        huffmanTable.setEffectiveCompressionRate(effectiveCompressionRate);
        huffmanTable.setTheoreticalCompressionRate(theoreticalCompressionRate);

        oneOf(compressionCrud).createHuffmanTable(huffmanTable);

        return huffmanTable;
    }

    /**
     * Add more stringent equals method for testing only.
     * 
     * @author Bill Wohler
     */
    private static class HuffmanTable extends
        gov.nasa.kepler.hibernate.gar.HuffmanTable {

        @Override
        public int hashCode() {
            final int prime = 31;
            int result = super.hashCode();
            result = prime * result
                + Float.floatToIntBits(getEffectiveCompressionRate());
            result = prime * result
                + (getEntries() == null ? 0 : getEntries().hashCode());
            result = prime * result
                + Float.floatToIntBits(getTheoreticalCompressionRate());
            return result;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj) {
                return true;
            }
            if (!(obj instanceof gov.nasa.kepler.hibernate.gar.HuffmanTable)) {
                return false;
            }
            gov.nasa.kepler.hibernate.gar.HuffmanTable other = (gov.nasa.kepler.hibernate.gar.HuffmanTable) obj;
            if (Float.floatToIntBits(getEffectiveCompressionRate()) != Float.floatToIntBits(other.getEffectiveCompressionRate())) {
                return false;
            }
            if (getEntries() == null) {
                if (other.getEntries() != null) {
                    return false;
                }
            } else if (!getEntries().equals(other.getEntries())) {
                return false;
            }
            if (Float.floatToIntBits(getTheoreticalCompressionRate()) != Float.floatToIntBits(other.getTheoreticalCompressionRate())) {
                return false;
            }
            return true;
        }
    }
}
