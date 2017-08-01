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

package gov.nasa.kepler.pdc;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * 
 * @author Forrest Girouard
 */
public class SpsdRemovalParameters implements Parameters, Persistable {

    private int bigPicturePolyOrder;
    private float harmonicFalsePositiveRate;
    private int logTimeConstantIncrement;
    private float logTimeConstantMaxValue;
    private int logTimeConstantStartValue;
    private int polyWindowHalfWidth;
    private int recoveryWindowWidth;
    private boolean shortCadencePostCorrectionEnabled;
    private int shortCadencePostCorrectionLeftWindow;
    private String shortCadencePostCorrectionMethod = "";
    private int shortCadencePostCorrectionRightWindow;
    private boolean useMapBasisVectors;

    public int getBigPicturePolyOrder() {
        return bigPicturePolyOrder;
    }

    public void setBigPicturePolyOrder(int bigPicturePolyOrder) {
        this.bigPicturePolyOrder = bigPicturePolyOrder;
    }

    public float getHarmonicFalsePositiveRate() {
        return harmonicFalsePositiveRate;
    }

    public void setHarmonicFalsePositiveRate(float harmonicFalsePositiveRate) {
        this.harmonicFalsePositiveRate = harmonicFalsePositiveRate;
    }

    public int getLogTimeConstantIncrement() {
        return logTimeConstantIncrement;
    }

    public void setLogTimeConstantIncrement(int logTimeConstantIncrement) {
        this.logTimeConstantIncrement = logTimeConstantIncrement;
    }

    public float getLogTimeConstantMaxValue() {
        return logTimeConstantMaxValue;
    }

    public void setLogTimeConstantMaxValue(float logTimeConstantMaxValue) {
        this.logTimeConstantMaxValue = logTimeConstantMaxValue;
    }

    public int getLogTimeConstantStartValue() {
        return logTimeConstantStartValue;
    }

    public void setLogTimeConstantStartValue(int logTimeConstantStartValue) {
        this.logTimeConstantStartValue = logTimeConstantStartValue;
    }

    public int getPolyWindowHalfWidth() {
        return polyWindowHalfWidth;
    }

    public void setPolyWindowHalfWidth(int polyWindowHalfWidth) {
        this.polyWindowHalfWidth = polyWindowHalfWidth;
    }

    public int getRecoveryWindowWidth() {
        return recoveryWindowWidth;
    }

    public void setRecoveryWindowWidth(int recoveryWindowWidth) {
        this.recoveryWindowWidth = recoveryWindowWidth;
    }

    public boolean isShortCadencePostCorrectionEnabled() {
        return shortCadencePostCorrectionEnabled;
    }

    public void setShortCadencePostCorrectionEnabled(
        boolean shortCadencePostCorrectionEnabled) {
        this.shortCadencePostCorrectionEnabled = shortCadencePostCorrectionEnabled;
    }

    public int getShortCadencePostCorrectionLeftWindow() {
        return shortCadencePostCorrectionLeftWindow;
    }

    public void setShortCadencePostCorrectionLeftWindow(
        int shortCadencePostCorrectionLeftWindow) {
        this.shortCadencePostCorrectionLeftWindow = shortCadencePostCorrectionLeftWindow;
    }

    public String getShortCadencePostCorrectionMethod() {
        return shortCadencePostCorrectionMethod;
    }

    public void setShortCadencePostCorrectionMethod(
        String shortCadencePostCorrectionMethod) {
        this.shortCadencePostCorrectionMethod = shortCadencePostCorrectionMethod;
    }

    public int getShortCadencePostCorrectionRightWindow() {
        return shortCadencePostCorrectionRightWindow;
    }

    public void setShortCadencePostCorrectionRightWindow(
        int shortCadencePostCorrectionRightWindow) {
        this.shortCadencePostCorrectionRightWindow = shortCadencePostCorrectionRightWindow;
    }

    public boolean isUseMapBasisVectors() {
        return useMapBasisVectors;
    }

    public void setUseMapBasisVectors(boolean useMapBasisVectors) {
        this.useMapBasisVectors = useMapBasisVectors;
    }
}
