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

package gov.nasa.kepler.mr.scriptlet;

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.mr.ParameterUtil;
import gov.nasa.spiffy.common.lang.StringUtils;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import net.sf.jasperreports.engine.JRDataSource;
import net.sf.jasperreports.engine.JRScriptletException;
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;

/**
 * This is the scriptlet class for the focal plane characterization report.
 * 
 * @author Bill Wohler
 */
public class FcScriptlet extends BaseScriptlet {

    private static final Log log = LogFactory.getLog(FcScriptlet.class);

    public static enum FcModelType {
        TWOD_BLACK(HistoryModelName.TWODBLACK),
        BAD_PIXELS(HistoryModelName.BAD_PIXELS),
        LARGE_FLAT_FIELD(HistoryModelName.LARGEFLATFIELD),
        SMALL_FLAT_FIELD(HistoryModelName.SMALLFLATFIELD),
        GAIN(HistoryModelName.GAIN),
        GEOMETRY(HistoryModelName.GEOMETRY),
        LINEARITY(HistoryModelName.LINEARITY),
        POINTING(HistoryModelName.POINTING),
        PRF(HistoryModelName.PRF),
        READ_NOISE(HistoryModelName.READNOISE),
        ROLL_TIME(HistoryModelName.ROLLTIME),
        SATURATION(HistoryModelName.SATURATION),
        UNDERSHOOT(HistoryModelName.UNDERSHOOT);

        private final String name;
        private final HistoryModelName historyModelName;

        private FcModelType(HistoryModelName historyModelName) {
            this.historyModelName = historyModelName;
            String type = super.toString();
            if (type.equals("TWOD_BLACK")) {
                name = "2D Black";
            } else if (type.equals("PRF")) {
                name = super.toString();
            } else {
                name = StringUtils.constantToCamelWithSpaces(super.toString())
                    .intern();
            }
        }

        public String getName() {
            return name;
        }

        public HistoryModelName getModelName() {
            return historyModelName;
        }
    }

    public static final String REPORT_NAME_FC = "fc";
    public static final String REPORT_TITLE_FC = "Focal Plane Characterization";
    private static final String PARAM_TYPE = "modelType";
    private static final String PARAM_RECENT = "mostRecentOnly";

    private static FcCrud fcCrud = new FcCrud();

    private Set<HistoryModelName> modelTypes;
    private boolean mostRecentEnabled = false;

    private List<History> history;

    @Override
    public void afterReportInit() throws JRScriptletException {
        super.afterReportInit();

        expectStartEndTimeParameters();
        if (getStartTime() == null || getEndTime() == null) {
            return;
        }

        // Grab modelType from parameters.
        String modelTypeStrings[] = getRequestParameters(PARAM_TYPE,
            String.format(ParameterUtil.MISSING_PARAM_ERROR_TEXT, PARAM_TYPE));

        if (modelTypeStrings != null
            && modelTypeStrings.length != HistoryModelName.values().length) {
            modelTypes = convertToEnum(modelTypeStrings);
        }

        // Grab mostRecentOnly parameter.
        String mostRecentString = getRequestParameter(PARAM_RECENT, null);
        if (mostRecentString != null && mostRecentString.length() > 0) {
            mostRecentEnabled = Boolean.valueOf(mostRecentString)
                .booleanValue();
        }

        try {
            history = fcCrud.retrieveHistoryByIngestDate(getStartTime(),
                getEndTime(), modelTypes);

            if (isMostRecentEnabled()) {
                history = mostRecentOnly(history, modelTypes);
            }

            if (history.size() == 0 && modelTypes == null) {
                String text = String.format(
                    "No FC history present from %s to %s.",
                    getDateFormatter().format(getStartTime()),
                    getDateFormatter().format(getEndTime()));
                setErrorText(text);
                log.error(text);
            }
        } catch (HibernateException e) {
            String text = "Could not obtain FC history from "
                + getDateFormatter().format(getStartTime()) + " to "
                + getDateFormatter().format(getEndTime()) + ": ";
            setErrorText(text + e + "\nCause: " + e.getCause());
            log.error(text, e);
            return;
        }
    }

    public boolean isModelEnabled(HistoryModelName modelType) {
        return modelTypes == null || modelTypes.contains(modelType);
    }

    public boolean is2DBlackEnabled() {
        return isModelEnabled(HistoryModelName.TWODBLACK);
    }

    public boolean isBadPixelsEnabled() {
        return isModelEnabled(HistoryModelName.BAD_PIXELS);
    }

    public boolean isLargeFlatFieldEnabled() {
        return isModelEnabled(HistoryModelName.LARGEFLATFIELD);
    }

    public boolean isSmallFlatFieldEnabled() {
        return isModelEnabled(HistoryModelName.SMALLFLATFIELD);
    }

    public boolean isGainEnabled() {
        return isModelEnabled(HistoryModelName.GAIN);
    }

    public boolean isGeometryEnabled() {
        return isModelEnabled(HistoryModelName.GEOMETRY);
    }

    public boolean isLinearityEnabled() {
        return isModelEnabled(HistoryModelName.LINEARITY);
    }

    public boolean isPointingEnabled() {
        return isModelEnabled(HistoryModelName.POINTING);
    }

    public boolean isPrfEnabled() {
        return isModelEnabled(HistoryModelName.PRF);
    }

    public boolean isReadNoiseEnabled() {
        return isModelEnabled(HistoryModelName.READNOISE);
    }

    public boolean isRollTimeEnabled() {
        return isModelEnabled(HistoryModelName.ROLLTIME);
    }

    public boolean isSaturationEnabled() {
        return isModelEnabled(HistoryModelName.SATURATION);
    }

    public boolean isUndershootEnabled() {
        return isModelEnabled(HistoryModelName.UNDERSHOOT);
    }

    public boolean isMostRecentEnabled() {
        return mostRecentEnabled;
    }

    public String getMostRecentOnly() {
        return Boolean.toString(isMostRecentEnabled());
    }

    /**
     * Returns a {@link JRDataSource} which wraps all of the {@link History}
     * elements of the given type for the current time range.
     * 
     * @param type
     * 
     * @return a non-{@code null} data source.
     * @throws JRScriptletException if the data source could not be created.
     * @throws NullPointerException if the type is {@code null}.
     */
    public JRDataSource dataSource(HistoryModelName type)
        throws JRScriptletException {

        log.debug("Filling data source for history elements of type " + type);

        List<HistoryFacade> list = new ArrayList<HistoryFacade>();
        if (history == null) {
            log.error("Should not be called if FC history is unavailable");
            return new JRBeanCollectionDataSource(list);
        }

        for (History historyItem : history) {
            if (historyItem.getModelType() == type) {
                list.add(new HistoryFacade(historyItem));
            }
        }

        return new JRBeanCollectionDataSource(list);
    }

    private Set<HistoryModelName> convertToEnum(String[] modelTypeStrings) {

        Set<HistoryModelName> modelNames = new HashSet<HistoryModelName>();
        if (modelTypeStrings != null) {
            for (String modelTypeString : modelTypeStrings) {
                FcModelType modelType = FcModelType.valueOf(modelTypeString);
                modelNames.add(modelType.getModelName());
            }
        }
        return modelNames;
    }

    private List<History> mostRecentOnly(List<History> allHistory,
        Set<HistoryModelName> modelTypes) {

        Set<HistoryModelName> modelTypesNeeded = new HashSet<HistoryModelName>(
            modelTypes);

        List<History> mostRecentHistory = new ArrayList<History>();
        for (History history : allHistory) {
            if (modelTypesNeeded.contains(history.getModelType())) {
                mostRecentHistory.add(history);
                modelTypesNeeded.remove(history.getModelType());
                if (modelTypesNeeded.isEmpty()) {
                    break;
                }
            }
        }

        return mostRecentHistory;
    }

    /**
     * A value-added facade to the {@link History} object.
     * 
     * @author Bill Wohler
     */
    public class HistoryFacade {
        private History history;

        public HistoryFacade(History history) {
            this.history = history;
        }

        public String getIngestTime() {
            return getDateFormatter().format(
                ModifiedJulianDate.mjdToDate(history.getIngestTime()));
        }

        public String getDescription() {
            return history.getDescription() != null ? history.getDescription()
                : "";
        }
    }
}
