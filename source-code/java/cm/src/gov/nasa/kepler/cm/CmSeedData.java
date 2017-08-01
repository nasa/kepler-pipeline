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

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;

/**
 * Loads CM tables into the database. At the moment, the only table created by
 * this class is CM_SKY_GROUP.
 * 
 * @author Bill Wohler
 */
public class CmSeedData {

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(CmSeedData.class);

    /**
     * The first season in this array is the one where module/output 2/1 has the
     * greatest declination.
     */
    private static final int[] SEASONS = new int[] { 2, 3, 0, 1 };

    private KicCrud kicCrud = new KicCrud();

    /**
     * Creates a {@link CmSeedData}.
     */
    public CmSeedData() {
    }

    /**
     * Loads CM tables into the database.
     * 
     * @throws HibernateException if there were problems persisting the
     * {@link SkyGroup} objects
     */
    public void loadSeedData() {
        clearSkyGroupTable();
        createSkyGroupTable();
    }

    /**
     * Removes all entries in CM_SKY_GROUP table.
     */
    private void clearSkyGroupTable() {
        kicCrud.deleteAllSkyGroups();
    }

    /**
     * Creates sky group table. This code has been adapted from the
     * {@code ingest} script. This method does not provide for transaction
     * processing.
     * 
     * @throws HibernateException if there were problems persisting the
     * {@link SkyGroup} objects
     */
    public void createSkyGroupTable() {
        int skyGroupId = 1;
        for (int module : FcConstants.modulesList) {
            for (int output : FcConstants.outputsList) {
                int seasonOffset = 0;
                for (int season : SEASONS) {
                    int seasonModule = module;
                    int seasonOutput = output;

                    for (int i = 0; i < seasonOffset; i++) {
                        // Center module hack: for module 13, the output number
                        // rotates with season, not the module number!
                        if (module == 13) {
                            seasonOutput++;
                            if (seasonOutput > 4) {
                                seasonOutput = 1;
                            }
                        } else {
                            seasonModule = seasonRotatedModuleNumber(seasonModule);
                        }
                    }
                    SkyGroup skyGroup = new SkyGroup(skyGroupId, seasonModule,
                        seasonOutput, season);
                    kicCrud.create(skyGroup);
                    seasonOffset++;
                }
                skyGroupId++;
            }
        }
    }

    private int seasonRotatedModuleNumber(int module) {
        int[][] modmap = { { 1, 2, 3, 4, 5 }, { 6, 7, 8, 9, 10 },
            { 11, 12, 13, 14, 15 }, { 16, 17, 18, 19, 20 },
            { 21, 22, 23, 24, 25 } };

        int rowIndex = (module - 1) / 5;
        int colIndex = (module - 1) % 5;

        int newRowIndex = 4 - colIndex;
        int newColIndex = rowIndex;
        int newModule = modmap[newRowIndex][newColIndex];

        return newModule;
    }

    public static void main(String[] args) {
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        databaseService.beginTransaction();
        CmSeedData seedData = new CmSeedData();
        seedData.loadSeedData();
        databaseService.commitTransaction();
    }
}
