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

package gov.nasa.kepler.dv.io;

import gov.nasa.spiffy.common.persistable.Persistable;

/**
 * Eclipsing binary discrimination statistics.
 * 
 * @author Forrest Girouard
 */
public class DvBinaryDiscriminationResults implements Persistable {

    private DvPlanetStatistic longerPeriodComparisonStatistic = new DvPlanetStatistic();

    private DvStatistic oddEvenTransitDepthComparisonStatistic = new DvStatistic();

    private DvStatistic oddEvenTransitEpochComparisonStatistic = new DvStatistic();

    private DvPlanetStatistic shorterPeriodComparisonStatistic = new DvPlanetStatistic();

    private DvStatistic singleTransitDepthComparisonStatistic = new DvStatistic();

    private DvStatistic singleTransitDurationComparisonStatistic = new DvStatistic();

    private DvStatistic singleTransitEpochComparisonStatistic = new DvStatistic();

    /**
     * Creates a {@link DvBinaryDiscriminationResults}. For use only by
     * serialization, mock objects, and Hibernate.
     */
    public DvBinaryDiscriminationResults() {
    }

    /**
     * Creates a new immutable {@link DvBinaryDiscriminationResults} from the
     * given {@link Builder} object.
     */
    protected DvBinaryDiscriminationResults(Builder builder) {

        longerPeriodComparisonStatistic = builder.longerPeriodComparisonStatistic;
        oddEvenTransitDepthComparisonStatistic = builder.oddEvenTransitDepthComparisonStatistic;
        oddEvenTransitEpochComparisonStatistic = builder.oddEvenTransitEpochComparisonStatistic;
        shorterPeriodComparisonStatistic = builder.shorterPeriodComparisonStatistic;
        singleTransitDepthComparisonStatistic = builder.singleTransitDepthComparisonStatistic;
        singleTransitDurationComparisonStatistic = builder.singleTransitDurationComparisonStatistic;
        singleTransitEpochComparisonStatistic = builder.singleTransitEpochComparisonStatistic;
    }

    /**
     * Used to construct a {@link DvBinaryDiscriminationResults} object. To use
     * this class, a {@link Builder} object is created and then non-null fields
     * are set using the available builder methods. Finally, a
     * {@link DvBinaryDiscriminationResults} object is created using the
     * {@code build} method. For example:
     * 
     * <pre>
     * DvBinaryDiscriminationResults binaryDiscriminationResults = new DvBinaryDiscriminationResults.Builder().shorterPeriodComparisonStatistic(
     *     shorterComparisonStat)
     *     .longerPeriodComparisonStatistic(longerComparisonStat)
     *     .build();
     * </pre>
     * 
     * This pattern is based upon <a href=
     * "http://developers.sun.com/learning/javaoneonline/2006/coreplatform/TS-1512.pdf"
     * > Josh Bloch's JavaOne 2006 talk, Effective Java Reloaded, TS-1512</a>.
     * 
     * @author Forrest Girouard
     */
    public static class Builder {

        private DvPlanetStatistic longerPeriodComparisonStatistic = new DvPlanetStatistic();
        private DvStatistic oddEvenTransitDepthComparisonStatistic = new DvStatistic();
        private DvStatistic oddEvenTransitEpochComparisonStatistic = new DvStatistic();
        private DvPlanetStatistic shorterPeriodComparisonStatistic = new DvPlanetStatistic();
        private DvStatistic singleTransitDepthComparisonStatistic = new DvStatistic();
        private DvStatistic singleTransitDurationComparisonStatistic = new DvStatistic();
        private DvStatistic singleTransitEpochComparisonStatistic = new DvStatistic();

        public Builder() {
        }

        public Builder shorterPeriodComparisonStatistic(
            DvPlanetStatistic shorterPeriodComparisonStatistic) {
            this.shorterPeriodComparisonStatistic = shorterPeriodComparisonStatistic;
            return this;
        }

        public Builder longerPeriodComparisonStatistic(
            DvPlanetStatistic longerPeriodComparisonStatistic) {
            this.longerPeriodComparisonStatistic = longerPeriodComparisonStatistic;
            return this;
        }

        public Builder oddEvenTransitDepthComparisonStatistic(
            DvStatistic oddEvenTransitDepthComparisonStatistic) {
            this.oddEvenTransitDepthComparisonStatistic = oddEvenTransitDepthComparisonStatistic;
            return this;
        }

        public Builder oddEvenTransitEpochComparisonStatistic(
            DvStatistic oddEvenTransitEpochComparisonStatistic) {
            this.oddEvenTransitEpochComparisonStatistic = oddEvenTransitEpochComparisonStatistic;
            return this;
        }

        public Builder singleTransitDepthComparisonStatistic(
            DvStatistic singleTransitDepthComparisonStatistic) {
            this.singleTransitDepthComparisonStatistic = singleTransitDepthComparisonStatistic;
            return this;
        }

        public Builder singleTransitDurationComparisonStatistic(
            DvStatistic singleTransitDurationComparisonStatistic) {
            this.singleTransitDurationComparisonStatistic = singleTransitDurationComparisonStatistic;
            return this;
        }

        public Builder singleTransitEpochComparisonStatistic(
            DvStatistic singleTransitEpochComparisonStatistic) {
            this.singleTransitEpochComparisonStatistic = singleTransitEpochComparisonStatistic;
            return this;
        }

        public DvBinaryDiscriminationResults build() {
            return new DvBinaryDiscriminationResults(this);
        }
    }

    public DvPlanetStatistic getLongerPeriodComparisonStatistic() {
        return longerPeriodComparisonStatistic;
    }

    public DvStatistic getOddEvenTransitDepthComparisonStatistic() {
        return oddEvenTransitDepthComparisonStatistic;
    }

    public DvStatistic getOddEvenTransitEpochComparisonStatistic() {
        return oddEvenTransitEpochComparisonStatistic;
    }

    public DvPlanetStatistic getShorterPeriodComparisonStatistic() {
        return shorterPeriodComparisonStatistic;
    }

    public DvStatistic getSingleTransitDepthComparisonStatistic() {
        return singleTransitDepthComparisonStatistic;
    }

    public DvStatistic getSingleTransitDurationComparisonStatistic() {
        return singleTransitDurationComparisonStatistic;
    }

    public DvStatistic getSingleTransitEpochComparisonStatistic() {
        return singleTransitEpochComparisonStatistic;
    }
}
