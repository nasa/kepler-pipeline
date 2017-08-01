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

import gov.nasa.kepler.cal.io.CalCosmicRayParameters;
import gov.nasa.kepler.cal.io.CalHarmonicsIdentificationParameters;
import gov.nasa.kepler.cal.io.CalInputs;
import gov.nasa.kepler.cal.io.CalModuleParameters;
import gov.nasa.kepler.cal.io.CalOutputs;
import gov.nasa.kepler.cal.io.CommonParameters;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.mc.ObservingLogModel;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrail;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.QuarterToParameterValueMap;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.PouModuleParameters;
import gov.nasa.kepler.mc.ProducerTaskIdsStream;
import gov.nasa.kepler.mc.pi.ModelOperationsFactory;
import gov.nasa.kepler.mc.pmrf.PmrfOperations;
import gov.nasa.kepler.mc.pmrf.SciencePmrfTable;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.kepler.pi.models.ModelOperations;
import gov.nasa.kepler.pi.module.*;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.text.ParseException;
import java.util.*;

import nom.tam.fits.FitsException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.*;

import static gov.nasa.kepler.common.FcConstants.getModuleOutput;

/**
 * The cal pipeline module.
 * 
 * @author Sean McCauliff
 * @author Forrest Girouard
 * @author Bill Wohler
 * @author Jason Brittain <jbrittain@mail.arc.nasa.gov>
 */
public class CalPipelineModule extends MatlabPipelineModule 
implements AsyncPipelineModule{

    private static final Log log = LogFactory.getLog(CalPipelineModule.class);

    public static final String MODULE_NAME = "cal";

    private PipelineTask pipelineTask;

    /**
     * Creates a {@link CalPipelineModule}.
     * 
     * @throws PipelineException if the database service could not be
     * initialized.
     */
    public CalPipelineModule() {
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return ModOutCadenceUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> rv = new ArrayList<Class<? extends Parameters>>();
        rv.add(CalModuleParameters.class);
        rv.add(PouModuleParameters.class);
        rv.add(CadenceTypePipelineParameters.class);
        rv.add(CalCosmicRayParameters.class);
        rv.add(CalHarmonicsIdentificationParameters.class);
        rv.add(GapFillModuleParameters.class);
        return rv;
    }

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }


    /**
     * 
     * @param pipelineTask
     * @param cadenceType
     * @param startCadence
     * @param endCadence
     * @param ccdModule
     * @param ccdOutput
     * @param blobOutputDir
     * @param calModuleParameters
     * @param pouModuleParameters
     * @param cosmicRayParameters
     * @return the common processing parameters to every cal invocation else 
     * returns null if there is not sufficient data to continue processing.
     */
    protected CommonParameters createCommonParameters(PipelineTask pipelineTask,
            CadenceType cadenceType,
            int startCadence, int endCadence, int ccdModule, int ccdOutput,
            File blobOutputDir, CalModuleParameters calModuleParameters,
            PouModuleParameters pouModuleParameters, 
            CalCosmicRayParameters cosmicRayParameters,
            CalHarmonicsIdentificationParameters harmonicsParameters,
            GapFillModuleParameters gapFillParameters) {

        CommonParametersFactory factory = new CommonParametersFactory();
        factory.setParameters(calModuleParameters, cosmicRayParameters, pouModuleParameters, harmonicsParameters, gapFillParameters);

        CommonParameters commonParameters;
        try {
            commonParameters = factory.create(cadenceType, startCadence, endCadence, ccdModule, ccdOutput, blobOutputDir);
        } catch (ParseException e) {
            throw new PipelineException(e);
        } catch (IOException e) {
            throw new PipelineException(e);
        } catch (FitsException e) {
            throw new PipelineException(e);
        }
        if (commonParameters == null) {
            return null;
        }
        commonParameters.setPipelineTaskId(pipelineTask.getId());

        return commonParameters;

    }

    protected CalOutputsConsumer createCalOutputsConsumer() {
        return new CalOutputsConsumer();
    }

    protected CalWorkParticleFactory createCalWorkParticleFactory(CommonParameters commonParameters) {
        return new CalWorkParticleFactory(commonParameters);
    }

    protected DataAccountabilityTrailCrud getDaTrailCrud() {
        return new DataAccountabilityTrailCrud();
    }

    protected QuarterToParameterValueMap quarterToParameterValueMap() {
        ModelOperations<ObservingLogModel> modelOperations = ModelOperationsFactory.getObservingLogInstance(
            new ModelMetadataRetrieverPipelineInstance(pipelineTask.getPipelineInstance()));
        ObservingLogModel observingLogModel = modelOperations.retrieveModel();
        return new QuarterToParameterValueMap(observingLogModel);
    }
    
    protected PmrfOperations createPmrfOperations(CommonParameters commonParameters) {
        return new PmrfOperations();
    }
    
    protected ProducerTaskIdsStream createProducerTaskIdsStream() {
        return new ProducerTaskIdsStream();
    }

    /**
     * @return An empty subtask sequence if the data needed for this unit of 
     * work is not present.
     */
    @Override
    public void generateInputs(InputsHandler inputsHandler, PipelineTask pipelineTask,
            File workingDirectory) throws Exception {
        this.pipelineTask = pipelineTask;
        
        ModOutCadenceUowTask modOutCadenceUow = pipelineTask.uowTaskInstance();
        for (int ccdChannel : modOutCadenceUow.getChannels()) {
            Pair<Integer, Integer> moduleOutput = getModuleOutput(ccdChannel);
            generateInputsForModOut(inputsHandler, pipelineTask, workingDirectory, 
                moduleOutput.left, moduleOutput.right);
        }
    }
    
    private void generateInputsForModOut(InputsHandler inputsHandler,
        PipelineTask pipelineTask,
        File workingDirectory,
        int ccdModule, int ccdOutput) 
        throws Exception {
        
        CadenceType cadenceType = pipelineTask.getParameters(
                CadenceTypePipelineParameters.class).cadenceType();

        CalModuleParameters calModuleParameters = pipelineTask.getParameters(CalModuleParameters.class);
        PouModuleParameters pouModuleParameters = pipelineTask.getParameters(PouModuleParameters.class);
        CalCosmicRayParameters calCosmicRayParameters = pipelineTask.getParameters(CalCosmicRayParameters.class);
        CalHarmonicsIdentificationParameters harmonicsParameters = pipelineTask.getParameters(CalHarmonicsIdentificationParameters.class);
        GapFillModuleParameters gapFillParameters = pipelineTask.getParameters(GapFillModuleParameters.class);
        
        ModOutCadenceUowTask modOutCadenceUow = pipelineTask.uowTaskInstance();
        int startCadence = modOutCadenceUow.getStartCadence();
        int endCadence = modOutCadenceUow.getEndCadence();

        log.info("cadenceType: " + cadenceType);
        log.info("ccdModule: " +ccdModule);
        log.info("ccdOutput: " + ccdOutput);
        log.info("task.getStartCadence(): " + startCadence);
        log.info("task.getEndCadence(): " + endCadence);
        
        QuarterToParameterValueMap blackAlgorithmValues = quarterToParameterValueMap();
        List<String> quartersList = Arrays.asList(calModuleParameters.getBlackAlgorithmQuarters().split(","));
        List<String> values = Arrays.asList(calModuleParameters.getBlackAlgorithm().split(","));
        String blackAlgorithmValue = blackAlgorithmValues.getValue(quartersList, values, cadenceType, startCadence, endCadence);
        calModuleParameters.setBlackAlgorithm(blackAlgorithmValue);

        CommonParameters commonParameters = createCommonParameters(pipelineTask,
                cadenceType,
                startCadence, endCadence, ccdModule, ccdOutput, workingDirectory,
                calModuleParameters, pouModuleParameters, calCosmicRayParameters,
                harmonicsParameters, gapFillParameters);
        
        PmrfOperations pmrfOps = createPmrfOperations(commonParameters);
        
        Map<FsId, Pixel> fsIdToPixel = findPixels(pmrfOps, cadenceType,
            commonParameters.targetTable().getExternalId(),
            ccdModule, ccdOutput,
            cadenceType == CadenceType.LONG ? commonParameters.backgroundTargetTable().getExternalId() : -1);

        Set<Pixel> tnbPixels = Sets.newHashSet(fsIdToPixel.values());
        
        CalWorkParticleFactory workParticleFactory = 
                createCalWorkParticleFactory(commonParameters);
        //TODO:  we should depreciate the max read fsids.
        int maxChunkSize = commonParameters.moduleParametersStruct().getMaxCalibrateFsIds();

        List<List<CalWorkParticle>> workParticles = 
                workParticleFactory.create(tnbPixels, fsIdToPixel, maxChunkSize);

        InputsGroup inputsGroup = inputsHandler.createGroup();
        Set<Long> producerTaskIds = Sets.newHashSet();
        for (List<CalWorkParticle> subList : workParticles) {
            
            if (subList.isEmpty()) {
                log.warn("Work particle list is empty.");
                continue;
            }
            int firstParticleNumber = subList.get(0).particleNumber();
            int lastParticleNumber = subList.get(subList.size() - 1).particleNumber();
            inputsGroup.add(firstParticleNumber, lastParticleNumber);
            //subTaskSequence.add(firstParticleNumber, lastParticleNumber);
            for (CalWorkParticle workParticle : subList) {
                CalWorkParticle identity = workParticle.call();  //This was once called in different threads.
                if (identity == null) {
                    throw new NullPointerException("Work particle " + workParticle + " is empty.");
                }
                log.info("Generating input " + workParticle.particleNumber()+".");
                CalInputs calInputs = workParticle.calInputs();
                inputsGroup.addSubTaskInputs(calInputs);
                workParticle.clear();
                producerTaskIds.addAll(workParticle.producerTaskIds());
            }
        }

        createProducerTaskIdsStream().write(workingDirectory, producerTaskIds);
    }

    private static Map<FsId, Pixel> findPixels(PmrfOperations pmrfOps, 
        CadenceType cadenceType, int sciTargetTableId, int ccdModule, int ccdOutput,
        int bkgTargetTableId) {
        SciencePmrfTable targetPmrf = pmrfOps.getSciencePmrfTable(cadenceType,
            sciTargetTableId, ccdModule, ccdOutput);
        
        Set<Pixel> tnbPixels = Sets.newHashSetWithExpectedSize(targetPmrf.length() * 2);
        if (cadenceType == CadenceType.LONG) {
            SciencePmrfTable backgroundPmrf = pmrfOps.getBackgroundPmrfTable(bkgTargetTableId,
                ccdModule, ccdOutput);
            backgroundPmrf.addAllPixels(tnbPixels);
        }
 
        targetPmrf.addAllPixels(tnbPixels);

        Map<FsId, Pixel> fsIdToPixel = new HashMap<FsId, Pixel>();
        for (Pixel p : tnbPixels) {
            fsIdToPixel.put(p.getFsId(), p);
        }
        return fsIdToPixel;
    }
    
    @Override
    public Class<?> outputsClass() {
        return CalOutputs.class;
    }

    @Override
    public void processOutputs(PipelineTask pipelineTask,
            Iterator<AlgorithmResults> outputs) throws PipelineException {

        PeekingIterator<AlgorithmResults> resultsIt = 
            Iterators.peekingIterator(outputs);
        
        if (!resultsIt.hasNext()) {
            log.warn("No calibration outputs to process.");
            return;
        }
        File taskDir  = resultsIt.peek().getTaskDir();
        Set<Long> producerTaskIds = createProducerTaskIdsStream().read(taskDir);
        
        // Update the data accountability trail.
        DataAccountabilityTrail daTrail = new DataAccountabilityTrail(pipelineTask.getId());
        daTrail.setProducerTaskIds(producerTaskIds);
        getDaTrailCrud().create(daTrail);
        
        CalOutputsConsumer calOutputsConsumer = createCalOutputsConsumer();
        while (resultsIt.hasNext()) {
            AlgorithmResults algoResults = resultsIt.next();

            if (!algoResults.successful()) {
                log.warn("Skipping failed sub-task due to MATLAB error for sub-task "
                    + algoResults.getResultsDir());
                continue;
            }
            
            CalOutputs calOutputs = (CalOutputs) algoResults.getOutputs();
            calOutputsConsumer.storeOutputs(calOutputs, algoResults.getGroupDir());
        }
    }
}
