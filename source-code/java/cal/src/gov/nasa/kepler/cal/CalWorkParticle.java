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

package gov.nasa.kepler.cal;

import gov.nasa.kepler.cal.io.CalInputs;
import gov.nasa.kepler.cal.io.CalInputsFactory;
import gov.nasa.kepler.cal.io.CommonParameters;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.spiffy.common.intervals.SimpleInterval;

import java.util.Collections;
import java.util.Set;
import java.util.concurrent.Callable;

/**
 * Completion of this callable indicates that matlab inputs have been marshaled.
 * @author Sean McCauliff
 *
 */
abstract class CalWorkParticle implements Callable<CalWorkParticle> {

    protected final CommonParameters commonParameters;
    private final int particleNumber;
    protected volatile Set<Long> producerTaskIds = Collections.emptySet();
    protected volatile DataPresentEnum hasData = DataPresentEnum.DataMissing;
    protected volatile CalInputs calInputs = null;
    protected final int totalParticles;
    
    protected CalWorkParticle(CommonParameters commonParameters, int particleNumber, int totalParticles) {
        this.commonParameters = commonParameters;
        this.particleNumber = particleNumber;
        this.totalParticles = totalParticles;
    }
    
    int particleNumber() {
        return particleNumber;
    }
    
    /**
     * 
     * @return undefined until this callable has completed.
     */
    Set<Long> producerTaskIds() {
        return producerTaskIds;
    }
    
    
    DataPresentEnum hasData() {
        return hasData;
    }
    
    /**
     * 
     * @return undefined until this callable has completed.
     */
    CalInputs calInputs() {
        return calInputs;
    }
    
    void clear() {
        calInputs = null;
    }

    protected CalInputsFactory calInputsFactory() {
        return new CalInputsFactory();
    }
    
    static boolean isEmpty(TimeSeries timeSeries, boolean[] isFinePt, boolean enableCoarsePointProcessing) {
        if (timeSeries.isEmpty()) {
            return true;
        }
        
        if (enableCoarsePointProcessing) {
            return false;
        }
        
        int startCadence = timeSeries.startCadence();
        for (SimpleInterval validInterval : timeSeries.validCadences()) {
            int validStart = (int) validInterval.start() - startCadence;
            int validEnd = (int) validInterval.end() - startCadence;
            for (int c=validStart; c <= validEnd; c++) {
                if (isFinePt[c]) {
                    return false;
                }
            }
        }
        return true;
    }
}
