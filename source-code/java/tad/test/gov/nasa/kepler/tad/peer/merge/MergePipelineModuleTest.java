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

package gov.nasa.kepler.tad.peer.merge;

import static com.google.common.collect.Lists.newArrayList;
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.fc.prf.PrfModel;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.hibernate.cm.Characteristic;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTableFactory;
import gov.nasa.kepler.hibernate.tad.ModOut;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.ObservedTargetFactory;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableFactory;
import gov.nasa.kepler.mc.cm.CelestialObjectParameter;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.tad.KicEntryData;
import gov.nasa.kepler.mc.tad.OptimalAperture;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.kepler.tad.peer.AmaModuleParameters;
import gov.nasa.kepler.mc.tad.OptimalAperture;
import gov.nasa.kepler.tad.peer.PipelineModuleTest;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.util.Date;
import java.util.List;
import java.util.Set;

import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableSet;

public class MergePipelineModuleTest extends JMockTest {

    private static final ModOut MOD_OUT = ModOut.of(1, 2);
    private static final int KIC_KEPLER_ID = 3;
    private static final Date START = new Date(4000);
    private static final Date END = new Date(5000);
    private static final int OBSERVING_SEASON = 6;
    private static final int SKY_GROUP_ID = 7;
    private static final byte[] PRF_BLOB = new byte[] { 9 };
    private static final int CADENCE_NUMBER = 10;
    private static final int[] BLOB_INDICES = new int[] { 11 };
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
    private static final double RA = 27.27;
    private static final double DEC = 28.28;
    private static final float MAGNITUDE = 29.29F;
    private float effectiveTemp = 30.30F;

    private static final String TARGET_LIST_SET_NAME = "TARGET_LIST_SET_NAME";
    private String origTargetListSetName = "origTargetListSetName";
    private static final String ASSOCIATED_LC_TARGET_LIST_SET_NAME = "ASSOCIATED_LC_TARGET_LIST_SET_NAME";
    private static final boolean REJECTED = false;
    private static final double START_MJD = new ModifiedJulianDate(
        START.getTime()).getMjd();
    private static final double END_MJD = new ModifiedJulianDate(END.getTime()).getMjd();
    private static final boolean[] GAP_INDICATORS = new boolean[] { false };
    private static final Object[] BLOB_FILENAMES = new Object[] { "BLOB_FILENAME" };
    private static final int APERTURE_PIXEL_COUNT = 1;
    private static final State STATE = State.LOCKED;
    private static final List<TargetList> TARGET_LISTS = newArrayList();
    private static final Set<String> LABELS = ImmutableSet.of("LABEL");

    private TargetListSet targetListSet = new TargetListSet(
        TARGET_LIST_SET_NAME) {
        {
            setStart(START);
            setEnd(END);
            setTargetLists(TARGET_LISTS);
            setState(STATE);
        }
    };

    private PipelineInstance pipelineInstance = mock(PipelineInstance.class);
    private PipelineTask pipelineTask = mock(PipelineTask.class);
    private ModOutUowTask modOutUowTask = mock(ModOutUowTask.class);
    private TadParameters tadParameters = mock(TadParameters.class);
    private TargetListSet associatedLcTargetListSet = mock(TargetListSet.class,
        "associatedLcTargetListSet");
    private TargetTable targetTable = mock(TargetTable.class, "targetTable");
    private TargetTable associatedLcTargetTable = mock(TargetTable.class,
        "associatedLcTargetTable");
    private final TargetTable targetTableOld = null;
    private ObservedTarget observedTarget = mock(ObservedTarget.class);
    private Aperture apertureExisting = mock(Aperture.class, "apertureExisting");
    private Aperture apertureCreated = mock(Aperture.class, "apertureCreated");
    private Offset offset = offsetFromModuleInterface.toDatabaseOffset();
    private List<Offset> offsets = newArrayList(offset);
    private PlannedSpacecraftConfigParameters plannedSpacecraftConfigParameters = mock(PlannedSpacecraftConfigParameters.class);
    private CelestialObjectParameters celestialObjectParameters = mock(CelestialObjectParameters.class);
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
    private PixelLog pixelLog = mock(PixelLog.class);
    @SuppressWarnings("unchecked")
    private BlobSeries<String> blobSeries = mock(BlobSeries.class);
    private OptimalAperture optimalAperture = mock(OptimalAperture.class);
    private KicEntryData kicEntryData = mock(KicEntryData.class);
    private Integer keplerId = KIC_KEPLER_ID;
    private TargetType targetType = TargetType.LONG_CADENCE;
    private MaskTable maskTable = mock(MaskTable.class);
    private final MaskTable maskTableOld = null;
    private List<TargetListSet> oldTargetListSets = ImmutableList.of();
    private AmaModuleParameters amaModuleParameters = mock(AmaModuleParameters.class);
    private TadLabelValidator tadLabelValidator = mock(TadLabelValidator.class);
    private TargetList targetList = mock(TargetList.class);
    private PlannedTarget plannedTarget = mock(PlannedTarget.class);
    private List<PlannedTarget> plannedTargets = ImmutableList.of(plannedTarget);
    private SkyGroup skyGroup = mock(SkyGroup.class);
    private List<SkyGroup> skyGroups = ImmutableList.of(skyGroup);

    private TargetCrud targetCrud = mock(TargetCrud.class);
    private TargetSelectionCrud targetSelectionCrud = mock(TargetSelectionCrud.class);
    private KicCrud kicCrud = mock(KicCrud.class);
    private TargetTableFactory targetTableFactory = mock(TargetTableFactory.class);
    private MaskTableFactory maskTableFactory = mock(MaskTableFactory.class);
    private RollTimeOperations rollTimeOperations = mock(RollTimeOperations.class);
    private TadLabelValidatorFactory tadLabelValidatorFactory = mock(TadLabelValidatorFactory.class);
    private DatabaseService databaseService = mock(DatabaseService.class);
    private ObservedTargetFactory observedTargetFactory = mock(ObservedTargetFactory.class);

    private MergePipelineModule mergePipelineModule = new MergePipelineModule(
        targetCrud, targetSelectionCrud, kicCrud, targetTableFactory,
        maskTableFactory, rollTimeOperations, tadLabelValidatorFactory,
        databaseService, observedTargetFactory);

    @Before
    public void setUp() {
        TARGET_LISTS.clear();
        TARGET_LISTS.add(targetList);
    }

    @Test
    public void testFrameworkMethods() {
        PipelineModuleTest.testFrameworkMethods(mergePipelineModule);
    }

    @Test
    public void testProcessTask() {
        setAllowances();

        setExpectations();

        mergePipelineModule.processTask(pipelineInstance, pipelineTask);

        assertEquals(associatedLcTargetListSet,
            targetListSet.getAssociatedLcTls());
        assertEquals(targetTable, targetListSet.getTargetTable());
    }

    @Test
    public void testProcessTaskWithTargetOnTwoTargetLists() {
        TARGET_LISTS.add(targetList);
        setPerTargetListExpectations();

        setAllowances();

        setExpectations();

        mergePipelineModule.processTask(pipelineInstance, pipelineTask);

        assertEquals(associatedLcTargetListSet,
            targetListSet.getAssociatedLcTls());
        assertEquals(targetTable, targetListSet.getTargetTable());
    }

    @Test
    public void testProcessTaskWithTargetOnThreeTargetLists() {
        TARGET_LISTS.add(targetList);
        TARGET_LISTS.add(targetList);
        setPerTargetListExpectations();
        setPerTargetListExpectations();

        setAllowances();

        setExpectations();

        mergePipelineModule.processTask(pipelineInstance, pipelineTask);

        assertEquals(associatedLcTargetListSet,
            targetListSet.getAssociatedLcTls());
        assertEquals(targetTable, targetListSet.getTargetTable());
    }

    private void setExpectations() {
        oneOf(targetCrud).delete(targetTableOld);

        oneOf(targetCrud).createMaskTable(maskTable);

        oneOf(targetTable).setMaskTable(maskTableOld);

        oneOf(targetCrud).createTargetTable(targetTable);

        oneOf(targetTable).setMaskTable(maskTable);

        oneOf(targetCrud).delete(maskTableOld);

        oneOf(targetTable).setObservingSeason(OBSERVING_SEASON);

        oneOf(targetTable).setPlannedStartTime(START);

        oneOf(targetTable).setPlannedEndTime(END);

        oneOf(observedTarget).setModOut(MOD_OUT);

        oneOf(databaseService).evictAll(plannedTargets);

        oneOf(targetCrud).createObservedTargets(ImmutableSet.of(observedTarget));

        oneOf(observedTarget).setTargetTable(targetTable);

        oneOf(observedTarget).setPipelineTask(pipelineTask);

        oneOf(observedTarget).setLabels(LABELS);

        oneOf(observedTarget).setAperture(apertureCreated);

        oneOf(apertureCreated).setTargetTable(targetTable);

        oneOf(observedTarget).setAperturePixelCount(APERTURE_PIXEL_COUNT);

        setPerTargetListExpectations();
    }

    private void setPerTargetListExpectations() {
        oneOf(tadLabelValidator).validate(plannedTargets);
    }

    private void setAllowances() {
        allowing(pipelineTask).uowTaskInstance();
        will(returnValue(modOutUowTask));

        allowing(pipelineTask).getParameters(TadParameters.class);
        will(returnValue(tadParameters));

        allowing(tadParameters).getTargetListSetName();
        will(returnValue(TARGET_LIST_SET_NAME));

        allowing(targetSelectionCrud).retrieveTargetListSet(
            TARGET_LIST_SET_NAME);
        will(returnValue(targetListSet));

        allowing(tadParameters).getAssociatedLcTargetListSetName();
        will(returnValue(ASSOCIATED_LC_TARGET_LIST_SET_NAME));

        allowing(targetSelectionCrud).retrieveTargetListSet(
            ASSOCIATED_LC_TARGET_LIST_SET_NAME);
        will(returnValue(associatedLcTargetListSet));

        allowing(tadParameters).getSupplementalFor();
        will(returnValue(origTargetListSetName));

        allowing(targetSelectionCrud).retrieveTargetListSet(
            origTargetListSetName);
        will(returnValue(targetListSet));

        allowing(associatedLcTargetListSet).getTargetTable();
        will(returnValue(associatedLcTargetTable));

        allowing(modOutUowTask).modOut();
        will(returnValue(MOD_OUT));

        allowing(observedTarget).getKeplerId();
        will(returnValue(keplerId));

        allowing(targetCrud).retrieveObservedTargetsPlusRejected(targetTable,
            MOD_OUT.getCcdModule(), MOD_OUT.getCcdOutput());
        will(returnValue(ImmutableList.of()));

        allowing(targetCrud).retrieveObservedTargetsPlusRejected(
            associatedLcTargetTable, MOD_OUT.getCcdModule(),
            MOD_OUT.getCcdOutput());
        will(returnValue(ImmutableList.of()));

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

        allowing(targetTable).getObservingSeason();
        will(returnValue(OBSERVING_SEASON));

        allowing(kicCrud).retrieveSkyGroupId(MOD_OUT.getCcdModule(),
            MOD_OUT.getCcdOutput(), OBSERVING_SEASON);
        will(returnValue(SKY_GROUP_ID));

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

        allowing(prfModel).getBlob();
        will(returnValue(PRF_BLOB));

        allowing(pixelLog).getCadenceNumber();
        will(returnValue(CADENCE_NUMBER));

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

        allowing(kicEntryData).getRA();
        will(returnValue(RA));

        allowing(kicEntryData).getDec();
        will(returnValue(DEC));

        allowing(kicEntryData).getMagnitude();
        will(returnValue(MAGNITUDE));

        allowing(kicEntryData).getEffectiveTemp();
        will(returnValue(effectiveTemp));

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

        allowing(apertureExisting).createCopy();
        will(returnValue(apertureCreated));

        allowing(associatedLcTargetListSet).getType();
        will(returnValue(TargetType.LONG_CADENCE));

        allowing(associatedLcTargetListSet).getName();
        will(returnValue(ASSOCIATED_LC_TARGET_LIST_SET_NAME));

        allowing(targetTableFactory).create(targetType);
        will(returnValue(targetTable));

        allowing(maskTableFactory).create(MergePipelineModule.MASK_TYPE);
        will(returnValue(maskTable));

        allowing(targetSelectionCrud).retrieveTargetListSets(maskTableOld);
        will(returnValue(oldTargetListSets));

        allowing(rollTimeOperations).mjdToSeason(START_MJD);
        will(returnValue(OBSERVING_SEASON));

        allowing(rollTimeOperations).mjdToSeason(END_MJD);
        will(returnValue(OBSERVING_SEASON));

        allowing(targetCrud).retrieveObservedTargetsPlusRejected(targetTable);
        will(returnValue(ImmutableList.of()));

        allowing(pipelineTask).getParameters(AmaModuleParameters.class);
        will(returnValue(amaModuleParameters));

        allowing(tadLabelValidatorFactory).create(amaModuleParameters);
        will(returnValue(tadLabelValidator));

        allowing(targetSelectionCrud).retrievePlannedTargets(targetList);
        will(returnValue(plannedTargets));

        allowing(plannedTarget).getKeplerId();
        will(returnValue(keplerId));

        allowing(plannedTarget).getLabels();
        will(returnValue(LABELS));

        allowing(plannedTarget).getAperture();
        will(returnValue(apertureExisting));

        allowing(kicCrud).retrieveAllSkyGroups();
        will(returnValue(skyGroups));

        allowing(skyGroup).getObservingSeason();
        will(returnValue(OBSERVING_SEASON));

        allowing(skyGroup).getSkyGroupId();
        will(returnValue(SKY_GROUP_ID));

        allowing(plannedTarget).getSkyGroupId();
        will(returnValue(SKY_GROUP_ID));

        allowing(skyGroup).getCcdModule();
        will(returnValue(MOD_OUT.getCcdModule()));

        allowing(skyGroup).getCcdOutput();
        will(returnValue(MOD_OUT.getCcdOutput()));

        allowing(observedTargetFactory).create(KIC_KEPLER_ID);
        will(returnValue(observedTarget));
    }

}
