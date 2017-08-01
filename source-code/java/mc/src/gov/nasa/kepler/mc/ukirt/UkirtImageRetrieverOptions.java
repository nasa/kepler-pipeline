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

package gov.nasa.kepler.mc.ukirt;

import java.io.File;
import java.util.Collection;
import java.util.HashSet;

import org.apache.commons.lang.ArrayUtils;

public class UkirtImageRetrieverOptions {

    public static final String DEFAULT_WORKING_DIRECTORY = "/tmp";
    public static final String DEFAULT_DS9_COMMAND_LINE_ARGS = " -align -zoom to fit"
        + " -grid"
        + " -cmap heat"
        + " -scale mode 99"
        + " -grid type publication" 
        + " -grid numerics fontsize 14"
        + " -grid labels fontsize 14"
        + " -view colorbar no";
    public static final String DEFAULT_DS9_EXECUTABLE = "ds9";
    public static final String DEFAULT_OUTPUT_DIRECTORY = "png";
    public static final float DEFAULT_IMAGE_SIZE_ARCMIN = 1.0F;

    private boolean customTargetProcessingEnabled;
    private String ds9Executable = DEFAULT_DS9_EXECUTABLE;
    private String ds9CommandLineArgs = DEFAULT_DS9_COMMAND_LINE_ARGS;
    private int endKeplerId = Integer.MAX_VALUE;
    private float imageSize = DEFAULT_IMAGE_SIZE_ARCMIN;
    private File keplerIdList = null;
    private String outputDir = DEFAULT_OUTPUT_DIRECTORY;
    private Collection<Integer> skyGroupIds = new HashSet<Integer>();
    private int startKeplerId = 0;
    private String[] targetListNames = ArrayUtils.EMPTY_STRING_ARRAY;
    private File workingDir = new File(DEFAULT_WORKING_DIRECTORY);

    public boolean isCustomTargetProcessingEnabled() {
        return customTargetProcessingEnabled;
    }

    public void setCustomTargetProcessingEnabled(
        boolean customTargetProcessingEnabled) {
        this.customTargetProcessingEnabled = customTargetProcessingEnabled;
    }

    public String getDs9CommandLineArgs() {
        return ds9CommandLineArgs;
    }

    public void setDs9CommandLineArgs(String ds9CommandLineArgs) {
        this.ds9CommandLineArgs = ds9CommandLineArgs;
    }

    public String getDs9Executable() {
        return ds9Executable;
    }

    public void setDs9Executable(String ds9Executable) {
        this.ds9Executable = ds9Executable;
    }

    public int getEndKeplerId() {
        return endKeplerId;
    }

    public void setEndKeplerId(int endKeplerId) {
        this.endKeplerId = endKeplerId;
    }

    public float getImageSize() {
        return imageSize;
    }

    public void setImageSize(float imageSize) {
        this.imageSize = imageSize;
    }

    public File getKeplerIdList() {
        return keplerIdList;
    }

    public void setKeplerIdList(File keplerIdList) {
        this.keplerIdList = keplerIdList;
    }

    public String getOutputDir() {
        return outputDir;
    }

    public void setOutputDir(String outputDir) {
        if (outputDir != null && outputDir.length() > 0) {
            this.outputDir = outputDir;
        }
    }

    public Collection<Integer> getSkyGroupIds() {
        return skyGroupIds;
    }

    public void setSkyGroupIds(Collection<Integer> skyGroupIds) {
        this.skyGroupIds = skyGroupIds;
    }

    public int getStartKeplerId() {
        return startKeplerId;
    }

    public void setStartKeplerId(int startKeplerId) {
        this.startKeplerId = startKeplerId;
    }

    public String[] getTargetListNames() {
        return targetListNames;
    }

    public void setTargetListNames(String[] targetListNames) {
        this.targetListNames = targetListNames;
    }

    public File getWorkingDir() {
        if (workingDir == null) {
            workingDir = new File(DEFAULT_WORKING_DIRECTORY);
        }
        return workingDir;
    }

    public void setWorkingDir(File workingDir) {
        this.workingDir = workingDir;
    }
}
