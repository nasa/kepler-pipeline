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

import gov.nasa.kepler.cal.io.CommonParameters;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.CollateralTimeSeriesOperations;
import gov.nasa.kepler.mc.Pixel;

import java.util.*;

import com.google.common.collect.Lists;

/**
 * Generate the work particles.  This does not fetch any of the time series
 * data associated with those work particles.
 * 
 * @author Sean McCauliff
 *
 */
public class CalWorkParticleFactory {

    private final CommonParameters commonParameters;
    
    
    
    public CalWorkParticleFactory(CommonParameters commonParameters) {
        super();
        this.commonParameters = commonParameters;
    }

    /**
     * Generates a list of collections of work particles.  Each set of work
     * particles in a collection can be executed independently.  But collections
     * of work particles should be executed in the order specified in the list.
     * @return A non-null list.
     */
    public List<List<CalWorkParticle>> create(Set<Pixel> tnbPixels, Map<FsId, Pixel> pixelsByFsId, int maxChunkSize) {
        CollateralTimeSeriesOperations collateralOps = createCollateralTimeSeriesOps();
        Set<FsId> maskedSmearIds = collateralOps.getMaskedSmearFsIds();
        Set<FsId> virtualSmearIds = collateralOps.getVirtualSmearFsIds();
        Set<FsId> blackLevelIds = collateralOps.getBlackLevelFsIds();
        Set<FsId> maskedBlackIds = collateralOps.getMaskedBlackFsIds();
        Set<FsId> virtualBlackIds = collateralOps.getVirtualBlackFsIds();
        Set<FsId> collateralFsIds = collateralOps.getCollateralFsIds();
        
        int totalPixels = tnbPixels.size() + collateralFsIds.size();
        if (totalPixels == 0) {
            return Collections.emptyList();
        }
        
        PixelRowIterator chunkIt =  new PixelRowIterator(tnbPixels, maxChunkSize);
        int lastIteration = chunkIt.nchunks();
        int totalParticles = lastIteration + 1;
        
        CollateralWorkParticle collateralWork = 
            new CollateralWorkParticle(commonParameters, 0, totalParticles, maskedSmearIds,
                virtualSmearIds, blackLevelIds, maskedBlackIds, virtualBlackIds,
                collateralFsIds, totalPixels);
        
        //Can't use ImmutableList.of() here b/c we need a list of a super class
        //type.
        List<CalWorkParticle> collateralWorkList = Lists.newArrayListWithCapacity(1);
        collateralWorkList.add(collateralWork);
        
       
        int iteration = 1;

        List<List<CalWorkParticle>> workParticles = 
            Lists.newArrayListWithCapacity(3);
        workParticles.add(collateralWorkList);
        
        List<CalWorkParticle> canBeExecutedInParallel = Lists.newArrayList();
        workParticles.add(canBeExecutedInParallel);

        for (List<FsId> fsIdChunk : chunkIt) {
            boolean lastIterationFlag = lastIteration == iteration;
            TargetAndBackgroundWorkParticle tnbWork = 
                new TargetAndBackgroundWorkParticle(commonParameters,
                    iteration++, totalParticles,
                    fsIdChunk, lastIterationFlag, totalPixels, pixelsByFsId,
                    collateralWork);
            if (lastIterationFlag) {
                List<CalWorkParticle> lastList = Lists.newArrayListWithCapacity(1);
                lastList.add(tnbWork);
                workParticles.add(lastList);
            } else {
                canBeExecutedInParallel.add(tnbWork);
            }
        }
        
        return workParticles;
    }
    
    protected CollateralTimeSeriesOperations createCollateralTimeSeriesOps() {
        return new CollateralTimeSeriesOperations(commonParameters.cadenceType(), 
            commonParameters.targetTable().getExternalId(),
            commonParameters.ccdModule(), commonParameters.ccdOutput());
    }

}
