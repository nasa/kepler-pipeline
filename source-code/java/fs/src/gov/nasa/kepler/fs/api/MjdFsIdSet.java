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

import java.util.HashSet;
import java.util.Set;
import java.io.*;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * A set of FsIds for a specific time.
 * 
 * @author Sean McCauliff
 *
 */
public class MjdFsIdSet {

    private final double startMjd;
    private final double endMjd;
    private final Set<FsId> ids;
    /**
     * @param startMjd
     * @param endMjd
     * @param ids
     */
    public MjdFsIdSet(double startMjd, double endMjd, Set<FsId> ids) {
        if (startMjd > endMjd) {
            throw new IllegalArgumentException("Start mjd occurs after end mjd.");
        }
        if (ids == null) {
            throw new NullPointerException("ids can not be null");
        }
        this.startMjd = startMjd;
        this.endMjd = endMjd;
        this.ids = ids;
    }
    
    public double startMjd() {
        return startMjd;
    }
    
    public double endMjd() {
        return endMjd;
    }
    
    public Set<FsId> ids() {
        return ids;
    }
    
    public void writeTo(DataOutput dout) throws IOException {
        dout.writeDouble(startMjd);
        dout.writeDouble(endMjd);
        dout.writeInt(ids.size());
        for (FsId id : ids) {
            id.writeTo(dout);
        }
    }
    
    public static MjdFsIdSet readFrom(DataInput din) throws IOException {
        double startMjd = din.readDouble();
        double endMjd = din.readDouble();
        int nIds = din.readInt();
        Set<FsId> ids = new HashSet<FsId>(nIds);
        for (int i=0; i < nIds; i++) {
            FsId id = FsId.readFrom(din);
            ids.add(id);
        }
        return new MjdFsIdSet(startMjd, endMjd, ids); 
    }
    
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        long temp;
        temp = Double.doubleToLongBits(endMjd);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        result = prime * result + ((ids == null) ? 0 : ids.hashCode());
        temp = Double.doubleToLongBits(startMjd);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        MjdFsIdSet other = (MjdFsIdSet) obj;
        if (Double.doubleToLongBits(endMjd) != Double.doubleToLongBits(other.endMjd)) {
            return false;
        }
        if (ids == null) {
            if (other.ids != null) {
                return false;
            }
        } else if (!ids.equals(other.ids)) {
            return false;
        }
        if (Double.doubleToLongBits(startMjd) != Double.doubleToLongBits(other.startMjd)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }
}
