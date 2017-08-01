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

package gov.nasa.kepler.etem;

import static gov.nasa.kepler.common.FitsConstants.*;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.DateUtils;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.BinaryTable;
import nom.tam.fits.BinaryTableHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;
import nom.tam.util.BufferedFile;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public abstract class KeplerFits {
    private static final int UNSET_TABLE_ID = 0;

    private static final Log log = LogFactory.getLog(KeplerFits.class);

    private static final String DMC_FITS_FILENAME_PREFIX = "kplr";
    private static final String DMC_FITS_FILENAME_EXTENSION = ".fits";

    protected String fitsDir;
    protected TargetType targetType;
    protected CadenceType cadenceType;

    protected double cadenceZeroMjd;

    protected Header primaryHeader;

    private BufferedFile bufferedFile;

    private int hduIndex = 0;

    protected String suffix;

    private List<Header> masterHeaders;

    private int scConfigId;

    protected double secondsPerShortCadence;
    protected int shortCadencesPerLong;

    protected int compressionId;
    protected int badId;
    protected int bgpId;
    protected int tadId;
    protected int lctId;
    protected int sctId;
    protected int rptId;
    protected boolean requantEnabled;

    // so FitsFfi2FitsLc can patch header values in its output files.
    private String filename;

    /**
     * If true, DCT_PURP=KARF039 MOTION keyword will be added to the primary HDU
     * header.
     */
    protected boolean hasMotion = false;

    protected KeplerFits(String fitsDir, TargetType targetType,
        double cadenceZeroMjd, List<Header> masterHeaders, int scConfigId,
        double secondsPerShortCadence, int shortCadencesPerLong,
        int compressionId, int badId, int bgpId, int tadId, int lctId,
        int sctId, int rptId, boolean hasMotion) {
        this.fitsDir = fitsDir;
        this.targetType = targetType;
        this.cadenceType = getCadenceType(targetType);
        this.cadenceZeroMjd = cadenceZeroMjd;
        this.masterHeaders = masterHeaders;
        this.scConfigId = scConfigId;
        this.secondsPerShortCadence = secondsPerShortCadence;
        this.shortCadencesPerLong = shortCadencesPerLong;
        this.compressionId = compressionId;
        this.badId = badId;
        this.bgpId = bgpId;
        this.tadId = tadId;
        this.lctId = lctId;
        this.sctId = sctId;
        this.rptId = rptId;
        this.hasMotion = hasMotion;

        if (this instanceof CadenceFits) {
            switch (cadenceType) {
                case LONG:
                    this.sctId = UNSET_TABLE_ID;
                    break;
                case SHORT:
                    this.lctId = UNSET_TABLE_ID;
                    this.bgpId = UNSET_TABLE_ID;
                    this.badId = UNSET_TABLE_ID;
                    break;
                default:
                    throw new PipelineException("Unexpected cadenceType: "
                        + cadenceType);
            }
        }
    }

    /**
     * Opens the fits files. If the file does not already exist for this
     * cadence, create it by copying the master.
     * 
     * @param suffix
     * @param ctlSuffix
     * @throws Exception
     */
    protected void initialize() throws Exception {
        suffix = getSuffix(targetType);

        String dmcTimestamp = DateUtils.formatLikeDmc(getTimestamp());

        // Create the new file.
        File file = new File(fitsDir + "/" + DMC_FITS_FILENAME_PREFIX
            + dmcTimestamp + suffix + DMC_FITS_FILENAME_EXTENSION);
        filename = file.getAbsolutePath();
        bufferedFile = new BufferedFile(file.getAbsolutePath(), "rw");

        // Get the primary header.
        primaryHeader = masterHeaders.get(0);

        // Format externalId.
        NumberFormat formatter = new DecimalFormat("000");
        String badIdString = formatter.format(Math.abs(badId));
        String bgpIdString = formatter.format(Math.abs(bgpId));
        String tadIdString = formatter.format(Math.abs(tadId));
        String lctIdString = formatter.format(Math.abs(lctId));
        String sctIdString = formatter.format(Math.abs(sctId));

        Date pmrfDate = ModifiedJulianDate.mjdToDate(PmrfFits.PMRF_MJD);
        String pmrfTimestamp = DateUtils.formatLikeDmc(pmrfDate);

        primaryHeader.addValue(LONG_CADENCE_PMRF_KW, "kplr"
            + pmrfTimestamp + "-" + lctIdString + "-" + tadIdString
            + "_lcm.fits", "");
        primaryHeader.addValue(SHORT_CADENCE_PMRF_KW, "kplr"
            + pmrfTimestamp + "-" + sctIdString + "-" + tadIdString
            + "_scm.fits", "");
        primaryHeader.addValue(BACKGROUND_PMRF_KW, "kplr"
            + pmrfTimestamp + "-" + bgpIdString + "-" + badIdString
            + "_bgm.fits", "");
        primaryHeader.addValue(LONG_CADENCE_COLLATERAL_PMRF_KW, "kplr"
            + pmrfTimestamp + "-" + lctIdString + "-" + tadIdString
            + "_lcc.fits", "");
        primaryHeader.addValue(SHORT_CADENCE_COLLATERAL_PMRF_KW, "kplr"
            + pmrfTimestamp + "-" + sctIdString + "-" + tadIdString
            + "_scc.fits", "");

        primaryHeader.addValue(
            SCCONFID_KW, scConfigId, "");

        primaryHeader.addValue(LCTRGDEF_KW,
            String.valueOf(lctId), "");
        primaryHeader.addValue(SCTRGDEF_KW,
            String.valueOf(sctId), "");
        primaryHeader.addValue(BKTRGDEF_KW,
            String.valueOf(bgpId), "");
        primaryHeader.addValue(TARGAPER_KW,
            String.valueOf(tadId), "");
        primaryHeader.addValue(BKG_APER_KW,
            String.valueOf(badId), "");

        primaryHeader.addValue(COMPTABL_KW,
            String.valueOf(compressionId), "");

        primaryHeader.addValue(DCT_PURP_KW, "", "");

        primaryHeader.addValue(REQUANT_KW,
            isRequantEnabled(), "");
        primaryHeader.addValue(HUFFMAN_KW, true, "");
        primaryHeader.addValue(BASELINE_KW, false, "");
        primaryHeader.addValue(BASENAME_KW, "", "");
        primaryHeader.addValue(BASERCON_KW, false, "");
        primaryHeader.addValue(RBASNAME_KW, "", "");

        primaryHeader.addValue(SEFI_ACC_KW, false, "");
        primaryHeader.addValue(SEFI_CAD_KW, false, "");
        primaryHeader.addValue(LDE_OOS_KW, false, "");
        primaryHeader.addValue(FINE_PNT_KW, true, "");
        primaryHeader.addValue(MMNTMDMP_KW, false, "");
        primaryHeader.addValue(LDEPARER_KW, false, "");
        primaryHeader.addValue(SCRC_ERR_KW, false, "");

        primaryHeader.addValue(FILENAME_KW,
            file.getName(), "");

        addSpecificKeywordsToPrimaryHdu();

        primaryHeader.write(bufferedFile);
        bufferedFile.flush();
    }

    protected abstract String getSuffix(TargetType targetType)
        throws PipelineException;

    protected abstract Date getTimestamp();

    protected abstract void addSpecificKeywordsToPrimaryHdu()
        throws HeaderCardException;

    protected void addBinaryTableHdu(BinaryTable newBinaryTable)
        throws IOException, FitsException {
        Header originalHeader = masterHeaders.get(hduIndex + 1);

        // Add NAXIS2. This is the one field that is not copied correctly.
        originalHeader.addValue(
            NAXIS2_KW,
            newBinaryTable.getNRows(), "");

        BinaryTableHDU newHdu = new BinaryTableHDU(originalHeader,
            newBinaryTable);

        newHdu.write(bufferedFile);
        bufferedFile.flush();

        hduIndex++;
    }

    protected static List<Header> getMasterHeaders(String masterFitsPath,
        String masterSuffix) throws FitsException {
        String masterFitsFilename = masterFitsPath + "/" + masterSuffix
            + DMC_FITS_FILENAME_EXTENSION;
        log.info("masterFitsFilename = " + masterFitsFilename);
        Fits masterFits = new Fits(masterFitsFilename);

        List<Header> masterHeaders = new ArrayList<Header>();
        for (BasicHDU basicHDU : masterFits.read()) {
            masterHeaders.add(basicHDU.getHeader());
        }

        return masterHeaders;
    }

    private CadenceType getCadenceType(TargetType targetType) {
        switch (targetType) {
            case LONG_CADENCE:
                return CadenceType.LONG;
            case SHORT_CADENCE:
                return CadenceType.SHORT;
            case BACKGROUND:
                return CadenceType.LONG;
            default:
                throw new PipelineException("Invalid target type " + targetType
                    + " for " + this.getClass()
                        .getName());
        }
    }

    public void save() throws Exception {
        bufferedFile.close();
    }

    /**
     * @return the hasMotion
     */
    public boolean isHasMotion() {
        return hasMotion;
    }

    public boolean isRequantEnabled() {
        return requantEnabled;
    }

    public void setRequantEnabled(boolean requantEnabled) {
        this.requantEnabled = requantEnabled;
    }

    public String getFilename() {
        return filename;
    }

    public void setFilename(String filename) {
        this.filename = filename;
    }
}
