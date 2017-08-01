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

package gov.nasa.kepler.cal;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.spiffy.common.intervals.SimpleInterval;

import java.util.Arrays;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import com.google.common.collect.Lists;

/**
 * Groups pixels by row and then into chunks.
 * 
 * @author Sean McCauliff
 *
 */
public final class PixelRowIterator implements Iterator<List<FsId>>, Iterable<List<FsId>>{

    private final List<List<FsId>>chunksOfPixels;
    private final Iterator<List<FsId>> chunkIt;

    /**
     * Only use this constructor for testing.
     * @param tnbPixels all target and background pixels.
     * @param maxPixels The maximum number of pixels per chunk.  A
     * positive integer.  Zero means this we will chunk by rows.
     */
    public PixelRowIterator(Set<Pixel> tnbPixels, int maxPixels) {
        
        if (maxPixels < 0) {
            throw new IllegalArgumentException("maxPixels == "
                + maxPixels + ", but it must be a positive integer.");
        }
        if (tnbPixels.isEmpty()) {
            chunksOfPixels = Collections.emptyList();
            chunkIt = chunksOfPixels.iterator();
            return;
        }
        Pixel[] sortedPixels = new Pixel[tnbPixels.size()];
        tnbPixels.toArray(sortedPixels);
        Arrays.sort(sortedPixels, PixelByRowCol.INSTANCE);
        
        chunksOfPixels = Lists.newArrayList();
        
        List<SimpleInterval> startStopIndicesByRow = 
            Lists.newArrayListWithCapacity(FcConstants.CCD_ROWS + 1);
        int currentRowStartIndex = -1;
        int currentRowEndIndex = -1;
        Pixel prevPixel = new Pixel(-1, 0);
        
        for (int i=0; i < sortedPixels.length; i++) {
            Pixel px = sortedPixels[i];
            if (px.getRow() != prevPixel.getRow()) {
                startStopIndicesByRow.add(new SimpleInterval(currentRowStartIndex, currentRowEndIndex));
                currentRowStartIndex = i;
            }
            currentRowEndIndex = i;
            prevPixel = px;
        }
        startStopIndicesByRow.add(new SimpleInterval(currentRowStartIndex, currentRowEndIndex));
        
        long currentChunkSize = -1;
        int currentChunkStartIndex = -1;
        int currentChunkEndIndex = -1;
        //Yes, we want to skip the first one.
        for (int i=1; i < startStopIndicesByRow.size(); i++) {
            SimpleInterval rowIndices = startStopIndicesByRow.get(i);
            final long rowSize = rowIndices.end() - rowIndices.start() + 1;
            if (currentChunkSize == -1) {
                currentChunkStartIndex = (int)rowIndices.start();
                currentChunkEndIndex = (int) rowIndices.end();
                currentChunkSize = rowSize;
            } else if ((currentChunkSize + rowSize) > maxPixels) {
                List<FsId> chunk = Lists.newArrayListWithCapacity((int)currentChunkSize);
                for (int sortedPixelIndex=currentChunkStartIndex;
                        sortedPixelIndex <= currentChunkEndIndex;
                        sortedPixelIndex++) {
                    chunk.add(sortedPixels[sortedPixelIndex].getFsId());
                }
                currentChunkSize = 0;
                currentChunkStartIndex = (int) rowIndices.start();
                currentChunkEndIndex = (int) rowIndices.end();
                chunksOfPixels.add(chunk);
            } else {
                currentChunkSize += rowSize;
                currentChunkEndIndex = (int)rowIndices.end();
            }
         }
        List<FsId> chunk = Lists.newArrayListWithCapacity((int)currentChunkSize);
        for (int sortedPixelIndex=currentChunkStartIndex;
                sortedPixelIndex <= currentChunkEndIndex;
                sortedPixelIndex++) {
            chunk.add(sortedPixels[sortedPixelIndex].getFsId());
        }
        chunksOfPixels.add(chunk);
        
        this.chunkIt = chunksOfPixels.iterator();
    }


    @Override
    public boolean hasNext() {
        return chunkIt.hasNext();
    }


    @Override
    public List<FsId> next() {
        return chunkIt.next();
    }
    
    public int nchunks() {
        return chunksOfPixels.size();
    }


    /**
     * @exception UnsupportedOperationException this is always thrown.
     */
    @Override
    public void remove() {
        throw new UnsupportedOperationException();
    }


    @Override
    public Iterator<List<FsId>> iterator() {
        return this;
    }
}
