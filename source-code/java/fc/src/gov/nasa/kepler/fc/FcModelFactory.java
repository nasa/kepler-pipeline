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

package gov.nasa.kepler.fc;

import gov.nasa.kepler.fc.prf.PrfModel;
import gov.nasa.kepler.hibernate.fc.Geometry;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.hibernate.fc.Linearity;
import gov.nasa.kepler.hibernate.fc.Pixel;
import gov.nasa.kepler.hibernate.fc.Pointing;
import gov.nasa.kepler.hibernate.fc.Saturation;
import gov.nasa.kepler.hibernate.pi.ModelMetadata;
import gov.nasa.kepler.hibernate.pi.ModelMetadataCrud;

import java.util.List;

public class FcModelFactory {

    public static RaDec2PixModel raDec2PixModel() {
        RaDec2PixModel model = new RaDec2PixModel();
        model.setGeometryModel(FcModelFactory.geometryModel());
        model.setPointingModel(FcModelFactory.pointingModel());
        model.setRollTimeModel(FcModelFactory.rollTimeModel());
        return model;
    }

    public static RaDec2PixModel raDec2PixModel(double modelMjdStart,
        double modelMjdEnd, PointingModel pointingModel,
        GeometryModel geometryModel, RollTimeModel rollTimeModel,
        String spiceFileAbsolutePath, String spiceFileSpacecraftEphermeris,
        String spiceFilePlanetaryEphermeris, String spiceFileLeapseconds) {

        RaDec2PixModel model = new RaDec2PixModel(modelMjdStart, modelMjdEnd,
            pointingModel, geometryModel, rollTimeModel, spiceFileAbsolutePath,
            spiceFileSpacecraftEphermeris, spiceFilePlanetaryEphermeris,
            spiceFileLeapseconds);

        model.getGeometryModel()
            .setFcModelMetadata(
                retrieveFcModelMetadata(HistoryModelName.GEOMETRY));
        model.getPointingModel()
            .setFcModelMetadata(
                retrieveFcModelMetadata(HistoryModelName.POINTING));
        model.getRollTimeModel()
            .setFcModelMetadata(
                retrieveFcModelMetadata(HistoryModelName.ROLLTIME));
        return model;
    }

    public static PrfModel prfModel() {
        PrfModel model = new PrfModel();
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.PRF));
        return model;
    }

    public static PrfModel prfModel(double mjd, int ccdModule, int ccdOutput,
        byte[] blob) {
        PrfModel model = new PrfModel(mjd, ccdModule, ccdOutput, blob);
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.PRF));
        return model;
    }

    public static PixelModel pixelModel(Pixel[] pixels) {
        PixelModel model = new PixelModel(pixels);
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.BAD_PIXELS));
        return model;
    }

    public static TwoDBlackModel twoDBlackModel() {
        TwoDBlackModel model = new TwoDBlackModel();
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.TWODBLACK));
        return model;
    }

    public static TwoDBlackModel twoDBlackModel(double[] mjds, int[] rows,
        int[] columns, float[][][] blacks, float[][][] uncertainties) {
        TwoDBlackModel model = new TwoDBlackModel(mjds, rows, columns, blacks,
            uncertainties);
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.TWODBLACK));
        return model;
    }

    public static TwoDBlackModel twoDBlackModel(double[] mjds,
        float[][][] blacks, float[][][] uncertainties) {
        TwoDBlackModel model = new TwoDBlackModel(mjds, blacks, uncertainties);
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.TWODBLACK));
        return model;
    }

    public static ReadNoiseModel readNoiseModel() {
        ReadNoiseModel model = new ReadNoiseModel();
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.READNOISE));
        return model;
    }

    public static ReadNoiseModel readNoiseModel(double[] mjds,
        double[][] constants) {
        ReadNoiseModel model = new ReadNoiseModel(mjds, constants);
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.READNOISE));
        return model;
    }

    public static LinearityModel linearityModel() {
        LinearityModel model = new LinearityModel();
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.LINEARITY));
        return model;
    }

    public static LinearityModel linearityModel(List<Linearity> linearities) {
        LinearityModel model = new LinearityModel(linearities);
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.LINEARITY));
        return model;
    }

    public static UndershootModel undershootModel() {
        UndershootModel model = new UndershootModel();
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.UNDERSHOOT));
        return model;
    }

    public static UndershootModel undershootModel(double[] mjds,
        double[][][] constants, double[][][] uncertainty) {
        UndershootModel model = new UndershootModel(mjds, constants,
            uncertainty);
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.UNDERSHOOT));
        return model;
    }

    public static GainModel gainModel() {
        GainModel model = new GainModel();
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.GAIN));
        return model;
    }

    public static GainModel gainModel(double[] mjds, double[][] constants) {
        GainModel model = new GainModel(mjds, constants);
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.GAIN));
        return model;
    }

    public static GeometryModel geometryModel() {
        GeometryModel model = new GeometryModel();
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.GEOMETRY));
        return model;
    }

    public static GeometryModel geometryModel(List<Geometry> geometrys) {
        GeometryModel model = new GeometryModel(geometrys);
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.GEOMETRY));
        return model;
    }

    public static GeometryModel geometryModel(double[] mjds,
        double[][] constants) {
        GeometryModel model = new GeometryModel(mjds, constants);
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.GEOMETRY));
        return model;
    }

    public static RollTimeModel rollTimeModel() {
        RollTimeModel model = new RollTimeModel();
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.ROLLTIME));
        return model;
    }

    public static RollTimeModel rollTimeModel(double[] mjds, int[] seasons,
        double[] rollTimeOffsets, double[] fovCenterRas,
        double[] fovCenterDeclinations, double[] fovCenterRolls) {
        RollTimeModel model = new RollTimeModel(mjds, seasons, rollTimeOffsets,
            fovCenterRas, fovCenterDeclinations, fovCenterRolls);
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.ROLLTIME));
        return model;
    }

    public static PointingModel pointingModel() {
        PointingModel model = new PointingModel();
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.POINTING));
        return model;
    }

    public static PointingModel pointingModel(List<Pointing> pointings) {
        PointingModel model = new PointingModel(pointings);
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.POINTING));
        return model;
    }

    public static PointingModel pointingModel(double[] mjds, double[] ras,
        double[] declinations, double[] rolls, double[] segmentStartMjds) {
        PointingModel model = new PointingModel(mjds, ras, declinations, rolls,
            segmentStartMjds);
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.POINTING));
        return model;
    }

    public static FlatFieldModel flatFieldModel() {
        FlatFieldModel model = new FlatFieldModel();
        model.setFcModelMetadataLargeFlat(retrieveFcModelMetadata(HistoryModelName.LARGEFLATFIELD));
        model.setFcModelMetadataSmallFlat(retrieveFcModelMetadata(HistoryModelName.SMALLFLATFIELD));
        return model;
    }

    public static FlatFieldModel flatFieldModel(double[] mjds,
        float[][][] flats, float[][][] uncertainties, int[] polynomialOrder,
        String[] type, int[] index, double[] offsetX, double[] scaleX,
        double[] originX, int[] index2, double[] offsetY, double[] scaleY,
        double[] originY, double[][] coeffs, double[][] covars) {

        FlatFieldModel model = new FlatFieldModel(mjds, new int[0], new int[0],
            flats, uncertainties, polynomialOrder, type, index, offsetX,
            scaleX, originX, index2, offsetY, scaleY, originY, coeffs, covars);
        model.setFcModelMetadataLargeFlat(retrieveFcModelMetadata(HistoryModelName.LARGEFLATFIELD));
        model.setFcModelMetadataSmallFlat(retrieveFcModelMetadata(HistoryModelName.SMALLFLATFIELD));
        return model;
    }

    public static FlatFieldModel flatFieldModel(double[] mjds,
        float[][][] flats, float[][][] uncertainties, int[] polynomialOrder,
        int[] rows, int[] columns, String[] type, int[] index,
        double[] offsetX, double[] scaleX, double[] originX, int[] index2,
        double[] offsetY, double[] scaleY, double[] originY, double[][] coeffs,
        double[][] covars) {

        FlatFieldModel model = new FlatFieldModel(mjds, rows, columns, flats,
            uncertainties, polynomialOrder, type, index, offsetX, scaleX,
            originX, index2, offsetY, scaleY, originY, coeffs, covars);
        model.setFcModelMetadataLargeFlat(retrieveFcModelMetadata(HistoryModelName.LARGEFLATFIELD));
        model.setFcModelMetadataSmallFlat(retrieveFcModelMetadata(HistoryModelName.SMALLFLATFIELD));
        return model;
    }

    /**
     * Private method to retrieve the FC Model metadata (to set the
     * fcModelMetadata field).
     * 
     * @param modelName
     * @return
     */
    private static FcModelMetadata retrieveFcModelMetadata(
        HistoryModelName modelName) {
        ModelMetadata modelMetadata = new ModelMetadataCrud().retrieveLatestModelRevision(modelName.toString());

        FcModelMetadata metadata = new FcModelMetadata();

        // These fields need to be filled with something or the HSQLDB tests
        // will fail:
        //
        if (modelMetadata != null) {
            metadata.setIngestTime(modelMetadata.getImportTime()
                .toString());
            metadata.setModelDescription(modelMetadata.getModelDescription());
            metadata.setSvnInfo(modelMetadata.getModelRevision());
        }

        return metadata;
    }

    public static SaturationModel saturationModel(Saturation[] saturations) {
        SaturationModel model = new SaturationModel(saturations);
        model.setFcModelMetadata(retrieveFcModelMetadata(HistoryModelName.SATURATION));
        return model;
    }

}
