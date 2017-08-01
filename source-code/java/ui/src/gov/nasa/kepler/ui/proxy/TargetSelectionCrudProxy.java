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

import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;

import java.util.Collection;
import java.util.List;

import org.hibernate.Hibernate;

/**
 * Provides a transactional version of {@link TargetSelectionCrud}.
 * 
 * @author Bill Wohler
 */
public class TargetSelectionCrudProxy extends AbstractCrud {

    private TargetSelectionCrud targetSelectionCrud;

    /**
     * Creates a new {@link TargetSelectionCrudProxy} object.
     */
    public TargetSelectionCrudProxy() {
        this(null);
    }

    /**
     * Creates a new {@link TargetSelectionCrudProxy} object with the specified
     * database service.
     * 
     * @param databaseService the {@link DatabaseService} to use for the
     * operations
     */
    public TargetSelectionCrudProxy(DatabaseService databaseService) {
        super(databaseService);
        targetSelectionCrud = new TargetSelectionCrud(databaseService);
    }

    public void create(TargetList targetList) {
        getDatabaseService().beginTransaction();
        targetSelectionCrud.create(targetList);
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();
    }

    public List<TargetList> retrieveAllTargetLists() {
        getDatabaseService().beginTransaction();
        List<TargetList> targetLists = targetSelectionCrud.retrieveAllTargetLists();
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();

        return targetLists;
    }

    public void delete(TargetList targetList) {
        getDatabaseService().beginTransaction();
        targetSelectionCrud.delete(targetList);
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();
    }

    public void create(Collection<PlannedTarget> targets) {
        getDatabaseService().beginTransaction();
        targetSelectionCrud.create(targets);
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();
    }

    public List<PlannedTarget> retrievePlannedTargets(TargetList targetList) {
        getDatabaseService().beginTransaction();
        List<PlannedTarget> targets = targetSelectionCrud.retrievePlannedTargets(targetList);
        for (PlannedTarget target : targets) {
            for (String label : target.getLabels()) {
                Hibernate.initialize(label);
            }
        }
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();

        return targets;
    }

    public int plannedTargetCount(TargetList targetList) {
        getDatabaseService().beginTransaction();
        int count = targetSelectionCrud.plannedTargetCount(targetList);
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();

        return count;
    }

    public void deletePlannedTargets(TargetList targetList) {
        getDatabaseService().beginTransaction();
        targetSelectionCrud.deletePlannedTargets(targetList);
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();
    }

    public void create(TargetListSet targetListSet) {
        getDatabaseService().beginTransaction();
        targetSelectionCrud.create(targetListSet);
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();
    }

    public List<TargetListSet> retrieveTargetListSets(State lowState,
        State highState) {
        getDatabaseService().beginTransaction();
        List<TargetListSet> targetListSets = targetSelectionCrud.retrieveTargetListSets(
            lowState, highState);
        for (TargetListSet targetListSet : targetListSets) {
            initializeTargetListSet(targetListSet);
        }
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();

        return targetListSets;
    }

    public List<TargetListSet> retrieveAllTargetListSets() {
        getDatabaseService().beginTransaction();
        List<TargetListSet> targetListSets = targetSelectionCrud.retrieveAllTargetListSets();
        for (TargetListSet targetListSet : targetListSets) {
            initializeTargetListSet(targetListSet);
        }
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();

        return targetListSets;
    }

    private void initializeTargetListSet(TargetListSet targetListSet) {
        Hibernate.initialize(targetListSet.getTargetTable());
        for (TargetList targetList : targetListSet.getTargetLists()) {
            Hibernate.initialize(targetList);
        }
        for (TargetList targetList : targetListSet.getExcludedTargetLists()) {
            Hibernate.initialize(targetList);
        }
    }

    public void delete(TargetListSet targetListSet) {
        getDatabaseService().beginTransaction();
        targetSelectionCrud.delete(targetListSet);
        getDatabaseService().flush();
        getDatabaseService().commitTransaction();
    }

    /**
     * Only used for testing.
     */
    void setTargetSelectionCrud(TargetSelectionCrud targetSelectionCrud) {
        this.targetSelectionCrud = targetSelectionCrud;
    }
}
