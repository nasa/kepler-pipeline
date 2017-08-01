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

package gov.nasa.kepler.ar.exporter.collateral;

import gov.nasa.kepler.ar.exporter.binarytable.ArrayDimensions;
import gov.nasa.kepler.ar.exporter.binarytable.ColumnDescription;
import gov.nasa.kepler.ar.exporter.binarytable.Float32Column;
import gov.nasa.kepler.ar.exporter.binarytable.Int32Column;

import java.util.List;

import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;

import com.google.common.collect.ImmutableList;

import static gov.nasa.kepler.common.FitsConstants.BLKALGO_COMMENT;
import static gov.nasa.kepler.common.FitsConstants.BLKALGO_KW;
import static gov.nasa.kepler.common.FitsConstants.SINGLE_PRECISION_HINT;
import static gov.nasa.kepler.common.FitsUtils.safeAdd;

final class ShortCadence2DCollateralHeaderFormatter extends
    CollateralPixelBinaryTableHeaderFormatter {

    private static final List<ColumnDescription> columns = 
        ImmutableList.of(
            mjdTimeColumn,
            cadenceColumn,
            new Int32Column("BMASKED_RAW", "2d coadd of masked black", "I8", "counts", "counts", -1),
            new Float32Column("BMASKED_RES", "cosmic ray subtracted black residual", SINGLE_PRECISION_HINT, "counts/s", "counts per second"),
            new Float32Column("BMASKED_RES_ERR", "1-sigma uncertainty", SINGLE_PRECISION_HINT, "counts/s", "counts per second"),
            new Float32Column("BMASKED_CR", "cosmic ray detections", SINGLE_PRECISION_HINT, "counts/s", "counts"),
            new Int32Column("BVIRTUAL_RAW", "2d coadd of virtual black", "I8","counts", "counts", -1),
            new Float32Column("BVIRTUAL_RES", "cosmic ray subtracted black residual", SINGLE_PRECISION_HINT, "counts/s", "counts per second"),
            new Float32Column("BVIRTUAL_RES_ERR", "1-sigma uncertainty", SINGLE_PRECISION_HINT, "counts/s", "counts per second"),
            new Float32Column("BVIRTUAL_CR", "cosmic ray detections", SINGLE_PRECISION_HINT, "counts/s", "counts per second")
        );
    
    public Header formatHeader(CollateralPixelBinaryTableHeaderSource source, String checksum, ArrayDimensions arrayDimensions) throws HeaderCardException {
        Header h = super.formatHeader(source, checksum, arrayDimensions);
        String blackAlgorithm = (source.blackAlgorithm() == null) ? null : source.blackAlgorithm().pipelineName();
        safeAdd(h, BLKALGO_KW, blackAlgorithm, BLKALGO_COMMENT);
        return h;
    }
    
    @Override
    String extensionName() {
        return "SC2DCOLLATERAL";
    }

    @Override
    String pixelListExtensionName() {
        throw new UnsupportedOperationException();
    }

    @Override
    String pixelListColumnType() {
        throw new UnsupportedOperationException();
    }

    @Override
    String pixelListColumnTypeComment() {
        throw new UnsupportedOperationException();
    }

    @Override
    protected List<ColumnDescription> columnDescriptions() {
        return columns;
    }

}
