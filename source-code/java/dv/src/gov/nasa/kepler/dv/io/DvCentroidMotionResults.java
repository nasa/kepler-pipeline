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
 * Centroid motion results.
 * 
 * @author Forrest Girouard
 */
public class DvCentroidMotionResults implements Persistable {

    private DvStatistic motionDetectionStatistic = new DvStatistic();
    private DvDoubleQuantity outOfTransitCentroidRaHours = new DvDoubleQuantity();
    private DvDoubleQuantity outOfTransitCentroidDecDegrees = new DvDoubleQuantity();
    private DvQuantity peakRaOffset = new DvQuantity();
    private DvQuantity peakDecOffset = new DvQuantity();
    private DvQuantity peakOffsetArcSec = new DvQuantity();
    private DvQuantity sourceRaOffset = new DvQuantity();
    private DvQuantity sourceDecOffset = new DvQuantity();
    private DvQuantity sourceOffsetArcSec = new DvQuantity();
    private DvDoubleQuantity sourceRaHours = new DvDoubleQuantity();
    private DvDoubleQuantity sourceDecDegrees = new DvDoubleQuantity();

    /**
     * Creates a {@link DvCentroidMotionResults}. For use only by serialization,
     * mock objects and Hibernate.
     */
    public DvCentroidMotionResults() {
    }

    /**
     * Creates a new immutable {@link DvCentroidMotionResults} object.
     */
    public DvCentroidMotionResults(DvStatistic motionDetectionStatistic,
        DvDoubleQuantity outOfTransitCentroidRaHours,
        DvDoubleQuantity outOfTransitCentroidDecDegrees,
        DvQuantity sourceRaOffset, DvQuantity sourceDecOffset,
        DvQuantity sourceOffsetArcSec, DvQuantity peakRaOffset,
        DvQuantity peakDecOffset, DvQuantity peakOffsetArcSec,
        DvDoubleQuantity sourceRaHours, DvDoubleQuantity sourceDecDegrees) {

        this.motionDetectionStatistic = motionDetectionStatistic;
        this.outOfTransitCentroidRaHours = outOfTransitCentroidRaHours;
        this.outOfTransitCentroidDecDegrees = outOfTransitCentroidDecDegrees;
        this.peakRaOffset = peakRaOffset;
        this.peakDecOffset = peakDecOffset;
        this.peakOffsetArcSec = peakOffsetArcSec;
        this.sourceRaOffset = sourceRaOffset;
        this.sourceDecOffset = sourceDecOffset;
        this.sourceOffsetArcSec = sourceOffsetArcSec;
        this.sourceRaHours = sourceRaHours;
        this.sourceDecDegrees = sourceDecDegrees;
    }

    public DvStatistic getMotionDetectionStatistic() {
        return motionDetectionStatistic;
    }

    public DvDoubleQuantity getOutOfTransitCentroidRaHours() {
        return outOfTransitCentroidRaHours;
    }

    public DvDoubleQuantity getOutOfTransitCentroidDecDegrees() {
        return outOfTransitCentroidDecDegrees;
    }

    public DvQuantity getPeakRaOffset() {
        return peakRaOffset;
    }

    public DvQuantity getPeakDecOffset() {
        return peakDecOffset;
    }

    public DvQuantity getPeakOffsetArcSec() {
        return peakOffsetArcSec;
    }

    public DvQuantity getSourceRaOffset() {
        return sourceRaOffset;
    }

    public DvQuantity getSourceDecOffset() {
        return sourceDecOffset;
    }

    public DvQuantity getSourceOffsetArcSec() {
        return sourceOffsetArcSec;
    }

    public DvDoubleQuantity getSourceRaHours() {
        return sourceRaHours;
    }

    public DvDoubleQuantity getSourceDecDegrees() {
        return sourceDecDegrees;
    }
}
