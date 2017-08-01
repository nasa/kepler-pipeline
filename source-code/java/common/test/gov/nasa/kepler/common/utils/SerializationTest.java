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

package gov.nasa.kepler.common.utils;

import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.PersistableUtils;

import java.io.File;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Test;

/**
 * Unit tests that verify that {@code ProxyInfo} annotations in
 * {@link Persistable} classes are correct, that the {@link Persistable} objects
 * have default constructors with public visibility, and that the serialization
 * and deserialization process works.
 * <p>
 * To use, create a subclass of this class and implement {@link #createInputs()},
 * {@link #populateInputs(Persistable)}, {@link #createOutputs()}, and
 * {@link #populateOutputs(Persistable)}.
 * <p>
 * These tests also create {@code <i>Class</i>-inputs.bin} and
 * {@code <i>Class</i>-outputs.bin} files in {@link Filenames#BUILD_TMP}.
 * 
 * @author Bill Wohler
 */
public abstract class SerializationTest {

    private static final Log log = LogFactory.getLog(SerializationTest.class);

    /**
     * Create pipeline's input structure. For example, this might be implemented
     * as {@code return new CalInputs();}.
     * 
     * @return a non-{@code null} {@link Persistable} object.
     */
    protected abstract Persistable createInputs();

    /**
     * Populate pipeline's input structure. To test the serialization properly,
     * ensure that there aren't any null objects, and that all collections have
     * at least one item in them.
     * 
     * @return the populated inputs.
     */
    protected abstract Persistable populateInputs(Persistable inputs);

    /**
     * Create pipeline's output structure. For example, this might be
     * implemented as {@code return new CalOutputs();}.
     * 
     * @return a non-{@code null} {@link Persistable} object.
     */
    protected abstract Persistable createOutputs();

    /**
     * Populate pipeline's output structure. To test the serialization properly,
     * ensure that there aren't any null objects, and that all collections have
     * at least one item in them.
     * 
     * @return the populated outputs.
     */
    protected abstract Persistable populateOutputs(Persistable outputs);

    /**
     * Tests in the pipeline module's inputs. Subclasses may want to override
     * this, mark the method with \@Test, and simply call
     * {@code super.testInputs()} so that the test can be run within Eclipse.
     * 
     * @throws Exception if anything goes terribly wrong.
     */
    @Test
    public void testInputs() throws IllegalAccessException {
        testSerialization(populateInputs(createInputs()), createInputs(),
            new File(Filenames.BUILD_TMP, getClass().getSimpleName()
                + "-inputs.bin"));
    }

    /**
     * Tests in the pipeline module's outputs. Subclasses may want to override
     * this, mark the method with \@Test, and simply call
     * {@code super.testOutputs()} so that the test can be run within Eclipse.
     * 
     * @throws Exception if anything goes terribly wrong.
     */
    @Test
    public void testOutputs() throws IllegalAccessException {
        testSerialization(populateOutputs(createOutputs()), createOutputs(),
            new File(Filenames.BUILD_TMP, getClass().getSimpleName()
                + "-outputs.bin"));
    }

    /**
     * A method that verifies that objects which implement the {@link
     * Persistable} interface can be successfully serialized and deserialized.
     * These objects must have default constructors with public visibility and
     * their implementations must be consistent with any of the optional
     * annotations.
     * 
     * @param expected a fully populated {@code Persistable} object
     * @param actual an empty object of the same type
     * @param file a file into which the expected object will be serialized
     * @throws IllegalAccessException 
     */
    public static void testSerialization(Persistable expected,
        Persistable actual, File file) throws IllegalAccessException {

        // Save and read file.
        log.info("Writing " + file);
        PersistableUtils.writeBinFile(expected, file);
        log.info("Reading " + file);
        PersistableUtils.readBinFile(actual, file);

        // Test.
        log.info("Comparing original against serialized copy");
        new ReflectionEquals().assertEquals(expected, actual);
    }
}
