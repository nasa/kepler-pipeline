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
import static gov.nasa.kepler.cal.DataPresentEnum.*;

import gov.nasa.kepler.cal.ffi.FfiModOut;
import gov.nasa.kepler.cal.io.CalInputPixelTimeSeries;
import gov.nasa.kepler.cal.io.CalInputs;
import gov.nasa.kepler.cal.io.CalInputsFactory;
import gov.nasa.kepler.cal.io.CalModuleParameters;
import gov.nasa.kepler.cal.io.CommonParameters;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.mc.FitsImage;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;

import java.util.*;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;

/**
 * 
 * @author Sean McCauliff
 *
 */
@RunWith(JMock.class)
public class TargetAndBackgoundWorkParticleTest {

    private Mockery mockery;
    private final int startCadence = 200;
    private final int endCadence = 300;
    private final long originator = 242343423L;
    private final int totalInvocations = 2;
    private final int invocationNumber = 1;
    
    private List<CalInputPixelTimeSeries> calInputPixelTimeSeries;
    
    @Before
    public void setup() {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
    }
    
    @Test
    public void targetAndBackgroundWorkParticle() throws Exception {
        FsId pixelId = new FsId("/targetpixel/0");
        List<FsId> pixelFsIds = ImmutableList.of(pixelId);
        Map<FsId, Pixel> fsIdToPixel = ImmutableMap.of(pixelId, new Pixel(1, 2), 
            new FsId("/dont/use/me"), new Pixel(1212232, 232323));
        
        CommonParameters commonParameters = createCommonParameters();
        final FileStoreClient fsClient = createFileStoreClient(pixelFsIds, fsIdToPixel);
        final CalInputsFactory calInputsFactory = createCalInputsFactory(commonParameters);
        final CollateralWorkParticle collateralWorkParticle = mockery.mock(CollateralWorkParticle.class);
        mockery.checking(new Expectations() {{ 
            one(collateralWorkParticle).hasData();
            will(returnValue(DataPresent));
        }});
        
        TargetAndBackgroundWorkParticle workParticle = 
            new TargetAndBackgroundWorkParticle(commonParameters,
                invocationNumber, totalInvocations,pixelFsIds, false, 1,
                fsIdToPixel, collateralWorkParticle) {
            @Override
            protected CalInputsFactory calInputsFactory() {
                return calInputsFactory;
            }
            
            @Override
            protected FileStoreClient fsClient() {
                return fsClient;
            }
        };
        
        assertEquals(DataMissing, workParticle.hasData());
        
        assertNotNull(workParticle.call());
        
        assertEquals(DataPresent, workParticle.hasData());
        
    }
    
    private CalInputsFactory createCalInputsFactory(final CommonParameters commonParameters) {
        final CalInputsFactory calInputsFactory = mockery.mock(CalInputsFactory.class);
        final CalInputs calInputs = mockery.mock(CalInputs.class);
        final FitsImage fitsImage = 
            commonParameters.ffiModOut().get(0).toFitsImage(new int[] { 1 });
        mockery.checking(new Expectations() {{
            one(calInputsFactory).createTargetAndBackground(commonParameters, 
                invocationNumber, totalInvocations, calInputPixelTimeSeries,
                Collections.singletonList(fitsImage),
                DataPresent);
            will(returnValue(calInputs));
            one(calInputs).setLastCall(false);
            one(calInputs).setTotalPixels(calInputPixelTimeSeries.size());
        }});
        
        return calInputsFactory;
    }
    private FileStoreClient createFileStoreClient(final List<FsId> fsIds,
        final Map<FsId, Pixel> fsIdToPixel) {
        final FileStoreClient fsClient = mockery.mock(FileStoreClient.class);
        
        int[] data = new int[endCadence - startCadence + 1];
        boolean[] gaps = new boolean[endCadence - startCadence + 1];
        final Map<FsId, TimeSeries> rv = Maps.newHashMap();
        calInputPixelTimeSeries = Lists.newArrayListWithCapacity(fsIds.size());
        for (FsId id : fsIds) {
            Pixel px = fsIdToPixel.get(id);
            rv.put(id, new IntTimeSeries(id, data, startCadence, endCadence, gaps, originator));
            calInputPixelTimeSeries.add(new CalInputPixelTimeSeries(px.getRow(), px.getColumn(), data, gaps));
        }
        mockery.checking(new Expectations() {{
            one(fsClient).readTimeSeries(fsIds, startCadence, endCadence, false);
            will(returnValue(rv));
        }});
        return fsClient;
    }

    private CommonParameters createCommonParameters() {
        final CommonParameters commonParameters = mockery.mock(CommonParameters.class);
        final boolean[] isFinePt = new boolean[endCadence - startCadence + 1];
        Arrays.fill(isFinePt, true);
        final TimestampSeries cadenceTimes =
            new TimestampSeries(null, null, null, null, null, null, null,
                null, null, isFinePt, null, null, null, null);
        final FfiModOut ffiModOut = new FfiModOut(new int[10][10],
            new boolean[10][10], 0.0, 1.0, 2.0, -1L, null, null,
            -1, -1, 2, 1, "blah");
        final CalModuleParameters calModuleParameters = 
            mockery.mock(CalModuleParameters.class);
        mockery.checking(new Expectations() {{
            atLeast(1).of(calModuleParameters).isEnableCoarsePointProcessing();
            will(returnValue(false));
            atLeast(1).of(commonParameters).startCadence();
            will(returnValue(startCadence));
            atLeast(1).of(commonParameters).endCadence();
            will(returnValue(endCadence));
            allowing(commonParameters).cadenceTimes();
            will(returnValue(cadenceTimes));
            allowing(commonParameters).ffiModOut();
            will(returnValue(Collections.singletonList(ffiModOut)));
            atLeast(1).of(commonParameters).moduleParametersStruct();
            will(returnValue(calModuleParameters));
        }});
        return commonParameters;
    }
}
