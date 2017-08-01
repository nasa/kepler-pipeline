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

package gov.nasa.kepler.ar.exporter.ffi;

import gov.nasa.kepler.ar.archive.*;
import gov.nasa.kepler.ar.exporter.SipWcsParameters;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.FfiType;
import gov.nasa.kepler.common.SipWcsCoordinates;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.common.pi.CalFfiModuleParameters;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.StreamedBlobResult;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.SkyGroupCrud;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrail;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.IOException;
import java.util.*;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;
import nom.tam.fits.ImageHDU;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Generates the image header and e-/s images from calibrated ffis.
 * 
 * @author Sean McCauliff
 *
 */
public class FfiFragmentGeneratorPipelineModule extends MatlabPipelineModule {

    private static final Log log = LogFactory.getLog(FfiFragmentGenerator.class);
    public static final String MODULE_NAME = "ffifrag";

    private double cachedReadNoise = Double.NaN;
    private final Set<Long> originators = new HashSet<Long>();
    private final Date generatedAt = new Date();
    private ModOutBarycentricCorrection bcCorrection;
    private SipWcsCoordinates sipWcsCoordinates;
    
    
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
        rv.add(CalFfiModuleParameters.class);
        rv.add(SipWcsParameters.class);
        rv.add(FfiFragmentGeneratorModuleParameters.class);
        return rv;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance, PipelineTask pipelineTask) throws PipelineException {
        ModOutUowTask uow = pipelineTask.uowTaskInstance();
        int ccdModule = uow.getCcdModule();
        int ccdOutput = uow.getCcdOutput();
        
        log.info("Generating FFI fragment for module/output " + ccdModule + "/" + ccdOutput + ".");
        CalFfiModuleParameters ffiParameters = pipelineTask.getParameters(CalFfiModuleParameters.class);
        SipWcsParameters sipWcsParameters = pipelineTask.getParameters(SipWcsParameters.class);
        FfiFragmentGeneratorModuleParameters assemblerParameters = 
            pipelineTask.getParameters(FfiFragmentGeneratorModuleParameters.class);
        
        String ffiTimestamp = ffiParameters.getFileTimeStamp();
        
        FfiFragmentGenerator ffiFragmentGenerator = ffiFragmentGenerator();
        try {
            FfiFragmentGeneratorSource source = 
                createFragmentGeneratorSource(ccdModule, ccdOutput, FfiType.SOC_CAL,
                    ffiTimestamp, pipelineTask,
                    sipWcsParameters, assemblerParameters);
            ffiFragmentGenerator.generateFragment(source);
            
            FfiFragmentGeneratorSource uncertSource = 
                createFragmentGeneratorSource(ccdModule, ccdOutput, FfiType.SOC_CAL_UNCERTAINTIES,
                    ffiTimestamp, pipelineTask, 
                    sipWcsParameters, assemblerParameters);
            ffiFragmentGenerator.generateFragment(uncertSource);
        } catch (Exception e) {
            throw new ModuleFatalProcessingException("Fix me.", e);
        }
        
        DataAccountabilityTrail daTrail = new DataAccountabilityTrail(pipelineTask.getId(), originators);
        getDataAccountabilityTrailCrud().create(daTrail);
        
    }
    
    protected FfiFragmentGenerator ffiFragmentGenerator() {
        return new FfiFragmentGenerator();
    }
    
    private FfiFragmentGeneratorSource createFragmentGeneratorSource(
        final int ccdModule, final int ccdOutput, final FfiType ffiType,
        final String ffiTimestamp, final PipelineTask pipelineTask,
        final SipWcsParameters sipWcsParameters,
        final FfiFragmentGeneratorModuleParameters assemblerParameters) throws FitsException, IOException {

        
        final FsId fragmentId = 
            CalFsIdFactory.getSingleChannelFfiFile(ffiTimestamp,
                ffiType, ccdModule, ccdOutput);

        log.info("Reading FFI image fragment \"" + fragmentId + "\".");
        
        StreamedBlobResult fsResult = getFileStoreClient().readBlobAsStream(fragmentId);
       
        BasicHDU primaryHdu = null;
        ImageHDU imageHdu = null;
        try {
            originators.add(fsResult.originator());
            Fits fits = new Fits(fsResult.stream());
            primaryHdu = fits.readHDU();
            imageHdu = (ImageHDU) fits.readHDU();
        } finally {
            FileUtil.close(fsResult.stream());
        }
        
        final BasicHDU finalPrimaryHdu = primaryHdu;
        final ImageHDU finalImageHdu = imageHdu;

        return new FfiFragmentGeneratorSource() {

           
            @Override
            public ImageHDU calibratedFfiImageHdu() {
                return finalImageHdu;
            }

            @Override
            public ConfigMap configMap(double startMjd, double endMjd) {
                List<ConfigMap> configMaps = getConfigMapOps().retrieveConfigMaps(startMjd, endMjd);
                if (configMaps.size() != 1) {
                    throw new IllegalStateException("Expected one config map" +
                            " but found " + configMaps.size() + ".");
                }
                return configMaps.get(0);
            }

            @Override
            public ModOutBarycentricCorrection ffiBarycentricCorrection(
                double startMjd, double endMjd,
                int longReferenceCadence,
                int imageWidth, int imageHeight) {
                
                
                if (bcCorrection == null) {
                    executeFfiArchive(pipelineTask, ccdModule, ccdOutput,
                                      startMjd, endMjd, longReferenceCadence,
                                      imageHeight, imageWidth,
                                      sipWcsParameters,
                                      assemblerParameters.isUseMotionPolynomials());
                }

                return bcCorrection;
            }

            @Override
            public double readNoiseE(double startMjd, double endMjd) {
                return FfiFragmentGeneratorPipelineModule.this.readNoiseE(startMjd, endMjd, ccdModule, ccdOutput);
            }

            @Override
            public FileStoreClient fsClient() {
                return getFileStoreClient();
            }

            @Override
            public long piplineTaskId() {
                return pipelineTask.getId();
            }

            @Override
            public String fileTimestamp() {
                return ffiTimestamp;
            }

            @Override
            public FfiType ffiType() {
                return ffiType;
            }
            
            @Override
            public int ccdModule() {
                return ccdModule;
            }

            @Override
            public int ccdOutput() {
                return ccdOutput;
            }
            
            @Override
            public Date generatedAt() {
                return generatedAt;
            }

            @Override
            public int skyGroupId( double startMjd, double endMjd) {
                final int startSeason = getRollTimeOps().mjdToSeason(startMjd);
                final int endSeason = getRollTimeOps().mjdToSeason(endMjd);
                if (startSeason != endSeason) {
                    throw new IllegalStateException("File is in season " + 
                        startSeason + " and season " + endSeason + ".");
                }

                return getSkyGroupCrud().retrieveSkyGroupId(ccdModule, ccdOutput, startSeason);
            }

            @Override
            public BasicHDU primaryHdu() {
                return finalPrimaryHdu;
            }

            @Override
            public double meanBlackCounts(double startMjd, double endMjd) {
               MeanBlackReader meanBlackReader = new MeanBlackReader();
               return meanBlackReader.meanBlack(startMjd, endMjd, ccdModule, ccdOutput);
            }

            @Override
            public SipWcsCoordinates sipWcs(double startMjd, double endMjd,
                int longReferenceCadence, 
                int imageWidth, int imageHeight) {
                
                if (!assemblerParameters.isUseMotionPolynomials()) {
                    return null;
                }
                
                if (sipWcsCoordinates == null) {
                    executeFfiArchive(pipelineTask, ccdModule, ccdOutput,
                                      startMjd, endMjd, longReferenceCadence, 
                                      imageHeight, imageWidth,
                                      sipWcsParameters, 
                                      assemblerParameters.isUseMotionPolynomials());
                }
                
                return sipWcsCoordinates;
            }
        };
    }

    /**
     * Assigns values to bcCorrection and sipWcs.
     * 
     * @param pipelineTask
     * @param ccdModule
     * @param ccdOutput
     * @param startMjd
     * @param endMjd
     * @param imageHeight
     * @param imageWidth
     */
    private void executeFfiArchive(
        PipelineTask pipelineTask,
        int ccdModule, int ccdOutput,
        double startMjd, double endMjd,
        int longReferenceCadence,
        int imageHeight, int imageWidth,
        SipWcsParameters sipWcsParameters,
        boolean useMotionPolynomials) {

        
        BlobSeries<String> motionPolyBlobs = BlobSeries.empty(longReferenceCadence, longReferenceCadence);
        
        if (useMotionPolynomials) {
            motionPolyBlobs = getBlobOps(pipelineTask)
                               .retrieveFfiMotionBlobFileSeries(ccdModule, ccdOutput,
                                                             longReferenceCadence,
                                                             longReferenceCadence);
        }
        
        double referenceCcdRow = ((double)imageWidth) / 2.0;
        double referenceCcdColumn = ((double)imageHeight) / 2.0;
        double midMjd = (startMjd + endMjd) / 2.0;
        
        List<ConfigMap> configMaps = getConfigMapOps().retrieveConfigMaps(startMjd, endMjd);
        if (configMaps.size() != 1) {
            throw new ModuleFatalProcessingException("Expected one config map found " + configMaps.size() + ".");
        }

        TimestampSeries emptyTimes = new TimestampSeries();
        
        FfiBarycentricCorrectionInputs ffiBarycentricCorrectionInputs =
            new FfiBarycentricCorrectionInputs(midMjd, referenceCcdColumn, referenceCcdRow);
        SipWcsInputs sipWcsInputs =
            new SipWcsInputs(longReferenceCadence,
                             sipWcsParameters.getColStep(),
                             sipWcsParameters.getRowStep());
                                                     
        RaDec2PixModel raDec2PixModel = getRaDec2PixOps().retrieveRaDec2PixModel(startMjd, endMjd);
        ArchiveInputs inputs = 
            new ArchiveInputs("ffi stuff", ccdModule, ccdOutput, configMaps,
                              emptyTimes, emptyTimes, raDec2PixModel, motionPolyBlobs, 
                              ffiBarycentricCorrectionInputs, sipWcsInputs);

        ArchiveOutputs outputs = new ArchiveOutputs();
        executeAlgorithm(pipelineTask, inputs, outputs);
        BarycentricCorrection baseCorrection = outputs.ffiBarycentricCorrection();
        bcCorrection = new ModOutBarycentricCorrection(baseCorrection.getCorrectionSeries()[0],
                                                       referenceCcdRow, referenceCcdColumn);
        sipWcsCoordinates = outputs.sipWcsCoordinates();
        
    }
    

    
    protected double readNoiseE(final double startMjd, final double endMjd, 
        final int ccdModule, final int ccdOutput) {
        if (!Double.isNaN(cachedReadNoise)) {
            return cachedReadNoise;
        }
        
        ReadNoiseOperations readNoiseOps = getReadNoiseOps();
        
        ReadNoiseModel readNoiseModel = readNoiseOps.retrieveReadNoiseModel(startMjd, endMjd);

        if (readNoiseModel.size() != 1 ) {
            throw new IllegalStateException("Expected only one read noise model, but found "
                + readNoiseModel.size());
        }
        
        GainOperations gainOps = getGainOps();
        double gainE = Double.NaN;
            GainModel gainModel = gainOps.retrieveGainModel(startMjd, endMjd);
            if (gainModel.size() != 1) {
                throw new IllegalStateException("Expected one gain model, but found " + gainModel.size() + ".");
            }
            gainE = gainModel.getConstants()[0][FcConstants.getChannelNumber(ccdModule, ccdOutput) - 1];
        
        double readNoiseDN = readNoiseModel.getConstants()[0][FcConstants.getChannelNumber(ccdModule, ccdOutput) - 1];
        cachedReadNoise = gainE * readNoiseDN;
        return cachedReadNoise;
    }
    
    
    private GainOperations getGainOps() {
        return new GainOperations();
    }

    protected ReadNoiseOperations getReadNoiseOps() {
        return new ReadNoiseOperations();
    }
    
    protected FileStoreClient getFileStoreClient() {
        return FileStoreClientFactory.getInstance();
    }
    
    protected ConfigMapOperations getConfigMapOps() {
        return new ConfigMapOperations();
    }
    
    protected SkyGroupCrud getSkyGroupCrud() {
        return new KicCrud();
    }
    
    protected RollTimeOperations getRollTimeOps() {
        return new RollTimeOperations();
    }

    protected RaDec2PixOperations getRaDec2PixOps() {
        return new RaDec2PixOperations();
    }
    
    protected LogCrud getLogCrud() {
        return new LogCrud();
    }
    
    protected DataAccountabilityTrailCrud getDataAccountabilityTrailCrud() {
        return new DataAccountabilityTrailCrud();
    }
    
    protected BlobOperations getBlobOps(PipelineTask pipelineTask) {
        return new BlobOperations(allocateWorkingDir(pipelineTask));
    }
    
    protected MjdToCadence getMjdToCadence() {
        return new MjdToCadence(CadenceType.LONG, new ModelMetadataRetrieverLatest());
    }
  
}
