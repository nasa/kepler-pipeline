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

package gov.nasa.kepler.mc.fs;


import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.spiffy.common.lang.StringUtils;


public class FpgFsIdFactory {


    public static final String FPG_PATH = "/fpg";

    public enum BlobSeriesType {
        FPG_RESULTS(FPG_PATH),
        FPG_IMPORT(FPG_PATH),
        FPG_GEOMETRY(FPG_PATH);

        private String pathName;
        private String pathBase;

        private BlobSeriesType(String pathBase) {
            pathName = StringUtils.constantToCamel(super.toString())
                .intern();
            this.pathBase = pathBase;
        }

        public String pathName() {
            return pathName;
        }
        
        public String pathBase() {
        	return pathBase;
        }
    }
    
    

    /**
     * Prevent instantiation.
     * 
     */
    private FpgFsIdFactory() {
    }

    /**
     * Get FsId for matlab blob data.
     * 
     * @return
     */
    public static FsId getMatlabBlobFsId(BlobSeriesType blobType, 
    		int startCadence, int endCadence, long pipelineTaskId) {

        if (blobType == null) {
            throw new NullPointerException("blobType is null");
        }
        StringBuilder fullPath = new StringBuilder(32);
        fullPath.append(blobType.pathBase())
            .append('/');
        fullPath.append(blobType.pathName())
            .append('/');
        fullPath.append(startCadence)
            .append(PrfFsIdFactory.PRF_SEP);
        fullPath.append(endCadence).append(PrfFsIdFactory.PRF_SEP);
        fullPath.append(pipelineTaskId);
        return new FsId(fullPath.toString());
    }
    

}
