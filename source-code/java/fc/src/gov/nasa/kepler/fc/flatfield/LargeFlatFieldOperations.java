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

package gov.nasa.kepler.fc.flatfield;

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.FcUtilities;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.hibernate.fc.LargeFlatField;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Date;
import java.util.List;

/**
 * LargeFlatFieldOperations handles the JDO operations for the FlatField class.
 * 
 * @author Kester Allen
 * 
 */
public class LargeFlatFieldOperations {
    private static HistoryModelName HISTORY_NAME = HistoryModelName.LARGEFLATFIELD;

    private FcCrud fcCrud;
    private History history;

    public LargeFlatFieldOperations() {
        this(DatabaseServiceFactory.getInstance());
    }

    public LargeFlatFieldOperations(DatabaseService dbService) {

        fcCrud = new FcCrud(dbService);
        history = null;
    }
//
//    public LargeFlatFieldOperations(DatabaseService dbService, HistoryModelName modelName) {
//
//        fcCrud = new FcCrud(dbService);
//        history = fcCrud.retrieveHistory(modelName);
//        if (null == history) {
//            Date now = new Date();
//            double mjdNow = ModifiedJulianDate.dateToMjd(now);
//            history = new History(mjdNow, modelName);
//            fcCrud.create(history);
//        }
//
//    }
//    
//    public LargeFlatFieldOperations(double historyMjd) {
//        fcCrud = new FcCrud(DatabaseServiceFactory.getInstance());
//        history = new History(historyMjd, HISTORY_NAME);
//    }
//
//    public LargeFlatFieldOperations(History history) {
//        this(DatabaseServiceFactory.getInstance(), history);
//    }
//    
//    public LargeFlatFieldOperations(DatabaseService dbService, History history) {
//        this.history = new History(history.getChangeTime(), history.getModelType(), history.getDescription());
//        fcCrud = new FcCrud(dbService);
//        fcCrud.create(this.history);
//    }

    /**
     * Persist a LargeFlatField instance
     * 
     * @param lff
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public void persistLargeFlatField(LargeFlatField lff)
        {
        if (!FcUtilities.isAllowedModule(lff.getCcdModule())
            || !FcUtilities.isAllowedOutput(lff.getCcdOutput())) {
            throw new FocalPlaneException(
                "The inputs module or output are out of range.");
        }
//        lff.setHistory(history);
        fcCrud.create(lff);
    }

    /**
     * Retrieve a LargeFlatField object. The object retrieved is valid for the
     * time range specified by the input LargeFlatField object.
     * 
     * @param lff The input LargeFlatField object; it is used to specify the
     * date.
     * @return The LargeFlatField object valid for the input LargeFlatField
     * object's date.
     */
    public LargeFlatField retrieveLargeFlatField(LargeFlatField lff) {
        return fcCrud.retrieve(lff.getStartTime(), lff.getCcdModule(),
            lff.getCcdOutput(), getHistory());
    }

    public LargeFlatField retrieveLargeFlatField(double mjd, int module,
        int output) {
        LargeFlatField flat = fcCrud.retrieve(mjd, module, output, getHistory());
        
//        if (flat == null) {
//        	throw new FocalPlaneException("large flat is null");
//        }
        return flat;
    }

    public LargeFlatField retrieveLargeFlatFieldNext(double mjd, int module,
        int output) {
        LargeFlatField flat = fcCrud.retrieveNext(mjd, module, output, getHistory());
//        if (flat == null) {
//        	throw new FocalPlaneException("large flat is null");
//        }
        return flat;
    }

    public List<LargeFlatField> retrieveLargeFlatFields(double startMjd,
        double endMjd, int ccdModule, int ccdOutput) {
    	List<LargeFlatField> flats = fcCrud.retrieveLargeFlatFields(startMjd, endMjd, ccdModule,
            ccdOutput, getHistory());
//    	if (flats.size() == 0) {
//    		throw new FocalPlaneException("no large flat for date range");
//    	}
    	return flats;
    }

    public List<LargeFlatField> retrieveLargeFlatFields(int ccdModule,
        int ccdOutput) {
        List<LargeFlatField> flats = fcCrud.retrieveLargeFlatFields(ccdModule, ccdOutput, getHistory());
//    	if (flats.size() == 0) {
//    		throw new FocalPlaneException("no large flat for date range");
//    	}
    	return flats;
    }

    public List<Double> retrieveDifferentFlatDates(double startTime,
        double endTime) {
        List<Double> times = fcCrud.retrieveUniqueLargeFlatFieldDates(startTime, endTime,
            getHistory());
//        if (times.size() == 0) {
//        	throw new FocalPlaneException("no large flats in time range");
//        }
        return times;
    }

    public LargeFlatField retrieveLargeFlatFieldExact(LargeFlatField flat) {
        return fcCrud.retrieveLargeFlatFieldExact(flat, getHistory());
    }
    

	public History getHistory() {
        if (history == null) {
            history = fcCrud.retrieveHistory(HISTORY_NAME);
        }
        
        if (null == history) {
            Date now = new Date();
            double mjdNow = ModifiedJulianDate.dateToMjd(now);
            history = new History(mjdNow, HISTORY_NAME,
                "creating history in LargeFlatFieldOperations.getHistory()", 1);
                
            fcCrud.create(history);

        }
		return history;
	}

	public void setHistory(History history) {
		this.history = history;
	}

}
