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
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.uow.CadenceUowTask;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;
import junit.framework.TestCase;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.xml.DOMConfigurator;

/**
 * @author tklaus
 * 
 */
public class ScienceDataMergePipelineModuleTestDriver extends TestCase {
    private static final Log log = LogFactory.getLog(ScienceDataMergePipelineModuleTestDriver.class);

    public ScienceDataMergePipelineModuleTestDriver(String name) {
        super(name);
    }

    /**
     * Test method for
     * {@link gov.nasa.kepler.etem.DataSetPackerPipelineModule#processTask()}.
     * 
     * @throws PipelineException
     */
    public void testProcessTask() {

        System.setProperty(
            ConfigurationServiceFactory.CONFIG_SERVICE_PROPERTIES_PATH_PROP,
            DIST_KEPLER_CONFIG);

        ScienceDataMergePipelineModule scienceMergeModule = new ScienceDataMergePipelineModule();

        int startCadence = 96;
        int endCadence = 191;

        long instanceId = 2;
        long taskId = 42;

        PipelineInstance pipelineInstance = new PipelineInstance();
        pipelineInstance.setId(instanceId);
        PackerParameters pipelineParameters = new PackerParameters();
        ParameterSet paramSet = new ParameterSet("packer");
        paramSet.setParameters(new BeanWrapper<Parameters>(pipelineParameters));
        pipelineInstance.putParameterSet(new ClassWrapper<Parameters>(
            pipelineParameters), paramSet);

        PipelineTask pipelineTask = new PipelineTask();
        pipelineTask.setId(taskId);
        pipelineTask.setPipelineInstance(pipelineInstance);
        pipelineTask.setUowTask(new BeanWrapper<UnitOfWorkTask>(
            new BeanWrapper<UnitOfWorkTask>(new CadenceUowTask(startCadence,
                endCadence))));

        scienceMergeModule.processTask(pipelineInstance, pipelineTask);
    }

    public static void main(String[] args) {

        DOMConfigurator.configure(Filenames.ETC + Filenames.LOG4J_CONFIG);

        log.debug("main(String[]) - start");

        junit.textui.TestRunner.run(ScienceDataMergePipelineModuleTestDriver.class);

        log.debug("main(String[]) - end");
    }
}
