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

import static gov.nasa.kepler.common.FitsConstants.*;
import java.io.File;

import nom.tam.fits.Header;

import org.apache.commons.io.FileUtils;
import org.jmock.integration.junit4.JMock;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import gov.nasa.kepler.ar.exporter.ExampleSipWcsCoordinates;
import gov.nasa.kepler.common.*;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.lang.StringUtils;

import static gov.nasa.kepler.ar.TestTimeConstants.*;

import static org.junit.Assert.*;

/**
 * @author Sean McCauliff
 *
 */
@RunWith(JMock.class)
public class FfiImageHeaderFormatterTest extends JMockTest {

    private final File testDir = new File(Filenames.BUILD_TEST, "FfiImageHeaderFormatterTest");
    
    @Before
    public void setUp() throws Exception {
        FileUtil.cleanDir(testDir);
        FileUtil.mkdirs(testDir);
    }
    
    @Test
    public void writeImageHeader() throws Exception {
        
        FfiImageHeaderSource source = super.mock(FfiImageHeaderSource.class);
        allowing(source).barycentricCorrection();
        will(returnValue((float) Math.PI));
        allowing(source).barycentricCorrectionReferenceColumn();
        will(returnValue(1.5));
        allowing(source).barycentricCorrectionReferenceRow();
        will(returnValue(2.5));
        allowing(source).barycentricStart();
        will(returnValue(5.5));
        allowing(source).barycentricEnd();
        will(returnValue(6.5));
        allowing(source).ccdChannel();
        will(returnValue(11));
        allowing(source).ccdModule();
        will(returnValue(12));
        allowing(source).ccdOutput();
        will(returnValue(13));
        allowing(source).checksumString();
        will(returnValue(CHECKSUM_DEFAULT));
        allowing(source).deadC();
        will(returnValue(Math.E));
        allowing(source).elaspedTimeDays();
        will(returnValue(7.7));
        allowing(source).startMjd();
        will(returnValue(55.6));
        allowing(source).endMjd();
        will(returnValue(77.8));
        allowing(source).exposureDays();
        will(returnValue(100.1));
        allowing(source).frameTimeSec();
        will(returnValue(100.2));
        allowing(source).generatedAt();
        will(returnValue(GENERATED_AT));
        allowing(source).imageHeight();
        will(returnValue(1000));
        allowing(source).imageWidth();
        will(returnValue(2000));
        allowing(source).integrationTimeSec();
        will(returnValue(2001.1));
        allowing(source).meanBlackCounts();
        will(returnValue(-1.0));
        allowing(source).nFgsFramesPerIntegration();
        will(returnValue(2002));
        allowing(source).nIntegrationsCoaddedPerFfiImage();
        will(returnValue(2003));
        allowing(source).observationStartUT();
        will(returnValue(OBSERVATION_START));
        allowing(source).observationEndUT();
        will(returnValue(OBSERVATION_END));
        allowing(source).readNoiseE();
        will(returnValue(2004.6));
        allowing(source).readsPerImage();
        will(returnValue(2005));
        allowing(source).readTimeMilliSec();
        will(returnValue(2006.8));
        allowing(source).skyGroup();
        will(returnValue(2007));
        allowing(source).timeResolutionOfDataDays();
        will(returnValue(2008.9));
        allowing(source).timeSlice();
        will(returnValue(2009));
        allowing(source).livetimeDays();
        will(returnValue(2010.0));
        allowing(source).fgsFrameTimeMilliS();
        will(returnValue(2011.0));
        allowing(source).isK2();
        will(returnValue(false));
        
        SipWcsCoordinates sipWcs = sipWcs();
        
        FfiImageHeaderFormatter formatter = new FfiImageHeaderFormatter();
        Header imageHeader = formatter.formatImageHeader(source, sipWcs);
        File outFile = new File(testDir, "image.header.txt");
        String actual = FitsUtils.headerToString(imageHeader);
        String actual80 = StringUtils.breakAt80Characters(actual);
        FileUtils.writeStringToFile(outFile, actual80);
        
        File expectedFile = new File("testdata", "image.header.txt");
        String expected = FileUtils.readFileToString(expectedFile);
        assertEquals(expected, actual80);
    }
    
    private SipWcsCoordinates sipWcs() {
        return ExampleSipWcsCoordinates.example();
    }
}
