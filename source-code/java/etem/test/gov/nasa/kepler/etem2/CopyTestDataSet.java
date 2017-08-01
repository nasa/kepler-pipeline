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

import gov.nasa.kepler.common.FilenameConstants;

import java.io.File;
import java.io.IOException;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class CopyTestDataSet {
    private static final Log log = LogFactory.getLog(CopyTestDataSet.class);

    private static final int NUM_LONG_CADENCES = 48;
    private static final String inDir = FilenameConstants.SOC_ROOT
        + "/etem2/auto/30d/";
    private static final String outDir = FilenameConstants.SOC_ROOT
        + "/etem2/debug/test";
    
    public CopyTestDataSet() {
    }

    /**
     * @param args
     * @throws IOException 
     */
    public static void main(String[] args) throws Exception {
        
        File shortDirOutFile = new File(outDir,"short/merged");
        File longDirOutFile = new File(outDir,"long/merged");
        
        File shortDirInFile = new File(inDir,"short/merged");
        File longDirInFile = new File(inDir,"long/merged");
        
        FileUtils.deleteDirectory(new File(outDir));
        
        FileUtils.forceMkdir(shortDirOutFile);
        FileUtils.forceMkdir(longDirOutFile);
        
        for (int lc = 0; lc < NUM_LONG_CADENCES; lc++) {
            File src = new File(longDirInFile,"mergedCadenceData-"+lc+".dat");
            log.info("copying long cadence: " + src);
            FileUtils.copyFileToDirectory(src, longDirOutFile);
        }

        for (int sc = 0; sc < (NUM_LONG_CADENCES * 30)+1; sc++) {
            File src = new File(shortDirInFile,"mergedCadenceData-"+sc+".dat");
            log.info("copying short cadence: " + src);
            FileUtils.copyFileToDirectory(src, shortDirOutFile);
        }
    }
}
