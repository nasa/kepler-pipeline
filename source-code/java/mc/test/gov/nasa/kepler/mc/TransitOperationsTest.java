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

import java.util.Collections;
import java.util.List;
import java.util.Map;

import gov.nasa.kepler.hibernate.mc.EbTransitParameterModel;
import gov.nasa.kepler.hibernate.mc.TransitParameter;
import gov.nasa.kepler.hibernate.mc.TransitParameterModel;
import gov.nasa.kepler.mc.pi.ModelOperationsFactory;
import gov.nasa.kepler.pi.models.ModelOperations;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.ImmutableList;

import static org.junit.Assert.*;

/**
 * 
 * @author Sean McCauliff
 *
 */
@RunWith(JMock.class)
public class TransitOperationsTest {

    private Mockery mockery;
    @Before
    public void setup() {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
    }
    
    @Test
    public void testTransitOperations() {
        List<TransitParameter> transitParameters = 
            ImmutableList.of(new TransitParameter(1, "koi-666", "kepid", "1"),
                             new TransitParameter(2, "koi-777", "kepid", "2"));
        
        final TransitParameterModel transitModel = new TransitParameterModel(-1, transitParameters);
        
        List<TransitParameter> ebParameters = Collections.emptyList();
        final EbTransitParameterModel ebModel = new EbTransitParameterModel(-1, ebParameters);
        
        @SuppressWarnings("unchecked")
        final ModelOperations<TransitParameterModel> modelOps = 
            mockery.mock(ModelOperations.class, "transit");
        @SuppressWarnings("unchecked")
        final ModelOperations<EbTransitParameterModel> ebModelOps = 
            mockery.mock(ModelOperations.class, "eb");
        mockery.checking(new Expectations() {{
            oneOf(modelOps).retrieveModel();
            will(returnValue(transitModel));
            
            oneOf(ebModelOps).retrieveModel();
            will(returnValue(ebModel));
        }});
        
        
        TransitOperations transitOps = new TransitOperations() {
            @Override
            protected ModelOperations<TransitParameterModel> getTransitParameterModelOperations() {
                return modelOps;
            }

            @Override
            protected ModelOperations<EbTransitParameterModel> getEbTransitParameterModelOperations() {
                return ebModelOps;
            }
        };
        
        //KeplerId 2 should have an entry, we don't ask for 1 and so it should
        //not be present in the returned map and 3 should be un the map, but
        //have an empty list.
        List<Integer> keplerIds = ImmutableList.of(2, 3);
        Map<Integer, List<Transit>> keplerIdToTransits = transitOps.getTransits(keplerIds);
        List<Transit> expectedTransitList = 
            ImmutableList.of(new Transit(2, "koi-777", false, Double.NaN, Float.NaN, Float.NaN));
        assertEquals(expectedTransitList, keplerIdToTransits.get(2));
        assertEquals(2, keplerIdToTransits.size());
        assertEquals(Collections.emptyList(), keplerIdToTransits.get(3));
    }
}
