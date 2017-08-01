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

package gov.nasa.kepler.systest;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.primitives.Ints.toArray;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.fc.TwoDBlackModel;
import gov.nasa.kepler.fc.twodblack.TwoDBlackOperations;
import gov.nasa.kepler.gar.requant.RequantInputs;
import gov.nasa.kepler.gar.requant.RequantOutputs;
import gov.nasa.kepler.gar.requant.RequantPipelineModule;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.MeanBlackEntry;
import gov.nasa.kepler.hibernate.gar.RequantEntry;
import gov.nasa.kepler.hibernate.gar.RequantTable;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.pi.module.MatlabMcrExecutable;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class SmokeTestRequantPipelineModule extends RequantPipelineModule {

    public static final String MODULE_NAME = "systest-requant";

    private static final Log log = LogFactory.getLog(SmokeTestRequantPipelineModule.class);

    @Override
    protected List<TwoDBlackModel> retrieveTwoDBlackModels()
        {
        TwoDBlackOperations twoDBlackOperations = new TwoDBlackOperations();

        log.info("Retrieving 2D black model");

        List<TwoDBlackModel> twoDBlackModels = new ArrayList<TwoDBlackModel>(
            FcConstants.MODULE_OUTPUTS);

        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                try {
                    twoDBlackModels.add(twoDBlackOperations.retrieveMostRecentTwoDBlackModel(
                        ccdModule, ccdOutput));
                } catch (ArrayIndexOutOfBoundsException e) {
                    log.warn("Unexpected exception retrieving 2-d black model for (" 
                        + ccdModule + "/" + ccdOutput + "): " + e);
                }
            }
        }

        return twoDBlackModels;
    }

    @Override
    protected void executeAlgorithm(PipelineTask pipelineTask,
        Persistable inputs, Persistable outputs) {

        validateMbin();

        validateInputs(inputs);

        populateOutputs(outputs);
    }

    private void validateMbin() {
        File mbinDir = new File(ConfigurationServiceFactory.getInstance()
            .getString(MatlabMcrExecutable.MODULE_EXE_BIN_DIR_PROPERTY_NAME));
        for (File file : mbinDir.listFiles()) {
            if (file.getName()
                .contains(getModuleName())) {
                return;
            }
        }

        throw new PipelineException("Expected to find an mbin "
            + getModuleName() + ", but it was not found.  mbinDir = "
            + mbinDir.getAbsolutePath());
    }

    private void validateInputs(Persistable inputs) {
        // Validate inputs.
        RequantInputs requantInputs = (RequantInputs) inputs;
        if (requantInputs.getFcConstants() == null
            || requantInputs.getGainModel() == null
            || requantInputs.getReadNoiseModel() == null
            || requantInputs.getRequantModuleParameters() == null
            || requantInputs.getScConfigParameters() == null
            || requantInputs.getTwoDBlackModels()
                .isEmpty()) {
            throw new PipelineException(
                "Unexpected empty input in smoke test requant ("
                    + getClass().getSimpleName() + ").");
        }
    }

    private void populateOutputs(Persistable outputs) {
        // Populate outputs.
        DatabaseService srcDatabaseService = DatabaseServiceFactory.getInstance();
        CompressionCrud srcCrud = new CompressionCrud(srcDatabaseService);

        log.info("Retrieving src requant table...");
        RequantTable srcRequantTable = srcCrud.retrieveAllRequantTables()
            .get(0);

        if (srcRequantTable == null) {
            throw new PipelineException("No requant table found.");
        }

        List<Integer> requantEnties = newArrayList();
        for (RequantEntry requantEntry : srcRequantTable.getRequantEntries()) {
            requantEnties.add(requantEntry.getRequantFlux());
        }

        List<Integer> meanBlackEnties = newArrayList();
        for (MeanBlackEntry meanBlackEntry : srcRequantTable.getMeanBlackEntries()) {
            meanBlackEnties.add(meanBlackEntry.getMeanBlackValue());
        }

        gov.nasa.kepler.mc.gar.RequantTable requantTableStruct = new gov.nasa.kepler.mc.gar.RequantTable();
        requantTableStruct.setRequantEntries(toArray(requantEnties));
        requantTableStruct.setMeanBlackEntries(toArray(meanBlackEnties));

        RequantOutputs requantOutputs = (RequantOutputs) outputs;
        requantOutputs.setRequantTable(requantTableStruct);
    }

}
