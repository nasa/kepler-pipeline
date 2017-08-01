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
import gov.nasa.kepler.ar.exporter.binarytable.ByteImageColumn;
import gov.nasa.kepler.ar.exporter.binarytable.ColumnDescription;
import gov.nasa.kepler.ar.exporter.binarytable.Float32ArrayColumn;
import gov.nasa.kepler.ar.exporter.binarytable.Float32ImageColumn;
import gov.nasa.kepler.ar.exporter.binarytable.Int32ArrayColumn;

import java.util.List;

import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;

import com.google.common.collect.ImmutableList;

import static gov.nasa.kepler.common.FitsConstants.*;
import static gov.nasa.kepler.common.FitsUtils.safeAdd;



/**
 * This formats the black collateral header, this does not include the 2D coadded
 * regions that exist for short cadence.
 * 
 * @author Sean McCauliff
 *
 */

final class BlackCollateralHeaderFormatter extends CollateralPixelBinaryTableHeaderFormatter {

    private final List<ColumnDescription> columns;
    
    BlackCollateralHeaderFormatter() {
        columns = ImmutableList.of(
            mjdTimeColumn,
            cadenceColumn,
            new Int32ArrayColumn("BLACK_RAW", "raw black counts", "I8", "counts", "digital numbers", -1),
            new Float32ArrayColumn("BLACK_RES", "black residuals", SINGLE_PRECISION_HINT, "counts", "digital numbers per sec"),
            new Float32ArrayColumn("BLACK_RES_ERR", "1-sigma residual uncertainty", SINGLE_PRECISION_HINT,  "counts", "digital numbers per sec"),
            new Float32ArrayColumn("BLACK_CR", "black cosmic ray detections", SINGLE_PRECISION_HINT, "counts", "digital numbers per sec"),
            new Float32ImageColumn(RB_LEVEL_TCOLUMN, RB_LEVEL_TCOLUMN_COMMENT, SINGLE_PRECISION_HINT, RB_LEVEL_TCOLUMN_UNIT, RB_LEVEL_TCOLUMN_UNIT_COMMENT),
            new ByteImageColumn(RB_FLAG_TCOLUMN, RB_FLAG_TCOLUMN_COMMENT, null /*unit*/, null/*unit comment*/, "B2.2", null)  
         );
    }
    
    @Override
    public Header formatHeader(CollateralPixelBinaryTableHeaderSource source, String checksum, ArrayDimensions arrayDimensions) throws HeaderCardException {
        Header h = super.formatHeader(source, checksum, arrayDimensions);
        
        addRollingBandKeywords(h, source.rollingBandDurations(), source.dynablackColumnCutoff(), source.dynablackThreshold());
        String blackAlgorithm = (source.blackAlgorithm() == null) ? null : source.blackAlgorithm().pipelineName();
        safeAdd(h, BLKALGO_KW, blackAlgorithm, BLKALGO_COMMENT);
        return h;
    }
    
    @Override
    protected List<ColumnDescription> columnDescriptions() {
        return columns;
    }


    @Override
    String extensionName() {
        return "BLACK";
    }


    @Override
    String pixelListExtensionName() {
        return "BLACKPIXELLIST";
    }


    @Override
    String pixelListColumnType() {
        return "BLACKROW";
    }


    @Override
    String pixelListColumnTypeComment() {
        return "CCD row of black collateral";
    }

}
