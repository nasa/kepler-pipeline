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

package gov.nasa.kepler.systest.sbt;

import gov.nasa.kepler.common.TicToc;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.hibernate.tps.TpsDbResult;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

public class SbtRetrieveTps extends AbstractSbt {
    private static final String SDF_FILE_NAME = "/tmp/sbt-retrieve-tps.sdf";
    private static final boolean REQUIRES_DATABASE = true;
    private static final boolean REQUIRES_FILESTORE = false;

    public static class TpsContainer implements Persistable {
        public List<SingleTpsResultContainer> tpsResults = new ArrayList<SingleTpsResultContainer>();

        public TpsContainer(List<TpsDbResult> tpsResults) {
            for (TpsDbResult tpsResult : tpsResults) {
                SingleTpsResultContainer resultContainer = new SingleTpsResultContainer(
                    tpsResult);
                this.tpsResults.add(resultContainer);
            }
        }

        @Override
        public String toString() {
            String out = "TpsContainer: [";
            for (SingleTpsResultContainer tpsResult : tpsResults) {
                out += " " + tpsResult.toString() + "\n";
            }
            out += "]";
            return out;
        }

        public int size() {
            return tpsResults.size();
        }
    }

    public static class SingleTpsResultContainer implements Persistable {
        // From superclass AbstractTpsDbResult:
        private int keplerId;
        private String fluxType;
        private float trialTransitPulseInHours;
        private Float maxSingleEventStatistic;
        private Float rmsCdpp;
        private int startCadence;
        private int endCadence;
        private Boolean isOnEclipsingBinaryList;

        // From TpsDbResult:
        public Double detectedOrbitalPeriodInDays;
        public Boolean isPlanetACandidate;
        public Float maxMultipleEventStatistic;
        public Float timeToFirstTransitInDays;
        public Double timeOfFirstTransitInMjd;
        public Float minSingleEventStatistic;
        public Float minMultipleEventStatistic;
        public Float timeToFirstMicrolensInDays;
        public Double timeOfFirstMicrolensInMjd;
        public Float detectedMicrolensOrbitalPeriodInDays;
        public Float robustStatistic;

        public SingleTpsResultContainer(TpsDbResult tpsResult) {
            keplerId = tpsResult.getKeplerId();
            fluxType = tpsResult.getFluxType()
                .getName();
            trialTransitPulseInHours = tpsResult.getTrialTransitPulseInHours();
            maxSingleEventStatistic = tpsResult.getMaxSingleEventStatistic();
            rmsCdpp = tpsResult.getRmsCdpp();
            startCadence = tpsResult.getStartCadence();
            endCadence = tpsResult.getEndCadence();
            try {
                isOnEclipsingBinaryList = tpsResult.isOnEclipsingBinaryList();
            } catch (NullPointerException npe) {
                isOnEclipsingBinaryList = false;
            }
            detectedOrbitalPeriodInDays = tpsResult.getDetectedOrbitalPeriodInDays();
            isPlanetACandidate = tpsResult.isPlanetACandidate();
            maxMultipleEventStatistic = tpsResult.getMaxMultipleEventStatistic();
            timeToFirstTransitInDays = tpsResult.getTimeToFirstTransitInDays();
            timeOfFirstTransitInMjd = tpsResult.timeOfFirstTransitInMjd();
            minSingleEventStatistic = tpsResult.getMinSingleEventStatistic();
            minMultipleEventStatistic = tpsResult.getMinMultipleEventStatistic();
            timeToFirstMicrolensInDays = tpsResult.getTimeToFirstMicrolensInDays();
            timeOfFirstMicrolensInMjd = tpsResult.getTimeOfFirstMicrolensInMjd();
            detectedMicrolensOrbitalPeriodInDays = tpsResult.getDetectedMicrolensOrbitalPeriodInDays();
            robustStatistic = tpsResult.getRobustStatistic();
        }

        @Override
        public String toString() {
            return "SingleTpsResultContainer [keplerId=" + keplerId
                + ", fluxType=" + fluxType + ", trialTransitPulseInHours="
                + trialTransitPulseInHours + ", maxSingleEventStatistic="
                + maxSingleEventStatistic + ", rmsCdpp=" + rmsCdpp
                + ", startCadence=" + startCadence + ", endCadence="
                + endCadence + ", isOnEclipsingBinaryList="
                + isOnEclipsingBinaryList + ", detectedOrbitalPeriodInDays="
                + detectedOrbitalPeriodInDays + ", isPlanetACandidate="
                + isPlanetACandidate + ", maxMultipleEventStatistic="
                + maxMultipleEventStatistic + ", timeToFirstTransitInDays="
                + timeToFirstTransitInDays + ", timeOfFirstTransitInMjd="
                + timeOfFirstTransitInMjd + ", matchedFilterUsed="
                + minSingleEventStatistic + ", minMultipleEventStatistic="
                + minMultipleEventStatistic + ", timeToFirstMicrolensInDays="
                + timeToFirstMicrolensInDays + ", timeOfFirstMicrolensInMjd="
                + timeOfFirstMicrolensInMjd
                + ", detectedMicrolensOrbitalPeriodInDays="
                + detectedMicrolensOrbitalPeriodInDays + ", robustStatistic="
                + robustStatistic + "]";
        }

    }

    public SbtRetrieveTps() {
        super(REQUIRES_DATABASE, REQUIRES_FILESTORE);
    }

    public String retrieveTps(int startKeplerId, int endKeplerId)
        throws Exception {
        if (!validateDatastores()) {
            return "";
        }

        TicToc.tic("Retrieving TPS data...");

        TpsCrud tpsCrud = new TpsCrud();

        List<TpsDbResult> tpsResults = tpsCrud.retrieveTpsResult(startKeplerId,
            endKeplerId);
        TpsContainer tpsContainer = new TpsContainer(tpsResults);

        TicToc.toc();

        return makeSdf(tpsContainer, SDF_FILE_NAME);
    }

    public static void main(String[] args) throws Exception {
        SbtRetrieveTps sbt = new SbtRetrieveTps();

        int startKeplerId = 8506000;
        int endKeplerId = 8518000;
        String path = sbt.retrieveTps(startKeplerId, endKeplerId);

        System.out.println(path);
    }

}
