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

package gov.nasa.kepler.mc.refpixels;

import static gov.nasa.kepler.mc.refpixels.RefPixelFileReader.GAP_INDICATOR_VALUE;

import java.io.File;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.xml.DOMConfigurator;

/**
 * Utility class that dumps the header and min/max pixel values from a reference
 * pixel file.
 * 
 * @author Todd Klaus
 * 
 */
public class RefPixelFileDump {
    private static final Log log = LogFactory.getLog(RefPixelFileDump.class);

    private String refPixelFilename;

    public RefPixelFileDump(String refPixelFilename) {
        this.refPixelFilename = refPixelFilename;
    }

    public void dump() throws Exception {
        RefPixelFileReader reader = new RefPixelFileReader(new File(
            refPixelFilename));

        log.info("timestamp = " + reader.getTimestamp());
        log.info("headerFlags = " + reader.getHeaderFlags());
        log.info("longCadenceTargetTableId = "
            + reader.getLongCadenceTargetTableId());
        log.info("shortCadenceTargetTableId = "
            + reader.getShortCadenceTargetTableId());
        log.info("backgroundTargetTableId = "
            + reader.getBackgroundTargetTableId());
        log.info("backgroundApertureTableId = "
            + reader.getBackgroundApertureTableId());
        log.info("scienceApertureTableId = "
            + reader.getScienceApertureTableId());
        log.info("referencePixelTargetTableId = "
            + reader.getReferencePixelTargetTableId());
        log.info("compressionTableId = " + reader.getCompressionTableId());
        log.info("numberOfReferencePixels = "
            + reader.getNumberOfReferencePixels());

        int numRefPixels = reader.getNumberOfReferencePixels();
        int gapCount = 0;
        int minPixelValue = Integer.MAX_VALUE;
        int maxPixelValue = Integer.MIN_VALUE;
        int pixelValueZeroCount = 0;

        for (int i = 0; i < numRefPixels; i++) {
            int pixel = reader.readNextPixel();

            if (pixel == GAP_INDICATOR_VALUE) {
                gapCount++;
            } else {
                if (pixel < minPixelValue) {
                    minPixelValue = pixel;
                }

                if (pixel > maxPixelValue) {
                    maxPixelValue = pixel;
                }

                if (pixel == 0) {
                    pixelValueZeroCount++;
                }
            }
        }

        log.info("gapCount = " + gapCount);
        log.info("minPixelValue = " + minPixelValue);
        log.info("maxPixelValue = " + maxPixelValue);
        log.info("pixelValueZeroCount = " + pixelValueZeroCount);

    }

    /**
     * @param args
     * @throws Exception
     */
    public static void main(String[] args) throws Exception {
        DOMConfigurator.configure("etc/log4j.xml");

        if (args.length < 1) {
            System.err.println("Usage: RefPixelFileDump filename");
            System.exit(1);
        }

        log.info("filename=" + args[0]);

        RefPixelFileDump refPixelFileDump = new RefPixelFileDump(args[0]);
        refPixelFileDump.dump();
    }

}
