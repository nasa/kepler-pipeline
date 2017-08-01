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
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyInfo;

import java.util.Arrays;

import org.apache.commons.lang.ArrayUtils;

public class TwoDBlackModel implements Persistable {
    private double[] mjds = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private int[] rows = ArrayUtils.EMPTY_INT_ARRAY;
    private int[] columns = ArrayUtils.EMPTY_INT_ARRAY;
    private FcModelMetadata fcModelMetadata = new FcModelMetadata();

    @ProxyInfo(preservePrecision=true)
    private float[][][] blacks = new float[0][][];
    @ProxyInfo(preservePrecision=true)
    private float[][][] uncertainties = new float[0][][];

    // FcConstants extraction to eliminate the need for matlab to call java directly:
    //
    private final int ccdRows = FcConstants.CCD_ROWS;
    private final int ccdColumns = FcConstants.CCD_COLUMNS;
    
    /**
     * Required by {@link Persistable}.
     */
    public TwoDBlackModel() {
    }
    
    /**
     * @param mjds
     * @param rows
     * @param columns
     * @param flat
     */
    public TwoDBlackModel(double[] mjds, int[] rows, int[] columns,
        float[][][] blacks, float[][][] uncertainties) {
        this.mjds = mjds;
        this.rows = rows;
        this.columns = columns;
        this.blacks = blacks;
        this.uncertainties = uncertainties;
    }

    /**
     * 
     * @param mjd
     * @param flat
     */
    public TwoDBlackModel(double[] mjds, float[][][] blacks,
        float[][][] uncertainties) {
        this.mjds = mjds;
        this.blacks = blacks;
        this.uncertainties = uncertainties;
    }

    public double[] getMjds() {
        return this.mjds;
    }

    public void setMjds(double[] mjds) {
        this.mjds = mjds;
    }

    public int[] getRows() {
        return this.rows;
    }

    public void setRows(int[] rows) {
        this.rows = rows;
    }

    public int[] getColumns() {
        return this.columns;
    }

    public void setColumns(int[] columns) {
        this.columns = columns;
    }

    public float[][][] getBlacks() {
        return this.blacks;
    }

    public void setBlacks(float[][][] blacks) {
        this.blacks = blacks;
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + Arrays.hashCode(blacks);
        result = PRIME * result + Arrays.hashCode(uncertainties);
        result = PRIME * result + Arrays.hashCode(columns);
        result = PRIME * result + Arrays.hashCode(mjds);
        result = PRIME * result + Arrays.hashCode(rows);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        final TwoDBlackModel other = (TwoDBlackModel) obj;
        if (!Arrays.equals(blacks, other.blacks))
            return false;
        if (!Arrays.equals(uncertainties, other.uncertainties))
            return false;
        if (!Arrays.equals(columns, other.columns))
            return false;
        if (!Arrays.equals(mjds, other.mjds))
            return false;
        if (!Arrays.equals(rows, other.rows))
            return false;
        return true;
    }

    public float[][][] getUncertainties() {
        return uncertainties;
    }

    public void setUncertainties(float[][][] uncertainties) {
        this.uncertainties = uncertainties;
    }
    
    public int getCcdRows() {
        return this.ccdRows;
    }

    public int getCcdColumns() {
        return this.ccdColumns;
    }

    public void setFcModelMetadata(FcModelMetadata fcModelMetadata) {
        this.fcModelMetadata = fcModelMetadata;
    }

    public FcModelMetadata getFcModelMetadata() {
        return fcModelMetadata;
    }
}
