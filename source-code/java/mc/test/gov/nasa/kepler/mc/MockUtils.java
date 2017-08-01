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

package gov.nasa.kepler.mc;

import static gov.nasa.spiffy.common.jmock.JMockTest.returnValue;
import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.common.AncillaryPipelineData;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.fc.FcModelMetadata;
import gov.nasa.kepler.fc.FlatFieldModel;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.GeometryModel;
import gov.nasa.kepler.fc.LinearityModel;
import gov.nasa.kepler.fc.PointingModel;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.RollTimeModel;
import gov.nasa.kepler.fc.SaturatedStar;
import gov.nasa.kepler.fc.SaturationModel;
import gov.nasa.kepler.fc.SaturationOperations;
import gov.nasa.kepler.fc.TargetPixel;
import gov.nasa.kepler.fc.TwoDBlackModel;
import gov.nasa.kepler.fc.UndershootModel;
import gov.nasa.kepler.fc.flatfield.FlatFieldOperations;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.invalidpixels.PixelOperations;
import gov.nasa.kepler.fc.linearity.LinearityOperations;
import gov.nasa.kepler.fc.prf.PrfModel;
import gov.nasa.kepler.fc.prf.PrfOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fc.twodblack.TwoDBlackOperations;
import gov.nasa.kepler.fc.undershoot.UndershootOperations;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.cm.CelestialObjectUtils;
import gov.nasa.kepler.hibernate.cm.CustomTarget;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dr.DataAnomaly.DataAnomalyType;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.fc.PixelType;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.MeanBlackEntry;
import gov.nasa.kepler.hibernate.gar.RequantEntry;
import gov.nasa.kepler.hibernate.gar.RequantTable;
import gov.nasa.kepler.hibernate.mc.DoubleDbTimeSeries;
import gov.nasa.kepler.hibernate.mc.DoubleDbTimeSeriesCrud;
import gov.nasa.kepler.hibernate.mc.DoubleTimeSeriesType;
import gov.nasa.kepler.hibernate.mr.MrReport;
import gov.nasa.kepler.hibernate.pa.BackgroundBlobMetadata;
import gov.nasa.kepler.hibernate.pa.MotionBlobMetadata;
import gov.nasa.kepler.hibernate.pa.PaCrud;
import gov.nasa.kepler.hibernate.pa.UncertaintyBlobMetadata;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadata;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.ModelType;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.mc.ancillary.AncillaryOperations;
import gov.nasa.kepler.mc.blob.BlobData;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectParameter;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.DrConstants;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.DataAnomalyFlags;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.fs.AncillaryFsIdFactory;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.BlobSeriesType;
import gov.nasa.kepler.mc.mr.GenericReportOperations;
import gov.nasa.kepler.mc.ppa.AttitudeSolution;
import gov.nasa.kepler.services.alert.AlertService;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.spiffy.common.collect.ArrayUtils;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.jmock.Expectations;
import org.jmock.Mockery;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableSet;

/**
 * Creation of test data and setting expectations.
 * 
 * @author Forrest Girouard
 * 
 */
public class MockUtils {

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(MockUtils.class);

    public static final float FLUX_FRACTION_IN_APERTURE = 0.85F;
    public static final float CROWDING_METRIC = 0.25F;

    public static final int MINUTES_PER_DAY = 24 * 60;
    public static final long RANDOM_SEED = 88673117554L;

    private static final String MAT_FILE_EXTENSION = ".mat";

    private static final double DEFAULT_RA = 17.13;
    private static final double DEFAULT_DEC = 31.71;
    private static final float DEFAULT_MAG = 12.0F;
    private static final int BLOB_SIZE = 1024;

    /**
     * Use an explicit seed value so that data generated by different runs of
     * the same test are identical.
     */
    private static Random random = new Random(RANDOM_SEED);

    private MockUtils() {
    }

    public static Pixel getNextPixel(int pixelsPerTarget,
        Set<Pixel> pixelsInUse, Random random) {

        int targetDimension = (int) Math.ceil(Math.sqrt(pixelsPerTarget));
        int halfTargetDimension = targetDimension / 2;
        int rowRange = FcConstants.nRowsImaging - targetDimension;
        int columnRange = FcConstants.nColsImaging - targetDimension;

        Pixel pixel = null;
        while (pixel == null || pixelsInUse.contains(pixel)) {
            int row = random.nextInt(rowRange) + halfTargetDimension;
            int column = random.nextInt(columnRange) + halfTargetDimension;
            pixel = new Pixel(row, column);
        }
        pixelsInUse.add(pixel);

        return pixel;
    }

    public static Offset getNextOffset(int pixelsPerTarget,
        Pixel referencePixel, Set<Pixel> pixelsInUse, Random random) {

        Offset offset = null;
        int minOffset = 0;
        int maxOffset = (int) Math.ceil(Math.sqrt(pixelsPerTarget));
        while (offset == null) {
            for (int row = minOffset; offset == null && row < maxOffset; row++) {
                for (int column = minOffset; offset == null
                    && column < maxOffset; column++) {
                    Pixel pixel = new Pixel(referencePixel.getRow() + row,
                        referencePixel.getColumn() + column);
                    if (!pixelsInUse.contains(pixel)) {
                        pixelsInUse.add(pixel);
                        offset = new Offset(row, column);
                    }
                }
            }
            if (offset == null) {
                minOffset = maxOffset;
                maxOffset++;
            }
        }

        return offset;
    }

    private static List<FsId> getTargetFsIds(TargetType targetType,
        int ccdModule, int ccdOutput, Pixel referencePixel, List<Offset> offsets) {

        List<FsId> fsIds = new ArrayList<FsId>();
        for (Offset offset : offsets) {
            int row = referencePixel.getRow() + offset.getRow();
            int column = referencePixel.getColumn() + offset.getColumn();
            fsIds.add(CalFsIdFactory.getTimeSeriesFsId(
                CalFsIdFactory.PixelTimeSeriesType.SOC_CAL, targetType,
                ccdModule, ccdOutput, row, column));
            fsIds.add(CalFsIdFactory.getTimeSeriesFsId(
                CalFsIdFactory.PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES,
                targetType, ccdModule, ccdOutput, row, column));
        }

        return fsIds;
    }

    private static FloatTimeSeries[] createGappedFloatTimeSeries(
        int startCadence, int endCadence, long producerTaskId, FsId[] fsIds) {

        final FloatTimeSeries[] floatTimeSeries = new FloatTimeSeries[fsIds.length];
        for (int i = 0; i < floatTimeSeries.length; i++) {
            FsId id = fsIds[i];
            float[] fseries = new float[endCadence - startCadence + 1];
            boolean[] gaps = new boolean[fseries.length];
            Arrays.fill(gaps, true);
            FloatTimeSeries timeSeries = new FloatTimeSeries(id, fseries,
                startCadence, endCadence, gaps, producerTaskId);
            floatTimeSeries[i] = timeSeries;
        }

        return floatTimeSeries;
    }

    public static IntTimeSeries[] createIntTimeSeries(int startCadence,
        int endCadence, long producerTaskId, FsId[] fsIds) {

        return createIntTimeSeries(startCadence, endCadence, producerTaskId,
            fsIds, true);
    }

    private static IntTimeSeries[] createIntTimeSeries(int startCadence,
        int endCadence, long producerTaskId, FsId[] fsIds, boolean exists) {

        final IntTimeSeries[] intTimeSeries = new IntTimeSeries[fsIds.length];
        for (int i = 0; i < intTimeSeries.length; i++) {
            FsId id = fsIds[i];
            IntTimeSeries timeSeries = null;
            if (exists) {
                int[] iseries = new int[endCadence - startCadence + 1];
                Arrays.fill(iseries, random.nextInt());
                timeSeries = new IntTimeSeries(id, iseries, startCadence,
                    endCadence, new int[0], producerTaskId);
            } else {
                timeSeries = new IntTimeSeries(id, new int[endCadence
                    - startCadence + 1], startCadence, endCadence, new int[0],
                    producerTaskId, false);
            }
            intTimeSeries[i] = timeSeries;
        }

        return intTimeSeries;
    }

    private static IntTimeSeries[] createIntTimeSeries(int startCadence,
        int endCadence, long producerTaskId, FsId[] fsIds, int value) {

        final IntTimeSeries[] intTimeSeries = new IntTimeSeries[fsIds.length];
        for (int i = 0; i < intTimeSeries.length; i++) {
            int[] iseries = new int[endCadence - startCadence + 1];
            Arrays.fill(iseries, value);
            intTimeSeries[i] = new IntTimeSeries(fsIds[i], iseries,
                startCadence, endCadence, new int[0], producerTaskId);
        }

        return intTimeSeries;
    }

    public static FloatTimeSeries[] createFloatTimeSeries(int startCadence,
        int endCadence, long producerTaskId, FsId[] fsIds) {

        return createFloatTimeSeries(startCadence, endCadence, producerTaskId,
            fsIds, true);
    }

    private static FloatTimeSeries[] createFloatTimeSeries(int startCadence,
        int endCadence, long producerTaskId, FsId[] fsIds, boolean exists) {

        final FloatTimeSeries[] floatTimeSeries = new FloatTimeSeries[fsIds.length];
        for (int i = 0; i < floatTimeSeries.length; i++) {
            FsId id = fsIds[i];
            FloatTimeSeries timeSeries = null;
            if (exists) {
                float[] fseries = new float[endCadence - startCadence + 1];
                Arrays.fill(fseries, random.nextFloat());
                timeSeries = new FloatTimeSeries(id, fseries, startCadence,
                    endCadence, new int[0], producerTaskId);
            } else {
                timeSeries = new FloatTimeSeries(id, new float[endCadence
                    - startCadence + 1], startCadence, endCadence, new int[0],
                    producerTaskId, false);
            }
            floatTimeSeries[i] = timeSeries;
        }

        return floatTimeSeries;
    }

    public static FloatMjdTimeSeries[] createFloatMjdTimeSeries(
        double startMjd, double endMjd, long producerTaskId, FsId[] fsIds) {

        return createFloatMjdTimeSeries(startMjd, endMjd, producerTaskId,
            fsIds, new double[] { startMjd, endMjd });
    }

    public static FloatMjdTimeSeries[] createFloatMjdTimeSeries(
        double startMjd, double endMjd, long producerTaskId, FsId[] fsIds,
        double[] outlierMjds) {

        List<Double> tmpMjds = new ArrayList<Double>();
        for (double outlierMjd : outlierMjds) {
            if (outlierMjd < startMjd || outlierMjd > endMjd) {
                continue;
            }
            tmpMjds.add(outlierMjd);
        }
        double[] inBoundsMjds = new double[tmpMjds.size()];
        for (int i = 0; i < inBoundsMjds.length; i++) {
            inBoundsMjds[i] = tmpMjds.get(i);
        }

        FloatMjdTimeSeries[] floatMjdTimeSeries = new FloatMjdTimeSeries[fsIds.length];
        int valuesLength = inBoundsMjds.length;
        for (int i = 0; i < floatMjdTimeSeries.length; i++) {
            FsId id = fsIds[i];
            float[] values = new float[valuesLength];
            Arrays.fill(values, random.nextFloat());
            floatMjdTimeSeries[i] = new FloatMjdTimeSeries(id, startMjd,
                endMjd, inBoundsMjds, values, producerTaskId);
        }

        return floatMjdTimeSeries;
    }

    private static FloatTimeSeries[] createFloatTimeSeries(int startCadence,
        int endCadence, long producerTaskId, List<FsId> allFsIds,
        List<FsId> existingFsIds) {

        Set<FsId> fsIds = new HashSet<FsId>(allFsIds.size());
        for (FsId fsId : allFsIds) {
            if (!existingFsIds.contains(fsId)) {
                fsIds.add(fsId);
            }
        }
        FloatTimeSeries[] timeSeriesArray = createFloatTimeSeries(startCadence,
            endCadence, producerTaskId, fsIds.toArray(new FsId[fsIds.size()]),
            false);
        Map<FsId, FloatTimeSeries> timeSeriesByFsId = new HashMap<FsId, FloatTimeSeries>(
            allFsIds.size());
        for (FloatTimeSeries timeSeries : timeSeriesArray) {
            timeSeriesByFsId.put(timeSeries.id(), timeSeries);
        }
        timeSeriesArray = createFloatTimeSeries(startCadence, endCadence,
            producerTaskId,
            existingFsIds.toArray(new FsId[existingFsIds.size()]), true);
        timeSeriesByFsId.putAll(TimeSeriesOperations.getFloatTimeSeriesByFsId(timeSeriesArray));

        List<FloatTimeSeries> allTimeSeries = new ArrayList<FloatTimeSeries>(
            allFsIds.size());
        for (FsId fsId : allFsIds) {
            allTimeSeries.add(timeSeriesByFsId.get(fsId));
        }

        return allTimeSeries.toArray(new FloatTimeSeries[allFsIds.size()]);
    }

    public static DoubleTimeSeries[] createDoubleTimeSeries(int startCadence,
        int endCadence, long producerTaskId, FsId[] fsIds) {

        return createDoubleTimeSeries(startCadence, endCadence, producerTaskId,
            fsIds, true);
    }

    private static DoubleTimeSeries[] createDoubleTimeSeries(int startCadence,
        int endCadence, long producerTaskId, FsId[] fsIds, boolean exists) {

        final DoubleTimeSeries[] doubleTimeSeries = new DoubleTimeSeries[fsIds.length];
        for (int i = 0; i < doubleTimeSeries.length; i++) {
            FsId id = fsIds[i];
            DoubleTimeSeries timeSeries = null;
            if (exists) {
                double[] dseries = new double[endCadence - startCadence + 1];
                Arrays.fill(dseries, random.nextDouble());
                timeSeries = new DoubleTimeSeries(id, dseries, startCadence,
                    endCadence, new int[0], producerTaskId);
            } else {
                timeSeries = new DoubleTimeSeries(id, new double[endCadence
                    - startCadence + 1], startCadence, endCadence, new int[0],
                    producerTaskId, false);
            }
            doubleTimeSeries[i] = timeSeries;
        }

        return doubleTimeSeries;
    }

    public static List<ObservedTarget> mockTargets(JMockTest jMockTest,
        TargetCrud targetCrud,
        CelestialObjectOperations stellarTargetOperations,
        boolean mockIndividualCelestialObjects, TargetTable targetTable,
        int targetsPerTable, int maxPixelsPerTarget, int ccdModule,
        int ccdOutput, Set<Pixel> pixelsInUse, Set<FsId> allTargetFsIds) {

        return mockTargets(jMockTest, targetCrud, stellarTargetOperations,
            mockIndividualCelestialObjects, targetTable, targetsPerTable,
            new ArrayList<Set<String>>(), maxPixelsPerTarget, ccdModule,
            ccdOutput, pixelsInUse, allTargetFsIds);
    }

    public static List<ObservedTarget> mockTargets(JMockTest jMockTest,
        TargetCrud targetCrud,
        CelestialObjectOperations stellarTargetOperations,
        boolean mockIndividualCelestialObjects, TargetTable targetTable,
        int targetsPerTable, List<Set<String>> targetLabels,
        int maxPixelsPerTarget, int ccdModule, int ccdOutput,
        Set<Pixel> pixelsInUse, Set<FsId> allTargetFsIds) {

        List<Integer> keplerIds = new ArrayList<Integer>(targetsPerTable);
        for (int i = 0; i < targetsPerTable; i++) {
            if (targetTable.getType() != TargetType.BACKGROUND) {
                keplerIds.add(i);
            } else {
                keplerIds.add(TargetManagementConstants.INVALID_KEPLER_ID);
            }
        }

        return mockTargets(jMockTest, targetCrud, stellarTargetOperations,
            mockIndividualCelestialObjects, targetTable, keplerIds,
            targetLabels, maxPixelsPerTarget, ccdModule, ccdOutput,
            pixelsInUse, allTargetFsIds);
    }

    public static List<ObservedTarget> mockTargets(JMockTest jMockTest,
        TargetCrud targetCrud, TargetTable targetTable,
        List<Integer> keplerIds, List<Set<String>> targetLabels,
        int maxPixelsPerTarget, int ccdModule, int ccdOutput,
        Set<Pixel> pixelsInUse, Set<FsId> allTargetFsIds) {

        return mockTargets(jMockTest, targetCrud, null, false, targetTable,
            keplerIds, targetLabels, maxPixelsPerTarget, ccdModule, ccdOutput,
            pixelsInUse, allTargetFsIds);
    }

    private static List<ObservedTarget> mockTargets(JMockTest jMockTest,
        TargetCrud targetCrud,
        CelestialObjectOperations celestialObjectOperations,
        boolean mockIndividualCelestialObjects, TargetTable targetTable,
        List<Integer> keplerIds, List<Set<String>> targetLabels,
        int maxPixelsPerTarget, int ccdModule, int ccdOutput,
        Set<Pixel> pixelsInUse, Set<FsId> allTargetFsIds) {

        List<ObservedTarget> targets = new ArrayList<ObservedTarget>();
        MaskTable maskTable = new MaskTable(
            targetTable.getType() == TargetType.BACKGROUND ? MaskType.BACKGROUND
                : MaskType.TARGET);
        Iterator<Set<String>> labels = targetLabels.iterator();
        for (int i = 0; i < keplerIds.size(); i++) {
            Integer keplerId = keplerIds.get(i);
            Random random = new Random(keplerId);

            List<Offset> aperturePixels = new ArrayList<Offset>();
            int pixelsPerTarget = random.nextInt(maxPixelsPerTarget) + 1;
            Pixel referencePixel = getNextPixel(pixelsPerTarget, pixelsInUse,
                random);
            for (int j = 0; j < pixelsPerTarget; j++) {
                Offset offset = getNextOffset(pixelsPerTarget, referencePixel,
                    pixelsInUse, random);

                aperturePixels.add(offset);
            }
            allTargetFsIds.addAll(getTargetFsIds(targetTable.getType(),
                ccdModule, ccdOutput, referencePixel, aperturePixels));

            ObservedTarget observedTarget = new ObservedTarget(targetTable,
                ccdModule, ccdOutput, keplerId);
            if (labels.hasNext()) {
                observedTarget.setLabels(labels.next());
            }
            observedTarget.setAperture(new Aperture(false,
                referencePixel.getRow(), referencePixel.getColumn(),
                aperturePixels));

            List<TargetDefinition> targetDefinitions = new ArrayList<TargetDefinition>();
            TargetDefinition targetDefinition = new TargetDefinition(
                observedTarget);
            targetDefinition.setReferenceRow(referencePixel.getRow());
            targetDefinition.setReferenceColumn(referencePixel.getColumn());
            targetDefinition.setMask(new Mask(maskTable, aperturePixels));
            targetDefinition.setIndexInModuleOutput(i);
            targetDefinitions.add(targetDefinition);
            observedTarget.setTargetDefinitions(targetDefinitions);
            targets.add(observedTarget);
        }

        if (jMockTest != null) {
            if (targetTable.getType() != TargetType.BACKGROUND
                && celestialObjectOperations != null) {

                List<CelestialObject> celestialObjectList = new ArrayList<CelestialObject>(
                    keplerIds.size());
                List<CelestialObjectParameters> celestialObjectParametersList = new ArrayList<CelestialObjectParameters>(
                    keplerIds.size());
                List<Integer> keplerIdList = new ArrayList<Integer>(
                    keplerIds.size());
                for (Integer keplerId : keplerIds) {
                    CelestialObject celestialObject = new Kic.Builder(keplerId,
                        DEFAULT_RA, DEFAULT_DEC).keplerMag(DEFAULT_MAG)
                        .build();
                    celestialObjectList.add(celestialObject);

                    CelestialObjectParameters celestialObjectParameters = new CelestialObjectParameters.Builder(
                        celestialObject).build();
                    celestialObjectParametersList.add(celestialObjectParameters);

                    keplerIdList.add(keplerId);
                    if (mockIndividualCelestialObjects) {
                        jMockTest.allowing(celestialObjectOperations)
                            .retrieveCelestialObjectParameters(keplerId);
                        jMockTest.will(returnValue(celestialObjectParameters));
                    }
                }
                if (!mockIndividualCelestialObjects) {
                    jMockTest.allowing(celestialObjectOperations)
                        .retrieveCelestialObjectParameters(keplerIdList);
                    jMockTest.will(returnValue(celestialObjectParametersList));
                }
            }

            if (targetCrud != null) {
                jMockTest.allowing(targetCrud)
                    .retrieveObservedTargets(targetTable, ccdModule, ccdOutput);
                jMockTest.will(returnValue(targets));
            }
        }

        return targets;
    }

    public static TargetTable mockTargetTable(JMockTest jMockTest,
        TargetType targetType, int tableId) {

        if (jMockTest == null) {
            throw new NullPointerException("jMockTest can't be null");
        }

        TargetTable targetTable = createTargetTable(jMockTest, targetType,
            tableId);

        return targetTable;
    }

    public static TargetTable mockTargetTable(JMockTest jMockTest,
        TargetCrud targetCrud, TargetType targetType, int tableId) {

        if (jMockTest == null) {
            throw new NullPointerException("jMockTest can't be null");
        }

        TargetTable targetTable = createTargetTable(jMockTest, targetType,
            tableId);

        if (targetCrud != null) {
            jMockTest.allowing(targetCrud)
                .retrieveTargetTable(tableId);
            jMockTest.will(returnValue(targetTable));
        }

        return targetTable;
    }

    private static TargetTable createTargetTable(JMockTest jMockTest,
        TargetType targetType, int tableId) {

        TargetTable targetTable = jMockTest.mock(TargetTable.class,
            targetType.toString() + tableId);
        jMockTest.allowing(targetTable)
            .getExternalId();
        jMockTest.will(returnValue(tableId));
        jMockTest.allowing(targetTable)
            .getType();
        jMockTest.will(returnValue(targetType));

        return targetTable;
    }

    public static TargetTableLog mockTargetTableLog(JMockTest jMockTest,
        TargetCrud targetCrud, TargetType targetType, int startCadence,
        int endCadence, TargetTable targetTable) {

        TargetTableLog targetTableLog = new TargetTableLog(targetTable,
            startCadence, endCadence);

        if (jMockTest != null && targetCrud != null) {
            jMockTest.allowing(targetCrud)
                .retrieveTargetTableLog(targetType, startCadence, endCadence);
            jMockTest.will(returnValue(targetTableLog));
        }

        return targetTableLog;
    }

    public static List<TargetTableLog> mockTargetTableLogs(JMockTest jMockTest,
        TargetCrud targetCrud, TargetType targetType, int startCadence,
        int endCadence, TargetTable targetTable) {

        List<TargetTableLog> targetTableLogs = ImmutableList.of(new TargetTableLog(
            targetTable, startCadence, endCadence));

        if (jMockTest != null && targetCrud != null) {
            jMockTest.allowing(targetCrud)
                .retrieveTargetTableLogs(targetType, startCadence, endCadence);
            jMockTest.will(returnValue(targetTableLogs));
        }

        return targetTableLogs;
    }

    public static TargetTable mockUplinkedTargetTable(JMockTest jMockTest,
        TargetCrud targetCrud, TargetType targetType, int tableId) {

        TargetTable targetTable = new TargetTable(targetType);
        targetTable.setExternalId(tableId);

        if (jMockTest != null && targetCrud != null) {
            jMockTest.allowing(targetCrud)
                .retrieveUplinkedTargetTable(targetTable.getExternalId(),
                    targetTable.getType());
            jMockTest.will(returnValue(targetTable));
        }

        return targetTable;
    }

    public static IntTimeSeries[] mockReadIntTimeSeries(JMockTest jMockTest,
        FileStoreClient fsClient, int startCadence, int endCadence,
        long producerTaskId, FsId[] fsIds) {

        IntTimeSeries[] intTimeSeries = createIntTimeSeries(startCadence,
            endCadence, producerTaskId, fsIds);

        if (jMockTest != null && fsClient != null) {
            jMockTest.allowing(fsClient)
                .readTimeSeriesAsInt(fsIds, startCadence, endCadence);
            jMockTest.will(returnValue(intTimeSeries));
        }

        return intTimeSeries;
    }

    public static IntTimeSeries[] mockReadIntTimeSeries(JMockTest jMockTest,
        FileStoreClient fsClient, int startCadence, int endCadence,
        long producerTaskId, FsId[] fsIds, boolean existsError) {

        IntTimeSeries[] intTimeSeries = createIntTimeSeries(startCadence,
            endCadence, producerTaskId, fsIds);

        if (jMockTest != null && fsClient != null) {
            jMockTest.allowing(fsClient)
                .readTimeSeriesAsInt(fsIds, startCadence, endCadence,
                    existsError);
            jMockTest.will(returnValue(intTimeSeries));
        }

        return intTimeSeries;
    }

    public static IntTimeSeries[] mockReadIntTimeSeries(JMockTest jMockTest,
        FileStoreClient fsClient, int startCadence, int endCadence,
        long producerTaskId, FsId[] fsIds, boolean existsError, int value) {

        IntTimeSeries[] intTimeSeries = createIntTimeSeries(startCadence,
            endCadence, producerTaskId, fsIds, value);

        if (jMockTest != null && fsClient != null) {
            jMockTest.allowing(fsClient)
                .readTimeSeriesAsInt(fsIds, startCadence, endCadence,
                    existsError);
            jMockTest.will(returnValue(intTimeSeries));
        }

        return intTimeSeries;
    }

    public static FloatTimeSeries[] mockReadFloatTimeSeries(
        JMockTest jMockTest, FileStoreClient fsClient, int startCadence,
        int endCadence, long producerTaskId, FsId[] fsIds) {

        FloatTimeSeries[] floatTimeSeries = createFloatTimeSeries(startCadence,
            endCadence, producerTaskId, fsIds);

        if (jMockTest != null && fsClient != null) {
            jMockTest.allowing(fsClient)
                .readTimeSeriesAsFloat(fsIds, startCadence, endCadence);
            jMockTest.will(returnValue(floatTimeSeries));
        }

        return floatTimeSeries;
    }

    public static DoubleTimeSeries[] mockReadDoubleTimeSeries(
        JMockTest jMockTest, FileStoreClient fsClient, int startCadence,
        int endCadence, long producerTaskId, FsId[] fsIds) {

        return mockReadDoubleTimeSeries(jMockTest, fsClient, startCadence,
            endCadence, producerTaskId, fsIds, true);
    }

    public static DoubleTimeSeries[] mockReadDoubleTimeSeries(
        JMockTest jMockTest, FileStoreClient fsClient, int startCadence,
        int endCadence, long producerTaskId, FsId[] fsIds, boolean existsError) {

        DoubleTimeSeries[] doubleTimeSeries = createDoubleTimeSeries(
            startCadence, endCadence, producerTaskId, fsIds);

        if (jMockTest != null && fsClient != null) {
            jMockTest.allowing(fsClient)
                .readTimeSeriesAsDouble(fsIds, startCadence, endCadence, false);
            jMockTest.will(returnValue(doubleTimeSeries));
        }

        return doubleTimeSeries;
    }

    public static FloatTimeSeries[] mockReadFloatTimeSeries(
        JMockTest jMockTest, FileStoreClient fsClient, int startCadence,
        int endCadence, long producerTaskId, FsId[] fsIds, boolean existsError) {

        return mockReadFloatTimeSeries(jMockTest, fsClient, startCadence,
            endCadence, producerTaskId, fsIds, existsError, true);
    }

    public static FloatTimeSeries[] mockReadFloatTimeSeries(
        JMockTest jMockTest, FileStoreClient fsClient, int startCadence,
        int endCadence, long producerTaskId, FsId[] fsIds, boolean existsError,
        boolean exists) {

        FloatTimeSeries[] floatTimeSeries = createFloatTimeSeries(startCadence,
            endCadence, producerTaskId, fsIds, exists);

        if (jMockTest != null && fsClient != null && fsIds.length > 0) {
            jMockTest.allowing(fsClient)
                .readTimeSeriesAsFloat(fsIds, startCadence, endCadence,
                    existsError);
            jMockTest.will(returnValue(floatTimeSeries));
        }

        return floatTimeSeries;
    }

    public static FloatTimeSeries[] mockReadFloatTimeSeries(
        JMockTest jMockTest, FileStoreClient fsClient, int startCadence,
        int endCadence, long producerTaskId, FsId[] allFsIds,
        FsId[] existingFsIds) {

        FloatTimeSeries[] floatTimeSeries = createFloatTimeSeries(startCadence,
            endCadence, producerTaskId, Arrays.asList(allFsIds),
            Arrays.asList(existingFsIds));

        if (jMockTest != null && fsClient != null && allFsIds.length > 0) {
            jMockTest.allowing(fsClient)
                .readTimeSeriesAsFloat(allFsIds, startCadence, endCadence,
                    false);
            jMockTest.will(returnValue(floatTimeSeries));
        }

        return floatTimeSeries;
    }

    public static FloatMjdTimeSeries[] mockReadMjdTimeSeries(
        JMockTest jMockTest, FileStoreClient fsClient, double startMjd,
        double endMjd, long producerTaskId, FsId[] fsIds) {

        FloatMjdTimeSeries[] floatMjdTimeSeries = createFloatMjdTimeSeries(
            startMjd, endMjd, producerTaskId, fsIds);

        if (jMockTest != null && fsClient != null && fsIds.length > 0) {
            jMockTest.allowing(fsClient)
                .readMjdTimeSeries(fsIds, startMjd, endMjd);
            jMockTest.will(returnValue(floatMjdTimeSeries));
        }

        return floatMjdTimeSeries;
    }

    public static FloatTimeSeries[] mockWriteFloatTimeSeries(
        JMockTest jMockTest, FileStoreClient fsClient, int startCadence,
        int endCadence, long producerTaskId, FsId[] fsIds) {

        return mockWriteFloatTimeSeries(jMockTest, fsClient, startCadence,
            endCadence, producerTaskId, fsIds, false);
    }

    public static FloatTimeSeries[] mockWriteFloatTimeSeries(
        JMockTest jMockTest, FileStoreClient fsClient, int startCadence,
        int endCadence, long producerTaskId, FsId[] fsIds, boolean empty) {

        FloatTimeSeries[] floatTimeSeries = null;
        if (empty) {
            floatTimeSeries = createGappedFloatTimeSeries(startCadence,
                endCadence, producerTaskId, fsIds);
        } else {
            floatTimeSeries = createFloatTimeSeries(startCadence, endCadence,
                producerTaskId, fsIds);
        }

        mockWriteTimeSeries(jMockTest, fsClient, floatTimeSeries);

        return floatTimeSeries;
    }

    public static void mockWriteTimeSeries(JMockTest jMockTest,
        FileStoreClient fsClient, TimeSeries[] timeSeries) {

        if (jMockTest != null && fsClient != null) {
            jMockTest.oneOf(fsClient)
                .writeTimeSeries(timeSeries);
        }
    }

    public static AttitudeSolution mockCreateAttitudeSolution(
        JMockTest jMockTest, FileStoreClient fsClient,
        DoubleDbTimeSeriesCrud doubleTimeSeriesCrud, int startCadence,
        int endCadence, long pipelineTaskId) {

        AttitudeSolution attitudeSolution = mockRetrieveAttitudeSolution(
            (JMockTest) null, null, null, startCadence, endCadence,
            pipelineTaskId, true);

        if (jMockTest != null && fsClient != null) {
            List<FloatTimeSeries> floatTimeSeries = attitudeSolution.getAllFloatTimeSeries(
                startCadence, endCadence, pipelineTaskId);
            jMockTest.oneOf(fsClient)
                .writeTimeSeries(
                    floatTimeSeries.toArray(new FloatTimeSeries[floatTimeSeries.size()]));
        }

        if (jMockTest != null && doubleTimeSeriesCrud != null) {
            List<DoubleDbTimeSeries> doubleTimeSeries = attitudeSolution.getAllDoubleTimeSeries(
                startCadence, endCadence, pipelineTaskId);
            for (DoubleDbTimeSeries timeSeries : doubleTimeSeries) {
                jMockTest.oneOf(doubleTimeSeriesCrud)
                    .create(timeSeries);
            }
        }

        return attitudeSolution;
    }

    public static AttitudeSolution mockRetrieveAttitudeSolution(
        JMockTest jMockTest, FileStoreClient fsClient,
        DoubleDbTimeSeriesCrud doubleTimeSeriesCrud, int startCadence,
        int endCadence, long producerTaskId, boolean exists) {

        AttitudeSolution attitudeSolution = new AttitudeSolution();
        List<FsId> fsIds = AttitudeSolution.getAllTimeSeriesFsIds();
        FloatTimeSeries[] floatTimeSeries = MockUtils.mockReadFloatTimeSeries(
            jMockTest, fsClient, startCadence, endCadence, producerTaskId,
            fsIds.toArray(new FsId[fsIds.size()]), false, exists);
        Map<FsId, FloatTimeSeries> timeSeriesByFsId = TimeSeriesOperations.getFloatTimeSeriesByFsId(floatTimeSeries);

        if (timeSeriesByFsId.size() > 0) {
            attitudeSolution.setAllFloatTimeSeries(timeSeriesByFsId);
            Map<DoubleTimeSeriesType, DoubleDbTimeSeries> timeSeriesByType = new HashMap<DoubleTimeSeriesType, DoubleDbTimeSeries>();
            for (DoubleTimeSeriesType type : AttitudeSolution.getAllDoubleTimeSeriesTypes()) {
                double[] dseries = new double[endCadence - startCadence + 1];
                Arrays.fill(dseries, random.nextDouble());
                DoubleDbTimeSeries timeSeries = new DoubleDbTimeSeries(dseries,
                    startCadence, endCadence, new int[0], producerTaskId, type);
                timeSeriesByType.put(type, timeSeries);
                if (jMockTest != null && doubleTimeSeriesCrud != null) {
                    jMockTest.allowing(doubleTimeSeriesCrud)
                        .retrieve(type, startCadence, endCadence);
                    jMockTest.will(returnValue(timeSeries));
                }
            }
            attitudeSolution.setAllDoubleTimeSeries(timeSeriesByType);
        }

        return attitudeSolution;
    }

    public static File createBlobFile(File workingDir, String fileName)
        throws IOException {

        File blobFile = new File(workingDir, fileName);
        FileOutputStream output = new FileOutputStream(blobFile);
        byte[] blob = new byte[BLOB_SIZE];
        random.nextBytes(blob);
        output.write(blob);
        output.close();

        return blobFile;
    }

    public static String mockMotionBlobFile(JMockTest jMockTest, PaCrud paCrud,
        FileStoreClient fsClient, File matlabWorkingDir, int ccdModule,
        int ccdOutput, int startCadence, int endCadence, long pipelineTaskId)
        throws IOException {

        File blobFile = createBlobFile(matlabWorkingDir,
            BlobSeriesType.MOTION.getName() + MAT_FILE_EXTENSION);
        MotionBlobMetadata metadata = new MotionBlobMetadata(pipelineTaskId,
            ccdModule, ccdOutput, startCadence, endCadence,
            FilenameUtils.getExtension(blobFile.getName()));

        if (jMockTest != null && paCrud != null) {
            jMockTest.oneOf(paCrud)
                .createMotionBlobMetadata(metadata);
            jMockTest.oneOf(fsClient)
                .writeBlob(BlobOperations.getFsId(metadata), pipelineTaskId,
                    blobFile);
        }

        return blobFile.getName();
    }

    public static String mockBackgroundBlobFile(JMockTest jMockTest,
        PaCrud paCrud, FileStoreClient fsClient, File matlabWorkingDir,
        int ccdModule, int ccdOutput, int startCadence, int endCadence,
        long pipelineTaskId) throws IOException {

        File blobFile = createBlobFile(matlabWorkingDir,
            BlobSeriesType.BACKGROUND.getName() + MAT_FILE_EXTENSION);
        BackgroundBlobMetadata metadata = new BackgroundBlobMetadata(
            pipelineTaskId, ccdModule, ccdOutput, startCadence, endCadence,
            FilenameUtils.getExtension(blobFile.getName()));

        if (jMockTest != null && paCrud != null) {
            jMockTest.oneOf(paCrud)
                .createBackgroundBlobMetadata(metadata);
            jMockTest.oneOf(fsClient)
                .writeBlob(BlobOperations.getFsId(metadata), pipelineTaskId,
                    blobFile);
        }

        return blobFile.getName();
    }

    public static String mockPaUncertaintyBlobFile(JMockTest jMockTest,
        PaCrud paCrud, FileStoreClient fsClient, File matlabWorkingDir,
        int ccdModule, int ccdOutput, CadenceType cadenceType,
        int startCadence, int endCadence, long pipelineTaskId)
        throws IOException {

        File blobFile = MockUtils.createBlobFile(matlabWorkingDir,
            BlobSeriesType.UNCERTAINTIES.getName() + MAT_FILE_EXTENSION);
        UncertaintyBlobMetadata metadata = new UncertaintyBlobMetadata(
            pipelineTaskId, ccdModule, ccdOutput, cadenceType, startCadence,
            endCadence, FilenameUtils.getExtension(blobFile.getName()));

        if (jMockTest != null && paCrud != null) {
            jMockTest.oneOf(paCrud)
                .createUncertaintyBlobMetadata(metadata);
            jMockTest.oneOf(fsClient)
                .writeBlob(BlobOperations.getFsId(metadata), pipelineTaskId,
                    blobFile);
        }

        return blobFile.getName();
    }

    @Deprecated
    public static BlobSeries<String> mockBackgroundBlobFileSeries(
        Mockery mockery, final BlobOperations blobOperations,
        final int ccdModule, final int ccdOutput, final int startCadence,
        final int endCadence, final long producerTaskId) {

        final BlobSeries<String> blobFileSeries = new BlobSeries<String>(
            new int[endCadence - startCadence + 1], new boolean[endCadence
                - startCadence + 1], new String[] { "backgroundBlob.mat" },
            new long[] { producerTaskId }, startCadence, endCadence);
        if (mockery != null && blobOperations != null) {
            mockery.checking(new Expectations() {
                {
                    oneOf(blobOperations).retrieveBackgroundBlobFileSeries(
                        ccdModule, ccdOutput, startCadence, endCadence);
                    will(returnValue(blobFileSeries));
                }
            });
        }

        return blobFileSeries;
    }

    public static BlobSeries<String> mockBackgroundBlobFileSeries(
        JMockTest jMockTest, BlobOperations blobOperations, int ccdModule,
        int ccdOutput, int startCadence, int endCadence, long producerTaskId) {

        BlobSeries<String> blobFileSeries = new BlobSeries<String>(
            new int[endCadence - startCadence + 1], new boolean[endCadence
                - startCadence + 1], new String[] { "backgroundBlob.mat" },
            new long[] { producerTaskId }, startCadence, endCadence);
        if (jMockTest != null && blobOperations != null) {
            jMockTest.allowing(blobOperations)
                .retrieveBackgroundBlobFileSeries(ccdModule, ccdOutput,
                    startCadence, endCadence);
            jMockTest.will(returnValue(blobFileSeries));
        }

        return blobFileSeries;
    }

    public static BlobSeries<String> mockCbvBlobFileSeries(JMockTest jMockTest,
        BlobOperations blobOperations, int ccdModule, int ccdOutput,
        CadenceType cadenceType, int startCadence, int endCadence,
        long producerTaskId) {

        BlobSeries<String> blobFileSeries = new BlobSeries<String>(
            new int[endCadence - startCadence + 1], new boolean[endCadence
                - startCadence + 1], new String[] { "cbvBlob.mat" },
            new long[] { producerTaskId }, startCadence, endCadence);
        if (jMockTest != null && blobOperations != null) {
            jMockTest.allowing(blobOperations)
                .retrieveCbvBlobFileSeries(ccdModule, ccdOutput, cadenceType,
                    startCadence, endCadence);
            jMockTest.will(returnValue(blobFileSeries));
        }

        return blobFileSeries;
    }

    @Deprecated
    public static BlobSeries<String> mockMotionBlobFileSeries(Mockery mockery,
        final BlobOperations blobOperations, final int ccdModule,
        final int ccdOutput, final int startCadence, final int endCadence,
        final long producerTaskId) {

        final BlobSeries<String> blobFileSeries = new BlobSeries<String>(
            new int[endCadence - startCadence + 1], new boolean[endCadence
                - startCadence + 1], new String[] { "motionBlob.mat" },
            new long[] { producerTaskId }, startCadence, endCadence);
        if (mockery != null && blobOperations != null) {
            mockery.checking(new Expectations() {
                {
                    oneOf(blobOperations).retrieveMotionBlobFileSeries(
                        ccdModule, ccdOutput, startCadence, endCadence);
                    will(returnValue(blobFileSeries));
                }
            });
        }

        return blobFileSeries;
    }

    public static BlobSeries<String> mockMotionBlobFileSeries(
        JMockTest jMockTest, BlobOperations blobOperations, int ccdModule,
        int ccdOutput, int startCadence, int endCadence, long producerTaskId) {

        BlobSeries<String> blobFileSeries = new BlobSeries<String>(
            new int[endCadence - startCadence + 1], new boolean[endCadence
                - startCadence + 1], new String[] { "motionBlob.mat" },
            new long[] { producerTaskId }, startCadence, endCadence);
        if (jMockTest != null && blobOperations != null) {
            jMockTest.allowing(blobOperations)
                .retrieveMotionBlobFileSeries(ccdModule, ccdOutput,
                    startCadence, endCadence);
            jMockTest.will(returnValue(blobFileSeries));
        }

        return blobFileSeries;
    }

    public static BlobSeries<String> mockPdcBlobFileSeries(JMockTest jMockTest,
        BlobOperations blobOperations, int ccdModule, int ccdOutput,
        CadenceType cadenceType, int startCadence, int endCadence,
        long producerTaskId) {

        BlobSeries<String> blobFileSeries = new BlobSeries<String>(
            new int[endCadence - startCadence + 1], new boolean[endCadence
                - startCadence + 1], new String[] { "pdcBlob.mat" },
            new long[] { producerTaskId }, startCadence, endCadence);
        if (jMockTest != null && blobOperations != null) {
            jMockTest.allowing(blobOperations)
                .retrievePdcBlobFileSeries(ccdModule, ccdOutput, cadenceType,
                    startCadence, endCadence);
            jMockTest.will(returnValue(blobFileSeries));
        }

        return blobFileSeries;
    }

    public static BlobSeries<String> mockCalUncertaintiesBlobSeries(
        JMockTest jMockTest, BlobOperations blobOperations, File outputDir,
        int ccdModule, int ccdOutput, CadenceType cadenceType,
        int startCadence, int endCadence, long producerTaskId) {

        BlobSeries<String> blobFileSeries = new BlobSeries<String>(
            new int[endCadence - startCadence + 1], new boolean[endCadence
                - startCadence + 1], new String[] { "calUncertainties.mat" },
            new long[] { producerTaskId }, startCadence, endCadence);
        if (jMockTest != null && blobOperations != null) {
            jMockTest.oneOf(blobOperations)
                .setOutputDir(outputDir);
            jMockTest.allowing(blobOperations)
                .retrieveCalUncertaintiesBlobFileSeries(ccdModule, ccdOutput,
                    cadenceType, startCadence, endCadence);
            jMockTest.will(returnValue(blobFileSeries));
        }

        return blobFileSeries;
    }

    @Deprecated
    public static void mockDataAccountabilityTrail(Mockery mockery,
        final DataAccountabilityTrailCrud daCrud,
        final PipelineTask pipelineTask, final Set<Long> producerTaskIds) {

        if (mockery != null && daCrud != null) {
            mockery.checking(new Expectations() {
                {
                    oneOf(daCrud).create(pipelineTask, producerTaskIds);
                }
            });
        }
    }

    public static void mockDataAccountabilityTrail(JMockTest jMockTest,
        DataAccountabilityTrailCrud daCrud, PipelineTask pipelineTask,
        Set<Long> producerTaskIds) {

        if (jMockTest != null && daCrud != null) {
            jMockTest.oneOf(daCrud)
                .create(pipelineTask, producerTaskIds);
        }
    }

    @Deprecated
    public static List<PixelLog> mockPixelLogs(Mockery mockery,
        final LogCrud logCrud, final CadenceType cadenceType,
        final int startCadence, final int endCadence) {

        double cadenceLengthDays = 0;
        if (cadenceType == CadenceType.SHORT) {
            cadenceLengthDays = (double) ModifiedJulianDate.SHORT_CADENCE_LENGTH_MINUTES
                / MINUTES_PER_DAY;
        } else {
            cadenceLengthDays = (double) ModifiedJulianDate.CADENCE_LENGTH_MINUTES
                / MINUTES_PER_DAY;
        }

        final List<PixelLog> pixelLogs = new ArrayList<PixelLog>();
        for (int cadence = startCadence; cadence <= endCadence; cadence++) {
            // Use the same time that is in TestDataSetDescriptor.
            // Must be in the range (54000, 64000).
            double startMjd = 55553.5 + cadence * cadenceLengthDays;
            double endMjd = startMjd + cadenceLengthDays;
            PixelLog pixelLog = new PixelLog();
            pixelLog.setDataSetType(DataSetType.Target);
            pixelLog.setCadenceNumber(cadence);
            pixelLog.setCadenceType(cadenceType.intValue());
            pixelLog.setMjdStartTime(startMjd);
            pixelLog.setMjdEndTime(endMjd);
            pixelLog.setMjdMidTime(startMjd + cadenceLengthDays / 2);
            pixelLogs.add(pixelLog);
        }

        if (mockery != null && logCrud != null) {
            mockery.checking(new Expectations() {
                {
                    oneOf(logCrud).retrievePixelLog(cadenceType.intValue(),
                        DataSetType.Target, startCadence, endCadence);
                    will(returnValue(pixelLogs));
                }
            });
        }

        return pixelLogs;
    }

    public static List<PixelLog> mockPixelLogs(JMockTest jMockTest,
        LogCrud logCrud, CadenceType cadenceType, int startCadence,
        int endCadence) {

        double cadenceLengthDays = 0;
        if (cadenceType == CadenceType.SHORT) {
            cadenceLengthDays = (double) ModifiedJulianDate.SHORT_CADENCE_LENGTH_MINUTES
                / MINUTES_PER_DAY;
        } else {
            cadenceLengthDays = (double) ModifiedJulianDate.CADENCE_LENGTH_MINUTES
                / MINUTES_PER_DAY;
        }

        List<PixelLog> pixelLogs = new ArrayList<PixelLog>();
        for (int cadence = startCadence; cadence <= endCadence; cadence++) {
            // Use the same time that is in TestDataSetDescriptor.
            // Must be in the range (54000, 64000).
            double startMjd = 55553.5 + cadence * cadenceLengthDays;
            double endMjd = startMjd + cadenceLengthDays;
            PixelLog pixelLog = new PixelLog();
            pixelLog.setDataSetType(DataSetType.Target);
            pixelLog.setCadenceNumber(cadence);
            pixelLog.setCadenceType(cadenceType.intValue());
            pixelLog.setMjdStartTime(startMjd);
            pixelLog.setMjdEndTime(endMjd);
            pixelLog.setMjdMidTime(startMjd + cadenceLengthDays / 2);
            pixelLogs.add(pixelLog);
        }

        if (jMockTest != null && logCrud != null) {
            jMockTest.allowing(logCrud)
                .retrievePixelLog(cadenceType.intValue(), DataSetType.Target,
                    startCadence, endCadence);
            jMockTest.will(returnValue(pixelLogs));
        }

        return pixelLogs;
    }

    public static Pair<Integer, Integer> mockShortCadenceToLongCadence(
        JMockTest jMockTest, LogCrud logCrud, int startShortCadence,
        int endShortCadence, int startLongCadence, int endLongCadence) {

        Pair<Integer, Integer> longCadences = Pair.of(startLongCadence,
            endLongCadence);

        if (jMockTest != null && logCrud != null) {
            jMockTest.allowing(logCrud)
                .shortCadenceToLongCadence(startShortCadence, endShortCadence);
            jMockTest.will(returnValue(longCadences));
        }

        return longCadences;
    }

    public static Pair<Integer, Integer> mockFirstAndLastCadences(
        JMockTest jMockTest, LogCrud logCrud, int cadenceType,
        int startCadence, int endCadence) {

        final Pair<Integer, Integer> firstAndLastCadences = Pair.of(
            startCadence, endCadence);

        if (jMockTest != null && logCrud != null) {
            jMockTest.allowing(logCrud)
                .retrieveFirstAndLastCadences(cadenceType);
            jMockTest.will(returnValue(firstAndLastCadences));
        }

        return firstAndLastCadences;
    }

    public static List<ConfigMap> mockConfigMaps(JMockTest jMockTest,
        ConfigMapOperations configMapOperations, int scConfigId,
        double startMjd, double endMjd) {

        List<ConfigMap> configMaps = new ArrayList<ConfigMap>();
        ConfigMap configMap = new ConfigMap(scConfigId, startMjd);
        configMaps.add(configMap);

        if (jMockTest != null && configMapOperations != null) {
            jMockTest.allowing(configMapOperations)
                .retrieveConfigMaps(startMjd, endMjd);
            jMockTest.will(returnValue(configMaps));
        }

        return configMaps;
    }

    public static BadPixel mockBadPixel(JMockTest jMockTest,
        PixelOperations pixelOperations, int ccdModule, int ccdOutput,
        double startMjd, double endMjd, int row, int column,
        PixelType pixelType, double value) {

        gov.nasa.kepler.hibernate.fc.Pixel pixel = new gov.nasa.kepler.hibernate.fc.Pixel(
            ccdModule, ccdOutput, row, column, pixelType, startMjd, endMjd,
            value);

        if (jMockTest != null && pixelOperations != null) {
            jMockTest.oneOf(pixelOperations)
                .persistPixel(pixel);
        }

        return new BadPixel(pixel);
    }

    public static PrfModel mockPrfModel(JMockTest jMockTest,
        PrfOperations prfOperations, double startMjd, int ccdModule,
        int ccdOutput) {

        byte[] prfBlob = new byte[1024];
        Arrays.fill(prfBlob, (byte) 85);
        PrfModel prfModel = new PrfModel(startMjd, ccdModule, ccdOutput,
            prfBlob);

        if (jMockTest != null && prfOperations != null) {
            jMockTest.allowing(prfOperations)
                .retrievePrfModel(startMjd, ccdModule, ccdOutput);
            jMockTest.will(returnValue(prfModel));
        }

        return prfModel;
    }

    public static List<PrfModel> mockPrfModels(JMockTest jMockTest,
        PrfOperations prfOperations, double startMjd,
        List<Integer> moduleOutputs) {

        List<PrfModel> prfModels = new ArrayList<PrfModel>();
        for (int moduleOutputNumber : moduleOutputs) {
            Pair<Integer, Integer> moduleOutput = FcConstants.getModuleOutput(moduleOutputNumber);
            PrfModel prfModel = mockPrfModel(jMockTest, prfOperations,
                startMjd, moduleOutput.left, moduleOutput.right);
            prfModels.add(prfModel);
        }

        return prfModels;
    }

    public static void mockAlert(JMockTest jMockTest,
        AlertService alertService, String component, long taskId,
        Severity severity, String message) {

        if (jMockTest != null && alertService != null) {
            jMockTest.oneOf(alertService)
                .generateAlert(component, taskId, severity, message);
        }
    }

    public static TimestampSeries mockCadenceTimes(JMockTest jMockTest,
        MjdToCadence mjdToCadence, CadenceType cadenceType, int startCadence,
        int endCadence) {

        TimestampSeries series = createTimestampSeries(cadenceType,
            startCadence, endCadence);

        if (jMockTest != null && mjdToCadence != null) {
            jMockTest.allowing(mjdToCadence)
                .cadenceTimes(startCadence, endCadence);
            jMockTest.will(returnValue(series));
        }
        return series;
    }

    public static TimestampSeries mockCadenceTimes(JMockTest jMockTest,
        MjdToCadence mjdToCadence, CadenceType cadenceType, int startCadence,
        int endCadence, boolean reloadCache, boolean loadDataAnomalyTypes) {

        TimestampSeries series = createTimestampSeries(cadenceType,
            startCadence, endCadence);

        if (jMockTest != null && mjdToCadence != null) {
            jMockTest.allowing(mjdToCadence)
                .cadenceTimes(startCadence, endCadence, reloadCache,
                    loadDataAnomalyTypes);
            jMockTest.will(returnValue(series));
        }
        return series;
    }

    private static TimestampSeries createTimestampSeries(
        CadenceType cadenceType, int startCadence, int endCadence) {
        double cadenceLengthDays = 0;
        if (cadenceType == CadenceType.SHORT) {
            cadenceLengthDays = (double) ModifiedJulianDate.SHORT_CADENCE_LENGTH_MINUTES
                / MINUTES_PER_DAY;
        } else {
            cadenceLengthDays = (double) ModifiedJulianDate.CADENCE_LENGTH_MINUTES
                / MINUTES_PER_DAY;
        }

        double[] startTimes = new double[endCadence - startCadence + 1];
        double[] endTimes = new double[endCadence - startCadence + 1];
        double[] midTimes = new double[endCadence - startCadence + 1];
        int[] cadenceNumbers = new int[startTimes.length];
        double startMjd = 55553.5 + startCadence * cadenceLengthDays;
        for (int cadence = startCadence; cadence <= endCadence; cadence++) {
            double endMjd = startMjd + cadenceLengthDays;
            startTimes[cadence - startCadence] = startMjd;
            endTimes[cadence - startCadence] = endMjd;
            midTimes[cadence - startCadence] = startMjd + cadenceLengthDays / 2;
            cadenceNumbers[cadence - startCadence] = cadence;
            startMjd = endMjd;
        }

        boolean[] gaps = new boolean[startTimes.length];
        boolean[] requantEnabled = new boolean[startTimes.length];
        boolean[] isSefiAcc = new boolean[startTimes.length];
        boolean[] isSefiCad = new boolean[startTimes.length];
        boolean[] isLdeOos = new boolean[startTimes.length];
        boolean[] isFinePnt = new boolean[startTimes.length];
        boolean[] isMmntmDmp = new boolean[startTimes.length];
        boolean[] isLdeParEr = new boolean[startTimes.length];
        boolean[] isScrcErr = new boolean[startTimes.length];
        Arrays.fill(requantEnabled, true);

        DataAnomalyFlags dataAnomalyFlags = new DataAnomalyFlags(
            new boolean[startTimes.length], new boolean[startTimes.length],
            new boolean[startTimes.length], new boolean[startTimes.length],
            new boolean[startTimes.length], new boolean[startTimes.length],
            new boolean[startTimes.length]);

        TimestampSeries series = new TimestampSeries(startTimes, midTimes,
            endTimes, gaps, requantEnabled, cadenceNumbers, isSefiAcc,
            isSefiCad, isLdeOos, isFinePnt, isMmntmDmp, isLdeParEr, isScrcErr,
            dataAnomalyFlags);
        return series;
    }

    public static int mockMjdToSeason(JMockTest jMockTest,
        RollTimeOperations rollTimeOperations, double mjd, int observingSeason) {

        if (jMockTest != null && rollTimeOperations != null) {
            jMockTest.allowing(rollTimeOperations)
                .mjdToSeason(mjd);
            jMockTest.will(returnValue(observingSeason));
        }
        return observingSeason;
    }

    public static int mockSkyGroupId(JMockTest jMockTest, KicCrud kicCrud,
        int ccdModule, int ccdOutput, int observingSeason, int skyGroupId) {

        if (jMockTest != null && kicCrud != null) {
            jMockTest.allowing(kicCrud)
                .retrieveSkyGroupId(ccdModule, ccdOutput, observingSeason);
            jMockTest.will(returnValue(skyGroupId));
        }
        return skyGroupId;
    }

    public static List<AncillaryEngineeringData> mockAncillaryEngineeringData(
        JMockTest jMockTest, AncillaryOperations ancillaryOperations,
        double startMjd, double endMjd, String[] mnemonics) {

        List<AncillaryEngineeringData> ancillaryEngineeringData = new ArrayList<AncillaryEngineeringData>();
        for (String mnemonic : mnemonics) {
            AncillaryEngineeringData data = new AncillaryEngineeringData(
                mnemonic);
            data.setTimestamps(new double[] { startMjd });
            data.setValues(new float[] { random.nextFloat() });
            ancillaryEngineeringData.add(data);
        }
        if (jMockTest != null && ancillaryOperations != null) {
            jMockTest.allowing(ancillaryOperations)
                .retrieveAncillaryEngineeringData(mnemonics, startMjd, endMjd);
            jMockTest.will(returnValue(ancillaryEngineeringData));
        }

        return ancillaryEngineeringData;
    }

    public static FloatMjdTimeSeries[] mockAncillaryEngineeringData(
        JMockTest jMockTest, FileStoreClient fsClient, String[] mnemonics,
        double startMjd, double endMjd) {

        FsId[] fsIds = new FsId[mnemonics.length];
        for (int i = 0; i < mnemonics.length; i++) {
            fsIds[i] = AncillaryFsIdFactory.getId(mnemonics[i]);
        }
        FloatMjdTimeSeries[] mjdTimeSeries = MockUtils.mockReadMjdTimeSeries(
            jMockTest, fsClient, startMjd, endMjd,
            DrConstants.DATA_RECEIPT_ORIGIN_ID, fsIds);

        return mjdTimeSeries;
    }

    public static FloatTimeSeries[] mockAncillaryPipelineData(
        JMockTest jMockTest, FileStoreClient fsClient, String[] mnemonics,
        TargetTable targetTable, int ccdModule, int ccdOutput,
        int startCadence, int endCadence, long producerTaskId) {

        Map<String, Pair<FsId, FsId>> mnemonicToFsIds = AncillaryOperations.getAncillaryMnemonicToTimeSeriesFsIds(
            mnemonics, targetTable, ccdModule, ccdOutput);

        List<FsId> allFsIds = new ArrayList<FsId>();
        for (String mnemonic : mnemonics) {
            Pair<FsId, FsId> fsIds = mnemonicToFsIds.get(mnemonic);
            if (fsIds != null) {
                allFsIds.add(fsIds.left);
                if (fsIds.right != null) {
                    allFsIds.add(fsIds.right);
                }
            } else {
                throw new IllegalArgumentException(String.format(
                    "%s: not currently supported by this method", mnemonic));
            }
        }

        FloatTimeSeries[] floatTimeSeries = MockUtils.mockReadFloatTimeSeries(
            jMockTest, fsClient, startCadence, endCadence, producerTaskId,
            allFsIds.toArray(new FsId[allFsIds.size()]), false);

        return floatTimeSeries;
    }

    public static List<AncillaryPipelineData> mockAncillaryPipelineData(
        JMockTest jMockTest, AncillaryOperations ancillaryOperations,
        String[] mnemonics, TargetTable targetTable, int ccdModule,
        int ccdOutput, TimestampSeries cadenceTimes, long producerTaskId) {

        List<AncillaryPipelineData> ancillaryPipelineData = new ArrayList<AncillaryPipelineData>();
        for (String mnemonic : mnemonics) {
            AncillaryPipelineData data = new AncillaryPipelineData(mnemonic);
            data.setTimestamps(cadenceTimes.midTimestamps);
            float[] values = new float[cadenceTimes.midTimestamps.length];
            Arrays.fill(values, random.nextFloat());
            data.setValues(values);
            ancillaryPipelineData.add(data);
        }
        if (jMockTest != null && ancillaryOperations != null) {
            jMockTest.allowing(ancillaryOperations)
                .retrieveAncillaryPipelineData(mnemonics, targetTable,
                    ccdModule, ccdOutput, cadenceTimes);
            jMockTest.will(returnValue(ancillaryPipelineData));
            jMockTest.allowing(ancillaryOperations)
                .producerTaskIds();
            jMockTest.will(returnValue(ImmutableSet.of(producerTaskId)));
        }

        return null;
    }

    public static RaDec2PixModel mockRaDec2PixModel(JMockTest jMockTest,
        RaDec2PixOperations raDec2PixOperations, double startMjd, double endMjd) {
        return mockRaDec2PixModel(jMockTest, raDec2PixOperations, startMjd,
            endMjd, 2);
    }

    public static RaDec2PixModel mockRaDec2PixModel(JMockTest jMockTest,
        RaDec2PixOperations raDec2PixOperations, double startMjd,
        double endMjd, int seasonCount) {

        double[] mjds = new double[seasonCount];
        for (int i = 0; i < seasonCount; i++) {
            mjds[i] = startMjd + i * (endMjd - startMjd) / (seasonCount - 1);
        }

        FcModelMetadata modelMetaData = new FcModelMetadata();
        modelMetaData.setIngestTime("mock ingest time");
        modelMetaData.setModelDescription("mock model description");
        modelMetaData.setSvnInfo("mock peg URL");

        PointingModel pointingModel = new PointingModel(mjds,
            new double[seasonCount], new double[seasonCount],
            new double[seasonCount], new double[seasonCount]);
        GeometryModel geometryModel = new GeometryModel(mjds,
            new double[seasonCount][2]);
        RollTimeModel rollTimeModel = new RollTimeModel(mjds,
            new int[seasonCount]);
        pointingModel.setFcModelMetadata(modelMetaData);
        geometryModel.setFcModelMetadata(modelMetaData);
        rollTimeModel.setFcModelMetadata(modelMetaData);

        String spiceFileDir = "spiceDir";
        String spiceFileName = "spiceFile";
        String planetaryEphemerisFileName = "planetaryEphemerisFile";
        String leapSecondsFileName = "leapSecondsFile";

        RaDec2PixModel raDec2PixModel = new RaDec2PixModel(startMjd, endMjd,
            pointingModel, geometryModel, rollTimeModel, spiceFileDir,
            spiceFileName, planetaryEphemerisFileName, leapSecondsFileName);
        if (jMockTest != null && raDec2PixOperations != null) {
            jMockTest.allowing(raDec2PixOperations)
                .retrieveRaDec2PixModel(startMjd, endMjd);
            jMockTest.will(returnValue(raDec2PixModel));
        }

        return raDec2PixModel;
    }

    public static List<TwoDBlackModel> mockTwoDBlackModels(JMockTest jMockTest,
        TwoDBlackOperations twoDBlackOperations, double startMjd,
        double endMjd, List<Integer> moduleOutputs,
        Map<Integer, List<TargetDefinition>> targetDefinitionsByModuleOutput) {

        List<TwoDBlackModel> twoDBlackModels = new ArrayList<TwoDBlackModel>();
        double[] mjds = new double[] { startMjd, endMjd };

        for (int moduleOutputNumber : moduleOutputs) {
            Pair<Integer, Integer> moduleOutput = FcConstants.getModuleOutput(moduleOutputNumber);
            int ccdModule = moduleOutput.left;
            int ccdOutput = moduleOutput.right;
            List<TargetDefinition> definitions = null;
            if (targetDefinitionsByModuleOutput != null && targetDefinitionsByModuleOutput.get(moduleOutputNumber) != null) {
                definitions = targetDefinitionsByModuleOutput.get(moduleOutputNumber);
            }

            List<TargetPixel> pixels = null;
            if (definitions != null) {
                pixels = TargetPixel.getPixels(definitions);
            } else {
                pixels = new ArrayList<TargetPixel>();
            }
            int[] rows = new int[pixels.size()];
            int[] columns = new int[pixels.size()];
            float[][][] blacks = new float[2][pixels.size()][pixels.size()];
            float[][][] uncertainties = new float[2][pixels.size()][pixels.size()];
            for (int i = 0; i < mjds.length; i++) {
                for (int j = 0; j < pixels.size(); j++) {
                    TargetPixel pixel = pixels.get(j);
                    rows[j] = pixel.getRow();
                    columns[j] = pixel.getColumn();
                    blacks[i][j][j] = 1;
                    uncertainties[i][j][j] = 0.001F;
                }
            }

            TwoDBlackModel twoDBlackModel = new TwoDBlackModel(mjds, rows,
                columns, blacks, uncertainties);
            if (jMockTest != null && twoDBlackOperations != null) {
                jMockTest.allowing(twoDBlackOperations)
                    .retrieveTwoDBlackModel(startMjd, endMjd, ccdModule,
                        ccdOutput, definitions);
                jMockTest.will(returnValue(twoDBlackModel));
            }
            twoDBlackModels.add(twoDBlackModel);
        }

        return twoDBlackModels;
    }

    public static List<FlatFieldModel> mockFlatFieldModels(JMockTest jMockTest,
        FlatFieldOperations flatFieldOperations, double startMjd,
        double endMjd, List<Integer> moduleOutputs,
        Map<Integer, List<TargetDefinition>> targetDefinitionsByModuleOutput) {

        List<FlatFieldModel> flatFieldModels = new ArrayList<FlatFieldModel>();
        double[] mjds = new double[] { startMjd, endMjd };

        for (int moduleOutputNumber : moduleOutputs) {
            Pair<Integer, Integer> moduleOutput = FcConstants.getModuleOutput(moduleOutputNumber);
            int ccdModule = moduleOutput.left;
            int ccdOutput = moduleOutput.right;
            List<TargetDefinition> definitions = null;
            if (targetDefinitionsByModuleOutput != null && targetDefinitionsByModuleOutput.get(moduleOutputNumber) != null) {
                definitions = targetDefinitionsByModuleOutput.get(moduleOutputNumber);
            }
            
            List<TargetPixel> pixels = null;
            if (definitions != null) {
                pixels = TargetPixel.getPixels(definitions);
            } else {
                pixels = new ArrayList<TargetPixel>();
            }
            int[] rows = new int[pixels.size()];
            int[] columns = new int[pixels.size()];
            float[][][] flats = new float[2][pixels.size()][pixels.size()];
            float[][][] uncertainties = new float[2][pixels.size()][pixels.size()];
            for (int i = 0; i < mjds.length; i++) {
                for (int j = 0; j < pixels.size(); j++) {
                    TargetPixel pixel = pixels.get(j);
                    rows[j] = pixel.getRow();
                    columns[j] = pixel.getColumn();
                    flats[i][j][j] = 1;
                    uncertainties[i][j][j] = 0.001F;
                }
            }

            FlatFieldModel flatFieldModel = new FlatFieldModel(mjds, flats,
                uncertainties, rows, columns);
            if (jMockTest != null && flatFieldOperations != null) {
                jMockTest.allowing(flatFieldOperations)
                    .retrieveFlatFieldModel(startMjd, endMjd, ccdModule,
                        ccdOutput, definitions);
                jMockTest.will(returnValue(flatFieldModel));
            }
            flatFieldModels.add(flatFieldModel);
        }

        return flatFieldModels;
    }

    public static SaturationModel mockSaturationModel(JMockTest jMockTest,
        SaturationOperations saturationOperations, int ccdModule, int ccdOutput) {

        int channel = FcConstants.getChannelNumber(ccdModule, ccdOutput);
        int season = 2;
        // TODO Create real fake stars.
        SaturatedStar[] stars = null;
        SaturationModel saturationModel = new SaturationModel(season, channel, stars);
        return saturationModel;
    }

    public static RequantTable mockRequantTable(JMockTest jMockTest,
        CompressionCrud compressionCrud, int compressionTableId) {

        RequantTable requantTable = createRequantTable(compressionTableId);

        if (jMockTest != null && compressionCrud != null) {
            jMockTest.allowing(compressionCrud)
                .retrieveUplinkedRequantTable(compressionTableId);
            jMockTest.will(returnValue(requantTable));
        }

        return requantTable;
    }

    public static List<RequantTable> mockRequantTables(JMockTest jMockTest,
        CompressionCrud compressionCrud, double mjdStart, double mjdEnd,
        int compressionTableId) {

        RequantTable requantTable = createRequantTable(compressionTableId);
        List<RequantTable> requantTables = ImmutableList.of(requantTable);

        if (jMockTest != null && compressionCrud != null) {
            jMockTest.allowing(compressionCrud)
                .retrieveRequantTables(mjdStart, mjdEnd);
            jMockTest.will(returnValue(requantTables));
        }

        return requantTables;
    }

    private static RequantTable createRequantTable(int compressionTableId) {
        List<RequantEntry> requantEntries = new ArrayList<RequantEntry>(
            FcConstants.REQUANT_TABLE_LENGTH);
        for (int i = 0; i < FcConstants.REQUANT_TABLE_LENGTH; i++) {
            requantEntries.add(new RequantEntry(
                FcConstants.REQUANT_TABLE_MIN_VALUE
                    + random.nextInt(FcConstants.REQUANT_TABLE_MAX_VALUE
                        - FcConstants.REQUANT_TABLE_MIN_VALUE)));
        }
        List<MeanBlackEntry> meanBlackEntries = new ArrayList<MeanBlackEntry>(
            FcConstants.MODULE_OUTPUTS);
        for (int i = 0; i < FcConstants.MODULE_OUTPUTS; i++) {
            meanBlackEntries.add(new MeanBlackEntry(i));
        }

        RequantTable requantTable = new RequantTable();
        requantTable.setExternalId(compressionTableId);
        requantTable.setRequantEntries(requantEntries);
        requantTable.setMeanBlackEntries(meanBlackEntries);

        return requantTable;
    }

    @Deprecated
    public static GainModel mockGainModel(Mockery mockery,
        final GainOperations gainOperations, final double startMjd,
        final double endMjd) {

        double[] gains = new double[FcConstants.MODULE_OUTPUTS];
        Arrays.fill(gains, 1.0);

        double[] mjds = new double[] { startMjd, endMjd };
        double[][] constants = new double[][] { gains, gains };

        final GainModel gainModel = new GainModel(mjds, constants);
        if (mockery != null && gainOperations != null) {
            mockery.checking(new Expectations() {
                {
                    oneOf(gainOperations).retrieveGainModel(startMjd, endMjd);
                    will(returnValue(gainModel));
                }
            });
        }

        return gainModel;
    }

    public static GainModel mockGainModel(JMockTest jMockTest,
        GainOperations gainOperations, double startMjd, double endMjd) {

        double[] gains = new double[FcConstants.MODULE_OUTPUTS];
        Arrays.fill(gains, 1.0);

        double[] mjds = new double[] { startMjd, endMjd };
        double[][] constants = new double[][] { gains, gains };

        GainModel gainModel = new GainModel(mjds, constants);
        if (jMockTest != null && gainOperations != null) {
            jMockTest.allowing(gainOperations)
                .retrieveGainModel(startMjd, endMjd);
            jMockTest.will(returnValue(gainModel));
        }

        return gainModel;
    }

    public static LinearityModel mockLinearityModel(JMockTest jMockTest,
        LinearityOperations linearityOperations, int ccdModule, int ccdOutput, double startMjd, double endMjd) {

        double[] linearity = new double[FcConstants.MODULE_OUTPUTS];
        Arrays.fill(linearity, 1.0);

        double[] mjds = new double[] { startMjd, endMjd };
        double[][] constants = new double[][] { linearity, linearity };

        LinearityModel linearityModel = new LinearityModel(mjds, constants);
        if (jMockTest != null && linearityOperations != null) {
            jMockTest.allowing(linearityOperations)
                .retrieveLinearityModel(ccdModule, ccdOutput, startMjd, endMjd);
            jMockTest.will(returnValue(linearityModel));
        }

        return linearityModel;
    }

    @Deprecated
    public static ReadNoiseModel mockReadNoiseModel(Mockery mockery,
        final ReadNoiseOperations readNoiseOperations, final double startMjd,
        final double endMjd) {

        double[] readNoises = new double[FcConstants.MODULE_OUTPUTS];
        Arrays.fill(readNoises, 1.0);

        double[] mjds = new double[] { startMjd, endMjd };
        double[][] constants = new double[][] { readNoises, readNoises };

        final ReadNoiseModel readNoiseModel = new ReadNoiseModel(mjds,
            constants);
        if (mockery != null && readNoiseOperations != null) {
            mockery.checking(new Expectations() {
                {
                    oneOf(readNoiseOperations).retrieveReadNoiseModel(startMjd,
                        endMjd);
                    will(returnValue(readNoiseModel));
                }
            });
        }

        return readNoiseModel;
    }

    public static ReadNoiseModel mockReadNoiseModel(JMockTest jMockTest,
        ReadNoiseOperations readNoiseOperations, double startMjd, double endMjd) {

        double[] readNoises = new double[FcConstants.MODULE_OUTPUTS];
        Arrays.fill(readNoises, 1.0);

        double[] mjds = new double[] { startMjd, endMjd };
        double[][] constants = new double[][] { readNoises, readNoises };

        ReadNoiseModel readNoiseModel = new ReadNoiseModel(mjds, constants);
        if (jMockTest != null && readNoiseOperations != null) {
            jMockTest.allowing(readNoiseOperations)
                .retrieveReadNoiseModel(startMjd, endMjd);
            jMockTest.will(returnValue(readNoiseModel));
        }

        return readNoiseModel;
    }

    @Deprecated
    public static UndershootModel mockUndershootModel(Mockery mockery,
        final UndershootOperations undershootOperations, final double startMjd,
        final double endMjd) {

        double[] mjds = new double[] { startMjd, endMjd };
        double[] defaultUndershoot = new double[] { 3, 1, 2, 0 };
        double[] defaultUndershootUncertainty = new double[] { 3, 1, 2, 0 };

        final double[][][] undershoots = new double[mjds.length][FcConstants.MODULE_OUTPUTS][];
        final double[][][] uncertainties = new double[mjds.length][FcConstants.MODULE_OUTPUTS][];

        for (int i = 0; i < mjds.length; i++) {
            for (int j = 0; j < FcConstants.MODULE_OUTPUTS; j++) {
                undershoots[i][j] = defaultUndershoot;
                uncertainties[i][j] = defaultUndershootUncertainty;
            }
        }

        final UndershootModel undershootModel = new UndershootModel(mjds,
            undershoots, uncertainties);
        if (mockery != null && undershootOperations != null) {
            mockery.checking(new Expectations() {
                {
                    oneOf(undershootOperations).retrieveUndershootModel(
                        startMjd, endMjd);
                    will(returnValue(undershootModel));
                }
            });
        }

        return undershootModel;
    }

    public static UndershootModel mockUndershootModel(JMockTest jMockTest,
        UndershootOperations undershootOperations, double startMjd,
        double endMjd) {

        double[] mjds = new double[] { startMjd, endMjd };
        double[] defaultUndershoot = new double[] { 3, 1, 2, 0 };
        double[] defaultUndershootUncertainty = new double[] { 3, 1, 2, 0 };

        double[][][] undershoots = new double[mjds.length][FcConstants.MODULE_OUTPUTS][];
        double[][][] uncertainties = new double[mjds.length][FcConstants.MODULE_OUTPUTS][];

        for (int i = 0; i < mjds.length; i++) {
            for (int j = 0; j < FcConstants.MODULE_OUTPUTS; j++) {
                undershoots[i][j] = defaultUndershoot;
                uncertainties[i][j] = defaultUndershootUncertainty;
            }
        }

        UndershootModel undershootModel = new UndershootModel(mjds,
            undershoots, uncertainties);
        if (jMockTest != null && undershootOperations != null) {
            jMockTest.allowing(undershootOperations)
                .retrieveUndershootModel(startMjd, endMjd);
            jMockTest.will(returnValue(undershootModel));
        }

        return undershootModel;
    }

    public static MrReport mockGenericReport(JMockTest jMockTest,
        GenericReportOperations genericReportOperations,
        PipelineTask pipelineTask, File reportFile) {

        MrReport mrReport = new MrReport(pipelineTask, reportFile.getName(),
            "application/pdf", "foo/bar/baz");

        if (jMockTest != null && genericReportOperations != null) {
            jMockTest.allowing(genericReportOperations)
                .createReport(pipelineTask, reportFile);
            jMockTest.will(returnValue(mrReport));
        }

        return mrReport;
    }

    public static MrReport mockGenericReport(JMockTest jMockTest,
        GenericReportOperations genericReportOperations,
        PipelineTask pipelineTask, String identifier, File workingDir,
        String filename) {

        MrReport mrReport = new MrReport(pipelineTask, identifier, filename,
            "application/pdf", "foo/bar/baz");

        if (jMockTest != null && genericReportOperations != null) {
            jMockTest.allowing(genericReportOperations)
                .createReport(pipelineTask, identifier,
                    new File(workingDir, filename));
            jMockTest.will(returnValue(mrReport));
        }

        return mrReport;
    }

    @Deprecated
    public static String[][] mockDataAnomalies(Mockery mockery,
        final DataAnomalyOperations dataAnomalyOperations,
        final CadenceType cadenceType, final int startCadence,
        final int endCadence) {

        final String[][] dataAnomalies = new String[endCadence - startCadence
            + 1][];
        ArrayUtils.fill(dataAnomalies, new String[0]);
        dataAnomalies[0] = new String[] { DataAnomalyType.SAFE_MODE.toString() };

        mockery.checking(new Expectations() {
            {
                oneOf(dataAnomalyOperations).retrieveDataAnomalyTypes(
                    cadenceType, startCadence, endCadence);
                will(returnValue(dataAnomalies));
            }
        });

        return dataAnomalies;
    }

    public static String[][] mockDataAnomalies(JMockTest jMockTest,
        DataAnomalyOperations dataAnomalyOperations, CadenceType cadenceType,
        int startCadence, int endCadence) {

        String[][] dataAnomalies = new String[endCadence - startCadence + 1][];
        ArrayUtils.fill(dataAnomalies, new String[0]);
        dataAnomalies[0] = new String[] { DataAnomalyType.SAFE_MODE.toString() };

        if (jMockTest != null && dataAnomalyOperations != null) {
            jMockTest.allowing(dataAnomalyOperations)
                .retrieveDataAnomalyTypes(cadenceType, startCadence, endCadence);
            jMockTest.will(returnValue(dataAnomalies));
        }

        return dataAnomalies;
    }

    @Deprecated
    public static DataAnomalyFlags mockDataAnomalyFlags(Mockery mockery,
        final DataAnomalyOperations dataAnomalyOperations,
        final CadenceType cadenceType, final int startCadence,
        final int endCadence) {

        boolean[] attitudeTweakIndicators = new boolean[endCadence
            - startCadence + 1];
        boolean[] safeModeIndicators = new boolean[attitudeTweakIndicators.length];
        boolean[] coarsePointIndicators = new boolean[attitudeTweakIndicators.length];
        boolean[] argabrighteningIndicators = new boolean[attitudeTweakIndicators.length];
        boolean[] excludeIndicators = new boolean[attitudeTweakIndicators.length];
        boolean[] earthPointIndicators = new boolean[attitudeTweakIndicators.length];
        boolean[] planetSearchExcludeIndicators = new boolean[attitudeTweakIndicators.length];
        safeModeIndicators[0] = true;

        final DataAnomalyFlags dataAnomalyFlags = new DataAnomalyFlags(
            attitudeTweakIndicators, safeModeIndicators, coarsePointIndicators,
            argabrighteningIndicators, excludeIndicators, earthPointIndicators,
            planetSearchExcludeIndicators);

        mockery.checking(new Expectations() {
            {
                oneOf(dataAnomalyOperations).retrieveDataAnomalyFlags(
                    cadenceType, startCadence, endCadence);
                will(returnValue(dataAnomalyFlags));
            }
        });

        return dataAnomalyFlags;
    }

    public static DataAnomalyFlags mockDataAnomalyFlags(JMockTest jMockTest,
        DataAnomalyOperations dataAnomalyOperations, CadenceType cadenceType,
        int startCadence, int endCadence) {

        boolean[] attitudeTweakIndicators = new boolean[endCadence
            - startCadence + 1];
        boolean[] safeModeIndicators = new boolean[attitudeTweakIndicators.length];
        boolean[] coarsePointIndicators = new boolean[attitudeTweakIndicators.length];
        boolean[] argabrighteningIndicators = new boolean[attitudeTweakIndicators.length];
        boolean[] excludeIndicators = new boolean[attitudeTweakIndicators.length];
        boolean[] earthPointIndicators = new boolean[attitudeTweakIndicators.length];
        boolean[] planetSearchExcludeIndicators = new boolean[attitudeTweakIndicators.length];
        safeModeIndicators[0] = true;

        DataAnomalyFlags dataAnomalyFlags = new DataAnomalyFlags(
            attitudeTweakIndicators, safeModeIndicators, coarsePointIndicators,
            argabrighteningIndicators, excludeIndicators, earthPointIndicators,
            planetSearchExcludeIndicators);

        if (jMockTest != null && dataAnomalyOperations != null) {
            jMockTest.allowing(dataAnomalyOperations)
                .retrieveDataAnomalyFlags(cadenceType, startCadence, endCadence);
            jMockTest.will(returnValue(dataAnomalyFlags));
        }

        return dataAnomalyFlags;
    }

    public static List<TargetList> mockPseudoTargetLists(JMockTest jMockTest,
        TargetSelectionCrud targetSelectionCrud, String[] pseudoTargetLists) {

        List<TargetList> targetLists = new ArrayList<TargetList>();

        for (String targetListName : pseudoTargetLists) {
            TargetList targetList = new TargetList(targetListName);
            targetLists.add(targetList);
            if (jMockTest != null && targetSelectionCrud != null) {
                jMockTest.allowing(targetSelectionCrud)
                    .retrieveTargetList(targetListName);
                jMockTest.will(returnValue(targetList));
            }
        }

        return targetLists;
    }

    public static List<PlannedTarget> mockPlannedTargets(JMockTest jMockTest,
        TargetSelectionCrud targetSelectionCrud, TargetType targetType,
        List<TargetList> targetLists, int startKeplerId,
        int plannedTargetCount, int ccdModule, int ccdOutput, int row,
        int column, int offset, int skyGroupId, Set<FsId> fsIds) {

        List<PlannedTarget> plannedTargets = new ArrayList<PlannedTarget>();
        int keplerId = startKeplerId;
        for (TargetList targetList : targetLists) {
            for (int i = 0; i < plannedTargetCount; i++) {
                PlannedTarget plannedTarget = new PlannedTarget(targetList);
                plannedTarget.setKeplerId(++keplerId);
                Random random = new Random(keplerId);
                int referenceRow = row + random.nextInt(offset);
                int referenceColumn = column + random.nextInt(offset);
                List<Offset> offsets = Arrays.asList(new Offset(0, 0),
                    new Offset(1, 1), new Offset(0, 1), new Offset(1, 0));
                fsIds.addAll(getTargetFsIds(targetType, ccdModule, ccdOutput,
                    new Pixel(referenceRow, referenceColumn), offsets));
                Aperture aperture = new Aperture(true, referenceRow,
                    referenceColumn, offsets);
                plannedTarget.setAperture(aperture);
                plannedTarget.setSkyGroupId(skyGroupId);
                plannedTargets.add(plannedTarget);
            }
            if (jMockTest != null && targetSelectionCrud != null) {
                jMockTest.allowing(targetSelectionCrud)
                    .retrievePlannedTargets(targetList, skyGroupId);
                jMockTest.will(returnValue(plannedTargets));
            }
        }

        return plannedTargets;
    }

    public static void mockPlannedTargets(JMockTest jMockTest,
        CelestialObjectOperations celestialObjectOperations,
        List<PlannedTarget> plannedTargets) {

        List<Integer> keplerIds = new ArrayList<Integer>();
        List<CelestialObjectParameters> celestialObjectParametersList = new ArrayList<CelestialObjectParameters>();
        for (PlannedTarget plannedTarget : plannedTargets) {
            keplerIds.add(plannedTarget.getKeplerId());
            CustomTarget customTarget = new CustomTarget(
                plannedTarget.getKeplerId(), plannedTarget.getSkyGroupId());
            // TODO Set all the field values.
            celestialObjectParametersList.add(new CelestialObjectParameters.Builder(
                customTarget).keplerMag(
                new CelestialObjectParameter("Test", 10.0, Double.NaN))
                .build());
        }
        if (jMockTest != null && celestialObjectOperations != null) {
            jMockTest.allowing(celestialObjectOperations)
                .retrieveCelestialObjectParameters(keplerIds);
            jMockTest.will(returnValue(celestialObjectParametersList));
        }
    }

    public static List<CelestialObjectParameters> mockCelestialObjectParameters(
        JMockTest jMockTest,
        CelestialObjectOperations celestialObjectOperations,
        List<Integer> keplerIds, int skyGroupId) {

        List<CelestialObjectParameters> celestialObjectParameters = new ArrayList<CelestialObjectParameters>();
        for (int keplerId : keplerIds) {
            CelestialObject celestialObject = createCelestialObject(keplerId,
                skyGroupId);
            celestialObjectParameters.add(new CelestialObjectParameters.Builder(
                celestialObject).build());
        }

        if (jMockTest != null && celestialObjectOperations != null) {
            jMockTest.allowing(celestialObjectOperations)
                .retrieveCelestialObjectParameters(keplerIds);
            jMockTest.will(returnValue(celestialObjectParameters));
        }

        return celestialObjectParameters;
    }

    public static CelestialObject createCelestialObject(int keplerId,
        int skyGroupId) {
        return CelestialObjectUtils.createCelestialObject(keplerId, skyGroupId,
            keplerId);
    }

    public static BlobData<String> mockTipBlob(
        JMockTest jMockTest,
        ModelMetadataRetrieverPipelineInstance modelMetadataRetrieverPipelineInstance,
        BlobOperations blobOperations, String modelType, int skyGroupId,
        Date now) {

        ModelMetadata modelMetadata = new ModelMetadata(
            new ModelType(modelType), "modelDescription", "modelRevision", now);
        BlobData<String> blobData = new BlobData<String>("blob-tip.txt",
            skyGroupId);
        if (jMockTest != null && modelMetadataRetrieverPipelineInstance != null
            && blobOperations != null) {
            jMockTest.allowing(modelMetadataRetrieverPipelineInstance)
                .retrieve(modelType);
            jMockTest.will(returnValue(modelMetadata));

            jMockTest.allowing(blobOperations)
                .retrieveTipBlobFile(skyGroupId, modelMetadata.getImportTime()
                    .getTime());
            jMockTest.will(returnValue(blobData));
        }

        return blobData;
    }
}
