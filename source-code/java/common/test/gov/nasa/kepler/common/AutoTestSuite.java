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

package gov.nasa.kepler.common;

import gov.nasa.kepler.common.concurrent.ActorTest;
import gov.nasa.kepler.common.concurrent.ServerLockTest;
import gov.nasa.kepler.common.file.DirectoryCopyVisitorTest;
import gov.nasa.kepler.common.file.Md5SumTest;
import gov.nasa.kepler.common.intervals.CadenceBlobCalculatorTest;
import gov.nasa.kepler.common.intervals.DoubleIntervalSetTest;
import gov.nasa.kepler.common.os.IOCheckerTest;
import gov.nasa.kepler.common.persistable.MatPersistableOutputStreamTest;
import gov.nasa.kepler.common.persistable.SdfPersistableOutputStreamTest;
import gov.nasa.kepler.common.pi.ModuleOutputListsParametersTest;
import gov.nasa.kepler.common.ranges.RangeTest;
import gov.nasa.kepler.common.ranges.RangesTest;
import gov.nasa.spiffy.common.pojo.PojoTestTest;
import junit.framework.JUnit4TestAdapter;
import junit.framework.Test;
import junit.framework.TestSuite;

public class AutoTestSuite extends TestSuite {

    public static Test suite() {
        TestSuite suite = new TestSuite();

        suite.addTest(new JUnit4TestAdapter(InvokerTransformerTest.class));
        suite.addTest(new JUnit4TestAdapter(ServerLockTest.class));
        suite.addTest(new JUnit4TestAdapter(StreamingIteratorTest.class));
        suite.addTest(new JUnit4TestAdapter(ActorTest.class));
        suite.addTest(new JUnit4TestAdapter(BinPackerTest.class));
        suite.addTest(new JUnit4TestAdapter(IOCheckerTest.class));
        suite.addTest(new JUnit4TestAdapter(AsciiCleanWriterTest.class));
        suite.addTest(new JUnit4TestAdapter(CadenceBlobCalculatorTest.class));
        suite.addTest(new JUnit4TestAdapter(ConcurrentUtilTest.class));
        suite.addTest(new JUnit4TestAdapter(ConfigMapDerivedValuesTest.class));
        suite.addTest(new JUnit4TestAdapter(DateUtilsTest.class));
        suite.addTest(new JUnit4TestAdapter(
            DelimiterSeparatedStringListTest.class));
        suite.addTest(new JUnit4TestAdapter(DirectoryCopyVisitorTest.class));
        suite.addTest(new JUnit4TestAdapter(DoubleIntervalSetTest.class));
        suite.addTest(new JUnit4TestAdapter(EnumListTest.class));
        suite.addTest(new JUnit4TestAdapter(FitsDiffTest.class));
        suite.addTest(new JUnit4TestAdapter(FitsUtilsTest.class));
        suite.addTest(new JUnit4TestAdapter(ListChunkIteratorTest.class));
        suite.addTest(new JUnit4TestAdapter(LruCacheTest.class));
        suite.addTest(new JUnit4TestAdapter(MatlabDateFormatterTest.class));
        suite.addTest(new JUnit4TestAdapter(MatlabEnumFetcherTest.class));
        suite.addTest(new JUnit4TestAdapter(MatPersistableOutputStreamTest.class));
        suite.addTest(new JUnit4TestAdapter(Md5SumTest.class));
        suite.addTest(new JUnit4TestAdapter(MimeTypeTest.class));
        suite.addTest(new JUnit4TestAdapter(ModifiedJulianDateTest.class));
        suite.addTest(new JUnit4TestAdapter(ModuleOutputListsParametersTest.class));
        suite.addTest(new JUnit4TestAdapter(PojoTestTest.class));
        suite.addTest(new JUnit4TestAdapter(RangeTest.class));
        suite.addTest(new JUnit4TestAdapter(RangesTest.class));
        suite.addTest(new JUnit4TestAdapter(SdfPersistableOutputStreamTest.class));
        suite.addTest(new JUnit4TestAdapter(SortedMapSortedKeySetTest.class));
        suite.addTest(new JUnit4TestAdapter(TargetManagementConstantsTest.class));
        suite.addTest(new JUnit4TestAdapter(WrappingInvocationHandlerTest.class));

        // Requires {DY,}LD_LIBRARY_PATH=$SOC_CODE_ROOT/dist/lib
        // suite.addTest(new JUnit4TestAdapter(HardlinkTest.class));

        return suite;
    }
}
