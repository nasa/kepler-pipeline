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

package gov.nasa.kepler.pi.parameters;

import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetCrud;
import gov.nasa.kepler.pi.pipeline.PipelineConfigurator;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.persistable.TestParametersBar;
import gov.nasa.spiffy.common.persistable.TestParametersFoo;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.io.IOException;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
public class ParametersOperationsTest {
    private static final String TEST_PARAMETERS = "testParameters";
    private static final String TEST_PARAMETERS_FOO = "testParametersFoo";
    private static final String TEST_PARAMETERS_BAR = "testParametersBar";
    private static final String TEST_PARAMETERS_BAZ = "testParametersBaz";
    
    private DatabaseService databaseService = null;
    private DdlInitializer ddlInitializer = null;
    private File libraryFile = new File(Filenames.BUILD_TEST,"param-lib/param-lib.xml");
    
    private TestParameters testParameters;
    private TestParametersFoo testParametersFoo;
    private TestParametersBar testParametersBar;
    private TestParametersBaz testParametersBaz;
    
    @Before
    public void setUp() {
        databaseService = DatabaseServiceFactory.getInstance();
        ddlInitializer = databaseService.getDdlInitializer();
        ddlInitializer.initDB();
    }
    
    @After
    public void tearDown() {
        if (databaseService != null) {
            databaseService.closeCurrentSession();
            ddlInitializer.cleanDB();
        }
    }

    private void createLibrary(){
        PipelineConfigurator pc = new PipelineConfigurator();
        
        testParameters = new TestParameters();
        testParametersFoo = new TestParametersFoo();
        testParametersBar = new TestParametersBar();
        testParametersBaz = new TestParametersBaz();
        
        pc.createParamSet(TEST_PARAMETERS_FOO, testParametersFoo);
        pc.createParamSet(TEST_PARAMETERS_BAR, testParametersBar);
        pc.createParamSet(TEST_PARAMETERS_BAZ, testParametersBaz);
    }
    
    private void modifyLibrary(){
        // create a new param set to trigger LIBRARY_ONLY
        PipelineConfigurator pc = new PipelineConfigurator();
        pc.createParamSet(TEST_PARAMETERS, testParameters);

        // delete a param set to trigger CREATE
        ParameterSetCrud paramCrud = new ParameterSetCrud();
        ParameterSet fooPs = paramCrud.retrieveLatestVersionForName(TEST_PARAMETERS_FOO);
        paramCrud.delete(fooPs);
        
        // modify a param set to trigger UPDATE
        ParameterSet barPs = paramCrud.retrieveLatestVersionForName(TEST_PARAMETERS_BAR);
        TestParametersBar bar = barPs.parametersInstance();
        bar.setBar1(1.1F);
        PipelineOperations pipelineOps = new PipelineOperations();
        pipelineOps.updateParameterSet(barPs, bar, false);
    }
    
    private void exportLibrary(List<String> excludeList) throws IOException{
        FileUtil.cleanDir(libraryFile.getParentFile());
        ParametersOperations paramOps = new ParametersOperations();
        paramOps.exportParameterLibrary(libraryFile.getAbsolutePath(), excludeList, false);
    }
    
    @Test
    public void testRoundTrip() throws Exception{
        try {
            ParametersOperations paramOps = new ParametersOperations();

            databaseService.beginTransaction();

            // create a param library
            createLibrary();
            
            databaseService.commitTransaction();

            databaseService.beginTransaction();
            
            // export the library
            exportLibrary(null);
            
            // make some changes to the library
            modifyLibrary();
            
            databaseService.commitTransaction();

            databaseService.beginTransaction();

            // import the library
            List<ParameterSetDescriptor> actualResults = paramOps.importParameterLibrary(libraryFile.getAbsolutePath(), null, false);
            
            databaseService.commitTransaction();

            // verify results
            ReflectionEquals comparator = new ReflectionEquals();

            List<ParameterSetDescriptor> expectedResults = new LinkedList<ParameterSetDescriptor>();
            expectedResults.add(new ParameterSetDescriptor(TEST_PARAMETERS_BAR, TestParametersBar.class.getName(), 
                ParameterSetDescriptor.State.UPDATE));
            expectedResults.add(new ParameterSetDescriptor(TEST_PARAMETERS_BAZ, TestParametersBaz.class.getName(), 
                ParameterSetDescriptor.State.SAME));
            expectedResults.add(new ParameterSetDescriptor(TEST_PARAMETERS_FOO, TestParametersFoo.class.getName(), 
                ParameterSetDescriptor.State.CREATE));
            expectedResults.add(new ParameterSetDescriptor(TEST_PARAMETERS, TestParameters.class.getName(), 
                ParameterSetDescriptor.State.LIBRARY_ONLY));
            
            comparator.excludeField(".*\\.libraryProps");
            comparator.excludeField(".*\\.fileProps");
            comparator.excludeField(".*\\.libraryParamSet");
            comparator.excludeField(".*\\.importedParamsBean");
            comparator.assertEquals("results", expectedResults, actualResults);
            
            ParameterSetCrud paramCrud = new ParameterSetCrud();
            
            comparator.assertEquals("TEST_PARAMETERS_BAR", new BeanWrapper<Parameters>(testParametersBar), 
                paramCrud.retrieveLatestVersionForName(TEST_PARAMETERS_BAR).getParameters());
            comparator.assertEquals("TEST_PARAMETERS_BAZ", new BeanWrapper<Parameters>(testParametersBaz), 
                paramCrud.retrieveLatestVersionForName(TEST_PARAMETERS_BAZ).getParameters());
            comparator.assertEquals("TEST_PARAMETERS_FOO", new BeanWrapper<Parameters>(testParametersFoo), 
                paramCrud.retrieveLatestVersionForName(TEST_PARAMETERS_FOO).getParameters());
            comparator.assertEquals("TEST_PARAMETERS", new BeanWrapper<Parameters>(testParameters), 
                paramCrud.retrieveLatestVersionForName(TEST_PARAMETERS).getParameters());

        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }
    
    @Test
    public void testRoundTripWithDryRun() throws Exception{
        try {
            ParametersOperations paramOps = new ParametersOperations();

            databaseService.beginTransaction();

            // create a param library
            createLibrary();
            
            databaseService.commitTransaction();

            databaseService.beginTransaction();
            
            // export the library
            exportLibrary(null);
            
            // make some changes to the library
            modifyLibrary();
            
            databaseService.commitTransaction();

            databaseService.beginTransaction();

            // import the library
            List<ParameterSetDescriptor> actualResults = paramOps.importParameterLibrary(libraryFile.getAbsolutePath(), null, true);
            
            databaseService.commitTransaction();

            // verify results
            ReflectionEquals comparator = new ReflectionEquals();
            
            List<ParameterSetDescriptor> expectedResults = new LinkedList<ParameterSetDescriptor>();
            expectedResults.add(new ParameterSetDescriptor(TEST_PARAMETERS_BAR, TestParametersBar.class.getName(), 
                ParameterSetDescriptor.State.UPDATE));
            expectedResults.add(new ParameterSetDescriptor(TEST_PARAMETERS_BAZ, TestParametersBaz.class.getName(), 
                ParameterSetDescriptor.State.SAME));
            expectedResults.add(new ParameterSetDescriptor(TEST_PARAMETERS_FOO, TestParametersFoo.class.getName(), 
                ParameterSetDescriptor.State.CREATE));
            expectedResults.add(new ParameterSetDescriptor(TEST_PARAMETERS, TestParameters.class.getName(), 
                ParameterSetDescriptor.State.LIBRARY_ONLY));

            comparator.excludeField(".*\\.libraryProps");
            comparator.excludeField(".*\\.fileProps");
            comparator.excludeField(".*\\.libraryParamSet");
            comparator.excludeField(".*\\.importedParamsBean");
            comparator.assertEquals("results", expectedResults, actualResults);
            
            ParameterSetCrud paramCrud = new ParameterSetCrud();
            
            TestParametersBar modifiedBar = new TestParametersBar();
            modifiedBar.setBar1(1.1F);
            comparator.assertEquals("TEST_PARAMETERS_BAR", new BeanWrapper<Parameters>(modifiedBar), 
                paramCrud.retrieveLatestVersionForName(TEST_PARAMETERS_BAR).getParameters());
            comparator.assertEquals("TEST_PARAMETERS_BAZ", new BeanWrapper<Parameters>(testParametersBaz), 
                paramCrud.retrieveLatestVersionForName(TEST_PARAMETERS_BAZ).getParameters());
            comparator.assertEquals("TEST_PARAMETERS", new BeanWrapper<Parameters>(testParameters), 
                paramCrud.retrieveLatestVersionForName(TEST_PARAMETERS).getParameters());
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }
    
    @Test
    public void testExportWithExclusions() throws Exception{
        try {
            ParametersOperations paramOps = new ParametersOperations();

            databaseService.beginTransaction();

            // create a param library
            createLibrary();
            
            databaseService.commitTransaction();

            databaseService.beginTransaction();
            
            // export the library
            List<String> excludeList = new LinkedList<String>();
            excludeList.add(TEST_PARAMETERS_FOO);
            excludeList.add(TEST_PARAMETERS_BAZ);
            exportLibrary(excludeList);
            
            databaseService.commitTransaction();

            databaseService.beginTransaction();

            // import the library
            List<ParameterSetDescriptor> actualResults = paramOps.importParameterLibrary(libraryFile.getAbsolutePath(), null, true);
            
            databaseService.commitTransaction();

            // verify results
            ReflectionEquals comparator = new ReflectionEquals();

            List<ParameterSetDescriptor> expectedResults = new LinkedList<ParameterSetDescriptor>();
            expectedResults.add(new ParameterSetDescriptor(TEST_PARAMETERS_BAR, TestParametersBar.class.getName(), 
                ParameterSetDescriptor.State.SAME));
            expectedResults.add(new ParameterSetDescriptor(TEST_PARAMETERS_BAZ, TestParametersBaz.class.getName(), 
                ParameterSetDescriptor.State.LIBRARY_ONLY));
            expectedResults.add(new ParameterSetDescriptor(TEST_PARAMETERS_FOO, TestParametersFoo.class.getName(), 
                ParameterSetDescriptor.State.LIBRARY_ONLY));
            
            comparator.excludeField(".*\\.libraryProps");
            comparator.excludeField(".*\\.fileProps");
            comparator.excludeField(".*\\.libraryParamSet");
            comparator.excludeField(".*\\.importedParamsBean");
            comparator.assertEquals("results", expectedResults, actualResults);
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test(expected=IllegalArgumentException.class)
    public void testExportToInvalidExistingFile() throws Exception{
        try {
            ParametersOperations paramOps = new ParametersOperations();

            databaseService.beginTransaction();

            // create a param library
            createLibrary();
            
            databaseService.commitTransaction();

            databaseService.beginTransaction();
            
            // export the library
            File invalidExportDir = new File(Filenames.BUILD_TEST,"invalid-param-lib");
            FileUtils.forceMkdir(invalidExportDir);
            // should throw IllegalArgumentException
            paramOps.exportParameterLibrary(invalidExportDir.getAbsolutePath(), null, false);
            
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }
    
    @Test(expected = NumberFormatException.class)
    public void testImportFloatIntoIntShouldFail() throws Exception {
        try {
            databaseService.beginTransaction();
            ParametersOperations paramOps = new ParametersOperations();
            paramOps.importParameterLibrary(
                new File(SocEnvVars.getLocalTestDataDir()
                    + "/pi/parameters/param-lib-with-float-smearEndCol.xml"),
                null, false);
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }
}