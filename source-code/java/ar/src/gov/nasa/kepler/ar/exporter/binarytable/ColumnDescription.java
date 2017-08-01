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

package gov.nasa.kepler.ar.exporter.binarytable;

import static gov.nasa.kepler.common.FitsConstants.*;
import gov.nasa.kepler.ar.exporter.CelestialWcsKeywordValueSource;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;
/**
 * This defines a FITS column in a binary table.  It's probably useful to read the
 * section in the FITS standard that deals with binary tables.
 * 
 * @author Sean McCauliff
 *
 */
public abstract class ColumnDescription {
    private final String type; //This is the value of the TTYPEn column.  Really a name.
    private final String typeComment; //This comment is appended to the comment in the TTYPEn keyword
    private final String form;
    private final String formComment;
    private final String unit;
    private final String unitComment; //This comment is appended to the comment in TUNITn
    private final String displayHint;
    private final Integer nullValue;
    private final int dimensions;
    private final int sizeOfScalar;
    
    protected ColumnDescription(String type, String typeComment,
        String form, String formComment,
        String unit, String unitComment,
        String displayHint, int dimensions, int sizeOfScalar) {

        this(type, typeComment, form, formComment, unit, unitComment, displayHint, dimensions, sizeOfScalar, null);
    }
    
    /**
     * 
     * @param type
     * @param typeComment
     * @param form
     * @param formComment
     * @param unit this may be null
     * @param unitComment this may be null
     * @param displayHint
     * @param dimensions
     * @param sizeOfScalar
     * @param nullValue this may be null
     */
    protected ColumnDescription(String type, String typeComment, String form,
        String formComment, 
        String unit, String unitComment, 
        String displayHint, int dimensions, int sizeOfScalar, Integer nullValue) {

        if (type == null) {
            throw new NullPointerException("type");
        }
        if (typeComment == null) {
            throw new NullPointerException("typeComment");
        }
        if (displayHint == null) {
            throw new NullPointerException("displayHint");
        }
        if (form == null) {
            throw new NullPointerException("form");
        }
        if (formComment == null) {
            throw new NullPointerException("formComment");
        }
        if (dimensions < 0) {
            throw new IllegalArgumentException("dimensions < 0");
        }
        if (sizeOfScalar <= 0) {
            throw new IllegalArgumentException("sizeOfScalar <= 0");
        }
        
        this.type = type;
        this.form = form;
        this.unit = unit;
        this.displayHint = displayHint;
        this.nullValue = nullValue;
        this.typeComment = typeComment;
        this.unitComment = unitComment;
        this.dimensions = dimensions;
        this.formComment = formComment;
        this.sizeOfScalar = sizeOfScalar;
    }
    
    /**
     * 
     * @param h
     * @param i index of this column in the binary table
     * @param source This may be null, but must be defined if this column type
     * requires WCS coordinates.
     * @param celestialWcs This may be null, but must be defined if this column
     * type requires celestial WCS coordinates.
     * @param imageDimensions This may be null or the empty list (prefered).
     * Otherwise this must be the dimensions of the non-scalar value stored in
     * each column cell.
     * @throws HeaderCardException
     */
    public void format(Header h, int i, 
        BaseBinaryTableHeaderSource source, 
        CelestialWcsKeywordValueSource celestialWcs, 
        ArrayDimensions imageDimensions)
    throws HeaderCardException {

        h.addValue("TTYPE"+i, type, "column title: " + typeComment);
        h.addValue(TFORM_KW+i, fitsForm(imageDimensions), "column format: " + formComment);
        if (unit != null) {
            h.addValue("TUNIT"+i, unit, "column units: " + unitComment);
        }
        h.addValue("TDISP"+i, displayHint, "column display format");
        if (dimensions > 0) {
            h.addValue("TDIM"+i, dimensionKeywordValue(imageDimensions),
                "column dimensions: pixel aperture array");
        }
        if (nullValue != null) {
            h.addValue("TNULL"+i, nullValue, "column null value indicator");
        }

        addImageColumnWcs(h, source, celestialWcs, i);
    }
    
    /**
     * This should go in the TFORM keyword values.
     * @param dimensionSizes This may be null or zero length if all the columns
     * in the binary data table store scalar values in each table cell.
     * @return
     */
    private String fitsForm(ArrayDimensions dimensionSizes) {
        if (dimensions == 0) {
            return form;
        }
        StringBuilder bldr = new StringBuilder();
        int columnSize = sizeOf(dimensionSizes) / sizeOfScalar;
        bldr.append(columnSize);
        bldr.append(form);
        return bldr.toString();
    }
    
    /**  This is really only useful for non-scalar column types.  This is the
     * value for TDIMn
     */
    private String dimensionKeywordValue(ArrayDimensions arrayDimensions) {
        StringBuilder bldr = new StringBuilder();
        bldr.append('(');
        Integer[] dimensionSizes = arrayDimensions.dimensions(type);
        for (int dimSize : dimensionSizes) {
            bldr.append(dimSize).append(',');
        }
        bldr.setLength(bldr.length() - 1);
        bldr.append(')');
        
        return bldr.toString();
    }
    
    /**
     * 
     * @param dimensionSizes An variable number of integers.  
     * @return the number of bytes an element of this column will occupy in a
     *  FITS binary table row.
     */
    public int sizeOf(ArrayDimensions arrayDimensions) {
        int columnSize = 1;
        int actualDimensionCount = 0;
        for (Integer dimensionSize : arrayDimensions.dimensions(type)) {
            if (actualDimensionCount >= dimensions) {
                break;
            }
            columnSize *= dimensionSize;
            actualDimensionCount++;
        }
        return columnSize * sizeOfScalar;
    }

    
    /**
     * Override to provide per column WCS.
     */
    protected void addImageColumnWcs(Header h,
        BaseBinaryTableHeaderSource source,
        CelestialWcsKeywordValueSource celestialWcs, int i)
        throws HeaderCardException {

        //This does nothing.
    }
    
    @Override
    public String toString() {
        return getClass().getSimpleName() + " " + type;
    }
}