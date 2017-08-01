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


package gov.nasa.kepler.fs.server;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.ArrayUtils;

import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeriesDataType;
import gov.nasa.kepler.io.DataInputStream;
import gov.nasa.kepler.io.DataOutputStream;
import gov.nasa.spiffy.common.intervals.IntervalUtils;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;

import static gov.nasa.kepler.fs.api.TimeSeries.NOT_EXIST_CADENCE;

/**
 * A holder for other time series. The file store server uses this
 * to store all the other time series instead of converting them
 * to/from their native forms.
 * 
 * Meta data stored in this class is stored as byte indices rather than
 * the indicates in the carried type. So a startCadence will be larger since it
 * is the byte start cadence and not the int start cadence.
 * 
 * @author Sean McCauliff
 *
 */
@ProxyIgnoreStatics
public class TimeSeriesCarrier  {

    private final TimeSeriesDataType carriedType;
    private final long startCadence;
    private final long endCadence;
    private final byte[] data;
    private final FsId id;
    private final List<SimpleInterval> validCadences;
    private final List<TaggedInterval> originators;
    private final boolean exists;

    public TimeSeriesCarrier(FsId id, byte[] data, long startCadence,
        long endCadence, List<SimpleInterval> validCadences,
        List<TaggedInterval> originators, boolean exists, TimeSeriesDataType carriedType) {
       
        if (data == null) {
            throw new NullPointerException("data must not be null");
        }
        if (id == null) {
            throw new NullPointerException("id must not be null");
        }
        if (validCadences == null) {
            throw new NullPointerException("validCadences must not be null");
        }
        if (originators == null) {
            throw new NullPointerException("originators must not be null");
        }
        this.carriedType = carriedType;
        this.id = id;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.validCadences = validCadences;
        this.originators = originators;
        this.exists = exists;
        this.data = data;
        
        validate();
    }

    public TimeSeriesDataType carriedType() {
        return carriedType;
    }

    public long startCadence() {
        return startCadence;
    }
    
    public long endCadence() {
        return endCadence;
    }
    
    public FsId id() {
        return id;
    }
    
    public int cadenceLength() {
        return (int) (endCadence - startCadence + 1);
    }
    
    public List<SimpleInterval> validCadences() {
        return validCadences;
    }
    
    public List<TaggedInterval> originators() {
        return originators;
    }
    
    public byte[] data() {
        return data;
    }
    
    /** Checks this carrier for logical inconsistencies. */
    private void validate() {
        if (endCadence < startCadence) {
            throw new IllegalArgumentException("Start cadence must not come before end cadence.");
        }
        if (startCadence == NOT_EXIST_CADENCE ^ endCadence == NOT_EXIST_CADENCE) {
            throw new IllegalArgumentException("Either both start and end must" +
            		" be NOT_EXIST_CADENCE or neither of them must be.");
        }
        if (startCadence < 0 && startCadence != NOT_EXIST_CADENCE) {
            throw new IllegalArgumentException("Start cadence must not be negative.");
        }
        if (endCadence < 0 && endCadence != NOT_EXIST_CADENCE) {
            throw new IllegalArgumentException("End cadence must not be negative.");
        }
        
        if (startCadence == NOT_EXIST_CADENCE && endCadence == NOT_EXIST_CADENCE) {
            if (exists) {
                throw new IllegalArgumentException("If cadences are NOT_EXIST then exists flag must be false.");
            }
            return;
        }
        if (!IntervalUtils.checkOverlap(validCadences)) {
            throw new IllegalArgumentException("Bad validCadecnes.");
        }
        if (!IntervalUtils.checkOverlap(originators)) {
            throw new IllegalArgumentException("Bad originators.");
        }
        if ( (endCadence - startCadence + 1) > Integer.MAX_VALUE) {
            throw new IllegalArgumentException("Can't represent more than 2Gi values.");
        }
        if (data.length != cadenceLength()) {
            throw new IllegalArgumentException("Data length does not match cadence length.");
        }
        if (validCadences.size() > 0) {
            if (validCadences.get(0).start() < startCadence) {
                throw new IllegalArgumentException("validCadences come before startCadence.");
            }
            if (validCadences.get(validCadences.size() - 1).end() > endCadence) {
                throw new IllegalArgumentException("validCadences come after endCadence");
            }
        }
        if (originators.size() > 0) {
            if (originators.get(0).start() < startCadence) {
                throw new IllegalArgumentException("originators come before startCadence.");
            }
            if (originators.get(originators.size() - 1).end() > endCadence) {
                throw new IllegalArgumentException("originators come after endCadence");
            }
            if (originators.get(0).start() != validCadences.get(0).start()) {
                throw new IllegalArgumentException("originators and validCadences do not agree.");
            }
            if (originators.get(originators.size() - 1).end() != validCadences.get(validCadences.size() - 1).end()) {
                throw new IllegalArgumentException("originators and validCadences do not agree.");
            }
        }
    }
    
    public static TimeSeriesCarrier transferFrom(DataInputStream din) throws IOException {
        final String typeString = din.readUTF();
        final  TimeSeriesDataType dataType = TimeSeriesDataType.valueOfTypeString(typeString);
        final FsId id = FsId.readFrom(din);
        long startCadence = din.readInt();
        if (startCadence != NOT_EXIST_CADENCE) {
            startCadence = dataType.startCadenceToByteStartCadence(startCadence);
        }
        long endCadence = din.readInt();
        if (endCadence != NOT_EXIST_CADENCE) {
            endCadence = dataType.endCadenceToByteEndCadence(endCadence);
        }
        final boolean exists = din.readBoolean();
        final int nValidIntervals = din.readInt();
  
        List<SimpleInterval> validIntervals = new ArrayList<SimpleInterval>(nValidIntervals);
        for (int i=0; i < nValidIntervals; i++) {
            long start = dataType.startCadenceToByteStartCadence(din.readLong());
            long end = dataType.endCadenceToByteEndCadence(din.readLong());
            validIntervals.add(new SimpleInterval(start, end));
        }
        int nOriginatorIntervals = din.readInt();
        List<TaggedInterval> originIntervals = new ArrayList<TaggedInterval>(nOriginatorIntervals);
        for (int i=0; i < nOriginatorIntervals; i++) {
            long start = dataType.startCadenceToByteStartCadence(din.readLong());
            long end = dataType.endCadenceToByteEndCadence(din.readLong());
            long origin = din.readLong();
            originIntervals.add(new TaggedInterval(start, end, origin));
        }
        final byte[] data = (startCadence == NOT_EXIST_CADENCE && endCadence == NOT_EXIST_CADENCE) ?
            ArrayUtils.EMPTY_BYTE_ARRAY : new byte[(int)(endCadence - startCadence + 1)];
        for (SimpleInterval valid : validIntervals) {
            int len = (int) (valid.end() - valid.start() + 1);
            din.readFully(data, (int) (valid.start() - startCadence), len);
        }
        return new TimeSeriesCarrier(id, data, startCadence, endCadence, 
            validIntervals, originIntervals, exists, dataType);
    }

    public void transferTo(DataOutputStream dout) throws IOException {
        
        dout.writeUTF(carriedType.typeName());
        id.writeTo(dout);
        if (startCadence != NOT_EXIST_CADENCE) {
            dout.writeInt((int)carriedType.byteStartCadenceToStartCadence(startCadence));
        } else {
            dout.writeInt(NOT_EXIST_CADENCE);
        }
        if (endCadence != NOT_EXIST_CADENCE) {
            dout.writeInt((int)carriedType.byteEndCadenceToEndCadence(endCadence));
        } else {
            dout.writeInt(NOT_EXIST_CADENCE);
        }
        dout.writeBoolean(exists);
        dout.writeInt(validCadences.size());
        for (SimpleInterval valid : validCadences) {
            dout.writeLong(carriedType.byteStartCadenceToStartCadence(valid.start()));
            dout.writeLong(carriedType.byteEndCadenceToEndCadence(valid.end()));
        }
        dout.writeInt(originators.size());
        for (TaggedInterval originator : originators) {
            dout.writeLong(carriedType.byteStartCadenceToStartCadence(originator.start()));
            dout.writeLong(carriedType.byteEndCadenceToEndCadence(originator.end()));
            dout.writeLong(originator.tag());
        }
        for (SimpleInterval valid : validCadences) {
            int len = (int) (valid.end() - valid.start() + 1);
            dout.write(data, (int) (valid.start() - startCadence), len);
        }
    }
}
