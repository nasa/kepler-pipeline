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

package gov.nasa.kepler.ar.exporter.dv;

import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;

import gov.nasa.kepler.ar.exporter.DefaultMultiQuarterTargetExporterSource;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dv.DvCrud;
import gov.nasa.kepler.hibernate.dv.DvPlanetResults;
import gov.nasa.kepler.hibernate.dv.DvTargetResults;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;

/**
 * Data needed to export a dv time series file.
 * 
 * @author Sean McCauliff
 *
 */
abstract class DefaultDvExporterSource
    extends DefaultMultiQuarterTargetExporterSource 
    implements DvExporterSource {
    
    private static final Log log = LogFactory.getLog(DefaultDvExporterSource.class);

    private final long dvPipelineInstanceId;
    
    private final DvCrud dvCrud;
    
    private Map<Integer, DvTargetResults> keplerIdToDvTargetResults;
    
    private Map<Integer, List<DvPlanetResults>> keplerIdToDvPlanetResults;
    
    
    
    DefaultDvExporterSource(int skyGroupId, TargetCrud targetCrud,
        int startKeplerId, int endKeplerId, LogCrud logCrud,
        DataAnomalyOperations anomalyOperations,
        ConfigMapOperations configMapOps,
        CelestialObjectOperations celestialObjectOps, TpsCrud tpsCrud,
        long tpsPipelineInstanceId, FileStoreClient fsClient,
        long dvPipelineInstanceId,
        DvCrud dvCrud) {
        super(skyGroupId, targetCrud, startKeplerId, endKeplerId, logCrud,
            anomalyOperations, configMapOps, celestialObjectOps, tpsCrud,
            tpsPipelineInstanceId, fsClient);
        
        this.dvPipelineInstanceId = dvPipelineInstanceId;
        this.dvCrud = dvCrud;
    }

    private void init() {
        if (keplerIdToDvTargetResults != null) {
            return;
        }
        
        initializeDvPlanetResults();
        
        
        //I need to check the map while I'm constructing it so I can't use
        //ImmutableMap.Builder here.
        keplerIdToDvPlanetResults = Maps.newHashMap();
        
        // This list should be in kepler id, tce order so we don't need to
        // sort things later.
        List<DvPlanetResults> planetResultsAllTargets = 
            dvCrud.retrievePlanetResultsByPipelineInstanceId(dvPipelineInstanceId, keplerIds());
        
        
        for (DvPlanetResults planetResults : planetResultsAllTargets) {
            List<DvPlanetResults> planetResultsSingleTarget = 
                keplerIdToDvPlanetResults.get(planetResults.getKeplerId());
            if (planetResultsSingleTarget == null) {
                planetResultsSingleTarget = Lists.newArrayList();
                keplerIdToDvPlanetResults.put(planetResults.getKeplerId(), planetResultsSingleTarget);
            }
            planetResultsSingleTarget.add(planetResults);
        }
    }

    private void initializeDvPlanetResults() {
        ImmutableMap.Builder<Integer, DvTargetResults> keplerIdToDvTargetResultsBuilder =
            new ImmutableMap.Builder<Integer, DvTargetResults>();
        List<DvTargetResults> targetResultsAllTargets = 
            dvCrud.retrieveTargetResultsByPipelineInstanceId(dvPipelineInstanceId, keplerIds());
        for (DvTargetResults dvTargetResults : targetResultsAllTargets) {
            keplerIdToDvTargetResultsBuilder.put(dvTargetResults.getKeplerId(), dvTargetResults);
        }
        this.keplerIdToDvTargetResults = keplerIdToDvTargetResultsBuilder.build();
        
        for (Integer keplerId : keplerIds()) {
            log.info("Found dv results for target " + keplerId + " -> " +
                this.keplerIdToDvTargetResults.get(keplerId));
        }
    }

    @Override
    public long dvPipelineInstanceId() {
        return dvPipelineInstanceId;
    }

    @Override
    public Map<Integer, DvTargetResults> keplerIdToDvTargetResults() {
        init();
        return keplerIdToDvTargetResults;
    }

    @Override
    public Map<Integer, List<DvPlanetResults>> keplerIdToDvPlanetResults() {
        init();
        return keplerIdToDvPlanetResults;
    }

    

}
