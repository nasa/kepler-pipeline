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

package gov.nasa.kepler.mc.fs;

import static gov.nasa.kepler.common.FcConstants.CCD_COLUMNS;
import static gov.nasa.kepler.common.FcConstants.CCD_ROWS;
import static gov.nasa.kepler.common.FcConstants.nMaskedSmear;
import static gov.nasa.kepler.common.FcConstants.validCcdModule;
import static gov.nasa.kepler.common.FcConstants.validCcdOutput;
import static gov.nasa.kepler.common.FcConstants.validColumn;
import static gov.nasa.kepler.common.FcConstants.validRow;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Abstract super-class for pixel FsIdGenerator classes (DR, Cal, PA, PDQ).
 * Contains some common code and constants needed by all FsIdGenerator classes
 * that generate FsId objects for pixel time series
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public abstract class PixelFsIdFactory {
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(PixelFsIdFactory.class);

    // Names of parsed parameters.
    public static final String CCD_MODULE = "ccdModule";
    public static final String CCD_OUTPUT = "ccdOutput";
    public static final String ROW = "row";
    public static final String COLUMN = "column";
    public static final String ROW_OR_COLUMN = "rowOrColumn";
    public static final String OFFSET = "offset";
    public static final String COLLATERAL_TYPE = "CollateralType";
    public static final String TARGET_TABLE_TYPE = "TargetType";
    public static final String CADENCE_TYPE = "CadenceType";
    public static final String TIME_SERIES_TYPE = "TimeSeriesType";
    public static final String FFI_TYPE = "FfiType";
    public static final String FILE_TIMESTAMP = "FileTimestamp";

    public static final String SEP = ":";

    /**
     * package protection to prevent instantiation while still allowing
     * sub-classes within this package
     * 
     */
    PixelFsIdFactory() {
    }

    /**
     * This method is used by sub-classes to construct the name part of the FsId
     * for a pixel time series that is addressed by table:mod:out:row:col
     * Sub-classes use this name along with their CSCI-specific namespace path
     * to construct the full FsId
     * 
     * @param path
     * @param targetTableType From gov.nasa.kepler.jdo.tad.TargetTable
     * @param ccdModule
     * @param ccdOutput
     * @param row
     * @param column
     * @return
     * @throws PipelineException
     */
    protected static FsId getPixelFsId(String path, TargetType targetTableType,
        int ccdModule, int ccdOutput, int row, int column)
        {
        return getPixelFsId(path, targetTableType, ccdModule, ccdOutput, row,
            column, SEP);
    }

    protected static FsId getPixelFsId(String path, TargetType targetTableType,
        int ccdModule, int ccdOutput, int row, int column, String sep)
        {

        validatePixelParameters(targetTableType, ccdModule, ccdOutput, row,
            column);

       // StringBuilder newPath = new StringBuilder(FsId.MAX_ID_LENGTH);
       // newPath.append(path);
        StringBuilder newPath = new StringBuilder(path);
        if (path.charAt(path.length() - 1) != '/') {
        	newPath.append('/');
        }
        newPath.append(targetTableType.shortName()).append('/')
                    .append(ccdModule).append('/')
                    .append(ccdOutput);
        
        StringBuilder s = new StringBuilder();
            s.append(row)
            .append(sep)
            .append(column);

        return new FsId(newPath.toString(), s.toString());
    }

    /**
     * @param targetTableType
     * @param ccdModule
     * @param ccdOutput
     * @param row
     * @param column
     * @throws PipelineException
     */
    protected static void validatePixelParameters(TargetType targetTableType,
        int ccdModule, int ccdOutput, int row, int column)
        {
        // validate targetTableType
        if (targetTableType == null) {
            throw new PipelineException("targetTableType must be non-null.");
        }

        // validate module
        if (!validCcdModule(ccdModule)) {
            throw new PipelineException(
                "Attempting to get a pixel GUID for an invalid module.  module="
                    + ccdModule);
        }

        // validate output
        if (!validCcdOutput(ccdOutput)) {
            throw new PipelineException(
                "Attempting to get a pixel GUID for an invalid output.  output="
                    + ccdOutput);
        }

        // validate row
        if (!validRow(row)) {
            throw new PipelineException(
                "Attempting to get a pixel GUID for an invalid row.  row="
                    + row);
        }

        // validate column
        if (!validColumn(column)) {
            throw new PipelineException(
                "Attempting to get a pixel GUID for an invalid column.  column="
                    + column);
        }
    }

    protected static void validateCollateralPixelParameters(
        CollateralType collateralType, int ccdModule, int ccdOutput,
        int rowOrColumn) {
        
        if (collateralType == null) {
            throw new PipelineException("Collateral type must not be null.");
        }

        // validate module
        if (!validCcdModule(ccdModule)) {
            throw new PipelineException(
                "Attempting to get a pixel GUID for an invalid module.  module="
                    + ccdModule);
        }

        // validate output
        if (!validCcdOutput(ccdOutput)) {
            throw new PipelineException(
                "Attempting to get a pixel GUID for an invalid output.  output="
                    + ccdOutput);
        }

        if (!collateralType.validRowOrColumnOffset(rowOrColumn)) {
            throw new PipelineException("Invalid offset " + rowOrColumn
                + " for collateral type \"" + collateralType + "\".");
        }
    }

    /**
     * Creates a regex for parsing pixel FsIds. This regex contains 5 capturing
     * groups: 1 - TargetType.shortName() 2 - module 3- output 4 - row 5 -
     * column
     * 
     * @param pathRegex
     * @param sep
     * @return
     */
    protected static String getPixelFsIdRegex(String pathRegex, String sep) {
        StringBuilder bldr = new StringBuilder(pathRegex);
        if (bldr.charAt(bldr.length() - 1) != '/') {
            bldr.append("/");
        }
        bldr.append("(");
        for (TargetType tttype : TargetType.values()) {
            bldr.append(tttype.shortName());
            bldr.append('|');
        }
        bldr.setLength(bldr.length() - 1);

        // parse module/output numbers
        bldr.append(")").append('/').append("(\\d+)").append('/').append(
            "(\\d+)").append('/');
        // parse row/column numbers.
        bldr.append("(\\d+)").append(sep).append("(\\d+)");

        return bldr.toString();
    }

    /**
     * Fills in the standard pixel stuff into a map.
     * 
     * @param values This is filled with the original pixel parameters.
     * @param matcher Where to get the original values from.
     * @param beginIndex The first index of matcher.group() to use to get the
     * pixel paramters.
     * @throws PipelineException
     */
    protected static void parsePixelFsId(Map<String, Object> values,
        Matcher matcher, int beginIndex) {

        int groupIndex = beginIndex;
        TargetType tttype = TargetType.valueOfShortName(matcher.group(groupIndex++));
        int module = Integer.parseInt(matcher.group(groupIndex++));
        int output = Integer.parseInt(matcher.group(groupIndex++));
        int row = Integer.parseInt(matcher.group(groupIndex++));
        int col = Integer.parseInt(matcher.group(groupIndex++));

        validatePixelParameters(tttype, module, output, row, col);

        values.put(TARGET_TABLE_TYPE, tttype);
        values.put(CCD_MODULE, module);
        values.put(CCD_OUTPUT, output);
        values.put(ROW, row);
        values.put(COLUMN, col);
    }

    /**
     * This method is a convenience method used by sub-classes to construct the
     * name part of the FsIds for all of the pixel time series in a Target
     * Sub-classes use this name along with their CSCI-specific namespace path
     * to construct the full FsId
     */
    protected static List<FsId> getPixelFsIdsForTarget(String path,
        ObservedTarget target) {
        // validate target
        if (target == null) {
            throw new PipelineException(
                "Attempting to get pixel GUIDs for a null target.");
        }

        TargetTable targetTable = target.getTargetTable();
        LinkedList<FsId> pixelIds = new LinkedList<FsId>();

        for (TargetDefinition targetDefinition : target.getTargetDefinitions()) {
            for (Offset aperturePixel : targetDefinition.getMask().getOffsets()) {
                // get row and column for the pixel:
                int row = targetDefinition.getReferenceRow()
                    + aperturePixel.getRow();
                int column = targetDefinition.getReferenceColumn()
                    + aperturePixel.getColumn();

                pixelIds.add(getPixelFsId(path, targetTable.getType(),
                    target.getCcdModule(), target.getCcdOutput(), row, column));
            }
        }

        return pixelIds;
    }

    /**
     * This method is used by sub-classes to construct the name part of the FsId
     * for a collateral pixel time series that is addressed by
     * type:mod:out:rowOrCol Sub-classes use this name along with their
     * CSCI-specific namespace path to construct the full FsId
     */
    protected static FsId getCollateralPixelFsId(String path,
        CollateralType collateralType, int ccdModule, int ccdOutput,
        int rowOrColumn) {
        // validate module
        if (!validCcdModule(ccdModule)) {
            throw new PipelineException(
                "Attempting to get collateral pixels for an invalid module.  module="
                    + ccdModule);
        }

        // validate output
        if (!validCcdOutput(ccdOutput)) {
            throw new PipelineException(
                "Attempting to get collateral pixels for an invalid output.  output="
                    + ccdOutput);
        }

        // validate rowOrColumn

        /*
         * TODO: Need to sit down with Jon and verify all of these constraint
         * checks. Currently, these ranges are based on ETEM output
         */
        if (collateralType == CollateralType.BLACK_LEVEL
            && (rowOrColumn < 0 || rowOrColumn >= CCD_ROWS)) {
            throw new PipelineException("Invalid row " + rowOrColumn);
        } else if (collateralType == CollateralType.MASKED_SMEAR
            && (rowOrColumn < 0 || rowOrColumn >= CCD_COLUMNS)) {
            throw new PipelineException("Invalid column " + rowOrColumn);
        } else if (collateralType == CollateralType.VIRTUAL_SMEAR
            && (rowOrColumn < 0 || rowOrColumn >= CCD_COLUMNS)) {
            throw new PipelineException("Invalid column " + rowOrColumn);
        } else if (collateralType == CollateralType.BLACK_MASKED
            && (rowOrColumn < 0 || rowOrColumn >= nMaskedSmear)) {
            throw new PipelineException("Invalid row " + rowOrColumn);
        } else if (collateralType == CollateralType.BLACK_VIRTUAL
            && (rowOrColumn < 0 || rowOrColumn >= CCD_COLUMNS)) {
            // TODO: We need to know what BlackVirtual is, and what coordinates
            // it should be able to have. Until then, it's 0 - 1131.
            throw new PipelineException("Invalid coordinate " + rowOrColumn);
        }

        StringBuilder s = new StringBuilder();
        s.append(collateralType.getName())
            .append(SEP)
            .append(ccdModule)
            .append(SEP)
            .append(ccdOutput)
            .append(SEP)
            .append(rowOrColumn);

        return new FsId(path, s.toString());
    }
}
