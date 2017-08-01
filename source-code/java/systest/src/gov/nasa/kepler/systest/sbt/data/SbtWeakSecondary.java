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

import gov.nasa.kepler.dv.io.DvQuantity;
import gov.nasa.kepler.hibernate.dv.DvWeakSecondary;

/**
 * This class contains a weak secondary for a planet candidate.
 * 
 * @author Forrest Girouard
 * 
 */
public class SbtWeakSecondary implements SbtDataContainer {

    private float maxMesPhaseInDays;
    private float maxMes;
    private float minMesPhaseInDays;
    private float minMes;
    private float mesMad;
    private DvQuantity depthPpm = new DvQuantity();
    private float medianMes;
    private int validPhaseCount;
    private float robustStatistic;

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {

        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("maxMesPhaseInDays",
            new SbtNumber(maxMesPhaseInDays).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("maxMes", new SbtNumber(
            maxMes).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("minMesPhaseInDays",
            new SbtNumber(minMesPhaseInDays).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("minMes", new SbtNumber(
            minMes).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("mesMad", new SbtNumber(
            mesMad).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("depthPpm.value",
            new SbtNumber(depthPpm.getValue()).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "depthPpm.uncertainty",
            new SbtNumber(depthPpm.getUncertainty()).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("medianMes", new SbtNumber(
            medianMes).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("validPhaseCount",
            new SbtNumber(validPhaseCount).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("robustStatistic",
            new SbtNumber(robustStatistic).toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtWeakSecondary() {
    }

    public SbtWeakSecondary(DvWeakSecondary dvWeakSecondary) {
        maxMesPhaseInDays = dvWeakSecondary.getMaxMesPhaseInDays();
        maxMes = dvWeakSecondary.getMaxMes();
        minMesPhaseInDays = dvWeakSecondary.getMinMesPhaseInDays();
        minMes = dvWeakSecondary.getMinMes();
        mesMad = dvWeakSecondary.getMesMad();
        depthPpm = new DvQuantity(dvWeakSecondary.getDepthPpm()
            .getValue(), dvWeakSecondary.getDepthPpm()
            .getUncertainty());
        medianMes = dvWeakSecondary.getMedianMes();
        validPhaseCount = dvWeakSecondary.getValidPhaseCount();
        robustStatistic = dvWeakSecondary.getRobustStatistic();
    }

    public float getMaxMesPhaseInDays() {
        return maxMesPhaseInDays;
    }

    public void setMaxMesPhaseInDays(float bestPhaseInDays) {
        maxMesPhaseInDays = bestPhaseInDays;
    }

    public float getMaxMes() {
        return maxMes;
    }

    public void setMaxMes(float bestMes) {
        maxMes = bestMes;
    }

    public float getMinMesPhaseInDays() {
        return minMesPhaseInDays;
    }

    public void setMinMesPhaseInDays(float minMesPhaseInDays) {
        this.minMesPhaseInDays = minMesPhaseInDays;
    }

    public float getMinMes() {
        return minMes;
    }

    public void setMinMes(float minMes) {
        this.minMes = minMes;
    }

    public float getMesMad() {
        return mesMad;
    }

    public void setMesMad(float mesMad) {
        this.mesMad = mesMad;
    }

    public DvQuantity getDepthPpm() {
        return depthPpm;
    }

    public void setDepthPpm(DvQuantity depthPpm) {
        this.depthPpm = depthPpm;
    }

    public float depthPpm() {
        return depthPpm.getValue();
    }

    public float depthPpmUncert() {
        return depthPpm.getUncertainty();
    }

    public float getMedianMes() {
        return medianMes;
    }

    public void setMedianMes(float medianMes) {
        this.medianMes = medianMes;
    }

    public int getValidPhaseCount() {
        return validPhaseCount;
    }

    public void setValidPhaseCount(int validPhaseCount) {
        this.validPhaseCount = validPhaseCount;
    }

    public float getRobustStatistic() {
        return robustStatistic;
    }

    public void setRobustStatistic(float robustStatistic) {
        this.robustStatistic = robustStatistic;
    }
}
