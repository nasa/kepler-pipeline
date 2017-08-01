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

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.cal.ffi.FfiModOut;
import gov.nasa.kepler.cal.ffi.FfiReader;
import gov.nasa.kepler.cal.io.CalCosmicRayParameters;
import gov.nasa.kepler.cal.io.CalHarmonicsIdentificationParameters;
import gov.nasa.kepler.cal.io.CalModuleParameters;
import gov.nasa.kepler.cal.io.CommonParameters;
import gov.nasa.kepler.cal.io.HuffmanTable;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.fc.FlatFieldModel;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.LinearityModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.TwoDBlackModel;
import gov.nasa.kepler.fc.UndershootModel;
import gov.nasa.kepler.fc.flatfield.FlatFieldOperations;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.linearity.LinearityOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fc.twodblack.TwoDBlackOperations;
import gov.nasa.kepler.fc.undershoot.UndershootOperations;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.cm.PlannedTarget.TargetLabel;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.fc.RollTime;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.PouModuleParameters;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.gar.RequantTable;
import gov.nasa.kepler.tad.operations.TargetOperations;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Set;

import junit.framework.Assert;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;

@RunWith(JMock.class)
public class CommonParametersFactoryTest {

    private Mockery mockery;
    private final int startCadence = 1024;
    private final int endCadence = 1025;
    /** This is only used during short cadence testing. */
    private final int lcStartCadence = 60;
    /** This is only used during short cadence testing. */
    private final int lcEndCadence = 61;

    private final int ttableExternalId = 23;
    private double startMjd = 5555.0;
    private double endMjd = 5555.2;
    private final int ccdModule = 7;
    private final int ccdOutput = 1;

    private TargetTable lcTargetTable;

    @Before
    public void setup() {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
        lcTargetTable = null;
    }

    @Test
    public void generateCommonParametersLc() throws Exception {
        generateCommonParameters(CadenceType.LONG);
    }

    @Test
    public void generateCommonParametersSc() throws Exception {
        generateCommonParameters(CadenceType.SHORT);
    }

    @Test
    public void nodataCommonParameters() throws Exception {
        final int badStartCadence = 9;
        final int badEndCadence = 10;
        
        final CadenceType cadenceType = CadenceType.SHORT;
        final TargetTable ttable = mockery.mock(TargetTable.class, "short table");
        final TargetTable bkgTtable = null;
        final TargetCrud targetCrud = targetCrud(cadenceType, ttable, bkgTtable);
        mockery.checking(new Expectations() {
            {
                one(targetCrud).retrieveTargetTableLogs(
                    TargetType.SHORT_CADENCE, badStartCadence, badEndCadence);
                will(returnValue(Collections.EMPTY_LIST));
            }
        });
        
        final LogCrud logCrud = mockery.mock(LogCrud.class);
        mockery.checking(new Expectations() {{
            //The return value for this is not completely accurate with respect
            //to how retrieveClosestCadenceToCadence actually acts.
            one(logCrud).retrieveClosestCadenceToCadence(badStartCadence, CadenceType.SHORT);
            will(returnValue(Pair.of(startCadence, endCadence)));
            atLeast(1).of(logCrud)
                        .shortCadenceToLongCadence(startCadence, endCadence);
            will(returnValue(Pair.of(lcStartCadence, lcEndCadence)));
        }});
        
        final TimestampSeries cadenceTimes = MockUtils.mockCadenceTimes(null,
            null, cadenceType, startCadence, endCadence);
        final MjdToCadence mjdToCadence = mjdToCadence(cadenceTimes);
        final RollTimeOperations rollTimeOps = rollTimeOps(cadenceTimes);
        
        CommonParametersFactory factory = new CommonParametersFactory() {

            @Override
            protected TargetCrud getTargetCrud() {
                return targetCrud;
            }
            
            @Override
            protected LogCrud getLogCrud() {
                return logCrud;
            }
            
            @Override
            protected MjdToCadence createMjdToCadence(CadenceType cadenceType) {
                if (cadenceType == CadenceType.LONG) {
                    throw new IllegalStateException("Fix test.");
                }
                return mjdToCadence;
            }
            
            @Override
            protected int useEndCadence(int userEndCadence, TargetTableLog ttableLog) {
                return endCadence;
            }
            
            @Override
            protected RollTimeOperations getRollTimeOps() {
               return rollTimeOps;
            }
        };

        CommonParameters commonParameters =
            factory.create(CadenceType.SHORT, badStartCadence, badEndCadence, 2, 1, null);
        assertTrue(commonParameters.emptyParameters());
        
    }

    private void generateCommonParameters(CadenceType cadenceType)
        throws Exception {
        final TimestampSeries cadenceTimes = MockUtils.mockCadenceTimes(null,
            null, cadenceType, startCadence, endCadence);
        startMjd = cadenceTimes.startTimestamps[0];
        endMjd = cadenceTimes.endTimestamps[cadenceTimes.endTimestamps.length - 1];

        final TargetTable ttable = mockery.mock(TargetTable.class);
        final TargetTable bkgTtable = cadenceType == CadenceType.LONG ? mockery.mock(
            TargetTable.class, "bkg ttable") : null;
        final TargetCrud targetCrud = targetCrud(cadenceType, ttable, bkgTtable);
        final GainOperations gainOps = gainOps();
        final LinearityOperations linearityOps = linearityOps();
        final ReadNoiseOperations readNoiseOps = readNoiseOps();
        final TwoDBlackOperations twoDBlackOps = twoDBlackOps();
        final UndershootOperations undershootOps = undershootOps();
        final FlatFieldOperations flatFieldOps = flatFieldOps();
        final CompressionCrud compressionCrud = compressionCrud();
        final gov.nasa.kepler.mc.gar.RequantTable requantTable = mockery.mock(
            gov.nasa.kepler.mc.gar.RequantTable.class, "persistable requant");
        final HuffmanTable huffmanTable = mockery.mock(HuffmanTable.class,
            "cal huffman");
        final ConfigMapOperations configMapOps = configMapOps();
        @SuppressWarnings("unchecked")
        final BlobSeries<String> dynablackBlobSeries = mockery.mock(
            BlobSeries.class, "dyna str blobs");
        @SuppressWarnings("unchecked")
        final BlobSeries<String> oneDBlackBlobSeries = mockery.mock(
            BlobSeries.class, "1d black str blobs");
        final BlobFileSeries dynablackBlobs = mockery.mock(
            BlobFileSeries.class, "dynablack blobs");
        final BlobFileSeries oneDBlackBlobs = mockery.mock(
            BlobFileSeries.class, "1d black blobs");
        @SuppressWarnings("unchecked")
        final BlobSeries<String> smearBlobSeries = mockery.mock(
            BlobSeries.class, "smear blob series");
        final BlobFileSeries smearBlobs = mockery.mock(BlobFileSeries.class,
            "smear blobs");
        final BlobOperations blobOps = blobOps(cadenceType,
            dynablackBlobSeries, oneDBlackBlobSeries, smearBlobSeries);
        final LogCrud logCrud = logCrud(cadenceType);
        final MjdToCadence mjdToCadence = mjdToCadence(cadenceTimes);
        final TargetOperations targetOps = targetOps(cadenceType, targetCrud,
            ttable, bkgTtable);
        final RollTimeOperations rollTimeOps = rollTimeOps(cadenceTimes);
        final Pair<FfiFinder, FfiReader> ffiStuff = ffiStuff();

        CommonParametersFactory factory = new CommonParametersFactory() {

            @Override
            protected TargetCrud getTargetCrud() {
                return targetCrud;
            }

            @Override
            protected GainOperations getGainOps() {
                return gainOps;
            }

            @Override
            protected LinearityOperations getLinearityOps() {
                return linearityOps;
            }

            @Override
            protected ReadNoiseOperations getReadNoiseOps() {
                return readNoiseOps;
            }

            @Override
            protected TwoDBlackOperations getTwoDBlackOps() {
                return twoDBlackOps;
            }

            @Override
            protected UndershootOperations getUndershootOps() {
                return undershootOps;
            }

            @Override
            protected FlatFieldOperations getFlatFieldOps() {
                return flatFieldOps;
            }

            @Override
            protected CompressionCrud getCompressionCrud() {
                return compressionCrud;
            }

            @Override
            protected ConfigMapOperations getConfigMapOps() {
                return configMapOps;
            }

            @Override
            protected BlobOperations getBlobOps(File blobOutputDir) {
                return blobOps;
            }

            @Override
            protected LogCrud getLogCrud() {
                return logCrud;
            }

            @Override
            protected MjdToCadence createMjdToCadence(CadenceType cadenceType) {
                return mjdToCadence;
            }

            @Override
            protected RequantTable createPersistableRequantTable(
                gov.nasa.kepler.hibernate.gar.RequantTable hRequantTable,
                double startMjd) {
                return requantTable;
            }

            @Override
            protected HuffmanTable createPersistableHuffmanTable(
                gov.nasa.kepler.hibernate.gar.HuffmanTable hHuffmanTable,
                double startMjd) {
                return huffmanTable;
            }

            @Override
            protected BlobFileSeries createBlobFileSeries(
                BlobSeries<String> strBlobSeries) {
                if (strBlobSeries == dynablackBlobSeries) {
                    return dynablackBlobs;
                } else if (strBlobSeries == oneDBlackBlobSeries) {
                    return oneDBlackBlobs;
                } else if (strBlobSeries == smearBlobSeries) {
                    return smearBlobs;
                } else {
                    throw new IllegalArgumentException(strBlobSeries.toString());
                }
            }

            @Override
            protected TargetOperations getTargetOps() {
                return targetOps;
            }

            @Override
            protected RollTimeOperations getRollTimeOps() {
                return rollTimeOps;
            }

            @Override
            protected FfiFinder createFfiFinder() {
                return ffiStuff.left;
            }

            @Override
            protected FfiReader createFfiReader() {
                return ffiStuff.right;
            }
        };

        CalModuleParameters dynablackEnabled = new CalModuleParameters();
        dynablackEnabled.setBlackAlgorithm("dynablack");
        dynablackEnabled.setEnableFfiInform(true);

        factory.setParameters(dynablackEnabled, new CalCosmicRayParameters(),
            new PouModuleParameters(),
            new CalHarmonicsIdentificationParameters(),
            new GapFillModuleParameters());

        CommonParameters commonParameters = factory.create(cadenceType,
            startCadence, endCadence, ccdModule, ccdOutput, new File("blah"));
        assertFalse(commonParameters == null);

    }

    private Pair<FfiFinder, FfiReader> ffiStuff() throws Exception {
        final FfiFinder ffiFinder = mockery.mock(FfiFinder.class);
        final FfiReader ffiReader = mockery.mock(FfiReader.class);
        final FfiModOut ffiModOut = new FfiModOut(new int[10][10],
            new boolean[10][10], startMjd, (endMjd + startMjd) / 2.0, endMjd,
            -1, null, null, startCadence, -7, ccdModule, ccdOutput, "blah.fits");
        final FsId ffiId = new FsId("/blah/ffi/mod/out");
        mockery.checking(new Expectations() {
            {
                allowing(ffiFinder).find(startMjd, endMjd, ccdModule, ccdOutput);
                will(returnValue(Collections.singletonList(ffiId)));

                allowing(ffiReader).readFFiModOut(ffiId);
                will(returnValue(ffiModOut));
            }
        });
        return Pair.of(ffiFinder, ffiReader);
    }

    private RollTimeOperations rollTimeOps(final TimestampSeries cadenceTimes) {
        final RollTimeOperations rollTimeOps = mockery.mock(RollTimeOperations.class);
        mockery.checking(new Expectations() {{
                allowing(rollTimeOps).retrieveRollTime(endMjd);
                will(returnValue(new RollTime(endMjd, 3)));
                atLeast(1).of(rollTimeOps).mjdToQuarter(new double[] { cadenceTimes.startMjd(), cadenceTimes.endMjd()});
                will(returnValue(new int[] { 7, 7}));
            }
        });
        return rollTimeOps;
    }

    private TargetOperations targetOps(CadenceType cadenceType,
        final TargetCrud targetCrud, final TargetTable ttable,
        final TargetTable bkgTtable) {
        final TargetOperations targetOps = mockery.mock(TargetOperations.class);
        final Map<Integer, List<Pixel>> twodBlackTargetPixels = ImmutableMap.of(
            0, Collections.singletonList(new Pixel(0, 0)));
        final Map<Integer, List<Pixel>> ldeTargetPixels = ImmutableMap.of(1,
            Collections.singletonList(new Pixel(1, 1)));
        final Set<String> twoDBlackLabels = ImmutableSet.of(TargetLabel.PPA_2DBLACK.toString());
        final Set<String> ldeLabels = ImmutableSet.of(TargetLabel.PPA_LDE_UNDERSHOOT.toString());

        mockery.checking(new Expectations() {
            {
                atLeast(1).of(targetOps)
                    .getAperturePixelsForLabeledTargets(targetCrud, ttable,
                        ccdModule, ccdOutput, twoDBlackLabels);
                will(returnValue(twodBlackTargetPixels));

                atLeast(1).of(targetOps)
                    .getAperturePixelsForLabeledTargets(targetCrud, ttable,
                        ccdModule, ccdOutput, ldeLabels);
                will(returnValue(ldeTargetPixels));
            }
        });

        if (cadenceType == CadenceType.SHORT) {
            return targetOps;
        }

        // Should probably return a different set of pixels.
        mockery.checking(new Expectations() {
            {
                atLeast(1).of(targetOps)
                    .getAperturePixelsForLabeledTargets(targetCrud, bkgTtable,
                        ccdModule, ccdOutput, twoDBlackLabels);
                will(returnValue(twodBlackTargetPixels));

                atLeast(1).of(targetOps)
                    .getAperturePixelsForLabeledTargets(targetCrud, bkgTtable,
                        ccdModule, ccdOutput, ldeLabels);
                will(returnValue(ldeTargetPixels));
            }
        });

        return targetOps;
    }

    private MjdToCadence mjdToCadence(final TimestampSeries cadenceTimes) {
        final MjdToCadence mjdToCadence = mockery.mock(MjdToCadence.class);
        mockery.checking(new Expectations() {
            {
                atLeast(1).of(mjdToCadence).cadenceTimes(startCadence, endCadence, false);
                will(returnValue(cadenceTimes));
            }
        });

        return mjdToCadence;
    }

    private LogCrud logCrud(CadenceType cadenceType) {
        final LogCrud logCrud = mockery.mock(LogCrud.class);

        mockery.checking(new Expectations() {
            {
                atLeast(1).of(logCrud)
                    .retrieveActualObservationTimeForTargetTable(
                        lcTargetTable.getExternalId(), lcTargetTable.getType());
                will(returnValue(Pair.of(startMjd, endMjd)));
            }
        });

        if (cadenceType == CadenceType.LONG) {
            return logCrud;
        }
        mockery.checking(new Expectations() {
            {
                atLeast(1).of(logCrud)
                    .shortCadenceToLongCadence(startCadence, endCadence);
                will(returnValue(Pair.of(lcStartCadence, lcEndCadence)));
            }
        });

        return logCrud;
    }

    private BlobOperations blobOps(CadenceType cadenceType,
        final BlobSeries<String> dynablackBlobSeries,
        final BlobSeries<String> oneDBlackBlobSeries,
        final BlobSeries<String> smearBlobSeries) {

        final BlobOperations blobOps = mockery.mock(BlobOperations.class);

        if (cadenceType == CadenceType.LONG) {
            mockery.checking(new Expectations() {
                {
                    one(blobOps).retrieveDynamicTwoDBlackBlobFileSeries(
                        ccdModule, ccdOutput, startCadence, endCadence);
                    will(returnValue(dynablackBlobSeries));
                }
            });
        } else {
            mockery.checking(new Expectations() {
                {
                    one(blobOps).retrieveCalOneDBlackFitBlobFileSeries(
                        ccdModule, ccdOutput, CadenceType.LONG, lcStartCadence,
                        lcEndCadence);
                    will(returnValue(oneDBlackBlobSeries));

                    one(blobOps).retrieveDynamicTwoDBlackBlobFileSeries(
                        ccdModule, ccdOutput, lcStartCadence, lcEndCadence);
                    will(returnValue(dynablackBlobSeries));

                    one(blobOps).retrieveSmearBlobFileSeries(ccdModule,
                        ccdOutput, CadenceType.LONG, lcStartCadence,
                        lcEndCadence);
                    will(returnValue(smearBlobSeries));
                }
            });
        }
        return blobOps;

    }

    private ConfigMapOperations configMapOps() {
        final ConfigMapOperations configMapOps = mockery.mock(ConfigMapOperations.class);
        final ConfigMap configMap = mockery.mock(ConfigMap.class);

        mockery.checking(new Expectations() {
            {
                atLeast(1).of(configMapOps)
                    .retrieveConfigMaps(lcTargetTable);
                will(returnValue(Collections.singletonList(configMap)));
            }
        });
        return configMapOps;
    }

    private CompressionCrud compressionCrud() {
        final CompressionCrud compressionCrud = mockery.mock(CompressionCrud.class);
        final gov.nasa.kepler.hibernate.gar.RequantTable hRequantTable = mockery.mock(
            gov.nasa.kepler.hibernate.gar.RequantTable.class,
            "hibernate requant");
        final gov.nasa.kepler.hibernate.gar.HuffmanTable hHuffmanTable = mockery.mock(
            gov.nasa.kepler.hibernate.gar.HuffmanTable.class,
            "hibernate huffman");

        mockery.checking(new Expectations() {
            {
                atLeast(1).of(compressionCrud)
                    .retrieveRequantTables(startMjd, endMjd);
                will(returnValue(Collections.singletonList(hRequantTable)));

                atLeast(1).of(hRequantTable)
                    .getExternalId();
                will(returnValue(72));

                atLeast(1).of(compressionCrud)
                    .retrieveStartEndTimes(72);
                will(returnValue(Pair.of(startMjd, endMjd)));

                atLeast(1).of(compressionCrud)
                    .retrieveHuffmanTables(startMjd, endMjd);
                will(returnValue(Collections.singletonList(hHuffmanTable)));

                atLeast(1).of(hHuffmanTable)
                    .getExternalId();
                will(returnValue(73));

                atLeast(1).of(compressionCrud)
                    .retrieveStartEndTimes(73);
                will(returnValue(Pair.of(startMjd, endMjd)));

            }
        });

        return compressionCrud;

    }

    private FlatFieldOperations flatFieldOps() {
        final FlatFieldOperations flatFieldOps = mockery.mock(FlatFieldOperations.class);
        final FlatFieldModel flatFieldModel = mockery.mock(FlatFieldModel.class);
        mockery.checking(new Expectations() {
            {
                atLeast(1).of(flatFieldOps)
                    .retrieveFlatFieldModel(startMjd, endMjd, ccdModule,
                        ccdOutput);
                will(returnValue(flatFieldModel));
            }
        });
        return flatFieldOps;
    }

    private UndershootOperations undershootOps() {
        final UndershootOperations undershootOps = mockery.mock(UndershootOperations.class);
        final UndershootModel undershootModel = mockery.mock(UndershootModel.class);
        mockery.checking(new Expectations() {
            {
                atLeast(1).of(undershootOps)
                    .retrieveUndershootModel(startMjd, endMjd);
                will(returnValue(undershootModel));
            }
        });
        return undershootOps;
    }

    private LinearityOperations linearityOps() {
        final LinearityOperations linearityOps = mockery.mock(LinearityOperations.class);
        final LinearityModel linearityModel = mockery.mock(LinearityModel.class);
        mockery.checking(new Expectations() {
            {
                atLeast(1).of(linearityOps)
                    .retrieveLinearityModel(ccdModule, ccdOutput, startMjd,
                        endMjd);
                will(returnValue(linearityModel));
            }
        });
        return linearityOps;
    }

    private ReadNoiseOperations readNoiseOps() {
        final ReadNoiseOperations readNoiseOps = mockery.mock(ReadNoiseOperations.class);
        final ReadNoiseModel readNoiseModel = mockery.mock(ReadNoiseModel.class);
        mockery.checking(new Expectations() {
            {
                atLeast(1).of(readNoiseOps)
                    .retrieveReadNoiseModel(startMjd, endMjd);
                will(returnValue(readNoiseModel));
            }
        });
        return readNoiseOps;
    }

    private TwoDBlackOperations twoDBlackOps() {
        final TwoDBlackOperations twoDBlackOps = mockery.mock(TwoDBlackOperations.class);
        final TwoDBlackModel twoDBlackModel = mockery.mock(TwoDBlackModel.class);
        mockery.checking(new Expectations() {
            {
                atLeast(1).of(twoDBlackOps)
                    .retrieveTwoDBlackModel(startMjd, endMjd, ccdModule,
                        ccdOutput);
                will(returnValue(twoDBlackModel));
            }
        });
        return twoDBlackOps;
    }

    private GainOperations gainOps() {
        final GainOperations gainOps = mockery.mock(GainOperations.class);
        final GainModel gainModel = mockery.mock(GainModel.class);
        mockery.checking(new Expectations() {
            {
                atLeast(1).of(gainOps)
                    .retrieveGainModel(startMjd, endMjd);
                will(returnValue(gainModel));
            }
        });
        return gainOps;
    }

    private TargetCrud targetCrud(final CadenceType cadenceType,
        final TargetTable ttable, final TargetTable bkgTargetTable) {

        final TargetType ttableType = TargetType.valueOf(cadenceType);
        final TargetTableLog ttableLog = new TargetTableLog(ttable,
            startCadence, endCadence);
        final TargetCrud targetCrud = mockery.mock(TargetCrud.class);

        if (cadenceType == CadenceType.LONG) {
            lcTargetTable = ttable;
            final TargetTableLog bkgTtableLog = new TargetTableLog(
                bkgTargetTable, startCadence, endCadence);

            mockery.checking(new Expectations() {
                {
                    atLeast(1).of(targetCrud)
                        .retrieveTargetTableLogs(ttableType, startCadence,
                            endCadence);
                    will(returnValue(Collections.singletonList(ttableLog)));

                    atLeast(1).of(ttable)
                        .getObservingSeason();
                    will(returnValue(3));

                    atLeast(1).of(targetCrud)
                        .retrieveTargetTableLogs(TargetType.BACKGROUND,
                            startCadence, endCadence);
                    will(returnValue(Collections.singletonList(bkgTtableLog)));

                    allowing(ttable).getExternalId();
                    will(returnValue(ttableExternalId));

                    allowing(ttable).getType();
                    will(returnValue(ttableType));

                }
            });
        } else {
            final TargetTableLog bkgTtableLog = new TargetTableLog(
                bkgTargetTable, lcStartCadence, lcEndCadence);

            lcTargetTable = mockery.mock(TargetTable.class, "lcTargetTable");
            final TargetTableLog lcTargetTableLog = new TargetTableLog(
                lcTargetTable, lcStartCadence, lcEndCadence);
            mockery.checking(new Expectations() {
                {
                    allowing(lcTargetTable).getExternalId();
                    will(returnValue(9999));

                    allowing(lcTargetTable).getType();
                    will(returnValue(TargetType.LONG_CADENCE));

                    atLeast(1).of(targetCrud)
                        .retrieveTargetTableLogs(TargetType.LONG_CADENCE,
                            lcStartCadence, lcEndCadence);
                    will(returnValue(Collections.singletonList(lcTargetTableLog)));

                    atLeast(1).of(targetCrud)
                        .retrieveTargetTableLogs(TargetType.BACKGROUND,
                            lcStartCadence, lcEndCadence);
                    will(returnValue(Collections.singletonList(bkgTtableLog)));

                    atLeast(1).of(targetCrud)
                        .retrieveTargetTableLogs(ttableType, startCadence,
                            endCadence);
                    will(returnValue(Collections.singletonList(ttableLog)));

                    atLeast(1).of(ttable)
                        .getObservingSeason();
                    will(returnValue(3));
                }
            });
        }

        return targetCrud;
    }
}
