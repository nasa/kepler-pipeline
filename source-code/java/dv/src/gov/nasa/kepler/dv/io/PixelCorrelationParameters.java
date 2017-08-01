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

package gov.nasa.kepler.dv.io;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * Pixel correlation module parameters.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class PixelCorrelationParameters implements Parameters, Persistable {

    private String apertureSymbol = "";
    private float chiSquaredTolerance;
    private String colorMap = "";
    private int iterationLimit;
    private float iterativeWhitenerTolerance;
    private float maxColorAxis;
    private int numIndicesDisplayedInAlerts;
    private String optimalApertureSymbol = "";
    private String significanceSymbol = "";
    private float significanceThreshold;
    private int timeoutPerTargetSeconds;

    public String getApertureSymbol() {
        return apertureSymbol;
    }

    public void setApertureSymbol(String apertureSymbol) {
        this.apertureSymbol = apertureSymbol;
    }

    public float getChiSquaredTolerance() {
        return chiSquaredTolerance;
    }

    public void setChiSquaredTolerance(float chiSquaredTolerance) {
        this.chiSquaredTolerance = chiSquaredTolerance;
    }

    public String getColorMap() {
        return colorMap;
    }

    public void setColorMap(String colorMap) {
        this.colorMap = colorMap;
    }

    public int getIterationLimit() {
        return iterationLimit;
    }

    public void setIterationLimit(int iterationLimit) {
        this.iterationLimit = iterationLimit;
    }

    public float getIterativeWhitenerTolerance() {
        return iterativeWhitenerTolerance;
    }

    public void setIterativeWhitenerTolerance(float iterativeWhitenerTolerance) {
        this.iterativeWhitenerTolerance = iterativeWhitenerTolerance;
    }

    public float getMaxColorAxis() {
        return maxColorAxis;
    }

    public void setMaxColorAxis(float maxColorAxis) {
        this.maxColorAxis = maxColorAxis;
    }

    public int getNumIndicesDisplayedInAlerts() {
        return numIndicesDisplayedInAlerts;
    }

    public void setNumIndicesDisplayedInAlerts(int numIndicesDisplayedInAlerts) {
        this.numIndicesDisplayedInAlerts = numIndicesDisplayedInAlerts;
    }

    public String getOptimalApertureSymbol() {
        return optimalApertureSymbol;
    }

    public void setOptimalApertureSymbol(String optimalApertureSymbol) {
        this.optimalApertureSymbol = optimalApertureSymbol;
    }

    public String getSignificanceSymbol() {
        return significanceSymbol;
    }

    public void setSignificanceSymbol(String significanceSymbol) {
        this.significanceSymbol = significanceSymbol;
    }

    public float getSignificanceThreshold() {
        return significanceThreshold;
    }

    public void setSignificanceThreshold(float significanceThreshold) {
        this.significanceThreshold = significanceThreshold;
    }
    
    public int getTimeoutPerTargetSeconds() {
        return timeoutPerTargetSeconds;
    }
    
    public void setTimeoutPerTargetSeconds(int timeoutPerTargetSeconds) {
        this.timeoutPerTargetSeconds = timeoutPerTargetSeconds;
    }

}
