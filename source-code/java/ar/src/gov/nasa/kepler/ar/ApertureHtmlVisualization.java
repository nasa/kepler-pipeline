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
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import nom.tam.fits.Fits;
import nom.tam.fits.ImageData;
import nom.tam.fits.ImageHDU;

/**
 * @author Sean McCauliff
 *
 */
public class ApertureHtmlVisualization {

    private static final class PixelValue {
        
        private final Color color;
        private final String description;
        private final String htmlValue;
        
        private PixelValue(Color color, String description) {
            this.color = color;
            this.description = description;
            this.htmlValue = String.format("<td bgcolor=\"#%06x\">&nbsp;</td>", color.getRGB() & 0xffffff);
        }
        
        public Color color() {
            return color;
        }
        
        public String description() {
            return description;
        }
        
        public String htmlValue() {
            return htmlValue;
        }
    }
  
    private static final PixelValue[] flagCombinations = 
        new PixelValue[] {
        new PixelValue(Color.black,   "0000 not collected"),
        new PixelValue(Color.gray,    "0001 collected"),
        new PixelValue(Color.red,     "0010 invalid"),
        new PixelValue(Color.cyan,    "0011 in optimal aperture"),
        new PixelValue(Color.red,     "0100 invalid"),
        new PixelValue(Color.magenta, "0101 collected + used for flux centroid"),
        new PixelValue(Color.red,     "0110 invalid"),
        new PixelValue(Color.green,   "0111 collected + flux + optimal"),
        new PixelValue(Color.red,     "1000 invalid"),
        new PixelValue(Color.blue,    "1001 collected + prf"),
        new PixelValue(Color.red,     "1010 invalid"),
        new PixelValue(Color.yellow,  "1011 collected + prf + optimal"),
        new PixelValue(Color.red,     "1100 invalid"),
        new PixelValue(Color.orange,  "1101 collected + prf + flux"),
        new PixelValue(Color.red,     "1110 invalid"),
        new PixelValue(Color.white,   "1111 collected + optimal + flux + prf")
    };

    /**
     * @param args
     */
    public static void main(String[] args) throws Exception {

        File inputFile = new File(args[0]);
        
        String fname = inputFile.getName();
        String fnamePrefix = inputFile.getName().substring(0, fname.length() - 5);
        File outputFile = new File(inputFile.getParentFile(), fnamePrefix + "-aperture.html");
        
        Fits fits = new Fits(inputFile);
        ImageHDU apertureImage = (ImageHDU) fits.getHDU(2);
        ImageData imageData = (ImageData) apertureImage.getData();
        int[][] imageArray = (int[][]) imageData.getData();
        
        BufferedWriter htmlOut= new BufferedWriter(new FileWriter(outputFile));
        
        writeHeader(htmlOut, fnamePrefix);
        legend(htmlOut);
        image(htmlOut, imageArray);
        writeFooter(htmlOut);
        htmlOut.flush();
        htmlOut.close();
    }
    
    private static void writeFooter(Appendable out) throws IOException {
        out.append("</body>\n</html>\n");
    }
    
    private static void image(Appendable out, int[][] imageArray) throws IOException {
        int width = imageArray[0].length;
        int height = imageArray.length;
        
        indent(1,out).append("<table>\n");
        
        //Pixel column coordinates
        indent(2,out).append("<tr>\n");
        indent(3,out).append("<td>&nbsp;</td>");
        for (int i=0; i < width; i++) {
            //and convert to ones based indexing
            out.append("<td>").append(Integer.toString(i + 1)).append("</td>");
        }
        out.append("\n");
        indent(2,out).append("</tr>\n");
        
        //image, FITS image is flipped vertically compared with normal computer
        //graphics orientation
        for (int rowi=height-1; rowi >= 0; rowi--) {
            indent(2,out).append("<tr>\n");
            //row number
            indent(3,out).append("<td>").append(Integer.toString(rowi + 1)).append("</td> ");
            for (int coli=0; coli < width; coli++) {
                int flagValue = imageArray[rowi][coli];
                PixelValue pixelValue = flagCombinations[flagValue];
                out.append(pixelValue.htmlValue()).append(" ");
            }
            indent(2,out).append("</tr>\n");
        }
        
        indent(1, out).append("</table>\n");
    }
    
    private static void legend(Appendable out) throws IOException {
        indent(1,out).append("<table>\n");
        indent(2,out).append("<tr>\n");
        indent(3,out).append("<th>Pixel Value</th> <th>Color</th>\n");
        indent(2,out).append("</tr>\n");
        
        for (int i=0; i < flagCombinations.length; i++) {
            //TODO:  fix this hack
            if (flagCombinations[i].description().contains("invalid")) {
                continue;
            }
            indent(2,out).append("<tr>\n");
            indent(3,out).append("<td>").append(flagCombinations[i].description())
                         .append("</td> ")
                         .append(flagCombinations[i].htmlValue())
                         .append("\n");
            indent(2,out).append("</tr>\n");
        }
        indent(1,out).append("</table>\n");
    }
    
    private static void writeHeader(Appendable out, String fnamePrefix) throws IOException {
        out.append("<html>\n").append("<head>\n");
        indent(1, out);
        out.append("<title>").append("Aperture Mask Image: ").append(fnamePrefix).append("</title>\n");
        out.append("</head>\n");
        out.append("<body>\n");
    }
    
    private static Appendable indent(int level, Appendable out) throws IOException {
        for (int i=0; i < level * 2; i++) {
            out.append(" ");
        }
        return out;
    }
    

}
