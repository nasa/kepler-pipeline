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

import java.util.Vector;

public class VcduPackerInputDatasetSpec {
    
    private String ccsdsFilename;
    private int startLongCadencePeriod;
    private int endLongCadencePeriod;
        
    public static final int FIRST = 0;
    public static final int LAST = -1;
        
    /**
     * Create an input specification for the VcduPacker.  VcduPacker accepts a List of these specs.
     */
    public VcduPackerInputDatasetSpec( String ccsdsFilename, int startLongCadencePeriod, int endLongCadencePeriod ) {
        this.ccsdsFilename = ccsdsFilename;
        this.startLongCadencePeriod = startLongCadencePeriod;
        this.endLongCadencePeriod = endLongCadencePeriod;
    }
    
    public String toString() {
        return "("+ccsdsFilename+":"+startLongCadencePeriod+"-"+endLongCadencePeriod+")";
    }
            
    /**
     * Given the input string "p1:0-7,p2,p1:8-LAST,p3:FIRST-9"
     * creates a Vector containing 4 VcduPackerInputDatasetSpec objects:
     * {ccsdsFilename="rootDir/p1/packetized/ccsds/ccsds.dat",start=FIRST,end=7}
     * {ccsdsFilename="rootDir/p2/packetized/ccsds/ccsds.dat",start=FIRST,end=LAST}
     * {ccsdsFilename="rootDir/p1/packetized/ccsds/ccsds.dat",start=8,end=LAST}
     * {ccsdsFilename="rootDir/p3/packetized/ccsds/ccsds.dat",start=FIRST,end=9}
     * @param s
     * @return
     */
    public static Vector<VcduPackerInputDatasetSpec> parse(String datasetRootDir, String specs) 
    throws Exception {
        Vector<VcduPackerInputDatasetSpec> inputSpecs = new Vector<VcduPackerInputDatasetSpec>();
        int colon;
        int hyphen;
        String datasetSubdirName;
        int start;
        int end;
        String[] specList = specs.split(",");
        for (String spec : specList) {
            if ( -1 == ( colon = spec.indexOf(':'))) {
                datasetSubdirName = spec;
                start = FIRST;
                end = LAST;
            } else {
                if ( -1 == ( hyphen = spec.indexOf('-'))) {
                    throw new Exception("colon with no hyphen in " + specs);
                }
                datasetSubdirName = spec.substring(0, colon);
                start = parseCadencePeriodNumber( spec.substring(colon+1, hyphen));
                end   = parseCadencePeriodNumber( spec.substring(hyphen+1));
            }
            inputSpecs.add( new VcduPackerInputDatasetSpec(
                datasetRootDir + "/" + datasetSubdirName + "/packetized/ccsds/ccsds.dat",
                start, end) );
        }
        return inputSpecs;
    }
        
    private static int parseCadencePeriodNumber(String s) throws Exception {
        if (s==null) {
            throw new Exception("cadence period number is null");
        } else if ( s.equals("FIRST")) {
            return FIRST;
        } else if ( s.equals("LAST")) {
            return LAST;
        } else {
            return Integer.parseInt( s);
        }
    }

    /**
     * @return the ccsdsFilename
     */
    public String getCcsdsFilename() {
        return ccsdsFilename;
    }

    /**
     * @param ccsdsFilename the ccsdsFilename to set
     */
    public void setCcsdsFilename(String ccsdsFilename) {
        this.ccsdsFilename = ccsdsFilename;
    }

    /**
     * @return the startLongCadencePeriod
     */
    public int getStartLongCadencePeriod() {
        return startLongCadencePeriod;
    }

    /**
     * @param startLongCadencePeriod the startLongCadencePeriod to set
     */
    public void setStartLongCadencePeriod(int startLongCadencePeriod) {
        this.startLongCadencePeriod = startLongCadencePeriod;
    }

    /**
     * @return the endLongCadencePeriod
     */
    public int getEndLongCadencePeriod() {
        return endLongCadencePeriod;
    }

    /**
     * @param endLongCadencePeriod the endLongCadencePeriod to set
     */
    public void setEndLongCadencePeriod(int endLongCadencePeriod) {
        this.endLongCadencePeriod = endLongCadencePeriod;
    }
}
