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

package gov.nasa.kepler.ar.exporter.dv;

import static gov.nasa.kepler.common.FitsConstants.*;
import static gov.nasa.kepler.common.FitsUtils.addChecksum;
import static gov.nasa.kepler.common.FitsUtils.safeAdd;

import java.util.List;

import com.google.common.collect.ImmutableList;

import gov.nasa.kepler.ar.exporter.binarytable.AbstractTargetBinaryTableHeaderFormatter;
import gov.nasa.kepler.ar.exporter.binarytable.ArrayDimensions;
import gov.nasa.kepler.ar.exporter.binarytable.BaseTargetBinaryTableHeaderSource;
import gov.nasa.kepler.ar.exporter.binarytable.ColumnDescription;
import gov.nasa.kepler.ar.exporter.binarytable.Float64Column;
import gov.nasa.kepler.ar.exporter.binarytable.Float32Column;
import gov.nasa.kepler.ar.exporter.dv.DvTceMetadata;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;

/**
 * A TCE HDU's header can appropriately be formatted using nom.tam.fits. This
 * class accomplishes that. This is a View part of the Model-View-Controller
 * pattern,
 * 
 * @author lbrownst
 */
public final class DvTceHeaderFormatter extends AbstractTargetBinaryTableHeaderFormatter {
    
    /** Descriptions of the table columns. */
    private static final List<ColumnDescription> COLUMN_DESCRIPTIONS =
        ImmutableList.of
        (
            // Type: "TIME (BKJD)"
            // Comment: "Time in BKJD"
            new Float64Column(TIME_TCOLUMN,  TIME_TCOLUMN_COMMENT, TIME_TCOLUMN_DISPLAY_HINT, TIME_TCOLUMN_UNIT, TIME_TCOLUMN_UNIT_COMMENT),
            new Float32Column("TIMECORR",    "Barycenter correction applied to time", "E13.6", "d", "day"),
            // Comment: "Cadence Numbers"
            cadenceColumn,
            new Float32Column("PHASE",       "Phase using period and epoch", SINGLE_PRECISION_HINT, "days", "[-0.25*period, 0.75*period]"),
            new Float32Column("LC_INIT",     "Quarter stitched initial light curve (gapped)", SINGLE_PRECISION_HINT, "dimensionless", null),
            new Float32Column("LC_INIT_ERR", "Error in the LC_INIT (gapped)", SINGLE_PRECISION_HINT, "dimensionless", null),
            new Float32Column("LC_WHITE",    "Initial whitened time series fit by DV (gapped)", SINGLE_PRECISION_HINT, "dimensionless", null),
            new Float32Column("LC_DETREND",  "Initial median detrended time series (gapped)", SINGLE_PRECISION_HINT, "dimensionless", null),
            new Float32Column("MODEL_INIT",  "Model light curve", SINGLE_PRECISION_HINT, "dimensionless", null),
            new Float32Column("MODEL_WHITE", "Whitened model light curve", SINGLE_PRECISION_HINT, "dimensionless",  null)
        );

    public Header formatHeader(BaseTargetBinaryTableHeaderSource source,
        String checksumString, DvTceMetadata tce) throws HeaderCardException {
        
        ArrayDimensions arrayDimensions = ArrayDimensions.newEmptyInstance();
        
        Header tceHeader = super.formatHeader(source, null, arrayDimensions);
        
        tceHeader.addValue(TPERIOD_KW,   tce.period(), TPERIOD_COMMENT);
        tceHeader.addValue(TEPOCH_KW,    tce.epoch(), TEPOCH_COMMENT);
        safeAdd(tceHeader, TDEPTH_KW,   tce.transitDepth(), TDEPTH_COMMENT);
        safeAdd(tceHeader, TSNR_KW,     tce.transitSignalToNoiseRatio(), TSNR_COMMENT);
        safeAdd(tceHeader, TDUR_KW,     tce.transitDurationHours(), TDUR_COMMENT);
        safeAdd(tceHeader, INDUR_KW,    tce.ingressDurationHours(), INDUR_COMMENT);
        safeAdd(tceHeader, IMPACT_KW,   tce.impact(), IMPACT_COMMENT);
        safeAdd(tceHeader, INCLIN_KW,   tce.inclinationDegrees(), INCLIN_COMMENT);
        safeAdd(tceHeader, DRRATIO_KW,  tce.planetDistanceStarRadiusRatio(), DRRATIO_COMMENT);
        safeAdd(tceHeader, RADRATIO_KW, tce.planetRadiusStarRadiusRatio(), RADRATIO_COMMENT);
        safeAdd(tceHeader, PRADIUS_KW,  tce.planetRadiusWrtEarth(), PRADIUS_COMMENT);
        tceHeader.addValue(MAXMES_KW,   tce.maxMes(), MAXMES_COMMENT);
        tceHeader.addValue(MAXSES_KW,   tce.maxSes(), MAXSES_COMMENT);
        tceHeader.addValue(NTRANS_KW,   tce.transitCount(), NTRANS_COMMENT);
        //I don't have safeAdd for boolean
        boolean convergence = (tce.convergence() == null) ? false : tce.convergence();
        tceHeader.addValue(CONVRGE_KW,  convergence, CONVRGE_COMMENT);
        safeAdd(tceHeader, MEDDETR_KW,  tce.medianDetrendWindowHours(), MEDDETR_COMMENT);

        addChecksum(tceHeader, checksumString, source.generatedAt());
        return tceHeader;
    }

    @Override
    protected List<ColumnDescription> columnDescriptions() {
        return COLUMN_DESCRIPTIONS;
    }
}
