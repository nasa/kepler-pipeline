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

package gov.nasa.kepler.systest.sbt.data;

import gov.nasa.kepler.mc.MqTimestampSeries;

/**
 * This class wraps {@link MqTimestampSeries}.
 * 
 * @author Miles Cote
 * 
 */
public class SbtMqTimestampSeries implements SbtDataContainer {

    private MqTimestampSeries timestampSeries = new MqTimestampSeries();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {
        SbtGapIndicators gapIndicators = new SbtGapIndicators(
            timestampSeries.gapIndicators);
        SbtList startTimestamps = new SbtList(
            SbtDataContainerListFactory.getInstance(timestampSeries.startTimestamps),
            gapIndicators);
        SbtList midTimestamps = new SbtList(
            SbtDataContainerListFactory.getInstance(timestampSeries.midTimestamps),
            gapIndicators);
        SbtList endTimestamps = new SbtList(
            SbtDataContainerListFactory.getInstance(timestampSeries.endTimestamps),
            gapIndicators);
        SbtList cadenceNumbers = new SbtList(
            SbtDataContainerListFactory.getInstance(timestampSeries.cadenceNumbers),
            gapIndicators);
        SbtList lcTargetTableIds = new SbtList(
            SbtDataContainerListFactory.getInstance(timestampSeries.lcTargetTableIds),
            gapIndicators);
        SbtList quarters = new SbtList(
            SbtDataContainerListFactory.getInstance(timestampSeries.quarters),
            gapIndicators);

        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("gapIndicators",
            gapIndicators.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("startTimestamps",
            startTimestamps.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("midTimestamps",
            midTimestamps.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("endTimestamps",
            endTimestamps.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("cadenceNumbers",
            cadenceNumbers.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("lcTargetTableIds",
            lcTargetTableIds.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("quarters",
            quarters.toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtMqTimestampSeries() {
    }

    public SbtMqTimestampSeries(MqTimestampSeries timestampSeries) {
        this.timestampSeries = timestampSeries;
    }

}
