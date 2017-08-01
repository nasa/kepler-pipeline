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

package gov.nasa.kepler.ar.cli;

/**
 * This is a tool to generate individual PNG files for every flux image 
 * contained in a target pixel file.  These can then be stiched togehter into a
 * video file with ffmpeg:
 * <pre>
 * ffmpeg -f image2 -r 24 -i ./kplr007198959-2009259160929_lpd-targ.fits.frame-r-%04d.png -b 600k ./rrlyrae-q2.mp4
 * </pre>
 * 
 * 
 * @author Sean McCauliff
 *
 */


import static gov.nasa.kepler.common.FitsConstants.*;

import gnu.trove.TIntHashSet;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.Iterator;

import javax.imageio.ImageIO;

import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;

import nom.tam.fits.Header;
import nom.tam.fits.ImageData;
import nom.tam.util.BufferedFile;


public class TargetPixelFrameGenerator {

    private static final long FITS_BLOCK_SIZE = 2880;
    
    public static void main(String[] argv) throws Exception {
        String fname = argv[0];
        System.out.println(fname);
        BufferedFile bfile = new BufferedFile(fname);
        Header primaryHeader = Header.readHeader(bfile);
        Header binaryTableHeader = Header.readHeader(bfile);
        long startOfBinaryTableData = bfile.getFilePointer();
        long binaryTableRowSizeBytes = binaryTableHeader.getIntValue(NAXIS1_KW);
        int nTableRows = binaryTableHeader.getIntValue(NAXIS2_KW);
        long skipBytes = nTableRows * binaryTableRowSizeBytes;
        if (skipBytes % FITS_BLOCK_SIZE != 0) {
            skipBytes += FITS_BLOCK_SIZE - (skipBytes % FITS_BLOCK_SIZE);
        }
        bfile.skipBytes(skipBytes);
        Header apertureImageHeader = Header.readHeader(bfile);
        ImageData apertureImageData = (ImageData) apertureImageHeader.makeData();
        apertureImageData.read(bfile);
        //TODO:  nom.tam.fits is transposing rows and columns here.  Thanks.
        int[][] apertureMaskImageArray = (int[][]) apertureImageData.getData();
        int amRows = apertureMaskImageArray[0].length;
        int amCols = apertureMaskImageArray.length;
        BufferedImage apertureMaskBufferedImage = 
            new BufferedImage(amCols, amRows, BufferedImage.TYPE_INT_RGB);
        for (int rowi=0; rowi < amRows; rowi++) {
            for (int coli=0; coli < amCols; coli++) {
                int rgbValue = -1;
                switch (apertureMaskImageArray[coli][rowi]) {
                    case 0: rgbValue = 0; break;
                    case 1: rgbValue = Color.darkGray.getRGB(); break;
                    case 2: rgbValue = Color.red.getRGB(); break;
                    case 3: rgbValue = Color.white.getRGB(); break;
                    default:
                        rgbValue = Color.white.getRGB();
                        System.err.println("Unhandled aperture mask image pixel flags.");
                }
                //image origin is in the upper left corner, rather than the
                //lower right corner
                apertureMaskBufferedImage.setRGB(amCols - coli - 1, rowi, rgbValue);
            }
        }
        ImageIO.write(apertureMaskBufferedImage, "PNG", new File(argv[0] + ".ap.png"));
        
        //Transpose rows and cols here because I read them in correctly
        //unlike nom.tam.fits
        TargetImageIterator it = new TargetImageIterator(fname, startOfBinaryTableData,
                binaryTableRowSizeBytes, nTableRows, amCols, amRows);
      
        VideoStatistics videoStats = generateVideoStatistics(it);
        
        double gamma = findGammaTransferParameter(videoStats);
        double logMax = videoStats.logMaxPixelValue;
        
        System.out.println("Best gamma: " + gamma + " max pixel variance" + videoStats.maxInterPixelVariance);
        
        it = new TargetImageIterator(fname, startOfBinaryTableData,
                binaryTableRowSizeBytes, nTableRows, amCols, amRows);
        
        //Transpose rows and cols here because I read them in correctly
        //unlike nom.tam.fits
        int rows = amCols;
        int cols = amRows;
        while (it.hasNext()) {
            int framei = it.framei();
            float[] singleImage = it.next();
            
             BufferedImage bufferedTargetImage = 
                 new BufferedImage(cols, rows, BufferedImage.TYPE_INT_RGB);

            for (int i=0; i < singleImage.length; i++) {
                if (Float.isNaN(singleImage[i]) ) {
                    singleImage[i] = 0;
                }
                if (singleImage[i] < 0) {
                    singleImage[i] = 0;
                }
                int rgbValue = processedPixelValue(singleImage[i], logMax, gamma);
                int row = rows - (i / cols) - 1;
                int col = i % cols;
                bufferedTargetImage.setRGB(col, row, rgbValue);
            }
            
            
            BufferedImage scaledImage = 
                new BufferedImage(bufferedTargetImage.getWidth() * 8, 
                    bufferedTargetImage.getHeight() * 8, bufferedTargetImage.getType());
            Graphics2D g = scaledImage.createGraphics();
            g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_OFF);
            g.drawImage(bufferedTargetImage, 0, 0, scaledImage.getWidth(), scaledImage.getHeight(), null);
            g.dispose();
            String fnameIndex = String.format("%04d", framei);
            ImageIO.write(scaledImage, "PNG", new File(fname + ".frame-" +fnameIndex + ".png"));
        }
    }
    
    /**
     * @return the RGB value.
     */
    private static int processedPixelValue(float originalPixelValue, double logMax, double gamma) {
        if (originalPixelValue == 0) {
            return 0;
        }
        double scaledValue = Math.pow(Math.log(originalPixelValue) / logMax, 1/gamma) * 255.0;
        int colorValue = Math.max(0, Math.min(255, (int) scaledValue));
        int rgbValue = (colorValue << 8) | (colorValue << 16) | colorValue;
        //int rgbValue = colorValue << 16;
        return rgbValue;
    }
    
    private static double findGammaTransferParameter(VideoStatistics videoStats) {
        double bestGamma = -1;
        int maxUniquePixelValues = -1;
        
        for (double gamma = 1.0; gamma <= 3.0; gamma += .1) {
            TIntHashSet uniqueRgbPixelValues = new TIntHashSet(1024);
            for (float pixelValue : videoStats.maxInterPixelVarianceFrame) {
                if (pixelValue < 0 || Float.isNaN(pixelValue) || Float.isInfinite(pixelValue)) {
                    continue;
                }
                int rgbValue = processedPixelValue(pixelValue, videoStats.logMaxPixelValue, gamma);
                uniqueRgbPixelValues.add(rgbValue);
            }
            if (uniqueRgbPixelValues.size() > maxUniquePixelValues) {
                maxUniquePixelValues = uniqueRgbPixelValues.size();
                bestGamma = gamma;
            }
        }
        System.out.println("Best number of unique pixel values "+ maxUniquePixelValues);
        return bestGamma;
    }
    
    private static VideoStatistics generateVideoStatistics(TargetImageIterator it) {
        float maxPixelValue = -Float.MAX_VALUE;
        double maxInterPixelVariance = -Double.MAX_VALUE;
        float[] frameWithMaxInterPixelVariance = null;
        
        while (it.hasNext()) {
            DescriptiveStatistics perFramePixelStatistics = new DescriptiveStatistics();
            
            float[] singleImage = it.next();
            for (int i=0; i < singleImage.length; i++) {
                float pixelValue = singleImage[i];
                if (Float.isNaN(pixelValue) || Float.isInfinite(pixelValue)) {
                    continue;
                }

                if (maxPixelValue < pixelValue) {
                    maxPixelValue = pixelValue;
                }
                
                if (pixelValue >= 0) {
                    perFramePixelStatistics.addValue(pixelValue);
                }
            }
            
            if (perFramePixelStatistics.getVariance() > maxInterPixelVariance) {
                frameWithMaxInterPixelVariance = singleImage;
                maxInterPixelVariance = perFramePixelStatistics.getVariance();
            }
        }
        
        
        double logMax = Math.log(maxPixelValue);
        return new VideoStatistics(logMax, maxInterPixelVariance, frameWithMaxInterPixelVariance);
    }
    
    private static final class VideoStatistics {
        public final double logMaxPixelValue;
        public final double maxInterPixelVariance;
        public final float[] maxInterPixelVarianceFrame;
        private VideoStatistics(double logMaxPixelValue,
            double maxInterPixelVariance, float[] frameWithMaxInterPixelVariance) {
            super();
            this.logMaxPixelValue = logMaxPixelValue;
            this.maxInterPixelVariance = maxInterPixelVariance;
            this.maxInterPixelVarianceFrame = frameWithMaxInterPixelVariance;
        }
        
    }

    private static final class TargetImageIterator implements Iterator<float[]> {
        private final BufferedFile bfile;
        private final long startOfBinaryTableData;
        private final long binaryTableRowSizeBytes;
        private int framei = 0 ;
        private final int endFrame;
        private final int rows;
        private final int cols;
        private final int imageSizeBytes;
        
        private TargetImageIterator(String fname,
                long startOfBinaryTableData,
                long binaryTableRowSizeBytes,
                int endFrame, int rows, int cols) throws IOException {
            super();
            this.bfile = new BufferedFile(fname);
            this.startOfBinaryTableData = startOfBinaryTableData;
            this.endFrame = endFrame;
            this.rows = rows;
            this.cols = cols;
            this.imageSizeBytes = rows * cols * 4; /* size of float */
            this.binaryTableRowSizeBytes = binaryTableRowSizeBytes;
        }

        @Override
        public boolean hasNext() {
            return framei < endFrame;
        }
        @Override
        public float[] next() {
            try {
                bfile.seek(startOfBinaryTableData + binaryTableRowSizeBytes * framei);
                //skip past the time stamp, cadence number and the first image
                //which is the raw pixel image and go right for the flux image.
                bfile.skipBytes(8 + 4 +  imageSizeBytes);
                
                float[] singleImage = new float[rows * cols];
                bfile.read(singleImage);
                framei++;
                if (!hasNext()) {
                    bfile.close();
                }
                return singleImage;
            } catch (IOException ioe) {
                try {
                    bfile.close();
                } catch (IOException ignored) {
                    //ignored.
                }
                throw new IllegalStateException(ioe);
            }
        }
        
        @Override
        public void remove() {
            throw new UnsupportedOperationException();
        }
        
        public int framei() {
            return framei;
        }
    }
}
