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

package gov.nasa.kepler.hibernate.dr;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.util.List;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
@RunWith(JMock.class)
public class PixelLogCacheTest {

    private Mockery mockery = new Mockery() {
        {
            setImposteriser(ClassImposteriser.INSTANCE);
        }
    };

    private final int cadenceType = CadenceType.LONG.intValue();
    private final DataSetType dataSetType = DataSetType.Background;
    private final int startCadence = 1;
    private final int endCadence = 2;
    private final double mjdStart = 3.3;
    private final double mjdEnd = 4.4;
    private final TargetType targetType = TargetType.BACKGROUND;

    private final List<PixelLog> pixelLogs1 = ImmutableList.of(mockery.mock(
        PixelLog.class, "pixelLogs1"));
    private final List<PixelLog> pixelLogs2 = ImmutableList.of(mockery.mock(
        PixelLog.class, "pixelLogs2"));
    private final List<PixelLog> pixelLogs3 = ImmutableList.of(mockery.mock(
        PixelLog.class, "pixelLogs3"));
    private final List<PixelLog> pixelLogs4 = ImmutableList.of(mockery.mock(
        PixelLog.class, "pixelLogs4"));
    private final List<PixelLogResult> pixelLogResults = ImmutableList.of(mockery.mock(PixelLogResult.class));

    private final PixelLogRetriever pixelLogRetriever = mockery.mock(PixelLogRetriever.class);

    private PixelLogCache pixelLogCache = new PixelLogCache(pixelLogRetriever);

    @Before
    public void setUp() {
        PixelLogCache.lruCache.clear();

        mockery.checking(new Expectations() {
            {
                exactly(1).of(pixelLogRetriever)
                    .retrievePixelLog(cadenceType, dataSetType, startCadence,
                        endCadence);
                will(returnValue(pixelLogs1));

                exactly(1).of(pixelLogRetriever)
                    .retrievePixelLog(cadenceType, dataSetType, mjdStart,
                        mjdEnd);
                will(returnValue(pixelLogs2));

                exactly(1).of(pixelLogRetriever)
                    .retrievePixelLog(cadenceType, startCadence, endCadence);
                will(returnValue(pixelLogs3));

                exactly(1).of(pixelLogRetriever)
                    .retrievePixelLog(cadenceType, mjdStart, mjdEnd);
                will(returnValue(pixelLogs4));

                exactly(1).of(pixelLogRetriever)
                    .retrieveTableIdsForCadenceRange(targetType, startCadence,
                        endCadence);
                will(returnValue(pixelLogResults));
            }
        });
    }

    @Test
    public void testRetrievePixelLogCalledOnceDelegatesToRetriever() {
        testRetrieve();
    }

    @Test
    public void testRetrievePixelLogCalledTwiceGoesToCache() {
        testRetrieve();
        testRetrieve();
    }

    private void testRetrieve() {
        List<PixelLog> actualPixelLogs1 = pixelLogCache.retrievePixelLog(
            cadenceType, dataSetType, startCadence, endCadence);
        List<PixelLog> actualPixelLogs2 = pixelLogCache.retrievePixelLog(
            cadenceType, dataSetType, mjdStart, mjdEnd);
        List<PixelLog> actualPixelLogs3 = pixelLogCache.retrievePixelLog(
            cadenceType, startCadence, endCadence);
        List<PixelLog> actualPixelLogs4 = pixelLogCache.retrievePixelLog(
            cadenceType, mjdStart, mjdEnd);
        List<PixelLogResult> actualPixelLogResults = pixelLogCache.retrieveTableIdsForCadenceRange(
            targetType, startCadence, endCadence);

        assertEquals(pixelLogs1, actualPixelLogs1);
        assertEquals(pixelLogs2, actualPixelLogs2);
        assertEquals(pixelLogs3, actualPixelLogs3);
        assertEquals(pixelLogs4, actualPixelLogs4);
        assertEquals(pixelLogResults, actualPixelLogResults);
    }

}
