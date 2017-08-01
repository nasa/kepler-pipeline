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

package gov.nasa.kepler.mc.tps;

import static gov.nasa.kepler.mc.fs.TpsFsIdFactory.getWeakSecondaryMesId;
import static gov.nasa.kepler.mc.fs.TpsFsIdFactory.getWeakSecondaryPhaseId;
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.pi.TpsType;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.PlanetaryCandidatesFilter;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.hibernate.tps.TpsDbResult;
import gov.nasa.kepler.hibernate.tps.WeakSecondaryDb;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;

import java.util.List;

import org.apache.commons.lang.ArrayUtils;
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
public class TpsOperationsTest{

    private Mockery mockery;
    
    @Before
    public void setup() {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
    }
    
    @Test
    public void testRetrieveLatestBestTpsResultsWithPlanetaryCandidate() {
        final int skyGroupId = 1;
        final int startKeplerId = 2;
        final int endKeplerId = 3;
        final float trialTransitPulseInHours = 3.0f;
        final long originatorId = 7;
        final long pipelineInstanceId = 234234;

        final int keplerId = 4;
        final List<Integer> keplerIds = ImmutableList.of(keplerId);

        final PlanetaryCandidatesFilter filter = mockery.mock(PlanetaryCandidatesFilter.class);

        final WeakSecondaryDb weakSecondaryDb = new WeakSecondaryDb(1.0f, 2.0f,
            ArrayUtils.EMPTY_FLOAT_ARRAY, ArrayUtils.EMPTY_FLOAT_ARRAY,
            3.0f, 4.0f, 5.0f, 6.0f, 7.0f, 8.0f, 9, 10.0f);
        final PipelineTask originator = mockery.mock(PipelineTask.class);
        final TpsDbResult tpsDbResult = mockery.mock(TpsDbResult.class);
        mockery.checking(new Expectations() {{
            atLeast(1).of(tpsDbResult).getTrialTransitPulseInHours();
            will(returnValue(trialTransitPulseInHours));
            atLeast(1).of(tpsDbResult).getWeakSecondary();
            will(returnValue(weakSecondaryDb));
            allowing(tpsDbResult).getKeplerId();
            will(returnValue(keplerId));
            atLeast(1).of(tpsDbResult).getOriginator();
            will(returnValue(originator));
            
            atLeast(1).of(originator).getId();
            will(returnValue(originatorId));
        }});
        
        final List<TpsDbResult> tpsDbResults = ImmutableList.of(tpsDbResult);

        final TpsCrud tpsCrud = mockery.mock(TpsCrud.class);
        final CelestialObjectOperations celestialObjectOperations = 
            mockery.mock(CelestialObjectOperations.class);

        mockery.checking(new Expectations() {{
            one(celestialObjectOperations).retrieveKeplerIdsForSkyGroupIdKeplerIdRange(
                skyGroupId, startKeplerId, endKeplerId);
            will(returnValue(keplerIds));
            allowing(tpsCrud).retrieveLatestTpsResults(keplerIds, filter);
            will(returnValue(tpsDbResults));
            
            PipelineInstance tpsPipelineInstance = new PipelineInstance();
            tpsPipelineInstance.setId(pipelineInstanceId);
            atLeast(1).of(tpsCrud).retrieveLatestTpsRun(TpsType.TPS_FULL);
            will(returnValue(tpsPipelineInstance));
        }});

       
        final FsId[] ids = new FsId[] { getWeakSecondaryMesId(pipelineInstanceId, keplerId, trialTransitPulseInHours),
            getWeakSecondaryPhaseId(pipelineInstanceId, keplerId, trialTransitPulseInHours)};
        FloatTimeSeries mesArray = new FloatTimeSeries(ids[0], new float[] { 1.0f}, 0, 0, new boolean[1], originatorId);
        FloatTimeSeries phaseArray = new FloatTimeSeries(ids[1], new float[] { 2.0f}, 0, 0, new boolean[1], originatorId);
        final FileStoreClient fsClient = mockery.mock(FileStoreClient.class);
        final FloatTimeSeries[] allTimeSeries = 
            new FloatTimeSeries[] { mesArray, phaseArray};
        mockery.checking(new Expectations() {{
            oneOf(fsClient).readAllTimeSeriesAsFloat(ids, true);
            will(returnValue(allTimeSeries));
        }});
        
        TpsOperations tpsOperations =
            new TpsOperations(tpsCrud, celestialObjectOperations, fsClient);
        List<TpsDbResult> actualTpsDbResults = tpsOperations.retrieveLatestTpsResultsWithFileStoreData( 
            skyGroupId, startKeplerId, endKeplerId, filter);

        assertEquals(tpsDbResults, actualTpsDbResults);
        assertEquals(weakSecondaryDb.getMes(), mesArray.fseries());
        assertEquals(weakSecondaryDb.getPhaseInDays(), phaseArray.fseries());
    }

}
