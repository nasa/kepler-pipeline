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

package gov.nasa.kepler.ar.exporter;

import static gov.nasa.kepler.common.FitsConstants.*;
import gov.nasa.kepler.common.FcConstants;

import java.io.File;
import java.io.IOException;
import java.util.Date;

import nom.tam.fits.*;
import nom.tam.util.BufferedFile;

/**
 * 
 * @author Sean McCauliff
 *
 */
class CombinedFlatFieldFits {

    private static final String VALIDTIME = "VALIDTIM";
    
    private final Fits fits;
    
    CombinedFlatFieldFits(String fileName, double validMjd) throws FitsException {
        fits = new Fits();
        
        FitsFileCreationTimeFormat creationTime = new FitsFileCreationTimeFormat();
        String creationTimeStr = creationTime.format(new Date());
        
        Header header = new Header();
        header.setSimple(true);
        header.setBitpix(ImageHDU.BITPIX_FLOAT);
        header.setNaxes(0);
        header.addValue(EXTEND_KW, EXTEND_VALUE, EXTEND_COMMENT);
        header.addValue(NEXTEND_KW, 84, NEXTEND_COMMENT);
        header.addValue(TELESCOP_KW, TELESCOP_VALUE,TELESCOP_COMMENT);
        header.addValue(INSTRUME_KW, INSTRUME_VALUE, INSTRUME_COMMENT);
        header.addValue(DATE_KW, creationTimeStr, 
                    "Date this file was written in yyyy-mm-dd format.");
        header.addValue(ORIGIN_KW, ORIGIN_VALUE, ORIGIN_COMMENT);
        header.addValue(FILENAME_KW, fileName, "");
        header.addValue(RADESYS_KW, RADESYS_VALUE, RADESYS_COMMENT);
        header.addValue(VALIDTIME, validMjd, "MJD time when file becomes valid ");
        header.addValue(PIXELTYP_KW, "cflat", "type of pixel in file: ssflat, cflat, 2d-black");
        header.addValue(DATSETNM_KW, FileNameFormatter.dataSetName(fileName),"");
        
        ImageHDU imageHDU = new ImageHDU(header, null);
        fits.addHDU(imageHDU);
    }
    
    CombinedFlatFieldFits(File fitsFile) throws FitsException {
        fits = new Fits(fitsFile);
        fits.read();
    }
    
    
    void addModuleOutput(float[][] image, int module, int output) 
            throws FitsException {
        
        float maxPixelValue = Float.MIN_VALUE;
        float minPixelValue = Float.MAX_VALUE;
        
        for (float[] data : image) {
            for (float v : data) {
                if (v < minPixelValue) {
                    minPixelValue = v;
                }
                if (v > maxPixelValue) {
                    maxPixelValue = v;
                }
            }
        }
        
        Data imageData = new ImageData(image);
        Header imageHeader = ImageHDU.manufactureHeader(imageData);
        imageHeader.addValue(MODULE_KW, module, "CCD module");
        imageHeader.addValue(OUTPUT_KW, output, "CCD output on module");
        imageHeader.addValue(INHERT_KW, true, "");
        imageHeader.addValue(CHANNEL_KW, FcConstants.getChannelNumber(module, output), "");
        imageHeader.addValue("MINPIXEL", minPixelValue, "minimum pixel value in image extension");
        imageHeader.addValue("MAXPIXEL", maxPixelValue, "maximum pixel value in image extension");

        ImageHDU imageHDU = new ImageHDU(imageHeader, imageData);
        fits.addHDU(imageHDU);
    }
    
    float[][] imageFor(int module, int output) throws FitsException, IOException {
        for (int i=1; i < fits.getNumberOfHDUs(); i++) {
            ImageHDU imageHDU  = (ImageHDU) fits.getHDU(i);
            
            int rmodule = imageHDU.getHeader().getIntValue(MODULE_KW);
            int routput = imageHDU.getHeader().getIntValue(OUTPUT_KW);
            
            if (rmodule != module || routput != output) {
                continue;
            }
            
            Data imageData = imageHDU.getData();
            float[][] floatImageData = (float[][]) imageData.getData();
            return floatImageData;
        }
        
        throw new FitsException("Combined flat field HDU not found for module " + module +
            " output " + output + ".");
    }
    
    double validTime() throws FitsException, IOException {
        Header header = fits.getHDU(0).getHeader();
        return header.getDoubleValue(VALIDTIME);
    }
    
    void write(File output) throws IOException, FitsException {

        BufferedFile outFile = null; 
        try {
            outFile = new BufferedFile(output.toString(), "rw");
            fits.write(outFile);
        } finally {
            if (outFile != null) {
                outFile.close();
            }
        }
        
    }
}
