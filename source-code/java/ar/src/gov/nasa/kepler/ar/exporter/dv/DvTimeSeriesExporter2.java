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
import static gov.nasa.kepler.ar.exporter.FluxTimeSeriesProcessing.barycentricCorrectionEndOfLastCadence;
import static gov.nasa.kepler.ar.exporter.FluxTimeSeriesProcessing.barycentricCorrectionStartOfFirstCadence;
import static gov.nasa.kepler.ar.exporter.binarytable.BinaryTableUtils.padBinaryTableData;
import gnu.trove.TLongHashSet;
import gov.nasa.kepler.ar.archive.BarycentricCorrection;
import gov.nasa.kepler.ar.exporter.AbstractMultiQuarterTargetExporter;
import gov.nasa.kepler.ar.exporter.AbstractSingleQuarterTargetExporter;
import gov.nasa.kepler.ar.exporter.ChecksumsAndOutputs;
import gov.nasa.kepler.ar.exporter.ExposureCalculator;
import gov.nasa.kepler.ar.exporter.RmsCdpp;
import gov.nasa.kepler.ar.exporter.binarytable.AbstractTargetBinaryTableHeaderFormatter;
import gov.nasa.kepler.ar.exporter.binarytable.ArrayDimensions;
import gov.nasa.kepler.ar.exporter.binarytable.ArrayWriter;
import gov.nasa.kepler.ar.exporter.binarytable.BaseTargetBinaryTableHeaderSource;
import gov.nasa.kepler.ar.exporter.binarytable.DoubleArrayWriter;
import gov.nasa.kepler.ar.exporter.binarytable.FloatArrayWriter;
import gov.nasa.kepler.ar.exporter.binarytable.IntArrayWriter;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.dv.DvPlanetResults;
import gov.nasa.kepler.hibernate.dv.DvTargetResults;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tps.TpsDbResult;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;

import java.io.*;
import java.util.*;

import nom.tam.fits.FitsException;
import nom.tam.fits.Header;
import nom.tam.util.ArrayDataOutput;
import nom.tam.util.BufferedDataOutputStream;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Iterators;
import com.google.common.collect.Maps;

/**
 * This class is intended to replace
 * {@link gov.nasa.kepler.ar.exporter.dv.DvTimeSeriesFitsFile}. It will be
 * used by a new DV exporter pipeline module.
 * 
 * 
 * 
 * @author Lee Brownston
 * @author Sean McCauliff
 * 
 */
public class DvTimeSeriesExporter2 
   extends AbstractMultiQuarterTargetExporter<DvTargetMetadata, DvExporterSource> {
    
    /** Used for creating the OutputStream. */
    private static final int OUTPUT_BUFFER_SIZE = 1024 * 512;
    
    /** This is the FluxType of all exported light curves. */
    public static final FluxType FLUX_TYPE = FluxType.SAP;
    
    private static final Log log = LogFactory.getLog(DvTimeSeriesExporter2.class);

    private static final float GAP_FILL = Float.NaN;

    private static final int INT_GAP_FILL = -1;
    

    /**
     * The API for initiating an export operation.
     * The exporter's Pipeline Module calls this.
     * @param source whatever the exporter pipeline module is able to tell this
     * object about what is to be exported; must not be null
     * @return a set of pipeline task IDs for the tasks which generated the
     * source information.  non-null
     */
    public TLongHashSet exportDv(DvExporterSource exporterSource)
        throws IOException, FitsException {
        
        // Build the object containing the time-series data to export
        ExportData<DvTargetMetadata> exportData = super.exportData(exporterSource);
        
        //Generate some new time series and correct existing time series.
        //Instantiate target time and exposure calculator for each target.
        barycentricCorrections(exporterSource.timestampSeries(), exportData);
        for (DvTargetMetadata targetMetadata : exportData.targetMetdatas) {
            targetMetadata.unfillAndUnoutlie(exportData.allTimeSeries,
                exportData.floatMjdTimeSeries, exporterSource.mjdToCadence());
            
            TargetTime targetTime = targetTime(exporterSource, targetMetadata,
                exportData.allTimeSeries, Float.NaN);
            
            targetMetadata.setTargetTime(targetTime);
           
            Collection<FloatTimeSeries> pdcTimeSeries = 
                Collections.singleton(targetMetadata.pdcLightCurve(exportData.allTimeSeries));
            
            ExposureCalculator exposureCalc = new ExposureCalculator(
                exporterSource.configMaps(), pdcTimeSeries, targetTime.cadenceType, targetTime.startBkjd,
                targetTime.endBkjd, targetTime.actualStart, targetTime.actualEnd);
            
            targetMetadata.setExposureCalculator(exposureCalc);
            
        }
        
        // There may be multiple files to write for this target
        for (DvTargetMetadata dvTargetMetadata : exportData.targetMetdatas) {
            log.info("Writing FITS file for target " + dvTargetMetadata.keplerId());
            super.exportFile(dvTargetMetadata, exporterSource, exportData);
        }
        return exportData.originators;
    }
    
    
    /**
     * Unlike some of the other exporters we already have the corrected time
     * stamps, but we don't have the corrections that were applied.  This
     * generates the corrections that were applied.
     * @param exportData
     */
    private void barycentricCorrections(
        TimestampSeries cadenceTimes,
        gov.nasa.kepler.ar.exporter.AbstractTargetExporter.ExportData<DvTargetMetadata> exportData) {
  
        double[] mjds = cadenceTimes.midTimestamps;
        double[] uncorrectedKjdTimestamps = new double[mjds.length];

        for (int i = 0; i < mjds.length; i++) {
            uncorrectedKjdTimestamps[i] = ModifiedJulianDate.mjdToKjd(mjds[i]);
        }
        
        for (DvTargetMetadata target : exportData.targetMetdatas) {
            DoubleTimeSeries correctedTimestampsTimeSeries = 
                target.bcCorrectedTimestamps(exportData.allTimeSeries);
            double[] correctedTimestamps = correctedTimestampsTimeSeries.dseries();
            boolean[] gaps = correctedTimestampsTimeSeries.getGapIndicators();
            float[] corrections = new float[correctedTimestamps.length];

            for (int i=0; i < corrections.length; i++) {
                if (gaps[i]) {
                    corrections[i] = Float.NaN;
                } else {
                    corrections[i] = 
                        (float) (uncorrectedKjdTimestamps[i] - correctedTimestamps[i]);
                }
            }
            BarycentricCorrection bcCorrection = 
                new BarycentricCorrection(target.keplerId(),
                     corrections, gaps,
                    target.celestialObject().getRa(),
                    target.celestialObject().getDec());
            target.setBarycentricCorrection(bcCorrection);
        }
    }

    /**
     * This is called twice, once to write to a dummy file so as to calculate
     * the checksums, and then again inside a try block, writing to the actual
     * OutputFile.
     * @param source information all target exporters need in order to export;
     * must not be null
     * @param targetMetadata the KIC entry, beefed up; must not be null
     * @param exportData contains maps from FsId to time series; must not be
     * null
     * @param outputs checksums and output buffers to use with the per-target
     * exporter; must not be null
     */
    @Override
    protected void writeFileUnsafe(
        DvExporterSource exporterSource,
        DvTargetMetadata targetMetadata,
        AbstractSingleQuarterTargetExporter.ExportData<DvTargetMetadata> exportData,
        ChecksumsAndOutputs outputs) throws IOException, FitsException {
        
        int firstHduIndex = 0;
        writePrimaryHeader(targetMetadata,
            outputs.checksums().get(firstHduIndex),
            outputs.outputs().get(firstHduIndex));

        writeTceHdus(targetMetadata, exportData, outputs, exporterSource);
        
        int lastHduIndex = targetMetadata.hduCount() - 1;
        writeStatisticsHdu(targetMetadata, exportData,
            outputs.checksums().get(lastHduIndex),
            outputs.outputs().get(lastHduIndex),
             exporterSource);
        
        // Do not close the output stream; let the framework do it.
    }

    /**
     * Use nom.tam.fits to write the primary header.
     * The primary HDU consists only of the header.
     * @param dvTargetMetadata the KIC entry, beefed up; must not be null
     * @param initialChecksum the checksum value as a String; must not be null
     * @param primaryHeaderOutput output buffer to use with the per-target
     * exporter; must not be null
     * @throws FitsException
     * @throws IOException on failure to flush
     */
    private void writePrimaryHeader(DvTargetMetadata dvTargetMetadata,
        String initialChecksum,
        ArrayDataOutput primaryHeaderOutput)
            throws FitsException, IOException {

        DvTargetPrimaryHeaderFormatter formatter =  new DvTargetPrimaryHeaderFormatter();
        Header primaryHeader = 
            formatter.formatHeader(dvTargetMetadata, initialChecksum);
        primaryHeader.write(primaryHeaderOutput);
        primaryHeaderOutput.flush();
    }
    
    /**
     * Write one HDU for each TCE.
     * @param tceMetadataList a sequence of objects that describe a single
     * target's TCEs, in order of discovery; must not be null
     * @param exportData contains maps from FsId to time series; must not be
     * null
     * @param outputs checksums and output buffers to use with the per-target
     * exporter; must not be null
     * @throws FitsException 
     * @throws IOException if any ArrayDataOutput in outputs can't be flushed
     */
    private void writeTceHdus(DvTargetMetadata target,
        ExportData<DvTargetMetadata> exportData, ChecksumsAndOutputs outputs,
        DvExporterSource exporterSource)
            throws FitsException, IOException {
        
        List<DvTceMetadata> tces = target.tceMetadataList();
        // Index zero for the checksums and outputs was used for the primary.
        for (int tceIndex = 0; tceIndex < tces.size(); tceIndex++) {
            int outputIndex = tceIndex + 1;
            DvTceMetadata tce = tces.get(tceIndex);
            ArrayDataOutput output = outputs.outputs().get(outputIndex);
            String checksum = outputs.checksums().get(outputIndex);
            
            // The data source that the formatter needs
            BaseTargetBinaryTableHeaderSource headerSource = 
                createBinaryTableHeaderSource(exporterSource,
                    target.exposureCalculator(), target, 
                    "TCE_" + tce.index(), target.targetTime());
            
            DvTceHeaderFormatter formatter = new DvTceHeaderFormatter();
            // Use the formatter to create the header
            Header tceHeader = formatter.formatHeader(headerSource, checksum, tce);
            // Write the header to the output file
            tceHeader.write(output);


            writeTceData(exporterSource, target, tce, exportData, formatter, output);
            output.flush();
        }
    }
    

    /**
     * Write the binary time series for the data of the HDU describing the TCE
     * with the given index.
     * @param tceMetadata characterization of a single TCE for this target;
     * must not be null
     * @param initialChecksum the checksum value as a String; must not be null
     * @param exportData contains maps from FsId to time series; must not be
     * null
     * @param tceHeaderOutput output buffer to use with the per-target
     * exporter; must not be null
     * @throws IOException 
     */
    private void writeTceData(
        DvExporterSource exporterSource,
        DvTargetMetadata targetMetadata,
        DvTceMetadata dvTceMetadata,
        ExportData<DvTargetMetadata> exportData,
        DvTceHeaderFormatter tceHeaderFormatter,
        ArrayDataOutput output)
            throws FitsException, IOException {
        
        
        List<ArrayWriter> fluxWriters = 
            dvTceMetadata.organizeData(exportData.allTimeSeries, 
                exportData.floatMjdTimeSeries,
                GAP_FILL,INT_GAP_FILL, targetMetadata.exposureCalculator(),
                exporterSource.mjdToCadence());
        
        writeWithArrayWriters(exporterSource, targetMetadata,
            tceHeaderFormatter, output, fluxWriters);
    }

    /**
     * Once you have all the array writers for a specific HDU constructed
     * this can be used to write out the data portion.  Padding is included.
     * 
     * @param exporterSource
     * @param targetMetadata
     * @param headerFormatter
     * @param output
     * @param fluxWriters
     * @throws IOException
     */
    private void writeWithArrayWriters(DvExporterSource exporterSource,
        DvTargetMetadata targetMetadata,
        AbstractTargetBinaryTableHeaderFormatter headerFormatter, ArrayDataOutput output,
        List<ArrayWriter> fluxWriters) throws IOException {
        TargetTime ttime = targetMetadata.targetTime();
        int[] cadenceNumbers = exporterSource.timestampSeries().cadenceNumbers;
        long rowLengthBytes = headerFormatter.bytesPerTableRow(ArrayDimensions.newEmptyInstance());
        long totalBytesWritten = rowLengthBytes * exporterSource.cadenceCount();
        
        List<ArrayWriter> timeWriters = ImmutableList.of(new DoubleArrayWriter(ttime.time),
            new FloatArrayWriter(ttime.barycentricCorrection.fseries(), null),
            new IntArrayWriter(cadenceNumbers));
    
        ArrayWriter[] allWriters = new ArrayWriter[fluxWriters.size() + timeWriters.size()];
        Iterator<ArrayWriter> it = Iterators.concat(timeWriters.iterator(), fluxWriters.iterator());
        int writeri = 0;
        while (it.hasNext()) {
            allWriters[writeri++] = it.next();
        }
        
        // Unlike other files we are not truncating the output.
        // The length of this file is always from [startCadence, endCadence]
        // for the exporter unit of work.
        int cadenceCount = exporterSource.cadenceCount();
        for (int cadencei = 0; cadencei < cadenceCount; cadencei++) {
            for (int columni=0; columni < allWriters.length; columni++) {
                allWriters[columni].write(cadencei, output);
            }
        }
        
        padBinaryTableData(totalBytesWritten, output);
    }
    
    /**
     * Write the final "statistics" HDU, which contains target-level time
     * series, and the minimal number of header cards.
     * @param dvTargetMetadata the KIC entry, beefed up; must not be null
     * @param exportData contains maps from FsId to time series; must not be
     * null
     * @param checksum the checksum value as a String; must not be null
     * @param arrayDataOutput output buffer to use with the per-target
     * exporter; must not be null
     * @throws IOException if arrayDataOutput can't be flushed
     */
    private void writeStatisticsHdu(DvTargetMetadata targetMetadata,
        ExportData<DvTargetMetadata> exportData, String checksum,
        ArrayDataOutput output,
        DvExporterSource exporterSource)
        throws FitsException, IOException {

        
        BaseTargetBinaryTableHeaderSource headerSource = 
            createBinaryTableHeaderSource(exporterSource,
                targetMetadata.exposureCalculator(), targetMetadata, "Statistics", targetMetadata.targetTime());
        
        DvStatisticsHeaderFormatter formatter = 
            new DvStatisticsHeaderFormatter(exporterSource.tpsTrialTransitPulseDurationsHours());
        Header statisticsHeader =
            formatter.formatHeader(headerSource, checksum);
        
        statisticsHeader.write(output);
   
        writeStatisticsData(exporterSource, targetMetadata, exportData, formatter,
            output);
            
        output.flush();
    }
     
    
    private BaseTargetBinaryTableHeaderSource createBinaryTableHeaderSource(
        final DvExporterSource exporterSource,
        final ExposureCalculator exposureCalculator,
        final DvTargetMetadata target,
        final String extensionName,
        final TargetTime targetTime) {
            
        return new BaseTargetBinaryTableHeaderSource() {

            @Override
            public Integer keplerId() {
                return target.keplerId();
            }

            @Override
            public int nBinaryTableRows() {
                return exporterSource.cadenceCount();
            }

            @Override
            public int readsPerCadence() {
                return exposureCalculator.numberOfScienceFramesPerCadence();
            }

            @Override
            public Date observationStartUTC() {
                TimestampSeries cadenceTimes = exporterSource.timestampSeries();
                int startCadenceIndex = targetTime.actualStart
                    - cadenceTimes.cadenceNumbers[0];
                return ModifiedJulianDate.mjdToDate(cadenceTimes.startTimestamps[startCadenceIndex]);
            }

            @Override
            public Date observationEndUTC() {
                TimestampSeries cadenceTimes = exporterSource.timestampSeries();
                int endCadenceIndex = targetTime.actualEnd
                    - cadenceTimes.cadenceNumbers[0];
                return ModifiedJulianDate.mjdToDate(exporterSource.timestampSeries().endTimestamps[endCadenceIndex]);
            }

            @Override
            public double photonAccumulationTimeSec() {
                return exposureCalculator.integrationTimeSec();
            }

            @Override
            public double readoutTimePerFrameSec() {
                return exposureCalculator.readTimeSec();
            }

            @Override
            public int framesPerCadence() {
                return exposureCalculator.numberOfScienceFramesPerCadence();
            }

            @Override
            public double timeResolutionOfDataDays() {
                return exposureCalculator.cadenceDurationDays();
            }

            @Override
            public double scienceFrameTimeSec() {
                return exposureCalculator.scienceFrameSec();
            }

            @Override
            public Date generatedAt() {
                return exporterSource.generatedAt();
            }

            @Override
            public String extensionName() {
                return extensionName;
            }

            @Override
            public boolean backgroundSubtracted() {
                return true;
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
            public double startKbjd() {
                return targetTime.startBkjd;
            }

            @Override
            public double endKbjd() {
                return targetTime.endBkjd;
            }

            @Override
            public double liveTimeDays() {
                return exposureCalculator.liveTimeDays();
            }

            @Override
            public double elaspedTime() {
                return exposureCalculator.elaspedTimeDays();
            }

            @Override
            public double startMidMjd() {
                return targetTime.startMjd;
            }

            @Override
            public double endMidMjd() {
                return targetTime.endMjd;
            }

            @Override
            public double deadC() {
                return exposureCalculator.deadC();
            }

            @Override
            public double raDegrees() {
                return target.raDegrees();
            }

            @Override
            public double decDegrees() {
                return target.celestialObject().getDec();
            }

            @Override
            public Float cdpp3Hr() {
                return target.cdpp3Hr();
            }

            @Override
            public Float cdpp6Hr() {
                return target.cdpp6Hr();
            }

            @Override
            public Float cdpp12Hr() {
                return target.cdpp12Hr();
            }

            @Override
            public Double fluxFractionInOptimalAperture() {
                return null;
            }

            @Override
            public Double crowding() {
                return null;
            }

            @Override
            public boolean isK2() {
                return false;
            }

            /**
             * We can't easily encode these because they are specific to
             * each CCD channel and this changes every quarter.
             * @return null
             */
            @Override
            public Integer timeSlice() {
                return null;
            }

            /**
             * We can't easily encode these because they are specific to
             * each CCD channel and this changes every quarter.
             * @return null
             */
            
            @Override
            public Integer meanBlackCounts() {
                return null;
            }
            /**
             * We can't easily encode these because they are specific to
             * each CCD channel and this changes every quarter.
             * @return null
             */
            @Override
            public Integer longCadenceFixedOffset() {
                return null;
            }
            
            /**
             * We can't easily encode these because they are specific to
             * each CCD channel and this changes every quarter.
             * @return null
             */
            @Override
            public Integer shortCadenceFixedOffset() {
                return null;
            }

            /**
             * We can't easily encode these because they are specific to
             * each CCD channel and this changes every quarter.
             * @return null
             */
            @Override
            public Double gainEPerCount() {
                return null;
            }

            /**
             * We can't easily encode these because they are specific to
             * each CCD channel and this changes every quarter.
             * @return null
             */
            @Override
            public Double readNoiseE() {
                return null;
            }

            @Override
            public double daysOnSource() {
                return exposureCalculator.exposureDays();
            }

            @Override
            public boolean isSingleQuarter() {
                return false;
            }
        };
    }
    
    /**
     * Write the binary time-series data for the final "statistics" HDU.
     * @param exportData  contains maps from FsId to time series; must not be
     * null
     * @param statisticsHeader the Header for the statistics HDU
     * @param arrayDataOutput output buffer to use with the per-target
     * exporter; must not be null
     * @throws FitsException
     */
    private void writeStatisticsData(DvExporterSource exporterSource,
        DvTargetMetadata targetMetadata,
        ExportData<DvTargetMetadata> exportData,
        DvStatisticsHeaderFormatter statHeaderFormatter,
        ArrayDataOutput output)
            throws FitsException, IOException {

        List<ArrayWriter> fluxWriters = 
            targetMetadata.organizeData(exportData.allTimeSeries, 
                exportData.floatMjdTimeSeries,
                GAP_FILL,INT_GAP_FILL, targetMetadata.exposureCalculator(),
                exporterSource.mjdToCadence());
        
        writeWithArrayWriters(exporterSource, targetMetadata,
            statHeaderFormatter, output, fluxWriters);
    }

    
    /**
     * Auxiliary to outputStream().
     * @param exportDirectory the parent directory
     * @param fileName the child; must not be null
     * @return a new open OutputStream in the given directory with the given
     * name
     * @throws FileNotFoundException
     */
    protected BufferedDataOutputStream createOutputStream(File exportDirectory,
        String fileName) throws FileNotFoundException {

        File outputFile = new File(exportDirectory, fileName);
        FileOutputStream fileOutputStream = new FileOutputStream(outputFile);
        return new BufferedDataOutputStream(fileOutputStream, OUTPUT_BUFFER_SIZE);
    }

    /** Return an empty mask, since it is not going to be used. */
    @Override
    protected int apertureMaskPixelMask() {
        return 0;
    }
  

    @Override
    protected DvTargetMetadata createMultiQuarterTargetMetadata(
        DvExporterSource exporterSource,
        CelestialObject celestialObject,
        List<ObservedTarget> observedTargetForKeplerId,
        RmsCdpp rmsCdpp,
        List<Set<Pixel>> pixelsPerQuarter, TpsDbResult initialTce) {

        Integer[] ttableIds = exporterSource.targetTableExternalId();
        Map<Integer, Set<Pixel>> ttableIdToPixels = Maps.newHashMap();
        Iterator<Set<Pixel>> pixelIt = pixelsPerQuarter.iterator();
        for (Integer ttableId : ttableIds) {
            Set<Pixel> pixels = pixelIt.next();
            if (ttableId == null) {
                continue;
            }
            
            ttableIdToPixels.put(ttableId, pixels);
        }
        
        Integer keplerId = celestialObject.getKeplerId();
        
        DvTargetResults targetResults = 
            exporterSource.keplerIdToDvTargetResults().get(keplerId);
        if (targetResults == null) {
            log.warn("Not exporting data for target " + keplerId + " since it is missing DvTargetResults.");
            return null;
        }
        
        List<DvPlanetResults> planetResults = 
            exporterSource.keplerIdToDvPlanetResults().get(keplerId);
        
        return new DvTargetMetadata(celestialObject, exporterSource,
            rmsCdpp, ttableIdToPixels, 
            exporterSource.ccdChannels(),
            exporterSource.rollingBandPulseDurationsCadences(),
            targetResults, planetResults, initialTce);
    }

    @Override
    protected boolean checkExport(
        DvTargetMetadata targetMetadata,
        DvExporterSource source,
        gov.nasa.kepler.ar.exporter.AbstractTargetExporter.ExportData<DvTargetMetadata> exportData) {

        File exportedFile = new File(source.exportDirectory(), targetMetadata.fileName());
        final long probableMinimumLength = 2880 * 5;
        return exportedFile.length() >= probableMinimumLength;
    }

    @Override
    protected BufferedDataOutputStream outputStream(
        DvTargetMetadata targetMetadata,
        DvExporterSource source,
        gov.nasa.kepler.ar.exporter.AbstractTargetExporter.ExportData<DvTargetMetadata> exportData)
        throws IOException, FitsException {

        File outputFile = new File(source.exportDirectory(), targetMetadata.fileName());
        return new BufferedDataOutputStream(
            new FileOutputStream(outputFile), OUTPUT_BUFFER_SIZE);
    }
    
    /** Factory method to return a new TargetTime for a single target.
     * For this exporter the barycentric time is interpolated for all
     * cadences because it is defined for all cadences for the model light
     * curve.  Also the target's start and end cadence should be the start
     * and end cadence of the unit of work regardless of how many quarters
     * the target was actually observed.
     */
    @Override
    protected final TargetTime targetTime(
            DvExporterSource source,
            DvTargetMetadata targetMetadata, 
            Map<FsId, TimeSeries> allTimeSeries, 
            float gapFill) {

        int startCadence = source.startCadence();
        int endCadence = source.endCadence();
        
        FloatTimeSeries barycentricCorrection = targetMetadata.barycentricCorrectionSeries(
            allTimeSeries, startCadence, endCadence);

        TimestampSeries cadenceTimes = source.timestampSeries();
        
        double startBkjd = 
            ModifiedJulianDate.mjdToKjd(cadenceTimes.startTimestamps[0])
            + barycentricCorrectionStartOfFirstCadence(barycentricCorrection,
               startCadence, endCadence);
        
        double endBkjd = 
            ModifiedJulianDate.mjdToKjd(cadenceTimes.endTimestamps[endCadence - startCadence])
            + barycentricCorrectionEndOfLastCadence(barycentricCorrection,
                source.startCadence(), source.endCadence());

        double startMjd = source.mjdToCadence().cadenceToMjd(source.startCadence());
        double endMjd = source.mjdToCadence().cadenceToMjd(source.endCadence());
        
        DoubleTimeSeries bcCorrectedTimestamps = 
            targetMetadata.bcCorrectedTimestamps(allTimeSeries);
        bcCorrectedTimestamps.fillGaps(gapFill);

        double[] time = bcCorrectedTimestamps.dseries();
        
        return new TargetTime(CadenceType.LONG, startMjd, endMjd,
            startBkjd, endBkjd, source.startCadence(), source.endCadence(),
            time, barycentricCorrection);
    }
    
}
