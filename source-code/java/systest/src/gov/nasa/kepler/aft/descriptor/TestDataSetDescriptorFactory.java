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

package gov.nasa.kepler.aft.descriptor;

import gov.nasa.kepler.aft.AutomatedFeatureTest;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * A factory for obtaining test data set descriptors.
 */
public class TestDataSetDescriptorFactory {

    /**
     * An enum of available test data set descriptors. This enum maps strings
     * used in configuration files to instances of {@link TestDataSetDescriptor}
     * . This enum contains all currently supported types. Two enum values can
     * be associated with each other; for example, a short cadence descriptor is
     * associated with a long cadence descriptor. The associated descriptor can
     * be accessed by calling the enum's {@link #getSignificantOther()} method.
     * The documentation for each descriptor refers to the implementing class,
     * as well as the associated class, if any.
     */
    public enum Type {
        /**
         * Used for monthly processing ({@link BasicTestDataSetDescriptor},
         * {@link ScBasicTestDataSetDescriptor}).
         */
        BASIC(BasicTestDataSetDescriptor.class,
            ScBasicTestDataSetDescriptor.class),

        /**
         * All module and outputs ({@link AllModOutTestDataSetDescriptor}).
         */
        ALL_MOD_OUT(AllModOutTestDataSetDescriptor.class),

        /**
         * Defines two module outputs that are diametrically opposed from one
         * another ({@link DualModOutTestDataSetDescriptor},
         * {@link ScDualModOutTestDataSetDescriptor}).
         */
        DUAL_MOD_OUT(DualModOutTestDataSetDescriptor.class,
            ScDualModOutTestDataSetDescriptor.class),

        /**
         * A short cadence version of BASIC (
         * {@link ScBasicTestDataSetDescriptor},
         * {@link BasicTestDataSetDescriptor}).
         */
        SC_BASIC(ScBasicTestDataSetDescriptor.class,
            BasicTestDataSetDescriptor.class),

        /**
         * A short cadence version of DUAL_MOD_OUT (
         * {@link ScDualModOutTestDataSetDescriptor},
         * {@link DualModOutTestDataSetDescriptor}).
         */
        SC_DUAL_MOD_OUT(ScDualModOutTestDataSetDescriptor.class,
            DualModOutTestDataSetDescriptor.class),

        /**
         * A dual mod/out version of PDQ (
         * {@link DualModOutPdqTestDataSetDescriptor}).
         */
        DUAL_MOD_OUT_PDQ(DualModOutPdqTestDataSetDescriptor.class),

        /**
         * A tps version of BASIC ({@link TpsBasicTestDataSetDescriptor}).
         */
        TPS_BASIC(TpsBasicTestDataSetDescriptor.class),

        /**
         * Describes a pdq-specific data set for a single mod/out (
         * {@link PdqTestDataSetDescriptor}).
         */
        PDQ(PdqTestDataSetDescriptor.class);

        private final Pair<Class<? extends TestDataSetDescriptor>, Class<? extends TestDataSetDescriptor>> classes;

        private Type(Class<? extends TestDataSetDescriptor> clazz) {
            this(clazz, null);
        }

        private Type(Class<? extends TestDataSetDescriptor> clazz,
            Class<? extends TestDataSetDescriptor> significantOther) {

            classes = Pair.<Class<? extends TestDataSetDescriptor>, Class<? extends TestDataSetDescriptor>> of(
                clazz, significantOther);
        }

        /**
         * Returns the implementing class of this descriptor.
         */
        public Class<? extends TestDataSetDescriptor> getClazz() {
            return getClasses().left;
        }

        /**
         * Returns the associated class of this descriptor.
         */
        public Class<? extends TestDataSetDescriptor> getSignificantOther() {
            return getClasses().right;
        }

        /**
         * Returns both the implementing class of this descriptor as well as the
         * associated class.
         */
        protected Pair<Class<? extends TestDataSetDescriptor>, Class<? extends TestDataSetDescriptor>> getClasses() {
            return classes;
        }

        /**
         * Returns the enum constant of this type with the specified test
         * descriptor.
         */
        public static Type valueOf(TestDataSetDescriptor testDescriptor) {
            // TODO Refactor valueOf with the following
            // return valueOf(testDescriptor.getClass());
            for (Type t : values()) {
                if (t.getClazz() == testDescriptor.getClass()) {
                    return t;
                }
            }
            throw new IllegalStateException("Unknown class "
                + testDescriptor.getClass());
        }

        /**
         * Returns the enum constant of this type with the specified test
         * descriptor class.
         */
        public static Type valueOf(
            Class<? extends TestDataSetDescriptor> testDescriptorClass) {
            for (Type t : values()) {
                if (t.getClazz() == testDescriptorClass) {
                    return t;
                }
            }
            throw new IllegalStateException("Unknown class "
                + testDescriptorClass);
        }
    }

    private static final Log log = LogFactory.getLog(TestDataSetDescriptorFactory.class);

    /**
     * Creates a test data set descriptor.
     * 
     * @param name the name of the descriptor
     * @return a new instance of the descriptor
     * 
     * @exception IllegalAccessException if the class or its nullary constructor
     * is not accessible
     * @exception InstantiationException if this {@code Class} represents an
     * abstract class, an interface, an array class, a primitive type, or void;
     * or if the class has no nullary constructor; or if the instantiation fails
     * for some other reason
     */
    public static TestDataSetDescriptor createTestDescriptor(String name)
        throws InstantiationException, IllegalAccessException {

        Type type = Type.valueOf(name);
        Class<? extends TestDataSetDescriptor> clazz = type.getClazz();
        TestDataSetDescriptor instance = clazz.newInstance();
        return instance;
    }

    /**
     * Returns the name of the given test data set descriptor. This is the
     * string representation of the descriptor's type (for example, BASIC).
     * 
     * @param testDescriptor the test data set descriptor
     * @return the name of the descriptor, a string
     */
    public static String getName(TestDataSetDescriptor testDescriptor) {
        return Type.valueOf(testDescriptor)
            .toString();
    }

    /**
     * Returns the path to the local data repo directory for the given test data
     * set descriptor. The path is determined as follows:
     * <ol>
     * <li>The value of the property {@code aft.localDataDir}, or
     * <li>The value of the environment variable SOC_DATA_ROOT, or
     * <li> {@code /path/to/rec}
     * </ol>
     * 
     * @param testDescriptor the test data set descriptor (not currently used in
     * the path determination)
     * @return the location of the data repo directory
     */
    public static String getLocalDataDir(TestDataSetDescriptor testDescriptor) {

        Configuration config = ConfigurationServiceFactory.getInstance();
        String path = config.getString(
            AutomatedFeatureTest.AFT_LOCAL_DATA_DIR_PROPERTY,
            SocEnvVars.getLocalDataDir());

        log.info(String.format("%s config property has value %s",
            AutomatedFeatureTest.AFT_LOCAL_DATA_DIR_PROPERTY, path));

        return path;
    }

    /**
     * Returns the path to the etem directory for the given test data set
     * descriptor. The path is determined as follows:
     * <ol>
     * <li>The value of the property {@code aft.etemDir}, or
     * <li>The concatenation of the following:
     * <ol>
     * <li>The content of the environment variable SOC_AFT_ROOT or {@code
     * /path/to/aft}
     * <li>"/"
     * <li>"etem"
     * <li>"/"
     * <li>The name of the descriptor (for example, BASIC)
     * <li>"/"
     * <li>"etem"
     * </ol>
     * </ol>
     * 
     * @param testDescriptor the test data set descriptor
     * @return the location of the etem directory
     */
    public static String getEtemDir(TestDataSetDescriptor testDescriptor) {

        Configuration config = ConfigurationServiceFactory.getInstance();
        String path = config.getString(
            AutomatedFeatureTest.AFT_ETEM_DIR_PROPERTY,
            (SocEnvVars.getLocalAftDir() + File.separator + "etem"
                + File.separator + getName(testDescriptor) + File.separator + "etem"));

        log.info(String.format("%s config property has value %s",
            AutomatedFeatureTest.AFT_ETEM_DIR_PROPERTY, path));

        return path;
    }
}
