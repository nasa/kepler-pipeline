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

public class FlatFieldModel implements Persistable {
    private double[] mjds = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private int[] rows = ArrayUtils.EMPTY_INT_ARRAY;
    private int[] columns = ArrayUtils.EMPTY_INT_ARRAY;

    @ProxyInfo(preservePrecision = true)
    private float[][][] flats = new float[0][][];
    @ProxyInfo(preservePrecision = true)
    private float[][][] uncertainties = new float[0][][];

    // Large scale flat definition:
    //
    private int[] polynomialOrder = ArrayUtils.EMPTY_INT_ARRAY;
    private String[] type = ArrayUtils.EMPTY_STRING_ARRAY;

    private int[] xIndex = ArrayUtils.EMPTY_INT_ARRAY;
    private double[] offsetX = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private double[] scaleX = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private double[] originX = ArrayUtils.EMPTY_DOUBLE_ARRAY;

    private int[] yIndex = ArrayUtils.EMPTY_INT_ARRAY;
    private double[] offsetY = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private double[] scaleY = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private double[] originY = ArrayUtils.EMPTY_DOUBLE_ARRAY;

    private double[][] coeffs = new double[0][];
    private double[][] covars = new double[0][];

    // FcConstants extraction to eliminate the need for matlab to call java
    // directly:
    //
    private int ccdRows = FcConstants.CCD_ROWS;
    private int ccdColumns = FcConstants.CCD_COLUMNS;
    
    private FcModelMetadata fcModelMetadataLargeFlat = new FcModelMetadata();
    private FcModelMetadata fcModelMetadataSmallFlat = new FcModelMetadata();
    
    /**
     * Required by {@link Persistable}.
     */
    public FlatFieldModel() {
        this.polynomialOrder = ArrayUtils.EMPTY_INT_ARRAY;
        this.type = ArrayUtils.EMPTY_STRING_ARRAY;

        this.xIndex = ArrayUtils.EMPTY_INT_ARRAY;
        this.offsetX = ArrayUtils.EMPTY_DOUBLE_ARRAY;
        this.scaleX = ArrayUtils.EMPTY_DOUBLE_ARRAY;
        this.originX = ArrayUtils.EMPTY_DOUBLE_ARRAY;

        this.yIndex = ArrayUtils.EMPTY_INT_ARRAY;
        this.offsetY = ArrayUtils.EMPTY_DOUBLE_ARRAY;
        this.scaleY = ArrayUtils.EMPTY_DOUBLE_ARRAY;
        this.originY = ArrayUtils.EMPTY_DOUBLE_ARRAY;

        this.coeffs = new double[0][];
        this.covars = new double[0][];
        
        this.rows = ArrayUtils.EMPTY_INT_ARRAY;
        this.columns = ArrayUtils.EMPTY_INT_ARRAY;
        this.mjds = ArrayUtils.EMPTY_DOUBLE_ARRAY;
        
        this.flats = new float[0][][];
        this.uncertainties = new float[0][][];
    }

    /**
     * 
     * @param mjds
     * @param rows
     * @param columns
     * @param flats
     * @param uncertainties
     * @param polynomialOrder
     * @param type
     * @param index
     * @param offsetX
     * @param scaleX
     * @param originX
     * @param index2
     * @param offsetY
     * @param scaleY
     * @param originY
     * @param coeffs
     * @param covars
     */
    public FlatFieldModel(double[] mjds, int[] rows, int[] columns,
        float[][][] flats, float[][][] uncertainties, int[] polynomialOrder,
        String[] type, int[] index, double[] offsetX, double[] scaleX,
        double[] originX, int[] index2, double[] offsetY, double[] scaleY,
        double[] originY, double[][] coeffs, double[][] covars) {

        this.mjds = mjds;
        this.rows = rows;
        this.columns = columns;
        this.flats = flats;
        this.uncertainties = uncertainties;
        this.polynomialOrder = polynomialOrder;
        this.type = type;
        this.xIndex = index;
        this.offsetX = offsetX;
        this.scaleX = scaleX;
        this.originX = originX;
        this.yIndex = index2;
        this.offsetY = offsetY;
        this.scaleY = scaleY;
        this.originY = originY;
        this.coeffs = coeffs;
        this.covars = covars;
    }

    /**
     * 
     * @param mjds
     * @param flats
     * @param uncertainties
     * @param polynomialOrder
     * @param type
     * @param index
     * @param offsetX
     * @param scaleX
     * @param originX
     * @param index2
     * @param offsetY
     * @param scaleY
     * @param originY
     * @param coeffs
     * @param covars
     */
    public FlatFieldModel(double[] mjds, float[][][] flats,
        float[][][] uncertainties, int[] polynomialOrder, String[] type,
        int[] index, double[] offsetX, double[] scaleX, double[] originX,
        int[] index2, double[] offsetY, double[] scaleY, double[] originY,
        double[][] coeffs, double[][] covars) {
        this(mjds, new int[0], new int[0], flats, uncertainties,
            polynomialOrder, type, index, offsetX, scaleX, originX, index2,
            offsetY, scaleY, originY, coeffs, covars);
    }

    public FlatFieldModel(double[] mjds, float[][][] flats,
        float[][][] uncertainties, int[] polynomialOrder, int[] rows,
        int[] columns, String[] type, int[] index, double[] offsetX,
        double[] scaleX, double[] originX, int[] index2, double[] offsetY,
        double[] scaleY, double[] originY, double[][] coeffs, double[][] covars) {
        this(mjds, rows, columns, flats, uncertainties, polynomialOrder, type,
            index, offsetX, scaleX, originX, index2, offsetY, scaleY, originY,
            coeffs, covars);
    }

    /**
     * @param mjds
     * @param rows
     * @param columns
     * @param flat
     */
    public FlatFieldModel(double[] mjds, float[][][] flats,
        float[][][] uncertainties, int[] rows, int[] columns) {
        this(mjds, flats, uncertainties);
        this.rows = rows;
        this.columns = columns;
    }

    /**
     * 
     * @param mjds
     * @param flat
     */
    public FlatFieldModel(double[] mjds, float[][][] flats,
        float[][][] uncertainties) {
        this();
        this.mjds = mjds;
        this.flats = flats;
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

    public float[][][] getFlats() {
        return this.flats;
    }

    public void setFlat(float[][][] flats) {
        this.flats = flats;
    }

    public float[][][] getUncertainties() {
        return uncertainties;
    }

    public void setUncertainties(float[][][] uncertainties) {
        this.uncertainties = uncertainties;
    }

    public void setFlats(float[][][] flats) {
        this.flats = flats;
    }

    public int[] getPolynomialOrder() {
        return this.polynomialOrder;
    }

    public void setPolynomialOrder(int[] polynomialOrder) {
        this.polynomialOrder = polynomialOrder;
    }

    public String[] getType() {
        return this.type;
    }

    public void setType(String[] type) {
        this.type = type;
    }

    public int[] getXIndex() {
        return this.xIndex;
    }

    public void setXIndex(int[] index) {
        this.xIndex = index;
    }

    public double[] getOffsetX() {
        return this.offsetX;
    }

    public void setOffsetX(double[] offsetX) {
        this.offsetX = offsetX;
    }

    public double[] getScaleX() {
        return this.scaleX;
    }

    public void setScaleX(double[] scaleX) {
        this.scaleX = scaleX;
    }

    public double[] getOriginX() {
        return this.originX;
    }

    public void setOriginX(double[] originX) {
        this.originX = originX;
    }

    public int[] getYIndex() {
        return this.yIndex;
    }

    public void setYIndex(int[] index) {
        this.yIndex = index;
    }

    public double[] getOffsetY() {
        return this.offsetY;
    }

    public void setOffsetY(double[] offsetY) {
        this.offsetY = offsetY;
    }

    public double[] getScaleY() {
        return this.scaleY;
    }

    public void setScaleY(double[] scaleY) {
        this.scaleY = scaleY;
    }

    public double[] getOriginY() {
        return this.originY;
    }

    public void setOriginY(double[] originY) {
        this.originY = originY;
    }

    public double[][] getCoeffs() {
        return this.coeffs;
    }

    public void setCoeffs(double[][] coeffs) {
        this.coeffs = coeffs;
    }

    public double[][] getCovars() {
        return this.covars;
    }

    public void setCovars(double[][] covars) {
        this.covars = covars;
    }

    // Large scale flat field individual accessors:
    //
    public double getMjd(int iTime) {
        return this.mjds[iTime];
    }

    public int getPolynomialOrder(int iTime) {
        return this.polynomialOrder[iTime];
    }

    public String getType(int iTime) {
        return this.type[iTime];
    }

    public int getXIndex(int iTime) {
        return this.xIndex[iTime];
    }

    public double getOffsetX(int iTime) {
        return this.offsetX[iTime];
    }

    public double getScaleX(int iTime) {
        return this.scaleX[iTime];
    }

    public double getOriginX(int iTime) {
        return this.originX[iTime];
    }

    public int getYIndex(int iTime) {
        return this.yIndex[iTime];
    }

    public double getOffsetY(int iTime) {
        return this.offsetY[iTime];
    }

    public double getScaleY(int iTime) {
        return this.scaleY[iTime];
    }

    public double getOriginY(int iTime) {
        return this.originY[iTime];
    }

    public double[] getCoeffs(int iTime) {
        return this.coeffs[iTime];
    }

    public double[] getCovars(int iTime) {
        return this.covars[iTime];
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Arrays.hashCode(columns);
        result = prime * result + Arrays.hashCode(flats);
        result = prime * result + Arrays.hashCode(mjds);
        result = prime * result + Arrays.hashCode(rows);
        result = prime * result + Arrays.hashCode(uncertainties);
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
        final FlatFieldModel other = (FlatFieldModel) obj;
        if (!Arrays.equals(columns, other.columns))
            return false;
        if (!Arrays.equals(flats, other.flats))
            return false;
        if (!Arrays.equals(mjds, other.mjds))
            return false;
        if (!Arrays.equals(rows, other.rows))
            return false;
        if (!Arrays.equals(uncertainties, other.uncertainties))
            return false;
        return true;
    }

    public int getCcdRows() {
        return this.ccdRows;
    }

    public void setCcdRows(int ccdRows) {
        this.ccdRows = ccdRows;
    }

    public int getCcdColumns() {
        return this.ccdColumns;
    }

    public void setCcdColumns(int ccdColumns) {
        this.ccdColumns = ccdColumns;
    }

    public void setFcModelMetadataLargeFlat(FcModelMetadata fcModelMetadataLargeFlat) {
        this.fcModelMetadataLargeFlat = fcModelMetadataLargeFlat;
    }

    public FcModelMetadata getFcModelMetadataLargeFlat() {
        return fcModelMetadataLargeFlat;
    }

    public void setFcModelMetadataSmallFlat(FcModelMetadata fcModelMetadataSmallFlat) {
        this.fcModelMetadataSmallFlat = fcModelMetadataSmallFlat;
    }

    public FcModelMetadata getFcModelMetadataSmallFlat() {
        return fcModelMetadataSmallFlat;
    }

}
