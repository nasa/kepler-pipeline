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

package gov.nasa.spiffy.common;

import gov.nasa.spiffy.common.collect.ArrayUtilsTest;
import gov.nasa.spiffy.common.intervals.IntervalSetTest;
import gov.nasa.spiffy.common.io.FileCopyVisitorTest;
import gov.nasa.spiffy.common.io.FileUtilTest;
import gov.nasa.spiffy.common.io.FindFileTest;
import gov.nasa.spiffy.common.io.ParallelDirectoryVisitorTest;
import gov.nasa.spiffy.common.jmx.JmxTest;
import gov.nasa.spiffy.common.lang.StringUtilsTest;
import gov.nasa.spiffy.common.metrics.CounterMetricTest;
import gov.nasa.spiffy.common.metrics.IntervalMetricTest;
import gov.nasa.spiffy.common.metrics.MetricTest;
import gov.nasa.spiffy.common.metrics.ValueMetricTest;
import gov.nasa.spiffy.common.os.CpuInfoTest;
import gov.nasa.spiffy.common.os.MemInfoTest;
import gov.nasa.spiffy.common.os.OperatingSystemTypeTest;
import gov.nasa.spiffy.common.os.ProcInfoTest;
import gov.nasa.spiffy.common.os.ProcessUtilsTest;
import gov.nasa.spiffy.common.persistable.BinFieldNodeTest;
import gov.nasa.spiffy.common.persistable.BinaryPersistableStreamTest;
import gov.nasa.spiffy.common.persistable.ClassWalkerTest;
import gov.nasa.spiffy.common.persistable.PersistableUtilsTest;

import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import org.junit.runners.Suite.SuiteClasses;

@RunWith(Suite.class)
@SuiteClasses({
    // gov.nasa.spiffy.common
    StringUtilsTest.class,
    
    // gov.nasa.spiffy.common.collect
    ArrayUtilsTest.class,
    
    // gov.nasa.spiffy.common.intervals
    IntervalSetTest.class,
    
    // gov.nasa.spiffy.common.io
    FileCopyVisitorTest.class,
    FileUtilTest.class,
    FindFileTest.class,
    ParallelDirectoryVisitorTest.class,
    
    // gov.nasa.spiffy.common.jmx
    JmxTest.class,
    
    // gov.nasa.spiffy.common.metrics
    CounterMetricTest.class,
    IntervalMetricTest.class,
    MetricTest.class,
    ValueMetricTest.class,
    
    // gov.nasa.spiffy.common.os
    CpuInfoTest.class,
    MemInfoTest.class,
    OperatingSystemTypeTest.class,
    ProcessUtilsTest.class,
    ProcInfoTest.class,
    
    // gov.nasa.spiffy.common.persistable
    BinaryPersistableStreamTest.class,
    BinFieldNodeTest.class,
    ClassWalkerTest.class,
    PersistableUtilsTest.class
})
public class AutoTestSuite {
}
