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

package gov.nasa.kepler.dr.fits;

import static com.google.common.collect.Maps.newHashMap;

import java.util.Map;
import java.util.Map.Entry;

import static com.google.common.base.Preconditions.checkNotNull;

import nom.tam.fits.Header;
import nom.tam.fits.HeaderCard;
import nom.tam.fits.HeaderCardException;
import nom.tam.util.Cursor;

/**
 * Contains a fits header.
 * 
 * A {@code FitsHeader} is a Facade for a {@link Header}, supplying accessors
 * for its key-value pairs, converters, {@code toString()}, {@code hashCode()}
 * and {@code equals()}.
 * 
 * @author Miles Cote
 * 
 */
public final class FitsHeader {

    @Override
    public String toString() {
        return "FitsHeader [header=" + getNameValuePairs(header) + "]";
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + ((header == null) ? 0 : getNameValuePairs(header).hashCode());
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
        FitsHeader other = (FitsHeader) obj;
        if (header == null) {
            if (other.header != null)
                return false;
        } else if (!getNameValuePairs(header).equals(
            getNameValuePairs(other.header)))
            return false;
        return true;
    }

    private final Header header;

    public boolean getBooleanValue(String key) {
        checkNotMissing(key);
        return header.getBooleanValue(key);
    }

    public byte getByteValue(String key) {
        checkNotMissing(key);
        return (byte) header.getIntValue(key);
    }

    public short getShortValue(String key) {
        checkNotMissing(key);
        return (short) header.getIntValue(key);
    }

    public int getIntValue(String key) {
        checkNotMissing(key);
        return header.getIntValue(key);
    }

    public long getLongValue(String key) {
        checkNotMissing(key);
        return header.getLongValue(key);
    }

    public float getFloatValue(String key) {
        checkNotMissing(key);
        return header.getFloatValue(key);
    }

    public double getDoubleValue(String key) {
        checkNotMissing(key);
        return header.getDoubleValue(key);
    }

    public String getStringValue(String key) {
        checkNotMissing(key);
        return header.getStringValue(key);
    }

    private void checkNotMissing(String key) {
        if (!header.containsKey(key)) {
            throw new IllegalArgumentException(
                "The key cannot be missing from the header." + "\n  key: "
                    + key + "\n  header: " + header);
        }
    }

    private Map<String, String> getNameValuePairs(Header header) {
        checkNotNull(header, "header can't be null.");
        Map<String, String> nameValuePairs = newHashMap();

        Cursor cursor = header.iterator();
        while (cursor.hasNext()) {
            HeaderCard headerCard = (HeaderCard) cursor.next();
            nameValuePairs.put(headerCard.getKey(), headerCard.getValue());
        }

        return nameValuePairs;
    }

    public static final FitsHeader of(Map<String, String> nameValuePairs) {
        checkNotNull(nameValuePairs, "nameValuePairs can't be null.");
        Header header = new Header();
        try {
            for (Entry<String, String> entry : nameValuePairs.entrySet()) {
                header.addValue(entry.getKey(), entry.getValue(), "");
            }
        } catch (HeaderCardException e) {
            throw new IllegalArgumentException("Unable to add value.", e);
        }

        return FitsHeader.of(header);
    }

    public static final FitsHeader of(Header header) {
        checkNotNull(header, "header can't be null.");
        return new FitsHeader(header);
    }

    private FitsHeader(Header header) {
        checkNotNull(header, "header can't be null.");
        this.header = header;
    }

    public Header getHeader() {
        return header;
    }
}
