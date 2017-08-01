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

package gov.nasa.kepler.hibernate;

import gov.nasa.kepler.hibernate.cal.CalProcessingCharacteristicsTest;
import gov.nasa.kepler.hibernate.cal.UncertaintyTest;
import gov.nasa.kepler.hibernate.cm.CatKeyTest;
import gov.nasa.kepler.hibernate.cm.CharacteristicCrudTest;
import gov.nasa.kepler.hibernate.cm.CharacteristicTest;
import gov.nasa.kepler.hibernate.cm.CustomTargetCrudTest;
import gov.nasa.kepler.hibernate.cm.DoubleFormatterTest;
import gov.nasa.kepler.hibernate.cm.KicCrudTest;
import gov.nasa.kepler.hibernate.cm.KicOverrideModelCrudTest;
import gov.nasa.kepler.hibernate.cm.KicOverrideModelTest;
import gov.nasa.kepler.hibernate.cm.KicOverrideTest;
import gov.nasa.kepler.hibernate.cm.KicTest;
import gov.nasa.kepler.hibernate.cm.PlannedTargetTest;
import gov.nasa.kepler.hibernate.cm.ScpKeyTest;
import gov.nasa.kepler.hibernate.cm.SkyGroupTest;
import gov.nasa.kepler.hibernate.cm.TargetListSetTest;
import gov.nasa.kepler.hibernate.cm.TargetListTest;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrudTest;
import gov.nasa.kepler.hibernate.dbservice.AnnotatedPojoListTest;
import gov.nasa.kepler.hibernate.dbservice.DerbyUrlTest;
import gov.nasa.kepler.hibernate.dbservice.DontNukeProductionDatabases;
import gov.nasa.kepler.hibernate.dbservice.XANodeNameFactoryTest;
import gov.nasa.kepler.hibernate.dr.AncillaryDictionaryCrudTest;
import gov.nasa.kepler.hibernate.dr.AncillaryLogCrudTest;
import gov.nasa.kepler.hibernate.dr.DataAnomalyModelCrudTest;
import gov.nasa.kepler.hibernate.dr.DispatcherTriggerCrudTest;
import gov.nasa.kepler.hibernate.dr.GapCrudTest;
import gov.nasa.kepler.hibernate.dr.HistogramLogCrudTest;
import gov.nasa.kepler.hibernate.dr.LogCrudShortToLongToShortTest;
import gov.nasa.kepler.hibernate.dr.LogCrudTest;
import gov.nasa.kepler.hibernate.dr.PixelLogCacheTest;
import gov.nasa.kepler.hibernate.dr.PixelLogRetrieverFactoryTest;
import gov.nasa.kepler.hibernate.dr.SclkCrudTest;
import gov.nasa.kepler.hibernate.dv.DvAbstractTargetTableDataTest;
import gov.nasa.kepler.hibernate.dv.DvBinaryDiscriminationResultsTest;
import gov.nasa.kepler.hibernate.dv.DvBootstrapHistogramTest;
import gov.nasa.kepler.hibernate.dv.DvCentroidMotionResultsTest;
import gov.nasa.kepler.hibernate.dv.DvCentroidResultsTest;
import gov.nasa.kepler.hibernate.dv.DvCrudTest;
import gov.nasa.kepler.hibernate.dv.DvDifferenceImagePixelDataTest;
import gov.nasa.kepler.hibernate.dv.DvDifferenceImageResultsTest;
import gov.nasa.kepler.hibernate.dv.DvDoubleQuantityTest;
import gov.nasa.kepler.hibernate.dv.DvDoubleQuantityWithProvenanceTest;
import gov.nasa.kepler.hibernate.dv.DvExternalTceModelDescriptionTest;
import gov.nasa.kepler.hibernate.dv.DvLimbDarkeningModelTest;
import gov.nasa.kepler.hibernate.dv.DvModelParameterTest;
import gov.nasa.kepler.hibernate.dv.DvPixelCorrelationResultsTest;
import gov.nasa.kepler.hibernate.dv.DvPixelStatisticTest;
import gov.nasa.kepler.hibernate.dv.DvPlanetCandidateTest;
import gov.nasa.kepler.hibernate.dv.DvPlanetModelFitTest;
import gov.nasa.kepler.hibernate.dv.DvPlanetResultsSequenceTest;
import gov.nasa.kepler.hibernate.dv.DvPlanetResultsTest;
import gov.nasa.kepler.hibernate.dv.DvPlanetStatisticTest;
import gov.nasa.kepler.hibernate.dv.DvQuantityTest;
import gov.nasa.kepler.hibernate.dv.DvQuantityWithProvenanceTest;
import gov.nasa.kepler.hibernate.dv.DvTargetResultsTest;
import gov.nasa.kepler.hibernate.dv.DvThresholdCrossingEventTest;
import gov.nasa.kepler.hibernate.dv.DvTransitModelDescriptionsTest;
import gov.nasa.kepler.hibernate.dynablack.DynablackCrudTest;
import gov.nasa.kepler.hibernate.gar.CompressionCrudTest;
import gov.nasa.kepler.hibernate.gar.ExportTableTest;
import gov.nasa.kepler.hibernate.mc.BoundsReportTest;
import gov.nasa.kepler.hibernate.mc.DoubleDbTimeSeriesCrudTest;
import gov.nasa.kepler.hibernate.mc.ExternalTceModelCrudTest;
import gov.nasa.kepler.hibernate.mc.ExternalTceModelTest;
import gov.nasa.kepler.hibernate.mc.ExternalTceTest;
import gov.nasa.kepler.hibernate.mc.ObservingLogCrudTest;
import gov.nasa.kepler.hibernate.mc.ObservingLogModelTest;
import gov.nasa.kepler.hibernate.mc.TransitNameModelCrudTest;
import gov.nasa.kepler.hibernate.mc.TransitNameModelTest;
import gov.nasa.kepler.hibernate.mc.TransitNameTest;
import gov.nasa.kepler.hibernate.mc.TransitParameterModelCrudTest;
import gov.nasa.kepler.hibernate.mc.TransitParameterModelTest;
import gov.nasa.kepler.hibernate.mr.MrReportCrudTest;
import gov.nasa.kepler.hibernate.pa.BackgroundBlobMetadataTest;
import gov.nasa.kepler.hibernate.pa.MotionBlobMetadataTest;
import gov.nasa.kepler.hibernate.pa.PaCrudTest;
import gov.nasa.kepler.hibernate.pdc.PdcBandTest;
import gov.nasa.kepler.hibernate.pdc.PdcCrudTest;
import gov.nasa.kepler.hibernate.pdc.PdcProcessingCharacteristicsTest;
import gov.nasa.kepler.hibernate.pdq.AttitudeAdjustmentTest;
import gov.nasa.kepler.hibernate.pdq.PdqCrudTest;
import gov.nasa.kepler.hibernate.pdq.PdqDbTimeSeriesCrudTest;
import gov.nasa.kepler.hibernate.pi.BeanWrapperTest;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrudTest;
import gov.nasa.kepler.hibernate.pi.ModelMetadataCrudTest;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatestTest;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstanceTest;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionCrudTest;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceTaskCrudTest;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinitionCrudTest;
import gov.nasa.kepler.hibernate.pi.TriggerCrudTest;
import gov.nasa.kepler.hibernate.ppa.MetricReportTest;
import gov.nasa.kepler.hibernate.ppa.PpaCrudTest;
import gov.nasa.kepler.hibernate.prf.PrfCrudTest;
import gov.nasa.kepler.hibernate.services.AlertLogCrudTest;
import gov.nasa.kepler.hibernate.services.KeyValuePairCrudTest;
import gov.nasa.kepler.hibernate.services.RoleTest;
import gov.nasa.kepler.hibernate.services.UserCrudTest;
import gov.nasa.kepler.hibernate.services.UserTest;
import gov.nasa.kepler.hibernate.tad.ApertureTest;
import gov.nasa.kepler.hibernate.tad.ImageTest;
import gov.nasa.kepler.hibernate.tad.ModOutTest;
import gov.nasa.kepler.hibernate.tad.ModOutsFactoryTest;
import gov.nasa.kepler.hibernate.tad.ObservedTargetTest;
import gov.nasa.kepler.hibernate.tad.SupplementalTargetListSetSetterTest;
import gov.nasa.kepler.hibernate.tad.TargetCrudTest;
import gov.nasa.kepler.hibernate.tad.TargetTableComparatorTest;
import gov.nasa.kepler.hibernate.tps.TpsCrudTest;
import junit.framework.JUnit4TestAdapter;
import junit.framework.Test;
import junit.framework.TestSuite;

public class AutoTestSuite {
    public static Test suite() {
        TestSuite suite = new TestSuite();

        // cal
        suite.addTest(new JUnit4TestAdapter(UncertaintyTest.class));
        suite.addTest(new JUnit4TestAdapter(CalProcessingCharacteristicsTest.class));

        // cm
        suite.addTest(new JUnit4TestAdapter(CatKeyTest.class));
        suite.addTest(new JUnit4TestAdapter(CharacteristicCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(CharacteristicTest.class));
        suite.addTest(new JUnit4TestAdapter(ConstraintTest.class));
        suite.addTest(new JUnit4TestAdapter(CustomTargetCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(ExportTableTest.class));
        suite.addTest(new JUnit4TestAdapter(KicCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(KicTest.class));
        suite.addTest(new JUnit4TestAdapter(PlannedTargetTest.class));
        suite.addTest(new JUnit4TestAdapter(ScpKeyTest.class));
        suite.addTest(new JUnit4TestAdapter(SkyGroupTest.class));
        suite.addTest(new JUnit4TestAdapter(TargetListSetTest.class));
        suite.addTest(new JUnit4TestAdapter(TargetListTest.class));
        suite.addTest(new JUnit4TestAdapter(TargetSelectionCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(KicOverrideModelCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(KicOverrideModelTest.class));
        suite.addTest(new JUnit4TestAdapter(KicOverrideTest.class));
        suite.addTest(new JUnit4TestAdapter(DoubleFormatterTest.class));

        // dbservice
        suite.addTest(new JUnit4TestAdapter(AnnotatedPojoListTest.class));
        suite.addTest(new JUnit4TestAdapter(DerbyUrlTest.class));
        suite.addTest(new JUnit4TestAdapter(DontNukeProductionDatabases.class));
        suite.addTest(new JUnit4TestAdapter(XANodeNameFactoryTest.class));

        // dr
        suite.addTest(new JUnit4TestAdapter(AncillaryLogCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(AncillaryDictionaryCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(DispatcherTriggerCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(GapCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(HistogramLogCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(LogCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(LogCrudShortToLongToShortTest.class));
        suite.addTest(new JUnit4TestAdapter(SclkCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(DataAnomalyModelCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(PixelLogRetrieverFactoryTest.class));
        suite.addTest(new JUnit4TestAdapter(PixelLogCacheTest.class));

        // dv
        suite.addTest(new JUnit4TestAdapter(DvAbstractTargetTableDataTest.class));
        suite.addTest(new JUnit4TestAdapter(
            DvBinaryDiscriminationResultsTest.class));
        suite.addTest(new JUnit4TestAdapter(DvBootstrapHistogramTest.class));
        suite.addTest(new JUnit4TestAdapter(DvCentroidMotionResultsTest.class));
        suite.addTest(new JUnit4TestAdapter(DvCentroidResultsTest.class));
        suite.addTest(new JUnit4TestAdapter(DvCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(
            DvDifferenceImagePixelDataTest.class));
        suite.addTest(new JUnit4TestAdapter(DvDifferenceImageResultsTest.class));
        suite.addTest(new JUnit4TestAdapter(DvDoubleQuantityTest.class));
        suite.addTest(new JUnit4TestAdapter(DvDoubleQuantityWithProvenanceTest.class));
        suite.addTest(new JUnit4TestAdapter(DvExternalTceModelDescriptionTest.class));
        suite.addTest(new JUnit4TestAdapter(DvLimbDarkeningModelTest.class));
        suite.addTest(new JUnit4TestAdapter(DvModelParameterTest.class));
        suite.addTest(new JUnit4TestAdapter(DvPlanetCandidateTest.class));
        suite.addTest(new JUnit4TestAdapter(DvPixelCorrelationResultsTest.class));
        suite.addTest(new JUnit4TestAdapter(DvPixelStatisticTest.class));
        suite.addTest(new JUnit4TestAdapter(DvPlanetModelFitTest.class));
        suite.addTest(new JUnit4TestAdapter(DvPlanetResultsSequenceTest.class));
        suite.addTest(new JUnit4TestAdapter(DvPlanetResultsTest.class));
        suite.addTest(new JUnit4TestAdapter(DvPlanetStatisticTest.class));
        suite.addTest(new JUnit4TestAdapter(DvQuantityTest.class));
        suite.addTest(new JUnit4TestAdapter(DvQuantityWithProvenanceTest.class));
        suite.addTest(new JUnit4TestAdapter(DvTargetResultsTest.class));
        suite.addTest(new JUnit4TestAdapter(DvThresholdCrossingEventTest.class));
        suite.addTest(new JUnit4TestAdapter(DvTransitModelDescriptionsTest.class));

        // dynablack
        suite.addTest(new JUnit4TestAdapter(DynablackCrudTest.class));

        // fpg
        suite.addTest(new JUnit4TestAdapter(DoubleDbTimeSeriesCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(PrfCrudTest.class));

        // gar
        suite.addTest(new JUnit4TestAdapter(CompressionCrudTest.class));

        // mc
        suite.addTest(new JUnit4TestAdapter(BoundsReportTest.class));
        suite.addTest(new JUnit4TestAdapter(ExternalTceModelCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(ExternalTceModelTest.class));
        suite.addTest(new JUnit4TestAdapter(ExternalTceTest.class));
        suite.addTest(new JUnit4TestAdapter(ObservingLogCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(ObservingLogModelTest.class));
        suite.addTest(new JUnit4TestAdapter(TransitNameModelCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(TransitNameModelTest.class));
        suite.addTest(new JUnit4TestAdapter(TransitNameTest.class));
        suite.addTest(new JUnit4TestAdapter(TransitParameterModelCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(TransitParameterModelTest.class));

        // mr
        suite.addTest(new JUnit4TestAdapter(MrReportCrudTest.class));

        // pa
        suite.addTest(new JUnit4TestAdapter(BackgroundBlobMetadataTest.class));
        suite.addTest(new JUnit4TestAdapter(MotionBlobMetadataTest.class));
        suite.addTest(new JUnit4TestAdapter(PaCrudTest.class));
        
        // pdc
        suite.addTest(new JUnit4TestAdapter(PdcBandTest.class));
        suite.addTest(new JUnit4TestAdapter(PdcProcessingCharacteristicsTest.class));
        suite.addTest(new JUnit4TestAdapter(PdcCrudTest.class));

        // pdq
        suite.addTest(new JUnit4TestAdapter(AttitudeAdjustmentTest.class));
        suite.addTest(new JUnit4TestAdapter(PdqCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(PdqDbTimeSeriesCrudTest.class));

        // pi
        suite.addTest(new JUnit4TestAdapter(BeanWrapperTest.class));
        suite.addTest(new JUnit4TestAdapter(
            DataAccountabilityTrailCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(PipelineDefinitionCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(PipelineInstanceTaskCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(
            PipelineModuleDefinitionCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(TriggerCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(ModelMetadataCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(
            ModelMetadataRetrieverLatestTest.class));
        suite.addTest(new JUnit4TestAdapter(
            ModelMetadataRetrieverPipelineInstanceTest.class));

        // ppa
        suite.addTest(new JUnit4TestAdapter(MetricReportTest.class));
        suite.addTest(new JUnit4TestAdapter(PpaCrudTest.class));

        // services
        suite.addTest(new JUnit4TestAdapter(AlertLogCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(KeyValuePairCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(RoleTest.class));
        suite.addTest(new JUnit4TestAdapter(UserCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(UserTest.class));

        // tad
        suite.addTest(new JUnit4TestAdapter(ApertureTest.class));
        suite.addTest(new JUnit4TestAdapter(ImageTest.class));
        suite.addTest(new JUnit4TestAdapter(ModOutsFactoryTest.class));
        suite.addTest(new JUnit4TestAdapter(ModOutTest.class));
        suite.addTest(new JUnit4TestAdapter(ObservedTargetTest.class));
        suite.addTest(new JUnit4TestAdapter(TargetCrudTest.class));
        suite.addTest(new JUnit4TestAdapter(TargetTableComparatorTest.class));
        suite.addTest(new JUnit4TestAdapter(
            SupplementalTargetListSetSetterTest.class));

        // tps
        suite.addTest(new JUnit4TestAdapter(TpsCrudTest.class));

        return suite;
    }
}
