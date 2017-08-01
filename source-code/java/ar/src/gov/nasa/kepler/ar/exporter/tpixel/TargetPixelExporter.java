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

import gnu.trove.TIntObjectHashMap;
import gnu.trove.TLongHashSet;
import gov.nasa.kepler.ar.archive.*;
import gov.nasa.kepler.ar.exporter.*;
import gov.nasa.kepler.ar.exporter.RollingBandFlags.RollingBandKey;
import gov.nasa.kepler.ar.exporter.binarytable.ArrayDataCopier;
import gov.nasa.kepler.ar.exporter.binarytable.ArrayDimensions;
import gov.nasa.kepler.ar.exporter.binarytable.DoubleToFloatArrayDataCopier;
import gov.nasa.kepler.ar.exporter.binarytable.FloatMjdArrayDataCopier;
import gov.nasa.kepler.ar.exporter.binarytable.IntArrayDataCopier;
import gov.nasa.kepler.ar.exporter.binarytable.RollingBandVariationCopier;
import gov.nasa.kepler.ar.exporter.binarytable.RollingBandVariationCopierShortCadence;
import gov.nasa.kepler.ar.exporter.binarytable.SingleCadenceImageWriter;
import gov.nasa.kepler.ar.exporter.primary.TargetPrimaryHeaderFormatter;
import gov.nasa.kepler.ar.exporter.tpixel.TargetImageDimensionCalculator.TargetImageDimensions;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.cal.BlackAlgorithm;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.pa.TargetAperture;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;

import java.io.DataOutput;
import java.io.IOException;
import java.util.*;

import nom.tam.fits.FitsException;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;
import nom.tam.util.ArrayDataOutput;
import nom.tam.util.BufferedDataOutputStream;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import static gov.nasa.kepler.ar.exporter.binarytable.BinaryTableUtils.*;
import static gov.nasa.kepler.ar.exporter.binarytable.SingleCadenceImageWriter.newImageWriter;
import static gov.nasa.kepler.common.FitsConstants.RB_LEVEL_TCOLUMN;

/**
 * Exports target pixel files for the specified interval of targets which should
 * all be on the same mod/out.
 * 
 * @author Sean McCauliff
 * 
 */
public class TargetPixelExporter 
    extends AbstractSingleQuarterTargetExporter<TargetPixelMetadata, TargetPixelExporterSource> {

    private static final Log log = LogFactory.getLog(TargetPixelExporter.class);

    private final PixelOutputStreamFactory outputStreamFactory = 
        new PixelOutputStreamFactory();
    
    public TargetPixelExporter() {
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
        final TargetPixelExporterSource source) throws IOException,
        FitsException {
       
        TargetMetadataFactory<TargetPixelMetadata> metadataFactory = 
            new TargetMetadataFactory<TargetPixelMetadata>() {
                
                @Override
                public TargetPixelMetadata create(CelestialObject celestialObject,
                    Set<Pixel> targetPixels, ObservedTarget observedTarget,
                    RmsCdpp targetCdpp) {

                    int keplerId = celestialObject.getKeplerId();
                    
                    return new TargetPixelMetadata(celestialObject,
                        source.cadenceType(),
                        targetPixels, source.ccdModule(), source.ccdOutput(),
                        source, observedTarget.getCrowdingMetric(),
                        observedTarget.getFluxFractionInAperture(),
                        source.wasTargetDroppedBySupplementalTad(keplerId),
                        observedTarget.getClippedPixelCount(),
                        targetCdpp, null,
                        source.longCadenceTimestampSeries(), source.k2Campaign(),
                        source.targetTableExternalId(), source.isK2(),
                        source.rollingBandUtils().rollingBandPulseDurations());
                }
            };
        
        ExportData<TargetPixelMetadata> exportData = 
            exportData(source, null, metadataFactory);
        
        Set<Pixel> allPixels = new HashSet<Pixel>(exportData.targetMetdatas.size() * 2 * 32);
        List<TimeSeries> centroidTimeSeries = new ArrayList<TimeSeries>(exportData.targetMetdatas.size() * 2);
        for (TargetPixelMetadata metadata : exportData.targetMetdatas) {
            allPixels.addAll(metadata.aperturePixels());
            centroidTimeSeries.addAll(metadata.fluxCentroidTimeSeries(exportData.allTimeSeries));
        }
        
        Map<Pixel, BackgroundPixelValue> background = 
            source.background(allPixels);
        
        
        Map<Integer, TargetAperture> keplerIdToTargetAperture = source.targetApertures(centroidTimeSeries);
        
        FluxPixelValueCalculator calCalc = new FluxPixelValueCalculator();
        
        for (TargetPixelMetadata targetMetadata : exportData.targetMetdatas) {
            log.info("Writing file for target with kepler id "
                + targetMetadata.keplerId());
            calCalc.modifyCalibratedPixels(
                    targetMetadata.calibratedPixels(exportData.allTimeSeries),
                    targetMetadata.cosmicRays(exportData.floatMjdTimeSeries),
                    targetMetadata.ummPixels(exportData.allTimeSeries),
                background,
               exportData.allTimeSeries,exportData.floatMjdTimeSeries,
               source.mjdToCadence(), GAP_FILL);
            targetMetadata.setBackground(background);
            targetMetadata.setTargetAperture(keplerIdToTargetAperture.get(targetMetadata.keplerId()));
            exportFile(targetMetadata, source, exportData);
        }

        return exportData.originators;
    }

  
    @Override
    protected BufferedDataOutputStream outputStream(TargetPixelMetadata targetMetadata,
        TargetPixelExporterSource exporterSource,
        ExportData<TargetPixelMetadata> exportData) throws IOException {
        
        return outputStreamFactory.outputStream(targetMetadata, exporterSource, exportData);

    }

   
    @Override
    protected void writeFileUnsafe(TargetPixelExporterSource source,
        TargetPixelMetadata targetMetadata,
        ExportData<TargetPixelMetadata> exportData,
        ChecksumsAndOutputs checksumsAndOutputs)
    throws IOException, FitsException {
        

        TargetTime ttime = targetTime(source, targetMetadata,
            exportData.allTimeSeries, GAP_FILL);
        
        TargetPrimaryHeaderFormatter primaryHeaderFormatter = new TargetPrimaryHeaderFormatter();
        Header primaryHeader = 
            primaryHeaderFormatter.formatHeader(targetMetadata, checksumsAndOutputs.checksums().get(0));
        primaryHeader.write(checksumsAndOutputs.outputs().get(0));

        SortedMap<Pixel, TimeSeries> rawPixels = 
            targetMetadata.rawPixels(exportData.allTimeSeries);
        ExposureCalculator exposureCalc = new ExposureCalculator(
            source.configMaps(), rawPixels.values(), ttime.cadenceType, ttime.startBkjd,
            ttime.endBkjd, ttime.actualStart, ttime.actualEnd);

        TargetImageDimensions imageDimensions = targetMetadata.imageDimensions();
        ArrayDimensions arrayDimensions = 
            ArrayDimensions.newInstance(new Integer[] { imageDimensions.nColumns, imageDimensions.nRows},
                                        RB_LEVEL_TCOLUMN, targetMetadata.rollingBandVariationDimensions());
        TargetPixelBinaryTableHeaderFormatter binTableFormatter = new TargetPixelBinaryTableHeaderFormatter();

        CelestialWcsKeywordValueSource celestialWcsSource = 
            createCelestialWcsKeywordValueSource(
            targetMetadata, exportData.allTimeSeries);
        Header binaryTableHeader = createBinaryTableHeader(source,
            targetMetadata, ttime.startMjd, ttime.endMjd, 
            ttime.startBkjd, ttime.endBkjd, exposureCalc,
            imageDimensions, ttime.actualStart, ttime.actualEnd,
            checksumsAndOutputs.checksums().get(1),
            binTableFormatter,
            celestialWcsSource, arrayDimensions);

        SortedMap<RollingBandKey, DoubleTimeSeries> rollingBandVariation = 
            targetMetadata.rollingBandVariation(exportData.allTimeSeries);
        
        ArrayDataOutput binaryTableOutput = checksumsAndOutputs.outputs().get(1);
        binaryTableHeader.write(binaryTableOutput);

        float[] timeCorrection = ttime.barycentricCorrection.fseries();
        int[] qualityFlags = targetMetadata.dataQualityFlags();
        TargetDva targetDva = targetMetadata.dva();
        targetDva.fillGaps(GAP_FILL);

        SingleCadenceImageWriter<TimeSeries> rawImages = newImageWriter(
            imageDimensions.boundingPixelsByRowCol,
            targetMetadata.rawPixels(exportData.allTimeSeries), new IntArrayDataCopier(),
            binaryTableOutput);
        SingleCadenceImageWriter<TimeSeries> calImages = newImageWriter(
            imageDimensions.boundingPixelsByRowCol,
            targetMetadata.calibratedPixels(exportData.allTimeSeries),
            new DoubleToFloatArrayDataCopier(exposureCalc), binaryTableOutput);
        SingleCadenceImageWriter<TimeSeries> calUmmImages = newImageWriter(
            imageDimensions.boundingPixelsByRowCol,
            targetMetadata.ummPixels(exportData.allTimeSeries), new DoubleToFloatArrayDataCopier(
                exposureCalc), binaryTableOutput);
        SingleCadenceImageWriter<FloatMjdTimeSeries> cosmicRayImages = newImageWriter(
            imageDimensions.boundingPixelsByRowCol,
            targetMetadata.cosmicRays(exportData.floatMjdTimeSeries),
            new FloatMjdArrayDataCopier(source.startCadence(),
                source.mjdToCadence(), exposureCalc), binaryTableOutput);
        SingleCadenceImageWriter<BackgroundPixelValue> backgroundImages = newImageWriter(
            imageDimensions.boundingPixelsByRowCol, targetMetadata.background(),
            new BackgroundPixelCopier(exposureCalc), binaryTableOutput);
        SingleCadenceImageWriter<BackgroundPixelValue> backgroundUmmImages = newImageWriter(
            imageDimensions.boundingPixelsByRowCol, targetMetadata.background(),
            new BackgroundUmmPixelCopier(exposureCalc), binaryTableOutput);
        SingleCadenceImageWriter<DoubleTimeSeries> rollingBandVariationImages = null;
        if (source.cadenceType() == CadenceType.LONG) {
            rollingBandVariationImages = 
                newImageWriter(rollingBandVariation.keySet(), rollingBandVariation,
                    new RollingBandVariationCopier(), binaryTableOutput);
        } else {
            ShortToLongCadenceMap shortToLongMap = 
                new ShortToLongCadenceMap(source.timestampSeries(), source.longCadenceTimes());
            RollingBandVariationCopierShortCadence scCopier =
                new RollingBandVariationCopierShortCadence(shortToLongMap, source.timestampSeries().gapIndicators);
            rollingBandVariationImages = 
                newImageWriter(rollingBandVariation.keySet(), rollingBandVariation,
                    scCopier, binaryTableOutput);
        }

        // This is how data arrays are truncated to fit the target's start and
        // end cadences.
        int nCadence = ttime.actualEnd - ttime.actualStart+ 1;
        int[] cadenceNumbers = source.timestampSeries().cadenceNumbers;
        for (int c = ttime.actualStart; c <= ttime.actualEnd; c++) {
            int rowi = c - source.startCadence();
            binaryTableOutput.writeDouble(ttime.time[rowi]);
            binaryTableOutput.writeFloat(timeCorrection[rowi]);
            binaryTableOutput.writeInt(cadenceNumbers[rowi]);
            rawImages.writeSingleCadenceImage(rowi);
            calImages.writeSingleCadenceImage(rowi);
            calUmmImages.writeSingleCadenceImage(rowi);
            backgroundImages.writeSingleCadenceImage(rowi);
            backgroundUmmImages.writeSingleCadenceImage(rowi);
            cosmicRayImages.writeSingleCadenceImage(rowi);
            binaryTableOutput.writeInt(qualityFlags[rowi]);
            binaryTableOutput.writeFloat(targetDva.getColumnDva()[rowi]);
            binaryTableOutput.writeFloat(targetDva.getRowDva()[rowi]);
            rollingBandVariationImages.writeSingleCadenceImage(rowi);
        }

        long rowLengthBytes = 
            binTableFormatter.bytesPerTableRow(arrayDimensions);
        long totalBytesWritten = rowLengthBytes * nCadence;
        padBinaryTableData(totalBytesWritten, binaryTableOutput);
 

        writeApertureMaskHdu(targetMetadata, 
            checksumsAndOutputs.outputs().get(2), imageDimensions,
            checksumsAndOutputs.checksums().get(2),
            celestialWcsSource);
    }

  

    private Header createBinaryTableHeader(
        final TargetPixelExporterSource source,
        final TargetPixelMetadata targetMetadata, final double startMjd,
        final double endMjd, final double startBkjd, final double endBkjd,
        final ExposureCalculator exposureCalc,
        final TargetImageDimensions imageDimensions,
        final int targetsStartCadence,
        final int targetsEndCadence,
        final String checksumString,
        TargetPixelBinaryTableHeaderFormatter binTableFormatter,
        CelestialWcsKeywordValueSource celestialWcsSource,
        ArrayDimensions arrayDimensions)
        throws HeaderCardException {
        
        TargetPixelHeaderSource headerSource =
            new TargetPixelHeaderSource() {

            @Override
            public Integer timeSlice() {
                return FcConstants.getCcdModuleTimeSlice(source.ccdModule());
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
                return source.readNoiseE();
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
                return targetsEndCadence - targetsStartCadence + 1;
            }

            @Override
            public Integer meanBlackCounts() {
                return source.meanBlackValue();
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
                return source.gainE();
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
                TimestampSeries cadenceTimes = source.timestampSeries();
                int startCadenceIndex = targetsStartCadence
                    - cadenceTimes.cadenceNumbers[0];
                return ModifiedJulianDate.mjdToDate(cadenceTimes.startTimestamps[startCadenceIndex]);
            }

            @Override
            public Date observationEndUTC() {
                TimestampSeries cadenceTimes = source.timestampSeries();
                int endCadenceIndex = targetsEndCadence
                    - cadenceTimes.cadenceNumbers[0];
                return ModifiedJulianDate.mjdToDate(source.timestampSeries().endTimestamps[endCadenceIndex]);
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
                return targetMetadata.cdpp3Hr();
            }

            @Override
            public Float cdpp6Hr() {
                return targetMetadata.cdpp6Hr();
            }

            @Override
            public Float cdpp12Hr() {
                return targetMetadata.cdpp12Hr();
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
                return true;
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
                return source.rollingBandUtils().columnCutoff();
            }

            @Override
            public Double dynablackThreshold() {
                return source.rollingBandUtils().fluxThreshold(exposureCalc.cadenceDurationDays());
            }

            @Override
            public int[] rollingBandDurations() {
                return source.rollingBandUtils().rollingBandPulseDurations();
            }

            @Override
            public BlackAlgorithm blackAlgorithm() {
                return source.blackAlgorithm();
            }

            @Override
            public boolean isSingleQuarter() {
                return true;
            }

        };
        
        
        Header binaryTableHeader = binTableFormatter.formatHeader(headerSource,
            celestialWcsSource, checksumString, arrayDimensions);
        return binaryTableHeader;
    }

    private static final class BackgroundPixelCopier implements
        ArrayDataCopier<BackgroundPixelValue> {
        private final ExposureCalculator exposureCalc;

        public BackgroundPixelCopier(ExposureCalculator exposureCalc) {
            this.exposureCalc = exposureCalc;
        }

        @Override
        public void copy(DataOutput dout, int tsi, BackgroundPixelValue t)
            throws IOException {
            // assume this is gap filled
            dout.writeFloat((float)exposureCalc.fluxPerCadenceToFluxPerSecond(t.getBackground()[tsi]));
        }

        @Override
        public void fillNull(DataOutput dout) throws IOException {
            dout.writeFloat(GAP_FILL);
        }

    }

    private static final class BackgroundUmmPixelCopier implements
        ArrayDataCopier<BackgroundPixelValue> {
        private final ExposureCalculator exposureCalc;

        public BackgroundUmmPixelCopier(ExposureCalculator exposureCalc) {
            this.exposureCalc = exposureCalc;
        }

        @Override
        public void copy(DataOutput dout, int tsi, BackgroundPixelValue t)
            throws IOException {
            // assume this is gap filled.
            dout.writeFloat((float)exposureCalc.fluxPerCadenceToFluxPerSecond(t.getBackgroundUncertainties()[tsi]));
        }

        @Override
        public void fillNull(DataOutput dout) throws IOException {
            dout.writeFloat(GAP_FILL);
        }

    }

    /**
     * Produce an aperture mask image with only the collected, and optimal
     * aperture flags.
     */
    @Override
    protected int apertureMaskPixelMask() {
        return ApertureMaskImageBuilder.PIXEL_WAS_COLLECTED |
               ApertureMaskImageBuilder.PIXEL_IN_OPTIMAL_APERTURE;
    }


    /**
     * This implementation returns true.
     */
    @Override
    protected boolean checkExport(
            TargetPixelMetadata targetMetadata,
            TargetPixelExporterSource source,
            gov.nasa.kepler.ar.exporter.AbstractSingleQuarterTargetExporter.ExportData<TargetPixelMetadata> exportData) {

        return true;
    }
}
