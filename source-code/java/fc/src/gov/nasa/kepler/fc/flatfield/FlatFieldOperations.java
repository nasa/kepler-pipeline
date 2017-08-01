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
import gov.nasa.kepler.fc.FcModelFactory;
import gov.nasa.kepler.fc.FlatFieldModel;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.fc.TargetPixel;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FlatField;
import gov.nasa.kepler.hibernate.fc.LargeFlatField;
import gov.nasa.kepler.hibernate.fc.SmallFlatFieldImage;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * FlatFieldOperations handles the JDO operations for the FlatField class.
 * 
 * @author Kester Allen
 * 
 */
public class FlatFieldOperations {
    private LargeFlatFieldOperations largeOps;
    private SmallFlatFieldOperations smallOps;
    @SuppressWarnings("unused")
	private static final Log log = LogFactory.getLog(FlatFieldOperations.class);

    public FlatFieldOperations() {
        this(DatabaseServiceFactory.getInstance());
    }

    public FlatFieldOperations(DatabaseService dbService) {
        largeOps = new LargeFlatFieldOperations(dbService);
        smallOps = new SmallFlatFieldOperations(dbService);
    }

    /**
     * Persist a SmallFlatFieldImage instance.
     * 
     * @param sff An input object of SmallFlatFieldImage
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public void persistSmallFlatFieldImage(SmallFlatFieldImage sffi) {
        smallOps.persistSmallFlatFieldImage(sffi);
    }

    public boolean isSmallFlatFieldImagePersisted(double mjd, int module,
        int output) {
        return smallOps.isSmallFlatFieldImagePersisted(mjd, module, output);
    }

    /**
     * Persist a LargeFlatField instance
     * 
     * @param lff
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public void persistLargeFlatField(LargeFlatField lff) {
        largeOps.persistLargeFlatField(lff);
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
        return largeOps.retrieveLargeFlatField(lff);
    }

    public LargeFlatField retrieveLargeFlatField(double mjd, int module,
        int output) {
        return largeOps.retrieveLargeFlatField(mjd, module, output);
    }

    public LargeFlatField retrieveLargeFlatFieldNext(double mjd, int module,
        int output) {
        return largeOps.retrieveLargeFlatFieldNext(mjd, module, output);
    }

    public List<LargeFlatField> retrieveLargeFlatFields(double startMjd,
        double endMjd, int ccdModule, int ccdOutput) {
        return largeOps.retrieveLargeFlatFields(startMjd, endMjd, ccdModule,
            ccdOutput);
    }

    public List<LargeFlatField> retrieveLargeFlatFields(int ccdModule,
        int ccdOutput) {
        return largeOps.retrieveLargeFlatFields(ccdModule, ccdOutput);
    }

    /**
     * Get the 2-D [time][pixel] flat field per pixel for one module/output and
     * time (MJD) range (start and end). Only valid dates in the start-end range
     * are used, i.e, if there is only one valid flat field for that time range,
     * one time index will be returned.
     * 
     * @param ccdModule
     * @param ccdOutput
     * @param start
     * @param end
     * @return
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public List<FlatField> retrieveFlatField(int ccdModule, int ccdOutput,
        double startTime, double endTime) throws PipelineException {

        List<Double> mjds = retrieveDifferentFlatDates(ccdModule, ccdOutput,
            startTime, endTime);

        List<FlatField> flatFields = new ArrayList<FlatField>();

        for (int iDate = 0; iDate < mjds.size(); ++iDate) {
            double mjd = mjds.get(iDate);
            float[][] values = retrieveFlatField(ccdModule, ccdOutput, mjd);
            flatFields.add(new FlatField(ccdModule, ccdOutput, mjd, values));
        }
        return flatFields;
    }

    /**
     * Get the 1-D (pixel) array of flat field values for the specified pixel
     * set at Date date.
     * 
     * @param ccdModules
     * @param ccdOutputs
     * @param date
     * @param pixelRows
     * @param pixelColumns
     * @return
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    @SuppressWarnings("unused")
    private double[] retrieveFlatField(int[] ccdModules, int[] ccdOutputs,
        double mjd, int[] pixelRows, int[] pixelColumns) {
        double[] flatFieldValues = new double[ccdModules.length];
        for (int ii = 0; ii < ccdModules.length; ++ii) {
            flatFieldValues[ii] = retrieveFlatField(ccdModules[ii],
                ccdOutputs[ii], mjd, pixelRows[ii], pixelColumns[ii]);
        }
        return flatFieldValues;
    }

    /**
     * 
     * @param ccdModule
     * @param ccdOutput
     * @param mjd
     * @param pixelRow
     * @param pixelColumn
     * @return
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public double retrieveFlatField(int ccdModule, int ccdOutput, double mjd,
        int pixelRow, int pixelColumn) throws PipelineException {

        double[] mjds = retrieveSmallFlatFieldImageTimes();

        SmallFlatFieldImage smallFlatImage = retrieveSmallFlatFieldImage(
            mjds[0], ccdModule, ccdOutput);

        float smallFlatValue = smallFlatImage.getImageValue(pixelRow,
            pixelColumn);

        LargeFlatField lff = retrieveLargeFlatField(mjd, ccdModule, ccdOutput);

        double lfValue = lff.getFlat(pixelRow, pixelColumn);
        double flatFieldValue = smallFlatValue * lfValue;
        return flatFieldValue;
    }

    /**
     * 
     * @param ccdModule
     * @param ccdOutput
     * @param mjd
     * @param rows
     * @param cols
     * @return
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public float[][] retrieveFlatField(int ccdModule, int ccdOutput,
        double mjd, int[] rows, int[] cols) throws PipelineException {
        LargeFlatField lff = retrieveLargeFlatField(mjd, ccdModule, ccdOutput);

        SmallFlatFieldImage smallFlatImage = retrieveSmallFlatFieldImage(mjd,
            ccdModule, ccdOutput);

        return calcFlatField(smallFlatImage, lff, rows, cols);
    }

    public float[][] retrieveUncertainties(int ccdModule, int ccdOutput,
        double mjd, int[] rows, int[] cols) throws PipelineException {

        SmallFlatFieldImage smallFlatImage = retrieveSmallFlatFieldImage(mjd,
            ccdModule, ccdOutput);

        return unpackUncertainties(smallFlatImage, rows, cols);
    }

    /**
     * 
     * @param ccdModule
     * @param ccdOutput
     * @param mjd
     * @return
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public float[][] retrieveFlatField(int ccdModule, int ccdOutput, double mjd) {

        LargeFlatField lff = retrieveLargeFlatField(mjd, ccdModule, ccdOutput);

        SmallFlatFieldImage smallFlatImage = retrieveSmallFlatFieldImage(mjd,
            ccdModule, ccdOutput);

        return calcFlatField(smallFlatImage, lff);
    }

    public float[][] retrieveUncertainties(int ccdModule, int ccdOutput,
        double mjd) {

        SmallFlatFieldImage smallFlatImage = retrieveSmallFlatFieldImage(mjd,
            ccdModule, ccdOutput);

        return unpackUncertainties(smallFlatImage);
    }

    /**
     * 
     * @param ccdModule
     * @param ccdOutput
     * @param mjd
     * @return
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public float[][] retrieveFlatFieldNext(int ccdModule, int ccdOutput,
        double mjd) {

        LargeFlatField lff = retrieveLargeFlatFieldNext(mjd, ccdModule,
            ccdOutput);

        double mjdNext = retrieveSmallFlatFieldImageDateNext(mjd);
        SmallFlatFieldImage smallFlatImage = retrieveSmallFlatFieldImage(
            mjdNext, ccdModule, ccdOutput);

        return calcFlatField(smallFlatImage, lff);
    }

    /**
     * Private calculation method to convolve the large and small flat field.
     * 
     * @param small
     * @param large
     * @return
     * @throws PipelineException
     */
    private float[][] calcFlatField(SmallFlatFieldImage small,
        LargeFlatField large) {

        float[][] values = new float[FcConstants.CCD_ROWS][FcConstants.CCD_COLUMNS];

        for (int irow = 0; irow < FcConstants.CCD_ROWS; ++irow) {
            for (int icol = 0; icol < FcConstants.CCD_COLUMNS; ++icol) {
                if (small != null && large != null) {
                    float smallFlatValue = small.getImageValue(irow, icol);
                    float lfValue = (float) large.getFlat(irow, icol);

                    values[irow][icol] = smallFlatValue * lfValue;
                }
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

        if (small == null) {
            return values;
        }
        for (int irow = 0; irow < FcConstants.CCD_ROWS; ++irow) {
            for (int icol = 0; icol < FcConstants.CCD_COLUMNS; ++icol) {
                values[irow][icol] = small.getUncertaintyValue(irow, icol);
            }
        }
        return values;
    }

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

    public List<Double> retrieveDifferentFlatDates(int ccdModule,
        int ccdOutput, double startTime, double endTime) {

        double[] smallMjds = smallOps.retrieveSmallFlatFieldImageTimes();
        List<LargeFlatField> lffs = largeOps.retrieveLargeFlatFields(ccdModule,
            ccdOutput);
        double[] mjds = sortedUniqueMjdsFromFlats(smallMjds, lffs);

        List<Double> dates = new ArrayList<Double>();
        for (double mjd : mjds) {
            dates.add(mjd);
        }

        return dates;
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
        return smallOps.retrieveSmallFlatFieldImageTimes(startMjd, endMjd);
    }

    /**
     * 
     * @param startMjd
     * @param endMjd
     * @return
     * @throws FocalPlaneException
     */
    public double[] retrieveSmallFlatFieldImageTimes(double startMjd,
        double endMjd, int ccdModule, int ccdOutput) {
        return smallOps.retrieveSmallFlatFieldImageTimes(startMjd, endMjd,
            ccdModule, ccdOutput);
    }

    /**
     * 
     * @param startMjd
     * @param endMjd
     * @return
     * @throws FocalPlaneException
     */
    public double[] retrieveSmallFlatFieldImageTimes() {
        return smallOps.retrieveSmallFlatFieldImageTimes();
    }

    public double retrieveSmallFlatFieldImageDateNext(double mjd) {
        return smallOps.retrieveSmallFlatFieldImageDateNext(mjd);
    }

    public SmallFlatFieldImage retrieveSmallFlatFieldImage(double mjd,
        int ccdModule, int ccdOutput) {
        return smallOps.retrieveSmallFlatFieldImage(mjd, ccdModule, ccdOutput);
    }

    public SmallFlatFieldImage retrieveSmallFlatFieldImageExact(double mjd,
        int ccdModule, int ccdOutput) {
        return smallOps.retrieveSmallFlatFieldImageExact(mjd, ccdModule,
            ccdOutput);
    }

    /**
     * Get the flat field model for all times
     * 
     * @param module
     * @param output
     * @return
     * @throws PipelineException
     * @throws FocalPlaneException
     */
    public FlatFieldModel retrieveFlatFieldModelAll(int module, int output) {

        double[] smallMjds = smallOps.retrieveSmallFlatFieldImageTimes(module,
            output);
        List<LargeFlatField> lffs = largeOps.retrieveLargeFlatFields(module,
            output);

        double[] mjds = sortedUniqueMjdsFromFlats(smallMjds, lffs);
        float[][][] flats = getFlats(mjds, module, output);
        float[][][] uncertainties = getUncertainties(mjds, module, output);

        // Large scale flat spec:
        //
        int[] polynomialOrder = new int[mjds.length];
        String[] type = new String[mjds.length];

        int[] xIndex = new int[mjds.length];
        double[] offsetX = new double[mjds.length];
        double[] scaleX = new double[mjds.length];
        double[] originX = new double[mjds.length];

        int[] yIndex = new int[mjds.length];
        double[] offsetY = new double[mjds.length];
        double[] scaleY = new double[mjds.length];
        double[] originY = new double[mjds.length];

        double[][] coeffs = new double[mjds.length][5];
        double[][] covars = new double[mjds.length][25];
        for (int ii = 0; ii < mjds.length; ++ii) {
            LargeFlatField largeFlatField = retrieveLargeFlatField(mjds[ii],
                module, output);
            polynomialOrder[ii] = largeFlatField.getPolynomialOrder();
            type[ii] = largeFlatField.getType();
            xIndex[ii] = largeFlatField.getXIndex();
            offsetX[ii] = largeFlatField.getOffsetX();
            scaleX[ii] = largeFlatField.getScaleX();
            originX[ii] = largeFlatField.getOriginX();
            yIndex[ii] = largeFlatField.getXIndex();
            offsetY[ii] = largeFlatField.getOffsetX();
            scaleY[ii] = largeFlatField.getScaleX();
            originY[ii] = largeFlatField.getOriginX();

            coeffs[ii] = largeFlatField.getPolynomialCoefficientsArray();
            covars[ii] = largeFlatField.getCovarianceCoefficientsArray();
        }

        // Construct model:
        //
        return FcModelFactory.flatFieldModel(mjds, flats, uncertainties,
            polynomialOrder, type, xIndex, offsetX, scaleX, originX, yIndex,
            offsetY, scaleY, originY, coeffs, covars);
    }

    /**
     * Get the flat field model that's valid for right now
     * 
     * @param module
     * @param output
     * @return
     * @throws PipelineException
     * @throws FocalPlaneException
     */
    public FlatFieldModel retrieveMostRecentFlatFieldModel(int module,
        int output) {

        double[] smallMjd = smallOps.retrieveMostRecentSmallFlatFieldImageTime();
        List<LargeFlatField> lffs = largeOps.retrieveLargeFlatFields(module,
            output);

        double[] allMjds = sortedUniqueMjdsFromFlats(smallMjd, lffs);
        double[] mostRecentMjd = new double[] { allMjds[allMjds.length - 1] };

        float[][][] flats = getFlats(mostRecentMjd, module, output);
        float[][][] uncertainties = getUncertainties(mostRecentMjd, module,
            output);

        // Large scale flat spec:
        //
        int[] polynomialOrder = new int[mostRecentMjd.length];
        String[] type = new String[mostRecentMjd.length];

        int[] xIndex = new int[mostRecentMjd.length];
        double[] offsetX = new double[mostRecentMjd.length];
        double[] scaleX = new double[mostRecentMjd.length];
        double[] originX = new double[mostRecentMjd.length];

        int[] yIndex = new int[mostRecentMjd.length];
        double[] offsetY = new double[mostRecentMjd.length];
        double[] scaleY = new double[mostRecentMjd.length];
        double[] originY = new double[mostRecentMjd.length];

        double[][] coeffs = new double[mostRecentMjd.length][5];
        double[][] covars = new double[mostRecentMjd.length][25];
        for (int ii = 0; ii < mostRecentMjd.length; ++ii) {
            LargeFlatField largeFlatField = retrieveLargeFlatField(
                mostRecentMjd[ii], module, output);
            polynomialOrder[ii] = largeFlatField.getPolynomialOrder();
            type[ii] = largeFlatField.getType();
            xIndex[ii] = largeFlatField.getXIndex();
            offsetX[ii] = largeFlatField.getOffsetX();
            scaleX[ii] = largeFlatField.getScaleX();
            originX[ii] = largeFlatField.getOriginX();
            yIndex[ii] = largeFlatField.getXIndex();
            offsetY[ii] = largeFlatField.getOffsetX();
            scaleY[ii] = largeFlatField.getScaleX();
            originY[ii] = largeFlatField.getOriginX();

            coeffs[ii] = largeFlatField.getPolynomialCoefficientsArray();
            covars[ii] = largeFlatField.getCovarianceCoefficientsArray();
        }

        // Construct model:
        //
        return FcModelFactory.flatFieldModel(mostRecentMjd, flats,
            uncertainties, polynomialOrder, type, xIndex, offsetX, scaleX,
            originX, yIndex, offsetY, scaleY, originY, coeffs, covars);
    }

    /**
     * Get the flat field model that's valid for the given time range:
     * 
     * @param startMjd
     * @param endMjd
     * @param module
     * @param output
     * @return
     * @throws PipelineException
     * @throws FocalPlaneException
     */
    public FlatFieldModel retrieveFlatFieldModel(double startMjd,
        double endMjd, int module, int output) throws FocalPlaneException {

        // Get the Hibernate items:
        //
        double[] smallMjds = retrieveSmallFlatFieldImageTimes(startMjd, endMjd,
            module, output);
        List<LargeFlatField> lffs = retrieveLargeFlatFields(startMjd, endMjd,
            module, output);

        // Get the components of the model:
        //
        double[] mjds = sortedUniqueMjdsFromFlats(smallMjds, lffs);
        float[][][] flats = getFlats(mjds, module, output);
        float[][][] uncertainties = getUncertainties(mjds, module, output);

        // Large scale flat spec:
        //
        int[] polynomialOrder = new int[mjds.length];
        String[] type = new String[mjds.length];

        int[] xIndex = new int[mjds.length];
        double[] offsetX = new double[mjds.length];
        double[] scaleX = new double[mjds.length];
        double[] originX = new double[mjds.length];

        int[] yIndex = new int[mjds.length];
        double[] offsetY = new double[mjds.length];
        double[] scaleY = new double[mjds.length];
        double[] originY = new double[mjds.length];

        double[][] coeffs = new double[mjds.length][5];
        double[][] covars = new double[mjds.length][25];
        for (int ii = 0; ii < mjds.length; ++ii) {
            LargeFlatField largeFlatField = retrieveLargeFlatField(mjds[ii],
                module, output);
            polynomialOrder[ii] = largeFlatField.getPolynomialOrder();
            type[ii] = largeFlatField.getType();
            xIndex[ii] = largeFlatField.getXIndex();
            offsetX[ii] = largeFlatField.getOffsetX();
            scaleX[ii] = largeFlatField.getScaleX();
            originX[ii] = largeFlatField.getOriginX();
            yIndex[ii] = largeFlatField.getXIndex();
            offsetY[ii] = largeFlatField.getOffsetX();
            scaleY[ii] = largeFlatField.getScaleX();
            originY[ii] = largeFlatField.getOriginX();

            coeffs[ii] = largeFlatField.getPolynomialCoefficientsArray();
            covars[ii] = largeFlatField.getCovarianceCoefficientsArray();
        }

        // Construct model:
        //
        return FcModelFactory.flatFieldModel(mjds, flats, uncertainties,
            polynomialOrder, type, xIndex, offsetX, scaleX, originX, yIndex,
            offsetY, scaleY, originY, coeffs, covars);
    }

    /**
     * Get the flat field model for the time range and pixel row/col pairs that
     * are given:
     * 
     * @param startMjd
     * @param endMjd
     * @param module
     * @param output
     * @param rows
     * @param cols
     * @return
     * @throws PipelineException
     * @throws FocalPlaneException
     */
    public FlatFieldModel retrieveFlatFieldModel(double startMjd,
        double endMjd, int module, int output, int[] rows, int[] cols) {

        if (rows.length != cols.length) {
            throw new PipelineException(
                "rows and cols must be same length in retrieveFlatFieldModel");
        }

        // Get the Hibernate items:
        //
        double[] smallMjds = retrieveSmallFlatFieldImageTimes(startMjd, endMjd,
            module, output);
        List<LargeFlatField> lffs = retrieveLargeFlatFields(startMjd, endMjd,
            module, output);
        double[] mjds = sortedUniqueMjdsFromFlats(smallMjds, lffs);

        float[][][] flats = new float[mjds.length][1][rows.length];
        float[][][] uncertainties = new float[mjds.length][1][rows.length];

        for (int idate = 0; idate < mjds.length; ++idate) {
            double mjd = mjds[idate];

            SmallFlatFieldImage image = this.retrieveSmallFlatFieldImage(mjd,
                module, output);

            for (int ipix = 0; ipix < rows.length; ++ipix) {
                int row = rows[ipix];
                int col = cols[ipix];

                flats[idate][0][ipix] = image.getImageValue(row, col);
                uncertainties[idate][0][ipix] = image.getUncertaintyValue(row,
                    col);
            }
        }

        // Large scale flat spec:
        //
        int[] polynomialOrder = new int[mjds.length];
        String[] type = new String[mjds.length];

        int[] xIndex = new int[mjds.length];
        double[] offsetX = new double[mjds.length];
        double[] scaleX = new double[mjds.length];
        double[] originX = new double[mjds.length];

        int[] yIndex = new int[mjds.length];
        double[] offsetY = new double[mjds.length];
        double[] scaleY = new double[mjds.length];
        double[] originY = new double[mjds.length];

        double[][] coeffs = new double[mjds.length][5];
        double[][] covars = new double[mjds.length][25];
        for (int ii = 0; ii < mjds.length; ++ii) {
            LargeFlatField largeFlatField = retrieveLargeFlatField(mjds[ii],
                module, output);
            polynomialOrder[ii] = largeFlatField.getPolynomialOrder();
            type[ii] = largeFlatField.getType();
            xIndex[ii] = largeFlatField.getXIndex();
            offsetX[ii] = largeFlatField.getOffsetX();
            scaleX[ii] = largeFlatField.getScaleX();
            originX[ii] = largeFlatField.getOriginX();
            yIndex[ii] = largeFlatField.getXIndex();
            offsetY[ii] = largeFlatField.getOffsetX();
            scaleY[ii] = largeFlatField.getScaleX();
            originY[ii] = largeFlatField.getOriginX();

            coeffs[ii] = largeFlatField.getPolynomialCoefficientsArray();
            covars[ii] = largeFlatField.getCovarianceCoefficientsArray();
        }

        // Construct model:
        //
        return FcModelFactory.flatFieldModel(mjds, flats, uncertainties,
            polynomialOrder, rows, cols, type, xIndex, offsetX, scaleX,
            originX, yIndex, offsetY, scaleY, originY, coeffs, covars);
    }

    /**
     * 
     * @param startMjd
     * @param endMjd
     * @param module
     * @param output
     * @param definitions
     * @return
     * @throws FocalPlaneException
     * @throws PipelineException
     */
    public FlatFieldModel retrieveFlatFieldModel(double startMjd,
        double endMjd, int module, int output,
        List<TargetDefinition> definitions) throws PipelineException {

        List<TargetPixel> pixels = TargetPixel.getPixels(definitions);
        final int[] rows = new int[pixels.size()];
        final int[] columns = new int[pixels.size()];
        for (int i = 0; i < pixels.size(); i++) {
            TargetPixel pixel = pixels.get(i);
            rows[i] = pixel.getRow();
            columns[i] = pixel.getColumn();
        }

        return retrieveFlatFieldModel(startMjd, endMjd, module, output, rows,
            columns);
    }

    /**
     * Utility routine to convolve the large and small flats fields into one
     * flat.
     * 
     * @param mjds
     * @param module
     * @param output
     * @return
     * @throws PipelineException
     * @throws FocalPlaneException
     */
    private float[][][] getFlats(double[] mjds, int module, int output) {

        // Allocate output images:
        //
        float[][][] flats = new float[mjds.length][][];

        // Extract data:
        //
        for (int ii = 0; ii < mjds.length; ++ii) {
            flats[ii] = retrieveFlatField(module, output, mjds[ii]);
        }
        return flats;
    }

    private float[][][] getUncertainties(double[] mjds, int module, int output) {

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

    /**
     * Utility routine to convolve the large and small flats fields into one
     * flat for the given row/col pairs.
     * 
     * @param mjds
     * @param module
     * @param output
     * @param rows
     * @param cols
     * @return
     * @throws PipelineException *
     * @throws FocalPlaneException
     */
    @SuppressWarnings("unused")
    private float[][][] getFlats(double[] mjds, int module, int output,
        int[] rows, int[] cols) {

        // Allocate output images:
        //
        float[][][] flats = new float[mjds.length][][];

        // Extract data:
        //
        for (int ii = 0; ii < mjds.length; ++ii) {
            flats[ii] = retrieveFlatField(module, output, mjds[ii], rows, cols);
        }
        return flats;
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
        return largeOps.retrieveLargeFlatFieldExact(flat);
    }

}
