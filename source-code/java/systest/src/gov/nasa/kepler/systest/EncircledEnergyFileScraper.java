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

package gov.nasa.kepler.systest;

import gov.nasa.spiffy.common.io.FileUtil;

import java.io.File;

import org.apache.commons.io.FileUtils;

/**
 * This class retrieves the final outputs.mat file from all of the pa
 * matFileDirs on a worker. The final pa outputs.mat file is the one that has
 * the encircled energy metrics.
 * 
 * @author Miles Cote
 * 
 */
public class EncircledEnergyFileScraper {

    private void scrape(File srcDir, File destDir) throws Exception {
        if (!srcDir.exists()) {
            throw new IllegalArgumentException(
                "The srcDir must exist.  srcDir: " + srcDir);
        }

        FileUtils.forceMkdir(destDir);

        for (File taskDir : srcDir.listFiles()) {
            if (taskDir.getName()
                .contains("pa")) {
                File taskOutputDir = new File(destDir, taskDir.getName());
                FileUtil.cleanDir(taskOutputDir);

                File latestOutputsDotMatFile = null;
                for (File matFile : taskDir.listFiles()) {
                    if (matFile.getName()
                        .startsWith("pa-outputs") && matFile.getName()
                        .endsWith(".mat")) {
                        if (latestOutputsDotMatFile == null
                            || matFile.lastModified() > latestOutputsDotMatFile.lastModified()) {
                            latestOutputsDotMatFile = matFile;
                        }
                    }
                }

                FileUtils.copyFileToDirectory(latestOutputsDotMatFile,
                    taskOutputDir);
            }
        }
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            throw new IllegalArgumentException(
                "Two arguments must be passed: dirContainingAllMatFileDirs and destDir");
        }

        File srcDir = new File(args[0]);
        File destDir = new File(args[1]);

        EncircledEnergyFileScraper scraper = new EncircledEnergyFileScraper();
        scraper.scrape(srcDir, destDir);
    }

}
