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

package gov.nasa.kepler.tps;

import static org.junit.Assert.*;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.pdc.PdcCrud;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.mc.PdcProcessingCharacteristics;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;

/**
 * @author Sean McCauliff
 *
 */
@RunWith(JMock.class)
public class PdcProcessingCharacteristicsFactoryTest {

    private final List<TargetTableLog> quarters = 
        ImmutableList.of(new TargetTableLog(null, 0, 10),
        new TargetTableLog(null, 11, 20), new TargetTableLog(null, 21,30));
    
    private Mockery mockery;
    
    @Before
    public void setUp() {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
    }
    
    @Test
    public void createPdcDataProcessingCharacteristics() {
        final PdcCrud pdcCrud = mockery.mock(PdcCrud.class);
        final int keplerId= 345;
        final Collection<Integer> keplerIds = ImmutableList.of(keplerId);
        //flags are missing in the second quarter.
        final gov.nasa.kepler.hibernate.pdc.PdcProcessingCharacteristics dbChar1 = 
            new gov.nasa.kepler.hibernate.pdc.PdcProcessingCharacteristics();
        dbChar1.setKeplerId(keplerId);
        dbChar1.setNumDiscontinuitiesDetected(1);
        final gov.nasa.kepler.hibernate.pdc.PdcProcessingCharacteristics dbChar3 =
            new gov.nasa.kepler.hibernate.pdc.PdcProcessingCharacteristics();
        dbChar3.setKeplerId(keplerId);
        dbChar3.setNumDiscontinuitiesDetected(444);
        
        mockery.checking(new Expectations() {{
            List<Object> listWithNull = new ArrayList<Object>();
            listWithNull.add(null);
            one(pdcCrud).retrievePdcProcessingCharacteristics(FluxType.SAP, CadenceType.LONG, keplerIds, 0, 10);
            will(returnValue(ImmutableList.of(dbChar1)));
            one(pdcCrud).retrievePdcProcessingCharacteristics(FluxType.SAP, CadenceType.LONG, keplerIds, 11,20);
            will(returnValue(listWithNull));
            one(pdcCrud).retrievePdcProcessingCharacteristics(FluxType.SAP, CadenceType.LONG, keplerIds, 21, 30);
            will(returnValue(ImmutableList.of(dbChar3)));
        }});
        
        PdcProcessingCharacteristicsFactory factory =
            new PdcProcessingCharacteristicsFactory(quarters, pdcCrud, keplerIds);
        
        
        PdcProcessingCharacteristics[] output =
            factory.characteristicsForTarget(keplerId);
        
        PdcProcessingCharacteristics firstQuarter = 
            new PdcProcessingCharacteristics(dbChar1);
        PdcProcessingCharacteristics secondQuarter = 
            new PdcProcessingCharacteristics();
        PdcProcessingCharacteristics thirdQuarter = 
            new PdcProcessingCharacteristics(dbChar3);
        
        assertEquals(3, output.length);
        assertEquals(firstQuarter,  output[0]);
        assertEquals(secondQuarter, output[1]);
        assertEquals(thirdQuarter,  output[2]);
    }
}
