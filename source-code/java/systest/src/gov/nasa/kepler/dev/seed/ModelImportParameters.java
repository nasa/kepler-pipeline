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

package gov.nasa.kepler.dev.seed;

import gov.nasa.spiffy.common.pi.Parameters;

public class ModelImportParameters implements Parameters {

    private String rolltimePath = "";
    private String pointingPath = "";
    private String geometryPath = "";
    private String spacecraftEphemPath = "";
    private String readNoisePath = "";
    private String gainPath = "";
    private String linearityPath = "";
    private String undershootPath = "";
    private String invalidPixelsPath = "";
    private String largeFlatPath = "";
    private String smallFlatPath = "";
    private String prfPath = "";
    private String twodBlackPath = "";
    private String planetaryEphemPath = "";
    private String leapSecsPath = "";
    private String sclkPath = "";
    private String saturationPath = "";
    private String kicOverrideModelPath = "";
    private String observingLogModelPath = "";
    private String transitParameterModelPath = "";
    private String transitNameModelPath = "";
    private String ebTransitParameterModelPath = "";

    public ModelImportParameters() {
    }

    public String getRolltimePath() {
        return rolltimePath;
    }

    public void setRolltimePath(String rolltimePath) {
        this.rolltimePath = rolltimePath;
    }

    public String getPointingPath() {
        return pointingPath;
    }

    public void setPointingPath(String pointingPath) {
        this.pointingPath = pointingPath;
    }

    public String getGeometryPath() {
        return geometryPath;
    }

    public void setGeometryPath(String geometryPath) {
        this.geometryPath = geometryPath;
    }

    public String getReadNoisePath() {
        return readNoisePath;
    }

    public void setReadNoisePath(String readNoisePath) {
        this.readNoisePath = readNoisePath;
    }

    public String getGainPath() {
        return gainPath;
    }

    public void setGainPath(String gainPath) {
        this.gainPath = gainPath;
    }

    public String getLinearityPath() {
        return linearityPath;
    }

    public void setLinearityPath(String linearityPath) {
        this.linearityPath = linearityPath;
    }

    public String getUndershootPath() {
        return undershootPath;
    }

    public void setUndershootPath(String undershootPath) {
        this.undershootPath = undershootPath;
    }

    public String getInvalidPixelsPath() {
        return invalidPixelsPath;
    }

    public void setInvalidPixelsPath(String invalidPixelsPath) {
        this.invalidPixelsPath = invalidPixelsPath;
    }

    public String getLargeFlatPath() {
        return largeFlatPath;
    }

    public void setLargeFlatPath(String largeFlatPath) {
        this.largeFlatPath = largeFlatPath;
    }

    public String getSmallFlatPath() {
        return smallFlatPath;
    }

    public void setSmallFlatPath(String smallFlatPath) {
        this.smallFlatPath = smallFlatPath;
    }

    public String getPrfPath() {
        return prfPath;
    }

    public void setPrfPath(String prfPath) {
        this.prfPath = prfPath;
    }

    public String getTwodBlackPath() {
        return twodBlackPath;
    }

    public void setTwodBlackPath(String twodBlackPath) {
        this.twodBlackPath = twodBlackPath;
    }

    public String getSpacecraftEphemPath() {
        return spacecraftEphemPath;
    }

    public void setSpacecraftEphemPath(String spacecraftEphemPath) {
        this.spacecraftEphemPath = spacecraftEphemPath;
    }

    public String getPlanetaryEphemPath() {
        return planetaryEphemPath;
    }

    public void setPlanetaryEphemPath(String planetaryEphemPath) {
        this.planetaryEphemPath = planetaryEphemPath;
    }

    public String getLeapSecsPath() {
        return leapSecsPath;
    }

    public void setLeapSecsPath(String leapSecsPath) {
        this.leapSecsPath = leapSecsPath;
    }

    public String getSclkPath() {
        return sclkPath;
    }

    public void setSclkPath(String sclkPath) {
        this.sclkPath = sclkPath;
    }

    public String getSaturationPath() {
        return saturationPath;
    }

    public void setSaturationPath(String saturationPath) {
        this.saturationPath = saturationPath;
    }

    public String getKicOverrideModelPath() {
        return kicOverrideModelPath;
    }

    public void setKicOverrideModelPath(String kicOverrideModelPath) {
        this.kicOverrideModelPath = kicOverrideModelPath;
    }

    public String getObservingLogModelPath() {
        return observingLogModelPath;
    }

    public void setObservingLogModelPath(String observingLogModelPath) {
        this.observingLogModelPath = observingLogModelPath;
    }

    public String getTransitParameterModelPath() {
        return transitParameterModelPath;
    }

    public void setTransitParameterModelPath(String transitParameterModelPath) {
        this.transitParameterModelPath = transitParameterModelPath;
    }

    public String getTransitNameModelPath() {
        return transitNameModelPath;
    }

    public void setTransitNameModelPath(String transitNameModelPath) {
        this.transitNameModelPath = transitNameModelPath;
    }

    public String getEbTransitParameterModelPath() {
        return ebTransitParameterModelPath;
    }

    public void setEbTransitParameterModelPath(String ebTransitParameterModelPath) {
        this.ebTransitParameterModelPath = ebTransitParameterModelPath;
    }

}
