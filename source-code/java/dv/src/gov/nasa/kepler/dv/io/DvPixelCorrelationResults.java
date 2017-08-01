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

import java.util.ArrayList;
import java.util.List;

/**
 * Pixel correlation results consisting of a single statistic per pixel.
 * 
 * @author Forrest Girouard
 */
public class DvPixelCorrelationResults extends DvAbstractTargetTableData {

    private DvCentroidOffsets controlCentroidOffsets;
    private DvImageCentroid controlImageCentroid;
    private DvImageCentroid correlationImageCentroid;
    private DvCentroidOffsets kicCentroidOffsets;
    private DvImageCentroid kicReferenceCentroid;

    private List<DvPixelStatistic> pixelCorrelationStatisticStruct = new ArrayList<DvPixelStatistic>();

    public DvPixelCorrelationResults() {
    }

    /**
     * Creates a new immutable {@link DvPixelCorrelationResults} object.
     */
    public DvPixelCorrelationResults(Builder builder) {

        super(builder);
        controlCentroidOffsets = builder.controlCentroidOffsets;
        controlImageCentroid = builder.controlImageCentroid;
        correlationImageCentroid = builder.correlationImageCentroid;
        kicCentroidOffsets = builder.kicCentroidOffsets;
        kicReferenceCentroid = builder.kicReferenceCentroid;
        pixelCorrelationStatisticStruct = builder.pixelCorrelationStatistics;
    }

    /**
     * Used to construct an immutable {@link DvPixelCorrelationResults} object.
     * To use this class, a {@link Builder} object is created and then non-null
     * fields are set using the available builder methods. Finally, a
     * {@link DvPixelCorrelationResults} object is created using the
     * {@code build} method. For example:
     * 
     * <pre>
     * DvPixelCorrelationResults pixelCorrelationResults = new DvPixelCorrelationResults.Builder().controlCentroidOffsets(
     *     controlCentroidOffsets)
     *     .kicReferenceCentroid(kicReferenceCentroid)
     *     .build();
     * </pre>
     * 
     * This pattern is based upon <a href=
     * "http://developers.sun.com/learning/javaoneonline/2006/coreplatform/TS-1512.pdf"
     * > Josh Bloch's JavaOne 2006 talk, Effective Java Reloaded, TS-1512</a>.
     * 
     * @author Forrest Girouard
     */
    public static class Builder extends DvAbstractTargetTableData.Builder {

        private DvCentroidOffsets controlCentroidOffsets;
        private DvImageCentroid controlImageCentroid;
        private DvImageCentroid correlationImageCentroid;
        private DvCentroidOffsets kicCentroidOffsets;
        private DvImageCentroid kicReferenceCentroid;
        private List<DvPixelStatistic> pixelCorrelationStatistics;

        public Builder(int targetTableId) {
            super(targetTableId);
        }

        @Override
        public Builder ccdModule(int ccdModule) {
            super.ccdModule(ccdModule);
            return this;
        }

        @Override
        public Builder ccdOutput(int ccdOutput) {
            super.ccdOutput(ccdOutput);
            return this;
        }

        @Override
        public Builder quarter(int quarter) {
            super.quarter(quarter);
            return this;
        }

        @Override
        public Builder startCadence(int startCadence) {
            super.startCadence(startCadence);
            return this;
        }

        @Override
        public Builder endCadence(int endCadence) {
            super.endCadence(endCadence);
            return this;
        }

        public Builder controlCentroidOffsets(
            DvCentroidOffsets controlCentroidOffsets) {
            this.controlCentroidOffsets = controlCentroidOffsets;
            return this;
        }

        public Builder controlImageCentroid(DvImageCentroid controlImageCentroid) {
            this.controlImageCentroid = controlImageCentroid;
            return this;
        }

        public Builder correlationImageCentroid(
            DvImageCentroid correlationImageCentroid) {
            this.correlationImageCentroid = correlationImageCentroid;
            return this;
        }

        public Builder kicCentroidOffsets(DvCentroidOffsets kicCentroidOffsets) {
            this.kicCentroidOffsets = kicCentroidOffsets;
            return this;
        }

        public Builder kicReferenceCentroid(DvImageCentroid kicReferenceCentroid) {
            this.kicReferenceCentroid = kicReferenceCentroid;
            return this;
        }

        public Builder pixelCorrelationStatistics(
            List<DvPixelStatistic> pixelCorrelationStatistics) {
            this.pixelCorrelationStatistics = pixelCorrelationStatistics;
            return this;
        }

        public DvPixelCorrelationResults build() {
            return new DvPixelCorrelationResults(this);
        }
    }

    public DvCentroidOffsets getControlCentroidOffsets() {
        return controlCentroidOffsets;
    }

    public DvImageCentroid getControlImageCentroid() {
        return controlImageCentroid;
    }

    public DvImageCentroid getCorrelationImageCentroid() {
        return correlationImageCentroid;
    }

    public DvCentroidOffsets getKicCentroidOffsets() {
        return kicCentroidOffsets;
    }

    public DvImageCentroid getKicReferenceCentroid() {
        return kicReferenceCentroid;
    }

    public List<DvPixelStatistic> getPixelCorrelationStatistics() {
        return pixelCorrelationStatisticStruct;
    }
}
