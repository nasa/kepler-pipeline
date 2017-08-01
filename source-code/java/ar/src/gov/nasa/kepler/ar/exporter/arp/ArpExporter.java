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

package gov.nasa.kepler.ar.exporter.arp;

import static gov.nasa.kepler.ar.exporter.binarytable.BinaryTableUtils.padBinaryTableData;
import static gov.nasa.kepler.ar.exporter.binarytable.SingleCadenceImageWriter.newImageWriter;

import java.io.DataOutput;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.*;

import gov.nasa.kepler.ar.exporter.ExposureCalculator;
import gov.nasa.kepler.ar.exporter.FileNameFormatter;
import gov.nasa.kepler.ar.exporter.FitsChecksumOutputStream;
import gov.nasa.kepler.ar.exporter.PixelByRowColumn;
import gov.nasa.kepler.ar.exporter.QualityFieldCalculator;
import gov.nasa.kepler.ar.exporter.RollingBandFlags;
import gov.nasa.kepler.ar.exporter.binarytable.ArrayDimensions;
import gov.nasa.kepler.ar.exporter.binarytable.BaseBinaryTableHeaderSource;
import gov.nasa.kepler.ar.exporter.binarytable.BinaryTableUtils;
import gov.nasa.kepler.ar.exporter.binarytable.DoubleToFloatArrayDataCopier;
import gov.nasa.kepler.ar.exporter.binarytable.FloatArrayDataCopier;
import gov.nasa.kepler.ar.exporter.binarytable.FloatMjdArrayDataCopier;
import gov.nasa.kepler.ar.exporter.binarytable.IntArrayDataCopier;
import gov.nasa.kepler.ar.exporter.binarytable.PixelListBinaryTableHeaderFormatter;
import gov.nasa.kepler.ar.exporter.binarytable.SingleCadenceImageWriter;
import gov.nasa.kepler.ar.exporter.primary.BasePrimaryHeaderSource;
import gov.nasa.kepler.ar.exporter.primary.PrimaryHeaderFormatter;
import gov.nasa.kepler.ar.exporter.tpixel.DataQualityFlagsSource;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.FitsConstants;
import gov.nasa.kepler.common.FitsConstants.ObservingMode;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.fs.DynablackFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import nom.tam.fits.FitsException;
import nom.tam.fits.Header;
import nom.tam.util.ArrayDataOutput;
import nom.tam.util.BufferedDataOutputStream;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

/**
 * Exports the Artifact Mitigation Pixels (ARP).  These pixels are special
 * targets that are not on science pixels.
 * 
 * @author Sean McCauliff
 *
 */
final class ArpExporter {

    private final static Log log = LogFactory.getLog(ArpExporter.class);
    
    public void export(ArpExporterSource source) throws IOException, FitsException  {
        
        boolean isK2 = source.startMidMjd() >= FcConstants.KEPLER_END_OF_MISSION_MJD;
        
        if (source.arpObservedTarget() == null) {
            log.warn("mod/out " + source.ccdModule() + "/" + source.ccdOutput() 
                     + " does not contain an ARP target.");
            return;
        }
        
        final double startStartMjd = source.cadenceTimes().startTimestamps[0];
        final double endEndMjd = source.cadenceTimes().endTimestamps[source.cadenceTimes().endTimestamps.length - 1];
        
        SortedMap<Pixel, FsIdsPerPixel> sortedPixels = pixels(source);
        Set<FsId> allTimeSeriesFsIds = new HashSet<FsId>(sortedPixels.size() * 3);
        Set<FsId> allMjdTimeSeriesFsIds = new HashSet<FsId>(sortedPixels.size());
        Set<FsId> collateralCosmicRayIds = new HashSet<FsId>(sortedPixels.size());
        for (FsIdsPerPixel idsPerPixel : sortedPixels.values()) {
            idsPerPixel.allTo(allTimeSeriesFsIds);
            idsPerPixel.addAllMjd(allMjdTimeSeriesFsIds);
            collateralCosmicRayIds.addAll(idsPerPixel.collateralCr);
        }
        
        FsId paArgabrighteningId = 
            PaFsIdFactory.getArgabrighteningFsId(CadenceType.LONG,
                source.targetTableId(), source.ccdModule(), source.ccdOutput());
        FsId zeroCrossingsIds = 
            PaFsIdFactory.getZeroCrossingFsId(CadenceType.LONG);
        
        allTimeSeriesFsIds.add(paArgabrighteningId);
        allTimeSeriesFsIds.add(zeroCrossingsIds);
        
        FileStoreClient fsClient = source.fileStoreClient();
        Map<FsId, FloatMjdTimeSeries> cosmicRays =
            fsClient.readMjdTimeSeries(allMjdTimeSeriesFsIds,startStartMjd, endEndMjd);
        
        Map<FsId, TimeSeries> allTimeSeries = 
            fsClient.readTimeSeries(allTimeSeriesFsIds, source.startCadence(), source.endCadence(), false);
        subtractCosmicRays(source.mjdToCadence(), sortedPixels.values(), allTimeSeries, cosmicRays);
        
        for (FsIdsPerPixel fsIdsPerPixel : sortedPixels.values()) {
            fillTimeSeries(fsIdsPerPixel.raw, allTimeSeries);
        }
        
        final Set<FsId> rollingBandFsIds = Sets.newHashSet();
        for (FsIdsPerPixel fsIdsPerPixel : sortedPixels.values()) {
            rollingBandFsIds.addAll(fsIdsPerPixel.rollingBandFlags);
        }
        
        DataQualityFlagsSource dataQualityFlagsSource = 
            createDataQualityFlagsSource(source, allTimeSeries, cosmicRays,
                paArgabrighteningId, zeroCrossingsIds, collateralCosmicRayIds,
                rollingBandFsIds);
        
        QualityFieldCalculator qualityFieldCalc = new QualityFieldCalculator();
        int[] quality = qualityFieldCalc.calculateQualityFlags(dataQualityFlagsSource);
        
        ExposureCalculator exposureCalc = 
            new ExposureCalculator(source.configMaps(), allTimeSeries.values(),
                CadenceType.LONG, startStartMjd, endEndMjd,
                source.startCadence(), source.endCadence());
        
        Date observationStartUtc =  ModifiedJulianDate.mjdToDate(startStartMjd);
        Date observationEndUtc = ModifiedJulianDate.mjdToDate(endEndMjd);
        
        ArpPrimaryHeader primaryHeaderFormatter = new ArpPrimaryHeader();
        BasePrimaryHeaderSource primarySource = createBasePrimaryHeaderSource(source, isK2);
        
        ArpBinaryTableHeaderFormatter binTableFormatter = 
            new ArpBinaryTableHeaderFormatter();
        
        ArpBinaryTableHeaderSource binTableSource = 
            createArpHeaderSource(source, exposureCalc, observationStartUtc, observationEndUtc,
                source.endCadence() - source.startCadence() + 1);
                
        
        PixelListBinaryTableHeaderFormatter pixelListHeaderFormatter = 
            new PixelListBinaryTableHeaderFormatter();
        BaseBinaryTableHeaderSource pixelListSource = 
            createPixelListHeaderSource(source, exposureCalc, observationStartUtc, observationEndUtc,
                sortedPixels.size());
        
        final FitsChecksumOutputStream primaryChecksum = new FitsChecksumOutputStream();
        final BufferedDataOutputStream primaryChecksumOut = new BufferedDataOutputStream(primaryChecksum);
        final FitsChecksumOutputStream binaryTableChecksum = new FitsChecksumOutputStream();
        final BufferedDataOutputStream binaryTableChecksumOut = new BufferedDataOutputStream(binaryTableChecksum);
        final FitsChecksumOutputStream pixelListChecksum = new FitsChecksumOutputStream();
        final BufferedDataOutputStream pixelListChecksumOut = new BufferedDataOutputStream(pixelListChecksum);
        
        
        OutputsAndChecksums generateChecksums = new OutputsAndChecksums() {
            
            @Override
            public ArrayDataOutput primaryHeaderOutput() {
                return primaryChecksumOut;
            }
            
            @Override
            public String primaryHeaderChecksum() {
                return FitsConstants.CHECKSUM_DEFAULT;
            }
            
            @Override
            public ArrayDataOutput pixelListOutput() {
                return pixelListChecksumOut;
            }
            
            @Override
            public String pixelListChecksum() {
                return FitsConstants.CHECKSUM_DEFAULT;
            }
            
            @Override
            public ArrayDataOutput binaryTableOutput() {
                return binaryTableChecksumOut;
            }
            
            @Override
            public String binaryTableChecksum() {
                return FitsConstants.CHECKSUM_DEFAULT;
            }
        };
        
        
        
       
        log.info("Generating checksums for ARP " + source.ccdModule() + "/" + source.ccdOutput() + ".");
        writeFile(generateChecksums, source, exposureCalc,
            sortedPixels, allTimeSeries, cosmicRays, quality,
            primaryHeaderFormatter, primarySource,
            binTableFormatter, binTableSource,
            pixelListHeaderFormatter, pixelListSource);
        
        FileNameFormatter fnameFormatter = new FileNameFormatter();
        String fname;
        if (isK2) {
            fname = fnameFormatter.k2ArpName(source.k2Campaign(), source.ccdModule(), source.ccdOutput());
        } else {
            fname = fnameFormatter.arpName(source.fileTimestamp(), source.ccdModule(), source.ccdOutput());
        }
        File outputFile = new File(source.exportDir(), fname);
        log.info("Writing file: \"" + outputFile + "\".");
        FileOutputStream fout = new FileOutputStream(outputFile);
        final BufferedDataOutputStream allOut = new BufferedDataOutputStream(fout);
        
        OutputsAndChecksums realOutput = new OutputsAndChecksums() {
            
            @Override
            public ArrayDataOutput primaryHeaderOutput() {
                return allOut;
            }
            
            @Override
            public String primaryHeaderChecksum() {
                return primaryChecksum.checksumString();
            }
            
            @Override
            public ArrayDataOutput pixelListOutput() {
                return allOut;
            }
            
            @Override
            public String pixelListChecksum() {
                return pixelListChecksum.checksumString();
            }
            
            @Override
            public ArrayDataOutput binaryTableOutput() {
                return allOut;
            }
            
            @Override
            public String binaryTableChecksum() {
                return binaryTableChecksum.checksumString();
            }
        };

        writeFile(realOutput, source, exposureCalc,
            sortedPixels, allTimeSeries, cosmicRays, quality,
            primaryHeaderFormatter, primarySource,
            binTableFormatter, binTableSource, 
            pixelListHeaderFormatter, pixelListSource);
        
        allOut.close();
        log.info("Writing file \"" + outputFile + "\" complete.");
       
    }

    private void fillTimeSeries(FsId id, Map<FsId, TimeSeries> allTimeSeries) {
        TimeSeries timeSeries = allTimeSeries.get(id);
        if (timeSeries instanceof IntTimeSeries) {
            IntTimeSeries its = (IntTimeSeries) timeSeries;
            its.fillGaps(BinaryTableUtils.INT_GAP_FILL);
        } else if (timeSeries instanceof FloatTimeSeries) {
            FloatTimeSeries fts = (FloatTimeSeries) timeSeries;
            fts.fillGaps(BinaryTableUtils.GAP_FILL);
        } else {
            throw new IllegalStateException("Unknown time series class " + timeSeries.getClass());
        }
    }

    /**
     * Subtracts cosmic ray values from the calibrated values making the results
     * double precision and putting the new double precision time series back
     * into the allTimeSeriesMap.
     * 
     * @param mjdToCadence
     * @param fsIdsPerPixel
     * @param allTimeSeries  this gets modified.
     * @param cosmicRays
     */
    private void subtractCosmicRays(MjdToCadence mjdToCadence,
        Collection<FsIdsPerPixel> fsIdsPerPixel,
        Map<FsId, TimeSeries> allTimeSeries, Map<FsId, FloatMjdTimeSeries> cosmicRays) {
        
        for (FsIdsPerPixel singlePixel : fsIdsPerPixel) {
            FloatTimeSeries calibrated = allTimeSeries.get(singlePixel.cal()).asFloatTimeSeries();
            FloatMjdTimeSeries cr = cosmicRays.get(singlePixel.cr());
            float[] calibratedData = calibrated.fseries();
            double[] crSubtractedData = new double[calibrated.cadenceLength()];
            for (int i=0; i < crSubtractedData.length; i++) {
                crSubtractedData[i] = calibratedData[i];
            }
            double[] cosmicRayMjd = cr.mjd();
            float[] cosmicRayValue = cr.values();
            for (int i=0; i < cosmicRayMjd.length; i++) {
                int cadenceIndex = mjdToCadence.mjdToCadence(cosmicRayMjd[i]) - calibrated.startCadence();
                crSubtractedData[cadenceIndex] -= cosmicRayValue[i];
            }
            DoubleTimeSeries cosmicRaySubtracted = 
                new DoubleTimeSeries(calibrated.id(), crSubtractedData,
                    calibrated.startCadence(), calibrated.endCadence(),
                    calibrated.validCadences(), calibrated.originators());
            cosmicRaySubtracted.fillGaps(BinaryTableUtils.GAP_FILL);
            allTimeSeries.put(calibrated.id(), cosmicRaySubtracted);
            
        }
    }
    
    private ArpBinaryTableHeaderSource createArpHeaderSource(final ArpExporterSource source,
        final ExposureCalculator exposureCalc, final Date observationStartUtc,
        final Date observationEndUtc, final int nRowsInTable) {
        
        return new ArpBinaryTableHeaderSource() {
            
            @Override
            public Integer timeSlice() {
                return FcConstants.getCcdModuleTimeSlice(source.ccdModule());
            }
            
            @Override
            public double timeResolutionOfDataDays() {
                return exposureCalc.cadenceDurationDays();
            }
            
            @Override
            public Integer shortCadenceFixedOffset() {
                return exposureCalc.shortCadenceFixedOffset();
            }
            
            @Override
            public double scienceFrameTimeSec() {
                return exposureCalc.scienceFrameSec();
            }
            
            @Override
            public int readsPerCadence() {
                return exposureCalc.numberOfScienceFramesPerCadence();
            }
            
            @Override
            public double readoutTimePerFrameSec() {
                return exposureCalc.readTimeSec();
            }
            
            @Override
            public Double readNoiseE() {
                return source.readNoiseE();
            }
            
            @Override
            public double photonAccumulationTimeSec() {
                return exposureCalc.integrationTimeSec();
            }
            
            @Override
            public Date observationStartUTC() {
                return observationStartUtc;
            }
            
            @Override
            public Date observationEndUTC() {
                return observationEndUtc;
            }
            
            @Override
            public int nBinaryTableRows() {
                return nRowsInTable;
            }
            
            @Override
            public Integer meanBlackCounts() {
                return source.meanBlack();
            }
            
            @Override
            public Integer longCadenceFixedOffset() {
                return exposureCalc.longCadenceFixedOffset();
            }
            
            @Override
            public Integer keplerId() {
                return null;
            }
            
            @Override
            public Date generatedAt() {
                return source.generatedAt();
            }
            
            @Override
            public Double gainEPerCount() {
                return source.gainEPerCount();
            }
            
            @Override
            public int framesPerCadence() {
                return exposureCalc.numberOfScienceFramesPerCadence();
            }
            
            @Override
            public String extensionName() {
                return "ARTIFACTREMOVAL";
            }
            
            @Override
            public boolean backgroundSubtracted() {
                return false;
            }

            @Override
            public double startMidMjd() {
                return source.startMidMjd();
            }

            @Override
            public double endMidMjd() {
                return source.endMidMjd();
            }

            @Override
            public double deadC() {
                return exposureCalc.deadC();
            }
        };
    }
    
    
    private BaseBinaryTableHeaderSource createPixelListHeaderSource(final ArpExporterSource source,
        final ExposureCalculator exposureCalc, 
        final Date observationStartUtc, final Date observationEndUtc,
        final int nRowsInTable) {
        
        return new BaseBinaryTableHeaderSource() {
            
            @Override
            public Integer timeSlice() {
                return FcConstants.getCcdModuleTimeSlice(source.ccdModule());
            }
            
            @Override
            public double timeResolutionOfDataDays() {
                return exposureCalc.cadenceDurationDays();
            }
            
            @Override
            public Integer shortCadenceFixedOffset() {
                return exposureCalc.shortCadenceFixedOffset();
            }
            
            @Override
            public double scienceFrameTimeSec() {
                return exposureCalc.scienceFrameSec();
            }
            
            @Override
            public int readsPerCadence() {
                return exposureCalc.numberOfScienceFramesPerCadence();
            }
            
            @Override
            public double readoutTimePerFrameSec() {
                return exposureCalc.readTimeSec();
            }
            
            @Override
            public Double readNoiseE() {
                return source.readNoiseE();
            }
            
            @Override
            public double photonAccumulationTimeSec() {
                return exposureCalc.integrationTimeSec();
            }
            
            @Override
            public Date observationStartUTC() {
                return observationStartUtc;
            }
            
            @Override
            public Date observationEndUTC() {
                return observationEndUtc;
            }
            
            @Override
            public int nBinaryTableRows() {
                return nRowsInTable;
            }
            
            @Override
            public Integer meanBlackCounts() {
                return source.meanBlack();
            }
            
            @Override
            public Integer longCadenceFixedOffset() {
                return exposureCalc.longCadenceFixedOffset();
            }
            
            @Override
            public Integer keplerId() {
                return null;
            }
            
            @Override
            public Date generatedAt() {
                return source.generatedAt();
            }
            
            @Override
            public Double gainEPerCount() {
                return source.gainEPerCount();
            }
            
            @Override
            public int framesPerCadence() {
                return exposureCalc.numberOfScienceFramesPerCadence();
            }
            
            @Override
            public String extensionName() {
                return "PIXELS";
            }
            
            @Override
            public boolean backgroundSubtracted() {
                return false;
            }
        };
        
    }

    private DataQualityFlagsSource createDataQualityFlagsSource(
        final ArpExporterSource source,
        final Map<FsId, TimeSeries> allTimeSeries,
        final Map<FsId, FloatMjdTimeSeries> cosmicRays,
        final FsId paArgabrighteningId, final FsId zeroCrossingsIds,
        final Set<FsId> collateralCosmicRayIds,
        final Set<FsId> rollingBandFsIds) {
        
        final List<FloatMjdTimeSeries> collateralCosmicRays = 
            Lists.newArrayListWithCapacity(collateralCosmicRayIds.size());
        for (FsId collateralCrId : collateralCosmicRayIds) {
            collateralCosmicRays.add(cosmicRays.get(collateralCrId));
        }
        
        final RollingBandFlags rbFlags = RollingBandFlags.newRollingBandFlags(allTimeSeries, rollingBandFsIds);
        
        return new DataQualityFlagsSource() {
            
            @Override
            public int startCadence() {
                return source.startCadence();
            }
            
            @Override
            public IntTimeSeries reactionWheelZeroCrossings() {
                return allTimeSeries.get(zeroCrossingsIds).asIntTimeSeries();
            }
            
            /**
             * This can return null since we don't care about the PDC outliers
             * for ARP targets.
             */
            @Override
            public FloatMjdTimeSeries pdcOutliers() {
                return null;
            }
            
            @Override
            public IntTimeSeries paArgabrighteningTimeSeries() {
                return allTimeSeries.get(paArgabrighteningId).asIntTimeSeries();
            }
            
            @Override
            public MjdToCadence mjdToCadence() {
                return source.mjdToCadence();
            }
            
            @Override
            public TimestampSeries timestampSeries() {
                return source.cadenceTimes();
            }
            
            @Override
            public int endCadence() {
                return source.endCadence();
            }
            
            /**
             * PDC discontinuities mean nothing for ARP targets.
             */
            @Override
            public IntTimeSeries discontinuityTimeSeries() {
                return null;
            }
            
            /**
             * Returns null because we don't have an optimal aperture.
             */
            @Override
            public Collection<FloatMjdTimeSeries> cosmicRays() {
                return Collections.emptyList();
            }

            @Override
            public Collection<FloatMjdTimeSeries> collateralCosmicRays() {
                return collateralCosmicRays;
            }
            
            @Override
            public List<DataAnomaly> anomalies() {
                return source.dataAnomalies();
            }

            @Override
            public RollingBandFlags rollingBandFlags() {
                return rbFlags;
            }

            @Override
            public TimestampSeries lcTimestampSeries() {
                return null; //OK, never have short cadence.
            }

            @Override
            public IntTimeSeries thrusterFire() {
                return null; //OK, these targets do not exist for K2.
            }

            @Override
            public IntTimeSeries possibleThusterFire() {
                return null; //OK, these targets do not exist for K2.
            }

            @Override
            public boolean isLcForShortCadence() {
                return false;
            }

            @Override
            public RollingBandFlags optimalApertureRollingBandFlags() {
                return null; //OK no optimal aperture.
            }

        };
    }

    private SortedMap<Pixel, FsIdsPerPixel> pixels(ArpExporterSource source) {
        SciencePixelOperations sciOps = source.sciencePixelOps();
        ObservedTarget arpTarget = source.arpObservedTarget();
        Set<Pixel> unsortedPixels = 
            sciOps.loadTargetPixels(arpTarget, source.ccdModule(), source.ccdOutput());
        SortedMap<Pixel, FsIdsPerPixel> sortedPixels = 
            new TreeMap<Pixel, FsIdsPerPixel>(PixelByRowColumn.INSTANCE);
        for (Pixel px : unsortedPixels) {
            sortedPixels.put(px, new FsIdsPerPixel(px, source.ccdModule(), source.ccdOutput(), source.rollingBandPulseDurationsLc()));
        }
        
        return sortedPixels;
    }
    private void writeFile(OutputsAndChecksums outputsAndChecksums,
        ArpExporterSource source, ExposureCalculator exposureCalc,
        SortedMap<Pixel, FsIdsPerPixel> idsByPixel,
        Map<FsId, TimeSeries> allTimeSeries, Map<FsId, FloatMjdTimeSeries> cosmicRays,
        int[] quality, ArpPrimaryHeader primaryHeaderFormatter,
        BasePrimaryHeaderSource primarySource, 
        ArpBinaryTableHeaderFormatter binTableFormatter,
        ArpBinaryTableHeaderSource binTableSource,
        PixelListBinaryTableHeaderFormatter pixelListHeaderFormatter, BaseBinaryTableHeaderSource pixelListSource) throws IOException, FitsException {

        Header primaryHeader = 
            primaryHeaderFormatter.formatHeader(primarySource, outputsAndChecksums.primaryHeaderChecksum());
        
        primaryHeader.write(outputsAndChecksums.primaryHeaderOutput());
        
        outputsAndChecksums.primaryHeaderOutput().flush();
        
        ArrayDimensions arrayDims = ArrayDimensions.newInstance(idsByPixel.size());
        Header binTableHeader = 
            binTableFormatter.formatHeader(binTableSource, arrayDims,
                outputsAndChecksums.binaryTableChecksum());
        binTableHeader.write(outputsAndChecksums.binaryTableOutput());
        
        writeTableData(idsByPixel.values(), allTimeSeries, cosmicRays, quality,
            source.cadenceTimes(), outputsAndChecksums.binaryTableOutput(),
            exposureCalc, source.startCadence(), source.endCadence(),
            source.mjdToCadence());
        
 
        long nBytesWritten = binTableFormatter.bytesPerTableRow(arrayDims)
        * (source.endCadence() - source.startCadence() + 1);
        padBinaryTableData(nBytesWritten, outputsAndChecksums.binaryTableOutput());
        outputsAndChecksums.binaryTableOutput().flush();
        
        Header pixelListHeader = 
            pixelListHeaderFormatter.formatHeader(pixelListSource, 1, outputsAndChecksums.pixelListChecksum());
        pixelListHeader.write(outputsAndChecksums.pixelListOutput());
        writeOutPixels(idsByPixel.keySet(), outputsAndChecksums.pixelListOutput());
        nBytesWritten = pixelListHeaderFormatter.bytesPerTableRow(arrayDims) *
            idsByPixel.size();
        padBinaryTableData(nBytesWritten, outputsAndChecksums.pixelListOutput());
        outputsAndChecksums.pixelListOutput().flush();
    }
    
    private void writeTableData(Collection<FsIdsPerPixel> byPixel,
        Map<FsId, TimeSeries> allTimeSeries,  Map<FsId, FloatMjdTimeSeries> cosmicRays,
        int[] quality, TimestampSeries cadenceTimes,
        DataOutput out, ExposureCalculator exposureCalc, 
        int startCadence, int endCadence, MjdToCadence mjdToCadence) throws IOException {
        List<FsId> rawPixelIds = collectFsIds(byPixel, SelectRaw.INST);
        SingleCadenceImageWriter<TimeSeries> rawWriter = 
            newImageWriter(rawPixelIds, 
                allTimeSeries, new IntArrayDataCopier(), out);
        List<FsId> calPixelIds = collectFsIds(byPixel, SelectCal.INST);
        SingleCadenceImageWriter<TimeSeries> calWriter = 
            newImageWriter(calPixelIds,
                allTimeSeries, new DoubleToFloatArrayDataCopier(exposureCalc), out);
        List<FsId> ummPixelIds = collectFsIds(byPixel, SelectUmm.INST);
        SingleCadenceImageWriter<TimeSeries> ummWriter = 
            newImageWriter(ummPixelIds,
                allTimeSeries, new FloatArrayDataCopier(exposureCalc),
                out);
        List<FsId> crPixelIds = collectFsIds(byPixel, SelectCr.INST);
        SingleCadenceImageWriter<FloatMjdTimeSeries> crWriter =
            newImageWriter(crPixelIds, cosmicRays,
                new FloatMjdArrayDataCopier(startCadence, mjdToCadence, exposureCalc),
                out);
        for (int c=startCadence; c <= endCadence; c++) {
            int index = c - startCadence;
            out.writeDouble(cadenceTimes.midTimestamps[index]);
            out.writeInt(c);
            rawWriter.writeSingleCadenceImage(index);
            calWriter.writeSingleCadenceImage(index);
            ummWriter.writeSingleCadenceImage(index);
            crWriter.writeSingleCadenceImage(index);
            out.writeInt(quality[index]);
        }
    }

    private void writeOutPixels(Collection<Pixel> pixels, DataOutput out) throws IOException {
        for (Pixel px : pixels) {
            out.writeInt(px.getColumn());
            out.writeInt(px.getRow());
        }
    }
    
    private BasePrimaryHeaderSource createBasePrimaryHeaderSource(
        final ArpExporterSource source, final boolean isK2) {

        
        return new BasePrimaryHeaderSource() {
            
            @Override
            public String subversionUrl() {
                return source.subversionUrl();
            }
            
            @Override
            public String subversionRevision() {
                return source.subversionRevision();
            }
            
            @Override
            public Integer skyGroup() {
                return source.skyGroup();
            }
            
            @Override
            public int season() {
                return source.season();
            }
            
            @Override
            public double raDegrees() {
                return -1;
            }
            
            @Override
            public int quarter() {
                return source.quarter();
            }
            
            @Override
            public String programName() {
                return source.programName();
            }
            
            @Override
            public long pipelineTaskId() {
                return source.pipelineTaskId();
            }
            
            @Override
            public ObservingMode observingMode() {
                return ObservingMode.LONG_CADENCE;
            }
            
            @Override
            public int keplerId() {
                return PrimaryHeaderFormatter.NO_KEPLER_ID;
            }
            
            @Override
            public Date generatedAt() {
                return source.generatedAt();
            }
            
            @Override
            public int dataReleaseNumber() {
                return source.dataReleaseNumber();
            }
            
            @Override
            public int ccdOutput() {
                return source.ccdOutput();
            }
            
            @Override
            public int ccdModule() {
                return source.ccdModule();
            }
            
            @Override
            public int ccdChannel() {
                return FcConstants.getChannelNumber(source.ccdModule(), source.ccdOutput());
            }

            @Override
            public int k2Campaign() {
                return source.k2Campaign();
            }

            @Override
            public boolean isK2Target() {
                return isK2;
            }

            @Override
            public int targetTableId() {
                return source.targetTableId();
            }

            @Override
            public int extensionHduCount() {
                return 2;
            }
        };
        
    }
    
    private static final class FsIdsPerPixel {
        private final FsId raw;
        private final FsId cal;
        private final FsId umm;
        private final FsId cr;
        private final List<FsId> collateralCr = new ArrayList<FsId>(3);
        private final List<FsId> rollingBandFlags = new ArrayList<FsId>();
        
        public FsIdsPerPixel(Pixel px, int ccdModule, int ccdOutput, int[] rollingBandFlagPulseDurations) {
            raw = DrFsIdFactory.getSciencePixelTimeSeries(DrFsIdFactory.TimeSeriesType.ORIG,
                TargetTable.TargetType.LONG_CADENCE, ccdModule, ccdOutput,
                px.getRow(), px.getColumn());
            cal = CalFsIdFactory.getTimeSeriesFsId(CalFsIdFactory.PixelTimeSeriesType.SOC_CAL,
                TargetTable.TargetType.LONG_CADENCE, ccdModule, ccdOutput,
                px.getRow(), px.getColumn());
            umm = CalFsIdFactory.getTimeSeriesFsId(CalFsIdFactory.PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES,
                TargetTable.TargetType.LONG_CADENCE, ccdModule, ccdOutput,
                px.getRow(), px.getColumn());
            cr = PaFsIdFactory.getCosmicRaySeriesFsId(TargetTable.TargetType.LONG_CADENCE,
                ccdModule, ccdOutput, px.getRow(), px.getColumn());
            collateralCr.add(CalFsIdFactory.getCosmicRaySeriesFsId(CollateralType.BLACK_LEVEL,
                CadenceType.LONG, ccdModule, ccdOutput, px.getRow()));
            collateralCr.add(CalFsIdFactory.getCosmicRaySeriesFsId(CollateralType.MASKED_SMEAR,
                CadenceType.LONG, ccdModule, ccdOutput, px.getColumn()));
            collateralCr.add(CalFsIdFactory.getCosmicRaySeriesFsId(CollateralType.VIRTUAL_SMEAR,
                CadenceType.LONG, ccdModule, ccdOutput, px.getColumn()));
            for (int rbPulseDuration : rollingBandFlagPulseDurations) {
                rollingBandFlags.add(DynablackFsIdFactory.getRollingBandArtifactFlagsFsId(ccdModule, ccdOutput, px.getRow(), rbPulseDuration));
            }
        }
        
        public FsId raw() {
            return raw;
        }
        
        public FsId cal() {
            return cal;
        }
        
        public FsId umm() {
            return umm;
        }
        
        public FsId cr() {
            return cr;
        }
        
        public void allTo(Collection<FsId> dest) {
            dest.add(raw);
            dest.add(cal);
            dest.add(umm);
            dest.addAll(rollingBandFlags);
        }
        
        public void addAllMjd(Collection<FsId> dest) {
            dest.add(cr);
            dest.addAll(collateralCr);
        }
    }
    
    //TODO: there might be a way to share this code with other expoerters.
    private static final List<FsId> collectFsIds(Collection<FsIdsPerPixel> byPixel, FsIdSelector selector) {
        List<FsId> rv = Lists.newArrayListWithCapacity(byPixel.size());
        for (FsIdsPerPixel fsIds : byPixel) {
            rv.add(selector.apply(fsIds));
        }
        return rv;
    }
    
    private interface FsIdSelector {
        FsId apply(FsIdsPerPixel perPixelFsIds);
    }
    
    private static final class SelectRaw implements FsIdSelector {
        public static final SelectRaw INST = new SelectRaw();
        public FsId apply(FsIdsPerPixel perPixelFsIds) {
            return perPixelFsIds.raw();
        }
    }
    
    private static final class SelectCal implements FsIdSelector {
        public static final SelectCal INST = new SelectCal();
        public FsId apply(FsIdsPerPixel perPixelFsIds) {
            return perPixelFsIds.cal();
        }
    }
    
    private static final class SelectUmm implements FsIdSelector {
        public static final SelectUmm INST = new SelectUmm();
        public FsId apply(FsIdsPerPixel perPixelFsIds) {
            return perPixelFsIds.umm();
        }
    }
    
    private static final class SelectCr implements FsIdSelector {
        public static final SelectCr INST = new SelectCr();
        public FsId apply(FsIdsPerPixel perPixelFsIds) {
            return perPixelFsIds.cr();
        }
    }
}
