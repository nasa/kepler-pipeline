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

package gov.nasa.kepler.cal.ffi;

import java.io.*;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.List;

import gov.nasa.kepler.cal.io.Cal2DCollateral;
import gov.nasa.kepler.cal.io.CalInputPixelTimeSeries;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.fs.api.BlobClient;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.StreamedBlobResult;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.os.ProcessUtils;
import static gov.nasa.kepler.common.FcConstants.*;
import static org.junit.Assert.*;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class FfiReaderTest {
    
    private static final long ORIGINATOR = 23L;
    
    private final File testRoot =  
        new File(Filenames.BUILD_TEST, "FfiReaderTest.test");
    
    private final File ffiFile = new File(SocEnvVars.getLocalTestDataDir(),
        "/cal/unit-test/kplr2009095195923_ffi-orig.fits.bz2");

    @Before
    public void setUp() throws IOException {
        FileUtil.mkdirs(testRoot);
    }
    
    @After
    public void cleanUp() throws Exception {
        FileUtil.removeAll(testRoot);
    }
    
    @Test
    public void testFfiReader() throws Exception {
        ConfigMap configMap = new FakeConfigMap();
       
        
        final FsId ffiId = new FsId("/fake-ffi/TODO");
        final InvocationHandler invocationHandler = new InvocationHandler() {
            @Override
            public Object invoke(Object proxy, Method method, Object[] args)
                throws Throwable {

                if (method.getName().equals("toString")) {
                    return "Dynamic Proxy";
                }
                
                if (method.getName().equals("isStreamOpen")) {
                    return false;
                }
                
                if (!method.getName().equals("readBlobAsStream")) {
                    throw new IllegalStateException("Do not call this method." + method);
                }
                
                
                Class<?>[] parameters = method.getParameterTypes();
                if (parameters.length != 1 || 
                    parameters[0] != FsId.class) {
                    
                    throw new IllegalStateException("Do not call this method.");
                }
               
                if (!ffiId.equals(args[0])) {
                    throw new IllegalArgumentException("Bad fsid \"" + ffiId + "\".");
                }
                final Process bzip2Process = Runtime.getRuntime().exec("bzip2 -d -c " + ffiFile.getAbsolutePath());
                final InputStream bzip2 = bzip2Process.getInputStream();
                InputStream bzip2CloseProcess = new InputStream() {

                    @Override
                    public int read() throws IOException {
                        return bzip2.read();
                    }
                    
                    @Override
                    public int read(byte[] buf, int off, int len) throws IOException {
                        return bzip2.read(buf, off, len);
                    }
                    
                    @Override
                    public void close() throws IOException {
                        ProcessUtils.closeProcess(bzip2Process);
                    }
                    
                };
                
              //  FileInputStream fin = new FileInputStream(ffiFile);
               // BufferedInputStream bin = new BufferedInputStream(fin);
               // BZip2CompressorInputStream bzip2 = new BZip2CompressorInputStream(bin);
                return new StreamedBlobResult(ORIGINATOR, ffiFile.length(), bzip2CloseProcess);
            }
        };
            
        FileStoreClient fsClient = (FileStoreClient)
            Proxy.newProxyInstance(getClass().getClassLoader(), 
                new Class<?>[] {FileStoreClient.class, BlobClient.class}, invocationHandler);
            
        FileStoreClientFactory.setInstance(fsClient);
        
        FfiReader ffiReader = new FfiReader();
        
        FfiModOut ffiModOut = ffiReader.readFfi(ffiId, 2, 1);
        assertEquals(ORIGINATOR, ffiModOut.originator);
        
        List< CalInputPixelTimeSeries> pixelSeriesList = ffiModOut.allPixels();
        assertEquals(CCD_COLUMNS * CCD_ROWS, pixelSeriesList.size());
        Cal2DCollateral cal2DCollateral = ffiModOut.collateral(configMap);
        
        int[][] blackPixels = cal2DCollateral.getBlackStruct().getPixels();
        assertEquals(CCD_ROWS, blackPixels.length);
        assertEquals(20, blackPixels[0].length);
        
        int[][] virtualSmearPixels = cal2DCollateral.getVirtualSmearStruct().getPixels();
        assertEquals(26, virtualSmearPixels.length);
        assertEquals(nColsImaging, virtualSmearPixels[0].length);

        int[][] maskedSmearPixels = cal2DCollateral.getMaskedSmearStruct().getPixels();
        assertEquals(20, maskedSmearPixels.length);
        assertEquals(nColsImaging, maskedSmearPixels[0].length);

    }


}
