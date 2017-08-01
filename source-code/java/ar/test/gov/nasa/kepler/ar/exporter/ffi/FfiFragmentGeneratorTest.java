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

package gov.nasa.kepler.ar.exporter.ffi;

import gov.nasa.kepler.ar.TestTimeConstants;
import gov.nasa.kepler.ar.exporter.ExampleSipWcsCoordinates;
import gov.nasa.kepler.common.*;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.KeplerException;
import gov.nasa.kepler.mc.fs.ArFsIdFactory;
import gov.nasa.spiffy.common.collect.ArrayUtils;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.List;

import nom.tam.fits.*;

import org.apache.commons.lang.StringUtils;
import org.jmock.integration.junit4.JMock;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import org.junit.Assert;

/**
 * @author Sean McCauliff
 * 
 */
@RunWith(JMock.class)
public class FfiFragmentGeneratorTest extends JMockTest {

    private final File testDir = new File(Filenames.BUILD_TEST, "FfiFragmentGeneratorTest");
    private final String NOMINAL_FILE_NAME  = "ffi.fragment.fits";
    
    private final String MODULE3_FILE_NAME = "ffi.module3.fragment.fits";

    private final double startMjd = 55.1;
    private final double endMjd = 66.2;
    private final int imageWidth = 100;
    private final int imageHeight = 200;
    private final boolean finePoint = false;
    private final boolean momentiumDump = true;
    private final float barycentricCorrectionDays = .0001f;
    private final String timestamp = "2012355000000";
    private final FfiType ffiType = FfiType.SOC_CAL;
    private final int ccdModule = 2;
    private final int ccdOutput = 1;
    private final long pipelineTaskId = 43434343L;
    private final double readNoise = Math.PI;
    private final int longCadence = 3433;
    
    @Before
    public void setUp() throws Exception {
//        FileUtil.cleanDir(testDir);
        FileUtil.mkdirs(testDir);
    }

    
    @Test
    public void generateFragmentWithMissingWcsAndBarycentricCorrection() throws Exception {
        
        File outputFile = new File(testDir, MODULE3_FILE_NAME);
        File expectedFile = new File("testdata", MODULE3_FILE_NAME);
        FfiTest ffiTest = new FfiTest(outputFile, expectedFile) {
            @Override
            protected SipWcsCoordinates sipWcs() {
               return null;
            }
            
            @Override
            protected ModOutBarycentricCorrection barycentricCorrection() {
                return null;
            }
        };
        ffiTest.runTest();
    }
    
    @Test
    public void ffiFragmentGeneratorTest() throws Exception {
        
        File outputFile = new File(testDir, NOMINAL_FILE_NAME);
        File expectedFile = new File("testdata", NOMINAL_FILE_NAME);
        FfiTest ffiTest = new FfiTest(outputFile, expectedFile);
        ffiTest.runTest();
       
    }

    
    private class FfiTest {

        private final File outputFile;
        private final File expectedFile;
        
        FfiTest(File outputFile, File expectedFile) {
            this.outputFile = outputFile;
            this.expectedFile = expectedFile;
        }
        
        void runTest() throws Exception {
            final CommonKeywordsExtractor commonExtractor = commonKeywordsExtractor();
            
            final FfiIImageHeaderKeywordExtractor keywordValueExtractor =
                ffiImageHeaderKeywordExtractor(commonExtractor);
           
            final FfiPrimaryHeaderKeywordExtractor primaryKeywordExtractor =
                ffiPrimaryHeaderKeywordExtractor(commonExtractor);
            
            
            float[][] originalImage = new float[imageHeight][imageWidth];
            float[][] electronsPerSecondImage = new float[imageHeight][imageWidth];
            ArrayUtils.fill(electronsPerSecondImage, (float) Math.E);
            
            BasicHDU primaryHdu = originalPrimaryHdu();
            
            ImageHDU imageHdu = originalImageHdu(originalImage);
            
            final FfiExposureCalculator exposureCalculator =
                exposureCalculator(originalImage, electronsPerSecondImage);
          
            ConfigMap configMap = mock(ConfigMap.class);
            ModOutBarycentricCorrection bcCorrection = barycentricCorrection();
            SipWcsCoordinates sipWcs = sipWcs();
            
            FsId resultId = ArFsIdFactory.getSingleChannelFfiFile(timestamp, ffiType, ccdModule, ccdOutput);
            
            //JMockTest badness: here we update state, but can't use one() b/c one() can't return a value
            FileStoreClient fsClient = mock(FileStoreClient.class);
            allowing(fsClient).writeBlob(resultId, pipelineTaskId);
            
            FileOutputStream fout = new FileOutputStream(outputFile);
            will(returnValue(fout));
            
            FfiFragmentGeneratorSource source = mock(FfiFragmentGeneratorSource.class);
            allowing(source).calibratedFfiImageHdu();
            will(returnValue(imageHdu));
            
            allowing(source).primaryHdu();
            will(returnValue(primaryHdu));
            
            allowing(source).ccdModule();
            will(returnValue(ccdModule));
            
            allowing(source).ccdOutput();
            will(returnValue(ccdOutput));
            
            allowing(source).configMap(startMjd, endMjd);
            will(returnValue(configMap));
            //JMockTest badness: this should only be called once, but I can't use one() and return a value.
            allowing(source).ffiBarycentricCorrection(startMjd, endMjd, longCadence, imageWidth, imageHeight);
            will(returnValue(bcCorrection));
            allowing(source).ffiType();
            will(returnValue(ffiType));
            allowing(source).fileTimestamp();
            will(returnValue(timestamp));
            allowing(source).fsClient();
            will(returnValue(fsClient));
            allowing(source).piplineTaskId();
            will(returnValue(pipelineTaskId));
            allowing(source).readNoiseE(startMjd, endMjd);
            will(returnValue(readNoise));
            allowing(source).skyGroupId( startMjd, endMjd);
            will(returnValue(5555));
            allowing(source).generatedAt();
            will(returnValue(TestTimeConstants.GENERATED_AT));
            allowing(source).sipWcs(startMjd, endMjd, longCadence, imageWidth, imageHeight);
            will(returnValue(sipWcs));
            allowing(source).meanBlackCounts(startMjd, endMjd);
            will(returnValue(7.0));

            try {
                FfiFragmentGenerator ffiFragmentGenerator = new FfiFragmentGenerator() {
                    @Override
                    protected FfiIImageHeaderKeywordExtractor createKeywordValueExtractor(Header imageHeader) {
                        return keywordValueExtractor;
                    }
                    @Override
                    protected  FfiExposureCalculator ffiExposureCalculator(final double startMjd, final double endMjd,
                        final ConfigMap configMap) {
                        return exposureCalculator;
                    }
                    
                    @Override
                    protected FfiPrimaryHeaderKeywordExtractor createPrimaryKeywordExtractor(Header primaryHeader) throws KeplerException {
                        return primaryKeywordExtractor;
                    }
                };
                ffiFragmentGenerator.generateFragment(source);
            } finally {
                FileUtil.close(fout);
            }
            
            
            List<String> diffs = new ArrayList<String>();
            FitsDiff fitsDiff = new FitsDiff();
            fitsDiff.diff(expectedFile, outputFile, diffs);
            //JUMockTest badness : don't have assert with error message
            Assert.assertTrue(StringUtils.join(diffs.iterator(), "\n"), diffs.size() == 0);
        }

        protected SipWcsCoordinates sipWcs() {
            return ExampleSipWcsCoordinates.example();
        }
        
        protected ModOutBarycentricCorrection barycentricCorrection() {
            return new ModOutBarycentricCorrection(barycentricCorrectionDays, 1, 2);
        }
        
        protected FfiExposureCalculator exposureCalculator(float[][] originalImage,
            float[][] electronsPerSecondImage) {
            final FfiExposureCalculator exposureCalculator = mock(FfiExposureCalculator.class);
            allowing(exposureCalculator).deadC();
            will(returnValue(0.1));
            allowing(exposureCalculator).elaspedTimeDays();
            will(returnValue(0.2));
            allowing(exposureCalculator).exposureDays();
            will(returnValue(0.3));
            allowing(exposureCalculator).fgsFrameTimeMilliS();
            will(returnValue(0.4));
            allowing(exposureCalculator).integrationTimeSec();
            will(returnValue(0.5));
            allowing(exposureCalculator).liveTimeDays();
            will(returnValue(0.6));
            allowing(exposureCalculator).nFgsFramesPerIntegration();
            will(returnValue(7));
            allowing(exposureCalculator).nIntegrationsPerFfiImage();
            will(returnValue(8));
            allowing(exposureCalculator).readTimeSec();
            will(returnValue(0.9));
            allowing(exposureCalculator).toElectronsPerSecond(originalImage, imageWidth, imageHeight);
            will(returnValue(electronsPerSecondImage));
            return exposureCalculator;
        }


        protected BasicHDU originalPrimaryHdu() {
            BasicHDU primaryHdu = mock(BasicHDU.class);
            Header primaryHeader = mock(Header.class, "primary");
            allowing(primaryHdu).getHeader();
            will(returnValue(primaryHeader));
            return primaryHdu;
        }


        protected ImageHDU originalImageHdu(float[][] originalImage) throws FitsException {
            ImageHDU imageHdu = mock(ImageHDU.class);
            Header imageHeader = mock(Header.class, "image");
            Data data = mock(Data.class);
            allowing(imageHdu).getHeader();
            will(returnValue(imageHeader));
            allowing(imageHdu).getData();
            will(returnValue(data));
            allowing(data).getData();
            will(returnValue(originalImage));
            return imageHdu;
        }


        protected FfiPrimaryHeaderKeywordExtractor ffiPrimaryHeaderKeywordExtractor(
            final CommonKeywordsExtractor commonExtractor) {
            final FfiPrimaryHeaderKeywordExtractor primaryKeywordExtractor = mock(FfiPrimaryHeaderKeywordExtractor.class);
            allowing(primaryKeywordExtractor).common();
            will(returnValue(commonExtractor));
            return primaryKeywordExtractor;
        }


        protected FfiIImageHeaderKeywordExtractor ffiImageHeaderKeywordExtractor(
            final CommonKeywordsExtractor commonExtractor) {
            final FfiIImageHeaderKeywordExtractor keywordValueExtractor = mock(FfiIImageHeaderKeywordExtractor.class);
            allowing(keywordValueExtractor).imageHeight();
            will(returnValue(imageHeight));
            allowing(keywordValueExtractor).imageWidth();
            will(returnValue(imageWidth));
            allowing(keywordValueExtractor).ccdModule();
            will(returnValue(ccdModule));
            allowing(keywordValueExtractor).ccdOutput();
            will(returnValue(ccdOutput));
            allowing(keywordValueExtractor).common();
            will(returnValue(commonExtractor));
            return keywordValueExtractor;
        }


        protected CommonKeywordsExtractor commonKeywordsExtractor() {
            final CommonKeywordsExtractor commonExtractor = mock(CommonKeywordsExtractor.class);
            allowing(commonExtractor).startMjd();
            will(returnValue(startMjd));
            allowing(commonExtractor).endMjd();
            will(returnValue(endMjd));
            allowing(commonExtractor).finePoint();
            will(returnValue(finePoint));
            allowing(commonExtractor).momentiumDump();
            will(returnValue(momentiumDump));
            allowing(commonExtractor).longCadence();
            will(returnValue(longCadence));
            return commonExtractor;
        }
    }
}
