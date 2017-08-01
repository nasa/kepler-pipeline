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
 * A difference image result consisting of various flux values and differences
 * for a single pixel.
 * 
 * @author Bill Wohler
 */
public class DvDifferenceImagePixelData implements Persistable {

    private int ccdRow;
    private int ccdColumn;
    private DvQuantity meanFluxInTransit;
    private DvQuantity meanFluxOutOfTransit;
    private DvQuantity meanFluxDifference;
    private DvQuantity meanFluxForTargetTable;

    /**
     * Creates a {@link DvDifferenceImagePixelData} object. For use only by
     * serialization and mock objects.
     */
    public DvDifferenceImagePixelData() {
    }

    public DvDifferenceImagePixelData(int ccdRow, int ccdColumn,
        DvQuantity meanFluxInTransit, DvQuantity meanFluxOutOfTransit,
        DvQuantity meanFluxDifference, DvQuantity meanFluxForTargetTable) {
        this.ccdRow = ccdRow;
        this.ccdColumn = ccdColumn;
        this.meanFluxInTransit = meanFluxInTransit;
        this.meanFluxOutOfTransit = meanFluxOutOfTransit;
        this.meanFluxDifference = meanFluxDifference;
        this.meanFluxForTargetTable = meanFluxForTargetTable;
    }

    public int getCcdRow() {
        return ccdRow;
    }

    public int getCcdColumn() {
        return ccdColumn;
    }

    public DvQuantity getMeanFluxInTransit() {
        return meanFluxInTransit;
    }

    public DvQuantity getMeanFluxOutOfTransit() {
        return meanFluxOutOfTransit;
    }

    public DvQuantity getMeanFluxDifference() {
        return meanFluxDifference;
    }

    public DvQuantity getMeanFluxForTargetTable() {
        return meanFluxForTargetTable;
    }
}
