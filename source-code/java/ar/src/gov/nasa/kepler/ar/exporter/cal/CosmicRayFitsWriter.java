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

import static gov.nasa.kepler.common.FitsConstants.*;
import static gov.nasa.kepler.common.FcConstants.*;
import gov.nasa.kepler.common.Cadence;

import java.io.Closeable;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

import nom.tam.fits.*;
import nom.tam.util.BufferedFile;

/**
 * Reads and writes the Cosmic Ray Correction Table.  See the DMC to SOC ICD
 * for more details on the specification of this file.
 * 
 * By convention the collateral pixels should be written in with the
 * target pixels.
 * 
 * @author Sean McCauliff
 */
public class CosmicRayFitsWriter implements Closeable {
    
    protected final int cadence;
    protected final DataType type;
    
    protected final short lcTargDef;
    protected final short scTargDef;
    protected final short bkgTargDef;
    protected final short tarAperDef;
    protected final short bkgAperDef;
    protected final short compressTbl;
    protected final BufferedFile outputFile;
    protected final TargetAndApertureIdMap targetAndApertureIdMap;
    
    
    /**
     *  Note that FFI (Full Frame Image) is not something that we expect to
     *  produce here at the SOC.
     */
    public enum DataType { 
        LONG("long cadence"), SHORT("short cadence"), FFI("FFI");
        
        private final String fitsValue;
    
        private DataType(String fitsValue) {
            this.fitsValue = fitsValue;
        }
        public String fitsValue() {
            return fitsValue;
        }
        
        public static DataType fromFitsValue(String fvalue) {
            if (fvalue.equals(LONG.fitsValue)) {
                return LONG;
            }
            if (fvalue.equals(SHORT.fitsValue)) {
                return SHORT;
            }
            if (fvalue.equals(FFI.fitsValue)) {
                return FFI;
            }
            throw new AssertionError("Unknown data type:" + fvalue);
        }
        
        public static DataType fromCadenceValue(int cadenceType) {
            if (cadenceType == Cadence.CADENCE_LONG) {
                return LONG;
            }
            if (cadenceType == Cadence.CADENCE_SHORT) {
                return SHORT;
            }
            throw new AssertionError("Unknown cadence type:" + cadenceType);
        }
    }
   
    
 

    /**
     * Constructs a new empty cosmic ray correction table fits file,
     * not yet written to disk.
     * 
     * @param dataSetName This can be obtained from the DMC's correction tables.
     * @param lcTargDef long cadence target definition identifier 
     * @param scTargDef short cadence target definition identifier 
     * @param bkgTargDef background definition identifier
     * @param tarAperDef target aperture definition identifier
     * @param bkgAperDef background aperture definition identifier
     * @param compressTbl compression table identifier
     *      * @param fileName This is the name of the file that is written into the
     * FITS FILENAME keyword.
     */
    public CosmicRayFitsWriter(int cadence,  DataType type,
        short lcTargDef,
        short scTargDef,
        short bkgTargDef,
        short tarAperDef,
        short bkgAperDef,
        short compressTbl,
        BufferedFile outputFile,
        String fileName,
        TargetAndApertureIdMap targetAndApertureIdMap
    )  throws FitsException {


        this.cadence = cadence;
        this.type = type;
        this.lcTargDef = lcTargDef;
        this.scTargDef = scTargDef;
        this.bkgTargDef = bkgTargDef;
        this.tarAperDef = tarAperDef;
        this.bkgAperDef = bkgAperDef;
        this.compressTbl = compressTbl;
        this.outputFile = outputFile;
        this.targetAndApertureIdMap = targetAndApertureIdMap;


        if (cadence < 0) {
            throw new IllegalArgumentException("Cadence must be non-negative.");
        }
        
        SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
        Header header = new Header();
        header.setSimple(true);
        header.setNaxes(0);
        header.setBitpix(32); //Otherwise this will not parse.
        header.addValue(EXTEND_KW, true, "File may contain standard extensions.");
        header.addValue(NEXTEND_KW, MODULE_OUTPUTS, "Number of standard extensions.");
        header.addValue(TELESCOP_KW, "Kepler","");
        header.addValue(INSTRUME_KW, "CCD", "");
        //header.addValue(EQUINOX, 2000.0f,"");
        header.addValue(RADESYS_KW, RADESYS_VALUE, RADESYS_COMMENT);
        header.addValue(DATE_KW, dateFormatter.format(new Date()), "UTC time of file creation");
        header.addValue(ORIGIN_KW, "NASA/Ames", "");
        header.addValue(FILENAME_KW, fileName, "The name of this file.");
    
        header.addValue(DATSETNM_KW, dataSetName(fileName), "dataset which this file belongs to");
        header.addValue(DATATYPE_KW, type.fitsValue(), "" );

        header.addValue(CADENNUM_KW, cadence, "long or short cadence number");

        header.addValue(LCTRGDEF_KW, lcTargDef, "long cadence target definition identifier I2 N");
        header.addValue(SCTRGDEF_KW, scTargDef, "short cadence target definition identifier I2 N");
        header.addValue(BKTRGDEF_KW, bkgTargDef, "background definition identifier I2 N");
        header.addValue(TARGAPER_KW , tarAperDef, "target aperture definition identifier I2 N");
        header.addValue(BKG_APER_KW, bkgAperDef, "background aperture definition identifier I2 N");
        header.addValue(COMPTABL_KW, compressTbl,"compression tables identifier");
        
        header.addValue(DATA_REL_KW, DATA_REL_VALUE, DATA_REL_COMMENT);
        header.addValue(QUARTER_KW, QUARTER_VALUE, QUARTER_COMMENT);
        BasicHDU hdu = Fits.makeHDU(header);
        hdu.write(outputFile);

    }

    public int cadence() {
        return cadence;
    }
    
    public TargetAndApertureIdMap tnaMap() {
        return targetAndApertureIdMap;
    }
    
    public void writeModuleOutput(CosmicRayFitsModuleOutput modOut) throws FitsException {
        BinaryTableHDU hdu = modOut.toBinaryTableHdu();
        hdu.write(outputFile);
    }
  
    protected static String dataSetName(String fileName) {
       //As per email from Daryl Swade
       int lastUnderScore = fileName.lastIndexOf('_');
       if (lastUnderScore == -1) {
           throw new IllegalArgumentException("Invalid file name \"" + fileName 
               +"\" lacks an underscore character.");
       }
       String dataSetName = fileName.substring(0,lastUnderScore);
       return dataSetName;
   }
   
   
    public void close() throws IOException {
        this.outputFile.close();
    }
}
