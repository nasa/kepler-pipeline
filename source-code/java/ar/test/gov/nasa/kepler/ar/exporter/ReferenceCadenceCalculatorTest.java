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

import static org.junit.Assert.*;

import java.util.Arrays;

import org.junit.Before;
import org.junit.Test;

import gov.nasa.kepler.ar.exporter.QualityFieldCalculator;
import gov.nasa.kepler.ar.exporter.ReferenceCadenceCalculator;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;

/**
 * @author Sean McCauliff
 *
 */
public class ReferenceCadenceCalculatorTest {

    private final int startCadence = 55;
    private final int endCadence = 777;
    private final int midCadence = (endCadence + startCadence) / 2;
    private final int targetStartCadence = 56;
    private final int targetEndCadence = 776;
    private final ReferenceCadenceCalculator refCadenceCalc = new ReferenceCadenceCalculator();
    private int[] dataQualityFlags;
    private boolean[] gapIndicators;
    private int[] cadenceNumbers; 
    
    @Before
    public void setUp() {
        cadenceNumbers = absoluteCadenceNumbers(startCadence, endCadence);
        gapIndicators = new boolean[cadenceNumbers.length];
        dataQualityFlags  = new int[gapIndicators.length];
    }
    
    
    @Test(expected=IllegalStateException.class)
    public void testMissingCadences() {
        Arrays.fill(gapIndicators, true);
        gapIndicators[0] = false;
        gapIndicators[gapIndicators.length - 1] = false;
        int[] dataQualityFlags = new int[gapIndicators.length];
        TimestampSeries cadenceTimes = 
            new TimestampSeries(null, null, null, gapIndicators, null,
                cadenceNumbers, null, null, null, null, null, null, null, null);
        refCadenceCalc.referenceCadence(startCadence, targetStartCadence,
            targetEndCadence, cadenceTimes, dataQualityFlags, ReferenceCadenceCalculator.BAD_QUALITY_FLAGS);
    }
    
    @Test(expected=IllegalStateException.class)
    public void testMissingCadencesQuality() {
        Arrays.fill(dataQualityFlags, QualityFieldCalculator.ARGABRIGHTENING);
        dataQualityFlags[0] = 0;
        dataQualityFlags[dataQualityFlags.length - 1] =0;
        TimestampSeries cadenceTimes = 
            new TimestampSeries(null, null, null, gapIndicators, null,
                cadenceNumbers, null, null, null, null, null, null, null, null);
        refCadenceCalc.referenceCadence(startCadence, targetStartCadence,
            targetEndCadence, cadenceTimes, dataQualityFlags, ReferenceCadenceCalculator.BAD_QUALITY_FLAGS);
    }
    
    @Test
    public void middleIsGood() {
        Arrays.fill(dataQualityFlags, QualityFieldCalculator.COSMIC_RAY);
        TimestampSeries cadenceTimes = 
            new TimestampSeries(null, null, null, gapIndicators, null,
                cadenceNumbers, null, null, null, null, null, null, null, null);
        int refCadence = refCadenceCalc.referenceCadence(startCadence, targetStartCadence,
            targetEndCadence, cadenceTimes, dataQualityFlags, ReferenceCadenceCalculator.BAD_QUALITY_FLAGS);
        assertEquals(midCadence, refCadence);
    }
    
    @Test
    public void lowerReferenceCadence() {
        gapIndicators[midCadence - startCadence] = true;
        gapIndicators[midCadence - startCadence + 1] = true;

        TimestampSeries cadenceTimes = 
            new TimestampSeries(null, null, null, gapIndicators, null,
                cadenceNumbers, null, null, null, null, null, null, null, null);
        int refCadence = refCadenceCalc.referenceCadence(startCadence, targetStartCadence,
            targetEndCadence, cadenceTimes, dataQualityFlags, ReferenceCadenceCalculator.BAD_QUALITY_FLAGS);
        assertEquals(midCadence-1, refCadence);
    }
    
    @Test
    public void upperReferenceCadence() {
        gapIndicators[midCadence - startCadence] = true;
        gapIndicators[midCadence - startCadence - 1] = true;

        TimestampSeries cadenceTimes = 
            new TimestampSeries(null, null, null, gapIndicators, null,
                cadenceNumbers, null, null, null, null, null, null, null, null);
        int refCadence = refCadenceCalc.referenceCadence(startCadence, targetStartCadence,
            targetEndCadence, cadenceTimes, dataQualityFlags, ReferenceCadenceCalculator.BAD_QUALITY_FLAGS);
        assertEquals(midCadence+1, refCadence);
    }
    
    int[] absoluteCadenceNumbers(int s, int e) {
        int[] cadences = new int[e - s + 1];
        for (int i=0; i < cadences.length; i++) {
            cadences[i] = i + s;
        }
        return cadences;
    }
    
}
