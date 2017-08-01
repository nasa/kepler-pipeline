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

package gov.nasa.kepler.ar.exporter.background;

import java.io.DataOutput;
import java.io.File;
import java.io.FileNotFoundException;
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

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;

import gnu.trove.TLongHashSet;
import gov.nasa.kepler.ar.archive.BarycentricCorrection;
import gov.nasa.kepler.ar.archive.TargetDva;
import gov.nasa.kepler.ar.exporter.ExposureCalculator;
import gov.nasa.kepler.ar.exporter.FileNameFormatter;
import gov.nasa.kepler.ar.exporter.FitsChecksumOutputStream;
import gov.nasa.kepler.ar.exporter.PixelByRowColumn;
import gov.nasa.kepler.ar.exporter.QualityFieldCalculator;
import gov.nasa.kepler.ar.exporter.ReferenceCadenceCalculator;
import gov.nasa.kepler.ar.exporter.RollingBandFlags;
import gov.nasa.kepler.ar.exporter.background.BackgroundPolynomial.Polynomial;
import gov.nasa.kepler.ar.exporter.binarytable.*;
import gov.nasa.kepler.ar.exporter.primary.BasePrimaryHeaderSource;
import gov.nasa.kepler.ar.exporter.primary.PrimaryHeaderFormatter;
import gov.nasa.kepler.ar.exporter.tpixel.DataQualityFlagsSource;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.*;
import gov.nasa.kepler.common.FitsConstants.ObservingMode;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.FsTimeSeries;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.fs.DynablackFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.ThrusterActivityType;
import static gov.nasa.kepler.ar.exporter.FluxTimeSeriesProcessing.*;
import static gov.nasa.kepler.ar.exporter.binarytable.BinaryTableUtils.*;
import static gov.nasa.kepler.ar.exporter.binarytable.SingleCadenceImageWriter.newImageWriter;
import static gov.nasa.kepler.ar.exporter.background.BackgroundBinaryTableHeaderFormatter.*;

/**
 * Generates background pixel files.
 * 
 * @author Sean McCauliff
 *
 */
public class BackgroundPixelExporter {

    private static final Log log = LogFactory.getLog(BackgroundPixelExporter.class);
    
    /**
     * Generate a file.
     * 
     * @param source non-null
     * @return the set of originator ids.
     * @throws IOException
     * @throws FitsException
     */
    public TLongHashSet export(BackgroundPixelSource source) throws IOException, FitsException {
        
        boolean isK2 = source.startStartMjd() >= FcConstants.KEPLER_END_OF_MISSION_MJD;
        
        TLongHashSet originators = new TLongHashSet();
        
        Set<Pixel> backgroundPixels = source.backgroundPixels();
        
        //This sets some deterministic ordering for how the pixels are arranged
        //in the resulting file.
        SortedMap<Pixel, FsIdsForPixel> pixelFsIds = 
            Maps.newTreeMap(PixelByRowColumn.INSTANCE);
        
        SortedSet<FsId> allFsIds = Sets.newTreeSet();
        SortedSet<FsId> allMjdIds = Sets.newTreeSet();
        Set<FsId> collateralCosmicRayIds = Sets.newHashSet();
        Set<FsId> cosmicRayIds = Sets.newHashSetWithExpectedSize(pixelFsIds.size());
        Set<FsId> rollingBandFlagsIds = Sets.newHashSet();
        for (Pixel px : backgroundPixels) {
            addFsIdsFromPixel(source, pixelFsIds, allFsIds, allMjdIds,
                collateralCosmicRayIds, cosmicRayIds, rollingBandFlagsIds, 
                source.rollingBandPulseDurationsLc(), px);
        }

        FsId paArgabrighteningId = 
            PaFsIdFactory.getArgabrighteningFsId(CadenceType.LONG,
                source.targetTableExternalId(), 
                source.ccdModule(), source.ccdOutput());
        
        FsId thrusterFiringId = PaFsIdFactory.getThrusterActivityFsId(CadenceType.LONG, ThrusterActivityType.DEFINITE_THRUSTER_ACTIVITY);
        FsId possibleThrusterFiringId = PaFsIdFactory.getThrusterActivityFsId(CadenceType.LONG, ThrusterActivityType.POSSIBLE_THRUSTER_ACTIVITY);
        
        FsId zeroCrossingsId =
            PaFsIdFactory.getZeroCrossingFsId(CadenceType.LONG);
        
        allFsIds.add(paArgabrighteningId);
        allFsIds.add(zeroCrossingsId);
        allFsIds.add(thrusterFiringId);
        allFsIds.add(possibleThrusterFiringId);
        
        log.info("Reading time series.");
        Map<FsId, TimeSeries> allTimeSeries = 
            source.fileStoreClient().readTimeSeries(allFsIds, source.startCadence(), source.endCadence(), false);
        log.info("Reading mjd time series.");
        Map<FsId, FloatMjdTimeSeries> allMjdTimeSeries = 
            source.fileStoreClient().readMjdTimeSeries(allMjdIds, source.startStartMjd(), source.endEndMjd());
        log.info("Done reading information from file store server.");
        addAllOriginators(originators, allTimeSeries);
        addAllOriginators(originators, allMjdTimeSeries);
        
        subtractCosmicRays(allTimeSeries, allMjdTimeSeries, pixelFsIds, 
            source.mjdToCadence());
        
        int[] quality = createQualityColumn(source, allTimeSeries, allMjdTimeSeries,
            cosmicRayIds, collateralCosmicRayIds, rollingBandFlagsIds, 
            zeroCrossingsId, paArgabrighteningId, thrusterFiringId, possibleThrusterFiringId);
        
        ExposureCalculator exposureCalc = 
            new ExposureCalculator(source.configMaps(),
                allTimeSeries.values(), CadenceType.LONG,
                source.cadenceTimes().startTimestamps[0],
                source.cadenceTimes().endTimestamps[source.cadenceTimes().endTimestamps.length - 1],
                source.startCadence(), source.endCadence());
        
        BackgroundPolynomial bkgPolynomial = source.backgroundPolynomial();
        convertBackgroundPolynomialToElectronsPerSecond(bkgPolynomial, exposureCalc);
        
        ArrayDimensions arrayDimensions = 
            ArrayDimensions.newInstance(backgroundPixels.size(),
                                        BKG_POLY_COEFF,  bkgPolynomial.fitsDimensions() ,
                                        BKG_POLY_ERR_COEFF, bkgPolynomial.fitsCovarianceDimensions());
        
        ReferenceCadenceCalculator refCadenceCalculator = 
            new ReferenceCadenceCalculator();
        int qualityMask = ReferenceCadenceCalculator.BAD_QUALITY_FLAGS;
        if (source.ignoreZeroCrossingsForReferenceCadence()) {
            qualityMask &= ~ QualityFieldCalculator.REACTION_WHEEL_0_CROSSING;
        }
        if (isK2) {
            qualityMask &= ~QualityFieldCalculator.DETECTOR_ELECTRONICS_ANOMALY;
        }
        int barycenticCorrectionCadence = 
            refCadenceCalculator.referenceCadence(source.startCadence(), source.startCadence(),
            source.endCadence(), source.cadenceTimes(), quality, qualityMask);
        
        BarycentricCorrection centerModOutCorrection = 
            centerModOutBarycentricCorrection(source, barycenticCorrectionCadence);


        log.info("Computing per pixel BKJD time series.");
        Map<Pixel, BarycentricCorrection> perPixelBarycentricCorrection =
            source.perPixelBarycentricCorrection(barycenticCorrectionCadence,
                pixelFsIds.keySet());
        
        Map<Pixel, TargetDva> dvaCorrections = 
            source.dvaMotionCorrections(perPixelBarycentricCorrection, barycenticCorrectionCadence);
        
        Map<Pixel, PixelBkjd> perPixelBkjd = Maps.newHashMapWithExpectedSize(perPixelBarycentricCorrection.size());
        for (Map.Entry<Pixel, BarycentricCorrection> correction : perPixelBarycentricCorrection.entrySet()) {
            perPixelBkjd.put(correction.getKey(), 
                new PixelBkjd(source.cadenceTimes(), correction.getValue(), source.startCadence(), source.endCadence()));
        }
        log.info("Done computing per pixel BKJD time series.");
        
        SipWcsCoordinates sipWcsCoordinates = source.sipWcsCoordinates(barycenticCorrectionCadence);
       
        BackgroundPrimaryHeaderFormatter primaryHeaderFormatter = 
            new BackgroundPrimaryHeaderFormatter();
        
        BackgroundBinaryTableHeaderFormatter bkgHeaderFormatter = 
            new BackgroundBinaryTableHeaderFormatter();
        BackgroundTableHeaderSource bkgHeaderSource = 
            createBackgroundHeaderSource(source, pixelFsIds,  exposureCalc, centerModOutCorrection);
        
        BasePrimaryHeaderSource primaryHeaderSource = createPrimaryHeaderSource(source, isK2);
       
        
        BackgroundPixelListHeaderFormatter pixelListFormatter = 
            new BackgroundPixelListHeaderFormatter();
        BaseBinaryTableHeaderSource pixelListSource = 
            createPixelListSource(source, exposureCalc, pixelFsIds.size());
        
        final FitsChecksumOutputStream primaryChecksum = new FitsChecksumOutputStream();
        final BufferedDataOutputStream primaryChecksumBuf = new BufferedDataOutputStream(primaryChecksum);
        final FitsChecksumOutputStream backgroundChecksum = new FitsChecksumOutputStream();
        final BufferedDataOutputStream backgroundChecksumBuf = new BufferedDataOutputStream(backgroundChecksum);
        final FitsChecksumOutputStream pixelListChecksum = new FitsChecksumOutputStream();
        final BufferedDataOutputStream pixelListChecksumBuf = new BufferedDataOutputStream(pixelListChecksum);
        
        OutputsAndChecksums generateChecksum = new OutputsAndChecksums() {
            
            @Override
            public ArrayDataOutput primaryOut() {
                return primaryChecksumBuf;
            }
            
            @Override
            public String primaryChecksum() {
                return FitsConstants.CHECKSUM_DEFAULT;
            }
            
            @Override
            public ArrayDataOutput pixelListOut() {
                return pixelListChecksumBuf;
            }
            
            @Override
            public String pixelListChecksum() {
                return FitsConstants.CHECKSUM_DEFAULT;
            }
            
            @Override
            public ArrayDataOutput binaryDataOut() {
                return backgroundChecksumBuf;
            }
            
            @Override
            public String binaryDataChecksum() {
                return FitsConstants.CHECKSUM_DEFAULT;
            }
        };
        

        log.info("Generating checksums.");
        writeFile(source, generateChecksum, bkgPolynomial,
            primaryHeaderFormatter, primaryHeaderSource,
            bkgHeaderFormatter, bkgHeaderSource, pixelListFormatter,
            pixelListSource, sipWcsCoordinates,
            quality, exposureCalc, perPixelBkjd, dvaCorrections,
            pixelFsIds, allTimeSeries, allMjdTimeSeries,
            arrayDimensions);
        
        log.info("Done generating checksums.");
        
        final BufferedDataOutputStream bufOut = createOutputFileStream(source, isK2);
        

        OutputsAndChecksums realOutput = new OutputsAndChecksums() {

            @Override
            public ArrayDataOutput primaryOut() {
                return bufOut;
            }

            @Override
            public String primaryChecksum() {
                return primaryChecksum.checksumString();
            }

            @Override
            public ArrayDataOutput binaryDataOut() {
                return bufOut;
            }

            @Override
            public String binaryDataChecksum() {
                return backgroundChecksum.checksumString();
            }

            @Override
            public ArrayDataOutput pixelListOut() {
                return bufOut;
            }

            @Override
            public String pixelListChecksum() {
                return pixelListChecksum.checksumString();
            }
            
        };
        
        log.info("Generating background file.");
        writeFile(source, realOutput, bkgPolynomial,
            primaryHeaderFormatter, primaryHeaderSource,
            bkgHeaderFormatter, bkgHeaderSource, pixelListFormatter,
            pixelListSource, sipWcsCoordinates,
            quality, exposureCalc, perPixelBkjd, dvaCorrections,
            pixelFsIds, allTimeSeries, allMjdTimeSeries,
            arrayDimensions);
        
        bufOut.close();
        log.info("Completed generating background file.");
        return originators;
    }

    /**
     * Modifies the BackgroundPolynomial object so that it's coefficients are
     * in units of flux per second squared.
     * @param bkgPolynomial
     * @param exposureCalc
     */
    private void convertBackgroundPolynomialToElectronsPerSecond(BackgroundPolynomial bkgPolynomial, ExposureCalculator exposureCalc) {
        for (Polynomial poly : bkgPolynomial.polynomials()) {
            double[] covarianceCoeffs = poly.covarianceCoeffs();
            for (int i=0; i < covarianceCoeffs.length; i++) {
                covarianceCoeffs[i] =
                    exposureCalc.fluxPerCadenceSquaredToFluxPerSecond(covarianceCoeffs[i]);
            }
            
            double[] coeffs = poly.coeffs();
            for (int i=0; i < coeffs.length; i++) {
                coeffs[i] = exposureCalc.fluxPerCadenceToFluxPerSecond(coeffs[i]);
            }
        }
    }

    private void addAllOriginators(TLongHashSet originators,
        Map<FsId, ? extends FsTimeSeries> allTimeSeries) {

        for (FsTimeSeries fsts : allTimeSeries.values()) {
            fsts.uniqueOriginators(originators);
        }
    }

    /**
     * Removes the cosmic rays from the calibrated background pixel values.
     * 
     * @param allTimeSeries
     * @param allMjdTimeSeries
     * @param pixelFsIds
     */
    private void subtractCosmicRays(Map<FsId, TimeSeries> allTimeSeries,
        Map<FsId, FloatMjdTimeSeries> allMjdTimeSeries,
        SortedMap<Pixel, FsIdsForPixel> pixelFsIds,
        MjdToCadence mjdToCadence) {

        log.info("Subtracting cosmic rays.");
        for (FsIdsForPixel fsIdsForPixel : pixelFsIds.values()) {
            FloatTimeSeries floatCalSeries = 
                allTimeSeries.get(fsIdsForPixel.cal).asFloatTimeSeries();
            FloatMjdTimeSeries cosmicRays = allMjdTimeSeries.get(fsIdsForPixel.cosmicRay);
            double[] crSubtractedBkg = new double[floatCalSeries.cadenceLength()];
            float[] bkg = floatCalSeries.fseries();
            for (int i=0; i < crSubtractedBkg.length; i++) {
                crSubtractedBkg[i] = (double)bkg[i];
            }
            double[] cosmicRayMjds = cosmicRays.mjd();
            float[] cosmicRayValues = cosmicRays.values();
            for (int cri=0; cri < cosmicRayMjds.length; cri++) {
                int cadence = mjdToCadence.mjdToCadence(cosmicRayMjds[cri]);
                crSubtractedBkg[cadence - floatCalSeries.startCadence()] -=
                    (double) cosmicRayValues[cri];
            }
            DoubleTimeSeries doubleCalSeries = 
                new DoubleTimeSeries(fsIdsForPixel.cal, 
                    crSubtractedBkg, floatCalSeries.startCadence(), 
                    floatCalSeries.endCadence(), floatCalSeries.validCadences(),
                    floatCalSeries.originators());

            allTimeSeries.put(fsIdsForPixel.cal, doubleCalSeries);
            
        }
        
        log.info("Cosmic ray correction complete.");
    }

    private BaseBinaryTableHeaderSource createPixelListSource(
        final BackgroundPixelSource source,
        final ExposureCalculator exposureCalc,
        final int nPixels) {
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
                return source.readNoseE();
            }
            
            @Override
            public double photonAccumulationTimeSec() {
                return exposureCalc.integrationTimeSec();
            }
            
            @Override
            public Date observationStartUTC() {
                double[] startTimes = source.cadenceTimes().startTimestamps;
                return ModifiedJulianDate.mjdToDate(startTimes[0]);
            }
            
            @Override
            public Date observationEndUTC() {
                double[] endTimes = source.cadenceTimes().endTimestamps;
                return ModifiedJulianDate.mjdToDate(endTimes[endTimes.length - 1]);
            }
            
            @Override
            public int nBinaryTableRows() {
                return nPixels;
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
                return source.gainE();
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

    private BufferedDataOutputStream createOutputFileStream(
        BackgroundPixelSource source, boolean isK2) throws FileNotFoundException {
        FileNameFormatter fnameFormatter = new FileNameFormatter();
        String fname;
        if (isK2) {
            fname = fnameFormatter.k2BackgroundName(source.k2Campaign(), source.ccdModule(), source.ccdOutput());
        } else {
            fname = fnameFormatter.backgroundName(source.fileTimestamp(), source.ccdModule(), source.ccdOutput());
        }
        File outputFile = new File(source.exportDir(), fname);
       
        log.info("Creating file \"" + outputFile + "\".");
        
        BufferedDataOutputStream bufOut = 
            new BufferedDataOutputStream(new FileOutputStream(outputFile));
        return bufOut;
    }

    private void addFsIdsFromPixel(BackgroundPixelSource source,
        SortedMap<Pixel, FsIdsForPixel> pixelFsIds, SortedSet<FsId> allFsIds,
        SortedSet<FsId> allMjdIds, Set<FsId> collateralCosmicRayIds,
        Set<FsId> cosmicRayIds, Set<FsId> rollingBandIds, int[] rollingBandPulseDurations, Pixel px) {
        FsIdsForPixel idsForPixel =
            new FsIdsForPixel(source.ccdModule(), source.ccdOutput(), px);
        
        //Getting the collateral cosmic ray ids so we can construct that bit
        //on the data quality column.
        FsId blackId = 
            CalFsIdFactory.getCosmicRaySeriesFsId(CollateralType.BLACK_LEVEL,
                CadenceType.LONG, source.ccdModule(), source.ccdOutput(), 
                px.getRow());
        FsId vSmearId = 
            CalFsIdFactory.getCosmicRaySeriesFsId(CollateralType.VIRTUAL_SMEAR,
                CadenceType.LONG, source.ccdModule(), source.ccdOutput(),
                px.getColumn());
        FsId mSmearId = 
            CalFsIdFactory.getCosmicRaySeriesFsId(CollateralType.MASKED_SMEAR,
                CadenceType.LONG, source.ccdModule(), source.ccdOutput(),
                px.getColumn());
        
        for (int rbPulseDuration : rollingBandPulseDurations) {
            FsId rollingBandId = 
                DynablackFsIdFactory.getRollingBandArtifactFlagsFsId(source.ccdModule(), source.ccdOutput(),
                    px.getRow(), rbPulseDuration);
            rollingBandIds.add(rollingBandId);
        }
        
        allFsIds.addAll(rollingBandIds);
        collateralCosmicRayIds.add(blackId);
        collateralCosmicRayIds.add(vSmearId);
        collateralCosmicRayIds.add(mSmearId);
        allMjdIds.add(blackId);
        allMjdIds.add(vSmearId);
        allMjdIds.add(mSmearId);
        cosmicRayIds.add(idsForPixel.cosmicRay);
        pixelFsIds.put(px, idsForPixel);
        idsForPixel.addTo(allFsIds);
        allMjdIds.add(idsForPixel.cosmicRay);
    }
    
    
    private BarycentricCorrection centerModOutBarycentricCorrection(
        BackgroundPixelSource source, int barycentricCorrectionCadence) {
        
        int referenceCcdColumn = FcConstants.CCD_COLUMNS/2;
        int referenceCcdRow = FcConstants.CCD_ROWS/2;
        Pixel centerPixel = new Pixel(referenceCcdRow, referenceCcdColumn);
        Collection<Pixel> asCollection = ImmutableList.of(centerPixel);
        
        Map<Pixel, BarycentricCorrection> corrections = 
            source.perPixelBarycentricCorrection(barycentricCorrectionCadence, asCollection);
        
        if (!corrections.containsKey(centerPixel)) {
            throw new IllegalStateException("Missing center pixel correction." + 
                                            corrections.size());
        }
        return corrections.get(centerPixel);
    }
    

    private BackgroundTableHeaderSource createBackgroundHeaderSource(
        final BackgroundPixelSource source,
        final SortedMap<Pixel, FsIdsForPixel> pixelFsIds,
        final ExposureCalculator exposureCalc,
        final BarycentricCorrection bcCorrection) {
        
        
        FloatTimeSeries bcTimeSeries = bcCorrection.toFloatTimeSeries(new FsId("/bogus/0"),
            source.startCadence(), source.endCadence());
        
        final double startBkjd = 
            ModifiedJulianDate.mjdToKjd(source.startStartMjd()) + 
            barycentricCorrectionStartOfFirstCadence(bcTimeSeries,
                source.startCadence(), source.endCadence());
        
        final double endBkjd = 
            ModifiedJulianDate.mjdToKjd(source.endEndMjd()) + 
            barycentricCorrectionEndOfLastCadence(bcTimeSeries,
                source.startCadence(), source.endCadence());
        

        return new BackgroundTableHeaderSource() {

            @Override
            public Integer keplerId() {
                return null;
            }

            @Override
            public int nBinaryTableRows() {
                return source.endCadence() - source.startCadence() + 1;
            }

            @Override
            public int readsPerCadence() {
                return exposureCalc.numberOfScienceFramesPerCadence();
            }

            @Override
            public Integer timeSlice() {
                return FcConstants.getCcdModuleTimeSlice(source.ccdModule());
            }

            @Override
            public Integer meanBlackCounts() {
                return source.meanBlack();
            }

            @Override
            public Date observationStartUTC() {
                return ModifiedJulianDate.mjdToDate(source.startStartMjd());
            }

            @Override
            public Date observationEndUTC() {
                return ModifiedJulianDate.mjdToDate(source.endEndMjd());
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
            public double photonAccumulationTimeSec() {
                return exposureCalc.integrationTimeSec();
            }

            @Override
            public double readoutTimePerFrameSec() {
                return exposureCalc.readTimeSec();
            }

            @Override
            public int framesPerCadence() {
                return exposureCalc.numberOfScienceFramesPerCadence();
            }

            @Override
            public double timeResolutionOfDataDays() {
                return exposureCalc.cadenceDurationDays();
            }

            @Override
            public Double gainEPerCount() {
                return source.gainE();
            }

            @Override
            public Double readNoiseE() {
                return source.readNoseE();
            }

            @Override
            public double scienceFrameTimeSec() {
                return exposureCalc.scienceFrameSec();
            }

            @Override
            public Date generatedAt() {
                return source.generatedAt();
            }

            @Override
            public String extensionName() {
                return "BACKGROUND";
            }

            @Override
            public boolean backgroundSubtracted() {
                return false;
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
                return startBkjd;
            }

            @Override
            public double endKbjd() {
                return endBkjd;
            }

            @Override
            public double startMidMjd() {
                return source.cadenceTimes().midTimestamps[0];
            }

            @Override
            public double endMidMjd() {
                double[] midTimestamps = source.cadenceTimes().midTimestamps;
                return midTimestamps[midTimestamps.length - 1];
            }

            @Override
            public double daysOnSource() {
                return exposureCalc.exposureDays();
            }

            @Override
            public double deadC() {
                return exposureCalc.deadC();
            }

            @Override
            public double liveTimeDays() {
                return exposureCalc.liveTimeDays();
            }

            @Override
            public double elaspedTime() {
                return exposureCalc.elaspedTimeDays();
            }

            @Override
            public int nBackgroundPixels() {
                return pixelFsIds.size();
            }
            
        };
    }

    private void writeFile(BackgroundPixelSource source,
        OutputsAndChecksums outputs,
        BackgroundPolynomial backgroundPolynomial,
        BackgroundPrimaryHeaderFormatter primaryHeaderFormatter,
        BasePrimaryHeaderSource primaryHeaderSource,
        BackgroundBinaryTableHeaderFormatter bkgHeaderFormatter,
        BackgroundTableHeaderSource bkgHeaderSource,
        BackgroundPixelListHeaderFormatter pixelListFormatter,
        BaseBinaryTableHeaderSource pixelListSource,
        SipWcsCoordinates sipWcsCoordinates,
        int[] quality, ExposureCalculator exposureCalc,
        Map<Pixel, PixelBkjd> pixelBkjd,
        Map<Pixel, TargetDva> dvaCorrections,
        SortedMap<Pixel, FsIdsForPixel> pixelFsIds,
        Map<FsId, TimeSeries> allTimeSeries,
        Map<FsId, FloatMjdTimeSeries> allMjdTimeSeries,
        ArrayDimensions arrayDimensions) throws FitsException, IOException {

        writePrimaryHeader(outputs, primaryHeaderFormatter, primaryHeaderSource);
        
        writeBackground(source, outputs, exposureCalc,
            backgroundPolynomial,
            bkgHeaderFormatter, bkgHeaderSource, quality, pixelFsIds, 
            allTimeSeries, allMjdTimeSeries, pixelBkjd,
            dvaCorrections, arrayDimensions);
        
        writePixelList(outputs, pixelListFormatter, pixelListSource, pixelFsIds, sipWcsCoordinates, arrayDimensions);
        
    }

    private void writeBackground(BackgroundPixelSource source,
        OutputsAndChecksums outputs, ExposureCalculator exposureCalc,
        BackgroundPolynomial backgroundPolynomial,
        BackgroundBinaryTableHeaderFormatter bkgHeaderFormatter,
        BackgroundTableHeaderSource bkgHeaderSource, int[] quality,
        SortedMap<Pixel, FsIdsForPixel> pixelFsIds,
        Map<FsId, TimeSeries> allTimeSeries,
        Map<FsId, FloatMjdTimeSeries> allMjdTimeSeries,
        Map<Pixel, PixelBkjd> perPixelBarycentricCorrection,
        Map<Pixel, TargetDva> dvaCorrections,
        ArrayDimensions arrayDimensions) throws FitsException, IOException {

                                           
        Header bkgHeader = 
            bkgHeaderFormatter.formatHeader(bkgHeaderSource, outputs.binaryDataChecksum(), backgroundPolynomial, arrayDimensions);
        bkgHeader.write(outputs.binaryDataOut());
        
        ArrayDataOutput backgroundOut = outputs.binaryDataOut();
        TimestampSeries mjdTimes = source.cadenceTimes();
        
        List<FsId> rawPixelIds = collectFsIds(pixelFsIds.values(), SelectNoCal.INST);
        List<FsId> calPixelIds = collectFsIds(pixelFsIds.values(), SelectCal.INST);
        List<FsId> ummPixelIds = collectFsIds(pixelFsIds.values(), SelectUmm.INST);
        List<FsId> cosmicRayIds = collectFsIds(pixelFsIds.values(), SelectCosmicRay.INST);
        
        SingleCadenceImageWriter<PixelBkjd> bkjd = 
            newImageWriter(pixelFsIds.keySet(),
                perPixelBarycentricCorrection, new PixelBkjdCopier(),
                backgroundOut);
        SingleCadenceImageWriter<TimeSeries> rawBackground = 
            newImageWriter(rawPixelIds, 
                allTimeSeries, new IntArrayDataCopier(), backgroundOut);
        SingleCadenceImageWriter<TimeSeries> calBackground = 
            newImageWriter(calPixelIds,
                allTimeSeries, new DoubleToFloatArrayDataCopier(exposureCalc),
                backgroundOut);
        SingleCadenceImageWriter<TimeSeries> ummBackground = 
            newImageWriter(ummPixelIds,
                allTimeSeries, new FloatArrayDataCopier(exposureCalc),
                backgroundOut);
        SingleCadenceImageWriter<FloatMjdTimeSeries> cosmicRayWriter =
            newImageWriter(cosmicRayIds, allMjdTimeSeries,
                new FloatMjdArrayDataCopier(source.startCadence(), source.mjdToCadence(), exposureCalc),
                backgroundOut);
        SingleCadenceImageWriter<TargetDva> ccdColWriter = 
            newImageWriter(pixelFsIds.keySet(), dvaCorrections, 
                new CcdColumnDvaCopier(), backgroundOut);
        SingleCadenceImageWriter<TargetDva> ccdRowWriter = 
            newImageWriter(pixelFsIds.keySet(), dvaCorrections,
                new CcdRowDvaCopier(), backgroundOut);
                
        for (int c=source.startCadence(); c <= source.endCadence(); c++) {
            int index = c - source.startCadence();
            backgroundOut.writeDouble(mjdTimes.midTimestamps[index]);
            bkjd.writeSingleCadenceImage(index);
            backgroundOut.writeInt(mjdTimes.cadenceNumbers[index]);
            rawBackground.writeSingleCadenceImage(index);
            calBackground.writeSingleCadenceImage(index);
            ummBackground.writeSingleCadenceImage(index);
            writePolynomial(index, backgroundPolynomial,backgroundOut);
            cosmicRayWriter.writeSingleCadenceImage(index);
            backgroundOut.writeInt(quality[index]);
            ccdColWriter.writeSingleCadenceImage(index);
            ccdRowWriter.writeSingleCadenceImage(index);
            
        }
        
        long nBytesWritten = bkgHeaderFormatter.bytesPerTableRow(arrayDimensions)
        * (source.endCadence() - source.startCadence() + 1);
        padBinaryTableData(nBytesWritten, backgroundOut);
        backgroundOut.flush();
        
    }
    
    /**
     * Writes both the polynomial coefficients and the covariance polynomial
     *  coefficients.
     *  
     * @param polynomialIndex
     * @param bkgPolys
     * @param dout
     * @throws IOException
     */
    private void writePolynomial(int polynomialIndex, BackgroundPolynomial bkgPolys, DataOutput dout) throws IOException {
        BackgroundPolynomial.Polynomial polynomial = bkgPolys.polynomials()[polynomialIndex];
        double[] coeffs = polynomial.coeffs();
        double[] covarianceCoeffs = polynomial.covarianceCoeffs();
        int nCoeff = bkgPolys.nCoefficients();
        int nCovarianceCoeff = nCoeff * nCoeff;
        if (polynomial.isGap()) {
            for (int i=0; i < nCoeff; i++) {
                dout.writeDouble(BinaryTableUtils.GAP_FILL);
            }
            for (int i=0; i < nCovarianceCoeff; i++) {
                dout.writeDouble(BinaryTableUtils.GAP_FILL);
            }
        } else {
            for (int i=0; i < nCoeff; i++) {
                dout.writeDouble(coeffs[i]);
            }

            for (int i=0; i < nCovarianceCoeff; i++) {
                dout.writeDouble(covarianceCoeffs[i]);
            }
        }
    }

    private void writePrimaryHeader(OutputsAndChecksums outputs,
        BackgroundPrimaryHeaderFormatter primaryHeaderFormatter,
        BasePrimaryHeaderSource primaryHeaderSource) 
        throws HeaderCardException, FitsException, IOException {
        Header primaryHeader = 
            primaryHeaderFormatter.formatHeader(primaryHeaderSource, outputs.primaryChecksum());
        primaryHeader.write(outputs.primaryOut());
        outputs.primaryOut().flush();
    }

    private void writePixelList(OutputsAndChecksums outputs,
        BackgroundPixelListHeaderFormatter pixelListFormatter,
        BaseBinaryTableHeaderSource pixelListSource,
        SortedMap<Pixel, FsIdsForPixel> pixelFsIds,
        SipWcsCoordinates sipWcsCoordinates,
        ArrayDimensions arrayDimensions) throws HeaderCardException,
        FitsException, IOException {
        
        Header pixelListHeader = 
            pixelListFormatter.formatHeader(pixelListSource, 1, sipWcsCoordinates, 
                                            outputs.pixelListChecksum());
        pixelListHeader.write(outputs.pixelListOut());
        for (Pixel px : pixelFsIds.keySet()) {
            outputs.pixelListOut().writeInt(px.getColumn());
            outputs.pixelListOut().writeInt(px.getRow());
        }

        int pixelListBytesWritten = pixelListFormatter.bytesPerTableRow(arrayDimensions) * pixelFsIds.size();
        padBinaryTableData(pixelListBytesWritten, outputs.pixelListOut());
        outputs.pixelListOut().flush();
    }

    private int[] createQualityColumn(final BackgroundPixelSource source,
        final Map<FsId, TimeSeries> allTimeSeries,
        final Map<FsId, FloatMjdTimeSeries> allMjdTimeSeries,
        final Collection<FsId> cosmicRayIds,
        final Collection<FsId> collateralCosmicRayIds,
        final Collection<FsId> rollingBandIds,
        final FsId zeroCrossingsId, final FsId paArgabrighteningId,
        final FsId thrusterFiringId, final FsId possibleThrusterFiringId) {

        final RollingBandFlags rbFlags = RollingBandFlags.newRollingBandFlags(allTimeSeries, rollingBandIds);
        
        DataQualityFlagsSource qSource = new DataQualityFlagsSource() {
            
            @Override
            public int startCadence() {
                return source.startCadence();
            }
            
            @Override
            public IntTimeSeries reactionWheelZeroCrossings() {
                return allTimeSeries.get(zeroCrossingsId).asIntTimeSeries();
            }
            
            @Override
            public FloatMjdTimeSeries pdcOutliers() {
                return null; //OK, background not processed with PDC
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
            
            @Override
            public IntTimeSeries discontinuityTimeSeries() {
                return null;  //OK background not processed with PDC.
            }
            
            @Override
            public Collection<FloatMjdTimeSeries> cosmicRays() {
                return Collections.emptyList();
            }
            
            @Override
            public Collection<FloatMjdTimeSeries> collateralCosmicRays() {
                List<FloatMjdTimeSeries> cosmicRayData = 
                    Lists.newArrayListWithCapacity(collateralCosmicRayIds.size());
                for (FsId crId : collateralCosmicRayIds) {
                    cosmicRayData.add(allMjdTimeSeries.get(crId));
                }
                return cosmicRayData;
            }
            
            @Override
            public List<DataAnomaly> anomalies() {
                return source.anomalies();
            }

            @Override
            public RollingBandFlags rollingBandFlags() {
                return rbFlags;
            }

            @Override
            public TimestampSeries lcTimestampSeries() {
                return null;
            }

            @Override
            public IntTimeSeries thrusterFire() {
                return allTimeSeries.get(thrusterFiringId).asIntTimeSeries();
            }

            @Override
            public IntTimeSeries possibleThusterFire() {
                return allTimeSeries.get(possibleThrusterFiringId).asIntTimeSeries();
            }

            @Override
            public boolean isLcForShortCadence() {
                return false;
            }

            @Override
            public RollingBandFlags optimalApertureRollingBandFlags() {
                return null;  //OK no optimal aperture
            }

        };
        
        QualityFieldCalculator qCalc = new QualityFieldCalculator();
        return qCalc.calculateQualityFlags(qSource);
    }

    private static BasePrimaryHeaderSource createPrimaryHeaderSource(final BackgroundPixelSource source, final boolean isK2) {
    
        
        BasePrimaryHeaderSource primaryHeaderSource = new BasePrimaryHeaderSource() {
            
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
                throw new UnsupportedOperationException();
            }
            
            @Override
            public int quarter() {
                return source.quarter();
            }
            
            @Override
            public String programName() {
                return BackgroundPixelExporter.class.getSimpleName();
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
                return source.targetTableExternalId();
            }

            @Override
            public int extensionHduCount() {
                return 2;
            }
        };
        
        return primaryHeaderSource;
    }
    
    private static final List<FsId> collectFsIds(Collection<FsIdsForPixel> byPixel, FsIdSelector selector) {
        List<FsId> rv = Lists.newArrayListWithCapacity(byPixel.size());
        for (FsIdsForPixel fsIds : byPixel) {
            rv.add(selector.select(fsIds));
        }
        return rv;
    }
    /**
     * Choose an FsId from FsIdsForPixel.
     *
     */
    private interface FsIdSelector {
        FsId select(FsIdsForPixel fsIds);
    }
    
    private static final class SelectNoCal implements FsIdSelector {
        static final SelectNoCal INST = new SelectNoCal();
        @Override
        public FsId select(FsIdsForPixel fsIds) {
            return fsIds.noCal;
        }
    }
    
    private static final class SelectCal implements FsIdSelector {
        static final SelectCal INST = new SelectCal();

        @Override
        public FsId select(FsIdsForPixel fsIds) {
            return fsIds.cal;
        }
    }
    
    private static final class SelectUmm implements FsIdSelector {
        static final SelectUmm INST = new SelectUmm();
        @Override
        public FsId select(FsIdsForPixel fsIds) {
            return fsIds.umm;
        }
    }
    
    private static final class SelectCosmicRay implements FsIdSelector {
        static final SelectCosmicRay INST = new SelectCosmicRay();
        @Override
        public FsId select(FsIdsForPixel fsIds) {
            return fsIds.cosmicRay;
        }
    }
    
    
    private static final class FsIdsForPixel {
        public final FsId noCal;
        public final FsId cal;
        public final FsId umm;
        public final FsId cosmicRay;
        public FsIdsForPixel(int ccdModule, int ccdOutput, Pixel px) {
            
            noCal  = DrFsIdFactory.getSciencePixelTimeSeries(DrFsIdFactory.TimeSeriesType.ORIG,
                TargetTable.TargetType.BACKGROUND,
                ccdModule, ccdOutput,
                px.getRow(), px.getColumn());
            cal = 
                 CalFsIdFactory.getTimeSeriesFsId(CalFsIdFactory.PixelTimeSeriesType.SOC_CAL,
                     TargetTable.TargetType.BACKGROUND,
                     ccdModule, ccdOutput,
                     px.getRow(), px.getColumn());
            umm= CalFsIdFactory.getTimeSeriesFsId(CalFsIdFactory.PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES,
                TargetTable.TargetType.BACKGROUND,
                ccdModule, ccdOutput,
                px.getRow(), px.getColumn());
            cosmicRay = 
                PaFsIdFactory.getCosmicRaySeriesFsId(TargetTable.TargetType.BACKGROUND,
                    ccdModule, ccdOutput, px.getRow(), px.getColumn());
        }
        
        public void addTo(Set<FsId> fsIds) {
            fsIds.add(noCal);
            fsIds.add(cal);
            fsIds.add(umm);
        }
    }
    
    /**
     * This is the computed per pixel barycentric time stamp series.
     * 
     * @author Sean McCauliff
     *
     */
    private static final class PixelBkjd {
        private final double[] bkjdTimes;
        
        public PixelBkjd(TimestampSeries mjdTimes, BarycentricCorrection correction, int startCadence, int endCadence) {
            FloatTimeSeries bcAsFloatTimeSeries = correction.toFloatTimeSeries(new FsId("/bs/blah"), startCadence, endCadence);
            
            bkjdTimes = 
                bkjdTimestampSeries(mjdTimes.midTimestamps,
                    mjdTimes.gapIndicators, bcAsFloatTimeSeries, Double.NaN);
        }
        
        double[] bkjdTimes() {
            return bkjdTimes;
        }
    }
    
    private static final class PixelBkjdCopier implements ArrayDataCopier<PixelBkjd> {

        @Override
        public void fillNull(DataOutput dout) throws IOException {
            dout.writeDouble(BinaryTableUtils.GAP_FILL);
        }

        @Override
        public void copy(DataOutput dout, int tsi, PixelBkjd t)
            throws IOException {
            
            dout.writeDouble(t.bkjdTimes()[tsi]);
        }
        
    }
    
    private static final class CcdColumnDvaCopier implements ArrayDataCopier<TargetDva> {

        @Override
        public void fillNull(DataOutput dout) throws IOException {
            dout.writeFloat(BinaryTableUtils.GAP_FILL);
        }

        @Override
        public void copy(DataOutput dout, int tsi, TargetDva t)
            throws IOException {
            dout.writeFloat(t.getColumnDva()[tsi]);
        }
        
    }
    
    private static final class CcdRowDvaCopier implements ArrayDataCopier<TargetDva> {

        @Override
        public void fillNull(DataOutput dout) throws IOException {
            dout.writeFloat(BinaryTableUtils.GAP_FILL);
        }

        @Override
        public void copy(DataOutput dout, int tsi, TargetDva t)
            throws IOException {
            dout.writeFloat(t.getRowDva()[tsi]);
        }
        
    }
}
