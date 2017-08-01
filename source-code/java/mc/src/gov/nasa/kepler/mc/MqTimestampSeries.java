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

package gov.nasa.kepler.mc;

import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.DataAnomalyFlags;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;

import java.util.Arrays;

import org.apache.commons.lang.ArrayUtils;

public class MqTimestampSeries extends TimestampSeries {

    @ProxyIgnore
    private static final long serialVersionUID = 5650996439902342724L;

    public int[] lcTargetTableIds = ArrayUtils.EMPTY_INT_ARRAY;
    public int[] scTargetTableIds = ArrayUtils.EMPTY_INT_ARRAY;
    public int[] quarters = ArrayUtils.EMPTY_INT_ARRAY;

    public MqTimestampSeries() {
    }

    public MqTimestampSeries(RollTimeOperations rollTimeOperations,
        MjdToCadence mjdToCadence, int startCadence, int endCadence) {

        TimestampSeries cadenceTimes = mjdToCadence.cadenceTimes(startCadence,
            endCadence, true, false);
        cadenceNumbers = cadenceTimes.cadenceNumbers;
        endTimestamps = cadenceTimes.endTimestamps;
        gapIndicators = cadenceTimes.gapIndicators;
        midTimestamps = cadenceTimes.midTimestamps;
        requantEnabled = cadenceTimes.requantEnabled;
        startTimestamps = cadenceTimes.startTimestamps;
        isFinePnt = cadenceTimes.isFinePnt;
        isLdeOos = cadenceTimes.isLdeOos;
        isLdeParEr = cadenceTimes.isLdeParEr;
        isMmntmDmp = cadenceTimes.isMmntmDmp;
        isScrcErr = cadenceTimes.isScrcErr;
        isSefiAcc = cadenceTimes.isSefiAcc;
        isSefiCad = cadenceTimes.isSefiCad;
        dataAnomalyFlags = cadenceTimes.dataAnomalyFlags;
        quarters = rollTimeOperations.mjdToQuarter(startTimestamps);
        lcTargetTableIds = new int[cadenceNumbers.length];
        scTargetTableIds = new int[cadenceNumbers.length];
        for (int i = 0; i < cadenceNumbers.length; i++) {
            PixelLog pixelLog = mjdToCadence.pixelLogForCadence(cadenceNumbers[i]);
            if (pixelLog != null) {
                lcTargetTableIds[i] = pixelLog.getLcTargetTableId();
                scTargetTableIds[i] = pixelLog.getScTargetTableId();
            }
        }
    }

    public MqTimestampSeries(RollTimeOperations rollTimeOperations,
        MjdToCadence mjdToCadence, double[] startTimestamps,
        double[] midTimestamps, double[] endTimestamps,
        boolean[] gapIndicators, boolean[] requantEnabled,
        int[] cadenceNumbers, boolean[] isSefiAcc, boolean[] isSefiCad,
        boolean[] isLdeOos, boolean[] isFinePnt, boolean[] isMmntmDmp,
        boolean[] isLdeParEr, boolean[] isScrcErr,
        DataAnomalyFlags dataAnomalyFlags) {
        this.startTimestamps = startTimestamps;
        this.endTimestamps = endTimestamps;
        this.midTimestamps = midTimestamps;
        this.gapIndicators = gapIndicators;
        this.requantEnabled = requantEnabled;
        this.cadenceNumbers = cadenceNumbers;
        this.isSefiAcc = isSefiAcc;
        this.isSefiCad = isSefiCad;
        this.isLdeOos = isLdeOos;
        this.isFinePnt = isFinePnt;
        this.isMmntmDmp = isMmntmDmp;
        this.isLdeParEr = isLdeParEr;
        this.isScrcErr = isScrcErr;
        this.dataAnomalyFlags = dataAnomalyFlags;
        quarters = rollTimeOperations.mjdToQuarter(startTimestamps);
        lcTargetTableIds = new int[cadenceNumbers.length];
        scTargetTableIds = new int[cadenceNumbers.length];
        for (int i = 0; i < cadenceNumbers.length; i++) {
            PixelLog pixelLog = mjdToCadence.pixelLogForCadence(cadenceNumbers[i]);
            if (pixelLog != null) {
                lcTargetTableIds[i] = pixelLog.getLcTargetTableId();
                scTargetTableIds[i] = pixelLog.getScTargetTableId();
            }
        }
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + super.hashCode();
        result = prime * result + Arrays.hashCode(lcTargetTableIds);
        result = prime * result + Arrays.hashCode(scTargetTableIds);
        result = prime * result + Arrays.hashCode(quarters);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof MqTimestampSeries)) {
            return false;
        }
        final MqTimestampSeries other = (MqTimestampSeries) obj;
        if (!super.equals(obj)) {
            return false;
        }
        if (!Arrays.equals(lcTargetTableIds, other.lcTargetTableIds)) {
            return false;
        }
        if (!Arrays.equals(scTargetTableIds, other.scTargetTableIds)) {
            return false;
        }
        if (!Arrays.equals(quarters, other.quarters)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return this.getClass()
            .getSimpleName();

    }
}
