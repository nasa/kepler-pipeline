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

package gov.nasa.kepler.fs;

import gov.nasa.kepler.fs.api.CosmicRaySeriesTest;
import gov.nasa.kepler.fs.api.FsIdTest;
import gov.nasa.kepler.fs.api.IntervalFilterTest;
import gov.nasa.kepler.fs.api.TimeSeriesTest;
import gov.nasa.kepler.fs.api.gen.ImportGeneratorTest;
import gov.nasa.kepler.fs.api.gen.MethodDataTest;
import gov.nasa.kepler.fs.api.gen.UtilsTest;
import gov.nasa.kepler.fs.cli.AddressTranslatorTest;
import gov.nasa.kepler.fs.cli.CheckerTest;
import gov.nasa.kepler.fs.cli.Clitest;
import gov.nasa.kepler.fs.cli.LsAndExtractorTest;
import gov.nasa.kepler.fs.cli.TimeSeriesMatAndXmlFileExporterTest;
import gov.nasa.kepler.fs.client.BlobCorrectnessTest;
import gov.nasa.kepler.fs.client.ComboTest;
import gov.nasa.kepler.fs.client.ImplicitTransactionLifecycleTest;
import gov.nasa.kepler.fs.client.LocalTimeSeriesTest;
import gov.nasa.kepler.fs.client.LocalTransactionTest;
import gov.nasa.kepler.fs.client.MjdTimeSeriesCorrectnessTest;
import gov.nasa.kepler.fs.client.QueryTest;
import gov.nasa.kepler.fs.client.RAMCosmicRayCorrectnessTest;
import gov.nasa.kepler.fs.client.RamTimeSeriesTest;
import gov.nasa.kepler.fs.client.XATest;
import gov.nasa.kepler.fs.client.util.DiskFileStoreClientTest;
import gov.nasa.kepler.fs.client.util.PersistableXidThreadLocalTest;
import gov.nasa.kepler.fs.perf.DelayModelTest;
import gov.nasa.kepler.fs.perf.StackTraceDumperTest;
import gov.nasa.kepler.fs.query.QueryEvalulatorTest;
import gov.nasa.kepler.fs.server.LongEncoderTest;
import gov.nasa.kepler.fs.server.ThrottleTest;
import gov.nasa.kepler.fs.server.TimeSeriesBackendPackageTest;
import gov.nasa.kepler.fs.server.TimeSeriesIntervalIteratorTest;
import gov.nasa.kepler.fs.server.TimeSeriesMergeIntervalIteratorTest;
import gov.nasa.kepler.fs.server.TypedRangeMergeTest;
import gov.nasa.kepler.fs.server.index.PersistentBitSetTest;
import gov.nasa.kepler.fs.server.index.PersistentSequenceTest;
import gov.nasa.kepler.fs.server.index.blinktree.BlinkNodeTest;
import gov.nasa.kepler.fs.server.index.blinktree.BlinkTreeTest;
import gov.nasa.kepler.fs.server.index.blinktree.NodeLockFactoryTest;
import gov.nasa.kepler.fs.server.index.btree.BTreeInMemoryTest;
import gov.nasa.kepler.fs.server.index.btree.BTreeOnDiskTest;
import gov.nasa.kepler.fs.server.index.btree.DiskNodeIOTest;
import gov.nasa.kepler.fs.server.index.btree.NodeTest;
import gov.nasa.kepler.fs.server.jmx.TransactionMonitoringTest;
import gov.nasa.kepler.fs.server.journal.JournalTest;
import gov.nasa.kepler.fs.server.nc.MetaSpaceTest;
import gov.nasa.kepler.fs.server.nc.NonContiguousReadWriteTest;
import gov.nasa.kepler.fs.server.scheduler.SchedulerTest;
import gov.nasa.kepler.fs.server.xfiles.DirectoryHashFactoryTest;
import gov.nasa.kepler.fs.server.xfiles.FileTransactionManagerTest;
import gov.nasa.kepler.fs.server.xfiles.OfflineExtractorTest;
import gov.nasa.kepler.fs.server.xfiles.OneToManyRouterTest;
import gov.nasa.kepler.fs.server.xfiles.OperationTest;
import gov.nasa.kepler.fs.server.xfiles.RecoveryCoordinatorTest;
import gov.nasa.kepler.fs.server.xfiles.RecoveryUtilsTest;
import gov.nasa.kepler.fs.server.xfiles.ScheduledReadTest;
import gov.nasa.kepler.fs.server.xfiles.TransactionalFileOpenerTest;
import gov.nasa.kepler.fs.server.xfiles.TransactionalMjdTimeSeriesTest;
import gov.nasa.kepler.fs.server.xfiles.TransactionalRandomAccessFileTest;
import gov.nasa.kepler.fs.server.xfiles.TransactionalStreamFileTest;
import gov.nasa.kepler.fs.server.xfiles.XFilesCheckerTest;
import gov.nasa.kepler.fs.storage.ContainerFileTest;
import gov.nasa.kepler.fs.storage.DirectoryHashTest;
import gov.nasa.kepler.fs.storage.FsIdPathLocatorTest;
import gov.nasa.kepler.fs.storage.RandomAccessAllocatorTest;
import gov.nasa.kepler.fs.transport.TransportTest;
import gov.nasa.kepler.io.DataInputOutputStreamTest;
import junit.framework.JUnit4TestAdapter;
import junit.framework.Test;
import junit.framework.TestSuite;

import org.junit.runner.RunWith;
import org.junit.runners.AllTests;

@RunWith(AllTests.class)
public class AutoTestSuite {
    public static Test suite() {

        TestSuite suite = new TestSuite();
        suite.addTest(new JUnit4TestAdapter(JournalTest.class));
        suite.addTest(new JUnit4TestAdapter(OneToManyRouterTest.class));
        suite.addTest(new JUnit4TestAdapter(AddressTranslatorTest.class));
        suite.addTest(new JUnit4TestAdapter(DelayModelTest.class));
        suite.addTest(new JUnit4TestAdapter(FsIdPathLocatorTest.class));
        suite.addTest(new JUnit4TestAdapter(BlinkTreeTest.class));
        suite.addTest(new JUnit4TestAdapter(BlinkNodeTest.class));
        suite.addTest(new JUnit4TestAdapter(ImplicitTransactionLifecycleTest.class));
        suite.addTest(new JUnit4TestAdapter(TransactionalFileOpenerTest.class));
        suite.addTest(new JUnit4TestAdapter(DumpMyFieldsTest.class));
        suite.addTest(new JUnit4TestAdapter(StackTraceDumperTest.class));
        suite.addTest(new JUnit4TestAdapter(ThrottleTest.class));
        suite.addTest(new JUnit4TestAdapter(OperationTest.class));
        suite.addTest(new JUnit4TestAdapter(DataInputOutputStreamTest.class));
        suite.addTest(new JUnit4TestAdapter(TimeSeriesMergeIntervalIteratorTest.class));
        suite.addTest(new JUnit4TestAdapter(IntervalFilterTest.class));
        suite.addTest(new JUnit4TestAdapter(LongEncoderTest.class));
        suite.addTest(new JUnit4TestAdapter(DiskFileStoreClientTest.class));
        suite.addTest(new JUnit4TestAdapter(
            TimeSeriesIntervalIteratorTest.class));
        suite.addTest(new JUnit4TestAdapter(BTreeOnDiskTest.class));
        suite.addTest(new JUnit4TestAdapter(DiskNodeIOTest.class));
        suite.addTest(new JUnit4TestAdapter(NodeTest.class));

        suite.addTest(new JUnit4TestAdapter(BTreeInMemoryTest.class));
        suite.addTest(new JUnit4TestAdapter(CosmicRaySeriesTest.class));
        suite.addTest(new JUnit4TestAdapter(OfflineExtractorTest.class));
        suite.addTest(new JUnit4TestAdapter(ScheduledReadTest.class));
        suite.addTest(new JUnit4TestAdapter(TransactionMonitoringTest.class));
        suite.addTest(new JUnit4TestAdapter(
            TransactionalRandomAccessFileTest.class));
        suite.addTest(new JUnit4TestAdapter(DirectoryHashTest.class));
        suite.addTest(new JUnit4TestAdapter(RamTimeSeriesTest.class));
        suite.addTest(new JUnit4TestAdapter(LocalTimeSeriesTest.class));
        suite.addTest(new JUnit4TestAdapter(TypedRangeMergeTest.class));
        suite.addTest(new JUnit4TestAdapter(FsIdTest.class));
        suite.addTest(new JUnit4TestAdapter(TimeSeriesTest.class));
        suite.addTest(new JUnit4TestAdapter(MetaSpaceTest.class));

        suite.addTest(new JUnit4TestAdapter(NonContiguousReadWriteTest.class));
        suite.addTest(new JUnit4TestAdapter(TimeSeriesBackendPackageTest.class));
        suite.addTest(new JUnit4TestAdapter(BlobCorrectnessTest.class));

        suite.addTest(new JUnit4TestAdapter(TransactionalStreamFileTest.class));
        suite.addTest(new JUnit4TestAdapter(MethodDataTest.class));
        suite.addTest(new JUnit4TestAdapter(ImportGeneratorTest.class));

        suite.addTest(new JUnit4TestAdapter(Clitest.class));
        

       suite.addTest(new JUnit4TestAdapter(LocalTransactionTest.class));
        suite.addTest(new JUnit4TestAdapter(FileTransactionManagerTest.class));
        suite.addTest(new JUnit4TestAdapter(DirectoryHashFactoryTest.class));
        suite.addTest(new JUnit4TestAdapter(RecoveryUtilsTest.class));
        suite.addTest(new JUnit4TestAdapter(RecoveryCoordinatorTest.class));

        suite.addTest(new JUnit4TestAdapter(XATest.class));

        suite.addTest(new JUnit4TestAdapter(TransportTest.class));
        suite.addTest(new JUnit4TestAdapter(UtilsTest.class));

        suite.addTest(new JUnit4TestAdapter(PersistentSequenceTest.class));
        suite.addTest(new JUnit4TestAdapter(RandomAccessAllocatorTest.class));
        suite.addTest(new JUnit4TestAdapter(ContainerFileTest.class));
        suite.addTest(new JUnit4TestAdapter(PersistentBitSetTest.class));

        suite.addTest(new JUnit4TestAdapter(PersistableXidThreadLocalTest.class));
        suite.addTest(new JUnit4TestAdapter(XFilesCheckerTest.class));
        suite.addTest(new JUnit4TestAdapter(LsAndExtractorTest.class));

        suite.addTest(new JUnit4TestAdapter(CheckerTest.class));

        suite.addTest(new JUnit4TestAdapter(
            TransactionalMjdTimeSeriesTest.class));

        suite.addTest(new JUnit4TestAdapter(MjdTimeSeriesCorrectnessTest.class));

        suite.addTest(new JUnit4TestAdapter(RAMCosmicRayCorrectnessTest.class));
        
        //This test can no longer be performed deterministically.
//        suite.addTest(new JUnit4TestAdapter(OverloadTest.class));
        
        suite.addTest(new JUnit4TestAdapter(ComboTest.class));
        
        suite.addTest(new JUnit4TestAdapter(TimeSeriesMatAndXmlFileExporterTest.class));
        
        suite.addTest(new JUnit4TestAdapter(QueryTest.class));

        suite.addTest(new JUnit4TestAdapter(QueryEvalulatorTest.class));
   
        suite.addTest(new JUnit4TestAdapter(SchedulerTest.class));

        suite.addTest(new JUnit4TestAdapter(NodeLockFactoryTest.class));
        
        return suite;
    }

}