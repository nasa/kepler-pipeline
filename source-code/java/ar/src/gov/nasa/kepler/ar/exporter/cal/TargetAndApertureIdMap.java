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

package gov.nasa.kepler.ar.exporter.cal;

import static gov.nasa.kepler.common.FitsConstants.*;
import gnu.trove.TLongIntHashMap;
import gnu.trove.TLongShortHashMap;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapperFactory;

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

import nom.tam.fits.BinaryTableHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;

/**
 * Maps from (row, column) -> (targetId, apertureId).  This is designed to be
 * more memory efficient than a Map<Pair<Integer, Integer>, Pair<Integer,Integer>>
 * 
 * @author Sean McCauliff
 *
 */
class TargetAndApertureIdMap {
    private final Set<String> seenPmrfs = new HashSet<String>();
    private final TLongShortHashMap rncToApertureId = new TLongShortHashMap();
    private final TLongIntHashMap rncToTargetId = new TLongIntHashMap();
    
    TargetAndApertureIdMap() {
    }
    
    /**
     * Add PMRF
     * @throws IOException 
     * @throws FitsException 
     */
    public void addVisiblePmrf(Fits pmrfFits, String pmrfName) throws FitsException, IOException {
        if (seenPmrfs.contains(pmrfName)) {
            return;
        }
        
        boolean isBackground = pmrfName.endsWith(DispatcherWrapperFactory.BACKGROUND_PMRF);
        pmrfFits.read();
        for (int i=1; i< pmrfFits.getNumberOfHDUs(); i++) {
            BinaryTableHDU binTable = (BinaryTableHDU) pmrfFits.getHDU(i);
            short[] rows = (short[]) binTable.getColumn(0);
            short[] cols = (short[]) binTable.getColumn(1);
            int[] targetIds = (int[]) binTable.getColumn(2);
            short[] apertureIds = (short[]) binTable.getColumn(3);
            short module = (short) binTable.getHeader().getIntValue(MODULE_KW);
            short output = (short) binTable.getHeader().getIntValue(OUTPUT_KW);
            
            addIds(module, isBackground, output, rows, cols, targetIds, apertureIds);
        }
        seenPmrfs.add(pmrfName);
    }
    
    /**
     * 
     * @param module
     * @param output
     * @param rows
     * @param cols
     * @param targetIds
     * @param apertureIds
     */
    public void addIds(short module, boolean isBackground, short output, short rows[], short cols[], int[] targetIds, short[] apertureIds) {
        for (int i=0; i < rows.length; i++) {
            long key = makeKey(module, isBackground, output, rows[i], cols[i]);
            rncToApertureId.put(key, apertureIds[i]);
            rncToTargetId.put(key, targetIds[i]);
        }
    }
    
    private long makeKey(short module, boolean isBackground, 
                         short output, short row, short col) {
        long lrow = row;
        long lcol = col;
        long lmod = module;
        long lout = output;
        long background = (isBackground) ? 1 :0;
        return (background << 48) |(lmod << 40) | (lout << 32) | ( lrow << 16) | lcol;
    }
    
    /**
     * 
     * @param row
     * @param col
     * @param isBackground is this for a background pixel?
     * @return This returns null if (row, col) does not exist.
     */
    TargetAndApertureId find(short module, boolean isBackground, 
                             short output, short row, short col) {
        long key = makeKey(module, isBackground, output, row, col);
        
        if (!rncToApertureId.containsKey(key)) {
            return null;
        }
        
        TargetAndApertureId rv = 
            new TargetAndApertureId(rncToTargetId.get(key), rncToApertureId.get(key) );
        return rv;
    }
    
    static final class TargetAndApertureId {
        final int targetId;
        final short apertureId;
        
        TargetAndApertureId(int targetId, short apertureId) {
            this.targetId = targetId;
            this.apertureId = apertureId;
        }
    }
}
