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

package gov.nasa.kepler.ar.exporter.background;

import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.FitsDiff;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.hibernate.dr.DataAnomaly.DataAnomalyType;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;

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
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Lists;

import gov.nasa.kepler.ar.archive.BarycentricCorrection;
import gov.nasa.kepler.ar.archive.TargetDva;
import gov.nasa.kepler.ar.exporter.ExampleSipWcsCoordinates;
import gov.nasa.kepler.ar.exporter.TestUtils;
import gov.nasa.kepler.ar.exporter.background.BackgroundPolynomial.Polynomial;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import static gov.nasa.kepler.ar.exporter.TestUtils.*;
import static org.junit.Assert.*;

@RunWith(JMock.class)
public class BackgroundPixelExporterTest {
    private static final File outputDir = 
        new File(Filenames.BUILD_TEST, BackgroundPixelExporterTest.class.getSimpleName());
    private static final File truthDir = new File("testdata");
    private static final int TTABLE_EXTERNAL_ID = 666;
    
    private Mockery mockery;
    
    @Before
    public void setUp() throws Exception {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
        
        FileUtil.cleanDir(outputDir);
        FileUtil.mkdirs(outputDir);
    }
    
    @Test
    public void testBackgroundPixelExporter() throws Exception {
        final BackgroundPixelSource source = 
            mockery.mock(BackgroundPixelSource.class);
        
        final List<DataAnomaly> dataAnomalies = 
            ImmutableList.of(new DataAnomaly(DataAnomalyType.ARGABRIGHTENING,
                Cadence.CADENCE_LONG, startCadence, startCadence+1));
        
        Pixel pixel0 = new Pixel(10, 11);
        Pixel pixel1 = new Pixel(23, 42);
        final Set<Pixel> backgroundPixels = ImmutableSet.of(pixel0, pixel1);
        
        double[] coeffs = new double[] { Math.PI, Math.PI };
        double[] covarianceCoeffs = new double[] {Math.E, Math.E, Math.E, Math.E};
        
        Polynomial[] polynomials = new Polynomial[cadenceLength];
        Arrays.fill(polynomials, new Polynomial(coeffs, covarianceCoeffs, false));
        
        final BackgroundPolynomial bkgPoly = 
            new BackgroundPolynomial(1.1, 2.2, 3.3, 4.4, 5.5, 6.6, polynomials);
        
        final Pixel centerModOutPixel =
            new Pixel(FcConstants.CCD_ROWS/2, FcConstants.CCD_COLUMNS/2);
        
        final BarycentricCorrection centerModOutCorrection =
            createBarycentricCorrection(-7);
        final Date generatedAt = new Date(23424233444L);
        
        final TimestampSeries cadenceTimes = createTimestampSeries();
        final double startMjd = cadenceTimes.startTimestamps[0];
        final double endMjd = cadenceTimes.endTimestamps[cadenceTimes.endTimestamps.length - 1];
        
        ConfigMap configMap = configureConfigMap(mockery);
        final List<ConfigMap> configMaps = ImmutableList.of(configMap);
        
        TargetDva pixel0Dva = createTargetDva(0, 0, startCadence, endCadence);
        TargetDva pixel1Dva = createTargetDva(1, 1, startCadence, endCadence);
        final Map<Pixel, TargetDva> perPixelDva = 
            ImmutableMap.of(pixel0, pixel0Dva, pixel1, pixel1Dva);
        
        final MjdToCadence mjdToCadence = createMjdToCadence(mockery, cadenceTimes, CadenceType.LONG);
        mjdToCadence.cadenceType();
        
        BarycentricCorrection pixel0Bc = createBarycentricCorrection(0);
        BarycentricCorrection pixel1Bc = createBarycentricCorrection(1);
        final Map<Pixel, BarycentricCorrection> perPixelBc = 
            ImmutableMap.of(pixel0, pixel0Bc, pixel1, pixel1Bc);
        
        final FileStoreClient fsClient = 
            createFileStoreClientForSparsePixelTargets(mockery, backgroundPixels, cadenceTimes,
            TTABLE_EXTERNAL_ID, TargetType.BACKGROUND, true);
        
        mockery.checking(new Expectations() {{
            atLeast(1).of(source).anomalies();
            will(returnValue(dataAnomalies));
            atLeast(1).of(source).backgroundPixels();
            will(returnValue(backgroundPixels));
            atLeast(1).of(source).backgroundPolynomial();
            will(returnValue(bkgPoly));
            atLeast(1).of(source).cadenceTimes();
            will(returnValue(cadenceTimes));
            atLeast(1).of(source).ccdModule();
            will(returnValue(ccdModule));
            atLeast(1).of(source).ccdOutput();
            will(returnValue(ccdOutput));
            atLeast(1).of(source).configMaps();
            will(returnValue(configMaps));
            atLeast(1).of(source).dataReleaseNumber();
            will(returnValue(-7));
            atLeast(1).of(source).dvaMotionCorrections(perPixelBc, referenceCadence);
            will(returnValue(perPixelDva));
            atLeast(1).of(source).endCadence();
            will(returnValue(endCadence));
            atLeast(1).of(source).endEndMjd();
            will(returnValue(endMjd));
            atLeast(1).of(source).exportDir();
            will(returnValue(outputDir));
            atLeast(1).of(source).fileStoreClient();
            will(returnValue(fsClient));
            atLeast(1).of(source).fileTimestamp();
            will(returnValue("timestamp"));
            atLeast(1).of(source).gainE();
            will(returnValue(8.8));
            atLeast(1).of(source).generatedAt();
            will(returnValue(generatedAt));
            atLeast(1).of(source).meanBlack();
            will(returnValue(9));
            atLeast(1).of(source).mjdToCadence();
            will(returnValue(mjdToCadence));
            atLeast(1).of(source).perPixelBarycentricCorrection((endCadence + startCadence) / 2, backgroundPixels);;
            will(returnValue(perPixelBc));
            atLeast(1).of(source).perPixelBarycentricCorrection(referenceCadence, ImmutableList.of(centerModOutPixel));
            will(returnValue(ImmutableMap.of(centerModOutPixel, centerModOutCorrection)));
            atLeast(1).of(source).pipelineTaskId();
            will(returnValue(-10L));
            atLeast(1).of(source).quarter();
            will(returnValue(11));
            atLeast(1).of(source).readNoseE();
            will(returnValue(12.12));
            atLeast(1).of(source).season();
            will(returnValue(13));
            atLeast(1).of(source).skyGroup();
            will(returnValue(14));
            atLeast(1).of(source).startCadence();
            will(returnValue(startCadence));
            atLeast(1).of(source).startStartMjd();
            will(returnValue(startMjd));
            atLeast(1).of(source).targetTableExternalId();
            will(returnValue(TTABLE_EXTERNAL_ID));
            atLeast(1).of(source).sipWcsCoordinates(referenceCadence);
            will(returnValue(ExampleSipWcsCoordinates.example()));
            atLeast(1).of(source).subversionRevision();
            will(returnValue("45723"));
            atLeast(1).of(source).subversionUrl();
            will(returnValue("svn+ssh://host/path/to/code"));
            atLeast(1).of(source).ignoreZeroCrossingsForReferenceCadence();
            will(returnValue(false));
            atLeast(1).of(source).rollingBandPulseDurationsLc();
            will(returnValue(new int[] {TestUtils.ROLLING_BAND_TEST_PULSE_DURATION}));
            
        }});
        BackgroundPixelExporter pixelExporter = new BackgroundPixelExporter();
        pixelExporter.export(source);
        
        String exportFname = "kplr021-timestamp_bkg.fits";
        File truthFile = new File(truthDir, exportFname);
        File actualFile = new File(outputDir, exportFname);
        FitsDiff fitsDiff = new FitsDiff();
        List<String> diffs = Lists.newArrayList();
        boolean diff = fitsDiff.diff(truthFile, actualFile, diffs);
        assertFalse(StringUtils.join(diffs.iterator(), "\n"), diff);
        
    }
   
    
    private BarycentricCorrection createBarycentricCorrection(int i) {
        float[] corrections = new float[cadenceLength];
        boolean[] gaps = new boolean[cadenceLength];
        
        Arrays.fill(corrections, .00666f * (i+1));
        
        BarycentricCorrection bc = new BarycentricCorrection(i, corrections, gaps, -1.1, -2.2);
        return bc;
            
    }
}
