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

import gov.nasa.kepler.hibernate.dv.DvBinaryDiscriminationResults;

/**
 * This class contains binary discrimination results.
 * 
 * @author Miles Cote
 * 
 */
public class SbtBinaryDiscriminationResults implements SbtDataContainer {

    private SbtPlanetStatistic longerPeriodComparisonStatistic = new SbtPlanetStatistic();
    private SbtPlanetStatistic shorterPeriodComparisonStatistic = new SbtPlanetStatistic();
    private SbtStatistic oddEvenTransitDepthComparisonStatistic = new SbtStatistic();
    private SbtStatistic oddEvenTransitEpochComparisonStatistic = new SbtStatistic();
    private SbtStatistic singleTransitDepthComparisonStatistic = new SbtStatistic();
    private SbtStatistic singleTransitEpochComparisonStatistic = new SbtStatistic();
    private SbtStatistic singleTransitDurationComparisonStatistic = new SbtStatistic();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString(
            "longerPeriodComparisonStatistic",
            longerPeriodComparisonStatistic.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "shorterPeriodComparisonStatistic",
            shorterPeriodComparisonStatistic.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "oddEvenTransitDepthComparisonStatistic",
            oddEvenTransitDepthComparisonStatistic.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "oddEvenTransitEpochComparisonStatistic",
            oddEvenTransitEpochComparisonStatistic.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "singleTransitDepthComparisonStatistic",
            singleTransitDepthComparisonStatistic.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "singleTransitEpochComparisonStatistic",
            singleTransitEpochComparisonStatistic.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "singleTransitDurationComparisonStatistic",
            singleTransitDurationComparisonStatistic.toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtBinaryDiscriminationResults() {
    }

    public SbtBinaryDiscriminationResults(
        DvBinaryDiscriminationResults dvBinaryDiscriminationResults) {
        this.longerPeriodComparisonStatistic = new SbtPlanetStatistic(
            dvBinaryDiscriminationResults.getLongerPeriodComparisonStatistic());
        this.shorterPeriodComparisonStatistic = new SbtPlanetStatistic(
            dvBinaryDiscriminationResults.getShorterPeriodComparisonStatistic());
        this.oddEvenTransitDepthComparisonStatistic = new SbtStatistic(
            dvBinaryDiscriminationResults.getOddEvenTransitDepthComparisonStatistic());
        this.oddEvenTransitEpochComparisonStatistic = new SbtStatistic(
            dvBinaryDiscriminationResults.getOddEvenTransitEpochComparisonStatistic());
        this.singleTransitDepthComparisonStatistic = new SbtStatistic(
            dvBinaryDiscriminationResults.getSingleTransitDepthComparisonStatistic());
        this.singleTransitEpochComparisonStatistic = new SbtStatistic(
            dvBinaryDiscriminationResults.getSingleTransitEpochComparisonStatistic());
        this.singleTransitDurationComparisonStatistic = new SbtStatistic(
            dvBinaryDiscriminationResults.getSingleTransitDurationComparisonStatistic());
    }

    public SbtBinaryDiscriminationResults(
        SbtPlanetStatistic longerPeriodComparisonStatistic,
        SbtPlanetStatistic shorterPeriodComparisonStatistic,
        SbtStatistic oddEvenTransitDepthComparisonStatistic,
        SbtStatistic oddEvenTransitEpochComparisonStatistic,
        SbtStatistic singleTransitDepthComparisonStatistic,
        SbtStatistic singleTransitEpochComparisonStatistic,
        SbtStatistic singleTransitDurationComparisonStatistic) {
        this.longerPeriodComparisonStatistic = longerPeriodComparisonStatistic;
        this.shorterPeriodComparisonStatistic = shorterPeriodComparisonStatistic;
        this.oddEvenTransitDepthComparisonStatistic = oddEvenTransitDepthComparisonStatistic;
        this.oddEvenTransitEpochComparisonStatistic = oddEvenTransitEpochComparisonStatistic;
        this.singleTransitDepthComparisonStatistic = singleTransitDepthComparisonStatistic;
        this.singleTransitEpochComparisonStatistic = singleTransitEpochComparisonStatistic;
        this.singleTransitDurationComparisonStatistic = singleTransitDurationComparisonStatistic;
    }

    public SbtPlanetStatistic getLongerPeriodComparisonStatistic() {
        return longerPeriodComparisonStatistic;
    }

    public void setLongerPeriodComparisonStatistic(
        SbtPlanetStatistic longerPeriodComparisonStatistic) {
        this.longerPeriodComparisonStatistic = longerPeriodComparisonStatistic;
    }

    public SbtPlanetStatistic getShorterPeriodComparisonStatistic() {
        return shorterPeriodComparisonStatistic;
    }

    public void setShorterPeriodComparisonStatistic(
        SbtPlanetStatistic shorterPeriodComparisonStatistic) {
        this.shorterPeriodComparisonStatistic = shorterPeriodComparisonStatistic;
    }

    public SbtStatistic getOddEvenTransitDepthComparisonStatistic() {
        return oddEvenTransitDepthComparisonStatistic;
    }

    public void setOddEvenTransitDepthComparisonStatistic(
        SbtStatistic oddEvenTransitDepthComparisonStatistic) {
        this.oddEvenTransitDepthComparisonStatistic = oddEvenTransitDepthComparisonStatistic;
    }

    public SbtStatistic getOddEvenTransitEpochComparisonStatistic() {
        return oddEvenTransitEpochComparisonStatistic;
    }

    public void setOddEvenTransitEpochComparisonStatistic(
        SbtStatistic oddEvenTransitEpochComparisonStatistic) {
        this.oddEvenTransitEpochComparisonStatistic = oddEvenTransitEpochComparisonStatistic;
    }

    public SbtStatistic getSingleTransitDepthComparisonStatistic() {
        return singleTransitDepthComparisonStatistic;
    }

    public void setSingleTransitDepthComparisonStatistic(
        SbtStatistic singleTransitDepthComparisonStatistic) {
        this.singleTransitDepthComparisonStatistic = singleTransitDepthComparisonStatistic;
    }

    public SbtStatistic getSingleTransitEpochComparisonStatistic() {
        return singleTransitEpochComparisonStatistic;
    }

    public void setSingleTransitEpochComparisonStatistic(
        SbtStatistic singleTransitEpochComparisonStatistic) {
        this.singleTransitEpochComparisonStatistic = singleTransitEpochComparisonStatistic;
    }

    public SbtStatistic getSingleTransitDurationComparisonStatistic() {
        return singleTransitDurationComparisonStatistic;
    }

    public void setSingleTransitDurationComparisonStatistic(
        SbtStatistic singleTransitDurationComparisonStatistic) {
        this.singleTransitDurationComparisonStatistic = singleTransitDurationComparisonStatistic;
    }

}
