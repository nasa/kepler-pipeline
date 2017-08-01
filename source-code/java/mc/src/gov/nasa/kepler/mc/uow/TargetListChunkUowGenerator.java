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
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTaskGenerator;
import gov.nasa.kepler.mc.TargetListParameters;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

/**
 * Breaks up the targets in a target list into fixed size chunks.
 * 
 * @author Sean McCauliff
 * 
 */
public class TargetListChunkUowGenerator implements UnitOfWorkTaskGenerator {
    private static final Log log = LogFactory.getLog(TargetListChunkUowGenerator.class);

    private SkyGroupBinner skyGroupBinner = new SkyGroupBinner();
    private KeplerIdChunkBinner keplerIdChunkBinner = new KeplerIdChunkBinner();

    private static final List<Class<? extends Parameters>> REQ_PARAMETERS;
    static {
        List<Class<? extends Parameters>> l =
            new ArrayList<Class<? extends Parameters>>(1);
        l.add(TargetListParameters.class);
        l.add(SkyGroupIdListsParameters.class);
        REQ_PARAMETERS = Collections.unmodifiableList(l);
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameterClasses() {
        return REQ_PARAMETERS;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return TargetListChunkUowTask.class;
    }

    public List<? extends UnitOfWorkTask> generateTasks(
        Map<Class<? extends Parameters>, Parameters> parameters) {
        List<KeplerIdChunkUowTask> tasks = new ArrayList<KeplerIdChunkUowTask>();

        TargetListParameters tlParams = (TargetListParameters) parameters.get(TargetListParameters.class);
        SkyGroupIdListsParameters skyGroupIdListsParameters = (SkyGroupIdListsParameters) parameters.get(SkyGroupIdListsParameters.class);

        List<String> targetListNames = tlParams.targetListNames();
        List<String> excludeListNames = tlParams.excludeTargetListNames();
        
        List<Integer> keplerIds = Lists.newLinkedList(checkedRetrieveKeplerIds(targetListNames));
        Set<Integer> excludeKeplerIds =
            Sets.newHashSet(checkedRetrieveKeplerIds(excludeListNames));
        //filter out keplerIds
        Iterator<Integer> keplerIdIt = keplerIds.iterator();
        while (keplerIdIt.hasNext()) {
            Integer keplerId = keplerIdIt.next();
            if (keplerId == null) {
                continue;
            }
            if(excludeKeplerIds.contains(keplerId)) {
                keplerIdIt.remove();
            }
        }
        
        log.info("Found " + keplerIds.size() + " keplerIDs to process after filtering.");
        
        if (keplerIds.isEmpty()) {
            return Collections.emptyList();
        }

        int minKeplerId = Integer.MAX_VALUE;
        int maxKeplerId = Integer.MIN_VALUE;
        for (int keplerId : keplerIds) {
            if (keplerId < minKeplerId) {
                minKeplerId = keplerId;
            }
            if (keplerId > maxKeplerId) {
                maxKeplerId = keplerId;
            }
        }

        KeplerIdChunkUowTask prototypeTask = new TargetListChunkUowTask(0,
            minKeplerId, maxKeplerId);

        tasks.add(prototypeTask);

        tasks = skyGroupBinner.subdivide(tasks, keplerIds,
            skyGroupIdListsParameters);

        int chunkSize = ((TargetListParameters) parameters.get(TargetListParameters.class)).getChunkSize();

        tasks = keplerIdChunkBinner.subdivide(tasks, chunkSize, keplerIds);

        return tasks;
    }

    private List<Integer> checkedRetrieveKeplerIds(List<String> targetListNames) {
        if (targetListNames.isEmpty()) {
            return Collections.emptyList();
        }
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        StringBuilder errMsg = new StringBuilder();
        for (String targetListName : targetListNames) {
            if (targetSelectionCrud.retrieveTargetList(targetListName) == null) {
               errMsg.append(targetListName);
            }
        }
        
        if (errMsg.length() != 0) {
            throw new IllegalArgumentException("Invalid target list(s) \"" + 
                errMsg +"\" specified.");
        }

        log.info("Generating units of work from target lists: \"" + 
                StringUtils.join(targetListNames.toArray(), ",") + "\".");
        
        List<Integer> keplerIds = targetSelectionCrud.retrieveKeplerIdsForTargetListName(targetListNames);
        return keplerIds;
    }
    
    public void setSkyGroupBinner(SkyGroupBinner skyGroupBinner) {
        this.skyGroupBinner = skyGroupBinner;
    }

    public void setKeplerIdChunkBinner(KeplerIdChunkBinner keplerIdChunkBinner) {
        this.keplerIdChunkBinner = keplerIdChunkBinner;
    }

    public String toString() {
        return "TargetListChunk";
    }
}
