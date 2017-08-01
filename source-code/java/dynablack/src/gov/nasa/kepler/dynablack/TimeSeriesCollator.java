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

package gov.nasa.kepler.dynablack;

import gov.nasa.kepler.cal.PixelByRowCol;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.PixelTimeSeriesReader;
import gov.nasa.spiffy.common.collect.RemovableArrayList;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.LinkedList;
import java.util.List;
import java.util.SortedSet;
import java.util.TreeSet;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Splits up the FsIds into chunks and removes duplicate series.
 * 
 * @author Sean McCauliff
 *
 */
public class TimeSeriesCollator {

    private static final Log log = LogFactory.getLog(TimeSeriesCollator.class);
    
    //The first index is the row index.
    private final List<List<Pixel>> idsByRow = new ArrayList<List<Pixel>>();
    
    private final LinkedList<IntTimeSeries> queue = 
        new LinkedList<IntTimeSeries>();
    
    private int nextRowIndex = 0;
    private final int maxChunkSize;
    private final int fsFetchSize;
    private final PixelTimeSeriesReader pixelTimeSeriesReader;
    private final int startCadence;
    private final int endCadence;
    
    
    public TimeSeriesCollator(Collection<Pixel> unsortedPixels, PixelTimeSeriesReader pixelTimeSeriesReader, int maxChunkSize, 
        int fsFetchSize, int startCadence, int endCadence) {
        
        if (fsFetchSize <= 0) {
            throw new IllegalArgumentException("fsFetchSize must be greater " +
                    "than zero, got " + fsFetchSize + ".");
        }
        if (maxChunkSize < FcConstants.CCD_COLUMNS) {
            log.warn("maxChunkSize is " + maxChunkSize 
                + " which is less than a complete CCD row.  " +
                        "This will be changed to " + FcConstants.CCD_COLUMNS + ".");
            
        }
        
        this.fsFetchSize = fsFetchSize;
        this.maxChunkSize = Math.max(maxChunkSize, FcConstants.CCD_COLUMNS);
        this.pixelTimeSeriesReader = pixelTimeSeriesReader;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        
        SortedSet<Pixel> sortedPixels = new TreeSet<Pixel>(new PixelByRowCol());
        sortedPixels.addAll(unsortedPixels);
        
        if (sortedPixels.size() > 0) {
            List<Pixel> currentList = new ArrayList<Pixel>();
            int currentRow = sortedPixels.first().getRow();
            for (Pixel p : sortedPixels) {
                int nextRow = p.getRow();
                if (nextRow != currentRow) {
                    currentRow = nextRow;
                    idsByRow.add(currentList);
                    currentList = new ArrayList<Pixel>();
                }
                currentList.add(p);
            }
            
            idsByRow.add(currentList);
        }
        
    }
    
    public boolean hasNext() {
        return nextRowIndex < idsByRow.size();
    }
    
    /**
     * If there is a next chunk then this will prefetch any time series not
     * fetched from the file store that are needed for the next chunk.  Calling
     * this is safe even if there is no next cunk.
     */
    public void preFetch() {
        if (!hasNext()) {
            return;
        }
        
        RemovableArrayList<Pixel> nextChunkIds = new RemovableArrayList<Pixel>(2 * maxChunkSize);
        int rowi=nextRowIndex;
        for (; rowi < idsByRow.size() && nextChunkIds.size() < this.maxChunkSize; rowi++) {
            nextChunkIds.addAll(idsByRow.get(rowi));
        }
        
        if (nextChunkIds.size() > maxChunkSize) {
            int removeRowSize = idsByRow.get(rowi - 1).size();
            nextChunkIds.removeInterval(nextChunkIds.size() - removeRowSize, nextChunkIds.size());
            rowi--;
        }
        
        if (queue.size() >= nextChunkIds.size()) {
            return;
        }
        
        for (int queuei=queue.size(); queuei < nextChunkIds.size(); queuei = queue.size()) {
            List<FsId> fetchBatchList = new ArrayList<FsId>(nextChunkIds.size());
            for (int bi=queue.size(); bi < nextChunkIds.size() && fetchBatchList.size() < fsFetchSize; bi++) {
                fetchBatchList.add(nextChunkIds.get(bi).getFsId());
            }
            refillTimeSeriesBuffer(rowi, fetchBatchList);
        }
    }
    
    public IntTimeSeries[] nextChunk() {
        RemovableArrayList<Pixel> nextChunkIds = new RemovableArrayList<Pixel>(2* maxChunkSize);
        int ri=nextRowIndex;
        for (; ri < idsByRow.size() && nextChunkIds.size() < this.maxChunkSize; ri++) {
            nextChunkIds.addAll(idsByRow.get(ri));
        }
        
        if (nextChunkIds.size() > maxChunkSize) {
            int removeRowSize = idsByRow.get(ri - 1).size();
            nextChunkIds.removeInterval(nextChunkIds.size() - removeRowSize, nextChunkIds.size());
            nextRowIndex = ri - 1;
        } else {
            //else ri exceeded the number of rows.
            nextRowIndex = ri;
        }
        
        if (nextChunkIds.size() == 0) {
            throw new IllegalStateException("Input rows are too long or chunk size too small.");
        }
        
        List<IntTimeSeries> rv = new ArrayList<IntTimeSeries>(nextChunkIds.size());
        int i=0;
        while (i < nextChunkIds.size()) {
            if (queue.size() > 0) {
                IntTimeSeries timeseries = queue.remove();
                i++;
                if (timeseries.exists() && !timeseries.isEmpty()) {
                    rv.add(timeseries);
                }
                continue;
            }
            
            List<FsId> fetchBatchList = new ArrayList<FsId>();
            for (int bi=i; bi < nextChunkIds.size() && fetchBatchList.size() < fsFetchSize; bi++) {
                fetchBatchList.add(nextChunkIds.get(bi).getFsId());
            }
            refillTimeSeriesBuffer(nextRowIndex,fetchBatchList);
        }
        
        return rv.toArray(new IntTimeSeries[0]);
    }
    
    /**
     * 
     * @param fetchBatchList Ids not present in the queue that are needed by the
     * current chunk.  Up to fetchSize additional ids are requested.
     * @throws FileStoreException 
     */
    private void refillTimeSeriesBuffer(int startRowIndex, List<FsId> fetchBatchList) {
        for (int rowi = startRowIndex; rowi < idsByRow.size() && fetchBatchList.size() < fsFetchSize; rowi++) {
                for (Pixel addId : idsByRow.get(rowi)) {
                    if (fetchBatchList.size() == fsFetchSize) {
                        break;
                    }
                    fetchBatchList.add(addId.getFsId());
                }
            }
        
        FsId[] ids = fetchBatchList.toArray(new FsId[0]);
        IntTimeSeries[] newSeries = pixelTimeSeriesReader.readTimeSeriesAsInt(ids, startCadence, endCadence);
        queue.addAll(Arrays.asList(newSeries));
        
    }

    /** The current cache size. */
    int cacheSize() {
        return queue.size();
    }
    
}
