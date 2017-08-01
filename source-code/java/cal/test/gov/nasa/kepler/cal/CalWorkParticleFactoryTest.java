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

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Set;

import gov.nasa.kepler.cal.io.CommonParameters;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.CollateralTimeSeriesOperations;
import gov.nasa.kepler.mc.Pixel;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;

/**
 * @author Sean McCauliff
 *
 */
@RunWith(JMock.class)
public class CalWorkParticleFactoryTest {

    private Mockery mockery;
    
    @Before
    public void setup() {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
    }
    
    @Test
    public void testWorkParticleFactory() {
        final CadenceType cadenceType = CadenceType.LONG;
        final CommonParameters commonParameters = mockery.mock(CommonParameters.class);
        final CollateralTimeSeriesOperations collateralTimeSeriesOps = 
            createCollateralTimeSeriesOps(cadenceType);
        
        CalWorkParticleFactory calWorkParticleFactory = new CalWorkParticleFactory(commonParameters) {
            @Override
            protected  CollateralTimeSeriesOperations createCollateralTimeSeriesOps() {
                return collateralTimeSeriesOps;
            }
        };
        
        Pixel tnbPixel = new Pixel(0, 0, new FsId("/tnb/0"));
        Map<FsId, Pixel> pixelsByFsId = ImmutableMap.of(tnbPixel.getFsId(), tnbPixel);
        Set<Pixel> tnbPixels = Collections.singleton(tnbPixel);
        
        List<List<CalWorkParticle>> workParticles = 
            calWorkParticleFactory.create(tnbPixels, pixelsByFsId, 43343);
        assertEquals(3, workParticles.size());
        assertTrue(workParticles.get(0).get(0) instanceof CollateralWorkParticle);
        assertEquals(0, workParticles.get(1).size());
        assertEquals(1, workParticles.get(2).size());
        assertTrue(workParticles.get(2).get(0) instanceof TargetAndBackgroundWorkParticle);
        TargetAndBackgroundWorkParticle tnbWork = (TargetAndBackgroundWorkParticle) workParticles.get(2).get(0);
        assertTrue(tnbWork.isLast());
    }
    
    private CollateralTimeSeriesOperations createCollateralTimeSeriesOps(CadenceType cadenceType) {
        final CollateralTimeSeriesOperations collateralTimeSeriesOps = 
            mockery.mock(CollateralTimeSeriesOperations.class);
        
        final FsId maskedSmear = new FsId("/masked/smear/0");
        final FsId virtualSmear = new FsId("/virtual/smear/1");
        final FsId blackLevel = new FsId("/black/level/2");
        final FsId maskedBlack = new FsId("/masked/black/3");
        final FsId virtualBlack = new FsId("/virtual/black/4");
        
        mockery.checking(new Expectations() {{
            atLeast(1).of(collateralTimeSeriesOps).getMaskedSmearFsIds();
            will(returnValue(Collections.singleton(maskedSmear)));
            
            atLeast(1).of(collateralTimeSeriesOps).getVirtualSmearFsIds();
            will(returnValue(Collections.singleton(virtualSmear)));
            
            atLeast(1).of(collateralTimeSeriesOps).getBlackLevelFsIds();
            will(returnValue(Collections.singleton(blackLevel)));
        }});
        
        if (cadenceType == CadenceType.SHORT) {
            mockery.checking(new Expectations() {{
                atLeast(1).of(collateralTimeSeriesOps).getMaskedBlackFsIds();
                will(returnValue(Collections.singleton(maskedBlack)));
                
                atLeast(1).of(collateralTimeSeriesOps).getVirtualBlackFsIds();
                will(returnValue(Collections.singleton(virtualBlack)));
                
                atLeast(1).of(collateralTimeSeriesOps).getCollateralFsIds();
                will(returnValue(ImmutableSet.of(maskedSmear, virtualSmear, blackLevel, maskedBlack, virtualBlack)));
            }});
        } else {
            mockery.checking(new Expectations() {{
                atLeast(1).of(collateralTimeSeriesOps).getMaskedBlackFsIds();
                will(returnValue(Collections.EMPTY_SET));
                
                atLeast(1).of(collateralTimeSeriesOps).getVirtualBlackFsIds();
                will(returnValue(Collections.EMPTY_SET));
                
                atLeast(1).of(collateralTimeSeriesOps).getCollateralFsIds();
                will(returnValue(ImmutableSet.of(maskedSmear, virtualSmear, blackLevel)));
            }});
        }

        return collateralTimeSeriesOps;
    }
}
