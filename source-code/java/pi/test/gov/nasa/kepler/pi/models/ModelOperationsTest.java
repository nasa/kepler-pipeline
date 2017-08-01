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

package gov.nasa.kepler.pi.models;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.hibernate.pi.Model;
import gov.nasa.kepler.hibernate.pi.ModelCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadata;
import gov.nasa.kepler.hibernate.pi.ModelMetadataCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetriever;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.util.Date;

import org.junit.Test;

/**
 * @author Miles Cote
 * 
 */
public class ModelOperationsTest extends JMockTest {

    private static final int REVISION_FIRST = Model.NULL_REVISION + 1;
    private static final int REVISION_EXISTING = 2;
    private static final int REVISION_NEW = 3;

    private static final Date CREATED = new Date(4000);

    private static final String MODEL_TYPE = "MODEL_TYPE";
    private static final String MODEL_DESCRIPTION = "MODEL_DESCRIPTION";

    private Model modelExisting = mock(Model.class, "modelExisting");
    private Model modelNew = mock(Model.class, "modelNew");

    private ModelMetadata modelMetadata = mock(ModelMetadata.class);

    private ModelMetadataRetriever modelMetadataRetriever = mock(ModelMetadataRetriever.class);
    private ModelMetadataCrud modelMetadataCrud = mock(ModelMetadataCrud.class);

    private ModelCrud<Model> modelCrud = mock(ModelCrud.class);

    @Test
    public void testReplaceExistingModelWithExistingModelLocked() {
        allowing(modelMetadata).isLocked();
        will(returnValue(true));

        oneOf(modelMetadataCrud).updateModelMetaData(MODEL_TYPE,
            MODEL_DESCRIPTION, CREATED, String.valueOf(REVISION_NEW));

        oneOf(modelNew).setRevision(REVISION_NEW);

        oneOf(modelCrud).create(modelNew);

        setExpectations();

        ModelOperations<Model> modelOperations = new ModelOperations<Model>(
            modelMetadataCrud, modelCrud, CREATED, modelMetadataRetriever);
        modelOperations.replaceExistingModel(modelNew, MODEL_DESCRIPTION);
    }

    @Test
    public void testReplaceExistingModelWithExistingModelUnlocked() {
        oneOf(modelCrud).delete(modelExisting);

        oneOf(modelMetadataCrud).updateModelMetaData(MODEL_TYPE,
            MODEL_DESCRIPTION, CREATED, String.valueOf(REVISION_NEW));
        
        oneOf(modelNew).setRevision(REVISION_NEW);

        oneOf(modelCrud).create(modelNew);

        setExpectations();

        ModelOperations<Model> modelOperations = new ModelOperations<Model>(
            modelMetadataCrud, modelCrud, CREATED, modelMetadataRetriever);
        modelOperations.replaceExistingModel(modelNew, MODEL_DESCRIPTION);
    }

    @Test
    public void testReplaceExistingModelWithNullModelMetadata() {
        allowing(modelMetadataCrud).retrieveLatestModelRevision(MODEL_TYPE);
        will(returnValue(null));

        oneOf(modelMetadataCrud).updateModelMetaData(MODEL_TYPE,
            MODEL_DESCRIPTION, CREATED, String.valueOf(REVISION_FIRST));

        oneOf(modelNew).setRevision(REVISION_FIRST);

        oneOf(modelCrud).create(modelNew);

        setExpectations();

        ModelOperations<Model> modelOperations = new ModelOperations<Model>(
            modelMetadataCrud, modelCrud, CREATED, modelMetadataRetriever);
        modelOperations.replaceExistingModel(modelNew, MODEL_DESCRIPTION);
    }

    @Test(expected = IllegalStateException.class)
    public void testReplaceExistingModelWithIllegalRevision() {
        allowing(modelExisting).getRevision();
        will(returnValue(Model.NULL_REVISION));

        setExpectations();

        ModelOperations<Model> modelOperations = new ModelOperations<Model>(
            modelMetadataCrud, modelCrud, CREATED, modelMetadataRetriever);
        modelOperations.replaceExistingModel(modelNew, MODEL_DESCRIPTION);
    }

    @Test
    public void testRetrieveModel() {
        setExpectations();

        ModelOperations<Model> modelOperations = new ModelOperations<Model>(
            modelMetadataCrud, modelCrud, CREATED, modelMetadataRetriever);
        Model actualModel = modelOperations.retrieveModel();

        assertEquals(modelExisting, actualModel);
    }

    @Test
    public void testRetrieveModelWithNullModelMetadata() {
        allowing(modelMetadataRetriever).retrieve(MODEL_TYPE);
        will(returnValue(null));

        setExpectations();

        ModelOperations<Model> modelOperations = new ModelOperations<Model>(
            modelMetadataCrud, modelCrud, CREATED, modelMetadataRetriever);
        Model actualModel = modelOperations.retrieveModel();

        assertEquals(null, actualModel);
    }

    private void setExpectations() {
        allowing(modelMetadata).getModelRevision();
        will(returnValue(String.valueOf(REVISION_EXISTING)));

        allowing(modelMetadata).isLocked();
        will(returnValue(false));

        allowing(modelMetadataCrud).retrieveLatestModelRevision(MODEL_TYPE);
        will(returnValue(modelMetadata));

        allowing(modelMetadataRetriever).retrieve(MODEL_TYPE);
        will(returnValue(modelMetadata));

        allowing(modelCrud).getType();
        will(returnValue(MODEL_TYPE));

        allowing(modelCrud).retrieve(REVISION_EXISTING);
        will(returnValue(modelExisting));

        allowing(modelCrud).retrieve(Model.NULL_REVISION);
        will(returnValue(null));

        allowing(modelExisting).getRevision();
        will(returnValue(REVISION_EXISTING));
    }

}
