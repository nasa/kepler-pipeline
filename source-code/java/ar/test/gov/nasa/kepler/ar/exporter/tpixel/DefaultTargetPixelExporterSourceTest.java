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

package gov.nasa.kepler.ar.exporter.tpixel;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.ar.archive.DvaTargetSource;
import gov.nasa.kepler.ar.archive.TargetWcs;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.cal.BlackAlgorithm;
import gov.nasa.kepler.hibernate.cal.CalCrud;
import gov.nasa.kepler.hibernate.cal.CalProcessingCharacteristics;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.pa.CentroidPixel;
import gov.nasa.kepler.hibernate.pa.PaCrud;
import gov.nasa.kepler.hibernate.pa.TargetAperture;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.*;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tps.AbstractTpsDbResult;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;

/**
 * @author Sean McCauliff
 * 
 */
@RunWith(JMock.class)
public class DefaultTargetPixelExporterSourceTest {

    private static final int LONG_CADENCE = 100;
    private static final int SHORT_CADENCE = LONG_CADENCE * 30;
    private static final int CCD_MODULE = 3;
    private static final int CCD_OUTPUT = 1;
    private static final int START_KEPLER_ID = 1000;
    private static final int END_KEPLER_ID = Integer.MAX_VALUE;

    private Mockery mockery;
    private final Date generatedAt = new Date();

    @Before
    public void setUp() {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
    }

//    @Test
//    public void checkTargetApertures() {
//        CentroidPixel centroidPixel = new CentroidPixel(0, 0, true, false);
//
//        final TargetTable targetTable = new TargetTable(TargetType.LONG_CADENCE);
//        TargetAperture targetAperture = new TargetAperture.Builder(null,
//            targetTable, START_KEPLER_ID).ccdModule(CCD_MODULE)
//            .ccdOutput(CCD_OUTPUT)
//            .pixels(ImmutableList.of(centroidPixel))
//            .build();
//        final PaCrud paCrud = mockery.mock(PaCrud.class);
//        final List<TargetAperture> targetApertures = ImmutableList.of(targetAperture);
//
//        final List<Integer> keplerIds = ImmutableList.of(START_KEPLER_ID,
//            END_KEPLER_ID);
//
//        mockery.checking(new Expectations() {
//            {
//                one(paCrud).retrieveTargetApertures(targetTable, CCD_MODULE,
//                    CCD_OUTPUT, keplerIds);
//                will(returnValue(targetApertures));
//            }
//        });
//        
//        DefaultTargetPixelExporterSource source = 
//            new DefaultTargetPixelExporterSource(
//            null, null, null, null, null, null, targetTable, null, null, 
//             START_KEPLER_ID, END_KEPLER_ID, null, -1, null) {
//
//                @Override
//                public Set<String> excludeTargetsWithLabel() {
//                    return null;
//                }
//
//                @Override
//                public int compressionThresholdInPixels() {
//                    return 0;
//                }
//
//                @Override
//                public File exportDirectory() {
//                    return null;
//                }
//
//                @Override
//                public MjdToCadence mjdToCadence() {
//
//                    return null;
//                }
//
//                @Override
//                public TimestampSeries timestampSeries() {
//                    return null;
//                }
//
//                @Override
//                public int ccdModule() {
//                    return CCD_MODULE;
//                }
//
//                @Override
//                public int ccdOutput() {
//                    return CCD_OUTPUT;
//                }
//
//                @Override
//                public int startCadence() {
//                    return LONG_CADENCE;
//                }
//
//                @Override
//                public int endCadence() {
//                    return LONG_CADENCE + 1;
//                }
//
//                @Override
//                public List<? extends AbstractTpsDbResult> tpsDbResults() {
//                    return null;
//                }
//
//                @Override
//                public int dataReleaseNumber() {
//                    return 0;
//                }
//
//                @Override
//                public long pipelineTaskId() {
//                    return 0;
//                }
//
//                @Override
//                public int quarter() {
//                    return 0;
//                }
//
//                @Override
//                public String programName() {
//                    return null;
//                }
//                
//                @Override
//                public List<Integer> keplerIds() {
//                    return keplerIds;
//                }
//                
//                @Override
//                public CadenceType cadenceType() {
//                    return CadenceType.LONG;
//                }
//
//
//                @Override
//                public TimestampSeries longCadenceTimestampSeries() {
//                    return null;
//                }
//
//                @Override
//                public int longCadenceExternalTargetTableId() {
//                    return 0;
//                }
//
//                @Override
//                public MjdToCadence longCadenceMjdToCadence() {
//                    return null;
//                }
//                
//                @Override
//                public <T extends DvaTargetSource> Map<Integer, TargetWcs> wcsCoordinates(
//                    Collection<T> targets, Map<FsId, TimeSeries> allTimeSeries) {
//
//                    return null;
//                }
//                
//                @Override
//                public Date generatedAt() {
//                    return generatedAt;
//                }
//                
//                @Override
//                public String fileTimestamp() {
//                    return null;
//                }
//
//        };
//        
//        Map<Integer, TargetAperture> keplerIdToTargetAperture =
//            source.targetApertures();
//        
//        assertEquals(targetAperture, keplerIdToTargetAperture.get(START_KEPLER_ID));
//        assertEquals(Collections.EMPTY_LIST, keplerIdToTargetAperture.get(END_KEPLER_ID).getCentroidPixels());
//    }
    
    @Test
    public void checkConversionToLongCadence() {
      
        final List<Integer> keplerIds = ImmutableList.of(START_KEPLER_ID);
        
        final LogCrud logCrud = mockery.mock(LogCrud.class);
        final MjdToCadence mjdToCadence = mockery.mock(MjdToCadence.class);
        mockery.checking(new Expectations() {{
            one(logCrud).shortCadenceToLongCadence(SHORT_CADENCE,SHORT_CADENCE);
            will(returnValue(Pair.of(LONG_CADENCE, LONG_CADENCE)));
            one(mjdToCadence).cadenceType();
            will(returnValue(CadenceType.SHORT));
            }
        });
        
        final PipelineTask cal0Ptask = mockery.mock(PipelineTask.class, "cal ptask0");
        final PipelineTask cal1Ptask = mockery.mock(PipelineTask.class, "cal ptask1");
        
        final CalCrud calCrud = mockery.mock(CalCrud.class);
        final CalProcessingCharacteristics cal0 = new CalProcessingCharacteristics(SHORT_CADENCE, SHORT_CADENCE, CadenceType.SHORT, cal0Ptask, BlackAlgorithm.DYNABLACK, CCD_MODULE, CCD_OUTPUT);
        final CalProcessingCharacteristics cal1 = new CalProcessingCharacteristics(SHORT_CADENCE, SHORT_CADENCE, CadenceType.SHORT, cal1Ptask, BlackAlgorithm.EXP_1D_BLACK, CCD_MODULE, CCD_OUTPUT);
        mockery.checking(new Expectations() {{
           atLeast(1).of(calCrud).retrieveProcessingCharacteristics(CCD_MODULE, CCD_OUTPUT, SHORT_CADENCE, SHORT_CADENCE, CadenceType.SHORT);
           will(returnValue(ImmutableList.of(cal0, cal1)));
           
           atLeast(1).of(cal0Ptask).getId();
           will(returnValue(101L));
           
           atLeast(1).of(cal1Ptask).getId();
           will(returnValue(1L));
        }});
        
        final TargetTable targetTable = mockery.mock(TargetTable.class, "orig");
        final UnifiedObservedTarget okTarget = mockery.mock(UnifiedObservedTarget.class, "ok");

        final Map<Integer, UnifiedObservedTarget> allObservedTargets = 
            ImmutableMap.of(START_KEPLER_ID, okTarget);
        final TargetCrud targetCrud = mockery.mock(TargetCrud.class);
        final UnifiedObservedTargetCrud uTargetCrud = mockery.mock(UnifiedObservedTargetCrud.class);
        mockery.checking(new Expectations() {{
            
            atLeast(1).of(okTarget).getKeplerId();
            will(returnValue(START_KEPLER_ID));
            
            atLeast(1).of(uTargetCrud).retrieveUnifiedObservedTargets(targetTable, CCD_MODULE, CCD_OUTPUT, keplerIds);
            will(returnValue(allObservedTargets));
            
            //This should only get called once since it's return value is
            //memorized.
            one(uTargetCrud).retrieveKeplerIds(targetTable, CCD_MODULE, CCD_OUTPUT, START_KEPLER_ID, END_KEPLER_ID);
            will(returnValue(keplerIds));
            
            atLeast(1).of(okTarget).wasDroppedBySupplementalTad();
            will(returnValue(true));
            
            
        }});

        
        final AtomicInteger ccdModule = new AtomicInteger(CCD_MODULE);
        DefaultTargetPixelExporterSource source = 
            new DefaultTargetPixelExporterSource(
            null, null, targetCrud, null, null, null, targetTable, logCrud, null, 
            START_KEPLER_ID, END_KEPLER_ID, uTargetCrud, -1, calCrud) {

            @Override
            public TimestampSeries timestampSeries() {
                return null;
            }

            @Override
            public int startCadence() {
                return SHORT_CADENCE;
            }
            
            @Override
            public CadenceType cadenceType() {
                return CadenceType.SHORT;
            }

            @Override
            public int quarter() {
                return 0;
            }

            @Override
            public String programName() {
                return null;
            }

            @Override
            public long pipelineTaskId() {
                return 0;
            }

            @Override
            public MjdToCadence mjdToCadence() {
                return mjdToCadence;
            }

            @Override
            public File exportDirectory() {
                return null;
            }

            @Override
            public Set<String> excludeTargetsWithLabel() {
                return null;
            }

            @Override
            public int endCadence() {
                return SHORT_CADENCE;
            }

            @Override
            public int dataReleaseNumber() {
                return 0;
            }

            @Override
            public int compressionThresholdInPixels() {
                return 0;
            }

            @Override
            public int ccdOutput() {
                return CCD_OUTPUT;
            }

            @Override
            public int ccdModule() {
                return ccdModule.get();
            }

            
            @Override
            public <T extends DvaTargetSource> Map<Integer, TargetWcs> wcsCoordinates(
                Collection<T> targets, Map<FsId, TimeSeries> allTimeSeries) {

                return null;
            }
            
            @Override
            public List<? extends AbstractTpsDbResult> tpsDbResults() {
                return Collections.emptyList();
            }

            @Override
            public TimestampSeries longCadenceTimestampSeries() {
                return null;
            }

            @Override
            public int longCadenceExternalTargetTableId() {
                return 0;
            }

            @Override
            public MjdToCadence longCadenceMjdToCadence() {
                return null;
            }

            @Override
            public Date generatedAt() {
                return generatedAt;
            }

            @Override
            public String fileTimestamp() {
                return null;
            }
    
        };

        assertEquals(ImmutableList.of(okTarget.getKeplerId()), source.keplerIds());
        assertEquals(ImmutableList.of(okTarget), source.observedTargets());
        assertTrue(source.wasTargetDroppedBySupplementalTad(START_KEPLER_ID));
        
        assertEquals(LONG_CADENCE, source.cadenceToLongCadence(SHORT_CADENCE));
        assertEquals(BlackAlgorithm.DYNABLACK, source.blackAlgorithm());
    }
    
}
