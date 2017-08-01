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

package gov.nasa.kepler.cal;

import gov.nasa.kepler.cal.ffi.FfiModOut;
import gov.nasa.kepler.cal.io.BlackTimeSeries;
import gov.nasa.kepler.cal.io.CalInputsFactory;
import gov.nasa.kepler.cal.io.CommonParameters;
import gov.nasa.kepler.cal.io.SingleBlackTimeSeries;
import gov.nasa.kepler.cal.io.SmearTimeSeries;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.mc.FitsImage;


import java.util.*;


import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

import static gov.nasa.kepler.cal.DataPresentEnum.*;

/**
 *  Retrieves the collateral pixel time series for the first invocation of cal.
 *  If data is not available (think mod 3 or short cadence mod/out without targets)
 *  then hasData() will return false.
 *  
 * @author Sean McCauliff
 *
 */
class CollateralWorkParticle extends CalWorkParticle {

    private static final Log log = LogFactory.getLog(CollateralWorkParticle.class);
    
    private final Set<FsId> maskedSmearIds;
    private final Set<FsId> virtualSmearIds;
    private final Set<FsId> blackLevelIds;
    private final Set<FsId> maskedBlackIds;
    private final Set<FsId> virtualBlackIds;
    private final Set<FsId> collateralFsIds;
    private final int totalPixels;
    
    /**
     * 
     * @param commonParameters
     * @param iteration
     * @param maskedSmearIds
     * @param virtualSmearIds
     * @param blackLevelIds
     * @param maskedBlackIds
     * @param virtualBlackIds
     * @param collateralFsIds
     * @param totalPixels the sum of the unique target, background and collateral pixels
     */
    public CollateralWorkParticle(CommonParameters commonParameters,
        int invocation, int maxInvocations,
        Set<FsId> maskedSmearIds, Set<FsId> virtualSmearIds,
        Set<FsId> blackLevelIds, Set<FsId> maskedBlackIds,
        Set<FsId> virtualBlackIds,
        Set<FsId> collateralFsIds,
        int totalPixels) {
        super(commonParameters, invocation, maxInvocations);

        this.maskedBlackIds = maskedBlackIds;
        this.virtualBlackIds = virtualBlackIds;
        this.blackLevelIds = blackLevelIds;
        this.maskedSmearIds = maskedSmearIds;
        this.virtualSmearIds = virtualSmearIds;
        this.collateralFsIds = collateralFsIds;
        this.totalPixels = totalPixels;
    }

    public int nPixels() {
        return collateralFsIds.size();
    }
    
    /**
     * @return This will return null if all the data needed to process the work
     * particle is missing.
     */
    @Override
    public CalWorkParticle call() throws Exception {

        log.info("Getting collateral data for mod/out " 
            + commonParameters.ccdModule() + "/" + commonParameters.ccdOutput() + ".");
        Set<Long> producerTaskIds = Sets.newHashSet();

        if (collateralFsIds.isEmpty()) {
            return this;
        }
        
        Map<FsId, TimeSeries> allTimeSeries = 
            fsClient().readTimeSeries(collateralFsIds, commonParameters.startCadence(), commonParameters.endCadence(), true);
        
        for (TimeSeries ts : allTimeSeries.values()) {
            producerTaskIds.addAll(ts.uniqueOriginators());
        }
        
        boolean enableCoarsePointProcessing = commonParameters.moduleParametersStruct().isEnableCoarsePointProcessing();
        boolean[] isFinePt = commonParameters.cadenceTimes().isFinePnt;
        
        List<SmearTimeSeries> maskedSmearPixels = Lists.newArrayListWithCapacity(maskedSmearIds.size());
        boolean hasMaskedSmear = false;
        for (FsId id : maskedSmearIds) {
            TimeSeries ts = allTimeSeries.get(id);
            maskedSmearPixels.add(new SmearTimeSeries(ts));
            hasMaskedSmear |= !isEmpty(ts, isFinePt, enableCoarsePointProcessing);
        }
        
        List<SmearTimeSeries> virtualSmearPixels = Lists.newArrayListWithCapacity(virtualSmearIds.size());
        boolean hasVirtualSmear = false;
        for (FsId id : virtualSmearIds) {
            TimeSeries ts = allTimeSeries.get(id);
            virtualSmearPixels.add(new SmearTimeSeries(ts));
            hasVirtualSmear |= !isEmpty(ts, isFinePt,  enableCoarsePointProcessing);
        }
        
        List<BlackTimeSeries> blackLevelPixels = Lists.newArrayListWithCapacity(blackLevelIds.size());
        boolean hasBlackLevel = false;
        for (FsId id : blackLevelIds) {
            TimeSeries ts = allTimeSeries.get(id);
            blackLevelPixels.add(new BlackTimeSeries(ts));
            hasBlackLevel |= !ts.isEmpty();
        }
        
        List<SingleBlackTimeSeries> maskedBlackPixels = Lists.newArrayListWithCapacity(maskedBlackIds.size());
        boolean hasMaskedBlack = false;
        for (FsId id : maskedBlackIds) {
            IntTimeSeries its = allTimeSeries.get(id).asIntTimeSeries();
            maskedBlackPixels.add(new SingleBlackTimeSeries(its.iseries(), its.getGapIndicators()));
            hasMaskedBlack |= !isEmpty(its, isFinePt,  enableCoarsePointProcessing);
        }
        
        List<SingleBlackTimeSeries> virtualBlackPixels = Lists.newArrayListWithCapacity(virtualBlackIds.size());
        boolean hasVirtualBlack = false;
        for (FsId id : virtualBlackIds) {
            IntTimeSeries its = allTimeSeries.get(id).asIntTimeSeries();
            virtualBlackPixels.add(new SingleBlackTimeSeries(its.iseries(), its.getGapIndicators()));
            hasVirtualBlack |= !isEmpty(its, isFinePt,  enableCoarsePointProcessing);
        }
        
        super.producerTaskIds = ImmutableSet.copyOf(producerTaskIds);
        
        
        if (commonParameters.cadenceType() == CadenceType.SHORT) {
            if (!(hasMaskedSmear && hasVirtualSmear && hasBlackLevel && hasMaskedBlack && hasVirtualBlack)) {
                log.warn("Missing collateral data. " + 
                    " hasMaskedSmear " + hasMaskedSmear +
                    " hasVirtualSmear " + hasVirtualSmear + 
                    " hasBlackLevel " + hasBlackLevel +
                    " hasMaskedBlack " + hasMaskedBlack + 
                    " hasVirtualBlack " + hasVirtualBlack);
                hasData = DataMissing;
            } else {
                hasData = DataPresent;
            }
        } else {
            if (!(hasMaskedSmear && hasVirtualSmear && hasBlackLevel)) {
                log.warn("Missing collateral data.  " + 
                    " hasMaskedSmear " + hasMaskedSmear +
                    " hasVirtualSmear " + hasVirtualSmear + 
                    " hasBlackLevel " + hasBlackLevel);
                hasData = DataMissing;
            } else {
                hasData = DataPresent;
            }
        } 
        
        if (!commonParameters.emptyParameters() && hasData == DataPresent) {
            PixelVerifier pixelVerifier = createPixelVerifier();
            pixelVerifier.verify(allTimeSeries.values());
        }
       
        List<FitsImage> ffis = Lists.newArrayList();
        if (hasData == DataPresent) {
            for (FfiModOut ffiModOut : commonParameters.ffiModOut()) {
                FitsImage fitsImage = ffiModOut.toFitsImage();
                ffis.add(fitsImage);
            }
        }
       
        
        CalInputsFactory calInputsFactory = calInputsFactory();
        if (commonParameters.cadenceType() == CadenceType.SHORT) {
            calInputs = calInputsFactory.createShortCadenceCollateral(commonParameters,
                super.totalParticles, maskedSmearPixels, virtualSmearPixels,
                blackLevelPixels, maskedBlackPixels, virtualBlackPixels,
                ffis, hasData);
            if (hasData == DataPresent) {
                calInputs.setOneDBlackBlobs(commonParameters.oneDBlackBlobs());
            }
        } else {
            calInputs = calInputsFactory.createLongCadenceCollateral(commonParameters,
                super.totalParticles,
                maskedSmearPixels, virtualSmearPixels,
                blackLevelPixels, ffis, hasData);
        }
        
        calInputs.setTotalPixels(totalPixels);

        return this;
    }
    
    @Override
    public String toString() {
        StringBuilder bldr = new StringBuilder();
        bldr.append("Cal collateral mod/out ").append(commonParameters.ccdModule()).append("/").append(commonParameters.ccdOutput());
        bldr.append(" [start,end] cadence [").append(commonParameters.startCadence()).append(",").append(commonParameters.endCadence()).append(']');
        return bldr.toString();
    }
   
    protected FileStoreClient fsClient() {
        return FileStoreClientFactory.getInstance();
    }

    protected PixelVerifier createPixelVerifier() {
        return new PixelVerifier(commonParameters.requantTables(), commonParameters.cadenceTimes());
    }

}
