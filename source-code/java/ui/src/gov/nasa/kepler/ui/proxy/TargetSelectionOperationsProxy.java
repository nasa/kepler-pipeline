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

package gov.nasa.kepler.ui.proxy;

import gov.nasa.kepler.cm.TargetSelectionOperations;
import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;

import java.util.List;

/**
 * Provides a transactional version of {@link TargetSelectionOperations}.
 * 
 * @author Bill Wohler
 */
public class TargetSelectionOperationsProxy extends AbstractCrud {

    private TargetSelectionOperations targetSelectionOperations;

    /**
     * Creates a new {@link TargetSelectionOperationsProxy} object.
     */
    public TargetSelectionOperationsProxy() {
        this(null);
    }

    /**
     * Creates a new {@link TargetSelectionOperationsProxy} object with the
     * specified database service.
     * 
     * @param databaseService the {@link DatabaseService} to use for the
     * operations
     */
    public TargetSelectionOperationsProxy(DatabaseService databaseService) {
        super(databaseService);
        targetSelectionOperations = new TargetSelectionOperations(
            databaseService);
    }

    public void updatePlannedTargets(TargetList targetList,
        List<PlannedTarget> plannedTargets) {
        getDatabaseService().beginTransaction();
        targetSelectionOperations.updatePlannedTargets(targetList,
            plannedTargets);
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();
    }

    public List<Object[]> retrieveAllVisibleKeplerSkyGroupIds() {
        getDatabaseService().beginTransaction();
        List<Object[]> ids = targetSelectionOperations.retrieveAllVisibleKeplerSkyGroupIds();
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();

        return ids;
    }

    public boolean exists(int keplerId) {
        getDatabaseService().beginTransaction();
        boolean exists = targetSelectionOperations.exists(keplerId);
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();

        return exists;
    }

    public String targetToString(PlannedTarget target) {
        getDatabaseService().beginTransaction();
        String s = targetSelectionOperations.targetToString(target);
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();

        return s;
    }

    public int skyGroupIdFor(int ccdModule, int ccdOutput) {
        getDatabaseService().beginTransaction();
        int skyGroupId = targetSelectionOperations.skyGroupIdFor(ccdModule,
            ccdOutput);
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();

        return skyGroupId;
    }

    public int skyGroupIdFor(int ccdModule, int ccdOutput, int season) {
        getDatabaseService().beginTransaction();
        int skyGroupId = targetSelectionOperations.skyGroupIdFor(ccdModule,
            ccdOutput, season);
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();

        return skyGroupId;
    }

    public SkyGroup skyGroupFor(int skyGroupId) {
        getDatabaseService().beginTransaction();
        SkyGroup skyGroup = targetSelectionOperations.skyGroupFor(skyGroupId);
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();

        return skyGroup;
    }

    public SkyGroup skyGroupFor(int skyGroupId, int season) {
        getDatabaseService().beginTransaction();
        SkyGroup skyGroup = targetSelectionOperations.skyGroupFor(skyGroupId,
            season);
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();

        return skyGroup;
    }

    /**
     * Only used for testing.
     */
    void setTargetSelectionOperations(
        TargetSelectionOperations targetSelectionOperations) {
        this.targetSelectionOperations = targetSelectionOperations;
    }
}
