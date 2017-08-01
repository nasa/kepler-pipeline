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

import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.nc.NonContiguousReadWrite;

import java.io.IOException;

/**
 * How the TransactionalRandomAccessFile will store data.
 * 
 * @author Sean McCauliff
 *
 */
public interface RandomAccessStorage {

    /**
     * Where to write meta data.
     * @return
     */
    NonContiguousReadWrite metaDataRw() throws IOException;
    
    NonContiguousReadWrite dataRw() throws IOException;
    
    /**
     * @return true if this space was just allocated.
     * @throws IOException 
     * @throws InterruptedException 
     */
    boolean isNew() throws IOException, InterruptedException;
    
    /**
     * When this is called the storage can be unallocated.  This is used to
     * remove files or allocations when a file is rolled back and needs to
     * be deleted.
     * @throws InterruptedException 
     *
     */
    void cleanUp() throws IOException, InterruptedException;
    
    FsId fsId();
    
    /**
     * If new then this marks this id as old.
     * @throws IOException
     * @throws InterruptedException 
     */
    void markOld() throws IOException, InterruptedException;
    
    /**
     * 
     * @param realDelete  when true deallocates this FsId from files else
     * only resets the newState to true.
     * @throws IOException 
     * @throws InterruptedException 
     */
	void delete(boolean realDelete) throws IOException, InterruptedException;
    
	/**
	 * I really hate this method.  It's here to make the lazy initialization of the mjd
	 * time series objects work correctly with having the recovery object use a different
	 * instance of the storage for this object.
	 */
	void initAlreadyDone();
}
