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

package gov.nasa.kepler.cal.ffi;

import static gov.nasa.kepler.common.FitsConstants.MODULE_KW;
import static gov.nasa.kepler.common.FitsConstants.OUTPUT_KW;
import gov.nasa.kepler.common.FcConstants;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.FileOutputStream;

import nom.tam.fits.*;
import nom.tam.util.BufferedDataOutputStream;

/**
 * Add a watermark to every FI frame.
 * 
 * @author Sean McCauliff
 *
 */
public class FfiWatermark {

    public static void main(String[] argv) throws Exception {

        Fits ffiFits = new Fits(argv[0]);

        FileOutputStream fout = new FileOutputStream(argv[1]);
        BufferedDataOutputStream bufOut = new BufferedDataOutputStream(fout);

        BasicHDU initialHdu = ffiFits.readHDU();
        initialHdu.write(bufOut);

        for (int module : FcConstants.modulesList) {
            for (int output : FcConstants.outputsList) {
                ImageHDU imageHdu = (ImageHDU) ffiFits.readHDU();

                int actualModule = imageHdu.getHeader().getIntValue(MODULE_KW);
                int actualOutput = imageHdu.getHeader().getIntValue(OUTPUT_KW);
                if (actualModule != module || actualOutput != output) {
                    throw new IllegalStateException("Expected mod/out " + 
                        module + " " + output + " but found mod/out " + 
                        actualModule + " " + actualOutput + ".");
                }

                watermarkImageHdu(imageHdu, bufOut);
            }
        }

        bufOut.flush();
        fout.close();
    }

    private static void watermarkImageHdu(ImageHDU imageHdu,
        BufferedDataOutputStream bufOut) throws Exception {

        Data fitsData = imageHdu.getData();
        final int[][] fitsDataArray = (int[][]) fitsData.getData();
        final int height = fitsDataArray.length;
        final int width = fitsDataArray[0].length;
        int module = imageHdu.getHeader().getIntValue(MODULE_KW);
        int output = imageHdu.getHeader().getIntValue(OUTPUT_KW);
        
        final BufferedImage watermarkImage = 
            new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        Graphics2D g2d  = watermarkImage.createGraphics();
        g2d.translate(100, 300);
        g2d.scale(3.0, 3.0);
        Font font =  g2d.getFont();
        System.out.println("font " + font);
        g2d.setColor(Color.WHITE);
        g2d.drawRect(100, 100, 100, 100);
        g2d.drawString(module + "/" + output, 10, 10);
        g2d.dispose();
        
        final int MAX_PIXEL_VALUE = (1 << 20) - 1;
        for (int y=0; y < height; y++) {
            for (int x=0; x < width; x++) {
                int value = watermarkImage.getRGB(x, y);
                value += fitsDataArray[y][x];
                if (value > MAX_PIXEL_VALUE || value < 0) {
                    value = MAX_PIXEL_VALUE;
                }
                fitsDataArray[y][x] = value;
            }
        }
       
        
        Data outputData = new ImageData(fitsDataArray);
        ImageHDU outputHdu = new ImageHDU(imageHdu.getHeader(), outputData);
        outputHdu.write(bufOut);
    }


}
