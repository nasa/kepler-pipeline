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

import static gov.nasa.kepler.common.ConfigMap.ConfigMapMnemonic.*;
import gov.nasa.kepler.common.ConfigMap;

/**
 * Calculate exposure related information related to an FFI.
 * 
 * TODO:  some of the terminology here is not consistent with the terminology
 * used in the target pixel files and the light curve files.
 * 
 * @author Sean McCauliff
 *
 */
class FfiExposureCalculator {

    private static final double SEC_PER_MILLIS = 1000;

    private final int nFgsFramesPerIntegration;
    private final int nIntegrationsPerFfiImage;
    private final double fgsFrameTimeMilliS;
    private final double readOutTimeMilliS;
    private final double startTimeDays;
    private final double endTimeDays;
    private final double fluxPerSecondConversion;
    
    /**
     * 
     * @param configMap the config map in common, not the hibernate one
     * @param startTimeDays It doesn't really matter what time system this uses
     * as long as it is the same time system as the end.
     * @param endTimeDays It doesn't really matter what time system this uses
     * as long as it is the same time system as the start.
     * @throws Exception
     */
    FfiExposureCalculator(ConfigMap configMap, double startTimeDays, double endTimeDays) throws Exception {
        this.startTimeDays = startTimeDays;
        this.endTimeDays = endTimeDays;
        
        fgsFrameTimeMilliS = configMap.getDouble(millisecondsPerFgsFrame);
        readOutTimeMilliS = configMap.getDouble(millisecondsPerReadout);
        nFgsFramesPerIntegration = configMap.getInt(fgsFramesPerIntegration);
        nIntegrationsPerFfiImage = configMap.getInt(integrationsPerScienceFfi);
        
        fluxPerSecondConversion = SEC_PER_MILLIS / (fgsFrameTimeMilliS * nFgsFramesPerIntegration * nIntegrationsPerFfiImage);
    }
    
    /**
     * Dead time correction.  The proportion of useful time when taking science data.
     * @return A number [0.0, 1.0]
     */
    public double deadC() {
        return nFgsFramesPerIntegration * fgsFrameTimeMilliS /
        (nFgsFramesPerIntegration * fgsFrameTimeMilliS +  readOutTimeMilliS);
    }
    
    public double elaspedTimeDays() {
        return endTimeDays - startTimeDays;
    }
    
    public double exposureDays() {
        return liveTimeDays();
    }
    
    public double liveTimeDays() {
        return elaspedTimeDays() * deadC();
    }
    
    public double integrationTimeSec() {
        return nFgsFramesPerIntegration * fgsFrameTimeMilliS / SEC_PER_MILLIS;
    }
    
    public double readTimeSec() {
        return readOutTimeMilliS / SEC_PER_MILLIS;
    }
    
    
    public float[][] toElectronsPerSecond(final float[][] originalImage, final int imageWidth, final int imageHeight) {
        final float[][] electronsPerSecond = new float[imageHeight][imageWidth];
        for (int rowi=0; rowi < imageHeight; rowi++) {
            for (int coli=0; coli < imageWidth; coli++) {
                electronsPerSecond[rowi][coli] = 
                    (float) (((double)originalImage[rowi][coli]) * fluxPerSecondConversion);
            }
        }
        return electronsPerSecond;
    }
    
    public int nIntegrationsPerFfiImage() {
        return nIntegrationsPerFfiImage;
    }
    
    public double fgsFrameTimeMilliS() {
        return fgsFrameTimeMilliS;
    }
    
    public int nFgsFramesPerIntegration() {
        return nFgsFramesPerIntegration;
    }
    
}
