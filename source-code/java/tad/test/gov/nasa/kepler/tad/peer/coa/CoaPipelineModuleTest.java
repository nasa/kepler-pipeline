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

package gov.nasa.kepler.tad.peer.coa;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.primitives.Ints.toArray;
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.MatlabDateFormatter;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.intervals.BlobFileSeriesFactory;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.fc.FlatFieldModel;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.LinearityModel;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.SaturationModel;
import gov.nasa.kepler.fc.SaturationOperations;
import gov.nasa.kepler.fc.TwoDBlackModel;
import gov.nasa.kepler.fc.UndershootModel;
import gov.nasa.kepler.fc.flatfield.FlatFieldOperations;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.linearity.LinearityOperations;
import gov.nasa.kepler.fc.prf.PrfModel;
import gov.nasa.kepler.fc.prf.PrfOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fc.twodblack.TwoDBlackOperations;
import gov.nasa.kepler.fc.undershoot.UndershootOperations;
import gov.nasa.kepler.hibernate.cm.Characteristic;
import gov.nasa.kepler.hibernate.cm.CharacteristicCrud;
import gov.nasa.kepler.hibernate.cm.CharacteristicType;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.ModOut;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperationsFactory;
import gov.nasa.kepler.mc.cm.CelestialObjectParameter;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.tad.CoaCommon;
import gov.nasa.kepler.mc.tad.CoaObservedTargetRejecter;
import gov.nasa.kepler.mc.tad.DistanceFromEdgeCalculator;
import gov.nasa.kepler.mc.tad.KicEntryData;
import gov.nasa.kepler.mc.tad.OptimalAperture;
import gov.nasa.kepler.mc.tad.PersistableFactory;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.kepler.tad.peer.CoaModuleParameters;
import gov.nasa.kepler.tad.peer.PipelineModuleTest;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.Date;
import java.util.List;

import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

public class CoaPipelineModuleTest extends JMockTest {

    private static final ModOut MOD_OUT = ModOut.of(1, 2);
    private static final int KIC_KEPLER_ID = 3;
    private static final Date START = new Date(4000);
    private static final Date END = new Date(5000);
    private static final long TARGET_TABLE_DATABASE_ID = 5;
    private static final int OBSERVING_SEASON = 6;
    private static final int SKY_GROUP_ID = 7;
    private static final byte[] PRF_BLOB = new byte[] { 9 };
    private static final int CADENCE_NUMBER = 10;
    private static final int[] BLOB_INDICES = new int[] { 11 };
    private static final double[][] COMPLETE_OUTPUT_IMAGE = new double[][] { { 12 } };
    private static final int MIN_ROW = 13;
    private static final int MAX_ROW = 14;
    private static final int MIN_COL = 15;
    private static final int MAX_COL = 16;
    private gov.nasa.kepler.mc.tad.Offset offsetFromModuleInterface = new gov.nasa.kepler.mc.tad.Offset(
        17, 18);
    private static final int REFERENCE_ROW = 19;
    private static final int REFERENCE_COLUMN = 20;
    private static final int BAD_PIXEL_COUNT = 21;
    private static final double SIGNAL_TO_NOISE_RATIO = 22.22;
    private static final double CROWDING_METRIC = 23.23;
    private static final double SKY_CROWDING_METRIC = 24.24;
    private static final double FLUX_FRACTION_IN_APERTURE = 25.25;
    private static final int DISTANCE_FROM_EDGE = 26;
    private static final int SATURATED_ROW_COUNT = 27;
    private static final double RA = 27.27;
    private static final double DEC = 28.28;
    private static final float MAGNITUDE = 29.29F;
    private float effectiveTemp = 30.30F;
    private float effectiveTempForMatlab = effectiveTemp;
    private int quarter = 31;

    private static final String TARGET_LIST_SET_NAME = "TARGET_LIST_SET_NAME";
    private String origTargetListSetName = "origTargetListSetName";
    private static final String ASSOCIATED_LC_TARGET_LIST_SET_NAME = "ASSOCIATED_LC_TARGET_LIST_SET_NAME";
    private static final boolean REJECTED = false;
    private static final double START_MJD = ModifiedJulianDate.dateToMjd(START);
    private static final double END_MJD = ModifiedJulianDate.dateToMjd(END);
    private static final boolean MOTION_POLYNOMIALS_ENABLED = true;
    private static final boolean BACKGROUND_POLYNOMIALS_ENABLED = true;
    private static final boolean[] GAP_INDICATORS = new boolean[] { false };
    private static final Object[] BLOB_FILENAMES = new Object[] { "BLOB_FILENAME" };
    private static final int APERTURE_PIXEL_COUNT = 1;
    private static final String START_TIME = MatlabDateFormatter.dateFormatter()
        .format(START);
    private static final double DURATION = (double) (END.getTime() - START.getTime())
        / (double) (1000 * 60 * 60 * 24);
    private static final boolean APERTURE_UPDATED_WITH_PACOA = false;
    private static final boolean PA_COA_APERTURE_USED = false;

    private PipelineInstance pipelineInstance = mock(PipelineInstance.class);
    private PipelineInstanceNode pipelineInstanceNode = mock(PipelineInstanceNode.class);
    private PipelineModuleDefinition pipelineModuleDefinition = mock(PipelineModuleDefinition.class);
    private PipelineTask pipelineTask = mock(PipelineTask.class);
    private ModOutUowTask modOutUowTask = mock(ModOutUowTask.class);
    private TadParameters tadParameters = mock(TadParameters.class);
    private File workingDir = mock(File.class);
    private TargetListSet targetListSet = mock(TargetListSet.class,
        "targetListSet");
    private TargetListSet associatedLcTargetListSet = mock(TargetListSet.class,
        "associatedLcTargetListSet");
    private TargetTable targetTable = mock(TargetTable.class, "targetTable");
    private TargetTable associatedLcTargetTable = mock(TargetTable.class,
        "associatedLcTargetTable");
    private ObservedTarget observedTarget = mock(ObservedTarget.class);
    private Aperture apertureExisting = mock(Aperture.class, "apertureExisting");
    private Aperture apertureCreated = mock(Aperture.class, "apertureCreated");
    private Offset offset = offsetFromModuleInterface.toDatabaseOffset();
    private List<Offset> offsets = newArrayList(offset);
    private PlannedSpacecraftConfigParameters plannedSpacecraftConfigParameters = mock(PlannedSpacecraftConfigParameters.class);
    private CoaModuleParameters coaModuleParameters = mock(CoaModuleParameters.class);
    private CelestialObjectParameters celestialObjectParameters = mock(CelestialObjectParameters.class);
    private List<CelestialObjectParameters> celestialObjectParametersList = newArrayList(celestialObjectParameters);
    private CharacteristicType characteristicTypeRa = mock(
        CharacteristicType.class, "characteristicTypeRa");
    private CharacteristicType characteristicTypeDec = mock(
        CharacteristicType.class, "characteristicTypeDec");
    private CharacteristicType characteristicTypeMagnitude = mock(
        CharacteristicType.class, "characteristicTypeMagnitude");
    private Characteristic characteristicRa = mock(Characteristic.class,
        "characteristicRa");
    private Characteristic characteristicDec = mock(Characteristic.class,
        "characteristicDec");
    private Characteristic characteristicMagnitude = mock(Characteristic.class,
        "characteristicMagnitude");
    private CelestialObjectParameter celestialObjectParameterRa = mock(
        CelestialObjectParameter.class, "celestialObjectParameterRa");
    private CelestialObjectParameter celestialObjectParameterDec = mock(
        CelestialObjectParameter.class, "celestialObjectParameterDec");
    private CelestialObjectParameter celestialObjectParameterMagnitude = mock(
        CelestialObjectParameter.class, "celestialObjectParameterMagnitude");
    private CelestialObjectParameter celestialObjectParameterEffectiveTemp = mock(
        CelestialObjectParameter.class, "celestialObjectParameterEffectiveTemp");
    private PrfModel prfModel = mock(PrfModel.class);
    private RaDec2PixModel raDec2PixModel = mock(RaDec2PixModel.class);
    private ReadNoiseModel readNoiseModel = mock(ReadNoiseModel.class);
    private GainModel gainModel = mock(GainModel.class);
    private SaturationModel saturationModel = mock(SaturationModel.class);
    private TwoDBlackModel twoDBlackModel = mock(TwoDBlackModel.class);
    private LinearityModel linearityModel = mock(LinearityModel.class);
    private UndershootModel undershootModel = mock(UndershootModel.class);
    private FlatFieldModel flatFieldModel = mock(FlatFieldModel.class);
    private PixelLog pixelLog = mock(PixelLog.class);
    @SuppressWarnings("unchecked")
    private BlobSeries<String> blobSeries = mock(BlobSeries.class);
    private OptimalAperture optimalAperture = mock(OptimalAperture.class);
    private List<OptimalAperture> optimalApertures = newArrayList(optimalAperture);
    private CoaInputs coaInputs = mock(CoaInputs.class);
    private CoaOutputs coaOutputs = mock(CoaOutputs.class);
    private KicEntryData kicEntryData = mock(KicEntryData.class);
    private List<KicEntryData> kicEntryDatas = ImmutableList.of(kicEntryData);
    private BlobFileSeries blobFileSeries = mock(BlobFileSeries.class);
    private Integer keplerId = KIC_KEPLER_ID;
    private List<Integer> keplerIds = newArrayList(keplerId);
    private TargetType targetType = TargetType.LONG_CADENCE;
    private State state = State.LOCKED;

    private TargetCrud targetCrud = mock(TargetCrud.class);
    private TargetSelectionCrud targetSelectionCrud = mock(TargetSelectionCrud.class);
    private KicCrud kicCrud = mock(KicCrud.class);
    private CharacteristicCrud characteristicCrud = mock(CharacteristicCrud.class);
    private RaDec2PixOperations raDec2PixOperations = mock(RaDec2PixOperations.class);
    private ReadNoiseOperations readNoiseOperations = mock(ReadNoiseOperations.class);
    private GainOperations gainOperations = mock(GainOperations.class);
    private SaturationOperations saturationOperations = mock(SaturationOperations.class);
    private TwoDBlackOperations twoDBlackOperations = mock(TwoDBlackOperations.class);
    private PrfOperations prfOperations = mock(PrfOperations.class);
    private LinearityOperations linearityOperations = mock(LinearityOperations.class);
    private UndershootOperations undershootOperations = mock(UndershootOperations.class);
    private FlatFieldOperations flatFieldOperations = mock(FlatFieldOperations.class);
    private BlobOperations blobOperations = mock(BlobOperations.class);
    private LogCrud logCrud = mock(LogCrud.class);
    private CelestialObjectOperations celestialObjectOperations = mock(CelestialObjectOperations.class);
    private CoaObservedTargetRejecter coaObservedTargetRejecter = mock(CoaObservedTargetRejecter.class);
    private PersistableFactory persistableFactory = mock(PersistableFactory.class);
    private BlobFileSeriesFactory blobFileSeriesFactory = mock(BlobFileSeriesFactory.class);
    private CelestialObjectOperationsFactory celestialObjectOperationsFactory = mock(CelestialObjectOperationsFactory.class);
    private DistanceFromEdgeCalculator distanceFromEdgeCalculator = mock(DistanceFromEdgeCalculator.class);

    private CoaPipelineModule coaPipelineModule = new CoaPipelineModule(
        targetCrud, targetSelectionCrud, kicCrud, characteristicCrud,
        raDec2PixOperations, readNoiseOperations, gainOperations,
        saturationOperations, twoDBlackOperations, prfOperations,
        linearityOperations, undershootOperations, flatFieldOperations,
        blobOperations, logCrud, coaObservedTargetRejecter, persistableFactory,
        blobFileSeriesFactory, celestialObjectOperationsFactory,
        distanceFromEdgeCalculator, workingDir) {

        @Override
        protected void executeAlgorithm(PipelineTask pipelineTask,
            Persistable inputs, Persistable outputs) {
            assertEquals(coaInputs, inputs);
            assertEquals(coaOutputs, outputs);
        }

        @Override
        protected File allocateWorkingDir(String workingDirNamePrefix,
            PipelineTask pipelineTask) {
            return workingDir;
        }
    };
    
    @Before
    public void setUp() {
        CoaCommon.clearTargetTableModOutToOrigObservedTargets();
    }

    @Test
    public void testFrameworkMethods() {
        PipelineModuleTest.testFrameworkMethods(coaPipelineModule);
    }

    @Test
    public void testProcessTaskWithLongCadenceKicTarget() {
        setAllowances();

        setExpectationsForLongCadenceTarget();

        setExpectationsForKicTarget();

        setExpectationsForLongCadenceKicTarget();

        setExpectations();

        coaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test
    public void testProcessTaskWithLongCadenceCustomTarget() {
        keplerId = TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START;
        keplerIds.clear();
        optimalApertures.clear();

        allowing(observedTarget).getAperture();
        will(returnValue(apertureExisting));

        setAllowances();

        setExpectationsForLongCadenceTarget();

        setExpectations();

        coaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test
    public void testProcessTaskWithLongCadenceKicTargetWithEmptyOffsets() {
        allowing(observedTarget).getAperture();
        will(returnValue(apertureExisting));

        allowing(apertureExisting).getOffsets();
        will(returnValue(ImmutableList.of()));

        setAllowances();

        setExpectationsForLongCadenceTarget();

        setExpectationsForKicTarget();

        setExpectationsForLongCadenceKicTarget();

        setExpectations();

        coaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test
    public void testProcessTaskWithShortCadenceKicTarget() {
        targetType = TargetType.SHORT_CADENCE;

        setAllowances();

        setExpectationsForKicTarget();

        setExpectations();

        coaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test
    public void testProcessTaskWithShortCadenceKicTargetWithNonNullLongCadenceAperture() {
        targetType = TargetType.SHORT_CADENCE;

        allowing(observedTarget).getAperture();
        will(returnValue(apertureExisting));

        oneOf(observedTarget).setAperture(apertureCreated);

        oneOf(apertureExisting).setTargetTable(targetTable);

        oneOf(observedTarget).setAperturePixelCount(APERTURE_PIXEL_COUNT);

        setAllowances();

        setExpectationsForKicTarget();

        setExpectations();

        coaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = PipelineException.class)
    public void testProcessTaskWithShortCadenceKicTargetWithMissingLongCadenceTarget() {
        targetType = TargetType.SHORT_CADENCE;

        allowing(targetCrud).retrieveObservedTargetsPlusRejected(
            associatedLcTargetTable, MOD_OUT.getCcdModule(),
            MOD_OUT.getCcdOutput());
        will(returnValue(ImmutableList.of()));

        oneOf(blobOperations).setOutputDir(workingDir);

        setAllowances();

        coaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = PipelineException.class)
    public void testProcessTaskWithUnlockedTargetListSet() {
        state = State.UNLOCKED;

        setAllowances();

        coaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = PipelineException.class)
    public void testProcessTaskWithReferencePixelTargetListSet() {
        targetType = TargetType.REFERENCE_PIXEL;

        setAllowances();

        coaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = PipelineException.class)
    public void testProcessTaskWithNullOrigTargetListSet() {
        allowing(targetSelectionCrud).retrieveTargetListSet(
            origTargetListSetName);
        will(returnValue(null));

        setAllowances();

        coaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = PipelineException.class)
    public void testProcessTaskWithLongCadenceKicTargetWithEmptyCelestialObjectParametersList() {
        celestialObjectParametersList.clear();

        setAllowances();

        oneOf(coaInputs).setSpacecraftConfigurationStruct(
            plannedSpacecraftConfigParameters);

        oneOf(coaInputs).setCoaConfigurationStruct(coaModuleParameters);

        oneOf(coaInputs).setModule(MOD_OUT.getCcdModule());

        oneOf(coaInputs).setOutput(MOD_OUT.getCcdOutput());

        oneOf(coaInputs).setStartTime(START_TIME);

        oneOf(coaInputs).setDuration(DURATION);

        oneOf(blobOperations).setOutputDir(workingDir);

        coaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test
    public void testProcessTaskWithLongCadenceKicTargetWithNullEffectiveTemp() {
        effectiveTemp = Float.NaN;
        effectiveTempForMatlab = CoaCommon.NULL_EFFECTIVE_TEMP;

        setAllowances();

        setExpectationsForLongCadenceTarget();

        setExpectationsForKicTarget();

        setExpectationsForLongCadenceKicTarget();

        setExpectations();

        coaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = PipelineException.class)
    public void testProcessTaskWithLongCadenceKicTargetWithDuplicateCharacteristicEntries() {
        allowing(characteristicCrud).retrieveCharacteristics(
            characteristicTypeRa, SKY_GROUP_ID, quarter);
        will(returnValue(ImmutableList.of(characteristicRa, characteristicRa)));

        setAllowances();

        oneOf(coaInputs).setSpacecraftConfigurationStruct(
            plannedSpacecraftConfigParameters);

        oneOf(coaInputs).setCoaConfigurationStruct(coaModuleParameters);

        oneOf(coaInputs).setModule(MOD_OUT.getCcdModule());

        oneOf(coaInputs).setOutput(MOD_OUT.getCcdOutput());

        oneOf(coaInputs).setStartTime(START_TIME);

        oneOf(coaInputs).setDuration(DURATION);

        oneOf(blobOperations).setOutputDir(workingDir);

        coaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = PipelineException.class)
    public void testProcessTaskWithLongCadenceKicTargetWithNoPrf() {
        allowing(prfModel).getBlob();
        will(returnValue(null));

        setAllowances();

        oneOf(coaInputs).setSpacecraftConfigurationStruct(
            plannedSpacecraftConfigParameters);

        oneOf(coaInputs).setCoaConfigurationStruct(coaModuleParameters);

        oneOf(coaInputs).setModule(MOD_OUT.getCcdModule());

        oneOf(coaInputs).setOutput(MOD_OUT.getCcdOutput());

        oneOf(coaInputs).setStartTime(START_TIME);

        oneOf(coaInputs).setDuration(DURATION);

        oneOf(coaInputs).setKicEntryData(kicEntryDatas);

        oneOf(kicEntryData).setKICID(keplerId);

        oneOf(kicEntryData).setRA(RA);

        oneOf(kicEntryData).setDec(DEC);

        oneOf(kicEntryData).setEffectiveTemp(effectiveTempForMatlab);

        oneOf(kicEntryData).setMagnitude(MAGNITUDE);

        oneOf(coaInputs).setTargetKeplerIDList(toArray(keplerIds));

        oneOf(blobOperations).setOutputDir(workingDir);

        coaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = PipelineException.class)
    public void testProcessTaskWithLongCadenceKicTargetWithNullOrigTargetListSet() {
        allowing(targetSelectionCrud).retrieveTargetListSet(
            origTargetListSetName);
        will(returnValue(null));

        coaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test
    public void testProcessTaskWithLongCadenceKicTargetWithEmptyOrigTargetListSetName() {
        origTargetListSetName = "";

        setAllowances();

        oneOf(coaObservedTargetRejecter).reject(
            ImmutableList.of(observedTarget), null);

        oneOf(coaInputs).setSpacecraftConfigurationStruct(
            plannedSpacecraftConfigParameters);

        oneOf(coaInputs).setCoaConfigurationStruct(coaModuleParameters);

        oneOf(coaInputs).setModule(MOD_OUT.getCcdModule());

        oneOf(coaInputs).setOutput(MOD_OUT.getCcdOutput());

        oneOf(coaInputs).setStartTime(START_TIME);

        oneOf(coaInputs).setDuration(DURATION);

        oneOf(coaInputs).setKicEntryData(kicEntryDatas);

        oneOf(kicEntryData).setKICID(keplerId);

        oneOf(kicEntryData).setRA(RA);

        oneOf(kicEntryData).setDec(DEC);

        oneOf(kicEntryData).setEffectiveTemp(effectiveTempForMatlab);

        oneOf(kicEntryData).setMagnitude(MAGNITUDE);

        oneOf(coaInputs).setTargetKeplerIDList(toArray(keplerIds));

        oneOf(coaInputs).setPrfBlob(PRF_BLOB);

        oneOf(coaInputs).setRaDec2PixModel(raDec2PixModel);

        oneOf(coaInputs).setReadNoiseModel(readNoiseModel);

        oneOf(coaInputs).setGainModel(gainModel);

        oneOf(coaInputs).setSaturationModel(saturationModel);

        oneOf(coaInputs).setTwoDBlackModel(twoDBlackModel);

        oneOf(coaInputs).setLinearityModel(linearityModel);

        oneOf(coaInputs).setUndershootModel(undershootModel);

        oneOf(coaInputs).setFlatFieldModel(flatFieldModel);

        oneOf(coaInputs).setMotionBlobs(blobFileSeries);

        oneOf(coaInputs).setBackgroundBlobs(blobFileSeries);

        oneOf(targetCrud).createImage(targetTable, MOD_OUT.getCcdModule(),
            MOD_OUT.getCcdOutput(), pipelineTask, COMPLETE_OUTPUT_IMAGE,
            MIN_ROW, MAX_ROW, MIN_COL, MAX_COL);

        setExpectationsForKicTarget();

        setExpectationsForLongCadenceKicTarget();

        setExpectations();

        coaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = PipelineException.class)
    public void testProcessTaskWithLongCadenceKicTargetWithEmptyImage() {
        allowing(coaOutputs).getCompleteOutputImage();
        will(returnValue(new double[][] {}));

        setAllowances();

        oneOf(coaInputs).setSpacecraftConfigurationStruct(
            plannedSpacecraftConfigParameters);

        oneOf(coaInputs).setCoaConfigurationStruct(coaModuleParameters);

        oneOf(coaInputs).setModule(MOD_OUT.getCcdModule());

        oneOf(coaInputs).setOutput(MOD_OUT.getCcdOutput());

        oneOf(coaInputs).setStartTime(START_TIME);

        oneOf(coaInputs).setDuration(DURATION);

        oneOf(coaInputs).setKicEntryData(kicEntryDatas);

        oneOf(kicEntryData).setKICID(keplerId);

        oneOf(kicEntryData).setRA(RA);

        oneOf(kicEntryData).setDec(DEC);

        oneOf(kicEntryData).setEffectiveTemp(effectiveTempForMatlab);

        oneOf(kicEntryData).setMagnitude(MAGNITUDE);

        oneOf(coaInputs).setTargetKeplerIDList(toArray(keplerIds));

        oneOf(coaInputs).setPrfBlob(PRF_BLOB);

        oneOf(coaInputs).setRaDec2PixModel(raDec2PixModel);

        oneOf(coaInputs).setReadNoiseModel(readNoiseModel);

        oneOf(coaInputs).setGainModel(gainModel);

        oneOf(coaInputs).setSaturationModel(saturationModel);

        oneOf(coaInputs).setTwoDBlackModel(twoDBlackModel);

        oneOf(coaInputs).setLinearityModel(linearityModel);

        oneOf(coaInputs).setUndershootModel(undershootModel);

        oneOf(coaInputs).setFlatFieldModel(flatFieldModel);

        oneOf(coaInputs).setMotionBlobs(blobFileSeries);

        oneOf(coaInputs).setBackgroundBlobs(blobFileSeries);

        oneOf(coaObservedTargetRejecter).reject(
            ImmutableList.of(observedTarget), ImmutableList.of(observedTarget));

        setExpectationsForKicTarget();

        setExpectationsForLongCadenceKicTarget();

        setExpectations();

        coaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    private void setExpectations() {
        oneOf(blobOperations).setOutputDir(workingDir);

        oneOf(observedTarget).setDistanceFromEdge(DISTANCE_FROM_EDGE);
    }

    private void setExpectationsForKicTarget() {
        oneOf(observedTarget).setRejected(REJECTED);

        oneOf(observedTarget).setAperturePixelCount(APERTURE_PIXEL_COUNT);

        oneOf(observedTarget).setBadPixelCount(BAD_PIXEL_COUNT);

        oneOf(observedTarget).setSignalToNoiseRatio(SIGNAL_TO_NOISE_RATIO);

        oneOf(observedTarget).setMagnitude(MAGNITUDE);

        oneOf(observedTarget).setRa(RA);

        oneOf(observedTarget).setDec(DEC);

        oneOf(observedTarget).setEffectiveTemp(effectiveTemp);

        oneOf(observedTarget).setCrowdingMetric(CROWDING_METRIC);

        oneOf(observedTarget).setSkyCrowdingMetric(SKY_CROWDING_METRIC);

        oneOf(observedTarget).setFluxFractionInAperture(
            FLUX_FRACTION_IN_APERTURE);

        oneOf(observedTarget).setSaturatedRowCount(SATURATED_ROW_COUNT);

        oneOf(observedTarget).setPaCoaApertureUsed(PA_COA_APERTURE_USED);;
    }

    private void setExpectationsForLongCadenceTarget() {
        oneOf(coaInputs).setSpacecraftConfigurationStruct(
            plannedSpacecraftConfigParameters);

        oneOf(coaInputs).setCoaConfigurationStruct(coaModuleParameters);

        oneOf(coaInputs).setModule(MOD_OUT.getCcdModule());

        oneOf(coaInputs).setOutput(MOD_OUT.getCcdOutput());

        oneOf(coaInputs).setStartTime(START_TIME);

        oneOf(coaInputs).setDuration(DURATION);

        oneOf(coaInputs).setKicEntryData(kicEntryDatas);

        oneOf(kicEntryData).setKICID(keplerId);

        oneOf(kicEntryData).setRA(RA);

        oneOf(kicEntryData).setDec(DEC);

        oneOf(kicEntryData).setEffectiveTemp(effectiveTempForMatlab);

        oneOf(kicEntryData).setMagnitude(MAGNITUDE);

        oneOf(coaInputs).setTargetKeplerIDList(toArray(keplerIds));

        oneOf(coaInputs).setPrfBlob(PRF_BLOB);

        oneOf(coaInputs).setRaDec2PixModel(raDec2PixModel);

        oneOf(coaInputs).setReadNoiseModel(readNoiseModel);

        oneOf(coaInputs).setGainModel(gainModel);

        oneOf(coaInputs).setSaturationModel(saturationModel);

        oneOf(coaInputs).setTwoDBlackModel(twoDBlackModel);

        oneOf(coaInputs).setLinearityModel(linearityModel);

        oneOf(coaInputs).setUndershootModel(undershootModel);

        oneOf(coaInputs).setFlatFieldModel(flatFieldModel);

        oneOf(coaInputs).setMotionBlobs(blobFileSeries);

        oneOf(coaInputs).setBackgroundBlobs(blobFileSeries);

        oneOf(coaObservedTargetRejecter).reject(
            ImmutableList.of(observedTarget), ImmutableList.of(observedTarget));

        oneOf(targetCrud).createImage(targetTable, MOD_OUT.getCcdModule(),
            MOD_OUT.getCcdOutput(), pipelineTask, COMPLETE_OUTPUT_IMAGE,
            MIN_ROW, MAX_ROW, MIN_COL, MAX_COL);
    }

    private void setExpectationsForLongCadenceKicTarget() {
        oneOf(apertureCreated).setPipelineTask(pipelineTask);

        oneOf(apertureCreated).setTargetTable(targetTable);

        oneOf(observedTarget).setAperture(apertureCreated);
    }

    private void setAllowances() {
               
        allowing(pipelineTask).uowTaskInstance();
        will(returnValue(modOutUowTask));

        allowing(pipelineTask).getParameters(TadParameters.class);
        will(returnValue(tadParameters));

        allowing(pipelineTask).getPipelineInstanceNode();
        will(returnValue(pipelineInstanceNode));
        
        allowing(pipelineInstanceNode).getPipelineModuleDefinition();
        will(returnValue(pipelineModuleDefinition));
        
        allowing(pipelineModuleDefinition).getImplementingClass();
        will(returnValue(new ClassWrapper<Class<?>>(CoaPipelineModule.class)));

        allowing(tadParameters).getTargetListSetName();
        will(returnValue(TARGET_LIST_SET_NAME));
        
        allowing(tadParameters).getQuarters();
        will(returnValue(String.valueOf(quarter)));

        allowing(targetSelectionCrud).retrieveTargetListSet(
            TARGET_LIST_SET_NAME);
        will(returnValue(targetListSet));

        allowing(tadParameters).getAssociatedLcTargetListSetName();
        will(returnValue(ASSOCIATED_LC_TARGET_LIST_SET_NAME));

        allowing(targetSelectionCrud).retrieveTargetListSet(
            ASSOCIATED_LC_TARGET_LIST_SET_NAME);
        will(returnValue(associatedLcTargetListSet));

        allowing(targetListSet).getType();
        will(returnValue(targetType));

        allowing(targetListSet).getState();
        will(returnValue(state));

        allowing(targetListSet).getSupplementalTls();
        will(returnValue(null));

        allowing(tadParameters).getSupplementalFor();
        will(returnValue(origTargetListSetName));

        allowing(targetSelectionCrud).retrieveTargetListSet(
            origTargetListSetName);
        will(returnValue(targetListSet));

        allowing(targetListSet).getTargetTable();
        will(returnValue(targetTable));

        allowing(associatedLcTargetListSet).getTargetTable();
        will(returnValue(associatedLcTargetTable));

        allowing(modOutUowTask).modOut();
        will(returnValue(MOD_OUT));

        allowing(targetCrud).retrieveObservedTargetsPlusRejected(targetTable,
            MOD_OUT.getCcdModule(), MOD_OUT.getCcdOutput(),
            CoaCommon.INCLUDE_NULL_APERTURES);
        will(returnValue(ImmutableList.of(observedTarget)));

        allowing(observedTarget).getKeplerId();
        will(returnValue(keplerId));

        allowing(targetCrud).retrieveObservedTargetsPlusRejected(targetTable,
            MOD_OUT.getCcdModule(), MOD_OUT.getCcdOutput());
        will(returnValue(ImmutableList.of(observedTarget)));

        allowing(targetCrud).retrieveObservedTargetsPlusRejected(
            associatedLcTargetTable, MOD_OUT.getCcdModule(),
            MOD_OUT.getCcdOutput());
        will(returnValue(ImmutableList.of(observedTarget)));

        allowing(observedTarget).isRejected();
        will(returnValue(REJECTED));

        allowing(observedTarget).getAperture();
        will(returnValue(null));

        allowing(apertureExisting).getOffsets();
        will(returnValue(offsets));

        allowing(apertureCreated).getOffsets();
        will(returnValue(offsets));

        allowing(pipelineTask).getParameters(
            PlannedSpacecraftConfigParameters.class);
        will(returnValue(plannedSpacecraftConfigParameters));

        allowing(pipelineTask).getParameters(CoaModuleParameters.class);
        will(returnValue(coaModuleParameters));

        allowing(targetListSet).getStart();
        will(returnValue(START));

        allowing(targetListSet).getEnd();
        will(returnValue(END));

        allowing(targetTable).getId();
        will(returnValue(TARGET_TABLE_DATABASE_ID));

        allowing(targetTable).getObservingSeason();
        will(returnValue(OBSERVING_SEASON));

        allowing(kicCrud).retrieveSkyGroupId(MOD_OUT.getCcdModule(),
            MOD_OUT.getCcdOutput(), OBSERVING_SEASON);
        will(returnValue(SKY_GROUP_ID));

        allowing(celestialObjectOperations).retrieveCelestialObjectParametersForSkyGroupId(
            SKY_GROUP_ID);
        will(returnValue(celestialObjectParametersList));

        allowing(characteristicCrud).retrieveCharacteristicType(
            CharacteristicType.RA);
        will(returnValue(characteristicTypeRa));

        allowing(characteristicCrud).retrieveCharacteristicType(
            CharacteristicType.DEC);
        will(returnValue(characteristicTypeDec));

        allowing(characteristicCrud).retrieveCharacteristicType(
            CharacteristicType.SOC_MAG);
        will(returnValue(characteristicTypeMagnitude));

        allowing(characteristicCrud).retrieveCharacteristics(
            characteristicTypeRa, SKY_GROUP_ID, quarter);
        will(returnValue(ImmutableList.of(characteristicRa)));

        allowing(characteristicCrud).retrieveCharacteristics(
            characteristicTypeDec, SKY_GROUP_ID, quarter);
        will(returnValue(ImmutableList.of(characteristicDec)));

        allowing(characteristicCrud).retrieveCharacteristics(
            characteristicTypeMagnitude, SKY_GROUP_ID, quarter);
        will(returnValue(ImmutableList.of(characteristicMagnitude)));

        allowing(characteristicRa).getKeplerId();
        will(returnValue(keplerId));

        allowing(characteristicDec).getKeplerId();
        will(returnValue(keplerId));

        allowing(characteristicMagnitude).getKeplerId();
        will(returnValue(keplerId));

        allowing(celestialObjectParameters).getKeplerId();
        will(returnValue(keplerId));

        allowing(characteristicRa).getValue();
        will(returnValue(RA));

        allowing(characteristicDec).getValue();
        will(returnValue(DEC));

        allowing(characteristicMagnitude).getValue();
        will(returnValue((double) MAGNITUDE));

        allowing(celestialObjectParameters).getRa();
        will(returnValue(celestialObjectParameterRa));

        allowing(celestialObjectParameters).getDec();
        will(returnValue(celestialObjectParameterDec));

        allowing(celestialObjectParameters).getKeplerMag();
        will(returnValue(celestialObjectParameterMagnitude));

        allowing(celestialObjectParameters).getEffectiveTemp();
        will(returnValue(celestialObjectParameterEffectiveTemp));

        allowing(celestialObjectParameterRa).getValue();
        will(returnValue(RA));

        allowing(celestialObjectParameterDec).getValue();
        will(returnValue(DEC));

        allowing(celestialObjectParameterMagnitude).getValue();
        will(returnValue(MAGNITUDE));

        allowing(celestialObjectParameterEffectiveTemp).getValue();
        will(returnValue((double) effectiveTemp));

        allowing(prfOperations).retrieveMostRecentPrfModel(
            MOD_OUT.getCcdModule(), MOD_OUT.getCcdOutput());
        will(returnValue(prfModel));

        allowing(prfModel).getBlob();
        will(returnValue(PRF_BLOB));

        allowing(raDec2PixOperations).retrieveRaDec2PixModel(START_MJD, END_MJD);
        will(returnValue(raDec2PixModel));

        allowing(readNoiseOperations).retrieveReadNoiseModel(START_MJD, END_MJD);
        will(returnValue(readNoiseModel));

        allowing(gainOperations).retrieveGainModel(START_MJD, END_MJD);
        will(returnValue(gainModel));

        allowing(saturationOperations).retrieveSaturationModel(START_MJD,
            MOD_OUT.getCcdModule(), MOD_OUT.getCcdOutput());
        will(returnValue(saturationModel));

        allowing(twoDBlackOperations).retrieveTwoDBlackModel(START_MJD,
            END_MJD, MOD_OUT.getCcdModule(), MOD_OUT.getCcdOutput());
        will(returnValue(twoDBlackModel));

        allowing(linearityOperations).retrieveLinearityModel(
            MOD_OUT.getCcdModule(), MOD_OUT.getCcdOutput(), START_MJD, END_MJD);
        will(returnValue(linearityModel));

        allowing(undershootOperations).retrieveUndershootModel(START_MJD,
            END_MJD);
        will(returnValue(undershootModel));

        allowing(flatFieldOperations).retrieveFlatFieldModel(START_MJD,
            END_MJD, MOD_OUT.getCcdModule(), MOD_OUT.getCcdOutput());
        will(returnValue(flatFieldModel));

        allowing(coaModuleParameters).isMotionPolynomialsEnabled();
        will(returnValue(MOTION_POLYNOMIALS_ENABLED));

        allowing(coaModuleParameters).isBackgroundPolynomialsEnabled();
        will(returnValue(BACKGROUND_POLYNOMIALS_ENABLED));

        allowing(logCrud).retrievePixelLog(CadenceType.LONG.intValue(),
            START_MJD, END_MJD);
        will(returnValue(ImmutableList.of(pixelLog)));

        allowing(pixelLog).getCadenceNumber();
        will(returnValue(CADENCE_NUMBER));

        allowing(blobOperations).retrieveMotionBlobFileSeries(
            MOD_OUT.getCcdModule(), MOD_OUT.getCcdOutput(), CADENCE_NUMBER,
            CADENCE_NUMBER);
        will(returnValue(blobSeries));

        allowing(blobOperations).retrieveBackgroundBlobFileSeries(
            MOD_OUT.getCcdModule(), MOD_OUT.getCcdOutput(), CADENCE_NUMBER,
            CADENCE_NUMBER);
        will(returnValue(blobSeries));

        allowing(blobSeries).blobIndices();
        will(returnValue(BLOB_INDICES));

        allowing(blobSeries).gapIndicators();
        will(returnValue(GAP_INDICATORS));

        allowing(blobSeries).blobFilenames();
        will(returnValue(BLOB_FILENAMES));

        allowing(blobSeries).startCadence();
        will(returnValue(CADENCE_NUMBER));

        allowing(blobSeries).endCadence();
        will(returnValue(CADENCE_NUMBER));

        allowing(optimalAperture).getOffsets();
        will(returnValue(ImmutableList.of(offsetFromModuleInterface)));

        allowing(optimalAperture).getReferenceRow();
        will(returnValue(REFERENCE_ROW));

        allowing(optimalAperture).getReferenceColumn();
        will(returnValue(REFERENCE_COLUMN));

        allowing(optimalAperture).getKeplerId();
        will(returnValue(keplerId));

        allowing(optimalAperture).getBadPixelCount();
        will(returnValue(BAD_PIXEL_COUNT));

        allowing(optimalAperture).getSignalToNoiseRatio();
        will(returnValue(SIGNAL_TO_NOISE_RATIO));

        allowing(optimalAperture).getCrowdingMetric();
        will(returnValue(CROWDING_METRIC));

        allowing(optimalAperture).getSkyCrowdingMetric();
        will(returnValue(SKY_CROWDING_METRIC));

        allowing(optimalAperture).getFluxFractionInAperture();
        will(returnValue(FLUX_FRACTION_IN_APERTURE));

        allowing(optimalAperture).getDistanceFromEdge();
        will(returnValue(DISTANCE_FROM_EDGE));

        allowing(optimalAperture).getSaturatedRowCount();
        will(returnValue(SATURATED_ROW_COUNT));

        allowing(optimalAperture).isApertureUpdatedWithPaCoa();
        will(returnValue(APERTURE_UPDATED_WITH_PACOA));

        allowing(targetCrud).retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
            targetTable, MOD_OUT.getCcdModule(), MOD_OUT.getCcdOutput(),
            CoaCommon.INCLUDE_NULL_APERTURES);
        will(returnValue(ImmutableList.of(observedTarget)));

        allowing(persistableFactory).create(CoaInputs.class);
        will(returnValue(coaInputs));

        allowing(coaInputs).getStartTime();
        will(returnValue(START_TIME));

        allowing(coaInputs).getDuration();
        will(returnValue(DURATION));

        allowing(persistableFactory).create(KicEntryData.class);
        will(returnValue(kicEntryData));

        allowing(kicEntryData).getKeplerId();
        will(returnValue(keplerId));
        
        allowing(kicEntryData).getRA();
        will(returnValue(RA));

        allowing(kicEntryData).getDec();
        will(returnValue(DEC));

        allowing(kicEntryData).getMagnitude();
        will(returnValue(MAGNITUDE));

        allowing(kicEntryData).getEffectiveTemp();
        will(returnValue(effectiveTemp));

        allowing(blobFileSeriesFactory).create();
        will(returnValue(blobFileSeries));

        allowing(blobFileSeriesFactory).create(blobSeries);
        will(returnValue(blobFileSeries));

        allowing(persistableFactory).create(CoaOutputs.class);
        will(returnValue(coaOutputs));

        allowing(coaOutputs).getOptimalApertures();
        will(returnValue(optimalApertures));

        allowing(coaOutputs).getCompleteOutputImage();
        will(returnValue(COMPLETE_OUTPUT_IMAGE));

        allowing(coaOutputs).getMinRow();
        will(returnValue(MIN_ROW));

        allowing(coaOutputs).getMaxRow();
        will(returnValue(MAX_ROW));

        allowing(coaOutputs).getMinCol();
        will(returnValue(MIN_COL));

        allowing(coaOutputs).getMaxCol();
        will(returnValue(MAX_COL));

        allowing(celestialObjectOperationsFactory).create(pipelineInstance,
            CoaCommon.EXCLUDE_CUSTOM_TARGETS);
        will(returnValue(celestialObjectOperations));

        allowing(distanceFromEdgeCalculator).getDistanceFromEdge(
            apertureExisting);
        will(returnValue(DISTANCE_FROM_EDGE));

        allowing(observedTarget).getBadPixelCount();
        will(returnValue(BAD_PIXEL_COUNT));

        allowing(observedTarget).getCrowdingMetric();
        will(returnValue(CROWDING_METRIC));

        allowing(observedTarget).isRejected();
        will(returnValue(REJECTED));

        allowing(observedTarget).getSignalToNoiseRatio();
        will(returnValue(SIGNAL_TO_NOISE_RATIO));

        allowing(observedTarget).getMagnitude();
        will(returnValue(MAGNITUDE));

        allowing(observedTarget).getFluxFractionInAperture();
        will(returnValue(FLUX_FRACTION_IN_APERTURE));

        allowing(observedTarget).getDistanceFromEdge();
        will(returnValue(DISTANCE_FROM_EDGE));

        allowing(observedTarget).getAperturePixelCount();
        will(returnValue(APERTURE_PIXEL_COUNT));

        allowing(observedTarget).getRa();
        will(returnValue(RA));

        allowing(observedTarget).getDec();
        will(returnValue(DEC));

        allowing(observedTarget).getMagnitude();
        will(returnValue(MAGNITUDE));

        allowing(observedTarget).getEffectiveTemp();
        will(returnValue(effectiveTemp));

        allowing(observedTarget).getSkyCrowdingMetric();
        will(returnValue(SKY_CROWDING_METRIC));

        allowing(observedTarget).getSaturatedRowCount();
        will(returnValue(SATURATED_ROW_COUNT));

        allowing(observedTarget).isPaCoaApertureUsed();
        will(returnValue(PA_COA_APERTURE_USED));

        allowing(apertureExisting).createCopy();
        will(returnValue(apertureCreated));

        allowing(associatedLcTargetListSet).getType();
        will(returnValue(TargetType.LONG_CADENCE));

        allowing(targetListSet).getName();
        will(returnValue(TARGET_LIST_SET_NAME));

        allowing(associatedLcTargetListSet).getName();
        will(returnValue(ASSOCIATED_LC_TARGET_LIST_SET_NAME));

        allowing(optimalAperture).toAperture(CoaCommon.USER_DEFINED);
        will(returnValue(apertureCreated));
    }

}
