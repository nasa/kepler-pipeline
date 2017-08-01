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

import gov.nasa.kepler.mc.KeplerException;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;

import org.junit.Ignore;
import org.junit.Test;

import static gov.nasa.kepler.common.FitsConstants.*;
import static org.junit.Assert.*;

/**
 * @author Sean McCauliff
 *
 */
public class FfiKeywordValueExtractorTest {

    @Test
    public void extractWithStandardKeywords() throws Exception {
        Header primaryHeader = generatePrimaryHeader();
        Header imageHeader = generateImageHeader();

        
        extractAndCheck(primaryHeader, imageHeader);
    }

    private static Header generateImageHeader() throws HeaderCardException {
        Header header = new Header();
        header.addValue(BITPIX_KW, BITPIX_SINGLE_PRECISION_IMAGE, BITPIX_COMMENT);
        header.setNaxes(2);
        header.setNaxis(1, 1000);
        header.setNaxis(2, 2000);
        header.addValue(MJDSTART_KW, 1.0, MJDSTART_COMMENT);
        header.addValue(MJDEND_KW, 2.0, MJDEND_COMMENT);
        header.addValue(MODULE_KW, 3, MODULE_COMMENT);
        header.addValue(OUTPUT_KW, 4, OUTPUT_COMMENT);
        header.addValue(FINE_PNT_KW, true, FINE_PNT_COMMENT);
        header.addValue(MMNTMDMP_KW, false, MMNTMDMP_COMMENT);
        return header;
    }
    
    private static Header generatePrimaryHeader() throws HeaderCardException {
        Header header = new Header();
        header.addValue(BITPIX_KW, BITPIX_EMPTY_PRIMARY_VALUE, BITPIX_COMMENT);
        header.addValue(ROLL_NOM_KW, 1.0, ROLL_NOM_COMMENT);
        header.addValue(RA_NOM_KW, 2.0, RA_NOM_COMMENT);
        header.addValue(DEC_NOM_KW, 3.0, DEC_NOM_COMMENT);
        header.addValue(REV_CLCK_KW, true, REV_CLCK_COMMENT);
        header.addValue(FOCPOS1_KW, 4.0, FOCPOS1_COMMENT);
        header.addValue(FOCPOS2_KW, 5.0, FOCPOS2_COMMENT);
        header.addValue(FOCPOS3_KW, 6.0, FOCPOS3_COMMENT);
        header.addValue(DATSETNM_KW, "kepler007", "the less said the better");
        header.addValue(DCT_TIME_KW, "dct_time_value", "whatever");
        //TODO:  This is a slightly different keyword than the old FITS files
        //does the SO really mean to change it.
        header.addValue(SCCONFIG_KW, 7, SCCONFIG_COMMENT);
        return header;
        
    }

    private void extractAndCheck(Header primaryHeader, Header imageHeader) throws KeplerException {
        FfiIImageHeaderKeywordExtractor imageExtractor = 
            new FfiIImageHeaderKeywordExtractor(imageHeader);
        FfiPrimaryHeaderKeywordExtractor primaryExtractor = 
            new FfiPrimaryHeaderKeywordExtractor(primaryHeader);
        
        assertEquals(1.0, primaryExtractor.boresightRollDeg(), 0);
        assertEquals(2.0, primaryExtractor.boresightRaDeg(), 0);
        assertEquals(3.0, primaryExtractor.boresightDecDeg(), 0);
        assertTrue(primaryExtractor.reverseClocked());
        assertEquals(4.0, primaryExtractor.focuserPositions()[0], 0);
        assertEquals(5.0, primaryExtractor.focuserPositions()[1], 0);
        assertEquals(6.0, primaryExtractor.focuserPositions()[2], 0);
        assertEquals("kepler007", primaryExtractor.datasetName());
        assertEquals("dct_time_value", primaryExtractor.dataCollectionTime());
        
        
        assertEquals(1.0, imageExtractor.common().startMjd(), 0);
        assertEquals(2.0, imageExtractor.common().endMjd(), 0);
        assertTrue(imageExtractor.common().finePoint());
        assertFalse(imageExtractor.common().momentiumDump());
        assertEquals(1000, imageExtractor.imageWidth());
        assertEquals(2000, imageExtractor.imageHeight());
        

    }
    
    //TODO:  Make new deprecation tests.
    @SuppressWarnings("deprecation")
    @Ignore
    public void extractWithLegacyKeywords() throws Exception {
//        Header header = generatePrimaryHeader();
//        header.removeCard(MJDSTART_KW);
//        header.removeCard(MJDEND_KW);
//        header.addValue(STARTIME_KW, 1.0, "deprecated keyword");
//        header.addValue(END_TIME_KW, 2.0, "deprecated keyword");
//        header.addValue(FINE_PNT_KW, true, FINE_PNT_COMMENT);
//        header.addValue(MMNTMDMP_KW, false, MMNTMDMP_COMMENT);
//        
//        extractAndCheck(header);
    }
    
}
