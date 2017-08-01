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

package gov.nasa.kepler.ppa;

import gov.nasa.kepler.hibernate.ppa.MetricReport;
import gov.nasa.kepler.mc.BoundsReport;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.spiffy.common.persistable.OracleDouble;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

/**
 * Report for a single metric.
 * <p>
 * Subclasses should create a {@code createReport} method that returns an
 * appropriate subclass of {@link MetricReport}.
 * 
 * @author Bill Wohler
 */
public class PpaMetricReport implements Persistable {

    /**
     * Time of the last sample (reference pixel file) used in determining the
     * summary value and uncertainty.
     */
    @OracleDouble
    private double time;

    /**
     * Summary value for this metric.
     */
    private float value;

    /**
     * The estimated mean value of the metric at the specified time.
     */
    private float meanValue;

    /**
     * The estimated uncertainty of the metric at the specified time.
     */
    private float uncertainty;

    private float adaptiveBoundsXFactor;

    /**
     * The metric status indicator at the specified time.
     */
    private int trackAlertLevel;

    /**
     * The metric status indicator for the future.
     */
    private int trendAlertLevel;

    /**
     * Adaptive bounds report, if available, for this metric.
     */
    private BoundsReport adaptiveBoundsReport = new BoundsReport();

    /**
     * Fixed bounds report for this metric.
     */
    private BoundsReport fixedBoundsReport = new BoundsReport();

    /**
     * Trend report for this metric.
     */
    private PpaTrendReport trendReport = new PpaTrendReport();

    /**
     * List of alerts, if any, for this metric over the report duration.
     */
    private List<ModuleAlert> alerts = new ArrayList<ModuleAlert>();

    public double getTime() {
        return time;
    }

    public void setTime(double time) {
        this.time = time;
    }

    public float getValue() {
        return value;
    }

    public void setValue(float value) {
        this.value = value;
    }

    public float getMeanValue() {
        return meanValue;
    }

    public void setMeanValue(float meanValue) {
        this.meanValue = meanValue;
    }

    public float getUncertainty() {
        return uncertainty;
    }

    public void setUncertainty(float uncertainty) {
        this.uncertainty = uncertainty;
    }

    public float getAdaptiveBoundsXFactor() {
        return adaptiveBoundsXFactor;
    }

    public void setAdaptiveBoundsXFactor(float adaptiveBoundsXFactor) {
        this.adaptiveBoundsXFactor = adaptiveBoundsXFactor;
    }

    public int getTrackAlertLevel() {
        return trackAlertLevel;
    }

    public void setTrackAlertLevel(int trackAlertLevel) {
        this.trackAlertLevel = trackAlertLevel;
    }

    public int getTrendAlertLevel() {
        return trendAlertLevel;
    }

    public void setTrendAlertLevel(int trendAlertLevel) {
        this.trendAlertLevel = trendAlertLevel;
    }

    public BoundsReport getAdaptiveBoundsReport() {
        return adaptiveBoundsReport;
    }

    public void setAdaptiveBoundsReport(BoundsReport adaptiveBoundsReport) {
        this.adaptiveBoundsReport = adaptiveBoundsReport;
    }

    public BoundsReport getFixedBoundsReport() {
        return fixedBoundsReport;
    }

    public void setFixedBoundsReport(BoundsReport fixedBoundsReport) {
        this.fixedBoundsReport = fixedBoundsReport;
    }

    public PpaTrendReport getTrendReport() {
        return trendReport;
    }

    public void setTrendReport(PpaTrendReport trendReport) {
        this.trendReport = trendReport;
    }

    public List<ModuleAlert> getAlerts() {
        return alerts;
    }

    public void setAlerts(List<ModuleAlert> alerts) {
        this.alerts = alerts;
    }
}
