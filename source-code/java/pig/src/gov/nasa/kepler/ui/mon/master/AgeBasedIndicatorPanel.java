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

package gov.nasa.kepler.ui.mon.master;

import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.services.process.AbstractPipelineProcess;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import javax.swing.Timer;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Superclass for {@link IndicatorPanel}s whose colors change based on the
 * length of time since the last status message was received from that source.
 * 
 * @author tklaus
 * 
 */
@SuppressWarnings("serial")
public abstract class AgeBasedIndicatorPanel extends IndicatorPanel {
    private static final Log log = LogFactory.getLog(AgeBasedIndicatorPanel.class);

    protected static final String AGE_CHECK_INTERVAL_PROP = "pig.status-panel.ageCheckIntervalMillis";
    protected static final int AGE_CHECK_INTERVAL_DEFAULT = 1000;
    protected static final float AMBER_THRESHOLD_FACTOR = 2;
    protected static final float RED_THRESHOLD_FACTOR = 3;

    protected Timer ageCheckTimer;
    protected int reportIntervalMillis;
    protected int amberThresholdMillis;
    protected int redThresholdMillis;

    protected Map<String, Indicator> currentIndicators = Collections.synchronizedMap(new HashMap<String, Indicator>());

    public AgeBasedIndicatorPanel(Indicator parentIndicator) {
        super(parentIndicator);
        initAgeTimer();
    }

    public AgeBasedIndicatorPanel(Indicator parentIndicator, int numRows, boolean hasTitleButtonBar) {
        super(parentIndicator, numRows, hasTitleButtonBar);
        initAgeTimer();
    }

    private void initAgeTimer() {

        int ageCheckIntervalMillis = AGE_CHECK_INTERVAL_DEFAULT;
        reportIntervalMillis = AbstractPipelineProcess.REPORT_INTERVAL_MILLIS_DEFAULT;

        try {
            Configuration configService = ConfigurationServiceFactory.getInstance();
            ageCheckIntervalMillis = configService.getInt(AGE_CHECK_INTERVAL_PROP, AGE_CHECK_INTERVAL_DEFAULT);
            reportIntervalMillis = configService.getInt(AbstractPipelineProcess.PROCESS_STATUS_REPORT_INTERVAL_MILLIS_PROP,
                AbstractPipelineProcess.REPORT_INTERVAL_MILLIS_DEFAULT);
        } catch (PipelineException e) {
            log.warn("failed to retrieve values from config service", e);
        }

        amberThresholdMillis = (int) (reportIntervalMillis * AMBER_THRESHOLD_FACTOR);
        redThresholdMillis = (int) (reportIntervalMillis * RED_THRESHOLD_FACTOR);

        ageCheckTimer = new Timer(ageCheckIntervalMillis, new ActionListener() {
            public void actionPerformed(ActionEvent event) {
                doAgeCheck();
            }
        });
        ageCheckTimer.start();
    }

    @Override
    public void dismissAll() {
        synchronized (currentIndicators) {
            for (Indicator indicator : currentIndicators.values()) {
                super.removeIndicator(indicator);
            }
            currentIndicators.clear();
        }
    }

    /**
     * Always called from the event dispatcher thread
     */
    protected void doAgeCheck() {

        // the State of the unhappiestChild gets propagated up to the parent
        Indicator.State unhappiestChild = Indicator.State.GREEN;

        synchronized (currentIndicators) {
            for (Indicator indicator : currentIndicators.values()) {
                long age = System.currentTimeMillis() - indicator.getLastUpdated();
                Indicator.State currentState;

                if (age > redThresholdMillis) {
                    currentState = Indicator.State.RED;
                } else if (age > amberThresholdMillis) {
                    currentState = Indicator.State.AMBER;
                } else {
                    currentState = Indicator.State.GREEN;
                }

                log.debug("indicator: " + indicator.getId() + " is " + currentState);

                indicator.setState(currentState);

                if (currentState.ordinal() > unhappiestChild.ordinal()) {
                    unhappiestChild = currentState;
                }
            }
        }

        parentIndicator.setState(unhappiestChild);
    }

    @Override
    public void removeIndicator(Indicator indicator) {
        super.removeIndicator(indicator);
        currentIndicators.remove(indicator.getId());
    }

}
