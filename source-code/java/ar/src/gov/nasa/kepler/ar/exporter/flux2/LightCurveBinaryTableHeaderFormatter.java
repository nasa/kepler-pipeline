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

package gov.nasa.kepler.ar.exporter.flux2;

import static gov.nasa.kepler.common.FitsConstants.*;
import static gov.nasa.kepler.common.FitsUtils.*;
import gov.nasa.kepler.ar.exporter.CelestialWcsKeywordValueSource;
import gov.nasa.kepler.ar.exporter.binarytable.AbstractTargetBinaryTableHeaderFormatter;
import gov.nasa.kepler.ar.exporter.binarytable.ArrayDimensions;
import gov.nasa.kepler.ar.exporter.binarytable.ColumnDescription;
import gov.nasa.kepler.ar.exporter.binarytable.Float32Column;
import gov.nasa.kepler.ar.exporter.binarytable.Float64Column;
import gov.nasa.kepler.ar.exporter.binarytable.Int32Column;
import gov.nasa.kepler.mc.PdcBand;
import gov.nasa.kepler.mc.PdcProcessingCharacteristics;

import java.util.List;

import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;

import com.google.common.collect.ImmutableList;

/**
 * This describes the light curve file binary table data.
 * 
 * @author Sean McCauliff
 *
 */
final class LightCurveBinaryTableHeaderFormatter extends
    AbstractTargetBinaryTableHeaderFormatter {


    private static final List<ColumnDescription> fitsColumns = ImmutableList.of(
        new Float64Column(TIME_TCOLUMN, TIME_TCOLUMN_COMMENT, TIME_TCOLUMN_DISPLAY_HINT, TIME_TCOLUMN_UNIT, TIME_TCOLUMN_UNIT_COMMENT),
        new Float32Column("TIMECORR", "barycenter - timeslice correction", "E13.6", "d", "day"),
        cadenceColumn,
        new Float32Column("SAP_FLUX", "aperture photometry flux",  SINGLE_PRECISION_HINT, "e-/s", "electrons per second"),
        new Float32Column("SAP_FLUX_ERR","aperture phot. flux error", SINGLE_PRECISION_HINT, "e-/s", "electrons per second (1-sigma)"),
        new Float32Column("SAP_BKG", "aperture phot. background flux", SINGLE_PRECISION_HINT, "e-/s", "electrons per second"),
        new Float32Column("SAP_BKG_ERR", "ap. phot. background flux error", SINGLE_PRECISION_HINT, "e-/s", "electrons per second (1-sigma)"),
        new Float32Column("PDCSAP_FLUX", "aperture phot. PDC flux", SINGLE_PRECISION_HINT, "e-/s", "electrons per second"),
        new Float32Column("PDCSAP_FLUX_ERR","ap. phot. PDC flux error", SINGLE_PRECISION_HINT, "e-/s", "electrons per second (1-sigma)"),
        new Int32Column("SAP_QUALITY", "aperture photometry quality flag", "B16.16", null, null, null),
        new Float64Column("PSF_CENTR1", "PSF-fitted column centroid", "F10.5", "pixel", "pixel"),
        new Float32Column("PSF_CENTR1_ERR", "PSF-fitted column error", SINGLE_PRECISION_HINT, "pixel", "pixel (1-sigma)"),
        new Float64Column("PSF_CENTR2", "PSF-fitted row centroid", "F10.5", "pixel", "pixel"),
        new Float32Column("PSF_CENTR2_ERR", "PSF-fitted row error", SINGLE_PRECISION_HINT, "pixel", "pixel (1-sigma)"),
        new Float64Column("MOM_CENTR1", "moment-derived column centroid", "F10.5", "pixel", "pixel"),
        new Float32Column("MOM_CENTR1_ERR", "moment-derived column error", SINGLE_PRECISION_HINT, "pixel", "pixel (1-sigma)"),
        new Float64Column("MOM_CENTR2", "moment-derived row centroid", "F10.5", "pixel", "pixel"),
        new Float32Column("MOM_CENTR2_ERR", "moment-derived row error", SINGLE_PRECISION_HINT, "pixel", "pixel (1-sigma)"),
        new Float32Column(POSCORR1, POSCORR1_COMMENT, SINGLE_PRECISION_HINT, "pixels", "pixel"),
        new Float32Column(POSCORR2, POSCORR2_COMMENT, SINGLE_PRECISION_HINT, "pixels", "pixel"));
        
        
    @Override
    protected List<ColumnDescription> columnDescriptions() {

        return fitsColumns;
    }

    
    public Header formatHeader(LightCurveBinaryTableHeaderSource source, 
        CelestialWcsKeywordValueSource celestialWcs, String checksum) throws HeaderCardException {
        
        
        Header h = super.formatHeader(source, celestialWcs, ArrayDimensions.newEmptyInstance());
        PdcProcessingCharacteristics characteristics = source.pdcMap().processingCharacteristics();
        if (characteristics == null) {
            safeAdd(h, NSPSDDET_KW, NULL_INT, NSPSDDET_COMMENT);
            safeAdd(h, NSPSDCOR_KW, NULL_INT, NSPSDCOR_COMMENT);
            safeAdd(h, PDCVAR_KW,   NULL_FLOAT, PDCVAR_COMMENT);
            safeAdd(h, PDCMETHD_KW, NULL_STRING, PDCMETHD_COMMENT);
            safeAdd(h, NUMBAND_KW,  NULL_INT, NUMBAND_COMMENT);
        } else {
            safeAdd(h, NSPSDDET_KW, characteristics.getNumDiscontinuitiesDetected(), NSPSDDET_COMMENT);
            safeAdd(h, NSPSDCOR_KW, characteristics.getNumDiscontinuitiesRemoved(), NSPSDCOR_COMMENT);
            safeAdd(h, PDCVAR_KW,   characteristics.getTargetVariability(), PDCVAR_COMMENT);
            safeAdd(h, PDCMETHD_KW, characteristics.getPdcMethod(), PDCMETHD_COMMENT);
            safeAdd(h, NUMBAND_KW,  characteristics.getBands().size(), NUMBAND_COMMENT);
            int bandNo = 1;
            for (PdcBand pdcBand : characteristics.getBands()) {
                safeAdd(h, FITTYPE_KW + bandNo, pdcBand.getFitType(), String.format(FITTYPE_COMMENT, bandNo));
                safeAdd(h, PR_GOOD_KW + bandNo, pdcBand.getPriorGoodness(), String.format(PR_GOOD_COMMENT, bandNo));
                safeAdd(h, PR_WGHT_KW + bandNo, pdcBand.getPriorWeight(), String.format(PR_WGHT_COMMENT, bandNo));
                bandNo++;
            }
        }
        safeAdd(h, PDC_TOT_KW, source.pdcMap().pdcTotalGoodness(), PDC_TOT_COMMENT);
        safeAdd(h, PDC_TOTP_KW, source.pdcMap().pdcTotalGoodnessPct(), PDC_TOTP_COMMENT);
        safeAdd(h, PDC_COR_KW, source.pdcMap().pdcCorrelationGoodness(), PDC_COR_COMMENT);
        safeAdd(h, PDC_CORP_KW, source.pdcMap().pdcCorrelationGoodnessPct(), PDC_CORP_COMMENT);
        safeAdd(h, PDC_VAR_KW, source.pdcMap().pdcVariabilityGoodness(), PDC_VAR_COMMENT);
        safeAdd(h, PDC_VARP_KW, source.pdcMap().pdcVariabilityGoodnessPct(), PDC_VARP_COMMENT);
        safeAdd(h, PDC_NOI_KW, source.pdcMap().pdcNoiseGoodness(), PDC_NOI_COMMENT);
        safeAdd(h, PDC_NOIP_KW, source.pdcMap().pdcNoiseGoodnessPct(), PDC_NOIP_COMMENT);
        safeAdd(h, PDC_EPT_KW, source.pdcMap().pdcEarthPointGoodness(), PDC_EPT_COMMENT);
        safeAdd(h, PDC_EPTP_KW, source.pdcMap().pdcEarthPointGoodnessPct(), PDC_EPTP_COMMENT);
        
        addChecksum(h, checksum, source.generatedAt());
        return h;
    }
    

}
