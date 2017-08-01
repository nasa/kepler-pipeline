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

package gov.nasa.kepler.pdc;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.hibernate.mc.ObservingLog;
import gov.nasa.kepler.hibernate.mc.ObservingLogModel;
import gov.nasa.kepler.mc.MqTimestampSeries;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.DataAnomalyFlags;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Arrays;
import java.util.List;

import org.apache.commons.lang.ArrayUtils;

public class PdcTimestampSeries extends MqTimestampSeries implements
    Persistable {

    private static final long serialVersionUID = 9017586244288235822L;

    public int[] months = ArrayUtils.EMPTY_INT_ARRAY;

    public PdcTimestampSeries() {
    }

    public PdcTimestampSeries(RollTimeOperations rollTimeOperations,
        MjdToCadence mjdToCadence, ObservingLogModel observingLogModel,
        CadenceType cadenceType, int startCadence, int endCadence) {

        super(rollTimeOperations, mjdToCadence, startCadence, endCadence);

        months = new int[cadenceNumbers.length];

        if (cadenceNumbers.length > 0) {
            List<ObservingLog> observingLogs = observingLogModel.observingLogsFor(
                cadenceType.intValue(), startCadence, endCadence);
            int lastIndex = 0;
            for (ObservingLog observingLog : observingLogs) {
                for (int i = lastIndex; i < cadenceNumbers.length; i++) {
                    if (cadenceNumbers[i] <= observingLog.getCadenceEnd()
                        && cadenceNumbers[i] >= observingLog.getCadenceStart()) {
                        months[i] = observingLog.getMonth();
                    } else {
                        lastIndex = i;
                        continue;
                    }
                }
            }
        }
    }

    public PdcTimestampSeries(RollTimeOperations rollTimeOperations,
        MjdToCadence mjdToCadence, ObservingLogModel observingLogModel,
        CadenceType cadenceType, int startCadence, int endCadence,
        double[] startTimestamps, double[] midTimestamps,
        double[] endTimestamps, boolean[] gapIndicators,
        boolean[] requantEnabled, int[] cadenceNumbers, boolean[] isSefiAcc,
        boolean[] isSefiCad, boolean[] isLdeOos, boolean[] isFinePnt,
        boolean[] isMmntmDmp, boolean[] isLdeParEr, boolean[] isScrcErr,
        DataAnomalyFlags dataAnomalyFlags) {

        super(rollTimeOperations, mjdToCadence, startTimestamps, midTimestamps,
            endTimestamps, gapIndicators, requantEnabled, cadenceNumbers,
            isSefiAcc, isSefiCad, isLdeOos, isFinePnt, isMmntmDmp, isLdeParEr,
            isScrcErr, dataAnomalyFlags);

        months = new int[cadenceNumbers.length];

        if (cadenceNumbers.length > 0) {
            List<ObservingLog> observingLogs = observingLogModel.observingLogsFor(
                cadenceType.intValue(), startCadence, endCadence);
            int lastIndex = 0;
            for (ObservingLog observingLog : observingLogs) {
                for (int i = lastIndex; i < cadenceNumbers.length; i++) {
                    if (cadenceNumbers[i] <= observingLog.getCadenceEnd()
                        && cadenceNumbers[i] >= observingLog.getCadenceStart()) {
                        months[i] = observingLog.getMonth();
                    } else {
                        lastIndex = i;
                        continue;
                    }
                }
            }
        }
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + super.hashCode();
        result = prime * result + Arrays.hashCode(months);
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
        if (!(obj instanceof PdcTimestampSeries)) {
            return false;
        }
        final PdcTimestampSeries other = (PdcTimestampSeries) obj;
        if (!super.equals(obj)) {
            return false;
        }
        if (!Arrays.equals(months, other.months)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return getClass().getSimpleName();

    }
}
