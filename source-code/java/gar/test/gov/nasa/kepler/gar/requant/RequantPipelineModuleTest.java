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

import static com.google.common.collect.Lists.newArrayList;
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.TwoDBlackModel;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fc.twodblack.TwoDBlackOperations;
import gov.nasa.kepler.gar.AbstractGarPipelineModuleTest;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.MeanBlackEntry;
import gov.nasa.kepler.hibernate.gar.RequantEntry;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.mc.gar.RequantTable;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.List;

import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * Tests the {@link RequantPipelineModule}.
 * 
 * @author Bill Wohler
 */
public class RequantPipelineModuleTest extends AbstractGarPipelineModuleTest {

    private RequantPipelineModule pipelineModule;
    private PipelineTask pipelineTask;

    private CompressionCrud compressionCrud = mock(CompressionCrud.class);
    private GainOperations gainOperations = mock(GainOperations.class);
    private ReadNoiseOperations readNoiseOperations = mock(ReadNoiseOperations.class);
    private TwoDBlackOperations twoDBlackOperations = mock(TwoDBlackOperations.class);

    @Test
    public void testGetModuleName() {
        assertEquals("requantization",
            new RequantPipelineModule().getModuleName());
    }

    @Test
    public void taskType() {
        assertEquals(SingleUowTask.class,
            new RequantPipelineModule().unitOfWorkTaskType());
    }

    @Test
    public void testRequiredParameters() {
        assertEquals(ImmutableList.of(RequantModuleParameters.class,
            PlannedSpacecraftConfigParameters.class),
            new RequantPipelineModule().requiredParameters());
    }

    private void populateObjects() {
        pipelineModule = new RequantPipelineModule();
        List<Parameters> moduleParameters = newArrayList();
        moduleParameters.add(new RequantModuleParameters());
        List<Parameters> pipelineParameters = newArrayList();
        pipelineParameters.add(new PlannedSpacecraftConfigParameters());
        pipelineTask = createPipelineTask(0, new SingleUowTask(),
            pipelineParameters, moduleParameters);
        pipelineModule.setPipelineTask(pipelineTask);
        pipelineModule.setCompressionCrud(compressionCrud);
        pipelineModule.setGainOperations(gainOperations);
        pipelineModule.setReadNoiseOperations(readNoiseOperations);
        pipelineModule.setTwoDBlackOperations(twoDBlackOperations);
    }

    @Test
    public void retrieveInputs() throws Exception {
        populateObjects();

        RequantInputs expectedRequantInputs = new RequantInputs();
        expectedRequantInputs.setRequantModuleParameters(pipelineTask.getParameters(RequantModuleParameters.class));
        expectedRequantInputs.setScConfigParameters(pipelineTask.getParameters(PlannedSpacecraftConfigParameters.class));
        expectedRequantInputs.setGainModel(createGainModel());
        expectedRequantInputs.setReadNoiseModel(createReadNoiseModel());
        expectedRequantInputs.setTwoDBlackModels(createTwoDBlackModels());

        RequantInputs actualRequantInputs = (RequantInputs) pipelineModule.createInputs();
        pipelineModule.retrieveInputs(actualRequantInputs);

        ReflectionEquals reflectEquals = new ReflectionEquals();
        reflectEquals.assertEquals(expectedRequantInputs, actualRequantInputs);
    }

    private GainModel createGainModel() {
        final GainModel gainModel = new GainModel();

        allowing(gainOperations).retrieveMostRecentGainModel();
        will(returnValue(gainModel));

        return gainModel;
    }

    private ReadNoiseModel createReadNoiseModel() {
        final ReadNoiseModel readNoiseModel = new ReadNoiseModel();

        allowing(readNoiseOperations).retrieveMostRecentReadNoiseModel();
        will(returnValue(readNoiseModel));

        return readNoiseModel;
    }

    private List<TwoDBlackModel> createTwoDBlackModels()
        {

        final List<TwoDBlackModel> twoDBlackModels = new ArrayList<TwoDBlackModel>(
            FcConstants.MODULE_OUTPUTS);
        for (int i = 0; i < FcConstants.MODULE_OUTPUTS; i++) {
            twoDBlackModels.add(new TwoDBlackModel());
        }

        int i = 0;
        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                allowing(twoDBlackOperations).retrieveMostRecentTwoDBlackModel(
                    ccdModule, ccdOutput);
                will(returnValue(twoDBlackModels.get(i++)));
            }
        }

        return twoDBlackModels;
    }

    @Test
    public void storeOutputs() {
        populateObjects();

        RequantOutputs outputs = (RequantOutputs) pipelineModule.createOutputs();
        outputs.setRequantTable(createRequantTable());

        pipelineModule.storeOutputs(outputs);
    }

    private RequantTable createRequantTable() {
        final TestingRequantTable destRequantTable = new TestingRequantTable();
        destRequantTable.setPipelineTask(pipelineTask);

        List<RequantEntry> requantEntries = new ArrayList<RequantEntry>(
            FcConstants.REQUANT_TABLE_LENGTH);
        for (int i = 0; i < FcConstants.REQUANT_TABLE_LENGTH; i++) {
            requantEntries.add(new RequantEntry(i));
        }
        destRequantTable.setRequantEntries(requantEntries);

        List<MeanBlackEntry> meanBlackEntries = new ArrayList<MeanBlackEntry>(
            FcConstants.MODULE_OUTPUTS);
        for (int i = 0; i < FcConstants.MODULE_OUTPUTS; i++) {
            meanBlackEntries.add(new MeanBlackEntry(i));
        }
        destRequantTable.setMeanBlackEntries(meanBlackEntries);

        oneOf(compressionCrud).createRequantTable(destRequantTable);

        RequantTable requantTable = new RequantTable();
        requantTable.setRequantEntries(destRequantTable.getRequantFluxes());
        requantTable.setMeanBlackEntries(destRequantTable.getMeanBlackValues());

        return requantTable;
    }

    /**
     * Add more stringent equals method for testing only.
     * 
     * @author Bill Wohler
     */
    private static class TestingRequantTable extends
        gov.nasa.kepler.hibernate.gar.RequantTable {

        @Override
        public int hashCode() {
            final int prime = 31;
            int result = super.hashCode();
            result = prime
                * result
                + (getMeanBlackEntries() == null ? 0
                    : getMeanBlackEntries().hashCode());
            result = prime
                * result
                + (getRequantEntries() == null ? 0
                    : getRequantEntries().hashCode());
            return result;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj) {
                return true;
            }
            if (!(obj instanceof gov.nasa.kepler.hibernate.gar.RequantTable)) {
                return false;
            }
            gov.nasa.kepler.hibernate.gar.RequantTable other = (gov.nasa.kepler.hibernate.gar.RequantTable) obj;
            if (getMeanBlackEntries() == null) {
                if (other.getMeanBlackEntries() != null) {
                    return false;
                }
            } else if (!getMeanBlackEntries().equals(
                other.getMeanBlackEntries())) {
                return false;
            }
            if (getRequantEntries() == null) {
                if (other.getRequantEntries() != null) {
                    return false;
                }
            } else if (!getRequantEntries().equals(other.getRequantEntries())) {
                return false;
            }
            return true;
        }
    }
}
