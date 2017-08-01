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
import java.util.Iterator;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.BinaryTableHDU;
import nom.tam.fits.Data;
import nom.tam.fits.Fits;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCard;
import nom.tam.util.ColumnTable;

/**
 * This is a tool to generate FITS test data.
 * 
 * @author Sean McCauliff
 *
 */
public class TruncateData {

    /**
     * @param args
     */
    public static void main(String[] argv) throws Exception {
        Fits fits = new Fits(new File(argv[0]));
        Fits fitsOut = new Fits();
        fits.read();
        fitsOut.addHDU((BasicHDU) fits.getHDU(0));
        for (int hdui=1; hdui < fits.getNumberOfHDUs(); hdui++) {
            BinaryTableHDU binTable = (BinaryTableHDU) fits.getHDU(hdui);
            ColumnTable  inData = (ColumnTable)binTable.getData().getData();
            Object[] outCols = new Object[inData.getNCols()];
            for (int datai=0; datai < inData.getNCols(); datai++) {
                outCols[datai] = truncateData(inData.getColumn(datai), 100);
            }
            
            Data dataOut = BinaryTableHDU.encapsulate(outCols);
            Header headerOut = BinaryTableHDU.manufactureHeader(dataOut);
            Header inHeader = binTable.getHeader();
            Iterator<?> it = inHeader.iterator();
            while (it.hasNext()) {
                HeaderCard card = (HeaderCard) it.next();
                String key = card.getKey();
                if (key.startsWith(NAXIS_KW)) continue;
                if (key.startsWith("BIT")) continue;
                headerOut.addLine(card);
            }
            BinaryTableHDU binOut = 
                new BinaryTableHDU( headerOut, dataOut);
            fitsOut.addHDU(binOut);
        }
        
        
        DataOutputStream dout =
            new DataOutputStream(new FileOutputStream(new File(argv[0]+ ".out")));
        fitsOut.write(dout);
        dout.close();
        
    }

    /**
     * 
     * @param o Is an array of some some primitive type.
     * @return An array of the primitive type, except truncated to the specified
     * length or the size of the original array which ever is smaller.
     */
    
    private static Object truncateData(Object o, int maxLen) {
        int[] iarray = new int[0];
        short[] sarray = new short[0];
        float[] farray = new float[0];
        byte[] barray = new byte[0];
        
        if (o.getClass() == iarray.getClass()) {
            int[] src = (int[]) o;
            int[] rv = new int[Math.min(maxLen, src.length)];
            System.arraycopy(src, 0, rv, 0, rv.length);
            return rv;
        } else if (o.getClass() == sarray.getClass()) {
            short[] src = (short[]) o;
            short[] rv = new short[Math.min(maxLen, src.length)];
            System.arraycopy(src, 0, rv, 0, rv.length);
            return rv;
        } else if (o.getClass() == farray.getClass()) {
            float[] src = (float[]) o;
            float[] rv = new float[Math.min(maxLen, src.length)];
            System.arraycopy(src, 0, rv, 0, rv.length);
            return rv;         
        } else if (o.getClass() == barray.getClass()) {
            byte[] src = (byte[]) o;
            byte[] rv = new byte[Math.min(maxLen, src.length)];
            System.arraycopy(src, 0, rv, 0, rv.length);
            return rv;
        }
        
        throw new IllegalArgumentException("Unsupported array class:" + o.getClass());
    }
}
