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

package gov.nasa.kepler.dr.dispatch;

import gov.nasa.kepler.dr.ancillary.AncillaryDispatcher;
import gov.nasa.kepler.dr.configmap.ConfigMapDispatcher;
import gov.nasa.kepler.dr.crct.CrctDispatcher;
import gov.nasa.kepler.dr.dataanomaly.DataAnomalyDispatcher;
import gov.nasa.kepler.dr.ephemeris.LeapSecondsDispatcher;
import gov.nasa.kepler.dr.ephemeris.PlanetaryEphemerisDispatcher;
import gov.nasa.kepler.dr.ephemeris.SpacecraftEphemerisDispatcher;
import gov.nasa.kepler.dr.ffi.FfiDispatcher;
import gov.nasa.kepler.dr.gap.GapReportDispatcher;
import gov.nasa.kepler.dr.histogram.HistogramDispatcher;
import gov.nasa.kepler.dr.history.HistoryDispatcher;
import gov.nasa.kepler.dr.pixels.LongCadencePixelDispatcher;
import gov.nasa.kepler.dr.pixels.RclcPixelDispatcher;
import gov.nasa.kepler.dr.pixels.ShortCadencePixelDispatcher;
import gov.nasa.kepler.dr.pmrf.PmrfDispatcher;
import gov.nasa.kepler.dr.refpixels.RefPixelDispatcher;
import gov.nasa.kepler.dr.sclk.SclkDispatcher;
import gov.nasa.kepler.dr.target.MaskTableDispatcher;
import gov.nasa.kepler.dr.target.TargetListDispatcher;
import gov.nasa.kepler.dr.target.TargetListSetDispatcher;
import gov.nasa.kepler.dr.thruster.ThrusterDataDispatcher;
import gov.nasa.kepler.dr.ukirt.UkirtImageDispatcher;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.PmrfLog.PmrfType;
import gov.nasa.kepler.mc.fc.EphemerisOperations;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;

import java.util.HashMap;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class acts as a sorter for the files listed in an SDNM/GRNM/SENM XML
 * file (Notification Message, see DMC-SOC ICD).
 * 
 * Returns and caches the correct type of Dispatcher based on the filename
 * suffix so that the file can then be added to the dispatcher
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class DispatcherWrapperFactory {
    private static final Log log = LogFactory.getLog(DispatcherWrapperFactory.class);

    public static final String LONG_CADENCE_TARGET = "_lcs-targ.fits";
    public static final String LONG_CADENCE_COLLATERAL = "_lcs-col.fits";
    public static final String LONG_CADENCE_BACKGROUND = "_lcs-bkg.fits";
    public static final String SHORT_CADENCE_TARGET = "_scs-targ.fits";
    public static final String SHORT_CADENCE_COLLATERAL = "_scs-col.fits";

    public static final String LONG_CADENCE_TARGET_PMRF = DrFsIdFactory.LONG_CADENCE_TARGET_PMRF;
    public static final String LONG_CADENCE_COLLATERAL_PMRF = DrFsIdFactory.LONG_CADENCE_COLLATERAL_PMRF;
    public static final String BACKGROUND_PMRF = DrFsIdFactory.BACKGROUND_PMRF;
    public static final String SHORT_CADENCE_TARGET_PMRF = DrFsIdFactory.SHORT_CADENCE_TARGET_PMRF;
    public static final String SHORT_CADENCE_COLLATERAL_PMRF = DrFsIdFactory.SHORT_CADENCE_COLLATERAL_PMRF;

    public static final String HISTOGRAM = "_comp-hist.fits";

    public static final String ANCILLARY = "_anc-eng.fits";

    // Leave .gz suffix off of this constant to allow processing of compressed
    // or uncompressed files.
    public static final String THRUSTER_DATA = "_tfr.txt";

    public static final String FFI_ORIGINAL = "_ffi-orig.fits";
    public static final String FFI_CALIBRATED = "_ffi-cal.fits";

    public static final String HISTORY = "-history.txt";

    public static final String DATA_ANOMALY_SUFFIX = "-data-anomaly.xml";

    public static final String CLOCK_STATE_MASK_PREFIX = "state_mask";
    public static final String CLOCK_STATE_MASK_SUFFIX = "fits";

    public static final String REFERENCE_PIXEL = "_rp.rp";

    public static final String SPACECRAFT_EPHEMERIS = EphemerisOperations.SPACECRAFT_EPHEMERIS_SUFFIX;
    public static final String PLANETARY_EPHEMERIS_PREFIX = EphemerisOperations.PLANETARY_EPHEMERIS_PREFIX;
    public static final String PLANETARY_EPHEMERIS_SUFFIX = EphemerisOperations.PLANETARY_EPHEMERIS_SUFFIX;
    public static final String LEAP_SECONDS = EphemerisOperations.LEAP_SECONDS_SUFFIX;

    public static final String SCLK = ".tsc";

    public static final String CRCT = "-crct.fits";

    public static final String GAP_REPORT = "-gaps.xml";

    public static final String CONFIG_MAP = "_map.xml";

    public static final String UKIRT_PNG = "_ukirt.png";

    private Map<DispatcherType, DispatcherWrapper> dispatcherWrappers = new HashMap<DispatcherType, DispatcherWrapper>();

    public DispatcherWrapper createDispatcherWrapper(String sourceDirectory,
        String fileNameSuffix,
        NotificationMessageHandler notificationMessageHandler) {

        DispatcherType dispatcherType = getDispatcherType(fileNameSuffix);

        return getDispatcherWrapper(sourceDirectory,
            notificationMessageHandler, dispatcherType);
    }

    public DispatcherWrapper createDispatcherByNmFile(String sourceDirectory,
        String nmFileNameSuffix,
        NotificationMessageHandler notificationMessageHandler) {

        DispatcherType dispatcherType = getDispatcherTypeByNmFile(nmFileNameSuffix);

        return getDispatcherWrapper(sourceDirectory,
            notificationMessageHandler, dispatcherType);
    }

    private DispatcherWrapper getDispatcherWrapper(String sourceDirectory,
        NotificationMessageHandler notificationMessageHandler,
        DispatcherType dispatcherType) {
        DispatcherWrapper dispatcherWrapper = dispatcherWrappers.get(dispatcherType);

        if (dispatcherWrapper != null) {
            return dispatcherWrapper;
        }

        log.info("Creating " + dispatcherType + " dispatcher");
        Dispatcher dispatcher = null;
        switch (dispatcherType) {
            case LONG_CADENCE_PIXEL:
                dispatcher = new LongCadencePixelDispatcher();
                break;
            case SHORT_CADENCE_PIXEL:
                dispatcher = new ShortCadencePixelDispatcher();
                break;
            case ANCILLARY:
                dispatcher = new AncillaryDispatcher();
                break;
            case THRUSTER_DATA:
                dispatcher = new ThrusterDataDispatcher();
                break;
            case CRCT:
                dispatcher = new CrctDispatcher();
                break;
            case SPACECRAFT_EPHEMERIS:
                dispatcher = new SpacecraftEphemerisDispatcher();
                break;
            case PLANETARY_EPHEMERIS:
                dispatcher = new PlanetaryEphemerisDispatcher();
                break;
            case LEAP_SECONDS:
                dispatcher = new LeapSecondsDispatcher();
                break;
            case FFI:
                dispatcher = new FfiDispatcher();
                break;
            case GAP_REPORT:
                dispatcher = new GapReportDispatcher();
                break;
            case CONFIG_MAP:
                dispatcher = new ConfigMapDispatcher();
                break;
            case HISTOGRAM:
                dispatcher = new HistogramDispatcher();
                break;
            case HISTORY:
                dispatcher = new HistoryDispatcher();
                break;
            case CLOCK_STATE_MASK:
                throw new UnsupportedOperationException(
                    "ClockStateMaskDispatcher has not been implemented.");
            case DATA_ANOMALY:
                dispatcher = new DataAnomalyDispatcher();
                break;
            case TARGET_LIST:
                dispatcher = new TargetListDispatcher();
                break;
            case TARGET_LIST_SET:
                dispatcher = new TargetListSetDispatcher();
                break;
            case MASK_TABLE:
                dispatcher = new MaskTableDispatcher();
                break;
            case LONG_CADENCE_TARGET_PMRF:
                dispatcher = new PmrfDispatcher(PmrfType.LONG_CADENCE_TARGET);
                break;
            case SHORT_CADENCE_TARGET_PMRF:
                dispatcher = new PmrfDispatcher(PmrfType.SHORT_CADENCE_TARGET);
                break;
            case BACKGROUND_PMRF:
                dispatcher = new PmrfDispatcher(PmrfType.BACKGROUND);
                break;
            case LONG_CADENCE_COLLATERAL_PMRF:
                dispatcher = new PmrfDispatcher(
                    PmrfType.LONG_CADENCE_COLLATERAL);
                break;
            case SHORT_CADENCE_COLLATERAL_PMRF:
                dispatcher = new PmrfDispatcher(
                    PmrfType.SHORT_CADENCE_COLLATERAL);
                break;
            case REF_PIXEL:
                dispatcher = new RefPixelDispatcher();
                break;
            case SCLK:
                dispatcher = new SclkDispatcher();
                break;
            case RCLC_PIXEL:
                dispatcher = new RclcPixelDispatcher();
                break;
            case UKIRT_IMAGE:
                dispatcher = new UkirtImageDispatcher();
                break;

            default:
                throw new DispatchException("Invalid dispatcher type: "
                    + dispatcherType);
        }

        dispatcherWrapper = new DispatcherWrapper(dispatcher, dispatcherType,
            sourceDirectory, notificationMessageHandler);

        dispatcherWrappers.put(dispatcherType, dispatcherWrapper);

        return dispatcherWrapper;
    }

    private DispatcherType getDispatcherType(String suffix) {
        if (suffix.contains(LONG_CADENCE_TARGET)) {
            return DispatcherType.LONG_CADENCE_PIXEL;
        } else if (suffix.contains(LONG_CADENCE_COLLATERAL)) {
            return DispatcherType.LONG_CADENCE_PIXEL;
        } else if (suffix.contains(LONG_CADENCE_BACKGROUND)) {
            return DispatcherType.LONG_CADENCE_PIXEL;
        } else if (suffix.contains(SHORT_CADENCE_TARGET)) {
            return DispatcherType.SHORT_CADENCE_PIXEL;
        } else if (suffix.contains(SHORT_CADENCE_COLLATERAL)) {
            return DispatcherType.SHORT_CADENCE_PIXEL;
        } else if (suffix.contains(HISTOGRAM)) {
            return DispatcherType.HISTOGRAM;
        } else if (suffix.contains(ANCILLARY)) {
            return DispatcherType.ANCILLARY;
        } else if (suffix.contains(THRUSTER_DATA)) {
            return DispatcherType.THRUSTER_DATA;
        } else if (suffix.contains(FFI_ORIGINAL)) {
            return DispatcherType.FFI;
        } else if (suffix.contains(FFI_CALIBRATED)) {
            return DispatcherType.FFI;
        } else if (suffix.contains(CRCT)) {
            return DispatcherType.CRCT;
        } else if (suffix.contains(HISTORY)) {
            return DispatcherType.HISTORY;
        } else if (suffix.contains(CLOCK_STATE_MASK_PREFIX)
            && suffix.contains(CLOCK_STATE_MASK_SUFFIX)) {
            return DispatcherType.CLOCK_STATE_MASK;
        } else if (suffix.contains(DATA_ANOMALY_SUFFIX)) {
            return DispatcherType.DATA_ANOMALY;
        } else if (suffix.contains(REFERENCE_PIXEL)) {
            return DispatcherType.REF_PIXEL;
        } else if (suffix.contains(SPACECRAFT_EPHEMERIS)) {
            return DispatcherType.SPACECRAFT_EPHEMERIS;
        } else if (suffix.contains(PLANETARY_EPHEMERIS_PREFIX)
            && suffix.contains(PLANETARY_EPHEMERIS_SUFFIX)) {
            return DispatcherType.PLANETARY_EPHEMERIS;
        } else if (suffix.contains(LEAP_SECONDS)) {
            return DispatcherType.LEAP_SECONDS;
        } else if (suffix.contains(SCLK)) {
            return DispatcherType.SCLK;
        } else if (suffix.contains(LONG_CADENCE_TARGET_PMRF)) {
            return DispatcherType.LONG_CADENCE_TARGET_PMRF;
        } else if (suffix.contains(SHORT_CADENCE_TARGET_PMRF)) {
            return DispatcherType.SHORT_CADENCE_TARGET_PMRF;
        } else if (suffix.contains(BACKGROUND_PMRF)) {
            return DispatcherType.BACKGROUND_PMRF;
        } else if (suffix.contains(LONG_CADENCE_COLLATERAL_PMRF)) {
            return DispatcherType.LONG_CADENCE_COLLATERAL_PMRF;
        } else if (suffix.contains(SHORT_CADENCE_COLLATERAL_PMRF)) {
            return DispatcherType.SHORT_CADENCE_COLLATERAL_PMRF;
        } else if (suffix.contains(GAP_REPORT)) {
            return DispatcherType.GAP_REPORT;
        } else if (suffix.contains(CONFIG_MAP)) {
            return DispatcherType.CONFIG_MAP;
        } else if (suffix.contains(UKIRT_PNG)) {
            return DispatcherType.UKIRT_IMAGE;
        } else {
            throw new DispatchException("unknown file suffix for fileName = "
                + suffix);
        }
    }

    private DispatcherType getDispatcherTypeByNmFile(String nmSuffix) {
        if (nmSuffix.contains(FileWatcher.TLNM_NOTIFICATION_MSG_EXTENSION)) {
            return DispatcherType.TARGET_LIST;
        } else if (nmSuffix.contains(FileWatcher.TLSNM_NOTIFICATION_MSG_EXTENSION)) {
            return DispatcherType.TARGET_LIST_SET;
        } else if (nmSuffix.contains(FileWatcher.MTNM_NOTIFICATION_MSG_EXTENSION)) {
            return DispatcherType.MASK_TABLE;
        } else if (nmSuffix.contains(FileWatcher.RCLCNM_NOTIFICATION_MSG_EXTENSION)) {
            return DispatcherType.RCLC_PIXEL;
        } else {
            throw new DispatchException(
                "unknown nm file suffix for nmFileName = " + nmSuffix);
        }
    }

    public void clear() {
        dispatcherWrappers.clear();
    }

    public Map<DispatcherType, DispatcherWrapper> getDispatcherWrappers() {
        return dispatcherWrappers;
    }

}
