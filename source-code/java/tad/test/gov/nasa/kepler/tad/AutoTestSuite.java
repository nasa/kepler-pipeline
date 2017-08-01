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

package gov.nasa.kepler.tad;

import gov.nasa.kepler.mc.tad.OffsetListTest;
import gov.nasa.kepler.mc.tad.OffsetTest;
import gov.nasa.kepler.mc.tad.OptimalApertureTest;
import gov.nasa.kepler.mc.tad.PersistableFactoryTest;
import gov.nasa.kepler.tad.operations.TadParametersTest;
import gov.nasa.kepler.tad.operations.TadRevisedParametersTest;
import gov.nasa.kepler.tad.operations.TadXmlImportParametersTest;
import gov.nasa.kepler.tad.operations.TargetListSetEditorLcTest;
import gov.nasa.kepler.tad.operations.TargetListSetEditorTest;
import gov.nasa.kepler.tad.operations.TargetOperationsTest;
import gov.nasa.kepler.tad.peer.AmaModuleParametersTest;
import gov.nasa.kepler.tad.peer.AmtModuleParametersTest;
import gov.nasa.kepler.tad.peer.ApertureStructFactoryTest;
import gov.nasa.kepler.tad.peer.ApertureStructTest;
import gov.nasa.kepler.tad.peer.BpaModuleParametersTest;
import gov.nasa.kepler.tad.peer.CoaModuleParametersTest;
import gov.nasa.kepler.tad.peer.KeplerIdMapTest;
import gov.nasa.kepler.tad.peer.MaskDefinitionTest;
import gov.nasa.kepler.tad.peer.MaskTableParametersTest;
import gov.nasa.kepler.tad.peer.RptsModuleParametersTest;
import gov.nasa.kepler.tad.peer.TargetDefinitionStructTest;
import gov.nasa.kepler.tad.peer.ama.AmaInputsTest;
import gov.nasa.kepler.tad.peer.ama.AmaOutputsTest;
import gov.nasa.kepler.tad.peer.ama.AmaPipelineModuleTest;
import gov.nasa.kepler.tad.peer.amt.AmtInputsTest;
import gov.nasa.kepler.tad.peer.amt.AmtOutputsTest;
import gov.nasa.kepler.tad.peer.amt.AmtPipelineModuleTest;
import gov.nasa.kepler.tad.peer.bpa.BpaInputsTest;
import gov.nasa.kepler.tad.peer.bpa.BpaOutputsTest;
import gov.nasa.kepler.tad.peer.bpa.BpaPipelineModuleTest;
import gov.nasa.kepler.tad.peer.bpasetup.BpaSetupPipelineModuleTest;
import gov.nasa.kepler.tad.peer.chartable.TadProductCharManagerTest;
import gov.nasa.kepler.tad.peer.chartable.TadProductCharTypeCreatorTest;
import gov.nasa.kepler.tad.peer.chartable.TadProductsToCharTablePipelineModuleTest;
import gov.nasa.kepler.tad.peer.coa.CoaInputsTest;
import gov.nasa.kepler.tad.peer.coa.CoaOutputsTest;
import gov.nasa.kepler.tad.peer.coa.CoaPipelineModuleTest;
import gov.nasa.kepler.tad.peer.coa.DistanceFromEdgeCalculatorTest;
import gov.nasa.kepler.tad.peer.merge.MergePipelineModuleTest;
import gov.nasa.kepler.tad.peer.merge.TadLabelValidatorTest;
import gov.nasa.kepler.tad.peer.rpts.RptsInputsTest;
import gov.nasa.kepler.tad.peer.rpts.RptsOutputsTest;
import gov.nasa.kepler.tad.peer.rpts.RptsPipelineModuleTest;
import gov.nasa.kepler.tad.peer.rptscleanup.RptsCleanupPipelineModuleTest;
import gov.nasa.kepler.tad.peer.tadval.TadValPipelineModuleTest;
import gov.nasa.kepler.tad.xml.ImportedMaskTableTest;
import gov.nasa.kepler.tad.xml.ImportedTargetTableTest;
import gov.nasa.kepler.tad.xml.MaskReaderFactoryTest;
import gov.nasa.kepler.tad.xml.MaskWriterFactoryTest;
import gov.nasa.kepler.tad.xml.MaskWriterReaderTest;
import gov.nasa.kepler.tad.xml.ObservedTargetsExporterImporterTest;
import gov.nasa.kepler.tad.xml.TadXmlFileOperationsTest;
import gov.nasa.kepler.tad.xml.TadXmlImportPipelineModuleTest;
import gov.nasa.kepler.tad.xml.TargetExporterTest;
import gov.nasa.kepler.tad.xml.TargetReaderFactoryTest;
import gov.nasa.kepler.tad.xml.TargetWriterFactoryTest;
import gov.nasa.kepler.tad.xml.TargetWriterReaderTest;

import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import org.junit.runners.Suite.SuiteClasses;

@RunWith(Suite.class)
@SuiteClasses({
    // gov.nasa.kepler.tad.operations
    TadParametersTest.class,
    TadRevisedParametersTest.class,
    TadXmlImportParametersTest.class,
    TargetListSetEditorLcTest.class,
    TargetListSetEditorTest.class,
    TargetOperationsTest.class,

    // gov.nasa.kepler.tad.peer
    AmaInputsTest.class,
    AmaModuleParametersTest.class,
    AmaOutputsTest.class,
    AmtInputsTest.class,
    AmtModuleParametersTest.class,
    AmtOutputsTest.class,
    ApertureStructFactoryTest.class,
    ApertureStructTest.class,
    BpaInputsTest.class,
    BpaModuleParametersTest.class,
    BpaOutputsTest.class,
    CoaInputsTest.class,
    CoaModuleParametersTest.class,
    CoaOutputsTest.class,
    KeplerIdMapTest.class,
    // Ignored because of a field that does not start with lower case.
    // KicEntryDataTest.class,
    MaskDefinitionTest.class,
    MaskTableParametersTest.class,
    OffsetListTest.class,
    OffsetTest.class,
    OptimalApertureTest.class,
    PersistableFactoryTest.class,
    RptsInputsTest.class,
    RptsModuleParametersTest.class,
    RptsOutputsTest.class,
    TargetDefinitionStructTest.class,

    // gov.nasa.kepler.tad.peer.ama
    AmaPipelineModuleTest.class,

    // gov.nasa.kepler.tad.peer.amt
    AmtPipelineModuleTest.class,

    // gov.nasa.kepler.tad.peer.bpa
    BpaPipelineModuleTest.class,

    // gov.nasa.kepler.tad.peer.bpasetup
    BpaSetupPipelineModuleTest.class,

    // gov.nasa.kepler.tad.peer.chartable
    TadProductCharManagerTest.class,
    TadProductCharTypeCreatorTest.class,
    TadProductsToCharTablePipelineModuleTest.class,

    // gov.nasa.kepler.tad.peer.coa
    CoaPipelineModuleTest.class,
    DistanceFromEdgeCalculatorTest.class,

    // gov.nasa.kepler.tad.peer.merge
    MergePipelineModuleTest.class,
    TadLabelValidatorTest.class,

    // gov.nasa.kepler.tad.peer.rpts
    RptsPipelineModuleTest.class,

    // gov.nasa.kepler.tad.peer.rptscleanup
    RptsCleanupPipelineModuleTest.class,

    // gov.nasa.kepler.tad.peer.tadval
    TadValPipelineModuleTest.class,

    // gov.nasa.kepler.tad.xml
    ImportedMaskTableTest.class, ImportedTargetTableTest.class,
    MaskReaderFactoryTest.class, MaskWriterFactoryTest.class,
    MaskWriterReaderTest.class, ObservedTargetsExporterImporterTest.class,
    TadXmlFileOperationsTest.class, TadXmlImportPipelineModuleTest.class,
    TargetExporterTest.class, TargetReaderFactoryTest.class,
    TargetWriterFactoryTest.class, TargetWriterReaderTest.class

})
public class AutoTestSuite {
}
