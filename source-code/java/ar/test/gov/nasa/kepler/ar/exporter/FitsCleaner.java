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

import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.util.Arrays;
import java.util.Iterator;
import java.util.Random;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.BinaryTableHDU;
import nom.tam.fits.Data;
import nom.tam.fits.Fits;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCard;

/**
 * Fills a pixel fits file with filler data.  This is used to generate test
 * calibrated pixel files.
 * 
 * @author Sean McCauliff
 *
 */
public class FitsCleaner {

    /**
     * argv[0] pixel fits file to modify.
     * argv[1] name of pixel mapping reference file to use.
     * argv[2] The data fill value.
     * @param args
     */
    public static void main(String[] argv) throws Exception  {
        Fits fits = new Fits(new File(argv[0]));
        Fits fitsOut = new Fits();
        fits.read();
        BasicHDU mainHdu = (BasicHDU) fits.getHDU(0);
        String pmrfFileName = argv[1];
        //Technically this is not correct, but it gets the job done.
        mainHdu.addValue(LONG_CADENCE_PMRF_KW, pmrfFileName, "");
        mainHdu.addValue(SHORT_CADENCE_PMRF_KW, pmrfFileName, "");
        mainHdu.addValue(BACKGROUND_PMRF_KW,pmrfFileName, "");
        mainHdu.addValue(LONG_CADENCE_COLLATERAL_PMRF_KW, pmrfFileName, "");
        mainHdu.addValue(SHORT_CADENCE_COLLATERAL_PMRF_KW, pmrfFileName, "");
        int cadenceNo = mainHdu.getHeader().getIntValue(CADENNUM_KW);
        fitsOut.addHDU(mainHdu);
        int fill = Integer.parseInt(argv[2]);
        for (int i=1; i < fits.getNumberOfHDUs(); i++) {
            System.out.println("Processing HDU " + i);
            BinaryTableHDU binaryHDU = (BinaryTableHDU) fits.getHDU(i);
            int[] orig = (int[]) binaryHDU.getColumn(0);
            int length = Math.min(100, orig.length);
            //float[] dcal = (float[]) binaryHDU.getColumn(1);
            float[] dcal = new float[length];
            int[] newOrig = new int[length];
            float[] uncert = new float[length];
            Arrays.fill(newOrig, fill);
            Arrays.fill(dcal, fill - 1);
            Arrays.fill(uncert, fillValueForCadence(cadenceNo));
            Object[] data = new Object[3];
            data[0] = newOrig;
            data[1] = dcal;
            data[2] = uncert;
            
            Data dataOut = BinaryTableHDU.encapsulate(data);
            Header headerOut = BinaryTableHDU.manufactureHeader(dataOut);
            Header inHeader = binaryHDU.getHeader();
            @SuppressWarnings("unchecked")
            Iterator<HeaderCard> it = inHeader.iterator();
            while (it.hasNext()) {
                HeaderCard card =  it.next();
                String key = card.getKey();
                if (key.startsWith(NAXIS_KW)) continue;
                if (key.startsWith("BIT")) continue;
                if (key.equals("TFORM2")) continue;
                headerOut.addLine(card);
            }
            headerOut.addValue("TFORM2", "1E", "");
            headerOut.addValue("TDISP2", "F16.3","");
            headerOut.addValue("TUNIT2", "e-","");
            headerOut.addValue("TFORM3", "1E", "");
            headerOut.addValue("TDISP3", "F16.3", "");
            headerOut.addValue("TTYPE3", "cal_uncert","");
            headerOut.addValue("TUNIT3", "sd e-", "");
            headerOut.addValue(NAXIS1_KW, 12,"");
            headerOut.addValue(TFIELDS_KW, 3, "");
            BinaryTableHDU binOut = 
                new BinaryTableHDU( headerOut, dataOut);
            fitsOut.addHDU(binOut);

        }
        
        DataOutputStream dout =
            new DataOutputStream(new FileOutputStream(new File(argv[0]+ ".out")));
        fitsOut.write(dout);
        dout.close();

    }
    
    private static float fillValueForCadence(int cadenceNo) {
    	Random r = new Random(10);
    	for (int i=0; i < cadenceNo; i++) {
    		r.nextFloat();
    	}
    	
    	return r.nextFloat();
    }

}
