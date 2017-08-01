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

import java.util.ArrayList;
import java.util.List;

public final class PpaFsIdFactory {

    public static final String PPA_PATH_PREFIX = "/ppa";
    private static final String PPA_SEP = ":";

    public static enum TimeSeriesType {
        // PMD
        BACKGROUND_LEVEL_UNCERTAINTIES,
        BACKGROUND_LEVEL(BACKGROUND_LEVEL_UNCERTAINTIES),
        CENTROIDS_MEAN_ROW_UNCERTAINTIES,
        CENTROIDS_MEAN_ROW(CENTROIDS_MEAN_ROW_UNCERTAINTIES),
        CENTROIDS_MEAN_COLUMN_UNCERTAINTIES,
        CENTROIDS_MEAN_COLUMN(CENTROIDS_MEAN_COLUMN_UNCERTAINTIES),
        PLATE_SCALE_UNCERTAINTIES,
        PLATE_SCALE(PLATE_SCALE_UNCERTAINTIES),
        CDPP_EXPECTED_VALUES,
        CDPP_EXPECTED_UNCERTAINTIES,
        CDPP_MEASURED_VALUES,
        CDPP_MEASURED_UNCERTAINTIES,
        CDPP_RATIO_VALUES,
        CDPP_RATIO_UNCERTAINTIES,

        // PAG
        THEORETICAL_COMPRESSION_EFFICIENCY,
        ACHIEVED_COMPRESSION_EFFICIENCY,

        // PAD
        // RA, DEC, ROLL are now doubles and moved to database.
        COVARIANCE_MATRIX_1_1,
        COVARIANCE_MATRIX_2_2,
        COVARIANCE_MATRIX_3_3,
        COVARIANCE_MATRIX_1_2,
        COVARIANCE_MATRIX_1_3,
        COVARIANCE_MATRIX_2_3,
        MAX_ATTITUDE_FOCAL_PLANE_RESIDUAL;

        private final String name;
        private final TimeSeriesType uncertaintiesType;

        private TimeSeriesType() {
            this(null);
        }

        private TimeSeriesType(TimeSeriesType uncertaintiesType) {
            name = StringUtils.constantToCamel(toString())
                .intern();
            this.uncertaintiesType = uncertaintiesType;
        }

        public String getName() {
            return name;
        }

        public TimeSeriesType uncertaintiesType() {
            return uncertaintiesType;
        }
    }

    /**
     * No instances.
     */
    private PpaFsIdFactory() {
    }

    public static FsId getTimeSeriesFsId(TimeSeriesType timeSeriesType) {

        StringBuilder fullPath = new StringBuilder();
        fullPath.append(PPA_PATH_PREFIX)
            .append('/')
            .append(timeSeriesType.getName());

        return new FsId(fullPath.toString());
    }

    public static FsId getTimeSeriesFsId(TimeSeriesType timeSeriesType,
        int ccdModule, int ccdOutput) {

        StringBuilder fullPath = new StringBuilder();
        fullPath.append(getTimeSeriesFsId(timeSeriesType))
            .append('/')
            .append(ccdModule)
            .append(PPA_SEP)
            .append(ccdOutput);

        return new FsId(fullPath.toString());
    }

    public static FsId getTimeSeriesFsId(TimeSeriesType timeSeriesType,
        int ccdModule, int ccdOutput, int magnitude, int hour) {

        StringBuilder fullPath = new StringBuilder();
        fullPath.append(getTimeSeriesFsId(timeSeriesType, ccdModule, ccdOutput))
            .append(PPA_SEP)
            .append(magnitude)
            .append(PPA_SEP)
            .append(hour);

        return new FsId(fullPath.toString());
    }

    /**
     * Returns a {@code Set} containing all the mnemonics supported by this
     * {@code FsId} factory.
     */
    public static List<String> getAncillaryPipelineDataMnemonics() {

        List<String> mnemonics = new ArrayList<String>();
        for (TimeSeriesType type : TimeSeriesType.values()) {
            if (type.uncertaintiesType() != null) {
                mnemonics.add(type.toString());
            }
        }
        return mnemonics;
    }

    /**
     * Returns the {@code FsId} for the given {@code mnemonic}'s data values.
     * 
     * @param mnemonic a {@code String} whose value is a valid ancillary
     * pipeline data mnemonic for this factory.
     * @param ccdModule a CCD module.
     * @param ccdOutput a CCD output.
     * @return the {@code FsId} for the corresponding ancillary pipeline data
     * values.
     * @see #getAncillaryPipelineDataMnemonics()
     */
    public static FsId getAncillaryPipelineDataFsId(String mnemonic,
        int ccdModule, int ccdOutput) {

        for (TimeSeriesType type : TimeSeriesType.values()) {
            if (type.toString()
                .equals(mnemonic) && type.uncertaintiesType() != null) {
                return getTimeSeriesFsId(type, ccdModule, ccdOutput);
            }
        }
        throw new IllegalArgumentException(String.format(
            "%s: invalid ancillary pipeline data mnemonic", mnemonic));
    }

    /**
     * Returns the {@code FsId} for the given {@code mnemonic}'s uncertainties
     * values.
     * 
     * @param mnemonic a {@code String} whose value is a valid ancillary
     * pipeline data mnemonic for this factory.
     * @param ccdModule a CCD module.
     * @param ccdOutput a CCD output.
     * @return the {@code FsId} for the corresponding ancillary pipeline data
     * uncertainties.
     * @see #getAncillaryPipelineDataMnemonics()
     */
    public static FsId getAncillaryPipelineDataUncertaintiesFsId(
        String mnemonic, int ccdModule, int ccdOutput) {

        for (TimeSeriesType type : TimeSeriesType.values()) {
            if (type.toString()
                .equals(mnemonic) && type.uncertaintiesType() != null) {
                return getTimeSeriesFsId(type.uncertaintiesType(), ccdModule,
                    ccdOutput);
            }
        }
        throw new IllegalArgumentException(String.format(
            "%s: invalid ancillary pipeline data mnemonic", mnemonic));
    }
}
