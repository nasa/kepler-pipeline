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

import static org.junit.Assert.assertFalse;
import gov.nasa.kepler.common.FitsDiff;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import nom.tam.util.BufferedDataOutputStream;

import org.apache.commons.lang.StringUtils;
import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(JMock.class)
public class ApertureMaskFormatterTest {

    private final File outputDir = new File(Filenames.BUILD_TEST, "ApertureMaskFormatterTest");
    
    private Mockery mockery;
    
    @Before
    public void setUp() throws Exception {
        FileUtil.cleanDir(outputDir);
        FileUtil.mkdirs(outputDir);
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
    }
   
    
    @Test
    public void apertureMaskHeaderTest() throws Exception {
        final int[][] imageData = new int[2][3];
        for (int i=0; i < imageData.length; i++) {
            for (int j=0; j < imageData[i].length; j++) {
                imageData[i][j] = i;
            }
        }
        
        final Date generatedAt = new Date(88888999);
        
        final ApertureMaskSource source = mockery.mock(ApertureMaskSource.class);
        mockery.checking(new Expectations() {{
            atLeast(1).of(source).decDegrees();
            will(returnValue(10.234567));
            atLeast(1).of(source).raDegrees();
            will(returnValue(23.456677));
            exactly(2).of(source).keplerId();
            will(returnValue(6677888));
            atLeast(1).of(source).nColumns();
            will(returnValue(3));
            atLeast(1).of(source).nRows();
            will(returnValue(2));
            atLeast(1).of(source).apertureMaskImage();
            will(returnValue(imageData));
            atLeast(1).of(source).referenceCcdColumn();
            will(returnValue(233));
            atLeast(1).of(source).referenceCcdRow();
            will(returnValue(422));
            atLeast(1).of(source).nPixelsInOptimalAperture();
            will(returnValue(7));
            atLeast(1).of(source).nPixelsMissingInOptimalAperture();
            will(returnValue(1));
            atLeast(1).of(source).checksumString();
            will(returnValue("A"));
            atLeast(1).of(source).generatedAt();
            will(returnValue(generatedAt));
            atLeast(1).of(source).isK2();
            will(returnValue(false));
            
        }});
        
        final File outputFile = new File(outputDir,"aperture.mask.fits");
        ApertureMaskFormatter formatter = new ApertureMaskFormatter();
        FileOutputStream fout = new FileOutputStream(outputFile);
        BufferedDataOutputStream fitsBout = new BufferedDataOutputStream(fout);
        formatter.format(fitsBout, source, new DefaultCelestialWcs());
        fitsBout.close();
        
        final File expectedFile = new File("testdata", "aperture.mask.fits");
        FitsDiff fitsDiff = new FitsDiff();
        List<String> differences = new ArrayList<String>();
        boolean filesDiffer = fitsDiff.diff(outputFile, expectedFile, differences);
        assertFalse(StringUtils.join(differences.iterator(), "\n"), filesDiffer);
        
    }
}
