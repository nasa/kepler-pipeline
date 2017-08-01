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

package gov.nasa.kepler.ar.exporter.binarytable;

import java.io.DataOutput;
import java.io.IOException;
import java.lang.reflect.Array;
import java.util.Collection;
import java.util.Map;

/**
 * @param <K> The key to use to get data in order from a map of key -> data
 * @param <T> The type of the TimeSeries object. This need not be a
 * TimeSeries from gov.nasa.kepler.fs.api.TimeSeries just the source of data
 * for the data copier.
 * @param copier writes data to output
 * @param imageData an ordered list of data, nulls indicate uncollected
 * pixels.
 * 
 * @param dout the output for the image data.
 * @throws IOException
 */

public final class SingleCadenceImageWriter<T> {
    /** Not using a list here because it's actually noticeably slower. */
    private final T[] imageData;
    private final ArrayDataCopier<T> copier;
    private final DataOutput dout;

    public static <K, T> SingleCadenceImageWriter<T> 
    newImageWriter(Collection<K> boundingPixels,
        Map<K, ? extends T> pixelData, ArrayDataCopier<T> copier, DataOutput dout) {
        
        T[] imageData = createImageData(boundingPixels, pixelData);
        return new SingleCadenceImageWriter<T>(imageData, copier, dout);
    }
    
    private SingleCadenceImageWriter(T[] imageData,
        ArrayDataCopier<T> copier, DataOutput dout) {
        this.imageData = imageData;
        this.copier = copier;
        this.dout = dout;
    }

    /**
     * Places image data in an easy to index package.  This assume all values are
     * of the same type.
     */
    @SuppressWarnings("unchecked")
    private static <K, T> T[] createImageData(Collection<K> boundingPixels,
        Map<K, T> pixelData) {
        
        if (pixelData.isEmpty()) {
            return null;
        }
        
        //This can't be set to a zero length array because I don't know the
        //class of T.
        T[] imageData = null;
        for (K someKey : boundingPixels) {
            T someValue = pixelData.get(someKey);
            if (someValue != null) {
                imageData = (T[]) Array.newInstance(someValue.getClass(), boundingPixels.size());
                break;
            }
        }
        if (imageData == null) {
            throw new NullPointerException("Pixels do not have any associated data.");
        }
        
        int i = 0;
        for (K boundingPixel : boundingPixels) {
            T timeSeries = pixelData.get(boundingPixel);
            if (timeSeries != null) {
                imageData[i] = timeSeries;
            }
            i++;
        }
        return imageData;
    }

    /**
     * 
     * @param imageNumber the index into the time series to write.
     * @throws IOException
     */
    public void writeSingleCadenceImage(int imageNumber) throws IOException {
        if (imageData == null) {
            return;
        }
        
        int imageDataSize = imageData.length;
        for (int pixelIndex = 0; pixelIndex < imageDataSize; pixelIndex++) {
            T ts = imageData[pixelIndex];
            if (ts == null) {
                copier.fillNull(dout);
            } else {
                copier.copy(dout, imageNumber, ts);
            }
        }
    }
}