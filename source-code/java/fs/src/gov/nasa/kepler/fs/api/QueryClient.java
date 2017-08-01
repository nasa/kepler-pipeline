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

package gov.nasa.kepler.fs.api;

import gov.nasa.kepler.fs.api.gen.ImplicitParameter;
import gov.nasa.kepler.fs.client.util.PersistableXid;

import java.util.Set;

/**
 * Describes methods which will return FsIds based on query strings.  This 
 * applies to all the data types used by the file store.
 * 
 * @author Sean McCauliff
 *
 */
public interface QueryClient {

    /**
     * Use queryIds2 instead.
     * 
     * @param queryString  TODO: FsId query specification.
     * @return If no FsIds match the query then this returns an empty set.
     * @throws FileStoreException  If the query string is poorly formed.
     */
    @ImplicitParameter(name = "xid", type = PersistableXid.class)
    @Deprecated
    Set<FsId> queryIds(String queryString);
    
    
    /**
     *  Finds a set of FsIds that match the query string.  This method is
     *  currently non-transactional and may return non existent FsIds.  This
     *  is a faster, more memory efficient implementation of queryIds.
     * 
     * @param queryString  TODO: FsId query specification.
     * @return If no FsIds match the query then this returns an empty set.
     * @throws FileStoreException  If the query string is poorly formed.
     */
    @ImplicitParameter(name = "xid", type = PersistableXid.class)
    Set<FsId> queryIds2(String queryString);
    
    /**
     * Finds a set of FsId paths which match the query string.  This is
     * currently non-transactional and may return non existent FsIds.
     * 
     * @param queryString TODO: FsId query specification.
     * @return If no paths match the query then this returns an empty set.
     * @throws FileStoreException  If the query string is poorly formed.
     */
    Set<FsId> queryPaths(String queryString);
}
