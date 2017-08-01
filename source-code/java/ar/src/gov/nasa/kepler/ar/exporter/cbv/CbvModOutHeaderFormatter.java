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

package gov.nasa.kepler.ar.exporter.cbv;

import static gov.nasa.kepler.common.FitsConstants.*;
import static gov.nasa.kepler.common.FitsUtils.safeAdd;

import java.util.List;

import com.google.common.collect.ImmutableList;

import gov.nasa.kepler.ar.exporter.binarytable.*;
import gov.nasa.kepler.common.FitsUtils;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;

/**
 * Formats the per mod/out data header.  This is the FITS header before every
 * binary data table that actually contains the co-trending basis vectors.
 * @author Sean McCauliff
 *
 */
class CbvModOutHeaderFormatter extends AbstractBinaryTableHeaderFormatter{

    private final static List<ColumnDescription> columns;
    final static int N_COTRENDING_BASIS_VECTORS = 16;
    
    static {
        ImmutableList.Builder<ColumnDescription> bldr = 
            new ImmutableList.Builder<ColumnDescription>();
        bldr.add(
            new Float64Column(MJD_TIME_TCOLUMN, MJD_TIME_TCOLUMN_COMMENT, MJD_TIME_TCOLUMN_DISPLAY_HINT, MJD_TIME_TCOLUMN_UNIT, MJD_TIME_TCOLUMN_UNIT_COMMENT));
        bldr.add(cadenceColumn);
        //bldr.add(new Int32Column("GAPFLAG", "when true cadence was gapped", "L", null, null));
        bldr.add(new Int32Column("GAPFLAG", "when true cadence was gapped", "I1", null, null, null /*null value*/));
        for (int i=1; i <= N_COTRENDING_BASIS_VECTORS; i++) {
            Float32Column cbVectorColumn =
                new Float32Column("VECTOR_" + i, "co-trending basis vector " + i,
                    "F8.5", null, null); //nulls indicate no units
            bldr.add(cbVectorColumn);
        }
        columns = bldr.build();
    }
    
    @Override
    protected List<ColumnDescription> columnDescriptions() {
        return columns;
    }
    
    /**
     * @param source
     * @return
     * @throws HeaderCardException 
     */
    Header formatHeader(CbvModOutHeaderSource source, String checksumStr) throws HeaderCardException {
        Header h = new Header();
        
        int tableRowSize = bytesPerTableRow(ArrayDimensions.newEmptyInstance());
        
        h.addValue(XTENSION_KW, XTENSION_BINTABLE_VALUE, XTENSION_COMMENT);
        h.addValue(BITPIX_KW, BITPIX_BINTABLE_VALUE, BITPIX_COMMENT);
        h.addValue(NAXIS_KW, 2, NAXIS_COMMENT);
        h.addValue(NAXIS1_KW, tableRowSize, NAXIS1_COMMENT); //number of bytes per row
        h.addValue(NAXIS2_KW, source.nBinaryTableRows(), NAXIS2_COMMENT); //number of rows
        h.addValue(PCOUNT_KW, 0, PCOUNT_COMMENT);
        h.addValue(GCOUNT_KW, 1, GCOUNT_COMMENT);
        h.addValue(TFIELDS_KW, columnDescriptions().size(), TFIELDS_COMMENT);
        int columnIndex = 1;
        for (ColumnDescription column : columnDescriptions()) {
            column.format(h, columnIndex++, null, null, ArrayDimensions.newEmptyInstance());
        }
        h.addValue(INHERT_KW, INHERIT_VALUE, INHERIT_COMMENT);
        h.addValue(EXTNAME_KW, "MODOUT_" + source.ccdModule() + "_" + source.ccdOutput(), EXTNAME_COMMENT);
        h.addValue(EXTVER_KW, 1, EXTVER_COMMENT);

        safeAdd(h, LC_START_KW, source.startMidMjd(), LC_START_COMMENT, LC_START_FORMAT);
        safeAdd(h, LC_END_KW,   source.endMidMjd(),   LC_END_COMMENT, LC_END_FORMAT);
        safeAdd(h, MODULE_KW,   source.ccdModule(),   MODULE_COMMENT);
        safeAdd(h, OUTPUT_KW,   source.ccdOutput(),   OUTPUT_COMMENT);
        safeAdd(h, CHANNEL_KW,  source.ccdChannel(),  CHANNEL_COMMENT);
        safeAdd(h, TELAPSE_KW,  source.elaspedTime(), TELAPSE_COMMENT, TELAPSE_FORMAT);
        safeAdd(h, MAPORDER_KW, source.mapOrder(),    MAPORDER_COMMENT);
        safeAdd(h, BVVER_KW, source.pdcVersion(), BVVER_COMMENT);
        FitsUtils.addChecksum(h, checksumStr, source.generatedAt());
        return h;
    }


}
