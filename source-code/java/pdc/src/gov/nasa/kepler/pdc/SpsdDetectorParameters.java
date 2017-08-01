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
public class SpsdDetectorParameters implements Parameters, Persistable {

    private int minWindowWidth;
    private int mode;
    private int sgPolyOrder;
    private int sgStepPolyOrder;
    private int shortSgPolyOrder;
    private int shortSgStepPolyOrder;
    private int shortWindowWidth;
    private int windowWidth;

    public int getMinWindowWidth() {
        return minWindowWidth;
    }

    public void setMinWindowWidth(int minWindowWidth) {
        this.minWindowWidth = minWindowWidth;
    }

    public int getMode() {
        return mode;
    }

    public void setMode(int mode) {
        this.mode = mode;
    }

    public int getSgPolyOrder() {
        return sgPolyOrder;
    }

    public void setSgPolyOrder(int sgPolyOrder) {
        this.sgPolyOrder = sgPolyOrder;
    }

    public int getSgStepPolyOrder() {
        return sgStepPolyOrder;
    }

    public void setSgStepPolyOrder(int sgStepPolyOrder) {
        this.sgStepPolyOrder = sgStepPolyOrder;
    }

    public int getShortSgPolyOrder() {
        return shortSgPolyOrder;
    }

    public void setShortSgPolyOrder(int shortSgPolyOrder) {
        this.shortSgPolyOrder = shortSgPolyOrder;
    }

    public int getShortSgStepPolyOrder() {
        return shortSgStepPolyOrder;
    }

    public void setShortSgStepPolyOrder(int shortSgStepPolyOrder) {
        this.shortSgStepPolyOrder = shortSgStepPolyOrder;
    }

    public int getShortWindowWidth() {
        return shortWindowWidth;
    }

    public void setShortWindowWidth(int shortWindowWidth) {
        this.shortWindowWidth = shortWindowWidth;
    }

    public int getWindowWidth() {
        return windowWidth;
    }

    public void setWindowWidth(int windowWidth) {
        this.windowWidth = windowWidth;
    }
}
