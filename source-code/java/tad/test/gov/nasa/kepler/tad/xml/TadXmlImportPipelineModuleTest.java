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

package gov.nasa.kepler.tad.xml;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.fc.prf.PrfModel;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.hibernate.cm.Characteristic;
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
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.ModOut;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.ObservedTargetFactory;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.cm.CelestialObjectParameter;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.tad.KicEntryData;
import gov.nasa.kepler.mc.tad.OptimalAperture;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.kepler.tad.operations.TadXmlImportParameters;
import gov.nasa.kepler.tad.peer.AmaModuleParameters;
import gov.nasa.kepler.mc.tad.OptimalAperture;
import gov.nasa.kepler.tad.peer.PipelineModuleTest;
import gov.nasa.kepler.tad.peer.bpa.BpaPipelineModule;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.io.File;
import java.io.IOException;
import java.util.Date;
import java.util.List;
import java.util.Set;

import org.apache.xmlbeans.XmlException;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableSet;

public class TadXmlImportPipelineModuleTest extends JMockTest {

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
    private static final int TARGET_DEFS_PIXEL_COUNT = 31;
    private static final int EXTERNAL_ID = 32;

    private static final double START_MJD = new ModifiedJulianDate(
        START.getTime()).getMjd();
    private static final double END_MJD = new ModifiedJulianDate(END.getTime()).getMjd();
    private static final String TARGET_LIST_SET_NAME = "TARGET_LIST_SET_NAME";
    private String origTargetListSetName = "origTargetListSetName";
    private static final String ASSOCIATED_LC_TARGET_LIST_SET_NAME = "ASSOCIATED_LC_TARGET_LIST_SET_NAME";
    private static final boolean REJECTED = false;
    private static final boolean[] GAP_INDICATORS = new boolean[] { false };
    private static final Object[] BLOB_FILENAMES = new Object[] { "BLOB_FILENAME" };
    private static final int APERTURE_PIXEL_COUNT = 1;
    private static final List<TargetList> TARGET_LISTS = newArrayList();
    private static final Set<String> LABELS = ImmutableSet.of("LABEL");
    private static final State STATE = State.LOCKED;
    private static final File TAD_XML_ABS_PATH = new File("TAD_XML_ABS_PATH");
    private static final MaskType MASK_TYPE = MaskType.TARGET;
    private static final TargetType TARGET_TYPE = TargetType.LONG_CADENCE;
    private static final File MASK_FILE = new File("MASK_FILE");
    private static final File TARGET_FILE = new File("TARGET_FILE");

    private TargetListSet targetListSet = mock(TargetListSet.class);
    private PipelineInstance pipelineInstance = mock(PipelineInstance.class);
    private PipelineTask pipelineTask = mock(PipelineTask.class);
    private ModOutUowTask modOutUowTask = mock(ModOutUowTask.class);
    private TadParameters tadParameters = mock(TadParameters.class);
    private TargetListSet associatedLcTargetListSet = mock(TargetListSet.class,
        "associatedLcTargetListSet");
    private TargetTable targetTable = mock(TargetTable.class, "targetTable");
    private TargetTable backgroundTable = mock(TargetTable.class,
        "backgroundTable");
    private TargetTable backgroundTableOld = mock(TargetTable.class,
        "backgroundTableOld");
    private TargetTable associatedLcTargetTable = mock(TargetTable.class,
        "associatedLcTargetTable");
    private ObservedTarget observedTarget = mock(ObservedTarget.class);
    private List<ObservedTarget> observedTargets = ImmutableList.of(observedTarget);
    private Aperture apertureExisting = mock(Aperture.class, "apertureExisting");
    private Aperture apertureCreated = mock(Aperture.class, "apertureCreated");
    private List<Offset> offsets = BpaPipelineModule.theOfficialTwoByTwoOffsets();
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
    private MaskTable maskTable = mock(MaskTable.class, "maskTable");
    private final MaskTable maskTableOld = mock(MaskTable.class, "maskTableOld");
    private List<TargetListSet> oldTargetListSets = ImmutableList.of();
    private AmaModuleParameters amaModuleParameters = mock(AmaModuleParameters.class);
    private TargetList targetList = mock(TargetList.class);
    private PlannedTarget plannedTarget = mock(PlannedTarget.class);
    private List<PlannedTarget> plannedTargets = ImmutableList.of(plannedTarget);
    private SkyGroup skyGroup = mock(SkyGroup.class);
    private Mask mask = mock(Mask.class);
    private List<Mask> masks = ImmutableList.of(mask);
    private TadXmlImportParameters tadXmlImportParameters = mock(TadXmlImportParameters.class);
    private ModuleOutputListsParameters moduleOutputListsParameters = mock(ModuleOutputListsParameters.class);
    private ImportedMaskTable importedMaskTable = new ImportedMaskTable(
        maskTable, masks);
    private TargetDefinition targetDefinition = mock(TargetDefinition.class);
    private List<TargetDefinition> targetDefinitions = ImmutableList.of(targetDefinition);
    private List<TargetDefinition> observedTargetTargetDefinitions = newArrayList();
    private ImportedTargetTable importedTargetTable = new ImportedTargetTable(
        targetTable, targetDefinitions);
    private MaskReader maskReader = mock(MaskReader.class);
    private TargetReader targetReader = mock(TargetReader.class);
    private int indexInTable = masks.size() - 1;

    private TargetCrud targetCrud = mock(TargetCrud.class);
    private TargetSelectionCrud targetSelectionCrud = mock(TargetSelectionCrud.class);
    private ObservedTargetFactory observedTargetFactory = mock(ObservedTargetFactory.class);
    private MaskReaderFactory maskReaderFactory = mock(MaskReaderFactory.class);
    private TargetReaderFactory targetReaderFactory = mock(TargetReaderFactory.class);
    private TadXmlFileOperations tadXmlFileOperations = mock(TadXmlFileOperations.class);
    private RollTimeOperations rollTimeOperations = mock(RollTimeOperations.class);
    private DatabaseService databaseService = mock(DatabaseService.class);

    private TadXmlImportPipelineModule tadXmlImportPipelineModule = new TadXmlImportPipelineModule(
        targetCrud, targetSelectionCrud, maskReaderFactory,
        targetReaderFactory, observedTargetFactory, tadXmlFileOperations,
        rollTimeOperations, databaseService);

    @Before
    public void setUp() {
        TARGET_LISTS.clear();
        TARGET_LISTS.add(targetList);
    }

    @Test
    public void testFrameworkMethods() {
        PipelineModuleTest.testFrameworkMethods(tadXmlImportPipelineModule);
    }

    @Test
    public void testProcessTask() throws XmlException, IOException {
        setAllowances();

        oneOf(observedTarget).setPipelineTask(pipelineTask);

        oneOf(observedTarget).setTargetDefsPixelCount(
            TARGET_DEFS_PIXEL_COUNT + offsets.size());

        oneOf(targetCrud).createObservedTargets(observedTargets);

        oneOf(observedTarget).setTargetDefinitions(targetDefinitions);

        oneOf(targetListSet).setState(State.UPLINKED);

        setMaskTableExpectations();

        setMaskTableExpectations();

        setTargetTableExpectations();

        oneOf(targetListSet).setBackgroundTable(targetTable);

        setTargetTableExpectations();

        oneOf(observedTarget).setTargetTable(targetTable);

        oneOf(targetListSet).setTargetTable(targetTable);

        oneOf(targetCrud).delete(targetTable);

        oneOf(databaseService).flush();

        tadXmlImportPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    private void setTargetTableExpectations() {
        oneOf(targetTable).setObservingSeason(OBSERVING_SEASON);

        oneOf(targetTable).setMaskTable(maskTable);

        oneOf(targetTable).setFileName(TARGET_FILE.getName());

        oneOf(targetTable).setState(State.UPLINKED);

        oneOf(targetDefinition).setPipelineTask(pipelineTask);

        oneOf(targetCrud).createTargetTable(targetTable);

        oneOf(targetDefinition).setMask(mask);
    }

    private void setMaskTableExpectations() {
        oneOf(maskTable).setFileName(MASK_FILE.getName());

        oneOf(maskTable).setState(State.UPLINKED);

        oneOf(mask).setPipelineTask(pipelineTask);

        oneOf(targetCrud).createMaskTable(maskTable);

        oneOf(targetCrud).createMasks(masks);
    }

    private void setAllowances() throws XmlException, IOException {
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

        allowing(modOutUowTask).getCcdModule();
        will(returnValue(MOD_OUT.getCcdModule()));

        allowing(modOutUowTask).getCcdOutput();
        will(returnValue(MOD_OUT.getCcdOutput()));

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

        allowing(associatedLcTargetListSet).getType();
        will(returnValue(TargetType.LONG_CADENCE));

        allowing(associatedLcTargetListSet).getName();
        will(returnValue(ASSOCIATED_LC_TARGET_LIST_SET_NAME));

        allowing(targetSelectionCrud).retrieveTargetListSets(maskTableOld);
        will(returnValue(oldTargetListSets));

        allowing(targetCrud).retrieveObservedTargetsPlusRejected(targetTable);
        will(returnValue(ImmutableList.of()));

        allowing(pipelineTask).getParameters(AmaModuleParameters.class);
        will(returnValue(amaModuleParameters));

        allowing(targetSelectionCrud).retrievePlannedTargets(targetList);
        will(returnValue(plannedTargets));

        allowing(plannedTarget).getKeplerId();
        will(returnValue(keplerId));

        allowing(plannedTarget).getLabels();
        will(returnValue(LABELS));

        allowing(plannedTarget).getAperture();
        will(returnValue(apertureExisting));

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

        allowing(targetListSet).getType();
        will(returnValue(targetType));

        allowing(targetListSet).getState();
        will(returnValue(STATE));

        allowing(targetListSet).getBackgroundTable();
        will(returnValue(backgroundTableOld));

        allowing(backgroundTable).getMaskTable();
        will(returnValue(maskTable));

        allowing(targetListSet).getTargetTable();
        will(returnValue(targetTable));

        allowing(targetListSet).getStart();
        will(returnValue(START));

        allowing(targetListSet).getEnd();
        will(returnValue(END));

        allowing(backgroundTableOld).getMaskTable();
        will(returnValue(maskTableOld));

        allowing(pipelineTask).getParameters(TadXmlImportParameters.class);
        will(returnValue(tadXmlImportParameters));

        allowing(pipelineTask).getParameters(ModuleOutputListsParameters.class);
        will(returnValue(moduleOutputListsParameters));

        allowing(tadXmlImportParameters).getTadXmlAbsPath();
        will(returnValue(TAD_XML_ABS_PATH.getName()));

        allowing(maskReaderFactory).create(MASK_FILE);
        will(returnValue(maskReader));

        allowing(maskReader).read();
        will(returnValue(importedMaskTable));

        allowing(tadXmlFileOperations).getFile(TAD_XML_ABS_PATH,
            MaskType.TARGET.shortName(), targetListSet);
        will(returnValue(MASK_FILE));

        allowing(tadXmlFileOperations).getFile(TAD_XML_ABS_PATH,
            MaskType.BACKGROUND.shortName(), targetListSet);
        will(returnValue(MASK_FILE));

        allowing(targetDefinition).getModOut();
        will(returnValue(MOD_OUT));

        allowing(moduleOutputListsParameters).included(MOD_OUT.getCcdModule(),
            MOD_OUT.getCcdOutput());
        will(returnValue(true));

        allowing(targetDefinition).getMask();
        will(returnValue(mask));

        allowing(mask).getOffsets();
        will(returnValue(offsets));

        allowing(observedTargetFactory).create(backgroundTable, MOD_OUT,
            TargetManagementConstants.INVALID_KEPLER_ID);
        will(returnValue(observedTarget));

        allowing(observedTarget).getTargetDefinitions();
        will(returnValue(observedTargetTargetDefinitions));

        allowing(observedTarget).getTargetDefsPixelCount();
        will(returnValue(TARGET_DEFS_PIXEL_COUNT));

        allowing(targetCrud).retrieveObservedTargets(targetTable,
            TadXmlImportPipelineModule.INCLUDE_NULL_APERTURES);
        will(returnValue(observedTargets));

        allowing(targetDefinition).getKeplerId();
        will(returnValue(keplerId));

        allowing(maskTable).getExternalId();
        will(returnValue(EXTERNAL_ID));

        allowing(maskTable).getType();
        will(returnValue(MASK_TYPE));

        allowing(targetCrud).retrieveUplinkedMaskTable(EXTERNAL_ID, MASK_TYPE);
        will(returnValue(null));

        allowing(tadXmlFileOperations).getFile(TAD_XML_ABS_PATH,
            TargetType.BACKGROUND.shortName(), targetListSet);
        will(returnValue(TARGET_FILE));

        allowing(targetReaderFactory).create(TARGET_FILE);
        will(returnValue(targetReader));

        allowing(targetReader).read();
        will(returnValue(importedTargetTable));

        allowing(targetTable).getExternalId();
        will(returnValue(EXTERNAL_ID));

        allowing(targetTable).getType();
        will(returnValue(TARGET_TYPE));

        allowing(targetCrud).retrieveUplinkedTargetTable(EXTERNAL_ID,
            TARGET_TYPE);
        will(returnValue(null));

        allowing(targetTable).getPlannedStartTime();
        will(returnValue(START));

        allowing(targetTable).getPlannedEndTime();
        will(returnValue(END));

        allowing(rollTimeOperations).mjdToSeason(START_MJD);
        will(returnValue(OBSERVING_SEASON));

        allowing(rollTimeOperations).mjdToSeason(END_MJD);
        will(returnValue(OBSERVING_SEASON));

        allowing(observedTargetFactory).create(targetTable, MOD_OUT,
            TargetManagementConstants.INVALID_KEPLER_ID);
        will(returnValue(observedTarget));

        allowing(tadXmlFileOperations).getFile(TAD_XML_ABS_PATH,
            TARGET_TYPE.shortName(), targetListSet);
        will(returnValue(TARGET_FILE));

        allowing(mask).getIndexInTable();
        will(returnValue(indexInTable));
    }

}
