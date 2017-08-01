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

package gov.nasa.kepler.ar.exporter;

import gnu.trove.TFloatHashSet;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.hibernate.tps.TpsDbResult;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.*;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

public abstract class DefaultMultiQuarterTargetExporterSource 
    extends DefaultTargetExporterSource
    implements MultiQuarterTargetSource {

    private static final Log log = LogFactory.getLog(DefaultMultiQuarterTargetExporterSource.class);
    
    /** We need to know the sky group or we won't have all the same
     * ccd mod/outs on every cadence.
     * 
     */
    private final int skyGroupId;
    
    protected final TpsCrud tpsCrud;
    
    private final long tpsPipelineInstanceId;
    
    private List<CelestialObject> celestialObjects;
    
    /**
     * In start cadence order.
     */
    private List<TargetTableLog> ttableLogs;
    
    private Map<Integer, Pair<Integer, Integer>> ttableIdToChannel;

    private List<ObservedTarget> observedTargets;
    
    private List<TpsDbResult> tpsResults;
    
    private List<Integer> keplerIds;
    
    private List<SciencePixelOperations> sciOps;
    
    /** elements in this list can be null. */
    private Integer[] ttableIds;
    
    private Map<Integer, RollingBandUtils> ttableIdToRollingBandUtils;
    
    private float[] tpsTrialTransitPulseDurationsHours;
     
    public DefaultMultiQuarterTargetExporterSource(
        int skyGroupId,
        TargetCrud targetCrud,
        int startKeplerId, int endKeplerId, LogCrud logCrud,
        DataAnomalyOperations anomalyOperations,
        ConfigMapOperations configMapOps,
        CelestialObjectOperations celestialObjectOps,
        TpsCrud tpsCrud,
        long tpsPipelineInstanceId,
        FileStoreClient fsClient) {
        
        super(targetCrud, startKeplerId, endKeplerId, logCrud, anomalyOperations,
            configMapOps, celestialObjectOps, fsClient);
        
        this.skyGroupId = skyGroupId;
        this.tpsCrud = tpsCrud;
        this.tpsPipelineInstanceId = tpsPipelineInstanceId;
    }
    

    private void init() {
        if (ttableLogs != null) {
            return;
        }
        
        initTpsRelated();
        
        initTTableLogs();
        
        celestialObjects = 
            ImmutableList.copyOf(celestialObjectOps.retrieveCelestialObjects(keplerIds()));  
        
        initCcdChannels();
        
        initObservedTargets();
        
        initSciencePixelOperations();
        
        initRollingBandUtils();
    }

    private void initTpsRelated() {
        log.info("Getting TPS results.");
        //I need all the results not just the the pulse duration where the
        //initial TCE is detected.
        List<TpsDbResult> unfilteredResults = 
            tpsCrud.retrieveTpsResultByPipelineInstanceIdSkyGroupId(
                startKeplerId, endKeplerId, tpsPipelineInstanceId, skyGroupId);
        log.info("Found " + unfilteredResults.size() + " unfiltered tps results.");
        
        SortedSet<Integer> keplerIdSet = Sets.newTreeSet();
        for (TpsDbResult tpsResult : unfilteredResults) {
            keplerIdSet.add(tpsResult.getKeplerId());
        }
        
        TFloatHashSet uniqueTransitPulseDurations = new TFloatHashSet();
        keplerIdSet = Sets.newTreeSet();
        for (TpsDbResult tpsResult : unfilteredResults) {
            Integer keplerId = tpsResult.getKeplerId();
            if (tpsResult.isPlanetACandidate()) {
                keplerIdSet.add(keplerId);
            }
            uniqueTransitPulseDurations.add(tpsResult.getTrialTransitPulseInHours());
        }
        
        ImmutableList.Builder<TpsDbResult> tpsResultsBuilder = new ImmutableList.Builder<TpsDbResult>();
        for (TpsDbResult tpsResult : unfilteredResults) {
            if (keplerIdSet.contains(tpsResult.getKeplerId())) {
                tpsResultsBuilder.add(tpsResult);
            }
        }
        tpsResults = tpsResultsBuilder.build();
        keplerIds = ImmutableList.copyOf(keplerIdSet);
        this.tpsTrialTransitPulseDurationsHours = uniqueTransitPulseDurations.toArray();
        Arrays.sort(tpsTrialTransitPulseDurationsHours);
        
        log.info("Found " + keplerIds.size() + " stars with TCEs.");
    }
    
    private void initTTableLogs() {
        log.info("Getting target table logs.");
        ttableLogs = 
            targetCrud.retrieveTargetTableLogs(TargetType.LONG_CADENCE, startCadence(), endCadence());
        Collections.sort(ttableLogs, new Comparator<TargetTableLog>() {

            @Override
            public int compare(TargetTableLog o1, TargetTableLog o2) {
                return o1.getCadenceStart() - o2.getCadenceEnd();
            }
        });
        
        if (log.isInfoEnabled()) {
            StringBuilder logMsg = new StringBuilder(128);
            logMsg.append("Found target tables:\n");
            for (TargetTableLog ttableLog : ttableLogs) {
                logMsg.append("    ")
                      .append(ttableLog.getTargetTable().getExternalId())
                      .append(" [")
                      .append(ttableLog.getCadenceStart())
                      .append(',')
                      .append(ttableLog.getCadenceEnd())
                      .append("].\n");
            }
            log.info(logMsg);
        }
    }

    private void initRollingBandUtils() {
        ImmutableMap.Builder<Integer, RollingBandUtils> ttableIdToRbBuilder =
            new ImmutableMap.Builder<Integer, RollingBandUtils>();
        for (TargetTableLog ttableLog : ttableLogs) {
            Integer ttableId = ttableLog.getTargetTable().getExternalId();
            Pair<Integer, Integer> ccdChannel = ttableIdToChannel.get(ttableId);
            log.info("Initializing rolling band utils for ccd mod/out " + 
                ccdChannel.left + "/" + ccdChannel.right + ".");
            RollingBandUtils rbUtil = 
                new RollingBandUtils(ccdChannel.left, ccdChannel.right, startCadence(), endCadence());
            ttableIdToRbBuilder.put(ttableId, rbUtil);
        }
        this.ttableIdToRollingBandUtils = ttableIdToRbBuilder.build();
    }


    private void initSciencePixelOperations() {
        ImmutableList.Builder<SciencePixelOperations> sciOpsBuilder =
            new ImmutableList.Builder<SciencePixelOperations>();
        for (TargetTableLog ttableLog : ttableLogs) {
            TargetTable ttable = ttableLog.getTargetTable();
            Pair<Integer, Integer> ccdChannel = ttableIdToChannel.get(ttable.getExternalId());
            log.info("Initializating science pixel operations for ccd mod/out " 
                + ccdChannel.left + "/" + ccdChannel.right + " for target table " + ttable + ".");
            
            SciencePixelOperations singleQuarterSciOps = 
                new SciencePixelOperations(ttable, null, ccdChannel.left, ccdChannel.right);
            sciOpsBuilder.add(singleQuarterSciOps);
        }
        
        sciOps = sciOpsBuilder.build();
    }


    private void initObservedTargets() {
        //Immutable list does not like null entries.
        observedTargets = Lists.newArrayList();
        
        Integer[] ttableIdArray = new Integer[ttableLogs.size()];
        int ttableIdArrayIndex = 0;
        for (TargetTableLog ttableLog : ttableLogs) {
            TargetTable ttable = ttableLog.getTargetTable();
            log.info("Loading observed targets for keplerIds for target table " + ttable + ".");
            List<ObservedTarget> ots = 
                targetCrud.retrieveObservedTargets(ttable, keplerIds());
            if (ots == null || ots.isEmpty()) {
                ttableIdArray[ttableIdArrayIndex++] = null;
            } else {
                ttableIdArray[ttableIdArrayIndex++] = ttable.getExternalId();
                observedTargets.addAll(ots);
            }
        }
        
        ttableIds = ttableIdArray;
        observedTargets = Collections.unmodifiableList(observedTargets);
    }


    private void initCcdChannels() {
        ImmutableMap.Builder<Integer, Pair<Integer, Integer>> ttableIdToChannelBuilder = 
            new ImmutableMap.Builder<Integer, Pair<Integer, Integer>>();
        
        for (TargetTableLog ttableLog : ttableLogs) {
            int observingSeason = ttableLogs.get(0).getTargetTable().getObservingSeason();
            KicCrud kicCrud = new KicCrud();
            //The season dependent part of the sky group
            SkyGroup skyGroupForSeason = kicCrud.retrieveSkyGroup(skyGroupId, observingSeason);
            ttableIdToChannelBuilder.put(ttableLog.getTargetTable().getExternalId(),
                Pair.of(skyGroupForSeason.getCcdModule(), skyGroupForSeason.getCcdOutput()));
        }
        
        ttableIdToChannel = ttableIdToChannelBuilder.build();
    }



    
    
    /**
     * 
     * @return LONG. If this needs to be changed so we can also deal with
     * short cadence then likely there are other many other places that assume
     * long cadence that need to be fixed as well.
     */
    @Override
    public final CadenceType cadenceType() {
        return CadenceType.LONG;
    }
    

    @Override
    public List<Integer> keplerIds() {
        init();
        return keplerIds;
    }
    
    @Override
    public Map<Integer, Pair<Integer, Integer>> ccdChannels() {
        init();
        return ttableIdToChannel;
    }

    @Override
    public Map<Integer, RollingBandUtils> rollingBandPulseDurationsCadences() {
        init();
        return ttableIdToRollingBandUtils;
    }

    @Override
    public List<CelestialObject> celestialObjects() {
        init();
        return celestialObjects;
    }

    @Override
    public List<ObservedTarget> observedTargets() {
        init();
        return observedTargets;
    }

    @Override
    public List<TpsDbResult> tpsResults() {
        init();
        return tpsResults;
    }

    @Override
    public List<SciencePixelOperations> sciOps() {
        init();
        return sciOps;
    }

    @Override
    public List<TargetTableLog> targetTableLogs() {
        init();
        return ttableLogs;
    }
    
    @Override
    public Integer[] targetTableExternalId() {
        init();
        return ttableIds;
    }
    
    @Override
    public float[] tpsTrialTransitPulseDurationsHours() {
        init();
        return tpsTrialTransitPulseDurationsHours;
    }

}
