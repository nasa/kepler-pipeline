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

package gov.nasa.kepler.fs;

import java.io.FileInputStream;

import org.apache.commons.io.input.CountingInputStream;

import gov.nasa.kepler.io.DataInputStream;
import gov.nasa.spiffy.common.intervals.IntervalSet;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;

/**
 * Load the metadata from the time series file.
 * @author Sean McCauliff
 *
 */
public class LoadTimeSeriesMetadata {

    public static void main(String[] argv) throws Exception {
        TaggedInterval.Factory taggedFactory = new TaggedInterval.Factory();
        SimpleInterval.Factory simpleFactory = new SimpleInterval.Factory();
        CountingInputStream count = new CountingInputStream(new FileInputStream(argv[0]));
        DataInputStream din = new DataInputStream(count);
        IntervalSet<SimpleInterval, SimpleInterval.Factory> rvValid = 
            new IntervalSet<SimpleInterval, SimpleInterval.Factory>(simpleFactory);
        byte version = din.readByte();  //version
        byte dataType = din.readByte();
        rvValid.readFrom(din);
        
        IntervalSet<TaggedInterval, TaggedInterval.Factory> rvOrigin = 
            new IntervalSet<TaggedInterval, TaggedInterval.Factory>(taggedFactory);
        rvOrigin.readFrom(din);

        
        System.out.println("Read " + count.getByteCount() + " bytes.");
        /* header + #intervals * sizeof(SimpleInterval) + sizeof(IntervalSet) */
        /* sizeof(SimpleInterval) = long + long + vtable ptr + pointer to interval itself */
        /* sizeof(TaggedIntervla) = long + long + long + vtable ptr + pointer to interval itself */
        /* sizeof(IntervalSet) = pointer to ArrayList, pointer to vtable + arrayList.size[int] + arrayList ptr to array + arrayList.vtable */
        int uncompressedSize = 2 + rvValid.intervals().size() * 32 + 34;
        uncompressedSize += rvOrigin.intervals().size() * 40 + 34;
        System.out.println("Uncompressed bytes " + uncompressedSize);
        System.out.println("version " + version + " data type " + dataType + " rvValid (" + rvValid.intervals().size() + ")");

        for (SimpleInterval s : rvValid.intervals()) {
            System.out.print(s);
        }
        System.out.println("\nrvOrigin(" + rvOrigin.intervals().size() + ")");
        for (TaggedInterval t : rvOrigin.intervals()) {
            System.out.print(t);
        }
        System.out.println("");
    }
}
