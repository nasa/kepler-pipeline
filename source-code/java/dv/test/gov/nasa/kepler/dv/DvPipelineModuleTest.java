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

package gov.nasa.kepler.dv;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.dv.io.DvInputs;
import gov.nasa.kepler.dv.io.DvOutputs;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.mc.pi.NumberOfElementsPerSubTask;
import gov.nasa.kepler.pi.module.AlgorithmResults;
import gov.nasa.kepler.pi.module.InputsHandler;
import gov.nasa.kepler.pi.module.MatlabSerializer;
import gov.nasa.kepler.pi.module.WorkingDirManager;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.io.File;
import java.util.Iterator;
import java.util.List;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.integration.junit4.JUnit4Mockery;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * @author Forrest Girouard
 */
@RunWith(JMock.class)
public class DvPipelineModuleTest {

    private final Mockery mockery = new JUnit4Mockery() {
        {
            setImposteriser(ClassImposteriser.INSTANCE);
        }
    };

    private static final File WORKING_DIRECTORY = new File("build/test");

    private Expectations expectations = new Expectations();

    private PipelineTask pipelineTask = mockery.mock(PipelineTask.class);

    private DvInputs dvInputs = new DvInputs();
    private List<Persistable> dvInputsList = newArrayList();

    private DvOutputs dvOutputs = mockery.mock(DvOutputs.class);

    // TODO: Assumes no sub-task dirs
    private AlgorithmResults algorithmResults = new AlgorithmResults(dvOutputs,
        WORKING_DIRECTORY, WORKING_DIRECTORY, WORKING_DIRECTORY, null);
    private List<AlgorithmResults> algorithmResultsList = ImmutableList.of(algorithmResults);

    private final DvInputsRetriever dvInputsRetriever = mockery.mock(DvInputsRetriever.class);
    private final DvOutputsStorer dvOutputsStorer = mockery.mock(DvOutputsStorer.class);
    private final MatlabSerializer matlabSerializer = mockery.mock(MatlabSerializer.class);
    private final WorkingDirManager workingDirManager = mockery.mock(WorkingDirManager.class);
    private final InputsHandler inputsHandler = mockery.mock(InputsHandler.class);

    private DvPipelineModule dvPipelineModule = new DvPipelineModule(
        dvInputsRetriever, dvOutputsStorer);

    @Before
    public void setUp() {
        dvPipelineModule.setSerializer(matlabSerializer);

        dvInputsList.add(dvInputs);
    }

    @Test
    public void testGenerateInputs() throws Exception {
        expectations = new Expectations();
        expectations.allowing(dvInputsRetriever)
            .retrieveInputs(
                expectations.with(Expectations.equal(pipelineTask)),
                expectations.with(Expectations.equal(WORKING_DIRECTORY)),
                expectations.with(Expectations.equal(inputsHandler)),
                expectations.with(Expectations.any(NumberOfElementsPerSubTask.class)));
        expectations.will(Expectations.returnValue(dvInputsList));
        mockery.checking(expectations);

        expectations = new Expectations();
        expectations.allowing(pipelineTask)
            .moduleExeName();
        expectations.will(Expectations.returnValue(DvPipelineModule.MODULE_NAME));
        expectations.allowing(pipelineTask)
            .getPipelineInstance();
        expectations.will(Expectations.returnValue(new PipelineInstance()));
        expectations.allowing(pipelineTask)
            .getId();
        expectations.will(Expectations.returnValue(42L));
        mockery.checking(expectations);
        dvPipelineModule.setPipelineTask(pipelineTask);

        expectations = new Expectations();
        expectations.allowing(workingDirManager)
            .allocateWorkingDir(
                expectations.with(Expectations.any(String.class)),
                expectations.with(Expectations.any(Long.class)),
                expectations.with(Expectations.any(Long.class)));
        expectations.will(Expectations.returnValue(WORKING_DIRECTORY));
        mockery.checking(expectations);
        dvPipelineModule.setWorkingDirManager(workingDirManager);

        dvPipelineModule.generateInputs(inputsHandler, pipelineTask,
            WORKING_DIRECTORY);
    }

    @Test
    public void testProcessOutputs() throws Exception {
        Iterator<AlgorithmResults> iterator = algorithmResultsList.iterator();

        expectations = new Expectations();
        expectations.oneOf(dvOutputsStorer)
            .storeOutputs(pipelineTask, iterator);
        mockery.checking(expectations);

        dvPipelineModule.processOutputs(pipelineTask, iterator);
    }

}
