/**
 * $Source$
 * $Date: 2017-07-27 10:04:13 -0700 (Thu, 27 Jul 2017) $
 * 
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
package gov.nasa.kepler.fs.api;

import gov.nasa.kepler.fs.api.gen.*;
import gov.nasa.kepler.fs.client.util.PersistableXid;

import java.io.File;
import java.io.OutputStream;

/**
 * Unless otherwise specified methods may be used without an active
 * transaction.
 * 
 * @author Jason Brittain jbrittain@mail.arc.nasa.gov
 * @author Sean McCauliff
 */
public interface BlobClient {

    /**
     * Client sends a blob to the file store for writing.
     * 
     * @param id
     * @param origin The id of the pipeline task that generated this data. This
     * is used for data accountability purposes.
     * @param fileData
     * @throws FileStoreException
     */
    @ImplicitParameter(name="xid",type=PersistableXid.class)
    @NeedClientEncoding
    @NeedServerDecoding
    void writeBlob(FsId id, long origin, byte[] fileData);

    /**
     * Write a blob of data into the specified id.  The returned stream must be
     * closed before a commit or rollback can happen.
     * 
     * @param id
     * @param origin
     * @return
     * @throws FileStoreException
     */
    @ImplicitParameter(name="xid",type=PersistableXid.class)
    @IgnoreClientGeneration
    @NeedServerDecoding
    OutputStream writeBlob(FsId id, long origin);
    
    /**
     * Writes the contents of a file into a blob.  This is faster than other
     * methods of transferring files.
     */
    @IgnoreClientGeneration
    @NeedServerDecoding
    void writeBlob(FsId id, long origin, File src);
    
    /**
     * Client requests a blob from the file store.  This method may
     * be used without an active transaction.
     * 
     * @param id
     * @param size
     * @return
     * @throws FileStoreException
     */
    @ImplicitParameter(name="xid",type=PersistableXid.class)
    @NeedServerDecoding
    BlobResult readBlob(FsId id);

    /**
     * Read a blob.
     */
    @ImplicitParameter(name="xid",type=PersistableXid.class)
    @IgnoreClientGeneration
    @NeedServerDecoding
    StreamedBlobResult readBlobAsStream(FsId id);
    
    /**
     * Read a blob into a file.  This is faster than other methods if the
     * intended destination is a file.
     */
    @IgnoreClientGeneration
    @NeedServerDecoding
    long readBlob(FsId id, File dest);
    
    /**
     * Client checks for the existence of a blob with the specified id.  This
     * method may be used without an active transaction.
     * 
     * @param id
     * @return
     * @throws FileStoreException
     */
    @ImplicitParameter(name="xid",type=PersistableXid.class)
    boolean blobExists(FsId id);
    
    /**
     * Transactionally deletes a blob.
     */
    @ImplicitParameter(name="xid",type=PersistableXid.class)
    void deleteBlob(FsId id);
}
