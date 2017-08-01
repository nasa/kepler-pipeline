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

package gov.nasa.kepler.gar.requant;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.TwoDBlackModel;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fc.twodblack.TwoDBlackOperations;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.MeanBlackEntry;
import gov.nasa.kepler.hibernate.gar.RequantEntry;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.gar.RequantTable;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.pi.module.StandardMatlabPipelineModule;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class RequantPipelineModule extends StandardMatlabPipelineModule {

    private static final Log log = LogFactory.getLog(RequantPipelineModule.class);

    public static final String MODULE_NAME = "requantization";

    private CompressionCrud compressionCrud = new CompressionCrud();
    private GainOperations gainOperations = new GainOperations();
    private ReadNoiseOperations readNoiseOperations = new ReadNoiseOperations();
    private TwoDBlackOperations twoDBlackOperations = new TwoDBlackOperations();

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
        List<Class<? extends Parameters>> requiredParameters = new ArrayList<Class<? extends Parameters>>();
        requiredParameters.add(RequantModuleParameters.class);
        requiredParameters.add(PlannedSpacecraftConfigParameters.class);

        return requiredParameters;
    }

    @Override
    protected Persistable createInputs() {
        return new RequantInputs();
    }

    @Override
    protected void retrieveInputs(Persistable inputs) {
        RequantInputs requantInputs = (RequantInputs) inputs;

        requantInputs.setRequantModuleParameters(getRequantModuleParameters());
        requantInputs.setScConfigParameters(getScConfigParameters());
        requantInputs.setGainModel(retrieveGainModel());
        requantInputs.setReadNoiseModel(retrieveReadNoiseModel());
        requantInputs.setTwoDBlackModels(retrieveTwoDBlackModels());
    }

    /**
     * Returns this task's module parameters.
     */
    private RequantModuleParameters getRequantModuleParameters() {
        return pipelineTask.getParameters(RequantModuleParameters.class);
    }

    /**
     * Returns this task's spacecraft configuration parameters.
     */
    private PlannedSpacecraftConfigParameters getScConfigParameters() {
        return pipelineTask.getParameters(PlannedSpacecraftConfigParameters.class);
    }

    private GainModel retrieveGainModel() {
        log.info("Retrieving gain model");

        return gainOperations.retrieveMostRecentGainModel();
    }

    private ReadNoiseModel retrieveReadNoiseModel() {
        log.info("Retrieving read noise model");

        return readNoiseOperations.retrieveMostRecentReadNoiseModel();
    }

    protected List<TwoDBlackModel> retrieveTwoDBlackModels() {
        log.info("Retrieving 2D black model");

        List<TwoDBlackModel> twoDBlackModels = new ArrayList<TwoDBlackModel>(
            FcConstants.MODULE_OUTPUTS);

        for (int ccdModule : FcConstants.modulesList) {
            log.info("Retrieving 2D black models for module " + ccdModule);
            for (int ccdOutput : FcConstants.outputsList) {
                twoDBlackModels.add(twoDBlackOperations.retrieveMostRecentTwoDBlackModel(
                    ccdModule, ccdOutput));
            }
        }

        return twoDBlackModels;
    }

    @Override
    protected Persistable createOutputs() {
        return new RequantOutputs();
    }

    @Override
    protected void storeOutputs(Persistable outputs) {
        RequantOutputs requantOutputs = (RequantOutputs) outputs;

        RequantTable srcRequantTable = requantOutputs.getRequantTable();
        int[] srcRequantEntries = srcRequantTable.getRequantEntries();
        int[] srcMeanBlackEntries = srcRequantTable.getMeanBlackEntries();

        if (srcRequantEntries.length == 0) {
            throw new ModuleFatalProcessingException(
                "No requantEntries were generated");
        }
        if (srcMeanBlackEntries.length == 0) {
            throw new ModuleFatalProcessingException(
                "No meanBlackEntries were generated");
        }

        List<RequantEntry> destRequantEntries = new ArrayList<RequantEntry>(
            srcRequantEntries.length);
        for (int entry : srcRequantEntries) {
            destRequantEntries.add(new RequantEntry(entry));
        }
        List<MeanBlackEntry> destMeanBlackEntries = new ArrayList<MeanBlackEntry>(
            srcMeanBlackEntries.length);
        for (int entry : srcMeanBlackEntries) {
            destMeanBlackEntries.add(new MeanBlackEntry(entry));
        }

        gov.nasa.kepler.hibernate.gar.RequantTable destRequantTable = new gov.nasa.kepler.hibernate.gar.RequantTable();
        destRequantTable.setRequantEntries(destRequantEntries);
        destRequantTable.setMeanBlackEntries(destMeanBlackEntries);
        destRequantTable.setPipelineTask(pipelineTask);

        compressionCrud.createRequantTable(destRequantTable);
    }

    /**
     * Sets the {@link CompressionCrud} object during testing.
     */
    void setCompressionCrud(CompressionCrud compressionCrud) {
        this.compressionCrud = compressionCrud;
    }

    /**
     * Sets the {@link GainOperations} object during testing.
     */
    void setGainOperations(GainOperations gainOperations) {
        this.gainOperations = gainOperations;
    }

    /**
     * Sets the {@link ReadNoiseOperations} object during testing.
     */
    void setReadNoiseOperations(ReadNoiseOperations readNoiseOperations) {
        this.readNoiseOperations = readNoiseOperations;
    }

    /**
     * Sets the {@link TwoDBlackOperations} object during testing.
     */
    void setTwoDBlackOperations(TwoDBlackOperations twoDBlackOperations) {
        this.twoDBlackOperations = twoDBlackOperations;
    }

    /**
     * Sets the {@link PipelineTask} object during testing.
     */
    public void setPipelineTask(PipelineTask pipelineTask) {
        this.pipelineTask = pipelineTask;
    }
}
