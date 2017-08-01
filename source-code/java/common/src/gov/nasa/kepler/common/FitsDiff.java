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

package gov.nasa.kepler.common;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.BinaryTableHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;
import nom.tam.fits.HeaderCard;

import static org.apache.commons.lang.ArrayUtils.*;

/**
 * Diffs two FITS files.  This is useful for testing as the contents of the
 * comments fields are ignored.
 * 
 * @author Sean McCauliff
 *
 */
public class FitsDiff {
    
    public FitsDiff() {
        
    }
    
    /**
     * 
     * @param f1 Must be a fits file, else an exception is thrown.
     * @param f2 Must be a fits file, else an exception is thrown.
     * @param diff() fills this with differences it finds.
     * @return true if files differ, else false.
     * @throws IOException
     */
    public boolean diff(File f1, File f2, List<String> diffs) 
        throws IOException, FitsException {
        
        boolean rv = false;
        
        Fits fits1 = new Fits(f1);
        Fits fits2 = new Fits(f2);
        fits1.read();
        fits2.read();
        if (fits1.getNumberOfHDUs() != fits2.getNumberOfHDUs()) {
            diffs.add("f1 has " + fits1.getNumberOfHDUs() + " hdus f2 has "
                      + fits2.getNumberOfHDUs() + " hdus.");
            return true;
        }
        
        for (int headerIndex=0; headerIndex < fits1.getNumberOfHDUs(); headerIndex++) {
            BasicHDU bhdu1 = fits1.getHDU(headerIndex);
            BasicHDU bhdu2 = fits2.getHDU(headerIndex);
            
            if (bhdu1 instanceof BinaryTableHDU) {
                if (!( bhdu2 instanceof BinaryTableHDU) ) {
                    diffs.add("Header " + headerIndex + " is binary table in f1 but not in f2.");
                    rv = true;
                } else {
                    
                    BinaryTableHDU bin1 = (BinaryTableHDU) bhdu1;
                    BinaryTableHDU bin2  = (BinaryTableHDU) bhdu2;
                    rv = diffHeader(bin1, bin2,headerIndex, diffs) || rv;
                }
            } else if (bhdu2 instanceof BinaryTableHDU) {
                diffs.add("Header " + headerIndex + " is binary table in f2 but not in f1.");
            } else {
                rv = diffHeader(bhdu1, bhdu2, headerIndex, diffs) || rv;
            }
        }
        
        return rv;
    }
    
    /**
     * 
     * @param bhdu1
     * @param bhdu2
     * @param diffs
     * @return true if there are differences, else false
     */
    protected boolean diffHeader(BasicHDU bhdu1, BasicHDU bhdu2, int headerIndex, List<String> diffs) {
        boolean rv = false;
        Map<String, HeaderCard> cards1 = buildMap(bhdu1);
        Map<String, HeaderCard> cards2 = buildMap(bhdu2);
        
        Set<String> inSet1 = setDifference(cards1.keySet(), cards2.keySet());
        for (String inSet1Diff : inSet1) {
            if (!isDiffOk(inSet1Diff)) {
                diffs.add("Header: " + headerIndex + " Keyword \""+inSet1Diff +
                    "\" is present in f1, but not in f2.");
                rv = true;
            }
        }
        
        Set<String> inSet2 = setDifference(cards2.keySet(), cards1.keySet());
        for (String inSet2Diff : inSet2) {
            if (!isDiffOk(inSet2Diff)) {
                diffs.add("Header: " + headerIndex + " Keyword \""+inSet2Diff +
                    "\" is present in f2, but not in f1.");
                rv = true;
            }
        }
       
        Set<String> same = setIntersection(cards1.keySet(), cards2.keySet());
        for (String key : same) {
            HeaderCard card1 = cards1.get(key);
            HeaderCard card2 = cards2.get(key);
            String msg = diffHeaderCard(card1, card2);
            if (msg != null) {
                diffs.add(msg);
                rv = true;
            }
        }
        
       return rv;
        
    }
    
    /**
     * Called when a keyword is only present in one of the sets.
     * @param keyword
     * @return true if the presence of this keyword in only one file is ok.
     */
    protected boolean isDiffOk(String keyword) {
        return false;
    }
    
    protected boolean diffHeader(BinaryTableHDU bin1, BinaryTableHDU bin2, int headerIndex, List<String> diffs)
        throws FitsException
    {
        boolean rv = false;
        
        rv = diffHeader((BasicHDU) bin1, (BasicHDU) bin2, headerIndex, diffs);
        
        if ( bin1.getNCols() != bin2.getNCols()) {
            diffs.add("Number of binary columns differ.");
            return true;
        }
        
        for (int c = 0; c < bin1.getNCols(); c++) {
            Object o1 = bin1.getColumn(c);
            Object o2 = bin2.getColumn(c);
            rv = diffColumns(o1, o2, headerIndex, diffs, bin1.getColumnName(c)) || rv;
        }
        
        return rv;
    }
    
   
    
    /**
     * 
     * @param set1
     * @param set2
     * @return  The strings in set1 that are not in set2.
     */
    protected Set<String> setDifference(Set<String> set1, Set<String> set2) {
        Set<String> difference = new HashSet<String>();
        for (String e1 : set1) {
            if (!set2.contains(e1)) {
                difference.add(e1);
            }
        }
        return difference;
    }
    
    /**
     * Assumes that the keys of the cards are the same.
     * @param card1
     * @param card2
     * @return null if nothing is different, else a descriptive string.
     */
    protected String diffHeaderCard(HeaderCard card1, HeaderCard card2) {
        if (card1.getValue() == null) {
            if (card2.getValue() == null) return null;
            return "\"" + card1.getKey() + "\" empty / \""+card2.getValue()+"\"";
        } else if (card2.getValue() == null) {
            return "\"" + card1.getKey() + "\"  \""+card1.getValue() +"\" / empty";
        }
        
        if (card1.getValue().equals(card2.getValue())) {
            return null;
        }
        
        return "\"" + card1.getKey() + "\"  \""+card1.getValue() +"\" / \""+card2.getValue()+"\"";
        
    }
    
    protected Set<String> setIntersection(Set<String> set1, Set<String> set2) {
        Set<String> intersect = new HashSet<String>();
        for (String s : set1) {
            if (set2.contains(s)) {
                intersect.add(s);
            }
        }
        return intersect;
    }
    
    protected Map<String, HeaderCard> buildMap(BasicHDU bhdu) {
        @SuppressWarnings("rawtypes")
        Iterator it = bhdu.getHeader().iterator();
        Map<String, HeaderCard> cardMap = new HashMap<String, HeaderCard>();
            
        while (it.hasNext()) {
            HeaderCard card = (HeaderCard) it.next();
            cardMap.put(card.getKey(), card);
        } 
        
        return cardMap;
    }
    
    public String joinDiffs(List<String> diffs) {
        StringBuilder builder = new StringBuilder();
        for (String s : diffs) {
            builder.append(s).append('\n');
        }
        return builder.toString();
    }
    
   
    
    /**
     * This currently only diffs a subset of possiable array types.
     * @param o1 An array.
     * @param o2 Another array.
     * @param diffs
     * @return
     */
    protected boolean diffColumns(Object o1, Object o2, int headerIndex,  List<String> diffs, String colName) {
        try {
            if (o1.getClass() == EMPTY_BYTE_ARRAY.getClass()) {
                return dataDiffMsg(!Arrays.equals((byte[])o1, (byte[])o2), headerIndex, diffs, colName);
            } else if (o1.getClass() == EMPTY_SHORT_ARRAY.getClass()) {
                return dataDiffMsg(!Arrays.equals((short[])o1, (short[])o2), headerIndex, diffs, colName);
            } else if (o1.getClass() == EMPTY_INT_ARRAY.getClass()) {
                return dataDiffMsg(!Arrays.equals((int[])o1, (int[])o2), headerIndex, diffs, colName);
            } else if (o1.getClass() == EMPTY_FLOAT_ARRAY.getClass()) {
                return dataDiffMsg(!Arrays.equals((float[])o1, (float[])o2), headerIndex, diffs, colName);
            } else if (o1.getClass() == EMPTY_DOUBLE_ARRAY.getClass()) {
                return dataDiffMsg(!Arrays.equals((double[])o1, (double[])o2), headerIndex, diffs, colName);
            } else if (o1.getClass() == EMPTY_BOOLEAN_ARRAY.getClass()) {
                return dataDiffMsg(!Arrays.equals((boolean[]) o1, (boolean[]) o2), headerIndex, diffs, colName);
            } else {
                return dataDiffMsg(!Arrays.deepEquals((Object[])o1, (Object[])o2), headerIndex, diffs, colName);
            }

        } catch (ClassCastException cce) {
            diffs.add("Different column types " + o1.getClass() + 
                        " " + o2.getClass() + " for column \"" + colName + "\".");
            return true;
        }
    }
    
    private boolean dataDiffMsg(boolean isDiff, int headerIndex, List<String> diffs, String colName) {
        if (isDiff) {
            diffs.add("Header: " + headerIndex  + " Binary table data differs for column \"" + colName +"\".");
        }
        return isDiff;
    }
    
    /**
     * argv[0] The name of a fits file.
     * argv[1] The name of a fits file.
     * @param argv
     */
    public static void main(String[] argv) throws Exception {
        FitsDiff diff = new FitsDiff();
        List<String> differences = new ArrayList<String>();
        diff.diff(new File(argv[0]),new File(argv[1]), differences);
        System.out.println(diff.joinDiffs(differences));
        if (differences.size() == 0) {
            System.exit(0);
        }
        System.exit(1);
    }

    
}
