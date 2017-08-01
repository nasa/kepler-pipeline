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

package gov.nasa.kepler.tps;

import gov.nasa.kepler.hibernate.tad.TargetCrowdingInfo;
import gov.nasa.kepler.mc.PdcProcessingCharacteristics;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;

import java.util.Arrays;

/**
 * Inputs useful for debugging TPS, but not used by the TPS algorithms.
 * 
 * @author Sean McCauliff
 * 
 */
@ProxyIgnoreStatics
public class TargetDiagnostics implements Persistable {

    private static final int NON_EXISTENT_CROWDING_METRIC_VALUE = -1;

    /**
     * The estimated Kepler magnitude of the target. This data is from the KIC.
     * This is used for debugging purposes.
     */
    private float keplerMag;

    /** When true the value in kep mag is correct. */
    private boolean validKeplerMag = false;

    /**
     * The list of CCD modules for each quarter the target was observed.
     */
    private int[] ccdModule;

    /**
     * The list of CCD outputs for each quarter the target was observed. This
     * has the same length as ccdModule
     */
    private int[] ccdOutput;

    /**
     * The crowding metric for each quarter the target was observed. This has
     * the same length as ccdModule.
     */
    private float[] crowding;

    /**
     * These are gap indicators for ccdModule, ccdOutput and crowding. When
     * gapIndicators[i] is true then crowding[i], ccdOutput[i] and ccdModule[i]
     * are undefined.
     */
    private boolean[] gapIndicators;

    /**
     * This is a per quarter data structure. This comes from PDC. If
     * gapIndicators[i] is true then the value of this structure is undefined.
     */
    private PdcProcessingCharacteristics[] pdcDataProcessingStruct;

    TargetDiagnostics(int nTargetTables) {
        ccdModule = new int[nTargetTables];
        ccdOutput = new int[nTargetTables];
        crowding = new float[nTargetTables];
        gapIndicators = new boolean[nTargetTables];
        pdcDataProcessingStruct = new PdcProcessingCharacteristics[nTargetTables];
        Arrays.fill(gapIndicators, true);
        Arrays.fill(pdcDataProcessingStruct, new PdcProcessingCharacteristics());
    }

    TargetDiagnostics(TargetCrowdingInfo crowdingInfo, float keplerMag,
        boolean validKeplerMag,
        PdcProcessingCharacteristics[] pdcProcessingCharacteristics) {
        
        if (crowdingInfo == null) {
            throw new NullPointerException("crowdingInfo");
        }
        
        if (pdcProcessingCharacteristics == null) {
            throw new NullPointerException("pdcProcessingCharacteristics");
        }
        
        this.keplerMag = keplerMag;
        this.validKeplerMag = validKeplerMag;

        crowding = new float[crowdingInfo.getCrowdingMetric().length];
        ccdModule = new int[crowding.length];
        ccdOutput = new int[crowding.length];
        gapIndicators = crowdingInfo.getGapIndicators();

        for (int i = 0; i < crowding.length; i++) {
            if (crowdingInfo.getCrowdingMetric()[i] == null) {
                crowding[i] = NON_EXISTENT_CROWDING_METRIC_VALUE;
                ccdModule[i] = 0;
                ccdOutput[i] = 0;
            } else {
                crowding[i] = crowdingInfo.getCrowdingMetric()[i].floatValue();
                ccdModule[i] = crowdingInfo.getCcdModule()[i];
                ccdOutput[i] = crowdingInfo.getCcdOutput()[i];
            }
        }

        if (pdcProcessingCharacteristics.length != gapIndicators.length) {
            throw new IllegalArgumentException(
                "pdcProcessingCharacteristics.length "
                    + pdcProcessingCharacteristics.length
                    + " != gapIndicators.length " + gapIndicators.length);
        }
        pdcDataProcessingStruct = pdcProcessingCharacteristics;
    }

    public float getKeplerMag() {
        return keplerMag;
    }

    public void setKeplerMag(float keplerMag) {
        this.keplerMag = keplerMag;
    }

    public boolean isValidKeplerMag() {
        return validKeplerMag;
    }

    public void setValidKeplerMag(boolean validKeplerMag) {
        this.validKeplerMag = validKeplerMag;
    }

    public float[] getCrowding() {
        return crowding;
    }

    public void setCrowding(float[] crowding) {
        this.crowding = crowding;
    }
}
