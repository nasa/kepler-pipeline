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

package gov.nasa.kepler.systest;

import gov.nasa.kepler.dev.seed.QuarterlyPipelineLauncherParametersTest;
import gov.nasa.kepler.ops.kid.CsvWriterTest;
import gov.nasa.kepler.ops.kid.EnglishFormatterTest;
import gov.nasa.kepler.ops.kid.InvestigationTypeListFactoryTest;
import gov.nasa.kepler.ops.kid.InvestigationWarningsGeneratorTest;
import gov.nasa.kepler.ops.kid.InvestigationsReaderWriterTest;
import gov.nasa.kepler.ops.kid.InvestigationsReportWriterTest;
import gov.nasa.kepler.ops.kid.KidGeneratorTest;
import gov.nasa.kepler.ops.kid.KidRuleAbstractTest;
import gov.nasa.kepler.ops.kid.KidRuleBaseInvestigationsExistTest;
import gov.nasa.kepler.ops.kid.KidRuleCollaboratorsTest;
import gov.nasa.kepler.ops.kid.KidRuleEndTest;
import gov.nasa.kepler.ops.kid.KidRuleLeaderTest;
import gov.nasa.kepler.ops.kid.KidRuleStartTest;
import gov.nasa.kepler.ops.kid.KidRuleTitleTest;
import gov.nasa.kepler.ops.kid.KidRuleTypeTest;
import gov.nasa.kepler.ops.kid.KtcReaderTest;
import gov.nasa.kepler.systest.flight.CadenceFitsTrimmerTest;
import gov.nasa.kepler.systest.flight.PmrfTrimmerTest;
import gov.nasa.kepler.systest.sbt.data.EnumMapFactoryTest;
import gov.nasa.kepler.systest.sbt.data.FsIdPipelineProductFilterTest;
import gov.nasa.kepler.systest.sbt.data.FsIdToTimeSeriesMapFactoryTest;
import gov.nasa.kepler.systest.sbt.data.IndexingSchemeConverterToOneBasedTest;
import gov.nasa.kepler.systest.sbt.data.PipelineProductListsTest;
import gov.nasa.kepler.systest.sbt.data.PixelCoordinateSystemConverterToOneBasedTest;
import gov.nasa.kepler.systest.sbt.data.PixelCoordinateSystemConverterToZeroBasedTest;
import gov.nasa.kepler.systest.sbt.data.SbtAncillaryOperationsTest;
import gov.nasa.kepler.systest.sbt.data.SbtBlobSeriesOperationsTest;
import gov.nasa.kepler.systest.sbt.data.SbtCadenceRangeDataMergerTest;
import gov.nasa.kepler.systest.sbt.data.SbtCsciOperationsTest;
import gov.nasa.kepler.systest.sbt.data.SbtDataOperationsTest;
import gov.nasa.kepler.systest.tad.TadTriggerValidatorTest;
import gov.nasa.kepler.systest.tad.TargetListSetVersionerTest;
import junit.framework.JUnit4TestAdapter;
import junit.framework.Test;
import junit.framework.TestSuite;

public class AutoTestSuite extends TestSuite {

    public static Test suite() {
        TestSuite suite = new TestSuite();

        suite.addTest(new JUnit4TestAdapter(CadenceFitsTrimmerTest.class));
        suite.addTest(new JUnit4TestAdapter(PmrfTrimmerTest.class));
        // suite.addTest(new JUnit4TestAdapter(
        // MatlabWrapperImportClassesExistTest.class));
        suite.addTest(new JUnit4TestAdapter(
            RunjavaNicknamesClassesExistTest.class));
        suite.addTest(new JUnit4TestAdapter(TadTriggerValidatorTest.class));
        suite.addTest(new JUnit4TestAdapter(TargetListSetVersionerTest.class));

        suite.addTest(new JUnit4TestAdapter(KidGeneratorTest.class));
        suite.addTest(new JUnit4TestAdapter(CsvWriterTest.class));
        suite.addTest(new JUnit4TestAdapter(EnglishFormatterTest.class));
        suite.addTest(new JUnit4TestAdapter(
            InvestigationsReaderWriterTest.class));
        suite.addTest(new JUnit4TestAdapter(
            InvestigationsReportWriterTest.class));
        suite.addTest(new JUnit4TestAdapter(
            InvestigationTypeListFactoryTest.class));
        suite.addTest(new JUnit4TestAdapter(
            InvestigationWarningsGeneratorTest.class));
        suite.addTest(new JUnit4TestAdapter(KidRuleAbstractTest.class));
        suite.addTest(new JUnit4TestAdapter(
            KidRuleBaseInvestigationsExistTest.class));
        suite.addTest(new JUnit4TestAdapter(KidRuleCollaboratorsTest.class));
        suite.addTest(new JUnit4TestAdapter(KidRuleLeaderTest.class));
        suite.addTest(new JUnit4TestAdapter(KidRuleStartTest.class));
        suite.addTest(new JUnit4TestAdapter(KidRuleEndTest.class));
        suite.addTest(new JUnit4TestAdapter(KidRuleTitleTest.class));
        suite.addTest(new JUnit4TestAdapter(KidRuleTypeTest.class));
        suite.addTest(new JUnit4TestAdapter(KtcReaderTest.class));

        suite.addTest(new JUnit4TestAdapter(
            FsIdToTimeSeriesMapFactoryTest.class));
        suite.addTest(new JUnit4TestAdapter(
            IndexingSchemeConverterToOneBasedTest.class));
        suite.addTest(new JUnit4TestAdapter(
            PixelCoordinateSystemConverterToOneBasedTest.class));
        suite.addTest(new JUnit4TestAdapter(
            PixelCoordinateSystemConverterToZeroBasedTest.class));
        suite.addTest(new JUnit4TestAdapter(SbtAncillaryOperationsTest.class));
        suite.addTest(new JUnit4TestAdapter(SbtBlobSeriesOperationsTest.class));
        suite.addTest(new JUnit4TestAdapter(SbtCsciOperationsTest.class));
        suite.addTest(new JUnit4TestAdapter(SbtDataOperationsTest.class));
        suite.addTest(new JUnit4TestAdapter(SbtCadenceRangeDataMergerTest.class));
        suite.addTest(new JUnit4TestAdapter(EnumMapFactoryTest.class));
        suite.addTest(new JUnit4TestAdapter(PipelineProductListsTest.class));
        suite.addTest(new JUnit4TestAdapter(FsIdPipelineProductFilterTest.class));

        suite.addTest(new JUnit4TestAdapter(
            QuarterlyPipelineLauncherParametersTest.class));

        suite.addTest(new JUnit4TestAdapter(TaskCopyValidatorTest.class));
        suite.addTest(new JUnit4TestAdapter(
            TaskCopyExpectationPipelineTaskDirsExistTest.class));
        suite.addTest(new JUnit4TestAdapter(
            TaskCopyExpectationOuptutsMatFilesExistTest.class));
        suite.addTest(new JUnit4TestAdapter(
            TaskCopyValidatorPipelineTaskFilterTest.class));

        return suite;
    }
}
