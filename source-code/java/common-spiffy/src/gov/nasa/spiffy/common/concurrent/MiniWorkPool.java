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

package gov.nasa.spiffy.common.concurrent;

import java.io.IOException;
import java.util.Collection;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.atomic.AtomicReference;

/**
 * Runs every unit of work in parallel, up to the number of processors available.
 * 
 * @author Sean McCauliff
 * 
 * @param <W> The unit of work
 *
 */
public class MiniWorkPool<W> {
    private final AtomicReference<Throwable> error = new AtomicReference<Throwable>();
    private final List<W> workQueue;
    private final MiniWorkFactory<W> factory;
    private final String prefix;

    public MiniWorkPool(String prefix, Collection<W> initWork, final MiniWork<W> miniwork) {
        this.workQueue = Collections.synchronizedList(new LinkedList<W>(initWork));
        this.factory = new MiniWorkFactory<W>() {
            @Override
            public MiniWork<W> createMiniWork() {
                return miniwork;
            }
        };
        this.prefix = prefix;
    }
    
    public MiniWorkPool(String prefix, Collection<W> initWork, MiniWorkFactory<W> factory) {
        this.workQueue = Collections.synchronizedList(new LinkedList<W>(initWork));
        this.factory = factory;
        this.prefix = prefix;
    }

    public void performAllWork() throws InterruptedException, IOException {
        Thread[] threads = new Thread[Runtime.getRuntime().availableProcessors()];
        for (int i=0; i < threads.length; i++) {
            MiniWork<W> miniwork = factory.createMiniWork();
            miniwork.setError(this.error);
            miniwork.setWorkQueue(this.workQueue);
            threads[i] = new Thread(miniwork, prefix + " - " + i);
            threads[i].start();
        }

        for (Thread t : threads) {
            t.join();
        }

        if (error.get() != null) {
            if (error.get() instanceof IOException) {
                throw (IOException) error.get();
            }
            throw new IllegalStateException("thread pool error", error.get());
        }
    }
}
