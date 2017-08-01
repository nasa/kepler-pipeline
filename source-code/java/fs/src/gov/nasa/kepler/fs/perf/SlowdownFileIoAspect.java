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

package gov.nasa.kepler.fs.perf;

import java.io.File;
import java.io.RandomAccessFile;
import java.util.concurrent.locks.LockSupport;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;


/**
 * This method will introduce a random wait into file I/O possibly modified
 * by the closeness of the read or write to an existing read or write.
 * This maintains a global cache of reads and writes that have been performed.
 * This cache is used to determine if a read or write has been performed
 * recently and if so how it should modify the delay introduced.
 * 
 * @author Sean McCauliff
 *
 */
@Aspect("pertypewithin(*)")
public class SlowdownFileIoAspect extends SlowdownState {

    private static final Log log = LogFactory.getLog(SlowdownFileIoAspect.class);
    
    private static final boolean isDebugEnabled;
    
    static {
        isDebugEnabled = log.isDebugEnabled();
    }
    
   
    
    /**
     * Match all calls to read or write methods on RandomAccessFile.
     * TODO:  This should also intercept calls to FileInputStream and
     * FileOutputStream, but these methods are usually wrapped by calls to
     * BufferedOutputStream and BufferedInputStream.  This makes life more
     * difficult as modifying classes in java.io.* seems like a bad idea.
     */
    @Pointcut("target(java.io.RandomAccessFile) && " +
              "( call(* read*(*)) || " +
              "  call(* write*(*))" +
              ")")
    public void slowMe() {}
    
    @Before("slowMe()")
    public void slowDown(JoinPoint joinPoint) throws Throwable {
        RandomAccessFile raf = (RandomAccessFile) joinPoint.getTarget();
        long ioAddress = raf.getFilePointer();
        File targetFile = ioInstanceToFile.get(raf);
        long delay = globalDelayModel.delayForFileAndAddress(targetFile, ioAddress);
        String debugId = null;
        if (isDebugEnabled && delay != 0) {
            debugId = "file \"" + targetFile + " and address " + ioAddress;
            log.debug("Delaying I/O to " + debugId + " for " + delay + "ns.");
        }
        if (delay == 0) {
            if (isDebugEnabled) {
                log.debug("I/O delay is zero for \"" + targetFile + "\" and address " + ioAddress);
            }
            return;
        }
        long startNanos = -1;
        if (isDebugEnabled) {
            startNanos = System.nanoTime();
        }
        LockSupport.parkNanos(delay);
        if (isDebugEnabled) {
            long duration = System.nanoTime() - startNanos;
            log.debug("Actual delay for " + debugId + " is " + duration + "ns.");
        }
    }
}
