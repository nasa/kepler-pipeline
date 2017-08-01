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

package gov.nasa.kepler.tip;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Maps.newHashMap;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.hibernate.tps.TpsDbResult;
import gov.nasa.kepler.mc.CustomTargetParameters;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.TargetListParameters;
import gov.nasa.kepler.mc.TpsPipelineInstanceSelectionParameters;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.pa.PaTarget;
import gov.nasa.kepler.mc.pa.RmsCdpp;
import gov.nasa.kepler.mc.pa.SimulatedTransitsModuleParameters;
import gov.nasa.kepler.mc.uow.TargetListChunkUowTask;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;

import java.io.File;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TimeZone;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

/**
 * Get the inputs for a TIP unit of work.
 * 
 * @author Forrest Girouard
 */
public class TipInputsRetriever {

    private static final Log log = LogFactory.getLog(TipInputsRetriever.class);

    public static final String DATE_FORMAT = "yyyyDDDHHmmss";
    public static final String FILENAME_FORMAT = "kplr%s-%02d_tip.txt";

    private PipelineTask pipelineTask;
    private CadenceType cadenceType;

    private CelestialObjectOperations celestialObjectOperations;
    private LogCrud logCrud = new LogCrud();
    private MjdToCadence mjdToCadence;
    private RaDec2PixOperations raDec2PixOperations = new RaDec2PixOperations();
    private ConfigMapOperations configMapOperations = new ConfigMapOperations();
    private TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
    private TpsCrud tpsCrud = new TpsCrud();

    private int skippedKeplerIdCount;

    public TipInputsRetriever(PipelineTask pipelineTask) {
        this.pipelineTask = pipelineTask;
    }

    public TipInputs retrieveInputs(File matlabWorkingDirectory) {

        TargetListChunkUowTask targetListChunk = pipelineTask.uowTaskInstance();

        CadenceTypePipelineParameters cadenceTypePipelineParameters = pipelineTask.getParameters(CadenceTypePipelineParameters.class);
        cadenceType = cadenceTypePipelineParameters.cadenceType();

        SimulatedTransitsModuleParameters simulatedTransitsParameters = pipelineTask.getParameters(SimulatedTransitsModuleParameters.class);

        Pair<Integer, Integer> cadenceInterval = computeCadenceInterval(pipelineTask);
        int startCadence = cadenceInterval.left;
        int endCadence = cadenceInterval.right;

        TimestampSeries cadenceTimes = getMjdToCadence(
            pipelineTask.getPipelineInstance()).cadenceTimes(startCadence,
            endCadence);

        TargetListParameters targetListParameters = pipelineTask.getParameters(TargetListParameters.class);
        List<String> targetListNames = targetListParameters.targetListNames();
        List<String> excludeTargetListNames = targetListParameters.excludeTargetListNames();

        List<Integer> allKeplerIds = Lists.newLinkedList(targetSelectionCrud.retrieveKeplerIdsForTargetListName(
            targetListNames, targetListChunk.getSkyGroupId(),
            targetListChunk.getStartKeplerId(),
            targetListChunk.getEndKeplerId()));
        Set<Integer> excludedKeplerIds = Sets.newHashSet(targetSelectionCrud.retrieveKeplerIdsForTargetListName(
            excludeTargetListNames, targetListChunk.getSkyGroupId(),
            targetListChunk.getStartKeplerId(),
            targetListChunk.getEndKeplerId()));

        log.info("Found " + excludedKeplerIds.size() + " excluded kepler ids.");
        Iterator<Integer> allKeplerIdIterator = allKeplerIds.iterator();

        while (allKeplerIdIterator.hasNext()) {
            Integer keplerId = allKeplerIdIterator.next();
            if (keplerId == null) {
                continue;
            }
            if (excludedKeplerIds.contains(keplerId)) {
                allKeplerIdIterator.remove();
                skippedKeplerIdCount++;
            }
        }

        log.info("Retrieve RaDec2Pix model.");
        RaDec2PixModel raDec2PixModel = raDec2PixOperations.retrieveRaDec2PixModel(
            cadenceTimes.startMjd(), cadenceTimes.endMjd());

        log.info("Retrieving configuration maps.");
        List<ConfigMap> configMaps = configMapOperations.retrieveConfigMaps(
            cadenceTimes.startMjd(), cadenceTimes.endMjd());

        if (configMaps == null || configMaps.isEmpty()) {
            throw new ModuleFatalProcessingException(
                "Need at least one spacecraft config map, but found none");
        }

        List<CelestialObjectParameters> kics = getCelestialObjectOperations(
            pipelineTask, pipelineTask.getPipelineInstance()).retrieveCelestialObjectParameters(
            allKeplerIds);

        Map<Integer, CelestialObjectParameters> kicByKeplerId = new HashMap<Integer, CelestialObjectParameters>();
        for (CelestialObjectParameters kic : kics) {
            if (kic == null) {
                continue;
            }
            kicByKeplerId.put(kic.getKeplerId(), kic);
        }

        List<Integer> keplerIds = filterKeplerIds(allKeplerIds,
            kicByKeplerId.keySet());
        skippedKeplerIdCount += allKeplerIds.size() - keplerIds.size();

        log.info("Processing " + keplerIds.size()
            + " keplerIds for target list(s) \""
            + StringUtils.join(targetListNames.toArray(), ", ") + "\".");

        TpsPipelineInstanceSelectionParameters tpsPipelineInstanceSelectionParameters = pipelineTask.getParameters(TpsPipelineInstanceSelectionParameters.class);
        if (tpsPipelineInstanceSelectionParameters.getPipelineInstanceId() < 1) {
            throw new ModuleFatalProcessingException(
                "Must specify valid TPS pipeline instance id.");
        }

        List<PaTarget> targets = getPaTargets(allKeplerIds, kicByKeplerId,
            tpsPipelineInstanceSelectionParameters.getPipelineInstanceId());

        log.info("Skipped " + skippedKeplerIdCount + " targets.");

        DateFormat dateFormatter = new SimpleDateFormat(DATE_FORMAT);
        dateFormatter.setTimeZone(TimeZone.getTimeZone("UTC"));
        String formattedDate = dateFormatter.format(new Date());
        String outputFilename = String.format(FILENAME_FORMAT, formattedDate,
            targetListChunk.getSkyGroupId());

        return new TipInputs(cadenceType.toString(), startCadence, endCadence,
            targetListChunk.getSkyGroupId(), raDec2PixModel, configMaps,
            targets, kics, simulatedTransitsParameters, outputFilename);
    }

    private Pair<Integer, Integer> computeCadenceInterval(
        PipelineTask pipelineTask) {
        CadenceRangeParameters cadenceRangeParameters = pipelineTask.getParameters(CadenceRangeParameters.class);

        int startCadence = cadenceRangeParameters.getStartCadence();
        int endCadence = cadenceRangeParameters.getEndCadence();
        if (startCadence == 0 || endCadence == 0) {
            Pair<Integer, Integer> startStopTimes = logCrud.retrieveFirstAndLastCadences(cadenceType.intValue());
            if (startStopTimes == null) {
                throw new ModuleFatalProcessingException("No data available.");
            }

            if (startCadence == 0) {
                startCadence = startStopTimes.left;
            }
            if (endCadence == 0) {
                endCadence = startStopTimes.right;
            }
        }

        log.info("Start cadence " + startCadence + " end cadence " + endCadence
            + ".");
        return Pair.of(startCadence, endCadence);
    }

    private List<PaTarget> getPaTargets(List<Integer> allKeplerIds,
        Map<Integer, CelestialObjectParameters> kicByKeplerId,
        long tpsPipelineInstanceId) {

        List<PaTarget> targets = new ArrayList<PaTarget>();
        for (Integer keplerId : allKeplerIds) {
            if (keplerId == null) {
                continue;
            }

            CelestialObjectParameters kic = kicByKeplerId.get(keplerId);
            float keplerMag = (float) kic.getKeplerMag()
                .getValue();
            double raHours = kic.getRa()
                .getValue();
            double decDegrees = kic.getDec()
                .getValue();

            TargetType targetType = cadenceType == CadenceType.LONG ? TargetType.LONG_CADENCE
                : TargetType.SHORT_CADENCE;

            PaTarget target = new PaTarget(keplerId, -1, -1, new String[0],
                Float.NaN, Float.NaN, Float.NaN, Float.NaN, -1, targetType,
                new HashSet<Pixel>());
            target.setKeplerMag(keplerMag);
            target.setRaHours(raHours);
            target.setDecDegrees(decDegrees);
            targets.add(target);
        }

        retrieveRmsCdpp(targets, tpsPipelineInstanceId);

        return targets;
    }

    private List<Integer> filterKeplerIds(List<Integer> keplerIds,
        Set<Integer> keplerIdWithCelestialObjectParameters) {
        ImmutableList.Builder<Integer> builder = ImmutableList.builder();
        for (Integer keplerId : keplerIds) {
            if (keplerId == null) {
                continue;
            }
            if (!keplerIdWithCelestialObjectParameters.contains(keplerId)) {
                log.warn("Target with kepler id " + keplerId
                    + " does not have a celestial object.");
            }
            builder.add(keplerId);
        }
        return builder.build();
    }

    private void retrieveRmsCdpp(List<PaTarget> targets,
        long tpsPipelineInstanceId) {

        List<Integer> keplerIds = newArrayList();
        for (PaTarget target : targets) {
            keplerIds.add(target.getKeplerId());
        }

        List<TpsDbResult> tpsResults = tpsCrud.retrieveTpsResultByKeplerIdsPipelineInstanceId(
            keplerIds, tpsPipelineInstanceId);

        Map<Integer, List<RmsCdpp>> rmsCdppsByKeplerId = newHashMap();
        for (TpsDbResult tpsResult : tpsResults) {
            if (tpsResult.getRmsCdpp() != null) {
                List<RmsCdpp> rmsCdpps = rmsCdppsByKeplerId.get(tpsResult.getKeplerId());
                if (rmsCdpps == null) {
                    rmsCdpps = newArrayList();
                    rmsCdppsByKeplerId.put(tpsResult.getKeplerId(), rmsCdpps);
                }
                rmsCdpps.add(new RmsCdpp(tpsResult.getRmsCdpp(),
                    tpsResult.getTrialTransitPulseInHours()));
            }
        }

        int count = 0;
        for (PaTarget target : targets) {
            List<RmsCdpp> rmsCdpps = rmsCdppsByKeplerId.get(target.getKeplerId());
            if (rmsCdpps == null || rmsCdpps.size() == 0) {
                log.warn(String.format(
                    "Kepler ID %d does not have Tps results",
                    target.getKeplerId()));
                count++;
            } else {
                target.setRmsCdpp(rmsCdpps);
            }
        }
        if (count > 0) {
            log.info(String.format(
                "%d out of %d targets do not have Tps results", count,
                targets.size()));
        }
    }

    private MjdToCadence getMjdToCadence(PipelineInstance pipelineInstance) {
        if (mjdToCadence == null) {
            mjdToCadence = new MjdToCadence(cadenceType,
                new ModelMetadataRetrieverPipelineInstance(pipelineInstance));
        }
        return mjdToCadence;
    }

    private CelestialObjectOperations getCelestialObjectOperations(
        PipelineTask pipelineTask, PipelineInstance pipelineInstance) {
        if (celestialObjectOperations == null) {
            celestialObjectOperations = new CelestialObjectOperations(
                new ModelMetadataRetrieverPipelineInstance(pipelineInstance),
                !pipelineTask.getParameters(CustomTargetParameters.class)
                    .isProcessingEnabled());
        }

        return celestialObjectOperations;
    }

    void setCelestialObjectOperations(
        CelestialObjectOperations celestialObjectOperations) {
        this.celestialObjectOperations = celestialObjectOperations;
    }

    void setLogCrud(LogCrud logCrud) {
        this.logCrud = logCrud;
    }

    void setMjdToCadence(MjdToCadence mjdToCadence) {
        this.mjdToCadence = mjdToCadence;
    }

    void setRaDec2PixOperations(RaDec2PixOperations raDec2PixOperations) {
        this.raDec2PixOperations = raDec2PixOperations;
    }

    void setConfigMapOperations(ConfigMapOperations configMapOperations) {
        this.configMapOperations = configMapOperations;
    }

    void setTargetSelectionCrud(TargetSelectionCrud targetSelectionCrud) {
        this.targetSelectionCrud = targetSelectionCrud;
    }

    void setTpsCrud(TpsCrud tpsCrud) {
        this.tpsCrud = tpsCrud;
    }
}
