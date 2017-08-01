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

import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.spiffy.common.lang.StringUtils;

public final class PdqFsIdFactory {

    private static final String PDQ_PATH_PREFIX = "/pdq";
    private static final String PDQ_SEP = ":";
    private static final String UNCERTAINTIES = "uncertainties";

    public static enum TimeSeriesType {
        BLACK_LEVELS,
        SMEAR_LEVELS,
        DARK_CURRENTS,
        BACKGROUND_LEVELS,
        MEAN_FLUXES,
        CENTROIDS_MEAN_ROWS,
        CENTROIDS_MEAN_COLS,
        ENCIRCLED_ENERGIES,
        PLATE_SCALES,
        DYNAMIC_RANGES,
        ATTITUDE_SOLUTION_RA,
        ATTITUDE_SOLUTION_DEC,
        ATTITUDE_SOLUTION_ROLL,
        DELTA_ATTITUDE_RA,
        DELTA_ATTITUDE_DEC,
        DELTA_ATTITUDE_ROLL,
        DESIRED_ATTITUDE_RA,
        DESIRED_ATTITUDE_DEC,
        DESIRED_ATTITUDE_ROLL,
        MAX_ATTITUDE_RESIDUAL_IN_PIXELS;

        private final String name;

        private TimeSeriesType() {
            this.name = StringUtils.constantToCamel(this.toString()).intern();
        }

        public String getName() {
            return name;
        }

        public static TimeSeriesType getInstance(int ordinal) {
            if (ordinal < 0 || ordinal >= TimeSeriesType.values().length) {
                throw new IllegalArgumentException(
                    "ordinal value exceeds maximum: "
                        + (TimeSeriesType.values().length - 1));
            }
            return TimeSeriesType.values()[ordinal];
        }

        public static TimeSeriesType valueOfName(String name) {
            for (TimeSeriesType type : values()) {
                if (type.getName().equals(name)) {
                    return type;
                }
            }

            throw new IllegalArgumentException(name
                + ": invalid time series type");
        }
    }

    /**
     * private to prevent instantiation
     * 
     */
    private PdqFsIdFactory() {
    }

    public static FsId getPdqTimeSeriesFsId(TimeSeriesType timeSeriesType,
        int targetTableId) {
        return getTimeSeriesFsId(PDQ_PATH_PREFIX, timeSeriesType.getName(),
            targetTableId);
    }

    public static FsId getPdqUncertaintiesFsId(TimeSeriesType timeSeriesType,
        int targetTableId) {
        return getUncertaintiesFsId(PDQ_PATH_PREFIX, timeSeriesType.getName(),
            targetTableId);
    }

    public static FsId getPdqTimeSeriesFsId(TimeSeriesType timeSeriesType,
        int targetTableId, int ccdModule, int ccdOutput) {
        return getTimeSeriesFsId(PDQ_PATH_PREFIX, timeSeriesType.getName(),
            targetTableId, ccdModule, ccdOutput);
    }

    public static FsId getPdqUncertaintiesFsId(TimeSeriesType timeSeriesType,
        int targetTableId, int ccdModule, int ccdOutput) {
        return getUncertaintiesFsId(PDQ_PATH_PREFIX, timeSeriesType.getName(),
            targetTableId, ccdModule, ccdOutput);
    }

    private static FsId getTimeSeriesFsId(String pathPrefix,
        String timeSeriesName, int targetTableId) {
        StringBuilder fullPath = new StringBuilder();
        fullPath.append(pathPrefix).append('/');
        fullPath.append(targetTableId).append('/');
        fullPath.append(timeSeriesName);
        return new FsId(fullPath.toString());
    }

    private static FsId getUncertaintiesFsId(String pathPrefix,
        String timeSeriesName, int targetTableId) {
        StringBuilder fullPath = new StringBuilder();
        fullPath.append(pathPrefix).append('/');
        fullPath.append(targetTableId).append('/');
        fullPath.append(timeSeriesName).append(PDQ_SEP);
        fullPath.append(UNCERTAINTIES);
        return new FsId(fullPath.toString());
    }

    private static FsId getTimeSeriesFsId(String pathPrefix,
        String timeSeriesName, int targetTableId, int ccdModule, int ccdOutput) {
        StringBuilder fullPath = new StringBuilder();
        fullPath.append(pathPrefix).append('/');
        fullPath.append(targetTableId).append('/');
        fullPath.append(timeSeriesName).append('/');
        fullPath.append(ccdModule).append(PDQ_SEP);
        fullPath.append(ccdOutput);
        return new FsId(fullPath.toString());
    }

    private static FsId getUncertaintiesFsId(String pathPrefix,
        String timeSeriesName, int targetTableId, int ccdModule, int ccdOutput) {
        StringBuilder fullPath = new StringBuilder();
        fullPath.append(pathPrefix).append('/');
        fullPath.append(targetTableId).append('/');
        fullPath.append(timeSeriesName).append('/');
        fullPath.append(ccdModule).append(PDQ_SEP);
        fullPath.append(ccdOutput).append(PDQ_SEP);
        fullPath.append(UNCERTAINTIES);
        return new FsId(fullPath.toString());
    }
}
