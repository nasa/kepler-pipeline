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

package gov.nasa.kepler.dv.io;

import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.fs.DvFsIdFactory;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvSingleEventStatisticsType;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Map;

/**
 * Single event statistics.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class DvSingleEventStatistics implements Persistable {

    private SimpleFloatTimeSeries correlationTimeSeries = new SimpleFloatTimeSeries();

    private SimpleFloatTimeSeries normalizationTimeSeries = new SimpleFloatTimeSeries();

    private float trialTransitPulseDuration;

    /**
     * Creates a {@link DvSingleEventStatistics}. For use only by mock objects
     * and Hibernate.
     */
    public DvSingleEventStatistics() {
    }

    public DvSingleEventStatistics(float trialTransitPulseDuration,
        SimpleFloatTimeSeries correlationTimeSeries,
        SimpleFloatTimeSeries normalizationTimeSeries) {

        this.trialTransitPulseDuration = trialTransitPulseDuration;
        this.correlationTimeSeries = correlationTimeSeries;
        this.normalizationTimeSeries = normalizationTimeSeries;
    }

    public static DvSingleEventStatistics getInstance(FluxType fluxType,
        long pipelineInstanceId, int keplerId, float trialTransitPulseDuration,
        Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        FloatTimeSeries correlationTimeSeries = timeSeriesByFsId.get(getCorrelationFsId(
            fluxType, pipelineInstanceId, keplerId, trialTransitPulseDuration));
        FloatTimeSeries normalizationTimeSeries = timeSeriesByFsId.get(getNormalizationFsId(
            fluxType, pipelineInstanceId, keplerId, trialTransitPulseDuration));

        if (correlationTimeSeries != null && normalizationTimeSeries != null) {
            return new DvSingleEventStatistics(trialTransitPulseDuration,
                new SimpleFloatTimeSeries(correlationTimeSeries.fseries(),
                    correlationTimeSeries.getGapIndicators()),
                new SimpleFloatTimeSeries(normalizationTimeSeries.fseries(),
                    normalizationTimeSeries.getGapIndicators()));
        }

        return new DvSingleEventStatistics();
    }

    private static FsId getCorrelationFsId(FluxType fluxType,
        long pipelineInstanceId, int keplerId, float trialTransitPulseDuration) {

        return DvFsIdFactory.getSingleEventStatisticsFsId(fluxType,
            DvSingleEventStatisticsType.CORRELATION, pipelineInstanceId,
            keplerId, trialTransitPulseDuration);
    }

    private static FsId getNormalizationFsId(FluxType fluxType,
        long pipelineInstanceId, int keplerId, float trialTransitPulseDuration) {

        return DvFsIdFactory.getSingleEventStatisticsFsId(fluxType,
            DvSingleEventStatisticsType.NORMALIZATION, pipelineInstanceId,
            keplerId, trialTransitPulseDuration);
    }

    public SimpleFloatTimeSeries getCorrelationTimeSeries() {
        return correlationTimeSeries;
    }

    public SimpleFloatTimeSeries getNormalizationTimeSeries() {
        return normalizationTimeSeries;
    }

    public float getTrialTransitPulseDuration() {
        return trialTransitPulseDuration;
    }
}
