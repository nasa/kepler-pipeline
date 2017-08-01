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

package gov.nasa.kepler.ar.exporter;

import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.mc.fs.DynablackFsIdFactory;
import gov.nasa.kepler.mc.fs.DynablackFsIdFactory.ParsedRollingBandId;

import java.util.Collection;
import java.util.Map;

import com.google.common.base.Predicate;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Maps;

/**
 * A holder for the rolling band flags that are generated for dynablack.
 * 
 * @author Sean McCauliff
 *
 */
public class RollingBandFlags {

    /**
     * A key for rolling rolling band related information.
     *
     */
    public static final class RollingBandKey implements Comparable<RollingBandKey> {
        private final int durationLc;
        private final int ccdRow;
        private final FsId flagId;
        
        public RollingBandKey(int durationLc, int ccdRow, int ccdModule, int ccdOutput) {
            this.durationLc = durationLc;
            this.ccdRow = ccdRow;
            this.flagId = DynablackFsIdFactory
                .getRollingBandArtifactVariationFsId(ccdModule, ccdOutput, ccdRow, durationLc);
        }
        
        public int durationLc() {
            return durationLc;
        }
        
        public int ccdRow() {
            return ccdRow;
        }
        
        public FsId id() {
            return flagId;
        }
        
        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime * result + ccdRow;
            result = prime * result + durationLc;
            return result;
        }
        @Override
        public boolean equals(Object obj) {
            if (this == obj)
                return true;
            if (obj == null)
                return false;
            if (getClass() != obj.getClass())
                return false;
            RollingBandKey other = (RollingBandKey) obj;
            if (ccdRow != other.ccdRow)
                return false;
            if (durationLc != other.durationLc)
                return false;
            return true;
        }

        /**
         * Order by row and then duration
         */
        @Override
        public int compareTo(RollingBandKey other) {
            int diff = this.ccdRow - other.ccdRow;
            if (diff != 0) {
                return diff;
            }
            return this.durationLc - other.durationLc;
        }
    }
    
    private final Map<RollingBandKey,byte[]> flags;
    
    /**
     * @param allByteSeries non-null
     */
    public static RollingBandFlags newRollingBandFlags(Collection<FsId> apertureFsIds, Map<FsId, byte[]> allByteSeries) {
        return new RollingBandFlags(allByteSeries, apertureFsIds);
    }
    
    /**
     * Use this constructor when you don't really have targets, but there are rolling band flags.
     * These rolling band flags don't have optimal apertures.
     * @param allTimeSeries  A superset of the all the time series.
     * @param rollingBandIds Just the rolling band flag fsIds.
     */
    public static RollingBandFlags newRollingBandFlags(Map<FsId, TimeSeries> allTimeSeries, Collection<FsId> rollingBandFsIds) {
        Map<FsId, TimeSeries> rbMap = RollingBandFlags.filterBySet(allTimeSeries, rollingBandFsIds);
        Map<FsId, byte[]> rbByteMap = RollingBandFlags.fromAllTimeSeries(rbMap.values());
		RollingBandFlags rbFlags = new RollingBandFlags(rbByteMap, rollingBandFsIds);
        return rbFlags;
    }
    
    
    private RollingBandFlags(Map<FsId, byte[]> allRbFlags, Collection<FsId> aperture) {
        
        ImmutableMap.Builder<RollingBandKey, byte[]> bldr = 
            new ImmutableMap.Builder<RollingBandKey, byte[]>();
       
        for (FsId apertureId : aperture) {
            byte[] flags = allRbFlags.get(apertureId);
            ParsedRollingBandId durationAndRow = DynablackFsIdFactory.getRollingBandDuration(apertureId);
            RollingBandKey rbKey = 
                new RollingBandKey(durationAndRow.duration, durationAndRow.row, durationAndRow.ccdModule, durationAndRow.ccdOutput);
            bldr.put(rbKey, flags);
        }
        
        flags = bldr.build();
    }
    
    
    public Map<RollingBandKey, byte[]> flags() {
        return flags;
    }
    
    /**
     * 
     * @param allRbTimeSeries  non-null
     * @return
     */
    public static Map<FsId, byte[]> fromAllTimeSeries(Collection<TimeSeries> allRbTimeSeries) {
        Map<FsId, byte[]> allRbSeries = Maps.newHashMapWithExpectedSize(allRbTimeSeries.size());
        for (TimeSeries ts : allRbTimeSeries) {
            IntTimeSeries rbSeries = ts.asIntTimeSeries();
            int[] origSeries = rbSeries.iseries();
            byte[] flagSeries = new byte[rbSeries.length()];
            for (int i=0; i < flagSeries.length; i++) {
                flagSeries[i] = (byte) (origSeries[i] & 0xff);
            }
            allRbSeries.put(ts.id(), flagSeries);
        }
        return allRbSeries;
    }
    
    public static <T extends TimeSeries> Map<FsId,T> filterBySet(Map<FsId, T> unfiltered, final Collection<FsId> inSet) {
       return Maps.filterKeys(unfiltered, new Predicate<FsId>() {

        @Override
        public boolean apply(FsId input) {
            return inSet.contains(input);
        }
       });
    }
}
