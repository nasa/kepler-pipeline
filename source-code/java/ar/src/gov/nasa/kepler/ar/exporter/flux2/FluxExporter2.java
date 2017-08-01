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

package gov.nasa.kepler.ar.exporter.flux2;

import gnu.trove.TIntObjectHashMap;
import gnu.trove.TLongHashSet;
import gov.nasa.kepler.ar.exporter.*;
import gov.nasa.kepler.ar.exporter.binarytable.*;
import gov.nasa.kepler.ar.exporter.primary.TargetPrimaryHeaderFormatter;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.FitsConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.pa.TargetAperture;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.*;

import nom.tam.fits.FitsException;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;
import nom.tam.util.ArrayDataOutput;
import nom.tam.util.BufferedDataOutputStream;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.base.Predicate;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.Iterators;

import static gov.nasa.kepler.ar.exporter.binarytable.BinaryTableUtils.padBinaryTableData;

/**
 * Export light curve files. 
 * 
 * @author Sean McCauliff
 *
 */
public class FluxExporter2 extends AbstractSingleQuarterTargetExporter<FluxTargetMetadata,
    FluxExporterSource> {

    private static final Log log = LogFactory.getLog(FluxExporter2.class);
    
    private static final int OUTPUT_BUFFER_SIZE = 1024*512;
    
    private static final float GAP_FILL = Float.NaN;
    private static final int INT_GAP_FILL = -1;
    
    public TLongHashSet exportLightCurves(final FluxExporterSource source)
        throws IOException, FitsException {
        
        /**
         * Do not export targets that where dropped by the supplemental TAD run.
         */
        Predicate<ObservedTarget> dropTargetsDroppedBySupplementalTad = new Predicate<ObservedTarget>() {

            @Override
            public boolean apply(ObservedTarget input) {
                if (input == null) {
                    return false;
                }
                boolean ok = !source.wasTargetDroppedBySupplementalTad(input.getKeplerId());
                if (!ok) {
                    log.warn("Not exporting target " + input.getKeplerId()
                             + " since it was dropped in a supplemnetal tad run.");
                }
                return ok;
            }
        };
        
        TargetMetadataFactory<FluxTargetMetadata> metadataFactory =
            new TargetMetadataFactory<FluxTargetMetadata>() {
                
                @Override
                public FluxTargetMetadata create(CelestialObject celestialObject,
                    Set<Pixel> targetPixels, ObservedTarget observedTarget, RmsCdpp cdpp) {

                    Integer keplerId = celestialObject.getKeplerId();
                    return new FluxTargetMetadata(celestialObject,
                        source.cadenceType(), source, targetPixels,
                        observedTarget.getCrowdingMetric(),
                        observedTarget.getFluxFractionInAperture(),
                        source.wasTargetDroppedBySupplementalTad(keplerId),
                        observedTarget.getClippedPixelCount(), cdpp,
                        null /* target aperture to be filled in later*/,
                        source.longCadenceTimestampSeries(),
                        source.pdcProcessingCharacteristics().get(keplerId),
                        source.k2Campaign(), source.targetTableExternalId(),
                        source.isK2(), source.rollingBandUtils().rollingBandPulseDurations());
                }
            };
            
        ExportData<FluxTargetMetadata> exportData = 
            super.exportData(source, dropTargetsDroppedBySupplementalTad, metadataFactory);
        
        List<TimeSeries> centroidTimeSeries = new ArrayList<TimeSeries>();
        for (FluxTargetMetadata targetMetadata : exportData.targetMetdatas) {
        	centroidTimeSeries.addAll(targetMetadata.fluxCentroidTimeSeries(exportData.allTimeSeries));
        }
     
        Map<Integer, TargetAperture> keplerIdToTargetAperture = source.targetApertures(centroidTimeSeries);
        for (FluxTargetMetadata targetMetadata : exportData.targetMetdatas) {
            log.info("Writing light curve file for target " + targetMetadata.keplerId());
            targetMetadata.setTargetAperture(keplerIdToTargetAperture.get(targetMetadata.keplerId()));
            super.exportFile(targetMetadata, source, exportData);
        }
        
        return exportData.originators;
    }
    
    
    
    @Override
    protected void writeFileUnsafe(
        FluxExporterSource source,
        FluxTargetMetadata targetMetadata,
        ExportData<FluxTargetMetadata> exportData,
        ChecksumsAndOutputs checksumsAndOutputs) throws IOException, FitsException {

        
        TargetTime ttime = targetTime(source, targetMetadata,
            exportData.allTimeSeries, GAP_FILL);
        
        TargetPrimaryHeaderFormatter primaryHeaderFormatter = new TargetPrimaryHeaderFormatter();
        Header primaryHeader = 
            primaryHeaderFormatter.formatHeader(targetMetadata, checksumsAndOutputs.checksums().get(0));
        primaryHeader.write(checksumsAndOutputs.outputs().get(0));
        
        checksumsAndOutputs.outputs().get(0);
        Map<FsId, TimeSeries> targetsData = 
            targetMetadata.targetData(exportData.allTimeSeries);
        
        ExposureCalculator exposureCalc = new ExposureCalculator(
            source.configMaps(), targetsData.values(), ttime.cadenceType, ttime.startBkjd,
            ttime.endBkjd, ttime.actualStart, ttime.actualEnd);
        
        LightCurveBinaryTableHeaderFormatter binTableFormatter = 
            new LightCurveBinaryTableHeaderFormatter();
        CelestialWcsKeywordValueSource celestialWcsSource = 
            createCelestialWcsKeywordValueSource(
            targetMetadata, exportData.allTimeSeries);
        
        Header binaryTableHeader = createBinaryTableHeader(source,
            targetMetadata, exposureCalc, ttime,
            checksumsAndOutputs.checksums().get(1),
            binTableFormatter,
            celestialWcsSource,
            exportData.allTimeSeries);

        binaryTableHeader.write(checksumsAndOutputs.outputs().get(1));
        
        final int nCadence = ttime.actualEnd - ttime.actualStart+ 1;
        final int[] cadenceNumbers = source.timestampSeries().cadenceNumbers;
        final long rowLengthBytes = binTableFormatter.bytesPerTableRow(ArrayDimensions.newEmptyInstance());
        final long totalBytesWritten = rowLengthBytes * nCadence;
        
        
        List<ArrayWriter> timeWriters = ImmutableList.of(new DoubleArrayWriter(ttime.time),
            new FloatArrayWriter(ttime.barycentricCorrection.fseries(), null),
            new IntArrayWriter(cadenceNumbers));
        
        List<ArrayWriter> fluxWriters = 
            targetMetadata.organizeData(exportData.allTimeSeries, 
                exportData.floatMjdTimeSeries,
                GAP_FILL,INT_GAP_FILL, exposureCalc, source.mjdToCadence());
        
        ArrayWriter[] allWriters = new ArrayWriter[fluxWriters.size() + timeWriters.size()];
        Iterator<ArrayWriter> it = Iterators.concat(timeWriters.iterator(), fluxWriters.iterator());
        int writeri = 0;
        while (it.hasNext()) {
            allWriters[writeri++] = it.next();
        }
        
        final ArrayDataOutput binaryTableOutput = checksumsAndOutputs.outputs().get(1);
        for (int c = ttime.actualStart; c <= ttime.actualEnd; c++) {
            int rowi = c - source.startCadence();
            for (int columni=0; columni < allWriters.length; columni++) {
                allWriters[columni].write(rowi, binaryTableOutput);
            }
        }
        
        padBinaryTableData(totalBytesWritten, binaryTableOutput);
        binaryTableOutput.flush();
        
        writeApertureMaskHdu(targetMetadata, checksumsAndOutputs.outputs().get(2),
            targetMetadata.imageDimensions(),
            checksumsAndOutputs.checksums().get(2),
            celestialWcsSource);
        


    }

    private Header createBinaryTableHeader(
        final SingleQuarterExporterSource source,
        final FluxTargetMetadata targetMetadata,
        final ExposureCalculator exposureCalc,
        final TargetTime ttime,
        final String checksumString,
        LightCurveBinaryTableHeaderFormatter binTableFormatter,
        CelestialWcsKeywordValueSource celestialWcsSource, 
        final Map<FsId, TimeSeries> allTimeSeries) 
        throws HeaderCardException {
        
        LightCurveBinaryTableHeaderSource headerSource = 
            new LightCurveBinaryTableHeaderSource() {
            
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
                return ttime.startMjd;
            }

            @Override
            public double startKbjd() {
                return ttime.startBkjd;
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
                return ttime.actualEnd - ttime.actualStart + 1;
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
                return (int) Math.floor(ModifiedJulianDate.mjdToJd(ModifiedJulianDate.KJD_OFFSET_FROM_MJD));
            }

            @Override
            public double kbjdReferenceFraction() {
                double startOfKeplerEpochInJd = ModifiedJulianDate.mjdToJd(ModifiedJulianDate.KJD_OFFSET_FROM_MJD);
                return startOfKeplerEpochInJd
                    - (double) (int) startOfKeplerEpochInJd;
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
                return ttime.endMjd;
            }

            @Override
            public double endKbjd() {
                return ttime.endBkjd;
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
                int startCadenceIndex = ttime.actualStart
                    - cadenceTimes.cadenceNumbers[0];
                return ModifiedJulianDate.mjdToDate(cadenceTimes.startTimestamps[startCadenceIndex]);
            }

            @Override
            public Date observationEndUTC() {
                TimestampSeries cadenceTimes = source.timestampSeries();
                int endCadenceIndex =ttime.actualEnd
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
                if (source.cadenceType() == CadenceType.SHORT) {
                    return null;
                } else {
                    return targetMetadata.cdpp3Hr();
                }
            }

            @Override
            public Float cdpp6Hr() {
                if (source.cadenceType() == CadenceType.SHORT) {
                    return null;
                } else {
                    return targetMetadata.cdpp6Hr();
                }
            }

            @Override
            public Float cdpp12Hr() {
                if (source.cadenceType() == CadenceType.SHORT) {
                    return null;
                } else {
                    return targetMetadata.cdpp12Hr();
                }
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
            public PdcMapResults pdcMap() {
                return targetMetadata.pdcMapResults(allTimeSeries);
            }

            @Override
            public String extensionName() {
                return "LIGHTCURVE";
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
            public boolean isSingleQuarter() {
                return true;
            }
        };
        
        Header binaryTableHeader = 
            binTableFormatter.formatHeader(headerSource, celestialWcsSource, checksumString);
        return binaryTableHeader;
    }


    @Override
    protected BufferedDataOutputStream outputStream(
        FluxTargetMetadata targetMetadata,
        FluxExporterSource source,
        gov.nasa.kepler.ar.exporter.AbstractSingleQuarterTargetExporter.ExportData<FluxTargetMetadata> exportData)
        throws IOException, FitsException {

        FileNameFormatter fnameFormatter = new FileNameFormatter();
        String fname;
        if (targetMetadata.isK2Target()) {
            fname = fnameFormatter.k2FluxName(targetMetadata.keplerId(), source.k2Campaign(),
                source.mjdToCadence().cadenceType() == CadenceType.SHORT);
        } else {
            fname = fnameFormatter.fluxName(targetMetadata.keplerId(),
                source.fileTimestamp(), source.mjdToCadence().cadenceType() == CadenceType.SHORT);
        }
        File outputFile = new File(source.exportDirectory(), fname);
        return new BufferedDataOutputStream(
            new FileOutputStream(outputFile), OUTPUT_BUFFER_SIZE);
    }

    @Override
    protected boolean checkExport(FluxTargetMetadata targetMetadata,
            FluxExporterSource source, ExportData<FluxTargetMetadata> exportData) {
    
        FileNameFormatter fnameFormatter = new FileNameFormatter();
        String fname = fnameFormatter.fluxName(targetMetadata.keplerId(),
            source.fileTimestamp(), source.mjdToCadence().cadenceType() == CadenceType.SHORT);
        File outputFile = new File(source.exportDirectory(), fname);
        return outputFile.length() > FitsConstants.HDU_BLOCK_SIZE * 3;
    }
    
    /**
     * Produce unmodified aperture mask image.
     */
    @Override
    protected int apertureMaskPixelMask() {
        return ApertureMaskImageBuilder.PIXEL_IN_OPTIMAL_APERTURE |
               ApertureMaskImageBuilder.PIXEL_USED_FOR_FLUX_CENTROID |
               ApertureMaskImageBuilder.PIXEL_USED_FOR_PRF_CENTROID  |
               ApertureMaskImageBuilder.PIXEL_WAS_COLLECTED;
    }

    
}
