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

package gov.nasa.kepler.ar.exporter.ffi;

import java.io.IOException;
import java.io.OutputStream;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import gov.nasa.kepler.ar.exporter.*;
import gov.nasa.kepler.common.*;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.KeplerException;
import gov.nasa.kepler.mc.fs.ArFsIdFactory;
import nom.tam.fits.*;
import nom.tam.util.ArrayDataOutput;
import nom.tam.util.BufferedDataOutputStream;
import static gov.nasa.kepler.common.FitsConstants.*;
import static gov.nasa.kepler.common.FitsUtils.*;


/**
 * Generates the image headers, and images used
 * to create the calibrated ffi files.
 * 
 * @author Sean McCauliff
 *
 */
public class FfiFragmentGenerator {

    private static final Log log = LogFactory.getLog(FfiFragmentGenerator.class);
    
    private final static double c0StartMjd;
    static {
        SimpleDateFormat dateParser = new SimpleDateFormat("dd MMM yyyy");
        try {
            c0StartMjd = ModifiedJulianDate.dateToMjd(dateParser.parse("30 May 2013"));
        } catch (ParseException e) {
            throw new RuntimeException(e);
        }
    }
    
    public void generateFragment(FfiFragmentGeneratorSource source) throws Exception {
        
        BasicHDU primaryHdu = source.primaryHdu();
        ImageHDU originalFfiImageHdu  = source.calibratedFfiImageHdu();
        Header originalHeader = originalFfiImageHdu.getHeader();
        
        FfiIImageHeaderKeywordExtractor originalValues = createKeywordValueExtractor(originalHeader);
        FfiPrimaryHeaderKeywordExtractor primaryHeaderValues = 
            createPrimaryKeywordExtractor(primaryHdu.getHeader());
        
        CommonKeywordValues commonValues = 
            new CommonKeywordValues(primaryHeaderValues.common(), primaryHeaderValues.common());
        final double startMjd = commonValues.startMjd();
        final double endMjd =  commonValues.endMjd();
        final int imageHeight = originalValues.imageHeight();
        final int imageWidth = originalValues.imageWidth();
        
        final ConfigMap configMap = source.configMap(startMjd, endMjd);
        
        
        final FfiExposureCalculator ffiExposureCalc = ffiExposureCalculator(startMjd, endMjd, configMap);
        final int ccdModule = originalValues.ccdModule();
        final int ccdOutput = originalValues.ccdOutput();
        final int longReferenceCadence = commonValues.longCadence();
        
        if (longReferenceCadence == 0) {
            throw new IllegalStateException("FFI's LC_INTER does not exist or" +
                " does not contain a valid long cadence for FFI \"" +
                source.fileTimestamp() + "\".");
        }
        
        if (ccdModule != source.ccdModule()) {
            throw new IllegalStateException("Unit of work ccdModule(" + source.ccdModule() 
                + ") != header's ccdModule(" + ccdModule + ").");
        }
        
        if (ccdOutput != source.ccdOutput()) {
            throw new IllegalStateException("Unit of work ccdOutput(" + source.ccdOutput() + 
                ") != header's ccdOutput(" + ccdOutput + ").");
        }
        
        ModOutBarycentricCorrection bcCorrection =  
            source.ffiBarycentricCorrection(startMjd, endMjd,  longReferenceCadence, imageWidth, imageHeight);
        
        final int skyGroup = source.skyGroupId(startMjd, endMjd);
        
        final Times times = 
            generateTimes(startMjd, endMjd, bcCorrection, source.generatedAt());
        
        final double readNoiseE =  source.readNoiseE(startMjd, endMjd);
        
        final double meanBlackCounts = source.meanBlackCounts(startMjd, endMjd);
        
        float[][] originalImage = (float[][]) originalFfiImageHdu.getData().getData();
        final float[][] electronsPerSecondImage = 
            ffiExposureCalc.toElectronsPerSecond(originalImage, imageWidth, imageHeight);
        
        boolean isK2 = times.startMjd > c0StartMjd;
        SipWcsCoordinates sipWcs = source.sipWcs(startMjd, endMjd, longReferenceCadence, imageWidth, imageHeight);
        
        log.info("SIP WCS " + sipWcs);
        
        FitsChecksumOutputStream checksumOutputStream =  new FitsChecksumOutputStream();
        BufferedDataOutputStream bufChecksumOut = new BufferedDataOutputStream(checksumOutputStream);
        
       
        
        FfiImageHeaderSource headerSource =
            createImageHeaderSource(meanBlackCounts, readNoiseE, times, ccdModule, ccdOutput,
            CHECKSUM_DEFAULT, skyGroup, imageWidth, imageHeight,
            ffiExposureCalc, bcCorrection, isK2);

        FfiImageHeaderFormatter imageHeaderFormatter = new FfiImageHeaderFormatter();
        Header imageHeader = imageHeaderFormatter.formatImageHeader(headerSource, sipWcs);
        imageHeader.write(bufChecksumOut);
        
        writeImage(electronsPerSecondImage, imageWidth, imageHeight, bufChecksumOut);
        bufChecksumOut.close();
        
        //Now that the checksum has been computed write out the actual image file.
        headerSource = createImageHeaderSource(meanBlackCounts, readNoiseE, times, ccdModule, ccdOutput,
            checksumOutputStream.checksumString(), skyGroup, imageWidth, imageHeight,
            ffiExposureCalc, bcCorrection, isK2);
        FsId calId = 
            ArFsIdFactory.getSingleChannelFfiFile(source.fileTimestamp(),source.ffiType(), ccdModule, ccdOutput);
        OutputStream fsOutput = fileStoreOutputStream(source, calId);
        

        BufferedDataOutputStream bufFsOutput = new BufferedDataOutputStream(fsOutput);
        
        //Write fake primary header here for debugging purposes.  You could
        //get this file right out of the file store server and feed it to fv
        Header fakePrimary = generateTemporaryPrimaryHeader();
        fakePrimary.write(bufFsOutput);
        imageHeader = imageHeaderFormatter.formatImageHeader(headerSource, sipWcs);
        imageHeader.write(bufFsOutput);
        writeImage(electronsPerSecondImage, imageWidth, imageHeight, bufFsOutput);
        bufFsOutput.close();

    }


    protected OutputStream fileStoreOutputStream(
        FfiFragmentGeneratorSource source, FsId calId) throws IOException {
        OutputStream fsOutput = source.fsClient().writeBlob(calId, source.piplineTaskId());
        return fsOutput;
    }

    
    protected  FfiExposureCalculator ffiExposureCalculator(final double startMjd, final double endMjd,
        final ConfigMap configMap) throws Exception {
        final FfiExposureCalculator ffiExposureCalc = 
            new FfiExposureCalculator(configMap, startMjd, endMjd);
        return ffiExposureCalc;
    }
    
  
    
    private void writeImage(final float[][] image,
        final int imageWidth, final int imageHeight, ArrayDataOutput dout)
        throws IOException {
        
        for (int rowi=0; rowi  < imageHeight; rowi++) {
            for (int coli=0; coli < imageWidth; coli++) {
                dout.writeFloat(image[rowi][coli]);
            }
        }
        
        //pad
        final long bytesWritten = imageWidth * (long) imageHeight * 4;
        final int padBytes =  HDU_BLOCK_SIZE - (int) (bytesWritten % HDU_BLOCK_SIZE);
        if (padBytes != HDU_BLOCK_SIZE) {
            for (int i=0; i < padBytes;i++) {
                dout.write(0);
            }
        }
    }
    
    private static Times generateTimes(double startMjd, double endMjd, 
        ModOutBarycentricCorrection bcCorrection, Date generatedAt) {
        
        Date startUtc = ModifiedJulianDate.mjdToDate(startMjd);
        Date endUtc = ModifiedJulianDate.mjdToDate(endMjd);
        
        if (bcCorrection == null) {
            return new Times(generatedAt, startMjd, endMjd, null, null, startUtc, endUtc);
        } else {
            float barycentricCorrectionDays = bcCorrection.barycentricCorrection();
            //  These barycentric correction calculations are done in single precision
            //  so as to be consistent with the calculations done with the other
            //  exporters which use the single precision values stored by PA or
            //  generated by the AR matlab module.
            double startBkjd = ModifiedJulianDate.mjdToKjd(startMjd) + barycentricCorrectionDays;
            double endBkjd = ModifiedJulianDate.mjdToKjd(endMjd) + barycentricCorrectionDays;
    
            return new Times(generatedAt, startMjd, endMjd, startBkjd, endBkjd, startUtc, endUtc);
        }
    }
    
    protected FfiPrimaryHeaderKeywordExtractor createPrimaryKeywordExtractor(Header primaryHeader) throws KeplerException {
        return new FfiPrimaryHeaderKeywordExtractor(primaryHeader);
    }
    
    protected FfiIImageHeaderKeywordExtractor createKeywordValueExtractor(Header imageHeader) throws KeplerException {
        return new FfiIImageHeaderKeywordExtractor(imageHeader);
    }
    
    private Header generateTemporaryPrimaryHeader() throws HeaderCardException {
        Header h = new Header();
        h.addValue(SIMPLE_KW, SIMPLE_VALUE, SIMPLE_COMMENT);
        safeAdd(h, BITPIX_KW, 8, BITPIX_COMMENT);
        safeAdd(h, NAXIS_KW, 0, NAXIS_COMMENT);
        h.addValue(EXTEND_KW, EXTEND_VALUE, EXTEND_COMMENT);
        h.insertComment("This is a bogus header to use when this image is stored in the file store database.");
        return h;
    }
    
    private static final class Times {
        /** Time file was generated at. */
        public final Date generatedAt;
        public final double startMjd;
        public final double endMjd;
        public final Double bkjdStart;
        public final Double bkjdEnd;
        
        /** You still need to format this with the correct time zone when printing. */
        public final Date utcStart;
        /** You still need to format this with the correction time zone when printing. */
        public final Date utcEnd;
        
        Times(Date generatedAt, double startMjd, double endMjd, Double bkjdStart, Double bkjdEnd,
            Date utcStart, Date utcEnd) {
            this.generatedAt = generatedAt;
            this.startMjd = startMjd;
            this.endMjd = endMjd;
            this.bkjdStart = bkjdStart;
            this.bkjdEnd = bkjdEnd;
            this.utcStart = utcStart;
            this.utcEnd = utcEnd;
        }
    }
    
    
    private FfiImageHeaderSource createImageHeaderSource(
        final double meanBlackCounts,
        final double readNoiseE,
        final Times times,
        final int ccdModule, final int ccdOutput,
        final String checksumString,
        final int skyGroup,
        final int imageWidth, final int imageHeight,
        final FfiExposureCalculator exposureCalc,
        final ModOutBarycentricCorrection bcCorrection,
        final boolean isK2) {
        
        return new FfiImageHeaderSource() {
            
            @Override
            public int timeSlice() {
                return FcConstants.getCcdModuleTimeSlice(ccdModule);
            }
            
            @Override
            public double timeResolutionOfDataDays() {
                return times.endMjd - times.startMjd;
            }
            
            @Override
            public double startMjd() {
                return times.startMjd;
            }
            
            @Override
            public int skyGroup() {
                return skyGroup;
            }
            
            @Override
            public int readsPerImage() {
                return exposureCalc.nIntegrationsPerFfiImage();
            }
            
            @Override
            public double readTimeMilliSec() {
                return exposureCalc.readTimeSec();
            }
            
            @Override
            public double readNoiseE() {
                return readNoiseE;
            }
            
            @Override
            public Date observationStartUT() {
                return times.utcStart;
            }
            
            @Override
            public Date observationEndUT() {
                return times.utcEnd;
            }
            
            @Override
            public double meanBlackCounts() {
                return meanBlackCounts;
            }
            
            @Override
            public double integrationTimeSec() {
                return exposureCalc.integrationTimeSec();
            }
            
            @Override
            public int imageWidth() {
                return imageWidth;
            }
            
            @Override
            public int imageHeight() {
                return imageHeight;
            }
            
            @Override
            public Date generatedAt() {
                return times.generatedAt;
            }
            
            @Override
            public double frameTimeSec() {
                return exposureCalc.integrationTimeSec() + exposureCalc.readTimeSec();
            }
            
            @Override
            public double exposureDays() {
                return exposureCalc.exposureDays();
            }
            
            @Override
            public double endMjd() {
                return times.endMjd;
            }
            
            @Override
            public double elaspedTimeDays() {
                return exposureCalc.elaspedTimeDays();
            }
            
            @Override
            public double deadC() {
                return exposureCalc.deadC();
            }
            
            @Override
            public String checksumString() {
                return checksumString;
            }
            
            @Override
            public int ccdOutput() {
                return ccdOutput;
            }
            
            @Override
            public int ccdModule() {
                return ccdModule;
            }
            
            @Override
            public int ccdChannel() {
                return FcConstants.getChannelNumber(ccdModule,ccdOutput);
            }
            
            @Override
            public Double barycentricStart() {
                return times.bkjdStart;
            }
            
            @Override
            public Double barycentricEnd() {
                return times.bkjdEnd;
            }
            
            @Override
            public Double barycentricCorrectionReferenceRow() {
                if (bcCorrection == null) {
                    return null;
                }
                return bcCorrection.referenceCcdRow() + 1; //  FITS uses one's based indexing for images.
            }
            
            @Override
            public Double barycentricCorrectionReferenceColumn() {
                if (bcCorrection == null) {
                    return null;
                }
                return bcCorrection.referenceCcdColumn() + 1;//  FITS uses one's based indexing for images.
            }
            
            @Override
            public Float barycentricCorrection() {
                if (bcCorrection == null) {
                    return null;
                }
                return bcCorrection.barycentricCorrection();
            }

            @Override
            public double livetimeDays() {
                return exposureCalc.liveTimeDays();
            }

            @Override
            public int nIntegrationsCoaddedPerFfiImage() {
                return exposureCalc.nIntegrationsPerFfiImage();
            }

            @Override
            public double fgsFrameTimeMilliS() {
                return exposureCalc.fgsFrameTimeMilliS();
            }

            @Override
            public int nFgsFramesPerIntegration() {
                return exposureCalc.nFgsFramesPerIntegration();
            }
            
            @Override
            public boolean isK2() {
                return isK2;
            }
        };
        
    }
}
