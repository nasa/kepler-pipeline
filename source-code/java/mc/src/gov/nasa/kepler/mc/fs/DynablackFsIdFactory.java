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

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import gov.nasa.kepler.fs.api.FsId;

/**
 * Creates {@link FsId}s for dynablack.
 * 
 * @author Miles Cote
 * 
 */
public class DynablackFsIdFactory extends PixelFsIdFactory {

    private static final String DYNAMIC_TWOD_BLACK_BLOB = "dynamicTwoDBlackBlob";
    private static final String ROLLING_BAND_ARTIFACT_FLAGS = "rollingBandArtifactFlags";
    private static final String ROLLING_BAND_ARTIFACT_VARIATION = "rollingBandArtifactVariation";
    private static final String DYNABLACK_PATH = "/dynablack/";
    private static final Pattern rollingBandFlagPattern = Pattern.compile("(\\d+)/(\\d+)/(\\d+):(\\d+)");

    private DynablackFsIdFactory() {
    }

    public static FsId getDynamicTwoDBlackBlobFsId(int ccdModule,
        int ccdOutput, long pipelineTaskId) {

        StringBuilder fullPath = new StringBuilder();
        fullPath.append(DynablackFsIdFactory.DYNABLACK_PATH)
            .append(DYNAMIC_TWOD_BLACK_BLOB)
            .append('/')
            .append(ccdModule)
            .append(PixelFsIdFactory.SEP)
            .append(ccdOutput)
            .append(PixelFsIdFactory.SEP)
            .append(pipelineTaskId);

        return new FsId(fullPath.toString());
    }

    public static FsId getRollingBandArtifactFlagsFsId(int ccdModule,
        int ccdOutput, int row, int testPulseDurationLc) {

        StringBuilder fullPath = new StringBuilder();
        fullPath.append(DynablackFsIdFactory.DYNABLACK_PATH)
            .append(ROLLING_BAND_ARTIFACT_FLAGS)
            .append('/')
            .append(ccdModule)
            .append('/')
            .append(ccdOutput)
            .append('/')
            .append(row)
            .append(PixelFsIdFactory.SEP)
            .append(testPulseDurationLc);

        return new FsId(fullPath.toString());
    }

    public static FsId getRollingBandArtifactVariationFsId(int ccdModule,
        int ccdOutput, int row, int testPulseDurationLc) {

        StringBuilder fullPath = new StringBuilder();
        fullPath.append(DynablackFsIdFactory.DYNABLACK_PATH)
            .append(ROLLING_BAND_ARTIFACT_VARIATION)
            .append('/')
            .append(ccdModule)
            .append('/')
            .append(ccdOutput)
            .append('/')
            .append(row)
            .append(PixelFsIdFactory.SEP)
            .append(testPulseDurationLc);

        return new FsId(fullPath.toString());
    }
    
    
    public static final class ParsedRollingBandId {
        public final int duration;
        public final int row;
        public final int ccdModule;
        public final int ccdOutput;
        public ParsedRollingBandId(Matcher matcher) {
            this.duration = Integer.parseInt(matcher.group(4));
            this.row = Integer.parseInt(matcher.group(3));
            this.ccdModule = Integer.parseInt(matcher.group(1));
            this.ccdOutput = Integer.parseInt(matcher.group(2));
        }  
    }
    
    /**
     * 
     * @param rollingBandId
     * @return return duration, row, ccdModule, ccdOutput.  Returns null
     *  if rollingBandId is not a valid rolling band id.
     */
    public static ParsedRollingBandId getRollingBandDuration(FsId rollingBandId) {
        
        String stringifiedId = rollingBandId.toString();
        Matcher matcher = rollingBandFlagPattern.matcher(stringifiedId);
        if (!matcher.find()) {
            return null;
        }
        
        return new ParsedRollingBandId(matcher);
    }
    

}
