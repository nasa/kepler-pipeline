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

import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.fs.PdqFsIdFactory;
import gov.nasa.kepler.mc.fs.PdqFsIdFactory.TimeSeriesType;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * The PDQ metrics for a single CCD module output and target table.
 * 
 * @author Forrest Girouard
 * 
 */
public class PdqModuleOutputTsData implements Persistable {

    /**
     * The CCD module for this data.
     */
    private int ccdModule;

    /**
     * The CCD output for this data.
     */
    private int ccdOutput;

    private CompoundFloatTimeSeries backgroundLevels = new CompoundFloatTimeSeries();
    private CompoundFloatTimeSeries blackLevels = new CompoundFloatTimeSeries();
    private CompoundFloatTimeSeries centroidsMeanCols = new CompoundFloatTimeSeries();
    private CompoundFloatTimeSeries centroidsMeanRows = new CompoundFloatTimeSeries();
    private CompoundFloatTimeSeries darkCurrents = new CompoundFloatTimeSeries();
    private CompoundFloatTimeSeries dynamicRanges = new CompoundFloatTimeSeries();
    private CompoundFloatTimeSeries encircledEnergies = new CompoundFloatTimeSeries();
    private CompoundFloatTimeSeries meanFluxes = new CompoundFloatTimeSeries();
    private CompoundFloatTimeSeries plateScales = new CompoundFloatTimeSeries();
    private CompoundFloatTimeSeries smearLevels = new CompoundFloatTimeSeries();

    /**
     * Required by Persistable interface.
     */
    public PdqModuleOutputTsData() {
    }

    public PdqModuleOutputTsData(final int ccdModule, final int ccdOutput,
        final int targetTableId, final Map<FsId, FloatTimeSeries> timeSeries) {

        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        setBackgroundLevels(targetTableId, timeSeries);
        setBlackLevels(targetTableId, timeSeries);
        setCentroidsMeanCols(targetTableId, timeSeries);
        setCentroidsMeanRows(targetTableId, timeSeries);
        setDarkCurrents(targetTableId, timeSeries);
        setDynamicRanges(targetTableId, timeSeries);
        setEncircledEnergies(targetTableId, timeSeries);
        setMeanFluxes(targetTableId, timeSeries);
        setPlateScales(targetTableId, timeSeries);
        setSmearLevels(targetTableId, timeSeries);
    }

    public boolean isEmpty() {
        if (getBackgroundLevels() != null && getBackgroundLevels().size() != 0) {
            return false;
        }
        if (getBlackLevels() != null && getBlackLevels().size() != 0) {
            return false;
        }
        if (getCentroidsMeanCols() != null
            && getCentroidsMeanCols().size() != 0) {
            return false;
        }
        if (getCentroidsMeanRows() != null
            && getCentroidsMeanRows().size() != 0) {
            return false;
        }
        if (getDarkCurrents() != null && getDarkCurrents().size() != 0) {
            return false;
        }
        if (getDynamicRanges() != null && getDynamicRanges().size() != 0) {
            return false;
        }
        if (getEncircledEnergies() != null
            && getEncircledEnergies().size() != 0) {
            return false;
        }
        if (getMeanFluxes() != null && getMeanFluxes().size() != 0) {
            return false;
        }
        if (getPlateScales() != null && getPlateScales().size() != 0) {
            return false;
        }
        if (getSmearLevels() != null && getSmearLevels().size() != 0) {
            return false;
        }
        return true;
    }

    public List<FloatTimeSeries> getAvailableTimeSeries(int targetTableId,
        long pipelineTaskId, int minEndCadence) {

        List<FloatTimeSeries> timeSeriesList = new ArrayList<FloatTimeSeries>();

        timeSeriesList.addAll(getBackgroundLevels(targetTableId,
            pipelineTaskId, minEndCadence));
        timeSeriesList.addAll(getBlackLevels(targetTableId, pipelineTaskId,
            minEndCadence));
        timeSeriesList.addAll(getCentroidsMeanCols(targetTableId,
            pipelineTaskId, minEndCadence));
        timeSeriesList.addAll(getCentroidsMeanRows(targetTableId,
            pipelineTaskId, minEndCadence));
        timeSeriesList.addAll(getDarkCurrents(targetTableId, pipelineTaskId,
            minEndCadence));
        timeSeriesList.addAll(getDynamicRanges(targetTableId, pipelineTaskId,
            minEndCadence));
        timeSeriesList.addAll(getEncircledEnergies(targetTableId,
            pipelineTaskId, minEndCadence));
        timeSeriesList.addAll(getMeanFluxes(targetTableId, pipelineTaskId,
            minEndCadence));
        timeSeriesList.addAll(getPlateScales(targetTableId, pipelineTaskId,
            minEndCadence));
        timeSeriesList.addAll(getSmearLevels(targetTableId, pipelineTaskId,
            minEndCadence));
        return timeSeriesList;
    }

    private List<FloatTimeSeries> getFloatTimeSeries(int targetTableId,
        long pipelineTaskId, TimeSeriesType type,
        CompoundFloatTimeSeries pdqTimeSeries, int minEndCadence) {

        List<FloatTimeSeries> timeSeries = new ArrayList<FloatTimeSeries>();
        if (pdqTimeSeries != null && pdqTimeSeries.size() > 0) {
            FsId fsId = PdqFsIdFactory.getPdqTimeSeriesFsId(type,
                targetTableId, ccdModule, ccdOutput);
            timeSeries.add(new FloatTimeSeries(fsId, pdqTimeSeries.getValues(),
                0, pdqTimeSeries.size() - 1, pdqTimeSeries.getGapIndicators(),
                pipelineTaskId));
            fsId = PdqFsIdFactory.getPdqUncertaintiesFsId(type, targetTableId,
                ccdModule, ccdOutput);
            timeSeries.add(new FloatTimeSeries(fsId,
                pdqTimeSeries.getUncertainties(), 0, pdqTimeSeries.size() - 1,
                pdqTimeSeries.getGapIndicators(), pipelineTaskId));

        }
        return timeSeries;
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result
            + (backgroundLevels == null ? 0 : backgroundLevels.hashCode());
        result = PRIME * result
            + (blackLevels == null ? 0 : blackLevels.hashCode());
        result = PRIME * result + ccdModule;
        result = PRIME * result + ccdOutput;
        result = PRIME * result
            + (centroidsMeanCols == null ? 0 : centroidsMeanCols.hashCode());
        result = PRIME * result
            + (centroidsMeanRows == null ? 0 : centroidsMeanRows.hashCode());
        result = PRIME * result
            + (darkCurrents == null ? 0 : darkCurrents.hashCode());
        result = PRIME * result
            + (dynamicRanges == null ? 0 : dynamicRanges.hashCode());
        result = PRIME * result
            + (encircledEnergies == null ? 0 : encircledEnergies.hashCode());
        result = PRIME * result
            + (meanFluxes == null ? 0 : meanFluxes.hashCode());
        result = PRIME * result
            + (plateScales == null ? 0 : plateScales.hashCode());
        result = PRIME * result
            + (smearLevels == null ? 0 : smearLevels.hashCode());
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
        final PdqModuleOutputTsData other = (PdqModuleOutputTsData) obj;
        if (backgroundLevels == null) {
            if (other.backgroundLevels != null) {
                return false;
            }
        } else if (!backgroundLevels.equals(other.backgroundLevels)) {
            return false;
        }
        if (blackLevels == null) {
            if (other.blackLevels != null) {
                return false;
            }
        } else if (!blackLevels.equals(other.blackLevels)) {
            return false;
        }
        if (ccdModule != other.ccdModule) {
            return false;
        }
        if (ccdOutput != other.ccdOutput) {
            return false;
        }
        if (centroidsMeanCols == null) {
            if (other.centroidsMeanCols != null) {
                return false;
            }
        } else if (!centroidsMeanCols.equals(other.centroidsMeanCols)) {
            return false;
        }
        if (centroidsMeanRows == null) {
            if (other.centroidsMeanRows != null) {
                return false;
            }
        } else if (!centroidsMeanRows.equals(other.centroidsMeanRows)) {
            return false;
        }
        if (darkCurrents == null) {
            if (other.darkCurrents != null) {
                return false;
            }
        } else if (!darkCurrents.equals(other.darkCurrents)) {
            return false;
        }
        if (dynamicRanges == null) {
            if (other.dynamicRanges != null) {
                return false;
            }
        } else if (!dynamicRanges.equals(other.dynamicRanges)) {
            return false;
        }
        if (encircledEnergies == null) {
            if (other.encircledEnergies != null) {
                return false;
            }
        } else if (!encircledEnergies.equals(other.encircledEnergies)) {
            return false;
        }
        if (meanFluxes == null) {
            if (other.meanFluxes != null) {
                return false;
            }
        } else if (!meanFluxes.equals(other.meanFluxes)) {
            return false;
        }
        if (plateScales == null) {
            if (other.plateScales != null) {
                return false;
            }
        } else if (!plateScales.equals(other.plateScales)) {
            return false;
        }
        if (smearLevels == null) {
            if (other.smearLevels != null) {
                return false;
            }
        } else if (!smearLevels.equals(other.smearLevels)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }

    public CompoundFloatTimeSeries getBackgroundLevels() {
        return backgroundLevels;
    }

    public void setBackgroundLevels(
        final CompoundFloatTimeSeries backgroundLevels) {
        this.backgroundLevels = backgroundLevels;
    }

    public CompoundFloatTimeSeries getBlackLevels() {
        return blackLevels;
    }

    public void setBlackLevels(final CompoundFloatTimeSeries blackLevels) {
        this.blackLevels = blackLevels;
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

    public CompoundFloatTimeSeries getCentroidsMeanCols() {
        return centroidsMeanCols;
    }

    public void setCentroidsMeanCols(
        final CompoundFloatTimeSeries centroidsMeanCols) {
        this.centroidsMeanCols = centroidsMeanCols;
    }

    public CompoundFloatTimeSeries getCentroidsMeanRows() {
        return centroidsMeanRows;
    }

    public void setCentroidsMeanRows(
        final CompoundFloatTimeSeries centroidsMeanRows) {
        this.centroidsMeanRows = centroidsMeanRows;
    }

    public CompoundFloatTimeSeries getDarkCurrents() {
        return darkCurrents;
    }

    public void setDarkCurrents(final CompoundFloatTimeSeries darkCurrents) {
        this.darkCurrents = darkCurrents;
    }

    public CompoundFloatTimeSeries getDynamicRanges() {
        return dynamicRanges;
    }

    public void setDynamicRanges(final CompoundFloatTimeSeries dynamicRanges) {
        this.dynamicRanges = dynamicRanges;
    }

    public CompoundFloatTimeSeries getEncircledEnergies() {
        return encircledEnergies;
    }

    public void setEncircledEnergies(
        final CompoundFloatTimeSeries encircledEnergies) {
        this.encircledEnergies = encircledEnergies;
    }

    public CompoundFloatTimeSeries getMeanFluxes() {
        return meanFluxes;
    }

    public void setMeanFluxes(final CompoundFloatTimeSeries meanFluxes) {
        this.meanFluxes = meanFluxes;
    }

    public CompoundFloatTimeSeries getPlateScales() {
        return plateScales;
    }

    public void setPlateScales(final CompoundFloatTimeSeries plateScales) {
        this.plateScales = plateScales;
    }

    public CompoundFloatTimeSeries getSmearLevels() {
        return smearLevels;
    }

    public void setSmearLevels(final CompoundFloatTimeSeries smearLevels) {
        this.smearLevels = smearLevels;
    }

    private List<FloatTimeSeries> getBackgroundLevels(final int targetTableId,
        final long pipelineTaskId, int minEndCadence) {
        return getFloatTimeSeries(targetTableId, pipelineTaskId,
            TimeSeriesType.BACKGROUND_LEVELS, getBackgroundLevels(),
            minEndCadence);
    }

    private List<FloatTimeSeries> getBlackLevels(final int targetTableId,
        final long pipelineTaskId, int minEndCadence) {
        return getFloatTimeSeries(targetTableId, pipelineTaskId,
            TimeSeriesType.BLACK_LEVELS, getBlackLevels(), minEndCadence);
    }

    private List<FloatTimeSeries> getCentroidsMeanCols(final int targetTableId,
        final long pipelineTaskId, int minEndCadence) {
        return getFloatTimeSeries(targetTableId, pipelineTaskId,
            TimeSeriesType.CENTROIDS_MEAN_COLS, getCentroidsMeanCols(),
            minEndCadence);
    }

    private List<FloatTimeSeries> getCentroidsMeanRows(final int targetTableId,
        final long pipelineTaskId, int minEndCadence) {
        return getFloatTimeSeries(targetTableId, pipelineTaskId,
            TimeSeriesType.CENTROIDS_MEAN_ROWS, getCentroidsMeanRows(),
            minEndCadence);
    }

    private List<FloatTimeSeries> getDarkCurrents(final int targetTableId,
        final long pipelineTaskId, int minEndCadence) {
        return getFloatTimeSeries(targetTableId, pipelineTaskId,
            TimeSeriesType.DARK_CURRENTS, getDarkCurrents(), minEndCadence);
    }

    private List<FloatTimeSeries> getDynamicRanges(final int targetTableId,
        final long pipelineTaskId, int minEndCadence) {
        return getFloatTimeSeries(targetTableId, pipelineTaskId,
            TimeSeriesType.DYNAMIC_RANGES, getDynamicRanges(), minEndCadence);
    }

    private List<FloatTimeSeries> getEncircledEnergies(final int targetTableId,
        final long pipelineTaskId, int minEndCadence) {
        return getFloatTimeSeries(targetTableId, pipelineTaskId,
            TimeSeriesType.ENCIRCLED_ENERGIES, getEncircledEnergies(),
            minEndCadence);
    }

    private List<FloatTimeSeries> getMeanFluxes(final int targetTableId,
        final long pipelineTaskId, int minEndCadence) {
        return getFloatTimeSeries(targetTableId, pipelineTaskId,
            TimeSeriesType.MEAN_FLUXES, getMeanFluxes(), minEndCadence);
    }

    private List<FloatTimeSeries> getPlateScales(final int targetTableId,
        final long pipelineTaskId, int minEndCadence) {
        return getFloatTimeSeries(targetTableId, pipelineTaskId,
            TimeSeriesType.PLATE_SCALES, getPlateScales(), minEndCadence);
    }

    private List<FloatTimeSeries> getSmearLevels(final int targetTableId,
        final long pipelineTaskId, int minEndCadence) {
        return getFloatTimeSeries(targetTableId, pipelineTaskId,
            TimeSeriesType.SMEAR_LEVELS, getSmearLevels(), minEndCadence);
    }

    private void setBackgroundLevels(final int targetTableId,
        final Map<FsId, FloatTimeSeries> timeSeriesMap) {
        FsId fsId = PdqFsIdFactory.getPdqTimeSeriesFsId(
            TimeSeriesType.BACKGROUND_LEVELS, targetTableId, ccdModule,
            ccdOutput);
        FloatTimeSeries timeSeries = timeSeriesMap.get(fsId);
        if (timeSeries != null) {
            fsId = PdqFsIdFactory.getPdqUncertaintiesFsId(
                TimeSeriesType.BACKGROUND_LEVELS, targetTableId, ccdModule,
                ccdOutput);
            FloatTimeSeries uncertainties = timeSeriesMap.get(fsId);
            setBackgroundLevels(new CompoundFloatTimeSeries(
                timeSeries.fseries(), uncertainties.fseries(),
                timeSeries.getGapIndicators()));
        }
    }

    private void setBlackLevels(final int targetTableId,
        final Map<FsId, FloatTimeSeries> timeSeriesMap) {
        FsId fsId = PdqFsIdFactory.getPdqTimeSeriesFsId(
            TimeSeriesType.BLACK_LEVELS, targetTableId, ccdModule, ccdOutput);
        FloatTimeSeries timeSeries = timeSeriesMap.get(fsId);
        if (timeSeries != null) {
            fsId = PdqFsIdFactory.getPdqUncertaintiesFsId(
                TimeSeriesType.BLACK_LEVELS, targetTableId, ccdModule,
                ccdOutput);
            FloatTimeSeries uncertainties = timeSeriesMap.get(fsId);
            setBlackLevels(new CompoundFloatTimeSeries(timeSeries.fseries(),
                uncertainties.fseries(), timeSeries.getGapIndicators()));
        }
    }

    private void setCentroidsMeanCols(final int targetTableId,
        final Map<FsId, FloatTimeSeries> timeSeriesMap) {
        FsId fsId = PdqFsIdFactory.getPdqTimeSeriesFsId(
            TimeSeriesType.CENTROIDS_MEAN_COLS, targetTableId, ccdModule,
            ccdOutput);
        FloatTimeSeries timeSeries = timeSeriesMap.get(fsId);
        if (timeSeries != null) {
            fsId = PdqFsIdFactory.getPdqUncertaintiesFsId(
                TimeSeriesType.CENTROIDS_MEAN_COLS, targetTableId, ccdModule,
                ccdOutput);
            FloatTimeSeries uncertainties = timeSeriesMap.get(fsId);
            setCentroidsMeanCols(new CompoundFloatTimeSeries(
                timeSeries.fseries(), uncertainties.fseries(),
                timeSeries.getGapIndicators()));
        }
    }

    private void setCentroidsMeanRows(final int targetTableId,
        final Map<FsId, FloatTimeSeries> timeSeriesMap) {
        FsId fsId = PdqFsIdFactory.getPdqTimeSeriesFsId(
            TimeSeriesType.CENTROIDS_MEAN_ROWS, targetTableId, ccdModule,
            ccdOutput);
        FloatTimeSeries timeSeries = timeSeriesMap.get(fsId);
        if (timeSeries != null) {
            fsId = PdqFsIdFactory.getPdqUncertaintiesFsId(
                TimeSeriesType.CENTROIDS_MEAN_ROWS, targetTableId, ccdModule,
                ccdOutput);
            FloatTimeSeries uncertainties = timeSeriesMap.get(fsId);
            setCentroidsMeanRows(new CompoundFloatTimeSeries(
                timeSeries.fseries(), uncertainties.fseries(),
                timeSeries.getGapIndicators()));
        }
    }

    private void setDarkCurrents(final int targetTableId,
        final Map<FsId, FloatTimeSeries> timeSeriesMap) {
        FsId fsId = PdqFsIdFactory.getPdqTimeSeriesFsId(
            TimeSeriesType.DARK_CURRENTS, targetTableId, ccdModule, ccdOutput);
        FloatTimeSeries timeSeries = timeSeriesMap.get(fsId);
        if (timeSeries != null) {
            fsId = PdqFsIdFactory.getPdqUncertaintiesFsId(
                TimeSeriesType.DARK_CURRENTS, targetTableId, ccdModule,
                ccdOutput);
            FloatTimeSeries uncertainties = timeSeriesMap.get(fsId);
            setDarkCurrents(new CompoundFloatTimeSeries(timeSeries.fseries(),
                uncertainties.fseries(), timeSeries.getGapIndicators()));
        }
    }

    private void setDynamicRanges(final int targetTableId,
        final Map<FsId, FloatTimeSeries> timeSeriesMap) {
        FsId fsId = PdqFsIdFactory.getPdqTimeSeriesFsId(
            TimeSeriesType.DYNAMIC_RANGES, targetTableId, ccdModule, ccdOutput);
        FloatTimeSeries timeSeries = timeSeriesMap.get(fsId);
        if (timeSeries != null) {
            fsId = PdqFsIdFactory.getPdqUncertaintiesFsId(
                TimeSeriesType.DYNAMIC_RANGES, targetTableId, ccdModule,
                ccdOutput);
            FloatTimeSeries uncertainties = timeSeriesMap.get(fsId);
            setDynamicRanges(new CompoundFloatTimeSeries(timeSeries.fseries(),
                uncertainties.fseries(), timeSeries.getGapIndicators()));
        }
    }

    private void setEncircledEnergies(final int targetTableId,
        final Map<FsId, FloatTimeSeries> timeSeriesMap) {
        FsId fsId = PdqFsIdFactory.getPdqTimeSeriesFsId(
            TimeSeriesType.ENCIRCLED_ENERGIES, targetTableId, ccdModule,
            ccdOutput);
        FloatTimeSeries timeSeries = timeSeriesMap.get(fsId);
        if (timeSeries != null) {
            fsId = PdqFsIdFactory.getPdqUncertaintiesFsId(
                TimeSeriesType.ENCIRCLED_ENERGIES, targetTableId, ccdModule,
                ccdOutput);
            FloatTimeSeries uncertainties = timeSeriesMap.get(fsId);
            setEncircledEnergies(new CompoundFloatTimeSeries(
                timeSeries.fseries(), uncertainties.fseries(),
                timeSeries.getGapIndicators()));
        }
    }

    private void setMeanFluxes(final int targetTableId,
        final Map<FsId, FloatTimeSeries> timeSeriesMap) {
        FsId fsId = PdqFsIdFactory.getPdqTimeSeriesFsId(
            TimeSeriesType.MEAN_FLUXES, targetTableId, ccdModule, ccdOutput);
        FloatTimeSeries timeSeries = timeSeriesMap.get(fsId);
        if (timeSeries != null) {
            fsId = PdqFsIdFactory.getPdqUncertaintiesFsId(
                TimeSeriesType.MEAN_FLUXES, targetTableId, ccdModule, ccdOutput);
            FloatTimeSeries uncertainties = timeSeriesMap.get(fsId);
            setMeanFluxes(new CompoundFloatTimeSeries(timeSeries.fseries(),
                uncertainties.fseries(), timeSeries.getGapIndicators()));
        }
    }

    private void setPlateScales(final int targetTableId,
        final Map<FsId, FloatTimeSeries> timeSeriesMap) {
        FsId fsId = PdqFsIdFactory.getPdqTimeSeriesFsId(
            TimeSeriesType.PLATE_SCALES, targetTableId, ccdModule, ccdOutput);
        FloatTimeSeries timeSeries = timeSeriesMap.get(fsId);
        if (timeSeries != null) {
            fsId = PdqFsIdFactory.getPdqUncertaintiesFsId(
                TimeSeriesType.PLATE_SCALES, targetTableId, ccdModule,
                ccdOutput);
            FloatTimeSeries uncertainties = timeSeriesMap.get(fsId);
            setPlateScales(new CompoundFloatTimeSeries(timeSeries.fseries(),
                uncertainties.fseries(), timeSeries.getGapIndicators()));
        }
    }

    private void setSmearLevels(final int targetTableId,
        final Map<FsId, FloatTimeSeries> timeSeriesMap) {
        FsId fsId = PdqFsIdFactory.getPdqTimeSeriesFsId(
            TimeSeriesType.SMEAR_LEVELS, targetTableId, ccdModule, ccdOutput);
        FloatTimeSeries timeSeries = timeSeriesMap.get(fsId);
        if (timeSeries != null) {
            fsId = PdqFsIdFactory.getPdqUncertaintiesFsId(
                TimeSeriesType.SMEAR_LEVELS, targetTableId, ccdModule,
                ccdOutput);
            FloatTimeSeries uncertainties = timeSeriesMap.get(fsId);
            setSmearLevels(new CompoundFloatTimeSeries(timeSeries.fseries(),
                uncertainties.fseries(), timeSeries.getGapIndicators()));
        }
    }

}
