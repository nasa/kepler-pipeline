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

import static gov.nasa.kepler.common.FitsConstants.*;

import gov.nasa.kepler.ar.cli.ReleaseTaggerCli;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapperFactory;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.lang.TestSystemProvider;

import java.io.File;
import java.io.IOException;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;
import nom.tam.fits.Header;
import nom.tam.util.BufferedFile;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.*;


/**
 * @author Sean McCauliff
 *
 */
public class ReleaseTaggerTest {

    private final File testRoot =
        new File(Filenames.BUILD_TEST, "ReleaseTaggerTest");
    
    @Before
    public void setUp() throws Exception {
        FileUtil.mkdirs(testRoot);
    }
    
    @After
    public void tearDown() throws Exception {
        FileUtil.removeAll(testRoot);
    }
    
    @Test(expected=IllegalStateException.class)
    public void missingReleaseKeywords() throws Exception {
        File fitsFile = new File(testRoot, 
            DispatcherWrapperFactory.LONG_CADENCE_BACKGROUND);
        BufferedFile bufferedFile = new BufferedFile(fitsFile, "rw");
        BasicHDU.getDummyHDU().write(bufferedFile);
        bufferedFile.close();
        
        ReleaseTagger releaseTagger = new ReleaseTagger(false, "Q1", "SOC1");
        releaseTagger.tag(testRoot);
    }
    
    @Test(expected=IllegalStateException.class)
    public void releaseKeywordsAlreadyAssigned() throws Exception {
        runWithAssigned(false);
    }
    
    @Test
    public void releaseKeywordsAlreadyAssignedForce() throws Exception {
        runWithAssigned(true);
     
    }
    
    private void runWithAssigned(boolean force) throws Exception {
        File fitsFile = new File(testRoot, DispatcherWrapperFactory.SHORT_CADENCE_COLLATERAL);
        generateFileWithReleaseKeywords(fitsFile, "assigned", "assigned");
        
        ReleaseTagger releaseTagger = new ReleaseTagger(force, "Q1", "SOC1");
        releaseTagger.tag(testRoot);
        
        checkReleaseKeywords(fitsFile, 0, "Q1", "SOC1");
    }
    
    private void generateFileWithReleaseKeywords(File fout, String quarterValue,
        String dataRelValue) throws Exception {
        
        BufferedFile bufferedFile = new BufferedFile(fout, "rw");
        BasicHDU primaryHdu = BasicHDU.getDummyHDU();
        primaryHdu.addValue(DATA_REL_KW, dataRelValue, DATA_REL_COMMENT);
        primaryHdu.addValue(QUARTER_KW, quarterValue, QUARTER_COMMENT);
        
        primaryHdu.write(bufferedFile);
        bufferedFile.close();
    }
    
    @Test
    public void tagFluxFile() throws Exception {
        File fitsFile = new File(testRoot, FileNameFormatter.LONG_CADENCE_FLUX);
        generateFluxFileWithReleaseKeywords(fitsFile);
        ReleaseTagger releaseTagger = new ReleaseTagger(false, "Q1", "SOC1");
        releaseTagger.tag(testRoot);
        
        checkReleaseKeywords(fitsFile, 1, "Q1", "SOC1");
    }
    
    /** The flux fits file has the release keywords in the extension header. */
    private void generateFluxFileWithReleaseKeywords(File fitsFile) throws Exception {

        BufferedFile bufferedFile = new BufferedFile(fitsFile, "rw");
        BasicHDU primaryHdu = BasicHDU.getDummyHDU();
        primaryHdu.write(bufferedFile);
        
        BasicHDU extensionHdu = BasicHDU.getDummyHDU();
        extensionHdu.addValue(DATA_REL_KW, DATA_REL_VALUE, DATA_REL_COMMENT);
        extensionHdu.addValue(QUARTER_KW, QUARTER_VALUE, QUARTER_COMMENT);
        
        extensionHdu.write(bufferedFile);
        bufferedFile.close();
    }
    
    private void checkReleaseKeywords(File fitsFile, int hduNo, 
        String expectedQuarter, String expectedDataRelease) 
        throws FitsException, IOException {
        
        Fits fits = new Fits(fitsFile);
        BasicHDU basicHdu = (BasicHDU) fits.getHDU(hduNo);
        Header header = basicHdu.getHeader();
        assertEquals(expectedQuarter, header.getStringValue(QUARTER_KW));
        assertEquals(expectedDataRelease, header.getStringValue(DATA_REL_KW));
    }
    
    @Test
    public void testReleaseTaggerCli() throws Exception {
        File fitsFile = new File(testRoot,DispatcherWrapperFactory.LONG_CADENCE_TARGET);
        generateFileWithReleaseKeywords(fitsFile, "blah", "blah");
        
        TestSystemProvider system = new TestSystemProvider(testRoot);
        ReleaseTaggerCli cli = new ReleaseTaggerCli(system);
        cli.parse(new String[] {"-f", "-q", "Q1", "-d", testRoot.toString(), 
            "-r", "SOC1"});
        
        cli.execute();
        
        assertEquals(0, system.returnCode());
        checkReleaseKeywords(fitsFile, 0, "Q1", "SOC1");
    }
}
