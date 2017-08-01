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

package gov.nasa.kepler.systest.sbt.data;

import gov.nasa.kepler.cal.io.CalCompressionTimeSeries;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.mc.DoubleDbTimeSeries;
import gov.nasa.kepler.hibernate.mc.DoubleDbTimeSeriesCrud;
import gov.nasa.kepler.hibernate.mc.DoubleTimeSeriesType;
import gov.nasa.kepler.mc.CompoundIndicesTimeSeries;
import gov.nasa.kepler.mc.CompoundTimeSeries;
import gov.nasa.kepler.mc.CompoundTimeSeries.Centroids;
import gov.nasa.kepler.mc.CorrectedFluxTimeSeries;
import gov.nasa.kepler.mc.SimpleIndicesTimeSeries;
import gov.nasa.kepler.mc.SimpleTimeSeries;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.spiffy.common.CentroidTimeSeries;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleDoubleTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleIntTimeSeries;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Map;

/**
 * This class creates {@link Persistable} time series.
 * 
 * @author Miles Cote
 * 
 */
public class PersistableTimeSeriesFactory {

    private final DoubleDbTimeSeriesCrud doubleDbTimeSeriesCrud;

    public PersistableTimeSeriesFactory(
        DoubleDbTimeSeriesCrud doubleDbTimeSeriesCrud) {
        this.doubleDbTimeSeriesCrud = doubleDbTimeSeriesCrud;
    }

    public SimpleIntTimeSeries getSimpleIntTimeSeries(FsId valuesFsId,
        Map<FsId, ? extends TimeSeries> timeSeriesByFsId) {
        return SimpleTimeSeries.getIntInstance(valuesFsId, timeSeriesByFsId);
    }

    public SimpleDoubleTimeSeries getSimpleDoubleTimeSeriesFromDatabase(
        DoubleTimeSeriesType timeSeriesType, int startCadence, int endCadence) {
        DoubleDbTimeSeries doubleDbTimeSeries = doubleDbTimeSeriesCrud.retrieve(
            timeSeriesType, startCadence, endCadence);

        return new SimpleDoubleTimeSeries(doubleDbTimeSeries.getValues(),
            doubleDbTimeSeries.getGapIndicators());
    }

    public SimpleDoubleTimeSeries getSimpleDoubleTimeSeries(FsId valuesFsId,
        Map<FsId, ? extends TimeSeries> timeSeriesByFsId) {
        return SimpleTimeSeries.getDoubleInstance(valuesFsId, timeSeriesByFsId);
    }

    public SimpleFloatTimeSeries getSimpleTimeSeries(FsId valuesFsId,
        Map<FsId, ? extends TimeSeries> timeSeriesByFsId) {
        return SimpleTimeSeries.getFloatInstance(valuesFsId, timeSeriesByFsId);
    }

    public CompoundFloatTimeSeries getCompoundTimeSeries(FsId valuesFsId,
        FsId uncertaintiesFsId, Map<FsId, ? extends TimeSeries> timeSeriesByFsId) {
        return CompoundTimeSeries.getFloatInstance(valuesFsId,
            uncertaintiesFsId, timeSeriesByFsId);
    }

    public CorrectedFluxTimeSeries getCorrectedFluxTimeSeries(FsId valuesFsId,
        FsId uncertaintiesFsId, FsId filledIndicesFsId,
        Map<FsId, ? extends TimeSeries> timeSeriesByFsId) {
        return CorrectedFluxTimeSeries.getInstance(valuesFsId,
            uncertaintiesFsId, filledIndicesFsId, 0, timeSeriesByFsId);
    }

    public SimpleIndicesTimeSeries getSimpleIndicesTimeSeries(FsId valuesFsId,
        Map<FsId, ? extends FloatMjdTimeSeries> fsIdToMjdTimeSeries,
        MjdToCadence mjdToCadence, int startCadence, int endCadence) {
        return SimpleIndicesTimeSeries.getInstance(valuesFsId,
            fsIdToMjdTimeSeries, mjdToCadence, startCadence, endCadence);
    }

    public CompoundIndicesTimeSeries getCompoundIndicesTimeSeries(
        FsId valuesFsId, FsId uncertaintiesFsId,
        Map<FsId, ? extends FloatMjdTimeSeries> fsIdToMjdTimeSeries,
        MjdToCadence mjdToCadence, int startCadence, int endCadence) {
        return CompoundIndicesTimeSeries.getInstance(valuesFsId,
            uncertaintiesFsId, fsIdToMjdTimeSeries, mjdToCadence, startCadence,
            endCadence);
    }

    public CentroidTimeSeries getCentroidTimeSeries(FsId rowFsId,
        FsId rowUncertaintiesFsId, FsId colFsId, FsId colUncertaintiesFsId,
        Map<FsId, ? extends TimeSeries> fsIdToTimeSeries) {
        return Centroids.getCentroidInstance(rowFsId, rowUncertaintiesFsId,
            colFsId, colUncertaintiesFsId, 0, fsIdToTimeSeries);
    }

    public CalCompressionTimeSeries getCalCompressionTimeSeries(
        FsId valuesFsId, FsId countsFsId,
        Map<FsId, ? extends TimeSeries> timeSeriesByFsId) {
        return CalCompressionTimeSeries.getInstance(valuesFsId, countsFsId,
            timeSeriesByFsId);
    }

}
