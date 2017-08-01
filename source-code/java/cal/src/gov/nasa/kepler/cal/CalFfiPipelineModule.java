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

package gov.nasa.kepler.cal;

import static gov.nasa.kepler.common.FitsConstants.NEXTEND_COMMENT;
import static gov.nasa.kepler.common.FitsConstants.NEXTEND_KW;
import static gov.nasa.kepler.common.pi.CalFfiModuleParameters.CALCULATE_LONG_CADENCE;
import static gov.nasa.kepler.mc.fs.DrFsIdFactory.getSingleChannelFfiFile;
import gov.nasa.kepler.cal.ffi.FfiModOut;
import gov.nasa.kepler.cal.ffi.FfiReader;
import gov.nasa.kepler.cal.io.*;
import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FfiType;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.pi.CalFfiModuleParameters;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dr.ConfigMapCrud;
import gov.nasa.kepler.hibernate.mc.ObservingLogModel;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrail;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.QuarterToParameterValueMap;
import gov.nasa.kepler.mc.PouModuleParameters;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.pi.ModelOperationsFactory;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.kepler.pi.models.ModelOperations;
import gov.nasa.kepler.pi.module.AlgorithmResults;
import gov.nasa.kepler.pi.module.AsyncPipelineModule;
import gov.nasa.kepler.pi.module.InputsGroup;
import gov.nasa.kepler.pi.module.InputsHandler;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.*;

import nom.tam.fits.FitsException;
import nom.tam.fits.ImageData;
import nom.tam.fits.ImageHDU;
import nom.tam.util.BufferedDataOutputStream;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Calibration for full frame images.
 * 
 * @author Sean McCauliff
 * 
 */
public class CalFfiPipelineModule extends AbstractCalPipelineModule
    implements AsyncPipelineModule {

    private static final Log log = LogFactory.getLog(CalFfiPipelineModule.class);

    public static final String MODULE_NAME = "calffi";

    private ConfigMapCrud configCrud;
    private RollTimeOperations rollOps;
    private QuarterToParameterValueMap parameterValues;

    private FitsHeaderReader fitsHeaderReader = new FitsHeaderReader();
    
    private PipelineTask pipelineTask;

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return ModOutUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> rv = new ArrayList<Class<? extends Parameters>>();
        rv.add(CalModuleParameters.class);
        rv.add(PouModuleParameters.class);
        rv.add(CalFfiModuleParameters.class);
        rv.add(CalCosmicRayParameters.class);
        rv.add(CalHarmonicsIdentificationParameters.class);
        rv.add(GapFillModuleParameters.class);
        return rv;
    }

    @Override
    public void generateInputs(InputsHandler inputsHandler, PipelineTask pipelineTask,
            File workingDirectory) throws RuntimeException {
        this.pipelineTask = pipelineTask;

        InputsGroup inputsGroup = inputsHandler.createGroup();
        
        CalModuleParameters calModuleParameters = 
            pipelineTask.getParameters(CalModuleParameters.class);
        PouModuleParameters pouModuleParameters = 
            pipelineTask.getParameters(PouModuleParameters.class);
        CalFfiModuleParameters calFfiModuleParameters = 
            pipelineTask.getParameters(CalFfiModuleParameters.class);
        CalCosmicRayParameters cosmicRayParameters = 
            pipelineTask.getParameters(CalCosmicRayParameters.class);
        CalHarmonicsIdentificationParameters harmonicsParameters = 
            pipelineTask.getParameters(CalHarmonicsIdentificationParameters.class);
        GapFillModuleParameters gapFillParameters = 
            pipelineTask.getParameters(GapFillModuleParameters.class);
        
        ModOutUowTask task = pipelineTask.uowTaskInstance();

        FsId ffiFsId = getSingleChannelFfiFile(
            calFfiModuleParameters.getFileTimeStamp(), FfiType.ORIG,
            task.getCcdModule(), task.getCcdOutput());

        log.info("Cal FFI processing file \"" + ffiFsId + "\".");

        FfiModOut ffiModOut = retrieveFfiModOut(ffiFsId);

        producerTaskIds.add(ffiModOut.originator);
        
        int closestLongCadence = 
            getLogCrud().retrieveCadenceClosestToMjd(Cadence.CADENCE_LONG, ffiModOut.midMjd);
        QuarterToParameterValueMap blackAlgorithmValues = getParameterValues();
        List<String> quartersList = Arrays.asList(calModuleParameters.getBlackAlgorithmQuarters().split(","));
        List<String> values = Arrays.asList(calModuleParameters.getBlackAlgorithm().split(","));
        String blackAlgorithmValue = blackAlgorithmValues.getValue(quartersList, values, 
            CadenceType.LONG, closestLongCadence, closestLongCadence);
        calModuleParameters.setBlackAlgorithm(blackAlgorithmValue);
        
        //See http://bit.ly/9RXx08
        BlobFileSeries dynaBlobs = new BlobFileSeries();
        if (calModuleParameters.dynablackIsEnabled()) {
            closestLongCadence = calFfiModuleParameters.getDynamic2DBlackBlobLongCadence();
            if (closestLongCadence == CALCULATE_LONG_CADENCE) {
                closestLongCadence = 
                    getLogCrud().retrieveCadenceClosestToMjd(Cadence.CADENCE_LONG, ffiModOut.midMjd);
            }
            dynaBlobs = retrieveDynamicTwo2Black(CadenceType.LONG,
                closestLongCadence, closestLongCadence,
                task.getCcdModule(), task.getCcdOutput(),
                workingDirectory);
        }
        
        TimestampSeries cadenceTimes = fitsHeaderReader.getCadenceTimes(ffiModOut);
        int season = getRollTimeOps().mjdToSeason(cadenceTimes.startMjd());
        retrieveFcModels(cadenceTimes.startMjd(), cadenceTimes.endMjd(),
            task.getCcdModule(), task.getCcdOutput());

        gov.nasa.kepler.hibernate.dr.ConfigMap hConfigMap = 
            getConfigMapCrud().retrieveConfigMap(ffiModOut.spaceCraftConfigMapId);

        if (hConfigMap == null) {
            throw new ModuleFatalProcessingException("Missing config map for "
                + "config id " + ffiModOut.spaceCraftConfigMapId + ".");
        }

        List<ConfigMap> configMaps = Collections.singletonList(new ConfigMap(
            hConfigMap.getScConfigId(), hConfigMap.getMjd(),
            hConfigMap.getMap()));

        EmbeddedPipelineInfo pipelineInfo = 
            new EmbeddedPipelineInfo(task.getCcdModule(), task.getCcdOutput(),
                                     pipelineTask.getId(), ffiFsId.toString(),
                                     ffiModOut.midMjd);
                                                   
        Cal2DCollateral twoDCollateral;
        try {
            twoDCollateral = ffiModOut.collateral(configMaps.get(0));
        } catch (Exception e) {
            throw new ModuleFatalProcessingException(
                "While getting config maps.", e);
        }
        int totalPixels = ffiModOut.image.length * ffiModOut.image[0].length
            + twoDCollateral.collateralPixelCount();

        CalInputs collateralInputs = 
            new CalInputs(task.getCcdModule(), task.getCcdOutput(), 
                          calModuleParameters, pouModuleParameters, 
                          cosmicRayParameters, harmonicsParameters,
                          gapFillParameters, cadenceTimes,
                          gainModel, flatFieldModel, twoDBlackModel, linearityModel,
                          undershootModel, readNoiseModel, configMaps, season,
                          dynaBlobs, pipelineInfo, twoDCollateral);
        collateralInputs.setTotalPixels(totalPixels);
        log.info("Writing FFI collateral inputs.");
        inputsGroup.addSubTaskInputs(collateralInputs);
        collateralInputs = null;
        

        CalInputs ffiInputs = 
            new CalInputs(task.getCcdModule(), task.getCcdOutput(),
                            calModuleParameters,
                            pouModuleParameters,
                            cosmicRayParameters, harmonicsParameters,
                            gapFillParameters, cadenceTimes, gainModel, flatFieldModel,
                            twoDBlackModel, linearityModel,
                            undershootModel, readNoiseModel,
                            configMaps, season, dynaBlobs,
                            pipelineInfo, ffiModOut.allPixels());
                                            
        
        ffiInputs.setTotalPixels(totalPixels);

        log.info("Writing cal FFI frame.");
        inputsGroup.addSubTaskInputs(ffiInputs);
        inputsGroup.add(0,1);
    }

	private FfiModOut retrieveFfiModOut(FsId ffiFsId) {
		FfiReader ffiReader = new FfiReader();
        FfiModOut ffiModOut = null;
        try {
            ffiModOut = ffiReader.readFFiModOut(ffiFsId);
        } catch (IOException e) {
            throw new ModuleFatalProcessingException(
                "Failed to read FFI file.", e);
        } catch (FitsException e) {
            throw new ModuleFatalProcessingException(
                "Failed to parse FFI file.", e);
        }
		return ffiModOut;
	}
    
    @Override
    public void processOutputs(PipelineTask pipelineTask,
            Iterator<AlgorithmResults> outputs) throws RuntimeException {

        log.info("Cal FFI completed calibrating full frame.");
        outputs.next(); //throw away the first invocation outputs.
        AlgorithmResults ffiResult = outputs.next();

        if (!ffiResult.successful()) {
            log.warn("Failed sub-task due to MATLAB error for sub-task "
                + ffiResult.getResultsDir());
            throw new ModuleFatalProcessingException("MATLAB failed, aborting.");
        }

        CalOutputs ffiOutputs = (CalOutputs) ffiResult.getOutputs();
        if (outputs.hasNext()) {
            throw new ModuleFatalProcessingException("Expected only two outputs.");
        }
        
        ModOutUowTask uow = pipelineTask.uowTaskInstance();
        CalFfiModuleParameters calFfiModuleParameters = 
                pipelineTask.getParameters(CalFfiModuleParameters.class);
        
        FsId ffiFsId = getSingleChannelFfiFile(
            calFfiModuleParameters.getFileTimeStamp(), FfiType.ORIG,
            uow.getCcdModule(), uow.getCcdOutput());

        log.info("Cal FFI storing outputs for \"" + ffiFsId + "\".");

        FfiModOut ffiModOut = retrieveFfiModOut(ffiFsId);
        try {
            storeFfiOutputs(ffiOutputs, ffiModOut,
                calFfiModuleParameters.getFileTimeStamp(), 
                ffiResult.getResultsDir(), pipelineTask);
        } catch (FitsException e) {
            throw new PipelineException("Failed to store outputs.", e);
        } catch (IOException e) {
            throw new PipelineException("Failed to store outputs.", e);
        }

        updateDataAccountability(pipelineTask);
    }

    protected void updateDataAccountability(PipelineTask pipelineTask) {
        // Update the data accountability trail.
        DataAccountabilityTrail daTrail = 
            new DataAccountabilityTrail(pipelineTask.getId());
        daTrail.setProducerTaskIds(producerTaskIds);
        getDaCrud().create(daTrail);
    }


    protected void storeFfiOutputs(CalOutputs ffiOutputs, FfiModOut ffiModOut,
        String fileTimeStamp, File workingDirectory, PipelineTask pipelineTask)
            throws FitsException, IOException {
        log.info("Cal FFI converting outputs.");
        List<CalOutputPixelTimeSeries> calibratedPixelSeries = ffiOutputs.getTargetAndBackgroundPixels();
        final int nRows = ffiModOut.image.length;
        final int nCols = ffiModOut.image[0].length;
        final float[][] calibratedImage = new float[nRows][nCols];
        final float[][] uncertaintyImage = new float[nRows][nCols];

        for (int i = 0; i < calibratedImage.length; i++) {
            Arrays.fill(calibratedImage[i], Float.NaN);
            Arrays.fill(uncertaintyImage[i],Float.NaN);
        }

        for (CalOutputPixelTimeSeries pixelSeries : calibratedPixelSeries) {
            if (pixelSeries.getGapIndicators()[0]) {
                continue;
            }
            int r = pixelSeries.getRow();
            int c = pixelSeries.getColumn();
            calibratedImage[r][c] = pixelSeries.getValues()[0];
            uncertaintyImage[r][c] = pixelSeries.getUncertainties()[0];
        }

        log.info("Cal FFI storing image.");
        FsId imageFsId = CalFsIdFactory.getSingleChannelFfiFile(fileTimeStamp,
            FfiType.SOC_CAL, ffiModOut.ccdModule, ffiModOut.ccdOutput);
        storeImage(calibratedImage, imageFsId, ffiModOut, workingDirectory, 
            pipelineTask);

        log.info("Cal FFI storing uncertainty image.");
        FsId uncertFsId = CalFsIdFactory.getSingleChannelFfiFile(fileTimeStamp,
            FfiType.SOC_CAL_UNCERTAINTIES, ffiModOut.ccdModule,
            ffiModOut.ccdOutput);
        storeImage(uncertaintyImage, uncertFsId, ffiModOut, workingDirectory,
            pipelineTask);

        if (ffiOutputs.getUncertaintyBlobFileName().length() != 0) {
            log.info("Cal FFI storing uncertainty blob.");
            File blobFile = 
                new File(workingDirectory, ffiOutputs.getUncertaintyBlobFileName());
            FsId uncertBlobFsId = CalFsIdFactory.getSingleChannelFfiFile(
                fileTimeStamp,
                FfiType.SOC_CAL_UNCERTAINTIES_BLOB,
                ffiModOut.ccdModule, ffiModOut.ccdOutput);
            FileStoreClientFactory.getInstance()
                .writeBlob(uncertBlobFsId, pipelineTask.getId(), blobFile);
        }
        log.info("Cal FFI storing outputs complete.");
    }

    private void storeImage(float[][] calibratedImage, FsId imageFsId,
        FfiModOut ffiModOut, File workingDirectory, PipelineTask pipelineTask)
            throws FitsException, IOException {

        ffiModOut.primaryHdu.addValue(NEXTEND_KW, 1,
            NEXTEND_COMMENT);
        //Header keywords that would misrepresent the SOC calibration process.
        //Are scrubbed by the FFI exporter.
        File tmpFile = new File(workingDirectory, imageFsId.name());
        FileOutputStream fout = new FileOutputStream(tmpFile);
        BufferedDataOutputStream bufout = new BufferedDataOutputStream(fout);
        ffiModOut.primaryHdu.write(bufout);
        ffiModOut.imageHeader.setBitpix(-32); // float
        ImageData imageData = new ImageData(calibratedImage);
        ImageHDU imageHdu = new ImageHDU(ffiModOut.imageHeader, imageData);
        imageHdu.write(bufout);
        FileUtil.close(bufout);
        FileUtil.close(fout);

        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        fsClient.writeBlob(imageFsId, pipelineTask.getId(), tmpFile);
        tmpFile.delete();

        // TODO: Fix file store bug when files are written in this way.
        /*
         * OutputStream fsout =
         * FileStoreClientFactory.getInstance().writeBlob(imageFsId,
         * pipelineTask.getId()); BufferedDataOutputStream fdout = new
         * BufferedDataOutputStream(fsout); ffiModOut.primaryHdu.write(fdout);
         * 
         * ffiModOut.imageHeader.setBitpix(-32); //float ImageData imageData =
         * new ImageData(calibratedImage); ImageHDU imageHdu = new
         * ImageHDU(ffiModOut.imageHeader, imageData); imageHdu.write(fdout);
         * fdout.close();
         */
    }

    /**           * Retrieves all the FC models needed by CAL.
     * 
     * @param ccdModule the module.
     * @param ccdOutput the output.
     * @param startCadence the starting cadence.
     * @param endCadence the ending cadence.
     * @throws PipelineException
     */
    protected void retrieveFcModels(double startMjd, double endMjd, 
        int ccdModule, int ccdOutput) {

        gainModel = getGainOperations().retrieveGainModel(startMjd, endMjd);
        flatFieldModel = getFlatFieldOperations().retrieveFlatFieldModel(
            startMjd, endMjd, ccdModule, ccdOutput);
        twoDBlackModel = getTwoDBlackOperations().retrieveTwoDBlackModel(
            startMjd, endMjd, ccdModule, ccdOutput);

        linearityModel = getLinearityOperations().retrieveLinearityModel(
            ccdModule, ccdOutput, startMjd, endMjd);

        undershootModel = 
            getUndershootOperations().retrieveUndershootModel(startMjd, endMjd);

        readNoiseModel = getReadNoiseOperations().retrieveReadNoiseModel(
                                                                         startMjd, endMjd);
    }

    private ConfigMapCrud getConfigMapCrud() {
        if (configCrud == null) {
            configCrud = new ConfigMapCrud();
        }
        return configCrud;
    }

    void setConfigMapCrud(ConfigMapCrud crud) {
        this.configCrud = crud;
    }

    void setFitsHeaderReader(FitsHeaderReader fitsHeaderReader) {
        this.fitsHeaderReader = fitsHeaderReader;
    }
    
    private RollTimeOperations getRollTimeOps() {
        if (rollOps == null) {
            rollOps = new RollTimeOperations();
        }
        return rollOps;
    }
    
    void setRollTimeOps(RollTimeOperations rollTimeOps) {
        this.rollOps = rollTimeOps;
    }

    private QuarterToParameterValueMap getParameterValues() {
        if (parameterValues == null) {
            ModelOperations<ObservingLogModel> modelOperations = ModelOperationsFactory.getObservingLogInstance(
                new ModelMetadataRetrieverPipelineInstance(pipelineTask.getPipelineInstance()));
            ObservingLogModel observingLogModel = modelOperations.retrieveModel();
            parameterValues = new QuarterToParameterValueMap(observingLogModel);
        }
        return parameterValues;
    }

    void setParameterValues(QuarterToParameterValueMap parameterValues) {
        this.parameterValues = parameterValues;
    }

    @Override
    public Class<?> outputsClass() {
        return CalOutputs.class;
    }

}
