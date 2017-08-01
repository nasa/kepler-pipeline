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

import java.util.List;

/**
 * This class contains parameters, along with the cadence range they were in
 * effect.
 * 
 * @author Miles Cote
 * 
 */
public class SbtParameterMap implements SbtDataContainer, CadenceRangeData {

    private int startCadence;
    private int endCadence;

    private List<SbtParameterMapEntry> entries = newArrayList();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("startCadence",
            new SbtNumber(startCadence).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("endCadence", new SbtNumber(
            endCadence).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("entries", new SbtList(
            entries, true).toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    @Override
    public boolean dataEquals(CadenceRangeData cadenceRangeData) {
        boolean dataEquals = false;
        if (cadenceRangeData != null
            && cadenceRangeData instanceof SbtParameterMap) {
            SbtParameterMap sbtParameterMap = (SbtParameterMap) cadenceRangeData;
            dataEquals = entries.equals(sbtParameterMap.entries);
        }

        return dataEquals;
    }

    public SbtParameterMap() {
    }

    public SbtParameterMap(int startCadence, int endCadence,
        List<SbtParameterMapEntry> entries) {
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.entries = entries;
    }

    public int getStartCadence() {
        return startCadence;
    }

    public void setStartCadence(int startCadence) {
        this.startCadence = startCadence;
    }

    @Override
    public int getEndCadence() {
        return endCadence;
    }

    @Override
    public void setEndCadence(int endCadence) {
        this.endCadence = endCadence;
    }

    public List<SbtParameterMapEntry> getEntries() {
        return entries;
    }

    public void setEntries(List<SbtParameterMapEntry> entries) {
        this.entries = entries;
    }

}
