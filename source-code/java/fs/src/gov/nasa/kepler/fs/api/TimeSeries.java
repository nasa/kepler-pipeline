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
import gov.nasa.kepler.io.DataInputStream;
import gov.nasa.kepler.io.DataOutputStream;

import gnu.trove.TLongHashSet;
import gov.nasa.spiffy.common.intervals.IntervalUtils;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.builder.ReflectionToStringBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * A typed non-contiguous series of floats or ints along with the information
 * about who wrote them (TaggedInterval)
 * 
 * @author Sean McCauliff
 */
@ProxyIgnoreStatics
public abstract class TimeSeries implements Persistable, FsTimeSeries {

    public static final int NOT_EXIST_CADENCE = -1;

    private static Map<String, TimeSeriesParser> parsers = new HashMap<String, TimeSeriesParser>();

    private static void registerTimeSeriesParser(TimeSeriesParser p) {
        parsers.put(p.type(), p);
    }
    
    static {
        registerTimeSeriesParser(new IntTimeSeries.IntTimeSeriesParser());
        registerTimeSeriesParser(new FloatTimeSeries.FloatTimeSeriesParser());
        registerTimeSeriesParser(new DoubleTimeSeries.DoubleTimeSeriesParser());
    }

    protected FsId id;

    protected int startCadence;

    protected int endCadence;

    protected boolean isFloat = false;

    private boolean exists = false;

    private List<TaggedInterval> originators;
    protected List<SimpleInterval> validCadences;
    
    @ProxyIgnore
    private transient volatile Set<Long> originatorIdSet; 

    /**
     * 
     * @param id The unique identifier for this cadence and time series type.
     * @param series The time series data. Gaps will be filled with unspecified
     * values.
     * @param startCadence The lowest cadence number. So that timeOf(series[0])
     * is equal to startCadence.
     * @param endCadence The highest cadence value. (endCadence - startCadence) +
     * 1 should be equal to series.length.
     * @param validCadences The intervals in validCadences must be in order so
     * that validCadence[j].end() < validCadence[i][j+1].start(). Each gap
     * between valid cadences represents a real data gap.
     * @param originators The intervals in originators must be in order so that
     * originators[i].end() <= originators[i+1].start() The type() in each
     * interval represents the module id that originally wrote this data.
     * @param exists When true there was an actual series stored in the file
     * store for this time series. When false this series is just filler.
     * 
     */
    protected TimeSeries(FsId id, int startCadence, int endCadence, List<SimpleInterval> validCadences,
        List<TaggedInterval> originators, boolean exists) {

        if (id == null) {
            throw new NullPointerException("Invalid id.");
        }

        if (startCadence != NOT_EXIST_CADENCE && endCadence != NOT_EXIST_CADENCE) {
            if (startCadence < 0) {
                throw new IllegalArgumentException("Start cadence must be a non-negative integer for FsId \"" + id + "\".");
            }
            if (endCadence < 0) {
                throw new IllegalArgumentException("End cadence must be a non-negative integer for FsId \"" + id + "\".");
            }
        }

        if (startCadence > endCadence) {
            throw new IllegalArgumentException("End cadence must be greater than or equal to start cadence for FsId \"" + id + "\".");
        }

        if (validCadences == null) {
            throw new NullPointerException("validCadences must not be null FsId \"" + id + "\".");
        }

        if (originators == null) {
            throw new NullPointerException("originators must not be null FsId \"" + id + "\".");
        }

        this.id = id;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.validCadences = validCadences;
        this.originators = originators;
        this.exists = exists;

        if (!cadenceMatch()) {
            throw new IllegalArgumentException("Cadence intervals must be within start/end cadence range for FsId \"" + id + "\".");
        }
    }

    /**
     * 
     * @param id The unique identifier for this cadence and time series type.
     * @param series The time series data. Gaps will be filled with unspecified
     * values.
     * @param startCadence The lowest cadence number. So that timeOf(series[0])
     * is equal to startCadence.
     * @param endCadence The highest cadence value. (endCadence - startCadence) +
     * 1 should be equal to series.length.
     * @param gaps The gaps in the given cadence range. The array must be of
     * length endCadence - startCadence + 1. Each gap between valid cadences
     * represents a real data gap.
     * @param moduleId The module id that originally wrote this data.
     * @param exists When true there was an actual series stored in the file
     * store for this time series. When false this series is just filler.
     * 
     */
    protected TimeSeries(FsId id, int startCadence, int endCadence, boolean[] gaps, long moduleId, boolean exists) {

        if (id == null) {
            throw new IllegalArgumentException("Invalid id.");
        }

        if (startCadence != NOT_EXIST_CADENCE && endCadence != NOT_EXIST_CADENCE) {
            if (startCadence < 0) {
                throw new IllegalArgumentException(String.format("Start cadence (%d) must be a non-negative integer for FsId \"%s\".", startCadence, id.toString()));
            }
            if (endCadence < 0) {
                throw new IllegalArgumentException(String.format("End cadence (%d) must be a non-negative integer for FsId \"%s\".", endCadence, id.toString()));
            }
        }

        if (startCadence > endCadence) {
            throw new IllegalArgumentException(String.format("End cadence (%d) must be greater than or equal to start cadence (%d) for FsId \"%s\".",
            endCadence, startCadence, id.toString()));
        }

        if (gaps == null) {
            throw new NullPointerException(String.format("Gap indicators must not be null for FsId \"%s\".", id.toString()));
        }

        if (gaps.length != endCadence - startCadence + 1) {
            throw new IllegalArgumentException(
                String.format("Gap indicators length (%d) must be equal to end cadence (%d) - start cadence (%d) + 1 for FsId \"%s\".", 
                    gaps.length, endCadence, startCadence, id.toString()));
        }

        this.id = id;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.validCadences = TimeSeries.createValidCadences(startCadence, endCadence, gaps);
        this.originators = TimeSeries.createOriginators(validCadences, moduleId);
        this.exists = exists;

        if (!cadenceMatch()) {
            throw new IllegalArgumentException(String.format("Cadence intervals must be within start/end cadence range for FsId \"%s\".", id.toString()));
        }
    }

    /**
     * 
     * @param id The unique identifier for this cadence and time series type.
     * @param series The time series data. Gaps will be filled with unspecified
     * values.
     * @param startCadence The lowest cadence number. So that timeOf(series[0])
     * is equal to startCadence.
     * @param endCadence The higest cadence value. (endCadence - startCadence) +
     * 1 should be equal to series.length.
     * @param gaps The gaps in the given cadence range as indices. The array
     * must be less than or equal to endCadence - startCadence + 1. Each gap
     * between valid cadences represents a real data gap.
     * @param moduleId The module id that orignally wrote this data.
     * @param exists When true there was an actual series stored in the file
     * store for this time series. When false this series is just filler.
     * 
     */
    protected TimeSeries(FsId id, int startCadence, int endCadence, int[] gaps, long moduleId, boolean exists) {

        if (id == null) {
            throw new IllegalArgumentException("Invalid id.");
        }

        if (startCadence != NOT_EXIST_CADENCE && endCadence != NOT_EXIST_CADENCE) {
            if (startCadence < 0) {
                throw new IllegalArgumentException("Start cadence must be a non-negative integer for FsId \"" + id + "\".");
            }
            if (endCadence < 0) {
                throw new IllegalArgumentException("End cadence must be a non-negative integer for FsId \"" + id + "\".");
            }
        }

        if (startCadence > endCadence) {
            throw new IllegalArgumentException("End cadence must be greater than or equal to start cadence for FsId \"" + id + "\".");
        }

        if (gaps == null) {
            throw new NullPointerException("Gap indices must not be null for FsId \"" + id + "\".");
        }

        this.id = id;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.validCadences = TimeSeries.createValidCadences(startCadence, endCadence, gaps);
        this.originators = TimeSeries.createOriginators(validCadences, moduleId);
        this.exists = exists;

        if (!cadenceMatch()) {
            throw new IllegalArgumentException("Cadence intervals must be within start/end cadence range for FsId \"" + id + "\".");
        }
    }

    /**
     * Needed for persistable.
     * 
     */
    protected TimeSeries() {

    }
    
    /**
     * @param cadence The cadence to check.  This must be non-negative.
     * @exception java.lang.IllegalArgumentException If the cadence does not
     * exist.
     * @return  The index into the originators array that contains the
     * originator to use else this returns -1 if the cadences does not appear
     * in the originators array.
     */
    public int originatorByCadence(int cadence) {
        if (originators.size() == 0) {
            return -1;
        }
        
        int firstIndex = 0;
        int lastIndex = originators.size() -1;
        while (firstIndex <= lastIndex) {
            int midIndex = (firstIndex + lastIndex) >>> 1;
            TaggedInterval interval = originators.get(midIndex);
            if (cadence > interval.end()) {
                firstIndex = midIndex + 1;
            } else if (cadence < interval.start()) {
                lastIndex = midIndex - 1;
            } else {
                return midIndex;
            }
        }
        return -1;
    }
    
    public boolean isFloat() {
        return isFloat;
    }

    /**
     * 
     * @return When true there was an actual series stored in the file store for
     * this time series. When false this series is just filler.
     */
    public boolean exists() {
        return exists;
    }

    @Override
    public FsId id() {
        return id;
    }

    public int startCadence() {
        return startCadence;
    }

    public int endCadence() {
        return endCadence;
    }

    public int cadenceLength() {
        return endCadence() - startCadence() + 1;
    }

    public int length() {
        return endCadence - startCadence + 1;
    }
    
    public List<SimpleInterval> validCadences() {
        return validCadences;
    }

    public List<TaggedInterval> originators() {
        return originators;
    }

    /**
     * @return true If this data only contains gaps. That is there is no valid
     * data.
     */
    public boolean isEmpty() {
        return validCadences.isEmpty();
    }

    /**
     * Collect a unique set of module ids used to populate this data set.
     * 
     * @return A set, if there are none then this returns an empty list.
     */
    public Set<Long> uniqueOriginators() {
        if (originators.isEmpty()) {
            return Collections.emptySet();
        }
        
        if (originatorIdSet != null) {
            return originatorIdSet;
        }
        
        Set<Long> rv = new HashSet<Long>();
        final int size = originators.size();
        for (int i=0; i < size; i++) {
            rv.add(originators.get(i).tag());
        }

        originatorIdSet =rv;
        return rv;
    }
    
    /**
     * Adds all the originators to the specified destination set.
     * @param destSet this set is modified.
     */
    public void uniqueOriginators(Set<Long> destSet) {
        for (TaggedInterval t : originators) {
            destSet.add(t.tag());
        }
    }
    
    /**
     * Adds all the originators to the specified destination set.
     * @param destSet this set is modified
     */
    @Override
    public void uniqueOriginators(TLongHashSet destSet) {
        for (TaggedInterval t : originators) {
            destSet.add(t.tag());
        }
    }

    /**
     * Useful for checking if the start, end cadence matches the valid, origin
     * intervals.
     * 
     * @return true if everything is ok.
     */
    private boolean cadenceMatch() {
        if (!IntervalUtils.checkOverlap(validCadences())) {
            return false;
        }
        if (validCadences().size() > 0) {
            if (validCadences().get(0).start() < startCadence) {
                return false;
            }
            if (validCadences().get(validCadences().size() - 1).end() > endCadence) {
                return false;
            }
        }

        if (!IntervalUtils.checkOverlap(originators())) {
            return false;
        }
        if (originators().size() > 0) {
            if (originators().get(0).start() < startCadence) {
                return false;
            }
            if (originators().get(originators().size() - 1).end() > endCadence) {
                return false;
            }
        }

        return true;
    }

    /**
     * Returns an array of the same length as the time series where each element
     * indicates whether the corresponding element in the time series is a data
     * gap.
     */
    public boolean[] getGapIndicators() {
        boolean[] dataGapIndicators = new boolean[endCadence - startCadence + 1];

        // If no valid cadences, everything is a gap.
        if (validCadences.size() == 0) {
            Arrays.fill(dataGapIndicators, true);
            return dataGapIndicators;

        }
        
        int prevEnd = startCadence - 1;
        for (SimpleInterval interval : validCadences) {
            int stop = ((int) interval.start()) - startCadence;
            int start = prevEnd - startCadence + 1;

            Arrays.fill(dataGapIndicators, start, stop, true);

            prevEnd = (int) interval.end();
        }

        // Set a gap after the last valid cadence.
        if (endCadence > prevEnd) {
            int stop = endCadence - startCadence + 1;
            int start = prevEnd - startCadence + 1;

            Arrays.fill(dataGapIndicators, start, stop, true);
        }

        return dataGapIndicators;
        
    }

    /**
     * Returns an array where each element in the array is an index of a data
     * gap in the time series values.
     */
    public int[] getGapIndices() {
        int[] gapIndices = null;

        if (validCadences.size() == 0) {
            gapIndices = new int[endCadence - startCadence + 1];
            for (int i = 0; i < gapIndices.length; i++) {
                gapIndices[i] = i;
            }
        } else {
            boolean[] gapIndicators = getGapIndicators();

            // pre-determine the number of cadence gaps
            int length = 0;
            for (boolean gapIndicator : gapIndicators) {
                if (gapIndicator) {
                    length++;
                }
            }
            gapIndices = new int[length];

            int gap = 0;
            for (int i = 0; i < gapIndicators.length; i++) {
                if (gapIndicators[i]) {
                    gapIndices[gap++] = i;
                }
            }
        }
        return gapIndices;
    }



    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + endCadence;
        result = PRIME * result + (exists ? 1231 : 1237);
        result = PRIME * result + ((id == null) ? 0 : id.hashCode());
        result = PRIME * result + (isFloat ? 1231 : 1237);
        result = PRIME * result + ((originators == null) ? 0 : originators.hashCode());
        result = PRIME * result + startCadence;
        result = PRIME * result + ((validCadences == null) ? 0 : validCadences.hashCode());
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
        final TimeSeries other = (TimeSeries) obj;
        if (endCadence != other.endCadence)
            return false;
        if (exists != other.exists)
            return false;
        if (id == null) {
            if (other.id != null)
                return false;
        } else if (!id.equals(other.id))
            return false;
        if (isFloat != other.isFloat)
            return false;
        if (originators == null) {
            if (other.originators != null)
                return false;
        } else if (!originators.equals(other.originators))
            return false;
        if (startCadence != other.startCadence)
            return false;
        if (validCadences == null) {
            if (other.validCadences != null)
                return false;
        } else if (!validCadences.equals(other.validCadences))
            return false;
        return true;
    }

    /**
     * Display an overview of this time series. To view every value, call
     * {@code toString(true)}.
     */
    @Override
    public String toString() {
        return toString(false);
    }

    public String toString(boolean verbose) {
        if (verbose == true) {
            // This renders mock output unreadable so it is not used by default.
            return ReflectionToStringBuilder.toString(this);
        } else {
            return new ToStringBuilder(this).append("id", id)
                .append("startCadence", startCadence)
                .append("endCadence", endCadence)
                .append("isFloat", isFloat)
                .append("exists", exists)
                .append("originators", originators)
                .append("validCadences", validCadences)
                .toString();
        }
    }

    /**
     * ASCII, \n line ended, each line is a different series, <FsId><type><exists><start><end><n
     * values><values><n valid><valid><n origin><origin>
     */
    public String toPipeString() {
        StringBuffer writer = new StringBuffer();
        writer.append(id().toString()).append('|').append(typeName()).append('|').append(exists).append('|').append(
            Integer.toString(startCadence())).append('|').append(Integer.toString(endCadence())).append('|').append(
            Integer.toString(cadenceLength())).append('|');

        int length = cadenceLength();
        for (int i = 0; i < length; i++) {
            this.appendValue(writer, i);
            writer.append('|');
        }

        writer.append(Integer.toString(validCadences().size())).append('|');
        for (SimpleInterval v : validCadences()) {
            writer.append(Long.toString(v.start())).append('|').append(Long.toString(v.end())).append('|');
        }
        writer.append(Integer.toString(originators().size())).append('|');
        for (TaggedInterval o : originators()) {
            writer.append(Long.toString(o.start())).append('|').append(Long.toString(o.end())).append('|').append(
                Long.toString(o.tag())).append('|');
        }

        if (originators.size() > 0) {
            writer.setLength(writer.length() - 1);
        }

        return writer.toString();

    }

    public void transferTo(DataOutputStream dout) throws IOException {
        dout.writeUTF(this.typeName());
        id.writeTo(dout);
        dout.writeInt(startCadence);
        dout.writeInt(endCadence);
        dout.writeBoolean(exists);
        dout.writeInt(validCadences().size());
        for (SimpleInterval valid : this.validCadences()) {
            dout.writeLong(valid.start());
            dout.writeLong(valid.end());
        }
        dout.writeInt(originators().size());
        for (TaggedInterval originator : this.originators()) {
            dout.writeLong(originator.start());
            dout.writeLong(originator.end());
            dout.writeLong(originator.tag());
        }
    }

    @SuppressWarnings("unchecked")
    public static TimeSeries transferFrom(DataInputStream din) throws IOException {
        String typeName = din.readUTF();
        FsId id = FsId.readFrom(din);
        int startCadence = din.readInt();
        int endCadence = din.readInt();
        boolean exists = din.readBoolean();
        int nvalid = din.readInt();
        List<SimpleInterval> valid = null;
        if (nvalid == 0) {
            valid = Collections.EMPTY_LIST;
        } else {
            valid = new ArrayList<SimpleInterval>(nvalid);
            for (int i = 0; i < nvalid; i++) {
                long start = din.readLong();
                long end = din.readLong();
                valid.add(new SimpleInterval(start, end));
            }
        }

        List<TaggedInterval> originators = null;
        int norigin = din.readInt();
        if (norigin == 0) {
            originators = Collections.EMPTY_LIST;
        } else {
            originators = new ArrayList<TaggedInterval>(norigin);
            for (int i = 0; i < norigin; i++) {
                long start = din.readLong();
                long end = din.readLong();
                long tag = din.readLong();
                originators.add(new TaggedInterval(start, end, tag));
            }
        }

        TimeSeriesParser parser = parsers.get(typeName);
        TimeSeries timeSeries = 
            parser.buildTimeSeries(id, startCadence, endCadence, valid, originators, exists, din);
        return timeSeries;

    }

    /**
     * This is used by toPipeString() to create build the string.
     * 
     * @param writer
     * @param index
     */
    protected abstract void appendValue(StringBuffer writer, int index);

    /**
     * This is used by the pipe string methods.
     * 
     * @return a non null value.
     */
    public String typeName() {
        return dataType().typeName();
    }

    public abstract TimeSeriesDataType dataType();
    
    /**
     * @return The time series data array, this will be some kind of primitive
     * array.  Non-null.
     */
    public abstract Object series();
    
    /**
     * @return an IntTimeSeries object if this TimeSeries is an IntTimeSeries
     * or can be coerced into IntTimeSeries.
     */
    public IntTimeSeries asIntTimeSeries() {
        if (this instanceof IntTimeSeries) {
            return (IntTimeSeries) this;
        }
        if (isEmpty()) {
            return new IntTimeSeries(id(), new int[length()],
                startCadence(), endCadence(), 
                Collections.<SimpleInterval> emptyList(),
                Collections.<TaggedInterval> emptyList());
        }
        throw new ClassCastException("Can not coerce " +
            getClass().getSimpleName() + " with id \"" + id() +
            " into IntTimeSeries.");
    }
    
    /**
     * @return an FloatTimeSeries object if this TimeSeries is a FloatTimeSeries
     * or can be coerced into FloatTimeSeries.
     */
    public FloatTimeSeries asFloatTimeSeries() {
        if (this instanceof FloatTimeSeries) {
            return (FloatTimeSeries) this;
        }
        if (isEmpty()) {
            return new FloatTimeSeries(id(), new float[length()],
                startCadence(), endCadence(), 
                Collections.<SimpleInterval> emptyList(),
                Collections.<TaggedInterval> emptyList());
        }
        throw new ClassCastException("Can not coerce " +
            getClass().getSimpleName() + " with id \"" + id() +
            " into FloatTimeSeries.");
    }
    
    /**
     * @return an FloatTimeSeries object if this TimeSeries is a FloatTimeSeries
     * or can be coerced into FloatTimeSeries.
     */
    public DoubleTimeSeries asDoubleTimeSeries() {
        if (this instanceof DoubleTimeSeries) {
            return (DoubleTimeSeries) this;
        }
        if (isEmpty()) {
            return new DoubleTimeSeries(id(), new double[length()],
                startCadence(), endCadence(), 
                Collections.<SimpleInterval> emptyList(),
                Collections.<TaggedInterval> emptyList());
        }
        throw new ClassCastException("Can not coerce " +
            getClass().getSimpleName() + " with id \"" + id() +
            " into DoubleTimeSeries.");
    }
    
    /**
     * You must have initalized all sub classes before using this method.
     * 
     * @param s pipe delimited string
     * @return
     */
    public static TimeSeries fromPipeString(String s) {
        String[] fields = s.split("\\|");
        int fieldIndex = 0;
        FsId tsFsId = new FsId(fields[fieldIndex++]);
        String typeName = fields[fieldIndex++];
        TimeSeriesParser parser = parsers.get(typeName);
        boolean exists = Boolean.parseBoolean(fields[fieldIndex++]);
        int start = Integer.parseInt(fields[fieldIndex++]);
        int end = Integer.parseInt(fields[fieldIndex++]);
        int length = Integer.parseInt(fields[fieldIndex++]);
        Object data = parser.newData(length);
        int dataStart = fieldIndex;

        for (int i = 0; fieldIndex < (dataStart + length); i++, fieldIndex++) {
            parser.addData(data, i, fields[fieldIndex]);
        }

        List<SimpleInterval> valid = new ArrayList<SimpleInterval>();
        int validLength = Integer.parseInt(fields[fieldIndex++]);
        for (int i = 0; i < validLength; i++) {
            int vstart = Integer.parseInt(fields[fieldIndex++]);
            int vend = Integer.parseInt(fields[fieldIndex++]);
            SimpleInterval validInterval = new SimpleInterval(vstart, vend);
            valid.add(validInterval);
        }

        int originLength = Integer.parseInt(fields[fieldIndex++]);
        List<TaggedInterval> origin = new ArrayList<TaggedInterval>();
        for (int i = 0; i < originLength; i++) {
            long ostart = Long.parseLong(fields[fieldIndex++]);
            long oend = Long.parseLong(fields[fieldIndex++]);
            int taskId = Integer.parseInt(fields[fieldIndex++]);
            TaggedInterval ointerval = new TaggedInterval(ostart, oend, taskId);
            origin.add(ointerval);
        }

        return parser.buildTimeSeries(tsFsId, data, start, end, valid, origin, exists);
    }

    public static List<SimpleInterval> createValidCadences(int startCadence, int endCadence, boolean[] gaps) {

        List<SimpleInterval> validCadences = new ArrayList<SimpleInterval>();
        if (gaps != null && gaps.length > 0) {
            int start = startCadence;
            int end = endCadence;
            for (int offset = 0; offset < gaps.length; offset++) {
                if (gaps[offset] && offset < endCadence - startCadence + 1) {
                    if (startCadence + offset - start == 0) {
                        start++;
                        continue;
                    } else {
                        validCadences.add(new SimpleInterval(start, startCadence + offset - 1));
                        start = startCadence + offset + 1;
                    }
                }
            }
            if (start <= end) {
                validCadences.add(new SimpleInterval(start, end));
            }
        } else {
            validCadences.add(new SimpleInterval(startCadence, endCadence));
        }
        return validCadences;
    }

    public static List<SimpleInterval> createValidCadences(int startCadence, int endCadence, int[] gaps) {

        List<SimpleInterval> validCadences = new ArrayList<SimpleInterval>();
        if (gaps != null && gaps.length > 0) {
            int start = startCadence;
            int end = endCadence;
            for (int i = 0; i < gaps.length; i++) {
                int offset = gaps[i];
                if (offset < endCadence - startCadence + 1) {
                    if (startCadence + offset - start == 0) {
                        start++;
                        continue;
                    } else {
                        validCadences.add(new SimpleInterval(start, startCadence + offset - 1));
                        start = startCadence + offset + 1;
                    }
                }
            }
            if (start <= end) {
                validCadences.add(new SimpleInterval(start, end));
            }
        } else {
            validCadences.add(new SimpleInterval(startCadence, endCadence));
        }
        return validCadences;
    }

    public static List<TaggedInterval> createOriginators(List<SimpleInterval> validCadences, long pipelineTaskId) {

        List<TaggedInterval> originators = new ArrayList<TaggedInterval>();
        for (SimpleInterval interval : validCadences) {
            originators.add(new TaggedInterval(interval.start(), interval.end(), pipelineTaskId));
        }
        return originators;
    }

    protected abstract static class TimeSeriesParser {
        abstract String type();

        /**
         * Creates an empty data array for this type.
         * 
         * @return
         */
        abstract Object newData(int size);

        /**
         * @param data generated from newData
         * @param index the index into the data array
         * @param value the value to parse
         */
        abstract void addData(Object data, int index, String value);

        /**
         * Creates a new time series object.
         * 
         * @param data Generated from newData
         */
        abstract TimeSeries buildTimeSeries(FsId id, Object data, int startCadence, int endCadence,
            List<SimpleInterval> valid, List<TaggedInterval> originators, boolean exists);

        abstract TimeSeries buildTimeSeries(FsId id, int startCadence, int endCadence, List<SimpleInterval> valid,
            List<TaggedInterval> originators, boolean exists, DataInputStream din) throws IOException;
    }
}
