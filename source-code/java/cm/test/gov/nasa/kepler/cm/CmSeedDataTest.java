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

package gov.nasa.kepler.cm;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link CmSeedData} class.
 * 
 * @author Bill Wohler
 */
public class CmSeedDataTest {

    // Each element contains sky group ID, module/output for seasons 0, 1, 2, 3.
    private int skyGroupData[][] = { { 1, 24, 1, 10, 1, 2, 1, 16, 1 },
        { 2, 24, 2, 10, 2, 2, 2, 16, 2 }, { 3, 24, 3, 10, 3, 2, 3, 16, 3 },
        { 4, 24, 4, 10, 4, 2, 4, 16, 4 },

        { 5, 23, 1, 15, 1, 3, 1, 11, 1 }, { 6, 23, 2, 15, 2, 3, 2, 11, 2 },
        { 7, 23, 3, 15, 3, 3, 3, 11, 3 }, { 8, 23, 4, 15, 4, 3, 4, 11, 4 },

        { 9, 22, 1, 20, 1, 4, 1, 6, 1 }, { 10, 22, 2, 20, 2, 4, 2, 6, 2 },
        { 11, 22, 3, 20, 3, 4, 3, 6, 3 }, { 12, 22, 4, 20, 4, 4, 4, 6, 4 },

        { 13, 20, 1, 4, 1, 6, 1, 22, 1 }, { 14, 20, 2, 4, 2, 6, 2, 22, 2 },
        { 15, 20, 3, 4, 3, 6, 3, 22, 3 }, { 16, 20, 4, 4, 4, 6, 4, 22, 4 },

        { 17, 19, 1, 9, 1, 7, 1, 17, 1 }, { 18, 19, 2, 9, 2, 7, 2, 17, 2 },
        { 19, 19, 3, 9, 3, 7, 3, 17, 3 }, { 20, 19, 4, 9, 4, 7, 4, 17, 4 },

        { 21, 18, 1, 14, 1, 8, 1, 12, 1 }, { 22, 18, 2, 14, 2, 8, 2, 12, 2 },
        { 23, 18, 3, 14, 3, 8, 3, 12, 3 }, { 24, 18, 4, 14, 4, 8, 4, 12, 4 },

        { 25, 17, 1, 19, 1, 9, 1, 7, 1 }, { 26, 17, 2, 19, 2, 9, 2, 7, 2 },
        { 27, 17, 3, 19, 3, 9, 3, 7, 3 }, { 28, 17, 4, 19, 4, 9, 4, 7, 4 },

        { 29, 16, 1, 24, 1, 10, 1, 2, 1 }, { 30, 16, 2, 24, 2, 10, 2, 2, 2 },
        { 31, 16, 3, 24, 3, 10, 3, 2, 3 }, { 32, 16, 4, 24, 4, 10, 4, 2, 4 },

        { 33, 15, 1, 3, 1, 11, 1, 23, 1 }, { 34, 15, 2, 3, 2, 11, 2, 23, 2 },
        { 35, 15, 3, 3, 3, 11, 3, 23, 3 }, { 36, 15, 4, 3, 4, 11, 4, 23, 4 },

        { 37, 14, 1, 8, 1, 12, 1, 18, 1 }, { 38, 14, 2, 8, 2, 12, 2, 18, 2 },
        { 39, 14, 3, 8, 3, 12, 3, 18, 3 }, { 40, 14, 4, 8, 4, 12, 4, 18, 4 },

        { 41, 13, 3, 13, 4, 13, 1, 13, 2 }, { 42, 13, 4, 13, 1, 13, 2, 13, 3 },
        { 43, 13, 1, 13, 2, 13, 3, 13, 4 }, { 44, 13, 2, 13, 3, 13, 4, 13, 1 },

        { 45, 12, 1, 18, 1, 14, 1, 8, 1 }, { 46, 12, 2, 18, 2, 14, 2, 8, 2 },
        { 47, 12, 3, 18, 3, 14, 3, 8, 3 }, { 48, 12, 4, 18, 4, 14, 4, 8, 4 },

        { 49, 11, 1, 23, 1, 15, 1, 3, 1 }, { 50, 11, 2, 23, 2, 15, 2, 3, 2 },
        { 51, 11, 3, 23, 3, 15, 3, 3, 3 }, { 52, 11, 4, 23, 4, 15, 4, 3, 4 },

        { 53, 10, 1, 2, 1, 16, 1, 24, 1 }, { 54, 10, 2, 2, 2, 16, 2, 24, 2 },
        { 55, 10, 3, 2, 3, 16, 3, 24, 3 }, { 56, 10, 4, 2, 4, 16, 4, 24, 4 },

        { 57, 9, 1, 7, 1, 17, 1, 19, 1 }, { 58, 9, 2, 7, 2, 17, 2, 19, 2 },
        { 59, 9, 3, 7, 3, 17, 3, 19, 3 }, { 60, 9, 4, 7, 4, 17, 4, 19, 4 },

        { 61, 8, 1, 12, 1, 18, 1, 14, 1 }, { 62, 8, 2, 12, 2, 18, 2, 14, 2 },
        { 63, 8, 3, 12, 3, 18, 3, 14, 3 }, { 64, 8, 4, 12, 4, 18, 4, 14, 4 },

        { 65, 7, 1, 17, 1, 19, 1, 9, 1 }, { 66, 7, 2, 17, 2, 19, 2, 9, 2 },
        { 67, 7, 3, 17, 3, 19, 3, 9, 3 }, { 68, 7, 4, 17, 4, 19, 4, 9, 4 },

        { 69, 6, 1, 22, 1, 20, 1, 4, 1 }, { 70, 6, 2, 22, 2, 20, 2, 4, 2 },
        { 71, 6, 3, 22, 3, 20, 3, 4, 3 }, { 72, 6, 4, 22, 4, 20, 4, 4, 4 },

        { 73, 4, 1, 6, 1, 22, 1, 20, 1 }, { 74, 4, 2, 6, 2, 22, 2, 20, 2 },
        { 75, 4, 3, 6, 3, 22, 3, 20, 3 }, { 76, 4, 4, 6, 4, 22, 4, 20, 4 },

        { 77, 3, 1, 11, 1, 23, 1, 15, 1 }, { 78, 3, 2, 11, 2, 23, 2, 15, 2 },
        { 79, 3, 3, 11, 3, 23, 3, 15, 3 }, { 80, 3, 4, 11, 4, 23, 4, 15, 4 },

        { 81, 2, 1, 16, 1, 24, 1, 10, 1 }, { 82, 2, 2, 16, 2, 24, 2, 10, 2 },
        { 83, 2, 3, 16, 3, 24, 3, 10, 3 }, { 84, 2, 4, 16, 4, 24, 4, 10, 4 } };

    private DatabaseService databaseService;
    private DdlInitializer ddlInitializer;
    private TargetSelectionOperations targetSelectionOperations;

    @Before
    public void setUp() throws Exception {
        databaseService = DatabaseServiceFactory.getInstance();
        ddlInitializer = databaseService.getDdlInitializer();
        ddlInitializer.initDB();
        targetSelectionOperations = new TargetSelectionOperations();
    }

    @After
    public void destroyDatabase() {
        databaseService.closeCurrentSession();
        ddlInitializer.cleanDB();
    }

    private void populateObjects() throws Exception {
        databaseService.beginTransaction();
        new CmSeedData().loadSeedData();
        databaseService.commitTransaction();
    }

    @Test
    public void testLoadSeedData() throws Exception {
        populateObjects();

        for (int[] skyGroup : skyGroupData) {
            int expectedSkyGroupId = skyGroup[0];
            for (int i = 0; i < 4; i++) {
                int ccdModule = skyGroup[1 + 2 * i];
                int ccdOutput = skyGroup[1 + 2 * i + 1];
                int actualSkyGroupId = targetSelectionOperations.skyGroupIdFor(
                    ccdModule, ccdOutput, i);
                assertEquals("For module=" + ccdModule + ", output="
                    + ccdOutput + ", season=" + i, expectedSkyGroupId,
                    actualSkyGroupId);
            }
        }
    }
}
