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

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;

import java.util.List;

/**
 * This class contains target table data. This includes mod/out specific data.
 * 
 * @author Miles Cote
 * 
 */
public class SbtTargetTable implements SbtDataContainer {

    private int targetTableId;
    private int quarter;
    private int startCadence;
    private int endCadence;

    private TimestampSeries cadenceTimes = new TimestampSeries();

    private List<SbtModOut> modOuts = newArrayList();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("targetTableId",
            new SbtNumber(targetTableId).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("quarter", new SbtNumber(
            quarter).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("startCadence",
            new SbtNumber(startCadence).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("endCadence", new SbtNumber(
            endCadence).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "cadenceTimes",
            new SbtTimestampSeries(cadenceTimes).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("modOuts", new SbtList(
            modOuts).toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtTargetTable() {
    }

    public SbtTargetTable(int targetTableId, int quarter, int startCadence,
        int endCadence, TimestampSeries cadenceTimes, List<SbtModOut> modOuts) {
        this.targetTableId = targetTableId;
        this.quarter = quarter;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.cadenceTimes = cadenceTimes;
        this.modOuts = modOuts;
    }

    public int getTargetTableId() {
        return targetTableId;
    }

    public void setTargetTableId(int targetTableId) {
        this.targetTableId = targetTableId;
    }

    public int getQuarter() {
        return quarter;
    }

    public void setQuarter(int quarter) {
        this.quarter = quarter;
    }

    public int getStartCadence() {
        return startCadence;
    }

    public void setStartCadence(int startCadence) {
        this.startCadence = startCadence;
    }

    public int getEndCadence() {
        return endCadence;
    }

    public void setEndCadence(int endCadence) {
        this.endCadence = endCadence;
    }

    public TimestampSeries getCadenceTimes() {
        return cadenceTimes;
    }

    public void setCadenceTimes(TimestampSeries cadenceTimes) {
        this.cadenceTimes = cadenceTimes;
    }

    public List<SbtModOut> getModOuts() {
        return modOuts;
    }

    public void setModOuts(List<SbtModOut> modOuts) {
        this.modOuts = modOuts;
    }

}
