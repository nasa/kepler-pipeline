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

package gov.nasa.kepler.fc.pointing;

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.FcModelFactory;
import gov.nasa.kepler.fc.PointingModel;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.hibernate.fc.Pointing;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Date;
import java.util.List;

/**
 * PointingOperations handles the JDO operations for the Pointing class.
 * 
 * @author Kester Allen
 * 
 */
public class PointingOperations {

    private static HistoryModelName HISTORY_NAME = HistoryModelName.POINTING;

    private DatabaseService dbService;
    private FcCrud fcCrud;
    private History history;

    /**
     * Default constructor; uses the current models. Run the method
     * {@link setHistory} to use a different History.
     * 
     * @throws PipelineException
     */
    public PointingOperations() {
        this(DatabaseServiceFactory.getInstance());
    }

    public PointingOperations(DatabaseService databaseService) {
        this.dbService = databaseService;
        fcCrud = new FcCrud(dbService);
        history = null;
    }

    /**
     * Persist a Pointing object into the database.
     * 
     * @param pointing
     */
    public void persistPointing(Pointing pointing) {
        fcCrud.create(pointing);
    }

    // N.B.: Didn't add a retrieveMostRecentPointingModel() that only returns
    // the most
    // recent Pointing instance-- there's no sensible usecase for that.
    //

    /**
     * Generate a PointingModel comprising all pointing info in the db
     * 
     * @return
     * @throws PipelineException
     */
    public PointingModel retrievePointingModelAll() {
        List<Pointing> pointings = fcCrud.retrievePointing(getHistory());
        return FcModelFactory.pointingModel(pointings);
    }

    /**
     * Return the unique pointing models that are valid for the range of
     * specified MJD times. The PointingModel will contain only the distinct
     * models that are valid for that time range, without duplicates.
     * 
     * @param mjdStart
     * @param mjdEnd
     * @return
     * @throws PipelineException
     */
    public PointingModel retrievePointingModel(double mjdStart, double mjdEnd) {

        List<Pointing> pointings = retrievePointingsBetween(mjdStart, mjdEnd);

        // Convert to array:
        //
        double[] mjdsArr = new double[pointings.size()];
        double[] rasArr = new double[pointings.size()];
        double[] declinationsArr = new double[pointings.size()];
        double[] rollsArr = new double[pointings.size()];
        double[] segmentStartMjdsArr = new double[pointings.size()];
        for (int ii = 0; ii < pointings.size(); ++ii) {
            mjdsArr[ii] = pointings.get(ii)
                .getMjd();
            rasArr[ii] = pointings.get(ii)
                .getRa();
            declinationsArr[ii] = pointings.get(ii)
                .getDeclination();
            rollsArr[ii] = pointings.get(ii)
                .getRoll();
            segmentStartMjdsArr[ii] = pointings.get(ii)
                .getSegmentStartMjd();
        }

        // Instantiate PointingModel:
        //
        return FcModelFactory.pointingModel(mjdsArr, rasArr, declinationsArr,
            rollsArr, segmentStartMjdsArr);
    }

    public Pointing retrievePointing(double mjd) {
        return fcCrud.retrievePointing(mjd, getHistory());
    }

    public Pointing retrievePointingExact(double mjd) {
        return fcCrud.retrievePointingExact(mjd, getHistory());
    }

    public Pointing retrieveNextPointing(double mjd) {
        return fcCrud.retrieveNextPointing(mjd, getHistory());
    }

    public Pointing[] retrievePointings(double[] mjds) {
        return fcCrud.retrievePointings(mjds, getHistory());
    }

    public Pointing[] retrieveUniquePointings(double[] mjds) {
        return fcCrud.retrieveUniquePointings(mjds, getHistory());
    }

    public List<Pointing> retrievePointingsBetween(double mjdStart,
        double mjdEnd) {
        return fcCrud.retrievePointingsBetween(mjdStart, mjdEnd, getHistory());
    }

    public double[][] retrievePointingsArray(double[] mjds) {
        return fcCrud.retrievePointingsArray(mjds, getHistory());
    }

    public double[] retrievePointingRasArray(double[] mjds) {
        return fcCrud.retrievePointingRasArray(mjds, getHistory());
    }

    public double[] retrievePointingDecsArray(double[] mjds) {
        return fcCrud.retrievePointingDecsArray(mjds, getHistory());
    }

    public double[] retrievePointingRollsArray(double[] mjds) {
        return fcCrud.retrievePointingRollsArray(mjds, getHistory());
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
                "creating new history in PointingOperations.getHistory because the table was empty",
                1);
            fcCrud.create(history);
        }
        return history;
    }

    public void setHistory(History history) {
        this.history = history;
    }
}
