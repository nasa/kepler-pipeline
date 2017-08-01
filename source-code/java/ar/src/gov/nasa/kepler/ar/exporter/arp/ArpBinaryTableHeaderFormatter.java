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

package gov.nasa.kepler.ar.exporter.arp;

import static gov.nasa.kepler.common.FitsConstants.*;
import static gov.nasa.kepler.common.FitsUtils.addChecksum;

import java.util.List;

import nom.tam.fits.FitsException;
import nom.tam.fits.Header;

import com.google.common.collect.ImmutableList;

import gov.nasa.kepler.ar.exporter.binarytable.AbstractBinaryTableHeaderFormatter;
import gov.nasa.kepler.ar.exporter.binarytable.ArrayDimensions;
import gov.nasa.kepler.ar.exporter.binarytable.ColumnDescription;
import gov.nasa.kepler.ar.exporter.binarytable.Float32ArrayColumn;
import gov.nasa.kepler.ar.exporter.binarytable.Float64Column;
import gov.nasa.kepler.ar.exporter.binarytable.Int32ArrayColumn;

final class ArpBinaryTableHeaderFormatter extends
    AbstractBinaryTableHeaderFormatter {


    @Override
    protected List<ColumnDescription> columnDescriptions() {
        return ImmutableList.of(
            new Float64Column(MJD_TIME_TCOLUMN, MJD_TIME_TCOLUMN_COMMENT, MJD_TIME_TCOLUMN_DISPLAY_HINT, MJD_TIME_TCOLUMN_UNIT, MJD_TIME_TCOLUMN_UNIT_COMMENT), 
            cadenceColumn,
            new Int32ArrayColumn("RAW_CNTS", "unprocessed pixel values", "I10", "counts", "counts", -1),
            new Float32ArrayColumn("FLUX", "calibrated pixel flux", SINGLE_PRECISION_HINT, "e-/s", "electrons per second"),
            new Float32ArrayColumn("FLUX_ERR", "1-sigma uncertainty", SINGLE_PRECISION_HINT, "e-/s", "electrons per second"),
            new Float32ArrayColumn("COSMIC_RAYS", "cosmic rays", SINGLE_PRECISION_HINT, "e-/s", "electrons per second"),
            qualityColumn);
           
    }
    
    public Header formatHeader(ArpBinaryTableHeaderSource source, ArrayDimensions arrayDims, String checksum) throws FitsException {
        Header h = super.basicBinaryTableHeader(source, null, arrayDims);
        addCommonTimeKeywords(source, h);
        addReadoutKeywords(source, h);
        addChecksum(h, checksum, source.generatedAt());
        return h;
    }

}
