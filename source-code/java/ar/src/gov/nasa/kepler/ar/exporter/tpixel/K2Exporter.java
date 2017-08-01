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

package gov.nasa.kepler.ar.exporter.tpixel;

import static gov.nasa.kepler.ar.exporter.binarytable.BinaryTableUtils.GAP_FILL;
import static gov.nasa.kepler.ar.exporter.binarytable.BinaryTableUtils.padBinaryTableData;
import static gov.nasa.kepler.ar.exporter.binarytable.SingleCadenceImageWriter.newImageWriter;
import static gov.nasa.kepler.common.FitsConstants.RB_LEVEL_TCOLUMN;
import gnu.trove.TLongHashSet;
import gov.nasa.kepler.ar.exporter.AbstractSingleQuarterTargetExporter;
import gov.nasa.kepler.ar.exporter.AbstractTargetMetadata;
import gov.nasa.kepler.ar.exporter.ApertureMaskImageBuilder;
import gov.nasa.kepler.ar.exporter.CelestialWcsKeywordValueSource;
import gov.nasa.kepler.ar.exporter.ChecksumsAndOutputs;
import gov.nasa.kepler.ar.exporter.ExposureCalculator;
import gov.nasa.kepler.ar.exporter.FileNameFormatter;
import gov.nasa.kepler.ar.exporter.SingleQuarterExporterSource;
import gov.nasa.kepler.ar.exporter.RmsCdpp;
import gov.nasa.kepler.ar.exporter.TargetMetadataFactory;
import gov.nasa.kepler.ar.exporter.binarytable.ArrayDimensions;
import gov.nasa.kepler.ar.exporter.binarytable.FloatArrayDataCopier;
import gov.nasa.kepler.ar.exporter.binarytable.IntArrayDataCopier;
import gov.nasa.kepler.ar.exporter.binarytable.SingleCadenceImageWriter;
import gov.nasa.kepler.ar.exporter.primary.TargetPrimaryHeaderFormatter;
import gov.nasa.kepler.ar.exporter.tpixel.TargetImageDimensionCalculator.TargetImageDimensions;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.cal.BlackAlgorithm;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tps.AbstractTpsDbResult;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.DataOutput;
import java.io.IOException;
import java.util.*;

import nom.tam.fits.FitsException;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;
import nom.tam.util.ArrayDataOutput;
import nom.tam.util.BufferedDataOutputStream;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Similar to the target pixel exporter except that we only assume that K2 data
 * exists in the datastore: that is calibrated pixels and original TAD
 * information (no supplemental data).
 * 
 * @author Sean McCauliff
 *
 */
public final class K2Exporter extends AbstractSingleQuarterTargetExporter<K2Target, K2Source> {

    private final Log log = LogFactory.getLog(K2Exporter.class);
   
    private final PixelOutputStreamFactory outputStreamFactory;
    
    public K2Exporter() {
        outputStreamFactory =  new PixelOutputStreamFactory() {
            @Override
            protected String fileName(TargetPixelMetadata targetMetadata, String fileTimestamp, CadenceType cadenceType, boolean useGzip) {
                FileNameFormatter fnameFormatter = new FileNameFormatter();
                String fname = fnameFormatter.k2TargetPixelName(targetMetadata.keplerId(),
                    targetMetadata.k2Campaign(), cadenceType == CadenceType.SHORT, useGzip);
                return fname;
            }
        };
    }
    
    /**
     * Export target pixel files.
     * 
     * @param source
     * @return The set of pipeline task ids which generated the source
     * information.
     * @throws IOException
     * @throws FitsException
     */
    public TLongHashSet exportPixelsForTargets(
        final K2Source source) throws IOException,
        FitsException {

        TargetMetadataFactory<K2Target> metadataFactory = 
            new TargetMetadataFactory<K2Target>() {
                
                @Override
                public K2Target create(CelestialObject celestialObject,
                    Set<Pixel> targetPixels, ObservedTarget observedTarget,
                    RmsCdpp targetCdpp) {

                    int keplerId = celestialObject.getKeplerId();
                    
                    K2Target m = 
                        new K2Target(celestialObject,
                        source.cadenceType(),
                        targetPixels, source.ccdModule(), source.ccdOutput(),
                        source, 
                        source.wasTargetDroppedBySupplementalTad(keplerId),
                        observedTarget.getClippedPixelCount(),
                        targetCdpp, null,
                        source.longCadenceTimestampSeries(),
                        source.k2Campaign(), source.targetTableExternalId());
                    
                    return m;
                }
            };
        
        ExportData<K2Target> exportData = 
            exportData(source, null, metadataFactory);
        
        Set<Pixel> allPixels = new HashSet<Pixel>(exportData.targetMetdatas.size() * 2 * 32);
        for (K2Target metadata : exportData.targetMetdatas) {
            allPixels.addAll(metadata.aperturePixels());
        }
        
        for (K2Target targetMetadata : exportData.targetMetdatas) {
            log.info("Writing file for target with kepler id "
                + targetMetadata.keplerId());
            exportFile(targetMetadata, source, exportData);
        }
        
        return exportData.originators;
    }
    
    /**
     * We don't have motion polynomials so we don't attempt to compute a position correction.
     */
    @Override
    protected void targetPositionCorrections(
            final SingleQuarterExporterSource source,
            SortedMap<Integer, K2Target> keplerIdToTargetPixelMetadata,
            Pair<Map<FsId, TimeSeries>, Map<FsId, FloatMjdTimeSeries>> allTimeSeries) {
    	
    }
    /** This implementation always returns true.
     * 
     */
    @Override
    protected boolean checkExport(
        K2Target targetMetadata,
        K2Source source,
        ExportData<K2Target> exportData) {
        
        return true;
    }

    @Override
    protected BufferedDataOutputStream outputStream(K2Target targetMetadata,
        K2Source source,
        ExportData<K2Target> exportData) throws IOException {
        
        return outputStreamFactory.outputStream(targetMetadata, source, exportData);

    }
    
    /**
     * This does nothing.
     */
    @Override
    protected void fetchRollingBandFlags(
        int targetTableExternalId,
        SortedMap<Integer, ? extends AbstractTargetMetadata> keplerIdToTargetMetadata,
        TimestampSeries longCadenceTimestampSeries,
        FileStoreClient fsClient) { 
    }
    
    /**
     * Produce an aperture mask image with only the collected flag set when needed.
     */
    @Override
    protected int apertureMaskPixelMask() {
        return ApertureMaskImageBuilder.PIXEL_WAS_COLLECTED;
    }
    
    
    /**
     * @return an empty map
     */
    @Override
    protected <T extends AbstractTpsDbResult> Map<Integer, RmsCdpp> toTpsDbResultMap(
        List<T> rawResults) {
        return Collections.emptyMap();
    }
    
    
    
    @Override
    protected void writeFileUnsafe(
        K2Source k2Source,
        K2Target targetMetadata,
        ExportData<K2Target> exportData,
        ChecksumsAndOutputs outputs) throws IOException, FitsException {

        final TargetTime ttime = targetTime(k2Source, targetMetadata,
            exportData.allTimeSeries, GAP_FILL);
        
        TargetPrimaryHeaderFormatter primaryHeaderFormatter = new TargetPrimaryHeaderFormatter();
        Header primaryHeader = primaryHeaderFormatter.formatHeader(targetMetadata, outputs.checksums().get(0));
        primaryHeader.write(outputs.outputs().get(0));

        SortedMap<Pixel, TimeSeries> rawPixels = 
            targetMetadata.rawPixels(exportData.allTimeSeries);
        final ExposureCalculator exposureCalc = new ExposureCalculator(
            k2Source.configMaps(), rawPixels.values(), ttime.cadenceType, ttime.startBkjd,
            ttime.endBkjd, ttime.actualStart, ttime.actualEnd);

        CelestialWcsKeywordValueSource celestialWcs =  
        		createCelestialWcsKeywordValueSource(targetMetadata, exportData.allTimeSeries);
        
        final TargetImageDimensions imageDimensions = targetMetadata.imageDimensions();
        TargetPixelBinaryTableHeaderFormatter binTableFormatter = new TargetPixelBinaryTableHeaderFormatter();

        ArrayDimensions arrayDimensions = 
            ArrayDimensions.newInstance(new Integer[] { imageDimensions.nColumns, imageDimensions.nRows},
                                        RB_LEVEL_TCOLUMN, targetMetadata.rollingBandVariationDimensions()); 
        Header binaryTableHeader = createBinaryTableHeader(k2Source,
            targetMetadata, ttime.startMjd, ttime.endMjd, 
            ttime.startBkjd, ttime.endBkjd, exposureCalc,
            imageDimensions, ttime.actualStart, ttime.actualEnd,
            outputs.checksums().get(1),
            celestialWcs,
            binTableFormatter, arrayDimensions);
        
        final ArrayDataOutput binaryTableOutput = outputs.outputs().get(1);
        binaryTableHeader.write(binaryTableOutput);

        final float[] timeCorrection = ttime.barycentricCorrection.fseries();
        final int[] qualityFlags = targetMetadata.dataQualityFlags();

        final SingleCadenceImageWriter<TimeSeries> rawImages = newImageWriter(
            imageDimensions.boundingPixelsByRowCol,
            targetMetadata.rawPixels(exportData.allTimeSeries), new IntArrayDataCopier(),
            binaryTableOutput);
        final SingleCadenceImageWriter<TimeSeries> calImages = newImageWriter(
            imageDimensions.boundingPixelsByRowCol,
            targetMetadata.calibratedPixels(exportData.allTimeSeries),
            new FloatArrayDataCopier(exposureCalc), binaryTableOutput);
        
        final SingleCadenceImageWriter<TimeSeries> calUmmImages = newImageWriter(
            imageDimensions.boundingPixelsByRowCol,
            targetMetadata.ummPixels(exportData.allTimeSeries),
            new FloatArrayDataCopier(exposureCalc), binaryTableOutput);
        
     // This is how data arrays are truncated to fit the target's start and
        // end cadences.
        final int nCadence = ttime.actualEnd - ttime.actualStart+ 1;
        final int[] cadenceNumbers = k2Source.timestampSeries().cadenceNumbers;
        for (int c = ttime.actualStart; c <= ttime.actualEnd; c++) {
            int rowi = c - k2Source.startCadence();
            binaryTableOutput.writeDouble(ttime.time[rowi]);
            binaryTableOutput.writeFloat(timeCorrection[rowi]);
            binaryTableOutput.writeInt(cadenceNumbers[rowi]);
            rawImages.writeSingleCadenceImage(rowi);
            calImages.writeSingleCadenceImage(rowi);
            calUmmImages.writeSingleCadenceImage(rowi);
            fillNullImage(imageDimensions, binaryTableOutput); //bkg
            fillNullImage(imageDimensions, binaryTableOutput); // bkg umm
            fillNullImage(imageDimensions, binaryTableOutput); // cosmic ray
            binaryTableOutput.writeInt(qualityFlags[rowi]);
            binaryTableOutput.writeFloat(Float.NaN);
            binaryTableOutput.writeFloat(Float.NaN);
        }

        long rowLengthBytes = 
            binTableFormatter.bytesPerTableRow(arrayDimensions);
        long totalBytesWritten = rowLengthBytes * nCadence;
        padBinaryTableData(totalBytesWritten, binaryTableOutput);

        writeApertureMaskHdu(targetMetadata, 
            outputs.outputs().get(2), imageDimensions,
            outputs.checksums().get(2),
            celestialWcs);
    }

    private void fillNullImage(TargetImageDimensions imageDimensions, DataOutput dout) throws IOException {
        for (int i=0; i < imageDimensions.sizeInPixels; i++) {
            dout.writeFloat(Float.NaN);
        }
    }
    
    private Header createBinaryTableHeader(final K2Source k2Source,
        final K2Target targetMetadata, 
        final double startMjd, final double endMjd,
        final double startBkjd, final double endBkjd, 
        final ExposureCalculator exposureCalc,
        final TargetImageDimensions imageDimensions,
        final int actualStart, final int actualEnd,
        final String targetTablesChecksum,
        CelestialWcsKeywordValueSource celestialWcs,
        TargetPixelBinaryTableHeaderFormatter binTableFormatter,
        ArrayDimensions arrayDimensions) throws HeaderCardException {
       
        TargetPixelHeaderSource headerSource =
            new TargetPixelHeaderSource() {

            @Override
            public Integer timeSlice() {
                return FcConstants.getCcdModuleTimeSlice(k2Source.ccdModule());
            }

            @Override
            public double timeResolutionOfDataDays() {
                return exposureCalc.cadenceDurationDays();
            }

            @Override
            public double startMidMjd() {
                return startMjd;
            }

            @Override
            public double startKbjd() {
                return startBkjd;
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
                return k2Source.readNoiseE();
            }

            @Override
            public double raDegrees() {
                return targetMetadata.raDegrees();
            }

            @Override
            public double photonAccumulationTimeSec() {
                return exposureCalc.integrationTimeSec();
            }

            @Override
            public int nBinaryTableRows() {
                return actualEnd - actualStart + 1;
            }

            @Override
            public Integer meanBlackCounts() {
                return k2Source.meanBlackValue();
            }

            @Override
            public Integer keplerId() {
                return targetMetadata.keplerId();
            }

            @Override
            public int kbjdReferenceInt() {
                return ModifiedJulianDate.kjdReferenceIntegerPart();
            }

            @Override
            public double kbjdReferenceFraction() {
                return ModifiedJulianDate.kjdReferenceFractionalPart();
            }

            @Override
            public Double gainEPerCount() {
                return k2Source.gainE();
            }

            @Override
            public int framesPerCadence() {
                return exposureCalc.numberOfScienceFramesPerCadence();
            }

            @Override
            public double endMidMjd() {
                return endMjd;
            }

            @Override
            public double endKbjd() {
                return endBkjd;
            }

            @Override
            public double decDegrees() {
                return targetMetadata.celestialObject().getDec();
            }

            @Override
            public double deadC() {
                return exposureCalc.deadC();
            }

            @Override
            public double daysOnSource() {
                return exposureCalc.exposureDays();
            }

            @Override
            public Date observationStartUTC() {
                TimestampSeries cadenceTimes = k2Source.timestampSeries();
                int startCadenceIndex = actualStart
                    - cadenceTimes.cadenceNumbers[0];
                return ModifiedJulianDate.mjdToDate(cadenceTimes.startTimestamps[startCadenceIndex]);
            }

            @Override
            public Date observationEndUTC() {
                TimestampSeries cadenceTimes = k2Source.timestampSeries();
                int endCadenceIndex = actualEnd
                    - cadenceTimes.cadenceNumbers[0];
                return ModifiedJulianDate.mjdToDate(k2Source.timestampSeries().endTimestamps[endCadenceIndex]);
            }

            @Override
            public double liveTimeDays() {
                return exposureCalc.liveTimeDays();
            }

            @Override
            public double scienceFrameTimeSec() {
                return exposureCalc.scienceFrameSec();
            }

            @Override
            public int referenceColumn() {
                return imageDimensions.referenceColumn;
            }

            @Override
            public int referenceRow() {
                return imageDimensions.referenceRow;
            }

            @Override
            public Integer longCadenceFixedOffset() {
                return exposureCalc.longCadenceFixedOffset();
            }

            @Override
            public Integer shortCadenceFixedOffset() {
                return exposureCalc.shortCadenceFixedOffset();
            }

            @Override
            public Date generatedAt() {
                return targetMetadata.generatedAt();
            }

            @Override
            public Float cdpp3Hr() {
                return null;
            }

            @Override
            public Float cdpp6Hr() {
                return null;
            }

            @Override
            public Float cdpp12Hr() {
                return null;
            }
            @Override
            public Double fluxFractionInOptimalAperture() {
                return targetMetadata.fluxFractionInOptimalAperture();
            }
            
            @Override
            public Double crowding() {
                return targetMetadata.crowdingMetric();
            }

            @Override
            public String extensionName() {
                return "TARGETTABLES";
            }

            @Override
            public boolean backgroundSubtracted() {
                return false;
            }

            @Override
            public double elaspedTime() {
                return exposureCalc.elaspedTimeDays();
            }

            @Override
            public boolean isK2() {
                return targetMetadata.isK2Target();
            }

            @Override
            public Integer dynablackColumnCutoff() {
                return null;
            }

            @Override
            public Double dynablackThreshold() {
                return null;
            }

            @Override
            public int[] rollingBandDurations() {
                return ArrayUtils.EMPTY_INT_ARRAY;
            }

            @Override
            public BlackAlgorithm blackAlgorithm() {
                return BlackAlgorithm.UNDEFINED;  //Use TargetPixelExporter if you want this defined.
            }

            @Override
            public boolean isSingleQuarter() {
                return true;
            }

        };
        
        
        Header binaryTableHeader = 
            binTableFormatter.formatHeader(headerSource, celestialWcs, targetTablesChecksum, arrayDimensions);
        return binaryTableHeader;
    }
    
}
