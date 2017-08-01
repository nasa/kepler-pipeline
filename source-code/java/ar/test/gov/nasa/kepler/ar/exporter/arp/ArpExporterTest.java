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

package gov.nasa.kepler.ar.exporter.arp;

import static gov.nasa.kepler.ar.exporter.TestUtils.*;
import static org.junit.Assert.assertFalse;
import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FitsDiff;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.hibernate.dr.DataAnomaly.DataAnomalyType;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.util.*;

import org.apache.commons.lang.StringUtils;
import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Lists;

/**
 * Test that the ARP pixel exporter generates a file.
 * 
 * @author Sean McCauliff
 *
 */
@RunWith(JMock.class)
public class ArpExporterTest {

    private static final File outputDir = 
        new File(Filenames.BUILD_TEST, ArpExporterTest.class.getSimpleName());
    private static final File truthDir = new File("testdata");
    private static final int externalTtableId = 25;
    
    private Mockery mockery;
    
    @Before
    public void setUp() throws Exception {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
        
        FileUtil.cleanDir(outputDir);
        FileUtil.mkdirs(outputDir);
    }
    
    @Test
    public void arpExporterTest() throws Exception {
        final ArpExporterSource source = mockery.mock(ArpExporterSource.class);
        
        final List<DataAnomaly> dataAnomalies = 
            ImmutableList.of(new DataAnomaly(DataAnomalyType.ARGABRIGHTENING,
                Cadence.CADENCE_LONG, startCadence, startCadence+1));
        
        Pixel pixel0 = new Pixel(10, 11);
        Pixel pixel1 = new Pixel(23, 42);
        final Set<Pixel> arpPixels = ImmutableSet.of(pixel0, pixel1);
        final Date generatedAt = new Date(34433322222L);
        
        final TimestampSeries cadenceTimes = createTimestampSeries();
        final double startMidMjd = cadenceTimes.midTimestamps[0];
        final double endMidMjd = cadenceTimes.midTimestamps[cadenceTimes.midTimestamps.length - 1];
        
        ConfigMap configMap = configureConfigMap(mockery);
        final List<ConfigMap> configMaps = ImmutableList.of(configMap);
        final ObservedTarget observedTarget = mockery.mock(ObservedTarget.class);

        final SciencePixelOperations sciOps = mockery.mock(SciencePixelOperations.class);
        mockery.checking(new Expectations() {{
            atLeast(1).of(sciOps).loadTargetPixels(observedTarget, ccdModule, ccdOutput);
            will(returnValue(arpPixels));
        }});
        
        
        final FileStoreClient fsClient = 
            createFileStoreClientForSparsePixelTargets(mockery, arpPixels, cadenceTimes,
                externalTtableId, TargetType.LONG_CADENCE, false);
        
        final MjdToCadence mjdToCadence = 
            createMjdToCadence(mockery, cadenceTimes, CadenceType.LONG);
        
        
        mockery.checking(new Expectations() {{
            atLeast(1).of(source).arpObservedTarget();
            will(returnValue(observedTarget));
            atLeast(1).of(source).cadenceTimes();
            will(returnValue(cadenceTimes));
            atLeast(1).of(source).ccdModule();
            will(returnValue(ccdModule));
            atLeast(1).of(source).ccdOutput();
            will(returnValue(ccdOutput));
            atLeast(1).of(source).configMaps();
            will(returnValue(configMaps));
            atLeast(1).of(source).dataAnomalies();
            will(returnValue(dataAnomalies));
            atLeast(1).of(source).dataReleaseNumber();
            will(returnValue(-17));
            atLeast(1).of(source).endCadence();
            will(returnValue(endCadence));
            atLeast(1).of(source).endMidMjd();
            will(returnValue(endMidMjd));
            atLeast(1).of(source).exportDir();
            will(returnValue(outputDir));
            atLeast(1).of(source).fileStoreClient();
            will(returnValue(fsClient));
            atLeast(1).of(source).fileTimestamp();
            will(returnValue("timestamp"));
            atLeast(1).of(source).gainEPerCount();
            will(returnValue(18.5));
            atLeast(1).of(source).generatedAt();
            will(returnValue(generatedAt));
            atLeast(1).of(source).meanBlack();
            will(returnValue(19));
            atLeast(1).of(source).mjdToCadence();
            will(returnValue(mjdToCadence));
            atLeast(1).of(source).pipelineTaskId();
            will(returnValue(-20L));
            atLeast(1).of(source).programName();
            will(returnValue("test"));
            atLeast(1).of(source).quarter();
            will(returnValue(21));
            atLeast(1).of(source).readNoiseE();
            will(returnValue(22.0));
            atLeast(1).of(source).sciencePixelOps();
            will(returnValue(sciOps));
            atLeast(1).of(source).season();
            will(returnValue(23));
            atLeast(1).of(source).skyGroup();
            will(returnValue(24));
            atLeast(1).of(source).startCadence();
            will(returnValue(startCadence));
            atLeast(1).of(source).startMidMjd();
            will(returnValue(startMidMjd));
            atLeast(1).of(source).subversionRevision();
            will(returnValue("r123"));
            atLeast(1).of(source).subversionUrl();
            will(returnValue("svn+ssh://host/path/to/code"));
            atLeast(1).of(source).targetTableId();
            will(returnValue(externalTtableId));
            atLeast(1).of(source).rollingBandPulseDurationsLc();
            will(returnValue(new int[] { 13 }));
        }});
        
        //The exporter never needs to call cadenceType() on mjdToCadence.
        mjdToCadence.cadenceType();
        
        ArpExporter arpExporter = new ArpExporter();
        arpExporter.export(source);
        
        String exportFname = "kplr021-timestamp_arp.fits";
        File truthFile = new File(truthDir, exportFname);
        File actualFile = new File(outputDir, exportFname);
        FitsDiff fitsDiff = new FitsDiff();
        List<String> diffs = Lists.newArrayList();
        boolean diff = fitsDiff.diff(truthFile, actualFile, diffs);
        assertFalse(StringUtils.join(diffs.iterator(), "\n"), diff);

    }
    
}
