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

package gov.nasa.kepler.mc;

import gov.nasa.kepler.mc.ancillary.AncillaryOperationsTest;
import gov.nasa.kepler.mc.blob.BlobOperationsTest;
import gov.nasa.kepler.mc.cm.CelestialObjectMagnitudeFilterTest;
import gov.nasa.kepler.mc.cm.CelestialObjectOperationsTest;
import gov.nasa.kepler.mc.cm.CelestialObjectParameterTest;
import gov.nasa.kepler.mc.cm.CelestialObjectParametersListFactoryTest;
import gov.nasa.kepler.mc.cm.CelestialObjectParametersTest;
import gov.nasa.kepler.mc.cm.CelestialObjectUpdaterTest;
import gov.nasa.kepler.mc.cm.KicOverrideModelExportImportTest;
import gov.nasa.kepler.mc.dr.DataAnomalyOperationsTest;
import gov.nasa.kepler.mc.dr.MjdToCadenceTest;
import gov.nasa.kepler.mc.dr.RclcPixelTimeSeriesOperationsTest;
import gov.nasa.kepler.mc.fc.TestsRaDec2PixModel;
import gov.nasa.kepler.mc.file.FileAssertTest;
import gov.nasa.kepler.mc.file.FileEqualsTest;
import gov.nasa.kepler.mc.fs.CalFsIdFactoryTest;
import gov.nasa.kepler.mc.fs.DvFsIdFactoryTest;
import gov.nasa.kepler.mc.fs.DynablackFsIdFactoryTest;
import gov.nasa.kepler.mc.fs.MrFsIdFactoryTest;
import gov.nasa.kepler.mc.fs.PaFsIdFactoryTest;
import gov.nasa.kepler.mc.fs.PdqFsIdFactoryTest;
import gov.nasa.kepler.mc.fs.PixelFsIdFactoryTest;
import gov.nasa.kepler.mc.mr.GenericReportOperationsTest;
import gov.nasa.kepler.mc.obslog.ObservingLogImporterTest;
import gov.nasa.kepler.mc.obslog.ObservingLogOperationsTest;
import gov.nasa.kepler.mc.obslog.ObservingLogXmlTest;
import gov.nasa.kepler.mc.pdc.FilledCadenceUtilTest;
import gov.nasa.kepler.mc.pi.OriginatorsModelRegistryCheckerTest;
import gov.nasa.kepler.mc.pmrf.CollateralPmrfTableTest;
import gov.nasa.kepler.mc.spice.KeplerSpacecraftClockKernelTest;
import gov.nasa.kepler.mc.spice.LeapSecondsKernelTest;
import gov.nasa.kepler.mc.spice.SpiceKernelFileReaderTest;
import gov.nasa.kepler.mc.spice.SpiceTimeTest;
import gov.nasa.kepler.mc.tps.TpsOperationsTest;
import gov.nasa.kepler.mc.tps.WeakSecondaryTest;
import gov.nasa.kepler.mc.uow.CadenceBinnerTest;
import gov.nasa.kepler.mc.uow.DeadChannelTrimmerTest;
import gov.nasa.kepler.mc.uow.DvResultUowTaskGeneratorTest;
import gov.nasa.kepler.mc.uow.KeplerIdChunkBinnerTest;
import gov.nasa.kepler.mc.uow.KicGroupBinnerTest;
import gov.nasa.kepler.mc.uow.KicGroupUowTaskGeneratorTest;
import gov.nasa.kepler.mc.uow.ModOutBinnerTest;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTaskGeneratorTest;
import gov.nasa.kepler.mc.uow.ModOutUowTaskTest;
import gov.nasa.kepler.mc.uow.ObservedKeplerIdUowTaskGeneratorTest;
import gov.nasa.kepler.mc.uow.PlanetaryCandidatesChunkUowTaskGeneratorTest;
import gov.nasa.kepler.mc.uow.SkyGroupBinnerTest;
import gov.nasa.kepler.mc.uow.TargetListChunkUowGeneratorTest;
import gov.nasa.kepler.mc.uow.TargetTableBinnerTest;
import gov.nasa.kepler.mc.vtc.VtcTimeTest;
import junit.framework.JUnit4TestAdapter;
import junit.framework.Test;
import junit.framework.TestSuite;

public class AutoTestSuite extends TestSuite {

    public static Test suite() {
        TestSuite suite = new TestSuite();
        // gov.nasa.kepler.mc
        suite.addTest(new JUnit4TestAdapter(SciencePixelOperationsTest.class));
        suite.addTest(new JUnit4TestAdapter(AncillaryOperationsTest.class));
        suite.addTest(new JUnit4TestAdapter(TargetListSetValidatorTest.class));
        suite.addTest(new JUnit4TestAdapter(ProducerTaskIdsStreamTest.class));
        suite.addTest(new JUnit4TestAdapter(FsIdsStreamTest.class));
        suite.addTest(new JUnit4TestAdapter(ParameterValuesTest.class));
        suite.addTest(new JUnit4TestAdapter(TimestampSeriesStreamTest.class));
        suite.addTest(new JUnit4TestAdapter(MatlabCallStateStreamTest.class));
        suite.addTest(new JUnit4TestAdapter(TransitOperationsTest.class));

        // gov.nasa.kepler.mc.blob
        suite.addTest(new JUnit4TestAdapter(BlobOperationsTest.class));

        // gov.nasa.kepler.mc.cm
        suite.addTest(new JUnit4TestAdapter(CelestialObjectOperationsTest.class));
        suite.addTest(new JUnit4TestAdapter(
            CelestialObjectMagnitudeFilterTest.class));
        suite.addTest(new JUnit4TestAdapter(
            CelestialObjectParametersListFactoryTest.class));
        suite.addTest(new JUnit4TestAdapter(CelestialObjectParametersTest.class));
        suite.addTest(new JUnit4TestAdapter(CelestialObjectParameterTest.class));
        suite.addTest(new JUnit4TestAdapter(CelestialObjectUpdaterTest.class));
        suite.addTest(new JUnit4TestAdapter(
            KicOverrideModelExportImportTest.class));

        // gov.nasa.kepler.mc.dr
        suite.addTest(new JUnit4TestAdapter(MjdToCadenceTest.class));
        suite.addTest(new JUnit4TestAdapter(DataAnomalyOperationsTest.class));
        suite.addTest(new JUnit4TestAdapter(
            RclcPixelTimeSeriesOperationsTest.class));

        // gov.nasa.kepler.mc.fc
        suite.addTest(new JUnit4TestAdapter(TestsRaDec2PixModel.class));
        
        // gov.nasa.kepler.mc.file
        suite.addTest(new JUnit4TestAdapter(FileAssertTest.class));
        suite.addTest(new JUnit4TestAdapter(FileEqualsTest.class));
        
        // gov.nasa.kepler.mc.fs
        suite.addTest(new JUnit4TestAdapter(PaFsIdFactoryTest.class));
        suite.addTest(new JUnit4TestAdapter(PixelFsIdFactoryTest.class));
        suite.addTest(new JUnit4TestAdapter(PdqFsIdFactoryTest.class));
        suite.addTest(new JUnit4TestAdapter(CalFsIdFactoryTest.class));
        suite.addTest(new JUnit4TestAdapter(MrFsIdFactoryTest.class));
        suite.addTest(new JUnit4TestAdapter(DvFsIdFactoryTest.class));
        suite.addTest(new JUnit4TestAdapter(DynablackFsIdFactoryTest.class));

        // gov.nasa.kepler.mc.obslog
        suite.addTest(new JUnit4TestAdapter(ObservingLogImporterTest.class));
        suite.addTest(new JUnit4TestAdapter(ObservingLogOperationsTest.class));
        suite.addTest(new JUnit4TestAdapter(ObservingLogXmlTest.class));
        
        // gov.nasa.kepler.mc.pi
        suite.addTest(new JUnit4TestAdapter(
            OriginatorsModelRegistryCheckerTest.class));
        
        // gov.nasa.kepler.mc.pmrf
        suite.addTest(new JUnit4TestAdapter(CollateralPmrfTableTest.class));

        // gov.nasa.kepler.mc.hsqldb
        // suite.addTest(new JUnit4TestAdapter(HsqlGeneratorTest.class));

        // gov.nasa.kepler.mc.mr
        suite.addTest(new JUnit4TestAdapter(GenericReportOperationsTest.class));

        // gov.nasa.kepler.mc.spice
        suite.addTest(new JUnit4TestAdapter(
            KeplerSpacecraftClockKernelTest.class));
        suite.addTest(new JUnit4TestAdapter(LeapSecondsKernelTest.class));
        suite.addTest(new JUnit4TestAdapter(SpiceKernelFileReaderTest.class));
        suite.addTest(new JUnit4TestAdapter(SpiceTimeTest.class));

        // gov.nasa.kepler.mc.tps
        suite.addTest(new JUnit4TestAdapter(TpsOperationsTest.class));
        suite.addTest(new JUnit4TestAdapter(WeakSecondaryTest.class));

        // gov.nasa.kepler.mc.uow
        suite.addTest(new JUnit4TestAdapter(ModOutBinnerTest.class));
        suite.addTest(new JUnit4TestAdapter(CadenceBinnerTest.class));
        suite.addTest(new JUnit4TestAdapter(KicGroupBinnerTest.class));
        suite.addTest(new JUnit4TestAdapter(TargetTableBinnerTest.class));
        suite.addTest(new JUnit4TestAdapter(SkyGroupBinnerTest.class));
        suite.addTest(new JUnit4TestAdapter(KeplerIdChunkBinnerTest.class));
        suite.addTest(new JUnit4TestAdapter(
            ModOutCadenceUowTaskGeneratorTest.class));
        suite.addTest(new JUnit4TestAdapter(DeadChannelTrimmerTest.class));
        suite.addTest(new JUnit4TestAdapter(
            TargetListChunkUowGeneratorTest.class));
        suite.addTest(new JUnit4TestAdapter(
            ObservedKeplerIdUowTaskGeneratorTest.class));
        suite.addTest(new JUnit4TestAdapter(
            PlanetaryCandidatesChunkUowTaskGeneratorTest.class));
        suite.addTest(new JUnit4TestAdapter(DvResultUowTaskGeneratorTest.class));
        suite.addTest(new JUnit4TestAdapter(KicGroupUowTaskGeneratorTest.class));
        suite.addTest(new JUnit4TestAdapter(ModOutUowTaskTest.class));

        // gov.nasa.kepler.mc.vtc
        suite.addTest(new JUnit4TestAdapter(VtcTimeTest.class));

        // PDC
        suite.addTest(new JUnit4TestAdapter(FilledCadenceUtilTest.class));
        return suite;
    }
}
