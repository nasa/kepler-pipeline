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

package gov.nasa.kepler.etem2;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.ArrayUtils;

import gov.nasa.spiffy.common.pi.Parameters;

public class PackerParameters implements Parameters {

    private String dataSetName = "";
    private String startDate = "";
    private int longCadenceCount;
    /** Offsets are Strings that can contain
     * single numbers of ranges of the form N-M */
    private String[] cadenceGapOffsets = ArrayUtils.EMPTY_STRING_ARRAY;
    private String etemInputsFile = "";

    private boolean includeFfi;
    private boolean genDmcFiles;

    public PackerParameters() {
    }

    public String getStartDate() {
        return startDate;
    }

    public void setStartDate(String startDate) {
        this.startDate = startDate;
    }

    public String getDataSetName() {
        return dataSetName;
    }

    public void setDataSetName(String dataSetName) {
        this.dataSetName = dataSetName;
    }

    public int getLongCadenceCount() {
        return longCadenceCount;
    }

    public void setLongCadenceCount(int longCadenceCount) {
        this.longCadenceCount = longCadenceCount;
    }

    public boolean isIncludeFfi() {
        return includeFfi;
    }

    public void setIncludeFfi(boolean includeFfi) {
        this.includeFfi = includeFfi;
    }

    public boolean isGenDmcFiles() {
        return genDmcFiles;
    }

    public void setGenDmcFiles(boolean genDmcFiles) {
        this.genDmcFiles = genDmcFiles;
    }
    
    public String getEtemInputsFile() {
        return etemInputsFile;
    }

    public void setEtemInputsFile(String etemInputsFile) {
        this.etemInputsFile = etemInputsFile;
    }

    public String[] getCadenceGapOffsets() {
        return cadenceGapOffsets;
    }

    public void setCadenceGapOffsets(String[] cadenceGapOffsets) {
        this.cadenceGapOffsets = cadenceGapOffsets;
    }

    public List<Integer> cadenceGapOffsets(){
        ArrayList<Integer> gaps = new ArrayList<Integer>(cadenceGapOffsets.length);
        
        for (String s : cadenceGapOffsets) {
            if(s.contains("-")){
                //range
                String s1 = s.substring(0, s.indexOf("-"));
                String s2 = s.substring(s.indexOf("-")+1);
                int start = parseCadenceOffset(s1);
                int end = parseCadenceOffset(s2);
                
                if(start < 0 || start >= end || end < 0){
                    throw new IllegalArgumentException("Unparsable cadence offset range:" + s);
                }
                
                for (int i = start; i <= end; i++) {
                    gaps.add(i);
                }
            }else{
                // single
                gaps.add(parseCadenceOffset(s));
            }
        }
        return gaps;
    }
    
    private int parseCadenceOffset(String s){
        try {
            return Integer.parseInt(s);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Unparsable cadence offset:" + s);
        }
    }
}
