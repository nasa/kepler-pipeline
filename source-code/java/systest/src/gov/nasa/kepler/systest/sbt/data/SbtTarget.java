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
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;

import java.util.List;

/**
 * This class contains target-specific data. This includes multi-quarter data as
 * well as quarter-specific data.
 * 
 * @author Miles Cote
 * 
 */
public class SbtTarget implements SbtDataContainer {

    private int keplerId;

    private CelestialObjectParameters kicData = new CelestialObjectParameters();

    private SimpleFloatTimeSeries barycentricTimeOffsets = new SimpleFloatTimeSeries();

    private List<SbtFluxGroup> fluxGroups = newArrayList();

    private List<SbtAperture> targetTables = newArrayList();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("keplerId", new SbtNumber(
            keplerId).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "kicData",
            new SbtCelestialObjectParameters(kicData).toMissingDataString(parameters)));
        if (!parameters.isCustomTarget()) {
            stringBuilder.append(SbtDataUtils.toString(
                "barycentricTimeOffsets", new SbtSimpleTimeSeries(
                    barycentricTimeOffsets).toMissingDataString(parameters)));
            // fluxGroups[1] and fluxGroups[2] are gapped because they are OAP
            // and DIA types, which will always be gapped until OAP or DIA is
            // implemented and enabled.
            stringBuilder.append(SbtDataUtils.toString("fluxGroups",
                new SbtList(fluxGroups, new SbtGapIndicators(new boolean[] {
                    false, true, true })).toMissingDataString(parameters)));
        }
        stringBuilder.append(SbtDataUtils.toString("targetTables", new SbtList(
            targetTables).toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtTarget() {
    }

    public SbtTarget(int keplerId, CelestialObjectParameters kicData,
        SimpleFloatTimeSeries barycentricTimeOffsets,
        List<SbtFluxGroup> fluxGroups, List<SbtAperture> targetTables) {
        this.keplerId = keplerId;
        this.kicData = kicData;
        this.barycentricTimeOffsets = barycentricTimeOffsets;
        this.fluxGroups = fluxGroups;
        this.targetTables = targetTables;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public void setKeplerId(int keplerId) {
        this.keplerId = keplerId;
    }

    public CelestialObjectParameters getKicData() {
        return kicData;
    }

    public void setKicData(CelestialObjectParameters kicData) {
        this.kicData = kicData;
    }

    public SimpleFloatTimeSeries getBarycentricTimeOffsets() {
        return barycentricTimeOffsets;
    }

    public void setBarycentricTimeOffsets(
        SimpleFloatTimeSeries barycentricTimeOffsets) {
        this.barycentricTimeOffsets = barycentricTimeOffsets;
    }

    public List<SbtFluxGroup> getFluxGroups() {
        return fluxGroups;
    }

    public void setFluxGroups(List<SbtFluxGroup> fluxGroups) {
        this.fluxGroups = fluxGroups;
    }

    public List<SbtAperture> getTargetTables() {
        return targetTables;
    }

    public void setTargetTables(List<SbtAperture> targetTables) {
        this.targetTables = targetTables;
    }

}
