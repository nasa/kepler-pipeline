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

package gov.nasa.kepler.mc.tad;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Maps.newHashMap;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.hibernate.cm.Characteristic;
import gov.nasa.kepler.hibernate.cm.CharacteristicCrud;
import gov.nasa.kepler.hibernate.cm.CharacteristicType;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.TargetListSetOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperationsFactory;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Common COA functions shared between TAD and PA.
 * 
 * @author Forrest Girouard
 */
public class CoaCommon {

    private static final ConcurrentMap<TargetTableModOut, List<ObservedTarget>> targetTableModOutToOrigObservedTargets = 
        new ConcurrentHashMap<TargetTableModOut, List<ObservedTarget>>();
    public static List<ObservedTarget> getOrigObservedTargets(TargetTable targetTable, int ccdModule, int ccdOutput, TargetCrud targetCrud) {
        TargetTableModOut targetTableModOut = new TargetTableModOut(targetTable.getId(), ccdModule, ccdOutput);
        if (targetTableModOutToOrigObservedTargets.get(targetTableModOut) == null) {
            synchronized (targetTableModOutToOrigObservedTargets) {
                if (targetTableModOutToOrigObservedTargets.get(targetTableModOut) == null) {
                    List<ObservedTarget> origObservedTargets = targetCrud.retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
                        targetTable, ccdModule, ccdOutput,
                        INCLUDE_NULL_APERTURES);
                        log.info("origObservedTargets.size(); " + origObservedTargets.size());
                        
                        targetTableModOutToOrigObservedTargets.put(targetTableModOut, origObservedTargets);
                }
            }
        }

        return targetTableModOutToOrigObservedTargets.get(targetTableModOut);
    }

    /**
     * Only used by unit tests. Not for production use.
     */
    public static void clearTargetTableModOutToOrigObservedTargets() {
        targetTableModOutToOrigObservedTargets.clear();
    }
    
    private static final Log log = LogFactory.getLog(CoaCommon.class);

    public static final boolean INCLUDE_NULL_APERTURES = true;

    public static final boolean USER_DEFINED = false;

    public static final boolean EXCLUDE_CUSTOM_TARGETS = true;

    public static final float NULL_EFFECTIVE_TEMP = 0;

    private CoaCommon() {
    }

    public static TargetListSet retrieveOriginalTargetListSet(
        TargetSelectionCrud targetSelectionCrud, String supplementalForTlsName) {
        TargetListSet originalTls = targetSelectionCrud.retrieveTargetListSet(supplementalForTlsName);
        if (originalTls == null) {
            throw new IllegalArgumentException(
                "The origTls must exist in the database.\n  origTlsName: "
                    + supplementalForTlsName);
        }

        return originalTls;
    }

    public static void storeImage(PipelineTask pipelineTask,
        TargetCrud targetCrud, int ccdModule, int ccdOutput,
        TargetListSet targetListSet, double[][] completeOutputImage,
        int minRow, int maxRow, int minCol, int maxCol) {

        if (completeOutputImage.length == 0) {
            throw new ModuleFatalProcessingException(
                "No image was returned from matlab."
                    + TargetListSetOperations.getTlsInfo(targetListSet));
        }

        targetCrud.createImage(targetListSet.getTargetTable(), ccdModule,
            ccdOutput, pipelineTask, completeOutputImage, minRow, maxRow,
            minCol, maxCol);
    }

    public static void copyLcApertures(TargetCrud targetCrud, TargetListSet targetListSet,
        TargetListSet associatedLcTargetListSet, int ccdModule, int ccdOutput,
        List<ObservedTarget> scTargets, boolean lcTargetRequiredForScCopy) {

        List<ObservedTarget> lcTargets = targetCrud.retrieveObservedTargetsPlusRejected(
            associatedLcTargetListSet.getTargetTable(), ccdModule, ccdOutput);
        Map<Integer, ObservedTarget> lcTargetMap = newHashMap();
        for (ObservedTarget target : lcTargets) {
            lcTargetMap.put(target.getKeplerId(), target);
        }

        for (ObservedTarget scTarget : scTargets) {
            ObservedTarget lcTarget = lcTargetMap.get(scTarget.getKeplerId());
            if (lcTarget != null) {
                // Per KSOC-288, label validation is performed in
                // MergePipelineModule.
                // validateLabels(scTarget, lcTarget);

                scTarget.setBadPixelCount(lcTarget.getBadPixelCount());
                scTarget.setCrowdingMetric(lcTarget.getCrowdingMetric());
                scTarget.setRejected(lcTarget.isRejected());
                scTarget.setSignalToNoiseRatio(lcTarget.getSignalToNoiseRatio());
                scTarget.setMagnitude(lcTarget.getMagnitude());
                scTarget.setFluxFractionInAperture(lcTarget.getFluxFractionInAperture());
                scTarget.setDistanceFromEdge(lcTarget.getDistanceFromEdge());
                scTarget.setAperturePixelCount(lcTarget.getAperturePixelCount());
                scTarget.setRa(lcTarget.getRa());
                scTarget.setDec(lcTarget.getDec());
                scTarget.setEffectiveTemp(lcTarget.getEffectiveTemp());
                scTarget.setSkyCrowdingMetric(lcTarget.getSkyCrowdingMetric());
                scTarget.setSaturatedRowCount(lcTarget.getSaturatedRowCount());
                scTarget.setPaCoaApertureUsed(lcTarget.isPaCoaApertureUsed());

                if (lcTarget.getAperture() != null) {
                    scTarget.setAperture(lcTarget.getAperture()
                        .createCopy());
                    scTarget.getAperture()
                        .setTargetTable(targetListSet.getTargetTable());
                    scTarget.setAperturePixelCount(lcTarget.getAperturePixelCount());
                }
            } else {
                String errorString = "Short-cadence targets must be on the long-cadence target list set.  \n  keplerId: "
                    + scTarget.getKeplerId() + "\n  scTargetListSetName: " + targetListSet.getName()
                    + "\n  lcTargetListSetName: " + associatedLcTargetListSet.getName();
                if (lcTargetRequiredForScCopy) {
                    throw new ModuleFatalProcessingException(errorString);
                } else {
                    scTarget.setBadPixelCount(0);
                    scTarget.setCrowdingMetric(1.0);
                    scTarget.setRejected(true);
                    scTarget.setSignalToNoiseRatio(1.0);
                    scTarget.setMagnitude(30);
                    scTarget.setFluxFractionInAperture(1.0);
                    scTarget.setDistanceFromEdge(0);
                    scTarget.setAperturePixelCount(0);
                    scTarget.setRa(0.0);
                    scTarget.setDec(0.0);
                    scTarget.setEffectiveTemp(0.0F);
                    scTarget.setSkyCrowdingMetric(1.0F);
                    scTarget.setSaturatedRowCount(0);
                    scTarget.setPaCoaApertureUsed(false);
                    log.warn(errorString
                        + "\nContinuing with defaults since TadParameters.lcTargetRequiredForScCopy is true");
                }
            }
        }
    }

    private static boolean isPaCoa(Class<?> paPipelineModuleClass,
        PipelineTask pipelineTask) {
        ClassWrapper<PipelineModule> pipelineModuleClass = pipelineTask.getPipelineInstanceNode()
            .getPipelineModuleDefinition()
            .getImplementingClass();

        return pipelineModuleClass.getClazz() == paPipelineModuleClass;
    }

    public static void storeOptimalApertures(PipelineTask pipelineTask,
        Class<?> paPipelineModuleClass, TargetCrud targetCrud,
        TargetSelectionCrud targetSelectionCrud, int ccdModule, int ccdOutput,
        TargetListSet targetListSet,
        CoaObservedTargetRejecter coaObservedTargetRejecter,
        List<ObservedTarget> observedTargets,
        List<ObservedTarget> observedTargetsCustom,
        List<OptimalAperture> optimalApertures, String supplementalForTlsName,
        Map<Integer, KicEntryData> keplerIdToKicEntryData) {
    
        log.info(String.format("observedTargets: %d\n", observedTargets.size()));
        log.info(String.format("observedTargetsCustom: %d\n",
            observedTargetsCustom.size()));
        log.info(String.format("optimalApertures: %d\n",
            optimalApertures.size()));
    
        // Create a map because the optimal apertures might be out of order and
        // some targets might not have optimalApertures.
        Map<Integer, ObservedTarget> keplerIdToObservedTarget = newHashMap();
        for (ObservedTarget target : observedTargets) {
            // Assume nothing is rejected and reject after assigning Apertures.
            target.setRejected(false);
            keplerIdToObservedTarget.put(target.getKeplerId(), target);
        }
        
        // Store the existing optimal apertures.
        for (OptimalAperture optimalAperture : optimalApertures) {
            Aperture aperture = optimalAperture.toAperture(USER_DEFINED);
            aperture.setPipelineTask(pipelineTask);
            aperture.setTargetTable(targetListSet.getTargetTable());
    
            int keplerId = optimalAperture.getKeplerId();
            ObservedTarget target = keplerIdToObservedTarget.get(keplerId);
            if (target == null) {
                log.error(String.format(
                    "KeplerId %d not found in map of ObservedTargetsByKeplerId created "
                        + "from non-rejected ObservedTargets on the TargetList with "
                        + "an externalId of %d\n",
                    keplerId,
                    targetListSet.getTargetTable()
                        .getExternalId()));
                log.error(String.format(
                    "TargetList.getExternalId() = %d; TargetList.getId() = %d\n",
                    targetListSet.getTargetTable()
                        .getExternalId(), targetListSet.getTargetTable()
                        .getId()));
                throw new IllegalStateException(
                    "optimalAperture.keplerId (%d) must be in keplerIdToObservedTarget map\n");
            }
            target.setAperture(aperture);
            target.setAperturePixelCount(aperture.getOffsets()
                .size());
            if (isPaCoa(paPipelineModuleClass, pipelineTask)) {
                target.setPaCoaApertureUsed(optimalAperture.isApertureUpdatedWithPaCoa());
            } else {
                target.setPaCoaApertureUsed(false);
            }
            target.setBadPixelCount(optimalAperture.getBadPixelCount());
            target.setSignalToNoiseRatio(optimalAperture.getSignalToNoiseRatio());
            target.setCrowdingMetric(optimalAperture.getCrowdingMetric());
            target.setSkyCrowdingMetric(optimalAperture.getSkyCrowdingMetric());
            target.setFluxFractionInAperture(optimalAperture.getFluxFractionInAperture());
            target.setDistanceFromEdge(optimalAperture.getDistanceFromEdge());
            target.setSaturatedRowCount(optimalAperture.getSaturatedRowCount());
    
            // Skip custom targets, since these fields do not exist.
            if (TargetManagementConstants.isCatalogTarget(keplerId)) {
                KicEntryData kicEntryData = keplerIdToKicEntryData.get(keplerId);
                // Skip targets that have no kicEntryData.
                if (kicEntryData != null) {
                    target.setMagnitude(kicEntryData.getMagnitude());
                    target.setRa(kicEntryData.getRA());
                    target.setDec(kicEntryData.getDec());
                    target.setEffectiveTemp(kicEntryData.getEffectiveTemp());
                }
            }
        }
    
        // Reject obervedTargets based on whether their optimal apertures are
        // empty.
        List<ObservedTarget> origObservedTargets = null;
        List<ObservedTarget> suppObservedTargets = null;
        if (supplementalForTlsName != null && !supplementalForTlsName.isEmpty()) {
            TargetListSet origTls = retrieveOriginalTargetListSet(
                targetSelectionCrud, supplementalForTlsName);
    
            if (origTls == null) {
                throw new IllegalStateException(
                    String.format("Cannot determine original target list "
                        + "from supplemental target list (%s).", supplementalForTlsName));
            }
            origObservedTargets = getOrigObservedTargets(origTls.getTargetTable(), ccdModule, ccdOutput, targetCrud);
    
            suppObservedTargets = newArrayList();
            suppObservedTargets.addAll(observedTargets);
            
            // tad-coa expects to have the observedTargetsCustom as part of suppObservedTargets.
            if (!isPaCoa(paPipelineModuleClass, pipelineTask)) {
                suppObservedTargets.addAll(observedTargetsCustom);
            }
            
            // For pa-coa, trim the origObservedTargets to match the suppObservedTargets, since 
            // this method is called multiple times (once per subtask).
            if (isPaCoa(paPipelineModuleClass, pipelineTask)) {
                List<ObservedTarget> paCoaOrigObservedTargets = newArrayList();
                for (ObservedTarget origObservedTarget : origObservedTargets) {
                    if (suppObservedTargets.contains(origObservedTarget)) {
                        paCoaOrigObservedTargets.add(origObservedTarget);
                    }
                }
                origObservedTargets = paCoaOrigObservedTargets;
            }
        } else {
            // This run of coa was an original run.
            origObservedTargets = observedTargets;
        }
    
        coaObservedTargetRejecter.reject(origObservedTargets,
            suppObservedTargets);
    }

    public static List<KicEntryData> retrieveKicEntryData(
        PipelineInstance pipelineInstance, KicCrud kicCrud,
        CharacteristicCrud characteristicCrud, int ccdModule, int ccdOutput,
        CelestialObjectOperationsFactory celestialObjectOperationsFactory,
        PersistableFactory persistableFactory,
        TargetListSet targetListSet, int quarter) {

        log.debug("kicCrud=" + kicCrud);
        log.debug("targetListSet=" + targetListSet);
        log.debug("targetListSet.getTargetTable()="
            + targetListSet.getTargetTable());
        int skyGroupId = kicCrud.retrieveSkyGroupId(ccdModule, ccdOutput,
            targetListSet.getTargetTable()
                .getObservingSeason());

        CelestialObjectOperations celestialObjectOperations = celestialObjectOperationsFactory.create(
            pipelineInstance, EXCLUDE_CUSTOM_TARGETS);
        List<CelestialObjectParameters> celestialObjectParametersList = celestialObjectOperations.retrieveCelestialObjectParametersForSkyGroupId(skyGroupId);

        if (celestialObjectParametersList.isEmpty()) {
            throw new ModuleFatalProcessingException(
                "No kic data was retrieved."
                    + TargetListSetOperations.getTlsInfo(targetListSet));
        }

        Map<Integer, Characteristic> keplerIdToSocMagMap = CoaCommon.getKeplerIdToCharMap(
            characteristicCrud, targetListSet, skyGroupId,
            CharacteristicType.SOC_MAG, quarter);
        Map<Integer, Characteristic> keplerIdToRaMap = getKeplerIdToCharMap(
            characteristicCrud, targetListSet, skyGroupId,
            CharacteristicType.RA, quarter);
        Map<Integer, Characteristic> keplerIdToDecMap = getKeplerIdToCharMap(
            characteristicCrud, targetListSet, skyGroupId,
            CharacteristicType.DEC, quarter);

        CoaMagnitudeSelector coaMagnitudeSelector = new CoaMagnitudeSelector();
        CoaRaSelector coaRaSelector = new CoaRaSelector();
        CoaDecSelector coaDecSelector = new CoaDecSelector();
        int magnitudeNaNCount = 0;

        List<KicEntryData> kicPeers = newArrayList();
        for (CelestialObjectParameters celestialObjectParameters : celestialObjectParametersList) {
            int keplerId = celestialObjectParameters.getKeplerId();

            float magnitude = coaMagnitudeSelector.select(
                celestialObjectParameters, keplerIdToSocMagMap.get(keplerId));
            double ra = coaRaSelector.select(celestialObjectParameters,
                keplerIdToRaMap.get(keplerId));
            double dec = coaDecSelector.select(celestialObjectParameters,
                keplerIdToDecMap.get(keplerId));

            if (!Float.isNaN(magnitude)) {
                // Only pass kics with a mag to coa; filter out those with
                // no mag.
                KicEntryData kicPeer = persistableFactory.create(KicEntryData.class);
                kicPeer.setKICID(keplerId);
                kicPeer.setRA(ra);
                kicPeer.setDec(dec);
                kicPeer.setEffectiveTemp((float) (Double.isNaN(celestialObjectParameters.getEffectiveTemp()
                    .getValue()) ? NULL_EFFECTIVE_TEMP
                    : celestialObjectParameters.getEffectiveTemp()
                        .getValue()));
                kicPeer.setMagnitude(magnitude);
                kicPeers.add(kicPeer);
            } else {
                log.info("keplerId: " + keplerId + "; magnitude: NaN");
                magnitudeNaNCount++;
            }
        }
        log.info("magnitudeNaNCount: " + magnitudeNaNCount);
        log.info("kicPeers.size(): " + kicPeers.size());

        return kicPeers;
    }

    private static Map<Integer, Characteristic> getKeplerIdToCharMap(
        CharacteristicCrud characteristicCrud, TargetListSet targetListSet,
        int skyGroupId, String charType, int quarter) {

        // Get values from the char table. Use the per-quarter characteristics.
        CharacteristicType type = characteristicCrud.retrieveCharacteristicType(charType);
        List<Characteristic> chars = characteristicCrud.retrieveCharacteristics(
            type, skyGroupId, quarter);
        if (chars.isEmpty()) {
            // If there are no per-quarter characteristics, then fall back to the non-per-quarter characteristics.
            chars = characteristicCrud.retrieveCharacteristics(
                type, skyGroupId, null);
        }
        
        Map<Integer, Characteristic> keplerIdToCharMap = newHashMap();
        for (Characteristic characteristic : chars) {
            Characteristic existingChar = keplerIdToCharMap.get(characteristic.getKeplerId());
            if (existingChar != null) {
                throw new ModuleFatalProcessingException(
                    "The characteristics table must not have more than one value for the type "
                        + type + ".\n  char1: " + existingChar + "\n  char2: "
                        + characteristic
                        + TargetListSetOperations.getTlsInfo(targetListSet));
            }

            keplerIdToCharMap.put(characteristic.getKeplerId(), characteristic);
        }

        return keplerIdToCharMap;
    }

    public static void validate(TargetSelectionCrud targetSelectionCrud,
        String suppForTlsName, TargetListSet targetListSet) {
        log.info(String.format("targetListSet.name=%s", targetListSet.getName()));
        log.info(String.format("targetListSet.state=%s",
            targetListSet.getState()));
        if (targetListSet.getState() != State.LOCKED) {
            throw new ModuleFatalProcessingException(
                TargetListSetOperations.getNotLockedTlsErrorText(targetListSet));
        }

        TargetType type = targetListSet.getType();
        if (type != TargetType.LONG_CADENCE && type != TargetType.SHORT_CADENCE) {
            throw new ModuleFatalProcessingException(
                String.format(
                    "COA must run on a %s or %s targetListSet.\n  targetType: %s%s",
                    TargetType.LONG_CADENCE, TargetType.SHORT_CADENCE, type,
                    TargetListSetOperations.getTlsInfo(targetListSet)));
        }

        if (suppForTlsName != null && !suppForTlsName.isEmpty()) {
            retrieveOriginalTargetListSet(targetSelectionCrud, suppForTlsName);
        }
    }
}