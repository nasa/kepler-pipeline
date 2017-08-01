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

package gov.nasa.kepler.fc.rolltime;

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.FcModelFactory;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.fc.RollTimeModel;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.hibernate.fc.RollTime;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * RollTimeOperations handles the database operations for the Pointing class.
 * 
 * @author Kester Allen
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class RollTimeOperations {

    private static final HistoryModelName HISTORY_NAME = HistoryModelName.ROLLTIME;

    /**
     * Actual start of Q0, not in roll-times table.
     */
    private static final double START_Q0 = 54953.0;

    /**
     * Actual start of Q1, not in roll-times table.
     */
    private static final double START_Q1 = 54964.0;

    /**
     * Amount to add to index into roll-time table to achieve quarter.
     */
    private static final int ROLL_TIME_TABLE_QUARTER_OFFSET = -1;

    private FcCrud fcCrud;
    private History history;

    public RollTimeOperations() {
        this(DatabaseServiceFactory.getInstance());
    }

    public RollTimeOperations(DatabaseService dbService) {
        fcCrud = new FcCrud(dbService);
        history = null;
    }

    public void persistRollTime(RollTime rollTime) {
        fcCrud.create(rollTime);
    }

    public RollTime retrieveRollTime(double mjd) {
        return fcCrud.retrieveRollTime(mjd, getHistory());
    }

    public RollTime retrieveRollTimeExact(double mjd) {
        return fcCrud.retrieveRollTimeExact(mjd, getHistory());
    }

    public List<RollTime> retrieveAllRollTimes() {
        return fcCrud.retrieveAllRollTimes(getHistory());
    }

    public int[] mjdToQuarter(double[] mjds) {

        int[] quarters = new int[mjds.length];
        List<RollTime> rollTimes = retrieveAllRollTimes();

        for (int i = 0; i < mjds.length; ++i) {
            // Mark MJDs that fall before Q0 as invalid (-1).
            quarters[i] = -1;
            if (mjds[i] <= START_Q0) {
                continue;
            }
            if (mjds[i] <= START_Q1) {
                quarters[i] = 0;
                continue;
            }
            // The following relies on the rollTimes being in ascending order.
            for (int j = 0; j < rollTimes.size(); j++) {
                if (mjds[i] <= rollTimes.get(j)
                    .getMjd()) {
                    quarters[i] = j + ROLL_TIME_TABLE_QUARTER_OFFSET;
                    break;
                }
            }
            // If the MJD is past the last roll, give it the last known quarter.
            if (quarters[i] == -1) {
                quarters[i] = rollTimes.size() + ROLL_TIME_TABLE_QUARTER_OFFSET;
            }
        }

        return quarters;
    }

    public int mjdToSeason(double mjd) {
        RollTime rollTime = retrieveRollTime(mjd);
        if (rollTime == null) {
            throw new NullPointerException(
                new ModifiedJulianDate(mjd).toStringYMDHMS()
                    + ": roll times unavailable");
        }
        return rollTime.getSeason();
    }

    public int[] jdToQuarter(double[] jds) {
        double[] mjds = new double[jds.length];
        for (int ii = 0; ii < jds.length; ++ii) {
            mjds[ii] = jds[ii] - ModifiedJulianDate.MJD_OFFSET_FROM_JD;
        }
        return mjdToQuarter(mjds);
    }

    public RollTimeModel retrieveRollTimeModelAll() {
        List<RollTime> rollTimes = retrieveAllRollTimes();

        return convertRollTimesToModel(rollTimes);
    }

    private RollTimeModel convertRollTimesToModel(List<RollTime> rollTimes) {
        List<Double> mjdsList = new ArrayList<Double>();
        List<Integer> seasonsList = new ArrayList<Integer>();
        List<Double> rollimeoffsetsList = new ArrayList<Double>();
        List<Double> fovCenterRasList = new ArrayList<Double>();
        List<Double> fovCenterDeclinationsList = new ArrayList<Double>();
        List<Double> fovCenterRollsList = new ArrayList<Double>();

        for (RollTime rollTime : rollTimes) {
            mjdsList.add(rollTime.getMjd());
            seasonsList.add(rollTime.getSeason());
            rollimeoffsetsList.add(rollTime.getRollOffset());
            fovCenterRasList.add(rollTime.getFovCenterRa());
            fovCenterDeclinationsList.add(rollTime.getFovCenterDeclination());
            fovCenterRollsList.add(rollTime.getFovCenterRoll());
        }

        // Convert to arrays:
        //
        double[] mjds = new double[mjdsList.size()];
        int[] seasons = new int[mjds.length];
        double[] rollimeOffsets = new double[mjds.length];
        double[] fovCenterRas = new double[mjds.length];
        double[] fovCenterDeclinations = new double[mjds.length];
        double[] fovCenterRolls = new double[mjds.length];
        for (int ii = 0; ii < mjds.length; ++ii) {
            mjds[ii] = mjdsList.get(ii);
            seasons[ii] = seasonsList.get(ii);
            rollimeOffsets[ii] = rollimeoffsetsList.get(ii);
            fovCenterRas[ii] = fovCenterRasList.get(ii);
            fovCenterDeclinations[ii] = fovCenterDeclinationsList.get(ii);
            fovCenterRolls[ii] = fovCenterRollsList.get(ii);
        }

        return FcModelFactory.rollTimeModel(mjds, seasons, rollimeOffsets,
            fovCenterRas, fovCenterDeclinations, fovCenterRolls);
    }

    public RollTimeModel retrieveMostRecentRollTimeModel() {
        double now = ModifiedJulianDate.dateToMjd(new Date());

        RollTime rollTime = retrieveRollTime(now);
        return FcModelFactory.rollTimeModel(new double[] { rollTime.getMjd() },
            new int[] { rollTime.getSeason() },
            new double[] { rollTime.getRollOffset() },
            new double[] { rollTime.getFovCenterRa() },
            new double[] { rollTime.getFovCenterDeclination() },
            new double[] { rollTime.getFovCenterRoll() });
    }

    /**
     * Return the unique roll time models that are valid for the range of
     * specified MJD times. The RollTimeModel will contain only the distinct
     * models that are valid for that time range, without duplicates.
     * 
     * @param mjdStart
     * @param mjdEnd
     * @return
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public RollTimeModel retrieveRollTimeModel(double mjdStart, double mjdEnd) {

        List<RollTime> rollTimes = fcCrud.retrieveRollTimeBetween(mjdStart,
            mjdEnd, getHistory());

        return convertRollTimesToModel(rollTimes);
    }

    public History getHistory() {
        if (history == null) {
            history = fcCrud.retrieveHistory(HISTORY_NAME);
        }

        if (history == null) {
            Date now = new Date();
            double mjdNow = ModifiedJulianDate.dateToMjd(now);
            history = new History(
                mjdNow,
                HISTORY_NAME,
                "history created by RollTimeOperations.getHistory() because the table was empty",
                1);
            fcCrud.create(history);
        }
        return history;
    }

    public void setHistory(History history) {
        this.history = history;
    }

    void setFcCrud(FcCrud fcCrud) {
        this.fcCrud = fcCrud;
    }
}
