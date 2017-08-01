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

package gov.nasa.kepler.tad.xml;

import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.io.File;
import java.io.FilenameFilter;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * Contains operations for tad xml files.
 * 
 * @author Miles Cote
 * 
 */
public class TadXmlFileOperations {

    public File getFile(final File srcDir, final String pattern,
        TargetListSet tls) {
        if (!srcDir.exists()) {
            throw new IllegalArgumentException(
                "The srcDir must exist.\n  srcDir: " + srcDir);
        }

        String[] fileArray = srcDir.list(new FilenameFilter() {
            @Override
            public boolean accept(File dir, String name) {
                return name.contains(pattern);
            }
        });
        List<String> files = Collections.emptyList();
        if (fileArray != null) {
            files = Arrays.asList(fileArray);
        }

        Collections.sort(files);

        String fileName = files.get(0);
        if (tls != null) {
            if (!tls.getType()
                .equals(TargetType.SHORT_CADENCE)) {
                if (files.size() != 1) {
                    throw new IllegalArgumentException(
                        "srcDir must have exactly one file that contains the pattern.\n  srcDir: "
                            + srcDir + "\n  pattern: " + pattern
                            + "\n  fileMatches: " + files);
                }

                fileName = files.get(0);
            } else {
                String tlsName = tls.getName();
                if (tlsName.contains("sc1") || files.size() == 1) {
                    // If there's only one sc file, then use that one.
                    fileName = files.get(0);
                } else if (tlsName.contains("sc2")) {
                    fileName = files.get(1);
                } else if (tlsName.contains("sc3")) {
                    fileName = files.get(2);
                } else {
                    throw new IllegalArgumentException(
                        "The short cadence tls name must contain either the string sc1, sc2, or sc3.\n  tlsName: "
                            + tlsName);
                }
            }
        }

        return new File(srcDir, fileName);
    }

}
