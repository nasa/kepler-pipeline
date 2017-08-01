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
import static com.google.common.primitives.Floats.toArray;
import gov.nasa.kepler.hibernate.dv.DvBootstrapHistogram;

import java.util.List;

import org.apache.commons.lang.ArrayUtils;

/**
 * This class contains a bootstrap histogram.
 * 
 * @author Miles Cote
 * 
 */
public class SbtBootstrapHistogram implements SbtDataContainer {

    private int finalSkipCount;
    private float[] probabilities = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] statistics = ArrayUtils.EMPTY_FLOAT_ARRAY;

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("finalSkipCount",
            new SbtNumber(finalSkipCount).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("probabilities",
            new SbtList(SbtDataContainerListFactory.getInstance(probabilities),
                true).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("statistics",
            new SbtList(SbtDataContainerListFactory.getInstance(statistics),
                true).toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtBootstrapHistogram() {
    }

    public SbtBootstrapHistogram(DvBootstrapHistogram dvBootstrapHistogram) {
        this.finalSkipCount = dvBootstrapHistogram.getFinalSkipCount();

        List<Float> probabilitiesList = newArrayList();
        for (Float probability : dvBootstrapHistogram.getProbabilities()) {
            probabilitiesList.add(probability);
        }
        this.probabilities = toArray(probabilitiesList);

        List<Float> statisticsList = newArrayList();
        for (Float statistic : dvBootstrapHistogram.getStatistics()) {
            statisticsList.add(statistic);
        }
        this.statistics = toArray(statisticsList);
    }

    public SbtBootstrapHistogram(int finalSkipCount, float[] probabilities,
        float[] statistics) {
        this.finalSkipCount = finalSkipCount;
        this.probabilities = probabilities;
        this.statistics = statistics;
    }

    public int getFinalSkipCount() {
        return finalSkipCount;
    }

    public void setFinalSkipCount(int finalSkipCount) {
        this.finalSkipCount = finalSkipCount;
    }

    public float[] getProbabilities() {
        return probabilities;
    }

    public void setProbabilities(float[] probabilities) {
        this.probabilities = probabilities;
    }

    public float[] getStatistics() {
        return statistics;
    }

    public void setStatistics(float[] statistics) {
        this.statistics = statistics;
    }

}
