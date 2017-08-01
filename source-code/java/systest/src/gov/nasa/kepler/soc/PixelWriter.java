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

package gov.nasa.kepler.soc;

import static gov.nasa.kepler.common.FitsConstants.*;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.hibernate.dr.PixelLog;

import java.io.ByteArrayInputStream;
import java.io.DataOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.List;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;
import nom.tam.fits.TableHDU;

/**
 * Writes pixels.
 * 
 * @author Miles Cote
 * 
 */
public class PixelWriter {

    private final OutputStream outputStream;

    public PixelWriter(OutputStream outputStream) {
        this.outputStream = outputStream;
    }

    public void write(ImportedPixels importedPixels) {
        try {
            InputStream inputStream = new ByteArrayInputStream(
                importedPixels.getPixelFitsBlob());
            Fits fits = new Fits(inputStream);

            BasicHDU[] hdus = fits.read();
            List<List<IntTimeSeries>> timeSeriesLists = importedPixels.getTimeSeriesLists();

            write(importedPixels.getPixelLog(), hdus[0]);

            for (int i = 1; i < hdus.length; i++) {
                TableHDU hdu = (TableHDU) hdus[i];
                List<IntTimeSeries> timeSeriesList = timeSeriesLists.get(i - 1);

                for (IntTimeSeries intTimeSeries : timeSeriesList) {
                    hdu.addRow(new Object[] { new int[] { intTimeSeries.iseries()[0] } });
                }
            }

            fits.write(new DataOutputStream(outputStream));

            outputStream.close();
        } catch (Throwable e) {
            throw new IllegalArgumentException("Unable to write.", e);
        }
    }

    private void write(PixelLog pixelLog, BasicHDU primaryHDU) {
        Header primaryHeader = primaryHDU.getHeader();

        try {
            primaryHeader.addValue(
                SCCONFID_KW,
                pixelLog.getSpacecraftConfigId(), "");

            primaryHeader.addValue(STARTIME_KW,
                pixelLog.getMjdStartTime(), "");
            primaryHeader.addValue(END_TIME_KW,
                pixelLog.getMjdEndTime(), "");

            primaryHeader.addValue(LCTRGDEF_KW,
                pixelLog.getLcTargetTableId(), "");
            primaryHeader.addValue(SCTRGDEF_KW,
                pixelLog.getScTargetTableId(), "");
            primaryHeader.addValue(BKTRGDEF_KW,
                pixelLog.getBackTargetTableId(), "");
            primaryHeader.addValue(TARGAPER_KW,
                pixelLog.getTargetApertureTableId(), "");
            primaryHeader.addValue(BKG_APER_KW,
                pixelLog.getBackApertureTableId(), "");
            primaryHeader.addValue(
                COMPTABL_KW,
                pixelLog.getCompressionTableId(), "");

            primaryHeader.addValue(REQUANT_KW,
                pixelLog.isDataRequantizedForDownlink(), "");
            primaryHeader.addValue(HUFFMAN_KW,
                pixelLog.isDataEntropicCompressedForDownlink(), "");
            primaryHeader.addValue(BASELINE_KW,
                pixelLog.isDataOriginatedAsBaselineImage(), "");
            primaryHeader.addValue(BASENAME_KW,
                pixelLog.getBaselineImageRootname(), "");
            primaryHeader.addValue(BASERCON_KW,
                pixelLog.isBaselineCreatedFromResidualBaselineImage(), "");
            primaryHeader.addValue(RBASNAME_KW,
                pixelLog.getResidualBaselineImageRootname(), "");

            primaryHeader.addValue(SEFI_ACC_KW,
                pixelLog.isSefiAcc(), "");
            primaryHeader.addValue(SEFI_CAD_KW,
                pixelLog.isSefiCad(), "");
            primaryHeader.addValue(LDE_OOS_KW,
                pixelLog.isLdeOos(), "");
            primaryHeader.addValue(FINE_PNT_KW,
                pixelLog.isFinePnt(), "");
            primaryHeader.addValue(MMNTMDMP_KW,
                pixelLog.isMmntmDmp(), "");
            primaryHeader.addValue(LDEPARER_KW,
                pixelLog.isLdeParEr(), "");
            primaryHeader.addValue(SCRC_ERR_KW,
                pixelLog.isScrcErr(), "");
        } catch (HeaderCardException e) {
            throw new IllegalArgumentException("Unable to write.", e);
        }
    }

}
