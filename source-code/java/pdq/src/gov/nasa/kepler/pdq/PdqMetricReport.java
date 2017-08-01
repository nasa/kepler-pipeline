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

package gov.nasa.kepler.pdq;

import gov.nasa.kepler.mc.BoundsReport;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

/**
 * PDQ summary report for a single metric including adpative bounds information
 * and alerts.
 * 
 * @author Forrest Girouard
 * 
 */
public class PdqMetricReport implements Persistable {

    /**
     * Summary value for this metric.
     */
    private float value;

    /**
     * Summary value uncertainty.
     */
    private float uncertainty;

    /**
     * Time of the last sample (reference pixel file) used in determining the
     * summary value and uncertainty.
     */
    private double time;

    /**
     * Adaptive bounds report, if available, for this metric.
     */
    private BoundsReport adaptiveBoundsReport = new BoundsReport();

    /**
     * Fixed bounds report for this metric.
     */
    private BoundsReport fixedBoundsReport = new BoundsReport();

    /**
     * List of alerts, if any, for this metric over the report duration (
     * {@link gov.nasa.kepler.pdq.PdqModuleParameters.getReportDurationTime}).
     */
    private List<ModuleAlert> alerts = new ArrayList<ModuleAlert>();

    public PdqMetricReport() {
    }

    public PdqMetricReport(final float value, final float uncertainty,
        final double time) {
        this.value = value;
        this.uncertainty = uncertainty;
        this.time = time;
    }

    public BoundsReport getAdaptiveBoundsReport() {
        return adaptiveBoundsReport;
    }

    public void setAdaptiveBoundsReport(final BoundsReport adaptiveBoundsReport) {
        this.adaptiveBoundsReport = adaptiveBoundsReport;
    }

    public List<ModuleAlert> getAlerts() {
        return alerts;
    }

    public boolean hasAlerts() {
        return alerts != null && !alerts.isEmpty();
    }

    public void setAlerts(final List<ModuleAlert> alerts) {
        this.alerts = alerts;
    }

    public BoundsReport getFixedBoundsReport() {
        return fixedBoundsReport;
    }

    public void setFixedBoundsReport(final BoundsReport fixedBoundsReport) {
        this.fixedBoundsReport = fixedBoundsReport;
    }

    public double getTime() {
        return time;
    }

    public void setTime(final double time) {
        this.time = time;
    }

    public float getUncertainty() {
        return uncertainty;
    }

    public void setUncertainty(final float uncertainty) {
        this.uncertainty = uncertainty;
    }

    public float getValue() {
        return value;
    }

    public void setValue(final float value) {
        this.value = value;
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME
            * result
            + (adaptiveBoundsReport == null ? 0
                : adaptiveBoundsReport.hashCode());
        result = PRIME * result + (alerts == null ? 0 : alerts.hashCode());
        result = PRIME * result
            + (fixedBoundsReport == null ? 0 : fixedBoundsReport.hashCode());
        long temp;
        temp = Double.doubleToLongBits(time);
        result = PRIME * result + (int) (temp ^ temp >>> 32);
        result = PRIME * result + Float.floatToIntBits(uncertainty);
        result = PRIME * result + Float.floatToIntBits(value);
        return result;
    }

    @Override
    public boolean equals(final Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof PdqMetricReport)) {
            return false;
        }
        final PdqMetricReport other = (PdqMetricReport) obj;
        if (adaptiveBoundsReport == null) {
            if (other.adaptiveBoundsReport != null) {
                return false;
            }
        } else if (!adaptiveBoundsReport.equals(other.adaptiveBoundsReport)) {
            return false;
        }
        if (alerts == null) {
            if (other.alerts != null) {
                return false;
            }
        } else if (!alerts.equals(other.alerts)) {
            return false;
        }
        if (fixedBoundsReport == null) {
            if (other.fixedBoundsReport != null) {
                return false;
            }
        } else if (!fixedBoundsReport.equals(other.fixedBoundsReport)) {
            return false;
        }
        if (Double.doubleToLongBits(time) != Double.doubleToLongBits(other.time)) {
            return false;
        }
        if (Float.floatToIntBits(uncertainty) != Float.floatToIntBits(other.uncertainty)) {
            return false;
        }
        if (Float.floatToIntBits(value) != Float.floatToIntBits(other.value)) {
            return false;
        }
        return true;
    }
}
