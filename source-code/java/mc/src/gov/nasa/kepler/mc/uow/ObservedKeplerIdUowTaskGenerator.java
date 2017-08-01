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

package gov.nasa.kepler.mc.uow;

import gov.nasa.kepler.common.pi.SkyGroupIdListsParameters;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTaskGenerator;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.TargetTableParameters;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.hibernate.Session;

/**
 * Generates tasks for the flux exporter. Pipeline modules need to run
 * TargetCrud.retrieveObservedKeplerIds(TargetTable) and do binary search for
 * the star end portions of the returned List<Integer> to find the actual
 * keplerIds to iterate over.
 * 
 * @author Sean McCauliff
 * 
 */
public class ObservedKeplerIdUowTaskGenerator implements
    UnitOfWorkTaskGenerator {

    private TargetCrud targetCrud;
    private KicCrud kicCrud;
    private CelestialObjectOperations celestialObjectOperations;

    @Override
    public List<? extends UnitOfWorkTask> generateTasks(
        Map<Class<? extends Parameters>, Parameters> parameters) {
        TargetTableParameters ttableParameters = (TargetTableParameters) parameters.get(TargetTableParameters.class);
        SkyGroupIdListsParameters skyGroupIdListsParameters = (SkyGroupIdListsParameters) parameters.get(SkyGroupIdListsParameters.class);

        long ttableDbId = ttableParameters.getTargetTableDbId();
        TargetTable ttable = targetTableForTargetTableId(ttableDbId);

        List<Integer> keplerIds = getTargetCrud().retrieveObservedKeplerIds(
            ttable);

        if (keplerIds.isEmpty()) {
            return Collections.emptyList();
        }

        int minKeplerId = keplerIds.get(0);
        int maxKeplerId = keplerIds.get(keplerIds.size() - 1);

        List<ObservedKeplerIdUowTask> tasks = new ArrayList<ObservedKeplerIdUowTask>();

        ObservedKeplerIdUowTask prototypeTask = new ObservedKeplerIdUowTask(
            minKeplerId, maxKeplerId, ttableDbId, -1, -1, -1);

        tasks.add(prototypeTask);

        SkyGroupBinner skyGroupBinner = new SkyGroupBinner(
            getCelestialObjectOperations());
        tasks = skyGroupBinner.subdivide(tasks, keplerIds,
            skyGroupIdListsParameters);

        int chunkSize = ttableParameters.getChunkSize();

        KeplerIdChunkBinner keplerIdChunkBinner = new KeplerIdChunkBinner(
            getCelestialObjectOperations());

        tasks = keplerIdChunkBinner.subdivide(tasks, chunkSize, keplerIds);

        // Put mod/out parameters in place
        List<SkyGroup> skyGroups = getKicCrud().retrieveAllSkyGroups();
        Map<Integer, SkyGroup> skyGroupIdToSkyGroup = new HashMap<Integer, SkyGroup>();
        for (SkyGroup skyGroup : skyGroups) {
            if (skyGroup.getObservingSeason() != ttable.getObservingSeason()) {
                continue;
            }
            skyGroupIdToSkyGroup.put(skyGroup.getSkyGroupId(), skyGroup);
        }

        for (ObservedKeplerIdUowTask task : tasks) {
            SkyGroup skyGroup = skyGroupIdToSkyGroup.get(task.getSkyGroupId());
            task.setCcdModule(skyGroup.getCcdModule());
            task.setCcdOutput(skyGroup.getCcdOutput());
        }

        // Set the maximum kepler id per group to be MAX_INT, this is to include
        // targets which may not have supplmental apertures
        // first sort by skygroup and then by the starting kepler id.
        Collections.sort(tasks, new Comparator<ObservedKeplerIdUowTask>() {

            @Override
            public int compare(ObservedKeplerIdUowTask o1,
                ObservedKeplerIdUowTask o2) {
                int diff = o1.getSkyGroupId() - o2.getSkyGroupId();
                if (diff != 0) {
                    return diff;
                }
                return o1.getStartKeplerId() - o2.getStartKeplerId();
            }
        });

        ObservedKeplerIdUowTask prev = null;
        for (int i = 0; i < tasks.size(); i++) {
            ObservedKeplerIdUowTask task = tasks.get(i);
            if (prev != null && prev.getSkyGroupId() != task.getSkyGroupId()) {
                prev.setEndKeplerId(Integer.MAX_VALUE);
            }
            prev = task;
        }
        if (prev != null) {
            prev.setEndKeplerId(Integer.MAX_VALUE);
        }
        return tasks;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameterClasses() {
        List<Class<? extends Parameters>> rv = new ArrayList<Class<? extends Parameters>>();
        rv.add(TargetTableParameters.class);
        rv.add(SkyGroupIdListsParameters.class);
        return rv;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return ObservedKeplerIdUowTask.class;
    }

    void setTargetCrud(TargetCrud targetCrud) {
        this.targetCrud = targetCrud;
    }

    private TargetCrud getTargetCrud() {
        if (targetCrud == null) {
            targetCrud = new TargetCrud();
        }
        return targetCrud;
    }

    void setKicCrud(KicCrud kicCrud) {
        this.kicCrud = kicCrud;
    }

    private KicCrud getKicCrud() {
        if (kicCrud == null) {
            kicCrud = new KicCrud();
        }
        return kicCrud;
    }

    void setCelestialObjectOperations(
        CelestialObjectOperations celestialObjectOperations) {
        this.celestialObjectOperations = celestialObjectOperations;
    }

    private CelestialObjectOperations getCelestialObjectOperations() {
        if (celestialObjectOperations == null) {
            celestialObjectOperations = new CelestialObjectOperations(
                new ModelMetadataRetrieverLatest(), false);
        }
        return celestialObjectOperations;
    }

    protected TargetTable targetTableForTargetTableId(long dbId) {
        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        Session session = dbService.getSession();
        return (TargetTable) session.get(TargetTable.class, dbId);
    }

    public String toString() {
        return "ObservedKeplerId";
    }
}
