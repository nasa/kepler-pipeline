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

package gov.nasa.kepler.cal;

import static com.google.common.collect.Lists.newArrayList;
import static gov.nasa.kepler.common.FcConstants.CCD_COLUMNS;
import static gov.nasa.kepler.common.FcConstants.CCD_ROWS;
import gov.nasa.kepler.cal.ffi.FakeConfigMap;
import gov.nasa.kepler.cal.ffi.FfiModOut;
import gov.nasa.kepler.cal.io.*;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.FfiType;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.common.pi.CalFfiModuleParameters;
import gov.nasa.kepler.fc.FlatFieldModel;
import gov.nasa.kepler.fc.LinearityModel;
import gov.nasa.kepler.fc.TwoDBlackModel;
import gov.nasa.kepler.fc.flatfield.FlatFieldOperations;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.linearity.LinearityOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fc.twodblack.TwoDBlackOperations;
import gov.nasa.kepler.fc.undershoot.UndershootOperations;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.StreamedBlobResult;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dr.ConfigMapCrud;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrail;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.QuarterToParameterValueMap;
import gov.nasa.kepler.mc.PouModuleParameters;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.kepler.pi.module.AlgorithmResults;
import gov.nasa.kepler.pi.module.InputsGroup;
import gov.nasa.kepler.pi.module.InputsHandler;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Random;
import org.apache.commons.io.FileUtils;
import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.integration.junit4.JUnit4Mockery;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.ImmutableList;

/**
 * @author Sean McCauliff
 * 
 */
@RunWith(JMock.class)
public class CalFfiPipelineModuleTest {

    private static final double DEFAULT_LINEARITY = 101.0; 
    
    private Mockery mockery = new JUnit4Mockery() {
        {
            setImposteriser(ClassImposteriser.INSTANCE);
        }
    };

    private final static int CCD_MODULE = 11;
    private final static int CCD_OUTPUT = 3;
    private final static double startMjd = -0.0104167;
    private final static double endMjd = 0.0;
    private final static double midMjd = (startMjd + endMjd) / 2.0;
    private final static String TIMESTAMP = "2008347160000";
    private final static long ORIGINATOR = 4223L;
    private final static long TASK_ID = 23432432432L;
    private final static int scConfigId = 1;
    private final static CadenceType cadenceType = CadenceType.LONG;
    private final static int cadenceNumber = 10;

    private String quarter = "3";
    private List<String> quartersList = newArrayList(quarter);

    private String value = "value";
    private List<String> values = newArrayList(value);

    private final File testRoot = new File(Filenames.BUILD_TEST,
        "CalFfiPipelineModuleTest.test");

    private final File ffiFile = new File(
        SocEnvVars.getLocalTestDataDir() + "/cal/unit-test",  TIMESTAMP + ":Orig:11:3");

    private final File calFfiInputs = new File(testRoot, "calffi-inputs-0.bin");

    private final File calImageFile = 
        new File(testRoot, TIMESTAMP + ":SocCal:11:3.fits");
    private final File calUncertFile = 
        new File(testRoot, TIMESTAMP + ":SocCalUncertaintes:11:3.fits");
    // private final File calUncertBlobFile = new File(testRoot, TIMESTAMP +
    // ":SocCalUncertaintiesBlob:11:3.bin");
    private final File calUncertBlobFileSrc =
        new File(testRoot, "uncert-blob-0.mat");

    @Before
    public void setUp() throws IOException {
        FileUtil.mkdirs(testRoot);
        FileUtils.writeStringToFile(calUncertBlobFileSrc, "Beware of the blob.");
    }

    @After
    public void cleanUp() throws Exception {
        FileUtil.removeAll(testRoot);
    }

    @Test
    public void calFfiPipelineModuleTest() throws Exception {
        CalFfiPipelineModule module = new CalFfiPipelineModule(); 
        
        GainOperations gainOps = mockery.mock(GainOperations.class);
        module.setGainOperations(gainOps);
        MockUtils.mockGainModel(mockery, gainOps, startMjd, endMjd);

        UndershootOperations undershootOps = mockery.mock(UndershootOperations.class);
        MockUtils.mockUndershootModel(mockery, undershootOps, startMjd, endMjd);
        module.setUndershootOperations(undershootOps);

        ReadNoiseOperations readNoiseOps = mockery.mock(ReadNoiseOperations.class);
        MockUtils.mockReadNoiseModel(mockery, readNoiseOps, startMjd, endMjd);
        module.setReadNoiseOperations(readNoiseOps);

        FlatFieldOperations ffOps = mockery.mock(FlatFieldOperations.class);
        createFlatFieldModel(ffOps);
        module.setFlatFieldOperations(ffOps);

        LinearityOperations linOps = mockery.mock(LinearityOperations.class);
        createLinearityModel(startMjd, endMjd, mockery, linOps, CCD_MODULE,
            CCD_OUTPUT);
        module.setLinearityOperations(linOps);

        TwoDBlackOperations blackOps = mockery.mock(TwoDBlackOperations.class);
        createTwoDBlackModel(blackOps);
        module.setTwoDBlackOperations(blackOps);

        FileStoreClient fsClient = createInputsFileStore();
        FileStoreClientFactory.setInstance(fsClient);

        DataAccountabilityTrailCrud daCrud = mockery.mock(DataAccountabilityTrailCrud.class);
        createDataAccountabilityExpectations(daCrud);
        module.setDaCrud(daCrud);

        ConfigMapCrud configCrud = mockery.mock(ConfigMapCrud.class);
        createConfigMapExpectations(configCrud);
        module.setConfigMapCrud(configCrud);

        final ModOutUowTask uow = new ModOutUowTask(CCD_MODULE, CCD_OUTPUT);
        final CalFfiModuleParameters calFfiParameters = 
            new CalFfiModuleParameters(TIMESTAMP);

        final CalModuleParameters calModuleParameters = new CalModuleParameters();
        calModuleParameters.setBlackAlgorithmQuarters(quarter);
        calModuleParameters.setBlackAlgorithm(value);
        
        final PouModuleParameters pou = new PouModuleParameters();
        final CalCosmicRayParameters cosmicRayParameters = new CalCosmicRayParameters();
        final CalHarmonicsIdentificationParameters harmonicsParameters = 
            new CalHarmonicsIdentificationParameters();
        final GapFillModuleParameters gapFillParameters = new GapFillModuleParameters();

        RollTimeOperations rollTimeOps = createRollTimeOperations();
        module.setRollTimeOps(rollTimeOps);
        
        LogCrud logCrud = createLogCrud();
        module.setLogCrud(logCrud);
        
        QuarterToParameterValueMap parameterValues = createParameterValues();
        module.setParameterValues(parameterValues);
        
        final PipelineTask task = mockery.mock(PipelineTask.class);

        mockery.checking(new Expectations() {{
            atLeast(1).of(task).getId();
            will(returnValue(TASK_ID));
            atLeast(1).of(task).uowTaskInstance();
            will(returnValue(uow));
            atLeast(1).of(task).getParameters(CalFfiModuleParameters.class);
            will(returnValue(calFfiParameters));
            atLeast(1).of(task).getParameters(PouModuleParameters.class);
            will(returnValue(pou));
            atLeast(1).of(task).getParameters(CalModuleParameters.class);
            will(returnValue(calModuleParameters));
            atLeast(1).of(task).getParameters(CalCosmicRayParameters.class);
            will(returnValue(cosmicRayParameters));
            atLeast(1).of(task).getParameters(CalHarmonicsIdentificationParameters.class);
            will(returnValue(harmonicsParameters));
            atLeast(1).of(task).getParameters(GapFillModuleParameters.class);
            will(returnValue(gapFillParameters));
        }});
        
        final FitsHeaderReader fitsHeaderReader = mockery.mock(FitsHeaderReader.class);
        module.setFitsHeaderReader(fitsHeaderReader);
        mockery.checking(new Expectations() {
            {
                atLeast(1).of(fitsHeaderReader)
                    .getCadenceTimes((FfiModOut) with(anything()));
                will(returnValue(new TimestampSeries(new double[] { startMjd },
                    new double[] { (startMjd + endMjd) / 2 },
                    new double[] { endMjd }, new boolean[] { false },
                    new boolean[] { false }, new int[] { 1 },
                    new boolean[] { false }, new boolean[] { false },
                    new boolean[] { false }, new boolean[] { true },
                    new boolean[] { false }, new boolean[] { false },
                    new boolean[] { false })));
            }
        });

        final InputsHandler inputsHandler = mockery.mock(InputsHandler.class);
        final InputsGroup inputsGroup  = mockery.mock(InputsGroup.class);
        
        mockery.checking(new Expectations() {{
            one(inputsHandler).createGroup();
            will(returnValue(inputsGroup));
            one(inputsGroup).add(0, 1);
            exactly(2).of(inputsGroup).addSubTaskInputs(with(aNonNull(CalInputs.class)));
        }});
        module.generateInputs(inputsHandler, task, testRoot);
        
        final CalOutputs frameOutputs = new CalOutputs();
        fillFfiOutputs(frameOutputs);
        AlgorithmResults collateralResults =
            new AlgorithmResults(null, null, null, null, null);
        final AlgorithmResults targetResults = 
            new AlgorithmResults(frameOutputs, testRoot, testRoot, testRoot, null);

        fsClient = createOutputsFileStore();
        FileStoreClientFactory.setInstance(fsClient);
        
        module.processOutputs(task, ImmutableList.of(collateralResults, targetResults).iterator());
    }
    
    private static void createLinearityModel(final double startMjd,
        final double endMjd, final Mockery mockery,
        final LinearityOperations linOps, final int ccdModule,
        final int ccdOutput) {

        double[] gains = new double[FcConstants.MODULE_OUTPUTS];
        double[] mjds = new double[2];
        double[][] constants = new double[2][];

        Arrays.fill(gains, DEFAULT_LINEARITY);

        mjds[0] = startMjd;
        constants[0] = gains;
        mjds[1] = endMjd;
        constants[1] = gains;

        final LinearityModel finalLinearityModel = new LinearityModel(mjds,
            constants);
        mockery.checking(new Expectations() {
            {
                one(linOps).retrieveLinearityModel(with(equal(ccdModule)),
                    with(equal(ccdOutput)), with(equal(startMjd)),
                    with(equal(endMjd)));
                will(returnValue(finalLinearityModel));
            }
        });
    }

    private void fillFfiOutputs(CalOutputs calOutputs)
        throws FileNotFoundException {
        List<CalOutputPixelTimeSeries> list = new ArrayList<CalOutputPixelTimeSeries>(
            CCD_ROWS * CCD_COLUMNS);

        final Random rand = new Random(89889);
        final double period = (Math.min(CCD_ROWS, CCD_COLUMNS) / 4.0) * Math.PI;
        final double maxValue = Integer.MAX_VALUE / 4.0;
        final double meanValue = maxValue / 4.0;
        for (int i = 0; i < CCD_ROWS; i++) {
            float rValue = (float) (Math.sin(i / period) * maxValue + meanValue);
            for (int j = 0; j < CCD_COLUMNS; j++) {
                float cValue = (float) (Math.sin(j / period) * maxValue + meanValue);
                float[] values = new float[] { (float) (cValue + rValue) };
                float[] uncertainties = new float[] { (float) rand.nextGaussian() };
                boolean[] gaps = new boolean[] { ((i % 7) == 0) };
                CalOutputPixelTimeSeries outputSeries = new CalOutputPixelTimeSeries(
                    i, j, values, uncertainties, gaps);
                list.add(outputSeries);
            }
        }

        calOutputs.setTargetAndBackgroundPixels(list);
        calOutputs.setUncertaintyBlobFileName(this.calUncertBlobFileSrc.getName());

    }

    private void createConfigMapExpectations(final ConfigMapCrud crud) {
        final FakeConfigMap config = new FakeConfigMap(scConfigId, startMjd);
        mockery.checking(new Expectations() {{
                one(crud).retrieveConfigMap(scConfigId);
                will(returnValue(config.toHibernate()));
            }
        });
    }

    private void createDataAccountabilityExpectations(
        final DataAccountabilityTrailCrud daCrud) {
        final DataAccountabilityTrail trail = 
            new DataAccountabilityTrail(TASK_ID);
        trail.addProducerTaskId(ORIGINATOR);

        mockery.checking(new Expectations() {
            {
                one(daCrud).create(trail);
            }
        });
    }

    private FileStoreClient createInputsFileStore() throws FileNotFoundException {
        final FileStoreClient fsClient = mockery.mock(FileStoreClient.class, "readInputs");
        
        final FileInputStream fin = new FileInputStream(this.ffiFile);
        final StreamedBlobResult blobResult = new StreamedBlobResult(
            ORIGINATOR, ffiFile.length(), fin);
        final FsId id = DrFsIdFactory.getSingleChannelFfiFile(TIMESTAMP,
            FfiType.ORIG, CCD_MODULE, CCD_OUTPUT);

        mockery.checking(new Expectations() {{
                one(fsClient).readBlobAsStream(id);
                will(returnValue(blobResult));
            }
        });
        
        return fsClient;
    }
    
    private FileStoreClient createOutputsFileStore() 
        throws FileNotFoundException {
        final FileStoreClient fsClient = mockery.mock(FileStoreClient.class, "storeOutputs");
        
        final FileInputStream fin = new FileInputStream(this.ffiFile);
        final StreamedBlobResult blobResult = new StreamedBlobResult(
            ORIGINATOR, ffiFile.length(), fin);
        final FsId srcId = DrFsIdFactory.getSingleChannelFfiFile(TIMESTAMP,
            FfiType.ORIG, CCD_MODULE, CCD_OUTPUT);


        final FsId imageFsId = CalFsIdFactory.getSingleChannelFfiFile(
            TIMESTAMP, FfiType.SOC_CAL, CCD_MODULE, CCD_OUTPUT);
        /**
         * TODO: When file store is fixed do this instead. final
         * FileOutputStream imageOut = new FileOutputStream(calImageFile);
         */
        final File imageFile = new File(testRoot, imageFsId.name());

        final FsId uncertFsId = CalFsIdFactory.getSingleChannelFfiFile(
            TIMESTAMP, FfiType.SOC_CAL_UNCERTAINTIES,
            CCD_MODULE, CCD_OUTPUT);
        final File uncertFile = new File(testRoot, uncertFsId.name());
        /**
         * TODO: When file store is fixed do this instead. final
         * FileOutputStream uncertOut = new FileOutputStream(calUncertFile);
         */

        final FsId blobFsId = CalFsIdFactory.getSingleChannelFfiFile(TIMESTAMP,
            FfiType.SOC_CAL_UNCERTAINTIES_BLOB, CCD_MODULE,
            CCD_OUTPUT);

        mockery.checking(new Expectations() {{
            one(fsClient).readBlobAsStream(srcId);
            will(returnValue(blobResult));
            
            one(fsClient).writeBlob(with(equal(imageFsId)),
                with(equal(TASK_ID)), with(equal(imageFile)));
            // will(returnValue(imageOut));

            one(fsClient).writeBlob(with(equal(uncertFsId)),
                with(equal(TASK_ID)), with(equal(uncertFile)));
            // will(returnValue(uncertOut));

            one(fsClient).writeBlob(with(equal(blobFsId)),
                with(equal(TASK_ID)), with(equal(calUncertBlobFileSrc)));

        }});
        
        return fsClient;
    }

    private RollTimeOperations createRollTimeOperations() {
        final RollTimeOperations rollTimeOps = mockery.mock(RollTimeOperations.class);
        mockery.checking(new Expectations() {{
            one(rollTimeOps).mjdToSeason(startMjd);
            will(returnValue(88));
        }});
        return rollTimeOps;
    }
    
    private LogCrud createLogCrud() {
        final LogCrud logCrud = mockery.mock(LogCrud.class);
        mockery.checking(new Expectations() {{
            one(logCrud).retrieveCadenceClosestToMjd(cadenceType.intValue(), midMjd);
            will(returnValue(cadenceNumber));
        }});
        return logCrud;
    }
    
    private QuarterToParameterValueMap createParameterValues() {
        final QuarterToParameterValueMap parameterValues = mockery.mock(QuarterToParameterValueMap.class);
        mockery.checking(new Expectations() {{
            one(parameterValues).getValue(quartersList, values, cadenceType, cadenceNumber, cadenceNumber);
            will(returnValue(value));
        }});
        return parameterValues;
    }
    
    private void createTwoDBlackModel(final TwoDBlackOperations blackOps) {
        final Random rand = new Random(7);

        final float[][][] blacks = new float[1][CCD_ROWS][CCD_COLUMNS];
        final float[][][] uncertainty = new float[1][CCD_ROWS][CCD_COLUMNS];

        for (int i = 0; i < CCD_ROWS; i++) {
            for (int j = 0; j < CCD_COLUMNS; j++) {
                blacks[0][i][j] = (float) (rand.nextGaussian() * 0.4);
                uncertainty[0][i][j] = (float) rand.nextGaussian();
            }
        }

        final TwoDBlackModel blackModel = new TwoDBlackModel(
            new double[] { startMjd }, blacks, uncertainty);

            mockery.checking(new Expectations() {
                {
                    one(blackOps).retrieveTwoDBlackModel(startMjd, endMjd,
                        CCD_MODULE, CCD_OUTPUT);

                    will(returnValue(blackModel));
                }
            });
    }

    private void createFlatFieldModel(final FlatFieldOperations ffOps) {

        final Random rand = new Random(7);

        final float[][][] flats = new float[1][CCD_ROWS][CCD_COLUMNS];
        final float[][][] uncertainty = new float[1][CCD_ROWS][CCD_COLUMNS];

        for (int i = 0; i < CCD_ROWS; i++) {
            for (int j = 0; j < CCD_COLUMNS; j++) {
                flats[0][i][j] = (float) rand.nextGaussian();
                uncertainty[0][i][j] = (float) rand.nextGaussian();
            }
        }

        final FlatFieldModel model = new FlatFieldModel(
            new double[] { startMjd }, flats, uncertainty);

            mockery.checking(new Expectations() {
                {
                    one(ffOps).retrieveFlatFieldModel(startMjd, endMjd,
                        CCD_MODULE, CCD_OUTPUT);
                    will(returnValue(model));
                }
            });
    }

}
