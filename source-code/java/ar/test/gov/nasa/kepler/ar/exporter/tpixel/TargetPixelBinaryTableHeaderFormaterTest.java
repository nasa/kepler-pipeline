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

package gov.nasa.kepler.ar.exporter.tpixel;

import static gov.nasa.kepler.common.FitsConstants.*;
import static org.junit.Assert.*;

import java.io.File;
import java.util.Date;

import gov.nasa.kepler.ar.exporter.DefaultCelestialWcs;
import gov.nasa.kepler.ar.exporter.binarytable.ArrayDimensions;
import gov.nasa.kepler.common.*;
import gov.nasa.kepler.hibernate.cal.BlackAlgorithm;
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

/**
 * @author Sean McCauliff
 *
 */
@RunWith(JMock.class)
public class TargetPixelBinaryTableHeaderFormaterTest {

    private static final int N_ROWS = 64;
    private static final int N_COLS = 128;
    private Mockery mockery;
    
    @Before
    public void setUp() {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
    }
    
    @Test
    public void testTargetPixelBinaryTableHeader() throws Exception {

        final Date generatedAtDate = new Date(0L);
        final TargetPixelHeaderSource source = mockery.mock(TargetPixelHeaderSource.class);
        mockery.checking(new Expectations() {{
            atLeast(1).of(source).keplerId();
            will(returnValue(5562342));
            atLeast(1).of(source).daysOnSource();
            will(returnValue(0.1));
            atLeast(1).of(source).deadC();
            will(returnValue(1.0));
            atLeast(1).of(source).decDegrees();
            will(returnValue(23.0));
            atLeast(1).of(source).endKbjd();
            will(returnValue(29.5));
            atLeast(1).of(source).framesPerCadence();
            will(returnValue(30*60/6));
            atLeast(1).of(source).gainEPerCount();
            will(returnValue(1.7));
            atLeast(1).of(source).kbjdReferenceFraction();
            will(returnValue(0.0));
            atLeast(1).of(source).kbjdReferenceInt();
            will(returnValue(55000));
            atLeast(1).of(source).meanBlackCounts();
            will(returnValue(8));
            atLeast(1).of(source).nBinaryTableRows();
            will(returnValue(1400));
            atLeast(1).of(source).photonAccumulationTimeSec();
            will(returnValue(6.0));
            atLeast(1).of(source).raDegrees();
            will(returnValue(42.0));
            atLeast(1).of(source).readNoiseE();
            will(returnValue(0.7));
            atLeast(1).of(source).readoutTimePerFrameSec();
            will(returnValue(.25));
            atLeast(1).of(source).readsPerCadence();
            will(returnValue(30*60/6));
            atLeast(1).of(source).startKbjd();
            will(returnValue(1.7));
            atLeast(1).of(source).startMidMjd();
            will(returnValue(55555.0));
            atLeast(1).of(source).endMidMjd();
            will(returnValue(55583.88833));
            atLeast(1).of(source).timeResolutionOfDataDays();
            will(returnValue(Math.PI/100000.0));
            atLeast(1).of(source).timeSlice();
            will(returnValue(7));
            atLeast(1).of(source).observationStartUTC();
            will(returnValue(ModifiedJulianDate.mjdToDate(0)));
            atLeast(1).of(source).observationEndUTC();
            will(returnValue(ModifiedJulianDate.mjdToDate(ModifiedJulianDate.KJD_OFFSET_FROM_MJD)));
            atLeast(1).of(source).referenceRow();
            will(returnValue(555));
            atLeast(1).of(source).referenceColumn();
            will(returnValue(666));
            atLeast(1).of(source).liveTimeDays();
            will(returnValue(777.1));
            atLeast(1).of(source).scienceFrameTimeSec();
            will(returnValue(888.2));
            atLeast(1).of(source).longCadenceFixedOffset();
            will(returnValue(1));
            atLeast(1).of(source).shortCadenceFixedOffset();
            will(returnValue(2));
            one(source).generatedAt();
            will(returnValue(generatedAtDate));
            one(source).cdpp3Hr();
            will(returnValue(null));
            one(source).cdpp6Hr();
            will(returnValue(6.0f));
            one(source).cdpp12Hr();
            will(returnValue(12.0f));
            one(source).fluxFractionInOptimalAperture();
            will(returnValue(0.999));
            one(source).crowding();
            will(returnValue(0.777));
            one(source).extensionName();
            will(returnValue("TARGETTABLES"));
            one(source).backgroundSubtracted();
            will(returnValue(true));
            one(source).elaspedTime();
            will(returnValue(27.8));
            atLeast(1).of(source).isK2();
            will(returnValue(false));
            atLeast(1).of(source).rollingBandDurations();
            will(returnValue(new int[] { 4 , 7}));
            atLeast(1).of(source).dynablackColumnCutoff();
            will(returnValue(34343));
            atLeast(1).of(source).dynablackThreshold();
            will(returnValue(7.1));
            atLeast(1).of(source).blackAlgorithm();
            will(returnValue(BlackAlgorithm.POLYNOMIAL_1D_BLACK));
            atLeast(1).of(source).isSingleQuarter();
            will(returnValue(true));
        }});
        
        ArrayDimensions arrayDimensions = 
            ArrayDimensions.newInstance(new Integer[] { N_ROWS, N_COLS}, "RB_LEVEL", new Integer[] { N_ROWS, 3});
        TargetPixelBinaryTableHeaderFormatter formatter = new TargetPixelBinaryTableHeaderFormatter();
        Header binaryTableHeader = formatter.formatHeader(source, new DefaultCelestialWcs(), CHECKSUM_DEFAULT, arrayDimensions);
        String actual = FitsUtils.headerToString(binaryTableHeader);
        
        String actual80 = StringUtils.breakAt80Characters(actual);
        FileUtils.writeStringToFile(new File("/tmp/tpixel.bintable.header.fits"), actual80);
        String expected80 = FileUtils.readFileToString(new File("testdata/tpixel.bintable.header.fits"));
        assertEquals(expected80, actual80);

    }
}
