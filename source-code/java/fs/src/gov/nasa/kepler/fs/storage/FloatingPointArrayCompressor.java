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

package gov.nasa.kepler.fs.storage;

import static gov.nasa.spiffy.common.io.LongEncoder.*;

import gov.nasa.kepler.fs.api.*;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.io.DataOutputStream;

import java.io.*;
import java.util.*;

/**
 * This is just some fun compression stuff that is not currently used in the file
 * store code.  It separates the mantissa from the floating point value and
 * subtracts this from the previous value.  The exponent and the mantissa
 * difference are written out using a variable byte length encoding.  This is
 * likely faster than GZIP or BZIP2, but not giving as good compression  ratio
 * as either of those algorithms.  Combined with GZIP or BZIP2 this yields better
 * compression ratio than either one of them can obtain alone.
 * 
 * @author Sean McCauliff   
 *
 */
public final class FloatingPointArrayCompressor {

    private static final int SINGLE_MANTISSA_MASK = 0x001FFFFF;
    private static final int SINGLE_N_MANTISSA_BITS = 23;
    private static final long DOUBLE_MANTISSA_MASK = 0x000FFFFFFFFFFFFFL;
    private static final int DOUBLE_N_MANTISSA_BITS = 52;
    
    public void compress(float[] f, DataOutput dout) throws IOException {
        longToBytes(f.length, dout);
        if (f.length == 0) {
            return;
        }
        
        dout.writeFloat(f[0]);
        if (f.length == 1) {
            return;
        }
        
        final int firstFloatAsInt = Float.floatToRawIntBits(f[0]);
        int prevSignAndExponent = firstFloatAsInt >>> SINGLE_N_MANTISSA_BITS;
        int prevMantissa = reverseSignAndExponent(firstFloatAsInt);
        for (int i=1; i < f.length; i++) {
            int floatAsInt = Float.floatToRawIntBits(f[i]);
            int signAndExponent = reverseSignAndExponent(floatAsInt);
            int mantissa = floatAsInt & SINGLE_MANTISSA_MASK;
            longToBytes(mantissa - prevMantissa, dout);
            longToBytes(signAndExponent - prevSignAndExponent, dout);
            prevSignAndExponent = signAndExponent;
            prevMantissa = mantissa;
        }
    
    }
    
    public void compress(double[] d, DataOutput dout) throws IOException {
        longToBytes(d.length, dout);
        if (d.length == 0) {
            return;
        }
        
        dout.writeDouble(d[0]);
        if (d.length == 1) {
            return;
        }
        
        long firstDoubleAsLong = Double.doubleToRawLongBits(d[0]);
        long prevSignAndExponent = reverseSignAndExponent(firstDoubleAsLong);
        long prevMantissa = firstDoubleAsLong >>> DOUBLE_MANTISSA_MASK;
        for (int i=1; i < d.length; i++) {
            long doubleAsLong = Double.doubleToRawLongBits(d[i]);
            long signAndExponent = reverseSignAndExponent(doubleAsLong);
            long mantissa = doubleAsLong & DOUBLE_MANTISSA_MASK;
            longToBytes(mantissa - prevMantissa, dout);
            longToBytes(signAndExponent - prevSignAndExponent, dout);
            prevSignAndExponent = signAndExponent;
            prevMantissa = mantissa;
        }
    }
    
    private static int signAndExponentBits(int floatAsInt) {
        return floatAsInt >>> SINGLE_N_MANTISSA_BITS;
    }
    
    private static long signAndExponentBits(long doubleAsLong) {
        return doubleAsLong >>> DOUBLE_N_MANTISSA_BITS;
    }
    
    /**
     * Reverse the sign and exponent bits.
     * @param doubleAsLong
     * @return
     */
    private static long reverseSignAndExponent(long doubleAsLong) {
        return doubleAsLong >>> 63 | ((signAndExponentBits(doubleAsLong) & ~0x400) << 1);
    }
    
    /**
     * Put the sign as the lower order bit.
     * @param floatAsInt
     * @return
     */
    private static int reverseSignAndExponent(int floatAsInt) {
        return floatAsInt >>> 31 | ((signAndExponentBits(floatAsInt) & ~0x100) << 1);
    }
    
    
    public static void main(String[] argv) throws Exception {
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        
        int startCadence = Integer.parseInt(argv[0]);
        int endCadence = Integer.parseInt(argv[1]);
        
        Set<FsId> fsIds = new HashSet<FsId>();
        
        for (int i=2; i < argv.length; i++) {
           fsIds.add(new FsId(argv[i]));
        }
        
        FsIdSet fsIdSet = new FsIdSet(startCadence, endCadence, fsIds);
        List<TimeSeriesBatch> tsBatch = fsClient.readTimeSeriesBatch(Collections.singletonList(fsIdSet), true);
        Collection<TimeSeries> timeSeriesCollection = tsBatch.get(0).timeSeries().values();
   
        
        FloatingPointArrayCompressor compressor = new FloatingPointArrayCompressor();
        
        DataOutputStream udout = new DataOutputStream(new BufferedOutputStream(new FileOutputStream("ufcompress")));
        
        DataOutputStream dout = new DataOutputStream(new BufferedOutputStream(new FileOutputStream("fcompress")));
        for (TimeSeries ts : timeSeriesCollection ) {
            udout.writeInt(ts.cadenceLength());
            if (ts instanceof DoubleTimeSeries) {
                double[] d = ((DoubleTimeSeries)ts).dseries();
                for (int i=0; i < d.length; i++) {
                    udout.writeDouble(d[i]);
                }
                compressor.compress(d, dout);
            } else {
                float[] f = ((FloatTimeSeries)ts).fseries();
                for (int i=0; i < f.length; i++) {
                    udout.writeFloat(f[i]);
                }
                compressor.compress(f, dout);
            }
        }
        udout.close();
        dout.close();
        
    }
}
