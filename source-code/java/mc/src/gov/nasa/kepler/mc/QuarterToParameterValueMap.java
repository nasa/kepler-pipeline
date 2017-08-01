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

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Maps.newHashMap;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ranges.Range;
import gov.nasa.kepler.common.ranges.Ranges;
import gov.nasa.kepler.hibernate.mc.ObservingLog;
import gov.nasa.kepler.hibernate.mc.ObservingLogModel;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.List;
import java.util.Map;

/**
 * Contains a map of quarters to parameter values. For example, given:
 *   blackAlgorithmQuarters = "q0:q1,q2:q16,q17"
 *   blackAlgorithm = "exponentialOneDBlack,dynablack,exponentialOneDBlack"
 *   
 * This class will return 'dynablack' for a q5 cadence range.
 * 
 * @author Miles Cote
 * 
 */
public class QuarterToParameterValueMap {

    private final ObservingLogModel observingLogModel;

    public QuarterToParameterValueMap(ObservingLogModel observingLogModel) {
        this.observingLogModel = observingLogModel;
    }

    public <T> int getQuarter(List<String> quartersList, List<T> values,
        CadenceType cadenceType, int startCadence, int endCadence) {
        return getQuarterValuePair(quartersList, values, cadenceType, startCadence, endCadence).left;
    }
    
    public <T> T getValue(List<String> quartersList, List<T> values,
        CadenceType cadenceType, int startCadence, int endCadence) {
        return getQuarterValuePair(quartersList, values, cadenceType, startCadence, endCadence).right;
    }
    
    private <T> Pair<Integer, T> getQuarterValuePair(List<String> quartersList, List<T> values,
        CadenceType cadenceType, int startCadence, int endCadence) {
        if (quartersList == null) {
            throw new IllegalArgumentException("quartersList cannot be null.");
        }

        if (values == null) {
            throw new IllegalArgumentException("values cannot be null.");
        }

        if (quartersList.size() != values.size()) {
            throw new IllegalArgumentException(
                "quartersList and values cannot differ in length."
                    + "\n  quartersList.size(): " + quartersList.size()
                    + "\n  values.size(): " + values.size());
        }

        List<String> updatedQuartersList = newArrayList();
        for (String quarters : quartersList) {
            quarters = quarters.replace("q", "");
            quarters = quarters.replace("Q", "");
            updatedQuartersList.add(quarters);
        }
        quartersList = updatedQuartersList;

        List<Range> quarterRanges = Ranges.forStrings(quartersList)
            .getRanges();

        Map<Integer, T> quarterToValue = newHashMap();
        for (int i = 0; i < quarterRanges.size(); i++) {
            Range quarterRange = quarterRanges.get(i);
            T value = values.get(i);
            for (Integer quarter : quarterRange.toIntegers()) {
                quarterToValue.put(quarter, value);
            }
        }

        List<ObservingLog> observingLogs = observingLogModel.observingLogsFor(cadenceType.intValue(), startCadence, endCadence);
        if (observingLogs.isEmpty()) {
            throw new IllegalArgumentException(
                "Observing logs for the input cadence range cannot be empty."
                    + "\n  cadenceType: " + cadenceType + "\n  startCadence: "
                    + startCadence + "\n  endCadence: " + endCadence);
        }

        int quarter = observingLogs.get(0)
            .getQuarter();

        for (ObservingLog observingLog : observingLogs) {
            if (observingLog.getQuarter() != quarter) {
                throw new IllegalArgumentException(
                    "Observing logs for the input cadence range cannot have different quarters."
                        + "\n  quarter: " + quarter + "\n  anotherQuarter: "
                        + observingLog.getQuarter());
            }
        }

        T value = quarterToValue.get(quarter);

        if (value == null) {
            throw new IllegalArgumentException(
                "The quarter from the observing log cannot be missing from the input quarters."
                    + "\n  quarterFromObservingLog: " + quarter
                    + "\n  inputQuarters: " + quarterToValue.keySet());
        }

        return Pair.of(quarter, value);
    }

}
