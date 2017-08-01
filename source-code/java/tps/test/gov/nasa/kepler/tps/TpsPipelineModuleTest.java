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

package gov.nasa.kepler.tps;

import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.mc.ProducerTaskIdsStream;
import gov.nasa.kepler.pi.module.AlgorithmResults;
import gov.nasa.kepler.pi.module.InputsHandler;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.persistable.BinaryPersistableInputStream;
import gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.List;

import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.integration.junit4.JUnit4Mockery;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.ImmutableList;

/**
 * @author Sean McCauliff
 * 
 */
@RunWith(JMock.class)
public class TpsPipelineModuleTest extends AbstractTpsPipelineModuleTest {

    private Mockery mockery;
    private final File testRoot = new File(Filenames.BUILD_TEST,
        "TpsPipelineModuleTest");

    @Before
    public void setUp() throws Exception {
        mockery = new JUnit4Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);

        FileUtil.cleanDir(testRoot);
        FileUtil.mkdirs(testRoot);
    }

    @After
    public void tearDown() throws Exception {
        FileUtil.cleanDir(testRoot);
    }

    @Override
    protected Mockery getMockery() {
        return mockery;
    }

    @Test
    public void tpsPipelineModuleUnitTest() throws Exception {
        final ProducerTaskIdsStream ptis = createProducerTaskIdsStream();
        TpsPipelineModule tpsPipelineModule = new TpsPipelineModule() {
            @Override
            protected ProducerTaskIdsStream createProducerTaskIdsStream() {
                return ptis;
            }
        };

        tpsPipelineModule.setDaAcctCrud(createDaTrailCrud());
        tpsPipelineModule.setCelestialObjectOperations(createCelestialObjectOperations());
        tpsPipelineModule.setLogCrud(createLogCrud());
        tpsPipelineModule.setMjdToCadence(createMjdToCadence());
        tpsPipelineModule.setRollTimeOperations(createRollTimeOperations());
        tpsPipelineModule.setTargetCrud(createTargetCrud());
        tpsPipelineModule.setTargetSelectionCrud(createTargetSelectionCrud());
        tpsPipelineModule.setTpsCrud(createTpsCrud());
        tpsPipelineModule.setPdcCrud(createPdcCrud());
        tpsPipelineModule.setTransitOps(createTransitOps());
        

        FileStoreClientFactory.setInstance(createFileStoreClient());
        AlertServiceFactory.setInstance(createAlertService());

        @SuppressWarnings("serial")
        InputsHandler inputsHandler = new InputsHandler() {
            @Override
            public void addSubTaskInputs(Persistable p) {
                TpsInputs tpsInputs = (TpsInputs) p;
                writeInputs(tpsInputs);
            }
        };
        
        tpsPipelineModule.generateInputs(inputsHandler, getPipelineTask(), testRoot);
        
        TpsOutputs tpsOutputs = new TpsOutputs();
        initTpsOutputs(tpsOutputs);
        
        writeAndReadOutputs(tpsOutputs);
        AlgorithmResults algorithmResult = 
                new AlgorithmResults(tpsOutputs, testRoot, testRoot, testRoot, null);
        List<AlgorithmResults> algoResults = ImmutableList.of(algorithmResult);
        tpsPipelineModule.processOutputs(getPipelineTask(), algoResults.iterator());

    }

    private void writeInputs(TpsInputs tpsInputs) {
        try {
            File tpsInputsFile = new File(testRoot, "tpsInputs.bin");
            DataOutputStream dout = new DataOutputStream(
                new BufferedOutputStream(new FileOutputStream(tpsInputsFile)));
            BinaryPersistableOutputStream pout = new BinaryPersistableOutputStream(dout);
            pout.save(tpsInputs);
            dout.close();
        } catch (Exception ioe) {
            throw new PipelineException(ioe);
        }
    }

    private void writeAndReadOutputs(TpsOutputs tpsOutputs) {
        try {
            File tpsOutputsFile = new File(testRoot, "tpsOutputs.bin");
            DataOutputStream dout = new DataOutputStream(
                new BufferedOutputStream(new FileOutputStream(tpsOutputsFile)));
            BinaryPersistableOutputStream pout = new BinaryPersistableOutputStream(
                dout);
            pout.save(tpsOutputs);
            dout.close();

            DataInputStream din = new DataInputStream(new BufferedInputStream(
                new FileInputStream(tpsOutputsFile)));
            BinaryPersistableInputStream pin = new BinaryPersistableInputStream(
                din);
            TpsOutputs loadedOutputs = new TpsOutputs();
            pin.load(loadedOutputs);
            din.close();
        } catch (Exception ioe) {
            throw new PipelineException(ioe);
        }
    }

}
