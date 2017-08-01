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

package gov.nasa.kepler.mc.fs;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.query.QueryEvaluator;
import gov.nasa.kepler.hibernate.dv.DvPlanetModelFit.PlanetModelFitType;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvCorrectedFluxType;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvSingleEventStatisticsType;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvTimeSeriesType;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.SingleEventParse;

import java.util.Collections;

import org.antlr.runtime.RecognitionException;
import org.junit.Test;

/**
 * FS unit tests for DV file store IDs.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class DvFsIdFactoryTest {

    @Test
    public void getResidualTimeSeriesFsId() {
        int keplerId = 123456;
        DvTimeSeriesType timeSeriesType = DvTimeSeriesType.FLUX;
        FluxType fluxType = FluxType.SAP;
        long pipelineInstanceId = 789L;

        // /dv/fluxType/Residual/timeSeriesType/pipelineInstanceId/keplerId
        String expectedValue = DvFsIdFactory.DV_PATH + fluxType.getName()
            + "/Residual/" + timeSeriesType.getName() + '/'
            + pipelineInstanceId + '/' + keplerId;

        FsId fsId = DvFsIdFactory.getResidualTimeSeriesFsId(fluxType,
            timeSeriesType, pipelineInstanceId, keplerId);
        assertEquals(expectedValue, fsId.toString());
    }

    @Test
    public void getInitialTimeSeriesFsId() {
        int keplerId = 123456;
        DvTimeSeriesType timeSeriesType = DvTimeSeriesType.FLUX;
        FluxType fluxType = FluxType.SAP;
        long pipelineInstanceId = 789L;
        int planetNumber = 2;

        // /dv/fluxType/Initial/timeSeriesType/pipelineInstanceId/keplerId:planetNumber
        String expectedValue = DvFsIdFactory.DV_PATH + fluxType.getName()
            + "/Initial/" + timeSeriesType.getName() + '/' + pipelineInstanceId
            + '/' + keplerId + ':' + planetNumber;

        FsId fsId = DvFsIdFactory.getCorrectedFluxTimeSeriesFsId(fluxType,
            DvCorrectedFluxType.INITIAL, timeSeriesType, pipelineInstanceId,
            keplerId, planetNumber);
        assertEquals(expectedValue, fsId.toString());
    }

    @Test
    public void getSingleEventStatisticsFsId() {
        int keplerId = 123456;
        DvSingleEventStatisticsType singleEventStatisticsType = DvSingleEventStatisticsType.NORMALIZATION;
        FluxType fluxType = FluxType.SAP;
        long pipelineInstanceId = 789L;
        float trialTransitPulseDuration = 5.5F;

        // /dv/fluxType/SingleEventStatistics/singleEventStatisticsType/pipelineInstanceId/keplerId:trialTransitPulseDuration
        String expectedValue = DvFsIdFactory.DV_PATH + fluxType.getName()
            + "/SingleEventStatistics/" + singleEventStatisticsType.getName()
            + '/' + pipelineInstanceId + '/' + keplerId + ':' + "5.50";

        FsId fsId = DvFsIdFactory.getSingleEventStatisticsFsId(fluxType,
            singleEventStatisticsType, pipelineInstanceId, keplerId,
            trialTransitPulseDuration);
        assertEquals(expectedValue, fsId.toString());

        trialTransitPulseDuration = 5.499999F;
        fsId = DvFsIdFactory.getSingleEventStatisticsFsId(fluxType,
            singleEventStatisticsType, pipelineInstanceId, keplerId,
            trialTransitPulseDuration);
        assertEquals(expectedValue, fsId.toString());
    }

    @Test(expected = IllegalArgumentException.class)
    public void getRobustWeightsTimeSeriesFsIdWithSingle() {
        int keplerId = 123456;
        PlanetModelFitType planetModelFitType = PlanetModelFitType.SINGLE;
        FluxType fluxType = FluxType.SAP;
        long pipelineInstanceId = 789L;
        int planetNumber = 2;

        // /dv/fluxType/RobustWeights/planetModelFitType/pipelineInstanceId/keplerId:planetNumber
        DvFsIdFactory.getRobustWeightsTimeSeriesFsId(fluxType,
            planetModelFitType, pipelineInstanceId, keplerId, planetNumber);
    }

    @Test
    public void getRobustWeightsTimeSeriesFsId() {
        int keplerId = 123456;
        PlanetModelFitType planetModelFitType = PlanetModelFitType.ALL;
        FluxType fluxType = FluxType.SAP;
        long pipelineInstanceId = 789L;
        int planetNumber = 2;

        // /dv/fluxType/RobustWeights/planetModelFitType/pipelineInstanceId/keplerId:planetNumber
        String expectedValue = DvFsIdFactory.DV_PATH + fluxType.getName()
            + "/RobustWeights/" + planetModelFitType.getName() + '/'
            + pipelineInstanceId + '/' + keplerId + ':' + planetNumber;

        FsId fsId = DvFsIdFactory.getRobustWeightsTimeSeriesFsId(fluxType,
            planetModelFitType, pipelineInstanceId, keplerId, planetNumber);
        assertEquals(expectedValue, fsId.toString());
    }

    @Test
    public void getSingleRobustWeightsTimeSeriesFsId() {
        int keplerId = 123456;
        FluxType fluxType = FluxType.SAP;
        long pipelineInstanceId = 789L;
        int planetNumber = 2;
        int transitNumber = 3;

        // /dv/fluxType/RobustWeights/Single/pipelineInstanceId/keplerId:planetNumber:transitNumber
        String expectedValue = DvFsIdFactory.DV_PATH + fluxType.getName()
            + "/RobustWeights/" + PlanetModelFitType.SINGLE.getName() + '/'
            + pipelineInstanceId + '/' + keplerId + ':' + planetNumber + ':'
            + transitNumber;

        FsId fsId = DvFsIdFactory.getSingleRobustWeightsTimeSeriesFsId(
            fluxType, pipelineInstanceId, keplerId, planetNumber, transitNumber);
        assertEquals(expectedValue, fsId.toString());
    }

    @Test
    public void getFoldedPhaseTimeSeriesFsId() {
        int keplerId = 123456;
        FluxType fluxType = FluxType.SAP;
        long pipelineInstanceId = 789L;
        int planetNumber = 2;

        // /dv/fluxType/FoldedPhase/pipelineInstanceId/keplerId:planetNumber
        String expectedValue = DvFsIdFactory.DV_PATH + fluxType.getName()
            + "/FoldedPhase/" + pipelineInstanceId + '/' + keplerId + ':'
            + planetNumber;

        FsId fsId = DvFsIdFactory.getFoldedPhaseTimeSeriesFsId(fluxType,
            pipelineInstanceId, keplerId, planetNumber);
        assertEquals(expectedValue, fsId.toString());
    }

    @Test
    public void createSingleEventStatisticsQuery() throws RecognitionException {
        int keplerId = 123456;
        DvSingleEventStatisticsType singleEventStatisticsType = DvSingleEventStatisticsType.NORMALIZATION;
        FluxType fluxType = FluxType.SAP;
        long pipelineInstanceId = 789L;
        float trialTransitPulseDuration = 5.5F;

        FsId fsId = DvFsIdFactory.getSingleEventStatisticsFsId(fluxType,
            singleEventStatisticsType, pipelineInstanceId, keplerId,
            trialTransitPulseDuration);

        QueryEvaluator queryEvaluator = new QueryEvaluator(
            DvFsIdFactory.createSingleEventStatisticsQuery(fluxType,
                Collections.singleton(pipelineInstanceId), 0, Integer.MAX_VALUE));
        queryEvaluator.match(fsId);
        assertTrue(queryEvaluator.completeMatch());
    }

    @Test
    public void testSingleEventFsIdParse() throws Exception {
        int keplerId = Integer.MAX_VALUE;
        DvSingleEventStatisticsType singleEventStatisticsType = DvSingleEventStatisticsType.NORMALIZATION;
        FluxType fluxType = FluxType.DIA;
        long pipelineInstanceId = Long.MAX_VALUE;
        float trialTransitPulseDuration = 15.5F;

        FsId fsId = DvFsIdFactory.getSingleEventStatisticsFsId(fluxType,
            singleEventStatisticsType, pipelineInstanceId, keplerId,
            trialTransitPulseDuration);

        SingleEventParse parseResult = DvFsIdFactory.parseSingleEventStatisticsFsId(fsId);
        assertEquals(keplerId, parseResult.keplerId);
        assertEquals(singleEventStatisticsType,
            parseResult.singleEventStatisticsType);
        assertEquals(fluxType, parseResult.fluxType);
        assertEquals(pipelineInstanceId, parseResult.pipelineInstanceId);
        assertEquals(trialTransitPulseDuration,
            parseResult.trialTransitPulseDuration, 0.0f);
    }
}
