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

package gov.nasa.kepler.ar.exporter.cdpp;

import static gov.nasa.kepler.common.FitsConstants.*;
import gov.nasa.kepler.ar.exporter.FitsFileCreationTimeFormat;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.*;
import java.util.Date;

import nom.tam.fits.*;

/** Combined Differential Photometric Precision fits file
 * format.  See the SAS to SOC ICD.  And the TPS SDD for more information.
 * 
 * @author Sean McCauliff
 *
 */
class CdppFitsFile {

    private static final String THREE_HR_AP = "cdpp_3h_ap";
    private static final String THREE_HR_AP_COMMENT = "AP CDPP for trial transit pulse 3 hr";
    private static final String SIX_HR_AP = "cdpp_6h_ap";
    private static final String SIX_HR_AP_COMMENT = "AP CDPP for trial transit pulse 6 hr";
    private static final String TWELEVE_HR_AP = "cdpp_12hr_ap";
    private static final String TWELEVE_HR_AP_COMMENT = "AP CDPP for trial transit pulse 12 hr";
    private static final String CDPP_UNIT = "parts per million";
    private static final String CDPP_FORM = "1E";
    private static final String CDPP_DISP = "F10.3";
    
    private final double startMjd;
    private final double endMjd;
    private final float[] threeHourTrialTransitPulseAp;
    private final float[] sixHourTrialTransitPulseAp;
    private final float[] tweleveHourTrialTransitPulseAp;
    private final double[] bkjd;
    private final int[] cadenceNumbers;
    private final int keplerId;
    
    
    /**
     * @param startMjd
     * @param startCadence
     * @param threeHourTrialTransitPulseDia
     * @param sixHourTrialTransitPulseDia
     * @param tweleveHourTrialTransitPulseDia
     * @param threeHourTrialTransitPulseAp
     * @param sixHourTrialTransitPulseAp
     * @param tweleveHourTrialTransitPulseAp
     * @param offsetSeconds
     * @param keplerId
     * @param aperturePhotometryType
     */
    public CdppFitsFile(int keplerId, double startMjd, double endMjd,
        float[] threeHourTrialTransitPulseAp,
        float[] sixHourTrialTransitPulseAp,
        float[] tweleveHourTrialTransitPulseAp, 
        double[] bkjd, int[] cadenceNumbers) {
        

        this.startMjd = startMjd;
        this.endMjd = endMjd;
        this.threeHourTrialTransitPulseAp = threeHourTrialTransitPulseAp;
        this.sixHourTrialTransitPulseAp = sixHourTrialTransitPulseAp;
        this.tweleveHourTrialTransitPulseAp = tweleveHourTrialTransitPulseAp;
        this.bkjd = bkjd;
        this.keplerId = keplerId;
        this.cadenceNumbers = cadenceNumbers;
    }

    public void write(File outputFile) throws IOException, FitsException {
        
        
        DataOutputStream dout = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(outputFile)));
        try {
            write(outputFile, dout);
        } finally {
            FileUtil.close(dout);
        }
        
    }

    private void write(File outputFile, DataOutputStream dout)
        throws HeaderCardException, FitsException {
        FitsFileCreationTimeFormat creationTime = new FitsFileCreationTimeFormat();
        String creationTimeStr = creationTime.format(new Date());
        
        Header header = new Header();
        header.setSimple(true);
        header.setBitpix(8);
        header.setNaxes(0);
        header.addValue(EXTEND_KW, EXTEND_VALUE, EXTEND_COMMENT);
        header.addValue(NEXTEND_KW, 1, NEXTEND_COMMENT);
        header.addValue(TELESCOP_KW, TELESCOP_VALUE,TELESCOP_COMMENT);
        header.addValue(INSTRUME_KW, INSTRUME_VALUE, INSTRUME_COMMENT);
        header.addValue(EQUINOX, 2000.0f,
            "Equinox of the celestial coord. system.");
        header.addValue(DATE_KW, creationTimeStr,
            "Date this file was written in yyyy-mm-dd format.");
        header.addValue(ORIGIN_KW, ORIGIN_VALUE, ORIGIN_COMMENT);
        header.addValue(FILENAME_KW, outputFile.getName(), "");
        header.addValue(LC_START_KW, startMjd, LC_START_COMMENT);
        header.addValue(LC_END_KW, endMjd, LC_END_COMMENT);
        header.addValue(KEPLERID_KW, keplerId, KEPLERID_COMMENT);
        
        BasicHDU primaryHdu = Fits.makeHDU(header);
        
        Object[] timeSeriesData = new Object[5];
        int dataIndex = 0;
        timeSeriesData[dataIndex++] = bkjd;
        timeSeriesData[dataIndex++] = cadenceNumbers;
        timeSeriesData[dataIndex++] = threeHourTrialTransitPulseAp;
        timeSeriesData[dataIndex++] = sixHourTrialTransitPulseAp;
        timeSeriesData[dataIndex++] = tweleveHourTrialTransitPulseAp;

        
        Data binaryTableData = BinaryTableHDU.encapsulate(timeSeriesData);
        Header binaryTableHeader = BinaryTableHDU.manufactureHeader(binaryTableData);
        int colNumber = 1;
        addBinaryTableColumn(binaryTableHeader, colNumber++, 
            TIME_TCOLUMN, TIME_TCOLUMN_COMMENT, "1D", TIME_TCOLUMN_DISPLAY_HINT, TIME_TCOLUMN_UNIT);
        addBinaryTableColumn(binaryTableHeader, colNumber++, 
                             CADENCENO_TCOLUMN, CADENCENO_TCOLUMN_COMMENT, "1J", CADENCENO_TCOLUMN_HINT, "");
        addBinaryTableColumn(binaryTableHeader, colNumber++,
            THREE_HR_AP, THREE_HR_AP_COMMENT, CDPP_FORM, CDPP_DISP, CDPP_UNIT);
        addBinaryTableColumn(binaryTableHeader, colNumber++,
            SIX_HR_AP, SIX_HR_AP_COMMENT, CDPP_FORM, CDPP_DISP, CDPP_UNIT);
        addBinaryTableColumn(binaryTableHeader, colNumber++,
            TWELEVE_HR_AP, TWELEVE_HR_AP_COMMENT, CDPP_FORM, CDPP_DISP, CDPP_UNIT);

        
        BinaryTableHDU binaryTableHdu = 
            new BinaryTableHDU(binaryTableHeader, binaryTableData);
        
        Fits fits = new Fits();
        fits.addHDU(primaryHdu);
        fits.addHDU(binaryTableHdu);
        fits.write(dout);
    }
   
    public static CdppFitsFile read(File inputFile) 
        throws FitsException, IOException {
        
        DataInputStream din = new DataInputStream(new BufferedInputStream(new FileInputStream(inputFile)));
        try {
            Fits inputFits = new Fits(din);
            BasicHDU primaryHdu = inputFits.readHDU();
            Header primaryHeader = primaryHdu.getHeader();
            if (!primaryHdu.getInstrument().equals(INSTRUME_VALUE)) {
                throw new IllegalArgumentException("instrument should be CCD");
            }
            if (!primaryHdu.getTelescope().equals(TELESCOP_VALUE)) {
                throw new IllegalArgumentException("Telescope should be Kepler.");
            }
            
            String fname = primaryHeader.getStringValue(FILENAME_KW);
            if (!fname.equals(inputFile.getName())) {
                throw new IllegalArgumentException("Fits file name does not match.");
            }
            
            double startMjd = primaryHeader.getDoubleValue(LC_START_KW);
            double endMjd = primaryHeader.getDoubleValue(LC_END_KW);
            int keplerId = primaryHeader.getIntValue(KEPLERID_KW);
            
            BinaryTableHDU dataHdu = (BinaryTableHDU) inputFits.readHDU();
            double[] bkjd = (double[]) dataHdu.getColumn(TIME_TCOLUMN);
            int[] cadenceNumbers = (int[]) dataHdu.getColumn(CADENCENO_TCOLUMN);
            float[] cdppThreeHrAp = (float[]) dataHdu.getColumn(THREE_HR_AP);
            float[] cdppSixHrAp = (float[]) dataHdu.getColumn(SIX_HR_AP);
            float[] cdppTweleveHrAp = (float[]) dataHdu.getColumn(TWELEVE_HR_AP);
;
            
            CdppFitsFile cdppFitsFile = 
                new CdppFitsFile(keplerId, startMjd, endMjd,
                    cdppThreeHrAp, cdppSixHrAp, cdppTweleveHrAp, bkjd, cadenceNumbers);
            return cdppFitsFile;
            
        } finally {
            FileUtil.close(din);
        }
    }
    private static void addBinaryTableColumn(Header header, int colNumber, 
        String colType, String colTypeComment, String form, String display, String unit) throws HeaderCardException {
        header.addValue("TTYPE" + colNumber, colType, colTypeComment);
        header.addValue(TFORM_KW + colNumber, form, "");
        header.addValue("TDISP" + colNumber, display, "");
        header.addValue("TUNIT" + colNumber, unit, "");
    }

    public double getStartMjd() {
        return startMjd;
    }


    public float[] getThreeHourTrialTransitPulseAp() {
        return threeHourTrialTransitPulseAp;
    }

    public float[] getSixHourTrialTransitPulseAp() {
        return sixHourTrialTransitPulseAp;
    }

    public float[] getTweleveHourTrialTransitPulseAp() {
        return tweleveHourTrialTransitPulseAp;
    }


    public int getKeplerId() {
        return keplerId;
    }

}
