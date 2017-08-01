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

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import static gov.nasa.kepler.common.ConfigMap.ConfigMapMnemonic.*;
import static gov.nasa.kepler.common.ConfigMap.configMapsShouldHaveUniqueValue;

import java.util.Collection;

/**
 * Calculates information about the total exposure of the data in 
 * contained in the target pixel file.
 * 
 * @author Sean McCauliff
 *
 */
public class ExposureCalculator {

    private static final int SEC_PER_MILLIS = 1000;
    private static final int SEC_PER_DAY = 24* 60* 60;
    
    // GSprm_FGSPER
    private final double fgsFrameTimeMilliS;
    //FDMINTPER + 2
    private final int numberOfFgsFramesPerScienceFrame;
    private final double readTimePerScienceFrameMilliS;
    private final int numberOfScienceFramesPerShortCadence;
    private final int numberOfShortCadencesPerLongCadence;
    private final double startTime;
    private final double endTime;
    private final double fluxPerCadenceToFluxPerSecond;
    private final double fluxPerCadenceSqToFluxPerSecond;
    private final int shortCadenceFixedOffset;
    private final int longCadenceFixedOffset;
    
    /** This is the number of gapped cadences in the data.  This used to calculate
     * the exposure information.
     */
    private final int cadenceGapCount;
    private final CadenceType cadenceType;
    
    /**
     * @param startTime in days.  This should be the beginning of the first cadence.
     * @param endTime in days.  This should be the end of the last cadence.
     * @param configMaps The spacecraft config maps stored in the database.  These
     * maps should span the time for the exported data.
     * @param dataCollected The most inclusive dataset.  This is going to scan
     * through the gaps to determine the exposure time.
     */
    public ExposureCalculator(Collection<ConfigMap> configMaps, 
                                 Collection<? extends TimeSeries> dataCollected,
                                 CadenceType cadenceType,
                                 double startTime, double endTime,
                                 int startCadence, int endCadence) {
        if (startTime >= endTime) {
            throw new IllegalArgumentException("startTime comes before endTime");
        }
        
        this.startTime = startTime;
        this.endTime = endTime;
        
        fgsFrameTimeMilliS = Double.parseDouble(
            configMapsShouldHaveUniqueValue(configMaps, millisecondsPerFgsFrame.mnemonic()));
        
        //This is not corrected for the spacecraft software adding 2 to the 
        //configured number of integration frames because this correction is
        //performed by DR when loading the config map into the database.
        numberOfFgsFramesPerScienceFrame = Integer.parseInt(
            configMapsShouldHaveUniqueValue(configMaps, fgsFramesPerIntegration.mnemonic()));
       
        readTimePerScienceFrameMilliS = Double.parseDouble(
            configMapsShouldHaveUniqueValue(configMaps, millisecondsPerReadout.mnemonic()));
        
        numberOfScienceFramesPerShortCadence = Integer.parseInt(
            configMapsShouldHaveUniqueValue(configMaps, integrationsPerShortCadence.mnemonic()));
        
        numberOfShortCadencesPerLongCadence = Integer.parseInt(
            configMapsShouldHaveUniqueValue(configMaps, shortCadencesPerLongCadence.mnemonic()));
        
        int minGaps = endCadence - startCadence + 1;
        for (TimeSeries ts : dataCollected) {
            int lastEndCadence = startCadence;
            int nGaps = 0;
            for (SimpleInterval valid : ts.validCadences()) {
                nGaps += (int) (valid.start() - lastEndCadence);
                lastEndCadence = (int) valid.end();
            }
            nGaps += endCadence - lastEndCadence;
            minGaps = Math.min(minGaps, nGaps);
        }
        cadenceGapCount = minGaps;
        this.cadenceType = cadenceType;
        switch (cadenceType) {
            case SHORT:
                fluxPerCadenceToFluxPerSecond = SEC_PER_MILLIS / 
                  (fgsFrameTimeMilliS * numberOfFgsFramesPerScienceFrame * numberOfScienceFramesPerShortCadence);
            break;
            case LONG:
                fluxPerCadenceToFluxPerSecond = SEC_PER_MILLIS / 
                (fgsFrameTimeMilliS * numberOfFgsFramesPerScienceFrame * numberOfScienceFramesPerShortCadence *numberOfShortCadencesPerLongCadence);
            break;
            default:
                throw new IllegalStateException("Unhandled cadence type : " + cadenceType);
        }
        fluxPerCadenceSqToFluxPerSecond = 
            fluxPerCadenceToFluxPerSecond * fluxPerCadenceToFluxPerSecond;
        
        this.shortCadenceFixedOffset = Integer.parseInt(configMapsShouldHaveUniqueValue(configMaps, scRequantFixedOffset.mnemonic()));
        this.longCadenceFixedOffset = Integer.parseInt(configMapsShouldHaveUniqueValue(configMaps, lcRequantFixedOffset.mnemonic()));
    }
    
    public int shortCadenceFixedOffset() {
        return shortCadenceFixedOffset;
    }
    
    public int longCadenceFixedOffset() {
        return longCadenceFixedOffset;
    }

    /**
     * Dead time correction.  The proportion of useful time when taking science data.
     * @return A number [0.0, 1.0]
     */
    public double deadC() {
        return numberOfFgsFramesPerScienceFrame * fgsFrameTimeMilliS /
        (numberOfFgsFramesPerScienceFrame * fgsFrameTimeMilliS + readTimePerScienceFrameMilliS);
    }
    
    public double elaspedTimeDays() {
        return endTime - startTime;
    }
    
    public double liveTimeDays() {
        return elaspedTimeDays() * deadC();
    }
    
    public double integrationTimeSec() {
        return numberOfFgsFramesPerScienceFrame * fgsFrameTimeMilliS / SEC_PER_MILLIS;
    }
    
    public double readTimeSec() {
        return readTimePerScienceFrameMilliS / SEC_PER_MILLIS;
    }
    
    public double scienceFrameSec() {
        return readTimeSec() + integrationTimeSec();
    }
    
    public int numberOfScienceFramesPerCadence() {
        switch (cadenceType) {
            case LONG:
                return this.numberOfScienceFramesPerShortCadence * this.numberOfShortCadencesPerLongCadence;
            case SHORT:
                return this.numberOfScienceFramesPerShortCadence;
            default:
                throw new IllegalStateException("Unhandled case " + cadenceType);
        }
    }
    
    public double cadenceDurationDays() {
        return scienceFrameSec() * numberOfScienceFramesPerCadence() / SEC_PER_DAY;
    }
    /**
     * The livetime on the target - the integration time spent in gapped cadences.
     * @return
     */
    public double exposureDays() {
        return liveTimeDays() - integrationTimeSec() * numberOfScienceFramesPerCadence() * cadenceGapCount / SEC_PER_DAY;
    }
    
    public double fluxPerCadenceToFluxPerSecond(double fluxPerCadence) {
        return fluxPerCadence * fluxPerCadenceToFluxPerSecond;
    }
    
    public double fluxPerCadenceSquaredToFluxPerSecond(double fluxPerCadenceSq) {
        return fluxPerCadenceSq * fluxPerCadenceSqToFluxPerSecond;
    }

}
