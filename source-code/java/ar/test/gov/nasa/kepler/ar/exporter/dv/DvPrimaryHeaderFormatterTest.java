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

package gov.nasa.kepler.ar.exporter.dv;

import static org.junit.Assert.assertFalse;
import gov.nasa.kepler.common.FitsConstants.ObservingMode;
import gov.nasa.kepler.common.FitsDiff;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import nom.tam.fits.Header;
import nom.tam.util.BufferedDataOutputStream;

import org.apache.commons.lang.StringUtils;
import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import static gov.nasa.kepler.ar.exporter.MockUtils.createMinimalCelestialObject;
import static gov.nasa.kepler.common.FitsConstants.CHECKSUM_DEFAULT;

/**
 * Unit test for class DvTargetPrimaryHeaderFormatter.
 * @author lbrownst
 */
// Specify the org.junit.runner.Runner
@RunWith(JMock.class)
public class DvPrimaryHeaderFormatterTest {
    
    /** The directory to which the primary Header is exported. */
    private final File outputDir =
        new File(Filenames.BUILD_TEST, DvPrimaryHeaderFormatterTest.class.getSimpleName());
    
    /** The test context, created afresh before each Test is run. */
    private Mockery mockery;
    
    /** Execute before each Test */
    @Before
    public void setUp() throws Exception {
        // Re-create the directory
        FileUtil.cleanDir(outputDir);
        FileUtil.mkdirs(outputDir);
        // Re-create and initialize the test context
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE); // Bypass constructor
    }
    
    /**
     * Test method that mocks a DvTargetMetadata, calls
     * DvTargetPrimaryHeaderFormatter.formatHeader() with that mocked object,
     * and then calls FitsDiff.diff() to compare the resulting FITS file with
     * a reference file. 
     * When the standard file changes, copy the exported file to the standard:
     * cp /path/to/java/ar/build/test/DvTargetPrimaryHeaderFormatterTest/dv-target-primary-header.fits
     * /path/to/java/ar/testdata
     * @throws Exception if the output file or reference file can't be opened,
     * or if the code being tested throws an Exception
     */
    @Test
    public void dvTargetPrimaryHeaderFormatterTest() throws Exception {
        // The directory in which a standard exported primary Header is saved
        String testFileDirectory = "testdata";
        String exportFileName = "dv-primary-header.fits";
        // The value of the "generatedAt" property
        final Date generatedAt = new Date(88888999);
        
        // Mock the argument to the formatter
        final DvTargetPrimaryHeaderSource source =
            mockery.mock(DvTargetPrimaryHeaderSource.class);
        
        final CelestialObject kic = createMinimalCelestialObject(mockery);

        mockery.checking(new Expectations() {{
            // Proper
            atLeast(1).of(source).dvSoftwareRevisionNumber();
            will(returnValue("9.3.2"));
            atLeast(1).of(source).quarters();
            will(returnValue("01010011110000110"));
            atLeast(1).of(source).dvXmlFileName();
            will(returnValue("kplr32333blah_dvr.xml"));
            // Inherited
            atLeast(1).of(source).keplerId();
            will(returnValue(6677888));
            atLeast(1).of(source).observingMode();
            will(returnValue(ObservingMode.LONG_CADENCE));
            atLeast(1).of(source).raDegrees();
            will(returnValue(9.28));
            atLeast(1).of(source).skyGroup();
            will(returnValue(37));
            atLeast(1).of(source).isK2Target();
            will(returnValue(false));
            atLeast(1).of(source).subversionRevision();
            will(returnValue("98765"));
            atLeast(1).of(source).targetTableId();
            will(returnValue(-1));
            atLeast(1).of(source).generatedAt();
            will(returnValue(generatedAt));
            atLeast(1).of(source).pipelineTaskId();
            will(returnValue(888L));
            atLeast(1).of(source).programName();
            will(returnValue("primary header test"));
            atLeast(1).of(source).subversionUrl();
            will(returnValue("svn+ssh://host/path/to/code"));
            atLeast(1).of(source).dataReleaseNumber();
            will(returnValue(44));
            atLeast(1).of(source).celestialObject();
            will(returnValue(kic));
            atLeast(1).of(source).extensionHduCount();
            will(returnValue(2));
            atLeast(1).of(source).tceCount();
            will(returnValue(7));
            
        }});
        
        // Export the primary Header
        final File outputFile = new File(outputDir, exportFileName);
        DvTargetPrimaryHeaderFormatter formatter =
            new DvTargetPrimaryHeaderFormatter();
        FileOutputStream fos = new FileOutputStream(outputFile);
        BufferedDataOutputStream bdos = new BufferedDataOutputStream(fos);
        final Header primaryHeader = formatter.formatHeader(source, CHECKSUM_DEFAULT);
        primaryHeader.write(bdos);
        bdos.close();        
    
        // The standard of comparison
        final File expectedFile = new File(testFileDirectory, exportFileName);
        // What's the diff
        FitsDiff fitsDiff = new FitsDiff();
        // FitsDiff.diff() populates this
        List<String> differences = new ArrayList<String>();
        boolean filesDiffer = fitsDiff.diff(outputFile, expectedFile, differences);
        // Expect no difference
        assertFalse(StringUtils.join(differences.iterator(), "\n"), filesDiffer);
    }

}
