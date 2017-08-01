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

package gov.nasa.kepler.ar.exporter.cbv;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.ar.archive.CotrendingBasisVectors;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.*;
import gov.nasa.kepler.fs.api.BlobResult;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.mc.dr.MjdToCadence.DataAnomalyFlags;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.ArFsIdFactory;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.*;
import java.util.*;
import java.util.concurrent.atomic.AtomicReference;

import org.apache.commons.lang.StringUtils;
import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

/**
 * @author Sean McCauliff
 *
 */
@RunWith(JMock.class)
public class CbvModOutExporterTest {

    private Mockery mockery;
    private static final int startCadence = 10;
    private static final int endCadence = 100;
    private static final CadenceType cadenceType = CadenceType.LONG;
    private static final int quarter = 10;
    private static final double startMjd = 66666;
    private static final double endMjd = startMjd + 1;
    private static final int ccdModule = 2;
    private static final int ccdOutput = 1;
    private static final long pipelineTaskId = 5556L;
    private static final long pdcPipelineTaskId = 343455L;
    
    private final File testDir = 
        new File(Filenames.BUILD_TEST, "CbvModOutExporterTest");
    private final File testDataDir = 
        new File(Filenames.BUILD_TEST + "/../../testdata");
    private final File expectedModOutCbvFile = 
        new File(testDataDir, "cbvmodout.fits");
    private final File expectedEmptyModOutCbvFile = 
        new File(testDataDir, "emptycbvmodout.fits");
    
    @Before
    public void setup() throws Exception {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
        FileUtil.mkdirs(testDir);
    }
   
    /**
     * This can happen when exporting module 3.
     * @throws Exception
     */
    @Test
    public void emptyCbvModOutExporterTest() throws Exception {
        cbvModOutExporterTest(false);
    }
    
    /**
     * The normal case, PDC generated a CBV blob.
     * @throws Exception
     */
    @Test
    public void validCbvModOutExporterTest() throws Exception {
        cbvModOutExporterTest(true);
    }
    
    private void cbvModOutExporterTest(boolean generateCbv) throws Exception {
        final CbvModOutExporterSource source = createSource(generateCbv);
        
        final AtomicReference<byte[]> fitsDataRef = new AtomicReference<byte[]>();
        CbvModOutExporter exporter = new CbvModOutExporter() {
            @Override
            protected void writeHdu(CbvModOutExporterSource source, FsId arFsId,
                byte[] fitsData) {
                
                fitsDataRef.set(fitsData);
            }
        };
        
        exporter.export(source);
        
        String outputFileName = (generateCbv) ? "modout.fits" : "emptymodout.fits";
        File modOutFile = new File(testDir, outputFileName);
        FileOutputStream fout = new FileOutputStream(modOutFile);
        fout.write(fitsDataRef.get());
        fout.close();
        
        FitsDiff fitsDiff = new FitsDiff();
        List<String> differences = new ArrayList<String>();
        File expectedFile = (generateCbv) ? expectedModOutCbvFile : expectedEmptyModOutCbvFile;
        fitsDiff.diff(modOutFile, expectedFile  , differences);
        String errMsg = StringUtils.join(differences.iterator(), "\n");
        assertEquals(errMsg, 0, differences.size());
    }

    private CbvModOutExporterSource createSource(final boolean returnCbv) {
        
        final Date generatedAt = new Date(4343434);
        
        final CbvModOutExporterSource source = mockery.mock(CbvModOutExporterSource.class);
        mockery.checking(new Expectations() {{
            atLeast(1).of(source).ccdModule();
            will(returnValue(ccdModule));
            atLeast(1).of(source).ccdOutput();
            will(returnValue(ccdOutput));
            atLeast(1).of(source).basisVectors();
            if (returnCbv) {
                will(returnValue(createBasisVectors()));
            } else {
                will(returnValue(null));
            }
            atLeast(1).of(source).cadenceTimes();
            will(returnValue(createCadenceTimes()));
            atLeast(1).of(source).generatedAt();
            will(returnValue(generatedAt));
            atLeast(1).of(source).quarter();
            will(returnValue(quarter));
            allowing(source).startCadence();
            will(returnValue(startCadence));
            allowing(source).endCadence();
            will(returnValue(endCadence));
            atLeast(1).of(source).cadenceType();
            will(returnValue(cadenceType));
            atLeast(1).of(source).startMjd();
            will(returnValue(startMjd));
            atLeast(1).of(source).endMjd();
            will(returnValue(endMjd));
            allowing(source).pipelineTaskCrud();
            will(returnValue(pipelineTaskCrud()));
            allowing(source).useFakeMjds();
            will(returnValue(false));
        }});
        return source;
    }
    

    private PipelineTaskCrud pipelineTaskCrud() {
        final PipelineTaskCrud ptaskCrud = mockery.mock(PipelineTaskCrud.class);
        final PipelineTask pipelineTask = mockery.mock(PipelineTask.class);
        mockery.checking(new Expectations() {{
            allowing(ptaskCrud).retrieve(pdcPipelineTaskId);
            will(returnValue(pipelineTask));
            allowing(pipelineTask).getSoftwareRevision();
            will(returnValue("svn+ssh://host/path/to/code@1234"));
        }});
        return ptaskCrud;
    }
    
    private TimestampSeries createCadenceTimes() {
        boolean[] gaps = new boolean[endCadence -  startCadence + 1];
        int gappedCadenceIndex = 44;
        gaps[gappedCadenceIndex] = true;
        double[] midMjds = new double[gaps.length];
        for (int i=0; i < gaps.length; i++) {
            midMjds[i] = startMjd + (1/(double)gaps.length) * i;
        }
        midMjds[gappedCadenceIndex] = 0;
        int[] cadenceNumbers = new int[gaps.length];
        for (int c=startCadence; c <= endCadence; c++) {
            cadenceNumbers[c - startCadence] = c;
        }
        
        boolean[] noGap = new boolean[gaps.length];
        boolean[] isFinePt = new boolean[gaps.length];
        Arrays.fill(isFinePt, true);
        DataAnomalyFlags dataAnomalyFlags = 
            new DataAnomalyFlags(
                noGap /*attitudeTweakIndicators*/  ,
                noGap /*safeModeIndicators*/       ,
                noGap /*coarsePointIndicators*/    ,
                noGap /*argabrighteningIndicators*/,
                noGap /*excludeIndicators*/        ,
                noGap /*earthPointIndicators */    , 
                null /*planetSearchExcludeIndicators*/);
        
        return new TimestampSeries(null, midMjds, null, gaps, null,
            cadenceNumbers, gaps, gaps, gaps, isFinePt, noGap, gaps, gaps,
            dataAnomalyFlags);
    }
    
    private CotrendingBasisVectors createBasisVectors() {
        float[][] noBandVectors = 
            new float[CbvModOutHeaderFormatter.N_COTRENDING_BASIS_VECTORS][endCadence - startCadence + 1];
        boolean[] additionalGaps = new boolean[endCadence - startCadence + 1];
        for (int i=0; i < noBandVectors.length; i++) {
            for (int j=0; j < noBandVectors[i].length; j++) {
                noBandVectors[i][j] = i * noBandVectors[i].length + j;
            }
        }
        return new CotrendingBasisVectors(noBandVectors, 0, pdcPipelineTaskId, additionalGaps);
      
    }
    
    @Test
    public void cbvAssemblerTest() throws Exception {
        final String fileTimeStamp = "000";
        final CbvAssemblerSource source = mockery.mock(CbvAssemblerSource.class);
        final Date generatedAt = new Date(4343444);
        mockery.checking(new Expectations() {{
            atLeast(1).of(source).cadenceType();
            will(returnValue(cadenceType));
            atLeast(1).of(source).dataRelease();
            will(returnValue(-1));
            atLeast(1).of(source).exportDirectory();
            will(returnValue(testDir));
            atLeast(1).of(source).exportTimestamp();
            will(returnValue(fileTimeStamp));
            atLeast(1).of(source).fileStoreClient();
            will(returnValue(fsClientForAssembler()));
            atLeast(1).of(source).generatedAt();
            will(returnValue(generatedAt));
            atLeast(1).of(source).pipelineTaskId();
            will(returnValue(pipelineTaskId));
            atLeast(1).of(source).programName();
            will(returnValue(this.getClass().getSimpleName()));
            atLeast(1).of(source).quarter();
            will(returnValue(quarter));
            atLeast(1).of(source).season();
            will(returnValue(3));
            atLeast(1).of(source).isK2();
            will(returnValue(false));
        }});
        
        CbvAssembler assembler = new CbvAssembler();
        assembler.assemble(source);
    }
    
    private FileStoreClient fsClientForAssembler() throws IOException {
        
        int modOutFileSize = (int) expectedModOutCbvFile.length();
        byte[] modOutData = new byte[modOutFileSize];
        FileInputStream fin = new FileInputStream(expectedModOutCbvFile);
        DataInputStream din = new DataInputStream(fin);
        din.readFully(modOutData);
        fin.close();
        final FileStoreClient fsClient = mockery.mock(FileStoreClient.class);
        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                final FsId modOutBlobId = ArFsIdFactory.
                    getSingleChannelCbvFile(ccdModule, ccdOutput, cadenceType, quarter);
                final BlobResult modOutBlob = new BlobResult(pipelineTaskId, modOutData);
                mockery.checking(new Expectations() {{
                    atLeast(1).of(fsClient).blobExists(modOutBlobId);
                    will(returnValue(true));
                    atLeast(1).of(fsClient).readBlob(modOutBlobId);
                    will(returnValue(modOutBlob));
                }});
            }
        }
        
        return fsClient;
    }
}
