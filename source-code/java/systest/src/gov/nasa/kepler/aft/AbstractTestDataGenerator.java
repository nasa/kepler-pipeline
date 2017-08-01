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

package gov.nasa.kepler.aft;

import gov.nasa.kepler.aft.descriptor.TestDataSetDescriptor;
import gov.nasa.kepler.aft.descriptor.TestDataSetDescriptorFactory;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Superclass for Test Data Generators. These are classes that generate data for
 * use by Automated Feature Tests (AFTs).
 * <p>
 * Test data generators are the main source of generated test data used by the
 * AFTs. However, nothing precludes the use of data created by other means.
 * <p>
 * See the class documentation for {@link AbstractAutomatedFeatureTest} for the
 * methods that you should override to create your test data generator.
 * <p>
 * Concrete subclasses should implement a main method which looks like the one
 * in the example below. Replace {@code InitDb} with the name of your test data
 * generator.
 * 
 * <pre>
 * public static void main(String[] args) {
 *     try {
 *         new InitDbTestDataGenerator().generate();
 *     } catch (Exception e) {
 *         log.error(e.getMessage(), e);
 *         System.err.println(e.getMessage());
 *     }
 * }
 * </pre>
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 * @author tklaus
 */
public abstract class AbstractTestDataGenerator extends
    AbstractAutomatedFeatureTest {

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(AbstractTestDataGenerator.class);

    /**
     * Creates an {@code AbstractTestDataGenerator}.
     * <p>
     * The value of the {@code test.descriptor} property is used for the test
     * data set descriptor. If that property does not exist, then BASIC is used.
     */
    public AbstractTestDataGenerator(String generatorName) {
        this(generatorName, null);
    }

    /**
     * Creates an {@link AbstractTestDataGenerator} overriding the default test
     * data set descriptor given by the {@code test.descriptor} property or
     * {@code BASIC} if the property does not exist.
     * 
     * @param testDescriptor the test data set descriptor
     */
    public AbstractTestDataGenerator(String generatorName,
        TestDataSetDescriptor testDescriptor) {

        super(generatorName, testDescriptor);
    }

    /**
     * Generates the HSQL and filestore output. Call this method from your
     * {@code main} method as described in the class documentation. To implement
     * your test data generator, override the methods described in the class
     * documentation for {@link AbstractAutomatedFeatureTest}.
     */
    public final void generate() throws Exception {
        run();
    }

    public static AbstractTestDataGenerator getInstance(
        TestDataSetDescriptorFactory.Type testDataSetType,
        Class<? extends AbstractTestDataGenerator> tdgClass)
        throws IllegalAccessException, InstantiationException {

        AbstractTestDataGenerator tdg = null;
        String testDescriptor = System.getProperty(TEST_DESCRIPTOR_PROPERTY);
        System.setProperty(TEST_DESCRIPTOR_PROPERTY, testDataSetType.name());
        tdg = tdgClass.newInstance();
        if (testDescriptor != null) {
            System.setProperty(TEST_DESCRIPTOR_PROPERTY, testDescriptor);
        } else {
            System.clearProperty(TEST_DESCRIPTOR_PROPERTY);
        }
        return tdg;
    }
}
