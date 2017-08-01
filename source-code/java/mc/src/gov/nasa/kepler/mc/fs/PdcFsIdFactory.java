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

package gov.nasa.kepler.mc.fs;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.spiffy.common.lang.StringUtils;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class creates FsId objects for items stored in the File Store by PDC.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class PdcFsIdFactory {
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(PdcFsIdFactory.class);

    public static final String PDC_PATH = "/pdc/";

    public enum PdcFluxTimeSeriesType {
        CORRECTED_FLUX,
        CORRECTED_FLUX_UNCERTAINTIES,
        HARMONIC_FREE_CORRECTED_FLUX,
        HARMONIC_FREE_CORRECTED_FLUX_UNCERTAINTIES;

        private String name;

        private PdcFluxTimeSeriesType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }
    }

    public enum PdcFilledIndicesTimeSeriesType {
        FILLED_INDICES, HARMONIC_FREE_FILLED_INDICES;

        private String name;

        private PdcFilledIndicesTimeSeriesType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }
    }

    public enum PdcOutliersTimeSeriesType {
        OUTLIERS,
        OUTLIER_UNCERTAINTIES,
        HARMONIC_FREE_OUTLIERS,
        HARMONIC_FREE_OUTLIER_UNCERTAINTIES;

        private String name;

        private PdcOutliersTimeSeriesType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }
    }

    public enum BlobSeriesType {
        PDC,
        CBV;

        private String name;

        private BlobSeriesType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }
    }

    public enum PdcGoodnessMetricType {
        CORRELATION,
        DELTA_VARIABILITY,
        EARTH_POINT_REMOVAL,
        INTRODUCED_NOISE,
        TOTAL;

        private String name;

        private PdcGoodnessMetricType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }
    }

    public enum PdcGoodnessComponentType {
        VALUE, PERCENTILE;

        private String name;

        private PdcGoodnessComponentType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }
    }

    public enum MapProcessingCharacteristicsType {
        PRIOR_WEIGHT, TARGET_VARIABILITY;

        private String name;

        private MapProcessingCharacteristicsType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }
    }

    /**
     * private to prevent instantiation
     * 
     */
    private PdcFsIdFactory() {
    }

    /**
     * Return FsId for Corrected Flux Values or Uncertainties.
     * 
     * @param timeSeriesType
     * @param fluxType
     * @param cadenceType
     * @param keplerId
     * @return An id for a FloatTimeSeries.
     */
    public static FsId getFluxTimeSeriesFsId(
        PdcFluxTimeSeriesType timeSeriesType, FluxType fluxType,
        CadenceType cadenceType, int keplerId) {

        StringBuilder fullPath = new StringBuilder().append(PDC_PATH)
            .append(fluxType.getName())
            .append(timeSeriesType.getName())
            .append('/')
            .append(cadenceType.getName())
            .append('/')
            .append(keplerId);
        
        return new FsId(fullPath.toString());
    }

    /**
     * Return FsId for Filled Indices of Corrected Flux Values. These are
     * indices that are filled during the gap-filling phase of PDC.
     * 
     * @param keplerId
     * @param cadenceType
     * @return An id for a FloatMjdTimeSeries.
     */
    public static FsId getFilledIndicesFsId(
        PdcFilledIndicesTimeSeriesType timeSeriesType, FluxType fluxType,
        CadenceType cadenceType, int keplerId) {
        
        StringBuilder fullPath = new StringBuilder().append(PDC_PATH)
            .append(fluxType.getName())
            .append('/')
            .append(timeSeriesType.getName())
            .append('/')
            .append(cadenceType.getName())
            .append('/')
            .append(keplerId);
        
        return new FsId(fullPath.toString());
    }

    public static FsId getDiscontinuityIndicesFsId(FluxType fluxType,
        CadenceType cadenceType, int keplerId) {
        
        StringBuilder fullPath = new StringBuilder().append(PDC_PATH)
            .append(fluxType.getName())
            .append("/DiscontinuityIndices/")
            .append(cadenceType.getName())
            .append('/')
            .append(keplerId);
        
        return new FsId(fullPath.toString());
    }

    /**
     * Return {@link FsId} for outliers in a corrected flux time series.
     * Outliers are values found to be out-of-range after the PDC gap-filling
     * phase. Before PDC replaces the outlier value in the corrected flux time
     * series, it stores the outlier value. The MJD is stored with the outlier
     * values.
     * 
     * @param timeSeriesType the type of time series
     * @param fluxType the relevant flux type
     * @param cadenceType the cadence type
     * @param keplerId the Kepler ID
     * @return ID for a FloatMjdTimeSeries
     */
    public static FsId getOutlierTimerSeriesId(
        PdcOutliersTimeSeriesType timeSeriesType, FluxType fluxType,
        CadenceType cadenceType, int keplerId) {

        StringBuilder fullPath = new StringBuilder().append(PDC_PATH)
            .append(fluxType.getName())
            .append('/')
            .append(timeSeriesType.getName())
            .append('/')
            .append(cadenceType.getName())
            .append('/')
            .append(keplerId);

        return new FsId(fullPath.toString());
    }

    /**
     * Get FsId for matlab blob data.
     * 
     * @return
     */
    public static FsId getMatlabBlobFsId(BlobSeriesType blobType,
        CadenceType cadenceType, int ccdModule, int ccdOutput,
        long pipelineTaskId) {

        if (blobType == null) {
            throw new NullPointerException("blobType can't be null");
        }
        if (cadenceType == null) {
            throw new NullPointerException("cadenceType can't be null");
        }

        StringBuilder fullPath = new StringBuilder();
        fullPath.append(PDC_PATH)
            .append(blobType.getName())
            .append('/')
            .append(cadenceType.getName())
            .append('/')
            .append(ccdModule)
            .append(PixelFsIdFactory.SEP)
            .append(ccdOutput)
            .append(PixelFsIdFactory.SEP)
            .append(pipelineTaskId);
        
        return new FsId(fullPath.toString());
    }

    /**
     * Get FsId for MAP goodness metric fields.
     * 
     * @param metricType type of metric
     * @param componentType value or percentile type
     * @param fluxType the relevant flux type
     * @param cadenceType the cadence type
     * @param keplerId the Kepler ID
     *
     * @return
     */
    public static FsId getPdcGoodnessMetricFsId(
        PdcGoodnessMetricType metricType,
        PdcGoodnessComponentType componentType, FluxType fluxType,
        CadenceType cadenceType, int keplerId) {

        StringBuilder fullPath = new StringBuilder().append(PDC_PATH)
            .append(fluxType.getName())
            .append("/PdcGoodnessMetric/")
            .append(metricType.getName())
            .append('/')
            .append(componentType.getName())
            .append('/')
            .append(cadenceType.getName())
            .append('/')
            .append(keplerId);
        
        return new FsId(fullPath.toString());
    }
}
