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

import static org.junit.Assert.*;
import gov.nasa.kepler.ar.FitsVerify;
import gov.nasa.kepler.ar.FitsVerify.FitsVerifyResults;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.util.Arrays;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Test the Dv flux fits file.
 * 
 * @author Sean McCauliff
 *
 */
public class DvFluxFitsFileTest {

    private static final int CADENCE_LENGTH = 2;
    private final FitsVerify fitsVerify = new FitsVerify();
    private final File outputDir = new File(Filenames.BUILD_TEST, "DvFluxFitsFile.test");
    
    @Before
    public void setUp() throws Exception {
        FileUtil.mkdirs(outputDir);
    }
    
    @After
    public void tearDown() throws Exception {
        FileUtil.cleanDir(outputDir);
    }
    
    @Test
    public void testDvFluxFitsFile() throws Exception {
        final int nPlanets = 2;
        final float[] trialTransitPulse = 
            new float[] { 1.5f, 3.0f, 6.0f, 12.0f, 16.0f };
        DvTimeSeriesFitsFile dvFlux = new DvTimeSeriesFitsFile();
        
        int fill = 1;
        dvFlux.setCadences(new int[CADENCE_LENGTH]);
        dvFlux.setInitialFlux(fillAll(nPlanets, fill));
        fill += nPlanets;
        dvFlux.setInitialFluxUncertaintiy(fillAll(nPlanets, fill));
        fill += nPlanets;
        dvFlux.setKeplerId(23);
        dvFlux.setMjdEnd(42.0);
        dvFlux.setMjdStart(43.0);
        dvFlux.setPlanetNumbers(new int[] { 1, 3 });
        dvFlux.setPipelineTaskId(Long.MAX_VALUE);
        float[] residual = new float[CADENCE_LENGTH];
        Arrays.fill(residual,  555.0f);
        dvFlux.setResidualTimeSeries(residual);
        float[] residualUncert = new float[CADENCE_LENGTH];
        Arrays.fill(residualUncert, 666.0f);
        dvFlux.setResidualTimeSeriesUncertaintiy(residualUncert);
        dvFlux.setSingleEventCorrelated(fillAll(trialTransitPulse.length, fill));
        fill += trialTransitPulse.length;
        dvFlux.setSingleEventNormalized(fillAll(trialTransitPulse.length, fill));
        fill += trialTransitPulse.length;
        dvFlux.setTime(new double[CADENCE_LENGTH]);
        dvFlux.setTrialTransitPulse(trialTransitPulse);
        dvFlux.setModelLightCurve(fillAll(nPlanets, fill+1));
        
        File outputFile = new File(outputDir, "dvflux.fits");
        dvFlux.export(outputFile);
        
        DvTimeSeriesFitsFile readIn = DvTimeSeriesFitsFile.read(outputFile);
        assertEquals(dvFlux, readIn);
        
        FitsVerifyResults results = fitsVerify.verify(outputFile, true);
        assertEquals(results.output, 0, results.returnCode);
    }
    
    private static float[][] fillAll(int sizeOfFirstDim,int fill) {
        float[][] data = new float[sizeOfFirstDim][];
        for (int i=0; i < sizeOfFirstDim; i++, fill++) {
            data[i] = new float[CADENCE_LENGTH];
            Arrays.fill(data[i], fill);
        }
        
        return data;
    }
}
