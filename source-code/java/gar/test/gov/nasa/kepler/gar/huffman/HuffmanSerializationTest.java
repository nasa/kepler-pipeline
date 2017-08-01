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

import gov.nasa.kepler.common.utils.SerializationTest;
import gov.nasa.spiffy.common.persistable.Persistable;

import org.junit.Test;

/**
 * Tests the {@link HuffmanInputs} and {@link HuffmanOutputs} classes.
 * 
 * @author Bill Wohler
 */
public class HuffmanSerializationTest extends SerializationTest {

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
        return new HuffmanInputs();
    }

    @Override
    protected Persistable createOutputs() {
        return new HuffmanOutputs();
    }

    @Override
    protected Persistable populateInputs(Persistable inputs) {
        HuffmanInputs huffmanInputs = (HuffmanInputs) inputs;

        huffmanInputs.setHuffmanModuleParameters(new HuffmanModuleParameters());
        huffmanInputs.setHistogram(new long[] { 1L, 2L, 3L });

        return huffmanInputs;
    }

    @Override
    protected Persistable populateOutputs(Persistable outputs) {
        HuffmanOutputs huffmanOutputs = (HuffmanOutputs) outputs;

        huffmanOutputs.setHuffmanCodeLengths(new int[] { 1, 1, 1 });
        huffmanOutputs.setHuffmanCodeStrings(new String[] { "a", "b", "c" });
        huffmanOutputs.setTheoreticalCompressionRate(42.0F);
        huffmanOutputs.setEffectiveCompressionRate(43.0F);

        return huffmanOutputs;
    }
}
