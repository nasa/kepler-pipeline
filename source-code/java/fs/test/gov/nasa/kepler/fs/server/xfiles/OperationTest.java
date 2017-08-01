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

package gov.nasa.kepler.fs.server.xfiles;
import gov.nasa.kepler.io.DataInputStream;
import gov.nasa.kepler.io.DataOutputStream;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;

import gov.nasa.spiffy.common.intervals.IntervalSet;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import org.junit.Test;

/**
 * Check that operation I/O works correctly.
 * @author Sean McCauliff
 *
 */
public class OperationTest {

    @Test
    public void operationTest() throws Exception {
        SimpleInterval.Factory sFactory = new SimpleInterval.Factory();
        
        IntervalSet<SimpleInterval, SimpleInterval.Factory> v =
            new IntervalSet<SimpleInterval, SimpleInterval.Factory>(sFactory);
        v.mergeInterval(new SimpleInterval(2342, 5555));
        
        TaggedInterval.Factory tFactory = new TaggedInterval.Factory();
        IntervalSet<TaggedInterval, TaggedInterval.Factory> o =
            new IntervalSet<TaggedInterval, TaggedInterval.Factory>(tFactory);
        
        WriteOperation wop = new WriteOperation(2342L, 5555L, v, o, 777777777799L);
        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        DataOutputStream dout = new DataOutputStream(bout);
        wop.writeTo(dout);
        
        ByteArrayInputStream bin = new ByteArrayInputStream(bout.toByteArray());
        DataInputStream din = new DataInputStream(bin);
        Operation readOp = Operation.readFrom(din);
        
        ReflectionEquals reflectionEquals = new ReflectionEquals();
        reflectionEquals.excludeField(".*\\.factory");
        reflectionEquals.assertEquals(wop, readOp);
        
        DeleteOperation delOp = new DeleteOperation(55555L, 98239048209384L);
        bout = new  ByteArrayOutputStream();
        dout = new DataOutputStream(bout);
        
        delOp.writeTo(dout);
        
        bin = new ByteArrayInputStream(bout.toByteArray());
        din = new DataInputStream(bin);
        
        readOp = Operation.readFrom(din);
        
        reflectionEquals.assertEquals(delOp, readOp);
        
        
    }
}
