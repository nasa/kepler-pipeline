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

package gov.nasa.kepler.ar.exporter.ktc;

import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentSkipListSet;
import java.util.concurrent.atomic.AtomicInteger;

import gov.nasa.kepler.hibernate.tad.KtcInfo;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Iterators;
import com.google.common.collect.Sets;

import static gov.nasa.kepler.common.ModifiedJulianDate.mjdToDate;
import static org.junit.Assert.*;

@RunWith(JMock.class)
public class EntryCollatorTest {


    private static final List<String> EXCLUDE_LABELS = Collections.singletonList("XME");
    private static final List<String> OK_LABELS = Collections.singletonList("OK");

    
    
    private Mockery mockery = new Mockery() {{
        setImposteriser(ClassImposteriser.INSTANCE);
    }};
    
    
    @Test
    public void testWithFilteredTargetLabels() throws Exception {
        
        final TargetCrud targetCrud = mockery.mock(TargetCrud.class);
        mockery.checking(new Expectations() {{
            atLeast(5).of(targetCrud).retrieveCategoriesForTarget(with(any(Long.class)), with(any(Long.class)));
            will(returnValue(Collections.singletonList("Category")));
        }});
        
        
        final TargetType targetType = TargetType.LONG_CADENCE;
        final KtcTimes ktcTimes = mockery.mock(KtcTimes.class);
        mockery.checking(new Expectations() {{
            allowing(ktcTimes).actualStartTime(targetType, 23);
            will(returnValue(0.0));
            //TODO:  This gets complicated with the last parameter.
            allowing(ktcTimes).actualStopTime(targetType, 23, null);
            will(returnValue(1.0));
            
            allowing(ktcTimes).actualStartTime(targetType, 24);
            will(returnValue(1.0));
            
            allowing(ktcTimes).actualStopTime(targetType, 24, 1.0);
            will(returnValue(2.0));
            
            allowing(ktcTimes).orderForExternalId(targetType, 23);
            will(returnValue(0));
            
            allowing(ktcTimes).orderForExternalId(targetType, 24);
            will(returnValue(1));
        }});
        
        ConcurrentSkipListSet<CompletedKtcEntry> completedEntries = 
            new ConcurrentSkipListSet<CompletedKtcEntry>();
        
        AtomicInteger completeCount = new AtomicInteger();
        
        Set<String> excludeLabels = Sets.newHashSet(EXCLUDE_LABELS);
        
        EntryCollator entryCollator = 
            new EntryCollator(targetCrud, completedEntries, 
                ktcTimes, completeCount, excludeLabels);
        
        //Target 0 contains a single entry where it should be filtered out.
        final KtcInfo ktcInfo0_0 = new KtcInfo(0, targetType, mjdToDate(0), mjdToDate(1), 1000L, 23, 10023);
        final KtcInfo ktcInfo0_1 = new KtcInfo(0, targetType, mjdToDate(1), mjdToDate(2), 1001L, 24, 10024);
        mockery.checking(new Expectations() {{
            one(targetCrud).retrieveLabelsForObservedTarget(ktcInfo0_0.targetId);
            will(returnValue(OK_LABELS));
            one(targetCrud).retrieveLabelsForObservedTarget(ktcInfo0_1.targetId);
            will(returnValue(EXCLUDE_LABELS));
        }});
        
        
        //Target 1 should be completely filtered
        final KtcInfo ktcInfo1_0 = new KtcInfo(1, targetType, mjdToDate(0), mjdToDate(1), 1010L, 23, 10023);
        mockery.checking(new Expectations() {{
            one(targetCrud).retrieveLabelsForObservedTarget(ktcInfo1_0.targetId);
            will(returnValue(EXCLUDE_LABELS));
        }});
        
        //Target 2 should not be filtered at all.
        final KtcInfo ktcInfo2_0 = new KtcInfo(2, targetType, mjdToDate(0), mjdToDate(1), 1020L, 23, 10023);
        final KtcInfo ktcInfo2_1 = new KtcInfo(2, targetType, mjdToDate(1), mjdToDate(2), 1021L, 24, 10024);
        mockery.checking(new Expectations() {{
            one(targetCrud).retrieveLabelsForObservedTarget(ktcInfo2_0.targetId);
            will(returnValue(OK_LABELS));
            one(targetCrud).retrieveLabelsForObservedTarget(ktcInfo2_1.targetId);
            will(returnValue(OK_LABELS));
        }});
        
        
        List<KtcInfo> allInfos = ImmutableList.of(ktcInfo0_0, ktcInfo0_1, ktcInfo1_0, ktcInfo2_0, ktcInfo2_1);
        entryCollator.doIt(allInfos);
        entryCollator.last(Collections.EMPTY_LIST);

        assertEquals(2, completedEntries.size());
        
        assertEquals(0, completedEntries.iterator().next().keplerId);
        assertEquals(2, Iterators.get(completedEntries.iterator(), 1).keplerId);
    }
}
