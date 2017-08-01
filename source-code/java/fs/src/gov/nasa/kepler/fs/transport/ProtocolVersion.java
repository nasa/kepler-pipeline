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

package gov.nasa.kepler.fs.transport;

import gov.nasa.kepler.fs.FileStoreConstants;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;

import org.apache.commons.configuration.Configuration;

/**
 * Protocol version constants.
 * 
 * @author Sean McCauliff
 *
 */
enum ProtocolVersion {
    //Do not change the order of these fields except for NUM_PROTOCOL_VERSION
    PROTOCOL_LEGACY(0, 0),
    PROTOCOL_V1(1024*1024*4, 5),
    /** V2 uses directly allocated buffers which are more difficult to manage
     * so buffer size is smaller.  The headers also contain a method invocation
     * number which is used to dispose of bad messages that are on their way
     * over the network.
     */
    PROTOCOL_V2(1024*1024, 9),
    NUM_PROTOCOL_VERSIONS(-1, -1); //this must always be last.
    
    public static final ProtocolVersion CURRENT_PROTOCOL_VERSION = PROTOCOL_V2;
    
    private final int maxPayloadSize;
    
    private final int maxMessageSize;
    
    private final int dataMessageHeaderSize;
    
    private ProtocolVersion(int maxPayloadSize, int dataMessageHeaderSize) {
        this.maxPayloadSize = maxPayloadSize;
        this.dataMessageHeaderSize = dataMessageHeaderSize;
        this.maxMessageSize = maxPayloadSize + dataMessageHeaderSize;
    }
    
    public static ProtocolVersion ordinalToEnum(int ordinal) throws TransportException {
        if (ordinal == PROTOCOL_V1.ordinal()) {
            return PROTOCOL_V1;
        } else if (ordinal == PROTOCOL_V2.ordinal()) {
            return PROTOCOL_V2;
        }
        throw new TransportException("Invalid or unsupported protocol version "+
            ordinal + ".");
    }
    
    /**
     * The size of the payload.
     * @return  The size of the payload in bytes for data message in bytes.  This will be
     * a number greater than zero unless it is an invalid protocol version like
     * legacy, or num.
     */
    public int maxPayloadSize() {
        return maxPayloadSize;
    }
    
    /**
     * The total size of a data message, header + payload.
     * @return  The total maximum size of a data message in bytes.
     * This is a number greater than zero unless it is an invalid
     * protocol version number like legacy or num.
     */
    public int maxMessageSize() {
        return maxMessageSize;
    }
    
    /**
     * The size of a data message header.
     * @return The size of the data message header in bytes.  This is a number
     * greater than zero unless it is an invalid protocol version like legacy
     * or num_versions.
     */
    public int dataMessageHeaderSize() {
        return dataMessageHeaderSize;
    }
    
    /**
     * It seems like a bad idea to try and override toString() for an enum so
     * this method is here instead.
     * @return The enum and its contents.
     */
    public String debugString() {
        StringBuilder bldr = new StringBuilder();
        bldr.append(name()).append('(').append(ordinal()).append(")[payload=")
            .append(maxPayloadSize).append(",message=").append(maxMessageSize)
            .append("header=").append(dataMessageHeaderSize).append("]");
        return bldr.toString();
    }

    public static ProtocolVersion configuredProtocolVersion() 
        throws TransportException {
        Configuration configuration = ConfigurationServiceFactory.getInstance();
        int ord =
            configuration.getInt(FileStoreConstants.FS_PROTOCOL_VERSION, CURRENT_PROTOCOL_VERSION.ordinal());
        return ordinalToEnum(ord);
    }
}
