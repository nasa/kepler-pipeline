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

package gov.nasa.kepler.ar;

import gov.nasa.kepler.ar.archive.CentroidCalculatorTest;
import gov.nasa.kepler.ar.exporter.*;
import gov.nasa.kepler.ar.exporter.arp.ArpExporterTest;
import gov.nasa.kepler.ar.exporter.background.BackgroundHeaderTest;
import gov.nasa.kepler.ar.exporter.background.BackgroundPixelExporterTest;
import gov.nasa.kepler.ar.exporter.cal.CalibratedPixelExtractorTest;
import gov.nasa.kepler.ar.exporter.cal.CosmicRayFitsTest;
import gov.nasa.kepler.ar.exporter.cal.TargetAndApertureIdMapTest;
import gov.nasa.kepler.ar.exporter.cbv.CbvModOutExporterTest;
import gov.nasa.kepler.ar.exporter.collateral.CollateralPixelExporterTest;
import gov.nasa.kepler.ar.exporter.dv.DvFluxFitsFileTest;
import gov.nasa.kepler.ar.exporter.dv.DvReportsExporterTest;
import gov.nasa.kepler.ar.exporter.dv.DvResultsExporterTest;
import gov.nasa.kepler.ar.exporter.dv.DvPrimaryHeaderFormatterTest;
import gov.nasa.kepler.ar.exporter.dv.DvStatisticsHeaderFormatterTest;
import gov.nasa.kepler.ar.exporter.dv.DvTargetMetdataTest;
import gov.nasa.kepler.ar.exporter.dv.DvTceHeaderFormatterTest;
import gov.nasa.kepler.ar.exporter.dv.PlanetarySystemTimeSeriesTest;
import gov.nasa.kepler.ar.exporter.ffi.*;
import gov.nasa.kepler.ar.exporter.flux2.FluxExporter2Test;
import gov.nasa.kepler.ar.exporter.ktc.CompletedKtcEntryTest;
import gov.nasa.kepler.ar.exporter.ktc.EntryCollatorTest;
import gov.nasa.kepler.ar.exporter.ktc.InvestigationClassifierTest;
import gov.nasa.kepler.ar.exporter.ktc.KtcExporterTest;
import gov.nasa.kepler.ar.exporter.tpixel.*;
import junit.framework.JUnit4TestAdapter;
import junit.framework.Test;
import junit.framework.TestSuite;

public class AutoTestSuite {

    public static Test suite() {

        TestSuite suite = new TestSuite();
        
        suite.addTest(new JUnit4TestAdapter(DvTargetMetdataTest.class));
        suite.addTest(new JUnit4TestAdapter(K2ExporterTest.class));
        suite.addTest(new JUnit4TestAdapter(CbvModOutExporterTest.class));
        suite.addTest(new JUnit4TestAdapter(CollateralPixelExporterTest.class));
        suite.addTest(new JUnit4TestAdapter(ArpExporterTest.class));
        suite.addTest(new JUnit4TestAdapter(BackgroundPixelExporterTest.class));
        suite.addTest(new JUnit4TestAdapter(BackgroundHeaderTest.class));
        
        suite.addTest(new JUnit4TestAdapter(EntryCollatorTest.class));
        suite.addTest(new JUnit4TestAdapter(FrontEndPipelineMetadataTest.class));
        suite.addTest(new JUnit4TestAdapter(FfiFragmentGeneratorTest.class));
        suite.addTest(new JUnit4TestAdapter(PositionCorrectionFilterTest.class));
        suite.addTest(new JUnit4TestAdapter(FfiKeywordValueExtractorTest.class));
        suite.addTest(new JUnit4TestAdapter(FfiImageHeaderFormatterTest.class));
        suite.addTest(new JUnit4TestAdapter(FfiPrimaryHeaderFormatterTest.class));
        suite.addTest(new JUnit4TestAdapter(TargetPixelMetadataTest.class));
        suite.addTest(new JUnit4TestAdapter(FitsChecksumTest.class));
        suite.addTest(new JUnit4TestAdapter(FluxExporter2Test.class));
        suite.addTest(new JUnit4TestAdapter(ExposureCalculatorTest.class));
        suite.addTest(new JUnit4TestAdapter(DefaultTargetPixelExporterSourceTest.class));
        suite.addTest(new JUnit4TestAdapter(ReferenceCadenceCalculatorTest.class));
        suite.addTest(new JUnit4TestAdapter(CentroidCalculatorTest.class));
        suite.addTest(new JUnit4TestAdapter(CalibratedPixelValueCalculatorTest.class));
        suite.addTest(new JUnit4TestAdapter(TargetPixelExporterPipelineModuleTest.class));
        suite.addTest(new JUnit4TestAdapter(TargetPixelExporterTest.class));
        suite.addTest(new JUnit4TestAdapter(TargetPixelBinaryTableHeaderFormaterTest.class));
        suite.addTest(new JUnit4TestAdapter(QualityFieldCalculatorTest.class));
        suite.addTest(new JUnit4TestAdapter(TargetImageDimensionCalculatorTest.class));
        suite.addTest(new JUnit4TestAdapter(ApertureMaskImageBuilderTest.class));
        suite.addTest(new JUnit4TestAdapter(ApertureMaskFormatterTest.class));
        suite.addTest(new JUnit4TestAdapter(PrimaryHeaderFormatterTest.class));
        suite.addTest(new JUnit4TestAdapter(CompletedKtcEntryTest.class));
        suite.addTest(new JUnit4TestAdapter(ReleaseTaggerTest.class));

        suite.addTest(new JUnit4TestAdapter(PlanetarySystemTimeSeriesTest.class));

        suite.addTest(new JUnit4TestAdapter(InvestigationClassifierTest.class));
                suite.addTest(new JUnit4TestAdapter(DvFluxFitsFileTest.class));
        suite.addTest(new JUnit4TestAdapter(KeywordCopierTest.class));

        suite.addTest(new JUnit4TestAdapter(DirectorySplitterTest.class));

        suite.addTest(new JUnit4TestAdapter(TargetAndApertureIdMapTest.class));
        suite.addTest(new JUnit4TestAdapter(CalibratedPixelExtractorTest.class));
        suite.addTest(new JUnit4TestAdapter(CombinedFlatFieldFitsTest.class));
        suite.addTest(new JUnit4TestAdapter(CombinedFlatFieldExporterTest.class));

        suite.addTest(new JUnit4TestAdapter(CharacteristicExporterUT.class));
        suite.addTest(new JUnit4TestAdapter(KICExporterUT.class));
        suite.addTest(new JUnit4TestAdapter(QdnmTest.class));
        suite.addTest(new JUnit4TestAdapter(Iso8601FormatterTest.class));

        suite.addTest(new JUnit4TestAdapter(KtcExporterTest.class));
        suite.addTest(new JUnit4TestAdapter(CosmicRayFitsTest.class));
        suite.addTest(new JUnit4TestAdapter(FluxTimeSeriesProcessingTest.class));;

        suite.addTest(new JUnit4TestAdapter(DvResultsExporterTest.class));

        suite.addTest(new JUnit4TestAdapter(DvReportsExporterTest.class));

        suite.addTest(new JUnit4TestAdapter(FluxFileDateFormatUT.class));

        suite.addTest(new JUnit4TestAdapter(FrontEndPipelineMetadataTest.class));
        
        suite.addTest(new JUnit4TestAdapter(ShortToLongCadenceMapTest.class));
        
        suite.addTest(new JUnit4TestAdapter(DvPrimaryHeaderFormatterTest.class));
        suite.addTest(new JUnit4TestAdapter(DvTceHeaderFormatterTest.class));
        suite.addTest(new JUnit4TestAdapter(DvStatisticsHeaderFormatterTest.class));

        return suite;
    }
}
