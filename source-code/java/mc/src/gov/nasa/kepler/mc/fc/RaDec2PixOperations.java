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

package gov.nasa.kepler.mc.fc;

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.EphemerisFiles;
import gov.nasa.kepler.fc.FcModelFactory;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.fc.GeometryModel;
import gov.nasa.kepler.fc.PointingModel;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fc.RollTimeModel;
import gov.nasa.kepler.fc.geometry.GeometryOperations;
import gov.nasa.kepler.fc.pointing.PointingOperations;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Arrays;
import java.util.Date;

public class RaDec2PixOperations {
    private static HistoryModelName HISTORY_NAME = HistoryModelName.RADEC2PIX;

    private DatabaseService dbService;
    private FcCrud fcCrud;
    private History history;

    /**
     * Default constructor; uses the current models. Run the method
     * {@link setHistory} to use a different History.
     * 
     * @throws PipelineException
     */
    public RaDec2PixOperations() {
        this(DatabaseServiceFactory.getInstance());
    }

    /**
     * Creates a {@link RaDec2PixOperations} object with the given database service.
     * 
     * @throws PipelineException
     */
    public RaDec2PixOperations(DatabaseService dbService) {
        this.dbService = dbService;
        fcCrud = new FcCrud(dbService);
        history = null;
    }

    /**
     * This method executes the operations methods for everything the RaDec2Pix
     * object needs (Pointing, RollTime, and Geometry), and gets the Model
     * objects that correspond to list of MJDs that are passed in as the
     * argument.
     * 
     * @param mjdStart
     * @param mjdEnd
     * @return
     * @throws PipelineException
     * @throws FocalPlaneException
     */
    public RaDec2PixModel retrieveRaDec2PixModel(double mjdStart, double mjdEnd) {

        PointingModel pointingModel = new PointingOperations(dbService).retrievePointingModel(mjdStart, mjdEnd);
        RollTimeModel rollTimeModel = new RollTimeOperations(dbService).retrieveRollTimeModelAll();
        GeometryModel geometryModel = new GeometryOperations(dbService).retrieveGeometryModel(mjdStart, mjdEnd);
        
        EphemerisFiles ephemerisFiles = EphemerisOperations.getLatestEphemerisFiles();
        String spiceFileAbsolutePath = ephemerisFiles.getSpiceDir();
        String spiceFileSpacecraftEphermeris = ephemerisFiles.getSpacecraftEphemerisFilename();
        String spiceFilePlanetaryEphermeris = ephemerisFiles.getPlanetaryEphemerisFilename();
        String spiceFileLeapseconds = ephemerisFiles.getLeapSecondsFilename();
        
        double modelMjdStart = getMjdStart(pointingModel, rollTimeModel, geometryModel);
        double modelMjdEnd   = getMjdEnd(  pointingModel, rollTimeModel, geometryModel);

        return FcModelFactory.raDec2PixModel(modelMjdStart, modelMjdEnd, pointingModel,
            geometryModel, rollTimeModel, spiceFileAbsolutePath,
            spiceFileSpacecraftEphermeris, spiceFilePlanetaryEphermeris,
            spiceFileLeapseconds);
    }

    public RaDec2PixModel retrieveRaDec2PixModel() {
        PointingOperations ptOps = new PointingOperations();
        RollTimeOperations rtOps = new RollTimeOperations();
        GeometryOperations gmOps = new GeometryOperations();

        PointingModel pointingModel = ptOps.retrievePointingModelAll();
        RollTimeModel rollTimeModel = rtOps.retrieveRollTimeModelAll();
        GeometryModel geometryModel = gmOps.retrieveGeometryModelAll();

        double mjdStart = getMjdStart(pointingModel, rollTimeModel, geometryModel);
        double mjdEnd   = getMjdEnd(  pointingModel, rollTimeModel, geometryModel);

        EphemerisFiles ephemerisFiles = EphemerisOperations.getLatestEphemerisFiles();
        String spiceFileAbsolutePath = ephemerisFiles.getSpiceDir();
        String spiceFileSpacecraftEphermeris = ephemerisFiles.getSpacecraftEphemerisFilename();
        String spiceFilePlanetaryEphermeris = ephemerisFiles.getPlanetaryEphemerisFilename();
        String spiceFileLeapseconds = ephemerisFiles.getLeapSecondsFilename();
        
        return FcModelFactory.raDec2PixModel(mjdStart, mjdEnd, pointingModel,
          geometryModel, rollTimeModel, spiceFileAbsolutePath,
          spiceFileSpacecraftEphermeris, spiceFilePlanetaryEphermeris,
          spiceFileLeapseconds);
    }

    private double getMjdStart(PointingModel pointingModel, RollTimeModel rollTimeModel, GeometryModel geometryModel) {
        // Calculate the start of valid date range, the latest start date of the models (disregard geom b/c it can have just a single entry):
        //
        double[] pMjds = pointingModel.getMjds();
        double[] rMjds = rollTimeModel.getMjds();
        //double[] gMjds = geometryModel.getMjds();

        Arrays.sort(pMjds);
        Arrays.sort(rMjds);
        //Arrays.sort(gMjds);

        double[] firstMjds = { pMjds[0], rMjds[0] };//, gMjds[0] };
        Arrays.sort(firstMjds);

        double modelMjdStart = firstMjds[firstMjds.length - 1];
        return modelMjdStart;
    }

    private double getMjdEnd(PointingModel pointingModel, RollTimeModel rollTimeModel, GeometryModel geometryModel) {
        // Calculate the start of valid date range, the earliest end date of the models (disregard geom b/c it can have just a single entry):
        //
        double[] pMjds = pointingModel.getMjds();
        double[] rMjds = rollTimeModel.getMjds();
        //double[] gMjds = geometryModel.getMjds();

        Arrays.sort(pMjds);
        Arrays.sort(rMjds);
        //Arrays.sort(gMjds);

        double[] lastMjds = { pMjds[pMjds.length - 1], rMjds[rMjds.length - 1] };//, gMjds[gMjds.length - 1] };
        Arrays.sort(lastMjds);

        double modelMjdEnd = lastMjds[0];
        return modelMjdEnd;
    }

    @SuppressWarnings("unused")
	private static String getDir(String spiceFileAbsolutePath) {
        String[] spiceFileDirs = spiceFileAbsolutePath.split("/");
        String spiceFileDir = "";
        for (int ii = 1; ii < spiceFileDirs.length - 1; ++ii) {
            spiceFileDir += "/" + spiceFileDirs[ii];
        }
        return spiceFileDir;
    }

    @SuppressWarnings("unused")
	private static String getName(String spiceFileAbsolutePath) {
        String[] spiceFileDirs = spiceFileAbsolutePath.split("/");
        String spiceFileName = spiceFileDirs[spiceFileDirs.length - 1];
        return spiceFileName;
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
                "history created by RaDec2PixOperations because table because table was empty",
                1);
        }

        return history;
    }

    public void setHistory(History history) {
        this.history = history;
    }
}
