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

import static gov.nasa.kepler.common.FitsConstants.*;
import gov.nasa.kepler.ar.exporter.CollateralConfigValues;
import gov.nasa.kepler.ar.exporter.FileNameFormatter;
import gov.nasa.kepler.ar.exporter.FitsChecksumOutputStream;
import gov.nasa.kepler.common.*;
import gov.nasa.kepler.common.ConfigMap.ConfigMapMnemonic;
import gov.nasa.kepler.common.pi.CalFfiModuleParameters;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.StreamedBlobResult;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.io.DataInputStream;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.fs.ArFsIdFactory;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.DataInput;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.List;

import nom.tam.fits.*;

import nom.tam.util.BufferedDataOutputStream;

import org.apache.commons.io.IOUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.ImmutableList;

/**
 * Generates the primary header and appends all the FFI fragments 
 * into a single file.
 * 
 * @author Sean McCauliff
 *
 */
public class FfiAssemberPipelineModule extends PipelineModule {

    private static final Log log = LogFactory.getLog(FfiAssemberPipelineModule.class);
    
    public final String MODULE_NAME = "ffiassembler";
    
    private final Date generatedAt = new Date();
    
    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return SingleUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> rv = new ArrayList<Class<? extends Parameters>>();
        rv.add(CalFfiModuleParameters.class);
        rv.add(FfiAssemblerModuleParameters.class);
        return rv;
    }
    
    
    @Override
    public void processTask(PipelineInstance pipelineInstance, PipelineTask pipelineTask) throws PipelineException {
        
        CalFfiModuleParameters calFfiParameters = pipelineTask.getParameters(CalFfiModuleParameters.class);
        FfiAssemblerModuleParameters assemblerParameters = pipelineTask.getParameters(FfiAssemblerModuleParameters.class);
        String exportDirStr = assemblerParameters.getNfsExportDirectory();
        File exportDir = new File(exportDirStr);
        
        String fileTimestamp = calFfiParameters.getFileTimeStamp();
        int dataReleaseNumber = assemblerParameters.getDataReleaseNumber();
        boolean allowMissingChannels = assemblerParameters.isAllowMissingChannels();
        
        try {
            FileUtil.mkdirs(exportDir);
            
            exportFile(exportDir, FfiType.SOC_CAL, fileTimestamp, pipelineTask,
                allowMissingChannels, dataReleaseNumber, assemblerParameters.getK2Campaign());
            exportFile(exportDir, FfiType.SOC_CAL_UNCERTAINTIES, fileTimestamp, pipelineTask,
                allowMissingChannels, dataReleaseNumber, assemblerParameters.getK2Campaign());
            
        } catch (Exception e) {
            throw new PipelineException(e);
        }
        
       
    }
    
    private void exportFile(File exportDir, FfiType ffiType,
        String fileTimestamp, 
        PipelineTask pipelineTask, boolean allowMissingChannels,
        int dataReleaseNumber,
        int k2Campaign) 
    throws Exception {
        FileNameFormatter fnameFormatter = new FileNameFormatter();
        String fname = null;
        if (k2Campaign < 0) {
            fname = fnameFormatter.ffiName(fileTimestamp, ffiType);
        } else {
            fname = fnameFormatter.k2FfiName(fileTimestamp, ffiType, k2Campaign);
        }
        
        FfiPrimaryHeaderFormatter headerFormatter = new FfiPrimaryHeaderFormatter();
        FfiPrimaryHeaderFormatterSource source = 
            createPrimaryHeaderSource(ffiType, fileTimestamp,
                pipelineTask, CHECKSUM_DEFAULT, allowMissingChannels, dataReleaseNumber,
                k2Campaign >= 0, k2Campaign,
                fname);
        
        FitsChecksumOutputStream checksumOutputStream = new FitsChecksumOutputStream();
        BufferedDataOutputStream bufOut = new BufferedDataOutputStream(checksumOutputStream);
        Header primaryHeader = headerFormatter.formatHeader(source);
        primaryHeader.write(bufOut);
        bufOut.close();
        
        final String primaryHeaderChecksum = checksumOutputStream.checksumString();
        source = 
            createPrimaryHeaderSource(ffiType, fileTimestamp,
                pipelineTask, primaryHeaderChecksum, allowMissingChannels, dataReleaseNumber,
                k2Campaign >= 0, k2Campaign,
                fname);
        
        
        File outputFile = new File(exportDir, fname);
        FileOutputStream fout = null;
        BufferedDataOutputStream bufferedFileOutput = null;
        try {
            fout = new FileOutputStream(outputFile);
            bufferedFileOutput = new BufferedDataOutputStream(fout);
            
            primaryHeader = headerFormatter.formatHeader(source);
            primaryHeader.write(bufferedFileOutput);
            
            for (int ccdModule : FcConstants.modulesList) {
                for (int ccdOutput : FcConstants.outputsList) {
                    writeOutImage(bufferedFileOutput, ffiType, fileTimestamp, ccdModule, ccdOutput, allowMissingChannels);
                }
            }
           
            
        } finally {
            FileUtil.close(bufferedFileOutput);
            FileUtil.close(fout);
        }
        
        log.info("Done writing FFI \"" + fname + "\".");
        
    }
    
    private void writeOutImage(BufferedDataOutputStream bufferedFileOutput, FfiType ffiType, String fileTimestamp,
        int ccdModule, int ccdOutput, boolean allowMissingChannels) throws IOException, FitsException {

        FsId fsId = ArFsIdFactory.getSingleChannelFfiFile(fileTimestamp, ffiType, ccdModule, ccdOutput);
        if (allowMissingChannels && !getFileStoreClient().blobExists(fsId)) {
            log.warn("Skipping mod/out " + ccdModule + "/" + ccdOutput + ".");
            return;
        }
        StreamedBlobResult blobResult = getFileStoreClient().readBlobAsStream(fsId);
        log.info("Reading image file from \"" + fsId + "\".");
        try {
            DataInput din = new DataInputStream(blobResult.stream());
            FitsUtils.advanceToEndOfHeader(din);
            IOUtils.copyLarge(blobResult.stream(), bufferedFileOutput);
            
        } finally {
            FileUtil.close(blobResult.stream());
        }
        log.info("Appended image HDU for mod/out " + ccdModule + "/" + ccdOutput + ".");
    }

    private FsId findFirstModOut(boolean allowMissingChannels, String fileTimestamp, FfiType ffiType) {
        if (!allowMissingChannels ) {
            return CalFsIdFactory.getSingleChannelFfiFile(fileTimestamp, ffiType, 2, 1);
        }
        
        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                FsId calFfiId = 
                    CalFsIdFactory.getSingleChannelFfiFile(fileTimestamp, ffiType, ccdModule, ccdOutput);
                if (getFileStoreClient().blobExists(calFfiId)) {
                    return calFfiId;
                }
            }
        }
        throw new ModuleFatalProcessingException("Can't find any mod outs" +
                " for FFI with time stamp \"" + fileTimestamp + "\".");
    }
    
    private FfiPrimaryHeaderFormatterSource createPrimaryHeaderSource(final FfiType ffiType,
        final String fileTimestamp, 
        final PipelineTask pipelineTask,
        final String checksumValue,
        boolean allowMissingChannels,
        final int dataReleaseNumber,
        final boolean isK2, 
        final int k2Campaign,
        final String fname)
    throws Exception {
        
        //This mod/out should have the original header.
        FsId calFfiId = findFirstModOut(allowMissingChannels, fileTimestamp, ffiType);
        
        StreamedBlobResult streamedBlobResult = 
            getFileStoreClient().readBlobAsStream(calFfiId);
        BasicHDU originalPrimaryHdu = null;
        ImageHDU imageHdu = null;
        try {
            Fits fits = new Fits(streamedBlobResult.stream());
            originalPrimaryHdu= fits.readHDU();
            imageHdu = (ImageHDU) fits.readHDU();
            streamedBlobResult.stream().close();
        } finally {
            FileUtil.close(streamedBlobResult.stream());
        }
        
        final FfiPrimaryHeaderKeywordExtractor originalKeywords = 
            new FfiPrimaryHeaderKeywordExtractor(originalPrimaryHdu.getHeader());
        FfiIImageHeaderKeywordExtractor imageKeywords = 
            new FfiIImageHeaderKeywordExtractor(imageHdu.getHeader());
        final CommonKeywordValues commonValues = new CommonKeywordValues(originalKeywords.common(), imageKeywords.common());
        
        final int configMapId = originalKeywords.configMapId();
        
        Collection<ConfigMap> configMaps = 
            ImmutableList.of(getConfigMapOps().retrieveConfigMap(configMapId));
        
        ConfigMap configMap = configMaps.iterator().next();
        int tempSetPointDn = 
            configMap.getInt(ConfigMapMnemonic.focalPlaneTemperatureSetPointDn);
        final float tempSetPointC = tempDnToC(tempSetPointDn);
        
        
        final int season = getRollTimeOps().mjdToSeason(commonValues.startMjd());
        int[] quarters = getRollTimeOps().mjdToQuarter(new double[] { commonValues.startMjd(), commonValues.endMjd()} );
        if (quarters[0] != quarters[1]) {
            throw new IllegalStateException("FFI can not be in two quarters.");
        }
        
        //If the quarter is -1 then this FFI occurs before Q0 in which case
        //we should just call it Q0.
        final int quarter = (quarters[0] == -1) ? 0 : quarters[0];
        final String dataSetName = FileNameFormatter.dataSetName(fname);
        
        FfiPrimaryHeaderFormatterSource  source = 
            new HeaderSourceInputs(configMaps) {

            @Override
            public String subversionUrl() {
                return KeplerSocVersion.getUrl();
            }
            
            @Override
            public String subversionRevision() {
                return KeplerSocVersion.getRevision();
            }
            
            @Override
            public int season() {
                return season;
            }
            
            @Override
            public double boresightRollDeg() {
                return originalKeywords.boresightRollDeg();
            }
            
            @Override
            public double boresightRaDeg() {
                return originalKeywords.boresightRaDeg();
            }
            
            @Override
            public int quarter() {
                return quarter;
            }
            
            @Override
            public String programName() {
                return MODULE_NAME;
            }
            
            @Override
            public long pipelineTaskId() {
                return pipelineTask.getId();
            }
            
            @Override
            public double operatingTemp() {
                return tempSetPointC;
            }
            
            @Override
            public boolean isReverseClocked() {
                return originalKeywords.reverseClocked();
            }
            
            @Override
            public boolean isMomemtumDump() {
                return commonValues.momentiumDump();
            }
            
            @Override
            public boolean isFinePoint() {
                return commonValues.finePoint();
            }
            
            @Override
            public FfiType imageType() {
                return ffiType;
            }
            
            @Override
            public Date generatedAt() {
                return FfiAssemberPipelineModule.this.generatedAt();
            }
            
            @Override
            public double[] focusingPosition() {
                return originalKeywords.focuserPositions();
            }
            
            @Override
            public double boresightDecDeg() {
                return originalKeywords.boresightDecDeg();
            }
            
            @Override
            public String datasetName() {
                return dataSetName;
            }
            
            @Override
            public String dataCollectionTime() {
                return originalKeywords.dataCollectionTime();
            }
            
            @Override
            public int configMapId() {
                return configMapId;
            }
            
            @Override
            public String checksumString() {
                return checksumValue;
            }
            
            @Override
            public int dataReleaseNumber() {
                return dataReleaseNumber;
            }

            @Override
            public boolean isK2() {
                return isK2;
            }

            @Override
            public int k2Campaign() {
                return k2Campaign;
            }
            
        };
        
        return source;
    }

    /**
     * This equation is from Doug from Ball's notes on how the temperature 
     * digital to analog controller works.
     * @param dn The temperature set point in DN (digital number).
     * @return The temperature set point in degrees C.
     */
    private static float tempDnToC(int dn) {
        return -88.58f  + 6.5034E-4f * dn;
    }
    
    protected RollTimeOperations getRollTimeOps() {
        return new RollTimeOperations();
    }
    
    protected Date generatedAt() {
        return generatedAt;
    }
    
    protected ConfigMapOperations getConfigMapOps() {
        return new ConfigMapOperations();
    }
    
    protected FileStoreClient getFileStoreClient() {
        return FileStoreClientFactory.getInstance();
    }
    //Implement this as an anonymous class elsewhere
    private abstract static class HeaderSourceInputs extends CollateralConfigValues 
        implements FfiPrimaryHeaderFormatterSource {

        public HeaderSourceInputs(Collection<ConfigMap> configMaps) {
            super(configMaps);
        }
    }
}
