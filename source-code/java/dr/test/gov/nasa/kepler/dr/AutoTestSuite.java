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

package gov.nasa.kepler.dr;

import gov.nasa.kepler.dr.configmap.ConfigMapStorerRetrieverTest;
import gov.nasa.kepler.dr.configmap.ConfigMapWriterReaderTest;
import gov.nasa.kepler.dr.dataanomaly.DataAnomalyExportImportTest;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapperTest;
import gov.nasa.kepler.dr.dispatch.ExporterTest;
import gov.nasa.kepler.dr.dispatch.FileWatcherTest;
import gov.nasa.kepler.dr.dispatch.FitsFileLogStorerRetrieverTest;
import gov.nasa.kepler.dr.dispatch.ImporterTest;
import gov.nasa.kepler.dr.dispatch.NmSplitterTest;
import gov.nasa.kepler.dr.dispatch.NotificationMessageHandlerTest;
import gov.nasa.kepler.dr.ephemeris.SpacecraftEphemerisDispatcherTest;
import gov.nasa.kepler.dr.fits.FitsFileReaderWriterTest;
import gov.nasa.kepler.dr.histogram.HistogramDispatcherTest;
import gov.nasa.kepler.dr.history.HistoryDispatcherTest;
import gov.nasa.kepler.dr.importer.MocModelDrCopierTest;
import gov.nasa.kepler.dr.kicextension.KicExtensionImporterTest;
import gov.nasa.kepler.dr.kicextension.KicExtensionStorerRetrieverTest;
import gov.nasa.kepler.dr.kicextension.KicExtensionTest;
import gov.nasa.kepler.dr.kicextension.KicExtensionWriterReaderTest;
import gov.nasa.kepler.dr.lazyfits.HeaderTest;
import gov.nasa.kepler.dr.lazyfits.LazyFitsTest;
import gov.nasa.kepler.dr.pixels.TimeSeriesBufferTest;
import gov.nasa.kepler.dr.pmrf.CollateralPmrfEntryTest;
import gov.nasa.kepler.dr.pmrf.CollateralPmrfModOutTest;
import gov.nasa.kepler.dr.pmrf.CollateralPmrfValidatorTest;
import gov.nasa.kepler.dr.pmrf.PmrfReaderTest;
import gov.nasa.kepler.dr.pmrf.PmrfRetrieverTest;
import gov.nasa.kepler.dr.pmrf.PmrfStorerTest;
import gov.nasa.kepler.dr.pmrf.PmrfTest;
import gov.nasa.kepler.dr.pmrf.PmrfWriterTest;
import gov.nasa.kepler.dr.pmrf.SciencePmrfEntryTest;
import gov.nasa.kepler.dr.pmrf.SciencePmrfModOutTest;
import gov.nasa.kepler.dr.pmrf.SciencePmrfTest;
import gov.nasa.kepler.dr.pmrf.SciencePmrfValidatorTest;
import gov.nasa.kepler.dr.pmrf.TadTargetTableModOutTest;
import gov.nasa.kepler.dr.pmrf.TadTargetTableTest;
import gov.nasa.kepler.dr.sclk.SclkDispatcherTest;
import gov.nasa.kepler.dr.target.TargetListSetImporterTest;
import gov.nasa.kepler.dr.thruster.ThrusterDataDispatcherTest;

import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import org.junit.runners.Suite.SuiteClasses;

@RunWith(Suite.class)
@SuiteClasses({

    // gov.nasa.kepler.dr.ancillary

    // gov.nasa.kepler.dr.configmap
    ConfigMapStorerRetrieverTest.class,
    ConfigMapWriterReaderTest.class,

    // gov.nasa.kepler.dr.dataanomaly
    DataAnomalyExportImportTest.class,

    // gov.nasa.kepler.dr.dispatch
    DispatcherWrapperTest.class,
    ExporterTest.class,
    FileWatcherTest.class,
    FitsFileLogStorerRetrieverTest.class,
    ImporterTest.class,
    NmSplitterTest.class,

    NotificationMessageHandlerTest.class,

    // gov.nasa.kepler.dr.ephemeris

    SpacecraftEphemerisDispatcherTest.class,

    // gov.nasa.kepler.dr.ffi

    // gov.nasa.kepler.dr.fits
    FitsFileReaderWriterTest.class,

    // gov.nasa.kepler.dr.gap

    // gov.nasa.kepler.dr.histogram
    HistogramDispatcherTest.class,

    // gov.nasa.kepler.dr.history
    HistoryDispatcherTest.class,

    // gov.nasa.kepler.dr.importer
    MocModelDrCopierTest.class,

    // gov.nasa.kepler.dr.kicextension
    KicExtensionImporterTest.class,
    KicExtensionStorerRetrieverTest.class,
    KicExtensionTest.class,
    KicExtensionWriterReaderTest.class,

    // gov.nasa.kepler.dr.lazyfits
    LazyFitsTest.class,
    HeaderTest.class,

    // gov.nasa.kepler.dr.main

    // gov.nasa.kepler.dr.pixels
    TimeSeriesBufferTest.class,

    // gov.nasa.kepler.dr.pmrf
    CollateralPmrfEntryTest.class, CollateralPmrfModOutTest.class,
    CollateralPmrfValidatorTest.class, PmrfReaderTest.class,
    PmrfRetrieverTest.class, PmrfStorerTest.class, PmrfTest.class,
    PmrfWriterTest.class, SciencePmrfEntryTest.class,
    SciencePmrfModOutTest.class, SciencePmrfTest.class,
    SciencePmrfValidatorTest.class, TadTargetTableModOutTest.class,
    TadTargetTableTest.class,

    // gov.nasa.kepler.dr.refpixels

    // gov.nasa.kepler.dr.sclk
    SclkDispatcherTest.class,

    // gov.nasa.kepler.dr.target
    TargetListSetImporterTest.class,

    // gov.nasa.kepler.dr.thruster
    ThrusterDataDispatcherTest.class,

})
public class AutoTestSuite {
}
