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

package gov.nasa.kepler.ui.common;

import java.util.Timer;
import java.util.TimerTask;
import java.util.prefs.BackingStoreException;
import java.util.prefs.Preferences;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.jdesktop.application.Application;
import org.jdesktop.application.ResourceMap;

/**
 * Preferences for the KSOC GUI. Use the {@link #getInstance()} method to get a
 * {@link Preferences} and use its get* and put* methods normally.
 * <p>
 * Note that {@link Preferences#flush()} is called occasionally to ensure that
 * the current settings are persisted.
 * <p>
 * On Linux, the preferences for the UI are stored in the file
 * {@code ~/.java/.userPrefs/gov/nasa/kepler/ui/common/prefs.xml}.
 * 
 * @see Preferences
 * 
 * @author Bill Wohler
 */
public class KsocPreferences {

    private static Preferences preferences;
    private static ResourceMap resourceMap;
    private static final Log log = LogFactory.getLog(KsocPreferences.class);
    private static final String PREFERENCES_TIMER = "KSOC Preferences Updater";
    private static final long PREFERENCE_UPDATE_PERIOD = 5000;

    /**
     * Returns a {@link Preferences} object.
     * 
     * @return a {@link Preferences} object.
     */
    public static synchronized Preferences getInstance() {
        try {
            if (preferences == null) {
                resourceMap = Application.getInstance()
                    .getContext()
                    .getResourceMap();
                preferences = Preferences.userNodeForPackage(KsocPreferences.class);
                Timer timer = new Timer(PREFERENCES_TIMER);
                timer.schedule(new PreferenceUpdater(),
                    PREFERENCE_UPDATE_PERIOD, PREFERENCE_UPDATE_PERIOD);
            }
        } catch (SecurityException e) {
            log.warn(resourceMap.getString("getInstance.securityException",
                e.getMessage()));
        }

        return preferences;
    }

    /**
     * A timer that flushes the preference cache to disk occasionally.
     * 
     * @author Bill Wohler
     */
    private static class PreferenceUpdater extends TimerTask {
        @Override
        public void run() {
            try {
                preferences.flush();
            } catch (BackingStoreException e) {
                log.warn(resourceMap.getString("PreferenceUpdater.run",
                    e.getMessage()));
            }
        }
    }
}
