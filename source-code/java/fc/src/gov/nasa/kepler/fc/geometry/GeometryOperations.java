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

package gov.nasa.kepler.fc.geometry;

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.FcModelFactory;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.fc.GeometryModel;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.Geometry;
import gov.nasa.kepler.hibernate.fc.GeometryHistoryModel;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * GeometryOperations handles the persistence operations for the Geometry class.
 * 
 * @author Kester Allen
 */
public class GeometryOperations {
    private static final Log log = LogFactory.getLog(GeometryOperations.class);
    private static HistoryModelName HISTORY_NAME = HistoryModelName.GEOMETRY;

    private DatabaseService databaseService;
    private FcCrud fcCrud;
    private History history;

    public GeometryOperations() {
        this(DatabaseServiceFactory.getInstance());
    }

    public GeometryOperations(DatabaseService databaseService)
        {
        this.databaseService = databaseService;
        fcCrud = new FcCrud(databaseService);
        history = null;
    }
    
//    public GeometryOperations(History history) {
//        this(DatabaseServiceFactory.getInstance(), history);
//    }
//    
//    public GeometryOperations(DatabaseService dbService, History history) {
//        this.history = history;
//        fcCrud = new FcCrud(dbService);
//        fcCrud.create(history);
//    }



//    /**
//     * 
//     * @param historyMjd
//     * @throws PipelineException
//     */
//    public GeometryOperations(double historyMjd)
//        {
//        this.databaseService = DatabaseServiceFactory.getInstance();
//        fcCrud = new FcCrud(databaseService);
//        history = new History(historyMjd, HISTORY_NAME);
//    }
//    
//    /**
//     * Retrieve the geometry model that is valid for the input Date.
//     * 
//     * @param inTime A java.util.Date time.
//     * @return The Geometry for the input time.
//     * @throws Exception
//     */
    // public Geometry retreieveGeometryModel(Date inTime) throws Exception {
    // if (log.isDebugEnabled()) {
    // log.debug("getGeometryModel(Date) - start");
    // }
    //
    // Geometry inGm = new Geometry(inTime);
    // Geometry returnGm = retrieveGeometryModel(inGm);
    // if (log.isDebugEnabled()) {
    // log.debug("getGeometryModel(Date) - end");
    // }
    // return returnGm;
    // }
    /**
     * 
     * @param time
     * @return
     * @throws PipelineException
     * @throws Exception
     */
    // public static Geometry getSkyCoordinateConversionConstantsStatic( Date
    // time ) {
    // if (log.isDebugEnabled()) {
    // log.debug("getSkyCoordinateConversionConstantsStatic(Date) - start");
    // }
    // Geometry inGm = new Geometry(time);
    // Geometry returnGeometryModel = retrieveGeometryModel(inGm);
    // if (log.isDebugEnabled()) {
    // log.debug("getSkyCoordinateConversionConstantsStatic(Date) - end");
    // }
    // return returnGeometryModel;
    // }
    // public static Geometry getSkyCoordinateConversionConstantsStatic( double
    // jd ) throws Exception {
    // if (log.isDebugEnabled()) {//
    // log.debug("getSkyCoordinateConversionConstantsStatic(double) - start");
    // }
    //
    // Date date = ModifiedJulianDate.jd2date( jd );
    // Geometry returnGeometryModel = retrieveGeometryModel(new Geometry(
    // date));
    // if (log.isDebugEnabled()) {
    // log.debug("getSkyCoordinateConversionConstantsStatic(double) - end");
    // }
    // return returnGeometryModel;
    // }
    // /**
    // *
    // * @param jd
    // * @return
    // * @throws Exception
    // */
    // public static Geometry getSkyCoordinateConversionConstantsStatic( long jd
    // ) throws Exception {
    // if (log.isDebugEnabled()) {
    // log.debug("getSkyCoordinateConversionConstantsStatic(long) - start");
    // }
    //
    // Date date = ModifiedJulianDate.jd2date( jd );
    // Geometry returnGeometryModel = retrieveGeometryModel(new Geometry(date));
    // if (log.isDebugEnabled()) {
    // log.debug("getSkyCoordinateConversionConstantsStatic(long) - end");
    // }
    // return returnGeometryModel;
    // }

//    /**
//     * Persist a geometry model into the database. Calls to this method should
//     * be transacted.
//     * 
//     * @param geometry The Geometry to be persisted.
//     * @throws PipelineException
//     */
//    public void persistGeometryTransacted(Geometry geometry)
//        {
//        if (log.isDebugEnabled()) {
//            log.debug("persistGeometryModel(Geometry) - start");
//        }
//
//        try {
//            databaseService.beginTransaction();
//            fcCrud.create(geometry);
//            databaseService.commitTransaction();
//        } finally {
//            databaseService.rollbackTransactionIfActive();
//        }
//
//        if (log.isDebugEnabled()) {
//            log.debug("persistGeometryModel(Geometry) - end");
//        }
//    }

    /**
     * Persist a geometry model into the database. Calls to this method should
     * be transacted.
     * 
     * @param geometry The Geometry to be persisted.
     * @throws PipelineException
     * @throws Exception
     */
    public void persistGeometry(Geometry geometry) {
        if (log.isDebugEnabled()) {
            log.debug("persistGeometryModel(Geometry) - start");
        }

        fcCrud.create(geometry);

        if (log.isDebugEnabled()) {
            log.debug("persistGeometryModel(Geometry) - end");
        }
    }

    public Geometry retrieveGeometry(Geometry gm) throws
        PipelineException {
        return retrieveGeometryMostRecent(gm);
    }

    public Geometry retrieveGeometry(double mjd) throws
        PipelineException {
        Geometry gm = new Geometry(mjd);
        return retrieveGeometryMostRecent(gm);
    }
    
    public Geometry retrieveGeometryExact(double mjd) {
    	return fcCrud.retrieveGeometryExact(mjd, history);
    }

    /**
     * Retrieve the geometry model that is valid for the date specified by the
     * input Geometry object.
     * 
     * @param gm
     * @return
     * @throws PipelineException
     * @throws Exception
     */
    public Geometry retrieveGeometryMostRecent(Geometry gm)
        {
        if (log.isDebugEnabled()) {
            log.debug("retrieveGeometryModelMostRecent(Geometry) - start");
        }

        Geometry geometry = fcCrud.retrieve(gm, getHistory());
        if (null == geometry) {
            throw new FocalPlaneException(
                "nothing returned from retrieveGeometryModelMostRecent");
        }
        if (log.isDebugEnabled()) {
            log.debug("retrieveGeometryModelMostRecent(Geometry) - end");
        }
        return geometry;
    }

    public Geometry retrieveGeometryNext(Geometry gm)
        {
        if (log.isDebugEnabled()) {
            log.debug("retrieveGeometryModelNext(Geometry) - start");
        }

        Geometry next = fcCrud.retrieveNext(gm, history);
        if (null == next) {
            throw new FocalPlaneException(
                "nothing returned from retrieveGeometryModelNext");
        }
        if (log.isDebugEnabled()) {
            log.debug("retrieveGeometryModelNext(Geometry) - end");
        }
        return next;
    }

    public Geometry[] retrieveGeometryRangeTransacted(Geometry start,
        Geometry stop) {

        Geometry[] gmArray = {};

        try {
            databaseService.beginTransaction();
            gmArray = retrieveGeometryModelRange(start, stop);
            databaseService.commitTransaction();
        } catch (Throwable t) {
            t.printStackTrace();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        return gmArray;
    }

    public Geometry retrieveGeometryMostRecentTransacted(double mjd)
        {

        Geometry gm = null;

        try {
            databaseService.beginTransaction();
            gm = retrieveGeometryMostRecent(new Geometry(mjd));
            databaseService.commitTransaction();
        } catch (Throwable t) {
            t.printStackTrace();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        return gm;
    }

    /**
     * Return every geometry model object that is in the database between the
     * timestamps specified by the input GMs "start" and "stop".
     * 
     * @param start
     * @param stop
     * @return An array of the GeometryModels whose timestamps are between the
     * timestamps of the input arguments "start" and "stop".
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public Geometry[] retrieveGeometryModelRange(Geometry start, Geometry stop)
        {
        if (log.isDebugEnabled()) {
            log.debug("retrieveGeometryModelRange(Geometry, Geometry) - start");
        }

        Geometry rangeStart = retrieveGeometryMostRecent(start);
        Geometry rangeStop = retrieveGeometryMostRecent(stop);

        List<Geometry> gmsBetween = fcCrud.retrieveBetween(rangeStart,
            rangeStop, history);

        Geometry[] gmsBetweenArray = new Geometry[gmsBetween.size()];
        for (int ii = 0; ii < gmsBetween.size(); ++ii) {
            gmsBetweenArray[ii] = gmsBetween.get(ii);
        }

        if (log.isDebugEnabled()) {
            log.debug("retrieveGeometryModelRange(Geometry, Geometry) - end");
        }

        return gmsBetweenArray;
    }

//    public Geometry[] retrieveGeometryModelRange(double startTime,
//        double endTime) {
//        if (log.isDebugEnabled()) {
//            log.debug("retrieveGeometryModelRange(Geometry, Geometry) - start");
//        }
//        
//        List<Geometry> geometrys = fcCrud.retrieveGeometrysBetween(startTime, endTime, getHistory());
//
//
//        Geometry[] gmArray = {};
//
//        Geometry rangeStart = retrieveGeometryMostRecent(new Geometry(startTime));
//        Geometry rangeStop = retrieveGeometryMostRecent(new Geometry(endTime));
//
//        gmArray = retrieveGeometryModelRange(rangeStart, rangeStop);
//
//        if (log.isDebugEnabled()) {
//            log.debug("retrieveGeometryModelRange(Geometry, Geometry) - end");
//        }
//        return gmArray;
//    }

//    /**
//     * Return the geometry models that are valid for the input array of MJD
//     * times. The GeometryModel is guaranteed to contain as many elements as the
//     * input argument does.
//     * 
//     * @param mjds
//     * @return
//     * @throws PipelineException
//     */
//    public GeometryModel retrieveGeometryModel(double[] mjds)
//        {
//        List<Geometry> geometrys = new ArrayList<Geometry>();
//        for (double mjd : mjds) {
//            Geometry geometry = fcCrud.retrieve(new Geometry(mjd), history);
//            geometrys.add(geometry);
//        }
//
//        // Convert to arrays:
//        //
//        double[] mjdsArr = new double[geometrys.size()];
//        double[][] constantsArr = new double[geometrys.size()][];
//        double[][] uncertaintyArr = new double[geometrys.size()][];
//        for (int ii = 0; ii < geometrys.size(); ++ii) {
//            mjdsArr[ii] = geometrys.get(ii).getTime();
//            constantsArr[ii] = geometrys.get(ii).getConstantsArray();
//            uncertaintyArr[ii] = geometrys.get(ii).getUncertaintyArray();
//        }
//
//        GeometryModel geometryModel = new GeometryModel(mjdsArr, constantsArr, uncertaintyArr);
//        if (geometryModel.size() != mjds.length) {
//            throw new PipelineException(
//                "Inconsistent sizes in retrieveGeometryModel");
//        }
//        return geometryModel;
//    }

    /**
     * Return the unique geometry models that are valid for the range of
     * specified MJD times. The GeometryModel will contain only the distinct
     * models that are valid for that time range, without duplicates.
     * 
     * @param mjdStart
     * @param mjdEnd
     * @return
     * @throws PipelineException
     * @throws FocalPlaneException
     */
    public GeometryModel retrieveGeometryModel(double mjdStart, double mjdEnd) {
        List<GeometryHistoryModel> historyModels = fcCrud.retrieveGeometryHistoryModels(getHistory());
        Collections.sort(historyModels);
        
        List<Geometry> geometrys = new ArrayList<Geometry>();
        for (GeometryHistoryModel historyModel : historyModels) {
            geometrys.add(historyModel.getGeometry());
        }
        
		Geometry prev = null;
		Geometry next = null;
        List<Geometry> inRangeGeometrys = new ArrayList<Geometry>();

		for (GeometryHistoryModel historyModel : historyModels) {
			Geometry current = historyModel.getGeometry();
			
			if (current.getStartTime() < mjdStart) {
				prev = current;
			} else if (current.getStartTime() > mjdEnd) {
				if (next == null) {
					next = current;
				}
			} else {
				inRangeGeometrys.add(current);
			}
		}
		
		if (prev != null) {
			inRangeGeometrys.add(0, prev);
		}
		if (next != null) {
			inRangeGeometrys.add(next);
		}

		return FcModelFactory.geometryModel(inRangeGeometrys);
    }

    // N.B.: Didn't add a retrieveMostRecentGeometryModel() that only returns the most
    // recent Geometry instance-- there's no sensible usecase for that.
    //
    public GeometryModel retrieveGeometryModelAll() {
        List<GeometryHistoryModel> historyModels = fcCrud.retrieveGeometryHistoryModels(getHistory());
        Collections.sort(historyModels);
        
        List<Geometry> geometrys = new ArrayList<Geometry>();
        for (GeometryHistoryModel historyModel : historyModels) {
            geometrys.add(historyModel.getGeometry());
        }
        
        return FcModelFactory.geometryModel(geometrys);
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
                "history created by GeometryOperations.getHistory because the table was empty",
                1);
            fcCrud.create(history);
        }
        return history;
    }

    public void setHistory(History history) {
        this.history = history;
    }
}
