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
import static gov.nasa.kepler.common.FitsUtils.addDateObsKeywords;
import static gov.nasa.kepler.common.FitsUtils.safeAdd;
import gov.nasa.kepler.ar.exporter.CelestialWcsKeywordValueSource;

import java.util.List;

import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;


/**
 * Information about the a binary table structure and how to write the table
 * header.  This has many Kepler specific conventions which are used in the
 * target pixel exporter and the flux exporter.
 * 
 * @author Sean McCauliff
 *
 */
public abstract class AbstractBinaryTableHeaderFormatter {

    protected static final Int32Column cadenceColumn =
        new Int32Column(CADENCENO_TCOLUMN, CADENCENO_TCOLUMN_COMMENT, CADENCENO_TCOLUMN_HINT, null, null, null);

    protected static final Int32Column qualityColumn = 
        new Int32Column("QUALITY", "pixel quality flags", "B24.24", null, null, null);
    
    
    /**
     * 
     * @param imageDimensions A map of column type (remember this is also the name of the column)
     * to the dimensions of the image (or array or multi dimensional array).  The key "*" indicates this
     * should be used by default.
     * @return The number of bytes in a single row in the table.
     */
    public int bytesPerTableRow(ArrayDimensions imageDimensions) {
        int tableRowSize = 0;
        for (ColumnDescription colDesc : columnDescriptions()) {
            tableRowSize += colDesc.sizeOf(imageDimensions);
        }
        return tableRowSize;
    }
    
    /**
     * 
     * @param source
     * @param celesitalWcs  This may be null.
     * @param arrayDimensions the sizes of the various non-scalar columns.
     * @return
     * @throws HeaderCardException
     */
    protected Header basicBinaryTableHeader(BaseBinaryTableHeaderSource source,
        CelestialWcsKeywordValueSource celesitalWcs, ArrayDimensions arrayDimensions) throws HeaderCardException {
        Header h = new Header();
        
        int tableRowSize = bytesPerTableRow(arrayDimensions);
        
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
            column.format(h, columnIndex++, source, celesitalWcs, arrayDimensions);
            //insertColumn(h, celestialWcs, column, source, columnIndex++,nImageColumns, nImageRows);
        }
        h.addValue(INHERT_KW, INHERIT_VALUE, INHERIT_COMMENT);
        h.addValue(EXTNAME_KW, source.extensionName(), EXTNAME_COMMENT);
        h.addValue(EXTVER_KW, 1, EXTVER_COMMENT);
        
        return h;
    }
    
    protected void addBarycentricTimeKeywords(
        BarycentricTimeSource source, Header h)
        throws HeaderCardException {
        safeAdd(h, EXPOSURE_KW, source.daysOnSource(), EXPOSURE_COMMENT, EXPOSURE_FORMAT);
        h.addValue(TIMEREF_KW, TIMEREF_VALUE, TIMEREF_COMMENT);
        h.addValue(TASSIGN_KW, TASSIGN_VALUE, TASSIGN_COMMENT);
        h.addValue(TIMESYS_KW, TIMESYS_VALUE, TIMESYS_COMMENT);
        h.addValue(BJDREFI_KW, source.kbjdReferenceInt(), BJDREFI_COMMENT);
        safeAdd(h, BJDREFF_KW, source.kbjdReferenceFraction(), BJDREFF_COMMENT, BJDREFF_FORMAT);
        h.addValue(TIMEUNIT_KW, TIMEUNIT_VALUE, TIMEUNIT_COMMENT);
        safeAdd(h, TELAPSE_KW, source.elaspedTime(), TELAPSE_COMMENT, TELAPSE_FORMAT);
        safeAdd(h, LIVETIME_KW, source.liveTimeDays(), LIVETIME_COMMENT, LIVETIME_FORMAT);
        safeAdd(h, TSTART_KW, source.startKbjd(), TSTART_COMMENT, TSTART_FORMAT);
        safeAdd(h, TSTOP_KW, source.endKbjd(), TSTOP_COMMENT, TSTOP_FORMAT);
        addCommonTimeKeywords(source, h);
    }
    
    protected void addCommonTimeKeywords(CommonTimeSource source, Header h) throws HeaderCardException {
        safeAdd(h, LC_START_KW, source.startMidMjd(), LC_START_COMMENT, LC_START_FORMAT);
        safeAdd(h, LC_END_KW, source.endMidMjd(), LC_END_COMMENT, LC_END_FORMAT);
        safeAdd(h, DEADC_KW, source.deadC(), DEADC_COMMENT, DEADC_FORMAT);
        safeAdd(h, TIMEPIXR_KW, TIMEPIXR_VALUE, TIMEPIXR_COMMENT, "%.1f");
        safeAdd(h, TIERRELA_KW, TIERRELA_VALUE, TIERRELA_COMMENT, TIERRELA_FORMAT);
        safeAdd(h, TIERABSO_KW, TIERABSO_VALUE, TIERABSO_COMMENT);
    }
    
    protected void addReadoutKeywords(BaseBinaryTableHeaderSource source,
        Header h) throws HeaderCardException {
        
        safeAdd(h, INT_TIME_KW, source.photonAccumulationTimeSec(), INT_TIME_COMMENT, INT_TIME_FORMAT);
        safeAdd(h, READTIME_KW, source.readoutTimePerFrameSec(), READTIME_COMMENT, READTIME_FORMAT);
        safeAdd(h, FRAMETIM_KW, source.scienceFrameTimeSec(), FRAMETIM_COMMENT, FRAMETIM_FORMAT);
        h.addValue(NUM_FRM_KW, source.framesPerCadence(), NUM_FRM_COMMENT);
        safeAdd(h, TIMEDEL_KW, source.timeResolutionOfDataDays(), TIMEDEL_COMMENT);
        addDateObsKeywords(h, source.observationStartUTC(), source.observationEndUTC());
        h.addValue(BACKAPP_KW, source.backgroundSubtracted(), BACKAPP_COMMENT);
        h.addValue(DEADAPP_KW, DEADAPP_VALUE, DEADAPP_COMMENT);
        h.addValue(VIGNAPP_KW, VIGNAPP_VALUE, VIGNAPP_COMMENT);
        if (source.gainEPerCount() != null) {
            h.addValue(GAIN_KW, source.gainEPerCount(), GAIN_COMMENT);
        }
        if (source.readNoiseE() != null) {
            safeAdd(h,READNOIS_KW, source.readNoiseE(), READNOIS_COMMENT, READNOIS_FORMAT);
        }
        h.addValue(NREADOUT_KW, source.readsPerCadence(), NREADOUT_COMMENT);
        if (source.timeSlice() != null) {
            h.addValue(TIMSLICE_KW, source.timeSlice(), TIMSLICE_COMMENT);
        }
        if (source.meanBlackCounts() != null) {
            h.addValue(MEANBLCK_KW, source.meanBlackCounts(), MEANBLCK_COMMENT);
        }
    }
    
    /**
     * This skips adding the keywords entirely if they are undefuned.
     * @param source
     * @param h
     * @throws HeaderCardException
     */
    protected void addFixedOffsetKeywords(
        BaseBinaryTableHeaderSource source, Header h)
        throws HeaderCardException {
        
        if (source.longCadenceFixedOffset() == null) {
            return;
        }
        safeAdd(h, LCFXDOFF_KW, source.longCadenceFixedOffset(), LCFXDOFF_COMMENT, LCFXDOFF_FORMAT);
        safeAdd(h, SCFXDOFF_KW, source.shortCadenceFixedOffset(), SCFXDOFF_COMMENT, SCFXDOFF_FORMAT);
    }
     
    protected void addRollingBandKeywords(Header h, int[] rollingBandDurations, Integer dynablackColumnCutoff, Double dynablackThreshold) 
        throws HeaderCardException {
        safeAdd(h, DBCOLCO_KW, dynablackColumnCutoff, DBCOLCO_COMMENT);
        safeAdd(h, DBTHRES_KW, dynablackThreshold, DBTHRES_COMMENT);
        
        if (rollingBandDurations != null) {
            for (int i=0; i < rollingBandDurations.length; i++) {
                int duration = rollingBandDurations[i];
                safeAdd(h, String.format(RBTDUR_KW_FORMAT, i + 1), duration, String.format(RBASNAME_COMMENT, i + 1));
            }
        }
    }
    
    /**
     * The list of column descriptions for this kind of binary table export.
     * @return
     */
    protected abstract List<ColumnDescription> columnDescriptions();
    

}
