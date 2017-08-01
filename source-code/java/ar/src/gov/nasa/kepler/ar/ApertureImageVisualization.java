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

package gov.nasa.kepler.ar;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.awt.image.RenderedImage;
import java.io.File;

import javax.imageio.ImageIO;

import nom.tam.fits.Fits;
import nom.tam.fits.ImageData;
import nom.tam.fits.ImageHDU;

/**
 * Generates a colored image from a FITS file containing an aperture mask image.
 * @author Sean McCauliff
 *
 */
public class ApertureImageVisualization {

    private static final Color[] visualizationColors = new Color[] {
        Color.black,    //  0000 not collected
        Color.gray, //  0001 collected
        Color.red,      //  0010 invalid
        Color.cyan,     //  0011 in optimal aperture
        Color.red,      //  0100 invalid
        Color.magenta,  //  0101 collected + used for flux centroid
        Color.red,      //  0110 invalid
        Color.green,    //  0111 collected + flux + optimal
        Color.red,      //  1000 invalid
        Color.blue,     //  1001 collected + prf
        Color.red,      //  1010 invalid
        Color.yellow,   //  1011 collected + prf + optimal
        Color.red,      //  1100 invalid
        Color.orange,   //  1101 collected + prf + flux
        Color.red,       //  1110 invalid
        Color.white     //  1111 collected + optimal + flux + prf
    };
    
    
    /**
     * 
     * @param args
     */
    public static void main(String[] args) throws Exception {
        File inputFile = new File(args[0]);
        
        String fname = inputFile.getName();
        String fnamePrefix = inputFile.getName().substring(0, fname.length() - 5);
        File outputFile = new File(inputFile.getParentFile(), fnamePrefix + ".png");
        
        Fits fits = new Fits(inputFile);
        ImageHDU apertureImage = (ImageHDU) fits.getHDU(2);
        ImageData imageData = (ImageData) apertureImage.getData();
        int[][] imageArray = (int[][]) imageData.getData();
        
        
        RenderedImage rendImage = convert(imageArray);

        // Write generated image to a file
        // Save as PNG
        ImageIO.write(rendImage, "png", outputFile);


    }
    // Returns a generated image.
    private static RenderedImage convert(int[][] srcImageArray) {
        int height = srcImageArray.length;
        int width = srcImageArray[0].length;
        
        BufferedImage smallImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);

        for (int rowi=0; rowi < height; rowi++) {
            for (int coli=0; coli < width; coli++) {
                int rgbColor = visualizationColors[srcImageArray[rowi][coli]].getRGB();
                smallImage.setRGB(coli, height - rowi - 1,  rgbColor);
            }
            
        }
        
        int largeWidth = width * 32;
        int largeHeight = height * 32;
        BufferedImage largeImage = new BufferedImage(largeWidth, largeHeight, BufferedImage.TYPE_INT_RGB);
        Graphics2D g2d = largeImage.createGraphics();
        g2d.setRenderingHint(RenderingHints.KEY_INTERPOLATION,
            RenderingHints.VALUE_INTERPOLATION_NEAREST_NEIGHBOR);

//        g2d.setRenderingHint(RenderingHints.KEY_RENDERING,
//        RenderingHints.VALUE_RENDER_QUALITY);

        g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
        RenderingHints.VALUE_ANTIALIAS_OFF);
        
        g2d.drawImage(smallImage, 0, 0, largeWidth, largeHeight, null);
        g2d.dispose();

        return largeImage;
    }
}
