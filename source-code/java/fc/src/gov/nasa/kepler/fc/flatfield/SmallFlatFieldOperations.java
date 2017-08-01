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

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.hibernate.fc.LargeFlatField;
import gov.nasa.kepler.hibernate.fc.SmallFlatFieldImage;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Arrays;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * SmallFlatFieldOperations handles the JDO operations for the FlatField class.
 * 
 * @author Kester Allen
 * 
 */
public class SmallFlatFieldOperations {
    private static HistoryModelName HISTORY_NAME = HistoryModelName.SMALLFLATFIELD;

    private FcCrud fcCrud;
    private History history;

    public SmallFlatFieldOperations() {
        this(DatabaseServiceFactory.getInstance());
    }

    public SmallFlatFieldOperations(DatabaseService dbService) {
        fcCrud = new FcCrud(dbService);
        history = null;
    }
    
    /**
     * Persist a SmallFlatFieldImage instance.
     * 
     * @param sff An input object of SmallFlatFieldImage
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public void persistSmallFlatFieldImage(SmallFlatFieldImage sffi)
        {
        fcCrud.create(sffi);
    }

    public float[][] retrieveUncertainties(int ccdModule, int ccdOutput,
        double mjd, int[] rows, int[] cols) throws
        PipelineException {

        SmallFlatFieldImage smallFlatImage = retrieveSmallFlatFieldImage(mjd,
            ccdModule, ccdOutput);

        return unpackUncertainties(smallFlatImage, rows, cols);
    }

    public float[][] retrieveUncertainties(int ccdModule, int ccdOutput,
        double mjd) {

        SmallFlatFieldImage smallFlatImage = retrieveSmallFlatFieldImage(mjd,
            ccdModule, ccdOutput);
        
        return unpackUncertainties(smallFlatImage);
    }

    /**
     * Private calculation method to convolve the large and small flat field.
     * 
     * @param small
     * @param large
     * @return
     * @throws PipelineException
     */
    @SuppressWarnings("unused")
	private float[][] calcFlatField(SmallFlatFieldImage small,
        LargeFlatField large) {
        float[][] values = new float[FcConstants.CCD_ROWS][FcConstants.CCD_COLUMNS];

        for (int irow = 0; irow < FcConstants.CCD_ROWS; ++irow) {
            for (int icol = 0; icol < FcConstants.CCD_COLUMNS; ++icol) {
                float smallFlatValue = small.getImageValue(irow, icol);

                float lfValue = (float) large.getFlat(irow, icol);

                values[irow][icol] = smallFlatValue * lfValue;
            }
        }
        return values;
    }

    /**
     * Unpack the uncertainties into a 2d array
     * 
     * @param small
     * @return
     * @throws PipelineException
     */
    private float[][] unpackUncertainties(SmallFlatFieldImage small) {
        float[][] values = new float[FcConstants.CCD_ROWS][FcConstants.CCD_COLUMNS];

        for (int irow = 0; irow < FcConstants.CCD_ROWS; ++irow) {
            for (int icol = 0; icol < FcConstants.CCD_COLUMNS; ++icol) {
                values[irow][icol] = small.getUncertaintyValue(irow, icol);
            }
        }
        return values;
    }

    @SuppressWarnings("unused")
	private float[][] calcFlatField(SmallFlatFieldImage small,
        LargeFlatField large, int[] rows, int[] cols) {
        float[][] values = new float[FcConstants.CCD_ROWS][FcConstants.CCD_COLUMNS];

        for (int ii = 0; ii < rows.length; ++ii) {
            float smallFlatValue = small.getImageValue(rows[ii], cols[ii]);
            double lfValue = large.getFlat(rows[ii], cols[ii]);

            values[rows[ii]][cols[ii]] = smallFlatValue * (float) lfValue;
        }
        return values;
    }

    /**
     * Unpack the uncertainties into a 2d array
     * 
     * @param small
     * @return
     * @throws PipelineException
     */
    private float[][] unpackUncertainties(SmallFlatFieldImage small,
        int[] rows, int[] cols) {
        float[][] values = new float[FcConstants.CCD_ROWS][FcConstants.CCD_COLUMNS];

        for (int ii = 0; ii < rows.length; ++ii) {
            values[rows[ii]][cols[ii]] = small.getUncertaintyValue(rows[ii],
                cols[ii]);
        }
        return values;
    }

    public List<Double> retrieveDifferentFlatDates(double startTime,
        double endTime) {
        return fcCrud.retrieveUniqueLargeFlatFieldDates(startTime, endTime,
            getHistory());
    }

    /**
     * 
     * @param startMjd
     * @param endMjd
     * @return
     * @throws FocalPlaneException
     */
    public double[] retrieveSmallFlatFieldImageTimes(double startMjd,
        double endMjd) {
        double[] times = fcCrud.retrieveSmallFlatFieldImageTimes(startMjd, endMjd, getHistory());
        return times;
    }
    
    /**
     * 
     * @param module
     * @param output
     * @return
     * @throws FocalPlaneException
     */
    public double[] retrieveSmallFlatFieldImageTimes(int module, int output) {
        double[] times = fcCrud.retrieveSmallFlatFieldImageTimes(module, output, getHistory());
        return times;
    }
    
    /**
     * 
     * @param startMjd
     * @param endMjd
     * @param ccdModule
     * @param ccdOutput
     * @return
     * @throws FocalPlaneException
     */
    public double[] retrieveSmallFlatFieldImageTimes(double startMjd, double endMjd, int ccdModule, int ccdOutput) {
        double[] times = fcCrud.retrieveSmallFlatFieldImageTimes(startMjd, endMjd, ccdModule, ccdOutput, getHistory());
        return times;
    }

    /**
     * 
     * @param startMjd
     * @param endMjd
     * @return
     * @throws FocalPlaneException
     */
    public double[] retrieveSmallFlatFieldImageTimes()
        {
        double[] times = fcCrud.retrieveSmallFlatFieldImageTimes(getHistory());
        return times;
    }
    
    public double[] retrieveMostRecentSmallFlatFieldImageTime() {
    	double[] time = fcCrud.retrieveMostRecentSmallFlatFieldImageTime(getHistory());
    	return time;
    }

    public double retrieveSmallFlatFieldImageDateNext(double mjd) {
        double time = fcCrud.retrieveSmallFlatFieldImageDateNext(mjd, getHistory());
        return time;
    }

    public SmallFlatFieldImage retrieveSmallFlatFieldImage(double mjd,
        int ccdModule, int ccdOutput) {
        SmallFlatFieldImage smallFlatImage = fcCrud.retrieveSmallFlatFieldImage(
            mjd, ccdModule, ccdOutput, getHistory());
        return smallFlatImage;
    }

    public SmallFlatFieldImage retrieveSmallFlatFieldImageExact(double mjd,
        int ccdModule, int ccdOutput) {
        SmallFlatFieldImage smallFlatImage = fcCrud.retrieveSmallFlatFieldImageExact(
            mjd, ccdModule, ccdOutput, getHistory());
        return smallFlatImage;
    }

    @SuppressWarnings("unused")
	private float[][][] getUncertainties(double[] mjds, int module, int output)
        {

        // Allocate output images:
        //
        float[][][] uncertainties = new float[mjds.length][][];

        // Extract data:
        //
        for (int ii = 0; ii < mjds.length; ++ii) {
            uncertainties[ii] = retrieveUncertainties(module, output, mjds[ii]);
        }
        return uncertainties;
    }

    @SuppressWarnings("unused")
	private float[][][] getUncertainties(double[] mjds, int module, int output,
        int[] rows, int[] cols) {

        // Allocate output images:
        //
        float[][][] flats = new float[mjds.length][][];

        // Extract data:
        //
        for (int ii = 0; ii < mjds.length; ++ii) {
            flats[ii] = retrieveUncertainties(module, output, mjds[ii], rows,
                cols);
        }
        return flats;
    }

    /**
     * Utility routine to generate a list of sorted MJD doubles from a list of
     * SmallFlatFieldDates and LargeFlatFields.
     * 
     * @param sffDates
     * @param lffs
     * @return
     */
    @SuppressWarnings("unused")
	private double[] sortedUniqueMjdsFromFlats(double[] smallMjds,
        List<LargeFlatField> larges) {

        // Make a set of all the dates. This'll eliminate duplicates
        //
        Set<Double> mjdsSet = new HashSet<Double>();
        for (double smallMjd : smallMjds) {
            mjdsSet.add(smallMjd);
        }
        for (LargeFlatField lff : larges) {
            mjdsSet.add(lff.getStartTime());
        }

        // Extract unique results into an array and sort it:
        //
        double[] mjds = new double[mjdsSet.size()];
        int ii = 0;
        for (Double mjd : mjdsSet) {
            mjds[ii++] = mjd;
        }
        Arrays.sort(mjds);

        return mjds;
    }

    public LargeFlatField retrieveLargeFlatFieldExact(LargeFlatField flat) {
        return fcCrud.retrieveLargeFlatFieldExact(flat, getHistory());
    }


    public boolean isSmallFlatFieldImagePersisted(double mjd, int module,
        int output) {
        return fcCrud.isSmallFlatFieldImagePersisted(mjd, module, output,
            getHistory());
    }

    public History getHistory() {
	    if (history == null) {
	        history = fcCrud.retrieveHistory(HISTORY_NAME);
	    }
        if (history == null) {
            Date now = new Date();
            double mjdNow = ModifiedJulianDate.dateToMjd(now);
            
            history = new History(mjdNow, HISTORY_NAME, "history created by SmallFlatFieldOperations.getHistory() because table was empty", 1);
            fcCrud.create(history);
        }
		return history;
	}

    public void setHistory(History history) {
        this.history = history;
    }

}
