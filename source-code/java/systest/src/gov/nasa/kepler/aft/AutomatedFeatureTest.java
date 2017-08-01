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

import gov.nasa.kepler.aft.descriptor.TestDataSetDescriptorFactory;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Test;

/**
 * Superclass for classes that provide Automated Feature Tests (AFTs).
 * <p>
 * See the class documentation for {@link AbstractAutomatedFeatureTest} for the
 * methods that you should override to create your AFT.
 * <p>
 * When naming your first class in a package, use the convention <i>Csci</i>
 * {@code NominalTest} (for example, SggenNominalTest). If you create additional
 * classes, replace {@code Nominal} with an appropriate descriptive word.
 * <p>
 * In your constructor, call {@code super(CsciPipelineModule.MODULE_NAME,
 * "Nominal")}. Replace Nominal as necessary. For example, the test in the
 * previous example calls {@code super(SkyGroupGenPipelineModule.MODULE_NAME,
 * "Nominal");}
 * <p>
 * Your test will either run Java code or execute a MATLAB pipeline module. AFTs
 * are unusual for unit tests in that assertions aren't made. Rather, a test
 * succeeds as long as it doesn't fail.
 * 
 * @author Forrest Girouard
 * @author tklaus
 * @author Bill Wohler
 */
public abstract class AutomatedFeatureTest extends AbstractAutomatedFeatureTest {

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(AutomatedFeatureTest.class);

    /**
     * A property ({@value #AFT_ETEM_DIR_PROPERTY}) whose value is the root
     * directory of the etem outputs. If this property is not set, then {@code
     * /path/to/aft/etem/}<i>test.descriptor</i>{@code /etem} is used.
     */
    public static final String AFT_ETEM_DIR_PROPERTY = "aft.etemDir";

    /**
     * A property ({@value #AFT_LOCAL_DATA_DIR_PROPERTY}) whose value is the
     * root of the data repo. If this property is not set, then the value of
     * {@code SOC_DATA_ROOT} is used; otherwise {@code /path/to/rec} is
     * used.
     */
    public static final String AFT_LOCAL_DATA_DIR_PROPERTY = "aft.localDataDir";

    /**
     * Creates an {@link AutomatedFeatureTest}. The parameters are used to form
     * the name of output directory. For example, if they contain {@code pa} and
     * {@code Nominal}, then the AFT writes (by default) to {@code
     * /path/to/aft/pa/Nominal-BASIC}.
     * 
     * @param dirName the root directory of the AFT output directory
     * @param testName the basename of the AFT output directory
     */
    public AutomatedFeatureTest(String dirName, String testName) {
        super(dirName, testName);
    }

    /**
     * Runs the AFT. Do not create {@code @Test} methods in your AFTs; override
     * the methods described in the class documentation for
     * {@link AbstractAutomatedFeatureTest} instead.
     */
    @Test
    public final void test() throws Exception {
        run();
    }

    /**
     * Create an instance of the given {@code aftClass} in the context of the
     * given {@code testDataSetType}.
     * 
     * @param testDataSetType the data set type
     * @param aftClass the test class
     * @return an instance of the given {@code aftClass}
     * @exception IllegalAccessException if the class specified by
     * {@value #AFT_EXISTING_HSQLDB_PROPERTY} or its nullary constructor is not
     * accessible
     * @exception InstantiationException if the class specified by
     * {@value #AFT_EXISTING_HSQLDB_PROPERTY} represents an abstract class, an
     * interface, an array class, a primitive type, or void; or if the class has
     * no nullary constructor; or if the instantiation fails for some other
     * reason
     */
    static AutomatedFeatureTest getInstance(
        TestDataSetDescriptorFactory.Type testDataSetType,
        Class<? extends AutomatedFeatureTest> aftClass)
        throws IllegalAccessException, InstantiationException {

        AutomatedFeatureTest aft = null;
        String testDescriptor = System.getProperty(TEST_DESCRIPTOR_PROPERTY);
        System.setProperty(TEST_DESCRIPTOR_PROPERTY, testDataSetType.name());
        aft = aftClass.newInstance();
        if (testDescriptor != null) {
            System.setProperty(TEST_DESCRIPTOR_PROPERTY, testDescriptor);
        } else {
            System.clearProperty(TEST_DESCRIPTOR_PROPERTY);
        }
        return aft;
    }
}
