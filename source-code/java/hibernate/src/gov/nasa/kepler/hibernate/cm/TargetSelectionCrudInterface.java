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

package gov.nasa.kepler.hibernate.cm;

import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.util.Collection;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.NonUniqueResultException;

public interface TargetSelectionCrudInterface {

    /**
     * Stores a new {@link TargetList}.
     * 
     * @param targetList the {@link TargetList} object to store
     * @throws HibernateException if there were problems persisting the target
     * list
     */
    void create(TargetList targetList);

    /**
     * Retrieves the named {@link TargetList} object.
     * 
     * @param name the name of the desired {@link TargetListSet}
     * @return the named {@link TargetList} object, or {@code null} if there
     * aren't any such {@link TargetList}s
     * @throws NonUniqueResultException if the database query returned more than
     * 1 result
     * @throws HibernateException if there were problems retrieving the target
     * list set
     */
    TargetList retrieveTargetList(String name);

    /**
     * Retrieves all {@link TargetList} objects.
     * 
     * @return a non-{@code null} list of all {@link TargetList} objects
     * @throws HibernateException if there were problems retrieving the target
     * lists
     */
    List<TargetList> retrieveAllTargetLists();

    /**
     * Retrieves the Kepler IDs for all planned targets.
     * 
     * @param targetListName the name of the target list
     * @return a non-{@code null} list of Kepler IDs
     */
    List<Integer> retrieveKeplerIdsForTargetListName(
        List<String> targetListName);

    /**
     * Retrieves the Kepler IDs for all planned targets in the given named
     * target list in the given range.
     * 
     * @param targetListNames the names of the target lists
     * @param startKeplerId the starting Kepler ID, inclusive
     * @param endKeplerId the ending Kepler ID, inclusive
     * @return a non-{@code null} list of Kepler IDs
     */
    List<Integer> retrieveKeplerIdsForTargetListName(
        List<String> targetListNames, int startKeplerId, int endKeplerId);

    /**
     * Retrieves the Kepler IDs for all planned targets in the given named
     * target list in the given range.
     * 
     * @param targetListNames the names of the target lists
     * @param startKeplerId the starting Kepler ID, inclusive
     * @param endKeplerId the ending Kepler ID, inclusive
     * @param skyGroupId the sky group ID to restrict this to.
     * @return a non-{@code null} list of Kepler IDs
     */
    List<Integer> retrieveKeplerIdsForTargetListName(
        List<String> targetListNames, int skyGroupId, 
        int startKeplerId, int endKeplerId);
    
    /**
     * Gets the number of {@link TargetList} entries.
     * 
     * @return the number of {@link TargetList} entries
     * @throws HibernateException if there were problems retrieving the count of
     * target lists
     */
    int targetListCount();

    /**
     * Deletes the given {@link TargetList} along with all of its associated
     * {@link PlannedTarget}s.
     * 
     * @throws HibernateException if there were problems deleting the target
     * list
     */
    void delete(TargetList targetList);

    /**
     * Stores a new collection of {@link PlannedTarget}s.
     * 
     * @param targets the collection of {@link PlannedTarget}s to store
     * @throws HibernateException if there were problems persisting the targets
     */
    void create(Collection<PlannedTarget> targets);

    /**
     * Retrieves all {@link PlannedTarget}s associated with the given
     * {@link TargetList}.
     * 
     * @param targetList the {@link TargetList}
     * @return a non-{@code null} list of all associated {@link PlannedTarget}s
     * @throws HibernateException if there were problems retrieving the targets.
     */
    List<PlannedTarget> retrievePlannedTargets(TargetList targetList);

    /**
     * Retrieves all {@link PlannedTarget}s associated with the given
     * {@link TargetListSet}.
     * 
     * @param targetListSet the {@link TargetListSet}
     * @return a non-{@code null} list of all associated rejected
     * {@link PlannedTarget}s
     * @throws HibernateException if there were problems retrieving the targets
     */
    List<PlannedTarget> retrieveRejectedPlannedTargets(
        TargetListSet targetListSet);

    /**
     * Gets the number of {@link PlannedTarget}s associated with the given
     * {@link TargetList}.
     * 
     * @param targetList the {@link TargetList}
     * @return the number of {@link PlannedTarget}s
     * @throws HibernateException if there were problems retrieving the count of
     * targets
     */
    int plannedTargetCount(TargetList targetList);

    /**
     * Deletes the {@link PlannedTarget}s associated with the given
     * {@link TargetList}. Note that {@link #delete(TargetList)} does this for
     * you.
     * 
     * @throws HibernateException if there were problems deleting the targets
     */
    void deletePlannedTargets(TargetList targetList);

    /**
     * Stores a new {@link TargetListSet}.
     * 
     * @param targetListSet the {@link TargetListSet} object to store
     * @throws HibernateException if there were problems persisting the target
     * list set
     */
    void create(TargetListSet targetListSet);

    /**
     * Retrieves the named {@link TargetListSet} object.
     * 
     * @param name the name of the desired {@link TargetListSet}
     * @return the named {@link TargetListSet} object, or {@code null} if there
     * aren't any such {@link TargetListSet}s
     * @throws NonUniqueResultException if the database query returned more than
     * 1 result
     * @throws HibernateException if there were problems retrieving the target
     * list set
     */
    TargetListSet retrieveTargetListSet(String name);

    /**
     * Retrieves the {@link TargetListSet} object associated with the given ID.
     * 
     * @param id the ID of the desired {@link TargetListSet}
     * @return the named {@link TargetListSet} object, or {@code null} if there
     * aren't any such {@link TargetListSet}s
     * @throws NonUniqueResultException if the database query returned more than
     * 1 result
     * @throws HibernateException if there were problems retrieving the target
     * list set
     */
    TargetListSet retrieveTargetListSet(long id);

    /**
     * Retrieves the target list sets in the given state.
     * 
     * @param state the state. Must not be {@code null}
     * @return a non-{@code null} list of {@link TargetListSet}s
     * @see #retrieveTargetListSets(ExportTable.State, ExportTable.State)
     * @throws HibernateException if there were problems retrieving the target
     * list sets
     */
    List<TargetListSet> retrieveTargetListSets(State state);

    /**
     * Retrieves the target list sets in the given range of states, inclusive.
     * 
     * @return non-{@code null} list of {@link TargetListSet}s
     * @see #retrieveTargetListSets(ExportTable.State)
     * @throws HibernateException if there were problems retrieving the target
     * list sets
     */
    List<TargetListSet> retrieveTargetListSets(State lowState, State highState);

    /**
     * Retrieves the target list sets that have the given {@link MaskTable}.
     * 
     * @param maskTable the {@link MaskTable}
     * @return non-{@code null} list of {@link TargetListSet}s
     * @throws HibernateException if there were problems retrieving the target
     * list sets
     */
    List<TargetListSet> retrieveTargetListSets(MaskTable maskTable);

    /**
     * Retrieves the target list sets whose associatedLcTls matches
     * the given {@link TargetListSet}.
     * 
     * @param targetListSet the associated LC {@link TargetListSet}
     * @return non-{@code null} list of {@link TargetListSet}s
     * @throws HibernateException if there were problems retrieving the target
     * list sets
     */
    List<TargetListSet> retrieveTargetListSets(TargetListSet targetListSet);

    /**
     * Retrieves the target list sets that have the given {@link TargetTable}.
     * 
     * @param targetTable the {@link MaskTable}
     * @return the associated {@link TargetListSet} object, or {@code null} if
     * there aren't any such {@link TargetListSet}s
     * @throws NonUniqueResultException if the database query returned more than
     * 1 result
     * @throws HibernateException if there were problems retrieving the target
     * list set
     */
    TargetListSet retrieveTargetListSetByTargetTable(TargetTable targetTable);

    /**
     * Retrieves all {@link TargetListSet} objects.
     * 
     * @return a non-{@code null} list of all {@link TargetListSet} objects
     * @throws HibernateException if there were problems retrieving the target
     * list sets
     */
    List<TargetListSet> retrieveAllTargetListSets();

    /**
     * Gets the number of {@link TargetListSet} entries.
     * 
     * @return the number of {@link TargetListSet} entries
     * @throws HibernateException if there were problems retrieving the count of
     * target list sets
     */
    int targetListSetCount();

    /**
     * Deletes the given {@link TargetListSet}.
     * 
     * @throws HibernateException if there were problems deleting the target
     * list set.
     */
    void delete(TargetListSet targetListSet);

    /**
     * A list of distinct TargetLists that where involved in uplinked
     * TargetTables.
     * 
     * @return a non-null list of TargetLists.
     */
    List<TargetList> retrieveTargetListsForUplinkedTargetTables();

    /**
     * 
     * @param names  A list of target names.
     * @param targetType Any valid TargetListSet target type.
     * @return a non-null list of TargetLists
     */
    List<TargetListSet> retrieveTargetListSets(Collection<String> names,
        TargetType targetType);
}