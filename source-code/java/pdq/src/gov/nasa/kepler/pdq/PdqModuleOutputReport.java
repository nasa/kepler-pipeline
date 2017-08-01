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

import gov.nasa.kepler.hibernate.pdq.ModuleOutputMetricReport;
import gov.nasa.kepler.hibernate.pdq.ModuleOutputMetricReport.MetricType;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * PDQ metric reports for a single module output (channel) for a single target
 * table.
 * 
 * @author Forrest Girouard
 * @see gov.nasa.kepler.pdq.ModuleOutputMetricReport.MetricType
 * 
 */
public class PdqModuleOutputReport implements Persistable {

    /**
     * The CCD module for this report.
     */
    private int ccdModule;

    /**
     * The CCD output for this report.
     */
    private int ccdOutput;

    private PdqMetricReport backgroundLevel = new PdqMetricReport();
    private PdqMetricReport blackLevel = new PdqMetricReport();
    private PdqMetricReport centroidsMeanCol = new PdqMetricReport();
    private PdqMetricReport centroidsMeanRow = new PdqMetricReport();
    private PdqMetricReport darkCurrent = new PdqMetricReport();
    private PdqMetricReport dynamicRange = new PdqMetricReport();
    private PdqMetricReport encircledEnergy = new PdqMetricReport();
    private PdqMetricReport meanFlux = new PdqMetricReport();
    private PdqMetricReport plateScale = new PdqMetricReport();
    private PdqMetricReport smearLevel = new PdqMetricReport();

    public PdqModuleOutputReport() {
    }

    public PdqModuleOutputReport(final int ccdModule, final int ccdOutput) {

        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
    }

    public PdqModuleOutputReport(final int ccdModule, final int ccdOutput,
        final PdqMetricReport backgroundLevel,
        final PdqMetricReport blackLevel,
        final PdqMetricReport centroidsMeanCol,
        final PdqMetricReport centroidsMeanRow,
        final PdqMetricReport darkCurrent, final PdqMetricReport dynamicRange,
        final PdqMetricReport encircledEnergy, final PdqMetricReport meanFlux,
        final PdqMetricReport plateScale, final PdqMetricReport smearLevel) {

        this(ccdModule, ccdOutput);
        this.backgroundLevel = backgroundLevel;
        this.blackLevel = blackLevel;
        this.centroidsMeanCol = centroidsMeanCol;
        this.centroidsMeanRow = centroidsMeanRow;
        this.darkCurrent = darkCurrent;
        this.dynamicRange = dynamicRange;
        this.encircledEnergy = encircledEnergy;
        this.meanFlux = meanFlux;
        this.plateScale = plateScale;
        this.smearLevel = smearLevel;
    }

    public List<ModuleOutputMetricReport> createModuleOutputMetricReports(
        final TargetTable targetTable, final PipelineTask pipelineTask) {

        List<ModuleOutputMetricReport> reports = new ArrayList<ModuleOutputMetricReport>();

        if (getBackgroundLevel() != null) {
            reports.add(createModuleOutputMetricReport(
                MetricType.BACKGROUND_LEVEL, targetTable, pipelineTask,
                getBackgroundLevel()));
        }
        if (getBlackLevel() != null) {
            reports.add(createModuleOutputMetricReport(MetricType.BLACK_LEVEL,
                targetTable, pipelineTask, getBlackLevel()));
        }
        if (getCentroidsMeanCol() != null) {
            reports.add(createModuleOutputMetricReport(
                MetricType.CENTROIDS_MEAN_COL, targetTable, pipelineTask,
                getCentroidsMeanCol()));
        }
        if (getCentroidsMeanRow() != null) {
            reports.add(createModuleOutputMetricReport(
                MetricType.CENTROIDS_MEAN_ROW, targetTable, pipelineTask,
                getCentroidsMeanRow()));
        }
        if (getDarkCurrent() != null) {
            reports.add(createModuleOutputMetricReport(MetricType.DARK_CURRENT,
                targetTable, pipelineTask, getDarkCurrent()));
        }
        if (getDynamicRange() != null) {
            reports.add(createModuleOutputMetricReport(
                MetricType.DYNAMIC_RANGE, targetTable, pipelineTask,
                getDynamicRange()));
        }
        if (getEncircledEnergy() != null) {
            reports.add(createModuleOutputMetricReport(
                MetricType.ENCIRCLED_ENERGY, targetTable, pipelineTask,
                getEncircledEnergy()));
        }
        if (getMeanFlux() != null) {
            reports.add(createModuleOutputMetricReport(MetricType.MEAN_FLUX,
                targetTable, pipelineTask, getMeanFlux()));
        }
        if (getPlateScale() != null) {
            reports.add(createModuleOutputMetricReport(MetricType.PLATE_SCALE,
                targetTable, pipelineTask, getPlateScale()));
        }
        if (getSmearLevel() != null) {
            reports.add(createModuleOutputMetricReport(MetricType.SMEAR_LEVEL,
                targetTable, pipelineTask, getSmearLevel()));
        }

        return reports;
    }

    private ModuleOutputMetricReport createModuleOutputMetricReport(
        final ModuleOutputMetricReport.MetricType type,
        final TargetTable targetTable, final PipelineTask pipelineTask,
        final PdqMetricReport report) {

        ModuleOutputMetricReport moduleOutputMetricReport = new ModuleOutputMetricReport.Builder(
            pipelineTask, targetTable, getCcdModule(), getCcdOutput()).type(
            type)
            .value(report.getValue())
            .uncertainty(report.getUncertainty())
            .time(report.getTime())
            .adaptiveBoundsReport(report.getAdaptiveBoundsReport()
                .createBoundsReport())
            .fixedBoundsReport(report.getFixedBoundsReport()
                .createBoundsReport())
            .build();
        return moduleOutputMetricReport;
    }

    public PdqMetricReport getBackgroundLevel() {
        return backgroundLevel;
    }

    public void setBackgroundLevel(final PdqMetricReport backgroundLevel) {
        this.backgroundLevel = backgroundLevel;
    }

    public PdqMetricReport getBlackLevel() {
        return blackLevel;
    }

    public void setBlackLevel(final PdqMetricReport blackLevel) {
        this.blackLevel = blackLevel;
    }

    public int getCcdModule() {
        return ccdModule;
    }

    public void setCcdModule(final int ccdModule) {
        this.ccdModule = ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public void setCcdOutput(final int ccdOutput) {
        this.ccdOutput = ccdOutput;
    }

    public PdqMetricReport getCentroidsMeanCol() {
        return centroidsMeanCol;
    }

    public void setCentroidsMeanCol(final PdqMetricReport centroidsMeanCol) {
        this.centroidsMeanCol = centroidsMeanCol;
    }

    public PdqMetricReport getCentroidsMeanRow() {
        return centroidsMeanRow;
    }

    public void setCentroidsMeanRow(final PdqMetricReport centroidsMeanRow) {
        this.centroidsMeanRow = centroidsMeanRow;
    }

    public PdqMetricReport getDarkCurrent() {
        return darkCurrent;
    }

    public void setDarkCurrent(final PdqMetricReport darkCurrent) {
        this.darkCurrent = darkCurrent;
    }

    public PdqMetricReport getDynamicRange() {
        return dynamicRange;
    }

    public void setDynamicRange(final PdqMetricReport dynamicRange) {
        this.dynamicRange = dynamicRange;
    }

    public PdqMetricReport getEncircledEnergy() {
        return encircledEnergy;
    }

    public void setEncircledEnergy(final PdqMetricReport encircledEnergy) {
        this.encircledEnergy = encircledEnergy;
    }

    public PdqMetricReport getMeanFlux() {
        return meanFlux;
    }

    public void setMeanFlux(final PdqMetricReport meanFlux) {
        this.meanFlux = meanFlux;
    }

    public PdqMetricReport getPlateScale() {
        return plateScale;
    }

    public void setPlateScale(final PdqMetricReport plateScale) {
        this.plateScale = plateScale;
    }

    public PdqMetricReport getSmearLevel() {
        return smearLevel;
    }

    public void setSmearLevel(final PdqMetricReport smearLevel) {
        this.smearLevel = smearLevel;
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result
            + (backgroundLevel == null ? 0 : backgroundLevel.hashCode());
        result = PRIME * result
            + (blackLevel == null ? 0 : blackLevel.hashCode());
        result = PRIME * result + ccdModule;
        result = PRIME * result + ccdOutput;
        result = PRIME * result
            + (centroidsMeanCol == null ? 0 : centroidsMeanCol.hashCode());
        result = PRIME * result
            + (centroidsMeanRow == null ? 0 : centroidsMeanRow.hashCode());
        result = PRIME * result
            + (darkCurrent == null ? 0 : darkCurrent.hashCode());
        result = PRIME * result
            + (dynamicRange == null ? 0 : dynamicRange.hashCode());
        result = PRIME * result
            + (encircledEnergy == null ? 0 : encircledEnergy.hashCode());
        result = PRIME * result + (meanFlux == null ? 0 : meanFlux.hashCode());
        result = PRIME * result
            + (plateScale == null ? 0 : plateScale.hashCode());
        result = PRIME * result
            + (smearLevel == null ? 0 : smearLevel.hashCode());
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
        final PdqModuleOutputReport other = (PdqModuleOutputReport) obj;
        if (backgroundLevel == null) {
            if (other.backgroundLevel != null) {
                return false;
            }
        } else if (!backgroundLevel.equals(other.backgroundLevel)) {
            return false;
        }
        if (blackLevel == null) {
            if (other.blackLevel != null) {
                return false;
            }
        } else if (!blackLevel.equals(other.blackLevel)) {
            return false;
        }
        if (ccdModule != other.ccdModule) {
            return false;
        }
        if (ccdOutput != other.ccdOutput) {
            return false;
        }
        if (centroidsMeanCol == null) {
            if (other.centroidsMeanCol != null) {
                return false;
            }
        } else if (!centroidsMeanCol.equals(other.centroidsMeanCol)) {
            return false;
        }
        if (centroidsMeanRow == null) {
            if (other.centroidsMeanRow != null) {
                return false;
            }
        } else if (!centroidsMeanRow.equals(other.centroidsMeanRow)) {
            return false;
        }
        if (darkCurrent == null) {
            if (other.darkCurrent != null) {
                return false;
            }
        } else if (!darkCurrent.equals(other.darkCurrent)) {
            return false;
        }
        if (dynamicRange == null) {
            if (other.dynamicRange != null) {
                return false;
            }
        } else if (!dynamicRange.equals(other.dynamicRange)) {
            return false;
        }
        if (encircledEnergy == null) {
            if (other.encircledEnergy != null) {
                return false;
            }
        } else if (!encircledEnergy.equals(other.encircledEnergy)) {
            return false;
        }
        if (meanFlux == null) {
            if (other.meanFlux != null) {
                return false;
            }
        } else if (!meanFlux.equals(other.meanFlux)) {
            return false;
        }
        if (plateScale == null) {
            if (other.plateScale != null) {
                return false;
            }
        } else if (!plateScale.equals(other.plateScale)) {
            return false;
        }
        if (smearLevel == null) {
            if (other.smearLevel != null) {
                return false;
            }
        } else if (!smearLevel.equals(other.smearLevel)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }
}
