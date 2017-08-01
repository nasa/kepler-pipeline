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

import gov.nasa.kepler.ar.exporter.binarytable.AbstractTargetBinaryTableHeaderFormatter;
import gov.nasa.kepler.ar.exporter.binarytable.ArrayDimensions;
import gov.nasa.kepler.ar.exporter.binarytable.BaseTargetBinaryTableHeaderSource;
import gov.nasa.kepler.ar.exporter.binarytable.ColumnDescription;
import gov.nasa.kepler.ar.exporter.binarytable.Float32Column;
import gov.nasa.kepler.ar.exporter.binarytable.Float64Column;

import java.util.List;

import com.google.common.collect.ImmutableList;

import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;
import static gov.nasa.kepler.common.FitsConstants.*;
import static gov.nasa.kepler.common.FitsUtils.addChecksum;

/**
 * The Statistics HDU's header can appropriately be formatted using
 * nom.tam.fits. This class accomplishes that. This is a View part of the
 * Model-View-Controller pattern, It is degenerate in that the card values
 * are constant.
 * 
 * @author lbrownst
 * @author Sean McCauliff
 */
public final class DvStatisticsHeaderFormatter extends AbstractTargetBinaryTableHeaderFormatter {
    
    private static final String SES_CORR_COLUMN_FORMAT = "SES_CORR_%.1f";
    private static final String SES_CORR_COLUMN_COMMENT = "SES correlation for pulse %d";
    private static final String SES_NORM_COLUMN_FORMAT = "SES_NORM_%.1f";
    private static final String SES_NORM_COLUMN_COMMENT = "SES normalization for pulse %d";
    private static final String CDPP_COLUMN_FORMAT = "CDPP_%.1f";
    private static final String CDPP_COLUMN_COMMENT = "CDPP for pulse %d";

    // @formatter:off
    /** Descriptions of the table columns. */
    private final List<ColumnDescription> columnDescriptions;
    
    public DvStatisticsHeaderFormatter(float[] tpsPulseDurationsHours) {
        ImmutableList.Builder<ColumnDescription> bldr = new ImmutableList.Builder<ColumnDescription>();
        bldr.add(new Float64Column(TIME_TCOLUMN, TIME_TCOLUMN_COMMENT, TIME_TCOLUMN_DISPLAY_HINT, TIME_TCOLUMN_UNIT, TIME_TCOLUMN_UNIT_COMMENT));
        bldr.add(new Float32Column("TIMECORR", "barycenter - timeslice correction", SINGLE_PRECISION_HINT, "d", "day"));
        bldr.add(cadenceColumn);
        bldr.add(new Float32Column("PDCSAP_FLUX", "PDC light curve (e/s)", SINGLE_PRECISION_HINT, "e-/s", "electrons per second"));
        bldr.add(new Float32Column("PDCSAP_FLUX_ERR", "uncertainty in  PCDSAP_FLUX", SINGLE_PRECISION_HINT, "e-/s", null));
        bldr.add(new Float32Column("RESIDUAL_LC", "residual light curve", SINGLE_PRECISION_HINT, "dimensionless", null));
        bldr.add(new Float32Column("DEWEIGHTS", "initial de-emphasis weights",  SINGLE_PRECISION_HINT, "proportion", "[0.0, 1.0]"));
        bldr.add(qualityColumn);
  
        for (int i=0; i < tpsPulseDurationsHours.length; i++) {
            String columnType = String.format(SES_CORR_COLUMN_FORMAT, tpsPulseDurationsHours[i]).replace('.', '_');
            String columnTypeComment = String.format(SES_CORR_COLUMN_COMMENT, i + 1);
            bldr.add(new Float32Column(columnType, columnTypeComment, SINGLE_PRECISION_HINT, null, null));
        }
        for (int i=0; i < tpsPulseDurationsHours.length; i++) {
            String columnType = String.format(SES_NORM_COLUMN_FORMAT, tpsPulseDurationsHours[i]).replace('.', '_');
            String columnTypeComment = String.format(SES_NORM_COLUMN_COMMENT, i + 1);
            bldr.add(new Float32Column(columnType, columnTypeComment, SINGLE_PRECISION_HINT, null, null));
        }
        for (int i=0; i < tpsPulseDurationsHours.length; i++) {
            String columnType = String.format(CDPP_COLUMN_FORMAT, tpsPulseDurationsHours[i]).replace('.', '_');
            String columnTypeComment = String.format(CDPP_COLUMN_COMMENT, i + 1);
            bldr.add(new Float32Column(columnType, columnTypeComment, SINGLE_PRECISION_HINT, "ppm", null));
        }
        columnDescriptions = bldr.build();
    }
    
    // @formatter:on

    public Header formatHeader(BaseTargetBinaryTableHeaderSource dvStatisticsHeaderSource,
        String checksumString) throws HeaderCardException {

        ArrayDimensions zeroDimensional = ArrayDimensions.newEmptyInstance();
        Header statisticsHeader = 
            super.formatHeader(dvStatisticsHeaderSource, null, zeroDimensional);

        addChecksum(statisticsHeader, checksumString, dvStatisticsHeaderSource.generatedAt());
        return statisticsHeader;
    }

    @Override
    public List<ColumnDescription> columnDescriptions() {
        return columnDescriptions;
    }
}
