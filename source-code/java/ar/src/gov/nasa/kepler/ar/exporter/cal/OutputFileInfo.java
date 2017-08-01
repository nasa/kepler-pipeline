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

package gov.nasa.kepler.ar.exporter.cal;

import gnu.trove.TIntArrayList;
import gnu.trove.TLongArrayList;
import gov.nasa.kepler.ar.exporter.FileNameFormatter;
import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.mc.dr.MjdToCadence;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import nom.tam.fits.Fits;
import nom.tam.util.BufferedFile;


/**
 * Tracks where the CalibratedPixelExporter should write out the next module/output
 *
 */
class OutputFileInfo {
    
    
    private final static FileNameFormatter fileNameFormatter = 
        new FileNameFormatter();
    private static final Pattern lastTimeStampPattern = 
        Pattern.compile("kplr(\\d+[a-z]?)_");
        
    
    private final Fits headerInfo;
    private final String headerFileName;
    private final PixelDataType pixelDataType;
    private final BufferedFile output;
    private final Fits pmrf;
    private final String pmrfName;
    private final String processingHistoryFileName;
    private final PixelLog pixelLog;
    
    /** The first byte of i */
    private final TLongArrayList headerOffsets = new TLongArrayList(84);
    /** The number of rows to expect for every  module output. */
    private final TIntArrayList naxis2 = new TIntArrayList(84);
    
    /**
     * 
     * @param headerInfo
     * @param headerFileName
     * @param pixelDataType
     * @param pixelLog
     * @param output
     * @param pmrf
     * @param pmrfName
     * @param cosmicRayWriter  This may be null.
     */
    OutputFileInfo(Fits headerInfo, String headerFileName, int longCadenceNumber,
                          PixelDataType pixelDataType, PixelLog pixelLog, 
                           BufferedFile output, Fits pmrf, String pmrfName,
                           MjdToCadence lcMjdToCadence
                           ) {
        
        if (headerInfo == null) {
            throw new NullPointerException("headerInfo");
        }
        if (headerFileName == null) {
            throw new NullPointerException("headerFileName");
        }
        if (pixelDataType == null) {
            throw new NullPointerException("pixelDataType");
        }
        if (pixelLog == null) {
            throw new NullPointerException("pixelLog");
        }
        if (output == null) {
            throw new NullPointerException("output");
        }
        if (pmrf == null) {
            throw new NullPointerException("pmrf");
        }
        if (pmrfName == null) {
            throw new NullPointerException("pmrfName");
        }
        if (lcMjdToCadence == null) {
            throw new NullPointerException("lcMjdToCadence");
        }
        this.headerInfo = headerInfo;
        this.headerFileName = headerFileName;
        this.output = output;
        this.pmrf = pmrf;
        this.pmrfName = pmrfName;
        this.pixelLog = pixelLog;
        this.pixelDataType = pixelDataType;
        
        if (pixelLog.getCadenceType() == Cadence.CADENCE_SHORT) {
            PixelLog lcPixelLog = lcMjdToCadence.pixelLogForCadence(longCadenceNumber);
            if (lcPixelLog == null) {
                throw new IllegalStateException("Can't export short cadence if" +
                    " covering long cadence " + longCadenceNumber +
                    " does not exist.");
            }
            String lastTimeStamp = getLastTimeStamp(lcPixelLog);
            processingHistoryFileName = 
                fileNameFormatter.pixelProcessingHistoryName(lastTimeStamp, true);
        } else  {
            String lastTimeStamp = getLastTimeStamp(pixelLog);
            processingHistoryFileName = 
                fileNameFormatter.pixelProcessingHistoryName(lastTimeStamp,false);
        }
    }
    

    private static String getLastTimeStamp(PixelLog cadenceLog) {
        String fitsFileName = cadenceLog.getFitsFilename();
        Matcher m = lastTimeStampPattern.matcher(fitsFileName);
        if (!m.find()) {
            throw new IllegalArgumentException("Invalid file name \""
                + fitsFileName + "\".");
        }
    
        return m.group(1);
    }
    
    /**
     * The name of the target and aperture map to use for this output file.
     * @return null if this is collateral else returns the name.
     */
    String targetAndApertureMapKey() {
        if (pixelDataType.isCollateral()) {
            return null;
        }
        int index = pmrfName.indexOf('-');
        if (index < 0) {
            //TODO:  This is here so the integration tests will work.
            //right now they use an old naming convention
            index = pmrfName.indexOf('_');
        }
        if (index == -1) {
            throw new IllegalStateException("Bad pmrf name \"" + pmrfName + "\".");
        }
        return pmrfName.substring(0,index);
    }
    
    int cadence() {
        return pixelLog.getCadenceNumber();
    }
    
    int cadenceType() {
        return pixelLog.getCadenceType();
    }
    
    Fits headerInfo() {
    	return headerInfo;
    }
    
    String headerFileName() {
    	return headerFileName;
    }
    
    PixelDataType pixelDataType() {
    	return pixelDataType;
    }
    
    BufferedFile output() {
    	return output;
    }
    Fits pmrf() {
    	return pmrf;
    }
    String pmrfName() {
    	return pmrfName;
    }
    String processingHistoryFileName() {
    	return processingHistoryFileName;
    }
    PixelLog pixelLog() {
    	return pixelLog;
    }
    TLongArrayList headerOffsets() {
    	return headerOffsets;
    }
    TIntArrayList naxis2() {
    	return naxis2;
    }
    
}