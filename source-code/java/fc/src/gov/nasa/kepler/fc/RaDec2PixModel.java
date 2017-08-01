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
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.spiffy.common.persistable.Persistable;

public class RaDec2PixModel implements Persistable {
    private double mjdStart;
    private double mjdEnd;

    private String spiceFileDir = "";
    private String spiceSpacecraftEphemerisFilename = "";
    private String planetaryEphemerisFilename = "";
    private String leapSecondFilename = "";

    private PointingModel pointingModel = new PointingModel();
    private GeometryModel geometryModel = new GeometryModel();
    private RollTimeModel rollTimeModel = new RollTimeModel();

    // FcConstants extraction to eliminate the need for matlab to call java
    // directly:
    //
    private double HALF_OFFSET_MODULE_ANGLE_DEGREES = FcConstants.HALF_OFFSET_MODULE_ANGLE_DEGREES;
    private int OUTPUTS_PER_ROW = FcConstants.OUTPUTS_PER_ROW;
    private int OUTPUTS_PER_COLUMN = FcConstants.OUTPUTS_PER_COLUMN;
    private int nRowsImaging = FcConstants.nRowsImaging;
    private int nColsImaging = FcConstants.nColsImaging;
    private int nMaskedSmear = FcConstants.nMaskedSmear;
    private int nLeadingBlack = FcConstants.nLeadingBlack;
    private double NOMINAL_CLOCKING_ANGLE = FcConstants.NOMINAL_CLOCKING_ANGLE;
    private int nModules = FcConstants.nModules;
    private double mjdOffset = ModifiedJulianDate.MJD_OFFSET_FROM_JD;

    /**
     * Required by {@link Persistable}.
     */
    public RaDec2PixModel() {
    }

    /**
     * 
     * @param mjdStart
     * @param mjdEnd
     * @param pointingModel
     * @param geometryModel
     * @param rollTimeModel
     * @param spiceFileDir
     * @param spiceFileName
     * @param planetaryEphemerisFilename
     * @param leapSecondFilename
     */
    public RaDec2PixModel(double mjdStart, double mjdEnd,
        PointingModel pointingModel, GeometryModel geometryModel,
        RollTimeModel rollTimeModel, String spiceFileDir, String spiceFileName,
        String planetaryEphemerisFilename, String leapSecondFilename) {

        this.mjdStart = mjdStart;
        this.mjdEnd = mjdEnd;

        this.pointingModel = pointingModel;
        this.geometryModel = geometryModel;
        this.rollTimeModel = rollTimeModel;

        this.spiceFileDir = spiceFileDir;
        this.spiceFileDir = spiceFileDir;
        spiceSpacecraftEphemerisFilename = spiceFileName;
        this.planetaryEphemerisFilename = planetaryEphemerisFilename;
        this.leapSecondFilename = leapSecondFilename;
    }

    public double getMjdStart() {
        return mjdStart;
    }

    public void setMjdStart(double mjdStart) {
        this.mjdStart = mjdStart;
    }

    public double getMjdEnd() {
        return mjdEnd;
    }

    public void setMjdEnd(double mjdEnd) {
        this.mjdEnd = mjdEnd;
    }

    public PointingModel getPointingModel() {
        return pointingModel;
    }

    public void setPointingModel(PointingModel pointingModel) {
        this.pointingModel = pointingModel;
    }

    public GeometryModel getGeometryModel() {
        return geometryModel;
    }

    public void setGeometryModel(GeometryModel geometryModel) {
        this.geometryModel = geometryModel;
    }

    public RollTimeModel getRollTimeModel() {
        return rollTimeModel;
    }

    public void setRollTimeModel(RollTimeModel rollTimeModel) {
        this.rollTimeModel = rollTimeModel;
    }

    public String getSpiceFileDir() {
        return spiceFileDir;
    }

    public void setSpiceFileDir(String spiceFileDir) {
        this.spiceFileDir = spiceFileDir;
    }

    public String getSpacecraftEphemerisFilename() {
        return spiceSpacecraftEphemerisFilename;
    }

    public void setSpacecraftEphemerisFilename(String spiceFileName) {
        spiceSpacecraftEphemerisFilename = spiceFileName;
    }

    @Override
    public String toString() {
        String out = "";
        out += pointingModel.toString();
        out += geometryModel.toString();
        out += rollTimeModel.toString();
        out += " " + spiceFileDir + "/" + spiceSpacecraftEphemerisFilename;
        return out;
    }

    public String getLeapsecondFilename() {
        return leapSecondFilename;
    }

    public void setLeapSecondFilename(String leapSecondFilename) {
        this.leapSecondFilename = leapSecondFilename;
    }

    public String getPlanetaryEphemerisFilename() {
        return planetaryEphemerisFilename;
    }

    public void setPlanetaryEphemerisFilename(String planetaryEphemerisFilename) {
        this.planetaryEphemerisFilename = planetaryEphemerisFilename;
    }

    public double getHALF_OFFSET_MODULE_ANGLE_DEGREES() {
        return HALF_OFFSET_MODULE_ANGLE_DEGREES;
    }

    public int getOUTPUTS_PER_ROW() {
        return OUTPUTS_PER_ROW;
    }

    public int getOUTPUTS_PER_COLUMN() {
        return OUTPUTS_PER_COLUMN;
    }

    public int getNRowsImaging() {
        return nRowsImaging;
    }

    public int getNColsImaging() {
        return nColsImaging;
    }

    public int getNMaskedSmear() {
        return nMaskedSmear;
    }

    public int getNLeadingBlack() {
        return nLeadingBlack;
    }

    public double getNOMINAL_CLOCKING_ANGLE() {
        return NOMINAL_CLOCKING_ANGLE;
    }

    public int getNModules() {
        return nModules;
    }

    public double getMjdOffset() {
        return mjdOffset;
    }

}
