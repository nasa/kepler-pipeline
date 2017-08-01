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

package gov.nasa.kepler.cal;

import gov.nasa.kepler.cal.io.CalCollateralCosmicRay;
import gov.nasa.kepler.cal.io.CalCompressionTimeSeries;
import gov.nasa.kepler.cal.io.CalOutputPixelTimeSeries;
import gov.nasa.kepler.cal.io.CalOutputs;
import gov.nasa.kepler.cal.io.CalTargetMetricsTimeSeries;
import gov.nasa.kepler.cal.io.CalibratedCollateralPixels;
import gov.nasa.kepler.cal.io.CollateralMetrics;
import gov.nasa.kepler.cal.io.CosmicRayEvents;
import gov.nasa.kepler.cal.io.EmbeddedPipelineInfo;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.intervals.CadenceBlob;
import gov.nasa.kepler.common.intervals.CadenceBlobCalculator;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cal.*;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.mc.AbstractModOutCadenceBlob;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.CosmicRayEraser;
import gov.nasa.kepler.mc.CosmicRaySeriesData;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.MetricsTimeSeriesType;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.PixelTimeSeriesType;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.TargetMetricsTimeSeriesType;
import gov.nasa.kepler.mc.pmrf.CollateralPmrfTable.Duplication;
import gov.nasa.kepler.mc.pmrf.PmrfOperations;
import gov.nasa.kepler.services.alert.AlertService;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.*;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

/**
 * Stores the outputs from an invocation of cal-matlab.
 * This class is not MT-safe.
 * 
 * @author Sean McCauliff
 *
 */
public class CalOutputsConsumer {

    private static final Log log = LogFactory.getLog(CalOutputsConsumer.class);
    
    private final static class Memorized {
        private final EmbeddedPipelineInfo state;
        private final CadenceType cadenceType;
        private final Set<Pixel> targetPixels;
        private final Set<Pixel> backgroundPixels;
        private final TargetType defaultTargetType;
        private final PipelineTask originator;
        private final TimestampSeries cadenceTimes;
        /**
         * This is needed if the cadenceTimes range does not exist.
         */
        private final TimestampSeries expandedCadenceTimes;
        
        /**
         * @param expandedCadenceTimes this may be null.
         */
        public Memorized(EmbeddedPipelineInfo state, CadenceType cadenceType,
            Set<Pixel> targetPixels, Set<Pixel> backgroundPixels,
            TargetType defaultTargetType, TimestampSeries cadenceTimes,
            TimestampSeries expandedCadenceTimes,
            PipelineTask pipelineTask) {
            super();
            this.state = state;
            this.cadenceType = cadenceType;
            this.targetPixels = targetPixels;
            this.backgroundPixels = backgroundPixels;
            this.defaultTargetType = defaultTargetType;
            this.originator = pipelineTask;
            this.cadenceTimes = cadenceTimes;
            this.expandedCadenceTimes = expandedCadenceTimes;
        }

    }

    
    private Memorized m;
    
    public CalOutputsConsumer() {
    }

    private void init(CalOutputs calOutputs, File blobDir) {
        EmbeddedPipelineInfo pipelineInfo = calOutputs.pipelineInfoStruct();
        if (m != null && m.state.equals(pipelineInfo)) {
            return; //We already have the correct context
        }
        
        CadenceType cadenceType = pipelineInfo.cadenceTypeStr().equalsIgnoreCase("SHORT") ?
            CadenceType.SHORT : CadenceType.LONG;
        
        int startCadence = pipelineInfo.startCadence();
        int endCadence = pipelineInfo.endCadence();
        int ccdModule = pipelineInfo.ccdModule();
        int ccdOutput = pipelineInfo.ccdOutput();
        
        TargetType targetType = TargetType.valueOf(cadenceType);
        
        PipelineTask pipelineTask = getPipelineTaskCrud().retrieve(pipelineInfo.pipelineTaskId());
        log.info("Processing outputs for pipeline task " + pipelineTask.getId() + ".");
        
        PmrfOperations pmrfOps = getPmrfOps();
        Set<Pixel> targetPixels = Sets.newHashSet();
        Set<Pixel> bkgPixels = Sets.newHashSet();
        
        pmrfOps.getSciencePmrfTable(cadenceType, pipelineInfo.targetTableId(), ccdModule, ccdOutput).addAllPixels(targetPixels);
        if (cadenceType == CadenceType.LONG) {
            pmrfOps.getBackgroundPmrfTable(pipelineInfo.bkgTargetTableId(), ccdModule, ccdOutput).addAllPixels(bkgPixels);
        }
        
        PipelineInstance calPipelineInstance = pipelineTask.getPipelineInstance();
        TimestampSeries cadenceTimes = getCadenceTimes(cadenceType, calPipelineInstance, startCadence, endCadence);
        TimestampSeries expandedCadenceTimes = null;
        if (cadenceTimes.gapIndicators[0]) {
            LogCrud logCrud = new LogCrud();
            Pair<Integer, Integer> expandedCadenceInterval = 
                logCrud.retrieveClosestCadenceToCadence(startCadence, cadenceType);
            expandedCadenceTimes = getCadenceTimes(cadenceType,
                calPipelineInstance,
                expandedCadenceInterval.left,
                expandedCadenceInterval.right);
        }
        m = new Memorized(pipelineInfo, cadenceType, targetPixels, bkgPixels,
            targetType, cadenceTimes, expandedCadenceTimes, pipelineTask);
    }
    
    /**
     * Writes a cal output to the file store or database.
     * 
     * @param calOutputs
     */
    public void storeOutputs(CalOutputs calOutputs, File blobOutputDir) {
        init(calOutputs, blobOutputDir);
        

        List<TimeSeries> allSeries = 
            new ArrayList<TimeSeries>(Math.max(calOutputs.getCalibratedCollateralPixels().size(), calOutputs.getTargetAndBackgroundPixels().size()));

        allSeries.addAll(
            createPhotometricPixels(calOutputs.getTargetAndBackgroundPixels()));

        CalibratedCollateralPixels calCollateral = calOutputs.getCalibratedCollateralPixels();
        allSeries.addAll(calCollateral.toTimeSeries(m.state.ccdModule(), 
            m.state.ccdOutput(), m.state.startCadence(), m.state.endCadence(), m.cadenceType, m.originator.getId()));
        
        for (CalTargetMetricsTimeSeries targetMetric: calOutputs.getLdeUndershootMetrics()) {
            allSeries.addAll(
                targetMetric.toFileStoreTimeSeries(m.state.startCadence(), m.state.endCadence(), 
                    m.cadenceType,
                    TargetMetricsTimeSeriesType.UNDERSHOOT,
                    TargetMetricsTimeSeriesType.UNDERSHOOT_UNCERTAINTIES, m.state.ccdModule(), m.state.ccdOutput(),m.originator.getId())
                    );
           
        }
        
        for (CalTargetMetricsTimeSeries targetMetric: calOutputs.getTwoDBlackMetrics()) {
            allSeries.addAll(
                targetMetric.toFileStoreTimeSeries( m.state.startCadence(), m.state.endCadence(), 
                    m.cadenceType,
                    TargetMetricsTimeSeriesType.TWOD_BLACK,
                    TargetMetricsTimeSeriesType.TWOD_BLACK_UNCERTAINTIES,
                    m.state.ccdModule(), m.state.ccdOutput(), m.originator.getId())
                    );
        }

        CollateralMetrics collateralMetrics = calOutputs.getCollateralMetrics();
        
        if (collateralMetrics.getBlackLevelMetrics().values().length != 0) {
            List<TimeSeries> ts = 
                collateralMetrics.getBlackLevelMetrics().toFileStoreTimeSeries(m.state.startCadence(), 
                    m.state.endCadence(), m.cadenceType, MetricsTimeSeriesType.BLACK_LEVEL,
                    MetricsTimeSeriesType.BLACK_LEVEL_UNCERTAINTIES, 
                    m.state.ccdModule(), m.state.ccdOutput(), m.originator.getId());
            allSeries.addAll(ts);
        }
        
        if (collateralMetrics.getSmearLevelMetrics().values().length != 0) {
            List<TimeSeries> ts = 
                    collateralMetrics.getSmearLevelMetrics().toFileStoreTimeSeries(m.state.startCadence(), 
                        m.state.endCadence(),  m.cadenceType, MetricsTimeSeriesType.SMEAR_LEVEL,
                    MetricsTimeSeriesType.SMEAR_LEVEL_UNCERTAINTIES,
                    m.state.ccdModule(), m.state.ccdOutput(), m.originator.getId());
            allSeries.addAll(ts);
        }

        
        if (collateralMetrics.getDarkCurrentMetrics().values().length != 0) {
            List<TimeSeries> ts = 
                collateralMetrics.getDarkCurrentMetrics().toFileStoreTimeSeries(m.state.startCadence(), 
                    m.state.endCadence(), m.cadenceType,  MetricsTimeSeriesType.DARK_CURRENT,
                    MetricsTimeSeriesType.DARK_CURRENT_UNCERTAINTIES,
                    m.state.ccdModule(), m.state.ccdOutput(), m.originator.getId());
            allSeries.addAll(ts);

        }
        
        if (calOutputs.getTheoreticalCompressionEfficiency().getValues().length != 0) {
            allSeries.addAll(storeCompression(
                MetricsTimeSeriesType.THEORETICAL_COMPRESSION_EFFICIENCY,
                MetricsTimeSeriesType.THEORETICAL_COMPRESSION_EFFICIENCY_COUNTS,
                calOutputs.getTheoreticalCompressionEfficiency()));
        }
        if (calOutputs.getAchievedCompressionEfficiency().getValues().length != 0) {
            allSeries.addAll(storeCompression(
                MetricsTimeSeriesType.ACHIEVED_COMPRESSION_EFFICIENCY,
                MetricsTimeSeriesType.ACHIEVED_COMPRESSION_EFFICIENCY_COUNTS, 
                calOutputs.getAchievedCompressionEfficiency()));
        }
        
        allSeries.addAll(calOutputs.getCosmicRayMetrics().
            toTimeSeries(m.state.ccdModule(), m.state.ccdOutput(), m.state.startCadence(), 
                m.state.endCadence(), m.cadenceType, m.originator.getId()));

        log.info("Writing " + allSeries.size() + " cadence time series to file store.");
        getFsClient().writeTimeSeries(allSeries.toArray(new TimeSeries[0]));
        log.info("Complete write of cadence time series to file store.");

        //this logs
        if (calOutputs.getCalibratedCollateralPixels().size() != 0) {
            storeCosmicRays(calOutputs.getCosmicRayEvents());
        }
        
        CalProcessingCharacteristics calProcessingChar = 
            new CalProcessingCharacteristics(m.state.startCadence(), m.state.endCadence(),
               cadenceType(), m.originator, calOutputs.blackAlgorithmApplied(),
               m.state.ccdModule(), m.state.ccdOutput());
        getCalCrud().create(calProcessingChar);
        log.info("Adding CAL alerts to the database.");
        for (ModuleAlert alert : calOutputs.getAlerts()) {
            getAlertService()
                .generateAlert("cal",m.originator.getId(),
                    Severity.valueOf(alert.getSeverity()),
                    alert.getMessage() + ": time=" + alert.getTime());
        }

        FsId oneDBlackId = 
                CalFsIdFactory.getOneDBlackFitBlobFsId(m.cadenceType,
                    m.state.ccdModule(), m.state.ccdOutput(), m.originator.getId());
        BlobMetadataFactory<CalOneDBlackFitMetadata> oneDBlackMetadataFactory =
            new BlobMetadataFactory<CalOneDBlackFitMetadata>() {

                @Override
                public CalOneDBlackFitMetadata constructBlob(
                        long pipelineTaskId, int startCadence, int endCadence,
                        CadenceType cadenceType, int ccdModule, int ccdOutput,
                        String fileExtension) {

                    return new CalOneDBlackFitMetadata(pipelineTaskId,
                            startCadence, endCadence, cadenceType,
                            ccdModule, ccdOutput, fileExtension);
                }
            
        };
        
        storeBlob(calOutputs.getOneDBlackFitBlobFileName(), blobOutputDir,
                oneDBlackId, oneDBlackMetadataFactory,
                CalOneDBlackFitMetadata.class);
        
        FsId uncertaintyId = 
            CalFsIdFactory.getUncertaintyTransformBlobFsId(m.cadenceType,
                m.state.ccdModule(), m.state.ccdOutput(), m.originator.getId());
        BlobMetadataFactory<UncertaintyTransformationMetadata> metadataFactory =
           new BlobMetadataFactory<UncertaintyTransformationMetadata>() {

            @Override
            public UncertaintyTransformationMetadata constructBlob(
                    long pipelineTaskId, int startCadence, int endCadence,
                    CadenceType cadenceType, int ccdModule, int ccdOutput,
                    String fileExtension) {
                return new UncertaintyTransformationMetadata(pipelineTaskId,
                        startCadence, endCadence, cadenceType,
                        ccdModule, ccdOutput, fileExtension);
            }
            
        };
        storeBlob(calOutputs.getUncertaintyBlobFileName(), blobOutputDir,
                uncertaintyId, metadataFactory, UncertaintyTransformationMetadata.class);
        
        FsId smearId = 
                CalFsIdFactory.getSmearBlobFsId(m.cadenceType,
                    m.state.ccdModule(), m.state.ccdOutput(), m.originator.getId());
        BlobMetadataFactory<SmearMetadata> smearFactory =
           new BlobMetadataFactory<SmearMetadata>() {

                @Override
                public SmearMetadata constructBlob(
                        long pipelineTaskId, int startCadence, int endCadence,
                        CadenceType cadenceType, int ccdModule, int ccdOutput,
                        String fileExtension) {
                    return new SmearMetadata(pipelineTaskId,
                            startCadence, endCadence, cadenceType,
                            ccdModule, ccdOutput, fileExtension);
                }
                
            };
        storeBlob(calOutputs.smearBlobFileName(), blobOutputDir,
                smearId, smearFactory, SmearMetadata.class);
            
    }
    
    
    
    //
    @SuppressWarnings("unchecked")
	private <B extends AbstractModOutCadenceBlob> void storeBlob(String blobFileName, 
        File blobOutputDir, FsId fsId, 
        BlobMetadataFactory<B> metadataFactory, Class<B> metadataClass) {
    
        if (blobFileName.isEmpty()) {
            return;
        }
        
        
        log.info("Writing uncertainty blob from file \"" + blobFileName + "\".");

        
        File blobFile = new File(blobOutputDir, blobFileName);
        getFsClient().writeBlob(fsId, m.originator.getId(), blobFile);

        log.info("Completed writing uncertainty blob to file store.");

        List<B> olderBlobs = 
            getCalCrud().retrieveCalBlobByModOut(
                m.state.ccdModule(), m.state.ccdOutput(), m.state.startCadence(),
                m.state.endCadence(), m.cadenceType, metadataClass);

        B blobMetadata = metadataFactory.constructBlob(
            m.originator.getId(),
            m.state.startCadence(),
            m.state.endCadence(),
            m.cadenceType,
            m.state.ccdModule(),
            m.state.ccdOutput(),
            FilenameUtils.getExtension( blobFileName));

        List<B> oldAndNew = Lists.newArrayList();
        oldAndNew.addAll(olderBlobs);
        oldAndNew.add(blobMetadata);
        
        CadenceBlobCalculator<B> cadenceBlobCalculator = 
            new CadenceBlobCalculator<B>(oldAndNew);
        List<? extends CadenceBlob> blobsToBeDeleted =
            cadenceBlobCalculator.deletedBlobs();
        for (CadenceBlob deleteMe : blobsToBeDeleted) {
            getCalCrud().delete((B)deleteMe);
        }
        
        getCalCrud().create(blobMetadata);
            
    }
    
    private interface BlobMetadataFactory<B extends AbstractModOutCadenceBlob> {
        B constructBlob(long pipelineTaskId,
                int startCadence, int endCadence, CadenceType cadenceType,
                int ccdModule, int ccdOutput, String fileExtension);
    }
    
    private CadenceType cadenceType() {
        CadenceType cadenceType = m.state.cadenceTypeStr().equalsIgnoreCase("SHORT") ?
            CadenceType.SHORT : CadenceType.LONG;
        return cadenceType;
    }
    
    /**
     * Stores the given pixels in the file store.
     * 
     * @param startCadence the starting cadence.
     * @param endCadence the ending cadence.
     * @param pixels a non-{@code null} list of
     * {@link CalOutputPixelTimeSeries}.
     * @throws PipelineException if the data store could not be accessed.
     */
    private List<FloatTimeSeries> createPhotometricPixels(
        List<CalOutputPixelTimeSeries> pixels) {

        List<FloatTimeSeries> rv = Lists.newArrayListWithExpectedSize(pixels.size() * 2);

        for (CalOutputPixelTimeSeries pixel : pixels) {
            Pixel outputPixel = new Pixel(pixel.getRow(), pixel.getColumn());
            if (m.backgroundPixels.contains(outputPixel)) {
                fsIdsForOutputPixel(rv, pixel,TargetType.BACKGROUND);
            }
            
            if (m.targetPixels.contains(outputPixel)) {
                fsIdsForOutputPixel(rv, pixel, m.defaultTargetType);
            }
            

        }

        return rv;

    }
    
    /**Appends the time series for the photometric pixels to the specified
     * list.
     * @param rv this list is modified.
     * @param calTimeSeries The time series generated by cal-matlab.
     * @param targetType
     */
    private void fsIdsForOutputPixel(
        List<FloatTimeSeries> rv, CalOutputPixelTimeSeries calTimeSeries,
        TargetType targetType) {
        
        FsId fsId = CalFsIdFactory.getTimeSeriesFsId(PixelTimeSeriesType.SOC_CAL,
            targetType,
            m.state.ccdModule(), m.state.ccdOutput(), calTimeSeries.getRow(), calTimeSeries.getColumn());
        rv.add(new FloatTimeSeries(fsId, calTimeSeries.getValues(), m.state.startCadence(), m.state.endCadence(), calTimeSeries.getGapIndicators(),
            m.originator.getId()));

        fsId = CalFsIdFactory.getTimeSeriesFsId(PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES,
            targetType, m.state.ccdModule(), m.state.ccdOutput(), calTimeSeries.getRow(), calTimeSeries.getColumn());
        rv.add(new FloatTimeSeries(fsId, calTimeSeries.getUncertainties(), m.state.startCadence(), m.state.endCadence(),
            calTimeSeries.getGapIndicators(), m.originator.getId()));
    }
    
    /**
     * Stores all the output cosmic ray events in collateral data to the file
     * store.
     * 
     * @param crEvents
     * @throws FileStoreException
     * @throws PipelineException
     */
    private void storeCosmicRays(CosmicRayEvents crEvents) {

        Map<CalCollateralCosmicRay, FsId> crsFsIdsByCalCosmicRay = new HashMap<CalCollateralCosmicRay, FsId>();
        List<CalCollateralCosmicRay> calCosmicRays = new ArrayList<CalCollateralCosmicRay>();
        processCollateralCosmicRays( crsFsIdsByCalCosmicRay,
            crEvents.getBlack(), CollateralType.BLACK_LEVEL);
        calCosmicRays.addAll(crEvents.getBlack());
        processCollateralCosmicRays(crsFsIdsByCalCosmicRay,
            crEvents.getMaskedBlack(), CollateralType.BLACK_MASKED);
        calCosmicRays.addAll(crEvents.getMaskedBlack());
        processCollateralCosmicRays( crsFsIdsByCalCosmicRay,
            crEvents.getVirtualBlack(), CollateralType.BLACK_VIRTUAL);
        calCosmicRays.addAll(crEvents.getVirtualBlack());
        processCollateralCosmicRays( crsFsIdsByCalCosmicRay,
            crEvents.getMaskedSmear(), CollateralType.MASKED_SMEAR);
        calCosmicRays.addAll(crEvents.getMaskedSmear());
        processCollateralCosmicRays( crsFsIdsByCalCosmicRay,
            crEvents.getVirtualSmear(), CollateralType.VIRTUAL_SMEAR);
        calCosmicRays.addAll(crEvents.getVirtualSmear());

        storeCosmicRaySeries(crsFsIdsByCalCosmicRay, calCosmicRays);
    }

    private void processCollateralCosmicRays(
        Map<CalCollateralCosmicRay, FsId> crsFsIdsByCalCosmicRay, List<CalCollateralCosmicRay> calCosmicRays,
        CollateralType collateralType) {

        for (CalCollateralCosmicRay calCosmicRay : calCosmicRays) {
            int row = calCosmicRay.getRowOrColumn();
            FsId fsId = CalFsIdFactory.getCosmicRaySeriesFsId(collateralType, m.cadenceType, m.state.ccdModule(), m.state.ccdOutput(), row);
            crsFsIdsByCalCosmicRay.put(calCosmicRay, fsId);
        }
    }


    /**
     * Converts compression time series to file store time series.
     * 
     * @param startCadence
     * @param endCadence
     * @param MetricsTimeSeriesType
     * @param uncertainMetricsTimeSeriesType
     * @param metrics
     * @return
     * @throws PipelineException
     */
    private List<TimeSeries> storeCompression(MetricsTimeSeriesType metricsTimeSeriesType,
        MetricsTimeSeriesType countMetricsTimeSeriesType, CalCompressionTimeSeries ccts) {

        // Concatenate pixel values and uncertainties.
        TimeSeries[] timeSeries = new TimeSeries[2];

        // Wrap all of the time series in an array of FloatTimeSeries.
        FsId fsId = CalFsIdFactory.getMetricsTimeSeriesFsId(m.cadenceType, 
            metricsTimeSeriesType,
            m.state.ccdModule(), m.state.ccdOutput());
        timeSeries[0] = new FloatTimeSeries(fsId, ccts.getValues(), m.state.startCadence(),
            m.state.endCadence(), ccts.getGapIndicators(),
            m.originator.getId());

        fsId = CalFsIdFactory.getMetricsTimeSeriesFsId(m.cadenceType,
            countMetricsTimeSeriesType, m.state.ccdModule(), m.state.ccdOutput());
        timeSeries[1] = new IntTimeSeries(fsId, ccts.getNCodeSymbols(),
            m.state.startCadence(), m.state.endCadence(),
            ccts.getGapIndicators(), m.originator.getId());

        return Arrays.asList(timeSeries);
    }
    

    /**
     * Converts the given list of CAL cosmic ray events in collateral data into
     * a list of file store cosmic ray series and writes them to the file store.
     * 
     * @param crsFsIdsByCalCosmicRay map from a cosmic ray event to it's
     * corresponding {@code FsId}.
     * @param calCosmicRays list of cosmic ray events in collateral data.
     * @throws FileStoreException
     * @throws PipelineException
     */
    private void storeCosmicRaySeries(Map<CalCollateralCosmicRay, FsId> crsFsIdsByCalCosmicRay, 
        List<CalCollateralCosmicRay> calCosmicRays) {

        List<FloatMjdTimeSeries> cosmicRaySeries = createCosmicRaySeries(crsFsIdsByCalCosmicRay, calCosmicRays);

        List<FsId> allIds = getPmrfOps().
            getCollateralCosmicRayFsIds(m.cadenceType, m.state.targetTableId(), m.state.ccdModule(), m.state.ccdOutput());
        CosmicRayEraser cosmicRayEraser = getCosmicRayEraser(cosmicRaySeries, allIds);

        double startMjd = 0;
        double endMjd = 0;
        if (m.cadenceTimes.gapIndicators[0]) {
            startMjd = Math.nextUp(m.expandedCadenceTimes.startMjd());
            endMjd = Math.nextAfter(m.expandedCadenceTimes.endMjd(), 0);
            log.warn("Erasing cosmic rays for gapped mjd interval [" + 
                startMjd + "," + endMjd + "]");
        } else {
            startMjd =  m.cadenceTimes.startMjd();
            endMjd = m.cadenceTimes.endMjd();
        }
        cosmicRayEraser.storeAndErase(startMjd, endMjd, m.originator.getId());
    }

    /**
     * Creates a list of {@link FloatMjdTimeSeries} instances that collectively
     * represent all the given cosmic ray events in collateral pixel data.
     * 
     * @param crsFsIdsByCalCosmicRay map from a cosmic ray event to it's
     * corresponding {@code FsId}.
     * @param calCosmicRays list of cosmic ray events in collateral data.  This
     * may not be in mjd order so this method will sort them into mjd order.
     * @return a list of {@link FloatMjdTimeSeries}..
     */
    private List<FloatMjdTimeSeries> createCosmicRaySeries(
        Map<CalCollateralCosmicRay, FsId> crsFsIdsByCalCosmicRay,
        List<CalCollateralCosmicRay> calCosmicRays) {

        List<FloatMjdTimeSeries> cosmicRaySeries = new ArrayList<FloatMjdTimeSeries>();

        Map<FsId, CosmicRaySeriesData> cosmicRaySeriesDataByFsId = new HashMap<FsId, CosmicRaySeriesData>();

        Collections.sort(calCosmicRays, new Comparator<CalCollateralCosmicRay>()  {

            public int compare(CalCollateralCosmicRay o1, CalCollateralCosmicRay o2) {
                return Double.compare(o1.getMjd(), o2.getMjd());
            }
            
        });
        
        for (CalCollateralCosmicRay calCosmicRay : calCosmicRays) {
            FsId fsId = crsFsIdsByCalCosmicRay.get(calCosmicRay);
            CosmicRaySeriesData cosmicRaySeriesData = cosmicRaySeriesDataByFsId.get(fsId);
            if (cosmicRaySeriesData == null) {
                cosmicRaySeriesData = new CosmicRaySeriesData(fsId);
                cosmicRaySeriesDataByFsId.put(cosmicRaySeriesData.getFsId(), cosmicRaySeriesData);
            }

            cosmicRaySeriesData.add(calCosmicRay.getMjd(), calCosmicRay.getDelta());
        }

        for (CosmicRaySeriesData data : cosmicRaySeriesDataByFsId.values()) {
            FloatMjdTimeSeries cosmicRay = new FloatMjdTimeSeries(data.getFsId(), m.cadenceTimes.startMjd(),
                m.cadenceTimes.endMjd(), data.getTimes(), data.getValues(), m.originator.getId());
            cosmicRaySeries.add(cosmicRay);
        }
        return cosmicRaySeries;
    }
    
    
    protected CosmicRayEraser getCosmicRayEraser(
        List<FloatMjdTimeSeries> cosmicRaySeries, List<FsId> allIds) {
        return new CosmicRayEraser(cosmicRaySeries, allIds);
    }
    
    protected AlertService getAlertService() {
        return AlertServiceFactory.getInstance();
    }
    
    protected PmrfOperations getPmrfOps() {
        return new PmrfOperations(Duplication.ALLOWED);
    }
    
    protected FileStoreClient getFsClient() {
        return FileStoreClientFactory.getInstance();
    }
    
    protected CalCrud getCalCrud() {
        return new CalCrud();
    }
    
    protected PipelineTaskCrud getPipelineTaskCrud() {
        return new PipelineTaskCrud();
    }
    
    protected TimestampSeries getCadenceTimes(CadenceType cadenceType,
        PipelineInstance calPipelineInstance, int startCadence, int endCadence) {
        MjdToCadence mjdToCadence = new MjdToCadence(cadenceType, new ModelMetadataRetrieverPipelineInstance(calPipelineInstance));
        return mjdToCadence.cadenceTimes(startCadence, endCadence, false);
    }

}
