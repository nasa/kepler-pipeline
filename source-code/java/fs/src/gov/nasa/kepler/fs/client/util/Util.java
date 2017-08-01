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

package gov.nasa.kepler.fs.client.util;

import java.io.UnsupportedEncodingException;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.net.UnknownHostException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.transaction.xa.Xid;

import org.apache.commons.codec.binary.Base64;
/**
 * 
 * @author Sean McCauliff
 *
 */
public class Util {

    private static final ThreadLocal<Base64> base64Encoder =
        new ThreadLocal<Base64>() {
        
        @Override
        protected Base64 initialValue() {
            return new Base64();
        }
    };
    
    private static final Pattern xidPattern = 
        Pattern.compile("Xid_([0-9A-Za-z+\\-\\.]+)_([0-9A-Za-z+\\-\\.]+)_(\\d+)", 
                        Pattern.CASE_INSENSITIVE);
    
    public static PersistableXid stringToXid(String str) 
        throws NumberFormatException {
        Matcher m = xidPattern.matcher(str);
        if (!m.matches()) {
            throw new IllegalArgumentException("Bad xid \"" + str + "\".");
        }
    
        try {
            byte[] globalStr = m.group(1).getBytes("US-ASCII");
            replaceGoodCharactersWithBad(globalStr);
            byte[] global = base64Encoder.get().decode(globalStr);   //hexStringToByteArray(m.group(1));
            byte[] branchStr = m.group(2).getBytes("US-ASCII");
            replaceGoodCharactersWithBad(branchStr);
            byte[] branch = base64Encoder.get().decode(branchStr);
            int format = Integer.parseInt(m.group(3));
            return new PersistableXid(global, branch, format);
        } catch (UnsupportedEncodingException uee) {
            throw new IllegalStateException("US-ASCII unsupported character encoding.", uee);
        }
        
    }
    
    public static String xidToString(Xid xid) {
        StringBuilder bldr = new StringBuilder();
        bldr.append("Xid_");
        //appendHexString(bldr, xid.getGlobalTransactionId());
        byte[] encodedGlobal = base64Encoder.get().encode(xid.getGlobalTransactionId());
        filterBadFileNameCharacters(encodedGlobal);
        for (byte b64char : encodedGlobal) {
            bldr.append((char) b64char);
        }
        bldr.append("_");
       // appendHexString(bldr, xid.getBranchQualifier());
        byte[] encodedBranch = base64Encoder.get().encode(xid.getBranchQualifier());
        filterBadFileNameCharacters(encodedBranch);
        for (byte b64char : encodedBranch) {
            bldr.append((char) b64char);
        }
        bldr.append("_").append(xid.getFormatId());
        return bldr.toString();
    }
    
    private static void filterBadFileNameCharacters(byte[] b64Encoded) {
        for (int i=0; i < b64Encoded.length; i++) {
            switch ((char) b64Encoded[i]) {
                case '/': b64Encoded[i] = '.'; break;
                case '=': b64Encoded[i] = '-'; break;
            }
        }
    }
    
    private static void replaceGoodCharactersWithBad(byte[] b64Encoded) {
        for (int i=0; i < b64Encoded.length; i++) {
            switch ((char) b64Encoded[i]) {
                case '.': b64Encoded[i] = '/'; break;
                case '-' : b64Encoded[i] = '='; break;
            }
        }
    }
    

    
    public static SocketAddress parseFstpUrl(String fstpUrl) 
        throws IllegalArgumentException, UnknownHostException {
        
        Pattern urlPattern = 
            Pattern.compile("fstp://(\\d+\\.\\d+\\.\\d+\\.\\d+|[a-zA-Z0-9_.-]+):(\\d+)");
        Matcher matcher = urlPattern.matcher(fstpUrl.trim());
        if (!matcher.matches()) {
            throw new IllegalArgumentException("Invalid fstp url \"" + fstpUrl + "\".");
        }
        
        String host =  matcher.group(1);
        String portStr = matcher.group(2);
        
        int port = Integer.parseInt(portStr);
        if (port <= 0 || port >= (1 << 16)) {
            throw new IllegalArgumentException("Invalid port number \"" + port + "\".");
        }
        
        InetAddress address = InetAddress.getByName(host);
        return new InetSocketAddress(address, port);
    }
     
}
