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

package gov.nasa.kepler.hibernate.fc;

import gov.nasa.kepler.common.FcConstants;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

/**
 * This class encapsulates the roll times of the Kepler spacecraft and its
 * geometric facing (season).
 * 
 * The permitted range for season is 0-3 (0-summer, 1-fall, 2-winter, 3-spring).
 * 
 * @author Forrest Girouard
 * @author kester
 * 
 */
@Entity
@Table(name = "FC_ROLLTIME")
public class RollTime {

    public static final double KEPLER_ROLL_OFFSET = 110.0;
    public static final double KEPLER_FOV_CENTER_RA = 290.666666666667;
    public static final double KEPLER_FOV_CENTER_DECLINATION = 44.5;
    public static final double KEPLER_FOV_CENTER_ROLL = 0.0;

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "FC_ROLLTIME_SEQ")
    private long id;

    /**
     * The Modified Julian Date of the roll time.
     */
    private double mjd;

    /**
     * The season corresponding to this rollTime.
     * 
     * The permitted range for season is 0-3 (0-summer, 1-fall, 2-winter,
     * 3-spring).
     */
    private int season = -1;

    /**
     * Units in degrees.
     */
    private double rollOffset;
    private double fovCenterRa;
    private double fovCenterDeclination;
    private double fovCenterRoll;

    /**
     * Default constructor.
     */
    public RollTime() {
    }

    /**
     * @param mjd
     * @param season
     */
    public RollTime(double mjd, int season) {
        if (mjd >= FcConstants.KEPLER_END_OF_MISSION_MJD) {
            throw new IllegalArgumentException(
                String.format(
                    "All roll times with a MJD greater than %d must be fully specified.",
                    FcConstants.KEPLER_END_OF_MISSION_MJD));
        }
        this.mjd = mjd;
        this.season = season;
        rollOffset = KEPLER_ROLL_OFFSET;
        fovCenterRa = KEPLER_FOV_CENTER_RA;
        fovCenterDeclination = KEPLER_FOV_CENTER_DECLINATION;
        fovCenterRoll = KEPLER_FOV_CENTER_ROLL;
    }

    public RollTime(double mjd, int season, double rollOffset,
        double fovCenterRa, double fovCenterDeclination, double fovCenterRoll) {
        this.mjd = mjd;
        this.season = season;
        this.rollOffset = rollOffset;
        this.fovCenterRa = fovCenterRa;
        this.fovCenterDeclination = fovCenterDeclination;
        this.fovCenterRoll = fovCenterRoll;
    }

    @Override
    public String toString() {
        StringBuilder out = new StringBuilder();
        out.append(mjd).append(" ");
        out.append(season).append(" ");
        out.append(rollOffset).append(" ");
        out.append(fovCenterRa).append(" ");
        out.append(fovCenterDeclination).append(" ");
        out.append(fovCenterRoll).append(" ");
        return out.toString();
    }

    public double getMjd() {
        return mjd;
    }

    public void setMjd(double mjd) {
        this.mjd = mjd;
    }

    public int getSeason() {
        return season;
    }

    public void setSeason(int season) {
        this.season = season;
    }

    public double getRollOffset() {
        return rollOffset;
    }

    public void setRollOffset(double rollOffset) {
        this.rollOffset = rollOffset;
    }

    public double getFovCenterRa() {
        return fovCenterRa;
    }

    public void setFovCenterRa(double fovCenterRa) {
        this.fovCenterRa = fovCenterRa;
    }

    public double getFovCenterDeclination() {
        return fovCenterDeclination;
    }

    public void setFovCenterDeclination(double fovCenterDeclination) {
        this.fovCenterDeclination = fovCenterDeclination;
    }

    public double getFovCenterRoll() {
        return fovCenterRoll;
    }

    public void setFovCenterRoll(double fovCenterRoll) {
        this.fovCenterRoll = fovCenterRoll;
    }

}
