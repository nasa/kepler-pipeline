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

package gov.nasa.kepler.systest.tad;

import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.TargetListSetValidator;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.ops.seed.CommonPipelineSeedData;
import gov.nasa.kepler.ops.seed.TadQuarterlyPipelineSeedData;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class TadTriggerValidatorTest extends JMockTest {

    private TargetListSetValidator mockTlsValidator;
    private List<TargetListSet> expectedTargetListSets;
    private DatabaseService databaseService;

    @Before
    public void setUp() throws Exception {
        System.setProperty(
            ConfigurationServiceFactory.CONFIG_SERVICE_PROPERTIES_PATH_PROP,
            "etc/unit-test-kepler.properties");

        DefaultProperties.setPropsForUnitTest();
        TestUtils.setUpDatabase(DatabaseServiceFactory.getInstance());
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(DatabaseServiceFactory.getInstance());

        System.setProperty(
            ConfigurationServiceFactory.CONFIG_SERVICE_PROPERTIES_PATH_PROP,
            "etc/kepler.properties");
    }

    @Test
    public void testValidate() {
        populateObjects();

        oneOf(mockTlsValidator).validate(expectedTargetListSets);

        databaseService.closeCurrentSession();
        TadTriggerValidator validator = new TadTriggerValidator(
            mockTlsValidator);
        validator.validate(TadQuarterlyPipelineSeedData.TAD_TRIGGER_NAME);
    }

    private void populateObjects() {
        databaseService = DatabaseServiceFactory.getInstance();

        createTargetListSets();

        createPipelineSeedData();

        mockTlsValidator = mock(TargetListSetValidator.class);
    }

    private void createTargetListSets() {
        databaseService.beginTransaction();
        TargetListSet lcTls = new TargetListSet(TadQuarterlyPipelineSeedData.LC);
        lcTls.setType(TargetType.LONG_CADENCE);

        TargetListSet sc1Tls = new TargetListSet(
            TadQuarterlyPipelineSeedData.SC1);
        sc1Tls.setType(TargetType.SHORT_CADENCE);

        TargetListSet sc2Tls = new TargetListSet(
            TadQuarterlyPipelineSeedData.SC2);
        sc2Tls.setType(TargetType.SHORT_CADENCE);

        TargetListSet sc3Tls = new TargetListSet(
            TadQuarterlyPipelineSeedData.SC3);
        sc3Tls.setType(TargetType.SHORT_CADENCE);

        TargetListSet rpTls = new TargetListSet(TadQuarterlyPipelineSeedData.RP);
        rpTls.setType(TargetType.REFERENCE_PIXEL);

        expectedTargetListSets = ImmutableList.of(lcTls, sc1Tls, sc2Tls, sc3Tls, rpTls);

        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        targetSelectionCrud.create(lcTls);
        targetSelectionCrud.create(sc1Tls);
        targetSelectionCrud.create(sc2Tls);
        targetSelectionCrud.create(sc3Tls);
        targetSelectionCrud.create(rpTls);
        databaseService.commitTransaction();
    }

    private void createPipelineSeedData() {
        databaseService.beginTransaction();
        CommonPipelineSeedData commonSeed = new CommonPipelineSeedData();
        commonSeed.loadSeedData();
        databaseService.commitTransaction();

        databaseService.beginTransaction();
        TadQuarterlyPipelineSeedData tadSeedData = new TadQuarterlyPipelineSeedData();
        tadSeedData.loadSeedData();
        databaseService.commitTransaction();
    }

    @Test(expected = IllegalArgumentException.class)
    public void testInvalidTargetListSetName() {
        populateObjects();

        // Set an invalid tls name.
        databaseService.beginTransaction();
        ParameterSetCrud parameterSetCrud = new ParameterSetCrud();
        ParameterSet paramSet = parameterSetCrud.retrieveLatestVersionForName(TadQuarterlyPipelineSeedData.TAD_PARAMETERS_LC);
        TadParameters tadParameters = paramSet.parametersInstance();
        tadParameters.setTargetListSetName("foo");

        PipelineOperations pipelineOperations = new PipelineOperations();
        pipelineOperations.updateParameterSet(paramSet, tadParameters, false);
        databaseService.commitTransaction();

        databaseService.closeCurrentSession();
        TadTriggerValidator validator = new TadTriggerValidator(
            mockTlsValidator);
        validator.validate(TadQuarterlyPipelineSeedData.TAD_TRIGGER_NAME);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testInvalidAssocLcTlsName() {
        populateObjects();

        // Set an invalid assoc lc tls name.
        databaseService.beginTransaction();
        ParameterSetCrud parameterSetCrud = new ParameterSetCrud();
        ParameterSet paramSet = parameterSetCrud.retrieveLatestVersionForName(TadQuarterlyPipelineSeedData.TAD_PARAMETERS_SC_M3);
        TadParameters tadParameters = paramSet.parametersInstance();
        tadParameters.setAssociatedLcTargetListSetName(TadQuarterlyPipelineSeedData.SC3);

        PipelineOperations pipelineOperations = new PipelineOperations();
        pipelineOperations.updateParameterSet(paramSet, tadParameters, false);
        databaseService.commitTransaction();

        databaseService.closeCurrentSession();
        TadTriggerValidator validator = new TadTriggerValidator(
            mockTlsValidator);
        validator.validate(TadQuarterlyPipelineSeedData.TAD_TRIGGER_NAME);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testInvalidTriggerName() {
        populateObjects();

        databaseService.closeCurrentSession();
        TadTriggerValidator validator = new TadTriggerValidator(
            mockTlsValidator);
        validator.validate("foo");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testInvalidTargetTypeForModule() {
        populateObjects();

        // Set an invalid target type.
        databaseService.beginTransaction();
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        TargetListSet rpTls = targetSelectionCrud.retrieveTargetListSet(TadQuarterlyPipelineSeedData.RP);
        rpTls.setType(TargetType.LONG_CADENCE);
        databaseService.commitTransaction();

        databaseService.closeCurrentSession();
        TadTriggerValidator validator = new TadTriggerValidator(
            mockTlsValidator);
        validator.validate(TadQuarterlyPipelineSeedData.TAD_TRIGGER_NAME);
    }

}
