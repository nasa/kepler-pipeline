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

import gnu.trove.TLongHashSet;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * @author Sean McCauliff
 * 
 */
@ProxyIgnoreStatics
public class FloatMjdTimeSeries implements Persistable, FsTimeSeries {

    public static final double[] EMPTY_MJD = new double[0];

    public static final float[] EMPTY_VALUES = new float[0];

    public static final long[] EMPTY_ORIGIN = new long[0];

    private double[] mjd;
    private FsId id;
    private float[] values;
    private long[] originators;
    private boolean exists;
    private double startMjd;
    private double endMjd;

    /**
     * Required for Persistable interface. Do not use this constructor.
     * 
     */
    public FloatMjdTimeSeries() {
    }

    public FloatMjdTimeSeries(FsId id, double startMjd, double endMjd,
        double[] mjd, float[] values, long[] originators, boolean exists) {

        if (mjd.length != values.length) {
            throw new IllegalArgumentException(
                "mjd length must match corrections length for FsId \"" + id
                    + "\".");
        }
        if (mjd.length != originators.length) {
            throw new IllegalArgumentException(
                "mjd length must match originators length for FsId \"" + id
                    + "\".");
        }

        final int badIndex = checkMjdArray(mjd);
        if (badIndex != -1) {
            throw new IllegalArgumentException(
                "mjd array is not ascending for FsId \"" + id + "\" at index "
                    + badIndex + " mjd[i-1] " + mjd[badIndex - 1] + " mjd[i] "
                    + mjd[badIndex] + ".");
        }

        if (mjd.length > 0) {
            if (!(startMjd <= mjd[0])) {
                throw new IllegalArgumentException("Start " + startMjd
                    + " occurs after mjd[0] " + mjd[0] + " for FsId \"" + id
                    + "\".");
            }
            if (!(endMjd >= mjd[mjd.length - 1])) {
                throw new IllegalArgumentException("End " + endMjd
                    + " occurs before mjd[mjd.length -1 ] "
                    + mjd[mjd.length - 1] + " for FsId \"" + id + "\".");
            }
        }

        this.id = id;
        this.mjd = mjd;
        this.values = values;
        this.originators = originators;
        this.exists = exists;
        this.startMjd = startMjd;
        this.endMjd = endMjd;

    }

    /**
     * Mjd array should be in ascending order.
     * 
     * @param mjd
     * @return -1 if this condition holds else the index of the violating mjd.
     */
    private static int checkMjdArray(double[] mjd) {
        if (mjd.length <= 1) {
            return -1;
        }

        double prevMjd = mjd[0];
        for (int i = 1; i < mjd.length; i++) {
            if (!(prevMjd < mjd[i])) {
                return i;
            }
            prevMjd = mjd[i];
        }
        return -1;
    }

    private static long[] newOriginators(long value, int length) {
        long[] rv = new long[length];
        Arrays.fill(rv, value);
        return rv;
    }

    /**
     * Exists=true, single originator.
     * 
     * @param id
     * @param startMjd
     * @param endMjd
     * @param mjd
     * @param corrections
     * @param originator
     */
    public FloatMjdTimeSeries(FsId id, double startMjd, double endMjd,
        double[] mjd, float[] values, long originator) {
        this(id, startMjd, endMjd, mjd, values, newOriginators(originator,
            mjd.length), true);
    }

    /**
     * start <= mjd[0] (if mjd[0] exists)
     * 
     * @return
     */
    public double startMjd() {
        return startMjd;
    }

    /**
     * mjd[mjd.length - 1] <= end ( if mjd.length >0);
     * 
     * @return
     */
    public double endMjd() {
        return endMjd;
    }

    /**
     * A valid FsId.
     * 
     * @return
     */
    @Override
    public FsId id() {
        return id;
    }

    /**
     * Mjd in sorted ascending order.
     * 
     * @return
     */
    public double[] mjd() {
        return mjd;
    }

    /**
     * Cosmic ray delta.
     * 
     * @return
     */
    public float[] values() {
        return values;
    }

    /**
     * The task ids that generated these corrections. Such that correction[i]
     * was made by originators[i]
     * 
     * @return
     */
    public long[] originators() {
        return originators;
    }

    /**
     * Finds the value for the specified mjd.
     * 
     * @return null if it does not exist else returns (value, originator)
     */
    public MjdValue find(double searchKey) {
        int index = Arrays.binarySearch(mjd, searchKey);
        if (index < 0) {
            return null;
        }

        return new MjdValue(originators[index], values[index]);
    }

    /**
     * Set of originators.
     */
    public Set<Long> uniqueOriginators() {
        Set<Long> set = new HashSet<Long>();
        for (long origin : originators) {
            set.add(origin);
        }
        return set;
    }

    /**
     * 
     * @return This fsid exists in the CosmicRayStore else it does not.
     */
    public boolean exists() {
        return exists;
    }

    @Override
    public void uniqueOriginators(TLongHashSet destSet) {
        destSet.addAll(originators);
    }

    @Override
    public int hashCode() {
        int PRIME = 31;
        int result = 1;
        result = PRIME * result + Arrays.hashCode(values);
        long temp;
        temp = Double.doubleToLongBits(endMjd);
        result = PRIME * result + (int) (temp ^ temp >>> 32);
        result = PRIME * result + (exists ? 1231 : 1237);
        result = PRIME * result + (id == null ? 0 : id.hashCode());
        result = PRIME * result + Arrays.hashCode(mjd);
        result = PRIME * result + Arrays.hashCode(originators);
        temp = Double.doubleToLongBits(startMjd);
        result = PRIME * result + (int) (temp ^ temp >>> 32);
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
        FloatMjdTimeSeries other = (FloatMjdTimeSeries) obj;
        if (!Arrays.equals(values, other.values)) {
            return false;
        }
        if (Double.doubleToLongBits(endMjd) != Double.doubleToLongBits(other.endMjd)) {
            return false;
        }
        if (exists != other.exists) {
            return false;
        }
        if (id == null) {
            if (other.id != null) {
                return false;
            }
        } else if (!id.equals(other.id)) {
            return false;
        }
        if (!Arrays.equals(mjd, other.mjd)) {
            return false;
        }
        if (!Arrays.equals(originators, other.originators)) {
            return false;
        }
        if (Double.doubleToLongBits(startMjd) != Double.doubleToLongBits(other.startMjd)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("id", id)
            .append("exists", exists)
            .append("startMjd", startMjd)
            .append("endMjd", endMjd)
            .append("mjds", Arrays.toString(mjd))
            .append("values", Arrays.toString(values))
            .append("originators", Arrays.toString(originators))
            .toString();
    }

    /**
     * Writes this into a pipe delimted string. As:
     * FsId|startMjd|endMjd|nItems|mjd0
     * |value0|origin0|mjd1|,,,,|mjdn-1|valuen-1|originn-1
     * 
     * @return
     */
    public String toPipeString() {
        StringBuilder builder = new StringBuilder();
        builder.append(id.toString())
            .append('|');
        builder.append(startMjd)
            .append('|')
            .append(endMjd)
            .append('|');
        builder.append(mjd.length)
            .append('|');
        for (int i = 0; i < mjd.length; i++) {
            builder.append(mjd[i])
                .append('|');
            builder.append(values[i])
                .append('|');
            builder.append(originators[i])
                .append('|');
        }
        builder.setLength(builder.length() - 1);
        return builder.toString();
    }

    /**
     * 
     * @param pipeString Generated from toPipeString()
     * @return
     */
    public static FloatMjdTimeSeries fromPipeString(String pipeString) {
        String[] parts = pipeString.split("\\|");
        int i = 0;
        FsId id = new FsId(parts[i++]);
        double startMjd = Double.parseDouble(parts[i++]);
        double endMjd = Double.parseDouble(parts[i++]);
        int nItems = Integer.parseInt(parts[i++]);
        double[] mjd = new double[nItems];
        float[] values = new float[nItems];
        long[] origin = new long[nItems];

        for (int n = 0; n < nItems; n++) {
            mjd[n] = Double.parseDouble(parts[i++]);
            values[n] = Float.parseFloat(parts[i++]);
            origin[n] = Long.parseLong(parts[i++]);
        }

        return new FloatMjdTimeSeries(id, startMjd, endMjd, mjd, values,
            origin, true);
    }

    /**
     * Returns an empty CosmicRaySeries
     * 
     * @param id2
     * @param b
     * @return
     */
    public static FloatMjdTimeSeries emptySeries(FsId id, double startMjd,
        double endMjd, boolean exists) {
        return new FloatMjdTimeSeries(id, startMjd, endMjd,
            FloatMjdTimeSeries.EMPTY_MJD, FloatMjdTimeSeries.EMPTY_VALUES,
            FloatMjdTimeSeries.EMPTY_ORIGIN, exists);
    }

    public static class MjdValue {
        public final long origin;
        public final float value;

        MjdValue(long origin, float value) {
            this.origin = origin;
            this.value = value;
        }
    }

    public void writeTo(DataOutput dout) throws IOException {
        dout.writeBoolean(exists);
        dout.writeDouble(startMjd);
        dout.writeDouble(endMjd);
        id.writeTo(dout);
        dout.writeInt(mjd.length);
        for (double element : mjd) {
            dout.writeDouble(element);
        }
        for (float value : values) {
            dout.writeFloat(value);
        }
        for (long originator : originators) {
            dout.writeLong(originator);
        }
    }

    public static FloatMjdTimeSeries readFrom(DataInput din) throws IOException {
        boolean exists = din.readBoolean();
        double startMjd = din.readDouble();
        double endMjd = din.readDouble();
        FsId id = FsId.readFrom(din);
        final int arrayLength = din.readInt();
        double[] mjd = new double[arrayLength];
        for (int i = 0; i < arrayLength; i++) {
            mjd[i] = din.readDouble();
        }
        float[] values = new float[arrayLength];
        for (int i = 0; i < arrayLength; i++) {
            values[i] = din.readFloat();
        }
        long[] originators = new long[arrayLength];
        for (int i = 0; i < arrayLength; i++) {
            originators[i] = din.readLong();
        }

        FloatMjdTimeSeries rv = new FloatMjdTimeSeries(id, startMjd, endMjd,
            mjd, values, originators, exists);
        return rv;
    }
}
