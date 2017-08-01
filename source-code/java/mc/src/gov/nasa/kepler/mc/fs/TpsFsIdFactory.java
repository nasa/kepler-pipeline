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

import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.common.pi.TpsType;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class creates FsId objects for items stored in the File Store
 *  by Transiting Planet Search
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
public class TpsFsIdFactory {
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(TpsFsIdFactory.class);

    public static final String TPS_PATH = "/tps";
    public static final String TPS_WEAK_SECONDARY_PATH = "/tps/weakSecondary";
    public static final String TPS_DETECTION_SERIES = TPS_PATH + "/detection";
    public static final String TPS_DEEMPHASIZED_NORMALIZATION =  
        TPS_DETECTION_SERIES + "/DeemphasizedNormalization";
    public static final String TPS_DEEMPHASIS_WEIGHT_PATH = TPS_DETECTION_SERIES + "/DeemphasisWeights";

    /**
     * private to prevent instantiation
     *
     */
    private TpsFsIdFactory() {
    }

    /**
     * Get a CDPP time series id for the specified star and CDPP interval
     * 
     * @return non-null
     */
    public static FsId getCdppId(long pipelineInstanceId, int keplerId, float cdppHours, TpsType tpsType, FluxType fluxType){
        StringBuilder path = new StringBuilder(32);
        path.append(TPS_PATH).append("/cdpp")
            .append('/').append(fluxType.getName())
            .append('/').append(tpsType)
            .append('/').append(pipelineInstanceId);
        StringBuilder name = new StringBuilder(16);
        name.append(keplerId).append(':').append(cdppHours);
        return new FsId(path.toString(), name.toString());
    }
    
    /**
     * Get a weak secondary mes id for the specified star.  The time series
     * stored in this FsId is more like an array.  Do not index by cadence.
     * 
     * @return non-null
     */
    public static FsId getWeakSecondaryMesId(long pipelineInstanceId, int keplerId, float pulseHours) {
        StringBuilder namePart = new StringBuilder();
        namePart.append("mes:").append(keplerId).append(':').append(pulseHours);
        StringBuilder pathPart = new StringBuilder(32);
        pathPart.append(TPS_WEAK_SECONDARY_PATH)
                .append('/').append(pipelineInstanceId);
        return new FsId(pathPart.toString(), namePart.toString());
    }
    
    /**
     * Get a weak secondary phase for the specified star.  The time series
     * stored in this FsId is more like an array.  Do not index by cadence.
     * @return non-null
     */
    public static FsId getWeakSecondaryPhaseId(long pipelineInstanceId, int keplerId, float pulseHours) {
        StringBuilder namePart = new StringBuilder();
        namePart.append("phase:").append(keplerId).append(':').append(pulseHours);
        StringBuilder pathPart = new StringBuilder(32);
        pathPart.append(TPS_WEAK_SECONDARY_PATH)
                .append('/').append(pipelineInstanceId);
        return new FsId(pathPart.toString(), namePart.toString());
    }
    
    /**
     * Create an FsId for the deemphasizedNormalizationTimeSeries for a specific target.
     * @return non-null
     */
    public static FsId getDeemphasizedNormalizationTimeSeriesId(long pipelineInstanceId, int keplerId, float pulseHours) {
        StringBuilder namePart = new StringBuilder();
        namePart.append(keplerId).append(':').append(pulseHours);
        StringBuilder pathPart = new StringBuilder(32);
        pathPart.append(TPS_DEEMPHASIZED_NORMALIZATION)
                .append('/').append(pipelineInstanceId);
        return new FsId(pathPart.toString(), namePart.toString());
    }
    
    /**
     * Create an FsId for the demphasis weights.
     * @return non-null
     */
    public static FsId getDeemphasisWeightsId(long pipelineInstanceId, int keplerId, float pulseHours) {
        StringBuilder namePart = new StringBuilder();
        namePart.append(keplerId).append(':').append(pulseHours);
        StringBuilder pathPart = new StringBuilder(32);
        pathPart.append(TPS_DEEMPHASIS_WEIGHT_PATH)
                .append('/').append(pipelineInstanceId);
        return new FsId(pathPart.toString(), namePart.toString());
    }
    
}
