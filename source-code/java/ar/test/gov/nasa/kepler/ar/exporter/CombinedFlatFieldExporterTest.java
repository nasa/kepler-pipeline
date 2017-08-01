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


import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.ar.cli.CombinedFlatFieldExportCli;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.fc.flatfield.FlatFieldOperations;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.lang.TestSystemProvider;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;

import nom.tam.fits.FitsException;

import org.apache.commons.io.FileUtils;
import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JUnit4Mockery;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 *
 */
public class CombinedFlatFieldExporterTest {

    private Mockery mockery;
    private FlatFieldOperations ffops;
    private final File testRoot =  
        new File(Filenames.BUILD_TEST, "CombinedFlatFieldFitsExporter.test");
    
    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        FileUtils.forceMkdir(testRoot);
        
        mockery = new JUnit4Mockery() {
            {
                setImposteriser(ClassImposteriser.INSTANCE);
            }
        };
        
        ffops = mockery.mock(FlatFieldOperations.class);
        final FlatFieldOperations fffOps = ffops;
        final double mjd = 1.0;
        
        for (int module : FcConstants.modulesList) {
            for (int output : FcConstants.outputsList) {
                
                final int fmodule = module;
                final int foutput = output;
                
                final float[][] image = imageFor(fmodule, foutput);
                
                mockery.checking(new Expectations() {{
                    one(fffOps).retrieveFlatField(
                        with(equal(fmodule)), with(equal(foutput)), with(equal(mjd)));
                    will(returnValue(image));
                }
                });
            }
        }
        
        mockery.checking(new Expectations() {{
            one(fffOps).retrieveSmallFlatFieldImageTimes();
            will(returnValue(new double[] { mjd }));
        }});

    }

    /**
     * @param fmodule
     * @param foutput
     * @return
     */
    private float[][] imageFor(final int fmodule, final int foutput) {
        float m = fmodule * foutput;
        final float[][] image = new float[][] {{1.0f * m, 2.0f * m}, { 3.0f * m, 4.0f * m}};
        return image;
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        FileUtil.removeAll(testRoot);
    }
    
    @Test
    public void testCombinedFlatFieldExporter() throws Exception {
        CombinedFlatFieldExporter exporter = new CombinedFlatFieldExporter(ffops);
        exporter.export(testRoot);
        
        validateOutput();
        
    }

    /**
     * @throws FitsException
     * @throws IOException
     */
    private void validateOutput() throws FitsException, IOException {
        FileNameFormatter fnameFormatter = new FileNameFormatter();
        String fname = fnameFormatter.combinedFlatField(1.0);
        File outputFile = new File(testRoot, fname);
        assertTrue(outputFile.exists());
        
        CombinedFlatFieldFits cFff = new CombinedFlatFieldFits(outputFile);
        for (int module : FcConstants.modulesList) {
            for (int output : FcConstants.outputsList) {
                      float[][] readImage = cFff.imageFor(module, output);
                      float[][] expectedImage = imageFor(module, output);
                      assertTrue(Arrays.deepEquals(expectedImage, readImage));
            }
        }
    }
    
    @Test
    public void testCombinedFlatFieldExportCli() throws Exception {
        TestSystemProvider system = new TestSystemProvider(testRoot);
        
        CombinedFlatFieldExportCli cli = new CombinedFlatFieldExportCli(ffops, system);
        
        cli.export(new String[] { "-o", testRoot.toString()});

        validateOutput();
    }

}
