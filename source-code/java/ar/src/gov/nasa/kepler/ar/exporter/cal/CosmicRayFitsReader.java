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

import static gov.nasa.kepler.ar.exporter.FileNameFormatter.CR_LONG_CADENCE_COLLATERAL_FNAME;
import static gov.nasa.kepler.ar.exporter.FileNameFormatter.CR_LONG_CADENCE_FNAME;
import static gov.nasa.kepler.ar.exporter.FileNameFormatter.CR_SHORT_CADENCE_COLLATERAL_FNAME;
import static gov.nasa.kepler.ar.exporter.FileNameFormatter.CR_SHORT_CADENCE_FNAME;
import static gov.nasa.kepler.common.FitsConstants.*;
import gov.nasa.kepler.ar.exporter.cal.CosmicRayFitsWriter.DataType;

import java.io.IOException;
import java.io.InputStream;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.BinaryTableHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;
import nom.tam.fits.Header;

/**
 * @author Sean McCauliff
 *
 */
public class CosmicRayFitsReader {

    final short lcTargDef;
    final short scTargDef;
    final short bkgTargDef;
    final short targAperDef;
    final short compressTbl;
    final short bkgAperDef;
    final int cadence;
    final DataType dataType;
    private final String dataSetName;
    private final String fileName;
    private final Fits fits;
    private int hduCount = 1;
    
    CosmicRayFitsReader(InputStream inputFile) throws FitsException, IOException {
        
        fits = new Fits(inputFile);
        BasicHDU basicHdu = fits.getHDU(0);
        Header basicHeader = basicHdu.getHeader();
        String kepler = basicHeader.getStringValue(TELESCOP_KW).trim();
        if (kepler == null || !kepler.equals("Kepler")) {
            throw new IOException("Invalid telescope.  Found \"" 
                + kepler +  "\" but should be \"Kepler\"");
        }
        
        dataType = 
            DataType.fromFitsValue(basicHeader.getStringValue(DATATYPE_KW));
        cadence = basicHeader.getIntValue(CADENNUM_KW);
        lcTargDef = (short) basicHeader.getIntValue(LCTRGDEF_KW);
        scTargDef = (short) basicHeader.getIntValue(SCTRGDEF_KW); 
        bkgTargDef = (short) basicHeader.getIntValue(BKTRGDEF_KW);
        targAperDef = (short) basicHeader.getIntValue(TARGAPER_KW); 
        bkgAperDef = (short) basicHeader.getIntValue(BKG_APER_KW);
        compressTbl = (short) basicHeader.getIntValue(COMPTABL_KW);


        fileName = basicHeader.getStringValue(FILENAME_KW);
        String calculatedDataSetName = CosmicRayFitsWriter.dataSetName(fileName);
        dataSetName = basicHeader.getStringValue(DATSETNM_KW);
        if (!calculatedDataSetName.equals(dataSetName)) {
            throw new IllegalArgumentException("Invalid datasetname.  Found\""+dataSetName +
                " but should be \"" + calculatedDataSetName + "\".");
        }
        
    }
    
    /**
     * 
     * @return The cosmic ray fits data structure.
     * @throws IOException
     * @throws FitsException 
     */
    public CosmicRayFitsModuleOutput read() throws IOException, FitsException {
        
        CosmicRayFitsModuleOutput modOut = null;
        
        if (fileName.endsWith(CR_LONG_CADENCE_COLLATERAL_FNAME) ||
            fileName.endsWith(CR_SHORT_CADENCE_COLLATERAL_FNAME)) {
            
                modOut =  new CollateralCosmicRayModuleOutput((short)-1, (short)-1, cadence, 0.0);
                
        } else if (fileName.endsWith(CR_LONG_CADENCE_FNAME) || 
                        fileName.endsWith(CR_SHORT_CADENCE_FNAME)) {
            
            modOut= new VisibleCosmicRayModuleOutput((short) -1, (short) -1, cadence, 0.0);
        }
        
        BinaryTableHDU binaryTableHDU = (BinaryTableHDU)fits.getHDU(hduCount++);
        modOut.fromBinaryTableHdu(binaryTableHDU);
        return modOut;
    }
}
