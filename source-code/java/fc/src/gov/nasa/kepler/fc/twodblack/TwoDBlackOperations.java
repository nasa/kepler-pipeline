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

package gov.nasa.kepler.fc.twodblack;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.FcModelFactory;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.fc.TargetPixel;
import gov.nasa.kepler.fc.TwoDBlackModel;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.hibernate.fc.TwoDBlackImage;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * TwoDBlackOperations handles the JDO operations for the TwoDBlackImage class.
 * 
 * @author Kester Allen
 * 
 */
public class TwoDBlackOperations {
    private static HistoryModelName HISTORY_NAME = HistoryModelName.TWODBLACK;
    @SuppressWarnings("unused")
	private static final Log log = LogFactory.getLog(TwoDBlackOperations.class);
    
    private DatabaseService dbService;
    private FcCrud fcCrud;
    private History history;

    public TwoDBlackOperations() {
        this(DatabaseServiceFactory.getInstance());
    }

    public TwoDBlackOperations(DatabaseService databaseService) {
        this.dbService = databaseService;
        fcCrud = new FcCrud(dbService);
        history = null;
    }

    /**
     * Persist a TwoDBlackImage instance.
     * 
     * @param image An input object of TwoDBlackImage
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public void persistTwoDBlackImage(TwoDBlackImage image)
        {
        fcCrud.create(image);
    }

    public boolean isTwoDBlackImagePersisted(double mjd, int module, int output) {
        return fcCrud.isTwoDBlackImagePersisted(mjd, module, output, getHistory());
    }

    /**
     * 
     * @param startTime
     * @param endTime
     * @param module
     * @param output
     * @param rows
     * @param cols
     * @return
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public TwoDBlackModel retrieveTwoDBlackModel(double startTime,
        double endTime, int module, int output, int[] rows, int[] cols)
        {

        if (rows.length != cols.length) {
            throw new PipelineException(
                "rows and cols must be same length in retrieveTwoDBlackModel");
        }

        double[] mjds = retrieveTwoDBlackImageTimes(module, output, startTime, endTime);
        
        float[][][] blacks = new float[mjds.length][1][rows.length];
        float[][][] uncertainties = new float[mjds.length][1][rows.length];

        for (int idate = 0; idate < mjds.length; ++idate) {
            double mjd = mjds[idate];

            TwoDBlackImage image = retrieveTwoDBlackImage(mjd, module, output);

            for (int ipix = 0; ipix < rows.length; ++ipix) {
                int row = rows[ipix];
                int col = cols[ipix];

                // Skip null images.
                //
                if (image != null) {
                    float value = image.getImageValue(row, col);
                    float uncertainty = image.getUncertaintyValue(row, col);

                    blacks[idate][0][ipix] = value;
                    uncertainties[idate][0][ipix] = uncertainty;
                }
            }
        }

        return FcModelFactory.twoDBlackModel(mjds, rows, cols, blacks, uncertainties);
    }

    /**
     * 
     * @param startMjd
     * @param endMjd
     * @return
     * @throws FocalPlaneException
     */
    public double[] retrieveTwoDBlackImageTimes(double startMjd, double endMjd)
        {
        double[] times = fcCrud.retrieveTwoDBlackImageTimes(startMjd, endMjd,
            getHistory());
        return times;
    }
    
    /**
     * 
     * @param startMjd
     * @param endMjd
     * @return
     * @throws FocalPlaneException
     */
    public double[] retrieveTwoDBlackImageTimes(int module, int output, double startMjd, double endMjd)
        {
        double[] times = fcCrud.retrieveTwoDBlackImageTimes(startMjd, endMjd, module, output, 
            getHistory());
        return times;
    }
    

    /**
     * Retrieve the model that is valid for the given time range.
     * 
     * @param startTime
     * @param endTime
     * @param module
     * @param output
     * @return
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public TwoDBlackModel retrieveTwoDBlackModel(double startTime,
        double endTime, int module, int output) {

        double[] mjds = fcCrud.retrieveTwoDBlackImageTimes(startTime, endTime, module, output,
            getHistory());
        float[][][] blacks = getFloats(mjds, module, output);
        float[][][] uncertainties = getUncertainties(mjds, module, output);

        return FcModelFactory.twoDBlackModel(mjds, blacks, uncertainties);
    }

    /**
     * Retrieve a model that is valid for right now:
     * 
     * @param module
     * @param output
     * @return
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public TwoDBlackModel retrieveMostRecentTwoDBlackModel(int module,
        int output) {

        double[] mjds = fcCrud.retrieveTwoDBlackImageTimes(module, output, getHistory());
        double[] mostRecentMjd = new double[0];
        if (mjds.length > 0) {
			mostRecentMjd = new double[] { mjds[mjds.length - 1] };
        }

		float[][][] flats = getFloats(mostRecentMjd, module, output);
		float[][][] uncertainties = getUncertainties(mostRecentMjd, module,
				output);

		TwoDBlackModel model = new TwoDBlackModel(mostRecentMjd, flats,
				uncertainties);

		return model;
    }

    /**
     * Retrieve a model that is valid for all time ranges
     * 
     * @param module
     * @param output
     * @return
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public TwoDBlackModel retrieveTwoDBlackModelAll(int module, int output)
        {

        double[] mjds = fcCrud.retrieveTwoDBlackImageTimes(module, output, getHistory());
        float[][][] blacks = getFloats(mjds, module, output);
        float[][][] uncertainties = getUncertainties(mjds, module, output);

        return FcModelFactory.twoDBlackModel(mjds, blacks, uncertainties);
    }

    /**
     * 
     * @param startMjd
     * @param endMjd
     * @param module
     * @param output
     * @param moduleOutputDefinitions
     * @return
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public TwoDBlackModel retrieveTwoDBlackModel(double startMjd,
        double endMjd, int module, int output,
        List<TargetDefinition> definitions) {

        List<TargetPixel> pixels = TargetPixel.getPixels(definitions);
        final int[] rows = new int[pixels.size()];
        final int[] columns = new int[pixels.size()];
        for (int i = 0; i < pixels.size(); i++) {
            TargetPixel pixel = pixels.get(i);
            rows[i] = pixel.getRow();
            columns[i] = pixel.getColumn();
        }

        return this.retrieveTwoDBlackModel(startMjd,
            endMjd, module, output, rows, columns);
    }

    private float[][][] getFloats(double[] mjds, int module, int output)
        {
        float[][][] blacks = new float[mjds.length][FcConstants.CCD_ROWS][FcConstants.CCD_COLUMNS];

        for (int ii = 0; ii < mjds.length; ++ii) {
            TwoDBlackImage image = retrieveTwoDBlackImage(mjds[ii], module,
                output);

            for (int irow = 0; irow < FcConstants.CCD_ROWS; ++irow) {
                for (int icol = 0; icol < FcConstants.CCD_COLUMNS; ++icol) {
                    float value = image.getImageValue(irow, icol);
                    blacks[ii][irow][icol] = value;
                }
            }
        }
        return blacks;
    }

    private float[][][] getUncertainties(double[] mjds, int module, int output)
        {
        float[][][] uncertainties = new float[mjds.length][FcConstants.CCD_ROWS][FcConstants.CCD_COLUMNS];

        for (int ii = 0; ii < mjds.length; ++ii) {
            TwoDBlackImage image = retrieveTwoDBlackImage(mjds[ii], module,
                output);

            for (int irow = 0; irow < FcConstants.CCD_ROWS; ++irow) {
                for (int icol = 0; icol < FcConstants.CCD_COLUMNS; ++icol) {
                    float value = image.getUncertaintyValue(irow, icol);
                    uncertainties[ii][irow][icol] = value;
                }
            }
        }
        return uncertainties;
    }

    public TwoDBlackImage retrieveTwoDBlackImage(double mjd, int ccdModule,
        int ccdOutput) {
        TwoDBlackImage image = fcCrud.retrieveTwoDBlackImage(mjd, ccdModule,
            ccdOutput, getHistory());
        return image;
    }

    public TwoDBlackImage retrieveTwoDBlackImageExact(double mjd,
        int ccdModule, int ccdOutput) {
        TwoDBlackImage image = fcCrud.retrieveTwoDBlackImageExact(mjd,
            ccdModule, ccdOutput, getHistory());
        return image;
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
                "created by TwoDBlackOperations.getHistory because the History table was empty",
                1);
            fcCrud.create(history);
        }
        return history;
    }

    public void setHistory(History history) {
        this.history = history;
    }

}
