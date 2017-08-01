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

package gov.nasa.kepler.hibernate.cm;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * Represents a single sky group.
 * <p>
 * As the telescope rotates each season, a star's light falls on a different
 * CCD. Each star is assigned to a sky group located in your database's
 * CM_SKY_GROUP table which remains fixed as the telescope rotates. The grouping
 * is therefore a function of the CCD module, CCD output, and observing season
 * and refers to a specific patch of sky. The typical use for this object is to
 * retrieve a subset of the stars in the KIC which is immune to the seasonal
 * rotation of the telescope.
 * <p>
 * This class is immutable.
 * 
 * @author Bill Wohler
 */
@Entity
@Table(name = "CM_SKY_GROUP")
public class SkyGroup {
    /**
     * The default season for the sky group ID. The default season is defined as
     * the season when the sky group ID is equal to the channel number. This
     * also happens to be the season when module/output 2/1 is channel #1 and
     * has its greatest declination. The seasons are defined as:
     * <p>
     * <table>
     * <tr>
     * <th>Number</th>
     * <th>Season</th>
     * <th>MJD</th>
     * <th>Date</th>
     * </tr>
     * <tr>
     * <td>0</td>
     * <td>summer</td>
     * <td>55000</td>
     * <td>2009-06-18</td>
     * </tr>
     * <tr>
     * <td>1</td>
     * <td>fall</td>
     * <td>55091</td>
     * <td>2009-09-17</td>
     * </tr>
     * <tr>
     * <td>2</td>
     * <td>winter</td>
     * <td>55182</td>
     * <td>2009-12-17</td>
     * </tr>
     * <tr>
     * <td>3</td>
     * <td>spring</td>
     * <td>55277</td>
     * <td>2010-03-22</td>
     * </tr>
     * </table>
     * <p>
     * The times are subject to change (see FC_ROLLTIME table).
     * 
     * @see <a
     * href="http://www.csgnetwork.com/julianmodifdateconv.html">Modified Julian
     * date converter</a>
     */
    public static final int DEFAULT_SEASON = 2;

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "CM_SKY_GROUP_SEQ")
    private long id;

    @Column(nullable = false)
    private int skyGroupId;

    @Column(nullable = false)
    private int ccdModule;

    @Column(nullable = false)
    private int ccdOutput;

    @Column(nullable = false)
    private int observingSeason;

    /**
     * Default constructor for Hibernate use only.
     */
    SkyGroup() {
    }

    /**
     * Creates a {@link SkyGroup} object with the given ID, CCD module, output,
     * and observing season.
     * 
     * @param skyGroupId the sky group ID.
     * @param ccdModule the module (1-25).
     * @param ccdOutput the output (1-4).
     * @param observingSeason the observing season (0-3).
     */
    public SkyGroup(int skyGroupId, int ccdModule, int ccdOutput,
        int observingSeason) {
        // If general methods are created that test the validity of a module,
        // output, and season, perhaps it would be good to test the parameters
        // with them.
        this.skyGroupId = skyGroupId;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.observingSeason = observingSeason;
    }

    /**
     * Returns the sky group ID.
     */
    public int getSkyGroupId() {
        return skyGroupId;
    }

    /**
     * Returns the CCD module for this sky group.
     * 
     * @return a number between 1 and 25 inclusive.
     */
    public int getCcdModule() {
        return ccdModule;
    }

    /**
     * Returns the CCD output for this sky group.
     * 
     * @return a number between 1 and 4 inclusive.
     */
    public int getCcdOutput() {
        return ccdOutput;
    }

    /**
     * Returns the observing season for this sky group. The spacecraft's season
     * is slightly different from our own as it has a longer year. The season
     * numbers were originally defined in the Mission Plan (KP-106), p. 65, but
     * have changed in two ways:
     * <p>
     * <ol>
     * <li>Launch is in Winter, 2009, not Summer, 2008.
     * <li> Seasons go from 0-3 instead of 1-4.
     * </ol>
     * <p>
     * The definitive resource for mapping a date to a season is the roll times
     * table (FC_ROLLTIMES).
     * 
     * @return a number between 0 and 3 inclusive.
     */
    public int getObservingSeason() {
        return observingSeason;
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + ccdModule;
        result = PRIME * result + ccdOutput;
        result = PRIME * result + skyGroupId;
        result = PRIME * result + observingSeason;
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (getClass() != obj.getClass())
            return false;
        final SkyGroup other = (SkyGroup) obj;
        if (ccdModule != other.ccdModule)
            return false;
        if (ccdOutput != other.ccdOutput)
            return false;
        if (skyGroupId != other.skyGroupId)
            return false;
        if (observingSeason != other.observingSeason)
            return false;
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("id", skyGroupId)
            .append("ccdModule", ccdModule)
            .append("ccdOutput", ccdOutput)
            .append("observingSeason", observingSeason)
            .toString();
    }
}
