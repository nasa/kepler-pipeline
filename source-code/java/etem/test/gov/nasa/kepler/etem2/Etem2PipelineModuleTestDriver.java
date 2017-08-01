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

package gov.nasa.kepler.etem2;

import static gov.nasa.kepler.common.FilenameConstants.DIST_KEPLER_CONFIG;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.pi.PipelineException;
import junit.framework.TestCase;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.xml.DOMConfigurator;

/**
 * @author tklaus
 * 
 */
public class Etem2PipelineModuleTestDriver extends TestCase {
    private static final Log log = LogFactory.getLog(Etem2PipelineModuleTestDriver.class);

    public Etem2PipelineModuleTestDriver(String name) {
        super(name);
    }

    /**
     * Test method for
     * {@link gov.nasa.kepler.etem.ETEMPipelineModule#processTask(long, gov.nasa.kepler.jdo.pi.UOWTask, gov.nasa.kepler.jdo.pi.PipelineModuleDefinition)}.
     * 
     * @throws PipelineException
     */
    public void testProcessTask() {

        System.setProperty(
            ConfigurationServiceFactory.CONFIG_SERVICE_PROPERTIES_PATH_PROP,
            DIST_KEPLER_CONFIG);

        Etem2PipelineModule etemModule = new Etem2PipelineModule();

        int ccdModule = 2;
        int ccdOutput = 3;
        long instanceId = 2;
        long taskId = 42;

        PipelineInstance pipelineInstance = new PipelineInstance();
        pipelineInstance.setId(instanceId);

        PipelineTask pipelineTask = new PipelineTask();
        pipelineTask.setId(taskId);
        pipelineTask.setPipelineInstance(pipelineInstance);
        pipelineTask.setUowTask(new BeanWrapper<UnitOfWorkTask>(
            new ModOutUowTask(ccdModule, ccdOutput)));

        // PipelineDefinitionNode pipelineNode = new PipelineDefinitionNode();
        // pipelineNode.setPipelineModuleDefinition(moduleDef);
        // pipelineTask.setPipelineNode(pipelineNode);

        etemModule.processTask(pipelineInstance, pipelineTask);
        // etemModule.processTask(42 , unitOfWork, moduleDef );
    }

    public static void main(String[] args) {

        DOMConfigurator.configure(Filenames.ETC + Filenames.LOG4J_CONFIG);

        log.debug("main(String[]) - start");

        junit.textui.TestRunner.run(Etem2PipelineModuleTestDriver.class);

        log.debug("main(String[]) - end");
    }
}
