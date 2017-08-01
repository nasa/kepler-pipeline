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

import gov.nasa.kepler.mc.CompoundIndicesTimeSeries;
import gov.nasa.kepler.mc.CorrectedFluxTimeSeries;

/**
 * This class wraps {@link CorrectedFluxTimeSeries} and
 * {@link CompoundIndicesTimeSeries} with a type.
 * 
 * @author Miles Cote
 * 
 */
public class SbtCorrectedFluxAndOutliersTimeSeries implements SbtDataContainer {

    private String type = "";

    private CorrectedFluxTimeSeries timeSeries = new CorrectedFluxTimeSeries();
    private CompoundIndicesTimeSeries outliers = new CompoundIndicesTimeSeries();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("type",
            new SbtString(type).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "timeSeries",
            new SbtCorrectedFluxTimeSeries(timeSeries).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "outliers",
            new SbtCompoundIndicesTimeSeries(outliers).toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtCorrectedFluxAndOutliersTimeSeries() {
    }

    public SbtCorrectedFluxAndOutliersTimeSeries(String type,
        CorrectedFluxTimeSeries timeSeries, CompoundIndicesTimeSeries outliers) {
        this.type = type;
        this.timeSeries = timeSeries;
        this.outliers = outliers;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public CorrectedFluxTimeSeries getTimeSeries() {
        return timeSeries;
    }

    public void setTimeSeries(CorrectedFluxTimeSeries timeSeries) {
        this.timeSeries = timeSeries;
    }

    public CompoundIndicesTimeSeries getOutliers() {
        return outliers;
    }

    public void setOutliers(CompoundIndicesTimeSeries outliers) {
        this.outliers = outliers;
    }

}
