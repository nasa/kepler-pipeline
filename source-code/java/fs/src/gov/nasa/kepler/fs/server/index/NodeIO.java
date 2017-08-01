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

package gov.nasa.kepler.fs.server.index;


import java.io.Closeable;
import java.io.IOException;

/**
 * CRUD for b-tree nodes.
 * 
 * @author Sean McCauliff
 *
 * @param <K> key type
 * @param <V> value type
 */
public interface NodeIO<K,V, T extends TreeNode<K,V>> extends Closeable {
	
    /**
     * Cleans up any resources currently being used. 
     * @throws IOException
     */
    void close() throws IOException;
    
    /**
     * @return A non-negative value.
     * @throws IOException
     */
    long rootNodeAddress() throws IOException;
    
    /**
     * Return a new unused address.
     * @return A non-negative integer.
     * @throws IOException
     */
    long allocateAddress() throws IOException;
    
    /**
     * Queue the specified node for writing.
     * @param node A non-null node that was assigned an address from this
     * particular instance of NodeIO.
     * @throws IOException
     */
    void writeNode(T node) throws IOException;

    /**
     * Reads an node from disk, cache or from the queue of pending writes.
     * @param address
     * @return A non-null reference.
     * @throws IOException
     * @throws java.util.NoSuchElementException This exception is thrown if the
     * specified address does not contain an allocated node.
     */
    T readNode(long address) throws IOException;

    /**
     * Delete a node.  This may queue the delete operation for later.
     * @param deleteMe A non-null reference to a Node allocated by this 
     * particular instance of a NodeIO.
     * @throws IOException
     */
    void deleteNode(T deleteMe) throws IOException;
    
    /**
     * Writes pending changes into permanent storage.  If allocateAddress(),
     * writeNode() or deleteNode() queued changes for later this will flush
     * them to permanent storage.
     */
    void flushPendingModifications() throws IOException ;
    
    /**
     * Allows access to the underlying KeyValueIO implementation.
     * @return A non-null reference.
     */
    KeyValueIO<K,V> keyValueIO();

    /**
     * Implementing this is optional.  If this is not implemented then this
     * should throw an UnsupportedOperationException.
     * 
     * @param newRootAddress
     * @exception UnsupportedOperationException If this is not implemented by
     * subclasses.
     */
    void setRootNodeAddress(long newRootAddress);
}
