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

import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.scheduler.FsIdLocation;
import gov.nasa.kepler.fs.server.scheduler.FsIdOrder;

import java.io.IOException;
import java.util.Collection;
import java.util.Set;

public interface StorageAllocatorInterface {

    public FsIdLocation locationFor(FsIdOrder id) throws IOException,
            FileStoreException, InterruptedException;

    public void close() throws IOException;

    /**
     * When a commit has completed mark the specified Ids as committed.
     * 
     * @param ids If a specified id is not known then this does nothing.
     * @throws IOException
     * @throws InterruptedException 
     */
    public void markIdsPersistent(Collection<FsId> ids)
            throws IOException, InterruptedException;

    public void commitPendingModifications() throws IOException,
            InterruptedException;

    /**
     * Removes all the ids that have not been made persistent with the
     * markIdPersistent method.
     * 
     * @param ids This may be null in which case it means all ids. Or it may
     * contain ids not maintained by this storage allocator in which case it
     * will be ignored.
     * @throws IOException
     * @throws InterruptedException 
     */
    public void removeAllNewIds(final Collection<FsId> ids)
            throws IOException, InterruptedException;

    public void removeAllNewIds() throws IOException,
            InterruptedException;

    /**
     * File ids.
     */
    public Set<FsId> findIds();

    public Set<FsId> findNewIds();

    public boolean hasSeries(FsId id) throws IOException,
            InterruptedException;

    /**
     * Remove the specified file by id. If this does not exist then nothing is
     * done.
     * 
     * @param xfile
     * @throws InterruptedException 
     */
    public void removeId(FsId id) throws IOException,
            InterruptedException;

    /**
     * Checks if the id is new, that is has not been committed.
     * 
     * @return true if the id does not exist or has not been committed.
     * @throws IOException
     * @throws InterruptedException 
     */
    public boolean isNew(FsId id) throws IOException,
            InterruptedException;

    /**
     * Actually checks that the storage is allocated for the specified id in the
     * Container file.
     * 
     * @return
     * @throws IOException
     * @throws InterruptedException
     */
    public boolean isAllocated(FsId id) throws IOException,
            InterruptedException;

    /**
     * Finds files which lack references and removes them from the file system.
     * 
     * @throws IOException
     * @throws InterruptedException 
     */
    public void gcFiles() throws IOException, InterruptedException;

    public boolean doesStorageTrackLength();

    public void setNewState(FsId id, boolean b) throws IOException, InterruptedException;

}