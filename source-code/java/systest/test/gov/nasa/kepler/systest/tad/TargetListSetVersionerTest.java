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

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetCrud;
import gov.nasa.kepler.hibernate.pi.ParameterSetName;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionNode;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.ops.seed.CommonPipelineSeedData;
import gov.nasa.kepler.ops.seed.TadQuarterlyPipelineSeedData;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.Map;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Miles Cote
 * 
 */
public class TargetListSetVersionerTest {

    private static final String ORIGINAL_LC_TLS_NAME = TadQuarterlyPipelineSeedData.LC;
    private static final String LC_V2_TLS_NAME = ORIGINAL_LC_TLS_NAME + "_v2";
    private static final String LC_V3_TLS_NAME = ORIGINAL_LC_TLS_NAME + "_v3";

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
    public void testPatterns() {

        String p = TargetListSetVersioner.EXISTING_VERSION_REGEXP;

        String s1 = "old_name_v3"; // match
        String s2 = "old_v2_name_v3"; // match
        String s3 = "old_v2_name_v32"; // match
        String s4 = "old_v2_name_v32a"; // NO match
        String s5 = "old_name"; // NO match
        String s6 = "old_v2_name"; // NO match

        assertTrue(s1.matches(p));
        assertTrue(s2.matches(p));
        assertTrue(s3.matches(p));
        assertTrue(!s4.matches(p));
        assertTrue(!s5.matches(p));
        assertTrue(!s6.matches(p));
    }

    @Test
    public void testVersionOrigToV2() {
        populateObjects();

        databaseService.closeCurrentSession();

        databaseService.beginTransaction();
        TargetListSetVersioner versioner = new TargetListSetVersioner();
        versioner.version(ORIGINAL_LC_TLS_NAME,
            TadQuarterlyPipelineSeedData.TAD_TRIGGER_NAME);
        databaseService.commitTransaction();

        databaseService.closeCurrentSession();
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();

        TargetListSet lcV2Tls = targetSelectionCrud.retrieveTargetListSet(LC_V2_TLS_NAME);
        assertNotNull(lcV2Tls);
        assertEquals(State.LOCKED, lcV2Tls.getState());

        validateTrigger(TadQuarterlyPipelineSeedData.TAD_TRIGGER_NAME,
            ORIGINAL_LC_TLS_NAME, LC_V2_TLS_NAME);
    }

    private void populateObjects() {
        databaseService = DatabaseServiceFactory.getInstance();

        createTargetListSets();

        createPipelineSeedData();
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

    private void validateTrigger(String triggerName, String origTlsName,
        String newTlsName) {
        TriggerDefinitionCrud triggerDefinitionCrud = new TriggerDefinitionCrud();
        TriggerDefinition triggerDef = triggerDefinitionCrud.retrieve(triggerName);

        Map<ClassWrapper<Parameters>, ParameterSetName> pipelineParameterSetNames = triggerDef.getPipelineParameterSetNames();
        validateTadParameters(pipelineParameterSetNames, origTlsName,
            newTlsName);

        for (TriggerDefinitionNode node : triggerDef.getNodes()) {
            Map<ClassWrapper<Parameters>, ParameterSetName> moduleParameterSetNames = node.getModuleParameterSetNames();
            validateTadParameters(moduleParameterSetNames, origTlsName,
                newTlsName);
        }
    }

    private void validateTadParameters(
        Map<ClassWrapper<Parameters>, ParameterSetName> parameterSetNames,
        String origTlsName, String newTlsName) {
        ParameterSetCrud parameterSetCrud = new ParameterSetCrud();
        ParameterSetName parameterSetName = parameterSetNames.get(new ClassWrapper<Parameters>(
            TadParameters.class));
        if (parameterSetName != null) {
            ParameterSet paramSet = parameterSetCrud.retrieveLatestVersionForName(parameterSetName);
            TadParameters tadParameters = paramSet.parametersInstance();

            String tlsName = tadParameters.getTargetListSetName();
            if (tlsName.contains(origTlsName)) {
                assertEquals(newTlsName, tlsName);
            }

            String assocLctlsName = tadParameters.getAssociatedLcTargetListSetName();
            if (assocLctlsName.contains(origTlsName)) {
                assertEquals(newTlsName, assocLctlsName);
            }
        }
    }

    @Test
    public void testVersionV2ToV3() {
        testVersionOrigToV2();

        databaseService.closeCurrentSession();

        databaseService.beginTransaction();
        TargetListSetVersioner versioner = new TargetListSetVersioner();
        versioner.version(LC_V2_TLS_NAME,
            TadQuarterlyPipelineSeedData.TAD_TRIGGER_NAME);
        databaseService.commitTransaction();

        databaseService.closeCurrentSession();
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();

        TargetListSet lcV3Tls = targetSelectionCrud.retrieveTargetListSet(LC_V3_TLS_NAME);
        assertNotNull(lcV3Tls);
        assertEquals(State.LOCKED, lcV3Tls.getState());

        validateTrigger(TadQuarterlyPipelineSeedData.TAD_TRIGGER_NAME,
            LC_V2_TLS_NAME, LC_V3_TLS_NAME);
    }

    @Test
    public void testGetNewTlsNameWithMultipleOccurrencesOfVInTlsName() {
        String oldName = "quarter5_spring2010_sc1_v2_supp_v2";

        TargetListSetVersioner versioner = new TargetListSetVersioner();
        String actualNewName = versioner.getNewTlsName(oldName);

        String expectedNewName = "quarter5_spring2010_sc1_v2_supp_v3";
        assertEquals(expectedNewName, actualNewName);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testVersionInvalidTlsName() {
        populateObjects();

        databaseService.closeCurrentSession();
        databaseService.beginTransaction();
        TargetListSetVersioner versioner = new TargetListSetVersioner();
        versioner.version("foo", TadQuarterlyPipelineSeedData.TAD_TRIGGER_NAME);
        databaseService.commitTransaction();
    }

    @Test(expected = IllegalArgumentException.class)
    public void testVersionInvalidTriggerName() {
        populateObjects();

        databaseService.closeCurrentSession();
        databaseService.beginTransaction();
        TargetListSetVersioner versioner = new TargetListSetVersioner();
        versioner.version(ORIGINAL_LC_TLS_NAME, "foo");
        databaseService.commitTransaction();
    }

}
