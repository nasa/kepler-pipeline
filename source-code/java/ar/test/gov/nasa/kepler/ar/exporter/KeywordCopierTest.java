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

package gov.nasa.kepler.ar.exporter;

import static org.junit.Assert.*;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.*;

import gov.nasa.kepler.common.Cadence;
import static gov.nasa.kepler.common.FitsConstants.*;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.StreamedBlobResult;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;

import nom.tam.fits.*;
import nom.tam.util.BufferedDataOutputStream;

import org.apache.commons.io.output.ByteArrayOutputStream;
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
public class KeywordCopierTest {

    public static final int MODULE_VALUE = 2;
    public static final int OUTPUT_VALUE = 1;
    
    private static final String[] WCS_KEYWORD_ARRAY = 
    { WCSAXES_KW, CRPIX1_KW, CRPIX2_KW, CTYPE1_KW, CTYPE2_KW, "CDELT1", "CDELT2",
        "PC1_1", "PC1_2", "PC2_1", "PC2_2", CRVAL1_KW, CRVAL2_KW
    };
    
    private static final Set<String> WCS_KEYWORDS = 
        Collections.unmodifiableSet(new HashSet<String>(Arrays.asList(WCS_KEYWORD_ARRAY)));
    
    
    private Mockery mockery;

    @Before
    public void setUp() throws Exception {
        mockery = new Mockery() {
            {
                setImposteriser(ClassImposteriser.INSTANCE);
            }
        };
    }

    @SuppressWarnings("deprecation")
    @Test
    public void testWcsKeywordFactory() throws Exception {
        final String FITS_NAME = "blahblahblah.fits";
        final String FITS_NAME2 = "blahblah.fits";
        final FileStoreClient fsClient = mockery.mock(FileStoreClient.class);
        final LogCrud logCrud = mockery.mock(LogCrud.class);

        final PixelLog pixelLog = new PixelLog();
        final PixelLog pixelLog2 = new PixelLog();
        final StreamedBlobResult pixelBlobResult = createHeaderBlobResult();
        final StreamedBlobResult pixelBlobResult2 = createHeaderBlobResult();
        final FsId blobId = DrFsIdFactory.getPixelFitsHeaderFile(FITS_NAME);
        final FsId blobId2 = DrFsIdFactory.getPixelFitsHeaderFile(FITS_NAME2);
         
        pixelLog.setFitsFilename(FITS_NAME);
        pixelLog.setDataSetType(DataSetType.Target);
        pixelLog2.setDataSetType(DataSetType.Target);
        pixelLog2.setFitsFilename(FITS_NAME2);
        
        mockery.checking(new Expectations() { {
            one(logCrud).retrievePixelLog(Cadence.CADENCE_LONG, 1, 1);
            will(returnValue(Collections.singletonList(pixelLog)));
            
            one(fsClient).readBlobAsStream(blobId);
            will(returnValue(pixelBlobResult));
            
            one(logCrud).retrievePixelLog(Cadence.CADENCE_LONG, 2, 2);
            will(returnValue(Collections.singletonList(pixelLog2)));
            
            one(fsClient).readBlobAsStream(blobId2);
            will(returnValue(pixelBlobResult2));
            
        } });
        
        KeywordCopier factory = new KeywordCopier(logCrud, fsClient);
        Header destHeader = new Header();
        factory.addKeywordsToHeader(destHeader, WCS_KEYWORDS, 1, Cadence.CadenceType.LONG, 
            MODULE_VALUE, OUTPUT_VALUE);
        factory.addKeywordsToHeader(destHeader, POINTING_KEYWORDS, 2, Cadence.CadenceType.LONG);
        assertTrue(destHeader.containsKey(WCSAXES_KW));
        assertTrue(destHeader.containsKey("PC1_1"));
        assertFalse(destHeader.containsKey("BOGUS1"));
        assertTrue(destHeader.containsKey(RA_XAXIS_KW));
        
    }

    public static StreamedBlobResult createHeaderBlobResult() throws FitsException, IOException {
        Fits fits = new Fits();
        
        Header primaryHeader = new Header();
        primaryHeader.setSimple(true);
        primaryHeader.setBitpix(8);
        primaryHeader.setNaxes(0);
        primaryHeader.addValue(NEXTEND_KW, 1, "Number of standard extensions.");
        primaryHeader.addValue(RA_XAXIS_KW, 23.44, "");
        
        fits.addHDU(Fits.makeHDU(primaryHeader));
        
        BinaryTable binaryTable = new BinaryTable();
        Header extensionHeader = BinaryTableHDU.manufactureHeader(binaryTable);
        extensionHeader.addValue("B0GUS1", 23425, "This is a bogus keyword.");
        extensionHeader.insertComment("WCS Keywords");
        extensionHeader.addValue(WCSAXES_KW, 2, "WCS axes");
        extensionHeader.addValue("PC1_1", 3434.222, "some value");
        extensionHeader.addValue(MODULE_KW, MODULE_VALUE, "");
        extensionHeader.addValue(OUTPUT_KW, OUTPUT_VALUE, "");
        
        fits.addHDU(new BinaryTableHDU(extensionHeader, binaryTable));
        
        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        BufferedDataOutputStream fitsOut = new BufferedDataOutputStream(bout);
        fits.write(fitsOut);
        fitsOut.close();
        byte[] headerData = bout.toByteArray();
        ByteArrayInputStream bin = new ByteArrayInputStream(headerData);
        StreamedBlobResult blobResult = new StreamedBlobResult(1L, headerData.length, bin);
        return blobResult;
    }
}
