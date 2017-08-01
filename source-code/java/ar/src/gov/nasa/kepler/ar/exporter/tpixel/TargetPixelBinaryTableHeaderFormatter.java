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

package gov.nasa.kepler.ar.exporter.tpixel;

import static gov.nasa.kepler.common.FitsConstants.*;
import static gov.nasa.kepler.common.FitsUtils.*;
import gov.nasa.kepler.ar.exporter.CelestialWcsKeywordValueSource;
import gov.nasa.kepler.ar.exporter.binarytable.AbstractTargetBinaryTableHeaderFormatter;
import gov.nasa.kepler.ar.exporter.binarytable.ArrayDimensions;
import gov.nasa.kepler.ar.exporter.binarytable.BaseBinaryTableHeaderSource;
import gov.nasa.kepler.ar.exporter.binarytable.ColumnDescription;
import gov.nasa.kepler.ar.exporter.binarytable.Float32Column;
import gov.nasa.kepler.ar.exporter.binarytable.Float32ImageColumn;
import gov.nasa.kepler.ar.exporter.binarytable.Float64Column;
import gov.nasa.kepler.ar.exporter.binarytable.Int32ImageColumn;
import gov.nasa.kepler.ar.exporter.tpixel.TargetPixelHeaderSource;

import java.util.List;

import com.google.common.collect.ImmutableList;

import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;

/**
 * Creates the header for the target pixel file's binary table header where we
 * store the pixel image data.
 * 
 * @author Sean McCauliff
 *
 */
final class TargetPixelBinaryTableHeaderFormatter 
    extends AbstractTargetBinaryTableHeaderFormatter {

    /**
     * 
     * @param h header non-null
     * @param baseSource non-null
     * @param celestialWcs This may be null in which case these keywords will
     * not appear in the final file.
     * @param i binary table column index number
     * @throws HeaderCardException
     */
    private static void addImageColumnWcs(Header h,
        BaseBinaryTableHeaderSource baseSource, 
        CelestialWcsKeywordValueSource celestialWcs, int i) 
    throws HeaderCardException {
        
        TargetPixelHeaderSource source = (TargetPixelHeaderSource) baseSource;
        safeAdd(h,"WCSN"+i+"P", "PHYSICAL", "table column WCS name");
        safeAdd(h,"WCAX"+i+"P", 2, "table column physical WCS dimensions");
        safeAdd(h,"1CTY" + i + "P", WCS_PHYSICAL_CCD_COL_TYPE, "table column physical WCS axis 1 type, CCD col");
        safeAdd(h,"2CTY" + i + "P", WCS_PHYSICAL_CCD_ROW_TYPE, "table column physical WCS axis 2 type, CCD row");
        safeAdd(h,"1CUN" + i + "P", "PIXEL", "table column physical WCS axis 1 unit");
        safeAdd(h,"2CUN" + i + "P", "PIXEL", "table column physical WCS axis 2 unit");
        safeAdd(h,"1CRV" + i + "P", source.referenceColumn(), "table column physical WCS ax 1 ref value");
        safeAdd(h,"2CRV" + i + "P", source.referenceRow(), "table column physical WCS ax 2 ref value");
        safeAdd(h,"1CDL" + i + "P", 1.0, "table column physical WCS a1 step");
        safeAdd(h,"2CDL" + i + "P", 1.0, "table column physical WCS a2 step");
        safeAdd(h,"1CRP" + i + "P", 1, "table column physical WCS a1 reference");
        safeAdd(h,"2CRP" + i + "P", 1, "table column physical WCS a2 reference");
        
        safeAdd(h,"WCAX"+i, 2, "number of WCS axes");
        safeAdd(h,"1CTYP"+i,"RA---TAN", "right ascension coordinate type");
        safeAdd(h,"2CTYP"+i,"DEC--TAN", "declination coordinate type");
        safeAdd(h,"1CRPX"+i, celestialWcs.referencePixelColumn(), "[pixel] reference pixel along image axis 1");
        safeAdd(h,"2CRPX"+i, celestialWcs.referencePixelRow(), "[pixel] reference pixel along image axis 2");
        safeAdd(h,"1CRVL"+i, source.raDegrees(), "[deg] right ascension at reference pixel");
        safeAdd(h,"2CRVL"+i, source.decDegrees(), "[deg] declination at reference pixel");
        safeAdd(h,"1CUNI"+i, "deg", "physical unit in column dimension");
        safeAdd(h,"2CUNI"+i, "deg", "physical unit in row dimension");
        safeAdd(h,"1CDLT"+i, celestialWcs.raScale(), "[deg] pixel scale in RA dimension");
        safeAdd(h,"2CDLT"+i, celestialWcs.decScale(), "[deg] pixel scale in DEC dimension");
        
        Double[][] xMatrix = celestialWcs.transformationMatrix();
        safeAdd(h,"11PC"+i, xMatrix[0][0], "linear transformation matrix element cos(th)" );
        safeAdd(h,"12PC"+i, xMatrix[0][1], "linear transformation matrix element -sin(th)");
        safeAdd(h,"21PC"+i, xMatrix[1][0], "linear transformation matrix element sin(th)");
        safeAdd(h,"22PC"+i, xMatrix[1][1], "linear transformation matrix element cos(th)");
    }

    private static final class Float32TargetImageColumn extends Float32ImageColumn {

        public Float32TargetImageColumn(String type, String typeComment,
            String displayHint, String unit, String unitComment) {
            super(type, typeComment, displayHint, unit, unitComment);
        }
        
        @Override
        protected void addImageColumnWcs(Header h,
            BaseBinaryTableHeaderSource baseSource, 
            CelestialWcsKeywordValueSource celestialWcs, int i) throws HeaderCardException {
            
            TargetPixelBinaryTableHeaderFormatter.addImageColumnWcs(h, baseSource, celestialWcs, i);
        }
    }
    
    private static final class Int32TargetImageColumn extends Int32ImageColumn {

        public Int32TargetImageColumn(String type, String typeComment,
            String displayHint, String unit, String unitComment) {
            super(type, typeComment, displayHint, unit, unitComment, -1);
        }

        @Override
        protected void addImageColumnWcs(Header h,
            BaseBinaryTableHeaderSource baseSource, 
            CelestialWcsKeywordValueSource celestialWcs, int i) throws HeaderCardException {
            
            TargetPixelBinaryTableHeaderFormatter.addImageColumnWcs(h, baseSource, celestialWcs, i);
        }
    }
    
    
    private static final List<ColumnDescription> binaryTableColumns =
        ImmutableList.of(
            new Float64Column(TIME_TCOLUMN, TIME_TCOLUMN_COMMENT, TIME_TCOLUMN_DISPLAY_HINT, TIME_TCOLUMN_UNIT, TIME_TCOLUMN_UNIT_COMMENT),
            new Float32Column("TIMECORR", "barycenter - timeslice correction", SINGLE_PRECISION_HINT, "d", "day"),
            cadenceColumn,
            new Int32TargetImageColumn("RAW_CNTS", "raw pixel counts", "I8", "count", "count"),
            new Float32TargetImageColumn("FLUX", "calibrated pixel flux", SINGLE_PRECISION_HINT, "e-/s", "electrons per second" ),
            new Float32TargetImageColumn("FLUX_ERR", "1-sigma calibrated uncertainty", SINGLE_PRECISION_HINT, "e-/s", "electrons per second (1-sigma)"),
            new Float32TargetImageColumn("FLUX_BKG", "calibrated background flux", SINGLE_PRECISION_HINT, "e-/s", "electrons per second"),
            new Float32TargetImageColumn("FLUX_BKG_ERR", "1-sigma cal. background uncertainty", SINGLE_PRECISION_HINT, "e-/s", "electrons per second (1-sigma)"), 
            new Float32TargetImageColumn("COSMIC_RAYS", "cosmic ray detections", SINGLE_PRECISION_HINT, "e-/s", "electrons per second"),
            qualityColumn,
            new Float32Column(POSCORR1, POSCORR1_COMMENT, SINGLE_PRECISION_HINT, "pixel", "pixel"),
            new Float32Column(POSCORR2, POSCORR2_COMMENT, SINGLE_PRECISION_HINT, "pixel", "pixel"),
            new Float32ImageColumn(RB_LEVEL_TCOLUMN, RB_LEVEL_TCOLUMN_COMMENT, SINGLE_PRECISION_HINT, RB_LEVEL_TCOLUMN_UNIT, RB_LEVEL_TCOLUMN_UNIT_COMMENT)
        );
            
    
    public Header formatHeader(TargetPixelHeaderSource source, 
        CelestialWcsKeywordValueSource celestialWcs, String checksum, ArrayDimensions arrayDimensions) throws HeaderCardException {

        Header h = super.formatHeader(source, celestialWcs, arrayDimensions);
        
        addRollingBandKeywords(h, source.rollingBandDurations(), source.dynablackColumnCutoff(), source.dynablackThreshold());
        
        String blackAlgorithm = (source.blackAlgorithm() == null) ? null : source.blackAlgorithm().pipelineName();
        safeAdd(h, BLKALGO_KW, blackAlgorithm, BLKALGO_COMMENT);
        
        addChecksum(h, checksum, source.generatedAt());
        return h;

    }  
    
    @Override
    protected List<ColumnDescription> columnDescriptions() {
        return binaryTableColumns;
    }
  

}
