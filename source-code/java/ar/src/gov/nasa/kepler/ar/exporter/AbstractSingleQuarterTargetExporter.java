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

package gov.nasa.kepler.ar.exporter;

import static com.google.common.base.Preconditions.checkNotNull;
import gnu.trove.TLongHashSet;
import gov.nasa.kepler.ar.archive.BarycentricCorrection;
import gov.nasa.kepler.ar.archive.TargetDva;
import gov.nasa.kepler.ar.archive.TargetWcs;
import gov.nasa.kepler.ar.exporter.tpixel.TargetImageDimensionCalculator.TargetImageDimensions;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesDataType;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.*;

import nom.tam.fits.FitsException;
import nom.tam.util.ArrayDataOutput;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.base.Predicate;
import com.google.common.base.Predicates;
import com.google.common.collect.Constraints;
import com.google.common.collect.MapConstraints;

/**
 * This is a base class for the target pixel exporter and the flux2 (light
 * curve) exporter.  This is suitable for use when there is a 1:1 mapping between
 * FITS files and targets for a single quarter.
 * 
 * @author Sean McCauliff
 * 
 */
public abstract class AbstractSingleQuarterTargetExporter<
    M extends AbstractTargetSingleQuarterMetadata,
    S extends SingleQuarterExporterSource> 
    extends AbstractTargetExporter<M, S> {
    
    private static final Log log = LogFactory.getLog(AbstractSingleQuarterTargetExporter.class);

    //source must be defined here a PerTargetExporterSource rather than type S
    //because we actually need to call methods on source.  Some of these
    //methods conflict with returns types needed for multiquarter targets.
    /**
     * Assembles the export data for all targets. There is a whole bunch of
     * logic to deal with custom targets and filling in missing data for some
     * targets.
     * 
     * @param source must not be null
     * @param observedTargetFilter when true retain the target, this is useful
     * to remove some targets which should not be exported.
     * @param metadataFactory create metadata for a specific data product.
     * @return
     */
    protected 
        ExportData<M> exportData( SingleQuarterExporterSource source,
            Predicate<ObservedTarget> observedTargetFilter,
            TargetMetadataFactory<M> metadataFactory) {

        log.info("Start assembling the export data.");
        log.info("Exporting files for " + source.cadenceType()
            + " cadences [" + source.startCadence() + "," + source.endCadence()
            + "] and mod/out " + source.ccdModule() + "/" + source.ccdOutput()
            + " target table " + source.targetTableExternalId() + ".");

        checkSizes(source);

        TLongHashSet sourceTaskIds = new TLongHashSet();
        SortedMap<Integer, M> keplerIdToTargetPixelMetadata = 
            mapTargetsToMetadata(source, metadataFactory, sourceTaskIds,
                observedTargetFilter);

        if (keplerIdToTargetPixelMetadata.isEmpty()) {
            log.warn("All targets skipped.");
            ExportData<M> empty = ExportData.empty();
            return empty;
        }
        
        Map<FsId, TimeSeriesDataType> timeSeriesFsIds =
            new HashMap<FsId, TimeSeriesDataType>(1024 * 4);
        Set<FsId> mjdTimeSeriesFsIds = new HashSet<FsId>(1024 * 4);
        for (M targetMetadata : keplerIdToTargetPixelMetadata.values()) {
            targetMetadata.addToTimeSeriesIds(timeSeriesFsIds);
            targetMetadata.addToMjdTimeSeriesIds(mjdTimeSeriesFsIds);
        }

        Map<FsId, TimeSeriesDataType> lcFsIds = new HashMap<FsId, TimeSeriesDataType>();
        
        DataQualityMetadata<M> dataQualityMetadata = 
            new DataQualityMetadata<M>(source.targetTableExternalId(), source.longCadenceExternalTargetTableId(),
                source.cadenceType(), 
                source.cadenceType() == CadenceType.SHORT,
                source.ccdModule(), source.ccdOutput(),
                source.startCadence(), source.endCadence(),
                source.anomalies(), source.mjdToCadence(),
                source.timestampSeries(), source.longCadenceTimestampSeries());
     
        dataQualityMetadata.addTimeSeriesTo(timeSeriesFsIds);

        DataQualityMetadata<M> lcDataQualityMetadata = null;
        if (source.cadenceType() == CadenceType.SHORT) {
            lcDataQualityMetadata =
            new DataQualityMetadata<M>(source.targetTableExternalId(), source.longCadenceExternalTargetTableId(),
                CadenceType.LONG, 
                true,
                source.ccdModule(), source.ccdOutput(),
                source.cadenceToLongCadence(source.startCadence()),
                source.cadenceToLongCadence(source.endCadence()),
                source.longCadenceAnomalies(), source.longCadenceMjdToCadence(),
                source.timestampSeries(), source.longCadenceTimestampSeries());
            
            lcDataQualityMetadata.addTimeSeriesTo(lcFsIds);
        }
        
        
        for (M targetMetadata : keplerIdToTargetPixelMetadata.values()) {
            targetMetadata.addToLongCadenceFsIds(lcFsIds);
        }
        
        Pair<Map<FsId, TimeSeries>, Map<FsId, FloatMjdTimeSeries>> allTimeSeries = fetchFileStoreStuff(
            timeSeriesFsIds, mjdTimeSeriesFsIds, sourceTaskIds,
            source.startCadence(), source.endCadence(), source.cadenceType(),
            source.cadenceToLongCadence(source.startCadence()),
            source.cadenceToLongCadence(source.endCadence()),
            lcFsIds, source.mjdToCadence(), source.fsClient());

        source.originatorsModelRegistryChecker().check(allTimeSeries);

        calculateQualityFlags(source.cadenceType(), keplerIdToTargetPixelMetadata,
            dataQualityMetadata, lcDataQualityMetadata, 
            allTimeSeries);

        removeEmptyEntries(keplerIdToTargetPixelMetadata, allTimeSeries.left,
            allTimeSeries.right);

        fillInMissingData(keplerIdToTargetPixelMetadata.values(),
            allTimeSeries.left, allTimeSeries.right, source,
            keplerIdToTargetPixelMetadata);

        targetPositionCorrections(source, keplerIdToTargetPixelMetadata,
            allTimeSeries);

        targetWcs(source, keplerIdToTargetPixelMetadata, allTimeSeries);

        skippedTargetsReport(source.keplerIds(), keplerIdToTargetPixelMetadata);

        log.info("End assembling the export data.");

        return new ExportData<M>(allTimeSeries.left, allTimeSeries.right,
            keplerIdToTargetPixelMetadata.values(), sourceTaskIds);
    }


    /**
     * Unconditionally add data quality flags of the native cadence to the
     * targetMetadata objects.  If the cadence is short, also add long-cadence data
     * quality flags to the target metadata objects.
     * 
     * @param lcDataQualityMetadata this may be null if we are exporting
     * long cadence targets.
     */
    private 
        void calculateQualityFlags(
            CadenceType cadenceType,
            SortedMap<Integer, M> keplerIdToTargetPixelMetadata,
            DataQualityMetadata<M> dataQualityMetadata,
            DataQualityMetadata<M> lcDataQualityMetadata,
            Pair<Map<FsId, TimeSeries>, Map<FsId, FloatMjdTimeSeries>> allTimeSeries) {
        
        for (M targetMetadata : keplerIdToTargetPixelMetadata.values()) {
            // This is generated at the full [start,end] not the targets'
            // [start,end]
            int[] qualityFlags = createQualityColumn(targetMetadata,
                allTimeSeries.left, allTimeSeries.right, dataQualityMetadata);
            targetMetadata.setDataQualityFlags(qualityFlags);

            if (cadenceType == CadenceType.SHORT) {
                int[] lcQualityFlags = createQualityColumn(targetMetadata,
                    allTimeSeries.left, allTimeSeries.right,
                    lcDataQualityMetadata
                    );
                AbstractTargetSingleQuarterMetadata singleQuarterMetadata = 
                    (AbstractTargetSingleQuarterMetadata) targetMetadata;
                singleQuarterMetadata.setLongCadenceDataQualityFlags(lcQualityFlags);
            }
        }
    }

    /**
     * @param source
     * @param metadataFactory
     * @param keplerIdToKic
     * @param keplerIdToObservedTarget
     * @param keplerIdToCdpp
     * @param sourceTaskIds
     * @return
     */
    protected  
        SortedMap<Integer, M> mapTargetsToMetadata(
            SingleQuarterExporterSource source,
            TargetMetadataFactory<M> metadataFactory,
            TLongHashSet sourceTaskIds,
            Predicate<ObservedTarget> observedTargetFilter) {

        Map<Integer, CelestialObject> keplerIdToKic = MapConstraints.constrainedMap(
            new HashMap<Integer, CelestialObject>(), MapConstraints.notNull());
        addCelestialObjectsToMap(keplerIdToKic, source.celestialObjects());

        List<MissingDataCelestialObject> missingDataTargets = 
            targetsMissingData(source.observedTargets(), source.celestialObjects());
        log.info("Found " + missingDataTargets.size() + " targets missing ra/dec.");
        
        addCelestialObjectsToMap(keplerIdToKic, missingDataTargets);

        observedTargetFilter =
            augmentObservedTargetFilter(observedTargetFilter, source);
        
        Map<Integer, ObservedTarget> keplerIdToObservedTarget = toObservedTargetMap(
            source.observedTargets(), observedTargetFilter);
        
        Map<Integer, RmsCdpp> keplerIdToCdpp = toTpsDbResultMap(source.tpsDbResults());
        
        SortedMap<Integer, M> keplerIdToTargetPixelMetadata =
            buildTargetMetadata(source, keplerIdToKic,
                keplerIdToObservedTarget,
                keplerIdToCdpp,
                sourceTaskIds,
                source.ccdModule(),
                source.ccdOutput(),
                metadataFactory,
                source.sciOps());

        fetchRollingBandFlags(
                source.longCadenceExternalTargetTableId(),
                keplerIdToTargetPixelMetadata, 
                source.longCadenceTimestampSeries(),
                source.fsClient());
        
        return keplerIdToTargetPixelMetadata;

    }

    /**
     * Require equal sizes of three collections in the source. Log that size.
     * @throws IllegalArgumentException if the source's observedTargets,
     * keplerIds and celestialObjects do not all have the same same size.
     * @param source must not be null
     */
    protected void checkSizes(final SingleQuarterExporterSource source)
        throws IllegalArgumentException {
        final int celestialObjectsSize = source.celestialObjects().size();
        final int keplerIdsSize = source.keplerIds().size();
        final int observedTargetsSize = source.observedTargets().size();
        if (keplerIdsSize != celestialObjectsSize) {
            throw new IllegalArgumentException("KeplerIds.size() "
                + keplerIdsSize + " != celestialObjects.size() "
                + celestialObjectsSize);
        }

        if (observedTargetsSize != keplerIdsSize) {
            throw new IllegalArgumentException("observedTargets.size() "
                + observedTargetsSize + " != keplerIds.size() "
                + keplerIdsSize);
        }

        log.info("Found " + observedTargetsSize + " observed targets.");
    }
    
    /**
     * Add an excluded-labels test to observedTargetFilter and return it.
     * @param observedTargetFilter a possibly-null Predicate on an
     * ObservedTarget
     * @return a non-null Predicate on an ObservedTarget that includes an
     * excluded labels test
     */
    protected Predicate<ObservedTarget> augmentObservedTargetFilter(
        Predicate<ObservedTarget> observedTargetFilter,
        final SingleQuarterExporterSource source) {
  
        Predicate<ObservedTarget> filterByLabels = new Predicate<ObservedTarget>() {

            @Override
            public boolean apply(ObservedTarget input) {
                if (input == null) {
                    return false;
                }

                Set<String> targetLabels = input.getLabels();

                for (String xLabel : source.excludeTargetsWithLabel()) {
                    if (targetLabels.contains(xLabel)) {
                        log.warn("Skipped target with Kepler ID "
                            + input.getKeplerId() + " it is labeled as \""
                            + xLabel + "\" which is not allowed.");
                        return false;
                    }
                }
                return true;
            }
        };

        if (observedTargetFilter == null) {
            observedTargetFilter = filterByLabels; // initialize
        } else {
            observedTargetFilter = 
                Predicates.and(filterByLabels, observedTargetFilter); // augment
        }
        
        return observedTargetFilter;
        
    }

    /**
     * Populates the target metadata's WCS information.
     * @param source non-null
     * @param keplerIdToTargetPixelMetadata non-null
     * @param allTimeSeries non-null
     */
    protected final void targetWcs(SingleQuarterExporterSource source,
        SortedMap<Integer, M> keplerIdToTargetPixelMetadata,
        Pair<Map<FsId, TimeSeries>, Map<FsId, FloatMjdTimeSeries>> allTimeSeries) {
        Map<Integer, TargetWcs> targetWcs = source.wcsCoordinates(
            keplerIdToTargetPixelMetadata.values(), allTimeSeries.left);
        for (AbstractTargetSingleQuarterMetadata targetMetadata : keplerIdToTargetPixelMetadata.values()) {
            targetMetadata.setWcs(targetWcs.get(targetMetadata.keplerId()));
        }
    }

    /**
     * Populates the target metadata's position corrections.
     * @param source non-null
     * @param keplerIdToTargetPixelMetadata non-null
     * @param allTimeSeries non-null
     */
    protected 
        void targetPositionCorrections(
            SingleQuarterExporterSource source,
            SortedMap<Integer, M> keplerIdToTargetPixelMetadata,
            Pair<Map<FsId, TimeSeries>, Map<FsId, FloatMjdTimeSeries>> allTimeSeries) {
        
        PositionCorrectionFilter positionCorrectionFilter = new PositionCorrectionFilter();
        Map<Integer, TargetDva> targetDva = source.dvaMotion(
            keplerIdToTargetPixelMetadata.values(), allTimeSeries.left);
        for (M targetMetadata : keplerIdToTargetPixelMetadata.values()) {
            TargetDva originalPositonCorrections = targetDva.get(targetMetadata.keplerId());
            TargetDva filteredPositions = positionCorrectionFilter.positionCorrectionFilter(
                originalPositonCorrections, targetMetadata.dataQualityFlags());
            targetMetadata.setDva(filteredPositions);
        }
    }


    /**
     * Return a new non-null Map from Kepler ID as an Integer to a non-null 
     * ObservedTarget, where all ObservedTargets are in a supplied list and all
     * satisfy a supplied filter.
     * @param observedTargets a non-null List of possibly-null ObservedTarget
     * objects
     * @param observedTargetFilter a non-null Predicate that determines which
     * ObservedTargets are inserted into the Map
     */
    private static Map<Integer, ObservedTarget> toObservedTargetMap(
        List<ObservedTarget> observedTargets,
        Predicate<ObservedTarget> observedTargetFilter) {
        Map<Integer, ObservedTarget> keplerIdToObservedTarget = MapConstraints.constrainedMap(
            new HashMap<Integer, ObservedTarget>(observedTargets.size() * 2),
            MapConstraints.notNull());
        for (ObservedTarget observedTarget : observedTargets) {
            if (observedTarget == null) {
                continue;
            }
            if (!observedTargetFilter.apply(observedTarget)) {
                continue;
            }
            keplerIdToObservedTarget.put(observedTarget.getKeplerId(),
                observedTarget);
        }
        return keplerIdToObservedTarget;
    }

    /**
     * Return a new Map from Kepler ID as Integer to a non-null metadata
     * object. Targets are inserted into the Map only if they have a
     * CelestialObject in a given map. The metadata object contains the 
     * ObservedTarget, CelestialObject, TargetCdpp and Set of pixels
     * retrieved from the arguments.
     * @param source ignored
     * @param keplerIdToCelestialObject a non-null Map from Kepler ID as
     * Integer to Celestial object. If this Map does not contain a non-null
     * CelestialObject, the target is not inserted into the returned value
     * @param keplerIdToObservedTarget a non-null map from Kepler ID as Integer
     * to non-null ObservedTarget, the source of the Kepler ID keys in the
     * returned value
     * @param keplerIdToCdpp a non-null Map from Kepler ID as Integer to 
     * TargetCDPP
     * @param sourceTaskIds a non-null out parameter collection to which are
     * added the pipeline task IDs of the the ObservedTargets in the given map
     * @param ccdModule the CCD module for the ObservedTargets in the given map
     * @param ccdOutput the CCD output for the ObservedTargets in the given map
     * @param metadataFactory
     * @param sciOps a non-null object used to retrieve the set of pixels for
     * each ObservedTarget
     */
    protected 
        SortedMap<Integer, M> buildTargetMetadata(
            SingleQuarterExporterSource source,
            Map<Integer, CelestialObject> keplerIdToCelestialObject,
            Map<Integer, ObservedTarget> keplerIdToObservedTarget,
            Map<Integer, RmsCdpp> keplerIdToCdpp, TLongHashSet sourceTaskIds,
            int ccdModule, int ccdOutput, TargetMetadataFactory<M> metadataFactory,
            SciencePixelOperations sciOps) {

        log.info("Starting to build target metadata.");
        SortedMap<Integer, M> perTargetMetadata = new TreeMap<Integer, M>();

        for (ObservedTarget observedTarget : keplerIdToObservedTarget.values()) {
            int keplerId = observedTarget.getKeplerId();
            sourceTaskIds.add(observedTarget.getPipelineTask()
                .getId());
            Set<Pixel> targetPixels = sciOps.loadTargetPixels(observedTarget,
                ccdModule, ccdOutput);

            CelestialObject celestialObject = keplerIdToCelestialObject.get(observedTarget.getKeplerId());
            if (celestialObject == null) {
                log.warn("Skipping target " + observedTarget.getKeplerId()
                    + " because it is missing a celestial object.");
                continue;
            }

            RmsCdpp cdpp = keplerIdToCdpp.get(keplerId);

            M metadata = metadataFactory.create(
                keplerIdToCelestialObject.get(keplerId), targetPixels,
                observedTarget, cdpp);
            perTargetMetadata.put(observedTarget.getKeplerId(), metadata);

        }
        log.info("Building target metadata is complete.");
        return perTargetMetadata;
    }

    /**
     * Generate a list of targets that are missing RA or DEC.
     * 
     * @param observedTargets
     * @param celestialObjects
     * @return a non-null list of MissingDataCelestialObjects
     */
    protected List<MissingDataCelestialObject> targetsMissingData(
        List<ObservedTarget> observedTargets,
        List<CelestialObject> celestialObjects) {

        List<MissingDataCelestialObject> missingDataCelestialObjects = Constraints.constrainedList(
            new ArrayList<MissingDataCelestialObject>(), Constraints.notNull());

        for (int i = 0; i < celestialObjects.size(); i++) {
            CelestialObject celestialObject = celestialObjects.get(i);
            if (celestialObject == null) {
                continue;
            }

            ObservedTarget observedTarget = observedTargets.get(i);

            if (observedTarget == null) {
                continue;
            }

            if (Double.isNaN(celestialObject.getRa())
                || Double.isNaN(celestialObject.getDec())) {

                MissingDataCelestialObject missing = new MissingDataCelestialObject(
                    celestialObject);
                missingDataCelestialObjects.add(missing);
            }
        }

        return missingDataCelestialObjects;
    }

    /**
     * for every custom target: calculate its reference cadence, get its
     * correction, set the ra/dec and set the barycentric correction on the
     * target metadata.
     */
    protected 
        void fillInMissingData(Collection<M> missingDataTargets,
            Map<FsId, TimeSeries> allTimeSeries,
            Map<FsId, FloatMjdTimeSeries> allMjdTimeSeries,
            SingleQuarterExporterSource source, Map<Integer, M> metadatas) {

        log.info("Beginning to fill in missing data.");
        log.info("Calculating barycentric time offsets.");
        Map<Integer, BarycentricCorrection> barycentricCorrections = source.barycentricCorrection(
            missingDataTargets, allTimeSeries);

        for (M targetMetadata : missingDataTargets) {
            BarycentricCorrection bc = barycentricCorrections.get(targetMetadata.keplerId());
            if (bc == null) {
                throw new NullPointerException(
                    "Missing barycentric correction for "
                        + targetMetadata.keplerId());
            }
            if (targetMetadata.celestialObject() instanceof MissingDataCelestialObject) {
                MissingDataCelestialObject pseudoKic = (MissingDataCelestialObject) targetMetadata.celestialObject();
                pseudoKic.setDec(bc.getDecDecimalDegrees());
                pseudoKic.setRa(bc.getRaDecimalHours());
            }
            targetMetadata.setBarycentricCorrection(bc);

        }
        log.info("Filling missing data is complete.");
    }


    protected final 
        CelestialWcsKeywordValueSource createCelestialWcsKeywordValueSource(
        final M targetMetadata, final Map<FsId, TimeSeries> timeSeries) {

        final TargetWcs targetWcs = targetMetadata.wcs();
        if (targetWcs == null) {
            return new DefaultCelestialWcs();
        }

        return new CelestialWcsKeywordValueSource() {

            @Override
            public Double[][] transformationMatrix() {
                Double[][] pc = new Double[2][2];
                pc[0][0] = targetWcs.getUnitMatrixRotationMatrix11()
                    .getValue();
                pc[0][1] = targetWcs.getUnitMatrixRotationMatrix12()
                    .getValue();
                pc[1][0] = targetWcs.getUnitMatrixRotationMatrix21()
                    .getValue();
                pc[1][1] = targetWcs.getUnitMatrixRotationMatrix22()
                    .getValue();
                return pc;
            }

            @Override
            public Double raScale() {
                return targetWcs.getUnitMatrixDegreesPerPixelColumn()
                    .getValue();
            }

            @Override
            public Double decScale() {
                return targetWcs.getUnitMatrixDegreesPerPixelRow()
                    .getValue();
            }

            @Override
            public Double referencePixelRow() {
                return targetWcs.getSubimageCoordinateSystemReferenceRow()
                    .getValue();

            }

            @Override
            public Double referencePixelColumn() {
                return targetWcs.getSubimageCoordinateSystemReferenceColumn()
                    .getValue();
            }

        };

    }

    /**
     * Writes out the aperture mask HDU to the specified output stream.
     * 
     * @param targetMetadata
     * @param bufOut
     * @param imageDimensions
     * @param checksumString
     * @param wcsSource This may be null.
     * @throws FitsException
     */
    protected 
        void writeApertureMaskHdu(M targetMetadata,
            ArrayDataOutput bufOut,
            TargetImageDimensions imageDimensions,
            String checksumString,
            CelestialWcsKeywordValueSource wcsSource) throws FitsException {

        ApertureMaskImageBuilder apertureMaskImageBuilder = new ApertureMaskImageBuilder();
        final int[][] apertureMaskImage = apertureMaskImageBuilder.buildImage(
            targetMetadata.aperturePixels(), imageDimensions.referenceRow,
            imageDimensions.referenceColumn, imageDimensions.nColumns,
            imageDimensions.nRows, targetMetadata.targetAperture());

        for (int[] row : apertureMaskImage) {
            for (int i = 0; i < row.length; i++) {
                row[i] &= apertureMaskPixelMask();
            }
        }

        formatApertureMask(targetMetadata, bufOut, imageDimensions, checksumString,
            wcsSource, apertureMaskImage);
    }

    /**
     * Auxiliary to format the collected data.
     * @param targetMetadata aggregates data about the target
     * @param bufOut an OutputStream to which the data are archived
     * @param imageDimensions the target's bounding box
     * @param checksumString
     * @param wcsSource for the target's Right Ascension and Declination
     * @param apertureMaskImage
     * @throws FitsException
     * @throws NullPointerException if targetMetadata or imageDimensions is null
     */
    protected 
        void formatApertureMask(final M targetMetadata, final ArrayDataOutput bufOut,
            final TargetImageDimensions imageDimensions,
            final String checksumString,
            final CelestialWcsKeywordValueSource wcsSource,
            final int[][] apertureMaskImage) throws FitsException {
        checkNotNull(targetMetadata, "targetMetadata can't be null");
        checkNotNull(imageDimensions, "imageDimensions can't be null");
        ApertureMaskFormatter apertureMaskFormatter = new ApertureMaskFormatter();
        apertureMaskFormatter.format(bufOut, new ApertureMaskSource() {

            @Override
            public double raDegrees() {
                return targetMetadata.raDegrees();
            }

            @Override
            public int nRows() {
                return imageDimensions.nRows;
            }

            @Override
            public int nColumns() {
                return imageDimensions.nColumns;
            }

            @Override
            public int keplerId() {
                return targetMetadata.keplerId();
            }

            @Override
            public double decDegrees() {
                return targetMetadata.celestialObject()
                    .getDec();
            }

            @Override
            public int[][] apertureMaskImage() {
                return apertureMaskImage;
            }

            @Override
            public int referenceCcdColumn() {
                return imageDimensions.referenceColumn;
            }

            @Override
            public int referenceCcdRow() {
                return imageDimensions.referenceRow;
            }

            @Override
            public Date generatedAt() {
                return targetMetadata.generatedAt();
            }

            @Override
            public String checksumString() {
                return checksumString;
            }

            @Override
            public int nPixelsInOptimalAperture() {
                int count = 0;
                for (Pixel pixel : targetMetadata.aperturePixels()) {
                    if (pixel.isInOptimalAperture()) {
                        count++;
                    }
                }
                return count;
            }

            @Override
            public int nPixelsMissingInOptimalAperture() {
                return targetMetadata.nPixelsMissingInOptimalAperture();
            }

            @Override
            public double fluxFractionInOptimalApertuire() {
                return targetMetadata.fluxFractionInOptimalAperture();
            }
            @Override
            public boolean isK2() {
                return targetMetadata.isK2Target();
            }
            

        }, wcsSource);
    }
}
