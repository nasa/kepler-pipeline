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

package gov.nasa.kepler.mc.blob;

import gnu.trove.TLongHashSet;
import gnu.trove.TLongObjectHashMap;
import gov.nasa.kepler.hibernate.mc.SkyGroupBlob;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Comparator;
import java.util.List;
import java.util.SortedSet;
import java.util.TreeSet;

public class SkyGroupBlobCalculator<T> {

    private final TLongObjectHashMap<SkyGroupBlob> skyGroupIdToBlob = new TLongObjectHashMap<SkyGroupBlob>();

    private final TLongObjectHashMap<SkyGroupBlob> idToBlob = new TLongObjectHashMap<SkyGroupBlob>();

    /**
     * this must be in ascending order.
     */
    private final SortedSet<SkyGroupBlob> sortedByTime;

    public SkyGroupBlobCalculator(Collection<? extends SkyGroupBlob> allBlobs) {
        Comparator<SkyGroupBlob> comp = new Comparator<SkyGroupBlob>() {

            @Override
            public int compare(SkyGroupBlob o1, SkyGroupBlob o2) {
                long diff = o1.getCreationTime() - o2.getCreationTime();
                if (diff < 0) {
                    return -1;
                } else if (diff > 0) {
                    return 1;
                }

                return 0;
            }
        };

        sortedByTime = new TreeSet<SkyGroupBlob>(comp);
        sortedByTime.addAll(allBlobs); // This also removes duplicates.

        for (SkyGroupBlob blob : sortedByTime) {
            idToBlob.put(blob.getId(), blob);
            skyGroupIdToBlob.put(blob.getSkyGroupId(), blob);
        }
    }

    /**
     * The list of blobs which are no longer needed.
     * 
     * @return A unique list of blobs in no particular order.
     */
    public List<SkyGroupBlob> deletedBlobs() {
        TLongHashSet idsSeen = new TLongHashSet();
        for (SkyGroupBlob blob : skyGroupIdToBlob.getValues(new SkyGroupBlob[0])) {
            idsSeen.add(blob.getId());
        }

        List<SkyGroupBlob> rv = new ArrayList<SkyGroupBlob>();
        for (SkyGroupBlob blob : sortedByTime) {
            if (!idsSeen.contains(blob.getId())) {
                rv.add(blob);
            }
        }

        return rv;
    }

    public BlobData<T> blobDataForSkyGroup(
        SkyGroupBlobDataFactory<T> dataFactory, int skyGroupId) {

        return new BlobData<T>(
            dataFactory.blobDataForSkyGroupBlob(skyGroupIdToBlob.get(skyGroupId)),
            skyGroupId);
    }
}
