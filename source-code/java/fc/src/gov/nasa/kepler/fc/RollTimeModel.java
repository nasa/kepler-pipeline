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

package gov.nasa.kepler.fc;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.hibernate.fc.RollTime;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.PipelineException;

import org.apache.commons.lang.ArrayUtils;

/**
 * Importer for the immutable rollTimeModel.
 * 
 * @author Forrest Girouard
 * 
 */
public class RollTimeModel implements Persistable {

    private double[] mjds = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private int[] seasons = ArrayUtils.EMPTY_INT_ARRAY;
    private double[] rollOffsets = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private double[] fovCenterRas = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private double[] fovCenterDeclinations = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private double[] fovCenterRolls = ArrayUtils.EMPTY_DOUBLE_ARRAY;

    private FcModelMetadata fcModelMetadata = new FcModelMetadata();

    /**
     * Required by {@link Persistable}.
     */
    public RollTimeModel() {
    }

    public RollTimeModel(double[] mjds, int[] seasons) {
        this.mjds = mjds;
        this.seasons = seasons;

        rollOffsets = new double[mjds.length];
        fovCenterRas = new double[mjds.length];
        fovCenterDeclinations = new double[mjds.length];
        fovCenterRolls = new double[mjds.length];
        for (int i = 0; i < mjds.length; i++) {
            if (mjds[i] >= FcConstants.KEPLER_END_OF_MISSION_MJD) {
                throw new IllegalArgumentException(
                    String.format(
                        "All roll times with a MJD greater than %d must be fully specified.",
                        FcConstants.KEPLER_END_OF_MISSION_MJD));
            }
            rollOffsets[i] = RollTime.KEPLER_ROLL_OFFSET;
            fovCenterRas[i] = RollTime.KEPLER_FOV_CENTER_RA;
            fovCenterDeclinations[i] = RollTime.KEPLER_FOV_CENTER_DECLINATION;
            fovCenterRolls[i] = RollTime.KEPLER_FOV_CENTER_ROLL;
        }
        checkSize();
    }

    public RollTimeModel(double[] mjds, int[] seasons,
        double[] rollOffsets, double[] fovCenterRas,
        double[] fovCenterDeclinations, double[] fovCenterRolls) {
        this.mjds = mjds;
        this.seasons = seasons;
        this.rollOffsets = rollOffsets;
        this.fovCenterRas = fovCenterRas;
        this.fovCenterDeclinations = fovCenterDeclinations;
        this.fovCenterRolls = fovCenterRolls;
        checkSize();
    }

    public int size() {
        checkSize();
        return mjds.length;
    }

    private void checkSize() {
        if (mjds.length != seasons.length || mjds.length != rollOffsets.length
            || mjds.length != fovCenterRas.length
            || mjds.length != fovCenterDeclinations.length
            || mjds.length != fovCenterRolls.length) {
            throw new PipelineException("Inconsistent sizes in RollTimeModel");
        }
    }

    @Override
    public String toString() {
        StringBuilder out = new StringBuilder();
        try {
            for (int i = 0; i < size(); ++i) {
                out.append(mjds[i])
                    .append(" ");
                out.append(rollOffsets[i])
                    .append(" ");
                out.append(fovCenterRas[i])
                    .append(" ");
                out.append(fovCenterDeclinations[i])
                    .append(" ");
                out.append(fovCenterRolls[i])
                    .append(" ");
                out.append("\n");
            }
        } catch (PipelineException p) {
            out.setLength(0);
            out.append("ERROR IN RollTimeModel.toString()");
        }

        return out.toString();
    }

    public double[] getMjds() {
        return mjds;
    }

    public int[] getSeasons() {
        return seasons;
    }

    public double[] getRollOffsets() {
        return rollOffsets;
    }

    public double[] getFovCenterRas() {
        return fovCenterRas;
    }

    public double[] getFovCenterDeclinations() {
        return fovCenterDeclinations;
    }

    public double[] getFovCenterRolls() {
        return fovCenterRolls;
    }

    public void setFcModelMetadata(FcModelMetadata fcModelMetadata) {
        this.fcModelMetadata = fcModelMetadata;
    }

    public FcModelMetadata getFcModelMetadata() {
        return fcModelMetadata;
    }
}
