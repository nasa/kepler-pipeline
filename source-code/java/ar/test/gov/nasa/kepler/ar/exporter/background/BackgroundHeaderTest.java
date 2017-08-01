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

import java.io.File;
import java.util.Date;

import gov.nasa.kepler.ar.exporter.ExampleSipWcsCoordinates;
import gov.nasa.kepler.ar.exporter.binarytable.ArrayDimensions;
import gov.nasa.kepler.ar.exporter.binarytable.BaseBinaryTableHeaderSource;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.SipWcsCoordinates;
import gov.nasa.spiffy.common.lang.StringUtils;
import nom.tam.fits.Header;

import org.apache.commons.io.FileUtils;
import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import static gov.nasa.kepler.ar.exporter.background.BackgroundBinaryTableHeaderFormatter.BKG_POLY_COEFF;
import static gov.nasa.kepler.ar.exporter.background.BackgroundBinaryTableHeaderFormatter.BKG_POLY_ERR_COEFF;
import static gov.nasa.kepler.common.FitsConstants.*;
import static org.junit.Assert.*;
import static gov.nasa.kepler.common.FitsUtils.headerToString;

import gov.nasa.kepler.ar.exporter.background.BackgroundPolynomial.Polynomial;

/**
 * Tests for all the background pixel file headers.
 * 
 * @author Sean McCauliff
 *
 */
@RunWith(JMock.class)
public class BackgroundHeaderTest {

    private final static int nBackgroundPixels = 4464;
    private final static int nPolynomialCoeff = 2;
    
    private Mockery mockery;
    
    @Before
    public void setUp() {
        mockery = new Mockery() {{
            setImposteriser(ClassImposteriser.INSTANCE);
        }};
    }
    
    
    @Test
    public void backgroundBinaryTableHeader() throws Exception {

        final Date generatedAt = ModifiedJulianDate.mjdToDate(55555.55);
        
        final BackgroundTableHeaderSource source = mockery.mock(BackgroundTableHeaderSource.class);
        mockery.checking(new Expectations() {{
            atLeast(1).of(source).daysOnSource();
            will(returnValue(1.1));
            atLeast(1).of(source).deadC();
            will(returnValue(2.2));
            atLeast(1).of(source).endKbjd();
            will(returnValue(4.4));
            atLeast(1).of(source).endMidMjd();
            will(returnValue(5.5));
            atLeast(1).of(source).extensionName();
            //TODO:  this constant should be defined someplace in ar src
            will(returnValue("BACKGROUND"));
            atLeast(1).of(source).framesPerCadence();
            will(returnValue(6));
            atLeast(1).of(source).gainEPerCount();
            will(returnValue(7.7));
            atLeast(1).of(source).generatedAt();
            will(returnValue(generatedAt));
            atLeast(1).of(source).kbjdReferenceFraction();
            will(returnValue(.888));
            atLeast(1).of(source).kbjdReferenceInt();
            will(returnValue(9999));
            atLeast(1).of(source).liveTimeDays();
            will(returnValue(10.10));
            atLeast(1).of(source).longCadenceFixedOffset();
            will(returnValue(11));
            atLeast(1).of(source).meanBlackCounts();
            will(returnValue(12));
            atLeast(1).of(source).nBinaryTableRows();
            will(returnValue(13));
            atLeast(1).of(source).observationEndUTC();
            will(returnValue(new Date(14)));
            atLeast(1).of(source).observationStartUTC();
            will(returnValue(new Date(15)));
            atLeast(1).of(source).photonAccumulationTimeSec();
            will(returnValue(16.16));
            atLeast(1).of(source).readNoiseE();
            will(returnValue(17.17));
            atLeast(1).of(source).readoutTimePerFrameSec();
            will(returnValue(18.18));
            atLeast(1).of(source).readsPerCadence();
            will(returnValue(19));
            atLeast(1).of(source).scienceFrameTimeSec();
            will(returnValue(20.20));
            atLeast(1).of(source).shortCadenceFixedOffset();
            will(returnValue(21));
            atLeast(1).of(source).startKbjd();
            will(returnValue(22.22));
            atLeast(1).of(source).startMidMjd();
            will(returnValue(23.23));
            atLeast(1).of(source).timeResolutionOfDataDays();
            will(returnValue(24.24));
            atLeast(1).of(source).timeSlice();
            will(returnValue(25));
            atLeast(1).of(source).backgroundSubtracted();
            will(returnValue(true));
            atLeast(1).of(source).elaspedTime();
            will(returnValue(-17.73000000));

        }});
        
        BackgroundPolynomial bkgPolynomial = new BackgroundPolynomial(1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 
            new Polynomial[] {new Polynomial(new double[] {0,  0}, new double[] {0, 0, 0, 0}, false)});
        
        ArrayDimensions arrayDimensions = 
            ArrayDimensions.newInstance(nBackgroundPixels,
                                        BKG_POLY_COEFF, bkgPolynomial.fitsDimensions(),
                                        BKG_POLY_ERR_COEFF, bkgPolynomial.fitsCovarianceDimensions());
        BackgroundBinaryTableHeaderFormatter formatter = 
            new BackgroundBinaryTableHeaderFormatter();
        assertEquals(8+4+4+nBackgroundPixels*(8+4*6)+nPolynomialCoeff*8 + nPolynomialCoeff*nPolynomialCoeff*8,
            formatter.bytesPerTableRow(arrayDimensions));
        

        Header h = formatter.formatHeader(source, CHECKSUM_DEFAULT, bkgPolynomial, arrayDimensions);
        String actual = headerToString(h);
        String actual80 = StringUtils.breakAt80Characters(actual);
        FileUtils.writeStringToFile(new File("/tmp/background.bintable.header.txt"), actual80);
        String expected80 = FileUtils.readFileToString(new File("testdata/background.bintable.header.txt"));
        assertEquals(expected80, actual80);
    }
    
    @Test
    public void backgroundPixelListHeader() throws Exception {
        final Date generatedAt = new Date(7);
        final BaseBinaryTableHeaderSource source = mockery.mock(BaseBinaryTableHeaderSource.class);
        mockery.checking(new Expectations() {{
            atLeast(1).of(source).extensionName();
            will(returnValue("PIXELS"));
            atLeast(1).of(source).generatedAt();
            will(returnValue(generatedAt));
            atLeast(1).of(source).nBinaryTableRows();
            will(returnValue(3));
        }});
        
        
        BackgroundPixelListHeaderFormatter formatter = 
            new BackgroundPixelListHeaderFormatter();
        
        SipWcsCoordinates sipWcs = ExampleSipWcsCoordinates.example();
        Header h = formatter.formatHeader(source, 1, sipWcs, CHECKSUM_DEFAULT);
        String actual = headerToString(h);
        String actual80 = StringUtils.breakAt80Characters(actual);
        FileUtils.writeStringToFile(new File("/tmp/background.pixellist.header.txt"), actual80);
        String expected80 = FileUtils.readFileToString(new File("testdata/background.pixellist.header.txt"));
        assertEquals(expected80, actual80);
    }
}
