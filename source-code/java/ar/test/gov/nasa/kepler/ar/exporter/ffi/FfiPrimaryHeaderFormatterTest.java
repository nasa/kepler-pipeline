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
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import junit.framework.Assert;

import gov.nasa.kepler.common.*;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import nom.tam.fits.Header;
import nom.tam.util.BufferedFile;

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
public class FfiPrimaryHeaderFormatterTest {

    private static final File testDir = 
        new File(Filenames.BUILD_TEST, "FfiPrimaryHeaderFormatterTest");
    private Mockery mockery;
    
    
    @Before
    public void setup() throws Exception {
        mockery = new Mockery() {{
            setImposteriser(ClassImposteriser.INSTANCE);
        }};
        FileUtil.mkdirs(testDir);
    }
    
    @Test
    public void primaryHeaderFormatterTest() throws Exception {
        final int blackColumnStart= 0;
        final int blackColumnEnd = 5;
        final int blackRowStart = 0;
        final int blackRowEnd = 1024;
        final Date generatedAt = new Date(7);
        final int maskedSmearColumnStart = blackColumnEnd + 1;
        final int maskedSmearColumnEnd = maskedSmearColumnStart + 1000;
        final int maskedSmearRowStart = 0;
        final int maskedSmearRowEnd = 10;
        final int virtualSmearColumnStart = 55;
        final int virtualSmearColumnEnd = 950;
        final int virtualSmearRowStart = 1040;
        final int virtualSmearRowEnd = 1042;
        
        
        final FfiPrimaryHeaderFormatterSource source = 
            mockery.mock(FfiPrimaryHeaderFormatterSource.class);
        mockery.checking(new Expectations() {{
            atLeast(1).of(source).blackColumnStart();
            will(returnValue(blackColumnStart));
            atLeast(1).of(source).blackColumnEnd();
            will(returnValue(blackColumnEnd));
            atLeast(1).of(source).blackRowStart();
            will(returnValue(blackRowStart));
            atLeast(1).of(source).blackRowEnd();
            will(returnValue(blackRowEnd));
            atLeast(1).of(source).checksumString();
            will(returnValue(CHECKSUM_DEFAULT));
            atLeast(1).of(source).configMapId();
            will(returnValue(23));
            atLeast(1).of(source).dataCollectionTime();
            will(returnValue("Data collection time"));
            atLeast(1).of(source).datasetName();
            will(returnValue("dataset name"));
            atLeast(1).of(source).boresightDecDeg();
            will(returnValue(11.0));
            atLeast(1).of(source).boresightRaDeg();
            will(returnValue(12.0));
            atLeast(1).of(source).boresightRollDeg();
            will(returnValue(13.0));
            atLeast(1).of(source).focusingPosition();
            will(returnValue(new double[] { 1.1, 2.2, 3.3} ));
            atLeast(1).of(source).generatedAt();
            will(returnValue(generatedAt));
            atLeast(1).of(source).imageType();
            will(returnValue(FfiType.SOC_CAL));
            atLeast(1).of(source).isFinePoint();
            will(returnValue(false));
            atLeast(1).of(source).isMomemtumDump();
            will(returnValue(true));
            atLeast(1).of(source).isReverseClocked();
            will(returnValue(true));
            atLeast(1).of(source).maskedSmearColumnStart();
            will(returnValue(maskedSmearColumnStart));
            atLeast(1).of(source).maskedSmearColumnEnd();
            will(returnValue(maskedSmearColumnEnd));
            atLeast(1).of(source).maskedSmearRowStart();
            will(returnValue(maskedSmearRowStart));
            atLeast(1).of(source).maskedSmearRowEnd();
            will(returnValue(maskedSmearRowEnd));
            atLeast(1).of(source).nBlackColumnBins();
            will(returnValue(blackColumnEnd - blackColumnStart + 1));
            atLeast(1).of(source).nBlackRows();
            will(returnValue(blackRowEnd - blackRowStart + 1));
            atLeast(1).of(source).nMaskedSmearColumns();
            will(returnValue(maskedSmearColumnEnd - maskedSmearColumnStart + 1));
            atLeast(1).of(source).nMaskedSmearRowBins();
            will(returnValue(maskedSmearRowEnd - maskedSmearRowStart + 1));
            atLeast(1).of(source).nVirtualSmearColumns();
            will(returnValue(virtualSmearColumnEnd - virtualSmearColumnStart + 1));
            atLeast(1).of(source).nVirtualSmearRowBins();
            will(returnValue(virtualSmearRowEnd - virtualSmearRowStart + 1));
            atLeast(1).of(source).operatingTemp();
            will(returnValue(Math.PI));
            atLeast(1).of(source).pipelineTaskId();
            will(returnValue(555L));
            atLeast(1).of(source).programName();
            will(returnValue("program name"));
            atLeast(1).of(source).quarter();
            will(returnValue(7));
            atLeast(1).of(source).season();
            will(returnValue(8));
            atLeast(1).of(source).subversionRevision();
            will(returnValue("r44444"));
            atLeast(1).of(source).subversionUrl();
            will(returnValue("svn+ssh://host/path/to/code"));
            atLeast(1).of(source).virtualSmearColumnStart();
            will(returnValue(virtualSmearColumnStart));
            atLeast(1).of(source).virtualSmearColumnEnd();
            will(returnValue(virtualSmearColumnEnd));
            atLeast(1).of(source).virtualSmearRowStart();
            will(returnValue(virtualSmearRowStart));
            atLeast(1).of(source).virtualSmearRowEnd();
            will(returnValue(virtualSmearRowEnd));
            atLeast(1).of(source).dataReleaseNumber();
            will(returnValue(9));
            atLeast(1).of(source).isK2();
            will(returnValue(false));
            
        }});
        
        FfiPrimaryHeaderFormatter formatter = new FfiPrimaryHeaderFormatter();
        Header header = formatter.formatHeader(source);
        File outputFile = new File(testDir, "ffi.primary.header.fits");
        BufferedFile bufferedFile = new BufferedFile(outputFile, "rw");
        header.write(bufferedFile);
        bufferedFile.close();
        
        
        File truthFile = new File("testdata", "ffi.primary.header.fits");
        FitsDiff fitsDiff = new FitsDiff();
        List<String> diffs = new ArrayList<String>();
        fitsDiff.diff(outputFile, truthFile, diffs);
        Assert.assertEquals(StringUtils.join(diffs.iterator(), "\n"), 0, diffs.size());
    }
}
