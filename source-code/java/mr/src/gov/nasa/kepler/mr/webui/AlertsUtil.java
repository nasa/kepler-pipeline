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

package gov.nasa.kepler.mr.webui;

import gov.nasa.kepler.hibernate.services.AlertLogCrud;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Provides methods for obtaining alerts.
 * 
 * @author Bill Wohler
 */
public class AlertsUtil extends AbstractUtil {

    private static final Log log = LogFactory.getLog(AlertsUtil.class);

    private static final String[] sortedSeverityPrefixes = new String[] {
        "fatal", "sever", "err", "warn", "info", "debug", "trace" };

    public String retrieveAlertComponents() {
        dbPrepare();

        List<String> components = null;
        try {
            components = new AlertLogCrud().retrieveComponents();
        } catch (Exception e) {
            return displayError("Could not obtain alert components: ", e);
        }

        if (components.size() == 0) {
            String errorText = "No alert components have been created.";
            return displayError(errorText);
        }

        // Generate select list option rows.
        StringBuilder options = new StringBuilder();
        for (String component : components) {
            options.append("<option value=\"")
                .append(component)
                .append('\"')
                .append(" selected")
                .append(">")
                .append(component)
                .append("</option>\r");
        }

        log.debug("Retrieved " + components.size() + " components");

        return options.toString();
    }

    /**
     * Sorts the given list of severities by severity. Unrecognized severities
     * are appended to the end of the sorted list in the order in which they
     * were received.
     * <p>
     * Ideally, the severities would be stored in the database using an enum so
     * that their severity order could be preserved. Without that, this
     * heuristic is the best we can do. We can only take a best guess of the
     * severity strings that are going to be used.
     */
    public static List<String> sortSeveritiesBySeverity(List<String> severities) {
        List<String> sortedSeverities = new ArrayList<String>(severities.size());

        // Sort severities we recognize.
        for (String sortedSeverityPrefix : sortedSeverityPrefixes) {
            for (String severity : severities) {
                if (severity.toLowerCase()
                    .startsWith(sortedSeverityPrefix)) {
                    sortedSeverities.add(severity);
                    break;
                }
            }
        }

        // Append severities we didn't.
        for (String severity : severities) {
            boolean added = false;
            for (String sortedSeverity : sortedSeverities) {
                if (severity.equals(sortedSeverity)) {
                    added = true;
                    break;
                }
            }
            if (!added) {
                sortedSeverities.add(severity);
            }
        }

        return sortedSeverities;
    }

    public String retrieveAlertSeverities() {
        dbPrepare();

        List<String> severities = null;
        try {
            severities = new AlertLogCrud().retrieveSeverities();
        } catch (Exception e) {
            return displayError("Could not obtain alert severities: ", e);
        }

        if (severities.size() == 0) {
            String errorText = "No alert severities have been created.";
            return displayError(errorText);
        }

        // Generate select list option rows.
        StringBuilder options = new StringBuilder();
        for (String severity : sortSeveritiesBySeverity(severities)) {
            options.append("<option value=\"")
                .append(severity)
                .append('\"')
                .append(" selected")
                .append(">")
                .append(severity)
                .append("</option>\r");
        }

        log.debug("Retrieved " + severities.size() + " severities");

        return options.toString();
    }
}
