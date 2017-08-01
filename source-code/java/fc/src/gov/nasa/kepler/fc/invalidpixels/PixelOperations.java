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

package gov.nasa.kepler.fc.invalidpixels;

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.FcModelFactory;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.fc.PixelModel;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.hibernate.fc.Pixel;
import gov.nasa.kepler.hibernate.fc.PixelType;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * The PixelOperations class handles the db operations for the Pixel class.
 * 
 * @author Kester Allen
 * 
 */
public class PixelOperations {
    private static HistoryModelName HISTORY_NAME = HistoryModelName.BAD_PIXELS;

    /**
     * Logger for this class
     */
    private static final Log log = LogFactory.getLog(PixelOperations.class);
    private FcCrud fcCrud;
    private History history;

    public PixelOperations() {
        fcCrud = new FcCrud();
        history = null;
    }

    /**
     * Retrieve a Pixel object from the database that matches the module,
     * output, row, and column of the input Pixel and is in the valid time
     * range.
     * 
     * @param The input pixel
     * @return The retrieve pixel
     * @throws FocalPlaneException
     */
    public Pixel retrievePixel(Pixel inPix) {
        return fcCrud.retrieve(inPix, history);
    }

    /**
     * Retrieve a Pixel object from the database that matches the module,
     * output, row, and column of the input Pixel and is in the valid time
     * range.
     * 
     * @param The input pixel
     * @return The retrieve pixel
     * @throws FocalPlaneException
     */
    public Pixel retrievePixelExact(Pixel inPix) {
        return fcCrud.retrievePixelExact(inPix, getHistory());
    }

    /**
     * 
     * @param module
     * @param output
     * @param startTime (MJD)
     * @param endTime (MJD)
     * @return
     */
    public Pixel[] retrievePixelRange(int module, int output, double startTime,
        double endTime) {
        Pixel searchPix = new Pixel(PixelType.GOOD, startTime, endTime);
        searchPix.setCcdModule(module);
        searchPix.setCcdOutput(output);

        Pixel[] outPixArr = fcCrud.retrieveBetween(searchPix, history);
        return outPixArr;
    }

    public PixelModel retrievePixelModel(int module, int output,
        double startTime, double endTime) {
        return FcModelFactory.pixelModel(retrievePixelRange(module, output,
            startTime, endTime));
    }

    /**
     * 
     * @param module
     * @param output
     * @param startTime (MJD)
     * @param endTime (MJD)
     * @return
     */
    public Pixel[] retrievePixelRange(int module, int output, double startTime,
        double endTime, String type) {
        Pixel searchPix = new Pixel(PixelType.valueOf(type), startTime, endTime);
        searchPix.setCcdModule(module);
        searchPix.setCcdOutput(output);

        Pixel[] outPixArr = fcCrud.retrieveBetweenType(searchPix, history);
        return outPixArr;
    }

    public PixelModel retrievePixelModel(int module, int output,
        double startTime, double endTime, String type) {
        return FcModelFactory.pixelModel(retrievePixelRange(module, output,
            startTime, endTime, type));
    }

    /**
     * 
     * @param module
     * @param output
     * @param startTime (MJD)
     * @param endTime (MJD)
     * @return
     */
    public Pixel[] retrievePixelRange(int module, int output, double startTime,
        double endTime, PixelType type) {
        Pixel searchPix = new Pixel(type, startTime, endTime);
        searchPix.setCcdModule(module);
        searchPix.setCcdOutput(output);

        Pixel[] outPixArr = fcCrud.retrieveBetweenType(searchPix, history);
        return outPixArr;
    }

    public PixelModel retrievePixelModel(int module, int output,
        double startTime, double endTime, PixelType type) {
        return FcModelFactory.pixelModel(retrievePixelRange(module, output,
            startTime, endTime, type));
    }

    /**
     * Persist the argument Pixel object into the database.
     * 
     * @param inPix The pixel to persist.
     * @throws PipelineException
     */
    public void persistPixel(Pixel inPix) {
        if (log.isDebugEnabled()) {
            log.debug("persistPixel(Pixel) - start");
        }

        fcCrud.create(inPix);

        if (log.isDebugEnabled()) {
            log.debug("persistPixel(Pixel) - end");
        }
    }

    public List<Pixel> whichOfThesePixelsAreInvalid(List<Pixel> pixelList,
        String type, double time) {
        if (log.isDebugEnabled()) {
            log.debug("whichOfThesePixelsAreInvalid(LinkedList<Pixel>, String, Date) - start");
        }

        List<Pixel> invalidPixels = new ArrayList<Pixel>();

        for (Pixel pix : pixelList) {
            if (isPixelInDatabase(pix)) {
                invalidPixels.add(pix);
            }
        }

        if (log.isDebugEnabled()) {
            log.debug("whichOfThesePixelsAreInvalid(LinkedList<Pixel>, String, Date) - end");
        }
        return invalidPixels;
    }

    public boolean isPixelInDatabase(Pixel pix) {
        Pixel[] pixelsInDatabase = fcCrud.retrieveBetween(pix, history);
        return 0 != pixelsInDatabase.length;
    }

    public List<Pixel> getInvalidPixelsByModuleOutput(int module, int output,
        PixelType type, double time, long maxPixReturned) throws Exception {
        if (log.isDebugEnabled()) {
            log.debug("getInvalidPixelsByModuleOutput(int, int, String, Date, long) - start");
        }

        List<Pixel> pixels = fcCrud.retrieveInvalidPixels(module, output, time,
            type, history);

        if (log.isDebugEnabled()) {
            log.debug("getInvalidPixelsByModuleOutput(int, int, String, Date, long) - end");
        }
        return pixels;
    }

    public List<Pixel> getInvalidPixelsByModuleOutput(int module, int output,
        PixelType type, double time) throws Exception {
        if (log.isDebugEnabled()) {
            log.debug("getInvalidPixelsByModuleOutput(int, int, String, Date) - start");
        }
        List<Pixel> pixels = getInvalidPixelsByModuleOutput(module, output,
            type, time, -1);

        if (log.isDebugEnabled()) {
            log.debug("getInvalidPixelsByModuleOutput(int, int, String, Date) - end");
        }
        return pixels;
    }

    public History getHistory() {
        if (history == null) {
            history = fcCrud.retrieveHistory(HISTORY_NAME);
        }
        if (history == null) {
            Date now = new Date();
            double mjdNow = ModifiedJulianDate.dateToMjd(now);
            history = new History(mjdNow, HISTORY_NAME,
                "created by PixelOperations.getHistory due to empty table", 1);
            fcCrud.create(history);
        }
        return history;
    }

    public void setHistory(History history) {
        this.history = history;
    }

}
