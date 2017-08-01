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

import gov.nasa.kepler.cal.io.Cal2DCollateral;
import gov.nasa.kepler.cal.io.Cal2DCollateralRegion;
import gov.nasa.kepler.cal.io.CalInputPixelTimeSeries;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.mc.FitsImage;
import static gov.nasa.kepler.common.ConfigMap.ConfigMapMnemonic.*;

import java.util.ArrayList;
import java.util.List;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.Header;

/**The image of the single mod out and the important metadata.
 * 
 * @author Sean McCauliff
 *
 */
public class FfiModOut {
    
    private static final boolean[] GAP = new boolean[] { true };
    private static final boolean[] NO_GAP = new boolean[] { false };
    
    public final int[][] image;
    public final boolean[][] gaps;
    public final double startMjd;
    public final double midMjd;
    public final double endMjd;
    public final long originator;
    public final int longCadenceNumber;
    public final BasicHDU primaryHdu;
    public final Header imageHeader;
    public final int spaceCraftConfigMapId;
    public final int ccdModule;
    public final int ccdOutput;
    public final String fileName;
    
    /**
     * @param image
     * @param gap
     * @param collectionMjd
     */
    public FfiModOut(int[][] image, boolean[][] gaps, double startMjd, 
            double midMjd, double endMjd, long originator, 
            BasicHDU primaryHDU, Header imageHeader,int longCadenceNumber,
            int spaceCraftConfigMapId, int ccdModule, int ccdOutput,
            String fileName) {
        
        if (startMjd > midMjd) {
            throw new IllegalArgumentException("Start mjd comes after mid mjd.");
        }
        if (midMjd > endMjd) {
            throw new IllegalArgumentException("Mid mjd comes aftger end mjd.");
        }
        
        if (image.length == 0) {
            throw new IllegalArgumentException("Image must not be the empty array.");
        }
        
        this.image = image;
        this.gaps = gaps;
        this.startMjd = startMjd;
        this.originator = originator;
        this.midMjd = midMjd;
        this.endMjd = endMjd;
        this.primaryHdu = primaryHDU;
        this.imageHeader = imageHeader;
        this.longCadenceNumber = longCadenceNumber;
        this.spaceCraftConfigMapId = spaceCraftConfigMapId;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.fileName = fileName;
       
    }
    
    public Cal2DCollateral collateral(ConfigMap configMap) throws Exception  {
        int[][] smear = 
            extractSubImage(configMap.getInt(smearStartRow),
                            configMap.getInt(smearEndRow),
                            configMap.getInt(smearStartCol),
                            configMap.getInt(smearEndCol));
        
        boolean[][] smearGaps = 
            extractSubGaps(configMap.getInt(smearStartRow),
                            configMap.getInt(smearEndRow),
                            configMap.getInt(smearStartCol),
                            configMap.getInt(smearEndCol));
        
        int[][] maskedSmear = 
            extractSubImage(configMap.getInt(maskedStartRow),
                            configMap.getInt(maskedEndRow),
                            configMap.getInt(maskedStartCol),
                            configMap.getInt(maskedEndCol));
        
        boolean[][] maskedSmearGaps =
            extractSubGaps(configMap.getInt(maskedStartRow),
                configMap.getInt(maskedEndRow),
                configMap.getInt(maskedStartCol),
                configMap.getInt(maskedEndCol));
        
        int[][] black = 
            extractSubImage(configMap.getInt(darkStartRow),
                            configMap.getInt(darkEndRow),
                            configMap.getInt(darkStartCol),
                            configMap.getInt(darkEndCol));
        boolean[][] blackGaps =
            extractSubGaps(configMap.getInt(darkStartRow),
                configMap.getInt(darkEndRow),
                configMap.getInt(darkStartCol),
                configMap.getInt(darkEndCol));
        
        return new Cal2DCollateral(new Cal2DCollateralRegion(black, blackGaps),
                                   new Cal2DCollateralRegion(smear, smearGaps),
                                   new Cal2DCollateralRegion(maskedSmear, maskedSmearGaps));
    }
    
    public List<CalInputPixelTimeSeries> allPixels() {
        List<CalInputPixelTimeSeries> list = 
            new ArrayList<CalInputPixelTimeSeries>(image.length * image[0].length);
        
        for (int i=0; i < image.length; i++) {
            if (image[0].length != image[i].length) {
                throw new IllegalStateException("Row sizes must match.");
            }
            for (int j=0; j < image[0].length; j++) {
                boolean[] gapIndicators = (gaps[i][j]) ? GAP : NO_GAP;
                CalInputPixelTimeSeries timeSeries = 
                    new CalInputPixelTimeSeries(i, j, new int[] { image[i][j] }, 
                        gapIndicators);
                list.add(timeSeries);
            }
        }
        return list;
    }

    private int[][] extractSubImage(int startRow, int endRow, int startCol, int endCol) {
        int[][] subImage = new int[endRow - startRow +1][endCol - startCol + 1];
        for (int si=0, i=startRow; i <= endRow; si++, i++) {
            for (int sj=0, j=startCol; j <= endCol; sj++, j++) {
                subImage[si][sj] = image[i][j];
            }
        }
        
        return subImage;
    }
    
    private boolean[][] extractSubGaps(int startRow, int endRow, int startCol, int endCol) {
        boolean[][] subGaps = new boolean[endRow - startRow +1][endCol - startCol + 1];
        for (int si=0, i=startRow; i <= endRow; si++, i++) {
            for (int sj=0, j=startCol; j <= endCol; sj++, j++) {
                subGaps[si][sj] = gaps[i][j];
            }
        }
        
        return subGaps;
    }
    
    /**
     * Number of columns.
     * @return a positive integer
     */
    public int width() {
        return image[0].length;
    }
    
    /**
     * Number of rows.
     * @return a positive integer
     */
    public int height() {
        return image.length;
    }
    
    /**
     * 
     * @return a non-null value.
     */
    public FitsImage toFitsImage() {
        int[] rows = new int[image.length];
        for (int i=0; i < rows.length; i++) {
            rows[i] = i;
        }
        return new FitsImage(fileName, startMjd, midMjd, endMjd, rows, image);
    }
    
    /**
     * Extract specified sub image.
     * @param rows  One or more row indices.  Duplicates permitted.
     * @return a non-null value.
     */
    public FitsImage toFitsImage(int[] rows) {
        
        int[][] subImage = new int[rows.length][];
        int subImageIndex = 0;
        for (int rowIndex : rows) {
            subImage[subImageIndex++] = image[rowIndex];
        }
        return new FitsImage(fileName, startMjd, midMjd, endMjd, rows, subImage);
    }
    
}
