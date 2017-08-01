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

package gov.nasa.kepler.common.pi;

import gov.nasa.kepler.common.ConfigMapDerivedValues;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

public class PlannedSpacecraftConfigParameters implements Parameters,
    Persistable {

    private int scConfigId;
    private double mjd;

    /**
     * WARNING! NOT WHAT YOU'D EXPECT: Integration time is commanded in number
     * of FGS frames. So the period of each integration is
     * fgsFramesPerIntegration * the FGS frame period + the readout time.
     * FDMINTPER * 0.10379 sec + 0.51895 sec.
     */
    private int fgsFramesPerIntegration;
    private double millisecondsPerFgsFrame;
    private double millisecondsPerReadout;

    private int integrationsPerShortCadence;
    private int shortCadencesPerLongCadence;
    private int longCadencesPerBaseline;
    private int integrationsPerScienceFfi;

    private int smearStartRow;
    private int smearEndRow;
    private int smearStartCol;
    private int smearEndCol;
    private int maskedStartRow;
    private int maskedEndRow;
    private int maskedStartCol;
    private int maskedEndCol;
    private int darkStartRow;
    private int darkEndRow;
    private int darkStartCol;
    private int darkEndCol;

    private long lcRequantFixedOffset;
    private long scRequantFixedOffset;

    public double getSecondsPerShortCadence() {
        return ConfigMapDerivedValues.getSecondsPerShortCadence(
            fgsFramesPerIntegration, millisecondsPerFgsFrame,
            millisecondsPerReadout, integrationsPerShortCadence);
    }

    public PlannedSpacecraftConfigParameters() {
    }

    public int getScConfigId() {
        return scConfigId;
    }

    public void setScConfigId(int scConfigId) {
        this.scConfigId = scConfigId;
    }

    public double getMjd() {
        return mjd;
    }

    public void setMjd(double mjd) {
        this.mjd = mjd;
    }

    public int getFgsFramesPerIntegration() {
        return fgsFramesPerIntegration;
    }

    public void setFgsFramesPerIntegration(int fgsFramesPerIntegration) {
        this.fgsFramesPerIntegration = fgsFramesPerIntegration;
    }

    public double getMillisecondsPerFgsFrame() {
        return millisecondsPerFgsFrame;
    }

    public void setMillisecondsPerFgsFrame(double millisecondsPerFgsFrame) {
        this.millisecondsPerFgsFrame = millisecondsPerFgsFrame;
    }

    public double getMillisecondsPerReadout() {
        return millisecondsPerReadout;
    }

    public void setMillisecondsPerReadout(double millisecondsPerReadout) {
        this.millisecondsPerReadout = millisecondsPerReadout;
    }

    public int getIntegrationsPerShortCadence() {
        return integrationsPerShortCadence;
    }

    public void setIntegrationsPerShortCadence(int integrationsPerShortCadence) {
        this.integrationsPerShortCadence = integrationsPerShortCadence;
    }

    public int getShortCadencesPerLongCadence() {
        return shortCadencesPerLongCadence;
    }

    public void setShortCadencesPerLongCadence(int shortCadencesPerLongCadence) {
        this.shortCadencesPerLongCadence = shortCadencesPerLongCadence;
    }

    public int getLongCadencesPerBaseline() {
        return longCadencesPerBaseline;
    }

    public void setLongCadencesPerBaseline(int longCadencesPerBaseline) {
        this.longCadencesPerBaseline = longCadencesPerBaseline;
    }

    public int getIntegrationsPerScienceFfi() {
        return integrationsPerScienceFfi;
    }

    public void setIntegrationsPerScienceFfi(int integrationsPerScienceFfi) {
        this.integrationsPerScienceFfi = integrationsPerScienceFfi;
    }

    public int getSmearStartRow() {
        return smearStartRow;
    }

    public void setSmearStartRow(int smearStartRow) {
        this.smearStartRow = smearStartRow;
    }

    public int getSmearEndRow() {
        return smearEndRow;
    }

    public void setSmearEndRow(int smearEndRow) {
        this.smearEndRow = smearEndRow;
    }

    public int getSmearStartCol() {
        return smearStartCol;
    }

    public void setSmearStartCol(int smearStartCol) {
        this.smearStartCol = smearStartCol;
    }

    public int getSmearEndCol() {
        return smearEndCol;
    }

    public void setSmearEndCol(int smearEndCol) {
        this.smearEndCol = smearEndCol;
    }

    public int getMaskedStartRow() {
        return maskedStartRow;
    }

    public void setMaskedStartRow(int maskedStartRow) {
        this.maskedStartRow = maskedStartRow;
    }

    public int getMaskedEndRow() {
        return maskedEndRow;
    }

    public void setMaskedEndRow(int maskedEndRow) {
        this.maskedEndRow = maskedEndRow;
    }

    public int getMaskedStartCol() {
        return maskedStartCol;
    }

    public void setMaskedStartCol(int maskedStartCol) {
        this.maskedStartCol = maskedStartCol;
    }

    public int getMaskedEndCol() {
        return maskedEndCol;
    }

    public void setMaskedEndCol(int maskedEndCol) {
        this.maskedEndCol = maskedEndCol;
    }

    public int getDarkStartRow() {
        return darkStartRow;
    }

    public void setDarkStartRow(int darkStartRow) {
        this.darkStartRow = darkStartRow;
    }

    public int getDarkEndRow() {
        return darkEndRow;
    }

    public void setDarkEndRow(int darkEndRow) {
        this.darkEndRow = darkEndRow;
    }

    public int getDarkStartCol() {
        return darkStartCol;
    }

    public void setDarkStartCol(int darkStartCol) {
        this.darkStartCol = darkStartCol;
    }

    public int getDarkEndCol() {
        return darkEndCol;
    }

    public void setDarkEndCol(int darkEndCol) {
        this.darkEndCol = darkEndCol;
    }

    public long getLcRequantFixedOffset() {
        return lcRequantFixedOffset;
    }

    public void setLcRequantFixedOffset(long lcRequantFixedOffset) {
        this.lcRequantFixedOffset = lcRequantFixedOffset;
    }

    public long getScRequantFixedOffset() {
        return scRequantFixedOffset;
    }

    public void setScRequantFixedOffset(long scRequantFixedOffset) {
        this.scRequantFixedOffset = scRequantFixedOffset;
    }

}
