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

import static gov.nasa.kepler.common.FilenameConstants.DIST_ETC;
import gov.nasa.kepler.common.pi.PlannedPhotometerConfigParameters;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Map;

import junit.framework.TestCase;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.xml.DOMConfigurator;
import org.junit.Test;

/**
 * @author tklaus
 * 
 */
public class DataSetPackerPipelineModuleTestDriver extends TestCase {
    private static final Log log = LogFactory.getLog(DataSetPackerPipelineModuleTestDriver.class);

    /**
     * Test method for
     * {@link gov.nasa.kepler.etem.DataSetPackerPipelineModule#processTask()}.
     * 
     * @throws PipelineException
     */
    @Test
    public void testProcessTask() {

        System.setProperty(
            ConfigurationServiceFactory.CONFIG_SERVICE_PROPERTIES_PATH_PROP,
            DIST_ETC + "/kepler.properties");

        DataSetPackerPipelineModule packerModule = new DataSetPackerPipelineModule();

        long instanceId = 2;
        long taskId = 42;

        PipelineInstance pipelineInstance = new PipelineInstance();
        pipelineInstance.setId(instanceId);
        Map<ClassWrapper<Parameters>, ParameterSet> paramSetMap = pipelineInstance.getPipelineParameterSets();

        // data gen params.
        DataGenParameters dataGenParams = new DataGenParameters();
        dataGenParams.setCadenceZeroDate("24-Jun-2010 12:00:00");
        dataGenParams.setDataGenOutputPath("/path/to/etem2/auto/gsit5a");
        dataGenParams.setDataSetNames("p1,p2,p3,p4,p5");

        ParameterSet dataGenParamSet = new ParameterSet("dataGen");
        dataGenParamSet.setParameters(new BeanWrapper<Parameters>(dataGenParams));
        paramSetMap.put(new ClassWrapper<Parameters>(dataGenParams),
            dataGenParamSet);

        // a-m2 params.
        PlannedPhotometerConfigParameters photometerParams = new PlannedPhotometerConfigParameters(
            120, 120, 120, 120, 120, 121, 120);

        ParameterSet photometerParamSet = new ParameterSet("photometer");
        photometerParamSet.setParameters(new BeanWrapper<Parameters>(
            photometerParams));
        paramSetMap.put(new ClassWrapper<Parameters>(photometerParams),
            photometerParamSet);

        PackerParameters p1PackerParameters = new PackerParameters();
        p1PackerParameters.setDataSetName("p1");
        p1PackerParameters.setLongCadenceCount(1413);
        p1PackerParameters.setStartDate("27-Jul-2010 8:09:11.52000");
        p1PackerParameters.setEtemInputsFile("ETEM2_inputs_gsit5a_base");
        p1PackerParameters.setIncludeFfi(false);
//        p1PackerParameters.setVirtualChannelNumber(14);
//        p1PackerParameters.setVcduCounterStart(0);

        ParameterSet packerParamSet = new ParameterSet("packer");
        packerParamSet.setParameters(new BeanWrapper<Parameters>(
            p1PackerParameters));
        paramSetMap.put(new ClassWrapper<Parameters>(p1PackerParameters),
            packerParamSet);

        PlannedSpacecraftConfigParameters spacecraftConfigParameters = new PlannedSpacecraftConfigParameters();

        ParameterSet scParamSet = new ParameterSet("sc");
        scParamSet.setParameters(new BeanWrapper<Parameters>(
            spacecraftConfigParameters));
        paramSetMap.put(
            new ClassWrapper<Parameters>(spacecraftConfigParameters),
            scParamSet);

        PipelineTask pipelineTask = new PipelineTask(pipelineInstance,
            new PipelineDefinitionNode(), new PipelineInstanceNode());
        pipelineTask.setId(taskId);
        pipelineTask.setUowTask(new BeanWrapper<UnitOfWorkTask>(
            new BeanWrapper<UnitOfWorkTask>(new SingleUowTask())));

        packerModule.processTask(pipelineInstance, pipelineTask);
    }

    public static void main(String[] args) {

        DOMConfigurator.configure(Filenames.ETC + Filenames.LOG4J_CONFIG);

        log.debug("main(String[]) - start");

        junit.textui.TestRunner.run(DataSetPackerPipelineModuleTestDriver.class);

        log.debug("main(String[]) - end");
    }
}
