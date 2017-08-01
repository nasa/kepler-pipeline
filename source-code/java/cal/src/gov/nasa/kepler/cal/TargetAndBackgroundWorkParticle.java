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

import java.util.*;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

import gov.nasa.kepler.cal.ffi.FfiModOut;
import gov.nasa.kepler.cal.io.CalInputPixelTimeSeries;
import gov.nasa.kepler.cal.io.CommonParameters;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.mc.FitsImage;
import gov.nasa.kepler.mc.Pixel;

import static gov.nasa.kepler.cal.DataPresentEnum.*;

/**
 * Retrieves a chunk of target and background pixel time series from the file store.
 * If data is not available then hasData() will return false call() has
 * been called.
 * @author Sean McCauliff
 *
 */
class TargetAndBackgroundWorkParticle extends CalWorkParticle {

    private static final Log log = LogFactory.getLog(TargetAndBackgroundWorkParticle.class);
    
    private final List<FsId> pixelFsIds;
    private final boolean lastIteration;
    private final int totalPixels;
    private final Map<FsId, Pixel> pixelByFsId;
    private final CollateralWorkParticle collateralWorkParticle;

    
    /**
     * 
     * @param commonParameters
     * @param iteration
     * @param pixelFsIds A list of unique pixel ids.
     * @param lastIteration
     * @param totalPixels total number of unique target, background
     * and collateral pixels.
     * @param pixelByFsId  A mapping from all the fsids to all the pixels in
     * this unit of work, not just this work particle.
     */
    public TargetAndBackgroundWorkParticle(
        CommonParameters commonParameters, int particleNumber, int totalParticles,
        List<FsId> pixelFsIds, boolean lastIteration, int totalPixels,
        Map<FsId, Pixel> pixelByFsId,
        CollateralWorkParticle collateralWorkParticle) {
        super(commonParameters, particleNumber, totalParticles);

        this.pixelFsIds = pixelFsIds;
        this.lastIteration = lastIteration;
        this.totalPixels = totalPixels;
        this.pixelByFsId = pixelByFsId;
        this.collateralWorkParticle = collateralWorkParticle;
    }

    public boolean isLast() {
        return lastIteration;
    }
    
    @Override
    public String toString() {
        if (pixelFsIds.isEmpty()) {
            return "Empty cal target and background pixels.";
        }
        FsId firstFsId = pixelFsIds.get(0);
        FsId lastFsId = pixelFsIds.get(pixelFsIds.size() - 1);
        StringBuilder bldr = new StringBuilder(128);
        bldr.append("Cal target and background pixels, from FsId ").append(firstFsId).append(" to ").append(lastFsId);
        return bldr.toString();
    }
    
    @Override
    public CalWorkParticle call() throws Exception {
        
        log.info("Getting pixel data for " + toString());
        Set<Long> producerTaskIds = Sets.newHashSet();
        Map<FsId, TimeSeries> allSeries =  fsClient().readTimeSeries(pixelFsIds, commonParameters.startCadence(), commonParameters.endCadence(), false);
        List<CalInputPixelTimeSeries> targetAndBackground = Lists.newArrayListWithCapacity(allSeries.size());
        boolean enableCoarsePointProcessing = commonParameters.moduleParametersStruct().isEnableCoarsePointProcessing();
        boolean[] isFinePnt = commonParameters.cadenceTimes().isFinePnt;
        hasData = DataMissing;
        for (FsId id : pixelFsIds) {
            IntTimeSeries uncalSeries = allSeries.get(id).asIntTimeSeries();
            Pixel px = pixelByFsId.get(uncalSeries.id());
            
            CalInputPixelTimeSeries calInputPixelTimeSeries = 
                new CalInputPixelTimeSeries(px, uncalSeries);
            targetAndBackground.add(calInputPixelTimeSeries);
            uncalSeries.uniqueOriginators(producerTaskIds);
            if (hasData == DataMissing && !isEmpty(uncalSeries, isFinePnt, enableCoarsePointProcessing)) {
                log.info("Data Found");
                hasData = DataPresent;
            }
        }
        
        if (collateralWorkParticle.hasData() == DataMissing) {
            log.warn("Collateral data is missing so target and background will also be considered missing.");
            hasData = DataMissing;
        }
        
        List<FitsImage> ffis = Lists.newArrayList();
        if (hasData == DataPresent) {
            int[] distinctRows = distinctRows();
            for (FfiModOut ffiModOut : commonParameters.ffiModOut()) {
                FitsImage fitsImage = ffiModOut.toFitsImage(distinctRows);
                ffis.add(fitsImage);
            }
        }
        calInputs = calInputsFactory().
            createTargetAndBackground(commonParameters, particleNumber(),
                super.totalParticles, targetAndBackground, ffis, hasData);
        calInputs.setLastCall(lastIteration);
        calInputs.setTotalPixels(totalPixels);

        super.producerTaskIds = producerTaskIds;
        return this;
    }
    
    private int[] distinctRows() {
        Set<Integer> rowSet = Sets.newHashSet();
        for (FsId id : pixelFsIds) {
            Pixel px = pixelByFsId.get(id);
            rowSet.add(px.getRow());
        }
        int[] rows = new int[rowSet.size()];
        int i=0;
        for (Integer r : rowSet) {
            rows[i++] = r;
        }
        Arrays.sort(rows);
        return rows;
    }
    
    protected FileStoreClient fsClient() {
        return FileStoreClientFactory.getInstance();
    }
    
    
    protected PixelVerifier createPixelVerifier() {
        return new PixelVerifier(commonParameters.requantTables(), commonParameters.cadenceTimes());
    }
    

}
