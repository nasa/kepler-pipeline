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

package gov.nasa.kepler.fc.linearity;

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.FcModelFactory;
import gov.nasa.kepler.fc.FcUtilities;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.fc.LinearityModel;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.hibernate.fc.Linearity;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * The LinearityOperations class handles the JDO operations for the
 * LinearityTable class.
 * 
 * @author Kester Allen
 * 
 */
public class LinearityOperations {
    /**
     * Logger for this class
     */
    private static HistoryModelName HISTORY_NAME = HistoryModelName.LINEARITY;
    private static final Log log = LogFactory.getLog(LinearityOperations.class);

    private DatabaseService dbService;
    private FcCrud fcCrud;
    private History history;

    /**
     * LinearityOperations constructor. Initializes dbService and fcCrud
     * 
     * @throws PipelineException
     */
    public LinearityOperations() {
        this(DatabaseServiceFactory.getInstance());
    }

    public LinearityOperations(DatabaseService databaseService)
        {
        this.dbService = databaseService;
        fcCrud = new FcCrud(dbService);
        history = null;
    }

//    /**
//     * Constructor to get models that were valid at the time specified by
//     * history.
//     */
//    public LinearityOperations(double historyMjd) {
//        this.dbService = DatabaseServiceFactory.getInstance();
//        fcCrud = new FcCrud(dbService);
//        history = new History(historyMjd, HISTORY_NAME);
//    }
//
//    public LinearityOperations(History history) {
//        this(DatabaseServiceFactory.getInstance(), history);
//    }
//    
//    public LinearityOperations(DatabaseService dbService, History history) {
//        this.history = history;
//        fcCrud = new FcCrud(dbService);
//        fcCrud.create(history);
//    }
    
    /**
     * 
     * @param mod
     * @param out
     * @param start
     * @param end
     * @return A list of the Linearity objects in the range start-end for the
     * mod/out specified.
     * @throws FocalPlaneException 
     */
    public List<Linearity> retrieveLinearity(int mod, int out, double startMjd,
        double stopMjd) {
    	List<Linearity> linearitys = fcCrud.retrieveLinearityBetween(mod, out,
				startMjd, stopMjd, history);
    	if (linearitys.size() == 0) {
    		throw new FocalPlaneException(
					"no linearity objects in db for specified range"
							+ " module " + mod + " output " + out + " MJD "
							+ startMjd + " to " + stopMjd);
    	}
    	return linearitys;
    }

    /**
     * 
     * @param module
     * @param output
     * @param time
     * @return
     * @throws FocalPlaneException
     * @throws Exception
     */
    public double[] retrieveLinearity(int module, int output, double mjd)
        {
        if (log.isDebugEnabled()) {
            log.debug("getLinearityCorrection(int, int, Date) - start");
        }

        if (!FcUtilities.isAllowedModule(module)
            || !FcUtilities.isAllowedOutput(output)) {
            throw new FocalPlaneException("The inputs module=" + module
                + " or output=" + output + " are out of range.");
        }

        Linearity outLt = fcCrud.retrieve(module, output, mjd, history);

        if (log.isDebugEnabled()) {
            log.debug("getLinearityCorrection(int, int, Date) - end");
        }

        if (null != outLt) {
            return outLt.getCoefficients();
        } else {
            throw new FocalPlaneException("no linearity objects in database");
        }
    }
    
    public Linearity retrieveLinearityExact(int module, int output, double mjd) {
        Linearity linearity = fcCrud.retrieveExact(module, output, mjd);
        return linearity;
    }

    public double[] retrieveLinearity(Linearity lt) {
        if (log.isDebugEnabled()) {
            log.debug("getLinearityCorrection(Linearity) - start");
        }

        double[] returnCoeffs = retrieveLinearity(lt.getCcdModule(),
            lt.getCcdOutput(), lt.getStartMjd());
        if (log.isDebugEnabled()) {
            log.debug("getLinearityCorrection(Linearity) - end");
        }
        return returnCoeffs;
    }

    public List<Linearity> retrieveLinearityBetween(int module, int output,
        double startMjd, double endMjd) {
        List<Linearity> linearitys = fcCrud.retrieveLinearityBetween(module, output, startMjd,
            endMjd, history);
    	if (linearitys.size() == 0) {
    		throw new FocalPlaneException(
					"no linearity objects in db for specified range"
							+ " module " + module + " output " + output + " MJD "
							+ startMjd + " to " + endMjd);
    	}
    	return linearitys;
    }
    
    public Linearity retrieveLinearityExact(Linearity linearity) {
        return fcCrud.retrieveLinearityExact(linearity, history);
    }

    /**
     * Persist a LinearityTable object into the database, by specifying its
     * properties.
     * 
     * @param module
     * @param output
     * @param startCadence
     * @param stopCadence
     * @param coeffs
     * @throws Exception
     */
    public void persistLinearity(int module, int output, double startMjd, double[] coeffs, double[] uncertainties) throws Exception {
        if (log.isDebugEnabled()) {
            log.debug("setLinearityCorrection(int, int, Date, Date, double[]) - start");
        }

        if (!FcUtilities.isAllowedModule(module)
            || !FcUtilities.isAllowedOutput(output)) {
            throw new Exception("The inputs module=" + module + " or output="
                + output + " are out of range.");
        }

        Linearity linearity = new Linearity(module, output, startMjd, coeffs, uncertainties);
        linearity.setHistory(history);
        fcCrud.create(linearity);
    }

    /**
     * Persist a Linearity object into the database.
     * 
     * @param linearity
     * @throws Exception
     */
    public void persistLinearity(Linearity linearity) {
        linearity.setHistory(history);
        fcCrud.create(linearity);
    }

    
    /**
     * Return a model that contains all linearity info for this mod/out
     * @param module
     * @param output
     * @return
     */
    public LinearityModel retrieveLinearityModelAll(int module, int output) {
    	List<Linearity> lins = fcCrud.retrieveLinearityAll(module, output, getHistory());
        return FcModelFactory.linearityModel(lins);
    }

    
    /**
     * Return a model that contains all linearity info for this mod/out
     * @param module
     * @param output
     * @return
     */
    public LinearityModel retrieveMostRecentLinearityModel(int module, int output) {
    	List<Linearity> allLins = fcCrud.retrieveLinearityAll(module, output, getHistory());
    	List<Linearity> latestLin = new ArrayList<Linearity>();
    	
    	// Relies on retrieveLinearityAll being sorted by date ASC:
    	//
    	latestLin.add(allLins.get(allLins.size()-1));
    	return FcModelFactory.linearityModel(latestLin);
    }

    /**
     * 
     * @param module
     * @param output
     * @param mjdStart
     * @param mjdEnd
     * @return
     */
    public LinearityModel retrieveLinearityModel(int module, int output,
        double mjdStart, double mjdEnd) {
        List<Linearity> lins = fcCrud.retrieveLinearityBetween(module, output,
            mjdStart, mjdEnd, getHistory());
        return FcModelFactory.linearityModel(lins);
    }

    public History getHistory() {
        if (history == null) {
            history = fcCrud.retrieveHistory(HISTORY_NAME);
        }
        if (history == null) {
            Date now = new Date();
            double mjdNow = ModifiedJulianDate.dateToMjd(now);
            history = new History(mjdNow, HISTORY_NAME, "creating history in LinearityOperations.getHistory()", 1);
            fcCrud.create(history);
        }
        
        return history;
    }

    public void setHistory(History history) {
        this.history = history;
    }
}
