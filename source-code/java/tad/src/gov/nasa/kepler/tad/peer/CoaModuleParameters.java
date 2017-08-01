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

package gov.nasa.kepler.tad.peer;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * Used to pass data to and from MATLAB.
 * 
 * @author Miles Cote
 */
public class CoaModuleParameters implements Persistable, Parameters {

    private int dvaMeshEdgeBuffer;
    private int dvaMeshOrder;
    private int nDvaMeshRows;
    private int nDvaMeshCols;
    private int nOutputBufferPix;
    private int nStarImageRows;
    private int nStarImageCols;
    private int starChunkLength;

    private double raOffset;
    private double decOffset;
    private double phiOffset;

    private float saturationSpillBufferSize;

    private boolean motionPolynomialsEnabled;
    private boolean backgroundPolynomialsEnabled;

    public CoaModuleParameters() {
    }

    public int getDvaMeshEdgeBuffer() {
        return dvaMeshEdgeBuffer;
    }

    public void setDvaMeshEdgeBuffer(int dvaMeshEdgeBuffer) {
        this.dvaMeshEdgeBuffer = dvaMeshEdgeBuffer;
    }

    public int getDvaMeshOrder() {
        return dvaMeshOrder;
    }

    public void setDvaMeshOrder(int dvaMeshOrder) {
        this.dvaMeshOrder = dvaMeshOrder;
    }

    public int getnDvaMeshCols() {
        return nDvaMeshCols;
    }

    public void setnDvaMeshCols(int dvaMeshCols) {
        nDvaMeshCols = dvaMeshCols;
    }

    public int getnDvaMeshRows() {
        return nDvaMeshRows;
    }

    public void setnDvaMeshRows(int dvaMeshRows) {
        nDvaMeshRows = dvaMeshRows;
    }

    public int getnOutputBufferPix() {
        return nOutputBufferPix;
    }

    public void setnOutputBufferPix(int outputBufferPix) {
        nOutputBufferPix = outputBufferPix;
    }

    public int getnStarImageCols() {
        return nStarImageCols;
    }

    public void setnStarImageCols(int starImageCols) {
        nStarImageCols = starImageCols;
    }

    public int getnStarImageRows() {
        return nStarImageRows;
    }

    public void setnStarImageRows(int starImageRows) {
        nStarImageRows = starImageRows;
    }

    public int getStarChunkLength() {
        return starChunkLength;
    }

    public void setStarChunkLength(int starChunkLength) {
        this.starChunkLength = starChunkLength;
    }

    public double getDecOffset() {
        return decOffset;
    }

    public void setDecOffset(double decOffset) {
        this.decOffset = decOffset;
    }

    public double getPhiOffset() {
        return phiOffset;
    }

    public void setPhiOffset(double phiOffset) {
        this.phiOffset = phiOffset;
    }

    public double getRaOffset() {
        return raOffset;
    }

    public void setRaOffset(double raOffset) {
        this.raOffset = raOffset;
    }

    public float getSaturationSpillBufferSize() {
        return saturationSpillBufferSize;
    }

    public void setSaturationSpillBufferSize(float saturationSpillBufferSize) {
        this.saturationSpillBufferSize = saturationSpillBufferSize;
    }

    public boolean isMotionPolynomialsEnabled() {
        return motionPolynomialsEnabled;
    }

    public void setMotionPolynomialsEnabled(boolean motionPolynomialsEnabled) {
        this.motionPolynomialsEnabled = motionPolynomialsEnabled;
    }

    public boolean isBackgroundPolynomialsEnabled() {
        return backgroundPolynomialsEnabled;
    }

    public void setBackgroundPolynomialsEnabled(
        boolean backgroundPolynomialsEnabled) {
        this.backgroundPolynomialsEnabled = backgroundPolynomialsEnabled;
    }

}
