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
 * 
 * @author Forrest Girouard
 */
public class DvMqCentroidOffsets implements Persistable {

    private DvQuantity meanDecOffset = new DvQuantity();
    private DvQuantity meanRaOffset = new DvQuantity();
    private DvQuantity meanSkyOffset = new DvQuantity();
    private DvQuantity singleFitDecOffset = new DvQuantity();
    private DvQuantity singleFitRaOffset = new DvQuantity();
    private DvQuantity singleFitSkyOffset = new DvQuantity();

    /**
     * Creates a {@link DvMqCentroidResults}. For use only by serialization,
     * mock objects, and Hibernate.
     */
    public DvMqCentroidOffsets() {
    }

    /**
     * Creates a new immutable {@link DvMqCentroidResults} object.
     */
    public DvMqCentroidOffsets(DvQuantity meanDecOffset,
        DvQuantity meanRaOffset, DvQuantity meanSkyOffset,
        DvQuantity singleFitDecOffset, DvQuantity singleFitRaOffset,
        DvQuantity singleFitSkyOffset) {
        this.meanDecOffset = meanDecOffset;
        this.meanRaOffset = meanRaOffset;
        this.meanSkyOffset = meanSkyOffset;
        this.singleFitDecOffset = singleFitDecOffset;
        this.singleFitRaOffset = singleFitRaOffset;
        this.singleFitSkyOffset = singleFitSkyOffset;
    }

    public DvQuantity getMeanDecOffset() {
        return meanDecOffset;
    }

    public DvQuantity getMeanRaOffset() {
        return meanRaOffset;
    }

    public DvQuantity getMeanSkyOffset() {
        return meanSkyOffset;
    }

    public DvQuantity getSingleFitDecOffset() {
        return singleFitDecOffset;
    }

    public DvQuantity getSingleFitRaOffset() {
        return singleFitRaOffset;
    }

    public DvQuantity getSingleFitSkyOffset() {
        return singleFitSkyOffset;
    }
}
