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

/**
 * This class contains planet results for an aperture.
 * 
 * @author Miles Cote
 * 
 */
public class SbtAperturePlanetResults implements SbtDataContainer {

    private int planetNumber;

    private SbtPixelCorrelationResults pixelCorrelationResults = new SbtPixelCorrelationResults();
    private SbtDifferenceImageResults differenceImageResults = new SbtDifferenceImageResults();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {

        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("planetNumber",
            new SbtNumber(planetNumber).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("pixelCorrelationResults",
            pixelCorrelationResults.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("differenceImageResults",
            differenceImageResults.toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtAperturePlanetResults() {
    }

    public SbtAperturePlanetResults(int planetNumber,
        SbtPixelCorrelationResults pixelCorrelationResults,
        SbtDifferenceImageResults differenceImageResults) {
        this.planetNumber = planetNumber;
        this.pixelCorrelationResults = pixelCorrelationResults;
        this.differenceImageResults = differenceImageResults;
    }

    public int getPlanetNumber() {
        return planetNumber;
    }

    public void setPlanetNumber(int planetNumber) {
        this.planetNumber = planetNumber;
    }

    public SbtPixelCorrelationResults getPixelCorrelationResults() {
        return pixelCorrelationResults;
    }

    public void setPixelCorrelationResults(
        SbtPixelCorrelationResults pixelCorrelationResults) {
        this.pixelCorrelationResults = pixelCorrelationResults;
    }

    public SbtDifferenceImageResults getDifferenceImageResults() {
        return differenceImageResults;
    }

    public void setDifferenceImageResults(
        SbtDifferenceImageResults differenceImageResults) {
        this.differenceImageResults = differenceImageResults;
    }

}
