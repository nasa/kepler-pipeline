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

import gov.nasa.kepler.systest.EtemScienceInjectedKeplerId.EtemScienceInjectionType;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.jmatio.io.MatFileReader;
import com.jmatio.types.MLArray;
import com.jmatio.types.MLChar;
import com.jmatio.types.MLDouble;
import com.jmatio.types.MLStructure;

/**
 * This class reads a scienceTargetList.mat file and returns
 * {@link EtemScienceInjectedKeplerId}s.
 * 
 * @author Miles Cote
 * 
 */
public class EtemScienceTargetListReader {

    public static final String SCIENCE_TARGET_LIST_MAT_FILE_NAME = "scienceTargetList.mat";

    public List<EtemScienceInjectedKeplerId> read(File scienceTargetListMatFile)
        throws IOException {
        List<EtemScienceInjectedKeplerId> injectedKeplerIds = new ArrayList<EtemScienceInjectedKeplerId>();

        MatFileReader reader = new MatFileReader(scienceTargetListMatFile);
        MLStructure targetList = (MLStructure) reader.getMLArray("targetList");
        for (int i = 0; i < targetList.getSize(); i++) {
            double[][] keplerIds = ((MLDouble) targetList.getField("keplerId",
                i)).getArray();
            int keplerId = (int) keplerIds[0][0];

            MLStructure lightCurveList = (MLStructure) targetList.getField(
                "lightCurveList", i);
            for (int j = 0; j < lightCurveList.getSize(); j++) {
                MLChar description = (MLChar) lightCurveList.getField(
                    "description", j);
                String stringDescription = description.contentToString()
                    .split("'")[1];
                EtemScienceInjectionType type = EtemScienceInjectionType.valueOfEtemStringId(stringDescription);

                if (!type.equals(EtemScienceInjectionType.SOHO_BASED_STELLAR_VARIABILITY)) {
                    MLArray lightCurveData = lightCurveList.getField(
                        "lightCurveData", j);

                    if (lightCurveData instanceof MLStructure) {
                        injectedKeplerIds.add(new EtemScienceInjectedKeplerId(
                            keplerId, type));
                    }
                }
            }
        }

        return injectedKeplerIds;
    }

    public static void main(String[] args) throws Exception {
        EtemScienceTargetListReader reader = new EtemScienceTargetListReader();
        List<EtemScienceInjectedKeplerId> injectedKeplerIds = reader.read(new File(
            "/path/to/dist/tmp/output/p1/long/run_long_m6o3s1/"
                + SCIENCE_TARGET_LIST_MAT_FILE_NAME));

        System.out.println(injectedKeplerIds);
        
        int ebCount = 0;
        int earthCount = 0;
        int jupiterCount = 0;
        for (EtemScienceInjectedKeplerId injectedKeplerId : injectedKeplerIds) {
            switch (injectedKeplerId.getEtemScienceInjectionType()) {
                case ECLIPSING_BINARY_STAR:
                    ebCount++;
                    break;
                case TRANSITING_EARTH:
                    earthCount++;
                    break;
                case TRANSITING_JUPITER:
                    jupiterCount++;
                    break;

                default:
                    throw new PipelineException("Unknown type");
            }
        }
        
        System.out.println("eclipsing binary count: " + ebCount);
        System.out.println("transiting earth count: " + earthCount);
        System.out.println("transiting jupiter count: " + jupiterCount);
    }

}
