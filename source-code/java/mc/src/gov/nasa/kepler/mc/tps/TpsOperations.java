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

package gov.nasa.kepler.mc.tps;

import static gov.nasa.kepler.mc.fs.TpsFsIdFactory.getWeakSecondaryMesId;
import static gov.nasa.kepler.mc.fs.TpsFsIdFactory.getWeakSecondaryPhaseId;
import gov.nasa.kepler.common.pi.TpsType;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.PlanetaryCandidatesFilter;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.hibernate.tps.TpsDbResult;
import gov.nasa.kepler.hibernate.tps.WeakSecondaryDb;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.spiffy.common.intervals.TaggedInterval;

import java.util.ArrayList;
import java.util.List;

/**
 * Contains operations related to {@link TpsDbResult}s.
 * 
 * @author Miles Cote
 * 
 */
public class TpsOperations {

    private final TpsCrud tpsCrud;
    private final CelestialObjectOperations celestialObjectOperations;
    private final FileStoreClient fsClient;

    public TpsOperations(CelestialObjectOperations celestialObjectOperations, FileStoreClient fsClient) {
        this(new TpsCrud(), celestialObjectOperations, fsClient);
    }

    TpsOperations(TpsCrud tpsCrud,
        CelestialObjectOperations celestialObjectOperations,
        FileStoreClient fsClient) {
        this.tpsCrud = tpsCrud;
        this.celestialObjectOperations = celestialObjectOperations;
        this.fsClient = fsClient;
    }

    /**
     * 
     * @param filterParameters this may be null
     * @return non-null
     */
    public List<TpsDbResult> retrieveLatestTpsResults(long pipelineInstanceId, int skyGroupId,
        int startKeplerId, int endKeplerId,
        PlanetaryCandidatesFilter filter) {
        List<Integer> keplerIds = celestialObjectOperations.retrieveKeplerIdsForSkyGroupIdKeplerIdRange(
            skyGroupId, startKeplerId, endKeplerId);

        List<TpsDbResult> tpsResults = tpsCrud.retrieveLatestTpsResults(
            keplerIds, filter);

        return tpsResults;
    }
    
    /**
     * Gets the TPS results including all the weak secondary information.  If
     * you don't need all those time series hanging around then you can just
     * can  use retrieveLatestTpsResults(int skyGroupId,
     *  int startKeplerId, int endKeplerId,
     *  PlanetaryCandidatesFilterParameters filterParameters) instead.
     * @param filterParameters  this may be null
     * @return non-null
     */
    public List<TpsDbResult> retrieveLatestTpsResultsWithFileStoreData(int skyGroupId,
            int startKeplerId, int endKeplerId,
            PlanetaryCandidatesFilter filter) {
        
        PipelineInstance tpsPipelineInstance = tpsCrud.retrieveLatestTpsRun(TpsType.TPS_FULL);
        List<TpsDbResult> tpsResults = 
                retrieveLatestTpsResults(tpsPipelineInstance.getId(), skyGroupId, startKeplerId, endKeplerId, filter);
        fillInTimeSeries(tpsPipelineInstance.getId(), tpsResults);
        
        return tpsResults;
    }

    public List<TpsDbResult> retrieveSbtResultsWithFileStoreData(List<Integer> keplerIds) {
        List<TpsDbResult> tpsResults = tpsCrud.retrieveTpsResultsForSbt(keplerIds);
        PipelineInstance tpsPipelineInstance = tpsCrud.retrieveLatestTpsRun(TpsType.TPS_FULL);
        fillInTimeSeries(tpsPipelineInstance.getId(), tpsResults);
        return tpsResults;
    }
    
	private void fillInTimeSeries(long pipelineInstanceId, List<TpsDbResult> tpsResults) {
        List<FsId> weakSecondaryFsIds = new ArrayList<FsId>(tpsResults.size());
        for (TpsDbResult result : tpsResults) {
            if (result.getWeakSecondary() == null) {
                continue;
            }
            
            FsId mesId = getWeakSecondaryMesId(pipelineInstanceId, result.getKeplerId(), result.getTrialTransitPulseInHours());
            FsId pulseId = getWeakSecondaryPhaseId(pipelineInstanceId, result.getKeplerId(), result.getTrialTransitPulseInHours());
            weakSecondaryFsIds.add(mesId);
            weakSecondaryFsIds.add(pulseId);
        }
        
        FsId[] idArray = new FsId[weakSecondaryFsIds.size()];
        weakSecondaryFsIds.toArray(idArray);
        FloatTimeSeries[] timeSeries = fsClient.readAllTimeSeriesAsFloat(idArray, true);
        
        int timeSeriesIndex = 0;
        for (TpsDbResult result: tpsResults) {
            if (result.getWeakSecondary() == null) {
                continue;
            }
            WeakSecondaryDb weakSecondary = result.getWeakSecondary();
            long dbOriginator = result.getOriginator().getId();
            checkOriginator(dbOriginator, timeSeries[timeSeriesIndex]);
            weakSecondary.setMes(timeSeries[timeSeriesIndex++].fseries());
            checkOriginator(dbOriginator, timeSeries[timeSeriesIndex]);
            weakSecondary.setPhaseInDays(timeSeries[timeSeriesIndex++].fseries());
        }
	}
	
	private static void checkOriginator(long dbOriginator, FloatTimeSeries timeSeries) {
	    for (TaggedInterval originatorInterval : timeSeries.originators()) {
	        if (originatorInterval.tag() != dbOriginator) {
	            throw new IllegalStateException("Expected db originator " +
	                dbOriginator + ", but time series \"" + timeSeries.id() +
	                "\" has originator " + originatorInterval.tag() + ".");
	        }
	    }
	}
    

}
