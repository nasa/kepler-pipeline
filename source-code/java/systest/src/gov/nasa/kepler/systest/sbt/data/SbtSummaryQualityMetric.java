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

import gov.nasa.kepler.hibernate.dv.DvSummaryQualityMetric;

public class SbtSummaryQualityMetric implements SbtDataContainer {

    private float fractionOfGoodMetrics;
    private int numberOfAttempts;
    private int numberOfGoodMetrics;
    private int numberOfMetrics;
    private float qualityThreshold;

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {

        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString(
            "fractionOfGoodMetrics",
            new SbtNumber(fractionOfGoodMetrics).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("numberOfAttempts",
            new SbtNumber(numberOfAttempts).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("numberOfGoodMetrics",
            new SbtNumber(numberOfGoodMetrics).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("numberOfMetrics",
            new SbtNumber(numberOfMetrics).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("qualityThreshold",
            new SbtNumber(qualityThreshold).toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtSummaryQualityMetric() {
    }

    public SbtSummaryQualityMetric(DvSummaryQualityMetric summaryQualityMetric) {
        fractionOfGoodMetrics = summaryQualityMetric.getFractionOfGoodMetrics();
        numberOfAttempts = summaryQualityMetric.getNumberOfAttempts();
        numberOfGoodMetrics = summaryQualityMetric.getNumberOfGoodMetrics();
        numberOfMetrics = summaryQualityMetric.getNumberOfMetrics();
        qualityThreshold = summaryQualityMetric.getQualityThreshold();
    }

    public float getFractionOfGoodMetrics() {
        return fractionOfGoodMetrics;
    }

    public void setFractionOfGoodMetrics(float fractionOfGoodMetrics) {
        this.fractionOfGoodMetrics = fractionOfGoodMetrics;
    }

    public int getNumberOfAttempts() {
        return numberOfAttempts;
    }

    public void setNumberOfAttempts(int numberOfAttempts) {
        this.numberOfAttempts = numberOfAttempts;
    }

    public int getNumberOfGoodMetrics() {
        return numberOfGoodMetrics;
    }

    public void setNumberOfGoodMetrics(int numberOfGoodMetrics) {
        this.numberOfGoodMetrics = numberOfGoodMetrics;
    }

    public int getNumberOfMetrics() {
        return numberOfMetrics;
    }

    public void setNumberOfMetrics(int numberOfMetrics) {
        this.numberOfMetrics = numberOfMetrics;
    }

    public float getQualityThreshold() {
        return qualityThreshold;
    }

    public void setQualityThreshold(float qualityThreshold) {
        this.qualityThreshold = qualityThreshold;
    }
}
