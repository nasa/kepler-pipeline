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

import gov.nasa.kepler.hibernate.pdq.FocalPlaneMetricReport;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * PDQ metric reports across the whole focal plane for a single target table.
 * 
 * @author Forrest Girouard
 * @see gov.nasa.kepler.pdq.FocalPlaneMetricReport.MetricType
 * 
 */
public class PdqFocalPlaneReport implements Persistable {

    private PdqMetricReport maxAttitudeResidualInPixels = new PdqMetricReport();
    private PdqMetricReport deltaAttitudeDec = new PdqMetricReport();
    private PdqMetricReport deltaAttitudeRa = new PdqMetricReport();
    private PdqMetricReport deltaAttitudeRoll = new PdqMetricReport();

    public PdqFocalPlaneReport() {
    }

    public PdqFocalPlaneReport(
        final PdqMetricReport maxAttitudeResidualInPixels,
        final PdqMetricReport deltaAttitudeDec,
        final PdqMetricReport deltaAttitudeRa,
        final PdqMetricReport deltaAttitudeRoll) {
        this.maxAttitudeResidualInPixels = maxAttitudeResidualInPixels;
        this.deltaAttitudeDec = deltaAttitudeDec;
        this.deltaAttitudeRa = deltaAttitudeRa;
        this.deltaAttitudeRoll = deltaAttitudeRoll;
    }

    public List<FocalPlaneMetricReport> createFocalPlaneMetricReports(
        final TargetTable targetTable, final PipelineTask pipelineTask) {

        List<FocalPlaneMetricReport> reports = new ArrayList<FocalPlaneMetricReport>();

        if (getMaxAttitudeResidualInPixels() != null) {
            reports.add(createFocalPlaneMetricReport(
                FocalPlaneMetricReport.MetricType.MAX_ATTITUDE_RESIDUAL_IN_PIXELS,
                targetTable, pipelineTask, getDeltaAttitudeDec()));
        }
        if (getDeltaAttitudeDec() != null) {
            reports.add(createFocalPlaneMetricReport(
                FocalPlaneMetricReport.MetricType.DELTA_ATTITUDE_DEC,
                targetTable, pipelineTask, getDeltaAttitudeDec()));
        }
        if (getDeltaAttitudeRa() != null) {
            reports.add(createFocalPlaneMetricReport(
                FocalPlaneMetricReport.MetricType.DELTA_ATTITUDE_RA,
                targetTable, pipelineTask, getDeltaAttitudeRa()));
        }
        if (getDeltaAttitudeRoll() != null) {
            reports.add(createFocalPlaneMetricReport(
                FocalPlaneMetricReport.MetricType.DELTA_ATTITUDE_ROLL,
                targetTable, pipelineTask, getDeltaAttitudeRoll()));
        }
        return reports;
    }

    private FocalPlaneMetricReport createFocalPlaneMetricReport(
        final FocalPlaneMetricReport.MetricType type,
        final TargetTable targetTable, final PipelineTask pipelineTask,
        final PdqMetricReport report) {

        FocalPlaneMetricReport focalPlaneMetricReport = new FocalPlaneMetricReport.Builder(
            pipelineTask, targetTable).type(type)
            .value(report.getValue())
            .uncertainty(report.getUncertainty())
            .time(report.getTime())
            .adaptiveBoundsReport(report.getAdaptiveBoundsReport()
                .createBoundsReport())
            .fixedBoundsReport(report.getFixedBoundsReport()
                .createBoundsReport())
            .build();
        return focalPlaneMetricReport;
    }

    public PdqMetricReport getMaxAttitudeResidualInPixels() {
        return maxAttitudeResidualInPixels;
    }

    public void setMaxAttitudeResidualInPixels(
        final PdqMetricReport maxAttitudeResidualInPixels) {
        this.maxAttitudeResidualInPixels = maxAttitudeResidualInPixels;
    }

    public PdqMetricReport getDeltaAttitudeDec() {
        return deltaAttitudeDec;
    }

    public void setDeltaAttitudeDec(final PdqMetricReport deltaAttitudeDec) {
        this.deltaAttitudeDec = deltaAttitudeDec;
    }

    public PdqMetricReport getDeltaAttitudeRa() {
        return deltaAttitudeRa;
    }

    public void setDeltaAttitudeRa(final PdqMetricReport deltaAttitudeRa) {
        this.deltaAttitudeRa = deltaAttitudeRa;
    }

    public PdqMetricReport getDeltaAttitudeRoll() {
        return deltaAttitudeRoll;
    }

    public void setDeltaAttitudeRoll(final PdqMetricReport deltaAttitudeRoll) {
        this.deltaAttitudeRoll = deltaAttitudeRoll;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime
            * result
            + (maxAttitudeResidualInPixels == null ? 0
                : maxAttitudeResidualInPixels.hashCode());
        result = prime * result
            + (deltaAttitudeDec == null ? 0 : deltaAttitudeDec.hashCode());
        result = prime * result
            + (deltaAttitudeRa == null ? 0 : deltaAttitudeRa.hashCode());
        result = prime * result
            + (deltaAttitudeRoll == null ? 0 : deltaAttitudeRoll.hashCode());
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
        if (getClass() != obj.getClass()) {
            return false;
        }
        PdqFocalPlaneReport other = (PdqFocalPlaneReport) obj;
        if (maxAttitudeResidualInPixels == null) {
            if (other.maxAttitudeResidualInPixels != null) {
                return false;
            }
        } else if (!maxAttitudeResidualInPixels.equals(other.maxAttitudeResidualInPixels)) {
            return false;
        }
        if (deltaAttitudeDec == null) {
            if (other.deltaAttitudeDec != null) {
                return false;
            }
        } else if (!deltaAttitudeDec.equals(other.deltaAttitudeDec)) {
            return false;
        }
        if (deltaAttitudeRa == null) {
            if (other.deltaAttitudeRa != null) {
                return false;
            }
        } else if (!deltaAttitudeRa.equals(other.deltaAttitudeRa)) {
            return false;
        }
        if (deltaAttitudeRoll == null) {
            if (other.deltaAttitudeRoll != null) {
                return false;
            }
        } else if (!deltaAttitudeRoll.equals(other.deltaAttitudeRoll)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }
}
