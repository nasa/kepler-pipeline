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

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.io.Serializable;
import java.io.UnsupportedEncodingException;
import java.util.Arrays;
import java.util.Comparator;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

/**
 * Identifies a time series or generic blob of data.
 * 
 * fs_id = path_part name_part
 *
 * path_part = path_segment+  "/"
 *
 * path_segment = "/" token
 *
 * name_part = token
 * 
 * token = allowed_char+
 *
 * allowed_char = "a"-"z" |  "A"-"Z" | "0"-"9" | "@" | "-" | "_" | "+" | ":" | "."
 * 
 * For example:
 * 
 * "/pdq/module:output:row:col"
 * "/dr/pixel/bkg/lc/m:o:r:c"
 * "/dr/pixel/bkg/lc/5:2:234:876"
 * 
 * "." and ".." are not allowed in a path_part
 * 
 * @author Sean McCauliff
 *
 */
@ProxyIgnoreStatics
public final class FsId implements Comparable<FsId>, Persistable, Serializable {

    /**
     * 
     */
    private static final long serialVersionUID = 5004474895517535393L;

    static final ConcurrentMap<String,String> pathCache 
        = new ConcurrentHashMap<String, String>();

    /** Maximum length for a file store id. */
    //Changing the value of this something else involves converting all the
    //B-tree indices.
    public static final int MAX_ID_LENGTH = 96;
    
    /** Handy comparator. */
    public static final Comparator<FsId> comparator = new Comparator<FsId>() {
        public int compare(FsId o1, FsId o2) {
            return o1.compareTo(o2);
        }
    };
 
    private String pathPart;
    private byte[] namePart;
    @ProxyIgnore
    private volatile transient int hashCode = 0;
    
    public FsId(String fullPath) {
        if (fullPath == null) {
            throw new NullPointerException("fullPath may not be null.");
        }
        
        validateWholeFsId(fullPath);
        
        int lastSlash = fullPath.lastIndexOf('/');
        String pathPartStr = fullPath.substring(0, lastSlash+1); 
        //Potentially faster than putIfAbsent
        String cachedPathPart = pathCache.get(pathPartStr);
        if (cachedPathPart == null) {
            this.pathPart = pathCache.putIfAbsent(pathPartStr , pathPartStr);
            if (this.pathPart == null) {
                this.pathPart = pathPartStr;
            }
        } else {
            this.pathPart = cachedPathPart;
        }

        this.namePart = asciiBytesForNamePart(fullPath, lastSlash+1, fullPath.length());

    }
    
    public FsId(String pathPart, String namePart) {
        if (pathPart == null) {
            throw new NullPointerException("pathPart may not be null.");
        }
        if (namePart == null) {
            throw new NullPointerException("namePart may not be null.");
        }
        if (pathPart.length() < 2) {
            throw new IllegalArgumentException("Invalid file store id \"" + 
                pathPart + namePart + "\".");
        }
        if (pathPart.charAt(pathPart.length() -1) != '/') {
            pathPart += '/';
        }
        
        validateParts(pathPart, namePart);
        
       //Potentially faster than calling putIfAbsent
        String cachedPathPart = pathCache.get(pathPart);
        if (cachedPathPart == null) {
            this.pathPart = pathCache.putIfAbsent(pathPart, pathPart);
            if (this.pathPart == null) {
                this.pathPart = pathPart;
            }
        } else {
            this.pathPart = cachedPathPart;
        }
        
        this.namePart = asciiBytesForNamePart(namePart, 0, namePart.length());
    }
    
    /** Required for persistable interface.  Do not use this constructor.
     */
    public FsId() {
        
    }
    
    /**
     * Useful for interning the path part of the FsId if this was moved over
     * the wire by Persistable.
     */
    public void intern() {
        try {
            validateParts(pathPart, new String(namePart, "UTF-8"));
        } catch (UnsupportedEncodingException e) {
            throw new IllegalStateException("can't validate FsId name", e);
        }
        pathPart = internPathPart(pathPart);
    }
    
    private FsId(String pathPart, byte[] namePart) {
        this.pathPart = internPathPart(pathPart);
        this.namePart = namePart;
    }
    
    private static String internPathPart(String path) {
        String cachedPath = pathCache.get(path);
        if (cachedPath == null) {
            pathCache.putIfAbsent(path, path);
            cachedPath = pathCache.get(path);
        }
        return cachedPath;
    }
    
    /**
     * 
     * @param s
     * @param startIndex
     * @param endIndex exclusive
     * @return
     */
    private static byte[] asciiBytesForNamePart(String s, int startIndex, int endIndex) {
    	byte[] name = new byte[endIndex - startIndex];
    	for (int i=startIndex; i < endIndex; i++) {
    		name[i - startIndex] = (byte) s.charAt(i);
    	}
    	return name;
    }
    
    private static void validateWholeFsId(String idStr) {
        int lastSlashIndex = idStr.lastIndexOf('/');
        if (lastSlashIndex == -1) {
            throw new MalformedFsIdException('"' + idStr + 
                "\"does not have a path part.");
        }
        
        if (lastSlashIndex == idStr.length() - 1) {
            throw new MalformedFsIdException('"' + idStr + 
            "\"does not have a name part.");
        }
        
        String pathPart = idStr.substring(0, lastSlashIndex + 1);
        String namePart = idStr.substring(lastSlashIndex + 1, idStr.length());
        
        validateParts(pathPart, namePart);
    }
    
    private static void validateParts(String pathPart, String namePart) {
        if ( pathPart.length() + namePart.length() > MAX_ID_LENGTH) {
            throw new MalformedFsIdException('"' + pathPart + namePart +
                "\" is longer than the maximum FsId length " +
                MAX_ID_LENGTH + ".");
        }
        
        validatePathPart(pathPart, namePart);
        validateNamePart(pathPart, namePart);
    }
    
    private static void validateNamePart(String pathPart, String namePart) {
        int len = namePart.length();
        if (len < 1) {
            throw new MalformedFsIdException('"' + pathPart +
                                    "\" is missing name part.");
        }
        
        for (int i=0; i <len; i++) {
            if (!validTokenChar(namePart.charAt(i))) {
                throw new MalformedFsIdException('"' + pathPart + namePart + 
                    "\" has invalid character '" + namePart.charAt(i) + "'.");
            }
        }
    }
    
    /**
     * 
     * @return true if this is a valid file store id, else false.
     */
    private static void validatePathPart(String pathPart, String namePart) {
        if (pathPart.length() < 3) {
            throw new MalformedFsIdException('"' + pathPart + namePart + 
                "\" has invalid path.");
        }
        
        if (pathPart.charAt(0) != '/') {
            throw new MalformedFsIdException("FsId path \"" + pathPart + 
                    "\" does not start with a '/' character.");
        }
        
        int len = pathPart.length();
        if (pathPart.charAt(len - 1) != '/') {
            throw new MalformedFsIdException("FsId path \"" + pathPart + 
                    "\" does not end with a '/' character.");
        }
        
        boolean expectSlash = false;
        for (int i=1; i < len; i++) {
            char c = pathPart.charAt(i);
            if (c == '/') {
                if (expectSlash) {
                    expectSlash = false;
                    continue;
                } else {
                    throw new MalformedFsIdException("FsId has path segment " +
                            " must contain something between //.  Path is \""+
                            pathPart + "\".");
                }
            } else if (c == '.') {
                //disallow '.' and '..'
                if (i < pathPart.length() - 1) {
                    if (pathPart.charAt(i+1) == '/' && pathPart.charAt(i-1) == '/') {
                        throw new MalformedFsIdException("Path part may not be '.' or '..'.");
                    } else if (pathPart.charAt(i + 1) == '.') {
                        throw new MalformedFsIdException("Path part may not be '.' or '..'.");
                    }
                } else if (pathPart.charAt(i - 1) == '/') {
                    throw new MalformedFsIdException("Path part may not be '.' or '..'.");
                }
            } else if (!validTokenChar(c)) {
                throw new MalformedFsIdException("FsId path \"" + pathPart + 
                    "\" contains invalid character '" + c + "'.");
            }
            expectSlash = true;
        }
        
    }
    
    private static boolean validTokenChar(char c) {
        if (c >= 'a' && c <= 'z') {
            return true;
        }
        
        if (c >= 'A' && c <= 'Z') {
            return true;
        }
        
        if (c >= '0' && c <= '9') {
            return true;
        }
        
        switch (c) {
            case '@' : return true;
            case '-': return true;
            case '_': return true;
            case '+': return true;
            case ':': return true;
            case '.': return true;
        }
        
        
        return false;
    }
    
    /**
     * Gets the path part of the id.
     * 
     * @return path_part
     */
    public String path() {
        return pathPart;
    }
    
    /**
     * Gets the name part of the id.
     * @return
     */
    public String name() {
        char[] buf = new char[namePart.length];
        for (int i=0; i < namePart.length; i++) {
            buf[i] = (char) namePart[i];
        }
        return new String(buf);
    }
    
    @Override
    public String toString() {
        StringBuilder bldr = new StringBuilder(pathPart.length() + namePart.length);
        bldr.append(pathPart);
        for (int i=0; i < namePart.length; i++) {
            bldr.append((char) namePart[i]);
        }
        return bldr.toString();
    }
    
    @Override
    public int hashCode() {
    	if (hashCode == 0)  {
    		hashCode = pathPart.hashCode() ^ Arrays.hashCode(namePart);
    	}
        return hashCode;
    }
    
    public byte[] toBytes() {
        try {
            return (pathPart + name()).getBytes("UTF-8");
        } catch (UnsupportedEncodingException x) {
            throw new IllegalStateException("UTF-8 is somehow not a supported character encoding.");
        }
    }
    
    public void writeTo(DataOutput dout) throws IOException {
        dout.writeUTF(pathPart);
        dout.writeByte((byte) namePart.length);
        dout.write(namePart);
    }
    
    /**
     * The number of bytes that would be written by calling writeTo()
     * @return A non-negative number.
     */
    public int writeToLength() {
        return 2 + pathPart.length() + 1 + namePart.length;
    }
    
    public int compareTo(FsId o) {
        FsId other = (FsId) o;
        int lenDiff = this.namePart.length - other.namePart.length;
        if (lenDiff != 0) {
            return lenDiff;
        }
        
        for (int i=0; i < this.namePart.length; i++) {
            int diff = this.namePart[i] - other.namePart[i];
            if (diff != 0) {
                return diff;
            }
         }
        
        return pathPart.compareTo(other.pathPart);
    }
    
    @Override
    public boolean equals(Object o) {
        if (o == null) {
            return false;
        }
        
        if (o.getClass() != FsId.class) {
            return false;
        }
        
        return compareTo((FsId)o) == 0;
    }
    
    public static String toString(FsId[] ids) {
        StringBuilder sb = new StringBuilder();
        for (FsId id : ids) {
            sb.append(id);
            sb.append(' ');
        }
        if (sb.length() > 0) {
            sb.setLength(sb.length() - 1);
        }
        return sb.toString();
    }
    
    public static FsId[] valueOf(String s) {
        if (s == null || s.length() == 0) {
            return new FsId[0];
        }
        
        String[] idStr = s.split(" ");
        FsId[] rv  = new FsId[idStr.length];
        for (int i=0; i < idStr.length; i++) {
            rv[i] = new FsId(idStr[i]);
        }
        return rv;
    }
    
    public static FsId valueOf(byte[] b) {
        try {
            String idStr = new String(b, "UTF-8");
            return new FsId(idStr);
        } catch (UnsupportedEncodingException uex) {
            throw new IllegalStateException("Some how UTF-8 encoding is not supported.", uex);
        }
    }
    
    public static FsId readFrom(DataInput din) throws IOException {
        String pathPart = din.readUTF();
        byte nameLen = din.readByte();
        byte[] namePart = new byte[nameLen];
        din.readFully(namePart);
        return new FsId(pathPart, namePart);
    }
}
