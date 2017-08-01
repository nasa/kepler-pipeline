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

package gov.nasa.kepler.hibernate.tip;

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Unit tests for the TIP CRUD.
 * 
 * @author Forrest Giroaurd
 */
public class TipCrudTest {

    private DatabaseService databaseService;
    private TipCrud tipCrud;

    private static final int PIPELINE_TASK_ID = 123456;
    private static final int SKY_GROUP_ID = 42;
    private static final String TXT_FILE_EXTENSION = ".txt";

    private int pipelineTaskId = PIPELINE_TASK_ID;

    private List<TipBlobMetadata> tipBlobMetadataList1;

    private TipBlobMetadata tipBlobMetadata1;

    @Before
    public void setUp() {
        databaseService = DatabaseServiceFactory.getInstance();
        tipCrud = new TipCrud();

        TestUtils.setUpDatabase(databaseService);
    }

    @After
    public void tearDown() {
        TestUtils.tearDownDatabase(databaseService);
    }

    @Test
    public void createTipBlobMetadata() {
        populateTipBlobMetadata();

        try {
            databaseService.beginTransaction();
            tipCrud.createTipBlobMetadata(tipBlobMetadata1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test(expected = HibernateException.class)
    public void storeTipBlobMetadataWithEmptyDatabase() {

        tearDown();
        createTipBlobMetadata();
    }

    @Test(expected = NullPointerException.class)
    public void createNullTipBlobMetadata() {

        try {
            databaseService.beginTransaction();
            tipCrud.createTipBlobMetadata((TipBlobMetadata) null);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void createTipBlobMetadataList() {
        populateTipBlobMetadata();

        try {
            databaseService.beginTransaction();
            tipCrud.createTipBlobMetadata(tipBlobMetadataList1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test(expected = IllegalArgumentException.class)
    public void createEmptyTipBlobMetadataList() {
        populateTipBlobMetadata();

        try {
            databaseService.beginTransaction();
            tipCrud.createTipBlobMetadata(new ArrayList<TipBlobMetadata>());
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    private void populateTipBlobMetadata() {

        tipBlobMetadataList1 = new ArrayList<TipBlobMetadata>();
        tipBlobMetadata1 = createTipBlobMetadata(SKY_GROUP_ID);
        tipBlobMetadataList1.add(tipBlobMetadata1);
    }

    private TipBlobMetadata createTipBlobMetadata(int skyGroupId) {
        return new TipBlobMetadata(getPipelineTaskId(), skyGroupId,
            TXT_FILE_EXTENSION);
    }

    private synchronized int getPipelineTaskId() {
        return pipelineTaskId++;
    }
}
