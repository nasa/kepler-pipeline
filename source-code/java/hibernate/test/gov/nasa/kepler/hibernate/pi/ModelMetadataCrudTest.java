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

package gov.nasa.kepler.hibernate.pi;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.util.Date;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Unit tests for ModelMetadataCrud and associated entities
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 * 
 */
public class ModelMetadataCrudTest {

    private static final Log log = LogFactory.getLog(ModelMetadataCrudTest.class);

    private static final String MODEL_1_TYPE = "model1";
    private static final String MODEL_2_TYPE = "model2";

    private static final String MODEL_1_DESC = "model1 description";
    private static final String MODEL_2_DESC = "model2 description";

    private static final String MODEL_1_REV_1 = "svn+ssh://host/path/to/code@42";
    private static final String MODEL_1_REV_2 = "svn+ssh://host/path/to/code@43";
    private static final String MODEL_2_REV_1 = "svn+ssh://host/path/to/code@100";

    private DatabaseService databaseService = null;

    private ModelMetadataCrud modelMetadataCrud = new ModelMetadataCrud();

    @Before
    public void setUp() {
        // System.setProperty("hibernate.show_sql", "true");

        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);
    }

    @After
    public void tearDown() {
        if (databaseService != null) {
            TestUtils.tearDownDatabase(databaseService);
        }
    }

    @Test
    public void testUpdateEmptyRegistry() throws Exception {
        Date importTime = new Date();
        try {
            databaseService.beginTransaction();
            modelMetadataCrud.updateModelMetaData(MODEL_1_TYPE, MODEL_1_DESC,
                importTime, MODEL_1_REV_1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }

        log.info("commit done");
        databaseService.closeCurrentSession();

        ModelType expectedModelType = new ModelType(MODEL_1_TYPE);
        ModelMetadata expectedModel = new ModelMetadata(expectedModelType,
            MODEL_1_DESC, MODEL_1_REV_1, importTime);
        ModelRegistry expectedRegistry = new ModelRegistry();
        expectedRegistry.getModels()
            .put(expectedModelType, expectedModel);

        ModelRegistry actualRegistry = modelMetadataCrud.retrieveLatestRegistry();
        Map<ModelType, ModelMetadata> actualModels = actualRegistry.getModels();
        assertEquals("actualModels.size", 1, actualModels.size());

        ReflectionEquals comparer = new ReflectionEquals();
        comparer.excludeField(".*\\.id");
        comparer.assertEquals("ModelRegistry", expectedRegistry, actualRegistry);

        List<ModelMetadata> allModel1Revisions = modelMetadataCrud.retrieveAllModelRevisions(MODEL_1_TYPE);
        assertEquals("allModel1Revisions.size", 1, allModel1Revisions.size());
        comparer.assertEquals("model1", expectedModel,
            allModel1Revisions.get(0));

        List<ModelRegistry> allRegistries = modelMetadataCrud.retrieveAllRegistryRevisions();
        assertEquals("allRegistries.size", 1, allRegistries.size());
        comparer.assertEquals("allRegistries", expectedRegistry,
            allRegistries.get(0));
    }

    @Test
    public void testUpdateNewModel() throws Exception {
        // create registry and model 1
        Date importTime1 = new Date();
        try {
            databaseService.beginTransaction();
            modelMetadataCrud.updateModelMetaData(MODEL_1_TYPE, MODEL_1_DESC,
                importTime1, MODEL_1_REV_1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        // create model 2
        Date importTime2 = new Date();
        try {
            databaseService.beginTransaction();
            modelMetadataCrud.updateModelMetaData(MODEL_2_TYPE, MODEL_2_DESC,
                importTime2, MODEL_2_REV_1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        ModelType expectedModel1Type = new ModelType(MODEL_1_TYPE);
        ModelType expectedModel2Type = new ModelType(MODEL_2_TYPE);
        ModelMetadata expectedModel1 = new ModelMetadata(expectedModel1Type,
            MODEL_1_DESC, MODEL_1_REV_1, importTime1);
        ModelMetadata expectedModel2 = new ModelMetadata(expectedModel2Type,
            MODEL_2_DESC, MODEL_2_REV_1, importTime2);
        ModelRegistry expectedRegistry = new ModelRegistry();
        expectedRegistry.getModels()
            .put(expectedModel1Type, expectedModel1);
        expectedRegistry.getModels()
            .put(expectedModel2Type, expectedModel2);

        ModelRegistry actualRegistry = modelMetadataCrud.retrieveLatestRegistry();
        Map<ModelType, ModelMetadata> actualModels = actualRegistry.getModels();
        assertEquals("actualModels.size", 2, actualModels.size());

        ReflectionEquals comparer = new ReflectionEquals();
        comparer.excludeField(".*\\.id");
        comparer.assertEquals("ModelRegistry", expectedRegistry, actualRegistry);

        List<ModelMetadata> allModel1Revisions = modelMetadataCrud.retrieveAllModelRevisions(MODEL_1_TYPE);
        assertEquals("allModel1Revisions.size", 1, allModel1Revisions.size());
        comparer.assertEquals("model1", expectedModel1,
            allModel1Revisions.get(0));

        List<ModelMetadata> allModel2Revisions = modelMetadataCrud.retrieveAllModelRevisions(MODEL_2_TYPE);
        assertEquals("allModel2Revisions.size", 1, allModel2Revisions.size());
        comparer.assertEquals("model2", expectedModel2,
            allModel2Revisions.get(0));

        List<ModelRegistry> allRegistries = modelMetadataCrud.retrieveAllRegistryRevisions();
        assertEquals("allRegistries.size", 1, allRegistries.size());
        comparer.assertEquals("allRegistries", expectedRegistry,
            allRegistries.get(0));
    }

    @Test
    public void testUpdateNewModelWithLockedRegistry() throws Exception {
        // create registry and model 1
        Date importTime1 = new Date();
        try {
            databaseService.beginTransaction();
            modelMetadataCrud.updateModelMetaData(MODEL_1_TYPE, MODEL_1_DESC,
                importTime1, MODEL_1_REV_1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        // lock registry
        try {
            databaseService.beginTransaction();
            modelMetadataCrud.lockCurrentRegistry();
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        // create model 2
        Date importTime2 = new Date();
        try {
            databaseService.beginTransaction();
            modelMetadataCrud.updateModelMetaData(MODEL_2_TYPE, MODEL_2_DESC,
                importTime2, MODEL_2_REV_1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        ModelType expectedModel1Type = new ModelType(MODEL_1_TYPE);
        ModelType expectedModel2Type = new ModelType(MODEL_2_TYPE);
        ModelMetadata expectedModel1 = new ModelMetadata(expectedModel1Type,
            MODEL_1_DESC, MODEL_1_REV_1, importTime1);
        expectedModel1.lock();
        ModelMetadata expectedModel2 = new ModelMetadata(expectedModel2Type,
            MODEL_2_DESC, MODEL_2_REV_1, importTime2);

        ModelRegistry expectedRegistryR1 = new ModelRegistry();
        expectedRegistryR1.getModels()
            .put(expectedModel1Type, expectedModel1);
        expectedRegistryR1.lock();
        expectedRegistryR1.setVersion(0);

        ModelRegistry expectedRegistryR2 = new ModelRegistry();
        expectedRegistryR2.getModels()
            .put(expectedModel1Type, expectedModel1);
        expectedRegistryR2.getModels()
            .put(expectedModel2Type, expectedModel2);
        expectedRegistryR2.setVersion(1);

        ModelRegistry actualRegistry = modelMetadataCrud.retrieveLatestRegistry();
        Map<ModelType, ModelMetadata> actualModels = actualRegistry.getModels();
        assertEquals("actualModels.size", 2, actualModels.size());

        ReflectionEquals comparer = new ReflectionEquals();
        comparer.excludeField(".*\\.id");
        comparer.excludeField(".*\\.lockTime");
        comparer.assertEquals("ModelRegistry", expectedRegistryR2,
            actualRegistry);

        List<ModelMetadata> allModel1Revisions = modelMetadataCrud.retrieveAllModelRevisions(MODEL_1_TYPE);
        assertEquals("allModel1Revisions.size", 1, allModel1Revisions.size());
        comparer.assertEquals("model1", expectedModel1,
            allModel1Revisions.get(0));

        List<ModelMetadata> allModel2Revisions = modelMetadataCrud.retrieveAllModelRevisions(MODEL_2_TYPE);
        assertEquals("allModel2Revisions.size", 1, allModel2Revisions.size());
        comparer.assertEquals("model2", expectedModel2,
            allModel2Revisions.get(0));

        List<ModelRegistry> allRegistries = modelMetadataCrud.retrieveAllRegistryRevisions();
        assertEquals("allRegistries.size", 2, allRegistries.size());
        comparer.assertEquals("allRegistries r1", expectedRegistryR1,
            allRegistries.get(1));
        comparer.assertEquals("allRegistries r2", expectedRegistryR2,
            allRegistries.get(0));
    }

    @Test
    public void testUpdateExistingModel() throws Exception {
        // create registry and model 1
        try {
            databaseService.beginTransaction();
            Date importTime1 = new Date();
            modelMetadataCrud.updateModelMetaData(MODEL_1_TYPE, MODEL_1_DESC,
                importTime1, MODEL_1_REV_1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        // update model 1
        Date importTime2 = new Date();
        try {
            databaseService.beginTransaction();
            modelMetadataCrud.updateModelMetaData(MODEL_1_TYPE, MODEL_1_DESC,
                importTime2, MODEL_1_REV_2);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        ModelType expectedModel1Type = new ModelType(MODEL_1_TYPE);
        ModelMetadata expectedModel1 = new ModelMetadata(expectedModel1Type,
            MODEL_1_DESC, MODEL_1_REV_2, importTime2);
        ModelRegistry expectedRegistry = new ModelRegistry();
        expectedRegistry.getModels()
            .put(expectedModel1Type, expectedModel1);

        ModelRegistry actualRegistry = modelMetadataCrud.retrieveLatestRegistry();
        Map<ModelType, ModelMetadata> actualModels = actualRegistry.getModels();
        assertEquals("actualModels.size", 1, actualModels.size());

        ReflectionEquals comparer = new ReflectionEquals();
        comparer.excludeField(".*\\.id");
        comparer.assertEquals("ModelRegistry", expectedRegistry, actualRegistry);

        List<ModelMetadata> allModel1Revisions = modelMetadataCrud.retrieveAllModelRevisions(MODEL_1_TYPE);
        assertEquals("allModel1Revisions.size", 1, allModel1Revisions.size());
        comparer.assertEquals("model1", expectedModel1,
            allModel1Revisions.get(0));

        List<ModelRegistry> allRegistries = modelMetadataCrud.retrieveAllRegistryRevisions();
        assertEquals("allRegistries.size", 1, allRegistries.size());
        comparer.assertEquals("allRegistries", expectedRegistry,
            allRegistries.get(0));
    }

    @Test
    public void testUpdateExistingModelWithLockedRegistry() throws Exception {
        // create registry and model 1
        Date importTime1 = new Date();
        try {
            databaseService.beginTransaction();
            modelMetadataCrud.updateModelMetaData(MODEL_1_TYPE, MODEL_1_DESC,
                importTime1, MODEL_1_REV_1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        // lock registry
        try {
            databaseService.beginTransaction();
            modelMetadataCrud.lockCurrentRegistry();
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        // update model 1
        Date importTime2 = new Date();
        try {
            databaseService.beginTransaction();
            modelMetadataCrud.updateModelMetaData(MODEL_1_TYPE, MODEL_1_DESC,
                importTime2, MODEL_1_REV_2);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        ModelType expectedModel1Type = new ModelType(MODEL_1_TYPE);
        ModelMetadata expectedModelr1 = new ModelMetadata(expectedModel1Type,
            MODEL_1_DESC, MODEL_1_REV_1, importTime1);
        expectedModelr1.lock();
        ModelMetadata expectedModelr2 = new ModelMetadata(expectedModel1Type,
            MODEL_1_DESC, MODEL_1_REV_2, importTime2);

        ModelRegistry expectedRegistryR1 = new ModelRegistry();
        expectedRegistryR1.getModels()
            .put(expectedModel1Type, expectedModelr1);
        expectedRegistryR1.setVersion(0);
        expectedRegistryR1.lock();

        ModelRegistry expectedRegistryR2 = new ModelRegistry();
        expectedRegistryR2.getModels()
            .put(expectedModel1Type, expectedModelr2);
        expectedRegistryR2.setVersion(1);

        ModelRegistry actualRegistry = modelMetadataCrud.retrieveLatestRegistry();
        Map<ModelType, ModelMetadata> actualModels = actualRegistry.getModels();
        assertEquals("actualModels.size", 1, actualModels.size());

        ReflectionEquals comparer = new ReflectionEquals();
        comparer.excludeField(".*\\.id");
        comparer.excludeField(".*\\.lockTime");
        comparer.assertEquals("ModelRegistry", expectedRegistryR2,
            actualRegistry);

        List<ModelMetadata> allModel1Revisions = modelMetadataCrud.retrieveAllModelRevisions(MODEL_1_TYPE);
        assertEquals("allModel1Revisions.size", 2, allModel1Revisions.size());
        // models returned sorted by importTime (descending)
        comparer.assertEquals("model1r1", expectedModelr1,
            allModel1Revisions.get(1));
        comparer.assertEquals("model1r2", expectedModelr2,
            allModel1Revisions.get(0));

        List<ModelMetadata> allModel2Revisions = modelMetadataCrud.retrieveAllModelRevisions(MODEL_2_TYPE);
        assertEquals("allModel2Revisions.size", 0, allModel2Revisions.size());

        List<ModelRegistry> allRegistries = modelMetadataCrud.retrieveAllRegistryRevisions();
        assertEquals("allRegistries.size", 2, allRegistries.size());
        comparer.assertEquals("allRegistries r1", expectedRegistryR1,
            allRegistries.get(1));
        comparer.assertEquals("allRegistries r2", expectedRegistryR2,
            allRegistries.get(0));
    }
}
