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

package gov.nasa.kepler.cal;

import gov.nasa.kepler.cal.io.CalCollateralCosmicRay;
import gov.nasa.kepler.cal.io.CalOutputs;
import gov.nasa.spiffy.common.persistable.BinaryPersistableInputStream;

import java.io.BufferedInputStream;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.util.Comparator;
import java.util.List;
import java.util.SortedMap;
import java.util.TreeMap;

/**
 * This just reads the outputs of cal-matlab to verify it can be read.  Also 
 * useful for inspecting in the debugger.
 * 
 * @author Sean McCauliff
 *
 */
public class ReadOutputs {

    /**
     * @param args
     */
    public static void main(String[] argv) throws Exception {
        FileInputStream fin = new FileInputStream(argv[0]);
        BufferedInputStream bin = new BufferedInputStream(fin, 1024*1024);
        DataInputStream din = new DataInputStream(bin);
        BinaryPersistableInputStream bpin = new BinaryPersistableInputStream(din);
        CalOutputs outputs = new CalOutputs();
        bpin.load(outputs);
        /*
        findDuplicateCalCollateralCosmicRay(outputs.getBlack(), "black");
        findDuplicateCalCollateralCosmicRay(outputs.getMaskedBlack(), "masked black");
        findDuplicateCalCollateralCosmicRay(outputs.getMaskedSmear(), "masked smear");
        findDuplicateCalCollateralCosmicRay(outputs.getVirtualBlack(), "virtual black");
        findDuplicateCalCollateralCosmicRay(outputs.getVirtualSmear(), "virtual smear");
    */
        din.close();
    }
    
    private static void findDuplicateCalCollateralCosmicRay(List<CalCollateralCosmicRay> cccr, String type) {
        SortedMap<CalCollateralCosmicRay, CalCollateralCosmicRay> set = 
            new TreeMap<CalCollateralCosmicRay, CalCollateralCosmicRay>(new Comparator<CalCollateralCosmicRay>() {

            public int compare(CalCollateralCosmicRay o1, CalCollateralCosmicRay o2) {
                int diff = Double.compare(o1.getMjd(), o2.getMjd());
                if (diff != 0) {
                    return diff;
                }
                
                return o1.getRowOrColumn() - o2.getRowOrColumn();
            }
        });
        
        for (CalCollateralCosmicRay c : cccr) {
            if (set.containsKey(c)) {
                System.out.println("Original " + type + " \"" + set.get(c) +  "\".");
                System.out.println("Duplicate "  + type + " \"" + c + "\".");
            }
            set.put(c, c);
        }
    }

}
