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

package gov.nasa.kepler.ar.exporter;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FfiType;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapperFactory;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Formatter;
import java.util.TimeZone;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Formats filenames for FluxTimeSeries and other archiver output formats. The
 * Cosmic Ray Correction Table name format is contained in the Cosmic Ray
 * Correction Table class. This class is MT-safe.
 * 
 * @author Sean McCauliff
 * 
 */
public class FileNameFormatter {
    public static final String LONG_CADENCE_FLUX = "_llc.fits";

    public static final String SHORT_CADENCE_FLUX = "_slc.fits";

    public static final String LONG_CADENCE_TARGET_PIXEL = "_lpd-targ.fits";

    public static final String SHORT_CADENCE_TARGET_PIXEL = "_spd-targ.fits";

    // Cosmic Ray Corrections
    public static final String CR_SHORT_CADENCE_FNAME = "_scs-crct.fits";
    public static final String CR_LONG_CADENCE_FNAME = "_lcs-crct.fits";
    public static final String CR_SHORT_CADENCE_COLLATERAL_FNAME = "_scs-crcc.fits";// "_cscs-crct.fits";
    public static final String CR_LONG_CADENCE_COLLATERAL_FNAME = "_lcs-crcc.fits"; // "_clcs-crct.fits";

    public static final String COLLATERAL_LC_PIXEL_FNAME = "_coll.fits";
    public static final String COLLATERAL_SC_PIXEL_FNAME = "_cols.fits";

    private final ThreadLocal<SimpleDateFormat> genericDate = new ThreadLocal<SimpleDateFormat>() {

        @Override
        protected SimpleDateFormat initialValue() {
            SimpleDateFormat format = new SimpleDateFormat("yyyyMMddHHmmss");
            format.setTimeZone(TimeZone.getTimeZone("UT"));
            return format;
        }
    };

    public String dataValidationTimeSeriesName(int keplerId,
        Date startTimeOfDvRun) {
        return String.format("kplr%09d-%s_dvt.fits", keplerId,
            genericDate.get()
                .format(startTimeOfDvRun));
    }

    /**
     * 
     * @param endTimeOfDvRun The start time of the DV pipeline run.
     * @return
     */
    public String dataValidationName(Date startTimeOfDvRun) {
        return String.format("kplr%s_dv.xml", genericDate.get()
            .format(startTimeOfDvRun));
    }

    /**
     * 
     * @param keplerId
     * @param endTimeOfDvRun The start time of the DV pipeline instance.
     * @return
     */
    public String dataValidationReportName(int keplerId, Date startTimeOfDvRun) {
        return String.format("kplr%09d-%s_dvr.pdf", keplerId, genericDate.get()
            .format(startTimeOfDvRun));
    }

    /**
     * 
     * @param keplerId
     * @param planetNumber
     * @param endTimeOfDvRun The start time of the DV pipeline instance.
     * @return
     */
    public String dataValidationReportSummaryName(int keplerId,
        int planetNumber, Date startTimeOfDvRun) {
        return String.format("kplr%09d-%02d-%s_dvs.pdf", keplerId,
            planetNumber, genericDate.get()
                .format(startTimeOfDvRun));
    }

    /**
     * 
     * @param endUTC
     * @param keplerId
     * @return
     */
    public String cdppName(Date endUTC, int keplerId) {
        return String.format("kplr%09d-%s_cdpp.fits", keplerId,
            genericDate.get()
                .format(endUTC));
    }

    /**
     * 
     * @param tpsStopTime In UTC
     * @return
     */
    public String tpsResultsName(Date tpsStopTime) {
        return "kplr" + genericDate.get()
            .format(tpsStopTime) + "_tps_results.txt";
    }

    public String combinedFlatField(double mjd) {
        Date date = ModifiedJulianDate.mjdToDate(mjd);

        return "kplr" + genericDate.get()
            .format(date) + "-mmo_cflat.fits";
    }

    /**
     * Generates a file name for the Flux time series files.
     * 
     * @param targetId the kepler id of the target
     * @param dateString The format and contents of this string are now
     * operationally defined.  non-null
     * @param shortCadence When true this generates a name for short cadence
     * else it will generate a name for long cadence.
     * @return non-null
     */
    public String fluxName(int targetId, String dateString, boolean shortCadence) {
        return String.format("kplr%09d-%s%s", targetId, dateString, fluxSuffix(shortCadence));
    }

    /**
     * As fluxName, but for k2 files.
     */
    public String k2FluxName(int targetId, int k2Campaign, boolean shortCadence) {
        return String.format("ktwo%09d-c%02d%s", targetId, k2Campaign, fluxSuffix(shortCadence));
    }
    
    /**
     * @return When shortCadence is true return the short cadence suffix else this returns the long
     * cadence suffix.
     */
    private String fluxSuffix(boolean shortCadence) {
        if (shortCadence) {
            return SHORT_CADENCE_FLUX;
        } else {
            return LONG_CADENCE_FLUX;
        }
    }
    
    /**
     * Generates a file name for the target pixel time series files.
     * 
     * @param targetId
     * @param dateString The format and contents of this string are now
     * operationally defined.
     * @param shortCadence When true this generates a name for short cadence
     * else it will generate a name for long cadence.
     * @param useGzip file is going to be gzip compressed
     * @return
     */
    public String targetPixelName(int targetId, String dateString,
        boolean shortCadence, boolean useGzip) {

        return formatTargetPixelFileName(shortCadence, useGzip, "kplr%09d-%s", targetId, dateString);
    }

    private String formatTargetPixelFileName(boolean shortCadence, boolean useGzip,
        String formatString, Object... formatParams) {
    
        StringBuilder fileNameBuf = new StringBuilder(32);
        Formatter formatter = new Formatter(fileNameBuf);
        formatter.format(formatString, formatParams);
        if (shortCadence) {
            fileNameBuf.append(SHORT_CADENCE_TARGET_PIXEL);
        } else {
            fileNameBuf.append(LONG_CADENCE_TARGET_PIXEL);
        }
        if (useGzip) {
            fileNameBuf.append(".gz");
        }
        formatter.close();
        return fileNameBuf.toString();
    }
    /**
     * Generates a file name for the KIC. kplr-yyyyMMddHHmmss.kic
     */
    public String kicName() {
        StringBuilder builder = new StringBuilder();
        String dateStr = genericDate.get()
            .format(new Date());
        builder.append("kplr");
        builder.append(dateStr);
        builder.append("_kic.txt");
        return builder.toString();
    }

    /** Parses the date string out of the KTC file name. */
    public String parseKtcName(String fname) {
        Pattern namePattern = Pattern.compile("kplr(\\d{14})_ktc.txt");
        Matcher m = namePattern.matcher(fname);
        if (!m.matches()) {
            throw new IllegalArgumentException("Bad KTC file name \"" + fname
                + "\".");
        }
        return m.group(1);
    }

    /**
     * Generates a file name for the characteristic table.
     * kplr-yyyyMMddHHmmss.char
     */
    public String characteristicName() {
        StringBuilder builder = new StringBuilder();
        String dateStr = genericDate.get()
            .format(new Date());
        builder.append("kplr")
            .append(dateStr)
            .append("_ct.txt");
        return builder.toString();
    }

    /**
     * Generates a file name for the Kepler Target Catalog (KTC)
     * kplryyyyMMddHHmmss_ktc.txt
     */
    public String targetCatalogName() {
        StringBuilder builder = new StringBuilder();
        String dateStr = genericDate.get()
            .format(new Date());
        builder.append("kplr")
            .append(dateStr)
            .append("_ktc.txt");
        return builder.toString();
    }

    public String qdnmFileName(Date lastCadence) {
        StringBuilder builder = new StringBuilder();
        String dateStr = genericDate.get()
            .format(lastCadence);
        builder.append("kplr")
            .append(dateStr)
            .append("_qdnm.xml");
        return builder.toString();
    }

    /**
     * The dataset name of the file name prefix up to the first _.
     * 
     * @param fileName
     * @return
     */
    public static String dataSetName(String fileName) {
        // As per email from Daryl Swade
        int lastUnderScore = fileName.lastIndexOf('_');
        if (lastUnderScore == -1) {
            throw new IllegalArgumentException("Invalid file name \""
                + fileName + "\" lacks an underscore character.");
        }
        String dataSetName = fileName.substring(0, lastUnderScore);
        return dataSetName;
    }

    /**
     * The name of the processing history.
     * 
     * @param lastTimeStamp This is the last time stamp in the pixel files which
     * this processing history is associaed with.
     * @param shortCadence true if this is for short cadence else it is for long
     * cadence.
     */
    public String pixelProcessingHistoryName(String lastTimeStamp,
        boolean shortCadence) {
        StringBuilder bldr = new StringBuilder();
        bldr.append("kplr");
        bldr.append(lastTimeStamp);
        if (shortCadence) {
            bldr.append("_scs-set-history.txt");
        } else {
            bldr.append("_lcs-history.txt");
        }
        return bldr.toString();
    }

    /**
     * Generates a file name for the Cosmic Ray Correction Table file.
     * 
     * @param lastCadenceTime UTC time associated with the end of enclosed
     * cadence data
     */
    public String cosmicRayName(boolean shortCadence, boolean collateral,
        Date lastCadenceTime) {

        String lastCadenceTimeStr = genericDate.get()
            .format(lastCadenceTime);

        return cosmicRayName(shortCadence, collateral, lastCadenceTimeStr);
    }

    /**
     * Generates a file name for the Cosmic Ray Correction Table file.
     * 
     * @param lastCadenceTime UTC time associated with the end of enclosed
     * cadence data
     */
    public String cosmicRayName(boolean shortCadence, boolean collateral,
        String lastCadenceTime) {
        StringBuilder bldr = new StringBuilder();
        bldr.append("kplr")
            .append(lastCadenceTime);

        if (collateral) {
            if (shortCadence) {
                bldr.append(CR_SHORT_CADENCE_COLLATERAL_FNAME);
            } else {
                bldr.append(CR_LONG_CADENCE_COLLATERAL_FNAME);
            }
        } else {
            if (shortCadence) {
                bldr.append(CR_SHORT_CADENCE_FNAME);
            } else {
                bldr.append(CR_LONG_CADENCE_FNAME);
            }
        }
        return bldr.toString();
    }

    /**
     * 
     * @param fname A file name.
     * @return true if the file name is a cosmic ray file else false.
     */
    public boolean isCosmicRayName(String fname) {
        if (fname.endsWith(CR_LONG_CADENCE_COLLATERAL_FNAME)) {
            return true;
        }
        if (fname.endsWith(CR_LONG_CADENCE_FNAME)) {
            return true;
        }
        if (fname.endsWith(CR_SHORT_CADENCE_COLLATERAL_FNAME)) {
            return true;
        }
        if (fname.endsWith(CR_SHORT_CADENCE_FNAME)) {
            return true;
        }
        return false;
    }

    public boolean isFluxName(String fname) {
        if (fname.endsWith(LONG_CADENCE_FLUX)) {
            return true;
        }
        if (fname.endsWith(SHORT_CADENCE_FLUX)) {
            return true;
        }
        return false;
    }

    public boolean isCadencePixelName(String fname) {
        if (fname.endsWith(DispatcherWrapperFactory.LONG_CADENCE_BACKGROUND)) {
            return true;
        }
        if (fname.endsWith(DispatcherWrapperFactory.LONG_CADENCE_COLLATERAL)) {
            return true;
        }
        if (fname.endsWith(DispatcherWrapperFactory.LONG_CADENCE_TARGET)) {
            return true;
        }
        if (fname.endsWith(DispatcherWrapperFactory.SHORT_CADENCE_COLLATERAL)) {
            return true;
        }
        if (fname.endsWith(DispatcherWrapperFactory.SHORT_CADENCE_TARGET)) {
            return true;
        }
        return false;
    }

    public boolean isCalFfi(String fname) {
        try {
            FfiType ffiType = FfiType.valueOfFileNameSuffix(fname);
            return ffiType == FfiType.SOC_CAL;
        } catch (IllegalArgumentException badfilename) {
            return false;
        }
    }

    public String ffiName(String fileTimestamp, FfiType ffiType) {
        StringBuilder bldr = new StringBuilder();
        if (!fileTimestamp.startsWith("kplr")) {
            bldr.append("kplr");
        }
        bldr.append(fileTimestamp)
            .append("_")
            .append(ffiType.toFitsFileNameSuffix())
            .append(".fits");
        return bldr.toString();
    }
    
    public String k2FfiName(String fileTimestamp, FfiType ffiType, int k2Campaign) {
        if (fileTimestamp.startsWith("kplr") || fileTimestamp.startsWith("ktwo")) {
            fileTimestamp = fileTimestamp.substring(4);
        }
        
        return String.format("ktwo%s-c%02d_%s.fits",
            fileTimestamp,
            k2Campaign,
            ffiType.toFitsFileNameSuffix());
    }
    

    /**
     * This is the name for the collateral pixel file. The file that contains
     * all the collateral for a mod/out for a large number of cadences, rather
     * than just one.
     * 
     * @param timestamp non-null
     * @param cadenceType non-null
     * @return non-null
     */
    public String collateralName(String timestamp, int ccdModule,
        int ccdOutput, CadenceType cadenceType) {
        StringBuilder bldr = new StringBuilder("kplr");
        bldr.append(String.format("%02d%1d", ccdModule, ccdOutput));
        bldr.append("-");
        bldr.append(timestamp);
        switch (cadenceType) {
            case SHORT:
                bldr.append(COLLATERAL_SC_PIXEL_FNAME);
                break;
            case LONG:
                bldr.append(COLLATERAL_LC_PIXEL_FNAME);
                break;
            default:
                throw new IllegalArgumentException("bad case");
        }
        return bldr.toString();

    }

    /**
     * The k2 version of collateralName()
     * @return non-null
     */
    public String k2CollateralName(int k2Campaign, int ccdModule,
        int ccdOutput, CadenceType cadenceType) {
        
        String fileTypeStr = null;
        switch (cadenceType) {
            case SHORT: fileTypeStr = "cols"; break;
            case LONG: fileTypeStr = "coll"; break;
            default:
                throw new IllegalStateException("Invalid cadence type : " + cadenceType);
        }
        return String.format("ktwo%02d%1d-c%02d_%s.fits", ccdModule, ccdOutput, k2Campaign, fileTypeStr);
        
    }
    
    /**
     * This is the file name for the per module output background files , not the background file
     * that is for a single cadence.
     * @param timestamp non-null
     * @return non-null
     */
    public String backgroundName(String timestamp, int ccdModule, int ccdOutput) {
        return String.format("kplr%02d%1d-%s_bkg.fits", ccdModule, ccdOutput, timestamp);
    }
    
    /**
     * The k2 version of backgroundName()
     * @return non-null
     */
    public String k2BackgroundName(int k2Campaign, int ccdModule, int ccdOutput) {
        return String.format("ktwo%02d%1d-c%02d_bkg.fits", ccdModule, ccdOutput, k2Campaign);
    }

    /**
     * File name for Artifact Removal Pixels
     * @return non-null
     */
    public String arpName(String timestamp, int ccdModule, int ccdOutput) {
        return String.format("kplr%02d%1d-%s_arp.fits", ccdModule, ccdOutput, timestamp);
    }
    
    /**
     * 
     * @return non-null
     */
    public String k2ArpName(int k2Campaign, int ccdModule, int ccdOutput) {
        return String.format("ktwo%02d%1d-c%02d_arp.fits", ccdModule, ccdOutput, k2Campaign);
    }

    /**
     * File name for the cotrending basis vector file.
     * 
     * @param timestamp This should be the same timestamp as the long cadence
     * target pixel FITS file and should be non-null.
     * @param cadenceType non-null
     * @return non-null
     */
    public String cbvName(String timestamp, int quarter, int dataReleaseNumber,
        CadenceType cadenceType) {

        String fnameSuffix = cadenceTypeToCbvSuffix(cadenceType);
        return String.format("kplr%s-q%02d-d%02d_%s.fits", timestamp, quarter,
            dataReleaseNumber, fnameSuffix);
    }

    private String cadenceTypeToCbvSuffix(CadenceType cadenceType) {
        String fnameSuffix = null;
        switch (cadenceType) {
            case LONG:
                fnameSuffix = "lcbv";
                break;
            case SHORT:
                fnameSuffix = "scbv";
                break;
            default:
                throw new IllegalArgumentException(cadenceType.toString());
        }
        return fnameSuffix;
    }
    
    public String k2CbvName(int k2Campaign, int dataReleaseNumber, CadenceType cadenceType) {
        String fnameSuffix = cadenceTypeToCbvSuffix(cadenceType);
        return String.format("ktwo-c%02d-d%02d_%s.fits", k2Campaign, dataReleaseNumber, fnameSuffix);
    }
    
    /**
     * Target pixel file name in K2 format.
     * @param catalogId  The EPIC identifier.
     * @param campaign  The campaign number.
     * @param shortCadence When true format for short cadence else formats for long cadence
     * @param useGzip The file name should have the gzip extension or not.
     * @return non-null
     */
    public String k2TargetPixelName(int catalogId, int campaign, boolean shortCadence, boolean useGzip) {
        return formatTargetPixelFileName(shortCadence, useGzip, "ktwo%09d-c%02d", catalogId, campaign);
    }

}
