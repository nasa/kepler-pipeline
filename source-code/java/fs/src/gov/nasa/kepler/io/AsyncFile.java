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

package gov.nasa.kepler.io;

import java.io.File;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

/**
 * Represents an open asynchronous file.  This exists because JDK 7 is not out yet
 * and I need something to experiment with asynchronous reads.
 * 
 * @author Sean McCauliff
 *
 */
public class AsyncFile {
    
    private final int fd;
    
    public AsyncFile(File f) throws IOException {
        fd = nativeOpenDirect(f.toString());
    }
    
    private native int nativeOpenDirect(String fname) throws IOException;
    
    public Future<ByteBuffer> scheduleRead(ByteBuffer byteBuffer, long off, int len) throws IOException {
        if (byteBuffer == null) {
            throw new NullPointerException("byteBufer may not be null");
        }
        
        if (off < 0) {
            throw new IllegalArgumentException("offset must be greater than or equal to zero.  Got " + off);
        }
        if (len < 0) {
            throw new IllegalArgumentException("len must be greater than or equal to zero.  Got " + off);
        }
        
        long nativeRequestPointer = nativeScheduleRead(byteBuffer, off, len);
        AsyncReadFuture future = new AsyncReadFuture(byteBuffer, nativeRequestPointer);
        
        return future;
    }
    
    private native long nativeScheduleRead(ByteBuffer byteBuffer, long off, int len) throws IOException;

    private native void waitForRequestToComplete(long structAiocbPointer) throws IOException;
    
    public class AsyncReadFuture implements Future<ByteBuffer> {

        private volatile Throwable error;
        private final ByteBuffer byteBuffer;
        /**
         * This is a pointer to a native structure for this io request
         */
        private long structAiocbPointer;
        
        
        private AsyncReadFuture(ByteBuffer byteBuffer, long nativeRequestPointer) {
            this.byteBuffer = byteBuffer;
            this.structAiocbPointer = nativeRequestPointer;
        }

        @Override
        public boolean cancel(boolean mayInterruptIfRunning) {
            throw new IllegalStateException("Not implemented.");
        }

        @Override
        public ByteBuffer get() throws InterruptedException, ExecutionException {
            try {
                waitForRequestToComplete(structAiocbPointer);
            } catch (IOException e) {
                throw new ExecutionException(e);
            }
            return byteBuffer;
        }

        @Override
        public ByteBuffer get(long timeout, TimeUnit unit)
            throws InterruptedException, ExecutionException, TimeoutException {

            throw new IllegalStateException("not implemented");
        }

        @Override
        public boolean isCancelled() {
            return false;
        }

        @Override
        public boolean isDone() {
            throw new IllegalStateException("not implemeneted");
        }
        
    }
}
