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

package gov.nasa.kepler.prf;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidTimeSeriesType;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * Centroid time series.
 * 
 * @author Sean McCauliff
 * @author Forrest Girouard
 * 
 */
public class PrfCentroidTimeSeries implements Persistable {

    /**
     * The Kepler ID for this centroid's target (directly from the KIC).
     */
    private int keplerId;

    private float[] rows;

    /**
     * The centroid row uncertainties for a target.
     */
    private float[] rowUncertainties;

    private float[] columns;
    /**
     * The centroid column uncertainties for a target.
     */
    private float[] columnUncertainties;

    /**
     * Index (relative cadence) of gaps in the time series.
     */
    private int[] gapIndices;

    public PrfCentroidTimeSeries() {
    }

    public PrfCentroidTimeSeries(int keplerId, float[] rows,
        float[] rowUncertainties, float[] column, float[] columnUncertainties,
        int[] gapIndices) {
        this.keplerId = keplerId;
        this.rows = rows;
        this.rowUncertainties = rowUncertainties;
        this.columns = column;
        this.columnUncertainties = columnUncertainties;
        this.gapIndices = gapIndices;
    }

    public PrfCentroidTimeSeries(int keplerId, Map<FsId,FloatTimeSeries> fsIdToTimeSeries) {
        this.keplerId = keplerId;
        
        FloatTimeSeries fseries = fsIdToTimeSeries.get(rowsFsId(keplerId));
        rows = fseries.fseries();
        
        fseries = fsIdToTimeSeries.get(rowUncertFsId(keplerId));
        rowUncertainties = fseries.fseries();
        
        fseries = fsIdToTimeSeries.get(colsFsId(keplerId));
        columns = fseries.fseries();
        
        fseries = fsIdToTimeSeries.get(colUncertFsId(keplerId));
        columnUncertainties = fseries.fseries();
        
        gapIndices = fseries.getGapIndices();
        
    }
    public List<FloatTimeSeries> getAllFloatTimeSeries(int startCadence,
        int endCadence, long pipelineTaskId) {

        List<FloatTimeSeries> timeSeries = new ArrayList<FloatTimeSeries>();
        FsId fsId = rowsFsId(getKeplerId());
        timeSeries.add(new FloatTimeSeries(fsId, getRows(), startCadence,
            endCadence, getGapIndices(), pipelineTaskId));

        fsId = colsFsId(getKeplerId());
        timeSeries.add(new FloatTimeSeries(fsId, getColumns(), startCadence,
            endCadence, getGapIndices(), pipelineTaskId));

        fsId = rowUncertFsId(getKeplerId());
        timeSeries.add(new FloatTimeSeries(fsId, getRowUncertainties(),
            startCadence, endCadence, getGapIndices(), pipelineTaskId));

        fsId = colUncertFsId(getKeplerId());
        timeSeries.add(new FloatTimeSeries(fsId, getColumnUncertainties(),
            startCadence, endCadence, getGapIndices(), pipelineTaskId));
        return timeSeries;
    }
    
    static List<FsId> fsIdsFor(int keplerId) {
        List<FsId> ids = new ArrayList<FsId>(4);
        ids.add(rowsFsId(keplerId));
        ids.add(colsFsId(keplerId));
        ids.add(rowUncertFsId(keplerId));
        ids.add(colUncertFsId(keplerId));
        return ids;
    }

    private static FsId colUncertFsId(int keplerId) {
        return PaFsIdFactory.getCentroidTimeSeriesFsId(
            CentroidTimeSeriesType.CENTROID_COLS_UNCERTAINTIES,
            CadenceType.LONG, keplerId);
    }

    private static FsId rowUncertFsId(int keplerId) {
        return PaFsIdFactory.getCentroidTimeSeriesFsId(
            CentroidTimeSeriesType.CENTROID_ROWS_UNCERTAINTIES,
            CadenceType.LONG, keplerId);
    }

    private static FsId colsFsId(int keplerId) {
        return PaFsIdFactory.getCentroidTimeSeriesFsId(
            CentroidTimeSeriesType.CENTROID_COLS, CadenceType.LONG,
            keplerId);
    }

    private static FsId rowsFsId(int keplerId) {
        return PaFsIdFactory.getCentroidTimeSeriesFsId(
            CentroidTimeSeriesType.CENTROID_ROWS, CadenceType.LONG,
            keplerId);
    }
    
    @Override
    public String toString() {
        return new ToStringBuilder(this).append("keplerId", keplerId)
            .append("row.length", rows.length)
            .append("rowUncertainties.length", rowUncertainties.length)
            .append("column.length", columns.length)
            .append("columnUncertainties.length", columnUncertainties.length)
            .append("gapIndices.length", gapIndices)
            .toString();
    }

    // accessors

    public float[] getColumns() {
        return columns;
    }

    public float[] getColumnUncertainties() {
        return columnUncertainties;
    }

    public int[] getGapIndices() {
        return gapIndices;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public float[] getRows() {
        return rows;
    }

    public float[] getRowUncertainties() {
        return rowUncertainties;
    }

}
