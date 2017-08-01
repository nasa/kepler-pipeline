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

import static org.junit.Assert.*;
import static gov.nasa.kepler.common.CollateralType.*;
import static gov.nasa.kepler.mc.fs.DrFsIdFactory.getCollateralPixelTimeSeries;
import static gov.nasa.kepler.mc.fs.DrFsIdFactory.TimeSeriesType.*;
import static gov.nasa.kepler.cal.DataPresentEnum.*;
import static java.util.Collections.singletonList;


import java.util.*;

import gov.nasa.kepler.cal.ffi.FfiModOut;
import gov.nasa.kepler.cal.io.BlackTimeSeries;
import gov.nasa.kepler.cal.io.CalInputs;
import gov.nasa.kepler.cal.io.CalInputsFactory;
import gov.nasa.kepler.cal.io.CalModuleParameters;
import gov.nasa.kepler.cal.io.CommonParameters;
import gov.nasa.kepler.cal.io.SingleBlackTimeSeries;
import gov.nasa.kepler.cal.io.SmearTimeSeries;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.mc.FitsImage;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;


import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Maps;

/**
 * @author Sean McCauliff
 *
 */
@RunWith(JMock.class)
public class CollateralWorkParticleTest {

    private Mockery mockery;
    private final int startCadence = 3;
    private final int endCadence = 4;
    private final long originator = 8888L;
    private final int ccdModule = 2;
    private final int ccdOutput = 1;
    private final int totalPixels = 60000;
    private final int totalInvocations = 2;
    
    private Set<FsId> maskedBlackIds;
    private Set<FsId> virtualBlackIds;
    private Set<FsId> maskedSmearIds;
    private Set<FsId> virtualSmearIds;
    private Set<FsId> blackLevelIds;
    private Set<FsId> collateralIds;
    
    private List<SmearTimeSeries> maskedSmearTimeSeries;
    private List<SmearTimeSeries> virtualSmearTimeSeries;
    private List<BlackTimeSeries> blackLevelTimeSeries;
    private List<SingleBlackTimeSeries> maskedBlackTimeSeries;
    private List<SingleBlackTimeSeries> virtualBlackTimeSeries;
    
    private FsId maskedSmearId;
    private FsId virtualSmearId;
    private FsId blackLevelId;
    private FsId maskedBlackId;
    private FsId virtualBlackId;
    
    private Map<FsId, TimeSeries> fsTimeSeries;
    private BlobFileSeries oneDBlackBlobs;
    
    @Before
    public void setup() {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
    }
    
    @Test
    public void testCollateralWorkParticleLc() throws Exception {
        testCollateralWorkParticle(CadenceType.LONG);
    }
    
    @Test
    public void testCollateralWorkParticleSc() throws Exception {
        testCollateralWorkParticle(CadenceType.SHORT);
    }
    
    @Test
    public void testCollateralWorkParticleMissingData() throws Exception {
        CadenceType cadenceType = CadenceType.SHORT;
        
        final CommonParameters commonParameters = createCommonParameters(cadenceType, false);
        
        initFsIds(cadenceType);
        
        final FileStoreClient fsClient = createFileStoreClient(cadenceType, false);
        
        final CalInputsFactory inputsFactory = mockery.mock(CalInputsFactory.class);
        final List<FitsImage> noImages = Collections.emptyList();
        mockery.checking(new Expectations() {{
            one(inputsFactory).createShortCadenceCollateral(commonParameters,
                2, maskedSmearTimeSeries, virtualSmearTimeSeries, 
                blackLevelTimeSeries, maskedBlackTimeSeries,
                virtualBlackTimeSeries, noImages, DataMissing); 
        }});
        
        CollateralWorkParticle collateralWork = 
            new CollateralWorkParticle(commonParameters, 0, totalInvocations, maskedSmearIds,
                virtualSmearIds, blackLevelIds, maskedBlackIds, virtualBlackIds,
                collateralIds, totalPixels) {
            @Override
            protected PixelVerifier createPixelVerifier() {
                throw new UnsupportedOperationException();
            }
            
            
            @Override
            protected FileStoreClient fsClient() {
                return fsClient;
            }
            
            @Override
            protected CalInputsFactory calInputsFactory() {
                return inputsFactory;
            }
        };
        
        
        assertNotNull(collateralWork.call());
    }
    
    @Test
    public void testIsEmpty() {
        boolean[] gaps = new boolean[1024];
        Arrays.fill(gaps, true);
        gaps[44] = false;
        gaps[55] = false;
        boolean[] isFinePt = new boolean[1024];
        TimeSeries ts0 = new IntTimeSeries(new FsId("/blah/blah"), new int[1024], 11, 11+1024 - 1, gaps, 5);
        assertTrue(CalWorkParticle.isEmpty(ts0, isFinePt, false));
        assertFalse(CalWorkParticle.isEmpty(ts0, isFinePt, true));
        isFinePt[55] = true;
        assertFalse(CalWorkParticle.isEmpty(ts0, isFinePt, false));
        
    }
    
    private void testCollateralWorkParticle(CadenceType cadenceType) throws Exception {
        CommonParameters commonParameters = createCommonParameters(cadenceType, true);
        
        initFsIds(cadenceType);
        
        final FileStoreClient fsClient = createFileStoreClient(cadenceType, true);
        
        final PixelVerifier pixelVerifier = createPixelVerifier();
        
        final CalInputsFactory calInputsFactory = createCalInputsFactory(cadenceType, commonParameters);
        CollateralWorkParticle collateralWork = 
            new CollateralWorkParticle(commonParameters, 0, totalInvocations, maskedSmearIds,
                virtualSmearIds, blackLevelIds, maskedBlackIds, virtualBlackIds,
                collateralIds, totalPixels) {
            
            
            @Override
            protected PixelVerifier createPixelVerifier() {
                return pixelVerifier;
            }
            
            
            @Override
            protected FileStoreClient fsClient() {
                return fsClient;
            }
            
            @Override
            protected CalInputsFactory calInputsFactory() {
                return calInputsFactory;
            }
        };
        assertEquals(0, collateralWork.particleNumber());
        assertEquals(collateralIds.size(), collateralWork.nPixels());
        assertEquals(DataMissing, collateralWork.hasData());
        
        assertNotNull(collateralWork.call());
        
        assertEquals(DataPresent, collateralWork.hasData());
        assertEquals(1, collateralWork.producerTaskIds().size());
        long foundOriginator = collateralWork.producerTaskIds().iterator().next();
        assertEquals(originator, foundOriginator);
        
    }
    
    private CalInputsFactory createCalInputsFactory(CadenceType cadenceType,
        final CommonParameters commonParameters) {
        final CalInputsFactory calInputsFactory = mockery.mock(CalInputsFactory.class);
        final CalInputs calInputs = mockery.mock(CalInputs.class);
        
        FfiModOut ffiModOut = commonParameters.ffiModOut().get(0);
        
        final FitsImage fitsImage = ffiModOut.toFitsImage();
        if (cadenceType == CadenceType.LONG) {
            mockery.checking(new Expectations() {{
                one(calInputsFactory).createLongCadenceCollateral(commonParameters,
                    totalInvocations,
                    maskedSmearTimeSeries,  virtualSmearTimeSeries,
                    blackLevelTimeSeries, Collections.singletonList(fitsImage), DataPresent);
                will(returnValue(calInputs));
            }});
        } else { //SHORT
            mockery.checking(new Expectations() {{
                one(calInputsFactory).createShortCadenceCollateral(commonParameters,
                    totalInvocations,
                    maskedSmearTimeSeries, virtualSmearTimeSeries,
                    blackLevelTimeSeries, maskedBlackTimeSeries,
                    virtualBlackTimeSeries,
                    Collections.singletonList(fitsImage),
                    DataPresent);
                will(returnValue(calInputs));
                one(calInputs).setOneDBlackBlobs(oneDBlackBlobs);
            }});
        }
        
        mockery.checking(new Expectations() {{
            one(calInputs).setTotalPixels(totalPixels);
        }});
        return calInputsFactory;
    }
    
    private PixelVerifier createPixelVerifier() {
        final PixelVerifier pixelVerifier = mockery.mock(PixelVerifier.class);
        mockery.checking(new Expectations() {{
            one(pixelVerifier).verify(fsTimeSeries.values());
            will(returnValue(0));
        }});
        return pixelVerifier;
    }
    
    private void initFsIds(CadenceType cadenceType) {
        maskedSmearId = getCollateralPixelTimeSeries(ORIG, cadenceType,
            MASKED_SMEAR, ccdModule, ccdOutput, 0);
        virtualSmearId = getCollateralPixelTimeSeries(ORIG, cadenceType,
        VIRTUAL_SMEAR, ccdModule, ccdOutput, 1);
        blackLevelId =  getCollateralPixelTimeSeries(ORIG, cadenceType,
        BLACK_LEVEL, ccdModule, ccdOutput, 2);
        maskedSmearIds = Collections.singleton(maskedSmearId);
        virtualSmearIds = Collections.singleton(virtualSmearId);
        blackLevelIds = Collections.singleton(blackLevelId);
        if (cadenceType == CadenceType.SHORT) {
            virtualBlackId = getCollateralPixelTimeSeries(ORIG, cadenceType,
                BLACK_VIRTUAL, ccdModule, ccdOutput, 0);
            maskedBlackId = getCollateralPixelTimeSeries(ORIG, cadenceType,
                BLACK_MASKED, ccdModule, ccdOutput, 0);
            virtualBlackIds = Collections.singleton(virtualBlackId);
            maskedBlackIds = Collections.singleton(maskedBlackId);
        } else {
            virtualBlackId = null;
            maskedBlackId = null;
            maskedBlackIds = Collections.emptySet();
            virtualBlackIds = Collections.emptySet();
        }
        ImmutableSet.Builder<FsId> bldr = new ImmutableSet.Builder<FsId>();
        bldr.addAll(maskedSmearIds).addAll(virtualSmearIds).addAll(blackLevelIds).addAll(maskedBlackIds).addAll(virtualBlackIds);
        collateralIds = bldr.build();
        
    }

    
    @SuppressWarnings("unchecked")
    private FileStoreClient createFileStoreClient(CadenceType cadenceType, boolean hasData) {

        final FileStoreClient fsClient = mockery.mock(FileStoreClient.class);
        int[] data = new int[endCadence - startCadence + 1];
        boolean[] gaps = new boolean[data.length];
        if (!hasData) {
            Arrays.fill(gaps, true);
        }
        fsTimeSeries = Maps.newHashMap();
        for (FsId collateralId : collateralIds) {
            if (hasData) {
                fsTimeSeries.put(collateralId, new IntTimeSeries(collateralId, data, startCadence, endCadence, gaps, originator));
            } else {
                fsTimeSeries.put(collateralId, new IntTimeSeries(collateralId, data, startCadence, endCadence, Collections.EMPTY_LIST, Collections.EMPTY_LIST));
            }
        }
        
        maskedSmearTimeSeries = singletonList(new SmearTimeSeries(0 , data, gaps));
        virtualSmearTimeSeries = singletonList(new SmearTimeSeries(1, data, gaps));
        blackLevelTimeSeries = singletonList(new BlackTimeSeries(2, data, gaps));
        
        if (cadenceType == CadenceType.SHORT) {
            virtualBlackTimeSeries = singletonList(new SingleBlackTimeSeries(data, gaps));
            maskedBlackTimeSeries = singletonList(new SingleBlackTimeSeries(data, gaps));
        } else {
            virtualBlackTimeSeries = null;
            maskedBlackTimeSeries = null;
        }
        
        mockery.checking(new Expectations() {{
            one(fsClient).readTimeSeries(fsTimeSeries.keySet(), startCadence, endCadence, true);
            will(returnValue(fsTimeSeries));
        }});
        
        return fsClient;
    }
    
    private CommonParameters createCommonParameters(final CadenceType cadenceType, final boolean hasData) {
        boolean[] isFinePt = new boolean[endCadence - startCadence + 1];
        Arrays.fill(isFinePt, true);
        final TimestampSeries cadenceTimes = 
            new TimestampSeries(null, null, null, null, null, null, null,
                null, null, isFinePt, null, null, null);
        final FfiModOut ffiModOut = new FfiModOut(new int[10][10],
            new boolean[10][10], 0, 1, 2, -1, null, null, startCadence,
            -1, ccdModule, ccdOutput, "blah");
        
        final CommonParameters commonParameters = mockery.mock(CommonParameters.class);
        final CalModuleParameters calModuleParameters = mockery.mock(CalModuleParameters.class);
        mockery.checking(new Expectations() {{
            atLeast(1).of(commonParameters).ccdModule();
            will(returnValue(2));
            atLeast(1).of(commonParameters).ccdOutput();
            will(returnValue(1));
            atLeast(1).of(commonParameters).startCadence();
            will(returnValue(startCadence));
            atLeast(1).of(commonParameters).endCadence();
            will(returnValue(endCadence));
            atLeast(1).of(commonParameters).cadenceType();
            will(returnValue(cadenceType));
            atLeast(1).of(commonParameters).cadenceTimes();
            will(returnValue(cadenceTimes));
            allowing(commonParameters).ffiModOut();
            will(returnValue(Collections.singletonList(ffiModOut)));
            atLeast(1).of(commonParameters).moduleParametersStruct();
            will(returnValue(calModuleParameters));
            atLeast(1).of(calModuleParameters).isEnableCoarsePointProcessing();
            will(returnValue(false));
            atLeast(1).of(commonParameters).emptyParameters();
            will(returnValue(!hasData));
        }});
        
        if (cadenceType == CadenceType.SHORT && hasData) {
            oneDBlackBlobs = new BlobFileSeries();
            mockery.checking(new Expectations() {{
                one(commonParameters).oneDBlackBlobs();
                will(returnValue(oneDBlackBlobs));
            }});
        } else {
            oneDBlackBlobs = null;
        }
        return commonParameters;
    }
}
