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

package gov.nasa.kepler.systest.sbt.data;

import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.hibernate.mc.DoubleTimeSeriesType;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppDuration;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppMagnitude;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.MetricsTimeSeriesType;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.TargetMetricsTimeSeriesType;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvSingleEventStatisticsType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.BlobSeriesType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CosmicRayMetricType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.MetricTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFluxTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcOutliersTimeSeriesType;
import gov.nasa.kepler.mc.fs.PpaFsIdFactory.TimeSeriesType;
import gov.nasa.kepler.mc.ppa.AttitudeSolution;

import java.util.Arrays;
import java.util.List;

/**
 * This class creates {@link List}s of {@link Enum} types.
 * 
 * @author Miles Cote
 * 
 */
public class TypesFactory {

    public List<FluxType> getFluxTypes() {
        return Arrays.asList(FluxType.values());
    }

    public List<DvSingleEventStatisticsType> getDvSingleEventStatisticsTypes() {
        return Arrays.asList(DvSingleEventStatisticsType.values());
    }

    public List<BlobSeriesType> getBlobSeriesTypes() {
        return Arrays.asList(BlobSeriesType.values());
    }

    public List<CentroidType> getCentroidTypes() {
        return Arrays.asList(CentroidType.values());
    }

    public List<TimeSeriesType> getAttitudeSolutionFloatTypes() {
        return AttitudeSolution.FLOAT_TYPES;
    }

    public List<DoubleTimeSeriesType> getAttitudeSolutionDoubleTypes() {
        return AttitudeSolution.DOUBLE_TYPES;
    }

    public List<CosmicRayMetricType> getPaCosmicRayMetricTypes() {
        return Arrays.asList(CosmicRayMetricType.values());
    }

    public List<MetricTimeSeriesType> getPaMetricTypes() {
        return Arrays.asList(MetricTimeSeriesType.values());
    }

    public List<CorrectedFluxType> getCorrectedFluxTypes() {
        return Arrays.asList(CorrectedFluxType.values());
    }

    public List<PdcFluxTimeSeriesType> getPdcFluxTimeSeriesTypes() {
        return Arrays.asList(PdcFluxTimeSeriesType.values());
    }

    public List<PdcOutliersTimeSeriesType> getPdcOutliersTimeSeriesTypes() {
        return Arrays.asList(PdcOutliersTimeSeriesType.values());
    }

    public List<TargetMetricsTimeSeriesType> getCalTargetMetricsTimeSeriesTypes() {
        return Arrays.asList(TargetMetricsTimeSeriesType.values());
    }

    public List<MetricsTimeSeriesType> getCalMetricsTimeSeriesTypes() {
        return Arrays.asList(MetricsTimeSeriesType.values());
    }

    public List<gov.nasa.kepler.mc.fs.CalFsIdFactory.CosmicRayMetricType> getCalCosmicRayMetricsTypes() {
        return Arrays.asList(gov.nasa.kepler.mc.fs.CalFsIdFactory.CosmicRayMetricType.values());
    }

    public List<CollateralType> getCollateralTypes() {
        return Arrays.asList(CollateralType.values());
    }

    public List<PipelineProduct> getPipelineProducts() {
        return Arrays.asList(PipelineProduct.values());
    }

    public List<TimeSeriesType> getPmdTimeSeriesTypes() {
        return Arrays.asList(new TimeSeriesType[] {
            TimeSeriesType.BACKGROUND_LEVEL,
            TimeSeriesType.BACKGROUND_LEVEL_UNCERTAINTIES,
            TimeSeriesType.CENTROIDS_MEAN_ROW,
            TimeSeriesType.CENTROIDS_MEAN_ROW_UNCERTAINTIES,
            TimeSeriesType.CENTROIDS_MEAN_COLUMN,
            TimeSeriesType.CENTROIDS_MEAN_COLUMN_UNCERTAINTIES,
            TimeSeriesType.PLATE_SCALE,
            TimeSeriesType.PLATE_SCALE_UNCERTAINTIES });
    }

    public List<TimeSeriesType> getPmdCdppTimeSeriesTypes() {
        return Arrays.asList(new TimeSeriesType[] {
            TimeSeriesType.CDPP_EXPECTED_VALUES,
            TimeSeriesType.CDPP_EXPECTED_UNCERTAINTIES,
            TimeSeriesType.CDPP_MEASURED_VALUES,
            TimeSeriesType.CDPP_MEASURED_UNCERTAINTIES,
            TimeSeriesType.CDPP_RATIO_VALUES,
            TimeSeriesType.CDPP_RATIO_UNCERTAINTIES });
    }

    public List<TimeSeriesType> getPagTimeSeriesTypes() {
        return Arrays.asList(new TimeSeriesType[] {
            TimeSeriesType.THEORETICAL_COMPRESSION_EFFICIENCY,
            TimeSeriesType.ACHIEVED_COMPRESSION_EFFICIENCY });
    }

    public List<CdppMagnitude> getCdppMagnitudes() {
        return Arrays.asList(CdppMagnitude.values());
    }

    public List<CdppDuration> getCdppDurations() {
        return Arrays.asList(CdppDuration.values());
    }

}
