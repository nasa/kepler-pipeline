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

import gov.nasa.kepler.fs.api.gen.*;
import gov.nasa.kepler.fs.client.util.PersistableXid;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Save/store MjdTimeSeries.  
 * 
 * @author Sean McCauliff
 *
 */
public interface MjdTimeSeriesClient {

    /**
     * Transactionally reads cosmic ray series.
     * 
     * @param ids  may not be null.
     * @param startMjd Modified julian day, inclusive.
     * @param endMjd Modified julian dat, inclusive
     * @return An array of CosmicRaySeries,  If ids is zero length then this
     * will be zero length.  Furthermore return[i].id() == ids[i].  If the cosmic 
     * ray series would not contain any data between start and end then
     * the series returned will have arrays of length zero, but the exists flag
     * will be set to true.  If the id does not exist then the series returned will
     * have exists set to false.
     * 
     * @throws Exception
     */
    @ImplicitParameter(name="xid",type=PersistableXid.class)
    public FloatMjdTimeSeries[] readMjdTimeSeries(FsId[] ids, double startMjd, double endMjd);
    
    /**
     * 
     * @param ids May not be null.
     * @return An array of CosmicRaySeries,  If ids is zero length then this
     * will be zero length.  Furthermore return[i].id() == ids[i].  If the cosmic 
     * ray series would not contain any data between start and end then
     * the series returned will have arrays of length zero, but the exists flag
     * will be set to true.  If the id does not exist then the series returned will
     * have exists set to false.  Returned series may not all have the same
     * mjdStart and mjdEnd times.
     * @throws FileStoreException
     */
    @ImplicitParameter(name="xid",type=PersistableXid.class)
    public FloatMjdTimeSeries[] readAllMjdTimeSeries(FsId[] ids);
    
    
    @ImplicitParameter(name="xid",type=PersistableXid.class)
    @NeedServerDecoding
    @NeedClientEncoding
    public List<MjdTimeSeriesBatch> readMjdTimeSeriesBatch(List<MjdFsIdSet> mjdFsIdSetList);
    
    @IgnoreClientGeneration
    @IgnoreServerGeneration
    public Map<FsId, FloatMjdTimeSeries> readMjdTimeSeries(Collection<FsId> fsId, double startMjd, double endMjd);
    
    /**
     *  As writeMjdtimeSeries(series, overwrite=true);
     * 
     * @param cosmicRaySeries  This may not be null.
     * @throws Exception
     */
    @ImplicitParameter(name="xid",type=PersistableXid.class)
    @IgnoreClientGeneration
    @IgnoreServerGeneration
    public void writeMjdTimeSeries(FloatMjdTimeSeries[] series);
    
    /**
     * Transactionally writes or overwrites cosmic ray series.  New series will 
     * be created as
     * as needed.  When overwrite is true all data points between 
     * cosmicRaySeries[i].start and cosmicRaySeries[i].end will be erased 
     * and replaced with the new  information.  In this way old data points in
     * the specified interval can be erased.
     * 
     * @param cosmicRaySeries  This may not be null.
     * @param overwrite see above.
     * @throws Exception
     */
    @ImplicitParameter(name="xid",type=PersistableXid.class)
    @NeedServerDecoding
    @NeedClientEncoding
    public void writeMjdTimeSeries(FloatMjdTimeSeries[] series, boolean overwrite);
    
    /**
     * Lists all the cosmic ray series non-Transactionally.
     * @param prefix List all the FsIds that are in the path part of this FsId.
     */
    public Set<FsId> listMjdTimeSeries(FsId prefix);
    
    /**
     * Transactionally removes the specified  MjdTimeSeries.
     * @param ids
     * @throws FileStoreException
     */
    @ImplicitParameter(name="xid",type=PersistableXid.class)
    void deleteMjdTimeSeries(FsId[] ids);
    
}
